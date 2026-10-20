"""NOONA_PLATFORM (لوحة المنصة) - لمسؤول المنصة فقط: المؤسسات المشتركة واشتراكاتها وتجهيزها والتدقيق
الاستخدام: python3 tools/build_platform.py   ->  apex/NOONA_PLATFORM/f125
بيانات المؤسسات تقرأ عبر NOONA_PLATFORM_ADMIN_PKG (مقاييس تشغيلية فقط، لا بيانات أعمال).
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_PLATFORM/f125'),
          app_id=125, alias='NOONA_PLATFORM', name='NOONA Platform', id_base=91820265000000000)
app.wire_security()
app.add_branding()
PLATFORM = app.schemes['platform']

def back(page_no):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:::'

TENANT_STATUS = ("select noona_ui_pkg.status_label(column_value) d, column_value r from table(sys.odcivarchar2list("
                 "'TRIAL','PENDING_ACTIVATION','ACTIVE','GRACE_PERIOD','READ_ONLY','SUSPENDED','ARCHIVED','CLOSED'))")
TENANTS_SQL = [
    'select t.id, t.tenant_code, t.name_ar, t.country_code, t.deployment_model,',
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'COMPANIES') as companies,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'USERS') as users,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'MODULES') as modules,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'LAST_LOGIN') as last_login,",
    "       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html",
    '  from plt_tenant t']
TENANTS_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('TENANT_CODE', 'الرمز', {}), ('NAME_AR', 'المؤسسة', {}),
                ('COUNTRY_CODE', 'الدولة', {}), ('DEPLOYMENT_MODEL', 'نموذج التشغيل', {}), ('COMPANIES', 'شركات', {}),
                ('USERS', 'مستخدمون', {}), ('MODULES', 'وحدات مشترك فيها', {}), ('LAST_LOGIN', 'آخر دخول', {}),
                ('LEGAL_HOLD', 'حجز قانوني', {}), ('STATUS_HTML', 'الحالة', {'html': True})]
TENANT_LINK = 'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'

# =============================================================== 1) لوحة المنصة
p = app.page(1, 'Home', 'HOME', 'لوحة المنصة', scheme=PLATFORM)
p.dynamic('مؤشرات المنصة', 10, 'return noona_platform_admin_pkg.platform_summary;', hide_header=True)
r = p.ir('المؤسسات المشتركة', 20, TENANTS_SQL, TENANTS_COLS, link=TENANT_LINK, titled=True)
p.button(r, 10, 'NEW_TENANT', 'تجهيز مؤسسة جديدة', hot=True, redirect=back(4), position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 3) المؤسسة
p = app.page(3, 'Tenant', 'TENANT', 'المؤسسة المشتركة', scheme=PLATFORM)
info = p.static('المؤسسة', 10)
p.hidden('P3_ID', info, 1)
p.display('P3_NAME', info, 10, 'المؤسسة')
p.display('P3_STATUS', info, 20, 'الحالة')
p.display('P3_DETAILS', info, 30, 'التفاصيل')
p.select('P3_NEW_STATUS', info, 40, 'تغيير الحالة إلى', lov_sql=TENANT_STATUS)
p.textarea('P3_REASON', info, 50, 'السبب (إلزامي لتغيير الحالة والحجز القانوني)', rows=2)
b_st = p.button(info, 10, 'CHANGE_STATUS', 'تغيير الحالة', hot=True)
b_hold = p.button(info, 20, 'LEGAL_HOLD', 'تفعيل الحجز القانوني')
b_unhold = p.button(info, 30, 'RELEASE_HOLD', 'رفع الحجز القانوني')
p.button(info, 40, 'BACK', 'رجوع', redirect=back(1))
p.process(10, 'BEFORE_HEADER', 'Load Tenant', [
    "select name_ar || ' (' || tenant_code || ')', noona_ui_pkg.status_label(status_code),",
    "       country_code || ' · ' || base_currency || ' · ' || deployment_model || ' · منذ ' || to_char(created_at, 'YYYY-MM-DD')",
    "       || case legal_hold when 'Y' then ' · تحت حجز قانوني' end",
    '  into :P3_NAME, :P3_STATUS, :P3_DETAILS from plt_tenant where id = :P3_ID;'])
p.process(10, 'AFTER_SUBMIT', 'Change Status', 'noona_platform_pkg.change_tenant_status(:P3_ID, :P3_NEW_STATUS, :P3_REASON);',
          when_button=b_st, success='تم تغيير حالة المؤسسة')
p.process(20, 'AFTER_SUBMIT', 'Legal Hold', "noona_platform_pkg.set_legal_hold(:P3_ID, 'Y', :P3_REASON);",
          when_button=b_hold, success='تم تفعيل الحجز القانوني')
p.process(30, 'AFTER_SUBMIT', 'Release Hold', "noona_platform_pkg.set_legal_hold(:P3_ID, 'N', :P3_REASON);",
          when_button=b_unhold, success='تم رفع الحجز القانوني')
# الاشتراك في الوحدات: يحدد الأنظمة الظاهرة لمستخدمي المؤسسة في شاشة الأنظمة
md = p.static('الوحدات المشترك فيها', 20)
p.hidden('P3_MODS', md, 1, protected=False)
b_mods = p.button(md, 10, 'SAVE_MODULES', 'حفظ الاشتراك', hot=True)
p.dynamic('خانات الوحدات', 25, 'return noona_platform_admin_pkg.module_matrix(:P3_ID);', hide_header=True)
p.onload([
    '// قبل الإرسال: أرقام الوحدات المختارة',
    "$(document).on('apexbeforepagesubmit', function () {",
    "    $s('P3_MODS', $('.nn-mod-cb:checked').map(function () { return this.value; }).get().join(','));",
    '});'])
p.process(40, 'AFTER_SUBMIT', 'Save Modules', [
    'declare l_r varchar2(50);',
    'begin',
    '    l_r := noona_platform_admin_pkg.set_tenant_modules(:P3_ID, :P3_MODS);',
    "    apex_application.g_print_success_message := 'تم حفظ الاشتراك: تفعيل ' || substr(l_r, 1, instr(l_r, ':') - 1)",
    "        || ' وإيقاف ' || substr(l_r, instr(l_r, ':') + 1);",
    'end;'], when_button=b_mods)
p.dynamic('مسؤولو المؤسسة', 30, 'return noona_platform_admin_pkg.tenant_admins_html(:P3_ID);')
pw = p.static('إعادة تعيين كلمة مرور (دعم فني)', 35)
p.text('P3_USERNAME', pw, 10, 'اسم الدخول', maxlen=100, width=30)
p.password('P3_PASSWORD', pw, 20, 'كلمة المرور الجديدة')
p.text('P3_PWD_REASON', pw, 30, 'رقم طلب الدعم أو السبب')
b_pwd = p.button(pw, 10, 'RESET_PASSWORD', 'تعيين كلمة المرور')
p.process(50, 'AFTER_SUBMIT', 'Reset Password', [
    'noona_sec_admin_pkg.platform_set_password(:P3_USERNAME, :P3_PASSWORD, :P3_PWD_REASON);',
    ':P3_PASSWORD := null;'], when_button=b_pwd, success='تم تعيين كلمة المرور وفك القفل')
p.dynamic('سلامة سجل التدقيق', 40, [
    'declare l_bad number := noona_platform_admin_pkg.verify_tenant_chain(:P3_ID);',
    'begin',
    '    if l_bad is null then',
    "        return '<div class=\"nn-chain is-ok\"><span class=\"fa fa-shield\" aria-hidden=\"true\"></span><div><b>سجل تدقيق المؤسسة سليم</b>'",
    "            || '<small>سلسلة التجزئة مطابقة لكل الأحداث</small></div></div>';",
    '    end if;',
    "    return '<div class=\"nn-chain is-bad\"><span class=\"fa fa-exclamation-triangle\" aria-hidden=\"true\"></span><div>'",
    "        || '<b>انقطاع في سلسلة التدقيق</b><small>أول حدث غير مطابق رقم ' || l_bad || '</small></div></div>';",
    'end;'], hide_header=True)
p.dynamic('آخر أحداث التدقيق', 45, 'return noona_platform_admin_pkg.audit_html(:P3_ID, 30);')
p.branch(10, 'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:3:P3_ID:&P3_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 4) تجهيز مؤسسة جديدة
p = app.page(4, 'Provision Tenant', 'PROVISION', 'تجهيز مؤسسة جديدة', scheme=PLATFORM)
t = p.static('بيانات المؤسسة', 10)
p.text('P4_CODE', t, 10, 'رمز المؤسسة', required=True, maxlen=30, width=15)
p.text('P4_SLUG', t, 20, 'المعرف في الرابط (حروف إنجليزية صغيرة)', required=True, maxlen=50, width=20)
p.text('P4_NAME_AR', t, 30, 'الاسم بالعربية', required=True)
p.text('P4_NAME_EN', t, 40, 'الاسم بالإنجليزية', required=True)
p.select('P4_COUNTRY', t, 50, 'الدولة', lov_name='NOONA_COUNTRIES', required=True)
p.select('P4_CURRENCY', t, 60, 'العملة الأساسية', lov_name='NOONA_CURRENCIES', required=True)
p.yesno('P4_TRIAL', t, 70, 'نسخة تجريبية')
p.text('P4_COMPANY_CODE', t, 80, 'رمز الشركة الأولى', required=True, maxlen=50, width=15)
p.text('P4_COMPANY_NAME', t, 90, 'اسم الشركة الأولى', required=True)
a = p.static('مسؤول المؤسسة', 20)
p.text('P4_ADMIN_USER', a, 10, 'اسم الدخول', required=True, maxlen=100, width=30)
p.text('P4_ADMIN_NAME', a, 20, 'الاسم الكامل', required=True)
p.text('P4_ADMIN_EMAIL', a, 30, 'البريد الإلكتروني', required=True)
p.password('P4_ADMIN_PASSWORD', a, 40, 'كلمة المرور الأولى', required=True)
b = p.button(a, 10, 'PROVISION', 'تجهيز المؤسسة', hot=True)
p.button(a, 20, 'CANCEL', 'إلغاء', redirect=back(1))
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P4_COUNTRY := nvl(:P4_COUNTRY, 'SA'); :P4_CURRENCY := nvl(:P4_CURRENCY, 'SAR');"])
p.process(10, 'AFTER_SUBMIT', 'Provision Tenant', [
    ':P3_ID := noona_platform_pkg.provision_tenant(',
    '    p_tenant_code => :P4_CODE, p_tenant_slug => lower(:P4_SLUG), p_name_ar => :P4_NAME_AR, p_name_en => :P4_NAME_EN,',
    '    p_country_code => :P4_COUNTRY, p_base_currency => :P4_CURRENCY, p_admin_username => :P4_ADMIN_USER,',
    '    p_admin_email => :P4_ADMIN_EMAIL, p_admin_name => :P4_ADMIN_NAME, p_company_code => :P4_COMPANY_CODE,',
    "    p_company_name_ar => :P4_COMPANY_NAME, p_idempotency_key => 'UI-' || upper(:P4_CODE), p_is_trial => nvl(:P4_TRIAL, 'N'));",
    "noona_sec_admin_pkg.platform_set_password(:P4_ADMIN_USER, :P4_ADMIN_PASSWORD, 'كلمة المرور الأولى عند التجهيز');",
    ':P4_ADMIN_PASSWORD := null;'], when_button=b, success='تم تجهيز المؤسسة؛ حدد الوحدات المشترك فيها')
p.branch(10, 'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:&P3_ID.&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 5) سجل تدقيق المنصة
p = app.page(5, 'Platform Audit', 'AUDIT', 'سجل تدقيق المنصة', scheme=PLATFORM)
p.dynamic('سلامة سجل المنصة', 10, [
    'declare l_bad number := noona_platform_admin_pkg.verify_tenant_chain(null);',
    'begin',
    "    return case when l_bad is null then '<div class=\"nn-chain is-ok\"><span class=\"fa fa-shield\" aria-hidden=\"true\"></span>'",
    "        || '<div><b>سجل تدقيق المنصة سليم</b><small>سلسلة التجزئة مطابقة</small></div></div>'",
    "        else '<div class=\"nn-chain is-bad\"><span class=\"fa fa-exclamation-triangle\" aria-hidden=\"true\"></span>'",
    "        || '<div><b>انقطاع في سلسلة التدقيق</b><small>أول حدث غير مطابق رقم ' || l_bad || '</small></div></div>' end;",
    'end;'], hide_header=True)
p.dynamic('أحداث المنصة', 20, 'return noona_platform_admin_pkg.audit_html(null, 200);')

# =============================================================== 6) الوحدات
p = app.page(6, 'Modules', 'MODULES', 'وحدات النظام', scheme=PLATFORM)
p.ir('وحدات النظام', 10, [
    'select id, package_no, module_code, name_ar, name_en, plsql_package, noona_ui_pkg.code_label(is_core) as is_core,',
    '       noona_ui_pkg.code_label(is_active) as is_active from plt_module'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PACKAGE_NO', 'الحزمة', {'type': 'NUMBER'}), ('MODULE_CODE', 'الرمز', {}),
     ('NAME_AR', 'الوحدة', {}), ('NAME_EN', 'بالإنجليزية', {}), ('PLSQL_PACKAGE', 'حزمة PL/SQL', {}),
     ('IS_CORE', 'أساسية', {}), ('IS_ACTIVE', 'فعالة', {})])

# =============================================================== 7) مسؤولو المنصة
p = app.page(7, 'Platform Admins', 'ADMINS', 'مسؤولو المنصة', scheme=PLATFORM)
p.ir('مسؤولو المنصة', 10, [
    "select id, username, display_name, email, noona_ui_pkg.code_label(mfa_required) as mfa, to_char(last_login_at, 'YYYY-MM-DD HH24:MI') as last_login,",
    "       noona_ui_pkg.status_badge(status_code) as status_html from sec_user where user_type in ('PLATFORM_ADMIN', 'SUPPORT', 'BREAK_GLASS')"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('USERNAME', 'اسم الدخول', {}), ('DISPLAY_NAME', 'الاسم', {}),
     ('EMAIL', 'البريد', {}), ('MFA', 'تحقق متعدد', {}), ('LAST_LOGIN', 'آخر دخول', {}), ('STATUS_HTML', 'الحالة', {'html': True})])

app.nav_item('لوحة المنصة', 1, 'fa-server', 10)
app.nav_item('تجهيز مؤسسة', 4, 'fa-plus-circle', 20)
app.nav_item('سجل تدقيق المنصة', 5, 'fa-shield', 30)
app.nav_item('وحدات النظام', 6, 'fa-cubes', 40)
app.nav_item('مسؤولو المنصة', 7, 'fa-user-secret', 50)

app.finalize()
print('NOONA_PLATFORM built:', len(app.pages), 'pages')
