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

  -- ترويسة التقارير: شعار الشركة وبياناتها، وعنوان التقرير، وعلامة النظام
  FUNCTION report_header(p_title IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL) RETURN CLOB;
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
      l_out := l_out || REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(
                 DBMS_LOB.SUBSTR(l_blob, c_step, l_pos))), CHR(13)), CHR(10));
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

  FUNCTION report_header(p_title IN VARCHAR2, p_company_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_co   org_company%ROWTYPE;
    l_logo    CLOB;
    l_company NUMBER := company_id(p_company_id);
  BEGIN
    SELECT * INTO l_co FROM org_company WHERE id = l_company;
    l_logo := logo_data_uri(l_co.id);
    RETURN '<div class="nn-rpt-head"><div class="nn-rpt-co">'
        || CASE WHEN l_logo IS NOT NULL THEN '<img class="nn-rpt-logo" alt="" src="' || l_logo || '">' END
        || '<div><div class="nn-rpt-co-name">' || NOONA_UI_PKG.esc(l_co.legal_name_ar) || '</div>'
        || CASE WHEN l_co.legal_name_en IS NOT NULL
             THEN '<div class="nn-rpt-co-en">' || NOONA_UI_PKG.esc(l_co.legal_name_en) || '</div>' END
        || '</div></div><div class="nn-rpt-title">' || NOONA_UI_PKG.esc(p_title)
        || '<small>' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || '</small></div>'
        || '<div class="nn-rpt-sys">NOONA PLUS ERP</div></div>';
  END report_header;

END NOONA_BRAND_PKG;
/
