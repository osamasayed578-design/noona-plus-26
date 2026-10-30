-- =============================================================================
-- NOONA PLUS ERP | ترقية 42: التسعير الموحد والعروض والباقات لكل الموديولات
--   * التكلفة: الصنف (متوسط مرجح، آخر شراء، معيارية) والخدمة الطبية وخدمة السيارات ببطاقة تكلفة
--     (مواد الخدمة + عمالة بالدقائق × تكلفة الساعة + أعباء ثابتة أو نسبة)
--   * سياسات سعر البيع من التكلفة: نسبة فوق التكلفة، هامش من سعر البيع، مبلغ ثابت، معامل؛ أدنى هامش؛ التقريب
--   * إعادة التسعير بمراجعة قبل التطبيق، وسجل لكل تغيير سعر، وتقرير الهوامش
--   * العروض والتخفيضات (نسبة، مبلغ، سعر خاص، اشتر واحصل، خصم على قيمة الفاتورة) بالفترة والأيام والساعات والقنوات والكوبون
--   * الباقات: أصناف و/أو خدمات بسعر ثابت أو خصم، يوزع سعرها على مكوناتها
--   * التطبيق: نقطة البيع (عروض تلقائية، كوبون، باقات)، فاتورة المبيعات (تطبيق العروض)، زيارة المستشفى (عرض الخدمة النقدية،
--     باقة الفحص)، أمر إصلاح السيارة (عرض الخدمة والقطعة، باقة الصيانة)؛ والصفحات في المبيعات والمستشفيات وخدمة السيارات
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_42_pricing.sql
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
PROMPT ========== جداول التسعير والصلاحيات وعزل البيانات
@@upgrade_parts/42_pricing.sql
@@upgrade_parts/42_his_bundle.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/133_noona_prc_pkg.sql
GRANT EXECUTE ON NOONA_PRC_PKG TO NOONA_APP;
PROMPT ========== ربط المستشفيات وخدمة السيارات بالعروض والباقات
@@plsql/106_noona_sal_pkg.sql
@@plsql/107_noona_pos_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/131_noona_aut_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 42 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
