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
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'COMPANIES') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, 'COMPANIES'),",
    "           ' / ' || noona_platform_admin_pkg.tenant_limit(t.id, 'COMPANIES'), '') as companies,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'BRANCHES') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, 'BRANCHES'),",
    "           ' / ' || noona_platform_admin_pkg.tenant_limit(t.id, 'BRANCHES'), '') as branches,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'USERS') || nvl2(noona_platform_admin_pkg.tenant_limit(t.id, 'USERS'),",
    "           ' / ' || noona_platform_admin_pkg.tenant_limit(t.id, 'USERS'), '') as users,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'MODULES') as modules,",
    "       noona_platform_admin_pkg.tenant_metric(t.id, 'LAST_LOGIN') as last_login,",
    "       noona_platform_admin_pkg.sub_info(t.id, 'PLAN') as plan_name, noona_platform_admin_pkg.sub_info(t.id, 'END') as sub_end,",
    "       to_number(noona_platform_admin_pkg.sub_info(t.id, 'LEFT')) as days_left, to_char(t.created_at, 'YYYY-MM-DD') as joined,",
    "       noona_ui_pkg.code_label(t.legal_hold) as legal_hold, noona_ui_pkg.status_badge(t.status_code) as status_html, t.status_code",
    '  from plt_tenant t']
TENANTS_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('TENANT_CODE', 'الرمز', {}), ('NAME_AR', 'المؤسسة', {}),
                ('COUNTRY_CODE', 'الدولة', {}), ('DEPLOYMENT_MODEL', 'نموذج التشغيل', {}), ('COMPANIES', 'شركات (الحد)', {}),
                ('BRANCHES', 'فروع (الحد)', {}), ('USERS', 'مستخدمون (الحد)', {}), ('MODULES', 'وحدات مشترك فيها', {}), ('LAST_LOGIN', 'آخر دخول', {}),
                ('PLAN_NAME', 'الباقة', {}), ('SUB_END', 'نهاية الاشتراك', {}), ('DAYS_LEFT', 'الأيام المتبقية', {'type': 'NUMBER'}),
                ('JOINED', 'تاريخ الاشتراك', {}), ('LEGAL_HOLD', 'حجز قانوني', {}), ('STATUS_HTML', 'الحالة', {'html': True}),
                ('STATUS_CODE', 'رمز الحالة', {'hidden': True})]
PLAN_LOV = ("select name_ar d, code r from plt_plan where is_active = 'Y' "
            "order by decode(code, 'TRIAL', 0, 'MONTHLY', 1, 'QUARTERLY', 2, 'SEMI_ANNUAL', 3, 'ANNUAL', 4, 5)")


def tenants_where(cond, order):
    return ['select * from ('] + TENANTS_SQL + [f') where {cond} order by {order}']
TENANT_LINK = 'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'

# =============================================================== 1) لوحة المنصة
p = app.page(1, 'Home', 'HOME', 'لوحة المنصة', scheme=PLATFORM)
p.dynamic('مؤشرات المنصة', 10, 'return noona_platform_admin_pkg.platform_summary;', hide_header=True)
ex = p.static('متابعة الاشتراكات', 15)
b_exp = p.button(ex, 10, 'APPLY_EXPIRY', 'تطبيق قواعد الانتهاء الآن (سماح ← قراءة فقط ← تعليق)')
p.button(ex, 20, 'SUBS', 'كل الاشتراكات', redirect=back(8))
p.process(10, 'AFTER_SUBMIT', 'Apply Expiry', [
    'declare l_n number;', 'begin',
    '    l_n := noona_platform_admin_pkg.apply_expiry;',
    "    apex_application.g_print_success_message := 'تم تطبيق قواعد الانتهاء: تغيرت حالة ' || l_n || ' مؤسسة';",
    'end;'], when_button=b_exp)
p.ir('تنتهي خلال 60 يوماً', 20, tenants_where('days_left between 0 and 60', 'days_left'), TENANTS_COLS, link=TENANT_LINK, titled=True, rows=10)
p.ir('منتهية: فترة سماح أو قراءة فقط أو معلقة', 22, tenants_where("days_left < 0 or status_code in ('GRACE_PERIOD', 'READ_ONLY', 'SUSPENDED')", 'days_left'),
     TENANTS_COLS, link=TENANT_LINK, titled=True, rows=10)
p.ir('مشتركون جدد (آخر 30 يوماً)', 24, tenants_where("joined >= to_char(sysdate - 30, 'YYYY-MM-DD')", 'joined desc'), TENANTS_COLS,
     link=TENANT_LINK, titled=True, rows=10)
r = p.ir('المؤسسات المشتركة', 30, TENANTS_SQL, TENANTS_COLS, link=TENANT_LINK, titled=True)
p.button(r, 10, 'NEW_TENANT', 'تجهيز مؤسسة جديدة', hot=True, redirect=back(4), position='RIGHT_OF_IR_SEARCH_BAR')
p.branch(10, back(1) + '&success_msg=#SUCCESS_MSG#')

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
# حدود الاشتراك: المؤسسة تدير بياناتها ومستخدميها بنفسها ضمن هذه الحدود
lm = p.static('حدود الاشتراك (فارغ = بلا حد)', 15)
p.number('P3_MAX_USERS', lm, 10, 'الحد الأقصى للمستخدمين')
p.number('P3_MAX_BRANCHES', lm, 20, 'الحد الأقصى للفروع')
p.number('P3_MAX_COMPANIES', lm, 30, 'الحد الأقصى للشركات')
p.display('P3_USAGE', lm, 40, 'الاستخدام الحالي')
b_lim = p.button(lm, 10, 'SAVE_LIMITS', 'حفظ الحدود', hot=True)
p.process(15, 'BEFORE_HEADER', 'Load Limits', [
    "if :REQUEST is null or :REQUEST <> 'SAVE_LIMITS' then",
    "    :P3_MAX_USERS := noona_platform_admin_pkg.tenant_limit(:P3_ID, 'USERS');",
    "    :P3_MAX_BRANCHES := noona_platform_admin_pkg.tenant_limit(:P3_ID, 'BRANCHES');",
    "    :P3_MAX_COMPANIES := noona_platform_admin_pkg.tenant_limit(:P3_ID, 'COMPANIES');",
    'end if;',
    ":P3_USAGE := noona_platform_admin_pkg.tenant_metric(:P3_ID, 'USERS') || ' مستخدم · '",
    "    || noona_platform_admin_pkg.tenant_metric(:P3_ID, 'BRANCHES') || ' فرع · '",
    "    || noona_platform_admin_pkg.tenant_metric(:P3_ID, 'COMPANIES') || ' شركة';"])
p.process(35, 'AFTER_SUBMIT', 'Save Limits', [
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'USERS', :P3_MAX_USERS);",
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'BRANCHES', :P3_MAX_BRANCHES);",
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'COMPANIES', :P3_MAX_COMPANIES);"],
    when_button=b_lim, success='تم حفظ حدود الاشتراك')

# الاشتراك: الباقة والفترة والتجديد (المؤسسة ترى اشتراكها في إدارة المؤسسة)
sb = p.static('الاشتراك والتجديد', 17)
p.display('P3_SUB_NOW', sb, 5, 'الاشتراك الحالي')
p.select('P3_PLAN', sb, 10, 'الباقة', lov_sql=PLAN_LOV, null_text=None)
p.date('P3_SUB_START', sb, 20, 'بداية الفترة')
p.number('P3_PERIODS', sb, 30, 'عدد الفترات')
p.date('P3_SUB_END', sb, 40, 'أو نهاية محددة (اختياري)')
p.text('P3_SUB_NOTE', sb, 50, 'ملاحظة (رقم العقد / الفاتورة)')
b_sub = p.button(sb, 10, 'SAVE_SUB', 'تسجيل / تعديل الاشتراك', hot=True)
b_ren = p.button(sb, 20, 'RENEW', 'تجديد بعدد الفترات')
p.process(16, 'BEFORE_HEADER', 'Load Subscription', [
    ":P3_SUB_NOW := nvl(noona_platform_admin_pkg.sub_info(:P3_ID, 'PLAN'), 'لم يسجل اشتراك') || nvl2(noona_platform_admin_pkg.sub_info(:P3_ID, 'END'),",
    "    ' · من ' || noona_platform_admin_pkg.sub_info(:P3_ID, 'START') || ' إلى ' || noona_platform_admin_pkg.sub_info(:P3_ID, 'END')",
    "    || ' · المتبقي ' || noona_platform_admin_pkg.sub_info(:P3_ID, 'LEFT') || ' يوماً · ' || noona_ui_pkg.status_label(noona_platform_admin_pkg.sub_info(:P3_ID, 'STATUS')), '');",
    "if :REQUEST is null or :REQUEST not in ('SAVE_SUB', 'RENEW') then",
    "    :P3_PLAN := nvl(noona_platform_admin_pkg.sub_info(:P3_ID, 'PLAN_CODE'), 'ANNUAL');",
    "    :P3_SUB_START := to_char(sysdate, 'YYYY-MM-DD');",
    '    :P3_PERIODS := 1;',
    'end if;'])
p.process(36, 'AFTER_SUBMIT', 'Save Subscription', [
    'declare l_id number;', 'begin',
    "    l_id := noona_platform_admin_pkg.set_subscription(:P3_ID, :P3_PLAN, to_date(:P3_SUB_START, 'YYYY-MM-DD'), nvl(:P3_PERIODS, 1),",
    "                                                      to_date(:P3_SUB_END, 'YYYY-MM-DD'), :P3_SUB_NOTE);",
    'end;'], when_button=b_sub, success='تم تسجيل الاشتراك')
p.process(37, 'AFTER_SUBMIT', 'Renew', [
    'declare l_end date;', 'begin',
    '    l_end := noona_platform_admin_pkg.renew_subscription(:P3_ID, nvl(:P3_PERIODS, 1), :P3_PLAN, :P3_SUB_NOTE);',
    "    apex_application.g_print_success_message := 'تم التجديد حتى ' || to_char(l_end, 'YYYY-MM-DD');",
    'end;'], when_button=b_ren)
p.dynamic('سجل الاشتراك والتجديدات', 18, 'return noona_platform_admin_pkg.subscription_history_html(:P3_ID);')

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
p.number('P4_MAX_USERS', t, 100, 'الحد الأقصى للمستخدمين')
p.number('P4_MAX_BRANCHES', t, 110, 'الحد الأقصى للفروع')
p.number('P4_MAX_COMPANIES', t, 120, 'الحد الأقصى للشركات')
p.select('P4_PLAN', t, 130, 'الباقة', lov_sql=PLAN_LOV, null_text=None)
p.date('P4_SUB_START', t, 140, 'بداية الاشتراك')
p.number('P4_PERIODS', t, 150, 'عدد الفترات')
a = p.static('مسؤول المؤسسة', 20)
p.text('P4_ADMIN_USER', a, 10, 'اسم الدخول', required=True, maxlen=100, width=30)
p.text('P4_ADMIN_NAME', a, 20, 'الاسم الكامل', required=True)
p.text('P4_ADMIN_EMAIL', a, 30, 'البريد الإلكتروني', required=True)
p.password('P4_ADMIN_PASSWORD', a, 40, 'كلمة المرور الأولى', required=True)
b = p.button(a, 10, 'PROVISION', 'تجهيز المؤسسة', hot=True)
p.button(a, 20, 'CANCEL', 'إلغاء', redirect=back(1))
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P4_COUNTRY := nvl(:P4_COUNTRY, 'SA'); :P4_CURRENCY := nvl(:P4_CURRENCY, 'SAR');",
    ":P4_PLAN := nvl(:P4_PLAN, 'ANNUAL'); :P4_SUB_START := nvl(:P4_SUB_START, to_char(sysdate, 'YYYY-MM-DD')); :P4_PERIODS := nvl(:P4_PERIODS, 1);"])
p.process(10, 'AFTER_SUBMIT', 'Provision Tenant', [
    ':P3_ID := noona_platform_pkg.provision_tenant(',
    '    p_tenant_code => :P4_CODE, p_tenant_slug => lower(:P4_SLUG), p_name_ar => :P4_NAME_AR, p_name_en => :P4_NAME_EN,',
    '    p_country_code => :P4_COUNTRY, p_base_currency => :P4_CURRENCY, p_admin_username => :P4_ADMIN_USER,',
    '    p_admin_email => :P4_ADMIN_EMAIL, p_admin_name => :P4_ADMIN_NAME, p_company_code => :P4_COMPANY_CODE,',
    "    p_company_name_ar => :P4_COMPANY_NAME, p_idempotency_key => 'UI-' || upper(:P4_CODE), p_is_trial => nvl(:P4_TRIAL, 'N'));",
    "noona_sec_admin_pkg.platform_set_password(:P4_ADMIN_USER, :P4_ADMIN_PASSWORD, 'كلمة المرور الأولى عند التجهيز');",
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'USERS', :P4_MAX_USERS);",
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'BRANCHES', :P4_MAX_BRANCHES);",
    "noona_platform_admin_pkg.set_tenant_limit(:P3_ID, 'COMPANIES', :P4_MAX_COMPANIES);",
    "if noona_platform_admin_pkg.set_subscription(:P3_ID, case when :P4_TRIAL = 'Y' then 'TRIAL' else :P4_PLAN end,",
    "       to_date(:P4_SUB_START, 'YYYY-MM-DD'), nvl(:P4_PERIODS, 1), null, 'التجهيز') is null then null; end if;",
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

# =============================================================== 8) الاشتراكات
p = app.page(8, 'Subscriptions', 'SUBSCRIPTIONS', 'الاشتراكات', scheme=PLATFORM)
p.ir('اشتراكات المؤسسات', 10, tenants_where('1 = 1', 'days_left nulls first'), TENANTS_COLS, link=TENANT_LINK, rows=100)

# =============================================================== 9) طلبات التسجيل الذاتي
p = app.page(9, 'Signups', 'SIGNUPS', 'طلبات التسجيل الذاتي', scheme=PLATFORM)
f = p.static('تأكيد التحويل أو رفض الطلب', 5, text=(
    '<p class="nn-hint">العميل يسجل بنفسه من صفحة الدخول فتنشأ مؤسسته فوراً بتجربة 14 يوماً. الخطة المدفوعة بالتحويل البنكي '
    'تبقى «بانتظار تأكيد التحويل» حتى تتأكد من وصول المبلغ فتؤكدها هنا، فيتحول اشتراكها للخطة المدفوعة من اليوم.</p>'))
p.select('P9_SIGNUP', f, 10, 'الطلب', lov_sql=(
    "select '#' || id || ' ' || org_name_ar || ' - ' || plan_code || ' - ' || to_char(amount_due, 'FM999,999,990.00') || ' ريال'"
    " || nvl2(payment_ref, ' (' || payment_ref || ')', '') d, id r from plt_signup"
    " where status_code in ('PAYMENT_PENDING', 'STARTED', 'VERIFIED', 'DETAILS') order by decode(status_code, 'PAYMENT_PENDING', 0, 1), id desc"))
p.text('P9_NOTE', f, 20, 'ملاحظة (إلزامية للرفض)', maxlen=400)
b_ok = p.button(f, 10, 'CONFIRM', 'تأكيد وصول التحويل', hot=True)
b_no = p.button(f, 20, 'REJECT', 'رفض الطلب')
p.process(10, 'AFTER_SUBMIT', 'Confirm', 'noona_signup_pkg.confirm_payment(to_number(:P9_SIGNUP), :P9_NOTE); :P9_SIGNUP := null; :P9_NOTE := null;',
          when_button=b_ok, success='تأكد الدفع وتحول الاشتراك للخطة المدفوعة')
p.process(20, 'AFTER_SUBMIT', 'Reject', 'noona_signup_pkg.reject_signup(to_number(:P9_SIGNUP), :P9_NOTE); :P9_SIGNUP := null; :P9_NOTE := null;',
          when_button=b_no, success='رفض الطلب')
p.select('P9_STATUS', f, 30, 'عرض', lov_sql=(
    'STATIC2:بانتظار تأكيد التحويل;PAYMENT_PENDING,تجربة فعالة;PROVISIONED,مدفوع;PAID,غير مكتمل;STARTED,مرفوض;REJECTED'),
    null_text='الكل', submit=True)
p.dynamic('الطلبات', 20, 'return noona_signup_pkg.signups_html(:P9_STATUS);')

# =============================================================== 10) الأسعار وإعدادات التسجيل
p = app.page(10, 'Pricing', 'PRICING', 'الأسعار وإعدادات التسجيل', scheme=PLATFORM)
f = p.static('سعر نظام', 10, text='<p class="nn-hint">السعر الشهري بالريال قبل الضريبة؛ لا يؤثر على الطلبات السابقة (يحفظ السعر وقت الطلب).</p>')
p.select('P10_OFF', f, 10, 'النظام', lov_sql=(
    "select name_ar || ' - ' || to_char(monthly_price, 'FM999,990') || ' ريال' || case when is_active = 'N' then ' (موقوف)' end d, code r"
    " from plt_offering order by sort_order"))
p.number('P10_PRICE', f, 20, 'السعر الشهري الجديد')
p.yesno('P10_ACTIVE', f, 30, 'متاح للتسجيل')
b_pr = p.button(f, 10, 'SAVE_PRICE', 'حفظ السعر', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Price', "noona_signup_pkg.save_offering(:P10_OFF, to_number(:P10_PRICE), nvl(:P10_ACTIVE, 'Y'));",
          when_button=b_pr, success='حفظ السعر')
d = p.static('خصم المدة', 20)
p.select('P10_PLAN', d, 10, 'الخطة', lov_sql=(
    "select name_ar || ' - خصم ' || to_char(discount_pct) || '%' d, code r from plt_plan where code <> 'TRIAL' and is_active = 'Y'"
    " order by decode(code, 'MONTHLY', 1, 'QUARTERLY', 2, 'SEMI_ANNUAL', 3, 'ANNUAL', 4, 9)"))
p.number('P10_PCT', d, 20, 'الخصم %')
b_ds = p.button(d, 10, 'SAVE_DISC', 'حفظ الخصم')
p.process(20, 'AFTER_SUBMIT', 'Discount', 'noona_signup_pkg.save_plan_discount(:P10_PLAN, to_number(:P10_PCT));', when_button=b_ds, success='حفظ الخصم')
g = p.static('إعدادات التسجيل', 30, text=(
    '<p class="nn-hint">وضع الرموز DEMO يعرض رمز التحقق على الشاشة (للتجربة المحلية)، وEMAIL يرسله بالبريد عبر APEX '
    '(يتطلب ضبط SMTP في APEX). رسائل الجوال تحتاج ربط مزود رسائل.</p>'))
p.select('P10_KEY', g, 10, 'الإعداد', lov_sql=(
    "select name_ar || ': ' || substr(default_value, 1, 60) d, setting_key r from plt_setting_def where setting_key like 'SIGNUP.%' order by setting_key"),
    submit=True)
p.textarea('P10_VALUE', g, 20, 'القيمة', rows=2)
b_st = p.button(g, 10, 'SAVE_SET', 'حفظ الإعداد')
p.process(5, 'BEFORE_HEADER', 'Load setting', ':P10_VALUE := noona_signup_pkg.setting(:P10_KEY);', when=':P10_KEY is not null')
p.process(30, 'AFTER_SUBMIT', 'Setting', 'noona_signup_pkg.save_setting(:P10_KEY, :P10_VALUE);', when_button=b_st, success='حفظ الإعداد')
p.dynamic('الأنظمة كما يراها العميل', 40, 'return noona_signup_pkg.offerings_html;')
p.dynamic('مثال تسعير: المالية والمخزون، 5 مستخدمين، سنوي', 50, "return noona_signup_pkg.quote_html('FIN:SCM', 5, 'ANNUAL');")

app.nav_item('لوحة المنصة', 1, 'fa-server', 10)
app.nav_item('طلبات التسجيل', 9, 'fa-user-plus', 12)
app.nav_item('الأسعار والتسجيل', 10, 'fa-tags', 13)
app.nav_item('الاشتراكات', 8, 'fa-calendar-check-o', 15)
app.nav_item('تجهيز مؤسسة', 4, 'fa-plus-circle', 20)
app.nav_item('سجل تدقيق المنصة', 5, 'fa-shield', 30)
app.nav_item('وحدات النظام', 6, 'fa-cubes', 40)
app.nav_item('مسؤولو المنصة', 7, 'fa-user-secret', 50)

app.finalize()
print('NOONA_PLATFORM built:', len(app.pages), 'pages')
