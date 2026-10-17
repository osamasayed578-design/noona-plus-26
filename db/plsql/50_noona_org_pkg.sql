-- =============================================================================
-- NOONA PLUS ERP | NOONA_ORG_PKG  (الحزمة 02 - الهيكل التنظيمي)
--   * الهياكل وإصداراتها: التعديل على المسودة فقط، والتفعيل يستبدل الإصدار الساري
--     ويعيد ربط المناصب بالوحدات المقابلة بالرمز دون محو التاريخ (13.1)
--   * شجرة غير محدودة: منع Self-Parent والدورات، وحساب المسار والمستوى
--   * المناصب والتعيينات: السعة، الفترات، منصب أساسي واحد، حالة الشغور
--   * الحل: شاغل المنصب، رئيس الوحدة، المدير المباشر (يستخدمها Workflow والمراسلات)
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_ORG_PKG AUTHID DEFINER AS

  FUNCTION create_structure(
    p_company_id     IN NUMBER,
    p_code           IN VARCHAR2,
    p_name_ar        IN VARCHAR2,
    p_name_en        IN VARCHAR2 DEFAULT NULL,
    p_structure_type IN VARCHAR2 DEFAULT 'ADMINISTRATIVE',
    p_is_primary     IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;

  -- ينشئ إصداراً مسودة؛ مع p_copy_from_active = 'Y' تنسخ وحدات الإصدار الساري
  FUNCTION new_version(p_structure_id IN NUMBER, p_reason IN VARCHAR2,
                       p_copy_from_active IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER;

  FUNCTION add_unit(
    p_version_id   IN NUMBER,
    p_code         IN VARCHAR2,
    p_name_ar      IN VARCHAR2,
    p_unit_type    IN VARCHAR2,
    p_parent_code  IN VARCHAR2 DEFAULT NULL,
    p_name_en      IN VARCHAR2 DEFAULT NULL,
    p_branch_id    IN NUMBER   DEFAULT NULL) RETURN NUMBER;

  PROCEDURE move_unit(p_unit_id IN NUMBER, p_new_parent_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE rebuild_paths(p_version_id IN NUMBER);
  PROCEDURE activate_version(p_version_id IN NUMBER, p_effective_date IN DATE DEFAULT TRUNC(SYSDATE));

  FUNCTION create_position(
    p_unit_id          IN NUMBER,
    p_job_id           IN NUMBER,
    p_code             IN VARCHAR2,
    p_name_ar          IN VARCHAR2,
    p_is_head          IN VARCHAR2 DEFAULT 'N',
    p_reports_to_id    IN NUMBER   DEFAULT NULL,
    p_capacity_fte     IN NUMBER   DEFAULT 1,
    p_name_en          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  FUNCTION assign_position(
    p_employment_id   IN NUMBER,
    p_position_id     IN NUMBER,
    p_assignment_type IN VARCHAR2 DEFAULT 'PRIMARY',
    p_from            IN DATE     DEFAULT TRUNC(SYSDATE),
    p_to              IN DATE     DEFAULT NULL,
    p_fte_pct         IN NUMBER   DEFAULT 100,
    p_reason          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE end_assignment(p_assignment_id IN NUMBER, p_end_date IN DATE, p_reason IN VARCHAR2);

  -- ---------------------------------------------------------- Resolution
  FUNCTION position_holder(p_position_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION unit_head(p_unit_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION primary_position(p_membership_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
  FUNCTION manager_of(p_membership_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;
END NOONA_ORG_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_ORG_PKG AS

  FUNCTION version_of_unit(p_unit_id NUMBER) RETURN org_structure_version%ROWTYPE IS
    l_v org_structure_version%ROWTYPE;
  BEGIN
    SELECT v.* INTO l_v FROM org_structure_version v JOIN org_unit u ON u.structure_version_id = v.id
     WHERE u.id = p_unit_id;
    RETURN l_v;
  END;

  PROCEDURE assert_draft(p_version_id NUMBER) IS
    l_st org_structure_version.status_code%TYPE;
  BEGIN
    SELECT status_code INTO l_st FROM org_structure_version WHERE id = p_version_id;
    NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-ORG-001',
      'لا يعدل الهيكل الساري مباشرة؛ أنشئ إصداراً جديداً', 'Only DRAFT structure versions can be edited');
  END assert_draft;

  -- ================================================================ structures
  FUNCTION create_structure(
    p_company_id     IN NUMBER,
    p_code           IN VARCHAR2,
    p_name_ar        IN VARCHAR2,
    p_name_en        IN VARCHAR2 DEFAULT NULL,
    p_structure_type IN VARCHAR2 DEFAULT 'ADMINISTRATIVE',
    p_is_primary     IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_id NUMBER;
    l_n  NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission('ORG_STRUCTURE.CREATE', p_company_id);
    IF p_is_primary = 'Y' THEN
      SELECT COUNT(*) INTO l_n FROM org_structure
       WHERE company_id = p_company_id AND is_primary = 'Y' AND is_active = 'Y';
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-ORG-002', 'للشركة هيكل إداري أساسي بالفعل',
                            'Company already has a primary structure');
    END IF;
    INSERT INTO org_structure (company_id, code, name_ar, name_en, structure_type, is_primary)
    VALUES (p_company_id, UPPER(p_code), p_name_ar, p_name_en, p_structure_type, p_is_primary)
    RETURNING id INTO l_id;
    RETURN l_id;
  END create_structure;

  FUNCTION new_version(p_structure_id IN NUMBER, p_reason IN VARCHAR2,
                       p_copy_from_active IN VARCHAR2 DEFAULT 'Y') RETURN NUMBER IS
    l_s      org_structure%ROWTYPE;
    l_ver    NUMBER;
    l_id     NUMBER;
    l_active NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_s FROM org_structure WHERE id = p_structure_id;
    NOONA_SECURITY_PKG.assert_permission('ORG_STRUCTURE_VERSION.CREATE', l_s.company_id);
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_ver FROM org_structure_version WHERE structure_id = p_structure_id;
    INSERT INTO org_structure_version (company_id, structure_id, version_no, change_reason, status_code)
    VALUES (l_s.company_id, p_structure_id, l_ver, p_reason, 'DRAFT')
    RETURNING id INTO l_id;

    IF p_copy_from_active = 'Y' THEN
      SELECT MAX(id) INTO l_active FROM org_structure_version
       WHERE structure_id = p_structure_id AND status_code = 'ACTIVE';
      IF l_active IS NOT NULL THEN
        INSERT INTO org_unit (company_id, structure_version_id, code, name_ar, name_en, unit_type, branch_id, site_id,
                              cost_center_id, receives_correspondence, has_budget, confidentiality_level, status_code)
        SELECT company_id, l_id, code, name_ar, name_en, unit_type, branch_id, site_id, cost_center_id,
               receives_correspondence, has_budget, confidentiality_level, 'DRAFT'
          FROM org_unit WHERE structure_version_id = l_active AND status_code <> 'CLOSED';
        -- إعادة ربط الآباء بالرمز
        MERGE INTO org_unit n
        USING (SELECT c.code, p.code parent_code
                 FROM org_unit c JOIN org_unit p ON p.id = c.parent_unit_id
                WHERE c.structure_version_id = l_active) o
           ON (n.structure_version_id = l_id AND n.code = o.code)
         WHEN MATCHED THEN UPDATE SET n.parent_unit_id =
              (SELECT x.id FROM org_unit x WHERE x.structure_version_id = l_id AND x.code = o.parent_code);
        rebuild_paths(l_id);
      END IF;
    END IF;
    RETURN l_id;
  END new_version;

  FUNCTION add_unit(
    p_version_id   IN NUMBER,
    p_code         IN VARCHAR2,
    p_name_ar      IN VARCHAR2,
    p_unit_type    IN VARCHAR2,
    p_parent_code  IN VARCHAR2 DEFAULT NULL,
    p_name_en      IN VARCHAR2 DEFAULT NULL,
    p_branch_id    IN NUMBER   DEFAULT NULL) RETURN NUMBER IS
    l_v      org_structure_version%ROWTYPE;
    l_parent org_unit%ROWTYPE;
    l_id     NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_v FROM org_structure_version WHERE id = p_version_id;
    NOONA_SECURITY_PKG.assert_permission('ORG_UNIT.UPDATE', l_v.company_id);
    assert_draft(p_version_id);
    IF p_parent_code IS NOT NULL THEN
      BEGIN
        SELECT * INTO l_parent FROM org_unit WHERE structure_version_id = p_version_id AND code = UPPER(p_parent_code);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-ORG-003', 'الوحدة الأم غير موجودة في هذا الإصدار',
                                   'Parent unit not found in this version');
      END;
    END IF;
    INSERT INTO org_unit (company_id, structure_version_id, code, name_ar, name_en, unit_type, parent_unit_id,
                          branch_id, hier_path, hier_level, status_code)
    VALUES (l_v.company_id, p_version_id, UPPER(p_code), p_name_ar, p_name_en, p_unit_type, l_parent.id,
            p_branch_id,
            CASE WHEN l_parent.id IS NULL THEN '/' || UPPER(p_code) ELSE l_parent.hier_path || '/' || UPPER(p_code) END,
            NVL(l_parent.hier_level, 0) + 1, 'DRAFT')
    RETURNING id INTO l_id;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-ORG-004', 'رمز الوحدة مكرر في هذا الإصدار', 'Duplicate unit code');
  END add_unit;

  PROCEDURE move_unit(p_unit_id IN NUMBER, p_new_parent_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_u   org_unit%ROWTYPE;
    l_np  org_unit%ROWTYPE;
    l_cyc NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_u FROM org_unit WHERE id = p_unit_id;
    NOONA_SECURITY_PKG.assert_permission('ORG_UNIT.UPDATE', l_u.company_id);
    assert_draft(l_u.structure_version_id);
    IF p_new_parent_id IS NOT NULL THEN
      SELECT * INTO l_np FROM org_unit WHERE id = p_new_parent_id;
      NOONA_CORE_PKG.assert(l_np.structure_version_id = l_u.structure_version_id, 'NOONA-ORG-005',
        'الوحدة الأم من إصدار آخر', 'Parent belongs to another version');
      -- منع الدورة: الأب الجديد لا يكون الوحدة نفسها ولا أحد توابعها
      SELECT COUNT(*) INTO l_cyc FROM org_unit
       WHERE id = p_new_parent_id
       START WITH id = p_unit_id CONNECT BY NOCYCLE PRIOR id = parent_unit_id;
      NOONA_CORE_PKG.assert(l_cyc = 0, 'NOONA-ORG-006', 'النقل ينشئ دورة في الشجرة',
                            'Move would create a cycle');
    END IF;
    UPDATE org_unit SET parent_unit_id = p_new_parent_id, change_reason = p_reason WHERE id = p_unit_id;
    rebuild_paths(l_u.structure_version_id);
  END move_unit;

  PROCEDURE rebuild_paths(p_version_id IN NUMBER) IS
  BEGIN
    MERGE INTO org_unit u
    USING (SELECT id, SYS_CONNECT_BY_PATH(code, '/') path, LEVEL lvl
             FROM org_unit WHERE structure_version_id = p_version_id
            START WITH parent_unit_id IS NULL AND structure_version_id = p_version_id
            CONNECT BY NOCYCLE PRIOR id = parent_unit_id) t
       ON (u.id = t.id)
     WHEN MATCHED THEN UPDATE SET u.hier_path = t.path, u.hier_level = t.lvl;
  END rebuild_paths;

  PROCEDURE activate_version(p_version_id IN NUMBER, p_effective_date IN DATE DEFAULT TRUNC(SYSDATE)) IS
    l_v       org_structure_version%ROWTYPE;
    l_old     NUMBER;
    l_orphans NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_v FROM org_structure_version WHERE id = p_version_id FOR UPDATE;
    NOONA_SECURITY_PKG.assert_permission('ORG_STRUCTURE_VERSION.APPROVE', l_v.company_id);
    NOONA_CORE_PKG.assert(l_v.status_code IN ('DRAFT', 'APPROVED', 'SCHEDULED'), 'NOONA-ORG-007',
      'حالة الإصدار لا تسمح بالتفعيل', 'Version status does not allow activation');
    SELECT MAX(id) INTO l_old FROM org_structure_version
     WHERE structure_id = l_v.structure_id AND status_code = 'ACTIVE' AND id <> p_version_id;

    IF l_old IS NOT NULL THEN
      -- كل منصب في وحدة قديمة نشطة يجب أن يجد وحدة بنفس الرمز في الإصدار الجديد
      SELECT COUNT(*) INTO l_orphans
        FROM org_position p JOIN org_unit ou ON ou.id = p.org_unit_id
       WHERE ou.structure_version_id = l_old
         AND p.status_code NOT IN ('CANCELLED', 'CLOSED')
         AND NOT EXISTS (SELECT 1 FROM org_unit nu WHERE nu.structure_version_id = p_version_id AND nu.code = ou.code);
      NOONA_CORE_PKG.assert(l_orphans = 0, 'NOONA-ORG-008',
        l_orphans || ' منصب في وحدات حذفت من الإصدار الجديد؛ انقلها أو أغلقها أولاً',
        l_orphans || ' positions belong to units missing in the new version');
      UPDATE org_position p
         SET p.org_unit_id = (SELECT nu.id FROM org_unit nu JOIN org_unit ou ON ou.code = nu.code
                               WHERE ou.id = p.org_unit_id AND nu.structure_version_id = p_version_id)
       WHERE p.org_unit_id IN (SELECT id FROM org_unit WHERE structure_version_id = l_old);
      -- إعادة هيكلة في نفس يوم التفعيل السابق: لا تسبق النهاية البداية
      UPDATE org_unit SET status_code = 'CLOSED', effective_to = GREATEST(p_effective_date - 1, effective_from)
       WHERE structure_version_id = l_old AND status_code = 'ACTIVE';
      UPDATE org_structure_version
         SET status_code = 'SUPERSEDED', effective_to = GREATEST(p_effective_date - 1, NVL(effective_from, p_effective_date - 1))
       WHERE id = l_old;
    END IF;

    UPDATE org_unit SET status_code = 'ACTIVE', effective_from = p_effective_date
     WHERE structure_version_id = p_version_id AND status_code = 'DRAFT';
    -- رئيس الوحدة = المنصب المعلم IS_HEAD داخلها
    UPDATE org_unit u SET u.head_position_id =
           (SELECT MIN(p.id) FROM org_position p WHERE p.org_unit_id = u.id AND p.is_head = 'Y'
               AND p.status_code NOT IN ('CANCELLED', 'CLOSED'))
     WHERE u.structure_version_id = p_version_id;
    UPDATE org_structure_version SET status_code = 'ACTIVE', effective_from = p_effective_date WHERE id = p_version_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'ORG_STRUCTURE_VERSION', p_version_id, 'ACTIVATE', 'SUCCESS',
                              p_company_id => l_v.company_id);
  END activate_version;

  -- ================================================================ positions
  FUNCTION create_position(
    p_unit_id          IN NUMBER,
    p_job_id           IN NUMBER,
    p_code             IN VARCHAR2,
    p_name_ar          IN VARCHAR2,
    p_is_head          IN VARCHAR2 DEFAULT 'N',
    p_reports_to_id    IN NUMBER   DEFAULT NULL,
    p_capacity_fte     IN NUMBER   DEFAULT 1,
    p_name_en          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_u  org_unit%ROWTYPE;
    l_id NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_u FROM org_unit WHERE id = p_unit_id;
    NOONA_SECURITY_PKG.assert_permission('ORG_POSITION.CREATE', l_u.company_id);
    NOONA_CORE_PKG.assert(l_u.status_code IN ('DRAFT', 'ACTIVE'), 'NOONA-ORG-010',
      'الوحدة غير فعالة', 'Unit is not active');
    NOONA_CORE_PKG.assert(p_capacity_fte > 0, 'NOONA-ORG-011', 'السعة يجب أن تكون أكبر من صفر',
                          'Capacity must be positive');
    INSERT INTO org_position (company_id, org_unit_id, job_id, code, name_ar, name_en, is_head,
                              reports_to_position_id, capacity_fte, branch_id, status_code)
    VALUES (l_u.company_id, p_unit_id, p_job_id, UPPER(p_code), p_name_ar, p_name_en, NVL(p_is_head, 'N'),
            p_reports_to_id, p_capacity_fte, l_u.branch_id, 'VACANT')
    RETURNING id INTO l_id;
    IF p_is_head = 'Y' AND l_u.status_code = 'ACTIVE' THEN
      UPDATE org_unit SET head_position_id = l_id WHERE id = p_unit_id AND head_position_id IS NULL;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-ORG-012', 'رمز المنصب مكرر', 'Duplicate position code');
  END create_position;

  PROCEDURE refresh_position_status(p_position_id NUMBER) IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM org_position_assignment
     WHERE position_id = p_position_id AND status_code = 'EFFECTIVE'
       AND TRUNC(SYSDATE) BETWEEN effective_from AND NVL(effective_to, DATE '9999-12-31');
    UPDATE org_position
       SET status_code = CASE WHEN l_n > 0 THEN 'OCCUPIED' ELSE 'VACANT' END
     WHERE id = p_position_id AND status_code IN ('VACANT', 'OCCUPIED', 'APPROVED', 'TEMPORARILY_FILLED');
  END refresh_position_status;

  FUNCTION assign_position(
    p_employment_id   IN NUMBER,
    p_position_id     IN NUMBER,
    p_assignment_type IN VARCHAR2 DEFAULT 'PRIMARY',
    p_from            IN DATE     DEFAULT TRUNC(SYSDATE),
    p_to              IN DATE     DEFAULT NULL,
    p_fte_pct         IN NUMBER   DEFAULT 100,
    p_reason          IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_p    org_position%ROWTYPE;
    l_e    hr_employment%ROWTYPE;
    l_used NUMBER;
    l_n    NUMBER;
    l_id   NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_p FROM org_position WHERE id = p_position_id FOR UPDATE;
    SELECT * INTO l_e FROM hr_employment WHERE id = p_employment_id;
    NOONA_SECURITY_PKG.assert_permission('ORG_POSITION_ASSIGNMENT.CREATE', l_p.company_id);

    NOONA_CORE_PKG.assert(l_p.status_code NOT IN ('FROZEN', 'CANCELLED', 'CLOSED', 'PLANNED'), 'NOONA-ORG-020',
      'المنصب ' || l_p.status_code || ' ولا يقبل التعيين', 'Position is ' || l_p.status_code);
    NOONA_CORE_PKG.assert(l_e.status_code IN ('PENDING', 'ACTIVE'), 'NOONA-ORG-021',
      'علاقة التوظيف غير فعالة', 'Employment is not active');
    NOONA_CORE_PKG.assert(p_from >= l_p.effective_from AND (l_p.effective_to IS NULL OR NVL(p_to, DATE '9999-12-31') <= l_p.effective_to),
      'NOONA-ORG-022', 'فترة التعيين خارج مدة المنصب', 'Assignment outside position dates');

    -- منصب أساسي واحد متزامن لكل علاقة توظيف
    IF p_assignment_type = 'PRIMARY' THEN
      SELECT COUNT(*) INTO l_n FROM org_position_assignment
       WHERE employment_id = p_employment_id AND assignment_type = 'PRIMARY'
         AND status_code IN ('APPROVED', 'SCHEDULED', 'EFFECTIVE')
         AND effective_from <= NVL(p_to, DATE '9999-12-31')
         AND NVL(effective_to, DATE '9999-12-31') >= p_from;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-ORG-023', 'للموظف منصب أساسي متداخل في نفس الفترة',
                            'Employee already has an overlapping primary position');
    END IF;

    -- سعة المنصب FTE
    SELECT NVL(SUM(fte_pct), 0) / 100 INTO l_used FROM org_position_assignment
     WHERE position_id = p_position_id AND status_code IN ('APPROVED', 'SCHEDULED', 'EFFECTIVE')
       AND effective_from <= NVL(p_to, DATE '9999-12-31')
       AND NVL(effective_to, DATE '9999-12-31') >= p_from;
    NOONA_CORE_PKG.assert(l_used + p_fte_pct / 100 <= l_p.capacity_fte, 'NOONA-ORG-024',
      'تجاوز سعة المنصب (' || l_p.capacity_fte || ' FTE)', 'Position capacity exceeded');

    INSERT INTO org_position_assignment (employment_id, position_id, assignment_type, fte_pct, reason,
                                         approved_by, effective_from, effective_to, status_code)
    VALUES (p_employment_id, p_position_id, p_assignment_type, p_fte_pct, p_reason,
            NOONA_CTX_PKG.current_user_name, p_from, p_to,
            CASE WHEN p_from > TRUNC(SYSDATE) THEN 'SCHEDULED' ELSE 'EFFECTIVE' END)
    RETURNING id INTO l_id;
    refresh_position_status(p_position_id);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'ORG_POSITION_ASSIGNMENT', l_id, 'ASSIGN', 'SUCCESS',
                              p_company_id => l_p.company_id);
    RETURN l_id;
  END assign_position;

  PROCEDURE end_assignment(p_assignment_id IN NUMBER, p_end_date IN DATE, p_reason IN VARCHAR2) IS
    l_a org_position_assignment%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    SELECT * INTO l_a FROM org_position_assignment WHERE id = p_assignment_id FOR UPDATE;
    NOONA_CORE_PKG.assert(p_end_date >= l_a.effective_from, 'NOONA-ORG-025',
      'تاريخ الانتهاء قبل البداية', 'End date before start date');
    UPDATE org_position_assignment
       SET effective_to = p_end_date, reason = SUBSTR(reason || ' | ' || p_reason, 1, 1000),
           status_code = CASE WHEN p_end_date < TRUNC(SYSDATE) THEN 'COMPLETED' ELSE status_code END
     WHERE id = p_assignment_id;
    refresh_position_status(l_a.position_id);
  END end_assignment;

  -- ================================================================ resolution
  FUNCTION position_holder(p_position_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_member NUMBER;
  BEGIN
    SELECT m.id INTO l_member
      FROM org_position_assignment a
      JOIN hr_employment e ON e.id = a.employment_id AND e.status_code = 'ACTIVE'
      JOIN sec_user_membership m ON m.employee_id = e.employee_id AND m.status_code = 'ACTIVE'
     WHERE a.position_id = p_position_id
       AND a.status_code IN ('EFFECTIVE', 'SCHEDULED')
       AND p_date BETWEEN a.effective_from AND NVL(a.effective_to, DATE '9999-12-31')
     ORDER BY CASE a.assignment_type WHEN 'PRIMARY' THEN 1 WHEN 'ACTING' THEN 2 ELSE 3 END, a.effective_from
     FETCH FIRST 1 ROWS ONLY;
    RETURN l_member;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END position_holder;

  FUNCTION unit_head(p_unit_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_head NUMBER;
  BEGIN
    SELECT head_position_id INTO l_head FROM org_unit WHERE id = p_unit_id;
    RETURN CASE WHEN l_head IS NULL THEN NULL ELSE position_holder(l_head, p_date) END;
  END unit_head;

  FUNCTION primary_position(p_membership_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_pos NUMBER;
  BEGIN
    SELECT a.position_id INTO l_pos
      FROM sec_user_membership m
      JOIN hr_employment e ON e.employee_id = m.employee_id AND e.status_code = 'ACTIVE'
      JOIN org_position_assignment a ON a.employment_id = e.id
     WHERE m.id = p_membership_id
       AND a.status_code IN ('EFFECTIVE', 'SCHEDULED')
       AND p_date BETWEEN a.effective_from AND NVL(a.effective_to, DATE '9999-12-31')
     ORDER BY CASE a.assignment_type WHEN 'PRIMARY' THEN 1 ELSE 2 END
     FETCH FIRST 1 ROWS ONLY;
    RETURN l_pos;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END primary_position;

  -- المدير: شاغل المنصب الأعلى؛ وإلا رئيس الوحدة؛ وإن كان هو نفسه فرئيس الوحدة الأعلى (يصعد حتى يجد)
  FUNCTION manager_of(p_membership_id IN NUMBER, p_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
    l_pos     org_position%ROWTYPE;
    l_pos_id  NUMBER := primary_position(p_membership_id, p_date);
    l_unit    NUMBER;
    l_head    NUMBER;
    l_guard   PLS_INTEGER := 0;
  BEGIN
    IF l_pos_id IS NULL THEN
      RETURN NULL;
    END IF;
    SELECT * INTO l_pos FROM org_position WHERE id = l_pos_id;
    IF l_pos.reports_to_position_id IS NOT NULL THEN
      l_head := position_holder(l_pos.reports_to_position_id, p_date);
      IF l_head IS NOT NULL AND l_head <> p_membership_id THEN
        RETURN l_head;
      END IF;
    END IF;
    l_unit := l_pos.org_unit_id;
    WHILE l_unit IS NOT NULL AND l_guard < 50 LOOP
      l_guard := l_guard + 1;
      l_head := unit_head(l_unit, p_date);
      IF l_head IS NOT NULL AND l_head <> p_membership_id THEN
        RETURN l_head;
      END IF;
      SELECT parent_unit_id INTO l_unit FROM org_unit WHERE id = l_unit;
    END LOOP;
    RETURN NULL;
  END manager_of;

END NOONA_ORG_PKG;
/
