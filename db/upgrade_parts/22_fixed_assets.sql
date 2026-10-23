-- مولد من tools/upgrade_part.py (لا تعدله يدوياً)
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261) THEN RAISE; END IF; END;
  -- إضافة أعمدة إلزامية وقيود على جداول محمية بـ VPD تتطلب قراءة كامل الجدول: تعطل السياسات مؤقتاً
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('FA_ASSET_BOOK', 'FA_DISPOSAL')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE FA_DISPOSAL ADD (VAT_AMOUNT NUMBER(24,6) DEFAULT ON NULL 0 NOT NULL)');
  ex(q'~COMMENT ON COLUMN FA_DISPOSAL.VAT_AMOUNT IS 'ضريبة القيمة المضافة على البيع'~');
  ex('ALTER TABLE FA_DISPOSAL ADD (REASON VARCHAR2(1000 CHAR))');
  ex(q'~COMMENT ON COLUMN FA_DISPOSAL.REASON IS 'السبب والملاحظات'~');
  ex('ALTER TABLE FA_ASSET_BOOK ADD (DEPRECIATED_TO DATE)');
  ex(q'~COMMENT ON COLUMN FA_ASSET_BOOK.DEPRECIATED_TO IS 'مهلك حتى تاريخ (آخر فترة أو رصيد افتتاحي أو تاريخ الاستبعاد)'~');
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
