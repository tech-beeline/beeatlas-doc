# Загрузка из Structurizr (structurizr-sequence)

## Что загружается

`structurizr-sequence` — C4-модель одного продукта (контейнеры, технические возможности, интерфейсы, операции) вместе со сценариями вызовов (Dynamic Views) из его `workspace.json` в Structurizr. В отличие от e2e-sequence, здесь **нет** внешней публикации — результат сохраняется только в собственные канонические таблицы staging-service.

## Подключение

Здесь нет отдельной БД — источник данных для каждого продукта задаётся **на стороне fdm-products**, полем `structurizrApiUrl` в карточке продукта (плюс `structurizrWorkspaceName`; поля `structurizrApiKey`/`structurizrApiSecret` в fdm-products тоже есть, но в staging-service сейчас не прокидываются и не используются — адаптер обращается к `{structurizrApiUrl}/json` без какой-либо авторизации).

> Если для продукта в fdm-products не заполнен `structurizrApiUrl` — pre-adapter его просто не увидит, никакой ошибки не будет.

## Периодичность

По умолчанию раз в **час** (`schedule_interval_seconds = 3600` в `staging.configurations`, конфигурация `structurizr-sequence-default`). Меняется обычным `UPDATE` этой таблицы — см. [общую страницу настройки](overview.md#как-настраивается-расписание).

## Как находятся продукты (pre-adapter)

Pre-adapter опрашивает fdm-products и получает список мнемоник (alias) всех продуктов, у которых заполнен `structurizrApiUrl` — то есть продуктов, для которых в Structurizr вообще описана архитектура.

## Как устроено извлечение (adapter)

Для каждого продукта адаптер скачивает `{structurizrApiUrl}/json` — это **чистый passthrough**: ответ Structurizr API сохраняется в `staging.raw_data_refs` байт-в-байт, без парсинга и модификации (с тем же дедупом по `content_hash`, что и у Sparx). Что бы Structurizr ни вернул (или не вернул) — это будет то, что реально хранится в источнике; адаптер ничего не досочиняет и ничего не обрезает.

## Как определяется целевая система

Один workspace может содержать несколько `softwareSystem`. Целевая система находится сопоставлением `model.properties.workspace_cmdb` (CMDB-код продукта) с `softwareSystem.properties."structurizr.dsl.identifier"` — обрабатывается только она, остальные `softwareSystem` в том же workspace игнорируются.

## Правила извлечения C4-элементов

| Элемент C4 | Куда попадает | Как формируется `uid` |
|---|---|---|
| `container` | `containers`/`container_versions` | `properties.external_name` |
| `component` с `type=capability` | `tech_capabilities`/`tech_capability_versions` | `{cmdb}.{properties.code}` |
| `component` с `type=api` | `interfaces`/`interface_versions` | `properties.external_name` |
| Ключ `properties` такого api-компонента (кроме служебных: `external_name`, `api_url`, `protocol`, `version`, `tc`, `code`, `parents`, `source`) | `operations`/`operation_versions` | `{interface_uid}_{нормализованное_имя}`; значение свойства — SLA-строка вида `RPS=..;LATENCY=..;ERROR_RATE=..;TC=..` (поддержаны оба разделителя, `:` и `=`) |
| `views.dynamicViews[]`, отфильтрованные по `elementId` целевой системы | `sequences`/`sequence_versions` | `key` (или `{cmdb}.{key}`, если `key` без точки) |

Каждый шаг вызова (`dynamicView.relationships[]`) резолвится в конкретную операцию по описанию — тем же способом, которым при извлечении операций строится ключ из свойства интерфейса: `"{METОД} {путь}"` в нижнем регистре для REST (метод ищется в тексте описания целиком, не обязательно в самом начале — человекочитаемый текст перед методом допустим), либо просто нижний регистр имени метода для SOAP.

## Валидация

Продукт проходит validator, только если **хотя бы один** `dynamicView` в его workspace реально вызывает операцию, объявленную в `properties` одного из его `type=api`-компонентов — иначе стадия падает с error-нотисом и дальше не идёт. Отсутствие `views.dynamicViews` как такового (продукт без единой диаграммы вызовов) — это отдельный, некритичный случай: он просто фиксируется info/warning-заметкой, стадия не падает, сущности сохраняются без сценариев.

## Сохранение

`StructurizrSequenceCanonicalSaver` пишет канонические сущности строго по цепочке зависимостей (продукт → контейнеры → технические возможности → интерфейсы → операции → сценарии), резолвя FK каждого следующего слоя на предыдущий по `uid` через соответствующий `*MatchService`. Подробности схемы — в [README staging-service](https://git.vimpelcom.ru/products/eafdmmart/staging-service/-/blob/develop/README.md), раздел "Каноническая модель".
