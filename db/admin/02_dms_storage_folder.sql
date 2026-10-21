-- =============================================================================
-- NOONA PLUS ERP | تخصيص مجلد حفظ ملفات المستندات لمؤسسة أو شركة (يشغله مسؤول قاعدة البيانات SYS)
--   sqlplus sys@//host:1521/PDB as sysdba @admin/02_dms_storage_folder.sql
-- الاسم الناتج: NOONA_DMS_T<رقم المؤسسة>            (مجلد المؤسسة الافتراضي)
--               NOONA_DMS_T<رقم المؤسسة>_<لاحقة>     (مجلد إضافي، مثل مجلد مستقل لكل شركة: C2)
-- أنشئ المجلد على قرص خادم قاعدة البيانات وأعط حساب خدمة Oracle صلاحية التعديل عليه قبل التشغيل.
-- قابل للتكرار: إعادة التشغيل بنفس الاسم تحدث المسار.
-- =============================================================================
SET VERIFY OFF
SET SERVEROUTPUT ON
SET FEEDBACK OFF
SET LINESIZE 200
SET PAGESIZE 100
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN tenant_id FORMAT 99999
COLUMN company_id FORMAT 99999
COLUMN tenant FORMAT A40
COLUMN company FORMAT A40
COLUMN directory_name FORMAT A30
COLUMN directory_path FORMAT A80

PROMPT ========== المؤسسات والشركات
SELECT t.id tenant_id, t.name_ar tenant, c.id company_id, c.legal_name_ar company
  FROM noona_owner.plt_tenant t LEFT JOIN noona_owner.org_company c ON c.tenant_id = t.id
 ORDER BY t.id, c.id;
PROMPT ========== المجلدات المخصصة حالياً
SELECT directory_name, directory_path FROM dba_directories WHERE directory_name LIKE 'NOONA\_DMS\_T%' ESCAPE '\' ORDER BY 1;

PROMPT tenant_id = رقم المؤسسة | suffix = لاحقة اختيارية مثل C2 (Enter = المجلد الافتراضي) | path = مثل D:\noona_docs\T1
ACCEPT p_tenant NUMBER PROMPT 'tenant_id: '
ACCEPT p_suffix CHAR   PROMPT 'suffix (optional): ' DEFAULT ''
ACCEPT p_path   CHAR   PROMPT 'path on DB server: '

DECLARE
  l_name VARCHAR2(128) := 'NOONA_DMS_T' || TO_CHAR(&p_tenant)
                          || CASE WHEN TRIM('&p_suffix') IS NOT NULL THEN '_' || UPPER(TRIM('&p_suffix')) END;
  l_path VARCHAR2(4000) := TRIM(q'~&p_path~');
  l_n    NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM noona_owner.plt_tenant WHERE id = &p_tenant;
  IF l_n = 0 THEN RAISE_APPLICATION_ERROR(-20000, 'رقم المؤسسة غير موجود: ' || &p_tenant); END IF;
  IF NOT REGEXP_LIKE(l_name, '^NOONA_DMS_T[0-9]+(_[A-Z0-9_]{1,20})?$') THEN
    RAISE_APPLICATION_ERROR(-20000, 'اللاحقة تقبل حروفاً إنجليزية وأرقاماً و _ فقط');
  END IF;
  IF l_path IS NULL THEN RAISE_APPLICATION_ERROR(-20000, 'المسار مطلوب'); END IF;
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY ' || l_name || ' AS ''' || REPLACE(l_path, '''', '''''') || '''';
  EXECUTE IMMEDIATE 'GRANT READ, WRITE ON DIRECTORY ' || l_name || ' TO NOONA_OWNER';
  DBMS_OUTPUT.PUT_LINE('تم: ' || l_name || ' -> ' || l_path);
END;
/
PROMPT ========== اختر المجلد من تطبيق 129: الإعدادات > مكان حفظ الملفات ثم اضغط "اختبار الاتصال"
EXIT
