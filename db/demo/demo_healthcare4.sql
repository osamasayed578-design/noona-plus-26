-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمرحلة الرابعة من المستشفى: متابعة المنومين (بعد التحديث 28 وبعد demo_healthcare1-3) - بحساب NOONA_APP
-- ولا تكرر (تكتشف الممرضة ذات الرمز DEMO-RN1):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_healthcare4.sql ADMIN
-- المحتوى: ممرضات الجناح (إحداهن مربوطة بمستخدم الدخول لتصله التنبيهات)، الورديات الثلاث، مناوبات اليوم والغد،
--          جدول جرعات المنومين بجرعات معطاة وأخرى مستحقة ومتأخرة، ومهام متابعة (سكر، تقليب، مدخلات ومخرجات)
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co   NUMBER;
  l_n    NUMBER;
  l_x    NUMBER;
  l_ward NUMBER;
  TYPE t_map IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
  rn     t_map;
  sh     t_map;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE duty(p_date DATE, p_shift VARCHAR2, p_nurse VARCHAR2, p_role VARCHAR2, p_rooms VARCHAR2 DEFAULT NULL) IS
  BEGIN
    l_x := NOONA_HIS_NURSE_PKG.assign_duty('{"date":"' || TO_CHAR(p_date, 'YYYY-MM-DD') || '","shift":' || sh(p_shift) || ',"ward":' || l_ward
           || ',"nurse":' || rn(p_nurse) || ',"role":"' || p_role || '"' || CASE WHEN p_rooms IS NOT NULL THEN ',"rooms":"' || p_rooms || '"' END || '}');
  END duty;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM his_integration WHERE company_id = l_co AND code = 'DEMO-GW';
  IF l_n = 0 THEN
    say('شغّل demo_healthcare.sql ثم demo_healthcare2.sql ثم demo_healthcare3.sql أولاً.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT COUNT(*) INTO l_n FROM his_doctor WHERE company_id = l_co AND code = 'DEMO-RN1';
  IF l_n > 0 THEN
    say('بيانات المرحلة الرابعة محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT id INTO l_ward FROM his_department WHERE company_id = l_co AND code = 'WARD';

  -- الممرضات (الأولى مربوطة بمستخدم الدخول لتظهر له تنبيهات الجرعات)
  rn('RN1') := NOONA_HIS_PKG.save_doctor('{"code":"DEMO-RN1","name":"ممرضة. أمل الشهري","dept":' || l_ward || ',"title":"NURSE","specialty":"تمريض باطني",'
               || '"mobile":"0551300001","user":"' || c_admin || '"}');
  rn('RN2') := NOONA_HIS_PKG.save_doctor('{"code":"DEMO-RN2","name":"ممرضة. جوانا كروز","dept":' || l_ward || ',"title":"NURSE","mobile":"0551300002"}');
  rn('RN3') := NOONA_HIS_PKG.save_doctor('{"code":"DEMO-RN3","name":"ممرض. فيصل العتيبي","dept":' || l_ward || ',"title":"NURSE","mobile":"0551300003"}');
  rn('RN4') := NOONA_HIS_PKG.save_doctor('{"code":"DEMO-RN4","name":"ممرضة. ماريا سانتوس","dept":' || l_ward || ',"title":"NURSE","mobile":"0551300004"}');
  rn('RN5') := NOONA_HIS_PKG.save_doctor('{"code":"DEMO-RN5","name":"مساعد تمريض. خالد اليامي","dept":' || l_ward || ',"title":"NURSE","mobile":"0551300005"}');
  say('خمسة من طاقم التمريض في جناح التنويم');

  -- الورديات والمناوبات: أمس (لليلية الممتدة) واليوم والغد
  l_n := NOONA_HIS_NURSE_PKG.seed_shifts;
  FOR s IN (SELECT id, code FROM his_nurse_shift WHERE company_id = l_co) LOOP
    sh(s.code) := s.id;
  END LOOP;
  FOR d IN -1 .. 1 LOOP
    duty(TRUNC(SYSDATE) + d, 'M', 'RN1', 'CHARGE');
    duty(TRUNC(SYSDATE) + d, 'M', 'RN2', 'STAFF', '101,102');
    duty(TRUNC(SYSDATE) + d, 'M', 'RN5', 'ASSISTANT');
    duty(TRUNC(SYSDATE) + d, 'E', 'RN1', 'CHARGE');
    duty(TRUNC(SYSDATE) + d, 'E', 'RN3', 'STAFF', '103,104');
    duty(TRUNC(SYSDATE) + d, 'N', 'RN1', 'CHARGE');
    duty(TRUNC(SYSDATE) + d, 'N', 'RN4', 'STAFF');
  END LOOP;
  say('الورديات الثلاث ومناوبات أمس واليوم والغد (المستخدم الحالي مسؤول الوردية لتصله التنبيهات)');

  -- جداول جرعات المنومين وخطط المتابعة
  FOR a IN (SELECT a.visit_id FROM his_admission a WHERE a.company_id = l_co AND a.status_code = 'ADMITTED') LOOP
    NOONA_HIS_NURSE_PKG.default_tasks(a.visit_id);
    FOR x IN (SELECT id FROM his_prescription WHERE visit_id = a.visit_id AND status_code NOT IN ('CANCELLED', 'EXPIRED')) LOOP
      l_n := NOONA_HIS_NURSE_PKG.schedule_rx(x.id);
    END LOOP;
  END LOOP;
  l_n := NOONA_HIS_NURSE_PKG.extend_schedules;
  -- جرعات الأمس معطاة، وجرعة صباح اليوم متأخرة للتنبيه
  UPDATE his_med_schedule SET status_code = 'GIVEN', done_at = due_at + INTERVAL '10' MINUTE, nurse_id = rn('RN1')
   WHERE company_id = l_co AND status_code = 'DUE' AND due_at < SYSTIMESTAMP - INTERVAL '3' HOUR;
  UPDATE his_med_schedule SET due_at = SYSTIMESTAMP - INTERVAL '45' MINUTE
   WHERE id = (SELECT MIN(id) FROM his_med_schedule WHERE company_id = l_co AND status_code = 'DUE');
  FOR a IN (SELECT a.visit_id, ROWNUM rn FROM his_admission a WHERE a.company_id = l_co AND a.status_code = 'ADMITTED') LOOP
    IF a.rn = 1 THEN
      l_x := NOONA_HIS_NURSE_PKG.add_task('{"visit":' || a.visit_id || ',"type":"BLOOD_SUGAR","desc":"Capillary glucose before meals and at bedtime","every":6}');
      l_x := NOONA_HIS_NURSE_PKG.complete_task(l_x, '168 mg/dL', 'Sliding scale insulin 4 units', rn('RN1'));
      l_x := NOONA_HIS_NURSE_PKG.add_task('{"visit":' || a.visit_id || ',"type":"INTAKE_OUTPUT","desc":"Fluid balance chart","every":8}');
    ELSE
      l_x := NOONA_HIS_NURSE_PKG.add_task('{"visit":' || a.visit_id || ',"type":"TURNING","desc":"Reposition to prevent pressure sores","every":2,'
             || '"start":"' || TO_CHAR(SYSDATE - 2.5 / 24, 'YYYY-MM-DD HH24:MI') || '"}');
    END IF;
  END LOOP;
  SELECT COUNT(*) INTO l_n FROM his_med_schedule WHERE company_id = l_co;
  say('جدول الجرعات: ' || l_n || ' جرعة للمنومين، ومهام متابعة (سكر، توازن السوائل، تقليب)');

  COMMIT;
  say('');
  say('تم تحميل بيانات متابعة المنومين. افتح «التمريض والتنويم > محطة التمريض».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
