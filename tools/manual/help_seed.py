#!/usr/bin/env python3
"""يولد db/demo/nine/20_help_seed.sql: شروح الشاشات (الغرض، الخطوات، التنبيهات) في ENG_HELP من كتالوج الشاشات
tools/manual/specs/*.py، برقم الصفحة من تصدير التطبيقات apex/NOONA_*/fNNN. صفوف المنصة (TENANT_ID فارغ) تظهر لكل المؤسسات،
وما يعدله مسؤول المؤسسة يحفظ صفاً خاصاً بمؤسسته ولا يمس هذه الصفوف.
فيديو الشرح: إن وجد tools/manual/help_videos.json ({"NOONA_POS": "https://..."}) يضاف رابط فيديو النظام لكل شاشاته.
التشغيل: python3 tools/manual/help_seed.py
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
from build_manual import load_spec, screens  # noqa: E402

OUT = os.path.join(ROOT, 'db', 'demo', 'nine', '20_help_seed.sql')


def page_map():
    """{(ALIAS_APP, PAGE_ALIAS): page_id} من ملفات تصدير التطبيقات."""
    m = {}
    for d in glob.glob(os.path.join(ROOT, 'apex', 'NOONA_*', 'f[0-9]*', 'application', 'pages')):
        app = d.split(os.sep)[-4]
        for f in glob.glob(os.path.join(d, 'page_*.sql')):
            s = open(f, encoding='utf-8').read(4000)
            i = re.search(r"p_id=>(\d+)", s)
            a = re.search(r"p_alias=>'([A-Z0-9_-]+)'", s)
            if i and a:
                m[(app, a.group(1))] = int(i.group(1))
    return m


def plain(s):
    s = re.sub(r'<[^>]+>', '', str(s or ''))
    return re.sub(r'\s+', ' ', s).replace('~', '-').strip()


def lit(s, limit=1900):
    s = (s or '')[:limit]
    if not s:
        return 'NULL'
    parts = [s[i:i + 300] for i in range(0, len(s), 300)]
    return '\n    || '.join("q'~" + p + "~'" for p in parts)


def main():
    pm = page_map()
    videos = {}
    vf = os.path.join(HERE, 'help_videos.json')
    if os.path.exists(vf):
        videos = json.load(open(vf, encoding='utf-8'))
    rows, seen, missing = [], set(), []
    for f in sorted(glob.glob(os.path.join(HERE, 'specs', 'm[0-9]*.py'))):
        mod = load_spec(f)
        for s in screens(mod):
            app = s['app'].upper()
            pid = pm.get((app, s['alias']))
            if pid is None:
                missing.append(app + ':' + s['alias'])
                continue
            if (app, pid) in seen:
                continue
            seen.add((app, pid))
            title = s.get('title') or s.get('menu', '').split('←')[-1].strip()
            steps = '\n'.join(plain(x) for x in s.get('steps', []))
            tips = '\n'.join(plain(x) for x in s.get('notes', []))
            rows.append((app, pid, plain(title), plain(s.get('purpose')), steps, tips, videos.get(app)))
    with open(OUT, 'w', encoding='utf-8') as o:
        o.write('-- =============================================================================\n'
                '-- NOONA PLUS ERP | شروح الشاشات في قسم المساعدة (مولد من tools/manual/help_seed.py - لا تعدل يدوياً)\n'
                '--   صفوف المنصة لكل المؤسسات؛ يشغل بحساب NOONA_OWNER (من tools/vm/reset_nine_orgs.sh أو يدوياً)\n'
                '-- =============================================================================\n'
                'SET DEFINE OFF\nSET SERVEROUTPUT ON SIZE UNLIMITED\nSET FEEDBACK OFF\nWHENEVER SQLERROR EXIT FAILURE ROLLBACK\n'
                'DECLARE\n  n NUMBER := 0;\n'
                '  PROCEDURE h(p_app VARCHAR2, p_page NUMBER, p_title VARCHAR2, p_purpose VARCHAR2, p_steps VARCHAR2, p_tips VARCHAR2, p_video VARCHAR2) IS\n'
                '    l_id NUMBER;\n  BEGIN\n'
                '    SELECT MAX(id) INTO l_id FROM eng_help WHERE tenant_id IS NULL AND app_alias = p_app AND page_id = p_page;\n'
                '    IF l_id IS NULL THEN\n'
                '      INSERT INTO eng_help (tenant_id, app_alias, page_id, title, purpose, steps, tips, video_url)\n'
                '      VALUES (NULL, p_app, p_page, p_title, p_purpose, p_steps, p_tips, p_video);\n'
                '    ELSE\n'
                '      UPDATE eng_help SET title = p_title, purpose = p_purpose, steps = p_steps, tips = p_tips,\n'
                '             video_url = NVL(p_video, video_url) WHERE id = l_id;\n'
                '    END IF;\n    n := n + 1;\n  END h;\nBEGIN\n  NOONA_CORE_PKG.begin_system;\n')
        for r in rows:
            o.write("  h('%s', %d, %s,\n    %s,\n    %s,\n    %s,\n    %s);\n" % (
                r[0], r[1], lit(r[2], 190), lit(r[3]), lit(r[4]), lit(r[5]), lit(r[6], 490)))
        o.write("  COMMIT;\n  NOONA_CORE_PKG.end_system;\n  DBMS_OUTPUT.PUT_LINE('HELP_OK screens=' || n);\n"
                "EXCEPTION WHEN OTHERS THEN\n  ROLLBACK;\n  NOONA_CORE_PKG.end_system;\n  RAISE;\nEND;\n/\nEXIT\n")
    print('screens:', len(rows), 'file:', os.path.relpath(OUT, ROOT))
    if missing:
        print('not found in exports (skipped):', ', '.join(missing))


if __name__ == '__main__':
    main()
