-- =============================================================================
-- NOONA PLUS ERP | NOONA_EINV_PKG - الفوترة الإلكترونية (المرحلة الثانية - الربط والتكامل مع الهيئة)
--   * إعداد لكل شركة/فرع: المحول (SIMULATOR محاكي داخلي، REST خدمة توقيع/بوابة خارجية)، نمط التكامل، الجهاز، الشهادة
--   * فاتورة UBL 2.1 لكل فاتورة مبيعات مرحلة: 388 فاتورة، 381 إشعار دائن، 383 إشعار مدين؛ 0100000 ضريبية، 0200000 مبسطة
--   * سلسلة الفواتير: العداد التسلسلي ICV، تجزئة SHA-256 للفاتورة (Base64)، تجزئة الفاتورة السابقة PIH، UUID
--   * رمز QR بالوسوم 1-5 + التجزئة (6) + التوقيع والمفتاح العام (7، 8) عند توفرها من خدمة التوقيع
--   * طابور الإرسال: الاعتماد (Clearance) للضريبية والإبلاغ (Reporting) للمبسطة خلال 24 ساعة، إعادة المحاولة بفاصل متزايد
--   التوقيع الرقمي ECDSA وشهادة CSID تتم في خدمة توقيع خارجية (ENDPOINT_REF)؛ المحاكي يحاكي ردود الهيئة للاختبار
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_EINV_PKG AUTHID DEFINER AS
  -- تجزئة الفاتورة السابقة للفاتورة الأولى (قيمة الهيئة الثابتة)
  c_first_pih CONSTANT VARCHAR2(100) := 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ==';

  FUNCTION company RETURN NUMBER;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION seller_vat RETURN VARCHAR2;
  FUNCTION seller_name RETURN VARCHAR2;
  FUNCTION type_code(p_doc_type IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION new_uuid RETURN VARCHAR2;
  -- الإعداد الفعال للشركة (أو فرعها) ؛ NULL إن لم تفعل الفوترة الإلكترونية
  FUNCTION active_profile(p_branch_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- {"id","branch","adapter":"SIMULATOR|REST","mode":"CLEARANCE|REPORTING","device","certificate","endpoint","sandbox":"Y","status"}
  FUNCTION save_profile(p_doc IN CLOB) RETURN NUMBER;

  -- Base64 لتجزئة SHA-256 لنص
  FUNCTION sha256_b64(p_text IN CLOB) RETURN VARCHAR2;
  -- رمز QR بترميز TLV ثم Base64
  FUNCTION qr_tlv(p_seller IN VARCHAR2, p_vat IN VARCHAR2, p_at IN TIMESTAMP, p_total IN NUMBER, p_tax IN NUMBER,
                  p_hash IN VARCHAR2 DEFAULT NULL, p_signature IN VARCHAR2 DEFAULT NULL, p_public_key IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  -- فاتورة UBL 2.1 (بدون التوقيع)
  FUNCTION build_xml(p_invoice_id IN NUMBER, p_uuid IN VARCHAR2, p_icv IN NUMBER, p_pih IN VARCHAR2) RETURN CLOB;
  -- قواعد التحقق قبل الإرسال: يعيد مصفوفة JSON بالأخطاء ([] إن كانت سليمة)
  FUNCTION validate_invoice(p_invoice_id IN NUMBER) RETURN CLOB;

  -- يضع فاتورة مرحلة في الطابور (يعيد الإرسال)؛ يستدعى تلقائياً عند الترحيل إذا كان للشركة إعداد فعال
  FUNCTION queue_invoice(p_invoice_id IN NUMBER) RETURN NUMBER;
  PROCEDURE on_invoice_posted(p_invoice_id IN NUMBER);
  -- يرسل إرسالاً واحداً (لا يرفع خطأ الاتصال: يسجله ويجدول المحاولة)
  PROCEDURE submit(p_submission_id IN NUMBER);
  -- يعالج الطابور (للمهمة المجدولة): يعيد عدد المعالج
  FUNCTION process_queue(p_limit IN NUMBER DEFAULT 50) RETURN NUMBER;
  -- إعادة إرسال المرفوض بعد تصحيح البيانات: إرسال جديد بنفس العداد والسلسلة (UUID جديد)
  FUNCTION resubmit(p_submission_id IN NUMBER) RETURN NUMBER;
  -- رمز QR للطباعة: من الإرسال المعتمد إن وجد
  FUNCTION invoice_qr(p_invoice_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION summary_html RETURN CLOB;
  FUNCTION queue_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION submission_html(p_submission_id IN NUMBER) RETURN CLOB;
  FUNCTION profiles_html RETURN CLOB;
END NOONA_EINV_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_EINV_PKG AS

  c_ent CONSTANT VARCHAR2(30) := 'SAL_INVOICE';

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END ds;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  -- مبلغ في XML: نقطة عشرية وبدون فواصل
  FUNCTION am(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(ROUND(NVL(p, 0), 2), 'FM9999999999990.00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END am;
  FUNCTION qn(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(RTRIM(TO_CHAR(NVL(p, 0), 'FM9999999999990.000000', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END qn;
  FUNCTION x(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'), '''', '&apos;');
  END x;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN
    RETURN TO_NUMBER(p_o.get_string(p_k));
  END jn;

  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status WHEN 'DRAFT' THEN 'مسودة' WHEN 'VALIDATED' THEN 'تم التحقق' WHEN 'READY_TO_SUBMIT' THEN 'جاهز للإرسال'
      WHEN 'SUBMITTED' THEN 'مرسل' WHEN 'ACCEPTED' THEN 'مقبول (مبلغ)' WHEN 'CLEARED' THEN 'معتمد من الهيئة' WHEN 'REJECTED' THEN 'مرفوض'
      WHEN 'VALIDATION_FAILED' THEN 'فشل التحقق' WHEN 'SUBMISSION_FAILED' THEN 'فشل الإرسال' WHEN 'PENDING_RETRY' THEN 'بانتظار إعادة المحاولة'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'ONBOARDING' THEN 'قيد الربط' WHEN 'ACTIVE' THEN 'فعال' WHEN 'SUSPENDED' THEN 'موقوف' ELSE p_status END;
  END status_label;

  FUNCTION badge(p_status VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_status IN ('CLEARED', 'ACCEPTED', 'ACTIVE') THEN 'is-success'
                                            WHEN p_status IN ('REJECTED', 'VALIDATION_FAILED', 'SUBMISSION_FAILED', 'SUSPENDED') THEN 'is-danger'
                                            WHEN p_status IN ('CANCELLED') THEN 'is-muted' ELSE 'is-warning' END || '">' || esc(status_label(p_status)) || '</span>';
  END badge;

  -- ================================================================ الإعداد
  FUNCTION active_profile(p_branch_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN branch_id = p_branch_id THEN 0 ELSE 1 END, id) INTO l
      FROM loc_einvoice_profile
     WHERE company_id = company AND status_code IN ('ACTIVE', 'ONBOARDING') AND (branch_id IS NULL OR branch_id = p_branch_id);
    RETURN l;
  END active_profile;

  FUNCTION save_profile(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_ad   VARCHAR2(50) := NVL(UPPER(js(l_o, 'adapter')), 'SIMULATOR');
    l_mode VARCHAR2(30) := NVL(UPPER(js(l_o, 'mode')), 'CLEARANCE');
    l_st   VARCHAR2(30) := NVL(UPPER(js(l_o, 'status')), 'ACTIVE');
    l_ep   VARCHAR2(200) := js(l_o, 'endpoint');
    l_br   NUMBER := jn(l_o, 'branch');
    l_dev  VARCHAR2(200) := js(l_o, 'device');
    l_cert VARCHAR2(200) := js(l_o, 'certificate');
    l_sb   VARCHAR2(1) := NVL(js(l_o, 'sandbox'), 'Y');
    l_co   NUMBER := company;
    l_pack NUMBER;
  BEGIN
    guard('LOC_EINVOICE_PROFILE.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_ad IN ('SIMULATOR', 'REST'), 'NOONA-EINV-001', 'المحول: محاكي أو خدمة خارجية', 'Adapter must be SIMULATOR or REST');
    NOONA_CORE_PKG.assert(l_ad <> 'REST' OR l_ep LIKE 'http%', 'NOONA-EINV-002', 'أدخل عنوان خدمة التوقيع/البوابة (http/https)', 'Endpoint URL is required');
    SELECT MAX(country_pack_id) INTO l_pack FROM org_company WHERE id = l_co;
    NOONA_CORE_PKG.assert(l_pack IS NOT NULL, 'NOONA-EINV-003', 'طبق حزمة الدولة على الشركة أولاً', 'Apply the country pack first');
    IF l_id IS NULL THEN
      INSERT INTO loc_einvoice_profile (company_id, branch_id, country_pack_id, adapter_code, integration_mode, device_id, certificate_ref, endpoint_ref,
                                        is_sandbox, status_code)
      VALUES (l_co, l_br, l_pack, l_ad, l_mode, l_dev, l_cert, l_ep, l_sb, l_st)
      RETURNING id INTO l_id;
    ELSE
      UPDATE loc_einvoice_profile SET branch_id = l_br, adapter_code = l_ad, integration_mode = l_mode, device_id = l_dev,
                                      certificate_ref = l_cert, endpoint_ref = l_ep, is_sandbox = l_sb, status_code = l_st
       WHERE id = l_id AND company_id = l_co;
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'LOC_EINVOICE_PROFILE', l_id, 'SAVE', 'SUCCESS',
                              p_new_values => JSON_OBJECT('adapter' VALUE l_ad, 'mode' VALUE l_mode, 'status' VALUE l_st));
    RETURN l_id;
  END save_profile;

  -- ================================================================ التجزئة والرمز
  FUNCTION b64(p RAW) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(p)), CHR(13)), CHR(10));
  END b64;

  FUNCTION sha256_b64(p_text IN CLOB) RETURN VARCHAR2 IS
    l_b BLOB;
    l_h RAW(32);
  BEGIN
    l_b := APEX_UTIL.clob_to_blob(p_text, 'AL32UTF8');
    l_h := DBMS_CRYPTO.HASH(l_b, DBMS_CRYPTO.HASH_SH256);
    RETURN b64(l_h);
  END sha256_b64;

  FUNCTION qr_tlv(p_seller IN VARCHAR2, p_vat IN VARCHAR2, p_at IN TIMESTAMP, p_total IN NUMBER, p_tax IN NUMBER,
                  p_hash IN VARCHAR2 DEFAULT NULL, p_signature IN VARCHAR2 DEFAULT NULL, p_public_key IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    l_raw RAW(4000);
    PROCEDURE tlv(p_tag PLS_INTEGER, p_val VARCHAR2) IS
      l_v RAW(2000);
    BEGIN
      IF p_val IS NULL AND p_tag > 5 THEN RETURN; END IF;
      l_v := UTL_I18N.STRING_TO_RAW(NVL(p_val, ' '), 'AL32UTF8');
      l_raw := UTL_RAW.CONCAT(l_raw, UTL_RAW.CONCAT(HEXTORAW(LPAD(TRIM(TO_CHAR(p_tag, 'XX')), 2, '0')),
                                                    HEXTORAW(LPAD(TRIM(TO_CHAR(UTL_RAW.LENGTH(l_v), 'XX')), 2, '0')), l_v));
    END tlv;
  BEGIN
    tlv(1, p_seller);
    tlv(2, NVL(p_vat, '000000000000000'));
    tlv(3, TO_CHAR(SYS_EXTRACT_UTC(CAST(p_at AS TIMESTAMP WITH TIME ZONE)), 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));
    tlv(4, am(p_total));
    tlv(5, am(p_tax));
    tlv(6, p_hash);
    tlv(7, p_signature);
    tlv(8, p_public_key);
    RETURN b64(l_raw);
  END qr_tlv;

  -- ================================================================ بيانات الفاتورة
  FUNCTION seller_vat RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(r.reg_number) KEEP (DENSE_RANK FIRST ORDER BY r.is_primary DESC NULLS LAST, r.id) INTO l
      FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = company AND t.is_tax_registration = 'Y' AND r.status_code IN ('ACTIVE', 'EXPIRING');
    RETURN l;
  END seller_vat;

  FUNCTION seller_crn RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(r.reg_number) INTO l FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = company AND t.code LIKE '%\_CR' ESCAPE '\' AND r.status_code IN ('ACTIVE', 'EXPIRING');
    RETURN l;
  END seller_crn;

  FUNCTION seller_name RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT legal_name_ar INTO l FROM org_company WHERE id = company;
    RETURN l;
  END seller_name;

  FUNCTION type_code(p_doc_type IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_doc_type WHEN 'CREDIT_NOTE' THEN '381' WHEN 'DEBIT_NOTE' THEN '383' ELSE '388' END;
  END type_code;

  FUNCTION subtype_of(p_i sal_invoice%ROWTYPE) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_i.doc_type = 'SIMPLIFIED_INVOICE' OR TRIM(p_i.customer_tax_no_snapshot) IS NULL THEN '0200000' ELSE '0100000' END;
  END subtype_of;

  -- فئة الضريبة في الفاتورة الإلكترونية وسبب الإعفاء
  FUNCTION category(p_tax_code_id NUMBER, p_tax NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(NVL(einvoice_category, CASE tax_nature WHEN 'STANDARD' THEN 'S' WHEN 'ZERO_RATED' THEN 'Z' WHEN 'EXEMPT' THEN 'E' ELSE 'O' END))
      INTO l FROM loc_tax_code WHERE id = p_tax_code_id;
    RETURN NVL(SUBSTR(l, 1, 1), CASE WHEN p_tax <> 0 THEN 'S' ELSE 'O' END);
  END category;

  FUNCTION exemption(p_cat VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_cat WHEN 'Z' THEN '<cbc:TaxExemptionReasonCode>VATEX-SA-32</cbc:TaxExemptionReasonCode><cbc:TaxExemptionReason>Export of goods</cbc:TaxExemptionReason>'
                      WHEN 'E' THEN '<cbc:TaxExemptionReasonCode>VATEX-SA-29</cbc:TaxExemptionReasonCode><cbc:TaxExemptionReason>Financial services mentioned in Article 29 of the VAT Regulations</cbc:TaxExemptionReason>'
                      WHEN 'O' THEN '<cbc:TaxExemptionReasonCode>VATEX-SA-OOS</cbc:TaxExemptionReasonCode><cbc:TaxExemptionReason>Out of scope</cbc:TaxExemptionReason>' END;
  END exemption;

  FUNCTION get_invoice(p_id NUMBER) RETURN sal_invoice%ROWTYPE IS
    l sal_invoice%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM sal_invoice WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-EINV-010', 'الفاتورة غير موجودة', 'Invoice not found');
  END get_invoice;

  FUNCTION address_xml(p_company NUMBER, p_party NUMBER, p_fallback VARCHAR2, p_country VARCHAR2) RETURN VARCHAR2 IS
    l_a ref_address%ROWTYPE;
    l_city VARCHAR2(200);
  BEGIN
    BEGIN
      SELECT * INTO l_a FROM (
        SELECT * FROM ref_address
         WHERE ((p_party IS NOT NULL AND party_id = p_party) OR (p_party IS NULL AND company_id = p_company AND party_id IS NULL))
           AND NVL(effective_to, DATE '9999-12-31') >= TRUNC(SYSDATE)
         ORDER BY is_primary DESC, CASE address_type WHEN 'LEGAL' THEN 0 WHEN 'BILLING' THEN 1 ELSE 2 END, id)
       WHERE ROWNUM = 1;
      SELECT MAX(NVL(name_en, name_ar)) INTO l_city FROM ref_city WHERE id = l_a.city_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    RETURN '<cac:PostalAddress><cbc:StreetName>' || x(NVL(l_a.street, NVL(NVL(l_a.address_line_ar, p_fallback), '-'))) || '</cbc:StreetName>'
        || CASE WHEN l_a.building_no IS NOT NULL THEN '<cbc:BuildingNumber>' || x(l_a.building_no) || '</cbc:BuildingNumber>' END
        || CASE WHEN l_a.additional_no IS NOT NULL THEN '<cbc:PlotIdentification>' || x(l_a.additional_no) || '</cbc:PlotIdentification>' END
        || CASE WHEN l_a.district IS NOT NULL THEN '<cbc:CitySubdivisionName>' || x(l_a.district) || '</cbc:CitySubdivisionName>' END
        || '<cbc:CityName>' || x(NVL(l_city, '-')) || '</cbc:CityName>'
        || CASE WHEN l_a.postal_code IS NOT NULL THEN '<cbc:PostalZone>' || x(l_a.postal_code) || '</cbc:PostalZone>' END
        || '<cac:Country><cbc:IdentificationCode>' || x(NVL(l_a.country_code, p_country)) || '</cbc:IdentificationCode></cac:Country></cac:PostalAddress>';
  END address_xml;

  FUNCTION customer_party(p_i sal_invoice%ROWTYPE) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(c.party_id) INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id WHERE a.id = p_i.customer_account_id;
    RETURN l;
  END customer_party;

  FUNCTION build_xml(p_invoice_id IN NUMBER, p_uuid IN VARCHAR2, p_icv IN NUMBER, p_pih IN VARCHAR2) RETURN CLOB IS
    i      sal_invoice%ROWTYPE := get_invoice(p_invoice_id);
    l_x    CLOB;
    l_cc   VARCHAR2(2);
    l_cur  VARCHAR2(3) := i.currency_code;
    l_sub  VARCHAR2(10) := subtype_of(i);
    l_orig VARCHAR2(50);
    l_net  NUMBER := 0;
    l_tax  NUMBER := 0;
    l_disc NUMBER := 0;
    l_cat  VARCHAR2(1);
    l_rate NUMBER;
    l_crn  VARCHAR2(100) := seller_crn;
    l_cust NUMBER := customer_party(i);
    l_ccn  VARCHAR2(2);
    PROCEDURE w(p VARCHAR2) IS BEGIN DBMS_LOB.writeappend(l_x, LENGTH(p), p); END w;
  BEGIN
    SELECT country_code INTO l_cc FROM org_company WHERE id = company;
    SELECT MAX(country_code) INTO l_ccn FROM pty_party WHERE id = l_cust;
    DBMS_LOB.createtemporary(l_x, TRUE);
    w('<?xml version="1.0" encoding="UTF-8"?>' || CHR(10)
      || '<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"'
      || ' xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"'
      || ' xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"'
      || ' xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">' || CHR(10));
    w('<cbc:ProfileID>reporting:1.0</cbc:ProfileID><cbc:ID>' || x(i.doc_no) || '</cbc:ID><cbc:UUID>' || p_uuid || '</cbc:UUID>'
      || '<cbc:IssueDate>' || ds(i.doc_date) || '</cbc:IssueDate><cbc:IssueTime>' || TO_CHAR(NVL(i.issued_at, SYSTIMESTAMP), 'HH24:MI:SS') || '</cbc:IssueTime>'
      || '<cbc:InvoiceTypeCode name="' || l_sub || '">' || type_code(i.doc_type) || '</cbc:InvoiceTypeCode>'
      || '<cbc:DocumentCurrencyCode>' || l_cur || '</cbc:DocumentCurrencyCode><cbc:TaxCurrencyCode>' || NOONA_GL_PKG.ledger_currency || '</cbc:TaxCurrencyCode>' || CHR(10));
    IF i.doc_type IN ('CREDIT_NOTE', 'DEBIT_NOTE') THEN
      SELECT MAX(doc_no) INTO l_orig FROM sal_invoice WHERE id = i.original_invoice_id;
      w('<cac:BillingReference><cac:InvoiceDocumentReference><cbc:ID>' || x(NVL(l_orig, '-')) || '</cbc:ID></cac:InvoiceDocumentReference></cac:BillingReference>');
    END IF;
    w('<cac:AdditionalDocumentReference><cbc:ID>ICV</cbc:ID><cbc:UUID>' || p_icv || '</cbc:UUID></cac:AdditionalDocumentReference>'
      || '<cac:AdditionalDocumentReference><cbc:ID>PIH</cbc:ID><cac:Attachment><cbc:EmbeddedDocumentBinaryObject mimeCode="text/plain">' || p_pih
      || '</cbc:EmbeddedDocumentBinaryObject></cac:Attachment></cac:AdditionalDocumentReference>' || CHR(10));
    -- البائع
    w('<cac:AccountingSupplierParty><cac:Party>'
      || CASE WHEN l_crn IS NOT NULL THEN '<cac:PartyIdentification><cbc:ID schemeID="CRN">' || x(l_crn) || '</cbc:ID></cac:PartyIdentification>' END
      || address_xml(company, NULL, NULL, l_cc)
      || '<cac:PartyTaxScheme><cbc:CompanyID>' || x(seller_vat) || '</cbc:CompanyID><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:PartyTaxScheme>'
      || '<cac:PartyLegalEntity><cbc:RegistrationName>' || x(seller_name) || '</cbc:RegistrationName></cac:PartyLegalEntity></cac:Party></cac:AccountingSupplierParty>' || CHR(10));
    -- المشتري
    w('<cac:AccountingCustomerParty><cac:Party>' || address_xml(NULL, NVL(l_cust, -1), i.customer_address_snapshot, NVL(l_ccn, l_cc))
      || CASE WHEN TRIM(i.customer_tax_no_snapshot) IS NOT NULL THEN '<cac:PartyTaxScheme><cbc:CompanyID>' || x(TRIM(i.customer_tax_no_snapshot))
              || '</cbc:CompanyID><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:PartyTaxScheme>' END
      || '<cac:PartyLegalEntity><cbc:RegistrationName>' || x(i.customer_name_snapshot) || '</cbc:RegistrationName></cac:PartyLegalEntity></cac:Party></cac:AccountingCustomerParty>' || CHR(10));
    w('<cac:Delivery><cbc:ActualDeliveryDate>' || ds(NVL(i.supply_date, i.doc_date)) || '</cbc:ActualDeliveryDate></cac:Delivery>'
      || '<cac:PaymentMeans><cbc:PaymentMeansCode>' || CASE i.payment_mode WHEN 'CASH' THEN '10' WHEN 'CARD' THEN '48' WHEN 'BANK' THEN '42' ELSE '30' END
      || '</cbc:PaymentMeansCode>' || CASE WHEN i.doc_type IN ('CREDIT_NOTE', 'DEBIT_NOTE') THEN '<cbc:InstructionNote>'
      || CASE i.doc_type WHEN 'CREDIT_NOTE' THEN 'Returned goods / price adjustment' ELSE 'Additional charge' END || '</cbc:InstructionNote>' END
      || '</cac:PaymentMeans>' || CHR(10));
    -- إجماليات الضريبة حسب الفئة والنسبة
    FOR t IN (SELECT tax_code_id, SUM(net_amount) base, SUM(tax_amount) tax, SUM(discount_amount) disc FROM sal_invoice_line
               WHERE invoice_id = p_invoice_id GROUP BY tax_code_id) LOOP
      l_net := l_net + t.base; l_tax := l_tax + t.tax; l_disc := l_disc + NVL(t.disc, 0);
    END LOOP;
    w('<cac:TaxTotal><cbc:TaxAmount currencyID="' || NOONA_GL_PKG.ledger_currency || '">' || am(l_tax * NVL(i.exchange_rate, 1)) || '</cbc:TaxAmount></cac:TaxTotal>');
    w('<cac:TaxTotal><cbc:TaxAmount currencyID="' || l_cur || '">' || am(l_tax) || '</cbc:TaxAmount>');
    FOR t IN (SELECT tax_code_id, SUM(net_amount) base, SUM(tax_amount) tax FROM sal_invoice_line WHERE invoice_id = p_invoice_id GROUP BY tax_code_id) LOOP
      l_cat := category(t.tax_code_id, t.tax);
      l_rate := CASE WHEN t.base <> 0 THEN ROUND(t.tax * 100 / t.base, 2) ELSE 0 END;
      w('<cac:TaxSubtotal><cbc:TaxableAmount currencyID="' || l_cur || '">' || am(t.base) || '</cbc:TaxableAmount><cbc:TaxAmount currencyID="' || l_cur || '">'
        || am(t.tax) || '</cbc:TaxAmount><cac:TaxCategory><cbc:ID>' || l_cat || '</cbc:ID><cbc:Percent>' || am(l_rate) || '</cbc:Percent>'
        || exemption(l_cat) || '<cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:TaxCategory></cac:TaxSubtotal>');
    END LOOP;
    w('</cac:TaxTotal>' || CHR(10));
    w('<cac:LegalMonetaryTotal><cbc:LineExtensionAmount currencyID="' || l_cur || '">' || am(l_net) || '</cbc:LineExtensionAmount>'
      || '<cbc:TaxExclusiveAmount currencyID="' || l_cur || '">' || am(l_net) || '</cbc:TaxExclusiveAmount>'
      || '<cbc:TaxInclusiveAmount currencyID="' || l_cur || '">' || am(l_net + l_tax) || '</cbc:TaxInclusiveAmount>'
      || '<cbc:AllowanceTotalAmount currencyID="' || l_cur || '">0.00</cbc:AllowanceTotalAmount>'
      || '<cbc:PayableAmount currencyID="' || l_cur || '">' || am(l_net + l_tax) || '</cbc:PayableAmount></cac:LegalMonetaryTotal>' || CHR(10));
    FOR l IN (SELECT * FROM sal_invoice_line WHERE invoice_id = p_invoice_id ORDER BY line_no) LOOP
      l_cat := category(l.tax_code_id, l.tax_amount);
      l_rate := CASE WHEN l.net_amount <> 0 THEN ROUND(l.tax_amount * 100 / l.net_amount, 2) ELSE 0 END;
      w('<cac:InvoiceLine><cbc:ID>' || l.line_no || '</cbc:ID><cbc:InvoicedQuantity unitCode="PCE">' || qn(l.quantity) || '</cbc:InvoicedQuantity>'
        || '<cbc:LineExtensionAmount currencyID="' || l_cur || '">' || am(l.net_amount) || '</cbc:LineExtensionAmount>'
        || '<cac:TaxTotal><cbc:TaxAmount currencyID="' || l_cur || '">' || am(l.tax_amount) || '</cbc:TaxAmount><cbc:RoundingAmount currencyID="' || l_cur || '">'
        || am(l.net_amount + l.tax_amount) || '</cbc:RoundingAmount></cac:TaxTotal>'
        || '<cac:Item><cbc:Name>' || x(SUBSTR(l.description, 1, 1000)) || '</cbc:Name><cac:ClassifiedTaxCategory><cbc:ID>' || l_cat || '</cbc:ID><cbc:Percent>'
        || am(l_rate) || '</cbc:Percent><cac:TaxScheme><cbc:ID>VAT</cbc:ID></cac:TaxScheme></cac:ClassifiedTaxCategory></cac:Item>'
        || '<cac:Price><cbc:PriceAmount currencyID="' || l_cur || '">' || am(CASE WHEN l.quantity <> 0 THEN l.net_amount / l.quantity ELSE l.unit_price END)
        || '</cbc:PriceAmount>'
        || CASE WHEN NVL(l.discount_amount, 0) <> 0 THEN '<cac:AllowanceCharge><cbc:ChargeIndicator>false</cbc:ChargeIndicator><cbc:AllowanceChargeReason>discount</cbc:AllowanceChargeReason>'
                || '<cbc:Amount currencyID="' || l_cur || '">' || am(l.discount_amount / NULLIF(l.quantity, 0)) || '</cbc:Amount></cac:AllowanceCharge>' END
        || '</cac:Price></cac:InvoiceLine>' || CHR(10));
    END LOOP;
    w('</Invoice>');
    RETURN l_x;
  END build_xml;

  FUNCTION validate_invoice(p_invoice_id IN NUMBER) RETURN CLOB IS
    i     sal_invoice%ROWTYPE := get_invoice(p_invoice_id);
    l_a   JSON_ARRAY_T := JSON_ARRAY_T();
    l_vat VARCHAR2(100) := seller_vat;
    l_n   NUMBER;
    l_net NUMBER;
    l_tax NUMBER;
    PROCEDURE e(p_code VARCHAR2, p_msg VARCHAR2) IS
      l_o JSON_OBJECT_T := JSON_OBJECT_T();
    BEGIN
      l_o.put('code', p_code); l_o.put('message', p_msg); l_a.append(l_o);
    END e;
  BEGIN
    IF l_vat IS NULL THEN
      e('BR-KSA-39', 'لا يوجد رقم ضريبي فعال للشركة (أضفه في التسجيلات القانونية)');
    ELSIF NOT REGEXP_LIKE(l_vat, '^3[0-9]{13}3$') THEN
      e('BR-KSA-40', 'الرقم الضريبي للبائع 15 رقماً يبدأ وينتهي بالرقم 3');
    END IF;
    IF subtype_of(i) = '0100000' AND NOT REGEXP_LIKE(TRIM(i.customer_tax_no_snapshot), '^3[0-9]{13}3$') THEN
      e('BR-KSA-44', 'الرقم الضريبي للمشتري في الفاتورة الضريبية غير صحيح');
    END IF;
    IF i.doc_type IN ('CREDIT_NOTE', 'DEBIT_NOTE') AND i.original_invoice_id IS NULL THEN
      e('BR-KSA-56', 'الإشعار يجب أن يشير إلى الفاتورة الأصلية');
    END IF;
    SELECT COUNT(*), NVL(SUM(net_amount), 0), NVL(SUM(tax_amount), 0) INTO l_n, l_net, l_tax FROM sal_invoice_line WHERE invoice_id = p_invoice_id;
    IF l_n = 0 THEN
      e('BR-16', 'الفاتورة بلا أسطر');
    END IF;
    IF ABS(ROUND(l_net + l_tax, 2) - ROUND(i.total_amount, 2)) > 0.01 THEN
      e('BR-CO-15', 'إجمالي الفاتورة لا يساوي مجموع الأسطر والضريبة');
    END IF;
    IF i.status_code NOT IN ('POSTED', 'PARTIALLY_PAID', 'PAID', 'CREDITED', 'ISSUED') THEN
      e('NOONA-01', 'ترسل الفاتورة بعد ترحيلها فقط');
    END IF;
    RETURN l_a.to_clob;
  END validate_invoice;

  -- ================================================================ الطابور
  FUNCTION new_uuid RETURN VARCHAR2 IS
    l VARCHAR2(32) := LOWER(RAWTOHEX(SYS_GUID()));
  BEGIN
    RETURN SUBSTR(l, 1, 8) || '-' || SUBSTR(l, 9, 4) || '-4' || SUBSTR(l, 14, 3) || '-a' || SUBSTR(l, 18, 3) || '-' || SUBSTR(l, 21, 12);
  END new_uuid;

  -- يجهز المستند (XML + التجزئة + QR) لإرسال موجود بعداده وسلسلته
  PROCEDURE prepare(p_sub NUMBER) IS
    s     loc_einvoice_submission%ROWTYPE;
    i     sal_invoice%ROWTYPE;
    l_xml CLOB;
    l_h   VARCHAR2(100);
    l_sub VARCHAR2(10);
    l_qr  VARCHAR2(4000);
    l_bad VARCHAR2(1);
    l_err CLOB;
  BEGIN
    SELECT * INTO s FROM loc_einvoice_submission WHERE id = p_sub FOR UPDATE;
    i := get_invoice(s.source_entity_id);
    l_err := validate_invoice(i.id);
    l_xml := build_xml(i.id, s.invoice_uuid, s.invoice_counter, s.previous_hash);
    l_h := sha256_b64(l_xml);
    l_sub := subtype_of(i);
    l_bad := CASE WHEN DBMS_LOB.compare(l_err, TO_CLOB('[]')) <> 0 THEN 'Y' ELSE 'N' END;
    l_qr := qr_tlv(seller_name, seller_vat, NVL(i.issued_at, SYSTIMESTAMP), i.total_amount, i.tax_amount, l_h);
    UPDATE loc_einvoice_submission
       SET xml_content = l_xml, invoice_hash = l_h, invoice_type_code = type_code(i.doc_type), invoice_subtype = l_sub, qr_payload = l_qr,
           error_info = CASE WHEN l_bad = 'Y' THEN l_err END,
           status_code = CASE WHEN l_bad = 'Y' THEN 'VALIDATION_FAILED' ELSE 'READY_TO_SUBMIT' END
     WHERE id = p_sub;
    UPDATE sal_invoice SET einvoice_status = CASE WHEN l_bad = 'Y' THEN 'FAILED' ELSE 'PENDING' END, einvoice_submission_id = p_sub WHERE id = i.id;
  END prepare;

  FUNCTION enqueue(p_invoice_id IN NUMBER) RETURN NUMBER IS
    i      sal_invoice%ROWTYPE := get_invoice(p_invoice_id);
    l_prof NUMBER := active_profile(i.branch_id);
    l_icv  NUMBER;
    l_pih  VARCHAR2(128);
    l_id   NUMBER;
    l_n    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(l_prof IS NOT NULL, 'NOONA-EINV-011', 'لم تفعل الفوترة الإلكترونية للشركة (أضف إعداداً فعالاً)', 'E-invoicing is not enabled');
    SELECT COUNT(*) INTO l_n FROM loc_einvoice_submission
     WHERE source_entity_type = c_ent AND source_entity_id = p_invoice_id AND status_code NOT IN ('REJECTED', 'CANCELLED', 'VALIDATION_FAILED');
    IF l_n > 0 THEN
      SELECT MAX(id) INTO l_id FROM loc_einvoice_submission
       WHERE source_entity_type = c_ent AND source_entity_id = p_invoice_id AND status_code NOT IN ('REJECTED', 'CANCELLED', 'VALIDATION_FAILED');
      RETURN l_id;
    END IF;
    -- السلسلة لكل إعداد (جهاز): قفل الإعداد يضمن تتابع العداد والتجزئة
    SELECT id INTO l_n FROM loc_einvoice_profile WHERE id = l_prof FOR UPDATE;
    SELECT NVL(MAX(invoice_counter), 0) + 1, MAX(invoice_hash) KEEP (DENSE_RANK LAST ORDER BY invoice_counter, id)
      INTO l_icv, l_pih FROM loc_einvoice_submission WHERE profile_id = l_prof AND invoice_hash IS NOT NULL;
    INSERT INTO loc_einvoice_submission (company_id, source_entity_type, source_entity_id, profile_id, invoice_uuid, invoice_counter, previous_hash,
                                         attempts, idempotency_key, status_code)
    VALUES (company, c_ent, p_invoice_id, l_prof, new_uuid, l_icv, NVL(l_pih, c_first_pih), 0, 'SAL-' || p_invoice_id || '-' || l_icv, 'DRAFT')
    RETURNING id INTO l_id;
    prepare(l_id);
    RETURN l_id;
  END enqueue;

  FUNCTION queue_invoice(p_invoice_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.CREATE');
    RETURN enqueue(p_invoice_id);
  END queue_invoice;

  -- ---------------------------------------------------------------- المحولات
  -- المحاكي: يتصرف كبوابة الهيئة (الاعتماد للضريبية، الإبلاغ للمبسطة) ويرفض ما يفشل في قواعد التحقق
  PROCEDURE simulate(s loc_einvoice_submission%ROWTYPE, p_status OUT VARCHAR2, p_ref OUT VARCHAR2, p_resp OUT CLOB) IS
    l_err CLOB := validate_invoice(s.source_entity_id);
  BEGIN
    IF DBMS_LOB.compare(l_err, TO_CLOB('[]')) <> 0 THEN
      p_status := 'REJECTED';
      p_resp := '{"validationResults":{"status":"ERROR","errorMessages":' || l_err || '},"reportingStatus":"NOT_REPORTED"}';
    ELSE
      p_status := CASE s.invoice_subtype WHEN '0100000' THEN 'CLEARED' ELSE 'ACCEPTED' END;
      p_ref := 'SIM-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || s.invoice_counter;
      p_resp := '{"validationResults":{"status":"PASS","errorMessages":[]},"'
             || CASE p_status WHEN 'CLEARED' THEN 'clearanceStatus":"CLEARED"' ELSE 'reportingStatus":"REPORTED"' END || ',"simulator":true}';
    END IF;
  END simulate;

  -- الخدمة الخارجية: ترسل {uuid, invoiceHash, invoice(Base64 XML), mode, sandbox} وتعيد
  -- {status: CLEARED|REPORTED|REJECTED, reference, signature, publicKey, qr, clearedInvoice(Base64), errors[]}
  PROCEDURE call_rest(s loc_einvoice_submission%ROWTYPE, p loc_einvoice_profile%ROWTYPE, p_status OUT VARCHAR2, p_ref OUT VARCHAR2,
                      p_resp OUT CLOB, p_sig OUT VARCHAR2, p_qr OUT VARCHAR2, p_xml OUT CLOB) IS
    l_req  CLOB;
    l_o    JSON_OBJECT_T;
    l_st   VARCHAR2(30);
    l_b64  CLOB;
  BEGIN
    l_b64 := APEX_WEB_SERVICE.blob2clobbase64(APEX_UTIL.clob_to_blob(s.xml_content, 'AL32UTF8'));
    l_b64 := REPLACE(REPLACE(l_b64, CHR(13)), CHR(10));
    l_req := '{"uuid":"' || s.invoice_uuid || '","invoiceHash":"' || s.invoice_hash || '","icv":' || s.invoice_counter
          || ',"mode":"' || CASE s.invoice_subtype WHEN '0100000' THEN 'CLEARANCE' ELSE 'REPORTING' END || '","sandbox":"' || p.is_sandbox
          || '","device":"' || p.device_id || '","certificate":"' || p.certificate_ref || '","invoice":"';
    DBMS_LOB.append(l_req, l_b64);
    DBMS_LOB.append(l_req, TO_CLOB('"}'));
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    APEX_WEB_SERVICE.g_request_headers(1).name := 'Content-Type';
    APEX_WEB_SERVICE.g_request_headers(1).value := 'application/json; charset=utf-8';
    APEX_WEB_SERVICE.g_request_headers(2).name := 'Idempotency-Key';
    APEX_WEB_SERVICE.g_request_headers(2).value := s.idempotency_key;
    p_resp := APEX_WEB_SERVICE.make_rest_request(p_url => p.endpoint_ref, p_http_method => 'POST', p_body => l_req, p_transfer_timeout => 30);
    IF APEX_WEB_SERVICE.g_status_code NOT BETWEEN 200 AND 299 AND APEX_WEB_SERVICE.g_status_code NOT IN (400, 422) THEN
      p_status := 'PENDING_RETRY';
      RETURN;
    END IF;
    l_o := JSON_OBJECT_T.parse(p_resp);
    l_st := UPPER(js(l_o, 'status'));
    p_status := CASE WHEN l_st IN ('CLEARED') THEN 'CLEARED' WHEN l_st IN ('REPORTED', 'ACCEPTED') THEN 'ACCEPTED' WHEN l_st IN ('REJECTED', 'ERROR', 'INVALID') THEN 'REJECTED'
                     ELSE 'PENDING_RETRY' END;
    p_ref := js(l_o, 'reference');
    p_sig := js(l_o, 'signature');
    p_qr := js(l_o, 'qr');
    IF l_o.has('clearedInvoice') AND NOT l_o.get('clearedInvoice').is_null THEN
      p_xml := APEX_UTIL.blob_to_clob(APEX_WEB_SERVICE.clobbase642blob(l_o.get_clob('clearedInvoice')));
    END IF;
  END call_rest;

  PROCEDURE send(p_submission_id IN NUMBER) IS
    s      loc_einvoice_submission%ROWTYPE;
    p      loc_einvoice_profile%ROWTYPE;
    l_st   VARCHAR2(30);
    l_ref  VARCHAR2(200);
    l_resp CLOB;
    l_sig  VARCHAR2(4000);
    l_qr   VARCHAR2(4000);
    l_xml  CLOB;
    l_err  VARCHAR2(4000);
  BEGIN
    SELECT * INTO s FROM loc_einvoice_submission WHERE id = p_submission_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(s.status_code IN ('READY_TO_SUBMIT', 'PENDING_RETRY', 'SUBMISSION_FAILED', 'VALIDATION_FAILED'), 'NOONA-EINV-012',
                          'الإرسال ' || status_label(s.status_code) || ' ولا يعاد إرساله', 'Submission is not pending');
    IF s.status_code = 'VALIDATION_FAILED' THEN
      prepare(p_submission_id);
      SELECT * INTO s FROM loc_einvoice_submission WHERE id = p_submission_id;
      IF s.status_code = 'VALIDATION_FAILED' THEN RETURN; END IF;
    END IF;
    SELECT * INTO p FROM loc_einvoice_profile WHERE id = s.profile_id;
    BEGIN
      IF p.adapter_code = 'REST' THEN
        call_rest(s, p, l_st, l_ref, l_resp, l_sig, l_qr, l_xml);
      ELSE
        simulate(s, l_st, l_ref, l_resp);
      END IF;
    EXCEPTION WHEN OTHERS THEN
      l_st := 'PENDING_RETRY';
      l_err := SUBSTR(SQLERRM, 1, 3900);
    END;
    IF l_st = 'PENDING_RETRY' AND s.attempts + 1 >= 8 THEN
      l_st := 'SUBMISSION_FAILED';
    END IF;
    UPDATE loc_einvoice_submission
       SET status_code = l_st, attempts = attempts + 1, submitted_at = NVL(submitted_at, SYSTIMESTAMP),
           responded_at = CASE WHEN l_st IN ('CLEARED', 'ACCEPTED', 'REJECTED') THEN SYSTIMESTAMP END,
           gov_reference = NVL(l_ref, gov_reference), signature_value = NVL(l_sig, signature_value), qr_payload = NVL(l_qr, qr_payload),
           xml_content = NVL(l_xml, xml_content),
           -- إعادة المحاولة: 1، 2، 4، 8... دقائق حتى 4 ساعات
           next_retry_at = CASE WHEN l_st = 'PENDING_RETRY' THEN SYSTIMESTAMP + NUMTODSINTERVAL(LEAST(POWER(2, attempts), 240), 'MINUTE') END,
           error_info = CASE WHEN l_st = 'REJECTED' THEN l_resp WHEN l_err IS NOT NULL THEN TO_CLOB(JSON_OBJECT('error' VALUE l_err)) ELSE error_info END
     WHERE id = p_submission_id;
    UPDATE sal_invoice SET einvoice_status = CASE l_st WHEN 'CLEARED' THEN 'CLEARED' WHEN 'ACCEPTED' THEN 'ACCEPTED' WHEN 'REJECTED' THEN 'REJECTED'
                                                        WHEN 'SUBMISSION_FAILED' THEN 'FAILED' ELSE 'SUBMITTED' END
     WHERE id = s.source_entity_id;
    NOONA_AUDIT_PKG.log_event('API', 'LOC_EINVOICE_SUBMISSION', p_submission_id, 'SUBMIT',
                              CASE WHEN l_st IN ('CLEARED', 'ACCEPTED') THEN 'SUCCESS' ELSE 'FAILURE' END,
                              p_new_values => JSON_OBJECT('status' VALUE l_st, 'adapter' VALUE p.adapter_code));
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-EINV-013', 'الإرسال غير موجود', 'Submission not found');
  END send;

  PROCEDURE submit(p_submission_id IN NUMBER) IS
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.UPDATE');
    send(p_submission_id);
  END submit;

  -- عند ترحيل الفاتورة: تدخل السلسلة وترسل فوراً (فشل الاتصال يبقيها في الطابور لإعادة المحاولة)
  PROCEDURE on_invoice_posted(p_invoice_id IN NUMBER) IS
    l_b  NUMBER;
    l_id NUMBER;
    l_st VARCHAR2(30);
  BEGIN
    SELECT branch_id INTO l_b FROM sal_invoice WHERE id = p_invoice_id;
    IF active_profile(l_b) IS NOT NULL THEN
      l_id := enqueue(p_invoice_id);
      SELECT status_code INTO l_st FROM loc_einvoice_submission WHERE id = l_id;
      IF l_st = 'READY_TO_SUBMIT' THEN
        send(l_id);
      END IF;
    END IF;
  END on_invoice_posted;

  FUNCTION process_queue(p_limit IN NUMBER DEFAULT 50) RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.UPDATE');
    FOR s IN (SELECT id FROM loc_einvoice_submission
               WHERE company_id = company AND (status_code = 'READY_TO_SUBMIT' OR (status_code = 'PENDING_RETRY' AND NVL(next_retry_at, SYSTIMESTAMP) <= SYSTIMESTAMP))
               ORDER BY profile_id, invoice_counter FETCH FIRST p_limit ROWS ONLY) LOOP
      send(s.id);
      l_n := l_n + 1;
    END LOOP;
    RETURN l_n;
  END process_queue;

  FUNCTION resubmit(p_submission_id IN NUMBER) RETURN NUMBER IS
    s    loc_einvoice_submission%ROWTYPE;
    l_id NUMBER;
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.CREATE');
    SELECT * INTO s FROM loc_einvoice_submission WHERE id = p_submission_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(s.status_code IN ('REJECTED', 'SUBMISSION_FAILED'), 'NOONA-EINV-014', 'يعاد إرسال المرفوض أو الفاشل فقط',
                          'Only rejected or failed submissions are resubmitted');
    UPDATE loc_einvoice_submission SET status_code = 'CANCELLED' WHERE id = p_submission_id;
    -- نفس العداد وتجزئة السابقة: الفاتورة المرفوضة لم تدخل السلسلة لدى الهيئة
    INSERT INTO loc_einvoice_submission (company_id, source_entity_type, source_entity_id, profile_id, invoice_uuid, invoice_counter, previous_hash,
                                         attempts, idempotency_key, status_code)
    VALUES (company, s.source_entity_type, s.source_entity_id, s.profile_id, new_uuid, s.invoice_counter, s.previous_hash, 0,
            s.idempotency_key || '-R' || p_submission_id, 'DRAFT')
    RETURNING id INTO l_id;
    UPDATE loc_einvoice_submission SET invoice_hash = NULL WHERE id = p_submission_id;
    prepare(l_id);
    RETURN l_id;
  END resubmit;

  FUNCTION invoice_qr(p_invoice_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(qr_payload) KEEP (DENSE_RANK LAST ORDER BY id) INTO l FROM loc_einvoice_submission
     WHERE source_entity_type = c_ent AND source_entity_id = p_invoice_id AND status_code <> 'CANCELLED';
    RETURN l;
  END invoice_qr;

  -- ================================================================ الشاشات
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_ok NUMBER; l_pend NUMBER; l_bad NUMBER; l_miss NUMBER;
    l_prof NUMBER := active_profile;
    l_ad VARCHAR2(50);
    l_co NUMBER := company;
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.VIEW');
    SELECT COUNT(CASE WHEN status_code IN ('CLEARED', 'ACCEPTED') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('DRAFT', 'READY_TO_SUBMIT', 'SUBMITTED', 'PENDING_RETRY') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('REJECTED', 'VALIDATION_FAILED', 'SUBMISSION_FAILED') THEN 1 END)
      INTO l_ok, l_pend, l_bad FROM loc_einvoice_submission WHERE company_id = l_co;
    SELECT COUNT(*) INTO l_miss FROM sal_invoice i
     WHERE i.company_id = l_co AND i.status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID', 'CREDITED') AND i.einvoice_submission_id IS NULL
       AND i.doc_date >= (SELECT NVL(TRUNC(MIN(created_at)), TRUNC(SYSDATE)) FROM loc_einvoice_profile WHERE company_id = l_co);
    SELECT MAX(adapter_code) INTO l_ad FROM loc_einvoice_profile WHERE id = l_prof;
    RETURN '<div class="nn-prj-chips"><span>' || CASE WHEN l_prof IS NULL THEN 'الفوترة الإلكترونية غير مفعلة'
                                                     WHEN l_ad = 'SIMULATOR' THEN 'مفعلة - المحاكي (اختبار)' ELSE 'مفعلة - خدمة التوقيع/البوابة' END || '</span></div>'
        || '<div class="nn-kpis">' || kpi('معتمدة/مبلغة', l_ok, 'fa-check-circle', 'is-success')
        || kpi('في الطابور', l_pend, 'fa-clock-o', CASE WHEN l_pend > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('مرفوضة/فاشلة', l_bad, 'fa-exclamation-triangle', CASE WHEN l_bad > 0 THEN 'is-danger' ELSE 'is-muted' END)
        || kpi('فواتير مرحلة لم ترسل', l_miss, 'fa-paper-plane-o', CASE WHEN l_miss > 0 THEN 'is-warning' ELSE 'is-muted' END) || '</div>';
  END summary_html;

  FUNCTION queue_html(p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الفاتورة</th><th>التاريخ</th><th>العميل</th><th>النوع</th><th>ICV</th><th class="n">الإجمالي</th>'
        || '<th>المحاولات</th><th>مرجع الهيئة</th><th>الحالة</th><th></th></tr></thead><tbody>';
    FOR r IN (SELECT s.*, i.doc_no, i.doc_date, i.customer_name_snapshot cname, i.total_amount FROM loc_einvoice_submission s
                JOIN sal_invoice i ON i.id = s.source_entity_id
               WHERE s.company_id = company AND s.source_entity_type = c_ent
                 AND (p_status IS NULL OR s.status_code = p_status
                      OR (p_status = 'OPEN' AND s.status_code IN ('DRAFT', 'READY_TO_SUBMIT', 'SUBMITTED', 'PENDING_RETRY', 'REJECTED', 'VALIDATION_FAILED', 'SUBMISSION_FAILED')))
               ORDER BY s.id DESC FETCH FIRST 500 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-sub="' || r.id || '"><td>' || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '"><b>' || esc(r.doc_no) || '</b></a>'
                                                                ELSE '<b>' || esc(r.doc_no) || '</b>' END
          || '</td><td>' || ds(r.doc_date) || '</td><td>' || esc(r.cname) || '</td><td>' || r.invoice_type_code || ' / '
          || CASE r.invoice_subtype WHEN '0100000' THEN 'ضريبية' ELSE 'مبسطة' END || '</td><td>' || r.invoice_counter || '</td><td class="n">' || fmt(r.total_amount)
          || '</td><td>' || r.attempts || '</td><td dir="ltr">' || esc(r.gov_reference) || '</td><td>' || badge(r.status_code) || '</td><td>'
          || CASE WHEN r.status_code IN ('READY_TO_SUBMIT', 'PENDING_RETRY', 'VALIDATION_FAILED', 'SUBMISSION_FAILED') THEN '<button type="button" class="t-Button t-Button--small nn-einv-send" data-sub="' || r.id || '">إرسال</button>'
                  WHEN r.status_code = 'REJECTED' THEN '<button type="button" class="t-Button t-Button--small nn-einv-resend" data-sub="' || r.id || '">إعادة الإرسال</button>' END
          || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد إرسالات</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END queue_html;

  FUNCTION submission_html(p_submission_id IN NUMBER) RETURN CLOB IS
    s   loc_einvoice_submission%ROWTYPE;
    l_h CLOB;
    l_no VARCHAR2(50);
  BEGIN
    guard('LOC_EINVOICE_SUBMISSION.VIEW');
    SELECT * INTO s FROM loc_einvoice_submission WHERE id = p_submission_id AND company_id = company;
    SELECT doc_no INTO l_no FROM sal_invoice WHERE id = s.source_entity_id;
    l_h := '<div class="nn-prj-chips"><span>الفاتورة ' || esc(l_no) || '</span><span>ICV ' || s.invoice_counter || '</span>' || badge(s.status_code) || '</div>'
        || '<table class="nn-prj-cert-info nn-einv-info"><tr><th>UUID</th><td dir="ltr">' || s.invoice_uuid || '</td></tr>'
        || '<tr><th>تجزئة الفاتورة</th><td dir="ltr"><code>' || esc(s.invoice_hash) || '</code></td></tr>'
        || '<tr><th>تجزئة الفاتورة السابقة (PIH)</th><td dir="ltr"><code>' || esc(s.previous_hash) || '</code></td></tr>'
        || '<tr><th>مرجع الهيئة</th><td dir="ltr">' || esc(s.gov_reference) || '</td></tr>'
        || '<tr><th>المحاولات</th><td>' || s.attempts || CASE WHEN s.next_retry_at IS NOT NULL THEN ' - المحاولة التالية ' || TO_CHAR(s.next_retry_at, 'YYYY-MM-DD HH24:MI') END
        || '</td></tr></table>'
        || '<div class="nn-qr" data-qr="' || s.qr_payload || '"></div>';
    IF s.error_info IS NOT NULL THEN
      l_h := l_h || ('<h4 class="nn-prj-h">الأخطاء</h4><ul class="nn-einv-err">');
      BEGIN
        FOR e IN (SELECT code, msg FROM JSON_TABLE(s.error_info, '$[*]' COLUMNS (code VARCHAR2(50) PATH '$.code', msg VARCHAR2(1000) PATH '$.message'))) LOOP
          l_h := l_h || ('<li><b>' || esc(e.code) || '</b> ' || esc(e.msg) || '</li>');
        END LOOP;
        FOR e IN (SELECT code, msg FROM JSON_TABLE(s.error_info, '$.validationResults.errorMessages[*]' COLUMNS (code VARCHAR2(50) PATH '$.code', msg VARCHAR2(1000) PATH '$.message'))) LOOP
          l_h := l_h || ('<li><b>' || esc(e.code) || '</b> ' || esc(e.msg) || '</li>');
        END LOOP;
        FOR e IN (SELECT msg FROM JSON_TABLE(s.error_info, '$' COLUMNS (msg VARCHAR2(4000) PATH '$.error')) WHERE msg IS NOT NULL) LOOP
          l_h := l_h || ('<li>' || esc(e.msg) || '</li>');
        END LOOP;
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
      l_h := l_h || ('</ul>');
    END IF;
    l_h := l_h || ('<h4 class="nn-prj-h">مستند UBL 2.1</h4><pre class="nn-einv-xml" dir="ltr">');
    DBMS_LOB.append(l_h, TO_CLOB(esc(DBMS_LOB.substr(REPLACE(s.xml_content, '><', '>' || CHR(10) || '<'), 30000, 1))));
    RETURN l_h || ('</pre>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">الإرسال غير موجود</div>';
  END submission_html;

  FUNCTION profiles_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('LOC_EINVOICE_PROFILE.VIEW');
    l_h := '<table class="nn-prj-t"><thead><tr><th>الفرع</th><th>المحول</th><th>النمط</th><th>الجهاز</th><th>الخدمة</th><th>بيئة</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT p.*, b.name_ar bname FROM loc_einvoice_profile p LEFT JOIN org_branch b ON b.id = p.branch_id WHERE p.company_id = company ORDER BY p.id) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-profile="' || r.id || '"><td>' || esc(NVL(r.bname, 'كل الفروع')) || '</td><td>' || CASE r.adapter_code WHEN 'SIMULATOR' THEN 'المحاكي' ELSE 'خدمة خارجية (REST)' END
          || '</td><td>' || CASE r.integration_mode WHEN 'CLEARANCE' THEN 'اعتماد + إبلاغ' ELSE r.integration_mode END || '</td><td dir="ltr">' || esc(r.device_id)
          || '</td><td dir="ltr">' || esc(r.endpoint_ref) || '</td><td>' || CASE r.is_sandbox WHEN 'Y' THEN 'اختبار' ELSE 'إنتاج' END || '</td><td>' || badge(r.status_code)
          || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لم تفعل الفوترة الإلكترونية؛ أضف إعداداً (ابدأ بالمحاكي للاختبار)</div>'); END IF;
    -- CASE لا يرجع أكثر من 32 ألف حرف حتى لو كانت فروعه CLOB
    RETURN l_h || ('</tbody></table>');
  END profiles_html;
END NOONA_EINV_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_EINV_PKG
