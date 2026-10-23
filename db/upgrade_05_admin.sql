-- =============================================================================
-- NOONA PLUS ERP | ترقية 05: تطبيق الإدارة NOONA_ADMIN
--   * NOONA_SEC_ADMIN_PKG: المستخدمون والأدوار والصلاحيات والمنح وكلمات المرور
--   * كلمات المرور المحلية (SEC_CREDENTIAL، PBKDF2) والمصادقة المخصصة noona_authenticate
--   * NOONA_UI_PKG: تسميات الرموز ولوحة الإدارة
--   * سحب صلاحيات التطبيق المباشرة على جداول بيانات الاعتماد السرية
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_05_admin.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
-- تعديل الجداول ينتظر حتى دقيقتين إذا كان جدول مستخدماً في جلسة أخرى (بدلاً من الخطأ ORA-00054)
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== NOONA_APEX_PKG (local passwords)
@@plsql/80_noona_apex_pkg.sql
PROMPT ========== NOONA_UI_PKG
@@plsql/86_noona_ui_pkg.sql
PROMPT ========== NOONA_SEC_ADMIN_PKG
@@plsql/88_noona_sec_admin_pkg.sql
GRANT EXECUTE ON NOONA_APEX_PKG      TO NOONA_APP;
GRANT EXECUTE ON NOONA_UI_PKG        TO NOONA_APP;
GRANT EXECUTE ON NOONA_SEC_ADMIN_PKG TO NOONA_APP;
PROMPT ========== Revoke direct access to secret credential tables
BEGIN
  FOR t IN (SELECT table_name FROM user_tab_privs
             WHERE grantee = 'NOONA_APP' AND table_name IN ('SEC_CREDENTIAL', 'SEC_MFA_FACTOR')
             GROUP BY table_name) LOOP
    EXECUTE IMMEDIATE 'REVOKE ALL ON ' || t.table_name || ' FROM NOONA_APP';
  END LOOP;
END;
/
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 05 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
