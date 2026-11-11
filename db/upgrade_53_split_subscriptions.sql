-- =============================================================================
-- NOONA PLUS ERP | ترقية 53: فصل اشتراكات الأنظمة الداخلية + ربط شاحنات النقل بالأصول الثابتة
--   * الفنادق والضيافة (HSP) والمطاعم والكافتيريا (RST) وحدتان مستقلتان، والعقارات (RE/PRP) والمشاريع (PRJ)
--     عروض منفصلة في التسجيل الذاتي وصفحة «اشتراكي»؛ تبقى داخل تطبيقاتها وتظهر أقسامها فقط لمن اشترك فيها
--   * النقل والشحن: العربة المملوكة تسجل أصلاً ثابتاً (فئة السيارات ووسائل النقل) وترسمل بقيد الاقتناء
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_53_split_subscriptions.sql
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
PROMPT ========== الوحدات والأعمدة
@@upgrade_parts/53_trn_ownership.sql
@@upgrade_parts/53_split_modules.sql
@@seed/21_signup.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/85_noona_portal.sql
@@plsql/135_noona_trn_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 53 done. Now import apps 115, 133, 139 and 147
EXIT
