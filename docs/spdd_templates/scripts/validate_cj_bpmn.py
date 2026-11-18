#!/usr/bin/env python3
"""Проверка BPMN-файла Customer Journey на соответствие требованиям парсера BeeAtlas.

Правила выведены из двух источников:
  * документация парсера  — beeatlas-doc/docs/beeatlas-docs/instruction/cj_bpmn.md
  * рабочий эталон из платформы (Camunda Cloud 8.6) — загружается без ошибок

Зеркальные копии этого файла (правки вносить в оба, файлы должны совпадать):
  * навык — ~/.claude/skills/beeatlas-cj-bpmn/scripts/validate_cj_bpmn.py
  * доки  — beeatlas-doc/docs/spdd_templates/scripts/validate_cj_bpmn.py

Использование:
    python3 validate_cj_bpmn.py file.bpmn [file2.bpmn ...]
    python3 validate_cj_bpmn.py --strict file.bpmn   # предупреждения = ошибки

Как модуль:
    from validate_cj_bpmn import validate
    errors, warnings = validate(open('f.bpmn').read())
"""
import sys
import xml.etree.ElementTree as ET

B = '{http://www.omg.org/spec/BPMN/20100524/MODEL}'
DI = '{http://www.omg.org/spec/BPMN/20100524/DI}'
MODELER = '{http://camunda.org/schema/modeler/1.0}'

STEPS = ('userTask', 'serviceTask')          # допустимые типы шага сценария BI
GATEWAYS = ('exclusiveGateway', 'parallelGateway', 'inclusiveGateway',
            'eventBasedGateway', 'complexGateway', 'gateway')
FORBIDDEN_STEPS = ('task', 'manualTask', 'scriptTask', 'businessRuleTask',
                   'sendTask', 'receiveTask')   # НЕ распознаются как шаг сценария
FLOW_REFS = (B + 'incoming', B + 'outgoing')


def validate(xml):
    """-> (errors, warnings)"""
    err, warn = [], []
    try:
        root = ET.fromstring(xml)
    except ET.ParseError as e:
        return [f'XML не разобран: {e}'], []

    if root.tag != B + 'definitions':
        err.append(f'корневой элемент не bpmn:definitions: {root.tag}')

    # --- платформа: парсер ждёт 8.x, файлы 7.x не распознаются ---
    plat = root.get(MODELER + 'executionPlatform')
    ver = root.get(MODELER + 'executionPlatformVersion')
    if plat != 'Camunda Cloud':
        err.append(f'executionPlatform={plat!r} — парсер ждёт "Camunda Cloud" '
                   f'(Camunda Platform 7.x не распознаётся)')
    if ver and not ver.startswith('8.'):
        err.append(f'executionPlatformVersion={ver} — ожидается 8.x')
    if 'zeebe' not in xml:
        warn.append('нет пространства имён zeebe — Camunda 8 обычно его объявляет')

    # --- уникальность id ---
    ids = [e.get('id') for e in root.iter() if e.get('id')]
    dup = sorted({i for i in ids if ids.count(i) > 1})
    if dup:
        err.append(f'дубли id: {dup}')

    # --- потоки ---
    flows = {e.get('id'): (e.get('sourceRef'), e.get('targetRef'))
             for e in root.iter(B + 'sequenceFlow')}
    for fid, (s, t) in flows.items():
        if s not in ids or t not in ids:
            err.append(f'поток {fid}: sourceRef/targetRef не существует ({s} -> {t})')

    for el in root.iter():
        if el.tag == B + 'sequenceFlow':
            continue
        eid = el.get('id')
        if not eid:
            continue
        exp_in = {f for f, (s, t) in flows.items() if t == eid}
        exp_out = {f for f, (s, t) in flows.items() if s == eid}
        got_in = {x.text for x in el.findall(B + 'incoming')}
        got_out = {x.text for x in el.findall(B + 'outgoing')}
        if exp_in or exp_out or got_in or got_out:
            if exp_in != got_in or exp_out != got_out:
                err.append(f'{eid}: incoming/outgoing не сходятся с потоками '
                           f'(вход {sorted(exp_in)} vs {sorted(got_in)}, '
                           f'выход {sorted(exp_out)} vs {sorted(got_out)})')

    proc = root.find(B + 'process')
    if proc is None:
        return err + ['в файле нет bpmn:process'], warn
    if proc.get('isExecutable') != 'true':
        warn.append('у process нет isExecutable="true"')

    # --- события только на уровне процесса ---
    for sp in root.iter(B + 'subProcess'):
        inside = [e.get('id') for e in sp.iter()
                  if e.tag in (B + 'startEvent', B + 'endEvent')]
        if inside:
            err.append(f'внутри «{sp.get("name", sp.get("id"))}» есть события {inside} — '
                       f'у этапов и BI событий быть не должно')

    # --- уровни ---
    subs = [s for s in proc.iter(B + 'subProcess')]
    stages = [s for s in subs if not s.get('name', '').startswith('BI ')]
    bis = [s for s in subs if s.get('name', '').startswith('BI ')]

    # --- callActivity: допустим только на BI, существующий в библиотеке платформы ---
    for call in proc.iter(B + 'callActivity'):
        ce = (call.get('calledElement') or '').strip()
        who = call.get('name') or call.get('id')
        if not ce:
            err.append(f'callActivity «{who}» без calledElement — импорт упадёт с '
                       f'«не заполнено поле processID»; опишите BI вложенным subProcess «BI …»')
        else:
            warn.append(f'callActivity «{who}» -> {ce}: работает только если этот BI уже есть '
                        f'в библиотеке платформы; при генерации с нуля используйте '
                        f'вложенный subProcess с именем «BI …»')

    for st in stages:
        allowed = ((B + 'subProcess', B + 'sequenceFlow', B + 'callActivity') + FLOW_REFS
                   + tuple(B + g for g in GATEWAYS))
        for ch in st:
            tag = ch.tag.split('}')[-1]
            if ch.tag in tuple(B + g for g in GATEWAYS):
                # в рабочем эталоне шлюз есть и загружается — допустимо, но не обязательно
                warn.append(f'этап «{st.get("name")}»: найден {tag} — эталон использует шлюз, '
                            f'но для линейного CJ достаточно последовательных потоков')
                continue
            if ch.tag not in allowed:
                err.append(f'этап «{st.get("name")}» содержит недопустимый элемент {tag}')
        child_bis = st.findall(B + 'subProcess') + st.findall(B + 'callActivity')
        if not child_bis:
            err.append(f'этап «{st.get("name")}» не содержит ни одного BI '
                       f'(имя BI должно начинаться с "BI ")')

    for bi in bis:
        for ch in bi:
            if ch.tag not in tuple(B + t for t in STEPS) + (B + 'sequenceFlow',) + FLOW_REFS:
                err.append(f'BI «{bi.get("name")}» содержит недопустимый элемент '
                           f'{ch.tag.split("}")[-1]} — допустимы только userTask/serviceTask')
        n = sum(len(bi.findall(B + t)) for t in STEPS)
        if not (2 <= n <= 5):
            warn.append(f'BI «{bi.get("name")[:50]}»: {n} шаг(ов) — рабочий эталон держит 2–3')
        if not n:
            err.append(f'BI «{bi.get("name")}»: нет ни одного шага сценария')

    for bad in FORBIDDEN_STEPS:
        found = [e.get('id') for e in root.iter(B + bad)]
        if found:
            hint = ('шаг сценария BI' if bad == 'task' else 'не распознаётся парсером')
            err.append(f'найден bpmn:{bad} ({found[:3]}) — {hint}; '
                       f'используйте userTask для шагов пользователя и serviceTask для системных')

    # --- диаграммы ---
    diags = root.findall(DI + 'BPMNDiagram')
    exp = 1 + len(stages) + len(bis)
    if len(diags) != exp:
        warn.append(f'диаграмм {len(diags)}, ожидается {exp} '
                    f'(main + этапы + BI) — эталон даёт отдельную на каждый элемент')

    if list(root.iter(B + 'laneSet')):
        warn.append('есть laneSet (swimlane) — в эталоне не используется')

    return err, warn


def main(argv):
    strict = '--strict' in argv
    files = [a for a in argv if not a.startswith('--')]
    if not files:
        print(__doc__)
        return 2
    bad = 0
    for f in files:
        errors, warnings = validate(open(f, encoding='utf-8').read())
        print(f'══ {f}')
        for e in errors:
            print(f'  ✗ {e}')
        for w in warnings:
            print(f'  ! {w}')
        if not errors and not warnings:
            print('  ✓ соответствует конвенции')
        if errors or (strict and warnings):
            bad += 1
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
