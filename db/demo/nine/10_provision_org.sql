-- =============================================================================
-- NOONA PLUS ERP | تجهيز مؤسسة تجريبية واحدة (تشغل بحساب NOONA_APP من tools/vm/reset_nine_orgs.sh)
--   المعاملات: &1 رمز المؤسسة، &2 مستخدم المسؤول، &3 اسم المؤسسة، &4 الاسم الإنجليزي، &5 رمز الشركة، &6 اسم الشركة،
--              &7 رموز الأنظمة المشترك فيها (مفصولة بفواصل)، &8 رمز الفرع الثاني، &9 اسم الفرع الثاني
--   كلمة مرور المسؤول في المتغير ORG_PWD (يعرفه السكربت قبل الاستدعاء ولا تحفظ في ملف)
--   الناتج: المؤسسة واشتراك سنوي في أنظمتها، الشركة والمركز الرئيسي وفرع ثانٍ، دليل الحسابات، السجل التجاري والرقم
--           الضريبي، تفعيل الشركة، وتغيير كلمة المرور إلزامي عند أول دخول
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
DECLARE
  c_code  CONSTANT VARCHAR2(30)   := '&1';
  c_admin CONSTANT VARCHAR2(128)  := '&2';
  c_pwd   CONSTANT VARCHAR2(200)  := q'~&ORG_PWD~';
  l_t NUMBER; l_co NUMBER; l_x NUMBER; l_mods VARCHAR2(4000); l_f NUMBER; l_type NUMBER;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
BEGIN
  login(NVL('&PLT_USER', 'PLATFORM'));
  SELECT MAX(id) INTO l_t FROM plt_tenant WHERE tenant_code = c_code;
  IF l_t IS NULL THEN
    l_t := NOONA_PLATFORM_PKG.provision_tenant(
      p_tenant_code => c_code, p_tenant_slug => LOWER(c_code), p_name_ar => q'~&3~', p_name_en => q'~&4~',
      p_country_code => 'SA', p_base_currency => 'SAR', p_admin_username => c_admin,
      p_admin_email => LOWER(c_admin) || '@demo.noona.local', p_admin_name => 'مسؤول ' || q'~&3~', p_company_code => '&5',
      p_company_name_ar => q'~&6~', p_idempotency_key => 'NINE-' || c_code);
    l_x := NOONA_PLATFORM_ADMIN_PKG.set_subscription(l_t, 'ANNUAL', TRUNC(SYSDATE), 1, NULL, 'بيانات المختبرين');
  END IF;
  SELECT LISTAGG(id, ',') WITHIN GROUP (ORDER BY id) INTO l_mods FROM plt_module
   WHERE is_active = 'Y' AND (is_core = 'Y' OR INSTR(',' || '&7' || ',', ',' || module_code || ',') > 0);
  l_mods := NOONA_PLATFORM_ADMIN_PKG.set_tenant_modules(l_t, l_mods);
  NOONA_SEC_ADMIN_PKG.platform_set_password(c_admin, c_pwd, 'بيانات المختبرين');
  COMMIT;

  login(c_admin);
  SELECT MIN(id) INTO l_co FROM org_company WHERE code = '&5';
  NOONA_SECURITY_PKG.switch_company(l_co);
  SELECT COUNT(*) INTO l_x FROM org_branch WHERE company_id = l_co AND code = '&8';
  IF l_x = 0 THEN
    l_x := NOONA_PLATFORM_PKG.create_branch(l_co, '&8', q'~&9~', q'~&9~', 'REGIONAL');
  END IF;
  IF NOONA_GL_PKG.primary_coa IS NULL THEN
    l_x := NOONA_GL_PKG.quick_setup(l_co, 'OWN');
  END IF;
  COMMIT;
  -- السجل التجاري والرقم الضريبي ثم فحوص التفعيل والتفعيل (إن لم تكن نشطة)
  DECLARE
    l_st VARCHAR2(30); l_rt NUMBER; l_n NUMBER;
    l_cr  VARCHAR2(20) := '10' || LPAD(MOD(l_t * 7919, 99999999), 8, '0');
    l_vat VARCHAR2(20) := '3' || LPAD(MOD(l_t * 104729, 9999999999999), 13, '0') || '3';
  BEGIN
    SELECT status_code INTO l_st FROM org_company WHERE id = l_co;
    IF l_st <> 'ACTIVE' THEN
      FOR r IN (SELECT 'SA_CR' c, l_cr n, 'وزارة التجارة' a FROM dual UNION ALL
                SELECT 'SA_VAT', l_vat, 'هيئة الزكاة والضريبة والجمارك' FROM dual) LOOP
        SELECT MIN(t.id) INTO l_rt FROM loc_registration_type t WHERE t.country_pack_id = NOONA_LOC_PKG.company_pack AND t.code = r.c;
        SELECT COUNT(*) INTO l_n FROM org_legal_registration WHERE company_id = l_co AND reg_type_id = l_rt AND status_code = 'ACTIVE';
        IF l_rt IS NOT NULL AND l_n = 0 THEN
          l_n := NOONA_LOC_PKG.save_registration('{"type":' || l_rt || ',"number":"' || r.n || '","authority":"' || r.a
              || '","issue":"' || TO_CHAR(ADD_MONTHS(SYSDATE, -24), 'YYYY-MM-DD') || '"'
              || CASE WHEN r.c = 'SA_CR' THEN ',"expiry":"' || TO_CHAR(ADD_MONTHS(SYSDATE, 36), 'YYYY-MM-DD') || '"' END || '}');
        END IF;
      END LOOP;
      NOONA_INV_PKG.ensure_sequence('SAL_INVOICE', 'SI-');
      IF l_st = 'UNDER_CONFIGURATION' THEN
        NOONA_PLATFORM_PKG.change_company_status(l_co, 'READY_FOR_REVIEW', 'اكتمل إعداد الشركة');
      END IF;
      l_f := NOONA_PLATFORM_PKG.run_activation_checks(l_co);
      FOR k IN (SELECT check_code, result_info FROM org_company_check WHERE company_id = l_co AND status_code = 'FAILED') LOOP
        DBMS_OUTPUT.PUT_LINE('CHECK ' || k.check_code || ': ' || k.result_info);
      END LOOP;
      NOONA_PLATFORM_PKG.activate_company(l_co);
    END IF;
  EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('WARN activation: ' || SQLERRM);
  END;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ORG_OK ' || c_code || ' tenant=' || l_t || ' company=' || l_co);
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
