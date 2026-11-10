-- مهمة يومية (07:40): تنبيهات قرب انتهاء التجربة والاشتراك والتحول للقراءة فقط، وإغلاق طلبات التسجيل غير المكتملة
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_ACCOUNT_DAILY', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_ACCOUNT_DAILY',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE n NUMBER; BEGIN n := NOONA_ACCOUNT_PKG.daily_notices; COMMIT; END;',
    repeat_interval => 'FREQ=DAILY;BYHOUR=7;BYMINUTE=40',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: subscription notices by email and stale signup cleanup');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN  daily account job not created (' || SQLERRM || ')');
END;
/
