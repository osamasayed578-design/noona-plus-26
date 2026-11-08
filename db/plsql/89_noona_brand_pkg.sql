-- =============================================================================
-- NOONA PLUS ERP | NOONA_BRAND_PKG - شعار المشترك (الشركة) وترويسة التقارير
--   * شعار النظام (NOONA PLUS) ملف ثابت في التطبيقات؛ شعار المشترك لكل شركة في إدارة المستندات:
--     ORG_COMPANY.LOGO_DOCUMENT_ID -> DMS_DOCUMENT -> DMS_DOCUMENT_VERSION -> DMS_FILE_CONTENT
--   * يقبل PNG / JPEG / GIF / WEBP حتى 512KB ويتحقق من النوع من محتوى الملف (لا يقبل SVG لأنه قد يحمل نصوصاً برمجية)
-- لا تعتمد على كائنات APEX؛ تقديم الصورة للمتصفح عبر عملية التطبيق NOONA_COMPANY_LOGO.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_BRAND_PKG AUTHID DEFINER AS

  c_max_bytes CONSTANT PLS_INTEGER := 524288;

  -- رفع/استبدال شعار الشركة (صلاحية ORG_COMPANY.UPDATE). يعيد رقم المستند
  FUNCTION set_company_logo(p_company_id IN NUMBER, p_file_name IN VARCHAR2, p_content IN BLOB) RETURN NUMBER;
  PROCEDURE remove_company_logo(p_company_id IN NUMBER);

  -- محتوى الشعار (الشركة الحالية عند عدم التحديد). o_content فارغ إن لم يوجد شعار
  PROCEDURE get_company_logo(p_company_id IN NUMBER, o_content OUT BLOB, o_mime OUT VARCHAR2, o_hash OUT VARCHAR2);
  FUNCTION has_logo(p_company_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  -- الشعار مضمناً (data URI) للمعاينة والتقارير المطبوعة
  FUNCTION logo_data_uri(p_company_id IN NUMBER DEFAULT NULL) RETURN CLOB;

  -- شارة الشركة الحالية في ترويسة التطبيقات: الشعار (إن وجد) واسم الشركة
  FUNCTION header_badge(p_app_id IN NUMBER, p_session IN VARCHAR2) RETURN VARCHAR2;

  -- ترويسة التقارير والمستندات: الشعار واسم الشركة والفرع، والعنوان ووسائل الاتصال والسجل التجاري والرقم الضريبي،
  -- ثم عنوان التقرير ووقت الطباعة والمستخدم. بيانات الفرع تتقدم على بيانات الشركة إن وجدت (الفرع الحالي افتراضياً)
  FUNCTION report_header(p_title IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL) RETURN CLOB;

  -- تذييل المستندات المطبوعة: خانات التوقيع (عناوينها مفصولة بـ |) وختم الشركة وسطر الاتصال
  FUNCTION doc_footer(p_signs IN VARCHAR2 DEFAULT 'المستلم|المحاسب|المدير المعتمد',
                      p_company_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL) RETURN CLOB;

  -- العنوان ووسائل الاتصال الرئيسية للشركة (p_branch_id فارغ) أو للفرع؛ تظهر في الترويسة والفواتير
  PROCEDURE save_contact(p_company_id IN NUMBER, p_branch_id IN NUMBER, p_address IN VARCHAR2, p_postal IN VARCHAR2,
                         p_phone IN VARCHAR2, p_mobile IN VARCHAR2, p_email IN VARCHAR2);
  PROCEDURE get_contact(p_company_id IN NUMBER, p_branch_id IN NUMBER, o_address OUT VARCHAR2, o_postal OUT VARCHAR2,
                        o_phone OUT VARCHAR2, o_mobile OUT VARCHAR2, o_email OUT VARCHAR2);
END NOONA_BRAND_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_BRAND_PKG AS

  FUNCTION company_id(p_company_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NVL(p_company_id, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  END company_id;

  -- نوع الصورة من أول بايتات الملف (لا يعتمد على الامتداد أو ما يصرح به المتصفح)
  FUNCTION sniff_mime(p_content BLOB) RETURN VARCHAR2 IS
    l_head VARCHAR2(40) := RAWTOHEX(DBMS_LOB.SUBSTR(p_content, 12, 1));
  BEGIN
    RETURN CASE
      WHEN l_head LIKE '89504E470D0A1A0A%' THEN 'image/png'
      WHEN l_head LIKE 'FFD8FF%' THEN 'image/jpeg'
      WHEN l_head LIKE '474946383_61%' THEN 'image/gif'
      WHEN l_head LIKE '52494646________57454250' THEN 'image/webp'
    END;
  END sniff_mime;

  FUNCTION logo_type_id RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_id FROM dms_document_type WHERE code = 'COMPANY_LOGO';
    IF l_id IS NULL THEN
      INSERT INTO dms_document_type (code, name_ar, name_en, default_confidentiality, allowed_mime_types, max_file_mb,
                                     allow_ocr, allow_ai_index)
      VALUES ('COMPANY_LOGO', 'شعار الشركة', 'Company Logo', 'PUBLIC', 'image/png,image/jpeg,image/gif,image/webp', 1, 'N', 'N')
      RETURNING id INTO l_id;
    END IF;
    RETURN l_id;
  END logo_type_id;

  FUNCTION set_company_logo(p_company_id IN NUMBER, p_file_name IN VARCHAR2, p_content IN BLOB) RETURN NUMBER IS
    l_company org_company%ROWTYPE;
    l_mime    VARCHAR2(30);
    l_size    NUMBER := NVL(DBMS_LOB.GETLENGTH(p_content), 0);
    l_content NUMBER;
    l_doc     NUMBER;
    l_ver     NUMBER;
    l_type    NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.UPDATE', p_company_id);
    SELECT * INTO l_company FROM org_company WHERE id = p_company_id;                 -- VPD: شركات المؤسسة فقط
    NOONA_CORE_PKG.assert(l_size BETWEEN 1 AND c_max_bytes, 'NOONA-BRD-001',
      'حجم الشعار يجب ألا يتجاوز 512 كيلوبايت', 'Logo must be at most 512 KB');
    l_mime := sniff_mime(p_content);
    NOONA_CORE_PKG.assert(l_mime IS NOT NULL, 'NOONA-BRD-002',
      'الشعار يجب أن يكون صورة PNG أو JPG أو GIF أو WEBP', 'Logo must be a PNG, JPEG, GIF or WEBP image');

    INSERT INTO dms_file_content (storage_medium, content_blob, file_name, file_size_bytes, declared_mime, detected_mime,
                                  hash_algorithm, hash_value, scan_status, status_code)
    VALUES ('SECUREFILE', p_content, SUBSTR(NVL(p_file_name, 'logo'), 1, 500), l_size, l_mime, l_mime, 'SHA256',
            LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p_content, DBMS_CRYPTO.HASH_SH256))), 'SKIPPED', 'STORED')
    RETURNING id INTO l_content;
    l_type := logo_type_id;
    INSERT INTO dms_document (company_id, document_type_id, title, origin_type, status_code, confidentiality_level, document_date)
    VALUES (p_company_id, l_type, 'شعار ' || NVL(l_company.trade_name_ar, l_company.legal_name_ar),
            'AUTHENTIC', 'ACTIVE', 'PUBLIC', TRUNC(SYSDATE))
    RETURNING id INTO l_doc;
    INSERT INTO dms_document_version (document_id, version_no, content_id, change_type, uploaded_at, status_code)
    VALUES (l_doc, 1, l_content, 'INITIAL', SYSTIMESTAMP, 'CURRENT')
    RETURNING id INTO l_ver;
    UPDATE dms_document SET current_version_id = l_ver WHERE id = l_doc;
    -- الشعار السابق يبقى في الأرشيف (للتقارير التاريخية) بحالة SUPERSEDED
    UPDATE dms_document SET status_code = 'SUPERSEDED' WHERE id = l_company.logo_document_id;
    UPDATE org_company SET logo_document_id = l_doc WHERE id = p_company_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'SET_LOGO', 'SUCCESS',
      p_new_values => '{"document_id":' || l_doc || ',"bytes":' || l_size || ',"mime":"' || l_mime || '"}');
    RETURN l_doc;
  END set_company_logo;

  PROCEDURE remove_company_logo(p_company_id IN NUMBER) IS
    l_doc NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.UPDATE', p_company_id);
    SELECT logo_document_id INTO l_doc FROM org_company WHERE id = p_company_id;
    IF l_doc IS NOT NULL THEN
      UPDATE org_company SET logo_document_id = NULL WHERE id = p_company_id;
      UPDATE dms_document SET status_code = 'SUPERSEDED' WHERE id = l_doc;
      NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_COMPANY', p_company_id, 'REMOVE_LOGO', 'SUCCESS');
    END IF;
  END remove_company_logo;

  PROCEDURE get_company_logo(p_company_id IN NUMBER, o_content OUT BLOB, o_mime OUT VARCHAR2, o_hash OUT VARCHAR2) IS
    l_company NUMBER := company_id(p_company_id);
  BEGIN
    SELECT f.content_blob, f.detected_mime, f.hash_value
      INTO o_content, o_mime, o_hash
      FROM org_company c
      JOIN dms_document d ON d.id = c.logo_document_id
      JOIN dms_document_version v ON v.id = d.current_version_id
      JOIN dms_file_content f ON f.id = v.content_id
     WHERE c.id = l_company;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    o_content := NULL; o_mime := NULL; o_hash := NULL;
  END get_company_logo;

  FUNCTION has_logo(p_company_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l_n       NUMBER;
    l_company NUMBER := company_id(p_company_id);
  BEGIN
    SELECT COUNT(*) INTO l_n FROM org_company WHERE id = l_company AND logo_document_id IS NOT NULL;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END has_logo;

  FUNCTION logo_data_uri(p_company_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_blob BLOB; l_mime VARCHAR2(100); l_hash VARCHAR2(128);
    l_out  CLOB;
    l_pos  PLS_INTEGER := 1;
    l_len  PLS_INTEGER;
    c_step CONSTANT PLS_INTEGER := 23808;          -- مضاعف 3 ليبقى الترميز متصلاً
  BEGIN
    get_company_logo(p_company_id, l_blob, l_mime, l_hash);
    IF l_blob IS NULL THEN
      RETURN NULL;
    END IF;
    l_len := DBMS_LOB.GETLENGTH(l_blob);
    l_out := 'data:' || l_mime || ';base64,';
    WHILE l_pos <= l_len LOOP
      l_out := l_out || (REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(
                 DBMS_LOB.SUBSTR(l_blob, c_step, l_pos))), CHR(13)), CHR(10)));
      l_pos := l_pos + c_step;
    END LOOP;
    RETURN l_out;
  END logo_data_uri;

  FUNCTION header_badge(p_app_id IN NUMBER, p_session IN VARCHAR2) RETURN VARCHAR2 IS
    l_name VARCHAR2(400);
    l_logo VARCHAR2(30);
    l_company NUMBER := company_id(NULL);
  BEGIN
    IF SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID') IS NULL THEN
      RETURN NULL;
    END IF;
    SELECT NVL(trade_name_ar, legal_name_ar), NVL2(logo_document_id, 'Y', 'N')
      INTO l_name, l_logo
      FROM org_company WHERE id = l_company;
    RETURN '<span class="nn-co-badge" title="' || NOONA_UI_PKG.esc(l_name) || '">'
        || CASE WHEN l_logo = 'Y'
             THEN '<img class="nn-co-logo" alt="" src="f?p=' || p_app_id || ':0:' || NOONA_UI_PKG.esc(p_session)
                  || ':APPLICATION_PROCESS=NOONA_COMPANY_LOGO">'
             ELSE '<span class="nn-co-icon fa fa-building-o" aria-hidden="true"></span>' END
        || '<span class="nn-co-name">' || NOONA_UI_PKG.esc(l_name) || '</span></span>';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END header_badge;

  -- ---------------------------------------------------------------- العنوان ووسائل الاتصال
  PROCEDURE get_contact(p_company_id IN NUMBER, p_branch_id IN NUMBER, o_address OUT VARCHAR2, o_postal OUT VARCHAR2,
                        o_phone OUT VARCHAR2, o_mobile OUT VARCHAR2, o_email OUT VARCHAR2) IS
  BEGIN
    SELECT MAX(address_line_ar) KEEP (DENSE_RANK FIRST ORDER BY is_primary DESC, id DESC),
           MAX(postal_code) KEEP (DENSE_RANK FIRST ORDER BY is_primary DESC, id DESC)
      INTO o_address, o_postal
      FROM ref_address
     WHERE (p_branch_id IS NOT NULL AND branch_id = p_branch_id OR p_branch_id IS NULL AND company_id = p_company_id)
       AND address_type = 'LEGAL' AND (effective_to IS NULL OR effective_to >= TRUNC(SYSDATE));
    SELECT MAX(phone) KEEP (DENSE_RANK FIRST ORDER BY is_primary DESC, id DESC),
           MAX(mobile) KEEP (DENSE_RANK FIRST ORDER BY is_primary DESC, id DESC),
           MAX(email) KEEP (DENSE_RANK FIRST ORDER BY is_primary DESC, id DESC)
      INTO o_phone, o_mobile, o_email
      FROM ref_contact
     WHERE (p_branch_id IS NOT NULL AND branch_id = p_branch_id OR p_branch_id IS NULL AND company_id = p_company_id)
       AND contact_role = 'GENERAL' AND (effective_to IS NULL OR effective_to >= TRUNC(SYSDATE));
  END get_contact;

  PROCEDURE save_contact(p_company_id IN NUMBER, p_branch_id IN NUMBER, p_address IN VARCHAR2, p_postal IN VARCHAR2,
                         p_phone IN VARCHAR2, p_mobile IN VARCHAR2, p_email IN VARCHAR2) IS
    l_co   org_company%ROWTYPE;
    l_ctry VARCHAR2(10);
    l_cnt  PLS_INTEGER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_co FROM org_company WHERE id = p_company_id;                 -- VPD: شركات المؤسسة فقط
    IF p_branch_id IS NULL THEN
      NOONA_SECURITY_PKG.assert_permission('ORG_COMPANY.UPDATE', p_company_id);
      l_ctry := l_co.country_code;
    ELSE
      NOONA_SECURITY_PKG.assert_permission('ORG_BRANCH.UPDATE', p_company_id);
      SELECT NVL(country_code, l_co.country_code) INTO l_ctry FROM org_branch WHERE id = p_branch_id AND company_id = p_company_id;
    END IF;
    NOONA_CORE_PKG.assert(p_email IS NULL OR REGEXP_LIKE(TRIM(p_email), '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
      'NOONA-BRD-010', 'البريد الإلكتروني غير صحيح', 'Invalid e-mail address');

    UPDATE ref_address SET address_line_ar = TRIM(p_address), postal_code = TRIM(p_postal)
     WHERE (p_branch_id IS NOT NULL AND branch_id = p_branch_id OR p_branch_id IS NULL AND company_id = p_company_id)
       AND address_type = 'LEGAL' AND is_primary = 'Y' AND effective_to IS NULL;
    l_cnt := SQL%ROWCOUNT;
    IF l_cnt = 0 AND (TRIM(p_address) IS NOT NULL OR TRIM(p_postal) IS NOT NULL) THEN
      INSERT INTO ref_address (company_id, branch_id, address_type, country_code, address_line_ar, postal_code, is_primary)
      VALUES (CASE WHEN p_branch_id IS NULL THEN p_company_id END, p_branch_id, 'LEGAL', l_ctry, TRIM(p_address), TRIM(p_postal), 'Y');
    END IF;

    UPDATE ref_contact SET phone = TRIM(p_phone), mobile = TRIM(p_mobile), email = LOWER(TRIM(p_email))
     WHERE (p_branch_id IS NOT NULL AND branch_id = p_branch_id OR p_branch_id IS NULL AND company_id = p_company_id)
       AND contact_role = 'GENERAL' AND is_primary = 'Y' AND effective_to IS NULL;
    l_cnt := SQL%ROWCOUNT;
    IF l_cnt = 0 AND (TRIM(p_phone) IS NOT NULL OR TRIM(p_mobile) IS NOT NULL OR TRIM(p_email) IS NOT NULL) THEN
      INSERT INTO ref_contact (company_id, branch_id, contact_role, phone, mobile, email, is_primary)
      VALUES (CASE WHEN p_branch_id IS NULL THEN p_company_id END, p_branch_id, 'GENERAL', TRIM(p_phone), TRIM(p_mobile),
              LOWER(TRIM(p_email)), 'Y');
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-BRD-011', 'الشركة أو الفرع غير موجود', 'Company or branch not found');
  END save_contact;

  -- رقم التسجيل الرئيسي بنهاية رمز نوعه (_CR السجل التجاري، _VAT/_TRN/_TIN الضريبي)
  FUNCTION reg_no(p_company_id NUMBER, p_branch_id NUMBER, p_kind VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT MAX(r.reg_number) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN r.branch_id = p_branch_id THEN 0 ELSE 1 END, r.is_primary DESC, r.id DESC)
      INTO l
      FROM org_legal_registration r JOIN loc_registration_type t ON t.id = r.reg_type_id
     WHERE r.company_id = p_company_id AND (r.branch_id IS NULL OR r.branch_id = p_branch_id)
       AND (r.effective_to IS NULL OR r.effective_to >= TRUNC(SYSDATE)) AND NVL(r.status_code, 'ACTIVE') = 'ACTIVE'
       AND (p_kind = 'CR' AND t.code LIKE '%\_CR' ESCAPE '\'
            OR p_kind = 'TAX' AND (t.code LIKE '%\_VAT' ESCAPE '\' OR t.code LIKE '%\_TRN' ESCAPE '\' OR t.code IN ('QA_TIN', 'SD_TIN')));
    RETURN l;
  END reg_no;

  FUNCTION branch_of(p_branch_id NUMBER, p_company_id NUMBER) RETURN NUMBER IS
    l NUMBER := NVL(p_branch_id, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')));
    n PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO n FROM org_branch WHERE id = l AND company_id = p_company_id;
    RETURN CASE WHEN n = 1 THEN l END;
  END branch_of;

  -- بيانات الاتصال الفعلية: ما سجل للفرع، وما نقص منه يؤخذ من الشركة
  PROCEDURE contact_of(p_company_id NUMBER, p_branch_id NUMBER, o_address OUT VARCHAR2, o_phone OUT VARCHAR2,
                       o_mobile OUT VARCHAR2, o_email OUT VARCHAR2) IS
    a VARCHAR2(500); pc VARCHAR2(20); ph VARCHAR2(40); mb VARCHAR2(40); em VARCHAR2(320);
  BEGIN
    get_contact(p_company_id, NULL, o_address, pc, o_phone, o_mobile, o_email);
    o_address := o_address || NVL2(pc, ' - ص.ب/الرمز البريدي ' || pc, '');
    IF p_branch_id IS NOT NULL THEN
      get_contact(p_company_id, p_branch_id, a, pc, ph, mb, em);
      IF a IS NOT NULL THEN o_address := a || NVL2(pc, ' - ص.ب/الرمز البريدي ' || pc, ''); END IF;
      o_phone := NVL(ph, o_phone); o_mobile := NVL(mb, o_mobile); o_email := NVL(em, o_email);
    END IF;
  END contact_of;

  FUNCTION report_header(p_title IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_co      org_company%ROWTYPE;
    l_logo    CLOB;
    l_company NUMBER := company_id(p_company_id);
    l_branch  NUMBER;
    l_bname   VARCHAR2(400);
    l_addr    VARCHAR2(600); l_phone VARCHAR2(40); l_mobile VARCHAR2(40); l_email VARCHAR2(320);
    l_cr      VARCHAR2(100); l_vat VARCHAR2(100);
    l_info    VARCHAR2(4000);
    FUNCTION item(p_icon VARCHAR2, p_label VARCHAR2, p_val VARCHAR2, p_ltr BOOLEAN DEFAULT FALSE) RETURN VARCHAR2 IS
    BEGIN
      RETURN CASE WHEN p_val IS NOT NULL THEN
        '<span class="nn-lh-i"><span class="fa ' || p_icon || '" aria-hidden="true"></span>' || NVL2(p_label, '<em>' || p_label || '</em> ', '')
        || CASE WHEN p_ltr THEN '<bdi dir="ltr">' || NOONA_UI_PKG.esc(p_val) || '</bdi>' ELSE NOONA_UI_PKG.esc(p_val) END || '</span>' END;
    END item;
  BEGIN
    SELECT * INTO l_co FROM org_company WHERE id = l_company;
    l_branch := branch_of(p_branch_id, l_company);
    IF l_branch IS NOT NULL THEN
      SELECT CASE WHEN NVL(is_head_office, 'N') = 'Y' THEN NULL ELSE name_ar END INTO l_bname FROM org_branch WHERE id = l_branch;
    END IF;
    contact_of(l_company, l_branch, l_addr, l_phone, l_mobile, l_email);
    l_cr := reg_no(l_company, l_branch, 'CR');
    l_vat := reg_no(l_company, l_branch, 'TAX');
    l_logo := logo_data_uri(l_co.id);
    l_info := item('fa-map-marker', NULL, l_addr) || item('fa-phone', 'هاتف', l_phone, TRUE) || item('fa-mobile', 'جوال', l_mobile, TRUE)
           || item('fa-envelope-o', NULL, l_email, TRUE) || item('fa-id-card-o', 'س.ت', l_cr, TRUE) || item('fa-percent', 'الرقم الضريبي', l_vat, TRUE);
    RETURN '<header class="nn-rpt-head nn-lh"><div class="nn-lh-top"><div class="nn-rpt-co">'
        || CASE WHEN l_logo IS NOT NULL THEN '<img class="nn-rpt-logo" alt="" src="' || l_logo || '">'
                ELSE '<span class="nn-lh-mono" aria-hidden="true">' || NOONA_UI_PKG.esc(SUBSTR(NVL(l_co.trade_name_ar, l_co.legal_name_ar), 1, 1)) || '</span>' END
        || '<div><div class="nn-rpt-co-name">' || NOONA_UI_PKG.esc(l_co.legal_name_ar) || '</div>'
        || CASE WHEN l_co.legal_name_en IS NOT NULL THEN '<div class="nn-rpt-co-en">' || NOONA_UI_PKG.esc(l_co.legal_name_en) || '</div>' END
        || CASE WHEN l_bname IS NOT NULL THEN '<div class="nn-lh-branch">' || NOONA_UI_PKG.esc(l_bname) || '</div>' END
        || '</div></div>'
        || CASE WHEN l_info IS NOT NULL THEN '<div class="nn-lh-info">' || l_info || '</div>' END
        || '</div><div class="nn-lh-band"><div class="nn-rpt-title">' || NOONA_UI_PKG.esc(p_title) || '</div>'
        || '<div class="nn-lh-meta"><span>تاريخ الطباعة <bdi dir="ltr">' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || '</bdi></span>'
        || CASE WHEN SYS_CONTEXT('NOONA_CTX', 'USERNAME') IS NOT NULL
             THEN '<span>بواسطة ' || NOONA_UI_PKG.esc(LOWER(SYS_CONTEXT('NOONA_CTX', 'USERNAME'))) || '</span>' END
        || '<span class="nn-rpt-sys">NOONA PLUS ERP</span></div></div></header>';
  END report_header;

  FUNCTION doc_footer(p_signs IN VARCHAR2 DEFAULT 'المستلم|المحاسب|المدير المعتمد',
                      p_company_id IN NUMBER DEFAULT NULL, p_branch_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_company NUMBER := company_id(p_company_id);
    l_branch  NUMBER := branch_of(p_branch_id, l_company);
    l_co      org_company%ROWTYPE;
    l_addr    VARCHAR2(600); l_phone VARCHAR2(40); l_mobile VARCHAR2(40); l_email VARCHAR2(320);
    l_html    CLOB := '<footer class="nn-docfoot"><div class="nn-sign">';
    l_n       PLS_INTEGER := 0;
  BEGIN
    SELECT * INTO l_co FROM org_company WHERE id = l_company;
    FOR r IN (SELECT REGEXP_SUBSTR(p_signs, '[^|]+', 1, LEVEL) t FROM dual CONNECT BY REGEXP_SUBSTR(p_signs, '[^|]+', 1, LEVEL) IS NOT NULL) LOOP
      l_n := l_n + 1;
      l_html := l_html || '<div><b>' || NOONA_UI_PKG.esc(r.t) || '</b><span>الاسم: ..............................</span>'
             || '<span>التوقيع: ............................</span><span>التاريخ: ......./......./..........</span></div>';
    END LOOP;
    l_html := l_html || '<div class="nn-docfoot-seal"><b>ختم الشركة</b><span class="nn-docfoot-stamp" aria-hidden="true"></span></div></div>';
    contact_of(l_company, l_branch, l_addr, l_phone, l_mobile, l_email);
    RETURN l_html || '<div class="nn-docfoot-line">' || NOONA_UI_PKG.esc(NVL(l_co.trade_name_ar, l_co.legal_name_ar))
        || NVL2(l_addr, ' · ' || NOONA_UI_PKG.esc(l_addr), '')
        || NVL2(l_phone, ' · هاتف <bdi dir="ltr">' || NOONA_UI_PKG.esc(l_phone) || '</bdi>', '')
        || NVL2(l_email, ' · <bdi dir="ltr">' || NOONA_UI_PKG.esc(l_email) || '</bdi>', '')
        || '</div><div class="nn-docfoot-note">مستند صادر من نظام NOONA PLUS ERP، ولا يعتد به دون توقيع وختم الشركة</div></footer>';
  END doc_footer;

END NOONA_BRAND_PKG;
/
