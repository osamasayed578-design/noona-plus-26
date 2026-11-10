-- =============================================================================
-- NOONA PLUS ERP | ترقية 51: التسجيل الذاتي للعملاء
--   * صفحة عامة «إنشاء حساب مؤسسة» في التطبيق الرئيسي (115) ورابطها في صفحة الدخول: الحساب ← رمز التحقق للبريد والجوال ←
--     المؤسسة ← الأنظمة وعدد المستخدمين والخطة مع السعر ← تجهيز المؤسسة آلياً بتجربة 14 يوماً
--   * الخطة المدفوعة بالتحويل البنكي: تعمل المؤسسة بتجربة حتى يؤكد مسؤول المنصة التحويل فيتحول الاشتراك للمدفوع
--   * لوحة المنصة (125): طلبات التسجيل، والأسعار وخصم المدة وإعدادات التسجيل
--   * جداول PLT_OFFERING (الأنظمة وأسعارها) و PLT_SIGNUP (الطلبات)، وخصم المدة في PLT_PLAN
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_51_signup.sql
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
@@upgrade_parts/51_signup.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/138_noona_signup_pkg.sql
GRANT EXECUTE ON NOONA_SIGNUP_PKG TO NOONA_APP;
WHENEVER SQLERROR EXIT SQL.SQLCODE
PROMPT ========== الأنظمة وأسعارها الابتدائية وإعدادات التسجيل
@@seed/21_signup.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 51 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps 115 and 125
EXIT
