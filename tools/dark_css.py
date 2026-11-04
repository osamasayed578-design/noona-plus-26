"""يولد تجاوزات الوضع الداكن لكل لون فاتح/داكن ثابت في noona.css (قبل طبقة التصميم v2) وما يلحق به من ملفات أنماط.
الخلفيات الفاتحة ← سطح داكن، النصوص الداكنة ← نص فاتح، الحدود الفاتحة ← حد داكن. الاستخدام: python3 tools/dark_css.py
"""
import os, re
ROOT = os.path.join(os.path.dirname(__file__), '..')
P = os.path.join(ROOT, 'apex/shared/static/noona.css')
MARK_START = '/* ==== DARK AUTO (tools/dark_css.py) ==== */'
MARK_END = '/* ==== /DARK AUTO ==== */'
css = open(P, encoding='utf-8').read()
if MARK_START in css:
    css = css[:css.index(MARK_START)] + css[css.index(MARK_END) + len(MARK_END):]
src = css.split('NOONA DESIGN SYSTEM v2')[0]
src = re.sub(r'/\*.*?\*/', '', src, flags=re.S)


def lum(h):
    h = h.lstrip('#')
    if len(h) == 3: h = ''.join(c * 2 for c in h)
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def sat(h):
    h = h.lstrip('#')
    if len(h) == 3: h = ''.join(c * 2 for c in h)
    v = [int(h[i:i + 2], 16) for i in (0, 2, 4)]
    return (max(v) - min(v)) / 255


out = []
# قواعد بسيطة فقط (بلا @media متداخلة): نجمع المحددات والتصريحات
depth_re = re.compile(r'([^{}@]+)\{([^{}]*)\}')
for m in depth_re.finditer(src):
    sels, body = m.group(1).strip(), m.group(2)
    if not sels or sels.startswith('from') or sels.startswith('to') or '%' in sels or 'html[data-theme' in sels or ':root' in sels:
        continue
    decls = []
    for prop, val in re.findall(r'([a-z-]+)\s*:\s*([^;]+)', body):
        hexes = re.findall(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b', val)
        if not hexes or 'gradient' in val or 'var(' in val:
            continue
        h = hexes[0]
        L = lum(h)
        if prop in ('background', 'background-color'):
            if L > 0.82:
                decls.append(f'{prop}: ' + ('var(--nn-surface-2)' if sat(h) < 0.08 else 'color-mix(in srgb, ' + h + ' 14%, var(--nn-surface))') + ' !important')
        elif prop == 'color':
            if L < 0.3 and sat(h) < 0.25:
                decls.append('color: var(--nn-text) !important')
            elif L < 0.45 and sat(h) < 0.25:
                decls.append('color: var(--nn-muted) !important')
        elif prop in ('border-color', 'border', 'border-bottom', 'border-top', 'border-inline-start', 'border-inline-end') and L > 0.8:
            decls.append(prop + '-color: var(--nn-border) !important' if prop != 'border-color' else 'border-color: var(--nn-border) !important')
    if decls:
        sel = ', '.join('html[data-theme="dark"] ' + s.strip() for s in sels.split(',') if s.strip())
        out.append(sel + ' { ' + '; '.join(decls) + '; }')
block = MARK_START + '\n' + '\n'.join(out) + '\n' + MARK_END + '\n'
css = css.rstrip('\n') + '\n\n' + block
open(P, 'w', encoding='utf-8').write(css)
print('dark overrides:', len(out))
