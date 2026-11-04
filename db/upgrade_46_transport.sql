-- =============================================================================
-- NOONA PLUS ERP | ترقية 46: النقل والشحن والترحيل (التطبيق 147 NOONA_TRN) + تقارير المجموعة الموحدة + الطباعة الآمنة
--   * الأسطول والسائقون والمدن والمسارات وأنواع الشحنات وتعرفة الترحيل (طن متري/قصير/طويل، كجم، م³، كم، طن-كم، رحلة، حاوية)
--   * أوامر الشحن، الرحلات بزمن الوصول المتوقع ونقاط التوقف، التسليم والعجز، المصروفات، الأعطال والبلاغات والاستجابة، الفوترة
--   * التحليلات: نطاق «المجموعة كاملة» للشركة القابضة (كل الشركات والفروع المسموحة) وتوزيع المؤشر على الشركات
--   * الطباعة: إخفاء رأس وتذييل المتصفح (رابط الصفحة ورقمها) في الخطابات والتقارير
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_46_transport.sql
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
PROMPT ========== وحدة النقل والشحن
@@upgrade_parts/46_trn_module.sql
PROMPT ========== الجداول والصلاحيات وعزل البيانات
@@upgrade_parts/46_transport.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/135_noona_trn_pkg.sql
GRANT EXECUTE ON NOONA_TRN_PKG TO NOONA_APP;
@@plsql/134_noona_anl_pkg.sql
@@plsql/109_noona_cor_pkg.sql
@@plsql/123_noona_bi_pkg.sql
@@plsql/85_noona_portal.sql
PROMPT ========== كتالوج التقارير
@@seed/14_reports_catalog.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 46 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apex/NOONA_TRN/f147 and the rebuilt apps
EXIT
