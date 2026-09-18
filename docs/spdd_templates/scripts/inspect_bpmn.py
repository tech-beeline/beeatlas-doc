#!/usr/bin/env python3
"""Структурный дайджест BPMN: что именно объявлено на каждом уровне.

Печатает дерево process -> этапы -> BI -> шаги с точными тегами, именами
и ВСЕМИ атрибутами (включая namespaced: camunda:*, modeler:*), плюс
дочерние элементы шагов — чтобы поймать extensionElements/properties,
которые могут требоваться парсеру.

Зеркальные копии этого файла (правки вносить в оба, файлы должны совпадать):
  * навык — ~/.claude/skills/beeatlas-cj-bpmn/scripts/inspect_bpmn.py
  * доки  — beeatlas-doc/docs/spdd_templates/scripts/inspect_bpmn.py
"""
import sys
import xml.etree.ElementTree as ET

B = '{http://www.omg.org/spec/BPMN/20100524/MODEL}'
DI = '{http://www.omg.org/spec/BPMN/20100524/DI}'
DC = '{http://www.omg.org/spec/DD/20100524/DC}'

STEP_TAGS = {B + t for t in ('task', 'serviceTask', 'userTask', 'manualTask',
                             'scriptTask', 'businessRuleTask', 'sendTask',
                             'receiveTask', 'callActivity', 'subProcess')}


def short(tag):
    return tag.split('}')[-1]


def attrs(el):
    """Все атрибуты, с коротким префиксом вместо URI."""
    out = []
    for k, v in el.attrib.items():
        if k.startswith('{'):
            uri, local = k[1:].split('}')
            pre = {B: 'bpmn', 'http://camunda.org/schema/1.0/bpmn': 'camunda',
                   'http://camunda.org/schema/modeler/1.0': 'modeler'}.get(uri, uri.rsplit('/', 1)[-1])
            out.append(f'{pre}:{local}={v}')
        else:
            out.append(f'{k}={v}')
    return ' '.join(out)


def expanded_map(root):
    """bpmnElement -> isExpanded (и в каких плоскостях встречается)."""
    m = {}
    for d in root.findall(DI + 'BPMNDiagram'):
        plane = d.find(DI + 'BPMNPlane')
        pid = plane.get('bpmnElement')
        for sh in plane.findall(DI + 'BPMNShape'):
            m.setdefault(sh.get('bpmnElement'), []).append(
                (pid, sh.get('isExpanded', '<нет>')))
    return m


def walk(el, depth, exp, lines):
    for ch in el:
        if ch.tag not in STEP_TAGS:
            continue
        tag = short(ch.tag)
        info = exp.get(ch.get('id'), [])
        exp_s = ','.join(f'{p}:{v}' for p, v in info) if info else 'нет DI-shape'
        lines.append(f'{"  " * depth}{tag:12} {attrs(ch)}\n'
                     f'{"  " * depth}{"":12} DI isExpanded -> {exp_s}')
        # дети-расширения и вложенные потоки
        for sub in ch:
            st = short(sub.tag)
            if st in ('incoming', 'outgoing', 'documentation', 'extensionElements'):
                inner = ''
                if st == 'extensionElements':
                    inner = ' [' + ', '.join(f'{short(x.tag)}:{attrs(x)}' for x in sub) + ']'
                    if len(sub) == 0:
                        inner = ' [пусто]'
                lines.append(f'{"  " * (depth + 1)}{st}: ' +
                             (sub.text.strip() if sub.text and sub.text.strip() else '') + inner)
        if tag in ('subProcess', 'callActivity') or ch.tag == B + 'subProcess':
            walk(ch, depth + 1, exp, lines)


def digest(path):
    root = ET.parse(path).getroot()
    exp = expanded_map(root)
    out = [f'══ {path}']
    out.append(f'definitions: {attrs(root)}')
    for proc in root.iter(B + 'process'):
        out.append(f'process: {attrs(proc)}')
        lines = []
        walk(proc, 1, exp, lines)
        out += lines
    diags = root.findall(DI + 'BPMNDiagram')
    out.append(f'диаграмм: {len(diags)} -> ' +
               ', '.join(f"{d.get('id')}(plane={d.find(DI + 'BPMNPlane').get('bpmnElement')})"
                         for d in diags))
    # сводка по количествам
    tags = {}
    for el in root.iter():
        t = short(el.tag)
        if t in ('subProcess', 'task', 'serviceTask', 'userTask', 'callActivity',
                 'startEvent', 'endEvent', 'sequenceFlow', 'extensionElements',
                 'gateway', 'laneSet'):
            tags[t] = tags.get(t, 0) + 1
    out.append('сводка: ' + ', '.join(f'{k}={v}' for k, v in sorted(tags.items())))
    return '\n'.join(out)


if __name__ == '__main__':
    for p in sys.argv[1:]:
        print(digest(p))
        print()
