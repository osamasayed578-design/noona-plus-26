-- =============================================================================
-- NOONA PLUS 26 | ترقية الذكاء الاصطناعي 02: أداة «مقارنة السنوات» للمساعد
--   get_year_comparison: أشهر كل سنة متقابلة وإجمالي السنة والمنقضي منها ونسبة النمو (تشمل أرقام السنوات السابقة)
--   يتطلب ترقية 47 (مقارنة السنوات وأرقام السنوات السابقة)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_ai26_02.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== أداة مقارنة السنوات
BEGIN
  NOONA_CTX_PKG.enable_system_mode;
  MERGE INTO ai_tool t USING (SELECT 'GET_YEAR_COMPARISON' c FROM dual) x ON (t.code = x.c AND t.tenant_id IS NULL)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, operation_class, permission_code, handler_api, requires_human_confirm, status_code)
        VALUES (NULL, 'GET_YEAR_COMPARISON', 'مقارنة السنوات', 'get_year_comparison', 'READ', NULL, 'NOONA_AI_PKG.run_tool', 'N', 'ENABLED');
  NOONA_CTX_PKG.disable_system_mode;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CTX_PKG.disable_system_mode;
  RAISE;
END;
/
PROMPT ========== الحزمة
@@plsql26/140_noona_ai_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== AI upgrade 02 done
EXIT
