-- ترقية 58: طبقة «الرصيد القائم عند التحول إلى FIFO» بلا حركة استلام
DECLARE
  l_n VARCHAR2(1);
BEGIN
  SELECT nullable INTO l_n FROM user_tab_columns WHERE table_name = 'INV_COST_LAYER' AND column_name = 'RECEIPT_TXN_LINE_ID';
  IF l_n = 'N' THEN
    EXECUTE IMMEDIATE 'ALTER TABLE INV_COST_LAYER MODIFY (RECEIPT_TXN_LINE_ID NULL)';
  END IF;
  EXECUTE IMMEDIATE q'~COMMENT ON COLUMN INV_COST_LAYER.RECEIPT_TXN_LINE_ID IS 'حركة الاستلام المنشئة (فارغ لطبقة الرصيد القائم عند التحول إلى FIFO)'~';
END;
/
