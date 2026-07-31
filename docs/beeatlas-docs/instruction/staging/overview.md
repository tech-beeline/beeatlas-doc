# Staging Service: принципы и настройка

## Обзор

**Staging Service** — конфигурируемый ETL-пайплайн, который периодически забирает архитектурные данные из внешних источников (Sparx EA, Structurizr), приводит их к единой канонической модели (продукты/контейнеры/интерфейсы/операции/сценарии) и часть из них публикует в fdm-products.

Сейчас поддерживаются два типа данных:

- **[Structurizr (structurizr-sequence)](structurizr.md)** — C4-модель продукта и сценарии вызовов (Dynamic Views) из workspace.json конкретного продукта в Structurizr;
- **[Sparx EA (e2e-sequence)](sparx.md)** — сквозные (e2e) бизнес-сценарии, собранные из диаграмм последовательностей в корпоративном репозитории Sparx EA.

Оба типа проходят один и тот же конвейер стадий:

```
pre-adapter → adapter → validator → transformer → saver
```

- **pre-adapter** — находит список артефактов в источнике (какие продукты/сценарии вообще нужно забрать);
- **adapter** — скачивает сырые данные одного артефакта и кладёт их в `staging.raw_data_refs` (с дедупом по хешу содержимого — если с прошлого раза ничего не изменилось, новая строка не создаётся);
- **validator** — проверяет сырые данные на структурную и бизнес-корректность;
- **transformer** — превращает сырые данные в канонический снимок сущностей;
- **saver** — сохраняет снимок в канонические таблицы (и, для e2e-sequence, публикует результат в fdm-products).

Технически конвейер реализован как Camunda BPMN-процесс `artifact-pipeline-process`: один процесс на конфигурацию × момент запуска, внутри — multi-instance подпроцесс `adapter → validator → transformer → saver` по одной итерации на каждый найденный pre-adapter'ом артефакт (итерации идут строго последовательно, не параллельно).

## Как настраивается расписание

Что и как часто загружать, определяет таблица `staging.configurations`:

| Колонка | Смысл |
|---|---|
| `code` | Человекочитаемый уникальный код конфигурации (например, `e2e-sequence-default`) |
| `artifact_type` | Тип артефакта — `structurizr-sequence` или `e2e-sequence` |
| `data_type_id` | Ссылка на `staging.data_types` |
| `source_system_id` | Ссылка на `staging.source_systems` |
| `schedule_interval_seconds` | Как часто перезапускать скан (в секундах) |
| `is_active` | Включена ли конфигурация вообще |

Раз в `staging.scheduler.tick-interval-ms` (по умолчанию 60000 мс = 1 минута) `PipelineTickScheduler` проверяет все активные конфигурации: если с последнего завершённого запуска этой конфигурации прошло больше `schedule_interval_seconds` **и** для неё сейчас нет активного (незавершённого) запуска — стартует новый Camunda-процесс.

> **Важно:** пока для `artifact_type` нет активной строки в `staging.configurations`, пайплайн для этого типа не запускается вообще — без единой ошибки в логах. Это единственное место конфигурации, которое не подтягивается автоматически из кода; список модулей на каждую стадию (`PipelineDefinitions`) синхронизируется с кодом сам, а вот включать/выключать и задавать периодичность конкретного типа данных нужно руками через эту таблицу.

Пример: изменить периодичность e2e-sequence на 15 минут —

```sql
UPDATE staging.configurations
SET schedule_interval_seconds = 900
WHERE code = 'e2e-sequence-default';
```

## Ручной запуск, не дожидаясь расписания

Для e2e-sequence есть отдельный admin-эндпоинт, который сразу стартует скан для всех активных конфигураций этого типа (пропускает те, для которых уже что-то выполняется):

```
POST /admin/scan/e2e
```

Если конкретный запуск (строка `staging.pipeline_runs`) упал и его нужно повторить:

```
POST /admin/pipeline-runs/{runId}/retry?retries=3
```

Если завис/исчерпал ретраи конкретный шаг конвейера (Camunda external task) — можно сбросить его ретраи напрямую:

```
POST /admin/external-tasks/{taskId}/retry?retries=3
```

## Где смотреть, что происходит

| Вопрос | Где искать |
|---|---|
| Что и когда скачали, по какому идентификатору | `staging.raw_data_refs` |
| Статус конкретного запуска (pending/loading/…/completed/failed) | `staging.pipeline_runs` |
| Что произошло на каждой стадии конкретного запуска | `staging.pipeline_stage_logs` (`input_data`/`output_data`) |
| Визуально, через UI Camunda | Camunda Cockpit — путь `/camunda` на инстансе staging-service, логин задаётся `camunda.bpm.admin-user` (по умолчанию на локальном стенде `beeatlas`/`beeatlas`) |

Каждая заметная деталь, которую пайплайн заметил на стадии validate/transform/save (предупреждение валидации, "почему эта версия сущности создана заново / сматчена с существующей" и т.п.), сохраняется как **notice** в `staging.artifact_notices`, с привязкой к справочнику различимых кодов `staging.notice_types`. Новый код сначала попадает туда в состоянии `pending` — администратор может подтвердить его как ожидаемый или пометить как шумный:

```
GET  /admin/notice-types?state=pending
POST /admin/notice-types/{code}/confirm?confirmedBy=...
POST /admin/notice-types/{code}/reject?rejectedBy=...
```

После `reject` новые occurrence с этим кодом просто перестают сохраняться — полезно для кодов, которые оказались слишком шумными и не несут практической ценности.

## Инфраструктура: две отдельные схемы БД

Staging Service использует **две независимые схемы** в одной Postgres-базе:

- `staging` — собственные (бизнес) таблицы сервиса: `raw_data_refs`, `pipeline_runs`, канонические таблицы и т.д. Миграции — обычные Flyway-подобные SQL-файлы в `db/migration/`, накатываются вручную (`spring.flyway.enabled: false`), автосинхронизации с JPA-сущностями нет.
- `staging_camunda` (имя задаётся `STAGING_CAMUNDA_SCHEMA`, по умолчанию `staging_camunda`) — собственные служебные таблицы движка Camunda (`ACT_*`). Схема создаётся приложением автоматически при старте (`CREATE SCHEMA IF NOT EXISTS`), таблицы внутри неё разворачивает сам Camunda (`camunda.bpm.database.schema-update: true`).

> **Важно для окружений, где Postgres шарится с другими сервисами:** датасорс Camunda сознательно ограничивает `search_path` только этой схемой, без fallback на `public`. Если этого не сделать и по какой-то причине `staging_camunda` окажется пустой/недоступной, Camunda молча найдёт таблицы движка где-то ещё в `search_path` и начнёт работать там — вплоть до смешивания с данными совершенно другого приложения. Trust the schema isolation, don't remove it.

## Дальше

- [Загрузка из Sparx EA (e2e-sequence)](sparx.md)
- [Загрузка из Structurizr (structurizr-sequence)](structurizr.md)
