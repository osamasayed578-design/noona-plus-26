-- =============================================================================
-- NOONA PLUS ERP | NOONA_PTY_PKG - الأطراف (الهوية الموحدة للموردين والعملاء وغيرهم)
--   * طرف واحد بأدوار متعددة (مورد/عميل/مقاول...) على مستوى المؤسسة أو الشركة
--   * التحقق من الرقم الضريبي السعودي (15 رقماً يبدأ وينتهي بـ 3) ومنع تكرار الرقم الضريبي والسجل التجاري
--   * مستندات وشهادات الطرف تؤرشف عبر NOONA_DMS_PKG (نوع الكيان PTY_PARTY)
-- نواة مرحلة المشتريات والموردين والمبيعات والعملاء.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PTY_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- p_type: ORGANIZATION / PERSON ؛ p_role: SUPPLIER / CUSTOMER / CONTRACTOR ... ؛ يعيد رقم الطرف
  FUNCTION create_party(p_type IN VARCHAR2, p_name_ar IN VARCHAR2, p_role IN VARCHAR2 DEFAULT NULL,
                        p_name_en IN VARCHAR2 DEFAULT NULL, p_tax_number IN VARCHAR2 DEFAULT NULL,
                        p_cr_number IN VARCHAR2 DEFAULT NULL, p_country IN VARCHAR2 DEFAULT 'SA') RETURN NUMBER;
  PROCEDURE add_role(p_party_id IN NUMBER, p_role IN VARCHAR2);
  FUNCTION role_label(p_role IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  FUNCTION party_roles(p_party_id IN NUMBER) RETURN VARCHAR2;
END NOONA_PTY_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PTY_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION role_label(p_role IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN CASE p_role WHEN 'SUPPLIER' THEN 'مورد' WHEN 'CUSTOMER' THEN 'عميل' WHEN 'CONTRACTOR' THEN 'مقاول'
                       WHEN 'EMPLOYEE' THEN 'موظف' WHEN 'PARTNER' THEN 'شريك' WHEN 'LESSEE' THEN 'مستأجر'
                       WHEN 'LANDLORD' THEN 'مؤجر' WHEN 'BANK' THEN 'بنك' WHEN 'GOVERNMENT_AUTHORITY' THEN 'جهة حكومية'
                       ELSE p_role END;
  END role_label;

  PROCEDURE add_role(p_party_id IN NUMBER, p_role IN VARCHAR2) IS
    l_n NUMBER;
  BEGIN
    guard('PTY_PARTY_ROLE.CREATE');
    SELECT COUNT(*) INTO l_n FROM pty_party_role WHERE party_id = p_party_id AND role_code = p_role AND company_id = company;
    IF l_n = 0 THEN
      INSERT INTO pty_party_role (party_id, role_code, company_id, status_code) VALUES (p_party_id, p_role, company, 'ACTIVE');
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PTY_PARTY', p_party_id, 'ADD_ROLE', 'SUCCESS', p_new_values => '{"role":"' || p_role || '"}');
    END IF;
  END add_role;

  FUNCTION create_party(p_type IN VARCHAR2, p_name_ar IN VARCHAR2, p_role IN VARCHAR2 DEFAULT NULL,
                        p_name_en IN VARCHAR2 DEFAULT NULL, p_tax_number IN VARCHAR2 DEFAULT NULL,
                        p_cr_number IN VARCHAR2 DEFAULT NULL, p_country IN VARCHAR2 DEFAULT 'SA') RETURN NUMBER IS
    l_id  NUMBER;
    l_tax VARCHAR2(50) := REPLACE(TRIM(p_tax_number), ' ');
    l_cr  VARCHAR2(50) := REPLACE(TRIM(p_cr_number), ' ');
    l_n   NUMBER;
  BEGIN
    guard('PTY_PARTY.CREATE');
    NOONA_CORE_PKG.assert(p_type IN ('ORGANIZATION', 'PERSON') AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-PTY-001',
      'النوع والاسم إلزاميان', 'Type and name are required');
    NOONA_CORE_PKG.assert(l_tax IS NULL OR NVL(p_country, 'SA') <> 'SA' OR REGEXP_LIKE(l_tax, '^3[0-9]{13}3$'), 'NOONA-PTY-002',
      'الرقم الضريبي السعودي 15 رقماً يبدأ وينتهي بالرقم 3', 'Invalid Saudi VAT number');
    IF l_tax IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM pty_party WHERE tax_number = l_tax AND status_code <> 'MERGED';
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PTY-003', 'يوجد طرف مسجل بنفس الرقم الضريبي', 'Duplicate VAT number');
    END IF;
    IF l_cr IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM pty_organization WHERE cr_number = l_cr;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-PTY-004', 'يوجد طرف مسجل بنفس رقم السجل التجاري', 'Duplicate CR number');
    END IF;
    INSERT INTO pty_party (party_no, party_type, display_name_ar, display_name_en, ownership_scope, owner_company_id, tax_number,
                           country_code, status_code)
    VALUES ('NEW-' || RAWTOHEX(SYS_GUID()), p_type, TRIM(p_name_ar), p_name_en, 'TENANT_SHARED', company, l_tax,
            NVL(p_country, 'SA'), 'ACTIVE')
    RETURNING id INTO l_id;
    UPDATE pty_party SET party_no = 'P-' || LPAD(l_id, 6, '0') WHERE id = l_id;
    IF p_type = 'ORGANIZATION' THEN
      INSERT INTO pty_organization (party_id, legal_name_ar, legal_name_en, cr_number) VALUES (l_id, TRIM(p_name_ar), p_name_en, l_cr);
    ELSE
      INSERT INTO pty_person (party_id, first_name_ar) VALUES (l_id, TRIM(p_name_ar));
    END IF;
    IF p_role IS NOT NULL THEN
      add_role(l_id, p_role);
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PTY_PARTY', l_id, 'CREATE', 'SUCCESS');
    RETURN l_id;
  END create_party;

  FUNCTION party_roles(p_party_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT LISTAGG(DISTINCT role_label(role_code), '، ') WITHIN GROUP (ORDER BY role_code) INTO l
      FROM pty_party_role WHERE party_id = p_party_id AND status_code = 'ACTIVE';
    RETURN l;
  END party_roles;

END NOONA_PTY_PKG;
/
