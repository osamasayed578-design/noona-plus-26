-- =============================================================================
-- NOONA PLUS ERP | مؤسسة تجريبية للتطوير فقط (لا تشغل في الإنتاج)
-- تنشئ: Tenant (DEMO) + مجموعة + شركة سعودية + فرع رئيسي + مستخدم مسؤول ADMIN
--       + دور مسؤول المؤسسة بكل صلاحيات المؤسسة + تقويم وسنة مالية 2026 بفتراتها
--       + مستخدم مسؤول منصة PLATFORM (لتجربة تجهيز المؤسسات provision_tenant).
-- كلمة المرور تدار عبر APEX Accounts / مزود الهوية؛ لا تخزن هنا.
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
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
  l_tenant   NUMBER;
  l_group    NUMBER;
  l_company  NUMBER;
  l_branch   NUMBER;
  l_user     NUMBER;
  l_party    NUMBER;
  l_member   NUMBER;
  l_role     NUMBER;
  l_grant    NUMBER;
  l_cal      NUMBER;
  l_year     NUMBER;
BEGIN
  NOONA_CTX_PKG.enable_system_mode;      -- تجاوز VPD لعملية التجهيز فقط

  INSERT INTO plt_tenant (tenant_code, tenant_slug, name_ar, name_en, status_code, isolation_tier,
                          deployment_model, country_code, default_language, default_timezone, base_currency,
                          home_region_id, cell_id, activated_at)
  VALUES ('DEMO', 'demo', 'مؤسسة نونا التجريبية', 'NOONA Demo Tenant', 'ACTIVE', 'SHARED', 'SAAS', 'SA', 'ar',
          'Asia/Riyadh', 'SAR', (SELECT id FROM plt_region WHERE code = 'GCC-SA'),
          (SELECT id FROM plt_cell WHERE code = 'CELL-SA-01'), SYSTIMESTAMP)
  RETURNING id INTO l_tenant;

  INSERT INTO org_business_group (tenant_id, code, name_ar, name_en, status_code, consolidation_currency)
  VALUES (l_tenant, 'DEMO-GRP', 'مجموعة نونا التجريبية', 'NOONA Demo Group', 'ACTIVE', 'SAR')
  RETURNING id INTO l_group;

  INSERT INTO org_company (tenant_id, business_group_id, code, legal_name_ar, legal_name_en, trade_name_ar,
                           country_code, country_pack_id, functional_currency, default_language, timezone_code,
                           status_code)
  VALUES (l_tenant, l_group, 'DEMO-SA', 'شركة نونا التجريبية للتجارة', 'NOONA Demo Trading Co.', 'نونا التجريبية',
          'SA', (SELECT id FROM loc_country_pack WHERE country_code = 'SA' AND version_no = 1), 'SAR', 'ar',
          'Asia/Riyadh', 'ACTIVE')
  RETURNING id INTO l_company;

  INSERT INTO org_branch (tenant_id, company_id, code, name_ar, name_en, branch_type, is_head_office,
                          country_code, timezone_code, currency_code, status_code)
  VALUES (l_tenant, l_company, 'HQ', 'المركز الرئيسي - الرياض', 'Head Office - Riyadh', 'HEAD_OFFICE', 'Y',
          'SA', 'Asia/Riyadh', 'SAR', 'ACTIVE')
  RETURNING id INTO l_branch;

  INSERT INTO pty_party (tenant_id, party_no, party_type, display_name_ar, display_name_en, country_code)
  VALUES (l_tenant, 'P-000001', 'PERSON', 'مسؤول النظام', 'System Administrator', 'SA')
  RETURNING id INTO l_party;

  INSERT INTO sec_user (username, email, display_name, user_type, preferred_language, timezone_code,
                        mfa_required, status_code)
  VALUES ('ADMIN', 'admin@demo.noona.local', 'مسؤول النظام', 'TENANT_ADMIN', 'ar', 'Asia/Riyadh', 'N', 'ACTIVE')
  RETURNING id INTO l_user;

  INSERT INTO sec_user_membership (tenant_id, user_id, person_party_id, default_company_id, default_branch_id,
                                   clearance_level, is_tenant_admin, status_code)
  VALUES (l_tenant, l_user, l_party, l_company, l_branch, 'SECRET', 'Y', 'ACTIVE')
  RETURNING id INTO l_member;

  INSERT INTO sec_role (tenant_id, code, name_ar, name_en, role_type, is_privileged, status_code)
  VALUES (l_tenant, 'TENANT_ADMIN', 'مسؤول المؤسسة', 'Tenant Administrator', 'TENANT', 'Y', 'ACTIVE')
  RETURNING id INTO l_role;

  -- كل الصلاحيات عدا صلاحيات إدارة المنصة (VIEW/CONFIGURE على جداول النطاق العام)
  INSERT INTO sec_role_permission (tenant_id, role_id, permission_id, effect)
  SELECT l_tenant, l_role, p.id, 'ALLOW'
    FROM sec_permission p
   WHERE p.action_code <> 'CONFIGURE';

  INSERT INTO sec_role_grant (tenant_id, membership_id, role_id, grant_source, reason, approved_by, status_code)
  VALUES (l_tenant, l_member, l_role, 'MANUAL', 'Demo tenant bootstrap', 'SYSTEM', 'ACTIVE')
  RETURNING id INTO l_grant;

  INSERT INTO sec_data_scope (tenant_id, role_grant_id, scope_type)
  VALUES (l_tenant, l_grant, 'ALL_TENANT');
  -- دور مسؤول الشركة (كما عند تجهيز مؤسسة من المنصة)
  NOONA_PLATFORM_PKG.ensure_company_admin_role(l_tenant);

  -- التقويم المالي 2026 (12 شهراً)
  INSERT INTO gl_fiscal_calendar (tenant_id, company_id, code, name_ar, name_en, period_pattern)
  VALUES (l_tenant, l_company, 'GREG-12', 'التقويم الميلادي 12 شهراً', 'Gregorian 12 months', 'MONTHLY_12')
  RETURNING id INTO l_cal;

  INSERT INTO gl_fiscal_year (tenant_id, company_id, calendar_id, code, name_ar, name_en, start_date, end_date,
                              status_code)
  VALUES (l_tenant, l_company, l_cal, 'FY2026', 'السنة المالية 2026', 'Fiscal Year 2026',
          DATE '2026-01-01', DATE '2026-12-31', 'OPEN')
  RETURNING id INTO l_year;

  FOR m IN 1 .. 12 LOOP
    INSERT INTO gl_period (tenant_id, company_id, fiscal_year_id, period_no, period_code, period_type,
                           start_date, end_date, name_ar, name_en)
    VALUES (l_tenant, l_company, l_year, m, '2026-' || LPAD(m, 2, '0'), 'NORMAL',
            ADD_MONTHS(DATE '2026-01-01', m - 1), LAST_DAY(ADD_MONTHS(DATE '2026-01-01', m - 1)),
            'الفترة ' || m || ' - 2026', 'Period ' || m || ' 2026');
  END LOOP;

  -- تسلسلات المستندات الأساسية
  FOR d IN (SELECT 'SAL_INVOICE' doc, 'INV-' pfx, 'Y' gapless FROM dual UNION ALL
            SELECT 'SAL_ORDER', 'SO-', 'N' FROM dual UNION ALL
            SELECT 'PUR_ORDER', 'PO-', 'N' FROM dual UNION ALL
            SELECT 'GL_JOURNAL', 'JV-', 'Y' FROM dual UNION ALL
            SELECT 'AR_RECEIPT', 'RV-', 'Y' FROM dual UNION ALL
            SELECT 'AP_PAYMENT', 'PV-', 'Y' FROM dual UNION ALL
            SELECT 'COR_CORRESPONDENCE', 'COR-', 'N' FROM dual) LOOP
    INSERT INTO ref_doc_sequence (tenant_id, company_id, doc_type_code, fiscal_year, prefix, next_number, padding,
                                  is_gapless, reset_policy)
    VALUES (l_tenant, l_company, d.doc, 2026, d.pfx, 1, 6, d.gapless, 'YEARLY');
  END LOOP;

  -- مسؤول المنصة (بلا عضوية مؤسسة): يدخل عبر NOONA_SECURITY_PKG.establish_platform_session
  INSERT INTO sec_user (username, email, display_name, user_type, preferred_language, timezone_code,
                        mfa_required, status_code)
  VALUES ('PLATFORM', 'platform@noona.local', 'مسؤول المنصة', 'PLATFORM_ADMIN', 'ar', 'Asia/Riyadh', 'Y', 'ACTIVE');

  NOONA_CTX_PKG.clear_context;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Demo tenant created: TENANT_ID=' || l_tenant || ', COMPANY_ID=' || l_company ||
                       ', USERS=ADMIN, PLATFORM');
END;
/
