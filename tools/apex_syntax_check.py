"""Syntax check for APEX export folders without APEX installed.

Generates stub versions of the APEX import API (wwv_flow_imp*, wwv_imp_workspace, ...) whose
procedures accept every named parameter used in the given export files, then emits one SQL*Plus
script that installs the stubs and runs every export file against them. Run the script as a
scratch schema; any PLS/ORA error points to a syntax problem (quotes, missing =>, parentheses).
It does NOT prove that APEX accepts the parameter names; it catches structural/syntax errors.

usage: python3 tools/apex_syntax_check.py OUT.sql APP_DIR [APP_DIR ...]
"""
import re, sys, os, collections

out, dirs = sys.argv[1], sys.argv[2:]
calls = collections.defaultdict(dict)          # 'pkg.proc' -> {param: type}
files = []
for d in dirs:
    inst = open(os.path.join(d, 'install.sql'), encoding='utf-8').read()
    for rel in re.findall(r'^@@(\S+)', inst, re.M):
        path = os.path.join(d, rel); files.append(path)
        src = open(path, encoding='utf-8').read()
        for m in re.finditer(r'\b(wwv_flow_imp_page|wwv_flow_imp_shared|wwv_imp_workspace|wwv_flow_imp)\.(?!g_varchar2_table|empty_varchar2_table|varchar2_to_blob|id\b)(\w+)\s*\(\s*\n?(.*?)\n\);', src, re.S):
            key = f'{m.group(1)}.{m.group(2)}'
            for pm in re.finditer(r'(?:^|\n)\s*,?\s*(p_\w+)\s*=>\s*(.*?)(?=\n\s*,\s*p_\w+\s*=>|\Z)', m.group(3), re.S):
                name, val = pm.group(1), pm.group(2).strip()
                t = 'BOOLEAN' if (val.lower() in ('true', 'false') or 'get_auto_install_sup_obj' in val) else \
                    'BLOB' if 'varchar2_to_blob' in val else \
                    'CLOB' if ('to_clob' in val or 'wwv_flow_string.join' in val) else 'VARCHAR2'
                prev = calls[key].get(name)
                calls[key][name] = 'CLOB' if prev and prev != t and 'BOOLEAN' not in (prev, t) else (prev or t)
        for m in re.finditer(r'\b(wwv_flow_imp_page|wwv_flow_imp_shared|wwv_imp_workspace|wwv_flow_imp)\.(\w+)\s*\(\s*\)', src):
            calls.setdefault(f'{m.group(1)}.{m.group(2)}', {})

pk = collections.defaultdict(list)
for key, params in calls.items():
    p, proc = key.split('.')
    if proc in ('id', 'g_varchar2_table', 'empty_varchar2_table', 'varchar2_to_blob'):
        continue
    sig = ', '.join(f'{n} IN {t} DEFAULT NULL' for n, t in sorted(params.items()))
    pk[p].append(f"  PROCEDURE {proc}{'(' + sig + ')' if sig else ''}")
pk.setdefault('wwv_flow_imp', [])
L = ["SET DEFINE OFF", "SET FEEDBACK OFF", "WHENEVER SQLERROR CONTINUE",
     "BEGIN FOR o IN (SELECT object_type, object_name FROM user_objects WHERE object_type IN ('PACKAGE','TYPE')) LOOP"
     " EXECUTE IMMEDIATE 'DROP '||o.object_type||' '||o.object_name||CASE o.object_type WHEN 'TYPE' THEN ' FORCE' END; END LOOP;"
     " EXCEPTION WHEN OTHERS THEN NULL; END;", "/",
     "CREATE OR REPLACE TYPE wwv_flow_t_varchar2 AS TABLE OF VARCHAR2(32767);", "/",
     "CREATE OR REPLACE TYPE wwv_flow_t_plugin_attributes AS OBJECT (v wwv_flow_t_varchar2, MEMBER FUNCTION to_clob RETURN CLOB);", "/",
     "CREATE OR REPLACE TYPE BODY wwv_flow_t_plugin_attributes AS MEMBER FUNCTION to_clob RETURN CLOB IS BEGIN RETURN NULL; END; END;", "/",
     "CREATE OR REPLACE PACKAGE wwv_flow_string AS FUNCTION join(p wwv_flow_t_varchar2) RETURN CLOB; END;", "/",
     "CREATE OR REPLACE PACKAGE BODY wwv_flow_string AS FUNCTION join(p wwv_flow_t_varchar2) RETURN CLOB IS BEGIN RETURN NULL; END; END;", "/",
     "CREATE OR REPLACE PACKAGE wwv_flow AS g_flow_id NUMBER := 1; END;", "/",
     "CREATE OR REPLACE PACKAGE wwv_flow_application_install AS",
     *[f"  FUNCTION {f}{'(p NUMBER)' if f == 'get_static_theme_file_prefix' else ''} RETURN VARCHAR2;" for f in
       ('get_schema', 'get_application_name', 'get_application_alias', 'get_image_prefix', 'get_proxy',
        'get_no_proxy_domains', 'get_static_app_file_prefix', 'get_static_theme_file_prefix')],
     "  FUNCTION get_auto_install_sup_obj RETURN BOOLEAN;",
     "END;", "/",
     "CREATE OR REPLACE PACKAGE BODY wwv_flow_application_install AS",
     *[f"  FUNCTION {f}{'(p NUMBER)' if f == 'get_static_theme_file_prefix' else ''} RETURN VARCHAR2 IS BEGIN RETURN NULL; END;" for f in
       ('get_schema', 'get_application_name', 'get_application_alias', 'get_image_prefix', 'get_proxy',
        'get_no_proxy_domains', 'get_static_app_file_prefix', 'get_static_theme_file_prefix')],
     "  FUNCTION get_auto_install_sup_obj RETURN BOOLEAN IS BEGIN RETURN FALSE; END;",
     "END;", "/"]
for p, procs in pk.items():
    extra_spec = ['  TYPE t_vc IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER',
                  '  g_varchar2_table t_vc', '  empty_varchar2_table t_vc',
                  '  FUNCTION id(p NUMBER) RETURN NUMBER', '  FUNCTION varchar2_to_blob(p t_vc) RETURN BLOB',
                  '  PROCEDURE remove_flow(p NUMBER)', '  PROCEDURE component_end'] if p == 'wwv_flow_imp' else []
    procs = [x for x in procs if not (p == 'wwv_flow_imp' and x.strip() in ('PROCEDURE component_end', 'PROCEDURE remove_flow'))]
    spec = procs + extra_spec
    L += [f"CREATE OR REPLACE PACKAGE {p} AS", ';\n'.join(spec) + ';', "END;", "/"]
    body = [s.replace('  PROCEDURE', '  PROCEDURE', 1) + ' IS BEGIN NULL; END' for s in procs]
    if p == 'wwv_flow_imp':
        body += ['  FUNCTION id(p NUMBER) RETURN NUMBER IS BEGIN RETURN p; END',
                 '  FUNCTION varchar2_to_blob(p t_vc) RETURN BLOB IS BEGIN RETURN NULL; END',
                 '  PROCEDURE remove_flow(p NUMBER) IS BEGIN NULL; END', '  PROCEDURE component_end IS BEGIN NULL; END']
    L += [f"CREATE OR REPLACE PACKAGE BODY {p} AS", ';\n'.join(body) + ';', "END;", "/"]
L += ["SELECT 'STUB ERROR '||name||' '||line||' '||text FROM user_errors;", "WHENEVER SQLERROR EXIT 1"]
for f in files:
    txt = open(f, encoding='utf-8').read()
    txt = re.sub(r'^(set define off verify off feedback off|whenever sqlerror exit sql.sqlcode rollback)$', '', txt, flags=re.M | re.I)
    L += [f"PROMPT CHECK {f}", txt.strip()]
L += ["PROMPT ALL FILES COMPILED", "EXIT"]
open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
print(f'{len(files)} files, {sum(len(v) for v in pk.values())} stub procedures -> {out}')
