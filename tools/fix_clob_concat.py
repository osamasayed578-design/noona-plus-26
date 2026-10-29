"""يلف تعبير الإلحاق بالأقواس في «X := X || expr;» و«RETURN X || expr;» حين X متغير CLOB.
السبب: في PL/SQL يتحول CLOB || رقم (أو PLS_INTEGER) ضمنياً إلى VARCHAR2 فيفشل (ORA-06502) متى تجاوز النص 32 ألف حرف؛
أما CLOB || (تعبير نصي قصير) فيبقى CLOB. يعمل على ملفات الحزم ويحترم النصوص بين علامات الاقتباس.
python3 tools/fix_clob_concat.py db/plsql/*.sql"""
import re
import sys


def statements(s, start):
    """نهاية العبارة (موضع ;) من start مع تجاهل ما داخل '...'"""
    i, q = start, False
    while i < len(s):
        c = s[i]
        if c == "'":
            q = not q
        elif not q and c == ';':
            return i
        elif not q and c == '-' and s.startswith('--', i):
            j = s.find('\n', i)
            i = j if j > 0 else len(s)
            continue
        i += 1
    return -1


def clob_vars(s):
    # متغيرات CLOB المعرفة في الحزمة (محلية أو معاملات OUT)
    return set(m.group(1).lower() for m in re.finditer(r'\b(\w+)\s+(?:IN\s+OUT\s+NOCOPY\s+|IN\s+OUT\s+)?CLOB\b', s, re.I))


def fix(s):
    vars_ = clob_vars(s) - {'return', 'p_doc', 'p_content'}
    n = 0
    pat = re.compile(r'(\b(\w+)\s*:=\s*(\w+)\s*\|\||\bRETURN\s+(\w+)\s*\|\|)', re.I)
    out, pos = [], 0
    for m in pat.finditer(s):
        if m.start() < pos:
            continue
        tgt, src, ret = (m.group(2) or '').lower(), (m.group(3) or '').lower(), (m.group(4) or '').lower()
        ok = (tgt and tgt == src and tgt in vars_) or (ret and ret in vars_)
        if not ok:
            continue
        end = statements(s, m.end())
        if end < 0:
            continue
        expr = s[m.end():end]
        body = expr.strip()
        if not body or (body.startswith('(') and body.endswith(')') and body.count('(') == 1):
            continue
        lead = expr[:len(expr) - len(expr.lstrip())]
        out.append(s[pos:m.end()] + lead + '(' + body + ')')
        pos = end
        n += 1
    out.append(s[pos:])
    return ''.join(out), n


if __name__ == '__main__':
    total = 0
    for f in sys.argv[1:]:
        s = open(f, encoding='utf-8').read()
        s2, n = fix(s)
        if n:
            open(f, 'w', encoding='utf-8').write(s2)
            print(f, n)
            total += n
    print('total', total)
