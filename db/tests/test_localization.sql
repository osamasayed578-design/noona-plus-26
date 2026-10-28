-- =============================================================================
-- NOONA PLUS ERP | اختبار حزم الدول والضرائب: تطبيق حزمة الدولة وحسابات الضرائب، النسب بإصداراتها، التسجيلات وصيغ أرقامها،
--                  السجل الضريبي الموحد، إقرار ضريبة القيمة المضافة (احتساب، تصحيح، مراجعة، اعتماد بقيد، تقديم، سداد)،
--                  الاستقطاع وشهاداته وإقراره، والفوترة الإلكترونية المرحلة الثانية بالمحاكي (السلسلة، التجزئة، QR، UBL)
--                  (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_localization.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_d    VARCHAR2(10) := TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  l_n    NUMBER;
  l_x    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_box  NUMBER;
  l_cus  NUMBER;
  l_bad  NUMBER;
  l_sup  NUMBER;
  l_frn  NUMBER;
  l_item NUMBER;
  l_srv  NUMBER;
  l_reg  NUMBER;
  l_vtype NUMBER;
  l_inv1 NUMBER;
  l_inv2 NUMBER;
  l_inv3 NUMBER;
  l_ap   NUMBER;
  l_ret  NUMBER;
  l_wret NUMBER;
  l_cert NUMBER;
  l_cert2 NUMBER;
  l_prof NUMBER;
  l_s1   loc_einvoice_submission%ROWTYPE;
  l_s2   loc_einvoice_submission%ROWTYPE;
  r      loc_tax_return%ROWTYPE;
  l_out  NUMBER;
  l_in   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION ret(p_id NUMBER) RETURN loc_tax_return%ROWTYPE IS
    l loc_tax_return%ROWTYPE;
  BEGIN SELECT * INTO l FROM loc_tax_return WHERE id = p_id; RETURN l; END ret;
  FUNCTION box(p_id NUMBER, p_box VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN SELECT NVL(MAX(tax_amount), 0) INTO l FROM loc_tax_return_line WHERE tax_return_id = p_id AND box_code = p_box; RETURN l; END box;
  FUNCTION sub(p_inv NUMBER) RETURN loc_einvoice_submission%ROWTYPE IS
    l loc_einvoice_submission%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM loc_einvoice_submission WHERE id = (SELECT einvoice_submission_id FROM sal_invoice WHERE id = p_inv); RETURN l;
  END sub;
  -- حسابات قيد مستند: كود:مدين/دائن مرتبة
  FUNCTION jl(p_event NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(a.account_code || ':' || SUM(l.debit_amount) || '/' || SUM(l.credit_amount), ' ') WITHIN GROUP (ORDER BY a.account_code)
      INTO l FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id JOIN gl_account a ON a.id = l.account_id
     WHERE j.accounting_event_id = p_event GROUP BY a.account_code;
    RETURN l;
  EXCEPTION WHEN OTHERS THEN RETURN SQLERRM;
  END jl;
  FUNCTION balanced(p_event NUMBER) RETURN BOOLEAN IS
    l_d NUMBER; l_k NUMBER;
  BEGIN
    SELECT SUM(l.debit_amount), SUM(l.credit_amount) INTO l_d, l_k FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE j.accounting_event_id = p_event;
    RETURN l_d = l_k AND l_d > 0;
  END balanced;
  -- يفك QR (Base64 ثم TLV) ويعيد قيمة الوسم
  FUNCTION qr_tag(p_qr VARCHAR2, p_tag PLS_INTEGER) RETURN VARCHAR2 IS
    l_r RAW(4000) := UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(p_qr));
    l_i PLS_INTEGER := 1;
    l_t PLS_INTEGER;
    l_l PLS_INTEGER;
  BEGIN
    WHILE l_i < UTL_RAW.LENGTH(l_r) LOOP
      l_t := TO_NUMBER(RAWTOHEX(UTL_RAW.SUBSTR(l_r, l_i, 1)), 'XX');
      l_l := TO_NUMBER(RAWTOHEX(UTL_RAW.SUBSTR(l_r, l_i + 1, 1)), 'XX');
      IF l_t = p_tag THEN RETURN UTL_I18N.RAW_TO_CHAR(UTL_RAW.SUBSTR(l_r, l_i + 2, l_l), 'AL32UTF8'); END IF;
      l_i := l_i + 2 + l_l;
    END LOOP;
    RETURN NULL;
  END qr_tag;
BEGIN
  NOONA_APEX_PKG.cleanup_request;
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  UPDATE dms_archive_rule SET is_active = 'N';
  -- بيئة نظيفة لليوم: لا إقرارات سابقة تغطيه، ولا فوترة إلكترونية مفعلة من قبل
  DELETE FROM loc_einvoice_submission WHERE company_id = NOONA_LOC_PKG.company;
  UPDATE sal_invoice SET einvoice_submission_id = NULL WHERE company_id = NOONA_LOC_PKG.company AND einvoice_submission_id IS NOT NULL;
  DELETE FROM loc_einvoice_profile WHERE company_id = NOONA_LOC_PKG.company;
  -- شهادات استقطاع سابقة لليوم (من بيانات تجريبية) لا تدخل في حساب إقرار الاختبار
  UPDATE loc_withholding_cert SET status_code = 'CANCELLED' WHERE company_id = NOONA_LOC_PKG.company AND payment_date >= TRUNC(SYSDATE) - 1;

  -- ======================================================== حزمة الدولة
  ok('company is Saudi', NOONA_LOC_PKG.company_country = 'SA', NOONA_LOC_PKG.company_country);
  l_n := NOONA_LOC_PKG.setup_company;
  ok('country pack applied to the company', NOONA_LOC_PKG.company_pack IS NOT NULL);
  ok('tax accounts ready (2104/1107/2106/2107)', NOONA_INV_PKG.acc_id('2104') IS NOT NULL AND NOONA_INV_PKG.acc_id('1107') IS NOT NULL
     AND NOONA_INV_PKG.acc_id('2106') IS NOT NULL AND NOONA_INV_PKG.acc_id('2107') IS NOT NULL);
  SELECT COUNT(*) INTO l_n FROM loc_tax_account WHERE company_id = NOONA_LOC_PKG.company;
  ok('tax accounts per tax code', l_n >= 8, l_n);
  ok('second setup adds nothing', NOONA_LOC_PKG.setup_company = 0);
  ok('standard VAT rate 15%', NOONA_LOC_PKG.rate_on(NOONA_INV_PKG.tax_id('VAT15')) = 15);
  SELECT COUNT(DISTINCT country_code) INTO l_n FROM loc_country_pack WHERE status_code = 'PUBLISHED'
   AND country_code IN ('SA', 'AE', 'BH', 'OM', 'QA', 'KW', 'EG', 'SD');
  ok('packs for 8 countries', l_n = 8, l_n);
  l_c := NOONA_LOC_PKG.pack_html('AE');
  ok('UAE pack shows 5% VAT', DBMS_LOB.INSTR(l_c, '5%') > 0);
  ok('Egypt pack shows 14% VAT', DBMS_LOB.INSTR(NOONA_LOC_PKG.pack_html('EG'), '14%') > 0);
  ok('Kuwait pack without VAT', DBMS_LOB.INSTR(NOONA_LOC_PKG.pack_html('KW'), 'VAT15') = 0);
  BEGIN l_n := NOONA_LOC_PKG.set_rate(NOONA_INV_PKG.tax_id('VAT15'), 15, DATE '2019-01-01'); ok('rate version cannot go back in time', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('rate version cannot go back in time', INSTR(SQLERRM, 'NOONA-LOC-011') > 0 OR INSTR(SQLERRM, 'PLATFORM') > 0 OR INSTR(SQLERRM, 'NOONA-') > 0, SQLERRM); END;

  -- ======================================================== التسجيلات
  ok('SA VAT format valid', NOONA_LOC_PKG.valid_tax_number('SA', '310123456700003') = 'Y');
  ok('SA VAT format invalid', NOONA_LOC_PKG.valid_tax_number('SA', '210123456700003') = 'N');
  ok('UAE TRN format', NOONA_LOC_PKG.valid_tax_number('AE', '100123456700003') = 'Y');
  SELECT r.id INTO l_vtype FROM loc_registration_type r JOIN loc_country_pack p ON p.id = r.country_pack_id WHERE p.country_code = 'SA' AND r.code = 'SA_VAT';
  BEGIN l_n := NOONA_LOC_PKG.save_registration('{"type":' || l_vtype || ',"number":"12345"}'); ok('bad VAT number rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('bad VAT number rejected', 'NOONA-LOC-021', SQLERRM); END;
  UPDATE org_legal_registration SET status_code = 'CANCELLED' WHERE company_id = NOONA_LOC_PKG.company AND reg_type_id = l_vtype;
  l_reg := NOONA_LOC_PKG.save_registration('{"type":' || l_vtype || ',"number":"3101 2345 6700 003","authority":"هيئة الزكاة والضريبة والجمارك","issue":"2020-01-01"}');
  ok('VAT registration saved (spaces removed)', NOONA_LOC_PKG.company_tax_number = '310123456700003', NOONA_LOC_PKG.company_tax_number);
  ok('registrations listed', DBMS_LOB.INSTR(NOONA_LOC_PKG.registrations_html, '310123456700003') > 0);

  -- ======================================================== الفوترة الإلكترونية (المحاكي)
  ok('SHA-256 Base64', NOONA_EINV_PKG.sha256_b64('abc') = 'ungWv48Bz+pBQUDeXa4iI7ADYaOWF3qctBD/YfIAFa0=', NOONA_EINV_PKG.sha256_b64('abc'));
  BEGIN l_n := NOONA_EINV_PKG.save_profile('{"adapter":"REST"}'); ok('REST adapter needs an endpoint', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('REST adapter needs an endpoint', 'NOONA-EINV-002', SQLERRM); END;
  l_prof := NOONA_EINV_PKG.save_profile('{"adapter":"SIMULATOR","mode":"CLEARANCE","device":"EGS-TEST-1","sandbox":"Y"}');
  ok('e-invoicing profile active', NOONA_EINV_PKG.active_profile = l_prof);

  l_box := NOONA_CSH_PKG.create_cash_box('LB' || SUBSTR(l_sfx, 1, 6), 'صندوق ضرائب اختبار');
  l_cus := NOONA_SAL_PKG.save_customer('{"name":"شركة عميل ضريبي ' || l_sfx || '","person":"N","tax":"300000000000003","term":"NET30"}');
  l_item := NOONA_INV_PKG.save_item('{"name":"خدمة اختبار ضريبي ' || l_sfx || '","type":"SERVICE","price":1000,"incl":"N"}');
  -- فاتورة ضريبية (B2B) آجلة: تعتمد من الهيئة (المحاكي) فور الترحيل
  l_inv1 := NOONA_SAL_PKG.save_invoice('{"cust":' || l_cus || ',"date":"' || l_d || '","mode":"CREDIT","action":"POST","lines":[{"i":' || l_item || ',"q":2,"p":1000}]}');
  SELECT doc_type || '|' || einvoice_status || '|' || tax_amount INTO l_s FROM sal_invoice WHERE id = l_inv1;
  ok('B2B invoice cleared on posting', l_s = 'INVOICE|CLEARED|300', l_s);
  l_s1 := sub(l_inv1);
  ok('first invoice: ICV 1 and PIH = initial hash', l_s1.invoice_counter = 1 AND l_s1.previous_hash = NOONA_EINV_PKG.c_first_pih, l_s1.invoice_counter);
  ok('invoice hash is SHA-256 Base64 of the XML', l_s1.invoice_hash = NOONA_EINV_PKG.sha256_b64(l_s1.xml_content) AND LENGTH(l_s1.invoice_hash) = 44);
  ok('UBL: 388 standard tax invoice', DBMS_LOB.INSTR(l_s1.xml_content, '<cbc:InvoiceTypeCode name="0100000">388</cbc:InvoiceTypeCode>') > 0);
  ok('UBL: UUID, ICV, seller and buyer VAT', DBMS_LOB.INSTR(l_s1.xml_content, '<cbc:UUID>' || l_s1.invoice_uuid || '</cbc:UUID>') > 0
     AND DBMS_LOB.INSTR(l_s1.xml_content, '<cbc:ID>ICV</cbc:ID><cbc:UUID>1</cbc:UUID>') > 0 AND DBMS_LOB.INSTR(l_s1.xml_content, '310123456700003') > 0
     AND DBMS_LOB.INSTR(l_s1.xml_content, '300000000000003') > 0);
  ok('UBL: totals 2000 + 300 = 2300', DBMS_LOB.INSTR(l_s1.xml_content, '<cbc:TaxExclusiveAmount currencyID="SAR">2000.00') > 0
     AND DBMS_LOB.INSTR(l_s1.xml_content, '<cbc:PayableAmount currencyID="SAR">2300.00') > 0);
  ok('UBL is well-formed XML', XMLTYPE(l_s1.xml_content) IS NOT NULL);
  ok('QR tags: seller VAT, total, VAT, hash', qr_tag(l_s1.qr_payload, 2) = '310123456700003' AND qr_tag(l_s1.qr_payload, 4) = '2300.00'
     AND qr_tag(l_s1.qr_payload, 5) = '300.00' AND qr_tag(l_s1.qr_payload, 6) = l_s1.invoice_hash, qr_tag(l_s1.qr_payload, 4));
  ok('simulator reference', l_s1.gov_reference LIKE 'SIM-%' AND l_s1.status_code = 'CLEARED');
  ok('printed invoice uses the e-invoice QR', NOONA_EINV_PKG.invoice_qr(l_inv1) = l_s1.qr_payload);
  -- فاتورة مبسطة نقدية: إبلاغ، والسلسلة تتصل
  l_inv2 := NOONA_SAL_PKG.save_invoice('{"date":"' || l_d || '","mode":"CASH","place":"BOX:' || l_box || '","action":"POST","lines":[{"i":' || l_item || ',"q":1,"p":1000}]}');
  l_s2 := sub(l_inv2);
  ok('simplified invoice reported', l_s2.status_code = 'ACCEPTED' AND l_s2.invoice_subtype = '0200000', l_s2.status_code || ' ' || l_s2.invoice_subtype);
  ok('hash chain: ICV 2 and PIH = previous hash', l_s2.invoice_counter = 2 AND l_s2.previous_hash = l_s1.invoice_hash);
  -- مشتري برقم ضريبي خاطئ: يفشل التحقق ولا يرسل
  l_bad := NOONA_SAL_PKG.save_customer('{"name":"عميل رقم خاطئ ' || l_sfx || '","person":"N","term":"NET30"}');
  UPDATE pty_party SET tax_number = '123' WHERE id = (SELECT c.party_id FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id WHERE a.id = l_bad);
  l_inv3 := NOONA_SAL_PKG.save_invoice('{"cust":' || l_bad || ',"date":"' || l_d || '","mode":"CREDIT","action":"POST","lines":[{"i":' || l_item || ',"q":1,"p":100}]}');
  SELECT einvoice_status INTO l_s FROM sal_invoice WHERE id = l_inv3;
  ok('invalid buyer VAT fails validation', sub(l_inv3).status_code = 'VALIDATION_FAILED' AND l_s = 'FAILED', sub(l_inv3).status_code || ' ' || l_s);
  ok('validation error code shown', DBMS_LOB.INSTR(NOONA_EINV_PKG.submission_html(sub(l_inv3).id), 'BR-KSA-44') > 0);
  -- يصحح الرقم ويعاد الإرسال
  UPDATE sal_invoice SET customer_tax_no_snapshot = '300000000000003' WHERE id = l_inv3;
  NOONA_EINV_PKG.submit(sub(l_inv3).id);
  ok('corrected invoice cleared on retry', sub(l_inv3).status_code = 'CLEARED', sub(l_inv3).status_code);
  ok('queue process with nothing pending', NOONA_EINV_PKG.process_queue = 0);
  ok('queue and summary screens', DBMS_LOB.INSTR(NOONA_EINV_PKG.queue_html, 'معتمد من الهيئة') > 0 AND DBMS_LOB.INSTR(NOONA_EINV_PKG.summary_html, 'المحاكي') > 0);
  -- إشعار دائن: 381 يشير للفاتورة الأصلية
  SELECT MIN(id) INTO l_n FROM sal_invoice_line WHERE invoice_id = l_inv1;
  l_x := NOONA_SAL_PKG.post_return('{"inv":' || l_inv1 || ',"date":"' || l_d || '","reason":"مرتجع جزئي","lines":[{"l":' || l_n || ',"q":1}]}');
  ok('credit note e-invoice 381 with billing reference', l_x IS NOT NULL AND DBMS_LOB.INSTR(sub(l_x).xml_content, '>381</cbc:InvoiceTypeCode>') > 0
     AND DBMS_LOB.INSTR(sub(l_x).xml_content, '<cac:BillingReference>') > 0);

  -- ======================================================== السجل والإقرار
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"مورد محلي ضريبي ' || l_sfx || '","person":"N","term":"NET30"}');
  l_ap := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || l_d || '","supInv":"L-' || l_sfx || '","action":"POST","lines":[{"i":' || l_item || ',"q":1,"p":400}]}');
  SELECT NVL(SUM(CASE WHEN direction = 'SALE' THEN tax_amount END), 0), NVL(SUM(CASE WHEN direction = 'PURCHASE' THEN tax_amount END), 0)
    INTO l_out, l_in FROM noona_v_tax_register WHERE company_id = NOONA_LOC_PKG.company AND doc_date = TRUNC(SYSDATE);
  SELECT COUNT(*) INTO l_n FROM noona_v_tax_register WHERE source_type = 'SAL_INVOICE' AND source_id IN (l_inv1, l_inv2, l_inv3);
  ok('register: sales invoices included', l_n = 3, l_n);
  SELECT NVL(SUM(tax_amount), 0) INTO l_n FROM noona_v_tax_register WHERE source_type = 'SAL_INVOICE' AND source_id = l_x;
  ok('register: credit note reduces output VAT', l_n = -150, l_n);
  SELECT NVL(SUM(tax_amount), 0) INTO l_n FROM noona_v_tax_register WHERE source_type = 'AP_INVOICE' AND source_id = l_ap;
  ok('register: supplier invoice input VAT', l_n = 60, l_n);
  ok('register screen', DBMS_LOB.INSTR(NOONA_LOC_PKG.register_html(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'فاتورة مورد') > 0);

  BEGIN l_n := NOONA_LOC_PKG.new_return('VAT', TRUNC(SYSDATE) + 1, TRUNC(SYSDATE) + 30); ok('future period rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('future period rejected', 'NOONA-LOC-034', SQLERRM); END;
  DELETE FROM loc_tax_return_line WHERE tax_return_id IN (SELECT id FROM loc_tax_return WHERE company_id = NOONA_LOC_PKG.company AND period_end >= TRUNC(SYSDATE));
  DELETE FROM loc_tax_return WHERE company_id = NOONA_LOC_PKG.company AND period_end >= TRUNC(SYSDATE);
  l_ret := NOONA_LOC_PKG.new_return('VAT', TRUNC(SYSDATE), TRUNC(SYSDATE));
  r := ret(l_ret);
  ok('return output VAT = register', r.output_tax = l_out, r.output_tax || ' vs ' || l_out);
  ok('return input VAT = register', r.input_tax = l_in, r.input_tax || ' vs ' || l_in);
  ok('box 13 = output - input', box(l_ret, '13') = l_out - l_in AND r.net_payable = l_out - l_in, box(l_ret, '13'));
  ok('box 1 standard sales tax', box(l_ret, '1') >= 300 + 150 + 15 - 150, box(l_ret, '1'));
  ok('box 6 total sales = output', box(l_ret, '6') = r.output_tax);
  BEGIN l_n := NOONA_LOC_PKG.new_return('VAT', TRUNC(SYSDATE), TRUNC(SYSDATE)); ok('overlapping return rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('overlapping return rejected', 'NOONA-LOC-036', SQLERRM); END;
  BEGIN NOONA_LOC_PKG.set_adjustment(l_ret, '14', 10, NULL); ok('correction needs a reason', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('correction needs a reason', 'NOONA-LOC-038', SQLERRM); END;
  NOONA_LOC_PKG.set_adjustment(l_ret, '14', 10, 'فاتورة الشهر السابق لم تدرج');
  ok('correction box adds to net', ret(l_ret).net_payable = l_out - l_in + 10 AND box(l_ret, '16') = l_out - l_in + 10);
  BEGIN NOONA_LOC_PKG.approve_return(l_ret); ok('approval needs review', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approval needs review', 'NOONA-LOC-039', SQLERRM); END;
  NOONA_LOC_PKG.review_return(l_ret, 'راجعه المحاسب');
  NOONA_LOC_PKG.approve_return(l_ret);
  r := ret(l_ret);
  ok('approved with settlement journal', r.status_code = 'APPROVED' AND balanced(r.accounting_event_id));
  ok('settlement: Dr output, Cr input, Cr payable', jl(r.accounting_event_id) = '1107:0/' || l_in || ' 2104:' || (l_out + 10) || '/0 2107:0/' || (l_out - l_in + 10),
     jl(r.accounting_event_id));
  BEGIN NOONA_LOC_PKG.set_adjustment(l_ret, '14', 0, 'x'); ok('approved return locked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approved return locked', 'NOONA-LOC-031', SQLERRM); END;
  -- إعادة الفتح تعكس القيد
  NOONA_LOC_PKG.reopen_return(l_ret, 'تصحيح قبل التقديم');
  ok('reopen reverses settlement', ret(l_ret).status_code = 'DRAFT' AND ret(l_ret).accounting_event_id IS NULL);
  NOONA_LOC_PKG.review_return(l_ret);
  NOONA_LOC_PKG.approve_return(l_ret);
  BEGIN NOONA_LOC_PKG.file_return(l_ret, NULL); ok('filing needs a reference', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('filing needs a reference', 'NOONA-LOC-041', SQLERRM); END;
  NOONA_LOC_PKG.file_return(l_ret, 'ZATCA-' || l_sfx);
  ok('filed with authority reference', ret(l_ret).status_code = 'FILED' AND ret(l_ret).gov_reference = 'ZATCA-' || l_sfx, ret(l_ret).status_code);
  BEGIN NOONA_LOC_PKG.reopen_return(l_ret, 'x'); ok('filed return cannot reopen', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('filed return cannot reopen', 'NOONA-LOC-044', SQLERRM); END;
  l_n := NOONA_CSH_PKG.balance(l_box, NULL);
  NOONA_LOC_PKG.pay_return(l_ret, 'BOX:' || l_box);
  r := ret(l_ret);
  ok('return paid', r.status_code = 'PAID' AND r.paid_amount = r.net_payable AND balanced(r.payment_event_id));
  ok('payment: Dr 2107, Cr cash box', jl(r.payment_event_id) LIKE '%2107:' || r.net_payable || '/0%', jl(r.payment_event_id));
  ok('cash box paid out', NOONA_CSH_PKG.balance(l_box, NULL) = l_n - r.net_payable, NOONA_CSH_PKG.balance(l_box, NULL));
  l_c := NOONA_LOC_PKG.return_html(l_ret);
  ok('return screen shows SA boxes', DBMS_LOB.INSTR(l_c, '13 - إجمالي ضريبة القيمة المضافة المستحقة للفترة') > 0 AND DBMS_LOB.INSTR(l_c, 'ZATCA-' || l_sfx) > 0);
  ok('returns list', DBMS_LOB.INSTR(NOONA_LOC_PKG.returns_html, 'مسدد') > 0);
  ok('tax summary', DBMS_LOB.INSTR(NOONA_LOC_PKG.summary_html, '310123456700003') > 0);

  -- ======================================================== الاستقطاع
  l_frn := NOONA_PUR_PKG.save_supplier('{"name":"شركة استشارات أجنبية ' || l_sfx || '","person":"N","term":"NET30"}');
  UPDATE pty_party SET country_code = 'AE' WHERE id = (SELECT s.party_id FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id WHERE a.id = l_frn);
  ok('non-resident supplier detected', NOONA_LOC_PKG.is_non_resident(l_frn) = 'Y' AND NOONA_LOC_PKG.is_non_resident(l_sup) = 'N');
  l_srv := NOONA_PUR_PKG.save_invoice('{"sup":' || l_frn || ',"date":"' || l_d || '","supInv":"F-' || l_sfx || '","action":"POST","lines":[{"i":' || l_item || ',"q":1,"p":10000}]}');
  SELECT NVL(SUM(open_amount), 0) INTO l_x FROM ap_open_item WHERE supplier_account_id = l_frn AND item_type = 'INVOICE';
  BEGIN l_n := NOONA_LOC_PKG.withhold('{"supplier":' || l_frn || ',"code":"SA_WHT5","base":' || (l_x * 30) || '}'); ok('withholding over balance rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('withholding over balance rejected', 'NOONA-LOC-052', SQLERRM); END;
  l_cert := NOONA_LOC_PKG.withhold('{"supplier":' || l_frn || ',"code":"SA_WHT5","base":10000,"date":"' || l_d || '","service":"استشارات فنية"}');
  SELECT withheld_amount || '|' || rate_pct || '|' || certificate_no INTO l_s FROM loc_withholding_cert WHERE id = l_cert;
  ok('certificate 5% of 10000', l_s LIKE '500|5|WHT-%', l_s);
  SELECT NVL(SUM(open_amount), 0) INTO l_n FROM ap_open_item WHERE supplier_account_id = l_frn AND item_type = 'INVOICE';
  ok('supplier balance reduced by withholding', l_n = l_x - 500, l_n || ' vs ' || l_x);
  SELECT accounting_event_id INTO l_n FROM loc_withholding_cert WHERE id = l_cert;
  ok('withholding journal: Dr AP, Cr 2106', balanced(l_n) AND jl(l_n) LIKE '%2106:0/500%', jl(l_n));
  ok('certificate print', DBMS_LOB.INSTR(NOONA_LOC_PKG.certificate_html(l_cert), 'شهادة استقطاع ضريبي') > 0);
  ok('non-resident payments check', NOONA_LOC_PKG.wht_due_html(TRUNC(SYSDATE), TRUNC(SYSDATE)) IS NOT NULL);
  l_cert2 := NOONA_LOC_PKG.withhold('{"supplier":' || l_frn || ',"code":"SA_WHT15","base":1000,"service":"إتاوة"}');
  NOONA_LOC_PKG.cancel_withholding(l_cert2, 'خطأ في النسبة');
  SELECT NVL(SUM(open_amount), 0) INTO l_n FROM ap_open_item WHERE supplier_account_id = l_frn AND item_type = 'INVOICE';
  ok('cancelled certificate restores supplier balance', l_n = l_x - 500, l_n);
  l_wret := NOONA_LOC_PKG.new_return('WHT', TRUNC(SYSDATE), TRUNC(SYSDATE));
  ok('WHT return = issued certificates only', ret(l_wret).net_payable = 500 AND box(l_wret, 'SA_WHT5') = 500, ret(l_wret).net_payable);
  NOONA_LOC_PKG.review_return(l_wret);
  NOONA_LOC_PKG.approve_return(l_wret);
  ok('WHT return approved without VAT settlement journal', ret(l_wret).status_code = 'APPROVED' AND ret(l_wret).accounting_event_id IS NULL);
  BEGIN NOONA_LOC_PKG.cancel_withholding(l_cert, 'x'); ok('certificate in approved return cannot cancel', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('certificate in approved return cannot cancel', 'NOONA-LOC-054', SQLERRM); END;
  NOONA_LOC_PKG.file_return(l_wret, 'WHT-REF-' || l_sfx);
  NOONA_LOC_PKG.pay_return(l_wret, 'BOX:' || l_box);
  r := ret(l_wret);
  ok('WHT return paid: Dr 2106', r.status_code = 'PAID' AND jl(r.payment_event_id) LIKE '%2106:' || r.net_payable || '/0%', jl(r.payment_event_id));
  ok('withholding list', DBMS_LOB.INSTR(NOONA_LOC_PKG.withholding_html(TRUNC(SYSDATE), TRUNC(SYSDATE)), 'ضمن إقرار') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
