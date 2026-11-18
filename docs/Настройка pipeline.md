### Настройка CI/CD конвейера

#### Создание нового Pipeline

Инструкция применима для проектов которые содержат только исходные файлы архитектуры. Для остальных проектов - проконсультируйтесь с вашим DevOps инженером.


* Откройте в GitLab ваш проект
* Перейдите на закладку Build/Pipeline editor
* Скопируйте текст в тело pipeline
* Вместо **bee_cli:amd64** становите актуальный путь к образу в вашем корпоративном репозитории

```yaml
stages:
  - fitness_check

variables:
  GIT_SUBMODULE_STRATEGY: recursive
  GIT_SUBMODULE_UPDATE_FLAGS: --remote

fitness_check:
  stage: fitness_check
  image:
    name: harbor.example.com/common/structurizr/bee_cli:amd64
    pull_policy: always
  script:
    - /workspace/fitness_check.sh --key $STRUCTURIZR_API_KEY --secret $STRUCTURIZR_API_SECRET
  only:
    - main
  tags:
    - k8s
```

**Примечание:** По умолчанию, происходит публикация архитектуры, расположенной в workspace.dsl (и вложенных в него файлов) в корневой директории. Однако, если в корне директории расположен workspace.json - то публикуется он. Это сделано на случай, если вы используете ручную расстановку элементов на диаграмме.
Если вы помещаете workspace.json в git, то не забывайте его обновлять перед публикацией!



#### Установка переменных, необходимых для работы pipeline

* Откройте в левом меню Settings/ CI/CD
* Раскройте пункт Variables нажав кнопку Expand
* Введите значения переменных для вашего проекта (ключи доступны на странице приложения в [BeeAtlas](beeatlas-docs/models/apps.md))

|Имя переменной|Описание|пример значения|
|--------------|--------|---------------|
|STRUCTURIZR_WORKSPACE_ID|идентификатор вашего workspace|5|
|STRUCTURIZR_API_KEY|ключ для доступа к вашему workspace|1a62386d-daf1-4408-9a64-1305ba909f10|
|STRUCTURIZR_API_SECRET|секрет для доступа к вашему workspace|1a62386d-daf1-4408-9a64-1305ba909f10|
