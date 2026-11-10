-- =============================================================================
-- NOONA PLUS ERP | اختبار نقل البيانات وبدء التشغيل (NOONA_CONN_PKG):
--   شجرة الحسابات والعملاء والموردون والأصناف والموظفون من ملفات، والأرصدة الافتتاحية للحسابات والنقدية والعملاء
--   والموردين والمخزون، وترميز الملفات، والإلغاء والمطابقة (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_onboarding.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_dt   DATE := TRUNC(SYSDATE, 'YYYY');
  l_n NUMBER; l_x NUMBER; l_s VARCHAR2(4000); l_c CLOB; l_job NUMBER; l_b NUMBER; l_j NUMBER;
  l_box NUMBER; l_bal0 NUMBER; l_cacc NUMBER; l_sacc NUMBER; l_item NUMBER; l_nb NUMBER;
  j   api_import_job%ROWTYPE;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END); END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION job(p_id NUMBER) RETURN api_import_job%ROWTYPE IS
    l api_import_job%ROWTYPE;
  BEGIN SELECT * INTO l FROM api_import_job WHERE id = p_id; RETURN l; END job;
  FUNCTION errs(p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN SELECT SUBSTR(JSON_SERIALIZE(errors), 1, 1500) INTO l FROM api_import_job WHERE id = p_id; RETURN l; END errs;
  FUNCTION jacc(p_journal NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(debit_amount - credit_amount), 0) INTO l FROM gl_journal_line WHERE journal_id = p_journal AND account_id = NOONA_INV_PKG.acc_id(p_code);
    RETURN l;
  END jacc;
  FUNCTION nl RETURN VARCHAR2 IS BEGIN RETURN CHR(10); END;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  -- ======================================================== البيانات الأساسية
  l_job := NOONA_CONN_PKG.import_csv('ACCOUNTS', 'coa.csv', 'رمز الحساب,اسم الحساب,الحساب الأب,حساب حركة' || nl
                                     || 'T9' || SUBSTR(l_sfx, 1, 4) || ',عهد اختبار نقل البيانات,11,نعم');
  j := job(l_job);
  ok('accounts imported with Arabic headers', j.ok_rows = 1 AND j.status_code = 'COMPLETED', errs(l_job));
  l_job := NOONA_CONN_PKG.import_csv('CUSTOMERS', 'c.csv', 'name,phone,term' || nl || 'عميل نقل ' || l_sfx || ',0551234567,NET30' || nl
                                     || 'عميل ثاني ' || l_sfx || ',,NET0');
  ok('customers imported', job(l_job).ok_rows = 2, errs(l_job));
  l_job := NOONA_CONN_PKG.import_csv('SUPPLIERS', 's.csv', 'name,term' || nl || 'مورد نقل ' || l_sfx || ',NET30');
  ok('suppliers imported', job(l_job).ok_rows = 1, errs(l_job));
  l_job := NOONA_CONN_PKG.import_csv('ITEMS', 'i.csv', 'no,name,type,price,barcode' || nl || 'OB-' || l_sfx || ',صنف رصيد افتتاحي,STOCK,5,629' || l_sfx);
  ok('items imported', job(l_job).ok_rows = 1, errs(l_job));
  SELECT id INTO l_item FROM inv_item WHERE item_no = 'OB-' || l_sfx;

  -- ======================================================== أرصدة الحسابات والنقدية
  l_box := NOONA_CSH_PKG.create_cash_box('OBX' || SUBSTR(l_sfx, 1, 5), 'صندوق رصيد افتتاحي');
  SELECT COUNT(*) INTO l_nb FROM gl_opening_batch;
  -- ملف خاطئ: حساب غير موجود وحساب تجميعي: لا يرحل شيء
  l_job := NOONA_CONN_PKG.import_csv('OPENING_GL', 'tb_bad.csv', 'code,debit,credit,place' || nl || '1101,1000,,OBX' || SUBSTR(l_sfx, 1, 5) || nl
                                     || 'ZZ99,500,,' || nl || '11,200,,' || nl || '3101,,1700,', l_dt);
  j := job(l_job);
  SELECT COUNT(*) INTO l_n FROM gl_opening_batch;
  ok('bad trial balance file rejected as a whole', j.status_code = 'FAILED' AND j.failed_rows = 2 AND l_n = l_nb, errs(l_job));
  ok('bad file reports unknown and summary accounts', INSTR(errs(l_job), 'NOONA-CON-043') > 0 AND INSTR(errs(l_job), 'NOONA-CON-044') > 0, errs(l_job));
  BEGIN
    l_job := NOONA_CONN_PKG.import_csv('OPENING_GL', 'tb.csv', 'code,debit', l_dt);
    ok('opening needs data rows', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('opening needs data rows', 'NOONA-CON-002', SQLERRM); END;
  BEGIN
    l_job := NOONA_CONN_PKG.import_csv('OPENING_GL', 'tb.csv', 'code,debit' || nl || '1101,5', NULL);
    ok('opening date required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('opening date required', 'NOONA-CON-039', SQLERRM); END;
  SELECT COUNT(*) INTO l_n FROM gl_opening_batch WHERE company_id = NOONA_CONN_PKG.company AND scope_code = 'GL' AND status_code = 'POSTED';
  IF l_n > 0 THEN
    -- بيئة سبق فيها استيراد أرصدة: نلغيها داخل الاختبار (يتراجع في النهاية)
    FOR b IN (SELECT id FROM gl_opening_batch WHERE company_id = NOONA_CONN_PKG.company AND scope_code = 'GL' AND status_code = 'POSTED') LOOP
      NOONA_CONN_PKG.cancel_opening(b.id, 'اختبار');
    END LOOP;
  END IF;
  l_bal0 := NOONA_CSH_PKG.balance(l_box, NULL);
  l_job := NOONA_CONN_PKG.import_csv('OPENING_GL', 'tb.csv',
             'code,name,debit,credit,place' || nl
          || '1101,الصندوق,25000,,OBX' || SUBSTR(l_sfx, 1, 5) || nl
          || '1103,العملاء,80000,,' || nl
          || '2101,الموردون,,90000,' || nl
          || '1105,المخزون,250,,' || nl
          || 'T9' || SUBSTR(l_sfx, 1, 4) || ',عهد,"1,500.50",,' || nl
          || '1106,صفر,0,0,' || nl
          || '3101,رأس المال,,30000,', l_dt);
  j := job(l_job);
  ok('trial balance imported', j.status_code = 'COMPLETED' AND j.ok_rows = 6 AND j.result_ref IS NOT NULL, errs(l_job));
  ok('control accounts reported as warnings, not posted', INSTR(errs(l_job), 'تنبيه') > 0 AND j.failed_rows = 0, errs(l_job));
  l_b := j.result_ref;
  SELECT journal_id INTO l_j FROM gl_opening_batch WHERE id = l_b;
  SELECT COUNT(*) INTO l_n FROM gl_journal WHERE id = l_j AND is_opening = 'Y' AND status_code = 'POSTED' AND journal_category = 'OPENING';
  ok('one posted opening journal', l_n = 1);
  ok('cash and petty accounts debited', jacc(l_j, '1101') = 25000 AND jacc(l_j, 'T9' || SUBSTR(l_sfx, 1, 4)) = 1500.5, jacc(l_j, '1101'));
  ok('control accounts not in the journal', jacc(l_j, '1103') = 0 AND jacc(l_j, '2101') = 0 AND jacc(l_j, '1105') = 0);
  ok('difference to opening balances account 3105', jacc(l_j, '3105') = -(25000 + 1500.5 - 30000), jacc(l_j, '3105'));
  ok('cash box balance includes the opening', NOONA_CSH_PKG.balance(l_box, NULL) = l_bal0 + 25000, NOONA_CSH_PKG.balance(l_box, NULL));
  SELECT COUNT(*) INTO l_n FROM gl_opening_line WHERE batch_id = l_b;
  ok('opening lines kept for reconciliation (incl. control)', l_n = 6, l_n);
  BEGIN
    l_job := NOONA_CONN_PKG.import_csv('OPENING_GL', 'tb2.csv', 'code,debit' || nl || '1106,5', l_dt);
    ok('second GL opening blocked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('second GL opening blocked', 'NOONA-CON-040', SQLERRM); END;

  -- ======================================================== أرصدة العملاء والموردين
  SELECT a.id INTO l_cacc FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
   WHERE p.display_name_ar = 'عميل نقل ' || l_sfx AND a.company_id = NOONA_CONN_PKG.company;
  l_job := NOONA_CONN_PKG.import_csv('OPENING_AR', 'ar.csv', 'العميل,رقم الفاتورة,التاريخ,تاريخ الاستحقاق,المبلغ' || nl
          || 'عميل نقل ' || l_sfx || ',INV-1,' || TO_CHAR(l_dt - 20, 'DD/MM/YYYY') || ',,85000' || nl
          || 'عميل نقل ' || l_sfx || ',CN-1,' || TO_CHAR(l_dt - 5, 'YYYY-MM-DD') || ',,-5000', l_dt);
  j := job(l_job);
  ok('customer openings imported', j.status_code = 'COMPLETED' AND j.ok_rows = 2, errs(l_job));
  ok('customer balance = invoices - credit notes', NOONA_SAL_PKG.customer_balance(l_cacc) = 80000, NOONA_SAL_PKG.customer_balance(l_cacc));
  SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE customer_account_id = l_cacc AND source_entity_type = 'GL_OPENING_BATCH'
     AND ((doc_no = 'INV-1' AND item_type = 'INVOICE' AND doc_date = l_dt - 20 AND due_date = l_dt + 10)
       OR (doc_no = 'CN-1' AND item_type = 'CREDIT_NOTE'));
  ok('open items with document date and term due date', l_n = 2, l_n);
  j := job(l_job);
  SELECT journal_id INTO l_j FROM gl_opening_batch WHERE id = j.result_ref;
  ok('receivable vs 3105', jacc(l_j, '1103') = 80000 AND jacc(l_j, '3105') = -80000, jacc(l_j, '1103'));
  l_job := NOONA_CONN_PKG.import_csv('OPENING_AR', 'ar2.csv', 'customer,doc,amount' || nl || 'عميل نقل ' || l_sfx || ',INV-1,10' || nl
          || 'لا يوجد ' || l_sfx || ',X,10', l_dt);
  ok('duplicate document and unknown customer rejected', job(l_job).status_code = 'FAILED' AND INSTR(errs(l_job), 'NOONA-CON-057') > 0
     AND INSTR(errs(l_job), 'NOONA-CON-053') > 0, errs(l_job));
  SELECT a.id INTO l_sacc FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
   WHERE p.display_name_ar = 'مورد نقل ' || l_sfx AND a.company_id = NOONA_CONN_PKG.company;
  l_job := NOONA_CONN_PKG.import_csv('OPENING_AP', 'ap.csv', 'supplier,invoiceNo,date,amount' || nl || 'مورد نقل ' || l_sfx || ',SUP-1,'
          || TO_CHAR(l_dt - 10, 'YYYY-MM-DD') || ',90000', l_dt);
  ok('supplier openings imported', job(l_job).status_code = 'COMPLETED', errs(l_job));
  ok('supplier balance includes opening', NOONA_PUR_PKG.supplier_balance(l_sacc) = 90000, NOONA_PUR_PKG.supplier_balance(l_sacc));
  l_c := NOONA_PUR_PKG.supplier_statement(l_sacc, l_dt - 30, l_dt + 30);
  ok('supplier statement shows the opening', INSTR(l_c, 'SUP-1') > 0 AND INSTR(l_c, '90,000.00') > 0);

  -- ======================================================== أرصدة المخزون
  l_job := NOONA_CONN_PKG.import_csv('OPENING_STOCK', 'st.csv', 'item,qty,cost' || nl || '629' || l_sfx || ',100,2.5', l_dt);
  j := job(l_job);
  ok('stock openings imported by barcode', j.status_code = 'COMPLETED' AND j.ok_rows = 1, errs(l_job));
  SELECT COUNT(*), MAX(t.id) INTO l_n, l_x FROM inv_transaction t WHERE t.source_entity_type = 'GL_OPENING_BATCH' AND t.source_entity_id = j.result_ref
     AND t.status_code = 'POSTED';
  ok('posted opening stock document', l_n = 1, l_n);
  SELECT NVL(SUM(total_cost), 0) INTO l_n FROM inv_transaction_line WHERE transaction_id = l_x AND item_id = l_item;
  ok('stock value = qty x cost', l_n = 250, l_n);
  l_job := NOONA_CONN_PKG.import_csv('OPENING_STOCK', 'st2.csv', 'item,qty' || nl || 'NOPE' || l_sfx || ',3' || nl || 'OB-' || l_sfx || ',-4', l_dt);
  ok('unknown item and negative qty rejected', job(l_job).status_code = 'FAILED' AND INSTR(errs(l_job), 'NOONA-CON-062') > 0
     AND INSTR(errs(l_job), 'NOONA-CON-063') > 0, errs(l_job));

  -- ======================================================== الموظفون
  l_s := '1' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 999999999)), 9, '0');
  l_job := NOONA_CONN_PKG.import_csv('EMPLOYEES', 'emp.csv', 'الاسم,رقم الهوية,الجنسية,الجنس,تاريخ التعيين,المسمى الوظيفي,الراتب الأساسي,بدل السكن,بدل النقل' || nl
          || 'موظف نقل ' || l_sfx || ',' || l_s || ',سعودي,ذكر,' || TO_CHAR(l_dt, 'YYYY-MM-DD') || ',محاسب,"8,000",2000,800' || nl
          || 'موظف خطأ ' || l_sfx || ',,SA,غير معروف,,,,,');
  j := job(l_job);
  ok('employees: one ok, one rejected', j.ok_rows = 1 AND j.failed_rows = 1 AND j.status_code = 'PARTIAL' AND INSTR(errs(l_job), 'NOONA-CON-072') > 0, errs(l_job));
  SELECT COUNT(*) INTO l_n FROM hr_employee WHERE national_id = l_s;
  ok('employee created with national id', l_n = 1);

  -- ======================================================== المطابقة والإلغاء
  l_c := NOONA_CONN_PKG.onboarding_html('#T=#TYPE#');
  ok('wizard shows steps and reconciliation', INSTR(l_c, 'OPENING_AR') > 0 AND INSTR(l_c, 'المطابقة') > 0 AND INSTR(l_c, '3105') > 0);
  l_c := NOONA_CONN_PKG.openings_html;
  ok('batches listed', INSTR(l_c, 'OB-GL') > 0 AND INSTR(l_c, 'OB-AR') > 0);
  SELECT MAX(id) INTO l_x FROM gl_opening_batch WHERE scope_code = 'AR' AND status_code = 'POSTED';
  NOONA_CONN_PKG.cancel_opening(l_x, 'ملف خاطئ');
  ok('cancel AR batch restores customer balance', NOONA_SAL_PKG.customer_balance(l_cacc) = 0, NOONA_SAL_PKG.customer_balance(l_cacc));
  SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE source_entity_type = 'GL_OPENING_BATCH' AND source_entity_id = l_x AND status_code = 'CANCELLED';
  ok('opening items cancelled', l_n = 2, l_n);
  SELECT MAX(id) INTO l_x FROM gl_opening_batch WHERE scope_code = 'AP' AND status_code = 'POSTED';
  NOONA_CONN_PKG.cancel_opening(l_x, 'ملف خاطئ');
  ok('cancel AP batch restores supplier balance', NOONA_PUR_PKG.supplier_balance(l_sacc) = 0, NOONA_PUR_PKG.supplier_balance(l_sacc));
  NOONA_CONN_PKG.cancel_opening(l_b, 'إعادة');
  ok('cancel GL batch reverses cash box', NOONA_CSH_PKG.balance(l_box, NULL) = l_bal0, NOONA_CSH_PKG.balance(l_box, NULL));
  BEGIN
    SELECT MAX(id) INTO l_x FROM gl_opening_batch WHERE scope_code = 'INV' AND status_code = 'POSTED';
    NOONA_CONN_PKG.cancel_opening(l_x, 'x');
    ok('stock batch cannot be cancelled', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('stock batch cannot be cancelled', 'NOONA-CON-082', SQLERRM); END;

  -- ======================================================== الملفات
  l_c := NOONA_CONN_PKG.file_to_csv(UTL_I18N.string_to_raw('الاسم,الجوال' || nl || 'مؤسسة',  'AL32UTF8'), 'a.csv');
  ok('UTF-8 CSV read', INSTR(l_c, 'مؤسسة') > 0);
  l_c := NOONA_CONN_PKG.file_to_csv(UTL_I18N.string_to_raw('الاسم,الجوال' || nl || 'مؤسسة', 'AR8MSWIN1256'), 'b.csv');
  ok('Windows-1256 CSV read (Arabic Excel save)', INSTR(l_c, 'مؤسسة') > 0, SUBSTR(l_c, 1, 60));
  BEGIN
    l_c := NOONA_CONN_PKG.file_to_csv(UTL_RAW.cast_to_raw('x'), 'old.xls');
    ok('old xls refused', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('old xls refused', 'NOONA-CON-031', SQLERRM); END;

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('==== onboarding: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
END;
/
EXIT
