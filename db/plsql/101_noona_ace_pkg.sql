-- =============================================================================
-- NOONA PLUS ERP | NOONA_ACE_PKG - المحرك المحاسبي (Accounting Engine)
--   * كل مستند مصدر معتمد (سند قبض/صرف، فاتورة...) يتحول إلى قيد نظامي عبر هذا المحرك فقط
--   * حدث محاسبي لكل مستند بمفتاح منع التكرار (TENANT_ID + IDEMPOTENCY_KEY فريد) فلا يرحل المستند مرتين
--   * الربط ثنائي الاتجاه: الحدث يحمل رقم القيد، والقيد يحمل رقم الحدث (ACCOUNTING_EVENT_ID)
--   * العكس بقيد مقابل وحدث عكسي مرتبط بالحدث الأصلي
-- لا يمنح للتطبيق؛ تستدعيه حزم الأنظمة الفرعية فقط (ACCESSIBLE BY).
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_ACE_PKG AUTHID DEFINER ACCESSIBLE BY (PACKAGE NOONA_CSH_PKG, PACKAGE NOONA_INV_PKG, PACKAGE NOONA_PUR_PKG, PACKAGE NOONA_SAL_PKG, PACKAGE NOONA_POS_PKG, PACKAGE NOONA_MFG_PKG, PACKAGE NOONA_PAY_PKG, PACKAGE NOONA_FA_PKG, PACKAGE NOONA_HSP_PKG, PACKAGE NOONA_MNT_PKG, PACKAGE NOONA_HIS_PKG, PACKAGE NOONA_HIS_CLAIM_PKG, PACKAGE NOONA_HIS_CLIN_PKG, PACKAGE NOONA_PRJ_PKG, PACKAGE NOONA_LOC_PKG) AS

  -- يرحل مستنداً مصدراً: يعيد رقم القيد؛ يرفض المستند المرحل سابقاً (NOONA-ACE-001)
  FUNCTION post_source(p_event_class IN VARCHAR2, p_journal_source IN VARCHAR2, p_entity_type IN VARCHAR2,
                       p_entity_id IN NUMBER, p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2,
                       p_rate IN NUMBER, p_lines IN NOONA_GL_PKG.t_lines, p_reference IN VARCHAR2,
                       p_branch_id IN NUMBER DEFAULT NULL, p_journal_type IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- يعكس قيد المستند المصدر؛ يعيد رقم قيد العكس
  FUNCTION reverse_source(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER;
  -- قيد المستند الحالي (NULL إن لم يرحل)
  FUNCTION source_journal(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN NUMBER;
END NOONA_ACE_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_ACE_PKG AS

  FUNCTION source_journal(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    SELECT MAX(journal_id) INTO l_id FROM ace_accounting_event
     WHERE source_entity_type = p_entity_type AND source_entity_id = p_entity_id
       AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    RETURN l_id;
  END source_journal;

  FUNCTION post_source(p_event_class IN VARCHAR2, p_journal_source IN VARCHAR2, p_entity_type IN VARCHAR2,
                       p_entity_id IN NUMBER, p_doc_date IN DATE, p_description IN VARCHAR2, p_currency IN VARCHAR2,
                       p_rate IN NUMBER, p_lines IN NOONA_GL_PKG.t_lines, p_reference IN VARCHAR2,
                       p_branch_id IN NUMBER DEFAULT NULL, p_journal_type IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_class NUMBER;
    l_key   VARCHAR2(200);
    l_n     NUMBER;
    l_ev    NUMBER;
    l_j     NUMBER;
    l_total NUMBER := 0;
    l_dr    NUMBER := 0;
    l_cr    NUMBER := 0;
    l_cnt   NUMBER := p_lines.COUNT;
  BEGIN
    BEGIN
      SELECT id INTO l_class FROM ace_event_class WHERE code = p_event_class AND is_active = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-ACE-002', 'فئة الحدث المحاسبي غير معرفة: ' || p_event_class, 'Unknown event class');
    END;
    -- مفتاح منع التكرار: نسخة المستند تزيد بعد كل عكس فيسمح بإعادة الترحيل بعد التصحيح فقط
    SELECT COUNT(*) INTO l_n FROM ace_accounting_event
     WHERE source_entity_type = p_entity_type AND source_entity_id = p_entity_id AND reversal_of_event_id IS NULL;
    SELECT COUNT(*) INTO l_ev FROM ace_accounting_event
     WHERE source_entity_type = p_entity_type AND source_entity_id = p_entity_id AND reversal_of_event_id IS NULL
       AND status_code = 'POSTED';
    NOONA_CORE_PKG.assert(l_ev = 0, 'NOONA-ACE-001', 'المستند مرحل سابقاً؛ لا يرحل مرتين', 'Document already posted');
    l_key := p_entity_type || ':' || p_entity_id || ':V' || (l_n + 1);
    FOR i IN 1 .. p_lines.COUNT LOOP
      l_dr := l_dr + NVL(p_lines(i).debit, 0);
      l_cr := l_cr + NVL(p_lines(i).credit, 0);
    END LOOP;
    NOONA_CORE_PKG.assert(l_dr = l_cr AND l_dr > 0, 'NOONA-ACE-003',
      'قيد المستند غير متوازن (مدين ' || l_dr || ' / دائن ' || l_cr || ')', 'Source document entry is not balanced');
    l_total := l_dr;
    BEGIN
      INSERT INTO ace_accounting_event (company_id, source_entity_type, source_entity_id, currency_code, exchange_rate, rate_date,
                                        event_class_id, ledger_id, source_version, event_date, accounting_date, total_amount,
                                        event_data, idempotency_key, attempts, status_code)
      VALUES (NOONA_GL_PKG.company, p_entity_type, p_entity_id, p_currency, p_rate, TRUNC(p_doc_date), l_class,
              NOONA_GL_PKG.primary_ledger, l_n + 1, TRUNC(p_doc_date), TRUNC(p_doc_date), l_total,
              JSON_OBJECT('reference' VALUE p_reference, 'lines' VALUE l_cnt, 'source' VALUE p_journal_source),
              l_key, 1, 'VALIDATING')
      RETURNING id INTO l_ev;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      NOONA_CORE_PKG.raise_error('NOONA-ACE-001', 'المستند مرحل سابقاً؛ لا يرحل مرتين', 'Document already posted');
    END;
    l_j := NOONA_GL_PKG.post_system(p_journal_source, p_doc_date, p_description, p_currency, p_rate, p_lines,
                                    p_reference, l_ev, p_branch_id, p_journal_type);
    UPDATE ace_accounting_event SET journal_id = l_j, status_code = 'POSTED' WHERE id = l_ev;
    RETURN l_j;
  END post_source;

  FUNCTION reverse_source(p_entity_type IN VARCHAR2, p_entity_id IN NUMBER, p_date IN DATE, p_reason IN VARCHAR2) RETURN NUMBER IS
    l_ev  ace_accounting_event%ROWTYPE;
    l_rev NUMBER;
    l_new NUMBER;
  BEGIN
    BEGIN
      SELECT * INTO l_ev FROM ace_accounting_event
       WHERE source_entity_type = p_entity_type AND source_entity_id = p_entity_id
         AND status_code = 'POSTED' AND reversal_of_event_id IS NULL
         FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-ACE-004', 'لا يوجد قيد مرحل لهذا المستند', 'No posted entry for this document');
    END;
    l_rev := NOONA_GL_PKG.reverse_system(l_ev.journal_id, p_date, p_reason);
    INSERT INTO ace_accounting_event (company_id, source_entity_type, source_entity_id, currency_code, exchange_rate, rate_date,
                                      event_class_id, ledger_id, source_version, event_date, accounting_date, total_amount,
                                      event_data, idempotency_key, attempts, journal_id, reversal_of_event_id, status_code)
    VALUES (l_ev.company_id, p_entity_type, p_entity_id, l_ev.currency_code, l_ev.exchange_rate, l_ev.rate_date,
            l_ev.event_class_id, l_ev.ledger_id, l_ev.source_version, TRUNC(NVL(p_date, SYSDATE)), TRUNC(NVL(p_date, SYSDATE)),
            l_ev.total_amount, JSON_OBJECT('reason' VALUE p_reason), l_ev.idempotency_key || ':REV', 1, l_rev, l_ev.id, 'POSTED')
    RETURNING id INTO l_new;
    UPDATE gl_journal SET accounting_event_id = l_new WHERE id = l_rev;
    UPDATE ace_accounting_event SET status_code = 'REVERSED' WHERE id = l_ev.id;
    RETURN l_rev;
  END reverse_source;

END NOONA_ACE_PKG;
/
