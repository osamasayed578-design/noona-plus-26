-- =============================================================================
-- NOONA PLUS ERP | ترقية 60: التوزيع والمبيعات الميدانية (اشتراك مستقل، التطبيق 149 NOONA_DST)
--   المندوبون وسيارات التوزيع (مستودع متنقل وعهدة)، خطوط السير، المحلات بمواقعها، خطة اليوم والزيارات بالموقع،
--   البيع من السيارة وأوامر التوريد والمرتجعات، التحصيل بطريقة الدفع ورقم المرجع وتأكيد الإشعارات والشيكات،
--   تسوية نهاية اليوم وتوريد النقد، العمولات والأهداف، واتساب للمحلات
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_60_distribution.sql
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
PROMPT ========== الوحدة والجداول والصلاحيات وعزل البيانات
@@upgrade_parts/60_dst_module.sql
@@upgrade_parts/60_dst.sql
@@upgrade_parts/sync_admin_roles.sql
@@seed/21_signup.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/141_noona_dst_pkg.sql
GRANT EXECUTE ON NOONA_DST_PKG TO NOONA_APP;
@@plsql/85_noona_portal.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 60 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apps 115 and 149
EXIT
