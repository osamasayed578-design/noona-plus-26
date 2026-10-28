PROMPT ========== مهمة إرسال الأحداث الصادرة (كل دقيقة): Webhooks والرسائل وتنظيف مفاتيح منع التكرار
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_API_DISPATCH', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_API_DISPATCH',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN NOONA_API_PKG.run_job; END;',
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: outbox dispatcher (signed webhooks, SMS/WhatsApp) with retries');
  DBMS_OUTPUT.PUT_LINE('API dispatch job scheduled (every minute)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN  API dispatch job not created (' || SQLERRM || '). Run from SYS: GRANT CREATE JOB TO NOONA_OWNER; then rerun this upgrade. '
    || 'Events can still be sent from the integrations screen (Send now).');
END;
/
