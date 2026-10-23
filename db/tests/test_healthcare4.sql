-- =============================================================================
-- NOONA PLUS ERP | اختبار المستشفى - المرحلة الرابعة: ورديات التمريض والمناوبات، جدول جرعات المنومين وتسجيلها، مهام المتابعة،
--                  محطة التمريض والتنبيهات والملف الإلكتروني للمنوم (بحساب NOONA_APP - يتراجع عن كل التغييرات)
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_healthcare4.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
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
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n    NUMBER;
  l_x    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_sh   NUMBER;
  l_ward NUMBER;
  l_bed  NUMBER;
  l_room VARCHAR2(30);
  l_nur  NUMBER;
  l_nur2 NUMBER;
  l_pt   NUMBER;
  l_adm  NUMBER;
  l_v    NUMBER;
  l_med  NUMBER;
  l_wh   NUMBER;
  l_rx   NUMBER;
  l_rx2  NUMBER;
  l_d    NUMBER;
  l_t    NUMBER;
  l_mem  NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION dep(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_department WHERE code = p_code AND company_id = NOONA_HIS_PKG.company; RETURN l;
  END dep;
  FUNCTION doses(p_rx NUMBER, p_status VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id
     WHERE l.prescription_id = p_rx AND (p_status IS NULL OR m.status_code = p_status);
    RETURN l;
  END doses;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_n := NOONA_HIS_PKG.seed_catalog;
  l_n := NOONA_HIS_CARE_PKG.seed_defaults;
  l_n := NOONA_HIS_NURSE_PKG.seed_shifts;
  SELECT COUNT(*) INTO l_n FROM his_nurse_shift WHERE company_id = NOONA_HIS_PKG.company;
  ok('default nursing shifts', l_n >= 3, l_n);
  ok('a shift covers now', NOONA_HIS_NURSE_PKG.current_shift IS NOT NULL);
  BEGIN l_x := NOONA_HIS_NURSE_PKG.save_shift(NULL, 'X' || l_sfx, 'x', '7am', '15:00'); ok('shift times HH24:MI', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('shift times HH24:MI', 'NOONA-HIS-250', SQLERRM); END;
  -- وردية اختبار تشمل الآن (قد تتجاوز منتصف الليل)
  l_sh := NOONA_HIS_NURSE_PKG.save_shift(NULL, 'T' || l_sfx, 'اختبار', TO_CHAR(SYSDATE - 1 / 24, 'HH24:MI'), TO_CHAR(SYSDATE + 2 / 24, 'HH24:MI'));

  -- ======================================================== المناوبة
  SELECT MIN(b.id) INTO l_bed FROM his_bed b WHERE b.company_id = NOONA_HIS_PKG.company AND b.status_code = 'AVAILABLE';
  IF l_bed IS NULL THEN
    l_bed := NOONA_HIS_CARE_PKG.save_bed(NULL, dep('WARD'), 'T' || l_sfx, 'R' || l_sfx);
  END IF;
  SELECT ward_id, NVL(room_no, 'R1') INTO l_ward, l_room FROM his_bed WHERE id = l_bed;
  UPDATE his_bed SET room_no = l_room WHERE id = l_bed;
  l_nur := NOONA_HIS_PKG.save_doctor('{"name":"ممرضة مناوبة ' || l_sfx || '","dept":' || l_ward || ',"title":"NURSE","user":"ADMIN"}');
  l_nur2 := NOONA_HIS_PKG.save_doctor('{"name":"ممرض غرف أخرى ' || l_sfx || '","dept":' || l_ward || ',"title":"NURSE"}');
  l_x := NOONA_HIS_NURSE_PKG.assign_duty('{"date":"' || TO_CHAR(SYSDATE - 1 / 24, 'YYYY-MM-DD') || '","shift":' || l_sh || ',"ward":' || l_ward || ',"nurse":' || l_nur
         || ',"role":"CHARGE"}');
  l_x := NOONA_HIS_NURSE_PKG.assign_duty('{"date":"' || TO_CHAR(SYSDATE - 1 / 24, 'YYYY-MM-DD') || '","shift":' || l_sh || ',"ward":' || l_ward || ',"nurse":' || l_nur2
         || ',"rooms":"ZZ9, ZZ8"}');
  l_s := NOONA_HIS_NURSE_PKG.nurses_on_duty(l_ward, l_room);
  ok('nurse on duty for the room (charge nurse covers the whole ward)', INSTR(l_s, 'ممرضة مناوبة ' || l_sfx || ' (مسؤول)') > 0
     AND INSTR(l_s, 'ممرض غرف أخرى') = 0, l_s);
  ok('room assignment respected', INSTR(NOONA_HIS_NURSE_PKG.nurses_on_duty(l_ward, 'ZZ8'), 'ممرض غرف أخرى ' || l_sfx) > 0);
  ok('nobody on duty outside the shift', NOONA_HIS_NURSE_PKG.nurses_on_duty(l_ward, l_room, SYSDATE + 0.5) IS NULL
     OR INSTR(NOONA_HIS_NURSE_PKG.nurses_on_duty(l_ward, l_room, SYSDATE + 0.5), l_sfx) = 0);
  ok('roster copied to the next day', NOONA_HIS_NURSE_PKG.copy_roster(TRUNC(SYSDATE - 1 / 24), TRUNC(SYSDATE - 1 / 24) + 1, l_ward) >= 2);
  ok('on-duty panel', INSTR(NOONA_HIS_NURSE_PKG.on_duty_html(l_ward), 'مسؤول الوردية') > 0);

  -- ======================================================== أوقات الجرعات
  ok('dose times from frequency', NOONA_HIS_NURSE_PKG.times_for('BID') = '09:00,21:00' AND NOONA_HIS_NURSE_PKG.times_for('TID PO') = '08:00,14:00,22:00'
     AND NOONA_HIS_NURSE_PKG.times_for('Q6H') = '00:00,06:00,12:00,18:00' AND NOONA_HIS_NURSE_PKG.times_for('PRN') IS NULL
     AND NOONA_HIS_NURSE_PKG.times_for('OD', '07:30, 19:30') = '07:30,19:30');

  -- ======================================================== التنويم وجدول الجرعات
  l_pt := NOONA_HIS_PKG.save_patient('{"name":"منوم متابعة ' || l_sfx || '","name_en":"Ward Patient ' || l_sfx || '","gender":"M","birth":"1970-01-01",'
          || '"nationality":"SA","id_no":"5' || l_sfx || '","allergies":"Penicillin"}');
  l_adm := NOONA_HIS_CARE_PKG.admit('{"patient":' || l_pt || ',"bed":' || l_bed || ',"reason":"Cellulitis of the leg"}');
  SELECT visit_id INTO l_v FROM his_admission WHERE id = l_adm;
  SELECT COUNT(*) INTO l_n FROM his_care_task WHERE visit_id = l_v AND status_code = 'ACTIVE';
  ok('default care plan on admission (vitals q4h, doctor round)', l_n = 2, l_n);
  l_med := NOONA_INV_PKG.save_item('{"name":"دواء منوم ' || l_sfx || '","nameEn":"Clindamycin 600 mg IV ' || l_sfx || '","type":"STOCK","price":23,"incl":"Y","sell":"Y"}');
  SELECT warehouse_id INTO l_wh FROM his_department WHERE id = NOONA_HIS_CARE_PKG.default_pharmacy;
  l_n := NOONA_INV_PKG.save_stock_doc('{"type":"OPENING","date":"' || TO_CHAR(SYSDATE, 'YYYY-MM-DD') || '","wh":' || l_wh || ',"action":"POST",'
         || '"lines":[{"i":' || l_med || ',"q":100,"c":5}]}');
  BEGIN l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":2,"freq":"BID","times":"9am"}]}'); ok('dose times format', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('dose times format', 'NOONA-HIS-125', SQLERRM); END;
  l_rx := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":4,"dose":"600 mg","freq":"Q6H","days":1,"route":"IV"},'
          || '{"i":' || l_med || ',"q":2,"dose":"600 mg","freq":"OD","days":2,"times":"10:00"},{"i":' || l_med || ',"q":1,"dose":"600 mg","freq":"STAT"},'
          || '{"i":' || l_med || ',"q":5,"dose":"600 mg","freq":"PRN"}]}');
  SELECT COUNT(*) INTO l_n FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 1;
  ok('Q6H for one day = 4 doses', l_n = 4, l_n);
  SELECT COUNT(*) INTO l_n FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 2;
  ok('custom time 10:00 for two days = 2 doses', l_n = 2, l_n);
  SELECT COUNT(*), MAX(m.id) INTO l_n, l_d FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 3;
  ok('STAT = one dose now', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 4;
  ok('PRN not scheduled', l_n = 0);
  SELECT m.route INTO l_s FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 1 AND ROWNUM = 1;
  ok('route carried to the schedule', l_s = 'IV');
  ok('schedule not duplicated', NOONA_HIS_NURSE_PKG.schedule_rx(l_rx) = 0 AND NOONA_HIS_NURSE_PKG.extend_schedules >= 0 AND doses(l_rx) = 7, doses(l_rx));

  -- ======================================================== تسجيل الجرعات
  l_x := NOONA_HIS_NURSE_PKG.record_dose(l_d, 'GIVEN', l_nur);
  SELECT m.status_code || '/' || a.outcome || '/' || a.route INTO l_s FROM his_med_schedule m JOIN his_med_admin a ON a.id = m.admin_id WHERE m.id = l_d;
  ok('STAT dose given and recorded on the MAR', l_s = 'GIVEN/GIVEN/ORAL', l_s);
  BEGIN l_x := NOONA_HIS_NURSE_PKG.record_dose(l_d, 'GIVEN'); ok('dose recorded once', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('dose recorded once', 'NOONA-HIS-260', SQLERRM); END;
  SELECT MAX(m.id) INTO l_x FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id
   WHERE l.prescription_id = l_rx AND m.status_code = 'DUE' AND m.due_at > SYSTIMESTAMP + INTERVAL '3' HOUR;
  IF l_x IS NOT NULL THEN
    BEGIN l_n := NOONA_HIS_NURSE_PKG.record_dose(l_x, 'GIVEN'); ok('not recorded hours early', FALSE);
    EXCEPTION WHEN OTHERS THEN expect('not recorded hours early', 'NOONA-HIS-262', SQLERRM); END;
  ELSE
    ok('not recorded hours early', TRUE);
  END IF;
  BEGIN l_n := NOONA_HIS_NURSE_PKG.record_dose(l_d, 'LOST'); ok('valid outcome', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('valid outcome', 'NOONA-HIS-26', SQLERRM); END;
  -- جرعة متأخرة: تظهر في التنبيهات وترسل إشعاراً للممرضة المناوبة
  SELECT MIN(m.id) INTO l_d FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 1 AND m.status_code = 'DUE';
  UPDATE his_med_schedule SET due_at = SYSTIMESTAMP - INTERVAL '45' MINUTE WHERE id = l_d;
  l_c := NOONA_HIS_NURSE_PKG.alerts_json(l_ward);
  ok('overdue dose in the station alerts', TO_NUMBER(JSON_VALUE(l_c, '$.overdue')) >= 1 AND INSTR(l_c, '"D' || l_d || '"') > 0, DBMS_LOB.SUBSTR(l_c, 200, 1));
  l_n := NOONA_HIS_NURSE_PKG.run_alerts;
  SELECT alert_level INTO l_x FROM his_med_schedule WHERE id = l_d;
  SELECT MIN(um.id) INTO l_mem FROM sec_user_membership um JOIN sec_user u ON u.id = um.user_id WHERE UPPER(u.username) = 'ADMIN' AND um.status_code = 'ACTIVE';
  SELECT COUNT(*) INTO l_n FROM ntf_notification WHERE source_entity_type = 'HIS_MED_SCHEDULE' AND source_entity_id = l_d AND membership_id = l_mem;
  ok('overdue alert sent to the nurse on duty', l_x = 2 AND l_n = 1, l_x || ' / ' || l_n);
  l_n := NOONA_HIS_NURSE_PKG.run_alerts;
  SELECT COUNT(*) INTO l_n FROM ntf_notification WHERE source_entity_type = 'HIS_MED_SCHEDULE' AND source_entity_id = l_d;
  ok('alert not repeated', l_n = 1, l_n);
  l_x := NOONA_HIS_NURSE_PKG.record_dose(l_d, 'HELD', l_nur, 'Patient in theatre');
  SELECT status_code INTO l_s FROM his_med_schedule WHERE id = l_d;
  ok('held dose with reason', l_s = 'HELD');
  UPDATE his_med_schedule SET due_at = SYSTIMESTAMP - INTERVAL '7' HOUR, alert_level = 2
   WHERE id = (SELECT MIN(m.id) FROM his_med_schedule m JOIN his_prescription_line l ON l.id = m.line_id WHERE l.prescription_id = l_rx AND l.line_no = 1
                 AND m.status_code = 'DUE') RETURNING id INTO l_d;
  l_n := NOONA_HIS_NURSE_PKG.run_alerts;
  SELECT status_code INTO l_s FROM his_med_schedule WHERE id = l_d;
  ok('unrecorded dose becomes missed after 6 hours', l_s = 'MISSED', l_s);

  -- ======================================================== مهام المتابعة
  BEGIN l_x := NOONA_HIS_NURSE_PKG.add_task('{"visit":' || l_v || ',"type":"OTHER","every":2}'); ok('other task needs a description', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('other task needs a description', 'NOONA-HIS-266', SQLERRM); END;
  l_t := NOONA_HIS_NURSE_PKG.add_task('{"visit":' || l_v || ',"type":"BLOOD_SUGAR","desc":"Capillary glucose before meals","every":6}');
  l_x := NOONA_HIS_NURSE_PKG.complete_task(l_t, '182 mg/dL', 'Insulin per scale', l_nur);
  SELECT ROUND((CAST(next_due_at AS DATE) - SYSDATE) * 24) INTO l_n FROM his_care_task WHERE id = l_t;
  ok('task completed and next due in 6 hours', l_n = 6, l_n);
  l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"bp":"124/78","pulse":84,"temp":38.1,"glucose":160}');
  SELECT COUNT(*) INTO l_n FROM his_care_task WHERE visit_id = l_v AND task_type IN ('VITALS', 'BLOOD_SUGAR') AND last_done_at >= SYSTIMESTAMP - INTERVAL '1' MINUTE;
  ok('vital signs reading fulfils the vitals and sugar tasks', l_n = 2, l_n);
  UPDATE his_care_task SET next_due_at = SYSTIMESTAMP - INTERVAL '40' MINUTE WHERE id = l_t;
  l_n := NOONA_HIS_NURSE_PKG.run_alerts;
  SELECT COUNT(*) INTO l_n FROM ntf_notification WHERE source_entity_type = 'HIS_CARE_TASK' AND source_entity_id = l_t;
  ok('overdue care task alert', l_n = 1, l_n);

  -- ======================================================== المحطة والملف
  l_c := NOONA_HIS_NURSE_PKG.station_html(l_ward);
  ok('nurse station shows the patient, allergy and duty nurse', INSTR(l_c, 'منوم متابعة ' || l_sfx) > 0 AND INSTR(l_c, 'Penicillin') > 0
     AND INSTR(l_c, 'ممرضة مناوبة ' || l_sfx) > 0 AND INSTR(l_c, 'task(s) due') > 0);
  ok('due list', INSTR(NOONA_HIS_NURSE_PKG.due_html(l_ward, 30), 'Clindamycin') > 0);
  l_c := NOONA_HIS_NURSE_PKG.inpatient_chart_html(l_v);
  ok('inpatient electronic chart', INSTR(l_c, 'Medication schedule') > 0 AND INSTR(l_c, 'Clindamycin') > 0 AND INSTR(l_c, 'ds-given') > 0
     AND INSTR(l_c, 'ds-held') > 0 AND INSTR(l_c, 'Blood sugar') > 0 AND INSTR(l_c, '182 mg/dL') > 0 AND INSTR(l_c, 'Ward Patient') > 0);

  -- ======================================================== الإلغاء والخروج
  l_rx2 := NOONA_HIS_CARE_PKG.prescribe('{"visit":' || l_v || ',"lines":[{"i":' || l_med || ',"q":3,"freq":"TID","days":1}]}');
  NOONA_HIS_CARE_PKG.cancel_prescription(l_rx2);
  ok('cancelled prescription cancels its doses', doses(l_rx2, 'DUE') = 0 AND doses(l_rx2, 'CANCELLED') = doses(l_rx2));
  NOONA_HIS_CARE_PKG.discharge(l_adm, 'HOME', 'Improved on IV antibiotics; oral course at home.');
  SELECT COUNT(*) INTO l_n FROM his_care_task WHERE visit_id = l_v AND status_code = 'ACTIVE';
  ok('discharge stops follow-up and future doses', doses(l_rx, 'DUE') = 0 AND l_n = 0, doses(l_rx, 'DUE') || ' ' || l_n);
  l_c := NOONA_HIS_NURSE_PKG.inpatient_chart_html(l_v);
  ok('chart keeps the discharge summary', INSTR(l_c, 'oral course at home') > 0);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
