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
     " IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;", 
     "  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً",
     "  PROCEDURE rls(p_on BOOLEAN) IS BEGIN",
     "    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN (" + (", ".join(sorted({"'" + a.split('.')[0] + "'" for a in adds})) or "NULL") + ")) LOOP",
     "      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);",
     "    END LOOP;",
     "  END;", "BEGIN", "  rls(FALSE);"]
for t in tables:
    create = re.search(rf"CREATE TABLE {t} \(.*?\n\);", ddl, re.S).group(0)
    L += [f"  SELECT COUNT(*) INTO l_n FROM user_tables WHERE table_name = '{t}';",
          "  IF l_n = 0 THEN", "    EXECUTE IMMEDIATE q'~" + create.rstrip(';') + "~';", "  END IF;"]
    for l in ddl.splitlines():
        if l.startswith(f'ALTER TABLE {t} ') or (l.startswith(f'CREATE INDEX {t}_') and f' ON {t} (' in l) or \
           (l.startswith('COMMENT ON') and re.search(rf'\b{t}\b', l)):
            L.append("  ex(q'~" + l.rstrip(';') + "~');")
ALL = '\n'.join(open(os.path.join(D, 'ddl', f), encoding='utf-8').read() for f in sorted(os.listdir(os.path.join(D, 'ddl')))
                if f.endswith('.sql'))
for a in adds:
    t, c = a.split('.')
    m = re.search(rf"CREATE TABLE {t} \(.*?\n\);", ALL, re.S).group(0)
    col = re.search(rf"^\s+{c}\s+(.+?),?$", m, re.M).group(1).rstrip(',')
    L.append(f"  ex('ALTER TABLE {t} ADD ({c} {col.replace(chr(39), chr(39) * 2)})');")
    # القيود والفهارس والتعليق الخاصة بالعمود المضاف (قد تكون في ملف وحدة أخرى)
    ck = re.search(rf"^\s+CONSTRAINT ({t}_{c}_CK CHECK \(.*\)),?$", m, re.M)
    if ck:
        L.append("  ex(q'~ALTER TABLE " + t + " ADD CONSTRAINT " + ck.group(1).rstrip(',') + "~');")
    for l in ALL.splitlines():
        fk = re.match(rf"ALTER TABLE {t} ADD CONSTRAINT {t}_{c}_FK FOREIGN KEY \(TENANT_ID, {c}\) REFERENCES (\w+) \(TENANT_ID, ID\)", l)
        if fk:   # الجدول المرجع يحتاج مفتاحاً فريداً (TENANT_ID, ID) إن لم يكن مرجعاً سابقاً
            # اسم مستقل: أسماء UKn في القاعدة القائمة قد تخص أعمدة أخرى؛ إن وجد المفتاح نفسه يتجاهل (-2261)
            L.append(f"  ex(q'~ALTER TABLE {fk.group(1)} ADD CONSTRAINT {fk.group(1)[:23]}_TID_UK UNIQUE (TENANT_ID, ID)~');")
        if (l.startswith(f'ALTER TABLE {t} ADD CONSTRAINT {t}_{c}_FK ') or l.startswith(f'CREATE INDEX {t}_{c}_IX ')
                or l.startswith(f'COMMENT ON COLUMN {t}.{c} ')
                or (l.startswith(f'CREATE UNIQUE INDEX {t}_NUK') and re.search(rf'\b{c}\b', l))
                or (l.startswith(f'CREATE INDEX {t}_') and re.search(rf'\({"TENANT_ID"}, {c}\)', l))):
            L.append("  ex(q'~" + l.rstrip(';') + "~');")
L += ["  rls(TRUE);", "EXCEPTION WHEN OTHERS THEN", "  rls(TRUE);", "  RAISE;", "END;", "/"]
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
