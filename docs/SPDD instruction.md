# Structured Prompt Driven Design — How-To Guide

Этот документ описывает методологию **Structured Prompt Driven Design (SPDD)** и предоставляет инструкции по использованию шаблонов и промптов в рамках данного подхода.

## 📋 Что такое Structured Prompt Driven Design?

Structured Prompt Driven Design — это методология разработки, основанная на использовании структурированных промптов для создания артефактов проекта. Ключевые принципы:

- **Промпты как источник истины** — все артефакты создаются на основе чётко определённых промптов
- **Строгое следование шаблонам** — каждый тип артефакта имеет свой шаблон
- **Итеративная разработка** — анализ → спецификация → реализация → проверка
- **Валидация на каждом шаге** — артефакты должны быть валидными и открываться без ошибок

## 📁 Предлагаемая структура проекта для применения SPDD

```
project/
├── templates/                    # Шаблоны артефактов
│   ├── adr-template.md          # Шаблон ADR (Architecture Decision Record)
│   ├── cj_prompt.md             # Промпт для создания Customer Journey BPMN
│   ├── cj_template.bpmn         # Пример CJ в формате Camunda Modeler
│   ├── reasons-canvas-template.md # Шаблон REASONS Canvas
│   └── workspace.dsl            # Шаблон архитектуры в Structurizr DSL
├── documentation/
│   ├── prompts/                 # Промпты для генерации артефактов
│   │   └── create-specification.md
│   ├── adr/                     # Архитектурные решения
│   ├── cj/                      # Customer Journey диаграммы
│   └── requirements/            # Требования
└── README.md                    # Этот файл
```

## 🎯 Шаблоны и промпты

| Шаблон / Промпт | Описание | Ссылка |
|----------------|----------|--------|
| **REASONS Canvas** | Структурированное описание изменений (требования, сущности, подход, структура, операции, нормы, safeguards) | [`templates/reasons-canvas-template.md`](spdd_templates/reasons-canvas-template.md) |
| **ADR** | Architecture Decision Record — фиксация архитектурных решений | [`templates/adr-template.md`](spdd_templates/adr-template.md) |
| **CJ Prompt** | Промпт для создания Customer Journey в BPMN 2.0 | [`templates/cj_prompt.md`](spdd_templates/cj_prompt.md) |
| **CJ Template** | Пример Customer Journey в формате Camunda Modeler | [`templates/cj_template.bpmn`](spdd_templates/cj_template.bpmn) |
| **Workspace DSL** | Шаблон архитектуры в нотации Structurizr DSL | [`templates/workspace.dsl`](spdd_templates/workspace.dsl) |
| **create-specification** | Основной промпт для генерации всех артефактов проекта | [`documentation/prompts/create-specification.md`](spdd_templates/create-specification.md) |

## 🔄 Процесс работы по SPDD

### Основной промпт: create-specification.md

Ключевой промпт методологии — [`documentation/prompts/create-specification.md`](spdd_templates/create-specification.md). Он генерирует все основные артефакты проекта на основе шаблонов:

```text
Цель: подготовить анализ и план разработки приложения по моделированию бизнес процессов.

Сначала ничего не меняй в коде. Выполни только анализ, предложи план и подготовь содержание для `documentation/prompts/analysis.md`.

Используй:
- documentation/*.md как исходное задание
- templates/reasons-canvas-template.md как формат structured prompt для reasons-canvas.md
- templates/cj_prompt.md как промпт для создания CJ
- templates/adr-template.md как формат для ADR
- templates/workspace.dsl как шаблон архитектуры в нотации Structurizr DSL

Базовый принцип:
- пока технологии не фиксируем — цель этого этапа договориться о принципиальном подходе по CJ/модели данных/правила верификации и сопоставления данных от разных ролей/связи процессной модели и архитектуры CJ
- при создании артефактов проверь что они открываются и не содержат ошибок
- строго придерживайся шаблонов
- создавай CJ строго согласно prompt cj_prompt.md

Создай или обнови:
- documentation/prompts/reasons-canvas.md
- documentation/cj/*.bpmn - CJ пользователей
- documentation/adr/*.md - архитектурные решения
- documentation/workspace.dsl - архитектура проекта в нотации Structurizr DSL
- documentation/analysis.md - анализ требований и решений
```

### Результат применения промпта

После запуска промпта будут созданы/обновлены следующие артефакты:

1. **REASONS Canvas** — `documentation/prompts/reasons-canvas.md`
   - Требования с ID и критериями приёмки
   - Доменные сущности
   - Подход и структура
   - Операции с проверяемыми шагами
   - Нормы и safeguards

2. **Customer Journey** — `documentation/cj/*.bpmn`
   - BPMN 2.0 файлы для каждого пользовательского сценария
   - Соблюдение иерархии 4 уровней

3. **ADR** — `documentation/adr/*.md`
   - Архитектурные решения с контекстом и альтернативами
   - Статус и дата каждого решения

4. **Architecture DSL** — `documentation/workspace.dsl`
   - Описание системы в Structurizr DSL
   - Views для разных уровней абстракции

5. **Analysis** — `documentation/analysis.md`
   - Анализ требований и принятых решений
   - Риски и открытые вопросы

## ✅ Чеклист валидации

Перед завершением итерации проверьте:

- [ ] Все артефакты открываются без ошибок
- [ ] REASONS Canvas заполнен на уровне ревью
- [ ] Требования имеют ID и критерии приёмки
- [ ] ADR имеют статус и дату
- [ ] BPMN файлы валидны в Camunda Modeler
- [ ] DSL файл валиден в Structurizr
- [ ] Все связи между артефактами указаны
- [ ] Открытые вопросы зафиксированы


