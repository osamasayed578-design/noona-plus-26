-- =============================================================================
-- NOONA PLUS ERP | المستشفيات - مطالبات التأمين: NOONA_HIS_CLAIM_PKG (المرحلة الثانية)
--   دفعة مطالبات لجهة عن فترة (فواتير بحصة جهة لم تطالب)، إرسالها وملف إلكتروني بصيغة JSON (بيانات المستفيد والتشخيص
--   والخدمات برموز الفوترة والموافقات)، تسجيل رد الجهة (المقبول والمرفوض وسببه) بقيد رفض المطالبات (4129) وإشعار دائن
--   يخفض ذمة الجهة، ومتابعة التحصيل حتى السداد.
-- =============================================================================

CREATE OR REPLACE PACKAGE NOONA_HIS_CLAIM_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION create_batch(p_payer_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER;
  PROCEDURE remove_line(p_line_id IN NUMBER);
  PROCEDURE submit_batch(p_batch_id IN NUMBER, p_reference IN VARCHAR2);
  -- [{"inv":invoiceId,"approved":100,"reason":"..."}] ؛ الفواتير غير المذكورة مقبولة بالكامل؛ يسجل مرة واحدة للدفعة
  PROCEDURE record_response(p_batch_id IN NUMBER, p_lines IN CLOB);
  PROCEDURE cancel_batch(p_batch_id IN NUMBER);
  -- يحدث حالة الدفعة بعد التحصيل (مسددة إذا لم يبق على فواتيرها شيء)
  PROCEDURE refresh_batch(p_batch_id IN NUMBER);
  FUNCTION batch_html(p_batch_id IN NUMBER) RETURN CLOB;
  FUNCTION batch_json(p_batch_id IN NUMBER) RETURN CLOB;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
END NOONA_HIS_CLAIM_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_HIS_CLAIM_PKG AS

  c_bt  CONSTANT VARCHAR2(30) := 'HIS_CLAIM_BATCH';
  c_inv CONSTANT VARCHAR2(30) := 'HIS_INVOICE';

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'SUBMITTED' THEN 'مرسلة' WHEN 'PARTIAL' THEN 'مقبولة جزئياً' WHEN 'SETTLED' THEN 'مسددة'
                         WHEN 'CANCELLED' THEN 'ملغاة' ELSE p_status END;
  END status_label;

  FUNCTION get_batch(p_id NUMBER) RETURN his_claim_batch%ROWTYPE IS
    l his_claim_batch%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM his_claim_batch WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-160', 'دفعة المطالبات غير موجودة', 'Claim batch not found');
  END get_batch;

  PROCEDURE totals(p_id NUMBER) IS
  BEGIN
    UPDATE his_claim_batch b SET
      claimed_amount = (SELECT NVL(SUM(claimed_amount), 0) FROM his_claim_line WHERE batch_id = b.id),
      approved_amount = (SELECT NVL(SUM(NVL(approved_amount, claimed_amount)), 0) FROM his_claim_line WHERE batch_id = b.id),
      rejected_amount = (SELECT NVL(SUM(rejected_amount), 0) FROM his_claim_line WHERE batch_id = b.id)
     WHERE id = p_id;
  END totals;

  FUNCTION create_batch(p_payer_id IN NUMBER, p_from IN DATE, p_to IN DATE) RETURN NUMBER IS
    l_id NUMBER;
    l_no VARCHAR2(50);
    l_n  NUMBER := 0;
  BEGIN
    guard('HIS_INVOICE.CREATE');
    NOONA_CORE_PKG.assert(p_payer_id IS NOT NULL AND p_from IS NOT NULL AND p_to IS NOT NULL AND p_from <= p_to, 'NOONA-HIS-161',
                          'حدد الجهة والفترة', 'Payer and period are required');
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, c_bt, NULL, 'CL-', 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = c_bt);
    l_no := NOONA_REFERENCE_PKG.next_doc_no(c_bt, company, NULL, TRUNC(SYSDATE), c_bt, NULL);
    INSERT INTO his_claim_batch (company_id, doc_no, doc_date, payer_id, period_from, period_to, claimed_amount, approved_amount, rejected_amount, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), p_payer_id, p_from, p_to, 0, 0, 0, 'DRAFT')
    RETURNING id INTO l_id;
    -- الفواتير المرحلة بحصة جهة لم تدخل دفعة قائمة
    FOR i IN (SELECT i.id, i.payer_total FROM his_invoice i
               WHERE i.company_id = company AND i.payer_id = p_payer_id AND i.status_code = 'POSTED' AND i.payer_total > 0
                 AND i.doc_date BETWEEN p_from AND p_to AND i.claim_status = 'PENDING'
                 AND NOT EXISTS (SELECT 1 FROM his_claim_line l JOIN his_claim_batch b ON b.id = l.batch_id
                                  WHERE l.invoice_id = i.id AND b.status_code <> 'CANCELLED')
               ORDER BY i.doc_date, i.id) LOOP
      INSERT INTO his_claim_line (company_id, batch_id, invoice_id, claimed_amount, rejected_amount) VALUES (company, l_id, i.id, i.payer_total, 0);
      l_n := l_n + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-162', 'لا توجد فواتير غير مطالب بها لهذه الجهة في الفترة', 'No unclaimed invoices in the period');
    totals(l_id);
    RETURN l_id;
  END create_batch;

  PROCEDURE remove_line(p_line_id IN NUMBER) IS
    l_b NUMBER;
    l_bt his_claim_batch%ROWTYPE;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    SELECT batch_id INTO l_b FROM his_claim_line WHERE id = p_line_id AND company_id = company;
    l_bt := get_batch(l_b);
    NOONA_CORE_PKG.assert(l_bt.status_code = 'DRAFT', 'NOONA-HIS-163', 'تعدل الدفعة وهي مسودة فقط', 'Only draft batches can be edited');
    DELETE FROM his_claim_line WHERE id = p_line_id;
    totals(l_b);
  END remove_line;

  PROCEDURE submit_batch(p_batch_id IN NUMBER, p_reference IN VARCHAR2) IS
    l his_claim_batch%ROWTYPE := get_batch(p_batch_id);
    l_n NUMBER;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    NOONA_CORE_PKG.assert(l.status_code = 'DRAFT', 'NOONA-HIS-163', 'تعدل الدفعة وهي مسودة فقط', 'Only draft batches can be submitted');
    SELECT COUNT(*) INTO l_n FROM his_claim_line WHERE batch_id = p_batch_id;
    NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-HIS-162', 'الدفعة فارغة', 'Batch is empty');
    UPDATE his_claim_batch SET status_code = 'SUBMITTED', submitted_at = SYSTIMESTAMP, reference_no = p_reference WHERE id = p_batch_id;
    UPDATE his_invoice SET claim_status = 'SUBMITTED' WHERE id IN (SELECT invoice_id FROM his_claim_line WHERE batch_id = p_batch_id);
  END submit_batch;

  PROCEDURE record_response(p_batch_id IN NUMBER, p_lines IN CLOB) IS
    l      his_claim_batch%ROWTYPE := get_batch(p_batch_id);
    l_pay  his_payer%ROWTYPE;
    l_apr  NUMBER;
    l_rej  NUMBER;
    l_tot  NUMBER := 0;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_rec  NUMBER;
    l_racc NUMBER;
    l_j    NUMBER;
    l_ev   NUMBER;
    l_oi   NUMBER;
    l_open NUMBER;
    l_rsn  VARCHAR2(500);
    l_party NUMBER;
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    NOONA_CORE_PKG.assert(l.status_code = 'SUBMITTED', 'NOONA-HIS-164', 'يسجل الرد على دفعة مرسلة لم يسجل ردها', 'Batch must be submitted');
    SELECT * INTO l_pay FROM his_payer WHERE id = l.payer_id;
    FOR c IN (SELECT cl.id, cl.invoice_id, cl.claimed_amount, i.doc_no FROM his_claim_line cl JOIN his_invoice i ON i.id = cl.invoice_id
               WHERE cl.batch_id = p_batch_id ORDER BY cl.id) LOOP
      l_apr := NULL; l_rsn := NULL;
      IF p_lines IS NOT NULL THEN
        SELECT MAX(a), MAX(r) INTO l_apr, l_rsn FROM JSON_TABLE(p_lines, '$[*]' COLUMNS (inv NUMBER PATH '$.inv', a NUMBER PATH '$.approved',
                 r VARCHAR2(500) PATH '$.reason')) WHERE inv = c.invoice_id;
      END IF;
      l_apr := ROUND(NVL(l_apr, c.claimed_amount), 2);
      NOONA_CORE_PKG.assert(l_apr BETWEEN 0 AND c.claimed_amount, 'NOONA-HIS-165', 'المقبول للفاتورة ' || c.doc_no || ' خارج حدود المطالبة',
                            'Approved amount out of range');
      l_rej := c.claimed_amount - l_apr;
      NOONA_CORE_PKG.assert(l_rej = 0 OR TRIM(l_rsn) IS NOT NULL, 'NOONA-HIS-166', 'اذكر سبب الرفض للفاتورة ' || c.doc_no, 'Rejection reason is required');
      -- المرفوض يجب ألا يتجاوز المتبقي غير المحصل من الفاتورة
      SELECT MIN(id), NVL(SUM(open_amount), 0) INTO l_oi, l_open FROM ar_open_item
       WHERE source_entity_type = c_inv AND source_entity_id = c.invoice_id AND customer_account_id = l_pay.customer_account_id AND item_type = 'INVOICE';
      NOONA_CORE_PKG.assert(l_rej <= l_open, 'NOONA-HIS-167', 'المرفوض للفاتورة ' || c.doc_no || ' أكبر من المتبقي غير المحصل', 'Rejection exceeds open amount');
      UPDATE his_claim_line SET approved_amount = l_apr, rejected_amount = l_rej, reject_reason = l_rsn WHERE id = c.id;
      UPDATE his_invoice SET claim_status = CASE WHEN l_apr = 0 THEN 'REJECTED' WHEN l_rej > 0 THEN 'PARTIAL' ELSE 'SUBMITTED' END WHERE id = c.invoice_id;
      IF l_rej > 0 THEN
        UPDATE ar_open_item SET open_amount = open_amount - l_rej, open_func = open_func - l_rej,
                                status_code = CASE WHEN open_amount - l_rej = 0 THEN 'PAID' ELSE 'PARTIALLY_PAID' END
         WHERE id = l_oi;
        -- إشعار دائن يخفض رصيد الجهة
        INSERT INTO ar_open_item (company_id, branch_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id,
                                  item_type, doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func, status_code)
        VALUES (company, NULL, c_bt, p_batch_id, NOONA_GL_PKG.ledger_currency, 1, l_pay.customer_account_id, 'CREDIT_NOTE', l.doc_no || '/' || c.doc_no,
                TRUNC(SYSDATE), TRUNC(SYSDATE), c.id, l_rej, 0, l_rej, 0, 'PAID');
        l_tot := l_tot + l_rej;
      END IF;
    END LOOP;
    IF l_tot > 0 THEN
      SELECT MIN(id) INTO l_racc FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = '4129';
      IF l_racc IS NULL THEN
        l_racc := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '4129', 'رفض ومخصومات مطالبات التأمين', '4', 'REVENUE', 'Y', NULL);
      END IF;
      SELECT receivable_account_id INTO l_rec FROM ar_customer_account WHERE id = l_pay.customer_account_id;
      l_party := NOONA_SAL_PKG.customer_party(l_pay.customer_account_id);
      l_lines.EXTEND;
      l_lines(1).account_id := l_racc; l_lines(1).debit := l_tot; l_lines(1).description := 'رفض مطالبات ' || l_pay.name_ar || ' - دفعة ' || l.doc_no;
      l_lines.EXTEND;
      l_lines(2).account_id := l_rec; l_lines(2).credit := l_tot; l_lines(2).party_id := l_party;
      l_lines(2).description := 'رفض مطالبات ' || l_pay.name_ar || ' - دفعة ' || l.doc_no;
      l_j := NOONA_ACE_PKG.post_source('HIS_CLAIM_REJECTION', 'MEDICAL', c_bt, p_batch_id, TRUNC(SYSDATE), 'رفض مطالبات ' || l_pay.name_ar || ' - ' || l.doc_no,
                                       NOONA_GL_PKG.ledger_currency, 1, l_lines, l.doc_no, NULL, 'MEDICAL');
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      UPDATE his_claim_batch SET accounting_event_id = l_ev, posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name WHERE id = p_batch_id;
    END IF;
    totals(p_batch_id);
    UPDATE his_claim_batch SET status_code = CASE WHEN l_tot > 0 THEN 'PARTIAL' ELSE 'SUBMITTED' END WHERE id = p_batch_id;
    -- علامة أن الرد سجل (لا يسجل مرتين)
    UPDATE his_claim_line SET approved_amount = NVL(approved_amount, claimed_amount) WHERE batch_id = p_batch_id;
    refresh_batch(p_batch_id);
  END record_response;

  PROCEDURE refresh_batch(p_batch_id IN NUMBER) IS
    l_open NUMBER;
    l_n    NUMBER;
    l_resp NUMBER;
  BEGIN
    SELECT COUNT(*), COUNT(approved_amount) INTO l_n, l_resp FROM his_claim_line WHERE batch_id = p_batch_id;
    IF l_n = 0 OR l_resp < l_n THEN RETURN; END IF;
    SELECT NVL(SUM(a.open_amount), 0) INTO l_open
      FROM his_claim_line l JOIN ar_open_item a ON a.source_entity_type = c_inv AND a.source_entity_id = l.invoice_id AND a.item_type = 'INVOICE'
      JOIN his_claim_batch b ON b.id = l.batch_id JOIN his_payer y ON y.id = b.payer_id AND y.customer_account_id = a.customer_account_id
     WHERE l.batch_id = p_batch_id;
    IF l_open = 0 THEN
      UPDATE his_claim_batch SET status_code = 'SETTLED' WHERE id = p_batch_id AND status_code IN ('SUBMITTED', 'PARTIAL');
      UPDATE his_invoice SET claim_status = 'PAID' WHERE id IN (SELECT invoice_id FROM his_claim_line WHERE batch_id = p_batch_id AND approved_amount > 0);
    END IF;
  END refresh_batch;

  PROCEDURE cancel_batch(p_batch_id IN NUMBER) IS
    l his_claim_batch%ROWTYPE := get_batch(p_batch_id);
  BEGIN
    guard('HIS_INVOICE.UPDATE');
    NOONA_CORE_PKG.assert(l.status_code IN ('DRAFT', 'SUBMITTED') AND l.accounting_event_id IS NULL, 'NOONA-HIS-168',
                          'تلغى الدفعة قبل تسجيل رد الجهة فقط', 'Only batches without a response can be cancelled');
    UPDATE his_invoice SET claim_status = 'PENDING' WHERE id IN (SELECT invoice_id FROM his_claim_line WHERE batch_id = p_batch_id);
    UPDATE his_claim_batch SET status_code = 'CANCELLED' WHERE id = p_batch_id;
  END cancel_batch;

  FUNCTION batch_html(p_batch_id IN NUMBER) RETURN CLOB IS
    l    his_claim_batch%ROWTYPE;
    l_h  CLOB;
    l_py VARCHAR2(200);
    l_cn VARCHAR2(100);
  BEGIN
    guard('HIS_INVOICE.VIEW');
    SELECT * INTO l FROM his_claim_batch WHERE id = p_batch_id AND company_id = company;
    SELECT name_ar, contract_no INTO l_py, l_cn FROM his_payer WHERE id = l.payer_id;
    l_h := '<div class="nn-his-inv"><div class="nn-his-inv-h"><div><b>' || esc(NOONA_SAL_PKG.seller_name) || '</b><br>' || esc(l_py) || ' · عقد ' || esc(l_cn)
        || '</div><div><h2>دفعة مطالبات ' || esc(l.doc_no) || '</h2>' || status_label(l.status_code) || ' · ' || TO_CHAR(l.period_from, 'YYYY-MM-DD') || ' إلى '
        || TO_CHAR(l.period_to, 'YYYY-MM-DD') || CASE WHEN l.reference_no IS NOT NULL THEN '<br>مرجع الجهة: ' || esc(l.reference_no) END || '</div></div>'
        || '<table class="nn-rst-cred"><thead><tr><th>الفاتورة</th><th>التاريخ</th><th>المريض</th><th>العضوية</th><th>التشخيص</th><th>الخدمات</th>'
        || '<th class="n">المطالب</th><th class="n">المقبول</th><th class="n">المرفوض</th><th>السبب</th><th class="n">المتبقي</th></tr></thead><tbody>';
    FOR r IN (SELECT cl.*, i.doc_no, i.doc_date, p.name_ar, p.member_no, v.diagnosis, v.icd10,
                     (SELECT LISTAGG(NOONA_HIS_PKG.service_name(o.service_id) || NVL2(o.approval_no, ' [' || o.approval_no || ']', ''), '، ')
                             WITHIN GROUP (ORDER BY o.line_no) FROM his_order o WHERE o.invoice_id = i.id AND o.payer_net > 0) srv,
                     (SELECT NVL(SUM(a.open_amount), 0) FROM ar_open_item a JOIN his_payer y ON y.id = l.payer_id AND y.customer_account_id = a.customer_account_id
                       WHERE a.source_entity_type = c_inv AND a.source_entity_id = i.id AND a.item_type = 'INVOICE') open_amt
                FROM his_claim_line cl JOIN his_invoice i ON i.id = cl.invoice_id JOIN his_visit v ON v.id = i.visit_id JOIN his_patient p ON p.id = i.patient_id
               WHERE cl.batch_id = p_batch_id ORDER BY i.doc_date, i.doc_no) LOOP
      l_h := l_h || ('<tr><td>' || esc(r.doc_no) || '</td><td>' || TO_CHAR(r.doc_date, 'YYYY-MM-DD') || '</td><td>' || esc(r.name_ar) || '</td><td>'
          || esc(r.member_no) || '</td><td dir="ltr">' || esc(r.icd10) || ' ' || esc(r.diagnosis) || '</td><td dir="ltr">' || esc(r.srv) || '</td><td class="n">'
          || fmt0(r.claimed_amount) || '</td><td class="n">' || CASE WHEN r.approved_amount IS NOT NULL THEN fmt0(r.approved_amount) END || '</td><td class="n">'
          || CASE WHEN r.rejected_amount > 0 THEN '<b class="nn-neg">' || fmt0(r.rejected_amount) || '</b>' END || '</td><td>' || esc(r.reject_reason)
          || '</td><td class="n">' || fmt0(r.open_amt) || '</td></tr>');
    END LOOP;
    RETURN l_h || ('</tbody><tfoot><tr><td colspan="6">الإجمالي</td><td class="n">' || fmt0(l.claimed_amount) || '</td><td class="n">' || fmt0(l.approved_amount)
        || '</td><td class="n">' || fmt0(l.rejected_amount) || '</td><td colspan="2"></td></tr></tfoot></table></div>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<p class="nn-hint">الدفعة غير موجودة</p>';
  END batch_html;

  FUNCTION batch_json(p_batch_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    guard('HIS_INVOICE.VIEW');
    -- ملف المطالبة الإلكتروني: المزود والجهة، ولكل فاتورة المستفيد والتشخيص والخدمات برموز الفوترة والموافقات
    SELECT JSON_OBJECT('batch' VALUE b.doc_no, 'period' VALUE JSON_OBJECT('from' VALUE TO_CHAR(b.period_from, 'YYYY-MM-DD'), 'to' VALUE TO_CHAR(b.period_to, 'YYYY-MM-DD')),
             'provider' VALUE JSON_OBJECT('name' VALUE NOONA_SAL_PKG.seller_name, 'vat' VALUE NOONA_SAL_PKG.seller_vat),
             'payer' VALUE JSON_OBJECT('code' VALUE y.code, 'name' VALUE y.name_ar, 'contract' VALUE y.contract_no),
             'total' VALUE b.claimed_amount,
             'claims' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('invoice' VALUE i.doc_no, 'date' VALUE TO_CHAR(i.doc_date, 'YYYY-MM-DD'),
                               'visitType' VALUE v.visit_type,
                               'patient' VALUE JSON_OBJECT('mrn' VALUE p.mrn, 'name' VALUE NVL(p.name_en, p.name_ar), 'idType' VALUE p.id_type, 'id' VALUE p.id_no,
                                                           'gender' VALUE p.gender, 'birthDate' VALUE TO_CHAR(p.birth_date, 'YYYY-MM-DD'),
                                                           'member' VALUE p.member_no, 'policy' VALUE p.policy_no),
                               'diagnosis' VALUE JSON_OBJECT('icd10' VALUE v.icd10, 'text' VALUE v.diagnosis),
                               'items' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('code' VALUE NVL(s.billing_code, s.code), 'name' VALUE NOONA_HIS_PKG.service_name(s.id),
                                                   'type' VALUE s.service_type, 'qty' VALUE o.quantity, 'unitPrice' VALUE o.unit_price, 'gross' VALUE o.gross_amount,
                                                   'patientShare' VALUE o.patient_net, 'net' VALUE o.payer_net, 'vat' VALUE o.payer_vat,
                                                   'approval' VALUE o.approval_no) ORDER BY o.line_no RETURNING CLOB)
                                                FROM his_order o JOIN his_service s ON s.id = o.service_id WHERE o.invoice_id = i.id AND o.payer_net > 0) FORMAT JSON,
                               'claimed' VALUE cl.claimed_amount) ORDER BY i.doc_date, i.doc_no RETURNING CLOB)
                               FROM his_claim_line cl JOIN his_invoice i ON i.id = cl.invoice_id JOIN his_visit v ON v.id = i.visit_id
                               JOIN his_patient p ON p.id = i.patient_id WHERE cl.batch_id = b.id) FORMAT JSON
             RETURNING CLOB)
      INTO l
      FROM his_claim_batch b JOIN his_payer y ON y.id = b.payer_id WHERE b.id = p_batch_id AND b.company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-HIS-160', 'دفعة المطالبات غير موجودة', 'Claim batch not found');
  END batch_json;

END NOONA_HIS_CLAIM_PKG;
/
