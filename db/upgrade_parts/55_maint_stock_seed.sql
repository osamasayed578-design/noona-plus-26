-- =============================================================================
-- ترقية 55: حركات الصرف للصيانة والإرجاع منها، وحساب «صيانة تحت التنفيذ» 1116 في أدلة الحسابات القائمة
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO inv_txn_type t
  USING (SELECT 'MAINT_ISSUE' code, 'صرف قطع غيار وزيوت للصيانة' name_ar, 'Issue to maintenance' name_en, 'ISSUE' cls, -1 sg FROM dual
         UNION ALL SELECT 'MAINT_RETURN', 'مرتجع من الصيانة', 'Return from maintenance', 'RETURN_IN', 1 FROM dual) x
     ON (t.tenant_id IS NULL AND t.code = x.code)
   WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, txn_class, qty_sign, requires_approval, default_reason_required,
                                 is_active, created_by)
        VALUES (NULL, x.code, x.name_ar, x.name_en, x.cls, x.sg, 'N', 'N', 'Y', 'SYSTEM');
  -- نفس موضع «سلف وعهد الموظفين» 1108 في كل دليل حسابات لا يحوي 1116
  INSERT INTO gl_account (tenant_id, name_ar, name_en, coa_id, account_code, parent_account_id, account_level, account_type,
                          normal_balance, is_postable, is_control, subledger_code, allow_manual_posting, currency_restriction,
                          revalue_fx, cash_flow_category, status_code, effective_from, created_by)
  SELECT a.tenant_id, 'صيانة تحت التنفيذ (مواد مصروفة للورش)', 'Maintenance work in progress', a.coa_id, '1116', a.parent_account_id,
         a.account_level, a.account_type, a.normal_balance, 'Y', 'N', NULL, a.allow_manual_posting, a.currency_restriction,
         a.revalue_fx, a.cash_flow_category, 'ACTIVE', a.effective_from, 'SYSTEM'
    FROM gl_account a
   WHERE a.account_code = '1108'
     AND NOT EXISTS (SELECT 1 FROM gl_account b WHERE b.coa_id = a.coa_id AND b.account_code = '1116');
  DBMS_OUTPUT.PUT_LINE('1116 accounts added: ' || SQL%ROWCOUNT);
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  ROLLBACK;
  RAISE;
END;
/
