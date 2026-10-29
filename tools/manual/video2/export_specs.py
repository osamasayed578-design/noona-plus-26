"""يصدر كتالوجات الاستخدام (tools/manual/specs) إلى JSON لسكربت جولة الفيديو: شاشات كل موديول بشرحها وطريقة الوصول لها.
python3 tools/manual/video2/export_specs.py <out.json>"""
import glob
import importlib.util
import json
import os
import sys

SPECS = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'specs')
KEYS = ('app', 'alias', 'shot', 'menu', 'title', 'purpose', 'steps', 'notes', 'alt', 'fields', 'doc_fields', 'buttons', 'via', 'qs', 'actions', 'login')


def load(path):
    sys.path.insert(0, os.path.dirname(path))
    sp = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m.MODULE


out = {}
for f in sorted(glob.glob(os.path.join(SPECS, 'm[0-9][0-9]_*.py'))):
    mod = load(f)
    key = os.path.basename(f)[:3]
    out[key] = {'title': mod['title'], 'subtitle': mod.get('subtitle', ''), 'apps': mod['apps'], 'app_names': mod.get('app_names', {}),
                'intro': mod.get('intro', []),
                'sections': [{'title': s['title'], 'screens': [{k: sc[k] for k in KEYS if k in sc} for sc in s['screens']]} for s in mod['sections']]}
json.dump(out, open(sys.argv[1], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(', '.join(f"{k}:{sum(len(s['screens']) for s in v['sections'])}" for k, v in out.items()))
