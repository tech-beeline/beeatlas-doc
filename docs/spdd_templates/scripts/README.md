# Скрипты проверки BPMN для CJ

Утилиты, в которых закодированы требования парсера BeeAtlas к BPMN-файлу Customer Journey.
Работают вместе с промптом [`cj_prompt.md`](../cj_prompt.md) и образцом
[`cj_template.bpmn`](../cj_template.bpmn); сами правила описаны в
[инструкции по CJ](../../beeatlas-docs/instruction/cj_bpmn.md).

| Файл | Назначение |
|---|---|
| [`gen_cj_bpmn.py`](gen_cj_bpmn.py) | генератор BPMN из JSON-спецификации, с самопроверкой результата |
| [`validate_cj_bpmn.py`](validate_cj_bpmn.py) | валидатор готового файла — своего или чужого |
| [`inspect_bpmn.py`](inspect_bpmn.py) | структурный дайджест: что объявлено на каждом уровне, для сверки с эталоном |
| [`examples/spec-cjm13.json`](examples/spec-cjm13.json) | пример спецификации для генератора |

Нужен только Python 3, внешних зависимостей нет.

## Использование

```bash
cd docs/spdd_templates/scripts

# генерация из спецификации (формат — в шапке gen_cj_bpmn.py и в examples/)
python3 gen_cj_bpmn.py examples/spec-cjm13.json -o cj13.bpmn

# проверка готового файла
python3 validate_cj_bpmn.py cj13.bpmn
python3 validate_cj_bpmn.py --strict cj13.bpmn   # предупреждения = ошибки

# структурный дайджест — удобно сравнивать свой файл с cj_template.bpmn
python3 inspect_bpmn.py cj13.bpmn ../cj_template.bpmn
```

`validate_cj_bpmn.py` проверяет то, на чём чаще всего падает импорт: платформу и версию
(`Camunda Cloud` 8.x), префикс `BI ` у имён BI, отсутствие событий внутри этапов и BI,
типы шагов (только `userTask`/`serviceTask`), наличие `<zeebe:userTask />`, сходимость
`incoming`/`outgoing` с потоками, число диаграмм и `callActivity` без `calledElement`.

## Синхронизация с навыком

Те же файлы лежат в навыке `beeatlas-cj-bpmn` —
`~/.claude/skills/beeatlas-cj-bpmn/scripts/`. Правки вносить **в оба места**,
копии должны совпадать байт-в-байт:

```bash
S=~/.claude/skills/beeatlas-cj-bpmn/scripts
for f in gen_cj_bpmn.py validate_cj_bpmn.py inspect_bpmn.py; do
  diff -q "$S/$f" "$f" >/dev/null || echo "разошлось: $f"
done
```

Если навык не установлен — этих файлов достаточно, они самодостаточны.
