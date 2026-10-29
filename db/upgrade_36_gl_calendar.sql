-- =============================================================================
-- NOONA PLUS ERP | ترقية 36: تجهيز الأستاذ العام للشركات الجديدة
--   * زر «تجهيز الأستاذ العام» كان يفشل (NOONA-GL-020) لأي مؤسسة أو شركة تجهز بعد التثبيت لعدم وجود تقويم مالي
--   * الآن ينشئ التجهيز تقويماً شهرياً (12 فترة) إن لم يوجد، والسنة المالية الحالية بفتراتها إن لم توجد للشركة
--   * فتح السنة المالية التالية من شاشة الفترات المحاسبية: 12 فترة مفتوحة وترقيم سنوي جديد للقيود والسندات
--     (كانت السنة الأولى فقط تنشأ بالتجهيز، فيتوقف الترحيل مع بداية السنة الجديدة)
--   * بحث الأصناف في التصنيع ومستندات المخزون يعرض متوسط التكلفة (كانت تكلفة المكون تظهر صفراً في قائمة المواد)
--   * الترقيم السنوي: سنة بلا تسلسل (مستند بتاريخ سنة سابقة أو تالية) ينشأ تسلسلها تلقائياً بدل خطأ NOONA-REF-001
--   * رقم الأرشيف بسنة الأرشفة لا بتاريخ المستند (كانت أرشفة مستند صادر العام الماضي تفشل)
--   * المدن الرئيسية لدول حزم التوطين (كانت قائمة المدن فارغة في معالج العقار)، والقائمة حسب دولة الشركة
--   * المستشفيات: مريض بهوية وطنية بلا جنسية يأخذ جنسية دولة الشركة (ضريبة صفر لخدمات المواطن)، وعناوين عربية بدل الإنجليزية
--   * مراكز خدمة السيارات: التجهيز ينشئ فئات وخدمات افتراضية (كان المركز الجديد بلا خدمات ولا فئات)
--   * عرض القوائم الطويلة (السجل الضريبي، المشروعات، الإيجارات، الحجوزات، الربط...): لا تفشل حين يتجاوز المحتوى 32 ألف حرف
--   * كل قوائم HTML في الحزم (557 موضعاً): الأرقام داخل سطر يلحق بـ CLOB كانت تفشل بعد 32 ألف حرف (ORA-06502)
--   * قائمة الضريبة في بطاقة الصنف ومستندات المشتريات والمبيعات: ضريبة القيمة المضافة لدولة الشركة فقط
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_36_gl_calendar.sql
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
PROMPT ========== قوائم HTML الطويلة: إلحاق آمن بالـ CLOB (لا تفشل بعد 32 ألف حرف)
@@plsql/86_noona_ui_pkg.sql
@@plsql/88_noona_sec_admin_pkg.sql
@@plsql/89_noona_brand_pkg.sql
@@plsql/91_noona_platform_admin_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
@@plsql/105_noona_pur_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/107_noona_pos_pkg.sql
@@plsql/108_noona_mfg_pkg.sql
@@plsql/109_noona_cor_pkg.sql
@@plsql/110_noona_hr_pkg.sql
@@plsql/111_noona_pay_pkg.sql
@@plsql/112_noona_fa_pkg.sql
@@plsql/113_noona_re_pkg.sql
@@plsql/114_noona_hsp_pkg.sql
@@plsql/115_noona_mnt_pkg.sql
@@plsql/116_noona_rst_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/119_noona_his_claim_pkg.sql
@@plsql/121_noona_his_clin_pkg.sql
@@plsql/122_noona_his_nurse_pkg.sql
@@plsql/123_noona_bi_pkg.sql
PROMPT ========== المدن
@@seed/19_cities.sql
PROMPT ========== الترقيم والأرشيف
@@plsql/20_noona_reference_pkg.sql
@@plsql/95_noona_dms_pkg.sql
PROMPT ========== الأستاذ العام
@@plsql/100_noona_gl_pkg.sql
PROMPT ========== المستشفيات
@@plsql/117_noona_his_pkg.sql
PROMPT ========== القوائم الطويلة
@@plsql/124_noona_prj_pkg.sql
@@plsql/125_noona_loc_pkg.sql
@@plsql/126_noona_einv_pkg.sql
@@plsql/127_noona_res_pkg.sql
@@plsql/128_noona_prp_pkg.sql
@@plsql/129_noona_api_pkg.sql
@@plsql/130_noona_conn_pkg.sql
PROMPT ========== مراكز خدمة السيارات
@@plsql/131_noona_aut_pkg.sql
PROMPT ========== المخزون
@@plsql/104_noona_inv_pkg.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 36 done
EXIT
