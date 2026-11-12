-- =============================================================================
-- NOONA PLUS ERP | البوابة NOONA_PORTAL: حزمة الإجراءات وواجهات العرض (Views)
--   NOONA_PORTAL_PKG       : إجراءات صندوق المهام والإشعارات وظهور التطبيقات
--   NOONA_V_MY_TASKS       : مهامي المفتوحة (المسندة لي مباشرة أو بالتفويض)
--   NOONA_V_TASK_HISTORY   : سجل إجراءات المسارات التي أشارك فيها
--   NOONA_V_MY_NOTIFICATIONS: إشعاراتي
--   NOONA_V_APPS           : تطبيقات NOONA المتاحة للمستخدم الحالي
-- كل الواجهات تعتمد على سياق NOONA_CTX + VPD؛ بلا جلسة لا تعرض شيئاً.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_PORTAL_PKG AUTHID DEFINER AS

  -- إجراء على مهمة من صندوق المهام (أسماء أزرار APEX): APPROVE, REJECT, RETURN, REQUEST_INFO, PROVIDE_INFO, CLAIM
  PROCEDURE task_action(p_task_id IN NUMBER, p_action IN VARCHAR2, p_comments IN VARCHAR2 DEFAULT NULL);

  FUNCTION open_task_count RETURN NUMBER;

  PROCEDURE mark_read(p_notification_id IN NUMBER);
  PROCEDURE mark_all_read;
  FUNCTION unread_count RETURN NUMBER;

  -- هل يظهر التطبيق للمستخدم الحالي؟ 'Y' / 'N'
  -- p_module_code: وحدة أو قائمة وحدات مفصولة بفواصل؛ يظهر إذا كانت إحداها ضمن اشتراك المؤسسة
  -- وللمستخدم صلاحية سماح فعالة فيها (مسؤول المؤسسة يرى كل الأنظمة المشترك فيها)
  FUNCTION app_visible(p_app_alias IN VARCHAR2, p_module_code IN VARCHAR2) RETURN VARCHAR2;

  -- تسمية عربية/إنجليزية لرموز الإجراءات والأولويات
  FUNCTION action_label(p_action_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION priority_label(p_priority_code IN VARCHAR2) RETURN VARCHAR2;
END NOONA_PORTAL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_PORTAL_PKG AS

  FUNCTION en RETURN BOOLEAN IS
  BEGIN
    RETURN SYS_CONTEXT('NOONA_CTX', 'LANGUAGE') = 'en';
  END;

  PROCEDURE task_action(p_task_id IN NUMBER, p_action IN VARCHAR2, p_comments IN VARCHAR2 DEFAULT NULL) IS
    l_action VARCHAR2(30) := UPPER(TRIM(p_action));
  BEGIN
    NOONA_CORE_PKG.assert(l_action IN ('APPROVE', 'REJECT', 'RETURN', 'REQUEST_INFO', 'PROVIDE_INFO', 'CLAIM', 'COMMENT'),
      'NOONA-WF-060', 'إجراء غير مدعوم من صندوق المهام: ' || l_action, 'Unsupported inbox action ' || l_action);
    -- الرفض والإرجاع وطلب المعلومات تحتاج سبباً مكتوباً
    NOONA_CORE_PKG.assert(l_action NOT IN ('REJECT', 'RETURN', 'REQUEST_INFO') OR TRIM(p_comments) IS NOT NULL,
      'NOONA-WF-061', 'اكتب السبب في الملاحظات قبل الرفض أو الإرجاع أو طلب المعلومات',
      'Comments are required to reject, return or request information');
    NOONA_WORKFLOW_PKG.act(p_task_id, l_action, p_comments);
  END task_action;

  FUNCTION open_task_count RETURN NUMBER IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM wf_task
     WHERE assignee_member_id = NOONA_CTX_PKG.membership_id
       AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO');
    RETURN l_n;
  END open_task_count;

  PROCEDURE mark_read(p_notification_id IN NUMBER) IS
  BEGIN
    UPDATE ntf_notification
       SET read_at = SYSTIMESTAMP, status_code = 'READ'
     WHERE id = p_notification_id
       AND membership_id = NOONA_CTX_PKG.membership_id
       AND read_at IS NULL;
  END mark_read;

  PROCEDURE mark_all_read IS
  BEGIN
    UPDATE ntf_notification
       SET read_at = SYSTIMESTAMP, status_code = 'READ'
     WHERE membership_id = NOONA_CTX_PKG.membership_id
       AND read_at IS NULL;
  END mark_all_read;

  FUNCTION unread_count RETURN NUMBER IS
    l_n NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_n FROM ntf_notification
     WHERE membership_id = NOONA_CTX_PKG.membership_id AND read_at IS NULL AND status_code <> 'CANCELLED';
    RETURN l_n;
  END unread_count;

  FUNCTION app_visible(p_app_alias IN VARCHAR2, p_module_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_list  VARCHAR2(200) := ',' || REPLACE(p_module_code, ' ') || ',';
    l_n     NUMBER;
    l_on    BOOLEAN := FALSE;
    l_bi    VARCHAR2(1);
  BEGIN
    IF p_app_alias = 'NOONA_PLATFORM' THEN
      RETURN NOONA_APEX_PKG.is_platform_admin;
    END IF;
    IF NOONA_APEX_PKG.is_tenant_user = 'N' THEN
      RETURN 'N';
    END IF;
    IF p_app_alias = 'NOONA_ADMIN' THEN
      -- مسؤول المؤسسة أو مسؤول شركة (دور COMPANY_ADMIN)
      RETURN NOONA_SEC_ADMIN_PKG.is_org_admin;
    END IF;
    IF p_app_alias = 'NOONA_BI' THEN
      -- مركز التقارير: يظهر لمن له تقرير واحد على الأقل في الوحدات المشترك فيها
      -- (استدعاء ديناميكي: الحزمة تثبت في ترقية لاحقة فلا تتعطل هذه الحزمة قبلها)
      BEGIN
        EXECUTE IMMEDIATE 'BEGIN :r := NOONA_BI_PKG.has_reports; END;' USING OUT l_bi;
      EXCEPTION WHEN OTHERS THEN
        l_bi := 'N';
      END;
      RETURN l_bi;
    END IF;
    IF p_module_code IS NULL THEN
      RETURN 'Y';
    END IF;
    -- المراسلات حق لكل مستخدمي المؤسسة متى كانت وحدة المراسلات مفعلة (صفحات الأرشيف تتطلب صلاحيات الأرشيف)
    IF p_app_alias = 'NOONA_DOC' AND NOONA_PLATFORM_PKG.module_enabled('COR') = 'Y' THEN
      RETURN 'Y';
    END IF;
    -- الاشتراك: إحدى وحدات النظام مفعلة للمؤسسة
    FOR m IN (SELECT REGEXP_SUBSTR(p_module_code, '[^,]+', 1, LEVEL) AS code FROM dual
              CONNECT BY REGEXP_SUBSTR(p_module_code, '[^,]+', 1, LEVEL) IS NOT NULL) LOOP
      IF NOONA_PLATFORM_PKG.module_enabled(TRIM(m.code)) = 'Y' THEN
        l_on := TRUE;
        EXIT;
      END IF;
    END LOOP;
    IF NOT l_on THEN
      RETURN 'N';
    END IF;
    IF NOONA_APEX_PKG.is_tenant_admin = 'Y' THEN
      RETURN 'Y';
    END IF;
    -- التخصيص: صلاحية سماح من دور ممنوح فعال في إحدى وحدات النظام
    SELECT COUNT(*) INTO l_n
      FROM sec_role_grant g
      JOIN sec_role_permission rp ON rp.role_id = g.role_id AND rp.effect = 'ALLOW'
      JOIN sec_permission p ON p.id = rp.permission_id
     WHERE g.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
       AND g.status_code = 'ACTIVE'
       AND (g.effective_to IS NULL OR g.effective_to >= TRUNC(SYSDATE))
       AND INSTR(l_list, ',' || p.module_code || ',') > 0
       AND ROWNUM = 1;
    RETURN CASE WHEN l_n > 0 THEN 'Y' ELSE 'N' END;
  END app_visible;

  FUNCTION action_label(p_action_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF en THEN
      RETURN INITCAP(REPLACE(p_action_code, '_', ' '));
    END IF;
    RETURN CASE p_action_code
             WHEN 'APPROVE' THEN 'اعتماد'
             WHEN 'APPROVE_WITH_CONDITIONS' THEN 'اعتماد بشروط'
             WHEN 'REJECT' THEN 'رفض'
             WHEN 'RETURN' THEN 'إرجاع'
             WHEN 'REQUEST_INFO' THEN 'طلب معلومات'
             WHEN 'PROVIDE_INFO' THEN 'تقديم معلومات'
             WHEN 'CLAIM' THEN 'استلام'
             WHEN 'REASSIGN' THEN 'إعادة إسناد'
             WHEN 'FORWARD' THEN 'تحويل'
             WHEN 'COMMENT' THEN 'تعليق'
             WHEN 'ACKNOWLEDGE' THEN 'علم'
             WHEN 'ESCALATE' THEN 'تصعيد'
             WHEN 'CANCEL' THEN 'إلغاء'
             ELSE p_action_code END;
  END action_label;

  FUNCTION priority_label(p_priority_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF en THEN
      RETURN INITCAP(REPLACE(p_priority_code, '_', ' '));
    END IF;
    RETURN CASE p_priority_code
             WHEN 'LOW' THEN 'منخفضة' WHEN 'NORMAL' THEN 'عادية' WHEN 'HIGH' THEN 'مرتفعة'
             WHEN 'URGENT' THEN 'عاجلة' WHEN 'VERY_URGENT' THEN 'عاجلة جداً' ELSE p_priority_code END;
  END priority_label;

END NOONA_PORTAL_PKG;
/

-- ---------------------------------------------------------------- مهامي
CREATE OR REPLACE VIEW NOONA_V_MY_TASKS AS
SELECT t.id                                  AS task_id,
       t.instance_id,
       i.company_id,
       i.object_type,
       i.object_id,
       NVL(et.name_ar, i.object_type)        AS object_name_ar,
       NVL(et.name_en, i.object_type)        AS object_name_en,
       d.code                                AS workflow_code,
       d.name_ar                             AS workflow_name_ar,
       NVL(d.name_en, d.name_ar)             AS workflow_name_en,
       s.step_code,
       s.name_ar                             AS step_name_ar,
       NVL(s.name_en, s.name_ar)             AS step_name_en,
       t.task_type,
       t.priority_code,
       NOONA_PORTAL_PKG.priority_label(t.priority_code) AS priority_label,
       t.status_code,
       t.created_at                          AS assigned_at,
       t.due_at,
       CASE WHEN t.due_at < SYSTIMESTAMP THEN 'Y' ELSE 'N' END AS is_overdue,
       t.delegation_id,
       CASE WHEN t.delegation_id IS NOT NULL THEN
         (SELECT NVL(u.display_name, u.username) FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
           WHERE m.id = t.original_member_id) END AS on_behalf_of,
       (SELECT NVL(u.display_name, u.username) FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
         WHERE m.id = i.initiator_member_id) AS requester,
       JSON_VALUE(i.context_snapshot, '$.amount' RETURNING NUMBER NULL ON ERROR) AS amount,
       JSON_VALUE(i.context_snapshot, '$.currency' NULL ON ERROR)               AS currency_code
  FROM wf_task t
  JOIN wf_instance i            ON i.id = t.instance_id
  JOIN wf_step_def s            ON s.id = t.step_id
  JOIN wf_definition_version v  ON v.id = i.version_id
  JOIN wf_definition d          ON d.id = v.definition_id
  LEFT JOIN ref_entity_type et  ON et.entity_type_code = i.object_type
 WHERE t.assignee_member_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
   AND t.status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO');

-- ---------------------------------------------------------------- سجل المسار (لمن شارك فيه فقط)
CREATE OR REPLACE VIEW NOONA_V_TASK_HISTORY AS
SELECT a.id                                  AS action_id,
       t.instance_id,
       a.task_id,
       s.name_ar                             AS step_name_ar,
       NVL(s.name_en, s.name_ar)             AS step_name_en,
       a.action_code,
       NOONA_PORTAL_PKG.action_label(a.action_code) AS action_label,
       (SELECT NVL(u.display_name, u.username) FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
         WHERE m.id = a.actor_member_id)     AS actor_name,
       (SELECT NVL(u.display_name, u.username) FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
         WHERE m.id = a.on_behalf_member_id) AS on_behalf_of,
       a.acting_capacity,
       a.comments,
       a.created_at                          AS action_at
  FROM wf_task_action a
  JOIN wf_task t      ON t.id = a.task_id
  JOIN wf_step_def s  ON s.id = t.step_id
 WHERE t.instance_id IN (
         SELECT x.instance_id FROM wf_task x
          WHERE TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')) IN (x.assignee_member_id, x.original_member_id)
         UNION
         SELECT w.id FROM wf_instance w
          WHERE w.initiator_member_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')));

-- ---------------------------------------------------------------- إشعاراتي
CREATE OR REPLACE VIEW NOONA_V_MY_NOTIFICATIONS AS
SELECT n.id                                  AS notification_id,
       n.title,
       n.body_text,
       n.link_url,
       n.source_entity_type,
       n.source_entity_id,
       n.created_at,
       n.read_at,
       CASE WHEN n.read_at IS NULL THEN 'N' ELSE 'Y' END AS is_read,
       n.due_at
  FROM ntf_notification n
 WHERE n.membership_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'))
   AND n.status_code <> 'CANCELLED';

-- ---------------------------------------------------------------- تطبيقات NOONA
CREATE OR REPLACE VIEW NOONA_V_APPS AS
-- كل نظام يغطي عدة وحدات (module_list)؛ يظهر إذا اشتركت فيه المؤسسة وللمستخدم صلاحية في إحدى وحداته
SELECT app_alias, sort_order, app_name_ar, app_name_en, icon_class,
       REGEXP_SUBSTR(module_list, '[^,]+') AS module_code, module_list, description_ar
  FROM (SELECT 'NOONA_PORTAL' app_alias, 5 sort_order, 'مهامي وإشعاراتي' app_name_ar, 'My Work' app_name_en,
               'fa-inbox' icon_class, CAST(NULL AS VARCHAR2(100)) module_list,
               'الاعتمادات المطلوبة منك والإشعارات' description_ar FROM dual UNION ALL
        SELECT 'NOONA_ADMIN', 10, 'إدارة المؤسسة', 'Administration', 'fa-sitemap', NULL,
               'الشركات والهيكل والمستخدمون والصلاحيات' FROM dual UNION ALL
        SELECT 'NOONA_FIN', 20, 'المالية', 'Finance', 'fa-calculator', 'GL,AR,AP,CSH,FA',
               'الأستاذ العام والذمم والنقدية والأصول' FROM dual UNION ALL
        SELECT 'NOONA_SCM', 30, 'سلسلة الإمداد', 'Supply Chain', 'fa-truck', 'INV,PUR',
               'المخزون والمشتريات والموردون' FROM dual UNION ALL
        SELECT 'NOONA_POS', 40, 'المبيعات ونقاط البيع', 'Sales & POS', 'fa-shopping-cart', 'SAL',
               'عروض الأسعار والفواتير ونقاط البيع' FROM dual UNION ALL
        SELECT 'NOONA_HR', 50, 'الموارد البشرية والرواتب', 'HR & Payroll', 'fa-users', 'HR,PAY',
               'الموظفون والحضور والرواتب' FROM dual UNION ALL
        SELECT 'NOONA_PRJ', 60, 'العقارات والضيافة والمشروعات', 'Real Estate, Hospitality & Projects', 'fa-building', 'PRP,RE,MNT,PRJ,HSP',
               'السجل العقاري والفنادق والشقق الفندقية والصيانة والمشروعات' FROM dual UNION ALL
        SELECT 'NOONA_HIS', 65, 'المستشفيات والمراكز الطبية', 'Hospital & Clinics', 'fa-hospital-o', 'HIS',
               'المواعيد والزيارات والمعامل والأشعة والتأمين' FROM dual UNION ALL
        SELECT 'NOONA_AUTO', 67, 'مراكز خدمة السيارات', 'Auto Service Centers', 'fa-car', 'AUT',
               'الحجوزات وأوامر الإصلاح والخدمات وقطع الغيار والتأمين' FROM dual UNION ALL
        SELECT 'NOONA_TRN', 68, 'النقل والشحن والترحيل', 'Transport & Logistics', 'fa-truck', 'TRN',
               'الأسطول والسائقون والرحلات والشحنات والأعطال والترحيل' FROM dual UNION ALL
        SELECT 'NOONA_DST', 69, 'التوزيع والمبيعات الميدانية', 'Distribution & Field Sales', 'fa-map-marker', 'DST',
               'المندوبون وخطوط السير والمحلات والبيع من السيارة والتحصيل' FROM dual UNION ALL
        SELECT 'NOONA_MFG', 70, 'التصنيع', 'Manufacturing', 'fa-industry', 'MFG,QA',
               'أوامر الإنتاج والجودة' FROM dual UNION ALL
        SELECT 'NOONA_DOC', 80, 'المستندات والمراسلات', 'Documents & Correspondence', 'fa-folder-open', 'DMS,COR',
               'الأرشيف والمراسلات الصادرة والواردة' FROM dual UNION ALL
        SELECT 'NOONA_BI', 90, 'مركز التقارير', 'Reports Center', 'fa-bar-chart', NULL,
               'كل تقارير الأنظمة المشترك فيها في مكان واحد' FROM dual UNION ALL
        SELECT 'NOONA_PLATFORM', 100, 'لوحة المنصة', 'Platform Console', 'fa-server', NULL,
               'المشتركون والاشتراكات والتراخيص' FROM dual)
 WHERE NOONA_PORTAL_PKG.app_visible(app_alias, module_list) = 'Y';
