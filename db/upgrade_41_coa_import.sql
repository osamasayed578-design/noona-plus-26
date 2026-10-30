-- =============================================================================
-- NOONA PLUS ERP | ترقية 41: استيراد شجرة الحسابات من ملف CSV
--   * المالية ← دليل الحسابات: «استيراد حسابات من ملف» بجانب الإدخال اليدوي (والإدارة ← استيراد البيانات ← شجرة الحسابات)
--   * الأعمدة بالعربي أو الإنجليزي: رمز الحساب، اسم الحساب، الحساب الأب، النوع، حساب حركة؛ الأب في الدليل أو في الملف بأي ترتيب
--   * كل صف مستقل والأخطاء في تقرير الاستيراد
--   * مراجعة الإدخال في كل الشاشات: أخطاء الإدخال الشائعة (اختيار فارغ، حقل إلزامي، قيمة مكررة أو طويلة، رقم أو تاريخ غير صحيح)
--     تظهر برسالة عربية واضحة بدل «خطأ غير متوقع»؛ التحقق من وقت الاستئذان؛ اختيار السعر المعلق قبل اعتماده
--   * الرموز التلقائية (الأطباء، بنود المشروع، قوائم الأسعار) تكمل من أكبر رقم بدل العد (لا تصادم)؛
--     قالب تقرير الأشعة: قالب الخدمة ثم أحدث قالب للجهاز
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_41_coa_import.sql
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
PROMPT ========== نوع الاستيراد الجديد
BEGIN
  BEGIN EXECUTE IMMEDIATE 'ALTER TABLE API_IMPORT_JOB DROP CONSTRAINT API_IMPORT_JOB_IMPORT_TYPE_CK';
  EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -2443 THEN RAISE; END IF; END;
  EXECUTE IMMEDIATE q'~ALTER TABLE API_IMPORT_JOB ADD CONSTRAINT API_IMPORT_JOB_IMPORT_TYPE_CK CHECK (IMPORT_TYPE IN ('CUSTOMERS', 'SUPPLIERS', 'ITEMS', 'ACCOUNTS', 'BANK_STATEMENT', 'ORDERS'))~';
END;
/
PROMPT ========== الحزم ومعالج الأخطاء
@@plsql/87_noona_apex_error.sql
@@plsql/90_noona_refdata_pkg.sql
@@plsql/110_noona_hr_pkg.sql
@@plsql/130_noona_conn_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/124_noona_prj_pkg.sql
@@plsql/127_noona_res_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 41 done
EXIT
