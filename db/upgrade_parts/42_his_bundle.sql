-- مولد من tools/upgrade_part.py (لا تعدله يدوياً)
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;
  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('HIS_ORDER')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE HIS_ORDER ADD (BUNDLE_ID NUMBER(19))');
  ex(q'~ALTER TABLE SAL_BUNDLE ADD CONSTRAINT SAL_BUNDLE_TID_UK UNIQUE (TENANT_ID, ID)~');
  ex(q'~ALTER TABLE HIS_ORDER ADD CONSTRAINT HIS_ORDER_BUNDLE_ID_FK FOREIGN KEY (TENANT_ID, BUNDLE_ID) REFERENCES SAL_BUNDLE (TENANT_ID, ID)~');
  ex(q'~CREATE INDEX HIS_ORDER_BUNDLE_ID_IX ON HIS_ORDER (TENANT_ID, BUNDLE_ID)~');
  ex(q'~COMMENT ON COLUMN HIS_ORDER.BUNDLE_ID IS 'الباقة (الخدمة ضمن باقة)'~');
  ex('ALTER TABLE HIS_ORDER ADD (BUNDLE_NET NUMBER(24,6))');
  ex(q'~COMMENT ON COLUMN HIS_ORDER.BUNDLE_NET IS 'صافي الخدمة داخل الباقة (سعر الباقة الموزع)'~');
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
