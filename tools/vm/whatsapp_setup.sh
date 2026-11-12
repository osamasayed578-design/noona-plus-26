#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | السماح لقاعدة البيانات بالاتصال بـ WhatsApp Cloud API (graph.facebook.com:443)
#   يمنح صلاحية الشبكة (ACL) لمخطط APEX ولـ NOONA_OWNER. لا يحتاج أي مفتاح:
#   رمز الوصول يدخله مسؤول المؤسسة من «مركز الإدارة ← إعدادات واتساب» ويحفظ مشفراً.
#   يشغله سكربت التحديث تلقائياً، ويمكن تشغيله منفرداً: bash tools/vm/whatsapp_setup.sh
# =============================================================================
set -e
[ -f /home/oracle/.noona_env ] || { echo "النظام غير مثبت على هذا الخادم"; exit 1; }
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
OUT=$(su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" <<SQL 2>&1
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=$PDB;
SET SERVEROUTPUT ON FEEDBACK OFF
WHENEVER SQLERROR EXIT 1
DECLARE
  l_apx VARCHAR2(30);
BEGIN
  SELECT schema INTO l_apx FROM dba_registry WHERE comp_id = 'APEX';
  FOR u IN (SELECT l_apx n FROM dual UNION ALL SELECT 'NOONA_OWNER' FROM dual) LOOP
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(host => 'graph.facebook.com', lower_port => 443, upper_port => 443,
      ace => xs\$ace_type(privilege_list => xs\$name_list('connect'), principal_name => u.n, principal_type => xs_acl.ptype_db));
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(host => 'graph.facebook.com',
      ace => xs\$ace_type(privilege_list => xs\$name_list('resolve'), principal_name => u.n, principal_type => xs_acl.ptype_db));
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('WA_ACL_OK');
END;
/
EXIT
SQL
)
if echo "$OUT" | grep -q WA_ACL_OK; then echo "✓ اتصال WhatsApp Cloud API مسموح من قاعدة البيانات"; else echo "$OUT" | tail -5; exit 1; fi
