PROMPT ========== مهمة تنبيهات التمريض (كل 5 دقائق): مواعيد الجرعات ومهام المتابعة للممرضين المناوبين
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_HIS_NURSE_ALERTS', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_HIS_NURSE_ALERTS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE n NUMBER; BEGIN n := NOONA_HIS_NURSE_PKG.run_alerts; COMMIT; END;',
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=5',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: inpatient dose and nursing task alerts to the nurses on duty');
  DBMS_OUTPUT.PUT_LINE('Nursing alerts job scheduled (every 5 minutes)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN  nursing alerts job not created (' || SQLERRM || '). Run from SYS: GRANT CREATE JOB TO NOONA_OWNER; then rerun this upgrade. '
    || 'The nurse station page still shows due and overdue doses.');
END;
/
