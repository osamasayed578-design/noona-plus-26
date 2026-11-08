-- =============================================================================
-- NOONA PLUS ERP | مؤسسة تجريبية: «مجموعة الريادة القابضة» (بعد التحديث 48) - تشغل بحساب NOONA_APP
--   تستدعى من tools/vm/demo_holding.sh (يمرر كلمة مرور المستخدمين التجريبيين في DEMO_PWD بلا عرضها)
-- المحتوى (نفس سيناريو فيديو «الشركة القابضة»):
--   * مؤسسة RYD مشتركة في كل الأنظمة، مسؤولها RYD_ADMIN
--   * مجموعة الأعمال «مجموعة الريادة»: القابضة RYD-HQ (دليل خاص) وفرع جدة،
--     الريادة للتجارة RYD-TRD (فرعان) والريادة للمقاولات RYD-CON على دليل المجموعة الموحد
--   * دور «المدير المالي» ومستخدم RYD_FIN (سامي المحاسب) في الشركات الثلاث
--   * قيود معتمدة: رأس المال، قرض ورسوم إدارة بين الشركات، مبيعات ومصروفات
--   * مجموعة تجميع CONS-RYD تستبعد 4190/5290 وحسابات «بين الشركات»، واعتماد التجميع للفترة
-- إعادة التشغيل لا تكرر البيانات: تعيد فقط تعيين كلمتي المرور
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
    NOONA_APEX_PKG.cleanup_request;
    DBMS_OUTPUT.PUT_LINE('EXISTS: مجموعة الريادة موجودة؛ أعيد تعيين كلمة المرور لـ RYD_ADMIN و RYD_FIN');
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
  COMMIT;
  login('RYD_FIN');
  FOR i IN 1 .. g_j.COUNT LOOP
    NOONA_SECURITY_PKG.switch_company(g_jc(i));
    NOONA_GL_PKG.approve_journal(g_j(i), 'مطابق للمستندات');
  END LOOP;
  COMMIT;

  -- 6) التجميع: مجموعة CONS-RYD ثم اعتماد الفترة
  login('RYD_ADMIN');
  NOONA_SECURITY_PKG.switch_company(l_h);
  l_grp := NOONA_CONSOL_PKG.save_group(NULL, 'CONS-RYD', 'القوائم الموحدة لمجموعة الريادة', l_bg, 'SAR', '4190, 5290');
  l_x := NOONA_CONSOL_PKG.approve(l_grp, TRUNC(l_d, 'YYYY'), l_d);
  COMMIT;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('DONE: مجموعة الريادة جاهزة - RYD_ADMIN (مسؤول المؤسسة) و RYD_FIN (المحاسب)');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
UNDEFINE DEMO_PWD
