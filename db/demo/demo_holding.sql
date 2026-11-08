-- =============================================================================
-- NOONA PLUS ERP | مؤسسة تجريبية: «مجموعة الريادة القابضة» (بعد التحديث 48) - تشغل بحساب NOONA_APP
--   تستدعى من tools/vm/demo_holding.sh (يمرر كلمة مرور المستخدمين التجريبيين في DEMO_PWD بلا عرضها)
-- المحتوى (نفس سيناريو فيديو «الشركة القابضة»):
--   * مؤسسة RYD مشتركة في كل الأنظمة، مسؤولها RYD_ADMIN
--   * مجموعة الأعمال «مجموعة الريادة»: القابضة RYD-HQ (دليل خاص) وفرع جدة،
--     الريادة للتجارة RYD-TRD (فرعان) والريادة للمقاولات RYD-CON على دليل المجموعة الموحد
--   * دور «المدير المالي» ومستخدم RYD_FIN (سامي المحاسب) في الشركات الثلاث
--   * قيود معتمدة: رأس المال، قرض ورسوم إدارة بين الشركات، مبيعات ومصروفات
--   * استثمار القابضة في التابعتين (1250): الريادة للتجارة مملوكة 80% والمقاولات 100% (الشهرة وحقوق الأقلية)
--   * مجموعة تجميع CONS-RYD تستبعد 4190/5290 وحسابات «بين الشركات» والاستثمار، واعتماد التجميع للفترة
--   * الهيكل التنظيمي للقابضة ووظائفه ومناصبه، وخمسة موظفين معينين على المناصب (الرئيس التنفيذي، المدير المالي،
--     رئيس المحاسبة، مدير الشؤون الإدارية، أخصائية الأرشيف)، والأرشيف (السجل التجاري)، ومذكرة داخلية للمحاسب
-- إعادة التشغيل لا تكرر البيانات: تعيد تعيين كلمتي المرور، وتضيف ما ينقص من نسخة سابقة من هذا السكربت
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
DECLARE
  c_pwd CONSTANT VARCHAR2(200) := q'~&DEMO_PWD~';
  l_d   DATE := TRUNC(SYSDATE);
  l_t NUMBER; l_bg NUMBER; l_h NUMBER; l_a NUMBER; l_b NUMBER; l_x NUMBER; l_n NUMBER;
  l_mem NUMBER; l_role NUMBER; l_grp NUMBER; l_adm NUMBER;
  l_mods VARCHAR2(4000);
  TYPE t_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  g_j t_ids; g_jc t_ids;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  PROCEDURE jv(p_desc VARCHAR2, p_lines VARCHAR2) IS
    l_j NUMBER;
  BEGIN
    l_j := NOONA_GL_PKG.create_journal(l_d, p_desc);
    NOONA_GL_PKG.save_lines(l_j, p_lines);
    NOONA_GL_PKG.submit_journal(l_j);
    g_j(g_j.COUNT + 1) := l_j; g_jc(g_j.COUNT) := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END jv;
  FUNCTION co(p_code VARCHAR2) RETURN NUMBER IS l_id NUMBER;
  BEGIN SELECT id INTO l_id FROM org_company WHERE code = p_code; RETURN l_id; END;
  PROCEDURE approve_all IS
  BEGIN
    COMMIT;
    login('RYD_FIN');
    FOR i IN 1 .. g_j.COUNT LOOP
      NOONA_SECURITY_PKG.switch_company(g_jc(i));
      NOONA_GL_PKG.approve_journal(g_j(i), 'مطابق للمستندات');
    END LOOP;
    g_j.DELETE; g_jc.DELETE;
    COMMIT;
    login('RYD_ADMIN');
  END approve_all;
  -- الإضافات: الاستثمار ونسب الملكية، الهيكل التنظيمي، الأرشيف، المراسلات (تتخطى ما هو موجود)
  PROCEDURE additions IS
    l_h NUMBER := co('RYD-HQ'); l_a NUMBER := co('RYD-TRD'); l_b NUMBER := co('RYD-CON');
    l_s NUMBER; l_v NUMBER; l_u NUMBER; l_job NUMBER; l_p NUMBER; l_g NUMBER; l_bg NUMBER; l_m NUMBER; l_q NUMBER;
    FUNCTION job(p_code VARCHAR2, p_name VARCHAR2) RETURN NUMBER IS l NUMBER;
    BEGIN
      SELECT MAX(id) INTO l FROM org_job WHERE code = p_code;
      IF l IS NULL THEN INSERT INTO org_job (code, name_ar, status_code) VALUES (p_code, p_name, 'ACTIVE') RETURNING id INTO l; END IF;
      RETURN l;
    END job;
    FUNCTION unit(p_code VARCHAR2) RETURN NUMBER IS l NUMBER;
    BEGIN
      SELECT MAX(u.id) INTO l FROM org_unit u JOIN org_structure_version sv ON sv.id = u.structure_version_id
        JOIN org_structure st ON st.id = sv.structure_id
       WHERE st.company_id = l_h AND st.code = 'ORG-HQ' AND sv.status_code = 'ACTIVE' AND u.code = p_code;
      RETURN l;
    END unit;
    -- منصب في وحدة (ينشأ إن لم يوجد)
    FUNCTION pos(p_unit VARCHAR2, p_code VARCHAR2, p_name VARCHAR2, p_job NUMBER, p_head VARCHAR2, p_to NUMBER) RETURN NUMBER IS l NUMBER;
    BEGIN
      SELECT MAX(id) INTO l FROM org_position WHERE company_id = l_h AND code = p_code;
      IF l IS NULL THEN l := NOONA_ORG_PKG.create_position(unit(p_unit), p_job, p_code, p_name, p_head, p_to); END IF;
      RETURN l;
    END pos;
    -- موظف بعقده وراتبه ثم تعيينه على المنصب
    PROCEDURE hire(p_name VARCHAR2, p_en VARCHAR2, p_nid VARCHAR2, p_gender VARCHAR2, p_months NUMBER, p_title VARCHAR2,
                   p_unit VARCHAR2, p_pos NUMBER, p_basic NUMBER, p_mobile VARCHAR2) IS
      l_e NUMBER;
    BEGIN
      l_e := NOONA_HR_PKG.save_employee('{"name_ar":"' || p_name || '","name_en":"' || p_en || '","national_id":"' || p_nid
        || '","nationality":"SA","gender":"' || p_gender || '","hire_date":"' || TO_CHAR(ADD_MONTHS(l_d, -p_months), 'YYYY-MM-DD')
        || '","job_title":"' || p_title || '","unit":' || unit(p_unit) || ',"mobile":"' || p_mobile || '","gosi_no":"' || SUBSTR(p_nid, 2, 9)
        || '","salary":{"BASIC":' || p_basic || ',"HOUSING":' || ROUND(p_basic / 4) || ',"TRANSPORT":' || ROUND(p_basic / 10) || '}}');
      -- التعيين على المنصب من تاريخ سريانه (الهيكل أنشئ اليوم)
      l_e := NOONA_ORG_PKG.assign_position(l_e, p_pos, 'PRIMARY', l_d, NULL, 100, 'تعيين على الهيكل المعتمد');
    END hire;
  BEGIN
    login('RYD_ADMIN');
    NOONA_SECURITY_PKG.switch_company(l_h);
    -- الاستثمار في التابعات
    SELECT COUNT(*) INTO l_q FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_code = '1250';
    IF l_q = 0 THEN
      l_q := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '1250', 'استثمارات في شركات تابعة', '12', 'ASSET', 'Y', NULL);
      jv('استثمار في الريادة للتجارة (80%)', '[{"a":"1250","d":450000},{"a":"1102","c":450000}]');
      jv('استثمار في الريادة للمقاولات (100%)', '[{"a":"1250","d":400000},{"a":"1102","c":400000}]');
      approve_all;
      NOONA_SECURITY_PKG.switch_company(l_h);
      SELECT id, business_group_id INTO l_g, l_bg FROM gl_consolidation_group WHERE code = 'CONS-RYD';
      l_g := NOONA_CONSOL_PKG.save_group(l_g, 'CONS-RYD', 'القوائم الموحدة لمجموعة الريادة', l_bg, 'SAR', '4190, 5290', '1250', 'RYD-TRD:80');
      l_q := NOONA_CONSOL_PKG.approve(l_g, TRUNC(l_d, 'YYYY'), l_d);
      COMMIT;
    END IF;
    -- الهيكل التنظيمي للقابضة
    SELECT COUNT(*) INTO l_q FROM org_structure WHERE company_id = l_h AND code = 'ORG-HQ';
    IF l_q = 0 THEN
      l_s := NOONA_ORG_PKG.create_structure(l_h, 'ORG-HQ', 'الهيكل الإداري للشركة القابضة', 'Holding structure');
      l_v := NOONA_ORG_PKG.new_version(l_s, 'الإصدار الأول');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'BOARD', 'مجلس الإدارة', 'EXECUTIVE');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'CEO', 'الرئيس التنفيذي', 'EXECUTIVE', 'BOARD');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'FIN', 'الإدارة المالية', 'DEPARTMENT', 'CEO');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'ACC', 'قسم المحاسبة', 'SECTION', 'FIN');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'ADM', 'الشؤون الإدارية', 'DEPARTMENT', 'CEO');
      l_u := NOONA_ORG_PKG.add_unit(l_v, 'ARC', 'الأرشيف والاتصالات الإدارية', 'SECTION', 'ADM');
      NOONA_ORG_PKG.activate_version(l_v);
      SELECT MAX(id) INTO l_job FROM org_job WHERE code = 'ACCT';
      IF l_job IS NULL THEN
        INSERT INTO org_job (code, name_ar, status_code) VALUES ('ACCT', 'محاسب', 'ACTIVE') RETURNING id INTO l_job;
      END IF;
      SELECT MAX(id) INTO l_u FROM org_unit WHERE structure_version_id = l_v AND code = 'FIN';
      l_p := NOONA_ORG_PKG.create_position(l_u, l_job, 'POS-FIN-MGR', 'المدير المالي', 'Y');
      SELECT MAX(id) INTO l_u FROM org_unit WHERE structure_version_id = l_v AND code = 'ACC';
      l_p := NOONA_ORG_PKG.create_position(l_u, l_job, 'POS-ACC-HEAD', 'رئيس قسم المحاسبة', 'Y', l_p);
      COMMIT;
    END IF;
    -- الموظفون وتعيينهم على مناصب الهيكل
    SELECT COUNT(*) INTO l_q FROM hr_employee WHERE national_id = '1090000001';
    IF l_q = 0 AND unit('CEO') IS NOT NULL THEN
      l_q := NOONA_PAY_PKG.quick_setup;
      DECLARE
        p_ceo NUMBER; p_fin NUMBER; p_acc NUMBER; p_adm NUMBER; p_arc NUMBER;
      BEGIN
        p_ceo := pos('CEO', 'POS-CEO', 'الرئيس التنفيذي', job('CEO', 'رئيس تنفيذي'), 'Y', NULL);
        p_fin := pos('FIN', 'POS-FIN-MGR', 'المدير المالي', job('FINMGR', 'مدير مالي'), 'Y', p_ceo);
        UPDATE org_position SET reports_to_position_id = p_ceo WHERE id = p_fin AND reports_to_position_id IS NULL;
        p_acc := pos('ACC', 'POS-ACC-HEAD', 'رئيس قسم المحاسبة', job('ACCT', 'محاسب'), 'Y', p_fin);
        p_adm := pos('ADM', 'POS-ADM-MGR', 'مدير الشؤون الإدارية', job('ADMMGR', 'مدير إداري'), 'Y', p_ceo);
        p_arc := pos('ARC', 'POS-ARC', 'أخصائي أرشيف ومراسلات', job('ARCH', 'أخصائي أرشيف'), 'Y', p_adm);
        hire('عبدالله بن فهد الريادي', 'Abdullah Alriyadi', '1090000001', 'M', 60, 'الرئيس التنفيذي', 'CEO', p_ceo, 40000, '0500000101');
        hire('خالد بن سعد العتيبي', 'Khalid Alotaibi', '1090000002', 'M', 36, 'المدير المالي', 'FIN', p_fin, 25000, '0500000102');
        hire('سامي بن ناصر الحربي', 'Sami Alharbi', '1090000003', 'M', 24, 'رئيس قسم المحاسبة', 'ACC', p_acc, 15000, '0500000103');
        hire('منى بنت عبدالعزيز الشهري', 'Mona Alshehri', '1090000004', 'F', 30, 'مدير الشؤون الإدارية', 'ADM', p_adm, 18000, '0500000104');
        hire('ريم بنت خالد القحطاني', 'Reem Alqahtani', '1090000005', 'F', 12, 'أخصائية أرشيف ومراسلات', 'ARC', p_arc, 9000, '0500000105');
      END;
      COMMIT;
    END IF;
    -- الأرشيف: التجهيز وأرشفة السجل التجاري (أصل ورقي)
    SELECT COUNT(*) INTO l_q FROM dms_document WHERE company_id = l_h AND external_ref = 'CR-1010778899';
    IF l_q = 0 THEN
      l_q := NOONA_DMS_PKG.quick_setup;
      l_q := NOONA_DMS_PKG.archive_document(NULL, NULL, 'COMMERCIAL_REGISTER', 'السجل التجاري - شركة الريادة القابضة',
               'CR-1010778899', 'خزنة الإدارة - ملف 1', ADD_MONTHS(l_d, -6), 'الأصل الورقي للسجل التجاري',
               p_valid_from => ADD_MONTHS(l_d, -6), p_valid_to => ADD_MONTHS(l_d, 18));
      COMMIT;
    END IF;
    -- المراسلات: مذكرة داخلية من المسؤول إلى المحاسب
    SELECT MAX(m.id) INTO l_m FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = 'RYD_FIN';
    SELECT COUNT(*) INTO l_q FROM cor_correspondence WHERE subject = 'إقفال حسابات الشهر في شركات المجموعة';
    IF l_q = 0 AND l_m IS NOT NULL THEN
      l_q := NOONA_COR_PKG.send('{"kind":"INTERNAL","to":[{"k":"U","id":' || l_m || '}],"subject":"إقفال حسابات الشهر في شركات المجموعة",'
          || '"body":"نأمل مراجعة قيود الشركات الثلاث واعتمادها، ثم إصدار القوائم الموحدة واعتماد التجميع للفترة.","priority":"HIGH"}');
      COMMIT;
    END IF;
  END additions;
BEGIN
  SELECT MAX(id) INTO l_t FROM plt_tenant WHERE tenant_code = 'RYD';
  login('PLATFORM');
  IF l_t IS NOT NULL THEN
    -- موجودة: إعادة تعيين كلمتي المرور فقط
    NOONA_SEC_ADMIN_PKG.platform_set_password('RYD_ADMIN', c_pwd, 'إعادة تشغيل البيانات التجريبية');
    login('RYD_ADMIN');
    SELECT MAX(m.id) INTO l_mem FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = 'RYD_FIN';
    IF l_mem IS NOT NULL THEN NOONA_SEC_ADMIN_PKG.set_password(l_mem, c_pwd); END IF;
    COMMIT;
    additions;
    NOONA_APEX_PKG.cleanup_request;
    DBMS_OUTPUT.PUT_LINE('EXISTS: مجموعة الريادة موجودة؛ أعيد تعيين كلمة المرور لـ RYD_ADMIN و RYD_FIN وأضيف ما ينقص');
    RETURN;
  END IF;

  -- 1) المنصة: تجهيز المؤسسة والاشتراك في كل الأنظمة
  l_t := NOONA_PLATFORM_PKG.provision_tenant(
    p_tenant_code => 'RYD', p_tenant_slug => 'ryd', p_name_ar => 'مجموعة الريادة القابضة', p_name_en => 'Al Riyada Holding Group',
    p_country_code => 'SA', p_base_currency => 'SAR', p_admin_username => 'RYD_ADMIN',
    p_admin_email => 'admin@riyada.example', p_admin_name => 'مسؤول مجموعة الريادة', p_company_code => 'RYD-HQ',
    p_company_name_ar => 'شركة الريادة القابضة', p_idempotency_key => 'DEMO-RYD');
  NOONA_SEC_ADMIN_PKG.platform_set_password('RYD_ADMIN', c_pwd, 'البيانات التجريبية: مجموعة الريادة');
  l_x := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'ANNUAL', l_d, 1, NULL, 'البيانات التجريبية');
  SELECT LISTAGG(id, ',') WITHIN GROUP (ORDER BY id) INTO l_mods FROM plt_module WHERE is_active = 'Y';
  l_mods := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_t, l_mods);
  COMMIT;

  -- 2) مسؤول المؤسسة: مجموعة الأعمال والشركات والفروع
  login('RYD_ADMIN');
  l_h := co('RYD-HQ');
  SELECT MAX(id) INTO l_bg FROM org_business_group WHERE code = 'MAIN';
  l_bg := NOONA_CONSOL_PKG.save_business_group(l_bg, 'MAIN', 'مجموعة الريادة', 'SAR', NULL, 'Al Riyada Group');
  NOONA_CONSOL_PKG.set_company_group(l_h, l_bg);
  l_x := NOONA_PLATFORM_PKG.create_branch(l_h, 'HQ-JED', 'فرع جدة', 'Jeddah Branch', 'REGIONAL');
  l_a := NOONA_PLATFORM_PKG.create_company('RYD-TRD', 'شركة الريادة للتجارة', 'Al Riyada Trading', 'SA', 'SAR', l_bg);
  l_x := NOONA_PLATFORM_PKG.create_branch(l_a, 'TRD-HQ', 'المركز الرئيسي - التجارة', 'Trading HQ', 'HEAD_OFFICE', 'Y');
  l_x := NOONA_PLATFORM_PKG.create_branch(l_a, 'TRD-DMM', 'فرع الدمام', 'Dammam Branch', 'REGIONAL');
  l_b := NOONA_PLATFORM_PKG.create_company('RYD-CON', 'شركة الريادة للمقاولات', 'Al Riyada Contracting', 'SA', 'SAR', l_bg);
  l_x := NOONA_PLATFORM_PKG.create_branch(l_b, 'CON-HQ', 'المركز الرئيسي - المقاولات', 'Contracting HQ', 'HEAD_OFFICE', 'Y');
  NOONA_CONSOL_PKG.set_company_group(l_a, l_bg);
  NOONA_CONSOL_PKG.set_company_group(l_b, l_bg);

  -- 3) المالية: القابضة بدليل خاص، والتابعتان على دليل المجموعة الموحد
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_x := NOONA_GL_PKG.quick_setup(l_h, 'OWN');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '1190', 'جاري الشركات التابعة', '11', 'ASSET', 'Y', 'INTERCOMPANY');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '4190', 'رسوم إدارة من الشركات التابعة', '4', 'REVENUE', 'Y', NULL);
  NOONA_SECURITY_PKG.switch_company(l_a);
  l_x := NOONA_GL_PKG.quick_setup(l_a, 'GROUP');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '2190', 'جاري الشركة القابضة', '21', 'LIABILITY', 'Y', 'INTERCOMPANY');
  l_x := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, '5290', 'رسوم إدارة للشركة القابضة', '52', 'EXPENSE', 'Y', NULL);
  NOONA_SECURITY_PKG.switch_company(l_b);
  l_x := NOONA_GL_PKG.quick_setup(l_b, 'GROUP');

  -- 4) دور المدير المالي والمحاسب في الشركات الثلاث
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_role := NOONA_SEC_ADMIN_PKG.create_role('FIN_MANAGER', 'المدير المالي', 'Finance Manager');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,CREATE,UPDATE,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL');
  l_mem := NOONA_SEC_ADMIN_PKG.create_user('RYD_FIN', 'سامي المحاسب', 'fin@riyada.example', l_h);
  NOONA_SEC_ADMIN_PKG.set_password(l_mem, c_pwd);
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_h, 'البيانات التجريبية');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_a, 'البيانات التجريبية');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, l_b, 'البيانات التجريبية');

  -- 5) القيود (يدخلها المسؤول ويعتمدها المحاسب: فصل المهام)
  NOONA_SECURITY_PKG.switch_company(l_h);
  jv('رأس مال الشركة القابضة', '[{"a":"1102","d":2000000},{"a":"3101","c":2000000}]');
  jv('قرض للريادة للتجارة', '[{"a":"1190","d":300000},{"a":"1102","c":300000}]');
  jv('رسوم إدارة من الريادة للتجارة', '[{"a":"1102","d":40000},{"a":"4190","c":40000}]');
  NOONA_SECURITY_PKG.switch_company(l_a);
  jv('رأس مال الريادة للتجارة', '[{"a":"1102","d":500000},{"a":"3101","c":500000}]');
  jv('قرض من الشركة القابضة', '[{"a":"1102","d":300000},{"a":"2190","c":300000}]');
  jv('رسوم إدارة للشركة القابضة', '[{"a":"5290","d":40000},{"a":"1102","c":40000}]');
  jv('مبيعات نقدية', '[{"a":"1102","d":180000},{"a":"4101","c":180000}]');
  NOONA_SECURITY_PKG.switch_company(l_b);
  jv('رأس مال الريادة للمقاولات', '[{"a":"1102","d":400000},{"a":"3101","c":400000}]');
  jv('إيراد مستخلص مشروع', '[{"a":"1102","d":120000},{"a":"4101","c":120000}]');
  jv('مصروفات تشغيل', '[{"a":"5202","d":55000},{"a":"1102","c":55000}]');
  approve_all;

  -- 6) التجميع: مجموعة CONS-RYD ثم اعتماد الفترة
  login('RYD_ADMIN');
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_grp := NOONA_CONSOL_PKG.save_group(NULL, 'CONS-RYD', 'القوائم الموحدة لمجموعة الريادة', l_bg, 'SAR', '4190, 5290');
  l_x := NOONA_CONSOL_PKG.approve(l_grp, TRUNC(l_d, 'YYYY'), l_d);
  COMMIT;
  additions;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('DONE: مجموعة الريادة جاهزة - RYD_ADMIN (مسؤول المؤسسة) و RYD_FIN (المحاسب)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
UNDEFINE DEMO_PWD
