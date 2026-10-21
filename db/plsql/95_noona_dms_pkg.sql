-- =============================================================================
-- NOONA PLUS ERP | NOONA_DMS_PKG - محرك المستندات والأرشفة
--   * كل مستند مؤرشف له رقم أرشيف (ARC-YYYY-NNNNNN من تسلسل DMS_ARCHIVE) يكتب على الأصل الورقي،
--     ومرجعه الورقي/الخارجي (رقم الفاتورة أو الشيك أو الخطاب) وموقع الأصل (الملف/الرف)
--   * صورة الأصل اختيارية حسب القاعدة: PDF وصور ومستندات مكتبية بفحص المحتوى وحد للحجم، بإصدارات وبصمة SHA-256
--   * الربط بأي مستند أعمال (سند، قيد، فاتورة...) ؛ لا يفصل عن مستند مرحل
--   * قواعد الأرشفة لكل نوع مستند أعمال: المرجع الورقي إلزامي قبل الاعتماد، وصورة الأصل إلزامية اختيارياً
--   * كل تنزيل يسجل في DMS_ACCESS_LOG (مسموح/مرفوض)
-- لا تعتمد على حزم الأنظمة الفرعية (تقرأ جداولها للوصف والقفل فقط) حتى تستدعيها تلك الحزم عند الاعتماد.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_DMS_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;

  -- تسلسل أرقام الأرشيف وقواعد الأرشفة الافتراضية (السندات والقيود: المرجع إلزامي)؛ يعيد عدد القواعد المضافة
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  -- قاعدة أرشفة لنوع مستند أعمال
  PROCEDURE set_rule(p_entity_type IN VARCHAR2, p_type_code IN VARCHAR2, p_required IN VARCHAR2 DEFAULT 'Y',
                     p_require_file IN VARCHAR2 DEFAULT 'N', p_active IN VARCHAR2 DEFAULT 'Y');
  -- نوع مستند خاص بالمؤسسة
  FUNCTION create_type(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_category_code IN VARCHAR2 DEFAULT 'ADM',
                       p_mime IN VARCHAR2 DEFAULT NULL, p_max_mb IN NUMBER DEFAULT 20,
                       p_confidentiality IN VARCHAR2 DEFAULT 'INTERNAL') RETURN NUMBER;

  -- أرشفة مستند (بملف أو مرجع ورقي فقط) وربطه اختيارياً بمستند أعمال؛ يعيد رقم المستند المؤرشف
  -- p_type_code فارغ = النوع المناسب لمستند الأعمال (سند قبض/صرف/مصروف، قيد...) أو قاعدة الأرشفة
  FUNCTION archive_document(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_type_code IN VARCHAR2,
                            p_title IN VARCHAR2, p_external_ref IN VARCHAR2 DEFAULT NULL, p_location IN VARCHAR2 DEFAULT NULL,
                            p_doc_date IN DATE DEFAULT NULL, p_description IN VARCHAR2 DEFAULT NULL,
                            p_file_name IN VARCHAR2 DEFAULT NULL, p_mime IN VARCHAR2 DEFAULT NULL, p_content IN BLOB DEFAULT NULL,
                            p_confidentiality IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- إصدار جديد لملف المستند (الإصدار السابق يبقى في الأرشيف)
  FUNCTION add_version(p_document_id IN NUMBER, p_file_name IN VARCHAR2, p_mime IN VARCHAR2, p_content IN BLOB,
                       p_reason IN VARCHAR2) RETURN NUMBER;
  PROCEDURE link_document(p_document_id IN NUMBER, p_entity_type IN VARCHAR2, p_entity_id IN NUMBER);
  -- فصل مستند عن مستند أعمال (ممنوع بعد ترحيل مستند الأعمال)
  PROCEDURE detach(p_document_id IN NUMBER, p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_reason IN VARCHAR2);

  -- المرجع الورقي متحقق حسب القاعدة؟ Y/N ، والتحقق المانع قبل الاعتماد (NOONA-DMS-200)
  FUNCTION has_reference(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2;
  PROCEDURE assert_reference(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER);

  -- تنزيل الملف (استجابة HTTP) مع سجل الوصول
  PROCEDURE download(p_document_id IN NUMBER, p_version_id IN NUMBER DEFAULT NULL);

  -- الواجهة
  FUNCTION entity_label(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION refs_text(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2;
  -- p_link: رابط التنزيل/العرض؛ #ID# يستبدل برقم المستند
  FUNCTION attachments_html(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION document_html(p_document_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION summary(p_session IN VARCHAR2) RETURN CLOB;
  FUNCTION type_for_entity(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2;
END NOONA_DMS_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_DMS_PKG AS

  c_max_mb CONSTANT NUMBER := 20;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION company RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END company;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION size_text(p_bytes NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_bytes IS NULL THEN NULL WHEN p_bytes < 1024 THEN p_bytes || ' B'
                WHEN p_bytes < 1048576 THEN ROUND(p_bytes / 1024) || ' KB' ELSE ROUND(p_bytes / 1048576, 1) || ' MB' END;
  END size_text;

  -- نوع الملف من محتواه لا من اسمه (يمنع الملفات التنفيذية المتنكرة)
  FUNCTION sniff_mime(p_content BLOB, p_declared VARCHAR2) RETURN VARCHAR2 IS
    l_head VARCHAR2(40) := RAWTOHEX(DBMS_LOB.SUBSTR(p_content, 12, 1));
  BEGIN
    RETURN CASE
      WHEN l_head LIKE '25504446%' THEN 'application/pdf'
      WHEN l_head LIKE '89504E470D0A1A0A%' THEN 'image/png'
      WHEN l_head LIKE 'FFD8FF%' THEN 'image/jpeg'
      WHEN l_head LIKE '474946383_61%' THEN 'image/gif'
      WHEN l_head LIKE '52494646________57454250' THEN 'image/webp'
      WHEN l_head LIKE '49492A00%' OR l_head LIKE '4D4D002A%' THEN 'image/tiff'
      -- مستندات Office الحديثة حاوية ZIP: يقبل النوع المعلن إن كان من أنواعها
      WHEN l_head LIKE '504B0304%' AND p_declared IN ('application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        THEN p_declared
    END;
  END sniff_mime;

  FUNCTION type_row(p_code VARCHAR2) RETURN dms_document_type%ROWTYPE IS
    l dms_document_type%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM (SELECT * FROM dms_document_type WHERE code = p_code AND is_active = 'Y'
                           ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) WHERE ROWNUM = 1;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DMS-101', 'نوع المستند غير معرف: ' || p_code, 'Unknown document type');
  END type_row;

  -- ================================================================ الوصف والقفل لمستندات الأعمال
  FUNCTION entity_label(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(300);
  BEGIN
    IF p_entity_type = 'CSH_TRANSACTION' THEN
      SELECT CASE txn_type WHEN 'RECEIPT' THEN 'سند قبض ' WHEN 'PAYMENT' THEN 'سند صرف ' WHEN 'EXPENSE' THEN 'سند مصروفات ' ELSE 'حركة نقدية ' END
             || doc_no INTO l FROM csh_transaction WHERE id = p_entity_id AND company_id = company;
    ELSIF p_entity_type = 'GL_JOURNAL' THEN
      SELECT 'قيد يومية ' || doc_no INTO l FROM gl_journal WHERE id = p_entity_id AND company_id = company;
    ELSE
      SELECT NVL(MAX(name_ar), p_entity_type) || ' #' || p_entity_id INTO l FROM ref_entity_type WHERE entity_type_code = p_entity_type;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-DMS-102', 'مستند الأعمال غير موجود في الشركة الحالية', 'Business document not found');
  END entity_label;

  FUNCTION entity_locked(p_entity_type VARCHAR2, p_entity_id NUMBER) RETURN BOOLEAN IS
    l_st VARCHAR2(30);
  BEGIN
    IF p_entity_type = 'CSH_TRANSACTION' THEN
      SELECT MAX(status_code) INTO l_st FROM csh_transaction WHERE id = p_entity_id;
      RETURN l_st IN ('SETTLED', 'REVERSED');
    ELSIF p_entity_type = 'GL_JOURNAL' THEN
      SELECT MAX(status_code) INTO l_st FROM gl_journal WHERE id = p_entity_id;
      RETURN l_st IN ('POSTED', 'REVERSED');
    END IF;
    RETURN FALSE;
  END entity_locked;

  FUNCTION type_for_entity(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2 IS
    l_t VARCHAR2(30);
    l_code VARCHAR2(50);
  BEGIN
    IF p_entity_type = 'CSH_TRANSACTION' THEN
      SELECT MAX(txn_type) INTO l_t FROM csh_transaction WHERE id = p_entity_id;
      RETURN CASE l_t WHEN 'RECEIPT' THEN 'RECEIPT_VOUCHER' WHEN 'EXPENSE' THEN 'EXPENSE_VOUCHER' ELSE 'PAYMENT_VOUCHER' END;
    ELSIF p_entity_type = 'GL_JOURNAL' THEN
      RETURN 'JOURNAL_SUPPORT';
    END IF;
    SELECT MAX(t.code) INTO l_code FROM dms_archive_rule r JOIN dms_document_type t ON t.id = r.document_type_id
     WHERE r.company_id = company AND r.entity_type = p_entity_type;
    RETURN NVL(l_code, 'GENERAL');
  END type_for_entity;

  -- ================================================================ التجهيز والقواعد
  PROCEDURE set_rule(p_entity_type IN VARCHAR2, p_type_code IN VARCHAR2, p_required IN VARCHAR2 DEFAULT 'Y',
                     p_require_file IN VARCHAR2 DEFAULT 'N', p_active IN VARCHAR2 DEFAULT 'Y') IS
    l_type dms_document_type%ROWTYPE := type_row(p_type_code);
  BEGIN
    guard('DMS_ARCHIVE_RULE.UPDATE');
    NOONA_CORE_PKG.assert(p_entity_type IS NOT NULL AND NVL(p_required, 'N') IN ('Y', 'N') AND NVL(p_require_file, 'N') IN ('Y', 'N'),
      'NOONA-DMS-103', 'قاعدة غير صالحة', 'Invalid rule');
    MERGE INTO dms_archive_rule r
    USING (SELECT company c, p_entity_type e FROM dual) x ON (r.company_id = x.c AND r.entity_type = x.e)
     WHEN MATCHED THEN UPDATE SET r.document_type_id = l_type.id, r.is_required = NVL(p_required, 'N'),
                                  r.require_file = NVL(p_require_file, 'N'), r.is_active = NVL(p_active, 'Y')
     WHEN NOT MATCHED THEN INSERT (company_id, entity_type, document_type_id, is_required, require_file, is_active)
          VALUES (company, p_entity_type, l_type.id, NVL(p_required, 'N'), NVL(p_require_file, 'N'), NVL(p_active, 'Y'));
    NOONA_AUDIT_PKG.log_event('CONFIG', 'DMS_ARCHIVE_RULE', NULL, 'SET_RULE', 'SUCCESS',
      p_new_values => '{"entity":' || NOONA_CORE_PKG.json_text(p_entity_type) || ',"required":"' || p_required
                      || '","file":"' || p_require_file || '"}');
  END set_rule;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
    l_c NUMBER;
  BEGIN
    guard('DMS_ARCHIVE_RULE.UPDATE');
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, 'DMS_ARCHIVE', EXTRACT(YEAR FROM SYSDATE), 'ARC-', 1, 6, 'Y', 'YEARLY', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = 'DMS_ARCHIVE'
                         AND (fiscal_year = EXTRACT(YEAR FROM SYSDATE) OR fiscal_year IS NULL));
    FOR r IN (SELECT 'CSH_TRANSACTION' e, 'PAYMENT_VOUCHER' t FROM dual UNION ALL SELECT 'GL_JOURNAL', 'JOURNAL_SUPPORT' FROM dual) LOOP
      SELECT COUNT(*) INTO l_c FROM dms_archive_rule WHERE company_id = company AND entity_type = r.e;
      IF l_c = 0 THEN
        set_rule(r.e, r.t, 'Y', 'N');
        l_n := l_n + 1;
      END IF;
    END LOOP;
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = 'DMS_ARCHIVE' AND ROWNUM = 1;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION create_type(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_category_code IN VARCHAR2 DEFAULT 'ADM',
                       p_mime IN VARCHAR2 DEFAULT NULL, p_max_mb IN NUMBER DEFAULT 20,
                       p_confidentiality IN VARCHAR2 DEFAULT 'INTERNAL') RETURN NUMBER IS
    l_cat NUMBER;
    l_id  NUMBER;
  BEGIN
    guard('DMS_DOCUMENT_TYPE.CREATE');
    NOONA_CORE_PKG.assert(p_code IS NOT NULL AND p_name_ar IS NOT NULL, 'NOONA-DMS-104', 'الرمز والاسم إلزاميان', 'Code and name required');
    NOONA_CORE_PKG.assert(NVL(p_max_mb, 20) BETWEEN 1 AND 100, 'NOONA-DMS-105', 'حد الحجم بين 1 و 100 ميجابايت', 'Size limit 1-100 MB');
    SELECT MIN(id) INTO l_cat FROM dms_category WHERE code = p_category_code;
    INSERT INTO dms_document_type (code, name_ar, category_id, default_confidentiality, allowed_mime_types, max_file_mb,
                                   allow_ocr, allow_ai_index, is_active)
    VALUES (UPPER(TRIM(p_code)), p_name_ar, l_cat, NVL(p_confidentiality, 'INTERNAL'),
            NVL(p_mime, 'application/pdf,image/png,image/jpeg,image/tiff,image/webp'), NVL(p_max_mb, 20), 'N', 'N', 'Y')
    RETURNING id INTO l_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'DMS_DOCUMENT_TYPE', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-DMS-106', 'رمز النوع مستخدم', 'Type code already exists');
  END create_type;

  -- ================================================================ الأرشفة
  FUNCTION store_content(p_type dms_document_type%ROWTYPE, p_file_name VARCHAR2, p_mime VARCHAR2, p_content BLOB) RETURN NUMBER IS
    l_size NUMBER := DBMS_LOB.GETLENGTH(p_content);
    l_mime VARCHAR2(200) := sniff_mime(p_content, LOWER(p_mime));
    l_id   NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(l_size > 0, 'NOONA-DMS-110', 'الملف فارغ', 'Empty file');
    NOONA_CORE_PKG.assert(l_size <= NVL(p_type.max_file_mb, c_max_mb) * 1048576, 'NOONA-DMS-111',
      'حجم الملف ' || size_text(l_size) || ' يتجاوز الحد ' || NVL(p_type.max_file_mb, c_max_mb) || ' MB', 'File too large');
    NOONA_CORE_PKG.assert(l_mime IS NOT NULL, 'NOONA-DMS-112',
      'نوع الملف غير مقبول؛ المسموح PDF والصور ومستندات Word/Excel الحديثة', 'File type not allowed');
    NOONA_CORE_PKG.assert(p_type.allowed_mime_types IS NULL OR INSTR(',' || p_type.allowed_mime_types || ',', ',' || l_mime || ',') > 0,
      'NOONA-DMS-113', 'نوع الملف غير مسموح لهذا النوع من المستندات (' || l_mime || ')', 'File type not allowed for this document type');
    INSERT INTO dms_file_content (storage_medium, content_blob, file_name, file_size_bytes, declared_mime, detected_mime,
                                  hash_algorithm, hash_value, scan_status, status_code)
    VALUES ('SECUREFILE', p_content, SUBSTR(NVL(p_file_name, 'document'), 1, 500), l_size, SUBSTR(p_mime, 1, 200), l_mime, 'SHA256',
            LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p_content, DBMS_CRYPTO.HASH_SH256))), 'SKIPPED', 'STORED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END store_content;

  PROCEDURE do_link(p_document_id NUMBER, p_entity_type VARCHAR2, p_entity_id NUMBER) IS
    l_lbl VARCHAR2(300) := entity_label(p_entity_type, p_entity_id);     -- يتحقق من وجوده في الشركة الحالية
  BEGIN
    MERGE INTO dms_document_link k
    USING (SELECT p_document_id d, p_entity_type e, p_entity_id i FROM dual) x
       ON (k.document_id = x.d AND k.entity_type = x.e AND k.entity_id = x.i AND k.link_role = 'SUPPORTING')
     WHEN MATCHED THEN UPDATE SET k.status_code = 'ACTIVE', k.detach_reason = NULL
     WHEN NOT MATCHED THEN INSERT (document_id, entity_type, entity_id, company_id, link_role, added_method, status_code)
          VALUES (p_document_id, p_entity_type, p_entity_id, company, 'SUPPORTING', 'MANUAL', 'ACTIVE');
  END do_link;

  FUNCTION archive_document(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_type_code IN VARCHAR2,
                            p_title IN VARCHAR2, p_external_ref IN VARCHAR2 DEFAULT NULL, p_location IN VARCHAR2 DEFAULT NULL,
                            p_doc_date IN DATE DEFAULT NULL, p_description IN VARCHAR2 DEFAULT NULL,
                            p_file_name IN VARCHAR2 DEFAULT NULL, p_mime IN VARCHAR2 DEFAULT NULL, p_content IN BLOB DEFAULT NULL,
                            p_confidentiality IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_type    dms_document_type%ROWTYPE;
    l_content NUMBER;
    l_doc     NUMBER;
    l_ver     NUMBER;
    l_no      VARCHAR2(100);
    l_title   VARCHAR2(500) := TRIM(p_title);
    l_hasfile BOOLEAN := p_content IS NOT NULL AND DBMS_LOB.GETLENGTH(p_content) > 0;
    l_origin  VARCHAR2(30) := CASE WHEN l_hasfile THEN 'COPY' ELSE 'AUTHENTIC' END;
    l_filej   VARCHAR2(5) := CASE WHEN l_hasfile THEN 'true' ELSE 'false' END;
  BEGIN
    guard('DMS_DOCUMENT.CREATE');
    l_type := type_row(NVL(p_type_code, CASE WHEN p_entity_type IS NOT NULL THEN type_for_entity(p_entity_type, p_entity_id) ELSE 'GENERAL' END));
    NOONA_CORE_PKG.assert(l_hasfile OR TRIM(p_external_ref) IS NOT NULL, 'NOONA-DMS-114',
      'أدخل المرجع الورقي (رقم الأصل) أو أرفق صورة المستند', 'Paper reference or file required');
    IF l_title IS NULL THEN
      l_title := l_type.name_ar || CASE WHEN p_external_ref IS NOT NULL THEN ' ' || p_external_ref END
              || CASE WHEN p_entity_type IS NOT NULL THEN ' - ' || entity_label(p_entity_type, p_entity_id) END;
    END IF;
    IF l_hasfile THEN
      l_content := store_content(l_type, p_file_name, p_mime, p_content);
    END IF;
    l_no := NOONA_REFERENCE_PKG.next_doc_no('DMS_ARCHIVE', company, NULL, NVL(p_doc_date, TRUNC(SYSDATE)), 'DMS_DOCUMENT', NULL);
    INSERT INTO dms_document (company_id, branch_id, document_type_id, reference_no, external_ref, physical_location, title, description,
                              origin_type, owner_member_id, document_date, status_code, confidentiality_level)
    VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_type.id, l_no, TRIM(p_external_ref), TRIM(p_location),
            SUBSTR(l_title, 1, 500), p_description, l_origin,
            TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), NVL(p_doc_date, TRUNC(SYSDATE)), 'ACTIVE',
            NVL(p_confidentiality, l_type.default_confidentiality))
    RETURNING id INTO l_doc;
    IF l_hasfile THEN
      INSERT INTO dms_document_version (document_id, version_no, content_id, change_type, uploaded_by_member_id, uploaded_at, status_code)
      VALUES (l_doc, 1, l_content, 'INITIAL', TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), SYSTIMESTAMP, 'CURRENT')
      RETURNING id INTO l_ver;
      UPDATE dms_document SET current_version_id = l_ver WHERE id = l_doc;
    END IF;
    IF p_entity_type IS NOT NULL THEN
      do_link(l_doc, p_entity_type, p_entity_id);
    END IF;
    NOONA_AUDIT_PKG.log_event('DOCUMENT', 'DMS_DOCUMENT', l_doc, 'ARCHIVE', 'SUCCESS',
      p_new_values => '{"archive_no":' || NOONA_CORE_PKG.json_text(l_no) || ',"entity":' || NOONA_CORE_PKG.json_text(p_entity_type)
                      || ',"entity_id":' || NVL(TO_CHAR(p_entity_id), 'null') || ',"file":' || l_filej || '}');
    RETURN l_doc;
  END archive_document;

  FUNCTION add_version(p_document_id IN NUMBER, p_file_name IN VARCHAR2, p_mime IN VARCHAR2, p_content IN BLOB,
                       p_reason IN VARCHAR2) RETURN NUMBER IS
    l_doc  dms_document%ROWTYPE;
    l_type dms_document_type%ROWTYPE;
    l_cnt  NUMBER;
    l_ver  NUMBER;
    l_no   NUMBER;
  BEGIN
    guard('DMS_DOCUMENT.UPDATE');
    BEGIN
      SELECT * INTO l_doc FROM dms_document WHERE id = p_document_id AND company_id = company AND is_deleted = 'N' FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-DMS-120', 'المستند غير موجود', 'Document not found');
    END;
    NOONA_CORE_PKG.assert(l_doc.legal_hold = 'N', 'NOONA-DMS-121', 'المستند تحت حجز قانوني', 'Document under legal hold');
    NOONA_CORE_PKG.assert(p_content IS NOT NULL AND DBMS_LOB.GETLENGTH(p_content) > 0, 'NOONA-DMS-110', 'الملف فارغ', 'Empty file');
    SELECT * INTO l_type FROM dms_document_type WHERE id = l_doc.document_type_id;
    l_cnt := store_content(l_type, p_file_name, p_mime, p_content);
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_no FROM dms_document_version WHERE document_id = p_document_id;
    UPDATE dms_document_version SET status_code = 'SUPERSEDED' WHERE document_id = p_document_id AND status_code = 'CURRENT';
    INSERT INTO dms_document_version (document_id, version_no, content_id, change_type, change_reason, source_version_id,
                                      uploaded_by_member_id, uploaded_at, status_code)
    VALUES (p_document_id, l_no, l_cnt, CASE WHEN l_no = 1 THEN 'INITIAL' ELSE 'REVISION' END, p_reason, l_doc.current_version_id,
            TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), SYSTIMESTAMP, 'CURRENT')
    RETURNING id INTO l_ver;
    UPDATE dms_document SET current_version_id = l_ver WHERE id = p_document_id;
    NOONA_AUDIT_PKG.log_event('DOCUMENT', 'DMS_DOCUMENT', p_document_id, 'NEW_VERSION', 'SUCCESS', p_reason => p_reason);
    RETURN l_ver;
  END add_version;

  PROCEDURE link_document(p_document_id IN NUMBER, p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) IS
    l_n NUMBER;
  BEGIN
    guard('DMS_DOCUMENT.UPDATE');
    SELECT COUNT(*) INTO l_n FROM dms_document WHERE id = p_document_id AND company_id = company AND is_deleted = 'N';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-DMS-120', 'المستند غير موجود', 'Document not found');
    do_link(p_document_id, p_entity_type, p_entity_id);
    NOONA_AUDIT_PKG.log_event('DOCUMENT', 'DMS_DOCUMENT', p_document_id, 'LINK', 'SUCCESS',
      p_new_values => '{"entity":' || NOONA_CORE_PKG.json_text(p_entity_type) || ',"entity_id":' || p_entity_id || '}');
  END link_document;

  PROCEDURE detach(p_document_id IN NUMBER, p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_reason IN VARCHAR2) IS
  BEGIN
    guard('DMS_DOCUMENT.UPDATE');
    NOONA_CORE_PKG.assert(p_reason IS NOT NULL, 'NOONA-DMS-130', 'سبب الفصل إلزامي', 'Reason required');
    NOONA_CORE_PKG.assert(NOT entity_locked(p_entity_type, p_entity_id), 'NOONA-DMS-131',
      'لا يفصل المستند عن مستند أعمال مرحل؛ يبقى مرجعاً له', 'Cannot detach from a posted document');
    UPDATE dms_document_link SET status_code = 'DETACHED', detach_reason = p_reason
     WHERE document_id = p_document_id AND entity_type = p_entity_type AND entity_id = p_entity_id AND status_code = 'ACTIVE';
    NOONA_AUDIT_PKG.log_event('DOCUMENT', 'DMS_DOCUMENT', p_document_id, 'DETACH', 'SUCCESS', p_reason => p_reason);
  END detach;

  -- ================================================================ المرجع الورقي قبل الاعتماد
  FUNCTION has_reference(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2 IS
    l_rule dms_archive_rule%ROWTYPE;
    l_n    NUMBER;
  BEGIN
    BEGIN
      SELECT * INTO l_rule FROM dms_archive_rule
       WHERE company_id = company AND entity_type = p_entity_type AND is_active = 'Y' AND is_required = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 'Y';                                                -- لا قاعدة إلزامية
    END;
    SELECT COUNT(*) INTO l_n
      FROM dms_document_link k JOIN dms_document d ON d.id = k.document_id
     WHERE k.entity_type = p_entity_type AND k.entity_id = p_entity_id AND k.status_code = 'ACTIVE'
       AND d.is_deleted = 'N' AND d.status_code = 'ACTIVE'
       AND (CASE WHEN l_rule.require_file = 'Y' THEN CASE WHEN d.current_version_id IS NOT NULL THEN 1 ELSE 0 END
                 ELSE CASE WHEN d.current_version_id IS NOT NULL OR d.external_ref IS NOT NULL THEN 1 ELSE 0 END END) = 1;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END has_reference;

  PROCEDURE assert_reference(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) IS
    l_file VARCHAR2(1);
  BEGIN
    IF has_reference(p_entity_type, p_entity_id) = 'N' THEN
      SELECT MAX(require_file) INTO l_file FROM dms_archive_rule WHERE company_id = company AND entity_type = p_entity_type;
      NOONA_CORE_PKG.raise_error('NOONA-DMS-200',
        CASE WHEN l_file = 'Y' THEN 'أرشف صورة الأصل الورقي للمستند قبل الاعتماد (قاعدة الأرشفة تتطلب الملف)'
             ELSE 'سجل المرجع الورقي للمستند (رقم الأصل أو صورته) في الأرشيف قبل الاعتماد' END,
        'A paper reference must be archived before approval');
    END IF;
  END assert_reference;

  -- ================================================================ التنزيل
  PROCEDURE log_access(p_doc NUMBER, p_ver NUMBER, p_type VARCHAR2, p_result VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO dms_access_log (tenant_id, document_id, version_id, membership_id, access_type, result_code, channel, correlation_id)
    VALUES (TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID')), p_doc, p_ver, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')),
            p_type, p_result, 'APEX', SYS_CONTEXT('NOONA_CTX', 'CORRELATION_ID'));
    COMMIT;
  END log_access;

  PROCEDURE download(p_document_id IN NUMBER, p_version_id IN NUMBER DEFAULT NULL) IS
    l_doc  dms_document%ROWTYPE;
    l_blob BLOB;
    l_mime VARCHAR2(200);
    l_name VARCHAR2(500);
    l_ver  NUMBER;
    l_ok   BOOLEAN;
  BEGIN
    BEGIN
      SELECT * INTO l_doc FROM dms_document WHERE id = p_document_id AND company_id = company AND is_deleted = 'N';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      owa_util.status_line(404, 'Not Found');
      RETURN;
    END;
    l_ok := NOONA_SECURITY_PKG.has_permission('DMS_DOCUMENT.VIEW', company) = 'Y'
            AND (l_doc.confidentiality_level NOT IN ('SECRET', 'HIGHLY_RESTRICTED') OR NOONA_APEX_PKG.is_tenant_admin = 'Y'
                 OR l_doc.owner_member_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')));
    l_ver := NVL(p_version_id, l_doc.current_version_id);
    IF NOT l_ok THEN
      log_access(p_document_id, l_ver, 'DOWNLOAD', 'DENIED');
      owa_util.status_line(403, 'Forbidden');
      RETURN;
    END IF;
    SELECT c.content_blob, c.detected_mime, c.file_name INTO l_blob, l_mime, l_name
      FROM dms_document_version v JOIN dms_file_content c ON c.id = v.content_id
     WHERE v.id = l_ver AND v.document_id = p_document_id;
    log_access(p_document_id, l_ver, 'DOWNLOAD', 'ALLOWED');
    owa_util.mime_header(l_mime, FALSE);
    htp.p('Content-Length: ' || DBMS_LOB.GETLENGTH(l_blob));
    htp.p('Content-Disposition: inline; filename="' || REGEXP_REPLACE(l_name, '[^[:alnum:]._ -]', '_') || '"; filename*=UTF-8''''' || UTL_URL.ESCAPE(l_name, TRUE, 'UTF-8'));
    htp.p('X-Content-Type-Options: nosniff');
    htp.p('Cache-Control: private, no-store');
    owa_util.http_header_close;
    wpg_docload.download_file(l_blob);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    owa_util.status_line(404, 'Not Found');
  END download;

  -- ================================================================ الواجهة
  FUNCTION refs_text(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT LISTAGG(d.reference_no || CASE WHEN d.external_ref IS NOT NULL THEN ' (' || d.external_ref || ')' END, '، ')
             WITHIN GROUP (ORDER BY d.id)
      INTO l
      FROM dms_document_link k JOIN dms_document d ON d.id = k.document_id
     WHERE k.entity_type = p_entity_type AND k.entity_id = p_entity_id AND k.status_code = 'ACTIVE' AND d.is_deleted = 'N';
    RETURN l;
  END refs_text;

  FUNCTION attachments_html(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    l_cnt  PLS_INTEGER := 0;
    l_req  VARCHAR2(1);
    l_file VARCHAR2(1);
  BEGIN
    IF p_entity_id IS NULL THEN RETURN NULL; END IF;
    SELECT MAX(CASE WHEN is_active = 'Y' THEN is_required END), MAX(require_file) INTO l_req, l_file
      FROM dms_archive_rule WHERE company_id = company AND entity_type = p_entity_type;
    l_html := '<table class="nn-rpt nn-att"><thead><tr><th>رقم الأرشيف</th><th>النوع</th><th>المرجع الورقي</th><th>العنوان</th>'
           || '<th>موقع الأصل</th><th>الملف</th><th>أرشفه</th></tr></thead><tbody>';
    FOR r IN (SELECT d.id, d.reference_no, t.name_ar tname, d.external_ref, d.title, d.physical_location, d.created_by, d.created_at,
                     c.file_name, c.file_size_bytes, v.version_no
                FROM dms_document_link k JOIN dms_document d ON d.id = k.document_id JOIN dms_document_type t ON t.id = d.document_type_id
                LEFT JOIN dms_document_version v ON v.id = d.current_version_id LEFT JOIN dms_file_content c ON c.id = v.content_id
               WHERE k.entity_type = p_entity_type AND k.entity_id = p_entity_id AND k.status_code = 'ACTIVE' AND d.is_deleted = 'N'
               ORDER BY d.id) LOOP
      l_cnt := l_cnt + 1;
      l_html := l_html || '<tr><td class="nn-num-code">' || esc(r.reference_no) || '</td><td class="nn-rpt-text">' || esc(r.tname)
             || '</td><td class="nn-rpt-text">' || esc(r.external_ref) || '</td><td class="nn-rpt-text">' || esc(r.title)
             || '</td><td class="nn-rpt-text">' || esc(r.physical_location) || '</td><td class="nn-rpt-text">'
             || CASE WHEN r.file_name IS NULL THEN '<span class="nn-badge is-muted">أصل ورقي فقط</span>'
                     WHEN p_link IS NULL THEN esc(r.file_name)
                     ELSE '<a class="nn-drill" target="_blank" rel="noopener" href="' || esc(REPLACE(p_link, '#ID#', r.id)) || '">'
                          || '<span class="fa fa-paperclip" aria-hidden="true"></span> ' || esc(r.file_name) || '</a>' END
             || CASE WHEN r.file_size_bytes IS NOT NULL THEN ' <small>' || size_text(r.file_size_bytes)
                     || CASE WHEN r.version_no > 1 THEN ' - إصدار ' || r.version_no END || '</small>' END
             || '</td><td>' || esc(r.created_by) || '<br><small>' || TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI') || '</small></td></tr>';
    END LOOP;
    IF l_cnt = 0 THEN
      l_html := l_html || '<tr><td colspan="7" class="nn-rpt-text">لا توجد مستندات مؤرشفة لهذا المستند</td></tr>';
    END IF;
    l_html := l_html || '</tbody></table>';
    IF l_req = 'Y' THEN
      l_html := l_html || CASE WHEN has_reference(p_entity_type, p_entity_id) = 'Y'
        THEN '<div class="nn-chain is-ok nn-rpt-check"><span class="fa fa-check-circle" aria-hidden="true"></span><div><b>المرجع الورقي مسجل؛ المستند جاهز للاعتماد</b></div></div>'
        ELSE '<div class="nn-chain is-bad nn-rpt-check"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div><b>'
             || CASE WHEN l_file = 'Y' THEN 'قاعدة الأرشفة تتطلب صورة الأصل الورقي قبل الاعتماد'
                     ELSE 'قاعدة الأرشفة تتطلب تسجيل المرجع الورقي (رقم الأصل أو صورته) قبل الاعتماد' END || '</b></div></div>' END;
    END IF;
    RETURN l_html;
  END attachments_html;

  FUNCTION document_html(p_document_id IN NUMBER, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_d    dms_document%ROWTYPE;
    l_t    dms_document_type%ROWTYPE;
    l_html CLOB;
    FUNCTION fld(p_l VARCHAR2, p_v VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<div class="nn-field"><div class="nn-field-label">' || p_l || '</div><div class="nn-field-value">' || NVL(p_v, '-') || '</div></div>';
    END fld;
  BEGIN
    NOONA_SECURITY_PKG.assert_permission('DMS_DOCUMENT.VIEW', company);
    IF p_document_id IS NULL THEN RETURN '<div class="nn-empty">اختر مستنداً</div>'; END IF;
    BEGIN
      SELECT * INTO l_d FROM dms_document WHERE id = p_document_id AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-DMS-120', 'المستند غير موجود', 'Document not found');
    END;
    SELECT * INTO l_t FROM dms_document_type WHERE id = l_d.document_type_id;
    l_html := '<div class="nn-taskhead"><div class="nn-taskhead-top"><div><div class="nn-taskhead-title">' || esc(l_d.reference_no)
           || ' - ' || esc(l_d.title) || '</div><div class="nn-taskhead-sub">' || esc(l_t.name_ar) || '</div></div>'
           || NOONA_UI_PKG.status_badge(l_d.status_code) || '</div><div class="nn-fields">'
           || fld('رقم الأرشيف', esc(l_d.reference_no)) || fld('المرجع الورقي', esc(l_d.external_ref))
           || fld('موقع الأصل الورقي', esc(l_d.physical_location)) || fld('تاريخ المستند', TO_CHAR(l_d.document_date, 'YYYY-MM-DD'))
           || fld('السرية', esc(NOONA_UI_PKG.code_label(l_d.confidentiality_level))) || fld('أرشفه', esc(l_d.created_by)
           || ' ' || TO_CHAR(l_d.created_at, 'YYYY-MM-DD HH24:MI')) || '</div>'
           || CASE WHEN l_d.description IS NOT NULL THEN '<div class="nn-words-sub">' || esc(l_d.description) || '</div>' END || '</div>'
           || '<h3 class="nn-rpt-h">الإصدارات</h3><table class="nn-rpt"><thead><tr><th>الإصدار</th><th>الملف</th><th>الحجم</th>'
           || '<th>البصمة SHA-256</th><th>السبب</th><th>الحالة</th><th>الوقت</th></tr></thead><tbody>';
    FOR r IN (SELECT v.id, v.version_no, c.file_name, c.file_size_bytes, c.hash_value, v.change_reason, v.status_code, v.uploaded_at
                FROM dms_document_version v JOIN dms_file_content c ON c.id = v.content_id
               WHERE v.document_id = p_document_id ORDER BY v.version_no DESC) LOOP
      l_html := l_html || '<tr><td>' || r.version_no || '</td><td class="nn-rpt-text">'
             || CASE WHEN p_link IS NULL THEN esc(r.file_name)
                     ELSE '<a class="nn-drill" target="_blank" rel="noopener" href="' || esc(REPLACE(REPLACE(p_link, '#ID#', p_document_id), '#VER#', r.id))
                          || '">' || esc(r.file_name) || '</a>' END
             || '</td><td>' || size_text(r.file_size_bytes) || '</td><td class="nn-hash">' || SUBSTR(r.hash_value, 1, 16) || '…</td><td class="nn-rpt-text">'
             || esc(r.change_reason) || '</td><td>' || NOONA_UI_PKG.status_badge(r.status_code) || '</td><td>'
             || TO_CHAR(r.uploaded_at, 'YYYY-MM-DD HH24:MI') || '</td></tr>';
    END LOOP;
    l_html := l_html || '</tbody></table><h3 class="nn-rpt-h">مرتبط بـ</h3><table class="nn-rpt"><thead><tr><th>المستند</th><th>الحالة</th>'
           || '<th>سبب الفصل</th></tr></thead><tbody>';
    FOR r IN (SELECT entity_type, entity_id, status_code, detach_reason FROM dms_document_link WHERE document_id = p_document_id ORDER BY id) LOOP
      l_html := l_html || '<tr><td class="nn-rpt-text">' || esc(entity_label(r.entity_type, r.entity_id)) || '</td><td>'
             || NOONA_UI_PKG.status_badge(r.status_code) || '</td><td class="nn-rpt-text">' || esc(r.detach_reason) || '</td></tr>';
    END LOOP;
    l_html := l_html || '</tbody></table><h3 class="nn-rpt-h">سجل الوصول</h3><table class="nn-rpt"><thead><tr><th>الوقت</th><th>الإجراء</th>'
           || '<th>المستخدم</th><th>النتيجة</th></tr></thead><tbody>';
    FOR r IN (SELECT l.created_at, l.access_type, NVL(u.username, l.created_by) who, l.result_code
                FROM dms_access_log l LEFT JOIN sec_user_membership m ON m.id = l.membership_id LEFT JOIN sec_user u ON u.id = m.user_id
               WHERE l.document_id = p_document_id ORDER BY l.id DESC FETCH FIRST 30 ROWS ONLY) LOOP
      l_html := l_html || '<tr><td>' || TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI') || '</td><td>'
             || CASE r.access_type WHEN 'DOWNLOAD' THEN 'تنزيل/عرض' ELSE r.access_type END || '</td><td>' || esc(r.who) || '</td><td>'
             || CASE r.result_code WHEN 'ALLOWED' THEN '<span class="nn-badge is-success">مسموح</span>' ELSE '<span class="nn-badge is-danger">مرفوض</span>' END
             || '</td></tr>';
    END LOOP;
    RETURN l_html || '</tbody></table>';
  END document_html;

  FUNCTION summary(p_session IN VARCHAR2) RETURN CLOB IS
    l_all NUMBER; l_month NUMBER; l_paper NUMBER; l_bytes NUMBER; l_missing NUMBER := 0;
    FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span>'
          || '<div><div class="nn-kpi-value">' || esc(p_value) || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
    END kpi;
  BEGIN
    SELECT COUNT(*), COUNT(CASE WHEN d.created_at >= TRUNC(SYSDATE, 'MM') THEN 1 END),
           COUNT(CASE WHEN d.current_version_id IS NULL THEN 1 END), NVL(SUM(c.file_size_bytes), 0)
      INTO l_all, l_month, l_paper, l_bytes
      FROM dms_document d LEFT JOIN dms_document_version v ON v.id = d.current_version_id LEFT JOIN dms_file_content c ON c.id = v.content_id
     WHERE d.company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')) AND d.is_deleted = 'N' AND d.status_code = 'ACTIVE';
    -- مستندات أعمال قاعدتها إلزامية ولم يسجل مرجعها بعد (غير المرحلة)
    FOR r IN (SELECT entity_type FROM dms_archive_rule WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'))
                AND is_active = 'Y' AND is_required = 'Y') LOOP
      IF r.entity_type = 'CSH_TRANSACTION' THEN
        FOR t IN (SELECT id FROM csh_transaction WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'))
                     AND status_code = 'SUBMITTED') LOOP
          IF has_reference('CSH_TRANSACTION', t.id) = 'N' THEN l_missing := l_missing + 1; END IF;
        END LOOP;
      ELSIF r.entity_type = 'GL_JOURNAL' THEN
        FOR t IN (SELECT id FROM gl_journal WHERE company_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'))
                     AND status_code = 'SUBMITTED') LOOP
          IF has_reference('GL_JOURNAL', t.id) = 'N' THEN l_missing := l_missing + 1; END IF;
        END LOOP;
      END IF;
    END LOOP;
    RETURN '<div class="nn-kpis">'
        || kpi('المستندات المؤرشفة', l_all, 'fa-archive', 'is-info')
        || kpi('أرشفت هذا الشهر', l_month, 'fa-calendar-check-o', 'is-success')
        || kpi('أصول ورقية دون صورة', l_paper, 'fa-file-o', 'is-muted')
        || kpi('مستندات بانتظار مرجعها الورقي', l_missing, 'fa-exclamation-triangle', CASE WHEN l_missing > 0 THEN 'is-warning' ELSE 'is-muted' END)
        || kpi('حجم الأرشيف', NVL(size_text(l_bytes), '0'), 'fa-database', 'is-muted')
        || '</div>';
  END summary;

END NOONA_DMS_PKG;
/
