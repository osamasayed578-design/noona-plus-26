-- مولد من tools/upgrade_part.py (لا تعدله يدوياً)
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;
  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('INV_ITEM', 'TRN_MAINT_LINE')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE INV_ITEM ADD (SERVICE_LIFE_KM NUMBER)');
  ex(q'~COMMENT ON COLUMN INV_ITEM.SERVICE_LIFE_KM IS 'عمر الاستبدال بالكيلومتر (قطع الغيار والزيوت والإطارات)'~');
  ex('ALTER TABLE INV_ITEM ADD (SERVICE_LIFE_DAYS NUMBER(10))');
  ex(q'~COMMENT ON COLUMN INV_ITEM.SERVICE_LIFE_DAYS IS 'عمر الاستبدال بالأيام'~');
  ex('ALTER TABLE TRN_MAINT_LINE ADD (LIFE_KM NUMBER)');
  ex(q'~COMMENT ON COLUMN TRN_MAINT_LINE.LIFE_KM IS 'عمر الاستبدال (كم)'~');
  ex('ALTER TABLE TRN_MAINT_LINE ADD (LIFE_DAYS NUMBER(10))');
  ex(q'~COMMENT ON COLUMN TRN_MAINT_LINE.LIFE_DAYS IS 'عمر الاستبدال (يوم)'~');
  ex('ALTER TABLE TRN_MAINT_LINE ADD (NEXT_DUE_KM NUMBER)');
  ex(q'~COMMENT ON COLUMN TRN_MAINT_LINE.NEXT_DUE_KM IS 'الاستبدال التالي عند العداد'~');
  ex('ALTER TABLE TRN_MAINT_LINE ADD (NEXT_DUE_DATE DATE)');
  ex(q'~COMMENT ON COLUMN TRN_MAINT_LINE.NEXT_DUE_DATE IS 'الاستبدال التالي بتاريخ'~');
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
