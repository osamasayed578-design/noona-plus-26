"""كتالوج الاستخدام لكل موديول: صورة كل شاشة، حقولها ونوع كل حقل والإلزامي منها، الأزرار، أعمدة القوائم، خطوات الإدخال،
تسلسل الإدخال بين الشاشات، والشاشات البديلة. الشرح في tools/manual/specs/*.py والباقي يلتقط من النظام نفسه.

الاستخدام (بعد تشغيل قاعدة البيانات وORDS):
  PW_PATH=<playwright> NOONA_PWD_ADMIN=... NOONA_PWD_PLATFORM=... python3 tools/manual/build_manual.py [module_file ...] [--no-capture]
المخرجات: apex/_manual/out/<module>.html و<module>.pdf وimg/، وindex.html لكل الكتالوجات.
"""
import html
import importlib.util
import json
import os
import shutil
import subprocess
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'apex', '_manual', 'out')
WORK = os.path.join(OUT, '_capture')
STATIC = os.path.join(ROOT, 'apex', 'shared', 'static')
PW = os.environ.get('PW_PATH', '/opt/node-tools/node_modules/playwright')

BUTTON_HELP = {
    'حفظ': 'يحفظ البيانات المدخلة.', 'إلغاء': 'يعود دون حفظ.', 'حذف': 'يحذف السجل بعد التأكيد.', 'عرض': 'يحدّث النتائج حسب المرشحات.',
    'طباعة': 'يطبع الصفحة أو المستند.', 'جديد': 'يفتح نموذجاً فارغاً لإضافة سجل جديد.', 'بحث': 'يبحث بالقيمة المدخلة.',
    'رجوع': 'يعود للشاشة السابقة.', 'اليوم': 'يضبط الفترة على اليوم.',
}
TYPE_HELP = {'قائمة اختيار': 'اختيار من قائمة', 'اختيار متعدد': 'تحديد أكثر من خيار', 'تاريخ': 'من التقويم (YYYY-MM-DD)'}


def esc(s):
    return html.escape(str(s or ''), quote=True)


def load_spec(path):
    sp = importlib.util.spec_from_file_location(os.path.basename(path)[:-3], path)
    m = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(m)
    return m.MODULE


def screens(mod):
    for sec in mod['sections']:
        for s in sec['screens']:
            yield s


def capture(mod):
    """يجمع الشاشات حسب التطبيق ويشغل capture.js لكل تطبيق."""
    os.makedirs(WORK, exist_ok=True)
    by_app = {}
    for s in screens(mod):
        by_app.setdefault(s['app'], []).append(s)
    for app, lst in by_app.items():
        user = mod['apps'][app]
        pwd = os.environ.get('NOONA_PWD_' + user.upper())
        if not pwd:
            sys.exit(f'set NOONA_PWD_{user.upper()} for {app}')
        pages = []
        for s in lst:
            p = {'alias': s['alias'], 'shot': s['shot']}
            for k in ('via', 'qs', 'actions', 'maxHeight'):
                if k in s:
                    p[k] = s[k]
            pages.append(p)
        spec = {'app': app, 'user': user, 'pwd': pwd, 'pages': pages}
        if any(s.get('login') for s in lst):
            spec['loginShot'] = next(s['login'] for s in lst if s.get('login'))
        jf = os.path.join(WORK, f"{mod['file']}_{app}.json")
        with open(jf, 'w', encoding='utf-8') as f:
            json.dump(spec, f, ensure_ascii=False)
        r = subprocess.run(['node', os.path.join(HERE, 'capture.js'), jf, os.path.join(WORK, mod['file'] + '_' + app)],
                           env={**os.environ, 'PW_PATH': PW}, capture_output=True, text=True, timeout=1800)
        print(r.stdout.strip())
        if r.returncode:
            print(r.stderr)
            sys.exit(1)


def results(mod):
    res = {}
    for app in {s['app'] for s in screens(mod)}:
        d = os.path.join(WORK, mod['file'] + '_' + app)
        with open(os.path.join(d, app + '.json'), encoding='utf-8') as f:
            for p in json.load(f)['pages']:
                p['_dir'] = d
                res[(app, p['shot'] or p['alias'])] = p
    return res


def image(mod, d, shot):
    """PNG إلى JPEG مضغوط في مجلد الكتالوج."""
    src = os.path.join(d, 'img', shot + '.png')
    if not os.path.exists(src):
        return None
    os.makedirs(os.path.join(OUT, 'img'), exist_ok=True)
    name = f"{mod['file']}_{shot}.jpg".lower()
    im = Image.open(src).convert('RGB')
    if im.width > 1400:
        im = im.resize((1400, int(im.height * 1400 / im.width)))
    im.save(os.path.join(OUT, 'img', name), 'JPEG', quality=72, optimize=True)
    return 'img/' + name


CSS = """
@font-face { font-family: Cairo; src: url(fonts/cairo-arabic.woff2) format('woff2'); unicode-range: U+0600-06FF, U+0750-077F, U+FB50-FDFF, U+FE70-FEFF; }
@font-face { font-family: Cairo; src: url(fonts/cairo-latin.woff2) format('woff2'); unicode-range: U+0000-024F; }
:root { --p: #0067c0; --p50: #eaf3fc; --b: #dde3ea; --t: #111827; --m: #4b5563; --ok: #107c10; --w: #b45309; }
* { box-sizing: border-box; }
body { margin: 0; font-family: Cairo, Tahoma, sans-serif; color: var(--t); background: #f3f6fa; line-height: 1.75; font-size: 15px; }
main { max-width: 1180px; margin: 0 auto; padding: 24px 16px 60px; }
.cover { background: linear-gradient(135deg, #0b3b6e, #0067c0); color: #fff; padding: 48px 32px; border-radius: 12px; margin-bottom: 24px; }
.cover h1 { margin: 0 0 6px; font-size: 32px; } .cover p { margin: 0; opacity: .9; }
.card { background: #fff; border: 1px solid var(--b); border-radius: 10px; padding: 18px 22px; margin: 16px 0; }
h2 { color: #0b3b6e; border-bottom: 2px solid var(--p); padding-bottom: 6px; margin-top: 36px; }
h3 { color: #0b3b6e; margin: 0 0 4px; } h4 { margin: 14px 0 6px; color: #0b3b6e; }
.toc ol { columns: 2; column-gap: 32px; margin: 0; } .toc a { color: var(--p); text-decoration: none; }
.flow { display: flex; flex-wrap: wrap; gap: 10px; counter-reset: s; padding: 0; list-style: none; }
.flow li { counter-increment: s; flex: 1 1 250px; background: #fff; border: 1px solid var(--b); border-inline-start: 4px solid var(--p); border-radius: 8px; padding: 10px 12px; position: relative; }
.flow li::before { content: counter(s); position: absolute; inset-inline-end: 10px; top: 8px; background: var(--p); color: #fff; width: 26px; height: 26px; border-radius: 50%; display: grid; place-items: center; font-weight: 700; font-size: 13px; }
.flow li b { display: block; padding-inline-end: 34px; } .flow li small { color: var(--m); } .flow li a { color: var(--p); }
.screen { background: #fff; border: 1px solid var(--b); border-radius: 10px; padding: 18px 22px; margin: 22px 0; page-break-inside: auto; }
.screen .path { color: var(--m); font-size: 13px; } .screen .path b { color: var(--p); }
.shot { display: block; width: 100%; border: 1px solid var(--b); border-radius: 6px; margin: 12px 0; }
table { width: 100%; border-collapse: collapse; font-size: 13.5px; margin: 6px 0 12px; }
th, td { border: 1px solid var(--b); padding: 5px 8px; text-align: start; vertical-align: top; } th { background: var(--p50); color: #0b3b6e; }
.req { color: #c42b1c; font-weight: 700; } .muted { color: var(--m); }
.tag { display: inline-block; background: var(--p50); color: var(--p); border-radius: 12px; padding: 0 10px; margin: 2px; font-size: 13px; }
.note { background: #fff4e0; border-inline-start: 4px solid var(--w); padding: 8px 12px; border-radius: 6px; margin: 8px 0; }
.alt { background: #e9f6e9; border-inline-start: 4px solid var(--ok); padding: 8px 12px; border-radius: 6px; margin: 8px 0; }
ol.steps li { margin: 3px 0; }
.mods { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 14px; }
.mods a { display: block; background: #fff; border: 1px solid var(--b); border-top: 4px solid var(--p); border-radius: 10px; padding: 14px 16px; color: var(--t); text-decoration: none; }
.mods a b { display: block; color: #0b3b6e; font-size: 17px; }
@media print { body { background: #fff; font-size: 12.5px; } main { padding: 0; max-width: none; } .screen, .card { border: 0; padding: 0; }
  .screen { page-break-before: always; } .cover { -webkit-print-color-adjust: exact; print-color-adjust: exact; } a { color: inherit; } }
"""


def para(x):
    if not x:
        return ''
    if isinstance(x, str):
        x = [x]
    return ''.join(f'<p>{t}</p>' for t in x)


def lst(items, cls='', ordered=False):
    if not items:
        return ''
    tag = 'ol' if ordered else 'ul'
    return f'<{tag} class="{cls}">' + ''.join(f'<li>{t}</li>' for t in items) + f'</{tag}>'


def render_screen(mod, s, cap, n):
    p = cap.get((s['app'], s['shot'])) or {}
    img = image(mod, p['_dir'], s['shot']) if p.get('shot') else None
    title = s.get('title') or p.get('title') or s['alias']
    h = [f'<section class="screen" id="{esc(s["shot"])}"><h3>{n}. {esc(title)}</h3>']
    h.append(f'<div class="path">التطبيق: <b>{esc(mod["app_names"].get(s["app"], s["app"]))}</b>'
             + (f' · المسار: <b>{esc(s["menu"])}</b>' if s.get('menu') else '') + '</div>')
    h.append(para(s.get('purpose')))
    if s.get('login') and p.get('_dir'):
        li = image(mod, p['_dir'], s['login'])
        if li:
            h.append(f'<p class="muted">شاشة الدخول:</p><img class="shot" src="{li}" alt="شاشة الدخول" loading="lazy"><p class="muted">بعد الدخول:</p>')
    if img:
        h.append(f'<img class="shot" src="{img}" alt="{esc(title)}" loading="lazy">')
    elif p.get('error'):
        h.append(f'<p class="muted">(تعذر التقاط الصورة: {esc(p["error"])})</p>')
    if s.get('steps'):
        h.append('<h4>طريقة الإدخال</h4>' + lst(s['steps'], 'steps', True))
    notes = s.get('fields', {})
    items = [i for i in p.get('items', []) if i['label'] not in s.get('hide_fields', [])]
    if items and not s.get('no_fields'):
        h.append('<h4>الحقول</h4><table><thead><tr><th>#</th><th>الحقل</th><th>النوع</th><th>إلزامي</th><th>الوصف والقيم</th></tr></thead><tbody>')
        for k, i in enumerate(items, 1):
            desc = notes.get(i['label'], '')
            if not desc and i['options']:
                desc = 'القيم: ' + '، '.join(i['options'][:6]) + ('...' if len(i['options']) > 6 else '')
            if not desc and i.get('help'):
                desc = i['help']
            h.append(f'<tr><td>{k}</td><td>{esc(i["label"])}</td><td>{esc(TYPE_HELP.get(i["type"], i["type"]))}</td>'
                     f'<td>{"<span class=req>نعم</span>" if i["required"] else "-"}</td><td>{esc(desc)}</td></tr>')
        h.append('</tbody></table>')
    btns = [b for b in p.get('buttons', []) if b not in s.get('hide_buttons', [])]
    bh = s.get('buttons', {})
    if btns:
        h.append('<h4>الأزرار</h4><table><tbody>' + ''.join(
            f'<tr><th style="width:28%">{esc(b)}</th><td>{esc(bh.get(b) or BUTTON_HELP.get(b, ""))}</td></tr>' for b in btns) + '</tbody></table>')
    reps = [r for r in p.get('reports', []) if r['columns']]
    if reps and not s.get('no_columns'):
        h.append('<h4>القوائم في الشاشة</h4>')
        for r in reps:
            cols = [c for c in r['columns'] if c not in ('Link', 'رابط', 'تعديل')]
            h.append(f'<p><b>{esc(r["title"] or "القائمة")}</b>: ' + ''.join(f'<span class="tag">{esc(c)}</span>' for c in cols)
                     + '<br><span class="muted">القائمة تفاعلية: بحث، تصفية، ترتيب، تجميع، حفظ تقارير خاصة، وتصدير Excel/PDF من زر «الإجراءات».'
                     + (' انقر الرمز في أول العمود لفتح السجل.' if 'Link' in r['columns'] or 'رابط' in r['columns'] else '') + '</span></p>')
    for t in s.get('notes', []):
        h.append(f'<div class="note">{t}</div>')
    for t in s.get('alt', []):
        h.append(f'<div class="alt"><b>بديل:</b> {t}</div>')
    if s.get('next'):
        h.append(f'<p><b>بعدها:</b> {s["next"]}</p>')
    h.append('</section>')
    return ''.join(h)


def render(mod, cap):
    out = [f'<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
           f'<title>{esc(mod["title"])}</title><style>{CSS}</style></head><body><main>']
    out.append(f'<div class="cover"><h1>{esc(mod["title"])}</h1><p>{esc(mod.get("subtitle", ""))}</p>'
               f'<p>NOONA PLUS ERP · كتالوج الاستخدام</p></div>')
    out.append('<div class="card">' + para(mod.get('intro')) + '</div>')
    if mod.get('before'):
        out.append('<h2>قبل البدء</h2><div class="card">' + lst(mod['before']) + '</div>')
    if mod.get('flow'):
        out.append('<h2>تسلسل الإدخال</h2><ol class="flow">')
        for f in mod['flow']:
            ref = f' <a href="#{esc(f[2])}">(الشاشة)</a>' if len(f) > 2 and f[2] else ''
            out.append(f'<li><b>{f[0]}</b><small>{f[1]}{ref}</small></li>')
        out.append('</ol>')
    out.append('<div class="card toc"><b>محتوى الكتالوج</b><ol>')
    n = 0
    for sec in mod['sections']:
        out.append(f'<li><a href="#sec-{esc(sec["id"])}">{esc(sec["title"])}</a></li>')
    out.append('</ol></div>')
    for sec in mod['sections']:
        out.append(f'<h2 id="sec-{esc(sec["id"])}">{esc(sec["title"])}</h2>' + para(sec.get('intro')))
        for s in sec['screens']:
            n += 1
            out.append(render_screen(mod, s, cap, n))
    if mod.get('faq'):
        out.append('<h2>أسئلة وحالات شائعة</h2><div class="card">' + ''.join(f'<h4>{q}</h4>{para(a)}' for q, a in mod['faq']) + '</div>')
    out.append('</main></body></html>')
    return ''.join(out)


def pdf(html_file, pdf_file):
    js = f"""const {{ chromium }} = require('{PW}');
(async () => {{ const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('file://{html_file}', {{ waitUntil: 'load' }}); await p.waitForTimeout(800);
  await p.pdf({{ path: '{pdf_file}', format: 'A4', printBackground: true, margin: {{ top: '14mm', bottom: '14mm', left: '10mm', right: '10mm' }},
    displayHeaderFooter: true, headerTemplate: '<span></span>',
    footerTemplate: '<div style="font-size:8px;width:100%;text-align:center;color:#666"><span class=pageNumber></span> / <span class=totalPages></span></div>' }});
  await b.close(); }})();"""
    jf = os.path.join(WORK, '_pdf.js')
    with open(jf, 'w') as f:
        f.write(js)
    subprocess.run(['node', jf], check=True, timeout=600)


def index(mods):
    h = [f'<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><title>كتالوجات NOONA PLUS</title><style>{CSS}</style></head><body><main>'
         '<div class="cover"><h1>NOONA PLUS ERP</h1><p>كتالوجات الاستخدام: صور الشاشات وطريقة الإدخال وتسلسله لكل موديول</p></div><div class="mods">']
    for m in mods:
        h.append(f'<a href="{m["file"]}.html"><b>{esc(m["title"])}</b>{esc(m.get("subtitle", ""))}<br><span class="muted">'
                 f'{sum(1 for _ in screens(m))} شاشة · <span>PDF: {m["file"]}.pdf</span></span></a>')
    h.append('</div></main></body></html>')
    with open(os.path.join(OUT, 'index.html'), 'w', encoding='utf-8') as f:
        f.write(''.join(h))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    files = sorted(os.listdir(os.path.join(HERE, 'specs')))
    files = [f for f in files if f.endswith('.py') and not f.startswith('_') and (not args or any(f.startswith(a) for a in args))]
    os.makedirs(os.path.join(OUT, 'fonts'), exist_ok=True)
    for ff in ('cairo-arabic.woff2', 'cairo-latin.woff2'):
        shutil.copyfile(os.path.join(STATIC, ff), os.path.join(OUT, 'fonts', ff))
    for f in files:
        mod = load_spec(os.path.join(HERE, 'specs', f))
        if '--no-capture' not in sys.argv:
            capture(mod)
        page = render(mod, results(mod))
        hf = os.path.join(OUT, mod['file'] + '.html')
        with open(hf, 'w', encoding='utf-8') as fh:
            fh.write(page)
        if '--no-pdf' not in sys.argv:
            pdf(hf, os.path.join(OUT, mod['file'] + '.pdf'))
        print('built', mod['file'])
    allm = [load_spec(os.path.join(HERE, 'specs', f)) for f in sorted(os.listdir(os.path.join(HERE, 'specs')))
            if f.endswith('.py') and not f.startswith('_')]
    allm = [m for m in allm if os.path.exists(os.path.join(OUT, m['file'] + '.html'))]
    index(allm)


if __name__ == '__main__':
    main()
