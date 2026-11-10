-- =============================================================================
-- NOONA PLUS ERP | ترقية 52: بريد النظام وخدمات الحساب والاشتراك
--   * NOONA_MAIL_PKG: الإرسال عبر APEX_MAIL بقالب عربي، ويعمل بعد ربط SMTP (tools/vm/mail_setup.sh)
--   * «نسيت كلمة المرور» (صفحة عامة في 115): رمز بالبريد صالح 15 دقيقة لمرة واحدة
--   * «اشتراكي» (إدارة المؤسسة 123): الخطة والأنظمة والمستخدمون، وطلب تجديد أو ترقية أو إضافة بالسعر
--   * تأكيد الطلب من لوحة المنصة (125): تفعيل الأنظمة والمستخدمين والخطة، وفاتورة مبيعات في مؤسسة صاحب المنصة ترسل للعميل
--   * مهمة يومية NOONA_ACCOUNT_DAILY: تنبيهات قرب انتهاء التجربة والاشتراك والتحول للقراءة فقط
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_52_mail_account.sql
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
PROMPT ========== الجداول والأعمدة
@@upgrade_parts/52_mail_account.sql
@@seed/22_mail.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/139_noona_mail_pkg.sql
@@plsql/140_noona_account_pkg.sql
@@plsql/138_noona_signup_pkg.sql
@@plsql/140_noona_account_pkg.sql
GRANT EXECUTE ON NOONA_MAIL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_ACCOUNT_PKG TO NOONA_APP;
PROMPT ========== المهمة اليومية
@@upgrade_parts/52_account_job.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 52 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps 115, 123 and 125
EXIT
