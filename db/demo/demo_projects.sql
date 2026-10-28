-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمشروعات والمقاولات (بعد التحديث 30) - بحساب NOONA_APP، ولا تكرر (تكتشف المشروع DEMO-PRJ1):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_projects.sql ADMIN
-- المحتوى: مشروع إنشاء مبنى إداري لعميل (بنود عمل ونسب إنجاز، موازنة، عقد رئيسي بجدول كميات، دفعة مقدمة،
--          مستخلصان معتمدان، أمر تغيير، مقاول باطن ومستخلصه، مصروفات وساعات عمل)، ومشروع تطوير عقاري مرتبط بعقار (إن وجد)
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
  l_n    NUMBER;
  l_x    NUMBER;
  l_cust NUMBER;
  l_sup  NUMBER;
  l_box  NUMBER;
  l_prj  NUMBER;
  l_w    NUMBER;
  l_w2   NUMBER;
  l_w3   NUMBER;
  l_ct   NUMBER;
  l_sc   NUMBER;
  l_cl   NUMBER;
  l_vo   NUMBER;
  l_emp  NUMBER;
  l_prop NUMBER;
  l_ids  VARCHAR2(4000);
  FUNCTION d(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(TRUNC(SYSDATE) + p, 'YYYY-MM-DD'); END;
  FUNCTION boq(p_ct NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN SELECT id INTO l FROM prj_boq_item WHERE contract_id = p_ct AND item_code = p_code; RETURN l; END;
  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  -- تمويل الصندوق قبل الصرف منه (لا يصرف الصندوق فوق رصيده): سند قبض من الشركاء (3101) يعتمده المعتمد التجريبي (فصل المهام)
  PROCEDURE fund_box(p_need NUMBER, p_desc VARCHAR2) IS
    l_v   NUMBER;
    l_m   NUMBER;
    l_rl  NUMBER;
    l_g   NUMBER;
    l_amt NUMBER := p_need - NOONA_CSH_PKG.balance(l_box, NULL);
  BEGIN
    IF l_amt <= 0 THEN RETURN; END IF;
    SELECT MIN(m.id) INTO l_m FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = 'DEMO_APPROVER';
    IF l_m IS NULL THEN
      l_m := NOONA_SEC_ADMIN_PKG.create_user('DEMO_APPROVER', 'المعتمد المالي (تجريبي)', 'demo.approver@noona.local', NOONA_GL_PKG.company);
      l_rl := NOONA_SEC_ADMIN_PKG.create_role('DEMO_APPROVER', 'معتمد مالي (تجريبي)');
      l_g := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_rl, 'GL', 'VIEW,APPROVE,POST,REVERSE');
      l_g := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_rl, 'CSH', 'VIEW,APPROVE,POST');
      l_g := NOONA_SEC_ADMIN_PKG.grant_role(l_m, l_rl, NULL, 'بيانات تجريبية');
    END IF;
    l_v := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', GREATEST(TRUNC(SYSDATE, 'YYYY'), TRUNC(SYSDATE) - 200), l_box, NULL, NULL, 'الشركاء', p_desc, 'DEMO',
                                      '[{"a":"3101","m":' || CEIL(l_amt) || '}]');
    NOONA_CSH_PKG.submit_voucher(l_v);
    NOONA_APEX_PKG.post_auth('DEMO_APPROVER', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
    NOONA_CSH_PKG.approve_voucher(l_v);
    NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END fund_box;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_n FROM prj_project WHERE company_id = NOONA_PRJ_PKG.company AND code = 'DEMO-PRJ1';
  IF l_n > 0 THEN
    say('بيانات المشروعات محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = NOONA_PRJ_PKG.company AND status_code = 'ACTIVE';
  IF l_box IS NULL THEN
    say('أنشئ صندوقاً من المالية (الصناديق والبنوك) أولاً.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  fund_box(4000000, 'تمويل من الشركاء لمصروفات المشروعات');
  l_n := NOONA_PRJ_PKG.setup_accounts;
  l_cust := NOONA_SAL_PKG.save_customer('{"name":"شركة الأفق القابضة","nameEn":"Horizon Holding","person":"N","tax":"310123456700003","term":"NET30","phone":"0112345678"}');
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"مؤسسة الإتقان للتشطيبات","person":"N","type":"SERVICES","term":"NET30","phone":"0551234567"}');

  -- المشروع وبنوده
  l_prj := NOONA_PRJ_PKG.save_project('{"code":"DEMO-PRJ1","name":"إنشاء المبنى الإداري لشركة الأفق","nameEn":"Horizon HQ building","type":"CONSTRUCTION",'
           || '"customer":' || l_cust || ',"start":"' || d(-120) || '","end":"' || d(240) || '"}');
  UPDATE prj_wbs SET status_code = 'CANCELLED' WHERE project_id = l_prj AND code = 'GEN';
  l_w := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"01","name":"الأعمال الإنشائية","weight":55,"start":"' || d(-120) || '","end":"' || d(60) || '"}');
  l_w2 := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"02","name":"الأعمال المعمارية والتشطيبات","weight":30,"start":"' || d(30) || '","end":"' || d(200) || '"}');
  l_w3 := NOONA_PRJ_PKG.save_wbs('{"project":' || l_prj || ',"code":"03","name":"الأعمال الكهروميكانيكية","weight":15,"start":"' || d(60) || '","end":"' || d(230) || '"}');
  UPDATE prj_wbs SET status_code = 'ACTIVE' WHERE project_id = l_prj AND code = 'GEN';
  NOONA_PRJ_PKG.update_progress(l_w, 70, 'اكتمال الهيكل حتى الدور الرابع');
  NOONA_PRJ_PKG.update_progress(l_w2, 10, 'بدء أعمال البلوك');
  l_x := NOONA_PRJ_PKG.save_budget(l_prj, '[{"w":' || l_w || ',"t":"MATERIAL","a":1450000},{"w":' || l_w || ',"t":"LABOR","a":420000},{"w":' || l_w || ',"t":"EQUIPMENT","a":180000},'
         || '{"w":' || l_w2 || ',"t":"SUBCONTRACT","a":650000},{"w":' || l_w2 || ',"t":"MATERIAL","a":380000},{"w":' || l_w3 || ',"t":"SUBCONTRACT","a":540000},'
         || '{"t":"OVERHEAD","a":160000}]');
  say('مشروع إنشاء بثلاثة بنود عمل وموازنة 3,780,000');

  -- العقد الرئيسي وجدول الكميات
  l_ct := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"MAIN_CONTRACT","no":"HZN-2026-01","ret":10,"retCap":5,"adv":10,"advRec":15,'
          || '"start":"' || d(-120) || '","end":"' || d(240) || '","dlp":12}');
  l_n := NOONA_PRJ_PKG.save_boq(l_ct, '[{"code":"1.1","d":"حفر وردم للأساسات","q":3500,"r":35,"w":' || l_w || '},'
         || '{"code":"1.2","d":"خرسانة مسلحة للأساسات والرقاب","q":900,"r":1150,"w":' || l_w || '},'
         || '{"code":"1.3","d":"خرسانة مسلحة للأعمدة والأسقف","q":1600,"r":1300,"w":' || l_w || '},'
         || '{"code":"2.1","d":"مباني بلوك أسمنتي 20 سم","q":6200,"r":85,"w":' || l_w2 || '},'
         || '{"code":"2.2","d":"لياسة داخلية وخارجية","q":14000,"r":38,"w":' || l_w2 || '},'
         || '{"code":"2.3","d":"تبليط بورسلين للأرضيات","q":5200,"r":120,"w":' || l_w2 || '},'
         || '{"code":"3.1","d":"أعمال كهربائية (مقطوعية)","q":1,"r":520000,"w":' || l_w3 || '},'
         || '{"code":"3.2","d":"تكييف مركزي (مقطوعية)","q":1,"r":610000,"w":' || l_w3 || '}]');
  NOONA_PRJ_PKG.activate_contract(l_ct);
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct, 'ADVANCE', TRUNC(SYSDATE) - 118, TRUNC(SYSDATE) - 118);
  NOONA_PRJ_PKG.approve_claim(l_cl);
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct, 'PROGRESS', TRUNC(SYSDATE) - 120, TRUNC(SYSDATE) - 61);
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"lines":[{"b":' || boq(l_ct, '1.1') || ',"q":3500},{"b":' || boq(l_ct, '1.2') || ',"q":900},'
                          || '{"b":' || boq(l_ct, '1.3') || ',"q":300}]}');
  NOONA_PRJ_PKG.approve_claim(l_cl);
  -- العميل سدد المستخلص الأول
  SELECT id, open_amount INTO l_x, l_n FROM ar_open_item WHERE source_entity_type = 'PRJ_PROGRESS_CLAIM' AND source_entity_id = l_cl;
  l_x := NOONA_SAL_PKG.receive('{"cust":' || l_cust || ',"amount":' || l_n || ',"place":"BOX:' || l_box || '","method":"CASH","ref":"TRF-8812",'
         || '"alloc":[{"inv":' || l_x || ',"a":' || l_n || '}]}');
  l_vo := NOONA_PRJ_PKG.save_variation('{"contract":' || l_ct || ',"type":"ADDITION","desc":"إضافة دور ميزانين وعزل مائي للسطح","days":30,"ref":"HZN-VO-01",'
          || '"lines":[{"b":' || boq(l_ct, '1.3') || ',"q":120},{"code":"1.4","d":"عزل مائي للسطح بالرولات","q":1400,"r":65}]}');
  NOONA_PRJ_PKG.approve_variation(l_vo);
  l_cl := NOONA_PRJ_PKG.new_claim(l_ct, 'PROGRESS', TRUNC(SYSDATE) - 60, TRUNC(SYSDATE) - 1);
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"lines":[{"b":' || boq(l_ct, '1.3') || ',"q":1250},{"b":' || boq(l_ct, '2.1') || ',"q":900}]}');
  NOONA_PRJ_PKG.approve_claim(l_cl);
  say('العقد الرئيسي (جدول كميات 8 بنود) ودفعة مقدمة ومستخلصان معتمدان (الأول محصل) وأمر تغيير');

  -- مقاول الباطن
  l_sc := NOONA_PRJ_PKG.save_contract('{"project":' || l_prj || ',"type":"SUBCONTRACT","supplier":' || l_sup || ',"no":"SUB-ITQ-01","ret":5,'
          || '"start":"' || d(-30) || '","end":"' || d(200) || '"}');
  l_n := NOONA_PRJ_PKG.save_boq(l_sc, '[{"code":"L1","d":"لياسة (مصنعية ومواد)","q":14000,"r":26,"w":' || l_w2 || '},'
         || '{"code":"L2","d":"تبليط (مصنعية)","q":5200,"r":45,"w":' || l_w2 || '}]');
  NOONA_PRJ_PKG.activate_contract(l_sc);
  l_cl := NOONA_PRJ_PKG.new_claim(l_sc, 'PROGRESS', TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) - 1);
  NOONA_PRJ_PKG.save_claim('{"id":' || l_cl || ',"lines":[{"b":' || boq(l_sc, 'L1') || ',"q":2500}]}');
  NOONA_PRJ_PKG.approve_claim(l_cl);
  say('عقد مقاول باطن للتشطيبات ومستخلصه الأول');

  -- تكاليف مباشرة وساعات عمل
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w || ',"type":"EQUIPMENT","amount":38000,"place":"BOX:' || l_box
         || '","desc":"إيجار رافعة برجية لشهرين","ref":"INV-CR-221","date":"' || d(-40) || '"}');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w || ',"type":"MATERIAL","amount":265000,"place":"BOX:' || l_box
         || '","desc":"حديد تسليح 95 طن","ref":"INV-ST-918","date":"' || d(-90) || '"}');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"wbs":' || l_w || ',"type":"MATERIAL","amount":410000,"place":"BOX:' || l_box
         || '","desc":"خرسانة جاهزة","ref":"INV-RMX-77","date":"' || d(-70) || '"}');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"type":"OVERHEAD","amount":24000,"place":"BOX:' || l_box
         || '","desc":"سكن وإعاشة العمالة بالموقع","date":"' || d(-20) || '"}');
  SELECT MIN(e.id) INTO l_emp FROM hr_employee e JOIN hr_employment m ON m.employee_id = e.id WHERE m.company_id = NOONA_PRJ_PKG.company;
  IF l_emp IS NOT NULL THEN
    FOR i IN 1 .. 10 LOOP
      l_x := NOONA_PRJ_PKG.save_timesheet('{"employee":' || l_emp || ',"project":' || l_prj || ',"wbs":' || l_w || ',"hours":8,"rate":65,"date":"' || d(-i * 3) || '"}');
    END LOOP;
    l_n := NOONA_PRJ_PKG.post_timesheets(l_prj);
  END IF;
  say('مصروفات مباشرة وساعات عمل محملة على المشروع');

  -- مشروع تطوير عقاري
  SELECT MIN(p.id) INTO l_prop FROM re_property p WHERE p.company_id = NOONA_PRJ_PKG.company AND p.project_id IS NULL
     AND EXISTS (SELECT 1 FROM re_unit u WHERE u.property_id = p.id);
  IF l_prop IS NOT NULL THEN
    l_x := NOONA_PRJ_PKG.save_project('{"code":"DEMO-DEV1","name":"تطوير ' || REPLACE(NOONA_RE_PKG.property_name(l_prop), '"', '') || '","type":"REAL_ESTATE_DEVELOPMENT",'
           || '"property":' || l_prop || ',"start":"' || d(-200) || '","end":"' || d(160) || '"}');
    l_n := NOONA_PRJ_PKG.save_budget(l_x, '[{"t":"SUBCONTRACT","a":8500000},{"t":"OTHER","a":450000}]');
    l_n := NOONA_PRJ_PKG.post_expense('{"project":' || l_x || ',"type":"OTHER","amount":185000,"place":"BOX:' || l_box || '","desc":"رسوم رخصة البناء والتصاميم"}');
    l_n := NOONA_PRJ_PKG.post_expense('{"project":' || l_x || ',"type":"SUBCONTRACT","amount":2350000,"place":"BOX:' || l_box || '","desc":"دفعة المقاول العام - الهيكل"}');
    say('مشروع تطوير عقاري مرتبط بالعقار وتوزع تكلفته على وحداته');
  END IF;
  COMMIT;
  say('');
  say('تم تحميل بيانات المشروعات. افتح «العقارات والضيافة والمشروعات > المشروعات والمقاولات».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
