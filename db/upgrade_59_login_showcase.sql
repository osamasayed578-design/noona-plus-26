-- =============================================================================
-- NOONA PLUS ERP | ترقية 59: صفحة الدخول الجديدة
--   * عمود الدخول يمين الشاشة، وعرض متحرك للأنظمة في باقيها (من العروض الفعالة وأسعارها) مع زر التجربة المجانية
--   * لمن دخل سابقاً من نفس الجهاز: «أهلاً بعودتك» باسم مؤسسته و«ما الجديد» وترويج لنظام غير مشترك فيه
--   * «ما الجديد» يعدله مسؤول المنصة من «التسجيل الذاتي والأسعار» (الإعداد LOGIN.WHATS_NEW)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_59_login_showcase.sql
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
PROMPT ========== الإعدادات
@@seed/21_signup.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/138_noona_signup_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 59 done. Now import apps 115 and 125
EXIT
