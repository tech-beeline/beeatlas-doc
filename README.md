# BeeAtlas Documentation Portal

Портал документации по методологии **ПТР (Проектирование Технического Решения)** и системе **BeeAtlas** — корпоративной платформы архитектурного моделирования.

## Описание проекта

Репозиторий содержит:

- **ПТР** — методологию проектирования технических решений с использованием C4-модели, Structurizr, Markdown и GitLab
- **BeeAtlas** — пользовательскую документацию системы управления архитектурой предприятия (ФДМ, технорадар, карты возможностей, каталог приложений и др.)
- **Шаблоны и темы** — для Structurizr DSL и сопутствующих инструментов

Документация собрана в единый портал на базе **MkDocs Material** с удобной навигацией и поиском.

## Структура документации

```
docs/
├── index.md              # Главная страница портала
├── start.md              # Стартовая страница ПТР
├── 1-11...               # Разделы методологии ПТР
├── Инструкция...         # Настройка инструментов
├── beeatlas-docs/        # Документация BeeAtlas
│   ├── README.md
│   ├── models.md
│   ├── database.md
│   └── models/           # Детальные разделы моделей
├── templates/            # Шаблоны (Excel, PNG, JSON и др.)
└── themes/               # Темы Structurizr
```

## Запуск

### Локально (без Docker)

```bash
# Установка зависимостей
pip install -r requirements.txt

# Режим разработки (с hot-reload)
mkdocs serve

# Сборка статического сайта
mkdocs build
```

Портал будет доступен по адресу: http://127.0.0.1:8000

### Docker (production)

```bash
# Сборка образа
docker build -t beeatlas-doc .

# Запуск контейнера
docker run -p 8888:80 beeatlas-doc
```

Портал будет доступен по адресу: http://localhost:8080

### Режим разработки в Docker

```bash
docker run -it --rm -p 8000:8000 -v $(pwd):/docs \
  python:3.11-slim bash -c "pip install -r requirements.txt && mkdocs serve -a 0.0.0.0:8000"
```

## Технологии

- **MkDocs** — генератор статической документации
- **Material for MkDocs** — тема с поддержкой вкладок, поиска, светлой/тёмной темы
- **Python 3.11** — среда выполнения
- **Nginx** — раздача статики в production-образе

## Конфигурация

Основная конфигурация — `mkdocs.yml`:

- Навигация по разделам ПТР и BeeAtlas
- Язык интерфейса: русский
- Поиск с поддержкой русского языка
- Светлая и тёмная темы

## Редактирование документации

Документация хранится в каталоге `docs/` в формате Markdown. После изменений:

- В режиме `mkdocs serve` страницы обновляются автоматически
- Для production пересоберите Docker-образ

## Ссылки

- [MkDocs](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [C4 Model](https://c4model.com/)
- [Structurizr](https://docs.structurizr.com/)

