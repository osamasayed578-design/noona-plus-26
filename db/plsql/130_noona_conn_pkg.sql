-- =============================================================================
-- NOONA PLUS ERP | NOONA_CONN_PKG - الموصلات الجاهزة
--   * استيراد CSV للعملاء والموردين والأصناف: عناوين الأعمدة بالعربي أو الإنجليزي، كل صف مستقل (خطأ صف لا يوقف الباقي)
--     ونتيجة الاستيراد وأخطاؤه في مهمة استيراد
--   * كشف الحساب البنكي (CSV): أسطر بلا تكرار (بصمة السطر)، ومطابقة تلقائية مع حركات البنك (المبلغ والاتجاه والتاريخ ±3 أيام
--     والمرجع) كمقترحات تعتمد أو ترفض، والسطر المعتمد يعلم الحركة «مسواة»
--   * طلبات المتجر الإلكتروني: الطلب يصبح فاتورة مبيعات مرحلة (وتحصيلها إن كان مدفوعاً) مرة واحدة فقط لكل رقم طلب
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_CONN_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- p_type: CUSTOMERS | SUPPLIERS | ITEMS ؛ يعيد رقم مهمة الاستيراد
  FUNCTION import_csv(p_type IN VARCHAR2, p_file_name IN VARCHAR2, p_csv IN CLOB) RETURN NUMBER;
  -- كشف بنكي: أعمدة التاريخ والمبلغ (أو مدين/دائن) والمرجع والطرف والبيان؛ يعيد رقم الكشف
  FUNCTION import_bank_statement(p_bank_account_id IN NUMBER, p_file_name IN VARCHAR2, p_csv IN CLOB,
                                 p_opening IN NUMBER DEFAULT NULL, p_closing IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- يعيد عدد المقترحات الجديدة
  FUNCTION auto_match(p_statement_id IN NUMBER) RETURN NUMBER;
  PROCEDURE confirm_match(p_match_id IN NUMBER);
  PROCEDURE reject_match(p_match_id IN NUMBER);
  FUNCTION confirm_all(p_statement_id IN NUMBER) RETURN NUMBER;
  PROCEDURE ignore_line(p_line_id IN NUMBER);
  -- طلب متجر: {"orderId","date","customer":{"name","phone","email","taxNumber"},"lines":[{"sku"|"item","description","qty","price"}],
  --   "shipping":0,"paid":true,"place":"BANK:1","method":"CARD","reference"}
  FUNCTION ingest_order(p_body IN CLOB, p_source IN VARCHAR2 DEFAULT 'STORE') RETURN CLOB;
  -- مستند الصنف من حقول الواجهة/الملف (الفئة الافتراضية إن لم تحدد)
  FUNCTION item_doc(p_no IN VARCHAR2, p_name IN VARCHAR2, p_name_en IN VARCHAR2, p_type IN VARCHAR2, p_price IN NUMBER,
                    p_barcode IN VARCHAR2, p_category IN VARCHAR2, p_incl IN VARCHAR2 DEFAULT 'N') RETURN CLOB;

  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION template_csv(p_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION jobs_html RETURN CLOB;
  FUNCTION job_html(p_job_id IN NUMBER) RETURN CLOB;
  FUNCTION statements_html(p_bank_account_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION statement_html(p_statement_id IN NUMBER) RETURN CLOB;
END NOONA_CONN_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_CONN_PKG AS

  TYPE t_row  IS TABLE OF VARCHAR2(4000);
  TYPE t_rows IS TABLE OF t_row;
  TYPE t_map  IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00'); END fmt;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION type_label(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type WHEN 'CUSTOMERS' THEN 'العملاء' WHEN 'SUPPLIERS' THEN 'الموردون' WHEN 'ITEMS' THEN 'الأصناف'
      WHEN 'BANK_STATEMENT' THEN 'كشف حساب بنكي' WHEN 'ORDERS' THEN 'طلبات المتجر' ELSE p_type END;
  END type_label;

  FUNCTION template_csv(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type
      WHEN 'CUSTOMERS' THEN 'name,phone,email,tax,cr,address,term' || CHR(10) || 'مؤسسة النور التجارية,0551234567,info@alnoor.sa,300000000000003,1010101010,الرياض,NET30'
      WHEN 'SUPPLIERS' THEN 'name,phone,email,tax,cr,address,term' || CHR(10) || 'شركة التوريدات المتحدة,0112345678,sales@united.sa,310000000000003,1010202020,جدة,NET30'
      WHEN 'ITEMS' THEN 'no,name,nameEn,type,price,barcode,category' || CHR(10) || 'ITM-1001,قلم أزرق,Blue pen,STOCK,2.50,6281000000011,'
      WHEN 'BANK_STATEMENT' THEN 'date,amount,reference,counterparty,description' || CHR(10) || '2026-10-01,15000,TRF-889,مؤسسة النور,تحويل وارد'
                                 || CHR(10) || '2026-10-02,-2300,CHQ-1002,شركة التوريدات,سداد مورد' END;
  END template_csv;

  -- ================================================================ CSV
  FUNCTION parse_csv(p_csv CLOB) RETURN t_rows IS
    l_rows  t_rows := t_rows();
    l_row   t_row := t_row();
    l_fld   VARCHAR2(32767);
    l_q     BOOLEAN := FALSE;
    l_len   PLS_INTEGER := NVL(DBMS_LOB.getlength(p_csv), 0);
    l_pos   PLS_INTEGER := 1;
    l_buf   VARCHAR2(32767);
    l_i     PLS_INTEGER;
    l_c     VARCHAR2(4 CHAR);
    l_sep   VARCHAR2(1 CHAR) := ',';
    l_any   BOOLEAN := FALSE;
    PROCEDURE end_field IS
    BEGIN
      l_row.EXTEND; l_row(l_row.COUNT) := SUBSTR(TRIM(l_fld), 1, 4000); l_fld := NULL; l_any := TRUE;
    END;
    PROCEDURE end_row IS
    BEGIN
      end_field;
      IF NOT (l_row.COUNT = 1 AND l_row(1) IS NULL) THEN
        l_rows.EXTEND; l_rows(l_rows.COUNT) := l_row;
      END IF;
      l_row := t_row(); l_any := FALSE;
    END;
  BEGIN
    -- الفاصل: فاصلة أو فاصلة منقوطة (إكسل العربي) حسب السطر الأول
    l_buf := DBMS_LOB.substr(p_csv, 2000, 1);
    l_buf := SUBSTR(l_buf, 1, NVL(NULLIF(INSTR(l_buf, CHR(10)), 0), LENGTH(l_buf)));
    IF REGEXP_COUNT(l_buf, ';') > REGEXP_COUNT(l_buf, ',') THEN l_sep := ';'; END IF;
    IF REGEXP_COUNT(l_buf, CHR(9)) > GREATEST(REGEXP_COUNT(l_buf, ','), REGEXP_COUNT(l_buf, ';')) THEN l_sep := CHR(9); END IF;
    WHILE l_pos <= l_len LOOP
      l_buf := DBMS_LOB.substr(p_csv, 8000, l_pos);
      l_pos := l_pos + LENGTH(l_buf);
      l_i := 1;
      WHILE l_i <= LENGTH(l_buf) LOOP
        l_c := SUBSTR(l_buf, l_i, 1);
        IF l_q THEN
          IF l_c = '"' THEN
            IF SUBSTR(l_buf, l_i + 1, 1) = '"' THEN l_fld := l_fld || '"'; l_i := l_i + 1; ELSE l_q := FALSE; END IF;
          ELSE
            l_fld := l_fld || l_c;
          END IF;
        ELSIF l_c = '"' THEN l_q := TRUE;
        ELSIF l_c = l_sep THEN end_field;
        ELSIF l_c = CHR(10) THEN end_row;
        ELSIF l_c IN (CHR(13), UNISTR('\FEFF')) THEN NULL;
        ELSE l_fld := l_fld || l_c;
        END IF;
        l_i := l_i + 1;
      END LOOP;
    END LOOP;
    IF l_any OR l_fld IS NOT NULL THEN end_row; END IF;
    RETURN l_rows;
  END parse_csv;

  -- اسم العمود الموحد من العنوان
  FUNCTION norm_header(p VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(200) := LOWER(REPLACE(REPLACE(TRIM(p), ' ', ''), '_', ''));
  BEGIN
    RETURN CASE
      WHEN l IN ('name', 'الاسم', 'اسمالعميل', 'اسمالمورد', 'اسمالصنف', 'namear') THEN 'name'
      WHEN l IN ('nameen', 'englishname', 'الاسمبالإنجليزي', 'الاسمالإنجليزي') THEN 'nameEn'
      WHEN l IN ('phone', 'mobile', 'الجوال', 'الهاتف', 'رقمالجوال') THEN 'phone'
      WHEN l IN ('email', 'البريد', 'البريدالإلكتروني') THEN 'email'
      WHEN l IN ('tax', 'vat', 'taxnumber', 'vatnumber', 'الرقمالضريبي') THEN 'tax'
      WHEN l IN ('cr', 'السجلالتجاري', 'رقمالسجل') THEN 'cr'
      WHEN l IN ('address', 'العنوان') THEN 'address'
      WHEN l IN ('term', 'paymentterm', 'شرطالسداد') THEN 'term'
      WHEN l IN ('no', 'code', 'sku', 'itemno', 'الكود', 'رمزالصنف', 'رقمالصنف') THEN 'no'
      WHEN l IN ('type', 'النوع', 'نوعالصنف') THEN 'type'
      WHEN l IN ('price', 'السعر', 'سعرالبيع') THEN 'price'
      WHEN l IN ('barcode', 'الباركود') THEN 'barcode'
      WHEN l IN ('category', 'الفئة', 'التصنيف') THEN 'category'
      WHEN l IN ('date', 'txndate', 'التاريخ', 'تاريخالعملية') THEN 'date'
      WHEN l IN ('valuedate', 'تاريخالقيمة') THEN 'valueDate'
      WHEN l IN ('amount', 'المبلغ') THEN 'amount'
      WHEN l IN ('debit', 'withdrawal', 'مدين', 'سحب', 'مسحوبات') THEN 'debit'
      WHEN l IN ('credit', 'deposit', 'دائن', 'إيداع', 'ايداع', 'إيداعات') THEN 'credit'
      WHEN l IN ('reference', 'ref', 'المرجع', 'رقمالمرجع') THEN 'reference'
      WHEN l IN ('counterparty', 'payee', 'الطرف', 'الطرفالآخر', 'المستفيد') THEN 'counterparty'
      WHEN l IN ('description', 'narrative', 'details', 'البيان', 'الوصف') THEN 'description'
      ELSE l END;
  END norm_header;

  FUNCTION header_map(p_row t_row) RETURN t_map IS
    l t_map;
  BEGIN
    FOR i IN 1 .. p_row.COUNT LOOP
      l(SUBSTR(norm_header(p_row(i)), 1, 30)) := i;
    END LOOP;
    RETURN l;
  END header_map;

  FUNCTION col(p_row t_row, p_map t_map, p_key VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p_map.EXISTS(p_key) AND p_map(p_key) <= p_row.COUNT THEN
      RETURN TRIM(p_row(p_map(p_key)));
    END IF;
    RETURN NULL;
  END col;

  FUNCTION to_num(p VARCHAR2) RETURN NUMBER IS
    l VARCHAR2(100) := TRANSLATE(TRIM(p), '٠١٢٣٤٥٦٧٨٩٫', '0123456789.');
  BEGIN
    IF l IS NULL THEN RETURN NULL; END IF;
    l := REPLACE(REPLACE(l, ',', ''), ' ', '');
    IF l LIKE '(%)' THEN l := '-' || TRIM(BOTH '()' FROM l); END IF;
    RETURN TO_NUMBER(l, '9999999999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END to_num;

  FUNCTION to_dt(p VARCHAR2) RETURN DATE IS
    l VARCHAR2(30) := TRANSLATE(TRIM(p), '٠١٢٣٤٥٦٧٨٩', '0123456789');
  BEGIN
    IF l IS NULL THEN RETURN NULL; END IF;
    IF REGEXP_LIKE(l, '^\d{4}-\d{1,2}-\d{1,2}') THEN RETURN TO_DATE(SUBSTR(l, 1, 10), 'YYYY-MM-DD'); END IF;
    IF REGEXP_LIKE(l, '^\d{1,2}[/.-]\d{1,2}[/.-]\d{4}') THEN RETURN TO_DATE(REGEXP_REPLACE(SUBSTR(l, 1, 10), '[.-]', '/'), 'DD/MM/YYYY'); END IF;
    IF REGEXP_LIKE(l, '^\d{4}/\d{1,2}/\d{1,2}') THEN RETURN TO_DATE(SUBSTR(l, 1, 10), 'YYYY/MM/DD'); END IF;
    RAISE_APPLICATION_ERROR(-20001, 'NOONA-CON-005: تاريخ غير مفهوم: ' || p);
  END to_dt;

  FUNCTION clean_err(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(REGEXP_REPLACE(NVL(REGEXP_SUBSTR(p, 'NOONA-[A-Z]+-[0-9]+: [^' || CHR(10) || ']+'), REGEXP_REPLACE(p, '^ORA-[0-9]+: ', '')),
                                 '\s*\[cid=[^]]+\]', ''), 1, 400);
  END clean_err;

  FUNCTION item_doc(p_no IN VARCHAR2, p_name IN VARCHAR2, p_name_en IN VARCHAR2, p_type IN VARCHAR2, p_price IN NUMBER,
                    p_barcode IN VARCHAR2, p_category IN VARCHAR2, p_incl IN VARCHAR2 DEFAULT 'N') RETURN CLOB IS
    l_d   JSON_OBJECT_T := JSON_OBJECT_T();
    l_b   JSON_ARRAY_T := JSON_ARRAY_T();
    l_cat NUMBER;
  BEGIN
    IF p_category IS NOT NULL THEN
      SELECT MIN(id) INTO l_cat FROM inv_item_category WHERE code = p_category OR name_ar = p_category;
    END IF;
    IF l_cat IS NULL THEN
      SELECT MIN(id) INTO l_cat FROM inv_item_category
       WHERE NOT EXISTS (SELECT 1 FROM inv_item_category c2 WHERE c2.parent_category_id = inv_item_category.id);
    END IF;
    IF p_no IS NOT NULL THEN l_d.put('no', p_no); END IF;
    l_d.put('name', p_name);
    IF p_name_en IS NOT NULL THEN l_d.put('nameEn', p_name_en); END IF;
    l_d.put('type', NVL(UPPER(p_type), 'STOCK'));
    IF p_price IS NOT NULL THEN l_d.put('price', p_price); END IF;
    l_d.put('incl', NVL(p_incl, 'N'));
    IF l_cat IS NOT NULL THEN l_d.put('cat', l_cat); END IF;
    IF p_barcode IS NOT NULL THEN l_b.append(p_barcode); l_d.put('barcodes', l_b); END IF;
    RETURN l_d.to_clob;
  END item_doc;

  -- ================================================================ استيراد البيانات الأساسية
  FUNCTION import_csv(p_type IN VARCHAR2, p_file_name IN VARCHAR2, p_csv IN CLOB) RETURN NUMBER IS
    l_rows  t_rows;
    l_map   t_map;
    l_r     t_row;
    l_job   NUMBER;
    l_ok    PLS_INTEGER := 0;
    l_bad   PLS_INTEGER := 0;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_e     JSON_OBJECT_T;
    l_id    NUMBER;
    l_n     NUMBER;
    l_doc   CLOB;
    l_name  VARCHAR2(400);
    l_tax   VARCHAR2(100);
    l_no    VARCHAR2(100);
    l_ec    CLOB;
    l_jo    JSON_OBJECT_T;
    l_total PLS_INTEGER;
  BEGIN
    NOONA_CORE_PKG.assert(p_type IN ('CUSTOMERS', 'SUPPLIERS', 'ITEMS'), 'NOONA-CON-001', 'نوع استيراد غير مدعوم', 'Unsupported import type');
    guard('API_IMPORT_JOB.CREATE');
    guard(CASE p_type WHEN 'CUSTOMERS' THEN 'AR_CUSTOMER.CREATE' WHEN 'SUPPLIERS' THEN 'AP_SUPPLIER.CREATE' ELSE 'INV_ITEM.CREATE' END);
    l_rows := parse_csv(p_csv);
    NOONA_CORE_PKG.assert(l_rows.COUNT >= 2, 'NOONA-CON-002', 'الملف فارغ أو بلا صفوف بيانات بعد سطر العناوين', 'File has no data rows');
    NOONA_CORE_PKG.assert(l_rows.COUNT <= 5001, 'NOONA-CON-003', 'الحد الأقصى 5000 صف في الملف الواحد', 'Maximum 5000 rows per file');
    l_total := l_rows.COUNT - 1;
    l_map := header_map(l_rows(1));
    NOONA_CORE_PKG.assert(l_map.EXISTS('name'), 'NOONA-CON-004', 'عمود الاسم (name) مطلوب في سطر العناوين', 'Header must include name');
    INSERT INTO api_import_job (company_id, import_type, file_name, total_rows, ok_rows, failed_rows, status_code)
    VALUES (company, p_type, SUBSTR(p_file_name, 1, 300), l_total, 0, 0, 'RUNNING')
    RETURNING id INTO l_job;
    FOR i IN 2 .. l_rows.COUNT LOOP
      l_r := l_rows(i);
      SAVEPOINT import_row;
      BEGIN
        l_name := col(l_r, l_map, 'name');
        l_tax := col(l_r, l_map, 'tax');
        l_no := col(l_r, l_map, 'no');
        NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-CON-010', 'الاسم فارغ', 'Name is empty');
        IF p_type IN ('CUSTOMERS', 'SUPPLIERS') THEN
          -- لا تكرار: نفس الرقم الضريبي أو نفس الاسم في الشركة
          IF p_type = 'CUSTOMERS' THEN
            SELECT COUNT(*) INTO l_n FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
             WHERE a.company_id = company AND (p.display_name_ar = l_name OR (l_tax IS NOT NULL AND p.tax_number = l_tax));
          ELSE
            SELECT COUNT(*) INTO l_n FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
             WHERE a.company_id = company AND (p.display_name_ar = l_name OR (l_tax IS NOT NULL AND p.tax_number = l_tax));
          END IF;
          NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-011', 'موجود مسبقاً (نفس الاسم أو الرقم الضريبي)', 'Already exists');
          l_jo := JSON_OBJECT_T();
          l_jo.put('name', l_name);
          FOR k IN (SELECT column_value c FROM TABLE(apex_t_varchar2('nameEn', 'phone', 'email', 'cr', 'address'))) LOOP
            IF col(l_r, l_map, k.c) IS NOT NULL THEN l_jo.put(k.c, col(l_r, l_map, k.c)); END IF;
          END LOOP;
          IF l_tax IS NOT NULL THEN l_jo.put('tax', l_tax); END IF;
          l_jo.put('term', NVL(UPPER(col(l_r, l_map, 'term')), 'NET30'));
          l_doc := l_jo.to_clob;
          l_id := CASE p_type WHEN 'CUSTOMERS' THEN NOONA_SAL_PKG.save_customer(l_doc) ELSE NOONA_PUR_PKG.save_supplier(l_doc) END;
        ELSE
          IF l_no IS NOT NULL THEN
            SELECT COUNT(*) INTO l_n FROM inv_item WHERE item_no = l_no;
            NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-012', 'رقم الصنف موجود مسبقاً: ' || l_no, 'Item number already exists');
          END IF;
          l_doc := item_doc(l_no, l_name, col(l_r, l_map, 'nameEn'), col(l_r, l_map, 'type'), to_num(col(l_r, l_map, 'price')),
                            col(l_r, l_map, 'barcode'), col(l_r, l_map, 'category'));
          l_id := NOONA_INV_PKG.save_item(l_doc);
        END IF;
        l_ok := l_ok + 1;
      EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO import_row;
        l_bad := l_bad + 1;
        IF l_errs.get_size < 500 THEN
          l_e := JSON_OBJECT_T();
          l_e.put('row', i); l_e.put('name', l_name); l_e.put('error', clean_err(SQLERRM));
          l_errs.append(l_e);
        END IF;
      END;
    END LOOP;
    l_ec := l_errs.to_clob;
    UPDATE api_import_job SET ok_rows = l_ok, failed_rows = l_bad, errors = l_ec,
                              status_code = CASE WHEN l_bad = 0 THEN 'COMPLETED' WHEN l_ok = 0 THEN 'FAILED' ELSE 'PARTIAL' END
     WHERE id = l_job;
    NOONA_AUDIT_PKG.log_event('API', 'API_IMPORT_JOB', l_job, 'IMPORT_' || p_type, 'SUCCESS',
                              p_new_values => JSON_OBJECT('ok' VALUE l_ok, 'failed' VALUE l_bad));
    RETURN l_job;
  END import_csv;

  -- ================================================================ كشف الحساب البنكي
  FUNCTION import_bank_statement(p_bank_account_id IN NUMBER, p_file_name IN VARCHAR2, p_csv IN CLOB,
                                 p_opening IN NUMBER DEFAULT NULL, p_closing IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_rows  t_rows;
    l_map   t_map;
    l_r     t_row;
    l_st    NUMBER;
    l_job   NUMBER;
    l_n     NUMBER;
    l_dt    DATE;
    l_amt   NUMBER;
    l_hash  VARCHAR2(128);
    l_fhash VARCHAR2(128) := LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p_csv, DBMS_CRYPTO.HASH_SH256)));
    l_ok    PLS_INTEGER := 0;
    l_dup   PLS_INTEGER := 0;
    l_bad   PLS_INTEGER := 0;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_e     JSON_OBJECT_T;
    l_min   DATE;
    l_max   DATE;
    l_ec    CLOB;
    l_ref   VARCHAR2(200);
    l_vd    DATE;
    l_cp    VARCHAR2(500);
    l_ds    VARCHAR2(2000);
    l_desc  VARCHAR2(2000);
    l_total PLS_INTEGER;
    l_open  NUMBER;
    l_net   NUMBER;
  BEGIN
    guard('CSH_BANK_STATEMENT.CREATE');
    SELECT COUNT(*) INTO l_n FROM csh_bank_account WHERE id = p_bank_account_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-CON-020', 'الحساب البنكي غير موجود', 'Bank account not found');
    SELECT COUNT(*) INTO l_n FROM csh_bank_statement WHERE bank_account_id = p_bank_account_id AND file_hash = l_fhash AND status_code <> 'REJECTED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-021', 'هذا الملف مستورد من قبل لنفس الحساب', 'This file was already imported');
    l_rows := parse_csv(p_csv);
    NOONA_CORE_PKG.assert(l_rows.COUNT >= 2, 'NOONA-CON-002', 'الملف فارغ أو بلا صفوف بيانات بعد سطر العناوين', 'File has no data rows');
    l_total := l_rows.COUNT - 1;
    l_map := header_map(l_rows(1));
    NOONA_CORE_PKG.assert(l_map.EXISTS('date') AND (l_map.EXISTS('amount') OR l_map.EXISTS('debit') OR l_map.EXISTS('credit')), 'NOONA-CON-022',
                          'الملف يحتاج عمود التاريخ وعمود المبلغ (أو مدين ودائن)', 'Date and amount (or debit/credit) columns are required');
    INSERT INTO csh_bank_statement (company_id, bank_account_id, statement_no, from_date, to_date, opening_balance, closing_balance, source_code,
                                    file_hash, status_code)
    VALUES (company, p_bank_account_id, SUBSTR(NVL(p_file_name, 'CSV'), 1, 50), TRUNC(SYSDATE), TRUNC(SYSDATE), NVL(p_opening, 0), NVL(p_closing, 0), 'FILE',
            l_fhash, 'IMPORTED')
    RETURNING id INTO l_st;
    INSERT INTO api_import_job (company_id, import_type, file_name, total_rows, ok_rows, failed_rows, result_ref, status_code)
    VALUES (company, 'BANK_STATEMENT', SUBSTR(p_file_name, 1, 300), l_total, 0, 0, l_st, 'RUNNING')
    RETURNING id INTO l_job;
    FOR i IN 2 .. l_rows.COUNT LOOP
      l_r := l_rows(i);
      BEGIN
        l_dt := to_dt(col(l_r, l_map, 'date'));
        l_amt := CASE WHEN l_map.EXISTS('amount') THEN to_num(col(l_r, l_map, 'amount'))
                      ELSE NVL(to_num(col(l_r, l_map, 'credit')), 0) - NVL(ABS(to_num(col(l_r, l_map, 'debit'))), 0) END;
        NOONA_CORE_PKG.assert(l_dt IS NOT NULL AND NVL(l_amt, 0) <> 0, 'NOONA-CON-023', 'التاريخ أو المبلغ فارغ', 'Date or amount is empty');
        l_ref := col(l_r, l_map, 'reference');
        l_desc := col(l_r, l_map, 'description');
        l_hash := LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_bank_account_id || '|' || TO_CHAR(l_dt, 'YYYYMMDD') || '|' || TO_CHAR(l_amt)
                          || '|' || l_ref || '|' || l_desc, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256)));
        SELECT COUNT(*) INTO l_n FROM csh_bank_statement_line WHERE line_hash = l_hash;
        IF l_n > 0 THEN
          l_dup := l_dup + 1;
        ELSE
          l_vd := NVL(to_dt(col(l_r, l_map, 'valueDate')), l_dt);
          l_cp := SUBSTR(col(l_r, l_map, 'counterparty'), 1, 500);
          l_ds := SUBSTR(col(l_r, l_map, 'description'), 1, 2000);
          INSERT INTO csh_bank_statement_line (company_id, statement_id, line_no, txn_date, value_date, amount, bank_reference, counterparty, narrative,
                                               line_hash, status_code)
          VALUES (company, l_st, i - 1, l_dt, l_vd, l_amt, SUBSTR(l_ref, 1, 200), l_cp, l_ds, l_hash, 'UNMATCHED');
          l_ok := l_ok + 1;
          l_min := LEAST(NVL(l_min, l_dt), l_dt); l_max := GREATEST(NVL(l_max, l_dt), l_dt);
        END IF;
      EXCEPTION WHEN OTHERS THEN
        l_bad := l_bad + 1;
        IF l_errs.get_size < 500 THEN
          l_e := JSON_OBJECT_T(); l_e.put('row', i); l_e.put('error', clean_err(SQLERRM)); l_errs.append(l_e);
        END IF;
      END;
    END LOOP;
    IF l_dup > 0 THEN
      l_e := JSON_OBJECT_T(); l_e.put('row', 0); l_e.put('error', l_dup || ' سطر مستورد سابقاً تم تجاهله'); l_errs.append(l_e);
    END IF;
    -- الرصيد الافتتاحي إن لم يدخل: رصيد الدفاتر قبل أول حركة؛ الختامي = الافتتاحي + صافي الأسطر
    l_open := NVL(p_opening, NOONA_CSH_PKG.balance(NULL, p_bank_account_id, NVL(l_min, TRUNC(SYSDATE)) - 1));
    SELECT NVL(SUM(amount), 0) INTO l_net FROM csh_bank_statement_line WHERE statement_id = l_st;
    UPDATE csh_bank_statement SET opening_balance = l_open, closing_balance = NVL(p_closing, l_open + l_net) WHERE id = l_st;
    UPDATE csh_bank_statement SET from_date = NVL(l_min, from_date), to_date = NVL(l_max, to_date),
                                  status_code = CASE WHEN l_ok = 0 THEN 'REJECTED' ELSE 'IMPORTED' END
     WHERE id = l_st;
    l_ec := l_errs.to_clob;
    UPDATE api_import_job SET ok_rows = l_ok, failed_rows = l_bad, errors = l_ec,
                              status_code = CASE WHEN l_bad = 0 AND l_ok > 0 THEN 'COMPLETED' WHEN l_ok = 0 THEN 'FAILED' ELSE 'PARTIAL' END
     WHERE id = l_job;
    IF l_ok > 0 THEN
      l_n := auto_match(l_st);
    END IF;
    RETURN l_st;
  END import_bank_statement;

  FUNCTION recon_for(p_bank NUMBER) RETURN NUMBER IS
    l      NUMBER;
    l_book NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM csh_reconciliation WHERE bank_account_id = p_bank AND status_code IN ('DRAFT', 'IN_PROGRESS', 'REOPENED');
    IF l IS NULL THEN
      l_book := NOONA_CSH_PKG.balance(NULL, p_bank, TRUNC(SYSDATE));
      INSERT INTO csh_reconciliation (company_id, bank_account_id, cutoff_date, bank_balance, book_balance, prepared_by, status_code)
      VALUES (company, p_bank, TRUNC(SYSDATE), l_book, l_book, SYS_CONTEXT('NOONA_CTX', 'USERNAME'), 'IN_PROGRESS')
      RETURNING id INTO l;
    END IF;
    RETURN l;
  END recon_for;

  -- الحركات المحتملة: نفس الحساب والاتجاه والمبلغ، ±3 أيام، غير مسواة وغير مقترحة لسطر آخر؛ الثقة ترتفع بتطابق التاريخ والمرجع
  FUNCTION auto_match(p_statement_id IN NUMBER) RETURN NUMBER IS
    l_bank NUMBER;
    l_rec  NUMBER;
    l_n    NUMBER := 0;
  BEGIN
    guard('CSH_RECON_MATCH.CREATE');
    SELECT bank_account_id INTO l_bank FROM csh_bank_statement WHERE id = p_statement_id AND company_id = company;
    l_rec := recon_for(l_bank);
    FOR l IN (SELECT * FROM csh_bank_statement_line WHERE statement_id = p_statement_id AND status_code = 'UNMATCHED' ORDER BY line_no) LOOP
      FOR t IN (SELECT t.id,
                       60 + CASE WHEN t.doc_date = l.txn_date OR t.value_date = l.txn_date THEN 25 ELSE 10 - 3 * ABS(t.doc_date - l.txn_date) END
                          + CASE WHEN l.bank_reference IS NOT NULL AND (INSTR(l.bank_reference, t.doc_no) > 0 OR t.external_reference = l.bank_reference
                                                                        OR INSTR(NVL(l.narrative, '-'), t.doc_no) > 0) THEN 15 ELSE 0 END conf
                  FROM csh_transaction t
                 WHERE t.bank_account_id = l_bank AND t.company_id = company AND t.status_code IN ('APPROVED', 'SETTLED', 'SUBMITTED_TO_BANK')
                   AND NVL(t.is_reconciled, 'N') = 'N' AND t.amount = ABS(l.amount)
                   AND ((l.amount > 0 AND t.txn_type IN ('RECEIPT', 'TRANSFER_IN', 'INTEREST', 'ADJUSTMENT'))
                        OR (l.amount < 0 AND t.txn_type IN ('PAYMENT', 'EXPENSE', 'TRANSFER_OUT', 'BANK_CHARGE', 'ADJUSTMENT')))
                   AND t.doc_date BETWEEN l.txn_date - 3 AND l.txn_date + 3
                   AND NOT EXISTS (SELECT 1 FROM csh_recon_match m WHERE m.transaction_id = t.id AND m.status_code IN ('SUGGESTED', 'CONFIRMED'))
                 ORDER BY conf DESC, ABS(t.doc_date - l.txn_date), t.id FETCH FIRST 1 ROWS ONLY) LOOP
        INSERT INTO csh_recon_match (company_id, reconciliation_id, statement_line_id, transaction_id, match_method, confidence_pct, matched_amount, status_code)
        VALUES (company, l_rec, l.id, t.id, 'AUTO', LEAST(t.conf, 100), ABS(l.amount), 'SUGGESTED');
        UPDATE csh_bank_statement_line SET status_code = 'SUGGESTED' WHERE id = l.id;
        l_n := l_n + 1;
      END LOOP;
    END LOOP;
    UPDATE csh_bank_statement SET status_code = 'RECONCILING' WHERE id = p_statement_id AND status_code IN ('IMPORTED', 'VALIDATED') AND l_n > 0;
    RETURN l_n;
  END auto_match;

  PROCEDURE refresh_statement(p_statement_id NUMBER) IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM csh_bank_statement_line WHERE statement_id = p_statement_id AND status_code IN ('UNMATCHED', 'SUGGESTED');
    UPDATE csh_bank_statement SET status_code = CASE WHEN l_n = 0 THEN 'RECONCILED' ELSE 'RECONCILING' END WHERE id = p_statement_id;
  END refresh_statement;

  PROCEDURE confirm_match(p_match_id IN NUMBER) IS
    m csh_recon_match%ROWTYPE;
    l_st NUMBER;
  BEGIN
    guard('CSH_RECON_MATCH.UPDATE');
    SELECT * INTO m FROM csh_recon_match WHERE id = p_match_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(m.status_code = 'SUGGESTED', 'NOONA-CON-030', 'المطابقة ليست مقترحة', 'Match is not a suggestion');
    UPDATE csh_recon_match SET status_code = 'CONFIRMED' WHERE id = m.id;
    UPDATE csh_bank_statement_line SET status_code = 'MATCHED' WHERE id = m.statement_line_id RETURNING statement_id INTO l_st;
    UPDATE csh_transaction SET is_reconciled = 'Y' WHERE id = m.transaction_id;
    refresh_statement(l_st);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CON-031', 'المطابقة غير موجودة', 'Match not found');
  END confirm_match;

  PROCEDURE reject_match(p_match_id IN NUMBER) IS
    m csh_recon_match%ROWTYPE;
  BEGIN
    guard('CSH_RECON_MATCH.UPDATE');
    SELECT * INTO m FROM csh_recon_match WHERE id = p_match_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(m.status_code IN ('SUGGESTED', 'CONFIRMED'), 'NOONA-CON-030', 'لا يمكن رفض هذه المطابقة', 'Match cannot be rejected');
    UPDATE csh_recon_match SET status_code = CASE WHEN m.status_code = 'CONFIRMED' THEN 'UNDONE' ELSE 'REJECTED' END WHERE id = m.id;
    UPDATE csh_bank_statement_line SET status_code = 'UNMATCHED' WHERE id = m.statement_line_id;
    IF m.status_code = 'CONFIRMED' THEN
      UPDATE csh_transaction SET is_reconciled = 'N' WHERE id = m.transaction_id;
    END IF;
    FOR s IN (SELECT statement_id FROM csh_bank_statement_line WHERE id = m.statement_line_id) LOOP
      refresh_statement(s.statement_id);
    END LOOP;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CON-031', 'المطابقة غير موجودة', 'Match not found');
  END reject_match;

  FUNCTION confirm_all(p_statement_id IN NUMBER) RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    FOR m IN (SELECT m.id FROM csh_recon_match m JOIN csh_bank_statement_line l ON l.id = m.statement_line_id
               WHERE l.statement_id = p_statement_id AND m.status_code = 'SUGGESTED' AND l.company_id = company) LOOP
      confirm_match(m.id);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END confirm_all;

  PROCEDURE ignore_line(p_line_id IN NUMBER) IS
    l_st NUMBER;
  BEGIN
    guard('CSH_BANK_STATEMENT_LINE.UPDATE');
    UPDATE csh_recon_match SET status_code = 'REJECTED' WHERE statement_line_id = p_line_id AND status_code = 'SUGGESTED';
    UPDATE csh_bank_statement_line SET status_code = 'IGNORED' WHERE id = p_line_id AND company_id = company AND status_code IN ('UNMATCHED', 'SUGGESTED')
    RETURNING statement_id INTO l_st;
    NOONA_CORE_PKG.assert(l_st IS NOT NULL, 'NOONA-CON-032', 'لا يمكن تجاهل هذا السطر', 'Line cannot be ignored');
    refresh_statement(l_st);
  END ignore_line;

  -- ================================================================ طلبات المتجر
  FUNCTION ingest_order(p_body IN CLOB, p_source IN VARCHAR2 DEFAULT 'STORE') RETURN CLOB IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_body);
    l_c     JSON_OBJECT_T;
    l_lines JSON_ARRAY_T;
    l_x     JSON_OBJECT_T;
    l_out   JSON_ARRAY_T := JSON_ARRAY_T();
    l_y     JSON_OBJECT_T;
    l_d     JSON_OBJECT_T := JSON_OBJECT_T();
    l_order VARCHAR2(200) := l_o.get_string('orderId');
    l_src   VARCHAR2(100) := 'ORDER:' || SUBSTR(p_source, 1, 90);
    l_inbox NUMBER;
    l_prev  VARCHAR2(4000);
    l_cust  NUMBER;
    l_phone VARCHAR2(50);
    l_name  VARCHAR2(400);
    l_inv   NUMBER;
    l_item  NUMBER;
    l_sku   VARCHAR2(100);
    l_rcp   NUMBER;
    l_oi    NUMBER;
    l_tot   NUMBER;
    l_res   CLOB;
    l_place VARCHAR2(30) := l_o.get_string('place');
    l_fail  VARCHAR2(4000);
    l_email VARCHAR2(400);
    l_taxno VARCHAR2(400);
  BEGIN
    guard('SAL_INVOICE.CREATE');
    NOONA_CORE_PKG.assert(TRIM(l_order) IS NOT NULL, 'NOONA-CON-040', 'رقم الطلب orderId مطلوب', 'orderId is required');
    -- نفس الطلب مرة واحدة فقط
    BEGIN
      SELECT id, JSON_QUERY(payload, '$.result' RETURNING VARCHAR2(4000)) INTO l_inbox, l_prev
        FROM api_inbox WHERE source_system = l_src AND message_id = l_order AND status_code = 'PROCESSED';
      RETURN '{"duplicate":true,"result":' || NVL(l_prev, 'null') || '}';
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    DELETE FROM api_inbox WHERE source_system = l_src AND message_id = l_order AND status_code <> 'PROCESSED';
    -- العميل: بالجوال ثم بالاسم، وإلا ينشأ
    IF l_o.has('customer') THEN
      l_c := l_o.get_object('customer');
      l_phone := l_c.get_string('phone');
      l_name := l_c.get_string('name');
    END IF;
    IF l_phone IS NOT NULL THEN
      SELECT MIN(a.id) INTO l_cust FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
        JOIN ref_contact x ON x.party_id = c.party_id WHERE a.company_id = company AND x.mobile = l_phone;
    END IF;
    IF l_cust IS NULL AND l_name IS NOT NULL THEN
      l_email := l_c.get_string('email');
      l_taxno := l_c.get_string('taxNumber');
      SELECT JSON_OBJECT('name' VALUE l_name, 'phone' VALUE l_phone, 'email' VALUE l_email, 'tax' VALUE l_taxno,
                         'term' VALUE 'NET0' ABSENT ON NULL RETURNING CLOB) INTO l_res FROM dual;
      l_cust := NOONA_SAL_PKG.save_customer(l_res);
    END IF;
    NOONA_CORE_PKG.assert(l_cust IS NOT NULL, 'NOONA-CON-041', 'بيانات العميل (الاسم أو الجوال) مطلوبة', 'Customer name or phone is required');
    l_lines := l_o.get_array('lines');
    NOONA_CORE_PKG.assert(l_lines IS NOT NULL AND l_lines.get_size > 0, 'NOONA-CON-042', 'الطلب بلا أصناف', 'Order has no lines');
    FOR k IN 0 .. l_lines.get_size - 1 LOOP
      l_x := TREAT(l_lines.get(k) AS JSON_OBJECT_T);
      l_item := CASE WHEN l_x.has('item') THEN l_x.get_number('item') END;
      l_sku := l_x.get_string('sku');
      IF l_item IS NULL AND l_sku IS NOT NULL THEN
        l_item := NOONA_INV_PKG.item_by_barcode(l_sku);
        NOONA_CORE_PKG.assert(l_item IS NOT NULL, 'NOONA-CON-043', 'صنف غير معروف: ' || l_sku, 'Unknown SKU: ' || l_sku);
      END IF;
      l_y := JSON_OBJECT_T();
      IF l_item IS NOT NULL THEN l_y.put('i', l_item); ELSE l_y.put('d', NVL(l_x.get_string('description'), 'صنف متجر')); END IF;
      l_y.put('q', NVL(l_x.get_number('qty'), 1));
      IF l_x.has('price') THEN l_y.put('p', l_x.get_number('price')); END IF;
      l_y.put('inc', NVL(l_o.get_string('pricesIncludeTax'), 'Y'));
      l_out.append(l_y);
    END LOOP;
    IF NVL(l_o.get_number('shipping'), 0) > 0 THEN
      l_y := JSON_OBJECT_T(); l_y.put('d', 'رسوم الشحن'); l_y.put('q', 1); l_y.put('p', l_o.get_number('shipping'));
      l_y.put('inc', NVL(l_o.get_string('pricesIncludeTax'), 'Y'));
      l_out.append(l_y);
    END IF;
    l_d.put('cust', l_cust);
    IF l_o.get_string('date') IS NOT NULL THEN l_d.put('date', l_o.get_string('date')); END IF;
    l_d.put('mode', 'CREDIT');
    l_d.put('notes', 'طلب متجر ' || l_order);
    l_d.put('action', 'POST');
    l_d.put('lines', l_out);
    l_inv := NOONA_SAL_PKG.save_invoice(l_d.to_clob);
    SELECT total_amount INTO l_tot FROM sal_invoice WHERE id = l_inv;
    -- مدفوع في المتجر: تحصيل على الفاتورة
    IF NVL(l_o.get_string('paid'), 'false') IN ('true', 'Y') THEN
      NOONA_CORE_PKG.assert(l_place IS NOT NULL, 'NOONA-CON-044', 'حدد مكان التحصيل place (BANK:رقم) للطلبات المدفوعة', 'place is required for paid orders');
      SELECT MIN(id) INTO l_oi FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv AND open_amount > 0;
      IF l_oi IS NOT NULL THEN
        l_email := NVL(l_o.get_string('method'), 'CARD');
        l_taxno := NVL(l_o.get_string('reference'), l_order);
        SELECT JSON_OBJECT('cust' VALUE l_cust, 'amount' VALUE l_tot, 'place' VALUE l_place, 'method' VALUE l_email,
                           'ref' VALUE l_taxno,
                           'alloc' VALUE JSON_ARRAY(JSON_OBJECT('inv' VALUE l_oi, 'a' VALUE l_tot)) RETURNING CLOB)
          INTO l_res FROM dual;
        l_rcp := NOONA_SAL_PKG.receive(l_res);
      END IF;
    END IF;
    SELECT JSON_OBJECT('orderId' VALUE l_order, 'invoice' VALUE i.id, 'number' VALUE i.doc_no, 'customer' VALUE l_cust, 'total' VALUE i.total_amount,
                       'receipt' VALUE l_rcp)
      INTO l_res FROM sal_invoice i WHERE i.id = l_inv;
    INSERT INTO api_inbox (source_system, message_id, message_type, signature_valid, payload, processed_at, status_code)
    VALUES (l_src, l_order, 'ORDER', 'Y', JSON_OBJECT('order' VALUE p_body FORMAT JSON, 'result' VALUE l_res FORMAT JSON RETURNING CLOB),
            SYSTIMESTAMP, 'PROCESSED');
    NOONA_API_PKG.publish('ORDER.CREATED', 'SAL_INVOICE', l_inv);
    RETURN l_res;
  END ingest_order;

  -- ================================================================ الشاشات
  FUNCTION jobs_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_IMPORT_JOB.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>#</th><th>الوقت</th><th>النوع</th><th>الملف</th><th class="n">الصفوف</th><th class="n">نجح</th>'
        || '<th class="n">فشل</th><th>بواسطة</th><th>الحالة</th></tr></thead><tbody>';
    FOR j IN (SELECT * FROM api_import_job WHERE company_id = company ORDER BY id DESC FETCH FIRST 100 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-job="' || j.id || '"><td>' || j.id || '</td><td>' || TO_CHAR(j.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td>'
          || esc(type_label(j.import_type)) || '</td><td>' || esc(j.file_name) || '</td><td class="n">' || j.total_rows || '</td><td class="n">' || j.ok_rows
          || '</td><td class="n">' || j.failed_rows || '</td><td>' || esc(j.created_by) || '</td><td><span class="nn-badge '
          || CASE j.status_code WHEN 'COMPLETED' THEN 'is-success' WHEN 'PARTIAL' THEN 'is-warning' WHEN 'FAILED' THEN 'is-danger' ELSE 'is-muted' END || '">'
          || CASE j.status_code WHEN 'COMPLETED' THEN 'مكتمل' WHEN 'PARTIAL' THEN 'جزئي' WHEN 'FAILED' THEN 'فشل' ELSE 'جار' END || '</span></td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد عمليات استيراد بعد</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END jobs_html;

  FUNCTION job_html(p_job_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    j   api_import_job%ROWTYPE;
  BEGIN
    guard('API_IMPORT_JOB.VIEW');
    SELECT * INTO j FROM api_import_job WHERE id = p_job_id AND company_id = company;
    l_h := '<div class="nn-prj-chips"><span>' || esc(type_label(j.import_type)) || '</span><span>' || esc(j.file_name) || '</span><span>نجح ' || j.ok_rows
        || ' من ' || j.total_rows || '</span>' || CASE WHEN j.failed_rows > 0 THEN '<span class="is-danger">فشل ' || j.failed_rows || '</span>' END || '</div>';
    IF j.failed_rows > 0 OR JSON_EXISTS(j.errors, '$[0]') THEN
      l_h := l_h || ('<table class="nn-prj-t"><thead><tr><th>الصف</th><th>الاسم</th><th>الخطأ</th></tr></thead><tbody>');
      FOR e IN (SELECT * FROM JSON_TABLE(j.errors, '$[*]' COLUMNS (rn NUMBER PATH '$.row', nm VARCHAR2(400) PATH '$.name', er VARCHAR2(1000) PATH '$.error'))) LOOP
        l_h := l_h || ('<tr><td>' || CASE WHEN e.rn > 0 THEN TO_CHAR(e.rn) END || '</td><td>' || esc(e.nm) || '</td><td>' || esc(e.er) || '</td></tr>');
      END LOOP;
      l_h := l_h || ('</tbody></table>');
    END IF;
    RETURN l_h;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">اختر عملية استيراد</div>';
  END job_html;

  FUNCTION st_badge(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p IN ('MATCHED', 'RECONCILED', 'CONFIRMED') THEN 'is-success' WHEN p IN ('SUGGESTED', 'RECONCILING') THEN 'is-warning'
                                            WHEN p IN ('UNMATCHED', 'REJECTED') THEN 'is-danger' ELSE 'is-muted' END || '">'
        || CASE p WHEN 'UNMATCHED' THEN 'غير مطابق' WHEN 'SUGGESTED' THEN 'مقترح' WHEN 'MATCHED' THEN 'مطابق' WHEN 'EXPLAINED' THEN 'مفسر'
                  WHEN 'IGNORED' THEN 'متجاهل' WHEN 'IMPORTED' THEN 'مستورد' WHEN 'RECONCILING' THEN 'قيد التسوية' WHEN 'RECONCILED' THEN 'مسوى'
                  WHEN 'REJECTED' THEN 'مرفوض' ELSE p END || '</span>';
  END st_badge;

  FUNCTION statements_html(p_bank_account_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('CSH_BANK_STATEMENT.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الكشف</th><th>الحساب</th><th>الفترة</th><th class="n">الأسطر</th><th class="n">مطابق</th>'
        || '<th class="n">مقترح</th><th class="n">غير مطابق</th><th class="n">صافي الحركة</th><th>الحالة</th></tr></thead><tbody>';
    FOR s IN (SELECT s.*, b.name_ar bname,
                     (SELECT COUNT(*) FROM csh_bank_statement_line l WHERE l.statement_id = s.id) cnt,
                     (SELECT COUNT(*) FROM csh_bank_statement_line l WHERE l.statement_id = s.id AND l.status_code IN ('MATCHED', 'EXPLAINED', 'IGNORED')) ok,
                     (SELECT COUNT(*) FROM csh_bank_statement_line l WHERE l.statement_id = s.id AND l.status_code = 'SUGGESTED') sug,
                     (SELECT COUNT(*) FROM csh_bank_statement_line l WHERE l.statement_id = s.id AND l.status_code = 'UNMATCHED') un,
                     (SELECT SUM(amount) FROM csh_bank_statement_line l WHERE l.statement_id = s.id) net
                FROM csh_bank_statement s JOIN csh_bank_account b ON b.id = s.bank_account_id
               WHERE s.company_id = company AND (p_bank_account_id IS NULL OR s.bank_account_id = p_bank_account_id)
               ORDER BY s.id DESC FETCH FIRST 100 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-st="' || s.id || '"><td><a href="#" class="nn-st-open" data-id="' || s.id || '">' || esc(s.statement_no) || '</a></td><td>'
          || esc(s.bname) || '</td><td>' || TO_CHAR(s.from_date, 'YYYY-MM-DD') || ' ← ' || TO_CHAR(s.to_date, 'YYYY-MM-DD') || '</td><td class="n">' || s.cnt
          || '</td><td class="n">' || s.ok || '</td><td class="n">' || s.sug || '</td><td class="n">' || s.un || '</td><td class="n">' || fmt(s.net) || '</td><td>'
          || st_badge(s.status_code) || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد كشوف مستوردة</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END statements_html;

  FUNCTION statement_html(p_statement_id IN NUMBER) RETURN CLOB IS
    l_h CLOB;
    s   csh_bank_statement%ROWTYPE;
    l_b VARCHAR2(200);
  BEGIN
    guard('CSH_BANK_STATEMENT.VIEW');
    SELECT * INTO s FROM csh_bank_statement WHERE id = p_statement_id AND company_id = company;
    SELECT name_ar INTO l_b FROM csh_bank_account WHERE id = s.bank_account_id;
    l_h := '<div class="nn-prj-chips"><span>' || esc(l_b) || '</span><span>' || esc(s.statement_no) || '</span><span>' || TO_CHAR(s.from_date, 'YYYY-MM-DD')
        || ' ← ' || TO_CHAR(s.to_date, 'YYYY-MM-DD') || '</span>' || st_badge(s.status_code) || '</div>'
        || '<table class="nn-prj-t nn-recon"><thead><tr><th>#</th><th>التاريخ</th><th>المرجع</th><th>الطرف / البيان</th><th class="n">إيداع</th>'
        || '<th class="n">سحب</th><th>الحركة المقابلة في الدفاتر</th><th>الثقة</th><th>الحالة</th><th></th></tr></thead><tbody>';
    FOR l IN (SELECT l.*, m.id mid, m.confidence_pct conf, m.status_code mst, t.doc_no tno, t.doc_date tdate, t.description tdesc, t.counterparty_name tcp
                FROM csh_bank_statement_line l
                LEFT JOIN csh_recon_match m ON m.statement_line_id = l.id AND m.status_code IN ('SUGGESTED', 'CONFIRMED')
                LEFT JOIN csh_transaction t ON t.id = m.transaction_id
               WHERE l.statement_id = p_statement_id ORDER BY l.line_no) LOOP
      l_h := l_h || ('<tr data-line="' || l.id || '"' || CASE WHEN l.mid IS NOT NULL THEN ' data-match="' || l.mid || '"' END || '><td>' || l.line_no || '</td><td>'
          || TO_CHAR(l.txn_date, 'YYYY-MM-DD') || '</td><td dir="ltr">' || esc(l.bank_reference) || '</td><td>' || esc(l.counterparty)
          || CASE WHEN l.narrative IS NOT NULL THEN '<br><small>' || esc(l.narrative) || '</small>' END || '</td><td class="n">'
          || CASE WHEN l.amount > 0 THEN fmt(l.amount) END || '</td><td class="n">' || CASE WHEN l.amount < 0 THEN fmt(-l.amount) END || '</td><td>'
          || CASE WHEN l.tno IS NOT NULL THEN '<b>' || esc(l.tno) || '</b> ' || TO_CHAR(l.tdate, 'YYYY-MM-DD') || '<br><small>' || esc(NVL(l.tcp, l.tdesc)) || '</small>' END
          || '</td><td>' || CASE WHEN l.conf IS NOT NULL THEN ROUND(l.conf) || '%' END || '</td><td>' || st_badge(l.status_code) || '</td><td class="nn-recon-act">'
          || CASE WHEN l.mst = 'SUGGESTED' THEN '<button type="button" class="t-Button t-Button--small t-Button--success nn-recon-ok" data-id="' || l.mid
                    || '">اعتماد</button> <button type="button" class="t-Button t-Button--small nn-recon-no" data-id="' || l.mid || '">رفض</button>'
                  WHEN l.mst = 'CONFIRMED' THEN '<button type="button" class="t-Button t-Button--small nn-recon-no" data-id="' || l.mid || '">تراجع</button>'
                  WHEN l.status_code = 'UNMATCHED' THEN '<button type="button" class="t-Button t-Button--small nn-recon-ign" data-id="' || l.id || '">تجاهل</button>' END
          || '</td></tr>');
    END LOOP;
    RETURN l_h || ('</tbody></table>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">اختر كشفاً</div>';
  END statement_html;
END NOONA_CONN_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_CONN_PKG
