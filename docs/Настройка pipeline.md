### Настройка CI/CD конвейера

#### Создание нового Pipeline

Инструкция применима для проектов которые содержат только исходные файлы архитектуры. Для остальных проектов - проконсультируйтесь с вашим DevOps инженером.


* Откройте в GitLab ваш проект
* Перейдите на закладку Build/Pipeline editor
* Скопируйте текст в тело pipeline
* Вместо **bee_cli:amd64** становите актуальный путь к образу в вашем корпоративном репозитории

```yaml
stages:
  - prepare
  - fitness_check

# В случае если архитектура использует submodule как ссыылки на другие архитектурные проекты
# Если не использует - то заккоментируйте этот job

update_submodules:
  stage: prepare
  image: harbor.example.ru/common/ubuntu-git-svn:20.04.4
  script:
    - git config --global http.sslVerify false
    - git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@git.example.ru/".insteadOf "https://git.example.ru/"
    - git checkout main
    - git submodule init
    - git submodule update --remote --merge
  artifacts:
    paths:
      - ./landscape
  only:
    - main
  tags:
    - k8s

# Запускается процесс проверки и импорта архитектуры
# Прогресс импорта можно наблюдать на странице приложения в каталоге приложений BeeAtlas

fitness_check:
  stage: fitness_check
  image: 
    name: harbor.example.ru/common/structurizr/bee_cli:amd64 
    pull_policy: always
  script:
    - /workspace/run_pipeline.sh --key $STRUCTURIZR_API_KEY --secret $STRUCTURIZR_API_SECRET
  only:
    - main
  tags:
    - k8s

```

**Примечание:** если вы используете диаграммы с ручной расстановкой элементов, сохраняемые в workspace.json то команду в последнем этапе нужно заменить на:

```yaml
   - /usr/local/structurizr-cli/structurizr.sh push -url https://structurizr.example.ru/api -id $STRUCTURIZR_WORKSPACE_ID -key $STRUCTURIZR_API_KEY -secret $STRUCTURIZR_API_SECRET -merge false -workspace workspace.json
```

#### Установка переменных, необходимых для работы pipeline

* Откройте в левом меню Settings/ CI/CD
* Раскройте пункт Variables нажав кнопку Expand
* Введите значения переменных для вашего проекта (ключи доступны на странице приложения в [BeeAtlas](beeatlas-docs/models/apps.md))

|Имя переменной|Описание|пример значения|
|--------------|--------|---------------|
|STRUCTURIZR_WORKSPACE_ID|идентификатор вашего workspace|5|
|STRUCTURIZR_API_KEY|ключ для доступа к вашему workspace|1a62386d-daf1-4408-9a64-1305ba909f10|
|STRUCTURIZR_API_SECRET|секрет для доступа к вашему workspace|1a62386d-daf1-4408-9a64-1305ba909f10|
