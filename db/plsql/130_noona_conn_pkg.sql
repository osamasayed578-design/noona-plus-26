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
  -- p_type: CUSTOMERS | SUPPLIERS | ITEMS | ACCOUNTS | EMPLOYEES | OPENING_GL | OPENING_AR | OPENING_AP | OPENING_STOCK
  --   (الأرصدة الافتتاحية تتطلب p_date: تاريخ بدء العمل على النظام)
  FUNCTION import_csv(p_type IN VARCHAR2, p_file_name IN VARCHAR2, p_csv IN CLOB, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  -- محتوى الملف المرفوع نصاً CSV: ملف Excel (xlsx، الورقة الأولى) أو CSV بترميز UTF-8 أو Windows-1256
  FUNCTION file_to_csv(p_content IN BLOB, p_file_name IN VARCHAR2) RETURN CLOB;
  -- إلغاء دفعة أرصدة افتتاحية (الحسابات/العملاء/الموردين) بقيد عكسي ما لم يسدد شيء منها
  PROCEDURE cancel_opening(p_batch_id IN NUMBER, p_reason IN VARCHAR2);
  -- معالج بدء التشغيل: خطوات نقل البيانات وحالتها ومطابقة الأرصدة؛ p_link فيه #TYPE#
  FUNCTION onboarding_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION openings_html RETURN CLOB;
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
      WHEN 'ACCOUNTS' THEN 'شجرة الحسابات'
      WHEN 'BANK_STATEMENT' THEN 'كشف حساب بنكي' WHEN 'ORDERS' THEN 'طلبات المتجر' WHEN 'EMPLOYEES' THEN 'الموظفون'
      WHEN 'OPENING_GL' THEN 'أرصدة الحسابات الافتتاحية' WHEN 'OPENING_AR' THEN 'أرصدة العملاء الافتتاحية'
      WHEN 'OPENING_AP' THEN 'أرصدة الموردين الافتتاحية' WHEN 'OPENING_STOCK' THEN 'أرصدة المخزون الافتتاحية' ELSE p_type END;
  END type_label;

  FUNCTION template_csv(p_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_type
      WHEN 'CUSTOMERS' THEN 'name,phone,email,tax,cr,address,term' || CHR(10) || 'مؤسسة النور التجارية,0551234567,info@alnoor.sa,300000000000003,1010101010,الرياض,NET30'
      WHEN 'SUPPLIERS' THEN 'name,phone,email,tax,cr,address,term' || CHR(10) || 'شركة التوريدات المتحدة,0112345678,sales@united.sa,310000000000003,1010202020,جدة,NET30'
      WHEN 'ITEMS' THEN 'no,name,nameEn,type,price,barcode,category' || CHR(10) || 'ITM-1001,قلم أزرق,Blue pen,STOCK,2.50,6281000000011,'
      WHEN 'ACCOUNTS' THEN 'code,name,parent,type,postable' || CHR(10) || '1150,العهد والسلف المؤقتة,11,أصول,لا'
                           || CHR(10) || '115001,عهدة مدير المشتريات,1150,,نعم' || CHR(10) || '115002,عهدة أمين الصندوق,1150,,نعم'
      WHEN 'BANK_STATEMENT' THEN 'date,amount,reference,counterparty,description' || CHR(10) || '2026-10-01,15000,TRF-889,مؤسسة النور,تحويل وارد'
      WHEN 'EMPLOYEES' THEN 'name,nameEn,nationalId,nationality,gender,birthDate,mobile,email,hireDate,jobTitle,branch,iban,basic,housing,transport,leaveDays'
        || CHR(10) || 'أحمد محمد العتيبي,Ahmed Alotaibi,1012345678,SA,ذكر,1990-05-14,0551234567,ahmed@co.sa,2024-03-01,محاسب,,SA0380000000608010167519,8000,2000,800,21'
      WHEN 'OPENING_GL' THEN 'code,name,debit,credit,cc,place' || CHR(10) || '1101,النقدية في الصندوق,25000,,,' || CHR(10)
        || '1102,النقدية لدى البنوك,480000,,,' || CHR(10) || '1103,العملاء,150000,,,' || CHR(10) || '2101,الموردون,,90000,,' || CHR(10)
        || '3101,رأس المال,,500000,,' || CHR(10) || '3103,الأرباح المبقاة,,65000,,'
      WHEN 'OPENING_AR' THEN 'customer,invoiceNo,date,dueDate,amount,description' || CHR(10)
        || 'مؤسسة النور التجارية,INV-2025-0412,2025-12-10,2026-01-09,85000,فاتورة مبيعات ديسمبر' || CHR(10)
        || 'مؤسسة النور التجارية,CN-2025-0031,2025-12-20,2025-12-20,-5000,إشعار دائن'
      WHEN 'OPENING_AP' THEN 'supplier,invoiceNo,date,dueDate,amount,description' || CHR(10)
        || 'شركة التوريدات المتحدة,SUP-88231,2025-12-15,2026-01-14,90000,فاتورة توريد'
      WHEN 'OPENING_STOCK' THEN 'item,warehouse,qty,cost,lot,expiry' || CHR(10) || 'ITM-1001,,1200,1.75,,' || CHR(10)
        || 'MED-0007,,300,12.40,B2511,2027-06-30'
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
      WHEN l IN ('no', 'code', 'sku', 'itemno', 'الكود', 'رمزالصنف', 'رقمالصنف', 'accountcode', 'رمزالحساب', 'رقمالحساب', 'item', 'الصنف', 'رقمالصنفأوالباركود') THEN 'no'
      WHEN l IN ('parent', 'parentcode', 'الحسابالأب', 'الحسابالرئيسي', 'رمزالأب', 'رقمالحسابالأب') THEN 'parent'
      WHEN l IN ('postable', 'حسابحركة', 'حركة', 'قابلللترحيل') THEN 'postable'
      WHEN l IN ('اسمالحساب', 'accountname') THEN 'name'
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
      WHEN l IN ('party', 'customer', 'supplier', 'العميل', 'المورد', 'customerno', 'supplierno', 'رقمالعميل', 'رقمالمورد') THEN 'party'
      WHEN l IN ('doc', 'docno', 'invoice', 'invoiceno', 'رقمالفاتورة', 'رقمالمستند', 'الفاتورة', 'المستند') THEN 'doc'
      WHEN l IN ('due', 'duedate', 'تاريخالاستحقاق', 'الاستحقاق') THEN 'due'
      WHEN l IN ('balance', 'openamount', 'الرصيد', 'المتبقي', 'المبلغالمتبقي') THEN 'amount'
      WHEN l IN ('cc', 'costcenter', 'مركزالتكلفة') THEN 'cc'
      WHEN l IN ('place', 'box', 'bank', 'cashbox', 'bankaccount', 'الصندوق', 'البنك', 'الصندوقأوالبنك') THEN 'place'
      WHEN l IN ('wh', 'warehouse', 'store', 'المستودع', 'المخزن') THEN 'wh'
      WHEN l IN ('qty', 'quantity', 'الكمية') THEN 'qty'
      WHEN l IN ('cost', 'unitcost', 'avgcost', 'التكلفة', 'تكلفةالوحدة', 'سعرالتكلفة', 'متوسطالتكلفة') THEN 'cost'
      WHEN l IN ('lot', 'lotno', 'batch', 'batchno', 'التشغيلة', 'رقمالتشغيلة') THEN 'lot'
      WHEN l IN ('expiry', 'expirydate', 'exp', 'تاريخالانتهاء', 'تاريخالصلاحية', 'الصلاحية') THEN 'expiry'
      WHEN l IN ('nid', 'nationalid', 'iqama', 'idno', 'الهوية', 'رقمالهوية', 'الإقامة', 'رقمالإقامة', 'رقمالهويةأوالإقامة', 'السجلالمدني') THEN 'nid'
      WHEN l IN ('nationality', 'الجنسية') THEN 'nationality'
      WHEN l IN ('gender', 'sex', 'الجنس') THEN 'gender'
      WHEN l IN ('birth', 'birthdate', 'dob', 'dateofbirth', 'تاريخالميلاد') THEN 'birth'
      WHEN l IN ('idexpiry', 'انتهاءالهوية', 'تاريخانتهاءالهوية') THEN 'idexpiry'
      WHEN l IN ('hire', 'hiredate', 'joindate', 'startdate', 'تاريخالتعيين', 'تاريخالمباشرة', 'تاريخالالتحاق') THEN 'hire'
      WHEN l IN ('job', 'jobtitle', 'position', 'المسمىالوظيفي', 'الوظيفة', 'المهنة') THEN 'job'
      WHEN l IN ('branch', 'الفرع') THEN 'branch'
      WHEN l IN ('iban', 'الآيبان', 'الايبان', 'رقمالآيبان', 'رقمالايبان') THEN 'iban'
      WHEN l IN ('gosi', 'gosino', 'رقمالتأمينات', 'التأميناتالاجتماعية') THEN 'gosi'
      WHEN l IN ('basic', 'basicsalary', 'salary', 'الراتبالأساسي', 'الأساسي', 'الراتب') THEN 'basic'
      WHEN l IN ('housing', 'بدلالسكن', 'السكن') THEN 'housing'
      WHEN l IN ('transport', 'transportation', 'بدلالنقل', 'النقل', 'بدلالمواصلات') THEN 'transport'
      WHEN l IN ('other', 'otherallowance', 'بدلاتأخرى', 'بدلآخر') THEN 'other'
      WHEN l IN ('leave', 'leavedays', 'annualleave', 'أيامالإجازة', 'الإجازةالسنوية', 'أيامالإجازةالسنوية') THEN 'leave'
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
  EXCEPTION WHEN VALUE_ERROR OR INVALID_NUMBER THEN
    RAISE_APPLICATION_ERROR(-20001, 'NOONA-CON-006: رقم غير مفهوم: ' || SUBSTR(p, 1, 60));
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
  -- شجرة الحسابات من ملف: الرمز، الاسم، الحساب الأب، النوع (للحسابات الرئيسية العليا)، حساب حركة نعم/لا.
  -- الصفوف تعالج بأي ترتيب: من لم يوجد أبوه بعد يعاد في جولة لاحقة (حتى 10 مستويات)
  FUNCTION import_accounts(p_file_name VARCHAR2, p_csv CLOB) RETURN NUMBER IS
    TYPE t_idx IS TABLE OF PLS_INTEGER;
    l_rows  t_rows;
    l_map   t_map;
    l_r     t_row;
    l_job   NUMBER;
    l_ok    PLS_INTEGER := 0;
    l_bad   PLS_INTEGER := 0;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_e     JSON_OBJECT_T;
    l_todo  t_idx := t_idx();
    l_next  t_idx;
    l_id    NUMBER;
    l_coa   NUMBER := NOONA_GL_PKG.primary_coa;
    l_code  VARCHAR2(100);
    l_name  VARCHAR2(400);
    l_par   VARCHAR2(100);
    l_type  VARCHAR2(100);
    l_post  VARCHAR2(100);
    l_err   VARCHAR2(4000);
    l_ec    CLOB;
    l_total PLS_INTEGER;
    l_en    VARCHAR2(200);
    TYPE t_seen IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(100);
    l_seen  t_seen;
    FUNCTION acc_type(p VARCHAR2) RETURN VARCHAR2 IS
      l VARCHAR2(100) := UPPER(REPLACE(TRIM(p), ' ', ''));
    BEGIN
      RETURN CASE WHEN l IS NULL THEN NULL
                  WHEN l IN ('ASSET', 'ASSETS', 'أصول', 'أصل', 'اصول') THEN 'ASSET'
                  WHEN l IN ('LIABILITY', 'LIABILITIES', 'خصوم', 'التزامات', 'الالتزامات') THEN 'LIABILITY'
                  WHEN l IN ('EQUITY', 'حقوقملكية', 'حقوقالملكية') THEN 'EQUITY'
                  WHEN l IN ('REVENUE', 'INCOME', 'إيرادات', 'ايرادات', 'إيراد') THEN 'REVENUE'
                  WHEN l IN ('EXPENSE', 'EXPENSES', 'مصروفات', 'مصاريف', 'مصروف') THEN 'EXPENSE'
                  ELSE '?' || p END;
    END acc_type;
    FUNCTION yes(p VARCHAR2) RETURN VARCHAR2 IS
      l VARCHAR2(100) := UPPER(TRIM(p));
    BEGIN
      RETURN CASE WHEN l IS NULL THEN 'Y' WHEN l IN ('Y', 'YES', '1', 'نعم', 'حركة', 'TRUE') THEN 'Y'
                  WHEN l IN ('N', 'NO', '0', 'لا', 'تجميعي', 'رئيسي', 'FALSE') THEN 'N' ELSE '?' END;
    END yes;
  BEGIN
    guard('API_IMPORT_JOB.CREATE');
    guard('GL_ACCOUNT.CREATE');
    NOONA_CORE_PKG.assert(l_coa IS NOT NULL, 'NOONA-CON-020', 'جهز الأستاذ العام للشركة أولاً (دليل الحسابات)', 'Set up the general ledger first');
    l_rows := parse_csv(p_csv);
    NOONA_CORE_PKG.assert(l_rows.COUNT >= 2, 'NOONA-CON-002', 'الملف فارغ أو بلا صفوف بيانات بعد سطر العناوين', 'File has no data rows');
    NOONA_CORE_PKG.assert(l_rows.COUNT <= 5001, 'NOONA-CON-003', 'الحد الأقصى 5000 صف في الملف الواحد', 'Maximum 5000 rows per file');
    l_map := header_map(l_rows(1));
    NOONA_CORE_PKG.assert(l_map.EXISTS('no') AND l_map.EXISTS('name'), 'NOONA-CON-021',
      'عمودا رمز الحساب (code) واسم الحساب (name) مطلوبان في سطر العناوين', 'Header must include code and name');
    l_total := l_rows.COUNT - 1;
    INSERT INTO api_import_job (company_id, import_type, file_name, total_rows, ok_rows, failed_rows, status_code)
    VALUES (company, 'ACCOUNTS', SUBSTR(p_file_name, 1, 300), l_total, 0, 0, 'RUNNING')
    RETURNING id INTO l_job;
    -- الرمز المكرر داخل الملف: يعتمد أول ظهور ويرفض الباقي
    FOR i IN 2 .. l_rows.COUNT LOOP
      l_code := UPPER(col(l_rows(i), l_map, 'no'));
      IF l_code IS NOT NULL AND l_seen.EXISTS(l_code) THEN
        l_bad := l_bad + 1;
        l_e := JSON_OBJECT_T();
        l_e.put('row', i); l_e.put('name', l_code || ' ' || col(l_rows(i), l_map, 'name'));
        l_e.put('error', 'رمز الحساب مكرر في الملف (الصف ' || l_seen(l_code) || ')');
        l_errs.append(l_e);
      ELSE
        IF l_code IS NOT NULL THEN l_seen(l_code) := i; END IF;
        l_todo.EXTEND; l_todo(l_todo.COUNT) := i;
      END IF;
    END LOOP;
    FOR pass IN 1 .. 10 LOOP
      EXIT WHEN l_todo.COUNT = 0;
      l_next := t_idx();
      FOR k IN 1 .. l_todo.COUNT LOOP
        l_r := l_rows(l_todo(k));
        l_code := UPPER(col(l_r, l_map, 'no')); l_name := col(l_r, l_map, 'name'); l_par := UPPER(col(l_r, l_map, 'parent'));
        l_type := acc_type(col(l_r, l_map, 'type')); l_post := yes(col(l_r, l_map, 'postable'));
        SAVEPOINT import_acc;
        BEGIN
          NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-CON-022', 'رمز الحساب أو اسمه فارغ', 'Code or name is empty');
          NOONA_CORE_PKG.assert(l_type IS NULL OR l_type NOT LIKE '?%', 'NOONA-CON-023',
            'نوع غير معروف: ' || SUBSTR(l_type, 2) || ' (أصول، خصوم، حقوق ملكية، إيرادات، مصروفات)', 'Unknown account type');
          NOONA_CORE_PKG.assert(l_post <> '?', 'NOONA-CON-024', 'حساب حركة: نعم أو لا', 'Postable must be yes or no');
          l_id := NOONA_GL_PKG.add_account(l_coa, l_code, l_name, l_par, l_type, l_post);
          l_en := SUBSTR(col(l_r, l_map, 'nameEn'), 1, 200);
          IF l_en IS NOT NULL THEN
            UPDATE gl_account SET name_en = l_en WHERE id = l_id;
          END IF;
          l_ok := l_ok + 1;
        EXCEPTION WHEN OTHERS THEN
          ROLLBACK TO import_acc;
          l_err := clean_err(SQLERRM);
          IF INSTR(SQLERRM, 'NOONA-GL-011') > 0 AND pass < 10 THEN
            l_next.EXTEND; l_next(l_next.COUNT) := l_todo(k);             -- الأب في صف لاحق: جولة أخرى
          ELSE
            l_bad := l_bad + 1;
            IF l_errs.get_size < 500 THEN
              l_e := JSON_OBJECT_T();
              l_e.put('row', l_todo(k)); l_e.put('name', l_code || ' ' || l_name); l_e.put('error', l_err);
              l_errs.append(l_e);
            END IF;
          END IF;
        END;
      END LOOP;
      IF l_next.COUNT > 0 AND l_next.COUNT = l_todo.COUNT THEN
        -- لا تقدم: آباء هذه الصفوف ليست في الدليل ولا في الملف
        FOR k IN 1 .. l_next.COUNT LOOP
          l_r := l_rows(l_next(k));
          l_bad := l_bad + 1;
          l_e := JSON_OBJECT_T();
          l_e.put('row', l_next(k)); l_e.put('name', col(l_r, l_map, 'no') || ' ' || col(l_r, l_map, 'name'));
          l_e.put('error', 'الحساب الأب غير موجود: ' || col(l_r, l_map, 'parent'));
          l_errs.append(l_e);
        END LOOP;
        EXIT;
      END IF;
      l_todo := l_next;
    END LOOP;
    l_ec := l_errs.to_clob;
    UPDATE api_import_job SET ok_rows = l_ok, failed_rows = l_bad, errors = l_ec,
                              status_code = CASE WHEN l_bad = 0 THEN 'COMPLETED' WHEN l_ok = 0 THEN 'FAILED' ELSE 'PARTIAL' END
     WHERE id = l_job;
    NOONA_AUDIT_PKG.log_event('API', 'API_IMPORT_JOB', l_job, 'IMPORT_ACCOUNTS', 'SUCCESS',
                              p_new_values => JSON_OBJECT('ok' VALUE l_ok, 'failed' VALUE l_bad));
    RETURN l_job;
  END import_accounts;

  -- ================================================================ ملفات Excel وترميز CSV
  FUNCTION file_to_csv(p_content IN BLOB, p_file_name IN VARCHAR2) RETURN CLOB IS
    l_csv  CLOB;
    l_line VARCHAR2(32767);
    l_name VARCHAR2(400) := LOWER(p_file_name);
    l_raw  RAW(4000);
    l_len  PLS_INTEGER;
    l_pos  PLS_INTEGER;
    l_b    PLS_INTEGER;
    l_k    PLS_INTEGER;
    l_utf  BOOLEAN := TRUE;
    l_do   INTEGER := 1;
    l_so   INTEGER := 1;
    l_lc   INTEGER := DBMS_LOB.default_lang_ctx;
    l_w    INTEGER;
    FUNCTION q(p VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN CASE WHEN p IS NULL THEN NULL
                  WHEN INSTR(p, '"') > 0 OR INSTR(p, ',') > 0 OR INSTR(p, CHR(10)) > 0 OR INSTR(p, CHR(13)) > 0
                  THEN '"' || REPLACE(REPLACE(p, CHR(13)), '"', '""') || '"' ELSE p END;
    END q;
  BEGIN
    NOONA_CORE_PKG.assert(p_content IS NOT NULL AND DBMS_LOB.getlength(p_content) > 0, 'NOONA-CON-030', 'الملف فارغ', 'The file is empty');
    NOONA_CORE_PKG.assert(l_name NOT LIKE '%.xls', 'NOONA-CON-031',
      'صيغة xls القديمة غير مدعومة: احفظ الملف من Excel بصيغة xlsx أو CSV', 'Old .xls format: save as .xlsx or CSV');
    IF l_name LIKE '%.xlsx' THEN
      -- الورقة الأولى من الملف؛ كل صف يصبح سطر CSV بالفاصلة (حتى 40 عموداً)
      DBMS_LOB.createtemporary(l_csv, TRUE);
      FOR r IN (SELECT col001, col002, col003, col004, col005, col006, col007, col008, col009, col010,
                       col011, col012, col013, col014, col015, col016, col017, col018, col019, col020,
                       col021, col022, col023, col024, col025, col026, col027, col028, col029, col030,
                       col031, col032, col033, col034, col035, col036, col037, col038, col039, col040
                  FROM TABLE(apex_data_parser.parse(p_content => p_content, p_file_name => p_file_name, p_max_rows => 5002,
                                                    p_detect_data_types => 'N'))
                 ORDER BY line_number) LOOP
        l_line := RTRIM(q(r.col001) || ',' || q(r.col002) || ',' || q(r.col003) || ',' || q(r.col004) || ',' || q(r.col005) || ','
               || q(r.col006) || ',' || q(r.col007) || ',' || q(r.col008) || ',' || q(r.col009) || ',' || q(r.col010) || ','
               || q(r.col011) || ',' || q(r.col012) || ',' || q(r.col013) || ',' || q(r.col014) || ',' || q(r.col015) || ','
               || q(r.col016) || ',' || q(r.col017) || ',' || q(r.col018) || ',' || q(r.col019) || ',' || q(r.col020) || ','
               || q(r.col021) || ',' || q(r.col022) || ',' || q(r.col023) || ',' || q(r.col024) || ',' || q(r.col025) || ','
               || q(r.col026) || ',' || q(r.col027) || ',' || q(r.col028) || ',' || q(r.col029) || ',' || q(r.col030) || ','
               || q(r.col031) || ',' || q(r.col032) || ',' || q(r.col033) || ',' || q(r.col034) || ',' || q(r.col035) || ','
               || q(r.col036) || ',' || q(r.col037) || ',' || q(r.col038) || ',' || q(r.col039) || ',' || q(r.col040), ',');
        IF l_line IS NOT NULL THEN
          DBMS_LOB.writeappend(l_csv, LENGTH(l_line) + 1, l_line || CHR(10));
        END IF;
      END LOOP;
      RETURN l_csv;
    END IF;
    -- CSV: UTF-8، وإن لم يكن (حفظ Excel العربي العادي) فترميز Windows-1256
    -- الفحص: أول 4000 بايت تسلسل UTF-8 صالح، وإلا فالملف محفوظ بترميز Windows-1256 (حفظ CSV العادي في Excel العربي)
    l_raw := DBMS_LOB.substr(p_content, 4000, 1);
    l_len := UTL_RAW.length(l_raw);
    l_pos := 1;
    WHILE l_pos <= l_len AND l_utf LOOP
      l_b := TO_NUMBER(RAWTOHEX(UTL_RAW.substr(l_raw, l_pos, 1)), 'XX');
      l_k := CASE WHEN l_b < 128 THEN 0 WHEN l_b BETWEEN 194 AND 223 THEN 1 WHEN l_b BETWEEN 224 AND 239 THEN 2
                  WHEN l_b BETWEEN 240 AND 244 THEN 3 ELSE -1 END;
      IF l_k < 0 THEN l_utf := FALSE; END IF;
      FOR k IN 1 .. GREATEST(l_k, 0) LOOP
        EXIT WHEN l_pos + k > l_len;
        IF TO_NUMBER(RAWTOHEX(UTL_RAW.substr(l_raw, l_pos + k, 1)), 'XX') NOT BETWEEN 128 AND 191 THEN l_utf := FALSE; END IF;
      END LOOP;
      l_pos := l_pos + 1 + GREATEST(l_k, 0);
    END LOOP;
    DBMS_LOB.createtemporary(l_csv, TRUE);
    DBMS_LOB.converttoclob(dest_lob => l_csv, src_blob => p_content, amount => DBMS_LOB.lobmaxsize, dest_offset => l_do, src_offset => l_so,
                           blob_csid => NLS_CHARSET_ID(CASE WHEN l_utf THEN 'AL32UTF8' ELSE 'AR8MSWIN1256' END),
                           lang_context => l_lc, warning => l_w);
    RETURN l_csv;
  END file_to_csv;

  -- ================================================================ الأرصدة الافتتاحية
  -- ملف الحسابات: قيد افتتاحي واحد (الفرق إلى 3105 الأرصدة الافتتاحية)، وحسابات المراقبة (العملاء والموردون والمخزون
  -- والأصول) لا ترحل منه بل من ملفاتها التفصيلية فتطابق معها؛ النقدية والبنوك تسجل رصيداً للصندوق أو الحساب البنكي.
  -- ملفات العملاء والموردين: ذمة مفتوحة لكل فاتورة (تسدد لاحقاً بالتحصيل والسداد العادي) مقابل 3105.
  -- ملف المخزون: مستند رصيد افتتاحي مرحل لكل مستودع (الكمية والتكلفة والتشغيلة والصلاحية).
  -- كل ملف أرصدة يرحل كاملاً أو لا يرحل منه شيء: أي خطأ يمنع الترحيل ويظهر في تقرير الاستيراد.
  FUNCTION scope_label(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'GL' THEN 'الحسابات والنقدية' WHEN 'AR' THEN 'العملاء' WHEN 'AP' THEN 'الموردين' WHEN 'INV' THEN 'المخزون' ELSE p END;
  END scope_label;

  PROCEDURE add_err(p_errs IN OUT NOCOPY JSON_ARRAY_T, p_row PLS_INTEGER, p_name VARCHAR2, p_msg VARCHAR2) IS
    l_e JSON_OBJECT_T := JSON_OBJECT_T();
  BEGIN
    IF p_errs.get_size >= 500 THEN RETURN; END IF;
    l_e.put('row', p_row); l_e.put('name', SUBSTR(p_name, 1, 400)); l_e.put('error', SUBSTR(p_msg, 1, 1000));
    p_errs.append(l_e);
  END add_err;

  FUNCTION start_job(p_type VARCHAR2, p_file VARCHAR2, p_total PLS_INTEGER) RETURN NUMBER IS
    l_job NUMBER;
  BEGIN
    INSERT INTO api_import_job (company_id, import_type, file_name, total_rows, ok_rows, failed_rows, status_code)
    VALUES (company, p_type, SUBSTR(p_file, 1, 300), p_total, 0, 0, 'RUNNING')
    RETURNING id INTO l_job;
    RETURN l_job;
  END start_job;

  FUNCTION end_job(p_job NUMBER, p_type VARCHAR2, p_ok PLS_INTEGER, p_bad PLS_INTEGER, p_errs JSON_ARRAY_T, p_ref NUMBER DEFAULT NULL)
    RETURN NUMBER IS
    l_ec CLOB := p_errs.to_clob;
  BEGIN
    UPDATE api_import_job SET ok_rows = p_ok, failed_rows = p_bad, errors = l_ec, result_ref = p_ref,
                              status_code = CASE WHEN p_bad = 0 THEN 'COMPLETED' WHEN p_ok = 0 THEN 'FAILED' ELSE 'PARTIAL' END
     WHERE id = p_job;
    NOONA_AUDIT_PKG.log_event('API', 'API_IMPORT_JOB', p_job, 'IMPORT_' || p_type, CASE WHEN p_ok > 0 THEN 'SUCCESS' ELSE 'FAILED' END,
                              p_new_values => JSON_OBJECT('ok' VALUE p_ok, 'failed' VALUE p_bad, 'ref' VALUE p_ref));
    RETURN p_job;
  END end_job;

  FUNCTION opening_account RETURN NUMBER IS
    l NUMBER := NOONA_INV_PKG.acc_id('3105');
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '3105', 'الأرصدة الافتتاحية', '3', 'EQUITY');
    END IF;
    RETURN l;
  END opening_account;

  FUNCTION amount_of(p_row t_row, p_map t_map) RETURN NUMBER IS
  BEGIN
    IF p_map.EXISTS('amount') AND col(p_row, p_map, 'amount') IS NOT NULL THEN
      RETURN to_num(col(p_row, p_map, 'amount'));
    END IF;
    RETURN NVL(to_num(col(p_row, p_map, 'debit')), 0) - NVL(to_num(col(p_row, p_map, 'credit')), 0);
  END amount_of;

  FUNCTION new_batch(p_scope VARCHAR2, p_date DATE, p_file VARCHAR2) RETURN NUMBER IS
    l_id  NUMBER;
    l_no  VARCHAR2(50);
    l_n   NUMBER;
  BEGIN
    SELECT COUNT(*) + 1 INTO l_n FROM gl_opening_batch WHERE company_id = company;
    l_no := 'OB-' || p_scope || '-' || LPAD(l_n, 3, '0');
    INSERT INTO gl_opening_batch (company_id, batch_no, ledger_id, period_id, scope_code, source_system, status_code)
    VALUES (company, l_no, NOONA_GL_PKG.primary_ledger, NOONA_GL_PKG.period_for(p_date), p_scope, SUBSTR(p_file, 1, 100), 'DRAFT')
    RETURNING id INTO l_id;
    RETURN l_id;
  END new_batch;

  FUNCTION post_batch(p_batch NUMBER, p_date DATE, p_desc VARCHAR2, p_lines NOONA_GL_PKG.t_lines) RETURN NUMBER IS
    l_j  NUMBER;
    l_no VARCHAR2(50);
  BEGIN
    SELECT batch_no INTO l_no FROM gl_opening_batch WHERE id = p_batch;
    l_j := NOONA_ACE_PKG.post_source('GL_OPENING_BALANCE', 'MIGRATION', 'GL_OPENING_BATCH', p_batch, p_date, p_desc,
                                     NOONA_GL_PKG.ledger_currency, 1, p_lines, l_no, NULL, 'OPENING');
    -- قيد افتتاحي: يظهر في عمود الرصيد الافتتاحي بميزان المراجعة لا في حركة الفترة
    UPDATE gl_journal SET is_opening = 'Y', journal_category = 'OPENING' WHERE id = l_j;
    UPDATE gl_opening_batch SET journal_id = l_j, status_code = 'POSTED' WHERE id = p_batch;
    RETURN l_j;
  END post_batch;

  PROCEDURE add_gl(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_amt NUMBER, p_cc NUMBER, p_party NUMBER, p_txt VARCHAR2) IS
  BEGIN
    IF NVL(p_amt, 0) = 0 THEN RETURN; END IF;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := GREATEST(p_amt, 0);
    p_lines(p_lines.COUNT).credit := GREATEST(-p_amt, 0);
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).party_id := p_party;
    p_lines(p_lines.COUNT).description := SUBSTR(p_txt, 1, 1000);
  END add_gl;

  -- الصندوق أو الحساب البنكي لسطر نقدية: من عمود place (الرمز أو الاسم أو رقم الحساب/الآيبان) أو الوحيد المربوط بالحساب
  FUNCTION cash_place(p_account_id NUMBER, p_place VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2 IS
    l_box NUMBER; l_bnk NUMBER; l_n NUMBER; l_cur VARCHAR2(3);
  BEGIN
    IF p_place IS NOT NULL THEN
      SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = company AND (UPPER(code) = UPPER(p_place) OR name_ar = p_place);
      IF l_box IS NULL THEN
        SELECT MIN(id) INTO l_bnk FROM csh_bank_account
         WHERE company_id = company AND (UPPER(code) = UPPER(p_place) OR name_ar = p_place OR account_no_masked = p_place);
      END IF;
      NOONA_CORE_PKG.assert(l_box IS NOT NULL OR l_bnk IS NOT NULL, 'NOONA-CON-045', 'الصندوق أو الحساب البنكي غير موجود: ' || p_place,
                            'Cash box or bank account not found');
    ELSE
      SELECT COUNT(*), MIN(id) INTO l_n, l_box FROM csh_cash_box WHERE company_id = company AND gl_account_id = p_account_id AND status_code = 'ACTIVE';
      SELECT l_n + COUNT(*), MIN(id) INTO l_n, l_bnk FROM csh_bank_account WHERE company_id = company AND gl_account_id = p_account_id AND status_code = 'ACTIVE';
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-CON-046', 'لا يوجد صندوق أو حساب بنكي مربوط بالحساب ' || p_code || ': أنشئه في المالية أولاً',
                            'No cash box or bank account uses this GL account');
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-CON-047', 'أكثر من صندوق/بنك على الحساب ' || p_code || ': حدد الصندوق أو البنك في عمود place',
                            'Several cash places use this account: fill the place column');
      IF l_box IS NOT NULL THEN l_bnk := NULL; END IF;
    END IF;
    IF l_box IS NOT NULL THEN
      SELECT currency_code, gl_account_id INTO l_cur, l_n FROM csh_cash_box WHERE id = l_box;
    ELSE
      SELECT currency_code, gl_account_id INTO l_cur, l_n FROM csh_bank_account WHERE id = l_bnk;
    END IF;
    NOONA_CORE_PKG.assert(l_n = p_account_id, 'NOONA-CON-048', 'الصندوق/البنك ' || p_place || ' مربوط بحساب أستاذ غير ' || p_code,
                          'Cash place is linked to another GL account');
    NOONA_CORE_PKG.assert(l_cur = NOONA_GL_PKG.ledger_currency, 'NOONA-CON-049',
      'رصيد بعملة أجنبية (' || l_cur || '): أدخله بسند قبض يدوي بسعر الصرف', 'Foreign currency balances: use a manual receipt');
    RETURN CASE WHEN l_box IS NOT NULL THEN 'BOX:' || l_box ELSE 'BANK:' || l_bnk END;
  END cash_place;

  -- ---------------------------------------------------------------- أرصدة الحسابات
  FUNCTION import_opening_gl(p_date DATE, p_file VARCHAR2, p_rows t_rows, p_map t_map) RETURN NUMBER IS
    TYPE t_cash IS RECORD (place VARCHAR2(30), amt NUMBER, txt VARCHAR2(400));
    TYPE t_cashs IS TABLE OF t_cash;
    l_job   NUMBER;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_cash  t_cashs := t_cashs();
    l_acc   gl_account%ROWTYPE;
    l_coa   NUMBER := NOONA_GL_PKG.primary_coa;
    l_code  VARCHAR2(100);
    l_amt   NUMBER;
    l_cc    NUMBER;
    l_ccode VARCHAR2(100);
    l_bad   PLS_INTEGER := 0;
    l_ok    PLS_INTEGER := 0;
    l_ctl   PLS_INTEGER := 0;
    l_net   NUMBER := 0;
    l_batch NUMBER;
    l_j     NUMBER;
    l_ev    NUMBER;
    l_x     NUMBER;
    l_no    VARCHAR2(50);
    l_place VARCHAR2(30);
    l_txt   VARCHAR2(400);
    l_n     NUMBER;
    TYPE t_ol IS TABLE OF gl_opening_line%ROWTYPE;
    l_ol    t_ol := t_ol();
  BEGIN
    SELECT COUNT(*) INTO l_n FROM gl_opening_batch WHERE company_id = company AND scope_code = 'GL' AND status_code = 'POSTED';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-040',
      'أرصدة الحسابات الافتتاحية مستوردة مسبقاً؛ ألغ الدفعة السابقة من قائمة الدفعات قبل إعادة الاستيراد', 'GL opening balances already imported');
    NOONA_CORE_PKG.assert(p_map.EXISTS('no') AND (p_map.EXISTS('debit') OR p_map.EXISTS('credit') OR p_map.EXISTS('amount')), 'NOONA-CON-041',
      'الأعمدة المطلوبة: رمز الحساب (code) والمدين والدائن (debit, credit) أو الرصيد (balance)', 'Header must include code and debit/credit');
    l_job := start_job('OPENING_GL', p_file, p_rows.COUNT - 1);
    FOR i IN 2 .. p_rows.COUNT LOOP
      l_code := UPPER(col(p_rows(i), p_map, 'no'));
      BEGIN
        l_amt := ROUND(amount_of(p_rows(i), p_map), 2);
        CONTINUE WHEN l_code IS NULL AND NVL(l_amt, 0) = 0;
        NOONA_CORE_PKG.assert(l_code IS NOT NULL, 'NOONA-CON-042', 'رمز الحساب فارغ', 'Account code is empty');
        BEGIN
          SELECT * INTO l_acc FROM gl_account WHERE coa_id = l_coa AND UPPER(account_code) = l_code;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          NOONA_CORE_PKG.raise_error('NOONA-CON-043', 'الحساب غير موجود في الدليل: ' || l_code || ' (استورد شجرة الحسابات أولاً)', 'Account not found');
        END;
        CONTINUE WHEN NVL(l_amt, 0) = 0;
        NOONA_CORE_PKG.assert(l_acc.is_postable = 'Y', 'NOONA-CON-044', 'الحساب ' || l_code || ' تجميعي: أدخل الرصيد على حساباته الفرعية',
                              'Summary account: use its child accounts');
        l_ccode := col(p_rows(i), p_map, 'cc');
        l_cc := NULL;
        IF l_ccode IS NOT NULL THEN
          SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = company AND (UPPER(code) = UPPER(l_ccode) OR name_ar = l_ccode);
          NOONA_CORE_PKG.assert(l_cc IS NOT NULL, 'NOONA-CON-050', 'مركز التكلفة غير موجود: ' || l_ccode, 'Cost center not found');
        END IF;
        l_txt := NVL(col(p_rows(i), p_map, 'description'), 'رصيد افتتاحي ' || l_acc.name_ar);
        l_ol.EXTEND;
        l_ol(l_ol.COUNT).line_no := l_ol.COUNT;
        l_ol(l_ol.COUNT).source_account := SUBSTR(col(p_rows(i), p_map, 'no'), 1, 100);
        l_ol(l_ol.COUNT).account_id := l_acc.id;
        l_ol(l_ol.COUNT).debit_amount := GREATEST(l_amt, 0);
        l_ol(l_ol.COUNT).credit_amount := GREATEST(-l_amt, 0);
        l_ol(l_ol.COUNT).cost_center_id := l_cc;
        IF l_acc.is_control = 'Y' THEN
          -- حساب مراقبة: رصيده للمطابقة فقط، ويرحل من ملفه التفصيلي
          l_ctl := l_ctl + 1;
          add_err(l_errs, i, l_code || ' ' || l_acc.name_ar,
                  'تنبيه: حساب مراقبة (' || CASE l_acc.subledger_code WHEN 'AR' THEN 'العملاء' WHEN 'AP' THEN 'الموردون' WHEN 'INV' THEN 'المخزون'
                                                   WHEN 'FA' THEN 'الأصول الثابتة' ELSE l_acc.subledger_code END
                  || ') لم يرحل من هذا الملف؛ يرحل من ملف أرصدته التفصيلية ويطابق مع ' || TO_CHAR(l_amt, 'FM999,999,999,990.00'));
        ELSE
          IF l_acc.subledger_code = 'CASH' THEN
            l_place := cash_place(l_acc.id, col(p_rows(i), p_map, 'place'), l_code);
            l_cash.EXTEND; l_cash(l_cash.COUNT).place := l_place; l_cash(l_cash.COUNT).amt := l_amt; l_cash(l_cash.COUNT).txt := l_txt;
          END IF;
          add_gl(l_lines, l_acc.id, l_amt, l_cc, NULL, l_txt);
          l_net := l_net + l_amt;
        END IF;
        l_ok := l_ok + 1;
      EXCEPTION WHEN OTHERS THEN
        l_bad := l_bad + 1;
        add_err(l_errs, i, l_code, clean_err(SQLERRM));
      END;
    END LOOP;
    IF l_bad > 0 OR l_lines.COUNT = 0 THEN
      IF l_lines.COUNT = 0 AND l_bad = 0 THEN add_err(l_errs, 0, NULL, 'لا توجد أرصدة لترحيلها في الملف'); l_bad := 1; END IF;
      add_err(l_errs, 0, NULL, 'لم يرحل شيء: صحح الأخطاء أعلاه وأعد استيراد الملف كاملاً');
      RETURN end_job(l_job, 'OPENING_GL', 0, l_bad, l_errs);
    END IF;
    SAVEPOINT opening_gl;
    BEGIN
      l_batch := new_batch('GL', p_date, p_file);
      -- الفرق (أرصدة حسابات المراقبة التي ترحل من ملفاتها، أو عدم توازن الملف) إلى حساب الأرصدة الافتتاحية
      add_gl(l_lines, opening_account, -l_net, NULL, NULL, 'فرق الأرصدة الافتتاحية (يقابل أرصدة العملاء والموردين والمخزون والأصول)');
      FOR k IN 1 .. l_ol.COUNT LOOP
        INSERT INTO gl_opening_line (company_id, currency_code, exchange_rate, batch_id, line_no, source_account, account_id,
                                     debit_amount, credit_amount, debit_func, credit_func, cost_center_id)
        VALUES (company, NOONA_GL_PKG.ledger_currency, 1, l_batch, k, l_ol(k).source_account, l_ol(k).account_id,
                l_ol(k).debit_amount, l_ol(k).credit_amount, l_ol(k).debit_amount, l_ol(k).credit_amount, l_ol(k).cost_center_id);
      END LOOP;
      l_j := post_batch(l_batch, p_date, 'الأرصدة الافتتاحية للحسابات في ' || TO_CHAR(p_date, 'YYYY-MM-DD'), l_lines);
      SELECT accounting_event_id INTO l_ev FROM gl_journal WHERE id = l_j;
      SELECT batch_no INTO l_no FROM gl_opening_batch WHERE id = l_batch;
      FOR k IN 1 .. l_cash.COUNT LOOP
        l_x := NOONA_CSH_PKG.record_settlement(CASE WHEN l_cash(k).amt > 0 THEN 'RECEIPT' ELSE 'PAYMENT' END, l_cash(k).place, p_date,
                                               ABS(l_cash(k).amt), NULL, 'رصيد افتتاحي', 'GL_OPENING_BATCH', l_batch, l_no,
                                               l_cash(k).txt, l_ev);
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO opening_gl;
      add_err(l_errs, 0, NULL, 'تعذر الترحيل: ' || clean_err(SQLERRM));
      RETURN end_job(l_job, 'OPENING_GL', 0, l_ok + l_bad, l_errs);
    END;
    RETURN end_job(l_job, 'OPENING_GL', l_ok, 0, l_errs, l_batch);
  END import_opening_gl;

  -- ---------------------------------------------------------------- أرصدة العملاء والموردين
  FUNCTION party_account(p_scope VARCHAR2, p_key VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_scope = 'AR' THEN
      SELECT MIN(a.id) INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN pty_party p ON p.id = c.party_id
       WHERE a.company_id = company AND (UPPER(a.account_no) = UPPER(p_key) OR UPPER(c.customer_no) = UPPER(p_key)
                                         OR p.tax_number = p_key OR p.display_name_ar = p_key OR UPPER(p.display_name_en) = UPPER(p_key));
    ELSE
      SELECT MIN(a.id) INTO l FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id JOIN pty_party p ON p.id = s.party_id
       WHERE a.company_id = company AND (UPPER(a.account_no) = UPPER(p_key) OR UPPER(s.supplier_no) = UPPER(p_key)
                                         OR p.tax_number = p_key OR p.display_name_ar = p_key OR UPPER(p.display_name_en) = UPPER(p_key));
    END IF;
    RETURN l;
  END party_account;

  FUNCTION import_opening_party(p_scope VARCHAR2, p_date DATE, p_file VARCHAR2, p_rows t_rows, p_map t_map) RETURN NUMBER IS
    TYPE t_it IS RECORD (acc NUMBER, party NUMBER, ctl NUMBER, doc VARCHAR2(50), dt DATE, due DATE, amt NUMBER, txt VARCHAR2(400));
    TYPE t_its IS TABLE OF t_it;
    TYPE t_seen IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(200);
    l_type  VARCHAR2(30) := CASE p_scope WHEN 'AR' THEN 'OPENING_AR' ELSE 'OPENING_AP' END;
    l_job   NUMBER;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_its   t_its := t_its();
    l_seen  t_seen;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_key   VARCHAR2(400);
    l_acc   NUMBER;
    l_n     NUMBER;
    l_bad   PLS_INTEGER := 0;
    l_net   NUMBER := 0;
    l_batch NUMBER;
    l_j     NUMBER;
    l_due   NUMBER;
    l_doc   VARCHAR2(100);
    l_dt    DATE;
    l_amt   NUMBER;
    l_lbl   VARCHAR2(400);
  BEGIN
    NOONA_CORE_PKG.assert((p_map.EXISTS('party') OR p_map.EXISTS('name') OR p_map.EXISTS('no'))
                          AND (p_map.EXISTS('amount') OR p_map.EXISTS('debit') OR p_map.EXISTS('credit')), 'NOONA-CON-051',
      'الأعمدة المطلوبة: ' || CASE p_scope WHEN 'AR' THEN 'العميل (customer)' ELSE 'المورد (supplier)' END
      || ' والمبلغ (amount) أو مدين ودائن', 'Header must include the party and the amount');
    l_job := start_job(l_type, p_file, p_rows.COUNT - 1);
    FOR i IN 2 .. p_rows.COUNT LOOP
      l_key := NVL(col(p_rows(i), p_map, 'party'), NVL(col(p_rows(i), p_map, 'name'), col(p_rows(i), p_map, 'no')));
      BEGIN
        l_amt := ROUND(amount_of(p_rows(i), p_map), 2);
        CONTINUE WHEN l_key IS NULL AND NVL(l_amt, 0) = 0;
        NOONA_CORE_PKG.assert(l_key IS NOT NULL, 'NOONA-CON-052', 'اسم الطرف أو رقمه فارغ', 'Party is empty');
        l_acc := party_account(p_scope, l_key);
        NOONA_CORE_PKG.assert(l_acc IS NOT NULL, 'NOONA-CON-053',
          CASE p_scope WHEN 'AR' THEN 'العميل غير موجود: ' ELSE 'المورد غير موجود: ' END || l_key
          || ' (استورد ' || CASE p_scope WHEN 'AR' THEN 'العملاء' ELSE 'الموردين' END || ' أولاً)', 'Party not found');
        CONTINUE WHEN NVL(l_amt, 0) = 0;
        l_dt := NVL(to_dt(col(p_rows(i), p_map, 'date')), p_date);
        NOONA_CORE_PKG.assert(l_dt <= p_date, 'NOONA-CON-054', 'تاريخ المستند بعد تاريخ الأرصدة الافتتاحية', 'Document date after the opening date');
        l_doc := NVL(col(p_rows(i), p_map, 'doc'), 'OB-' || (i - 1));
        NOONA_CORE_PKG.assert(LENGTH(l_doc) <= 50, 'NOONA-CON-055', 'رقم المستند أطول من 50 حرفاً', 'Document number too long');
        NOONA_CORE_PKG.assert(NOT l_seen.EXISTS(l_acc || '|' || UPPER(l_doc)), 'NOONA-CON-056',
          'رقم المستند ' || l_doc || ' مكرر لنفس الطرف في الملف', 'Duplicate document in the file');
        IF p_scope = 'AR' THEN
          SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE customer_account_id = l_acc AND UPPER(doc_no) = UPPER(l_doc) AND status_code <> 'CANCELLED';
        ELSE
          SELECT COUNT(*) INTO l_n FROM ap_open_item WHERE supplier_account_id = l_acc AND UPPER(doc_no) = UPPER(l_doc) AND status_code <> 'CANCELLED';
        END IF;
        NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-057', 'المستند ' || l_doc || ' مسجل مسبقاً لهذا الطرف', 'Document already registered');
        l_seen(l_acc || '|' || UPPER(l_doc)) := i;
        l_its.EXTEND;
        l_its(l_its.COUNT).acc := l_acc; l_its(l_its.COUNT).doc := l_doc; l_its(l_its.COUNT).dt := l_dt; l_its(l_its.COUNT).amt := l_amt;
        IF p_scope = 'AR' THEN
          SELECT c.party_id, NVL(a.receivable_account_id, NOONA_INV_PKG.acc_id('1103')), NVL(MAX(t.due_days), 0)
            INTO l_its(l_its.COUNT).party, l_its(l_its.COUNT).ctl, l_due
            FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id LEFT JOIN ref_payment_term t ON t.id = a.payment_term_id
           WHERE a.id = l_acc GROUP BY c.party_id, a.receivable_account_id;
          l_lbl := NOONA_SAL_PKG.customer_label(l_acc);
        ELSE
          SELECT s.party_id, NVL(a.payable_account_id, NOONA_INV_PKG.acc_id('2101')), NVL(MAX(t.due_days), 0)
            INTO l_its(l_its.COUNT).party, l_its(l_its.COUNT).ctl, l_due
            FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id LEFT JOIN ref_payment_term t ON t.id = a.payment_term_id
           WHERE a.id = l_acc GROUP BY s.party_id, a.payable_account_id;
          l_lbl := NOONA_PUR_PKG.supplier_label(l_acc);
        END IF;
        NOONA_CORE_PKG.assert(l_its(l_its.COUNT).ctl IS NOT NULL, 'NOONA-CON-058', 'حساب المراقبة غير مجهز: نفذ تجهيز المبيعات/المشتريات',
                              'Control account not set up');
        l_its(l_its.COUNT).due := NVL(to_dt(col(p_rows(i), p_map, 'due')), l_dt + l_due);
        l_its(l_its.COUNT).txt := SUBSTR(NVL(col(p_rows(i), p_map, 'description'), 'رصيد افتتاحي ' || l_doc) || ' - ' || l_lbl, 1, 400);
      EXCEPTION WHEN OTHERS THEN
        l_bad := l_bad + 1;
        add_err(l_errs, i, l_key, clean_err(SQLERRM));
      END;
    END LOOP;
    IF l_bad > 0 OR l_its.COUNT = 0 THEN
      IF l_its.COUNT = 0 AND l_bad = 0 THEN add_err(l_errs, 0, NULL, 'لا توجد أرصدة لترحيلها في الملف'); l_bad := 1; END IF;
      add_err(l_errs, 0, NULL, 'لم يرحل شيء: صحح الأخطاء أعلاه وأعد استيراد الملف كاملاً');
      RETURN end_job(l_job, l_type, 0, l_bad, l_errs);
    END IF;
    SAVEPOINT opening_party;
    BEGIN
      l_batch := new_batch(p_scope, p_date, p_file);
      FOR k IN 1 .. l_its.COUNT LOOP
        -- العميل مدين بالرصيد الموجب؛ المورد دائن بالرصيد الموجب
        add_gl(l_lines, l_its(k).ctl, CASE p_scope WHEN 'AR' THEN l_its(k).amt ELSE -l_its(k).amt END, NULL, l_its(k).party, l_its(k).txt);
        l_net := l_net + CASE p_scope WHEN 'AR' THEN l_its(k).amt ELSE -l_its(k).amt END;
        INSERT INTO gl_opening_line (company_id, currency_code, exchange_rate, batch_id, line_no, source_account, account_id,
                                     debit_amount, credit_amount, debit_func, credit_func, party_id)
        VALUES (company, NOONA_GL_PKG.ledger_currency, 1, l_batch, k, l_its(k).doc, l_its(k).ctl,
                CASE WHEN (p_scope = 'AR') = (l_its(k).amt > 0) THEN ABS(l_its(k).amt) ELSE 0 END,
                CASE WHEN (p_scope = 'AR') = (l_its(k).amt > 0) THEN 0 ELSE ABS(l_its(k).amt) END,
                CASE WHEN (p_scope = 'AR') = (l_its(k).amt > 0) THEN ABS(l_its(k).amt) ELSE 0 END,
                CASE WHEN (p_scope = 'AR') = (l_its(k).amt > 0) THEN 0 ELSE ABS(l_its(k).amt) END, l_its(k).party);
      END LOOP;
      add_gl(l_lines, opening_account, -l_net, NULL, NULL, 'مقابل الأرصدة الافتتاحية ل' || scope_label(p_scope));
      l_j := post_batch(l_batch, p_date, 'الأرصدة الافتتاحية ل' || scope_label(p_scope) || ' في ' || TO_CHAR(p_date, 'YYYY-MM-DD'), l_lines);
      FOR k IN 1 .. l_its.COUNT LOOP
        IF p_scope = 'AR' THEN
          INSERT INTO ar_open_item (company_id, source_entity_type, source_entity_id, currency_code, exchange_rate, customer_account_id, item_type,
                                    doc_no, doc_date, due_date, installment_no, original_amount, open_amount, original_func, open_func,
                                    gl_journal_id, status_code)
          VALUES (company, 'GL_OPENING_BATCH', l_batch, NOONA_GL_PKG.ledger_currency, 1, l_its(k).acc,
                  CASE WHEN l_its(k).amt > 0 THEN 'INVOICE' ELSE 'CREDIT_NOTE' END, l_its(k).doc, l_its(k).dt, l_its(k).due, 1,
                  ABS(l_its(k).amt), ABS(l_its(k).amt), ABS(l_its(k).amt), ABS(l_its(k).amt), l_j, 'OPEN');
        ELSE
          INSERT INTO ap_open_item (company_id, currency_code, exchange_rate, supplier_account_id, item_type, doc_no, doc_date, due_date,
                                    installment_no, original_amount, open_amount, original_func, open_func, status_code)
          VALUES (company, NOONA_GL_PKG.ledger_currency, 1, l_its(k).acc, CASE WHEN l_its(k).amt > 0 THEN 'INVOICE' ELSE 'CREDIT_MEMO' END,
                  l_its(k).doc, l_its(k).dt, l_its(k).due, 1, ABS(l_its(k).amt), ABS(l_its(k).amt), ABS(l_its(k).amt), ABS(l_its(k).amt), 'OPEN');
        END IF;
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO opening_party;
      add_err(l_errs, 0, NULL, 'تعذر الترحيل: ' || clean_err(SQLERRM));
      RETURN end_job(l_job, l_type, 0, l_its.COUNT, l_errs);
    END;
    RETURN end_job(l_job, l_type, l_its.COUNT, 0, l_errs, l_batch);
  END import_opening_party;

  -- ---------------------------------------------------------------- أرصدة المخزون
  FUNCTION import_opening_stock(p_date DATE, p_file VARCHAR2, p_rows t_rows, p_map t_map) RETURN NUMBER IS
    TYPE t_docs IS TABLE OF JSON_ARRAY_T INDEX BY PLS_INTEGER;
    l_job   NUMBER;
    l_errs  JSON_ARRAY_T := JSON_ARRAY_T();
    l_docs  t_docs;
    l_ln    JSON_OBJECT_T;
    l_d     JSON_OBJECT_T;
    l_key   VARCHAR2(200);
    l_item  inv_item%ROWTYPE;
    l_wh    NUMBER;
    l_whk   VARCHAR2(200);
    l_q     NUMBER;
    l_c     NUMBER;
    l_x     DATE;
    l_bad   PLS_INTEGER := 0;
    l_ok    PLS_INTEGER := 0;
    l_batch NUMBER;
    l_txn   NUMBER;
    l_w     PLS_INTEGER;
    l_def   NUMBER := NOONA_INV_PKG.default_warehouse;
    l_n     NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert((p_map.EXISTS('no') OR p_map.EXISTS('barcode')) AND p_map.EXISTS('qty'), 'NOONA-CON-061',
      'الأعمدة المطلوبة: رقم الصنف أو الباركود (item) والكمية (qty)، والتكلفة (cost) والمستودع (warehouse) اختياريان',
      'Header must include item and qty');
    l_job := start_job('OPENING_STOCK', p_file, p_rows.COUNT - 1);
    FOR i IN 2 .. p_rows.COUNT LOOP
      l_key := NVL(col(p_rows(i), p_map, 'no'), col(p_rows(i), p_map, 'barcode'));
      BEGIN
        l_q := to_num(col(p_rows(i), p_map, 'qty'));
        CONTINUE WHEN l_key IS NULL AND NVL(l_q, 0) = 0;
        NOONA_CORE_PKG.assert(l_key IS NOT NULL, 'NOONA-CON-060', 'رقم الصنف أو الباركود فارغ', 'Item is empty');
        SELECT MIN(id) INTO l_n FROM inv_item WHERE UPPER(item_no) = UPPER(l_key);
        IF l_n IS NULL THEN
          SELECT MIN(item_id) INTO l_n FROM inv_item_barcode WHERE barcode = l_key;
        END IF;
        NOONA_CORE_PKG.assert(l_n IS NOT NULL, 'NOONA-CON-062', 'الصنف غير موجود: ' || l_key || ' (استورد الأصناف أولاً)', 'Item not found');
        SELECT * INTO l_item FROM inv_item WHERE id = l_n;
        CONTINUE WHEN NVL(l_q, 0) = 0;
        NOONA_CORE_PKG.assert(l_q > 0, 'NOONA-CON-063', 'الكمية الافتتاحية موجبة', 'Opening quantity must be positive');
        NOONA_CORE_PKG.assert(l_item.item_type NOT IN ('SERVICE', 'NON_STOCK'), 'NOONA-CON-064', 'الصنف خدمة وليس مخزنياً', 'Not a stock item');
        l_c := NVL(to_num(col(p_rows(i), p_map, 'cost')), 0);
        NOONA_CORE_PKG.assert(l_c >= 0, 'NOONA-CON-065', 'التكلفة لا تكون سالبة', 'Cost cannot be negative');
        l_whk := col(p_rows(i), p_map, 'wh');
        IF l_whk IS NULL THEN
          l_wh := l_def;
        ELSE
          SELECT MIN(id) INTO l_wh FROM inv_warehouse WHERE company_id = company AND (UPPER(code) = UPPER(l_whk) OR name_ar = l_whk);
        END IF;
        NOONA_CORE_PKG.assert(l_wh IS NOT NULL, 'NOONA-CON-066', 'المستودع غير موجود: ' || NVL(l_whk, '(الافتراضي)'), 'Warehouse not found');
        l_x := to_dt(col(p_rows(i), p_map, 'expiry'));
        l_ln := JSON_OBJECT_T();
        l_ln.put('i', l_item.id); l_ln.put('q', l_q); l_ln.put('c', l_c);
        IF col(p_rows(i), p_map, 'lot') IS NOT NULL THEN l_ln.put('lot', col(p_rows(i), p_map, 'lot')); END IF;
        IF l_x IS NOT NULL THEN l_ln.put('exp', TO_CHAR(l_x, 'YYYY-MM-DD')); END IF;
        IF NOT l_docs.EXISTS(l_wh) THEN l_docs(l_wh) := JSON_ARRAY_T(); END IF;
        l_docs(l_wh).append(l_ln);
        l_ok := l_ok + 1;
      EXCEPTION WHEN OTHERS THEN
        l_bad := l_bad + 1;
        add_err(l_errs, i, l_key, clean_err(SQLERRM));
      END;
    END LOOP;
    IF l_bad > 0 OR l_ok = 0 THEN
      IF l_ok = 0 AND l_bad = 0 THEN add_err(l_errs, 0, NULL, 'لا توجد كميات لترحيلها في الملف'); l_bad := 1; END IF;
      add_err(l_errs, 0, NULL, 'لم يرحل شيء: صحح الأخطاء أعلاه وأعد استيراد الملف كاملاً');
      RETURN end_job(l_job, 'OPENING_STOCK', 0, l_bad, l_errs);
    END IF;
    SAVEPOINT opening_stock;
    BEGIN
      l_batch := new_batch('INV', p_date, p_file);
      l_w := l_docs.FIRST;
      WHILE l_w IS NOT NULL LOOP
        l_d := JSON_OBJECT_T();
        l_d.put('type', 'OPENING'); l_d.put('date', TO_CHAR(p_date, 'YYYY-MM-DD')); l_d.put('wh', l_w);
        l_d.put('reason', 'OPENING'); l_d.put('action', 'POST'); l_d.put('lines', l_docs(l_w));
        l_txn := NOONA_INV_PKG.save_stock_doc(l_d.to_clob);
        UPDATE inv_transaction SET source_entity_type = 'GL_OPENING_BATCH', source_entity_id = l_batch WHERE id = l_txn;
        l_w := l_docs.NEXT(l_w);
      END LOOP;
      UPDATE gl_opening_batch SET status_code = 'POSTED' WHERE id = l_batch;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO opening_stock;
      add_err(l_errs, 0, NULL, 'تعذر الترحيل: ' || clean_err(SQLERRM));
      RETURN end_job(l_job, 'OPENING_STOCK', 0, l_ok, l_errs);
    END;
    RETURN end_job(l_job, 'OPENING_STOCK', l_ok, 0, l_errs, l_batch);
  END import_opening_stock;

  -- ---------------------------------------------------------------- الموظفون
  -- كل صف موظف مستقل (الخطأ لا يوقف الباقي): الهوية والجنسية والتعيين والوظيفة والفرع ومركز التكلفة والآيبان والراتب والبدلات
  FUNCTION import_employees(p_file VARCHAR2, p_rows t_rows, p_map t_map) RETURN NUMBER IS
    l_job  NUMBER;
    l_errs JSON_ARRAY_T := JSON_ARRAY_T();
    l_o    JSON_OBJECT_T;
    l_s    JSON_OBJECT_T;
    l_r    t_row;
    l_name VARCHAR2(400);
    l_v    VARCHAR2(400);
    l_id   NUMBER;
    l_ok   PLS_INTEGER := 0;
    l_bad  PLS_INTEGER := 0;
    PROCEDURE put_s(p_key VARCHAR2, p_col VARCHAR2) IS
      l VARCHAR2(400) := col(l_r, p_map, p_col);
    BEGIN
      IF l IS NOT NULL THEN l_o.put(p_key, l); END IF;
    END put_s;
    PROCEDURE put_d(p_key VARCHAR2, p_col VARCHAR2) IS
      l DATE := to_dt(col(l_r, p_map, p_col));
    BEGIN
      IF l IS NOT NULL THEN l_o.put(p_key, TO_CHAR(l, 'YYYY-MM-DD')); END IF;
    END put_d;
    PROCEDURE put_m(p_code VARCHAR2, p_col VARCHAR2) IS
      l NUMBER := to_num(col(l_r, p_map, p_col));
    BEGIN
      IF NVL(l, 0) > 0 THEN l_s.put(p_code, l); END IF;
    END put_m;
  BEGIN
    guard('API_IMPORT_JOB.CREATE');
    guard('HR_EMPLOYEE.CREATE');
    NOONA_CORE_PKG.assert(p_map.EXISTS('name'), 'NOONA-CON-070', 'عمود اسم الموظف (name) مطلوب في سطر العناوين', 'Header must include name');
    l_job := start_job('EMPLOYEES', p_file, p_rows.COUNT - 1);
    FOR i IN 2 .. p_rows.COUNT LOOP
      l_r := p_rows(i);
      l_name := col(l_r, p_map, 'name');
      SAVEPOINT import_emp;
      BEGIN
        NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-CON-010', 'الاسم فارغ', 'Name is empty');
        l_o := JSON_OBJECT_T(); l_s := JSON_OBJECT_T();
        l_o.put('name_ar', l_name);
        put_s('name_en', 'nameEn'); put_s('national_id', 'nid'); put_s('mobile', 'phone'); put_s('email', 'email');
        put_s('job_title', 'job'); put_s('iban', 'iban'); put_s('gosi_no', 'gosi');
        put_d('hire_date', 'hire'); put_d('birth_date', 'birth'); put_d('id_expiry', 'idexpiry');
        l_v := UPPER(REPLACE(col(l_r, p_map, 'nationality'), ' '));
        IF l_v IS NOT NULL THEN
          l_v := CASE WHEN l_v IN ('سعودي', 'سعودية', 'SAUDI', 'السعودية') THEN 'SA' WHEN l_v IN ('مصري', 'مصرية', 'EGYPTIAN') THEN 'EG'
                      WHEN l_v IN ('سوداني', 'سودانية', 'SUDANESE') THEN 'SD' WHEN l_v IN ('أردني', 'اردني', 'JORDANIAN') THEN 'JO'
                      WHEN l_v IN ('يمني', 'YEMENI') THEN 'YE' WHEN l_v IN ('هندي', 'INDIAN') THEN 'IN' WHEN l_v IN ('باكستاني', 'PAKISTANI') THEN 'PK'
                      WHEN l_v IN ('فلبيني', 'FILIPINO') THEN 'PH' WHEN l_v IN ('إماراتي', 'اماراتي', 'EMIRATI') THEN 'AE' ELSE l_v END;
          NOONA_CORE_PKG.assert(REGEXP_LIKE(l_v, '^[A-Z]{2}$'), 'NOONA-CON-071', 'الجنسية برمز الدولة من حرفين (SA، EG، SD...): ' || l_v,
                                'Nationality must be a 2-letter country code');
          l_o.put('nationality', l_v);
        END IF;
        l_v := UPPER(TRIM(col(l_r, p_map, 'gender')));
        IF l_v IS NOT NULL THEN
          l_v := CASE WHEN l_v IN ('M', 'MALE', 'ذكر', 'رجل') THEN 'M' WHEN l_v IN ('F', 'FEMALE', 'أنثى', 'انثى', 'امرأة') THEN 'F' END;
          NOONA_CORE_PKG.assert(l_v IS NOT NULL, 'NOONA-CON-072', 'الجنس: ذكر أو أنثى', 'Gender must be male or female');
          l_o.put('gender', l_v);
        END IF;
        l_v := col(l_r, p_map, 'branch');
        IF l_v IS NOT NULL THEN
          SELECT MIN(id) INTO l_id FROM org_branch WHERE company_id = company AND (UPPER(code) = UPPER(l_v) OR name_ar = l_v);
          NOONA_CORE_PKG.assert(l_id IS NOT NULL, 'NOONA-CON-073', 'الفرع غير موجود: ' || l_v, 'Branch not found');
          l_o.put('branch', l_id);
        END IF;
        l_v := col(l_r, p_map, 'cc');
        IF l_v IS NOT NULL THEN
          SELECT MIN(id) INTO l_id FROM gl_cost_center WHERE company_id = company AND (UPPER(code) = UPPER(l_v) OR name_ar = l_v);
          NOONA_CORE_PKG.assert(l_id IS NOT NULL, 'NOONA-CON-050', 'مركز التكلفة غير موجود: ' || l_v, 'Cost center not found');
          l_o.put('cost_center', l_id);
        END IF;
        IF to_num(col(l_r, p_map, 'leave')) IS NOT NULL THEN l_o.put('leave_days', to_num(col(l_r, p_map, 'leave'))); END IF;
        put_m('BASIC', 'basic'); put_m('HOUSING', 'housing'); put_m('TRANSPORT', 'transport'); put_m('OTHER_ALLOW', 'other');
        IF l_s.get_size > 0 THEN l_o.put('salary', l_s); END IF;
        l_id := NOONA_HR_PKG.save_employee(l_o.to_clob);
        l_ok := l_ok + 1;
      EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO import_emp;
        l_bad := l_bad + 1;
        add_err(l_errs, i, l_name, clean_err(SQLERRM));
      END;
    END LOOP;
    RETURN end_job(l_job, 'EMPLOYEES', l_ok, l_bad, l_errs);
  END import_employees;

  FUNCTION import_opening(p_type VARCHAR2, p_date DATE, p_file VARCHAR2, p_csv CLOB) RETURN NUMBER IS
    l_rows t_rows;
    l_map  t_map;
  BEGIN
    guard('API_IMPORT_JOB.CREATE');
    guard('GL_OPENING_BATCH.CREATE');
    NOONA_CORE_PKG.assert(p_date IS NOT NULL, 'NOONA-CON-039', 'تاريخ الأرصدة الافتتاحية إلزامي (أول يوم تبدأ فيه العمل على النظام)',
                          'Opening date is required');
    NOONA_CORE_PKG.assert(NOONA_GL_PKG.primary_ledger IS NOT NULL, 'NOONA-CON-020', 'جهز الأستاذ العام للشركة أولاً (دليل الحسابات)',
                          'Set up the general ledger first');
    l_rows := parse_csv(p_csv);
    NOONA_CORE_PKG.assert(l_rows.COUNT >= 2, 'NOONA-CON-002', 'الملف فارغ أو بلا صفوف بيانات بعد سطر العناوين', 'File has no data rows');
    NOONA_CORE_PKG.assert(l_rows.COUNT <= 5001, 'NOONA-CON-003', 'الحد الأقصى 5000 صف في الملف الواحد', 'Maximum 5000 rows per file');
    l_map := header_map(l_rows(1));
    RETURN CASE p_type
             WHEN 'OPENING_GL' THEN import_opening_gl(TRUNC(p_date), p_file, l_rows, l_map)
             WHEN 'OPENING_AR' THEN import_opening_party('AR', TRUNC(p_date), p_file, l_rows, l_map)
             WHEN 'OPENING_AP' THEN import_opening_party('AP', TRUNC(p_date), p_file, l_rows, l_map)
             ELSE import_opening_stock(TRUNC(p_date), p_file, l_rows, l_map) END;
  END import_opening;

  -- إلغاء دفعة أرصدة افتتاحية (الحسابات والعملاء والموردين) بقيد عكسي، ما لم يسدد شيء من ذممها
  PROCEDURE cancel_opening(p_batch_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_b  gl_opening_batch%ROWTYPE;
    l_n  NUMBER;
    l_dt DATE;
    l_x  NUMBER;
  BEGIN
    guard('GL_OPENING_BATCH.CANCEL');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-CON-080', 'سبب الإلغاء إلزامي', 'Reason is required');
    SELECT * INTO l_b FROM gl_opening_batch WHERE id = p_batch_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l_b.status_code = 'POSTED', 'NOONA-CON-081', 'الدفعة ليست مرحلة', 'Batch is not posted');
    NOONA_CORE_PKG.assert(l_b.scope_code <> 'INV', 'NOONA-CON-082',
      'أرصدة المخزون المرحلة تصحح بمستند تسوية بالنقص أو الزيادة من المخزون', 'Stock openings are corrected with stock adjustments');
    IF l_b.scope_code = 'AR' THEN
      SELECT COUNT(*) INTO l_n FROM ar_open_item WHERE source_entity_type = 'GL_OPENING_BATCH' AND source_entity_id = p_batch_id
         AND (open_amount <> original_amount OR status_code NOT IN ('OPEN', 'CANCELLED'));
    ELSIF l_b.scope_code = 'AP' THEN
      SELECT COUNT(*) INTO l_n FROM ap_open_item o JOIN gl_opening_line l ON l.batch_id = p_batch_id AND l.source_account = o.doc_no
                                                  AND o.supplier_account_id = (SELECT MIN(a.id) FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id
                                                                                WHERE s.party_id = l.party_id AND a.company_id = o.company_id)
       WHERE o.invoice_id IS NULL AND o.company_id = company AND (o.open_amount <> o.original_amount OR o.status_code NOT IN ('OPEN', 'CANCELLED'));
    ELSE
      l_n := 0;
    END IF;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-CON-083', 'سدد أو حصل جزء من ذمم هذه الدفعة: ألغ التحصيل/السداد أولاً', 'Some open items were settled');
    SELECT doc_date INTO l_dt FROM gl_journal WHERE id = l_b.journal_id;
    l_x := NOONA_ACE_PKG.reverse_source('GL_OPENING_BATCH', p_batch_id, l_dt, p_reason);
    IF l_b.scope_code = 'AR' THEN
      UPDATE ar_open_item SET status_code = 'CANCELLED', open_amount = 0, open_func = 0
       WHERE source_entity_type = 'GL_OPENING_BATCH' AND source_entity_id = p_batch_id;
    ELSIF l_b.scope_code = 'AP' THEN
      UPDATE ap_open_item o SET status_code = 'CANCELLED', open_amount = 0, open_func = 0
       WHERE o.invoice_id IS NULL AND o.company_id = company
         AND EXISTS (SELECT 1 FROM gl_opening_line l JOIN ap_supplier s ON s.party_id = l.party_id
                       JOIN ap_supplier_account a ON a.supplier_id = s.id AND a.id = o.supplier_account_id
                      WHERE l.batch_id = p_batch_id AND l.source_account = o.doc_no);
    END IF;
    UPDATE gl_opening_batch SET status_code = 'CANCELLED' WHERE id = p_batch_id;
    NOONA_AUDIT_PKG.log_event('POSTING', 'GL_OPENING_BATCH', p_batch_id, 'CANCEL', 'SUCCESS', p_reason => p_reason);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-CON-084', 'الدفعة غير موجودة', 'Batch not found');
  END cancel_opening;

  -- ---------------------------------------------------------------- معالج بدء التشغيل
  FUNCTION onboarding_html(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h    CLOB;
    l_coa  NUMBER := NOONA_GL_PKG.primary_coa;
    l_led  NUMBER := NOONA_GL_PKG.primary_ledger;
    l_ob   NUMBER;
    l_n    NUMBER;
    l_v    NUMBER;
    l_dt   DATE;
    l_step PLS_INTEGER := 0;
    FUNCTION bal(p_acc NUMBER) RETURN NUMBER IS
      l NUMBER;
    BEGIN
      SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l
        FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
       WHERE j.ledger_id = l_led AND j.status_code IN ('POSTED', 'REVERSED') AND l.account_id = p_acc AND j.doc_date <= NVL(l_dt, SYSDATE);
      RETURN l;
    END bal;
    -- APEX:<page>:<item> رابط بمجموع اختباري (الصفحات محمية ضد تعديل الروابط)، أو قالب نصي فيه #TYPE#
    FUNCTION link_for(p_type VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      IF p_link LIKE 'APEX:%' THEN
        RETURN apex_page.get_url(p_page => TO_NUMBER(REGEXP_SUBSTR(p_link, '[^:]+', 1, 2)), p_items => REGEXP_SUBSTR(p_link, '[^:]+', 1, 3),
                                 p_values => p_type);
      END IF;
      RETURN REPLACE(p_link, '#TYPE#', p_type);
    END link_for;
    PROCEDURE add_row(p_title VARCHAR2, p_type VARCHAR2, p_count VARCHAR2, p_done BOOLEAN, p_hint VARCHAR2) IS
    BEGIN
      l_step := l_step + 1;
      l_h := l_h || ('<tr><td class="n">' || l_step || '</td><td>' || esc(p_title) || '</td><td class="n">' || p_count || '</td><td><span class="nn-badge '
          || CASE WHEN p_done THEN 'is-success">تم' ELSE 'is-muted">لم يبدأ' END || '</span></td><td class="nn-hint">' || esc(p_hint) || '</td><td>'
          || CASE WHEN p_link IS NOT NULL AND p_type IS NOT NULL THEN '<a class="t-Button t-Button--small" href="' || link_for(p_type) || '">استيراد</a>' END
          || '</td></tr>');
    END add_row;
  BEGIN
    guard('API_IMPORT_JOB.VIEW');
    l_h := '<table class="nn-prj-t nn-onb"><thead><tr><th>#</th><th>الخطوة</th><th class="n">العدد / القيمة</th><th>الحالة</th><th>ملاحظة</th><th></th></tr></thead><tbody>';
    SELECT COUNT(*) INTO l_n FROM gl_account WHERE coa_id = l_coa;
    add_row('شجرة الحسابات', 'ACCOUNTS', l_n, l_n > 0, CASE WHEN l_coa IS NULL THEN 'جهز الأستاذ العام للشركة أولاً'
                                                       ELSE 'الدليل القياسي جاهز؛ أضف حساباتك أو استورد دليل نظامك السابق' END);
    SELECT COUNT(*) INTO l_n FROM ar_customer_account WHERE company_id = company;
    add_row('العملاء', 'CUSTOMERS', l_n, l_n > 0, 'الاسم والجوال والرقم الضريبي والسجل وشروط الدفع');
    SELECT COUNT(*) INTO l_n FROM ap_supplier_account WHERE company_id = company;
    add_row('الموردون', 'SUPPLIERS', l_n, l_n > 0, 'نفس أعمدة العملاء');
    SELECT COUNT(*) INTO l_n FROM inv_item;
    add_row('الأصناف', 'ITEMS', l_n, l_n > 0, 'الرقم والاسم والنوع والسعر والباركود والفئة');
    SELECT COUNT(*) INTO l_n FROM hr_employment WHERE company_id = company AND status_code <> 'TERMINATED';
    add_row('الموظفون', 'EMPLOYEES', l_n, l_n > 0, 'الهوية والجنسية والتعيين والراتب والبدلات والآيبان');
    FOR s IN (SELECT 'GL' sc, 'OPENING_GL' t, 'أرصدة الحسابات والنقدية والبنوك' ttl,
                     'من ميزان المراجعة في تاريخ البدء؛ حسابات العملاء والموردين والمخزون تأتي من ملفاتها' h FROM dual
              UNION ALL SELECT 'AR', 'OPENING_AR', 'أرصدة العملاء (الفواتير المفتوحة)', 'فاتورة مفتوحة لكل سطر تحصل لاحقاً بالتحصيل العادي' FROM dual
              UNION ALL SELECT 'AP', 'OPENING_AP', 'أرصدة الموردين (الفواتير المفتوحة)', 'فاتورة مستحقة لكل سطر تسدد لاحقاً بالسداد العادي' FROM dual
              UNION ALL SELECT 'INV', 'OPENING_STOCK', 'أرصدة المخزون (الكمية والتكلفة)', 'لكل صنف ومستودع، مع التشغيلة والصلاحية إن وجدت' FROM dual) LOOP
      SELECT COUNT(*), MIN(j.doc_date) INTO l_n, l_dt FROM gl_opening_batch b LEFT JOIN gl_journal j ON j.id = b.journal_id
       WHERE b.company_id = company AND b.scope_code = s.sc AND b.status_code = 'POSTED';
      IF s.sc = 'INV' THEN
        SELECT NVL(SUM(l.total_cost), 0) INTO l_v FROM inv_transaction t JOIN inv_transaction_line l ON l.transaction_id = t.id
         WHERE t.company_id = company AND t.source_entity_type = 'GL_OPENING_BATCH' AND t.status_code = 'POSTED';
      ELSE
        SELECT NVL(SUM(l.debit_amount + l.credit_amount), 0) INTO l_v FROM gl_opening_line l JOIN gl_opening_batch b ON b.id = l.batch_id
         WHERE b.company_id = company AND b.scope_code = s.sc AND b.status_code = 'POSTED'
           AND (s.sc <> 'GL' OR l.account_id NOT IN (SELECT id FROM gl_account WHERE is_control = 'Y'));
      END IF;
      add_row(s.ttl, s.t, CASE WHEN l_n > 0 THEN fmt(l_v) ELSE '-' END, l_n > 0, s.h);
    END LOOP;
    l_h := l_h || ('</tbody></table>');
    -- المطابقة: حساب الأرصدة الافتتاحية يصفر بعد اكتمال الملفات، وحسابات المراقبة تطابق ميزان المراجعة
    IF l_led IS NOT NULL THEN
      SELECT MIN(j.doc_date) INTO l_dt FROM gl_opening_batch b JOIN gl_journal j ON j.id = b.journal_id
       WHERE b.company_id = company AND b.status_code = 'POSTED';
      l_ob := NOONA_INV_PKG.acc_id('3105');
      IF l_ob IS NOT NULL AND l_dt IS NOT NULL THEN
        l_v := bal(l_ob);
        l_h := l_h || ('<h3 class="nn-onb-h">المطابقة في ' || TO_CHAR(l_dt, 'YYYY-MM-DD') || '</h3><table class="nn-prj-t"><thead><tr><th>الحساب</th>'
            || '<th class="n">حسب ميزان المراجعة المستورد</th><th class="n">المرحل من الملفات التفصيلية</th><th class="n">الفرق</th></tr></thead><tbody>');
        FOR c IN (SELECT a.id, a.account_code, a.name_ar, SUM(l.debit_amount - l.credit_amount) expd
                    FROM gl_opening_line l JOIN gl_opening_batch b ON b.id = l.batch_id JOIN gl_account a ON a.id = l.account_id
                   WHERE b.company_id = company AND b.scope_code = 'GL' AND b.status_code = 'POSTED' AND a.is_control = 'Y'
                   GROUP BY a.id, a.account_code, a.name_ar ORDER BY a.account_code) LOOP
          l_n := bal(c.id);
          l_h := l_h || ('<tr><td>' || esc(c.account_code || ' ' || c.name_ar) || '</td><td class="n">' || fmt(c.expd) || '</td><td class="n">' || fmt(l_n)
              || '</td><td class="n' || CASE WHEN ROUND(c.expd - l_n, 2) <> 0 THEN ' is-danger' END || '">' || fmt(c.expd - l_n) || '</td></tr>');
        END LOOP;
        l_h := l_h || ('<tr class="nn-rpt-total"><td>3105 الأرصدة الافتتاحية</td><td class="n">0.00</td><td class="n">' || fmt(l_v) || '</td><td class="n'
            || CASE WHEN ROUND(l_v, 2) <> 0 THEN ' is-danger' END || '">' || fmt(-l_v) || '</td></tr></tbody></table>'
            || '<p class="nn-hint">' || CASE WHEN ROUND(l_v, 2) = 0 THEN 'الأرصدة مكتملة ومتطابقة: رصيد حساب الأرصدة الافتتاحية صفر.'
               ELSE 'رصيد حساب الأرصدة الافتتاحية (3105) يصبح صفراً بعد استيراد كل الملفات التفصيلية والأصول الثابتة؛ '
                    || 'إن بقي فرق فهو اختلاف بين ميزان المراجعة والأرصدة التفصيلية (أو أصول لم تسجل بعد في الأصول الثابتة برصيد افتتاحي).' END || '</p>');
      END IF;
    END IF;
    RETURN l_h;
  END onboarding_html;

  FUNCTION openings_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('API_IMPORT_JOB.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الدفعة</th><th>النوع</th><th>التاريخ</th><th>الملف</th><th class="n">الأسطر</th>'
        || '<th class="n">الإجمالي</th><th>القيد</th><th>الحالة</th></tr></thead><tbody>';
    FOR b IN (SELECT b.*, j.doc_no jno,
                     NVL(j.doc_date, (SELECT MIN(t.doc_date) FROM inv_transaction t WHERE t.source_entity_type = 'GL_OPENING_BATCH' AND t.source_entity_id = b.id)) jdt,
                     (SELECT COUNT(*) FROM gl_opening_line l WHERE l.batch_id = b.id)
                     + (SELECT COUNT(*) FROM inv_transaction t JOIN inv_transaction_line tl ON tl.transaction_id = t.id
                         WHERE t.source_entity_type = 'GL_OPENING_BATCH' AND t.source_entity_id = b.id) ln,
                     (SELECT SUM(l.debit_amount) FROM gl_opening_line l WHERE l.batch_id = b.id) tot,
                     (SELECT SUM(tl.total_cost) FROM inv_transaction t JOIN inv_transaction_line tl ON tl.transaction_id = t.id
                       WHERE t.source_entity_type = 'GL_OPENING_BATCH' AND t.source_entity_id = b.id) inv
                FROM gl_opening_batch b LEFT JOIN gl_journal j ON j.id = b.journal_id
               WHERE b.company_id = company ORDER BY b.id DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || esc(b.batch_no) || '</td><td>' || esc(scope_label(b.scope_code)) || '</td><td>' || TO_CHAR(NVL(b.jdt, b.created_at), 'YYYY-MM-DD')
          || '</td><td>' || esc(b.source_system) || '</td><td class="n">' || b.ln || '</td><td class="n">' || fmt(NVL(b.tot, b.inv)) || '</td><td>'
          || esc(NVL(b.jno, CASE WHEN b.scope_code = 'INV' THEN 'مستند مخزون' END))
          || '</td><td><span class="nn-badge ' || CASE b.status_code WHEN 'POSTED' THEN 'is-success">مرحلة' WHEN 'CANCELLED' THEN 'is-muted">ملغاة'
                                                   ELSE 'is-warning">' || b.status_code END || '</span></td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لم تستورد أرصدة افتتاحية بعد</div>'); END IF;
    RETURN l_h || ('</tbody></table>');
  END openings_html;

  FUNCTION import_csv(p_type IN VARCHAR2, p_file_name IN VARCHAR2, p_csv IN CLOB,
                      p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
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
    NOONA_CORE_PKG.assert(p_type IN ('CUSTOMERS', 'SUPPLIERS', 'ITEMS', 'ACCOUNTS', 'EMPLOYEES', 'OPENING_GL', 'OPENING_AR', 'OPENING_AP', 'OPENING_STOCK'),
                          'NOONA-CON-001', 'نوع استيراد غير مدعوم', 'Unsupported import type');
    IF p_type = 'ACCOUNTS' THEN
      RETURN import_accounts(p_file_name, p_csv);
    ELSIF p_type LIKE 'OPENING%' THEN
      RETURN import_opening(p_type, p_date, p_file_name, p_csv);
    ELSIF p_type = 'EMPLOYEES' THEN
      l_rows := parse_csv(p_csv);
      NOONA_CORE_PKG.assert(l_rows.COUNT >= 2, 'NOONA-CON-002', 'الملف فارغ أو بلا صفوف بيانات بعد سطر العناوين', 'File has no data rows');
      NOONA_CORE_PKG.assert(l_rows.COUNT <= 5001, 'NOONA-CON-003', 'الحد الأقصى 5000 صف في الملف الواحد', 'Maximum 5000 rows per file');
      RETURN import_employees(p_file_name, l_rows, header_map(l_rows(1)));
    END IF;
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
