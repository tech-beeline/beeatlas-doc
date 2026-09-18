#!/usr/bin/env python3
"""Генератор BPMN 2.0 описания Customer Journey для загрузки в BeeAtlas.

Конвенция снята с рабочего эталона платформы (Camunda Cloud 8.6);
cj_prompt.md и cj_template.bpmn синхронизированы с ней — расхождений быть не должно.

Зеркальные копии этого файла (правки вносить в оба, файлы должны совпадать):
  * навык — ~/.claude/skills/beeatlas-cj-bpmn/scripts/gen_cj_bpmn.py
  * доки  — beeatlas-doc/docs/spdd_templates/scripts/gen_cj_bpmn.py

Структура:  Process -> Этап (subProcess) -> BI (subProcess «BI …») -> userTask/serviceTask

Использование:
    python3 gen_cj_bpmn.py spec.json [-o out.bpmn]

Формат спецификации:
    {
      "process_id":     "Process_BeeAtlas_CJM13",
      "definitions_id": "Definitions_beeatlas_cjm13",
      "stages": [
        {"name": "Поиск приложения",
         "bis": [
           {"name": "BI Поиск приложения",
            "steps": [
              {"type": "userTask",    "name": "Открыть каталог приложений"},
              {"type": "serviceTask", "name": "Список приложений: GET /product/v1/product/info"}
            ]}
         ]}
      ]
    }
"""
import json
import os
import re
import sys

sys.dont_write_bytecode = True   # не оставлять __pycache__ в каталоге с докой
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from validate_cj_bpmn import validate  # noqa: E402

CYR = {'а':'a','б':'b','в':'v','г':'g','д':'d','е':'e','ё':'e','ж':'zh','з':'z','и':'i',
       'й':'j','к':'k','л':'l','м':'m','н':'n','о':'o','п':'p','р':'r','с':'s','т':'t',
       'у':'u','ф':'f','х':'h','ц':'c','ч':'ch','ш':'sh','щ':'sch','ъ':'','ы':'y','ь':'',
       'э':'e','ю':'yu','я':'ya',' ':'','-':'','_':''}


def translit(s):
    return ''.join(CYR.get(c.lower(), c) for c in s if c.isalnum() or c in ' -_')


def camel(s):
    return ''.join(p[:1].upper() + p[1:] for p in re.split(r'[^A-Za-z0-9]+', translit(s)) if p)


def esc(s):
    """Экранирование как в файлах Camunda Modeler: кавычки — &#34;."""
    return (s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
             .replace('"', '&#34;'))


def build(spec):
    stages = spec['stages']
    pname = spec.get('process_id') or f"Process_{camel(spec['name'])}"
    did = spec.get('definitions_id') or f'Definitions_{pname.lower()}'

    body = ['    <bpmn:startEvent id="StartEvent_Process">',
            f'      <bpmn:outgoing>Flow_To{camel(stages[0]["name"])}</bpmn:outgoing>',
            '    </bpmn:startEvent>']
    di_main, stage_planes, bi_planes = [], [], []

    for si, st in enumerate(stages):
        sc = camel(st['name'])
        sid = f'Activity_{sc}'
        bis = st['bis']
        body.append(f'    <bpmn:subProcess id="{sid}" name="{esc(st["name"])}">')
        body.append(f'      <bpmn:incoming>Flow_To{sc}</bpmn:incoming>')
        next_flow = ('Flow_ToEnd' if si == len(stages) - 1
                     else f'Flow_To{camel(stages[si + 1]["name"])}')
        body.append(f'      <bpmn:outgoing>{next_flow}</bpmn:outgoing>')

        bi_ids, links = [], []
        for bi, b in enumerate(bis, 1):
            bid = f'Activity_BI_{sc}_{bi}'
            bi_ids.append(bid)
            link_in = f'{sc}Link{bi - 1}' if bi > 1 else None
            link_out = f'{sc}Link{bi}' if bi < len(bis) else None
            if link_in:
                links.append(link_in)
            body.append(f'      <bpmn:subProcess id="{bid}" name="{esc(b["name"])}">')
            if link_in:
                body.append(f'        <bpmn:incoming>{link_in}</bpmn:incoming>')
            if link_out:
                body.append(f'        <bpmn:outgoing>{link_out}</bpmn:outgoing>')
            tids, flow_ids = [], []
            for ti, step in enumerate(b['steps'], 1):
                tid = f'Activity_{sc}{bi}{ti}'
                kind = step.get('type', 'userTask')
                if kind not in ('userTask', 'serviceTask'):
                    raise SystemExit(f'недопустимый тип шага: {kind} '
                                     f'(только userTask/serviceTask)')
                tids.append(tid)
                flow_ids.append(f'{sc}{bi}F{ti}')
                body.append(f'        <bpmn:{kind} id="{tid}" name="{esc(step["name"])}">')
                if kind == 'userTask':
                    body.append('          <bpmn:extensionElements>')
                    body.append('            <zeebe:userTask />')
                    body.append('          </bpmn:extensionElements>')
                if ti > 1:
                    body.append(f'          <bpmn:incoming>{sc}{bi}F{ti - 1}</bpmn:incoming>')
                if ti < len(b['steps']):
                    body.append(f'          <bpmn:outgoing>{sc}{bi}F{ti}</bpmn:outgoing>')
                body.append(f'        </bpmn:{kind}>')
            for ti in range(1, len(b['steps'])):
                body.append(f'        <bpmn:sequenceFlow id="{sc}{bi}F{ti}" '
                            f'sourceRef="{tids[ti - 1]}" targetRef="{tids[ti]}" />')
            body.append('      </bpmn:subProcess>')
            bi_planes.append((bid, tids, sc, bi, len(b['steps'])))
        for bi in range(1, len(bis)):
            body.append(f'      <bpmn:sequenceFlow id="{sc}Link{bi}" '
                        f'sourceRef="{bi_ids[bi - 1]}" targetRef="{bi_ids[bi]}" />')
        body.append('    </bpmn:subProcess>')
        stage_planes.append((sid, bi_ids, [f'{sc}Link{i}' for i in range(1, len(bis))]))

    body.append('    <bpmn:endEvent id="EndEvent_Process">')
    body.append('      <bpmn:incoming>Flow_ToEnd</bpmn:incoming>')
    body.append('    </bpmn:endEvent>')
    prev = 'StartEvent_Process'
    for st in stages:
        tgt = f'Activity_{camel(st["name"])}'
        body.append(f'    <bpmn:sequenceFlow id="Flow_To{camel(st["name"])}" '
                    f'sourceRef="{prev}" targetRef="{tgt}" />')
        prev = tgt
    body.append(f'    <bpmn:sequenceFlow id="Flow_ToEnd" sourceRef="{prev}" '
                f'targetRef="EndEvent_Process" />')

    # ---------- BPMNDI ----------
    fx = 182
    di_main.append(f'      <bpmndi:BPMNShape id="StartEvent_Process_di" bpmnElement="StartEvent_Process">'
                   f'\n        <dc:Bounds x="{fx}" y="162" width="36" height="36" />\n'
                   f'      </bpmndi:BPMNShape>')
    fx += 36
    for st in stages:
        sc = camel(st['name'])
        di_main.append(f'      <bpmndi:BPMNShape id="Activity_{sc}_di" bpmnElement="Activity_{sc}">'
                       f'\n        <dc:Bounds x="{fx + 92}" y="140" width="100" height="80" />'
                       f'\n        <bpmndi:BPMNLabel />\n      </bpmndi:BPMNShape>')
        di_main.append(f'      <bpmndi:BPMNEdge id="Flow_To{sc}_di" bpmnElement="Flow_To{sc}">'
                       f'\n        <di:waypoint x="{fx}" y="180" />'
                       f'\n        <di:waypoint x="{fx + 92}" y="180" />\n      </bpmndi:BPMNEdge>')
        fx += 192
    di_main.append(f'      <bpmndi:BPMNShape id="EndEvent_Process_di" bpmnElement="EndEvent_Process">'
                   f'\n        <dc:Bounds x="{fx + 52}" y="162" width="36" height="36" />\n'
                   f'      </bpmndi:BPMNShape>')
    di_main.append(f'      <bpmndi:BPMNEdge id="Flow_ToEnd_di" bpmnElement="Flow_ToEnd">'
                   f'\n        <di:waypoint x="{fx}" y="180" />'
                   f'\n        <di:waypoint x="{fx + 52}" y="180" />\n      </bpmndi:BPMNEdge>')

    stage_di = []
    for sid, bi_ids, links in stage_planes:
        shapes, edges = [], []
        for bi, bid in enumerate(bi_ids):
            bx = 190 + 150 * bi
            shapes.append(f'      <bpmndi:BPMNShape id="{bid}_di" bpmnElement="{bid}">'
                          f'\n        <dc:Bounds x="{bx}" y="150" width="100" height="80" />'
                          f'\n        <bpmndi:BPMNLabel />\n      </bpmndi:BPMNShape>')
            if bi:
                edges.append(f'      <bpmndi:BPMNEdge id="{links[bi - 1]}_di" '
                             f'bpmnElement="{links[bi - 1]}">'
                             f'\n        <di:waypoint x="{bx - 50}" y="190" />'
                             f'\n        <di:waypoint x="{bx}" y="190" />\n      </bpmndi:BPMNEdge>')
        stage_di.append((sid, shapes, edges))

    bi_di = []
    for bid, tids, sc, bi, n in bi_planes:
        shapes, edges = [], []
        for ti, tid in enumerate(tids):
            tx = 190 + 140 * ti
            shapes.append(f'      <bpmndi:BPMNShape id="{tid}_di" bpmnElement="{tid}">'
                          f'\n        <dc:Bounds x="{tx}" y="150" width="100" height="80" />'
                          f'\n        <bpmndi:BPMNLabel />\n      </bpmndi:BPMNShape>')
            if ti:
                edges.append(f'      <bpmndi:BPMNEdge id="{sc}{bi}F{ti}_di" '
                             f'bpmnElement="{sc}{bi}F{ti}">'
                             f'\n        <di:waypoint x="{tx - 50}" y="190" />'
                             f'\n        <di:waypoint x="{tx}" y="190" />\n      </bpmndi:BPMNEdge>')
        bi_di.append((bid, shapes, edges))

    X = ['<?xml version="1.0" encoding="UTF-8"?>',
         '<bpmn:definitions '
         'xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" '
         'xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" '
         'xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" '
         'xmlns:zeebe="http://camunda.org/schema/zeebe/1.0" '
         'xmlns:di="http://www.omg.org/spec/DD/20100524/DI" '
         'xmlns:modeler="http://camunda.org/schema/modeler/1.0" '
         f'id="{did}" targetNamespace="http://bpmn.io/schema/bpmn" '
         'exporter="Camunda Modeler" exporterVersion="5.31.0" '
         'modeler:executionPlatform="Camunda Cloud" modeler:executionPlatformVersion="8.6.0">',
         f'  <bpmn:process id="{pname}" isExecutable="true">']
    X += body
    X.append('  </bpmn:process>')
    X.append('  <bpmndi:BPMNDiagram id="BPMNDiagram_Main">')
    X.append(f'    <bpmndi:BPMNPlane id="BPMNPlane_Main" bpmnElement="{pname}">')
    X += di_main
    X.append('    </bpmndi:BPMNPlane>')
    X.append('  </bpmndi:BPMNDiagram>')
    for sid, shapes, edges in stage_di:
        X += [f'  <bpmndi:BPMNDiagram id="BPMNDiagram_{sid}">',
              f'    <bpmndi:BPMNPlane id="BPMNPlane_{sid}" bpmnElement="{sid}">']
        X += shapes + edges
        X += ['    </bpmndi:BPMNPlane>', '  </bpmndi:BPMNDiagram>']
    for bid, shapes, edges in bi_di:
        X += [f'  <bpmndi:BPMNDiagram id="BPMNDiagram_{bid}">',
              f'    <bpmndi:BPMNPlane id="BPMNPlane_{bid}" bpmnElement="{bid}">']
        X += shapes + edges
        X += ['    </bpmndi:BPMNPlane>', '  </bpmndi:BPMNDiagram>']
    X.append('</bpmn:definitions>')
    return '\n'.join(X) + '\n'


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    spec_path = argv[0]
    out = None
    if '-o' in argv:
        out = argv[argv.index('-o') + 1]
    spec = json.load(open(spec_path, encoding='utf-8'))
    if out is None:
        out = os.path.splitext(spec_path)[0] + '.bpmn'
    xml = build(spec)
    errors, warnings = validate(xml)
    if errors:
        print('Сгенерированный файл не прошёл проверку — исправьте спецификацию:')
        for e in errors:
            print(f'  ✗ {e}')
        return 1
    open(out, 'w', encoding='utf-8').write(xml)
    n_st = len(spec['stages'])
    n_bi = sum(len(s['bis']) for s in spec['stages'])
    n_step = sum(len(b['steps']) for s in spec['stages'] for b in s['bis'])
    print(f'{out}: {n_st} этап(ов), {n_bi} BI, {n_step} шагов, '
          f'{len(xml.splitlines())} строк')
    for w in warnings:
        print(f'  ! {w}')
    print('  ✓ проверка пройдена')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
