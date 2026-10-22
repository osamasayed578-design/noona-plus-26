-- ترقية 19 (جزء الجداول): أسعار الصرف لكل شركة
--   يضيف COMPANY_ID إلى REF_EXCHANGE_RATE وينقل الأسعار القائمة (كانت مشتركة على مستوى المؤسسة) إلى كل شركة
--   في المؤسسة كنسخة مستقلة، ثم يجعله إلزامياً ويعيد المفتاح الفريد ليشمل الشركة. آمن لإعادة التشغيل.
DECLARE
  l_n NUMBER;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-955, -1430, -2275, -1408, -2260, -1442, -2264, -2261, -1451) THEN RAISE; END IF; END;
  PROCEDURE rls(p_on BOOLEAN) IS BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE object_name IN ('REF_EXCHANGE_RATE', 'ORG_COMPANY')) LOOP
      DBMS_RLS.ENABLE_POLICY(USER, r.object_name, r.policy_name, p_on);
    END LOOP;
  END;
BEGIN
  rls(FALSE);
  ex('ALTER TABLE REF_EXCHANGE_RATE ADD (COMPANY_ID NUMBER(19))');
  -- المفتاح الفريد القديم (بدون الشركة) يمنع نسخ السعر لكل شركة: يحذف أولاً ثم يعاد بالشركة
  SELECT COUNT(*) INTO l_n FROM user_cons_columns
   WHERE constraint_name = 'REF_EXCHANGE_RATE_UK1' AND column_name = 'COMPANY_ID';
  IF l_n = 0 THEN
    ex('ALTER TABLE REF_EXCHANGE_RATE DROP CONSTRAINT REF_EXCHANGE_RATE_UK1 DROP INDEX');
  END IF;
  SELECT COUNT(*) INTO l_n FROM user_tab_columns
   WHERE table_name = 'REF_EXCHANGE_RATE' AND column_name = 'COMPANY_ID' AND nullable = 'Y';
  IF l_n > 0 THEN
    -- السعر الأصلي لأول شركة، ونسخة لكل شركة أخرى في المؤسسة (بنفس الحالة والمعتمد)
    EXECUTE IMMEDIATE q'~UPDATE ref_exchange_rate r
       SET company_id = (SELECT MIN(c.id) FROM org_company c WHERE c.tenant_id = r.tenant_id)
     WHERE company_id IS NULL~';
    EXECUTE IMMEDIATE q'~INSERT INTO ref_exchange_rate (tenant_id, company_id, rate_type_id, from_currency, to_currency, rate_date,
           effective_at, rate, inverse_rate, source_code, approved_by, reason, status_code, created_by)
    SELECT r.tenant_id, c.id, r.rate_type_id, r.from_currency, r.to_currency, r.rate_date, r.effective_at, r.rate,
           r.inverse_rate, r.source_code, r.approved_by, r.reason, r.status_code, r.created_by
      FROM ref_exchange_rate r JOIN org_company c ON c.tenant_id = r.tenant_id AND c.id <> r.company_id
     WHERE r.company_id = (SELECT MIN(c2.id) FROM org_company c2 WHERE c2.tenant_id = r.tenant_id)
       AND NOT EXISTS (SELECT 1 FROM ref_exchange_rate x WHERE x.tenant_id = r.tenant_id AND x.company_id = c.id
                          AND x.rate_type_id = r.rate_type_id AND x.from_currency = r.from_currency
                          AND x.to_currency = r.to_currency AND x.effective_at = r.effective_at)~';
    -- مؤسسة بلا شركات: لا مالك للسعر
    EXECUTE IMMEDIATE 'DELETE FROM ref_exchange_rate WHERE company_id IS NULL';
    ex('ALTER TABLE REF_EXCHANGE_RATE MODIFY (COMPANY_ID NOT NULL)');
  END IF;
  ex('ALTER TABLE REF_EXCHANGE_RATE ADD CONSTRAINT REF_EXCHANGE_RATE_UK1 UNIQUE (TENANT_ID, COMPANY_ID, RATE_TYPE_ID, FROM_CURRENCY, TO_CURRENCY, EFFECTIVE_AT)');
  ex(q'~ALTER TABLE ORG_COMPANY ADD CONSTRAINT ORG_COMPANY_TID_UK UNIQUE (TENANT_ID, ID)~');
  ex(q'~ALTER TABLE REF_EXCHANGE_RATE ADD CONSTRAINT REF_EXCHANGE_RATE_COMPANY_ID_FK FOREIGN KEY (TENANT_ID, COMPANY_ID) REFERENCES ORG_COMPANY (TENANT_ID, ID)~');
  ex(q'~CREATE INDEX REF_EXCHANGE_RATE_RATE_TYPE_ID_IX ON REF_EXCHANGE_RATE (TENANT_ID, RATE_TYPE_ID)~');
  ex(q'~COMMENT ON TABLE REF_EXCHANGE_RATE IS 'أسعار الصرف | Exchange Rates | أسعار كل شركة مستقلة عن غيرها وتدار من المالية؛ لا تتغير المعاملات القديمة عند تعديل الجدول؛ المعاملة تحفظ سعرها'~');
  ex(q'~COMMENT ON COLUMN REF_EXCHANGE_RATE.COMPANY_ID IS 'الشركة (الكيان القانوني) المالكة للسجل'~');
  ex(q'~COMMENT ON COLUMN REF_EXCHANGE_RATE.RATE IS 'السعر (الاتجاه الرئيسي المعتمد للشركة)'~');
  UPDATE ref_entity_type SET has_company = 'Y' WHERE entity_type_code = 'REF_EXCHANGE_RATE';
  COMMIT;
  rls(TRUE);
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  rls(TRUE);
  RAISE;
END;
/
