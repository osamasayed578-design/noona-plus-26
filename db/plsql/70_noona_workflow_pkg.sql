-- =============================================================================
-- NOONA PLUS ERP | NOONA_WORKFLOW_PKG  (المرحلة 07 - محرك Workflow المركزي)
--   Business Event → Definition (Version) → Rule Evaluation → Instance → Tasks → Action
--   * الإصدار المنشور لا يعدل، والمسار القائم يكمل على إصداره
--   * حل المستلم من الهيكل: المدير، رئيس الوحدة، شاغل المنصب، الدور، اللجنة،
--     Queue، مصفوفة السلطة - مع Snapshot لسبب التوجيه
--   * SoD: يمنع اعتماد المستخدم لمعاملته (يرفع للمدير) ما لم يسمح التعريف
--   * التفويض: يوجه للمفوض إليه حسب الأولوية ويسجل المنفذ الفعلي وصاحب السلطة
--   * التوازي: ALL / ANY / COUNT / PERCENT / MAJORITY
--   * Idempotency لبدء المسار، Outbox للأحداث، إشعارات المهام، تصعيد المتأخر
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_WORKFLOW_PKG AUTHID DEFINER AS

  -- ---------------------------------------------------------- Definition API
  FUNCTION create_definition(
    p_code        IN VARCHAR2,
    p_name_ar     IN VARCHAR2,
    p_object_type IN VARCHAR2,
    p_kind        IN VARCHAR2 DEFAULT 'APPROVAL',
    p_scope_level IN VARCHAR2 DEFAULT 'TENANT',
    p_scope_id    IN NUMBER   DEFAULT NULL,
    p_name_en     IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  FUNCTION new_version(p_definition_id IN NUMBER) RETURN NUMBER;

  FUNCTION add_step(
    p_version_id      IN NUMBER,
    p_step_code       IN VARCHAR2,
    p_step_type       IN VARCHAR2,
    p_name_ar         IN VARCHAR2,
    p_assignee_rule   IN VARCHAR2 DEFAULT NULL,
    p_assignee_ref_id IN NUMBER   DEFAULT NULL,
    p_join_policy     IN VARCHAR2 DEFAULT NULL,
    p_join_value      IN NUMBER   DEFAULT NULL,
    p_sla_policy_id   IN NUMBER   DEFAULT NULL,
    p_allow_self      IN VARCHAR2 DEFAULT 'N',
    p_queue_id        IN NUMBER   DEFAULT NULL,
    p_action_handler  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE add_transition(
    p_version_id IN NUMBER,
    p_from_code  IN VARCHAR2,
    p_to_code    IN VARCHAR2,
    p_outcome    IN VARCHAR2 DEFAULT NULL,
    p_is_default IN VARCHAR2 DEFAULT 'N',
    p_rule_id    IN NUMBER   DEFAULT NULL,
    p_sort_order IN NUMBER   DEFAULT NULL);

  -- تعبير القاعدة JSON: {"field":"amount","op":">=","value":10000}
  --   أو {"all":[...]} أو {"any":[...]}؛ العوامل: = != > >= < <= in
  FUNCTION create_rule(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_expression IN CLOB) RETURN NUMBER;

  PROCEDURE publish_version(p_version_id IN NUMBER);

  -- تعديل الإصدار المسودة فقط: حذف خطوة (مع انتقالاتها) أو انتقال
  PROCEDURE remove_step(p_step_id IN NUMBER);
  PROCEDURE remove_transition(p_transition_id IN NUMBER);
  -- إصدار جديد (مسودة) منسوخ من آخر إصدار منشور بخطواته وانتقالاته
  FUNCTION copy_version(p_definition_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- Runtime
  FUNCTION start_workflow(
    p_definition_code IN VARCHAR2,
    p_object_type     IN VARCHAR2,
    p_object_id       IN NUMBER,
    p_context         IN CLOB     DEFAULT NULL,   -- {"amount":..,"currency":"SAR","priority":"HIGH",...}
    p_idempotency_key IN VARCHAR2 DEFAULT NULL,
    p_company_id      IN NUMBER   DEFAULT NULL) RETURN NUMBER;

  -- APPROVE / APPROVE_WITH_CONDITIONS / ACKNOWLEDGE / REJECT / RETURN / CLAIM / COMMENT
  -- / REQUEST_INFO / PROVIDE_INFO / REASSIGN / FORWARD
  PROCEDURE act(
    p_task_id          IN NUMBER,
    p_action           IN VARCHAR2,
    p_comments         IN VARCHAR2 DEFAULT NULL,
    p_target_member_id IN NUMBER   DEFAULT NULL);

  PROCEDURE cancel_instance(p_instance_id IN NUMBER, p_reason IN VARCHAR2);

  -- مهمة مجدولة: تصعيد المهام المتأخرة إلى المدير
  PROCEDURE escalate_overdue;

  FUNCTION eval_rule(p_rule_id IN NUMBER, p_context IN CLOB) RETURN BOOLEAN;
END NOONA_WORKFLOW_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_WORKFLOW_PKG AS

  TYPE t_ids IS TABLE OF NUMBER;
  c_open_states CONSTANT VARCHAR2(200) := ',PENDING,CLAIMED,IN_PROGRESS,WAITING_INFO,';

  PROCEDURE enter_step(p_inst_id NUMBER, p_step_id NUMBER);
  PROCEDURE follow(p_inst_id NUMBER, p_step_id NUMBER, p_outcome VARCHAR2);

  FUNCTION is_open(p_status VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN INSTR(c_open_states, ',' || p_status || ',') > 0;
  END;

  FUNCTION inst(p_id NUMBER) RETURN wf_instance%ROWTYPE IS
    l wf_instance%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM wf_instance WHERE id = p_id;
    RETURN l;
  END;

  FUNCTION step(p_id NUMBER) RETURN wf_step_def%ROWTYPE IS
    l wf_step_def%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM wf_step_def WHERE id = p_id;
    RETURN l;
  END;

  FUNCTION ctx_str(p_ctx CLOB, p_field VARCHAR2) RETURN VARCHAR2 IS
    l_obj JSON_OBJECT_T;
  BEGIN
    IF p_ctx IS NULL THEN RETURN NULL; END IF;
    l_obj := JSON_OBJECT_T.parse(p_ctx);
    RETURN CASE WHEN l_obj.has(p_field) THEN l_obj.get_string(p_field) END;
  END;

  FUNCTION ctx_num(p_ctx CLOB, p_field VARCHAR2) RETURN NUMBER IS
    l_obj JSON_OBJECT_T;
  BEGIN
    IF p_ctx IS NULL THEN RETURN NULL; END IF;
    l_obj := JSON_OBJECT_T.parse(p_ctx);
    RETURN CASE WHEN l_obj.has(p_field) THEN l_obj.get_number(p_field) END;
  END;

  FUNCTION definition_code(p_inst wf_instance%ROWTYPE) RETURN VARCHAR2 IS
    l VARCHAR2(50);
  BEGIN
    SELECT d.code INTO l FROM wf_definition d JOIN wf_definition_version v ON v.definition_id = d.id
     WHERE v.id = p_inst.version_id;
    RETURN l;
  END;

  PROCEDURE outbox(p_type VARCHAR2, p_id NUMBER, p_event VARCHAR2, p_payload CLOB, p_dest VARCHAR2 DEFAULT 'WORKFLOW') IS
  BEGIN
    INSERT INTO api_outbox (aggregate_type, aggregate_id, event_type, payload, destination, correlation_id)
    VALUES (p_type, p_id, p_event, p_payload, p_dest, NOONA_CTX_PKG.correlation_id);
  END outbox;

  -- ================================================================ definitions
  PROCEDURE assert_can_define IS
  BEGIN
    IF NOONA_CTX_PKG.is_platform_admin <> 'Y' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
      NOONA_SECURITY_PKG.assert_permission('WF_DEFINITION.CREATE');
    END IF;
  END;

  PROCEDURE assert_draft_version(p_version_id NUMBER) IS
    l_st wf_definition_version.status_code%TYPE;
  BEGIN
    SELECT status_code INTO l_st FROM wf_definition_version WHERE id = p_version_id;
    NOONA_CORE_PKG.assert(l_st = 'DRAFT', 'NOONA-WF-001', 'الإصدار المنشور لا يعدل؛ أنشئ إصداراً جديداً',
                          'Published versions are immutable');
  END;

  FUNCTION create_definition(
    p_code        IN VARCHAR2,
    p_name_ar     IN VARCHAR2,
    p_object_type IN VARCHAR2,
    p_kind        IN VARCHAR2 DEFAULT 'APPROVAL',
    p_scope_level IN VARCHAR2 DEFAULT 'TENANT',
    p_scope_id    IN NUMBER   DEFAULT NULL,
    p_name_en     IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
    l_n  NUMBER;
  BEGIN
    assert_can_define;
    SELECT COUNT(*) INTO l_n FROM ref_entity_type WHERE entity_type_code = p_object_type;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-WF-004', 'نوع الكائن غير مسجل في سجل الكيانات: ' || p_object_type,
                          'Unknown entity type ' || p_object_type);
    INSERT INTO wf_definition (code, name_ar, name_en, object_type, workflow_kind, scope_level, scope_id)
    VALUES (UPPER(p_code), p_name_ar, p_name_en, p_object_type, p_kind,
            CASE WHEN NOONA_CTX_PKG.tenant_id IS NULL THEN 'PLATFORM' ELSE p_scope_level END, p_scope_id)
    RETURNING id INTO l_id;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-WF-002', 'رمز المسار مستخدم', 'Workflow code already exists');
  END create_definition;

  FUNCTION new_version(p_definition_id IN NUMBER) RETURN NUMBER IS
    l_no NUMBER;
    l_id NUMBER;
  BEGIN
    assert_can_define;
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_no FROM wf_definition_version WHERE definition_id = p_definition_id;
    INSERT INTO wf_definition_version (definition_id, version_no, status_code)
    VALUES (p_definition_id, l_no, 'DRAFT')
    RETURNING id INTO l_id;
    RETURN l_id;
  END new_version;

  FUNCTION add_step(
    p_version_id      IN NUMBER,
    p_step_code       IN VARCHAR2,
    p_step_type       IN VARCHAR2,
    p_name_ar         IN VARCHAR2,
    p_assignee_rule   IN VARCHAR2 DEFAULT NULL,
    p_assignee_ref_id IN NUMBER   DEFAULT NULL,
    p_join_policy     IN VARCHAR2 DEFAULT NULL,
    p_join_value      IN NUMBER   DEFAULT NULL,
    p_sla_policy_id   IN NUMBER   DEFAULT NULL,
    p_allow_self      IN VARCHAR2 DEFAULT 'N',
    p_queue_id        IN NUMBER   DEFAULT NULL,
    p_action_handler  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    assert_can_define;
    assert_draft_version(p_version_id);
    INSERT INTO wf_step_def (version_id, step_code, step_type, name_ar, assignee_rule, assignee_ref_id,
                             join_policy, join_value, sla_policy_id, allow_self_approval, queue_id, action_handler)
    VALUES (p_version_id, UPPER(p_step_code), p_step_type, p_name_ar, p_assignee_rule, p_assignee_ref_id,
            p_join_policy, p_join_value, p_sla_policy_id, NVL(p_allow_self, 'N'), p_queue_id, p_action_handler)
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_step;

  PROCEDURE add_transition(
    p_version_id IN NUMBER,
    p_from_code  IN VARCHAR2,
    p_to_code    IN VARCHAR2,
    p_outcome    IN VARCHAR2 DEFAULT NULL,
    p_is_default IN VARCHAR2 DEFAULT 'N',
    p_rule_id    IN NUMBER   DEFAULT NULL,
    p_sort_order IN NUMBER   DEFAULT NULL) IS
    l_from NUMBER;
    l_to   NUMBER;
  BEGIN
    assert_can_define;
    assert_draft_version(p_version_id);
    SELECT id INTO l_from FROM wf_step_def WHERE version_id = p_version_id AND step_code = UPPER(p_from_code);
    SELECT id INTO l_to   FROM wf_step_def WHERE version_id = p_version_id AND step_code = UPPER(p_to_code);
    INSERT INTO wf_transition_def (version_id, from_step_id, to_step_id, outcome_code, is_default, rule_id, sort_order)
    VALUES (p_version_id, l_from, l_to, p_outcome, NVL(p_is_default, 'N'), p_rule_id, p_sort_order);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-WF-003', 'خطوة غير موجودة في هذا الإصدار', 'Step not found in version');
  END add_transition;

  FUNCTION create_rule(p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_expression IN CLOB) RETURN NUMBER IS
    l_id NUMBER;
    l_v  NUMBER;
    l_o  JSON_OBJECT_T;
  BEGIN
    assert_can_define;
    l_o := JSON_OBJECT_T.parse(p_expression);   -- يرفض JSON غير صالح
    SELECT NVL(MAX(version_no), 0) + 1 INTO l_v FROM wf_rule WHERE code = UPPER(p_code);
    INSERT INTO wf_rule (code, name_ar, version_no, rule_expression, status_code)
    VALUES (UPPER(p_code), p_name_ar, l_v, p_expression, 'PUBLISHED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END create_rule;

  PROCEDURE remove_step(p_step_id IN NUMBER) IS
    l_ver NUMBER;
  BEGIN
    assert_can_define;
    SELECT version_id INTO l_ver FROM wf_step_def WHERE id = p_step_id;
    assert_draft_version(l_ver);
    DELETE FROM wf_transition_def WHERE version_id = l_ver AND (from_step_id = p_step_id OR to_step_id = p_step_id);
    DELETE FROM wf_step_def WHERE id = p_step_id;
  END remove_step;

  PROCEDURE remove_transition(p_transition_id IN NUMBER) IS
    l_ver NUMBER;
  BEGIN
    assert_can_define;
    SELECT version_id INTO l_ver FROM wf_transition_def WHERE id = p_transition_id;
    assert_draft_version(l_ver);
    DELETE FROM wf_transition_def WHERE id = p_transition_id;
  END remove_transition;

  FUNCTION copy_version(p_definition_id IN NUMBER) RETURN NUMBER IS
    l_src NUMBER;
    l_new NUMBER;
    l_id  NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY version_no) INTO l_src
      FROM wf_definition_version WHERE definition_id = p_definition_id AND status_code IN ('PUBLISHED', 'ACTIVE', 'RETIRED');
    l_new := new_version(p_definition_id);
    IF l_src IS NOT NULL THEN
      FOR st IN (SELECT * FROM wf_step_def WHERE version_id = l_src ORDER BY id) LOOP
        l_id := add_step(l_new, st.step_code, st.step_type, st.name_ar, st.assignee_rule, st.assignee_ref_id,
                         st.join_policy, st.join_value, st.sla_policy_id, st.allow_self_approval, st.queue_id, st.action_handler);
      END LOOP;
      FOR tr IN (SELECT f.step_code from_code, t.step_code to_code, x.outcome_code, x.is_default, x.rule_id, x.sort_order
                   FROM wf_transition_def x JOIN wf_step_def f ON f.id = x.from_step_id JOIN wf_step_def t ON t.id = x.to_step_id
                  WHERE x.version_id = l_src ORDER BY x.sort_order, x.id) LOOP
        add_transition(l_new, tr.from_code, tr.to_code, tr.outcome_code, tr.is_default, tr.rule_id, tr.sort_order);
      END LOOP;
    END IF;
    RETURN l_new;
  END copy_version;

  PROCEDURE publish_version(p_version_id IN NUMBER) IS
    l_v      wf_definition_version%ROWTYPE;
    l_starts NUMBER;
    l_ends   NUMBER;
    l_dead   NUMBER;
    l_noassn NUMBER;
    l_unreach NUMBER;
    l_start_id NUMBER;
  BEGIN
    assert_can_define;
    SELECT * INTO l_v FROM wf_definition_version WHERE id = p_version_id FOR UPDATE;
    assert_draft_version(p_version_id);
    SELECT COUNT(CASE WHEN step_type = 'START' THEN 1 END), COUNT(CASE WHEN step_type = 'END' THEN 1 END),
           MIN(CASE WHEN step_type = 'START' THEN id END)
      INTO l_starts, l_ends, l_start_id
      FROM wf_step_def WHERE version_id = p_version_id;
    NOONA_CORE_PKG.assert(l_starts = 1 AND l_ends >= 1, 'NOONA-WF-010',
      'المسار يحتاج خطوة بداية واحدة وخطوة نهاية على الأقل', 'Exactly one START and at least one END required');
    SELECT COUNT(*) INTO l_dead FROM wf_step_def s
     WHERE s.version_id = p_version_id AND s.step_type <> 'END'
       AND NOT EXISTS (SELECT 1 FROM wf_transition_def t WHERE t.from_step_id = s.id);
    NOONA_CORE_PKG.assert(l_dead = 0, 'NOONA-WF-011', l_dead || ' خطوة بلا انتقال خارج',
                          l_dead || ' steps have no outgoing transition');
    SELECT COUNT(*) INTO l_noassn FROM wf_step_def
     WHERE version_id = p_version_id AND step_type IN ('APPROVAL', 'REVIEW', 'USER_TASK', 'SIGNATURE')
       AND assignee_rule IS NULL AND queue_id IS NULL;
    NOONA_CORE_PKG.assert(l_noassn = 0, 'NOONA-WF-012', 'خطوات اعتماد بلا قاعدة إسناد',
                          'Approval steps without an assignee rule');
    SELECT COUNT(*) INTO l_unreach FROM wf_step_def s
     WHERE s.version_id = p_version_id AND s.id <> l_start_id
       AND s.id NOT IN (SELECT to_step_id FROM wf_transition_def
                         START WITH from_step_id = l_start_id
                         CONNECT BY NOCYCLE PRIOR to_step_id = from_step_id);
    NOONA_CORE_PKG.assert(l_unreach = 0, 'NOONA-WF-013', l_unreach || ' خطوة لا يمكن الوصول إليها',
                          l_unreach || ' unreachable steps');

    UPDATE wf_definition_version
       SET status_code = 'RETIRED', effective_to = TRUNC(SYSDATE)
     WHERE definition_id = l_v.definition_id AND status_code = 'ACTIVE';
    SELECT JSON_OBJECT(
             'steps' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('code' VALUE step_code, 'type' VALUE step_type,
                                    'rule' VALUE assignee_rule, 'ref' VALUE assignee_ref_id,
                                    'join' VALUE join_policy) RETURNING CLOB)
                              FROM wf_step_def WHERE version_id = p_version_id),
             'transitions' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('from' VALUE f.step_code, 'to' VALUE t2.step_code,
                                    'outcome' VALUE t.outcome_code, 'default' VALUE t.is_default) RETURNING CLOB)
                                    FROM wf_transition_def t JOIN wf_step_def f ON f.id = t.from_step_id
                                    JOIN wf_step_def t2 ON t2.id = t.to_step_id WHERE t.version_id = p_version_id)
             RETURNING CLOB)
      INTO l_v.definition_json FROM dual;
    UPDATE wf_definition_version
       SET status_code = 'ACTIVE', effective_from = TRUNC(SYSDATE), published_by = NOONA_CTX_PKG.current_user_name,
           published_at = SYSTIMESTAMP, definition_json = l_v.definition_json
     WHERE id = p_version_id;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'WF_DEFINITION_VERSION', p_version_id, 'PUBLISH', 'SUCCESS',
                              p_new_values => l_v.definition_json);
  END publish_version;

  -- ================================================================ rules
  FUNCTION cond_true(p_cond JSON_OBJECT_T, p_ctx JSON_OBJECT_T) RETURN BOOLEAN IS
    l_field VARCHAR2(100) := p_cond.get_string('field');
    l_op    VARCHAR2(10)  := p_cond.get_string('op');
    l_val   JSON_ELEMENT_T := p_cond.get('value');
    l_ctxv  JSON_ELEMENT_T;
    l_arr   JSON_ARRAY_T;
  BEGIN
    IF NOT p_ctx.has(l_field) THEN
      RETURN FALSE;
    END IF;
    l_ctxv := p_ctx.get(l_field);
    IF l_op = 'in' THEN
      l_arr := TREAT(l_val AS JSON_ARRAY_T);
      FOR i IN 0 .. l_arr.get_size - 1 LOOP
        IF l_arr.get(i).to_string = l_ctxv.to_string THEN RETURN TRUE; END IF;
      END LOOP;
      RETURN FALSE;
    END IF;
    IF l_val.is_number AND l_ctxv.is_number THEN
      DECLARE
        a NUMBER := p_ctx.get_number(l_field);
        b NUMBER := p_cond.get_number('value');
      BEGIN
        RETURN CASE l_op WHEN '=' THEN a = b WHEN '!=' THEN a <> b WHEN '>' THEN a > b
                         WHEN '>=' THEN a >= b WHEN '<' THEN a < b WHEN '<=' THEN a <= b ELSE FALSE END;
      END;
    END IF;
    DECLARE
      a VARCHAR2(4000) := p_ctx.get_string(l_field);
      b VARCHAR2(4000) := p_cond.get_string('value');
    BEGIN
      RETURN CASE l_op WHEN '=' THEN a = b WHEN '!=' THEN a <> b ELSE FALSE END;
    END;
  END cond_true;

  FUNCTION expr_true(p_expr JSON_OBJECT_T, p_ctx JSON_OBJECT_T) RETURN BOOLEAN IS
    l_arr JSON_ARRAY_T;
  BEGIN
    IF p_expr.has('all') THEN
      l_arr := p_expr.get_array('all');
      FOR i IN 0 .. l_arr.get_size - 1 LOOP
        IF NOT expr_true(TREAT(l_arr.get(i) AS JSON_OBJECT_T), p_ctx) THEN RETURN FALSE; END IF;
      END LOOP;
      RETURN TRUE;
    ELSIF p_expr.has('any') THEN
      l_arr := p_expr.get_array('any');
      FOR i IN 0 .. l_arr.get_size - 1 LOOP
        IF expr_true(TREAT(l_arr.get(i) AS JSON_OBJECT_T), p_ctx) THEN RETURN TRUE; END IF;
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN cond_true(p_expr, p_ctx);
  END expr_true;

  FUNCTION eval_rule(p_rule_id IN NUMBER, p_context IN CLOB) RETURN BOOLEAN IS
    l_expr CLOB;
  BEGIN
    SELECT rule_expression INTO l_expr FROM wf_rule WHERE id = p_rule_id;
    RETURN expr_true(JSON_OBJECT_T.parse(l_expr), JSON_OBJECT_T.parse(NVL(p_context, '{}')));
  END eval_rule;

  -- ================================================================ assignment
  FUNCTION add_business_minutes(p_from TIMESTAMP WITH LOCAL TIME ZONE, p_minutes NUMBER, p_calendar_id NUMBER)
    RETURN TIMESTAMP WITH LOCAL TIME ZONE IS
    l_weekend VARCHAR2(20);
    l_days    NUMBER := CEIL(p_minutes / 480);    -- يوم عمل = 8 ساعات
    l_d       DATE := TRUNC(CAST(p_from AS DATE));
    l_n       NUMBER;
  BEGIN
    IF p_calendar_id IS NULL THEN
      RETURN p_from + NUMTODSINTERVAL(p_minutes, 'MINUTE');
    END IF;
    SELECT weekend_days INTO l_weekend FROM wf_business_calendar WHERE id = p_calendar_id;
    WHILE l_days > 0 LOOP
      l_d := l_d + 1;
      SELECT COUNT(*) INTO l_n FROM wf_calendar_holiday WHERE calendar_id = p_calendar_id AND holiday_date = l_d;
      IF l_n = 0 AND INSTR(',' || l_weekend || ',', ',' || TO_CHAR(l_d, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') || ',') = 0 THEN
        l_days := l_days - 1;
      END IF;
    END LOOP;
    RETURN CAST(l_d AS TIMESTAMP WITH LOCAL TIME ZONE) + NUMTODSINTERVAL(MOD(CAST(p_from AS DATE) - TRUNC(CAST(p_from AS DATE)), 1), 'DAY');
  END add_business_minutes;

  FUNCTION resolve(p_inst wf_instance%ROWTYPE, p_step wf_step_def%ROWTYPE) RETURN t_ids IS
    l_ids  t_ids := t_ids();
    l_m    NUMBER;
    l_amt  NUMBER := ctx_num(p_inst.context_snapshot, 'amount');
    l_cur  VARCHAR2(3) := ctx_str(p_inst.context_snapshot, 'currency');
    l_pos  NUMBER;
  BEGIN
    CASE p_step.assignee_rule
      WHEN 'USER' THEN l_ids.EXTEND; l_ids(1) := p_step.assignee_ref_id;
      WHEN 'REQUESTER' THEN l_ids.EXTEND; l_ids(1) := p_inst.initiator_member_id;
      WHEN 'MANAGER' THEN
        l_m := NOONA_ORG_PKG.manager_of(p_inst.initiator_member_id);
        IF l_m IS NOT NULL THEN l_ids.EXTEND; l_ids(1) := l_m; END IF;
      WHEN 'HEAD_POSITION' THEN
        IF p_step.assignee_ref_id IS NOT NULL THEN
          l_m := NOONA_ORG_PKG.unit_head(p_step.assignee_ref_id);
        ELSE
          l_pos := NOONA_ORG_PKG.primary_position(p_inst.initiator_member_id);
          IF l_pos IS NOT NULL THEN
            SELECT NOONA_ORG_PKG.unit_head(org_unit_id) INTO l_m FROM org_position WHERE id = l_pos;
          END IF;
        END IF;
        IF l_m IS NOT NULL THEN l_ids.EXTEND; l_ids(1) := l_m; END IF;
      WHEN 'POSITION' THEN
        l_m := NOONA_ORG_PKG.position_holder(p_step.assignee_ref_id);
        IF l_m IS NOT NULL THEN l_ids.EXTEND; l_ids(1) := l_m; END IF;
      WHEN 'ROLE' THEN
        SELECT DISTINCT g.membership_id BULK COLLECT INTO l_ids
          FROM sec_role_grant g JOIN sec_user_membership m ON m.id = g.membership_id AND m.status_code = 'ACTIVE'
         WHERE g.role_id = p_step.assignee_ref_id AND g.status_code = 'ACTIVE'
           AND TRUNC(SYSDATE) BETWEEN g.effective_from AND NVL(g.effective_to, DATE '9999-12-31');
      WHEN 'COMMITTEE' THEN
        SELECT DISTINCT NVL(m.id, NOONA_ORG_PKG.position_holder(cm.position_id)) BULK COLLECT INTO l_ids
          FROM org_committee_member cm
          LEFT JOIN sec_user_membership m ON m.employee_id = cm.employee_id AND m.status_code = 'ACTIVE'
         WHERE cm.committee_id = p_step.assignee_ref_id AND cm.has_vote = 'Y'
           AND TRUNC(SYSDATE) BETWEEN cm.effective_from AND NVL(cm.effective_to, DATE '9999-12-31')
           AND NVL(m.id, NOONA_ORG_PKG.position_holder(cm.position_id)) IS NOT NULL;
      WHEN 'AUTHORITY_MATRIX' THEN
        -- أقل منصب يكفي حده للمبلغ والعملة ونوع المعاملة
        BEGIN
          SELECT NOONA_ORG_PKG.position_holder(am.position_id) INTO l_m
            FROM wf_authority_matrix am
           WHERE am.transaction_type = p_inst.object_type AND am.status_code = 'ACTIVE'
             AND am.action_code = 'APPROVE' AND am.position_id IS NOT NULL
             AND (am.company_id IS NULL OR am.company_id = p_inst.company_id)
             AND (am.currency_code IS NULL OR am.currency_code = l_cur)
             AND (am.max_amount IS NULL OR am.max_amount >= NVL(l_amt, 0))
             AND TRUNC(SYSDATE) BETWEEN am.effective_from AND NVL(am.effective_to, DATE '9999-12-31')
           ORDER BY am.max_amount NULLS LAST
           FETCH FIRST 1 ROWS ONLY;
          IF l_m IS NOT NULL THEN l_ids.EXTEND; l_ids(1) := l_m; END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
      ELSE
        NULL;   -- QUEUE أو قاعدة غير مدعومة: لا مستلم فردي
    END CASE;
    RETURN l_ids;
  END resolve;

  PROCEDURE notify(p_task_id NUMBER, p_member NUMBER, p_title VARCHAR2, p_due TIMESTAMP WITH LOCAL TIME ZONE,
                   p_event VARCHAR2 DEFAULT 'WF_TASK_ASSIGNED') IS
    l_evt NUMBER;
  BEGIN
    IF p_member IS NULL THEN RETURN; END IF;
    SELECT MIN(id) INTO l_evt FROM ntf_event_type WHERE code = p_event;
    IF l_evt IS NULL THEN RETURN; END IF;
    INSERT INTO ntf_notification (event_type_id, membership_id, source_entity_type, source_entity_id, title,
                                  link_url, idempotency_key, due_at, correlation_id)
    VALUES (l_evt, p_member, 'WF_TASK', p_task_id, SUBSTR(p_title, 1, 500),
            -- اسم مستعار للتطبيق والصفحة بدل الأرقام (تختلف أرقام التطبيقات بين البيئات)
            'f?p=NOONA_PORTAL:TASK:::NO::P2_TASK_ID:' || p_task_id,
            p_event || ':' || p_task_id || ':' || p_member, p_due, NOONA_CTX_PKG.correlation_id);
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;     -- Idempotent
  END notify;

  PROCEDURE create_task(p_inst wf_instance%ROWTYPE, p_step wf_step_def%ROWTYPE, p_assignee NUMBER,
                        p_original NUMBER, p_delegation NUMBER, p_snapshot CLOB, p_status VARCHAR2 DEFAULT 'PENDING') IS
    l_due   TIMESTAMP WITH LOCAL TIME ZONE;
    l_warn  TIMESTAMP WITH LOCAL TIME ZONE;
    l_sla   wf_sla_policy%ROWTYPE;
    l_task  NUMBER;
    l_prio  VARCHAR2(30) := NVL(ctx_str(p_inst.context_snapshot, 'priority'), 'NORMAL');
  BEGIN
    IF p_step.sla_policy_id IS NOT NULL THEN
      SELECT * INTO l_sla FROM wf_sla_policy WHERE id = p_step.sla_policy_id;
      IF l_sla.completion_minutes IS NOT NULL THEN
        l_due := add_business_minutes(SYSTIMESTAMP, l_sla.completion_minutes, l_sla.calendar_id);
        IF l_sla.warn_before_minutes IS NOT NULL THEN
          l_warn := l_due - NUMTODSINTERVAL(l_sla.warn_before_minutes, 'MINUTE');
        END IF;
      END IF;
    END IF;
    INSERT INTO wf_task (instance_id, step_id, task_type, assignee_member_id, original_member_id,
                         assignee_position_id, queue_id, delegation_id, priority_code, due_at, warn_at,
                         resolution_snapshot, status_code)
    VALUES (p_inst.id, p_step.id, p_step.step_type, p_assignee, NVL(p_original, p_assignee),
            CASE WHEN NVL(p_original, p_assignee) IS NOT NULL THEN NOONA_ORG_PKG.primary_position(NVL(p_original, p_assignee)) END,
            p_step.queue_id, p_delegation,
            l_prio, l_due, l_warn, p_snapshot, p_status)
    RETURNING id INTO l_task;
    notify(l_task, p_assignee, 'مهمة جديدة: ' || p_step.name_ar, l_due);
  END create_task;

  PROCEDURE create_tasks(p_inst wf_instance%ROWTYPE, p_step wf_step_def%ROWTYPE) IS
    l_ids      t_ids;
    l_assignee NUMBER;
    l_orig     NUMBER;
    l_dlg      NUMBER;
    l_sod      VARCHAR2(1);
    l_done     t_ids := t_ids();
    l_created  PLS_INTEGER := 0;
    l_wf_code  VARCHAR2(50) := definition_code(p_inst);
    FUNCTION already(p_m NUMBER) RETURN BOOLEAN IS
    BEGIN
      FOR i IN 1 .. l_done.COUNT LOOP IF l_done(i) = p_m THEN RETURN TRUE; END IF; END LOOP;
      RETURN FALSE;
    END;
  BEGIN
    l_ids := resolve(p_inst, p_step);
    FOR i IN 1 .. l_ids.COUNT LOOP
      l_assignee := l_ids(i);
      l_sod := 'N';
      -- SoD: لا يعتمد الطالب معاملته؛ يرفع للمدير
      IF l_assignee = p_inst.initiator_member_id AND p_step.allow_self_approval = 'N'
         AND p_step.step_type IN ('APPROVAL', 'REVIEW', 'SIGNATURE') THEN
        l_assignee := NOONA_ORG_PKG.manager_of(p_inst.initiator_member_id);
        l_sod := 'Y';
      END IF;
      CONTINUE WHEN l_assignee IS NULL OR already(l_assignee);
      l_orig := l_assignee;
      l_dlg := NOONA_DELEGATION_PKG.find_delegation(
                 p_grantor_member_id => l_assignee,
                 p_action_code       => 'APPROVE',
                 p_company_id        => p_inst.company_id,
                 p_transaction_type  => p_inst.object_type,
                 p_workflow_code     => l_wf_code,
                 p_amount            => ctx_num(p_inst.context_snapshot, 'amount'),
                 p_currency          => ctx_str(p_inst.context_snapshot, 'currency'));
      IF l_dlg IS NOT NULL AND NOONA_DELEGATION_PKG.delegate_of(l_dlg) <> p_inst.initiator_member_id THEN
        l_assignee := NOONA_DELEGATION_PKG.delegate_of(l_dlg);
      ELSE
        l_dlg := NULL;
      END IF;
      l_done.EXTEND; l_done(l_done.COUNT) := l_orig;
      create_task(p_inst, p_step, l_assignee, l_orig, l_dlg,
                  JSON_OBJECT('rule' VALUE p_step.assignee_rule, 'ref' VALUE p_step.assignee_ref_id,
                              'resolved' VALUE l_ids(i), 'authority' VALUE l_orig, 'delegation_id' VALUE l_dlg,
                              'sod_escalated' VALUE l_sod, 'at' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS')));
      l_created := l_created + 1;
    END LOOP;

    IF l_created = 0 THEN
      IF p_step.queue_id IS NOT NULL THEN
        create_task(p_inst, p_step, NULL, NULL, NULL, '{"rule":"QUEUE"}');
      ELSE
        -- لا مستلم مؤهل: مهمة مصعدة لمسؤول Workflow (لا إسقاط صامت)
        create_task(p_inst, p_step, NULL, NULL, NULL,
                    '{"rule":"' || p_step.assignee_rule || '","unresolved":true}', 'ESCALATED');
        INSERT INTO wf_escalation (task_id, level_no, escalation_type)
        SELECT MAX(id), 1, 'INCIDENT' FROM wf_task WHERE instance_id = p_inst.id AND step_id = p_step.id;
      END IF;
    END IF;
  END create_tasks;

  -- ================================================================ engine
  PROCEDURE complete_instance(p_inst_id NUMBER, p_outcome VARCHAR2, p_end_step_id NUMBER DEFAULT NULL) IS
    l_i   wf_instance%ROWTYPE := inst(p_inst_id);
    l_h   VARCHAR2(128);
  BEGIN
    UPDATE wf_task SET status_code = 'CANCELLED', completed_at = SYSTIMESTAMP
     WHERE instance_id = p_inst_id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED');
    UPDATE wf_instance SET status_code = 'COMPLETED', outcome_code = p_outcome, completed_at = SYSTIMESTAMP
     WHERE id = p_inst_id;
    outbox('WF_INSTANCE', p_inst_id, 'WF_INSTANCE.COMPLETED',
           JSON_OBJECT('instance_id' VALUE p_inst_id, 'object_type' VALUE l_i.object_type,
                       'object_id' VALUE l_i.object_id, 'outcome' VALUE p_outcome));
    NOONA_AUDIT_PKG.log_event('APPROVAL', l_i.object_type, l_i.object_id, 'WORKFLOW_' || p_outcome, 'SUCCESS',
                              p_company_id => l_i.company_id);
    IF p_end_step_id IS NOT NULL THEN
      SELECT action_handler INTO l_h FROM wf_step_def WHERE id = p_end_step_id;
      IF l_h IS NOT NULL THEN
        EXECUTE IMMEDIATE 'BEGIN ' || DBMS_ASSERT.QUALIFIED_SQL_NAME(l_h) || '(:1, :2); END;'
          USING p_inst_id, p_outcome;
      END IF;
    END IF;
  END complete_instance;

  PROCEDURE enter_step(p_inst_id NUMBER, p_step_id NUMBER) IS
    l_s    wf_step_def%ROWTYPE := step(p_step_id);
    l_i    wf_instance%ROWTYPE := inst(p_inst_id);
    l_open NUMBER;
  BEGIN
    IF l_i.status_code NOT IN ('RUNNING', 'WAITING') THEN
      RETURN;
    END IF;
    CASE
      WHEN l_s.step_type = 'END' THEN
        complete_instance(p_inst_id, NVL(l_i.outcome_code, 'COMPLETED'), p_step_id);
      WHEN l_s.step_type IN ('APPROVAL', 'REVIEW', 'USER_TASK', 'SIGNATURE', 'MANUAL_CONFIRMATION') THEN
        create_tasks(l_i, l_s);
        UPDATE wf_instance SET status_code = 'WAITING' WHERE id = p_inst_id;
      WHEN l_s.step_type = 'PARALLEL_JOIN' THEN
        SELECT COUNT(*) INTO l_open FROM wf_task
         WHERE instance_id = p_inst_id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED');
        IF l_open = 0 THEN
          follow(p_inst_id, p_step_id, NULL);
        END IF;
      WHEN l_s.step_type IN ('START', 'DECISION', 'PARALLEL_SPLIT') THEN
        follow(p_inst_id, p_step_id, NULL);
      ELSE
        -- خطوات آلية: تنفذ الإجراء المعتمد ثم تتابع
        IF l_s.action_handler IS NOT NULL THEN
          EXECUTE IMMEDIATE 'BEGIN ' || DBMS_ASSERT.QUALIFIED_SQL_NAME(l_s.action_handler) || '(:1, :2); END;'
            USING p_inst_id, l_i.outcome_code;
        END IF;
        follow(p_inst_id, p_step_id, 'DONE');
    END CASE;
  END enter_step;

  PROCEDURE follow(p_inst_id NUMBER, p_step_id NUMBER, p_outcome VARCHAR2) IS
    l_s     wf_step_def%ROWTYPE := step(p_step_id);
    l_i     wf_instance%ROWTYPE := inst(p_inst_id);
    l_found BOOLEAN := FALSE;
  BEGIN
    UPDATE wf_instance SET status_code = 'RUNNING' WHERE id = p_inst_id AND status_code = 'WAITING';
    FOR t IN (SELECT * FROM wf_transition_def
               WHERE from_step_id = p_step_id
                 AND (outcome_code = p_outcome OR outcome_code IS NULL OR is_default = 'Y')
               ORDER BY CASE WHEN outcome_code = p_outcome THEN 0 WHEN rule_id IS NOT NULL THEN 1
                             WHEN is_default = 'Y' THEN 3 ELSE 2 END, sort_order NULLS LAST, id) LOOP
      -- انتقال بنتيجة مختلفة صريحة لا يؤخذ
      CONTINUE WHEN t.outcome_code IS NOT NULL AND t.outcome_code <> NVL(p_outcome, '#');
      CONTINUE WHEN t.rule_id IS NOT NULL AND NOT eval_rule(t.rule_id, l_i.context_snapshot);
      l_found := TRUE;
      enter_step(p_inst_id, t.to_step_id);
      EXIT WHEN l_s.step_type <> 'PARALLEL_SPLIT';
    END LOOP;

    IF NOT l_found THEN
      IF p_outcome IN ('REJECTED', 'RETURNED') THEN
        complete_instance(p_inst_id, p_outcome);
      ELSE
        UPDATE wf_instance SET status_code = 'FAILED' WHERE id = p_inst_id;
        NOONA_CORE_PKG.raise_error('NOONA-WF-030', 'لا يوجد انتقال صالح من الخطوة ' || l_s.step_code,
                                   'No valid transition from step ' || l_s.step_code);
      END IF;
    END IF;
  END follow;

  FUNCTION start_workflow(
    p_definition_code IN VARCHAR2,
    p_object_type     IN VARCHAR2,
    p_object_id       IN NUMBER,
    p_context         IN CLOB     DEFAULT NULL,
    p_idempotency_key IN VARCHAR2 DEFAULT NULL,
    p_company_id      IN NUMBER   DEFAULT NULL) RETURN NUMBER IS
    l_key     VARCHAR2(100) := NVL(p_idempotency_key, p_definition_code || ':' || p_object_type || ':' || p_object_id);
    l_id      NUMBER;
    l_version NUMBER;
    l_company NUMBER := NVL(p_company_id, NOONA_CTX_PKG.company_id);
    l_start   NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    BEGIN
      SELECT id INTO l_id FROM wf_instance WHERE idempotency_key = l_key;
      RETURN l_id;                                            -- Idempotent
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    -- الأكثر تحديداً يتقدم: شركة ← مؤسسة ← منصة
    BEGIN
      SELECT v.id INTO l_version
        FROM wf_definition d JOIN wf_definition_version v ON v.definition_id = d.id AND v.status_code = 'ACTIVE'
       WHERE d.code = UPPER(p_definition_code) AND d.is_active = 'Y'
         AND (d.scope_level <> 'COMPANY' OR d.scope_id = l_company)
       ORDER BY CASE WHEN d.scope_level = 'COMPANY' THEN 1 WHEN d.tenant_id IS NOT NULL THEN 2 ELSE 3 END
       FETCH FIRST 1 ROWS ONLY;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-WF-020', 'لا يوجد مسار منشور بالرمز ' || p_definition_code,
                                 'No active workflow ' || p_definition_code);
    END;
    INSERT INTO wf_instance (version_id, company_id, object_type, object_id, idempotency_key, initiator_member_id,
                             context_snapshot, correlation_id, status_code)
    VALUES (l_version, l_company, p_object_type, p_object_id, l_key, NOONA_CTX_PKG.membership_id,
            NVL(p_context, '{}'), NOONA_CTX_PKG.correlation_id, 'RUNNING')
    RETURNING id INTO l_id;
    SELECT id INTO l_start FROM wf_step_def WHERE version_id = l_version AND step_type = 'START';
    enter_step(l_id, l_start);
    NOONA_AUDIT_PKG.log_event('APPROVAL', p_object_type, p_object_id, 'WORKFLOW_START', 'SUCCESS',
                              p_new_values => p_context, p_company_id => l_company);
    RETURN l_id;
  END start_workflow;

  PROCEDURE decide_step(p_inst_id NUMBER, p_step_id NUMBER) IS
    l_s        wf_step_def%ROWTYPE := step(p_step_id);
    l_total    NUMBER;
    l_approved NUMBER;
    l_rejected NUMBER;
    l_returned NUMBER;
    l_open     NUMBER;
    l_outcome  VARCHAR2(30);
    l_policy   VARCHAR2(30);
  BEGIN
    SELECT COUNT(*),
           COUNT(CASE WHEN status_code = 'COMPLETED' AND outcome_code = 'APPROVED' THEN 1 END),
           COUNT(CASE WHEN status_code = 'COMPLETED' AND outcome_code = 'REJECTED' THEN 1 END),
           COUNT(CASE WHEN status_code = 'RETURNED' THEN 1 END),
           COUNT(CASE WHEN status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED') THEN 1 END)
      INTO l_total, l_approved, l_rejected, l_returned, l_open
      FROM wf_task
     WHERE instance_id = p_inst_id AND step_id = p_step_id AND status_code NOT IN ('REASSIGNED', 'CANCELLED');

    l_policy := NVL(l_s.join_policy, 'ALL');
    IF l_returned > 0 THEN
      l_outcome := 'RETURNED';
    ELSIF l_policy IN ('ALL', 'MANDATORY_PARTY') THEN
      l_outcome := CASE WHEN l_rejected > 0 THEN 'REJECTED' WHEN l_open = 0 THEN 'APPROVED' END;
    ELSIF l_policy = 'ANY' THEN
      l_outcome := CASE WHEN l_approved > 0 THEN 'APPROVED' WHEN l_open = 0 THEN 'REJECTED' END;
    ELSIF l_policy = 'COUNT' THEN
      l_outcome := CASE WHEN l_approved >= l_s.join_value THEN 'APPROVED'
                        WHEN l_approved + l_open < l_s.join_value THEN 'REJECTED' END;
    ELSIF l_policy = 'PERCENT' THEN
      l_outcome := CASE WHEN l_approved * 100 >= l_s.join_value * l_total THEN 'APPROVED'
                        WHEN (l_approved + l_open) * 100 < l_s.join_value * l_total THEN 'REJECTED' END;
    ELSIF l_policy = 'MAJORITY' THEN
      l_outcome := CASE WHEN l_approved * 2 > l_total THEN 'APPROVED'
                        WHEN l_rejected * 2 >= l_total THEN 'REJECTED' END;
    END IF;

    IF l_outcome IS NOT NULL THEN
      UPDATE wf_task SET status_code = 'CANCELLED', completed_at = SYSTIMESTAMP
       WHERE instance_id = p_inst_id AND step_id = p_step_id
         AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED');
      UPDATE wf_instance SET outcome_code = l_outcome WHERE id = p_inst_id;
      follow(p_inst_id, p_step_id, l_outcome);
    END IF;
  END decide_step;

  PROCEDURE act(
    p_task_id          IN NUMBER,
    p_action           IN VARCHAR2,
    p_comments         IN VARCHAR2 DEFAULT NULL,
    p_target_member_id IN NUMBER   DEFAULT NULL) IS
    l_t        wf_task%ROWTYPE;
    l_i        wf_instance%ROWTYPE;
    l_s        wf_step_def%ROWTYPE;
    l_me       NUMBER := NOONA_CTX_PKG.membership_id;
    l_capacity VARCHAR2(20);
    l_behalf   NUMBER;
    l_dlg      NUMBER;
    l_n        NUMBER;
    l_action   VARCHAR2(30) := UPPER(p_action);
    l_amt      NUMBER;
    l_cur      VARCHAR2(3);
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    BEGIN
      SELECT * INTO l_t FROM wf_task WHERE id = p_task_id FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-WF-040', 'المهمة غير موجودة', 'Task not found');
    END;
    l_i := inst(l_t.instance_id);
    l_s := step(l_t.step_id);
    l_amt := ctx_num(l_i.context_snapshot, 'amount');
    l_cur := ctx_str(l_i.context_snapshot, 'currency');
    NOONA_CORE_PKG.assert(is_open(l_t.status_code) OR (l_t.status_code = 'ESCALATED' AND l_action = 'REASSIGN'),
      'NOONA-WF-041', 'المهمة ليست مفتوحة (' || l_t.status_code || ')', 'Task is not open');

    -- تحديد الصفة: بنفسه / بالتفويض / من قائمة العمل / مسؤول Workflow
    IF l_action = 'CLAIM' THEN
      NOONA_CORE_PKG.assert(l_t.assignee_member_id IS NULL AND l_t.queue_id IS NOT NULL, 'NOONA-WF-042',
        'المهمة ليست في قائمة عمل مشتركة', 'Task is not in a shared queue');
      SELECT COUNT(*) INTO l_n FROM wf_queue_member qm
       WHERE qm.queue_id = l_t.queue_id
         AND TRUNC(SYSDATE) BETWEEN qm.effective_from AND NVL(qm.effective_to, DATE '9999-12-31')
         AND (qm.membership_id = l_me
              OR qm.role_id IN (SELECT role_id FROM sec_role_grant WHERE membership_id = l_me AND status_code = 'ACTIVE')
              OR qm.position_id = NOONA_ORG_PKG.primary_position(l_me));
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-WF-043', 'لست عضواً في قائمة العمل', 'Not a member of the queue');
      l_capacity := 'SELF';
    ELSIF l_t.assignee_member_id = l_me THEN
      IF l_t.delegation_id IS NOT NULL THEN
        l_capacity := 'DELEGATE'; l_behalf := l_t.original_member_id; l_dlg := l_t.delegation_id;
      ELSE
        l_capacity := 'SELF';
      END IF;
    ELSIF l_action = 'REASSIGN' AND NOONA_SECURITY_PKG.has_permission('WF_INSTANCE.UPDATE') = 'Y' THEN
      l_capacity := 'ADMIN';
    ELSE
      l_dlg := NOONA_DELEGATION_PKG.can_act_for(l_me, l_t.assignee_member_id, 'APPROVE', l_i.company_id,
                                                l_i.object_type, definition_code(l_i), l_amt, l_cur);
      NOONA_CORE_PKG.assert(l_dlg IS NOT NULL, 'NOONA-WF-044', 'المهمة غير مسندة إليك ولا تملك تفويضاً صالحاً لها',
                            'Task is not assigned to you and no valid delegation covers it');
      l_capacity := 'DELEGATE'; l_behalf := l_t.assignee_member_id;
    END IF;

    -- SoD وقت القرار: لا يعتمد المنشئ معاملته (حتى بالتفويض)
    IF l_action IN ('APPROVE', 'APPROVE_WITH_CONDITIONS') AND l_me = l_i.initiator_member_id
       AND l_s.allow_self_approval = 'N' THEN
      NOONA_AUDIT_PKG.log_event('APPROVAL', l_i.object_type, l_i.object_id, 'SELF_APPROVAL_BLOCKED', 'DENIED');
      NOONA_CORE_PKG.raise_error('NOONA-WF-045', 'لا يجوز اعتماد معاملة أنشأتها (فصل المهام)',
                                 'You cannot approve a transaction you initiated (SoD)');
    END IF;

    INSERT INTO wf_task_action (task_id, action_code, actor_member_id, on_behalf_member_id, delegation_id,
                                actor_position_id, acting_capacity, target_member_id, comments, session_id)
    VALUES (p_task_id, l_action, l_me, l_behalf, l_dlg, NOONA_ORG_PKG.primary_position(l_me), l_capacity,
            p_target_member_id, p_comments, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'SESSION_ID')));

    IF l_dlg IS NOT NULL AND l_action IN ('APPROVE', 'APPROVE_WITH_CONDITIONS', 'REJECT', 'RETURN') THEN
      NOONA_DELEGATION_PKG.record_exercise(l_dlg, l_action, l_i.object_type, l_i.object_id, p_task_id, l_amt, l_cur);
    END IF;

    CASE
      WHEN l_action = 'CLAIM' THEN
        UPDATE wf_task SET assignee_member_id = l_me, original_member_id = l_me, status_code = 'CLAIMED',
                           claimed_at = SYSTIMESTAMP WHERE id = p_task_id;
      WHEN l_action = 'COMMENT' THEN
        NULL;
      WHEN l_action = 'REQUEST_INFO' THEN
        UPDATE wf_task SET status_code = 'WAITING_INFO' WHERE id = p_task_id;
      WHEN l_action = 'PROVIDE_INFO' THEN
        UPDATE wf_task SET status_code = 'PENDING' WHERE id = p_task_id;
      WHEN l_action IN ('REASSIGN', 'FORWARD') THEN
        NOONA_CORE_PKG.assert(p_target_member_id IS NOT NULL AND p_target_member_id <> l_i.initiator_member_id,
          'NOONA-WF-046', 'المستلم الجديد غير صالح', 'Invalid target');
        UPDATE wf_task SET status_code = 'REASSIGNED', completed_at = SYSTIMESTAMP WHERE id = p_task_id;
        create_task(l_i, l_s, p_target_member_id, p_target_member_id, NULL,
                    JSON_OBJECT('rule' VALUE 'REASSIGN', 'from_task' VALUE p_task_id, 'by' VALUE l_me));
      WHEN l_action IN ('APPROVE', 'APPROVE_WITH_CONDITIONS', 'ACKNOWLEDGE', 'REJECT') THEN
        UPDATE wf_task SET status_code = 'COMPLETED', completed_at = SYSTIMESTAMP,
                           outcome_code = CASE WHEN l_action = 'REJECT' THEN 'REJECTED' ELSE 'APPROVED' END
         WHERE id = p_task_id;
        decide_step(l_i.id, l_s.id);
      WHEN l_action = 'RETURN' THEN
        UPDATE wf_task SET status_code = 'RETURNED', completed_at = SYSTIMESTAMP, outcome_code = 'RETURNED'
         WHERE id = p_task_id;
        decide_step(l_i.id, l_s.id);
      ELSE
        NOONA_CORE_PKG.raise_error('NOONA-WF-047', 'إجراء غير مدعوم: ' || l_action, 'Unsupported action ' || l_action);
    END CASE;
  END act;

  PROCEDURE cancel_instance(p_instance_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_i wf_instance%ROWTYPE := inst(p_instance_id);
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_CORE_PKG.assert(l_i.initiator_member_id = NOONA_CTX_PKG.membership_id
                          OR NOONA_SECURITY_PKG.has_permission('WF_INSTANCE.CANCEL') = 'Y',
      'NOONA-WF-050', 'غير مخول بإلغاء المسار', 'Not allowed to cancel this workflow');
    NOONA_CORE_PKG.assert(l_i.status_code IN ('RUNNING', 'WAITING', 'SUSPENDED'), 'NOONA-WF-051',
      'المسار ليس قيد التشغيل', 'Workflow is not running');
    UPDATE wf_task SET status_code = 'CANCELLED', completed_at = SYSTIMESTAMP
     WHERE instance_id = p_instance_id AND status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS', 'WAITING_INFO', 'ESCALATED');
    UPDATE wf_instance SET status_code = 'CANCELLED', outcome_code = 'CANCELLED', completed_at = SYSTIMESTAMP
     WHERE id = p_instance_id;
    outbox('WF_INSTANCE', p_instance_id, 'WF_INSTANCE.CANCELLED',
           JSON_OBJECT('instance_id' VALUE p_instance_id, 'object_type' VALUE l_i.object_type,
                       'object_id' VALUE l_i.object_id, 'reason' VALUE p_reason));
    NOONA_AUDIT_PKG.log_event('APPROVAL', l_i.object_type, l_i.object_id, 'WORKFLOW_CANCEL', 'SUCCESS',
                              p_reason => p_reason, p_company_id => l_i.company_id);
  END cancel_instance;

  -- مهمة مجدولة (DBMS_SCHEDULER) تعمل عبر كل المؤسسات بوضع النظام
  PROCEDURE escalate_overdue IS
    l_target NUMBER;
    l_level  NUMBER;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    FOR t IN (SELECT * FROM wf_task
               WHERE status_code IN ('PENDING', 'CLAIMED', 'IN_PROGRESS') AND due_at < SYSTIMESTAMP
                 AND assignee_member_id IS NOT NULL
               FOR UPDATE SKIP LOCKED) LOOP
      l_target := NOONA_ORG_PKG.manager_of(t.assignee_member_id);
      SELECT COUNT(*) + 1 INTO l_level FROM wf_escalation WHERE task_id = t.id;
      INSERT INTO wf_escalation (tenant_id, task_id, level_no, escalation_type, target_member_id)
      VALUES (t.tenant_id, t.id, l_level, CASE WHEN l_target IS NULL THEN 'INCIDENT' ELSE 'MANAGER' END, l_target);
      IF l_target IS NOT NULL THEN
        -- المهمة الأصلية تستبدل بمهمة المدير (لا تبقى مفتوحة فتعطل قرار الخطوة)
        UPDATE wf_task SET status_code = 'REASSIGNED', completed_at = SYSTIMESTAMP WHERE id = t.id;
        INSERT INTO wf_task (tenant_id, instance_id, step_id, task_type, assignee_member_id, original_member_id,
                             priority_code, resolution_snapshot, status_code)
        VALUES (t.tenant_id, t.instance_id, t.step_id, t.task_type, l_target, t.original_member_id, 'HIGH',
                JSON_OBJECT('rule' VALUE 'ESCALATION', 'from_task' VALUE t.id, 'level' VALUE l_level), 'PENDING');
      END IF;
    END LOOP;
    NOONA_CORE_PKG.end_system;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CORE_PKG.end_system;
    RAISE;
  END escalate_overdue;

END NOONA_WORKFLOW_PKG;
/
