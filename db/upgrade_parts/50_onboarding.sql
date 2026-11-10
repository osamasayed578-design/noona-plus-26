-- مولد من tools/upgrade_part.py، مع قيد أنواع الاستيراد (أضيف يدوياً)
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;
  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('AP_OPEN_ITEM')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE AP_OPEN_ITEM ADD (DOC_DATE DATE)');
  -- أنواع الاستيراد الجديدة: الموظفون والأرصدة الافتتاحية
  BEGIN EXECUTE IMMEDIATE 'ALTER TABLE API_IMPORT_JOB DROP CONSTRAINT API_IMPORT_JOB_IMPORT_TYPE_CK'; EXCEPTION WHEN OTHERS THEN NULL; END;
  ex(q'~ALTER TABLE API_IMPORT_JOB ADD CONSTRAINT API_IMPORT_JOB_IMPORT_TYPE_CK CHECK (IMPORT_TYPE IN ('CUSTOMERS', 'SUPPLIERS', 'ITEMS', 'ACCOUNTS', 'BANK_STATEMENT', 'ORDERS', 'EMPLOYEES', 'OPENING_GL', 'OPENING_AR', 'OPENING_AP', 'OPENING_STOCK'))~');
  ex(q'~COMMENT ON COLUMN AP_OPEN_ITEM.DOC_DATE IS 'تاريخ المستند (للأرصدة الافتتاحية والمستخلصات دون فاتورة)'~');
  rls(TRUE);
EXCEPTION WHEN OTHERS THEN
  rls(TRUE);
  RAISE;
END;
/
BEGIN
  NOONA_CORE_PKG.begin_system;
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
