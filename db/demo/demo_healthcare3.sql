-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمرحلة الثالثة من المستشفى (بعد التحديث 27 وبعد demo_healthcare و demo_healthcare2) - بحساب NOONA_APP
-- ولا تكرر (تكتشف القناة ذات الرمز DEMO-GW):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_healthcare3.sql ADMIN
-- المحتوى:
--   * قناة ربط تأمين بطريقة المحاكاة مربوطة بشركتي التأمين، وقناة وصفات إلكترونية (محاكاة) - تبدل إلى REST عند التعاقد
--   * تحقق أهلية وطلب موافقة إلكتروني على زيارات اليوم، ومريض مؤمن اختار الدفع النقدي
--   * طوارئ بمستويات فرز وعلامات حيوية، ملاحظات تمريض وإعطاء أدوية للمنومين، إجازة مرضية وتقرير طبي، وتسوية عمولات الأطباء
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
  l_co  NUMBER;
  l_n   NUMBER;
  l_x   NUMBER;
  l_v   NUMBER;
  l_o   NUMBER;
  l_ch  NUMBER;
  l_r   VARCHAR2(100);

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  FUNCTION srv(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_service WHERE company_id = l_co AND code = p_code; RETURN l;
  END srv;
  FUNCTION dep(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_department WHERE company_id = l_co AND code = p_code; RETURN l;
  END dep;
  FUNCTION pat(p_id_no VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM his_patient WHERE company_id = l_co AND id_no = p_id_no; RETURN l;
  END pat;
  FUNCTION doc(p_name VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM his_doctor WHERE company_id = l_co AND name_ar = p_name; RETURN l;
  END doc;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  SELECT COUNT(*) INTO l_n FROM his_device WHERE company_id = l_co AND code = 'DEMO-CT1';
  IF l_n = 0 THEN
    say('شغّل demo_healthcare.sql ثم demo_healthcare2.sql أولاً.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT COUNT(*) INTO l_n FROM his_integration WHERE company_id = l_co AND code = 'DEMO-GW';
  IF l_n > 0 THEN
    say('بيانات المرحلة الثالثة محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;

  -- قنوات الربط (محاكاة)
  l_ch := NOONA_HIS_LINK_PKG.save_integration('{"code":"DEMO-GW","name":"بوابة مطالبات التأمين (محاكاة)","kind":"INSURANCE","mode":"SIMULATOR",'
          || '"provider":"10000000123"}');
  FOR y IN (SELECT id, code FROM his_payer WHERE company_id = l_co AND code IN ('DEMO-INS1', 'DEMO-INS2')) LOOP
    NOONA_HIS_LINK_PKG.set_payer_link(y.id, l_ch, CASE y.code WHEN 'DEMO-INS1' THEN 'INS-UC' ELSE 'INS-SF' END);
  END LOOP;
  l_x := NOONA_HIS_LINK_PKG.save_integration('{"code":"DEMO-ERX","name":"منصة الوصفات الإلكترونية (محاكاة)","kind":"ERX","mode":"SIMULATOR"}');
  say('قناتا ربط بطريقة المحاكاة: التأمين (شركتا التأمين) والوصفات الإلكترونية');

  -- الأهلية والموافقة الإلكترونية على زيارة الرنين بانتظار الموافقة
  FOR v IN (SELECT DISTINCT v.id FROM his_visit v WHERE v.company_id = l_co AND v.status_code = 'OPEN' AND v.bill_to = 'PAYER') LOOP
    BEGIN l_r := NOONA_HIS_LINK_PKG.check_eligibility(v.id); EXCEPTION WHEN OTHERS THEN NULL; END;
  END LOOP;
  FOR o IN (SELECT o.id FROM his_order o JOIN his_visit v ON v.id = o.visit_id JOIN his_payer_plan pl ON pl.id = v.payer_plan_id
             JOIN his_payer y ON y.id = pl.payer_id
             WHERE o.company_id = l_co AND o.status_code = 'APPROVAL_PENDING' AND y.integration_id IS NOT NULL) LOOP
    BEGIN l_r := NOONA_HIS_LINK_PKG.request_preauth(o.id); EXCEPTION WHEN OTHERS THEN NULL; END;
  END LOOP;
  -- مريضة مؤمنة اختارت الدفع النقدي لهذه الزيارة
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('1078901239') || ',"doctor":' || doc('د. ريم السبيعي') || ',"bill_to":"CASH",'
         || '"complaint":"Acne, cosmetic consultation"}');
  say('تحقق الأهلية وطلبات الموافقة إلكترونياً، وزيارة نقدية لمريضة مؤمنة (التأمين اختياري)');

  -- الطوارئ: فرز وعلامات حيوية
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('1001234564') || ',"dept":' || dep('ER') || ',"type":"EMERGENCY"}');
  NOONA_HIS_CLIN_PKG.set_triage(l_v, '3');
  l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"bp":"128/84","pulse":98,"temp":37.8,"rr":20,"spo2":97,"pain":6}');
  l_v := NOONA_HIS_PKG.open_visit('{"patient":' || pat('1090123452') || ',"dept":' || dep('ER') || ',"doctor":' || doc('د. سلطان الغامدي')
         || ',"type":"EMERGENCY","complaint":"Shortness of breath and chest tightness"}');
  NOONA_HIS_CLIN_PKG.set_triage(l_v, '2');
  l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || l_v || ',"bp":"165/98","pulse":118,"temp":37.1,"rr":26,"spo2":90,"pain":7,"glucose":210}');
  l_x := NOONA_HIS_CLIN_PKG.add_note(l_v, 'NURSING', 'Oxygen 4 L/min via nasal cannula started. ECG done and shown to ER physician.');
  l_o := NOONA_HIS_PKG.add_order(l_v, srv('ECG'));
  say('الطوارئ: مريضان بمستويات فرز وعلامات حيوية');

  -- المنومون: علامات حيوية، ملاحظات، إعطاء الأدوية
  FOR a IN (SELECT a.visit_id FROM his_admission a WHERE a.company_id = l_co AND a.status_code = 'ADMITTED') LOOP
    l_x := NOONA_HIS_CLIN_PKG.record_vitals('{"visit":' || a.visit_id || ',"bp":"130/80","pulse":88,"temp":37.4,"rr":18,"spo2":95}');
    l_x := NOONA_HIS_CLIN_PKG.add_note(a.visit_id, 'PROGRESS', 'Clinically improving. Continue current management.');
    FOR l IN (SELECT l.id FROM his_prescription x JOIN his_prescription_line l ON l.prescription_id = x.id
               WHERE x.visit_id = a.visit_id AND x.status_code NOT IN ('CANCELLED', 'EXPIRED')) LOOP
      l_x := NOONA_HIS_CLIN_PKG.give_medication('{"line":' || l.id || ',"route":"IV"}');
    END LOOP;
  END LOOP;
  say('المنومون: علامات حيوية وملاحظات متابعة وإعطاء الأدوية');

  -- إجازة مرضية وتقرير طبي من زيارات سابقة
  FOR v IN (SELECT v.id, v.doctor_id, ROWNUM rn FROM (SELECT id, doctor_id FROM his_visit WHERE company_id = l_co AND status_code = 'CLOSED'
             AND diagnosis IS NOT NULL AND doctor_id IS NOT NULL ORDER BY visit_at DESC) v WHERE ROWNUM <= 2) LOOP
    IF v.rn = 1 THEN
      l_x := NOONA_HIS_CLIN_PKG.issue_certificate('{"visit":' || v.id || ',"type":"SICK_LEAVE","from":"' || TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD')
             || '","to":"' || TO_CHAR(SYSDATE + 1, 'YYYY-MM-DD') || '"}');
    ELSE
      l_x := NOONA_HIS_CLIN_PKG.issue_certificate('{"visit":' || v.id || ',"type":"MEDICAL_REPORT"}');
    END IF;
  END LOOP;
  say('تقريران طبيان: إجازة مرضية وتقرير طبي');

  -- عمولات الأطباء لما مضى من الشهر
  BEGIN
    l_n := NOONA_HIS_CLIN_PKG.settle_commissions(TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) - 1);
    say('تسوية عمولات ' || l_n || ' طبيب بقيد استحقاق');
  EXCEPTION WHEN OTHERS THEN
    say('لا توجد عمولات للتسوية: ' || SQLERRM);
  END;

  COMMIT;
  say('');
  say('تم تحميل بيانات المرحلة الثالثة للمستشفى.');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
