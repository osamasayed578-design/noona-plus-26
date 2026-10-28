-- =============================================================================
-- NOONA PLUS ERP | ترقية 33: واجهات REST عبر ORDS والأحداث الصادرة والتكاملات
--   * عملاء API بحساب خدمة ودور وشركة، رموز Bearer مؤقتة، سجل الطلبات، حد المعدل، قائمة IP، Idempotency-Key للعمليات المالية
--   * Webhooks موقعة HMAC-SHA256 من الصندوق الصادر بإعادة محاولة متزايدة، ورسائل SMS/واتساب بقواعد لكل حدث
--   * الموصلات: استيراد CSV (عملاء، موردون، أصناف)، كشف حساب بنكي ومطابقة تلقائية، طلبات المتجر الإلكتروني
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_33_api.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @ords/api_v1.sql      (وحدة ORDS: /ords/noona/v1/)
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
PROMPT ========== جداول وأعمدة الواجهات (رموز الدخول، مهام الاستيراد، اشتراكات وتسليمات Webhook)
@@upgrade_parts/33_api.sql
PROMPT ========== سجل نقاط النهاية v1
@@seed/18_api.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/129_noona_api_pkg.sql
@@plsql/130_noona_conn_pkg.sql
@@plsql/105_noona_pur_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/127_noona_res_pkg.sql
@@plsql/128_noona_prp_pkg.sql
GRANT EXECUTE ON NOONA_API_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_CONN_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
@@upgrade_parts/33_api_job.sql
@@upgrade_parts/33_api_fix_outbox.sql
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 33 done. Now run security/41_synonyms_noona_app.sql and ords/api_v1.sql as NOONA_APP
EXIT
