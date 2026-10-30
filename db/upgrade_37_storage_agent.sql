-- =============================================================================
-- NOONA PLUS ERP | ترقية 37: وكيل التخزين المحلي لملفات الأرشيف
--   * مكان حفظ جديد لكل شركة: «وكيل تخزين محلي» برنامج صغير يثبت عند الشركة (tools/storage_agent)
--   * الوكيل يتصل بالنظام (لا يفتح منفذاً في شبكة الشركة) عبر ORDS: /ords/noona/agent/v1/
--   * الملف لا يحذف من القاعدة إلا بعد أن يؤكد الوكيل حفظه بنفس البصمة SHA-256
--   * عند العرض يجلب من الوكيل خلال ثوانٍ وتبقى نسخة مؤقتة ساعة؛ إن كان الوكيل غير متصل تظهر رسالة واضحة
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_37_storage_agent.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== جداول الوكيل ومهامه وأعمدة التخزين
@@upgrade_parts/37_dms_agent.sql
PROMPT ========== قيم مكان الحفظ الجديدة
DECLARE
  PROCEDURE ck(p_table VARCHAR2, p_name VARCHAR2, p_cond VARCHAR2) IS
  BEGIN
    BEGIN EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table || ' DROP CONSTRAINT ' || p_name; EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -2443 THEN RAISE; END IF; END;
    EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table || ' ADD CONSTRAINT ' || p_name || ' CHECK (' || p_cond || ')';
  END;
BEGIN
  ck('DMS_STORAGE_PROFILE', 'DMS_STORAGE_PROFILE_STORAGE_MEDIUM_CK', q'~STORAGE_MEDIUM IN ('DATABASE', 'SERVER_FOLDER', 'OBJECT_STORAGE', 'LOCAL_AGENT')~');
  ck('DMS_FILE_CONTENT', 'DMS_FILE_CONTENT_STORAGE_MEDIUM_CK', q'~STORAGE_MEDIUM IN ('SECUREFILE', 'OBJECT_STORAGE', 'NAS', 'S3_COMPATIBLE', 'AGENT')~');
  ck('DMS_AGENT_JOB', 'DMS_AGENT_JOB_JOB_TYPE_CK', q'~JOB_TYPE IN ('PUT', 'GET', 'RETURN', 'DELETE', 'TEST')~');
END;
/
PROMPT ========== الحزم
@@plsql/95_noona_dms_pkg.sql
@@plsql/132_noona_dms_agent_pkg.sql
@@plsql/86_noona_ui_pkg.sql
GRANT EXECUTE ON NOONA_DMS_AGENT_PKG TO NOONA_APP;

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 37 done
EXIT
