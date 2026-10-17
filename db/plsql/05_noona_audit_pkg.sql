-- =============================================================================
-- NOONA PLUS ERP | NOONA_AUDIT_PKG - سجل التدقيق المركزي (المرحلة 32)
-- Who/What/When/Object/Action/Old/New/Session/IP مع سلسلة Hash مقاومة للعبث.
-- أحداث النجاح تسجل داخل معاملة العملية نفسها؛ أحداث الرفض والفشل تسجل في
-- معاملة مستقلة حتى لا تضيع عند ROLLBACK.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_AUDIT_PKG AUTHID DEFINER AS
  PROCEDURE log_event(
    p_category    IN VARCHAR2,
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_action      IN VARCHAR2,
    p_result      IN VARCHAR2 DEFAULT 'SUCCESS',
    p_old_values  IN CLOB     DEFAULT NULL,
    p_new_values  IN CLOB     DEFAULT NULL,
    p_reason      IN VARCHAR2 DEFAULT NULL,
    p_company_id  IN NUMBER   DEFAULT NULL);

  -- يعيد حساب السلسلة ويرجع أول حدث مكسور (NULL = سليمة)
  FUNCTION verify_chain(p_tenant_id IN NUMBER, p_from_id IN NUMBER DEFAULT 0) RETURN NUMBER;
END NOONA_AUDIT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_AUDIT_PKG AS

  FUNCTION sha256(p_text IN CLOB) RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(p_text, DBMS_CRYPTO.HASH_SH256)));
  END;

  FUNCTION payload(p_tenant NUMBER, p_cat VARCHAR2, p_type VARCHAR2, p_eid NUMBER,
                   p_action VARCHAR2, p_result VARCHAR2, p_user NUMBER, p_at TIMESTAMP WITH LOCAL TIME ZONE,
                   p_old CLOB, p_new CLOB, p_prev VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN p_prev || '|' || p_tenant || '|' || p_cat || '|' || p_type || '|' || p_eid || '|' ||
           p_action || '|' || p_result || '|' || p_user || '|' ||
           TO_CHAR(SYS_EXTRACT_UTC(CAST(p_at AS TIMESTAMP WITH TIME ZONE)), 'YYYY-MM-DD"T"HH24:MI:SS.FF6') ||
           '|' || p_old || '|' || p_new;
  END;

  PROCEDURE do_insert(
    p_category VARCHAR2, p_entity_type VARCHAR2, p_entity_id NUMBER, p_action VARCHAR2, p_result VARCHAR2,
    p_old_values CLOB, p_new_values CLOB, p_reason VARCHAR2, p_company_id NUMBER,
    p_autonomous BOOLEAN DEFAULT FALSE) IS
    l_tenant  NUMBER := NOONA_CTX_PKG.tenant_id;
    l_prev    VARCHAR2(128);
    l_hash    VARCHAR2(128);
    l_at      TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP;
    l_user    NUMBER := NOONA_CTX_PKG.user_id;
    l_member  NUMBER := NOONA_CTX_PKG.membership_id;
    l_company NUMBER := NVL(p_company_id, NOONA_CTX_PKG.company_id);
    l_session NUMBER := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'SESSION_ID'));
    l_reason  VARCHAR2(1000) := SUBSTR(p_reason, 1, 1000);
    l_unseen  VARCHAR2(400);
    l_n       NUMBER;
  BEGIN
    -- المعاملة المستقلة لا ترى صفوف المعاملة الأم غير المثبتة؛ ربط FK بها ينتظر قفل الأم => Deadlock.
    -- نربط فقط الصفوف المثبتة ونحفظ المعرفات الأخرى نصاً في السبب.
    IF p_autonomous THEN
      IF l_session IS NOT NULL THEN
        SELECT COUNT(*) INTO l_n FROM sec_session WHERE id = l_session;
        IF l_n = 0 THEN l_unseen := l_unseen || ' session=' || l_session; l_session := NULL; END IF;
      END IF;
      IF l_member IS NOT NULL THEN
        SELECT COUNT(*) INTO l_n FROM sec_user_membership WHERE id = l_member;
        IF l_n = 0 THEN l_unseen := l_unseen || ' membership=' || l_member; l_member := NULL; END IF;
      END IF;
      IF l_user IS NOT NULL THEN
        SELECT COUNT(*) INTO l_n FROM sec_user WHERE id = l_user;
        IF l_n = 0 THEN l_unseen := l_unseen || ' user=' || l_user; l_user := NULL; END IF;
      END IF;
      IF l_company IS NOT NULL THEN
        SELECT COUNT(*) INTO l_n FROM org_company WHERE id = l_company;
        IF l_n = 0 THEN l_unseen := l_unseen || ' company=' || l_company; l_company := NULL; END IF;
      END IF;
      IF l_unseen IS NOT NULL THEN
        l_reason := SUBSTR(l_reason || ' [uncommitted refs:' || l_unseen || ']', 1, 1000);
      END IF;
    END IF;

    BEGIN
      SELECT row_hash INTO l_prev
        FROM (SELECT row_hash FROM aud_event
               WHERE (tenant_id = l_tenant OR (tenant_id IS NULL AND l_tenant IS NULL))
               ORDER BY id DESC)
       WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_prev := 'GENESIS';
    END;

    l_hash := sha256(payload(l_tenant, p_category, p_entity_type, p_entity_id, p_action, p_result,
                             l_user, l_at, p_old_values, p_new_values, l_prev));

    INSERT INTO aud_event (tenant_id, event_category, entity_type, entity_id, action_code, result_code,
                           actor_user_id, membership_id, company_id, session_id, correlation_id,
                           request_source, ip_address, occurred_at, old_values, new_values, reason,
                           prev_hash, row_hash)
    VALUES (l_tenant, p_category, p_entity_type, p_entity_id, SUBSTR(p_action, 1, 50), p_result,
            l_user, l_member, l_company, l_session, NOONA_CTX_PKG.correlation_id,
            CASE WHEN SYS_CONTEXT('APEX$SESSION', 'APP_SESSION') IS NOT NULL THEN 'APEX' ELSE 'SYSTEM' END,
            SYS_CONTEXT('USERENV', 'IP_ADDRESS'), l_at, p_old_values, p_new_values, l_reason,
            l_prev, l_hash);
  END do_insert;

  PROCEDURE log_autonomous(
    p_category VARCHAR2, p_entity_type VARCHAR2, p_entity_id NUMBER, p_action VARCHAR2, p_result VARCHAR2,
    p_old_values CLOB, p_new_values CLOB, p_reason VARCHAR2, p_company_id NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    do_insert(p_category, p_entity_type, p_entity_id, p_action, p_result, p_old_values, p_new_values,
              p_reason, p_company_id, p_autonomous => TRUE);
    COMMIT;
  END log_autonomous;

  PROCEDURE log_event(
    p_category    IN VARCHAR2,
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_action      IN VARCHAR2,
    p_result      IN VARCHAR2 DEFAULT 'SUCCESS',
    p_old_values  IN CLOB     DEFAULT NULL,
    p_new_values  IN CLOB     DEFAULT NULL,
    p_reason      IN VARCHAR2 DEFAULT NULL,
    p_company_id  IN NUMBER   DEFAULT NULL) IS
  BEGIN
    IF p_result IN ('DENIED', 'FAILED') THEN
      log_autonomous(p_category, p_entity_type, p_entity_id, p_action, p_result, p_old_values, p_new_values,
                     p_reason, p_company_id);
    ELSE
      do_insert(p_category, p_entity_type, p_entity_id, p_action, p_result, p_old_values, p_new_values,
                p_reason, p_company_id);
    END IF;
  END log_event;

  -- السلسلة قد تتفرع (كتّاب متزامنون أو تسجيل الرفض في معاملة مستقلة يقرأ آخر صف مثبت فقط)،
  -- لذا يتحقق: (1) بصمة كل صف تطابق محتواه، (2) prev_hash يشير إلى GENESIS أو بصمة صف سابق.
  -- تعديل صف يكسر (1)، وحذف صف له تابع يكسر (2). يعيد أول ID مكسور أو NULL.
  FUNCTION verify_chain(p_tenant_id IN NUMBER, p_from_id IN NUMBER DEFAULT 0) RETURN NUMBER IS
    TYPE t_seen IS TABLE OF BOOLEAN INDEX BY VARCHAR2(128);
    l_seen  t_seen;
    l_first BOOLEAN := TRUE;
  BEGIN
    FOR r IN (SELECT * FROM aud_event
               WHERE (tenant_id = p_tenant_id OR (tenant_id IS NULL AND p_tenant_id IS NULL))
                 AND id > p_from_id
               ORDER BY id) LOOP
      IF r.row_hash <> sha256(payload(r.tenant_id, r.event_category, r.entity_type, r.entity_id,
                                      r.action_code, r.result_code, r.actor_user_id, r.occurred_at,
                                      r.old_values, r.new_values, r.prev_hash)) THEN
        RETURN r.id;
      END IF;
      -- أول صف في نطاق جزئي (p_from_id > 0) يقبل أي سابق
      IF r.prev_hash <> 'GENESIS' AND NOT l_seen.EXISTS(r.prev_hash) AND NOT (l_first AND p_from_id > 0) THEN
        RETURN r.id;
      END IF;
      l_seen(r.row_hash) := TRUE;
      l_first := FALSE;
    END LOOP;
    RETURN NULL;
  END verify_chain;

END NOONA_AUDIT_PKG;
/
