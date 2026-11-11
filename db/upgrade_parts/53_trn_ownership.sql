-- مولد من tools/upgrade_part.py (لا تعدله يدوياً)
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;
  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('TRN_VEHICLE')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE TRN_VEHICLE ADD (OWNERSHIP VARCHAR2(30 CHAR) DEFAULT ON NULL ''OWNED'' NOT NULL)');
  ex(q'~ALTER TABLE TRN_VEHICLE ADD CONSTRAINT TRN_VEHICLE_OWNERSHIP_CK CHECK (OWNERSHIP IN ('OWNED', 'RENTED', 'LEASED'))~');
  ex(q'~COMMENT ON COLUMN TRN_VEHICLE.OWNERSHIP IS 'الملكية (مملوكة تضاف للأصول الثابتة) [OWNED, RENTED, LEASED]'~');
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
