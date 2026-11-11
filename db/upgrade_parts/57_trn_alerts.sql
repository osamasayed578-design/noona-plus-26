-- =============================================================================
-- ترقية 57: أنواع إشعارات صيانة الأسطول ومهمة التنبيهات اليومية NOONA_TRN_MAINT_ALERTS (06:20 وكل 6 ساعات)
-- =============================================================================
BEGIN
  NOONA_CORE_PKG.begin_system;
  MERGE INTO ntf_event_type n
  USING (SELECT 'TRN_PART_DUE' code, 'موعد استبدال قطعة غيار' name_ar, 'Spare part replacement due' name_en FROM dual
         UNION ALL SELECT 'TRN_SERVICE_DUE', 'صيانة دورية مستحقة لعربة', 'Vehicle service due' FROM dual) x
     ON (n.code = x.code)
   WHEN NOT MATCHED THEN INSERT (code, name_ar, name_en, module_code, category, is_mandatory, default_channels)
        VALUES (x.code, x.name_ar, x.name_en, 'TRN', 'REMINDER', 'N', 'IN_APP,EMAIL');
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
BEGIN
  BEGIN
    DBMS_SCHEDULER.DROP_JOB('NOONA_TRN_MAINT_ALERTS', TRUE);
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'NOONA_TRN_MAINT_ALERTS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'DECLARE n NUMBER; BEGIN n := NOONA_TRN_PKG.run_maint_alerts; COMMIT; END;',
    start_date      => TRUNC(SYSTIMESTAMP) + INTERVAL '6' HOUR + INTERVAL '20' MINUTE,
    repeat_interval => 'FREQ=HOURLY;INTERVAL=6',
    enabled         => TRUE,
    comments        => 'NOONA PLUS: fleet spare part replacement and service due alerts');
  DBMS_OUTPUT.PUT_LINE('Fleet maintenance alerts job scheduled (every 6 hours)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('WARN  fleet alerts job not created (' || SQLERRM || '). Run from SYS: GRANT CREATE JOB TO NOONA_OWNER; then rerun this upgrade. '
    || 'Fleet maintenance page still shows due items.');
END;
/
