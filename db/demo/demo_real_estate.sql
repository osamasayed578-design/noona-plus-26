-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية لبيع الوحدات وإدارة الأملاك (بعد التحديث 32) - بحساب NOONA_APP، ولا تكرر (تكتشف العقار DEMO-RE-T):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_real_estate.sql ADMIN
-- المحتوى: برج سكني للبيع (12 شقة) بمشروع تطوير وتكاليف مرسملة، قائمة أسعار وخطة سداد، حجز ساري، عقدا بيع موقعان بأقساط وتحصيل
--          وعمولة وسيط؛ عمارة تجارية سكنية مدارة لصالح مالك (اتفاقية 8%)، ثلاثة عقود إيجار (شهري بتأمين، ربع سنوي بزيادة سنوية،
--          عقد ينتهي قريباً)، فوترة الإيجارات وتحصيل جزء منها، عداد كهرباء بقراءتين
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
  l_n     NUMBER;
  l_x     NUMBER;
  l_box   NUMBER;
  l_tower NUMBER;
  l_bld   NUMBER;
  l_prj   NUMBER;
  l_pl    NUMBER;
  l_plan  NUMBER;
  l_brk   NUMBER;
  l_b1    NUMBER; l_b2 NUMBER; l_b3 NUMBER;
  l_r     NUMBER;
  l_c     NUMBER;
  l_inv   NUMBER;
  l_oi    NUMBER;
  l_cu    NUMBER;
  l_agr   NUMBER;
  l_ls    NUMBER;
  l_met   NUMBER;
  l_lines VARCHAR2(4000);
  l_start DATE := ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -3);
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION unit(p_prop NUMBER, p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN SELECT id INTO l FROM re_unit WHERE property_id = p_prop AND code = p_code; RETURN l; END;
  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE pay(p_inv NUMBER, p_amt NUMBER) IS
  BEGIN
    SELECT customer_account_id INTO l_cu FROM sal_invoice WHERE id = p_inv;
    SELECT MIN(id) INTO l_oi FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = p_inv;
    l_x := NOONA_SAL_PKG.receive('{"cust":' || l_cu || ',"date":"' || d(TRUNC(SYSDATE)) || '","amount":' || p_amt || ',"place":"BOX:' || l_box
                                 || '","method":"BANK_APP","alloc":[{"inv":' || l_oi || ',"a":' || p_amt || '}]}');
  END pay;
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
  SELECT COUNT(*) INTO l_n FROM re_property WHERE company_id = NOONA_RES_PKG.company AND code = 'DEMO-RE-T';
  IF l_n > 0 THEN
    say('بيانات العقارات محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  SELECT MIN(id) INTO l_box FROM csh_cash_box WHERE company_id = NOONA_RES_PKG.company AND status_code = 'ACTIVE';
  IF l_box IS NULL THEN
    say('أنشئ صندوقاً من المالية (الصناديق والبنوك) أولاً.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  fund_box(3500000, 'تمويل من الشركاء لتطوير الأبراج');
  l_n := NOONA_RES_PKG.setup_accounts + NOONA_PRP_PKG.setup_accounts;

  -- ======================================================== برج للبيع
  l_tower := NOONA_RE_PKG.setup_wizard('{"code":"DEMO-RE-T","name_ar":"أبراج الياسمين السكنية","type":"TOWER","address":"الرياض - حي الياسمين",'
             || '"buildings":[{"code":"A","name":"البرج A","floors":3}],'
             || '"units":{"per_floor":4,"unit_type":"APARTMENT","usage_type":"SALE","bedrooms":3,"bathrooms":3,"area":160,"view":"CITY"}}');
  UPDATE re_unit SET net_area_sqm = CASE MOD(TO_NUMBER(code), 2) WHEN 0 THEN 185 ELSE 160 END, bedrooms = CASE MOD(TO_NUMBER(code), 2) WHEN 0 THEN 4 ELSE 3 END
   WHERE property_id = l_tower;
  l_prj := NOONA_PRJ_PKG.save_project('{"code":"DEMO-RE-DEV","name":"تطوير أبراج الياسمين","type":"REAL_ESTATE_DEVELOPMENT","property":' || l_tower || '}');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"type":"SUBCONTRACT","amount":1850000,"place":"BOX:' || l_box || '","desc":"أعمال الهيكل الخرساني"}');
  l_x := NOONA_PRJ_PKG.post_expense('{"project":' || l_prj || ',"type":"MATERIAL","amount":950000,"place":"BOX:' || l_box || '","desc":"التشطيبات والمواد"}');
  l_x := NOONA_RES_PKG.capitalize_costs(l_tower, 'AREA');
  say('برج الياسمين: 12 شقة، تكلفة تطوير 2,800,000 مرسملة على الوحدات حسب المساحة');
  l_lines := '';
  FOR u IN (SELECT u.id, NVL(u.net_area_sqm, 160) area, f.floor_no FROM re_unit u JOIN re_floor f ON f.id = u.floor_id WHERE u.property_id = l_tower) LOOP
    l_lines := l_lines || CASE WHEN l_lines IS NOT NULL THEN ',' END || '{"unit":' || u.id || ',"price":' || ROUND(u.area * 6500 * (1 + 0.02 * u.floor_no), -3)
            || ',"min":' || ROUND(u.area * 6500 * (1 + 0.02 * u.floor_no) * 0.95, -3) || '}';
  END LOOP;
  l_pl := NOONA_RES_PKG.save_price_list('{"property":' || l_tower || ',"name":"قائمة أسعار الإطلاق 2026","lines":[' || l_lines || ']}');
  NOONA_RES_PKG.activate_price_list(l_pl);
  l_plan := NOONA_RES_PKG.save_plan('{"code":"DEMO-PLAN","name":"10% مقدم و8 أقساط ربع سنوية و20% عند التسليم","property":' || l_tower
            || ',"down":10,"count":8,"freq":"QUARTERLY","handover":20}');
  l_brk := NOONA_PTY_PKG.create_party('ORGANIZATION', 'مكتب الديار للوساطة العقارية', 'BROKER');
  l_b1 := NOONA_SAL_PKG.customer_party(NOONA_SAL_PKG.save_customer('{"name":"عبدالله بن سعد القحطاني","phone":"0551230001","person":"Y","term":"NET0"}'));
  l_b2 := NOONA_SAL_PKG.customer_party(NOONA_SAL_PKG.save_customer('{"name":"نورة بنت محمد العتيبي","phone":"0551230002","person":"Y","term":"NET0"}'));
  l_b3 := NOONA_SAL_PKG.customer_party(NOONA_SAL_PKG.save_customer('{"name":"خالد بن عمر الشهري","phone":"0551230003","person":"Y","term":"NET0"}'));
  -- عقد من حجز بعربون مع وسيط
  l_r := NOONA_RES_PKG.reserve('{"unit":' || unit(l_tower, '101') || ',"buyer":' || l_b1 || ',"broker":' || l_brk || ',"deposit":25000,"place":"BOX:' || l_box || '"}');
  l_c := NOONA_RES_PKG.create_contract('{"reservation":' || l_r || ',"plan":' || l_plan || ',"handover":"' || d(ADD_MONTHS(SYSDATE, 18))
         || '","broker":' || l_brk || ',"commission":2.5,"eligible":20}');
  NOONA_RES_PKG.sign_contract(l_c, TRUNC(SYSDATE), 'SAKANI-2026-0101');
  SELECT sales_invoice_id INTO l_inv FROM re_sale_installment WHERE contract_id = l_c AND installment_no = 1;
  SELECT NVL(SUM(open_amount), 0) INTO l_n FROM ar_open_item WHERE source_entity_type = 'SAL_INVOICE' AND source_entity_id = l_inv;
  pay(l_inv, l_n);
  -- عقد مباشر بدفعة أولى غير مسددة بعد
  l_c := NOONA_RES_PKG.create_contract('{"unit":' || unit(l_tower, '202') || ',"buyer":' || l_b2 || ',"plan":' || l_plan || ',"handover":"' || d(ADD_MONTHS(SYSDATE, 18)) || '"}');
  NOONA_RES_PKG.sign_contract(l_c, TRUNC(SYSDATE));
  -- حجز ساري
  l_r := NOONA_RES_PKG.reserve('{"unit":' || unit(l_tower, '304') || ',"buyer":' || l_b3 || ',"deposit":15000,"place":"BOX:' || l_box || '","days":14}');
  NOONA_RES_PKG.refresh_installments;
  say('بيع الوحدات: عقدان موقعان (أحدهما بعربون ووسيط وعمولة 2.5%)، وحجز ساري');

  -- ======================================================== عمارة للإيجار مدارة لصالح مالك
  l_bld := NOONA_RE_PKG.setup_wizard('{"code":"DEMO-RE-L","name_ar":"عمارة النخيل","type":"BUILDING","address":"الرياض - حي النخيل",'
           || '"buildings":[{"code":"N","name":"عمارة النخيل","floors":2}],'
           || '"units":{"per_floor":3,"unit_type":"APARTMENT","usage_type":"LEASE","bedrooms":2,"area":110}}');
  UPDATE re_unit SET unit_type = 'OFFICE', bedrooms = NULL WHERE property_id = l_bld AND code LIKE '1%';
  l_agr := NOONA_PRP_PKG.save_agreement('{"ownerName":"ورثة عبدالرحمن النخيلي","property":' || l_bld || ',"feeType":"PCT_OF_COLLECTION","feePct":8,"remit":"MONTHLY",'
           || '"from":"' || d(ADD_MONTHS(TRUNC(SYSDATE), -12)) || '"}');
  l_ls := NOONA_PRP_PKG.save_lease('{"type":"RESIDENTIAL","property":' || l_bld || ',"units":[' || unit(l_bld, '201') || '],"tenantName":"فهد بن ناصر الدوسري",'
          || '"phone":"0554440001","start":"' || d(l_start) || '","end":"' || d(ADD_MONTHS(l_start, 12) - 1) || '","rent":42000,"freq":"MONTHLY",'
          || '"deposit":3500,"grace":5,"charges":[{"type":"SERVICE_CHARGE","amount":150,"freq":"MONTHLY"}]}');
  NOONA_PRP_PKG.activate_lease(l_ls, 'EJAR-2026-55001');
  l_x := NOONA_PRP_PKG.receive_deposit(l_ls, 'BOX:' || l_box);
  l_x := NOONA_PRP_PKG.bill_rent(l_ls);
  FOR i IN (SELECT DISTINCT sales_invoice_id FROM prp_rent_schedule WHERE lease_id = l_ls AND sales_invoice_id IS NOT NULL AND due_date < TRUNC(SYSDATE, 'MM')) LOOP
    SELECT total_amount INTO l_n FROM sal_invoice WHERE id = i.sales_invoice_id;
    pay(i.sales_invoice_id, l_n);
  END LOOP;
  l_met := NOONA_PRP_PKG.save_meter('{"unit":' || unit(l_bld, '201') || ',"type":"ELECTRICITY","no":"SEC-30018845","account":"30018845","rate":0.18}');
  l_x := NOONA_PRP_PKG.add_reading(l_met, TRUNC(SYSDATE) - 30, 12450);
  l_x := NOONA_PRP_PKG.add_reading(l_met, TRUNC(SYSDATE), 13120);
  l_ls := NOONA_PRP_PKG.save_lease('{"type":"COMMERCIAL","property":' || l_bld || ',"units":[' || unit(l_bld, '101') || ',' || unit(l_bld, '102')
          || '],"tenantName":"شركة الأفق للاستشارات","tax":"310987654300003","person":"N","start":"' || d(TRUNC(SYSDATE, 'MM')) || '","end":"'
          || d(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 36) - 1) || '","rent":120000,"freq":"QUARTERLY","escalation":5,"deposit":10000,'
          || '"charges":[{"type":"PARKING","amount":300,"freq":"MONTHLY"}]}');
  NOONA_PRP_PKG.activate_lease(l_ls, 'EJAR-2026-55002');
  l_x := NOONA_PRP_PKG.bill_rent(l_ls);
  l_ls := NOONA_PRP_PKG.save_lease('{"type":"COMMERCIAL","property":' || l_bld || ',"units":[' || unit(l_bld, '103') || '],"tenantName":"مؤسسة الرواد التجارية",'
          || '"person":"N","start":"' || d(GREATEST(TRUNC(SYSDATE, 'YYYY'), ADD_MONTHS(TRUNC(SYSDATE), -11))) || '","end":"' || d(TRUNC(SYSDATE) + 45) || '","rent":36000,"freq":"ANNUAL"}');
  NOONA_PRP_PKG.activate_lease(l_ls);
  l_x := NOONA_PRP_PKG.bill_rent(l_ls);
  say('الإيجارات: عمارة النخيل مدارة لصالح المالك بأتعاب 8%، ثلاثة عقود (أحدها ينتهي خلال 45 يوماً)، تأمين، عداد كهرباء بقراءتين');

  COMMIT;
  say('');
  say('تم تحميل بيانات العقارات. افتح «العقارات والضيافة والمشروعات > بيع الوحدات» و«الإيجارات وإدارة الأملاك».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
