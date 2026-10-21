"""يولد جزء ترقية آمن لإعادة التشغيل لجداول جديدة من ملفات المولد (DDL، القيود، الفهارس، التعليقات، المشغل،
الصلاحيات، سياسة VPD، المنح). الاستخدام:
  python3 tools/upgrade_part.py db/upgrade_parts/14_x.sql p04_dms TABLE1 [TABLE2 ...] [--add TABLE.COLUMN ...]
"""
import re, sys, os

out, pkg, *rest = sys.argv[1:]
tables = [t for t in rest if not t.startswith('--') and '.' not in t]
adds = [t for t in rest if '.' in t]
D = os.path.join(os.path.dirname(__file__), '..', 'db')
ddl = open(f'{D}/ddl/{pkg}.sql', encoding='utf-8').read()
trg = open(f'{D}/triggers/{pkg}_trg.sql', encoding='utf-8').read()
seed = open(f'{D}/seed/01_registry_seed.sql', encoding='utf-8').read().splitlines()
vpd = open(f'{D}/security/30_vpd_policies.sql', encoding='utf-8').read()
L = ["-- مولد من tools/upgrade_part.py (لا تعدله يدوياً)", "DECLARE", "  l_n NUMBER;",
     "  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN"
     " IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442) THEN RAISE; END IF; END;", "BEGIN"]
for t in tables:
    create = re.search(rf"CREATE TABLE {t} \(.*?\n\);", ddl, re.S).group(0)
    L += [f"  SELECT COUNT(*) INTO l_n FROM user_tables WHERE table_name = '{t}';",
          "  IF l_n = 0 THEN", "    EXECUTE IMMEDIATE q'~" + create.rstrip(';') + "~';", "  END IF;"]
    for l in ddl.splitlines():
        if l.startswith(f'ALTER TABLE {t} ') or l.startswith(f'CREATE INDEX {t}_') or \
           (l.startswith('COMMENT ON') and re.search(rf'\b{t}\b', l)):
            L.append("  ex(q'~" + l.rstrip(';') + "~');")
for a in adds:
    t, c = a.split('.')
    m = re.search(rf"CREATE TABLE {t} \(.*?\n\);", ddl, re.S).group(0)
    col = re.search(rf"^\s+{c}\s+(.+?),?$", m, re.M).group(1).rstrip(',')
    L.append(f"  ex('ALTER TABLE {t} ADD ({c} {col})');")
    for l in ddl.splitlines():
        if l.startswith(f'COMMENT ON COLUMN {t}.{c} '):
            L.append("  ex(q'~" + l.rstrip(';') + "~');")
L += ["END;", "/"]
for t in tables:
    L.append(re.search(rf"CREATE OR REPLACE TRIGGER {t}_BIU.*?\nEND;\n/", trg, re.S).group(0))
L.append("BEGIN\n  NOONA_CORE_PKG.begin_system;")
for t in tables:
    for l in seed:
        if re.search(rf"VALUES \('{t}[.']", l):
            tbl = re.match(r"INSERT INTO (\w+)", l).group(1)
            key = re.search(r"VALUES \('([^']+)'", l).group(1)
            col = 'PERMISSION_CODE' if tbl == 'SEC_PERMISSION' else 'ENTITY_TYPE_CODE'
            cols = l[len('INSERT INTO ' + tbl) + 1:].split(' VALUES ')[0]
            vals = l.split(' VALUES (', 1)[1].rstrip(');')
            L.append(f"  INSERT INTO {tbl} {cols} SELECT {vals} FROM dual WHERE NOT EXISTS (SELECT 1 FROM {tbl} WHERE {col} = '{key}');")
L.append("  NOONA_CORE_PKG.end_system;\n  COMMIT;\nEXCEPTION WHEN OTHERS THEN\n  NOONA_CORE_PKG.end_system;\n  RAISE;\nEND;\n/")
for t in tables:
    pol = re.search(rf"NOONA_VPD_PKG\.(add_\w+_policy)\('{t}'\);", vpd).group(1)
    L.append(f"BEGIN\n  NOONA_VPD_PKG.{pol}('{t}');\nEND;\n/")
    L.append(f"GRANT SELECT, INSERT, UPDATE, DELETE ON {t} TO NOONA_APP;")
open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
print('written', out)
