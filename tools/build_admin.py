"""NOONA_ADMIN (إدارة المؤسسة) - يبني التطبيق من القالب عبر tools/apexgen.py
الاستخدام: python3 tools/build_admin.py   ->  apex/NOONA_ADMIN/f123
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_ADMIN/f123'),
          app_id=123, alias='NOONA_ADMIN', name='NOONA Administration', id_base=91820262000000000)
app.wire_security()
app.add_branding()
ADMIN = app.schemes['admin']
# مسؤول المؤسسة أو مسؤول الشركة (COMPANY_ADMIN): المستخدمون والفروع واشتراك المؤسسة، كل في نطاقه
ORG = app.add_scheme('noona_org_admin', app.id(), 'NOONA - Organisation Admin', "return noona_sec_admin_pkg.is_org_admin = 'Y';",
                     'هذه الصفحة لمسؤول المؤسسة أو مسؤول الشركة / Administrators only')
TENANT_ONLY = "noona_sec_admin_pkg.admin_level = 'TENANT'"
# الشركات التي يديرها المستخدم الحالي (مسؤول المؤسسة: كلها)
ADMIN_CO_LOV = ("select nvl(trade_name_ar, legal_name_ar) d, id r from org_company where status_code not in ('CLOSED', 'ARCHIVED') "
                "and noona_sec_admin_pkg.can_admin_company(id) = 'Y' order by 1")
HOME = 'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'

def back(page_no):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:::'

STATUS_HTML = "noona_ui_pkg.status_badge(status_code) as status_html"

# =============================================================== 1) لوحة الإدارة
p = app.page(1, 'Home', 'HOME', 'إدارة المؤسسة', scheme=ORG)
p.dynamic('لوحة الإدارة', 10, 'return noona_ui_pkg.admin_summary(p_session => :APP_SESSION);', hide_header=True, condition=TENANT_ONLY)
p.dynamic('اشتراك المؤسسة', 5, 'return noona_sec_admin_pkg.subscription_html;')
p.ir('الشركات', 20, [
    'select id, code, nvl(trade_name_ar, legal_name_ar) as company_name, country_code, functional_currency,',
    f'       {STATUS_HTML}',
    "  from org_company where noona_sec_admin_pkg.can_admin_company(id) = 'Y'"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}),
     ('CODE', 'الرمز', {}), ('COMPANY_NAME', 'الشركة', {}), ('COUNTRY_CODE', 'الدولة', {}),
     ('FUNCTIONAL_CURRENCY', 'العملة', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:#ID#')

# =============================================================== 10) الشركات
p = app.page(10, 'Companies', 'COMPANIES', 'الشركات', scheme=ADMIN)
r = p.ir('الشركات', 10, [
    'select c.id, c.code, c.legal_name_ar, c.legal_name_en, c.trade_name_ar, c.country_code, c.functional_currency,',
    '       (select count(*) from org_branch b where b.company_id = c.id and b.status_code = \'ACTIVE\') as branches,',
    '       noona_ui_pkg.status_badge(c.status_code) as status_html, c.activated_at',
    '  from org_company c'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}),
     ('CODE', 'الرمز', {}), ('LEGAL_NAME_AR', 'الاسم القانوني', {}), ('LEGAL_NAME_EN', 'الاسم بالإنجليزية', {}),
     ('TRADE_NAME_AR', 'الاسم التجاري', {}), ('COUNTRY_CODE', 'الدولة', {}), ('FUNCTIONAL_CURRENCY', 'العملة', {}),
     ('BRANCHES', 'فروع نشطة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True}),
     ('ACTIVATED_AT', 'تاريخ التفعيل', {'type': 'DATE'})],
    link='f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:#ID#')
p.button(r, 10, 'CREATE', 'شركة جديدة', hot=True, redirect='f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::', position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 11) الشركة
p = app.page(11, 'Company', 'COMPANY', 'الشركة', scheme=ADMIN)
info = p.static('بيانات الشركة', 10)
p.hidden('P11_ID', info, 1)
p.text('P11_CODE', info, 10, 'الرمز', required=True, maxlen=50, width=20)
p.text('P11_LEGAL_NAME_AR', info, 20, 'الاسم القانوني بالعربية', required=True)
p.text('P11_LEGAL_NAME_EN', info, 30, 'الاسم القانوني بالإنجليزية')
p.text('P11_TRADE_NAME_AR', info, 40, 'الاسم التجاري')
p.select('P11_COUNTRY_CODE', info, 50, 'الدولة', lov_name='NOONA_COUNTRIES', required=True)
p.select('P11_FUNCTIONAL_CURRENCY', info, 60, 'العملة الوظيفية', lov_name='NOONA_CURRENCIES', required=True)
p.display('P11_STATUS', info, 70, 'الحالة')
b_create = p.button(info, 10, 'CREATE', 'إنشاء الشركة', hot=True, condition=':P11_ID is null')
b_save = p.button(info, 20, 'SAVE', 'حفظ التعديلات', hot=True, condition=':P11_ID is not null')
p.button(info, 30, 'BACK', 'رجوع', redirect=back(10))
p.process(10, 'BEFORE_HEADER', 'Load Company', [
    'if :P11_ID is not null then',
    '    select code, legal_name_ar, legal_name_en, trade_name_ar, country_code, functional_currency,',
    '           noona_ui_pkg.status_label(status_code)',
    '      into :P11_CODE, :P11_LEGAL_NAME_AR, :P11_LEGAL_NAME_EN, :P11_TRADE_NAME_AR, :P11_COUNTRY_CODE,',
    '           :P11_FUNCTIONAL_CURRENCY, :P11_STATUS',
    '      from org_company where id = :P11_ID;',
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Create Company', [
    ':P11_ID := noona_platform_pkg.create_company(',
    '    p_code => :P11_CODE, p_legal_name_ar => :P11_LEGAL_NAME_AR, p_legal_name_en => :P11_LEGAL_NAME_EN,',
    '    p_country_code => :P11_COUNTRY_CODE, p_functional_currency => :P11_FUNCTIONAL_CURRENCY);',
    'update org_company set trade_name_ar = :P11_TRADE_NAME_AR where id = :P11_ID;'],
    when_button=b_create, success='تم إنشاء الشركة؛ أكمل الفروع ثم شغّل فحوص التفعيل')
p.process(20, 'AFTER_SUBMIT', 'Save Company', [
    'noona_security_pkg.assert_permission(\'ORG_COMPANY.UPDATE\', :P11_ID);',
    'update org_company',
    '   set legal_name_ar = :P11_LEGAL_NAME_AR, legal_name_en = :P11_LEGAL_NAME_EN, trade_name_ar = :P11_TRADE_NAME_AR',
    ' where id = :P11_ID;'],
    when_button=b_save, success='تم حفظ بيانات الشركة')

# شعار المشترك: يظهر في ترويسة التطبيقات وفي ترويسة التقارير المطبوعة
lg = p.static('شعار الشركة (الترويسة والتقارير)', 15, condition=':P11_ID is not null')
p.file('P11_LOGO', lg, 10, 'ملف الشعار')
b_logo = p.button(lg, 10, 'UPLOAD_LOGO', 'رفع الشعار', hot=True)
b_nologo = p.button(lg, 20, 'REMOVE_LOGO', 'إزالة الشعار')
p.dynamic('معاينة الشعار وترويسة التقارير', 16, [
    'declare',
    '    l_uri clob := noona_brand_pkg.logo_data_uri(:P11_ID);',
    'begin',
    '    return case when l_uri is null',
    "                then '<div class=\"nn-empty\">لا يوجد شعار بعد؛ تظهر التقارير باسم الشركة فقط</div>'",
    "           end || noona_brand_pkg.report_header('معاينة ترويسة التقارير', :P11_ID);",
    'end;'], condition=':P11_ID is not null')
p.process(25, 'AFTER_SUBMIT', 'Upload Logo', [
    'declare',
    '    l_blob blob;',
    '    l_name varchar2(400);',
    '    l_doc  number;',
    'begin',
    '    if :P11_LOGO is null then',
    "        raise_application_error(-20500, 'NOONA-BRD-003: اختر ملف الشعار أولاً');",
    '    end if;',
    '    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P11_LOGO;',
    '    l_doc := noona_brand_pkg.set_company_logo(p_company_id => :P11_ID, p_file_name => l_name, p_content => l_blob);',
    'end;'], when_button=b_logo, success='تم حفظ الشعار؛ سيظهر في الترويسة والتقارير')
p.process(26, 'AFTER_SUBMIT', 'Remove Logo', 'noona_brand_pkg.remove_company_logo(p_company_id => :P11_ID);',
          when_button=b_nologo, success='تمت إزالة الشعار')

chk = p.ir('فحوص التفعيل', 20, [
    'select id, noona_ui_pkg.code_label(check_code) as check_code, noona_ui_pkg.status_badge(status_code) as status_html, result_info, waived_by, checked_at',
    '  from org_company_check where company_id = :P11_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CHECK_CODE', 'الفحص', {}),
     ('STATUS_HTML', 'النتيجة', {'html': True}), ('RESULT_INFO', 'التفاصيل', {}), ('WAIVED_BY', 'استثناء بواسطة', {}),
     ('CHECKED_AT', 'وقت الفحص', {'type': 'DATE'})], titled=True)
act = p.static('إجراءات التفعيل', 30)
p.select('P11_WAIVE_CODE', act, 10, 'استثناء فحص فاشل',
         lov_sql="select noona_ui_pkg.code_label(check_code) d, check_code r from org_company_check where company_id = :P11_ID and status_code = 'FAILED' order by 1")
p.textarea('P11_REASON', act, 20, 'السبب (إلزامي للاستثناء وتغيير الحالة)', rows=2)
p.select('P11_NEW_STATUS', act, 30, 'تغيير الحالة إلى', lov_sql=(
    "select noona_ui_pkg.status_label(column_value) d, column_value r from table(sys.odcivarchar2list("
    "'UNDER_CONFIGURATION','READY_FOR_REVIEW','SUSPENDED','INACTIVE','ACTIVE','CLOSURE_REQUESTED','UNDER_LIQUIDATION',"
    "'TRANSACTIONS_BLOCKED','FINANCIALLY_CLOSED','LEGALLY_CLOSED','CLOSED','ARCHIVED'))"))
b_run = p.button(act, 10, 'RUN_CHECKS', 'تشغيل الفحوص', condition=':P11_ID is not null')
b_waive = p.button(act, 20, 'WAIVE', 'استثناء الفحص', condition=':P11_ID is not null')
b_activate = p.button(act, 30, 'ACTIVATE', 'تفعيل الشركة', hot=True, condition=':P11_ID is not null')
b_status = p.button(act, 40, 'CHANGE_STATUS', 'تغيير الحالة', condition=':P11_ID is not null')
p.process(30, 'AFTER_SUBMIT', 'Run Checks', [
    'declare l_failed number;',
    'begin',
    '    l_failed := noona_platform_pkg.run_activation_checks(:P11_ID);',
    "    apex_application.g_print_success_message := case when l_failed = 0 then 'نجحت كل الفحوص؛ الشركة جاهزة للتفعيل'",
    "                                                     else 'عدد الفحوص الفاشلة: ' || l_failed end;",
    'end;'], when_button=b_run)
p.process(40, 'AFTER_SUBMIT', 'Waive Check',
          'noona_platform_pkg.waive_check(p_company_id => :P11_ID, p_check_code => :P11_WAIVE_CODE, p_reason => :P11_REASON);',
          when_button=b_waive, success='تم استثناء الفحص')
p.process(50, 'AFTER_SUBMIT', 'Activate', 'noona_platform_pkg.activate_company(p_company_id => :P11_ID);',
          when_button=b_activate, success='تم تفعيل الشركة')
p.process(60, 'AFTER_SUBMIT', 'Change Status',
          'noona_platform_pkg.change_company_status(p_company_id => :P11_ID, p_new_status => :P11_NEW_STATUS, p_reason => :P11_REASON);',
          when_button=b_status, success='تم تغيير حالة الشركة')
brs = p.ir('فروع الشركة', 40, [
    'select id, code, name_ar, noona_ui_pkg.code_label(branch_type) as branch_type, noona_ui_pkg.code_label(is_head_office) as is_head_office,',
    '       noona_ui_pkg.status_badge(status_code) as status_html',
    '  from org_branch where company_id = :P11_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفرع', {}),
     ('BRANCH_TYPE', 'النوع', {}), ('IS_HEAD_OFFICE', 'رئيسي', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_ID:#ID#', titled=True)
p.button(brs, 10, 'ADD_BRANCH', 'فرع جديد', redirect='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_COMPANY_ID:&P11_ID.',
         position='RIGHT_OF_IR_SEARCH_BAR', condition=':P11_ID is not null')
p.branch(10, 'f?p=&APP_ID.:11:&SESSION.::&DEBUG.::P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 12) الفروع
p = app.page(12, 'Branches', 'BRANCHES', 'الفروع', scheme=ORG)
r = p.ir('الفروع', 10, [
    'select b.id, b.code, b.name_ar, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, noona_ui_pkg.code_label(b.branch_type) as branch_type,',
    '       noona_ui_pkg.code_label(b.is_head_office) as is_head_office, b.country_code, b.currency_code, noona_ui_pkg.status_badge(b.status_code) as status_html',
    "  from org_branch b join org_company c on c.id = b.company_id where noona_sec_admin_pkg.can_admin_company(b.company_id) = 'Y'"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفرع', {}),
     ('COMPANY_NAME', 'الشركة', {}), ('BRANCH_TYPE', 'النوع', {}), ('IS_HEAD_OFFICE', 'رئيسي', {}),
     ('COUNTRY_CODE', 'الدولة', {}), ('CURRENCY_CODE', 'العملة', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_ID:#ID#')
p.button(r, 10, 'CREATE', 'فرع جديد', hot=True, redirect='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13::', position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 13) الفرع
p = app.page(13, 'Branch', 'BRANCH', 'الفرع', scheme=ORG)
info = p.static('بيانات الفرع', 10)
p.hidden('P13_ID', info, 1)
p.select('P13_COMPANY_ID', info, 10, 'الشركة', lov_sql=ADMIN_CO_LOV, required=True)
p.text('P13_CODE', info, 20, 'الرمز', required=True, maxlen=50, width=20)
p.text('P13_NAME_AR', info, 30, 'الاسم بالعربية', required=True)
p.text('P13_NAME_EN', info, 40, 'الاسم بالإنجليزية')
p.select('P13_BRANCH_TYPE', info, 50, 'نوع الفرع', required=True, lov_sql=(
    'STATIC2:مركز رئيسي;HEAD_OFFICE,فرع;BRANCH,مستودع;WAREHOUSE,معرض;SHOWROOM,مصنع;FACTORY,مكتب موقع;SITE_OFFICE'))
p.yesno('P13_IS_HEAD_OFFICE', info, 60, 'مركز رئيسي للشركة')
p.select('P13_COUNTRY_CODE', info, 70, 'الدولة', lov_name='NOONA_COUNTRIES')
p.display('P13_STATUS', info, 80, 'الحالة')
b_create = p.button(info, 10, 'CREATE', 'إنشاء الفرع', hot=True, condition=':P13_ID is null')
b_save = p.button(info, 20, 'SAVE', 'حفظ التعديلات', hot=True, condition=':P13_ID is not null')
p.button(info, 30, 'BACK', 'رجوع', redirect=back(12))
p.process(10, 'BEFORE_HEADER', 'Load Branch', [
    'if :P13_ID is not null then',
    '    select company_id, code, name_ar, name_en, branch_type, is_head_office, country_code,',
    '           noona_ui_pkg.status_label(status_code)',
    '      into :P13_COMPANY_ID, :P13_CODE, :P13_NAME_AR, :P13_NAME_EN, :P13_BRANCH_TYPE, :P13_IS_HEAD_OFFICE,',
    '           :P13_COUNTRY_CODE, :P13_STATUS',
    "      from org_branch where id = :P13_ID and noona_sec_admin_pkg.can_admin_company(company_id) = 'Y';",
    "elsif :P13_IS_HEAD_OFFICE is null then",
    "    :P13_IS_HEAD_OFFICE := 'N';",
    "    -- الشركة الممررة من بطاقة الشركة تبقى؛ وإلا تختار تلقائياً إن كانت شركة واحدة فقط",
    "    if :P13_COMPANY_ID is null then",
    "        select case when count(*) = 1 then min(id) end into :P13_COMPANY_ID from org_company",
    "         where status_code not in ('CLOSED', 'ARCHIVED') and noona_sec_admin_pkg.can_admin_company(id) = 'Y';",
    "    end if;",
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Create Branch', [
    ':P13_ID := noona_platform_pkg.create_branch(',
    '    p_company_id => :P13_COMPANY_ID, p_code => :P13_CODE, p_name_ar => :P13_NAME_AR, p_name_en => :P13_NAME_EN,',
    '    p_branch_type => :P13_BRANCH_TYPE, p_is_head_office => :P13_IS_HEAD_OFFICE, p_country_code => :P13_COUNTRY_CODE);'],
    when_button=b_create, success='تم إنشاء الفرع')
p.process(20, 'AFTER_SUBMIT', 'Save Branch', [
    "noona_security_pkg.assert_permission('ORG_BRANCH.UPDATE', :P13_COMPANY_ID);",
    'update org_branch set name_ar = :P13_NAME_AR, name_en = :P13_NAME_EN, branch_type = :P13_BRANCH_TYPE',
    " where id = :P13_ID and noona_sec_admin_pkg.can_admin_company(company_id) = 'Y';",
    "if sql%rowcount = 0 then raise_application_error(-20100, 'NOONA-SEC-260: لا تملك إدارة هذا الفرع'); end if;"],
    when_button=b_save, success='تم حفظ بيانات الفرع')
cl = p.static('إغلاق الفرع', 20)
p.textarea('P13_CLOSE_REASON', cl, 10, 'سبب الإغلاق', rows=2)
b_close = p.button(cl, 10, 'CLOSE_BRANCH', 'إغلاق الفرع', condition=":P13_ID is not null")
p.process(30, 'AFTER_SUBMIT', 'Close Branch',
          'noona_platform_pkg.close_branch(p_branch_id => :P13_ID, p_reason => :P13_CLOSE_REASON);',
          when_button=b_close, success='تم إغلاق الفرع')
p.branch(10, 'f?p=&APP_ID.:13:&SESSION.::&DEBUG.::P13_ID:&P13_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== التنقل
app.nav_item('لوحة الإدارة', 1, 'fa-dashboard', 10)
org = app.nav_item('الشركات والفروع', None, 'fa-building-o', 20)
app.nav_item('الشركات', 10, 'fa-building', 21, parent=org, scheme=ADMIN)
app.nav_item('الفروع', 12, 'fa-map-marker', 22, parent=org)


# ######################################################################## المرحلة 2: الهيكل التنظيمي
STRUCT_LOV = ("select s.code || ' - ' || s.name_ar || ' (' || nvl(c.trade_name_ar, c.legal_name_ar) || ')' d, s.id r "
              "from org_structure s join org_company c on c.id = s.company_id where s.is_active = 'Y' order by 1")
VERSION_LOV = ("select 'إصدار ' || version_no || ' - ' || noona_ui_pkg.status_label(status_code) d, id r "
               "from org_structure_version where structure_id = :P21_ID order by version_no desc")

# =============================================================== 20) الهياكل
p = app.page(20, 'Structures', 'STRUCTURES', 'الهياكل التنظيمية', scheme=ADMIN)
r = p.ir('الهياكل التنظيمية', 10, [
    'select s.id, s.code, s.name_ar, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, noona_ui_pkg.code_label(s.structure_type) as structure_type,',
    "       noona_ui_pkg.code_label(s.is_primary) as is_primary,",
    "       (select max(v.version_no) from org_structure_version v where v.structure_id = s.id and v.status_code = 'ACTIVE') as active_version,",
    '       (select count(*) from org_structure_version v where v.structure_id = s.id) as versions',
    '  from org_structure s join org_company c on c.id = s.company_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الهيكل', {}),
     ('COMPANY_NAME', 'الشركة', {}), ('STRUCTURE_TYPE', 'النوع', {}), ('IS_PRIMARY', 'أساسي', {}),
     ('ACTIVE_VERSION', 'الإصدار الساري', {'type': 'NUMBER'}), ('VERSIONS', 'عدد الإصدارات', {'type': 'NUMBER'})],
    link='f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#')
f = p.static('هيكل جديد', 20)
p.select('P20_COMPANY_ID', f, 10, 'الشركة', lov_name='NOONA_COMPANIES', required=True)
p.text('P20_CODE', f, 20, 'الرمز', required=True, maxlen=50, width=20)
p.text('P20_NAME_AR', f, 30, 'الاسم', required=True)
p.select('P20_TYPE', f, 40, 'النوع', required=True, null_text=None, lov_sql=(
    'STATIC2:إداري;ADMINISTRATIVE,مالي;FINANCIAL,تشغيلي;OPERATIONAL,مشروعات;PROJECT,مراسلات;CORRESPONDENCE,تقارير;REPORTING,مصفوفي;MATRIX'))
p.yesno('P20_IS_PRIMARY', f, 50, 'الهيكل الإداري الأساسي للشركة')
b = p.button(f, 10, 'CREATE', 'إنشاء الهيكل', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Create Structure', [
    'declare l_id number; l_ver number;',
    'begin',
    '    l_id := noona_org_pkg.create_structure(p_company_id => :P20_COMPANY_ID, p_code => :P20_CODE, p_name_ar => :P20_NAME_AR,',
    '                                           p_structure_type => :P20_TYPE, p_is_primary => nvl(:P20_IS_PRIMARY, \'N\'));',
    "    l_ver := noona_org_pkg.new_version(l_id, 'الإصدار الأول');",
    '    :P21_ID := l_id;',
    'end;'], when_button=b, success='تم إنشاء الهيكل وإصداره الأول (مسودة)؛ أضف الوحدات ثم فعّل الإصدار')
p.branch(10, 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 21) الهيكل: الإصدارات والوحدات
p = app.page(21, 'Structure', 'STRUCTURE', 'الهيكل التنظيمي', scheme=ADMIN)
hdr = p.static('الإصدار', 10)
p.hidden('P21_ID', hdr, 1)
p.select('P21_VERSION_ID', hdr, 10, 'الإصدار المعروض', lov_sql=VERSION_LOV, null_text=None)
p.display('P21_VERSION_STATUS', hdr, 20, 'حالة الإصدار')
b_show = p.button(hdr, 10, 'SHOW', 'عرض')
b_new = p.button(hdr, 20, 'NEW_VERSION', 'إصدار جديد (نسخ الساري)')
b_act = p.button(hdr, 30, 'ACTIVATE', 'تفعيل هذا الإصدار', hot=True)
p.button(hdr, 40, 'BACK', 'رجوع', redirect=back(20))
p.process(10, 'BEFORE_HEADER', 'Default Version', [
    'if :P21_VERSION_ID is null then',
    "    select max(id) keep (dense_rank first order by case status_code when 'DRAFT' then 1 when 'ACTIVE' then 2 else 3 end, version_no desc)",
    '      into :P21_VERSION_ID from org_structure_version where structure_id = :P21_ID;',
    'end if;',
    'select max(noona_ui_pkg.status_label(status_code)) into :P21_VERSION_STATUS from org_structure_version where id = :P21_VERSION_ID;'])
p.process(10, 'AFTER_SUBMIT', 'New Version', [
    ":P21_VERSION_ID := noona_org_pkg.new_version(:P21_ID, 'إعادة هيكلة');"],
    when_button=b_new, success='تم إنشاء إصدار جديد (مسودة) منسوخ من الإصدار الساري')
p.process(20, 'AFTER_SUBMIT', 'Activate Version', 'noona_org_pkg.activate_version(:P21_VERSION_ID);',
          when_button=b_act, success='تم تفعيل الإصدار؛ انتقلت المناصب إلى وحداته')
p.ir('وحدات الإصدار', 20, [
    "select u.id, replace(rpad(' ', (u.hier_level - 1) * 4, ' '), ' ', '&nbsp;') || case when u.hier_level > 1 then '&#8627; ' end || noona_ui_pkg.esc(u.name_ar) as unit_name,",
    "       u.code, noona_ui_pkg.code_label(u.unit_type) as unit_type, u.hier_path,",
    "       (select p.name_ar from org_position p where p.id = u.head_position_id) as head_position,",
    "       (select count(*) from org_position p where p.org_unit_id = u.id and p.status_code not in ('CANCELLED','CLOSED')) as positions,",
    '       noona_ui_pkg.status_badge(u.status_code) as status_html',
    '  from org_unit u where u.structure_version_id = :P21_VERSION_ID',
    ' order by u.hier_path'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('UNIT_NAME', 'الوحدة', {'html': True}), ('CODE', 'الرمز', {}),
     ('UNIT_TYPE', 'النوع', {}), ('HIER_PATH', 'المسار', {}), ('HEAD_POSITION', 'منصب الرئيس', {}),
     ('POSITIONS', 'المناصب', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], titled=True)
f = p.static('إضافة وحدة إلى الإصدار (مسودة فقط)', 30)
p.text('P21_UNIT_CODE', f, 10, 'رمز الوحدة', maxlen=50, width=20)
p.text('P21_UNIT_NAME', f, 20, 'اسم الوحدة')
p.select('P21_UNIT_TYPE', f, 30, 'نوع الوحدة', null_text=None, lov_sql=(
    'STATIC2:إدارة عليا;EXECUTIVE,قطاع;SECTOR,إدارة;DEPARTMENT,قسم;SECTION,وحدة;UNIT,فريق;TEAM,مكتب;OFFICE,لجنة;COMMITTEE'))
p.select('P21_PARENT_CODE', f, 40, 'الوحدة الأم', lov_sql=(
    "select lpad(' ', (hier_level - 1) * 4, ' ') || name_ar d, code r from org_unit where structure_version_id = :P21_VERSION_ID order by hier_path"),
    null_text='- بدون (وحدة جذرية) -')
b_add = p.button(f, 10, 'ADD_UNIT', 'إضافة الوحدة', hot=True)
p.process(30, 'AFTER_SUBMIT', 'Add Unit', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_org_pkg.add_unit(p_version_id => :P21_VERSION_ID, p_code => :P21_UNIT_CODE, p_name_ar => :P21_UNIT_NAME,',
    '                                   p_unit_type => :P21_UNIT_TYPE, p_parent_code => :P21_PARENT_CODE);',
    '    :P21_UNIT_CODE := null; :P21_UNIT_NAME := null;',
    'end;'], when_button=b_add, success='تمت إضافة الوحدة')
p.branch(10, 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID,P21_VERSION_ID:&P21_ID.,&P21_VERSION_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 22) المناصب
p = app.page(22, 'Positions', 'POSITIONS', 'المناصب', scheme=ADMIN)
p.ir('المناصب', 10, [
    'select p.id, p.code, p.name_ar, u.name_ar as unit_name, j.name_ar as job_name, noona_ui_pkg.code_label(p.is_head) as is_head,',
    '       r.name_ar as reports_to, p.capacity_fte,',
    '       (select nvl(us.display_name, us.username) from sec_user_membership m join sec_user us on us.id = m.user_id',
    '         where m.id = noona_org_pkg.position_holder(p.id)) as holder,',
    '       noona_ui_pkg.status_badge(p.status_code) as status_html',
    '  from org_position p join org_unit u on u.id = p.org_unit_id',
    '  left join org_job j on j.id = p.job_id left join org_position r on r.id = p.reports_to_position_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المنصب', {}),
     ('UNIT_NAME', 'الوحدة', {}), ('JOB_NAME', 'الوظيفة', {}), ('IS_HEAD', 'رئيس الوحدة', {}),
     ('REPORTS_TO', 'يرفع إلى', {}), ('CAPACITY_FTE', 'السعة', {'type': 'NUMBER'}), ('HOLDER', 'الشاغل', {}),
     ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('منصب جديد', 20)
p.select('P22_UNIT_ID', f, 10, 'الوحدة', required=True, lov_sql=(
    "select u.name_ar || ' - ' || s.name_ar || ' (إصدار ' || v.version_no || ')' d, u.id r from org_unit u "
    "join org_structure_version v on v.id = u.structure_version_id join org_structure s on s.id = v.structure_id "
    "where u.status_code in ('DRAFT','ACTIVE') and v.status_code in ('DRAFT','ACTIVE') order by s.name_ar, u.hier_path"))
p.select('P22_JOB_ID', f, 20, 'الوظيفة', required=True, lov_sql="select name_ar d, id r from org_job where status_code = 'ACTIVE' order by 1")
p.text('P22_CODE', f, 30, 'رمز المنصب', required=True, maxlen=50, width=20)
p.text('P22_NAME_AR', f, 40, 'اسم المنصب', required=True)
p.yesno('P22_IS_HEAD', f, 50, 'رئيس الوحدة')
p.select('P22_REPORTS_TO', f, 60, 'يرفع إلى', lov_sql=(
    "select name_ar || ' (' || code || ')' d, id r from org_position where status_code not in ('CANCELLED','CLOSED') order by 1"))
p.number('P22_CAPACITY', f, 70, 'السعة (FTE)')
b = p.button(f, 10, 'CREATE', 'إنشاء المنصب', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P22_IS_HEAD := nvl(:P22_IS_HEAD, 'N'); :P22_CAPACITY := nvl(:P22_CAPACITY, 1);"])
p.process(10, 'AFTER_SUBMIT', 'Create Position', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_org_pkg.create_position(p_unit_id => :P22_UNIT_ID, p_job_id => :P22_JOB_ID, p_code => :P22_CODE,',
    '        p_name_ar => :P22_NAME_AR, p_is_head => :P22_IS_HEAD, p_reports_to_id => :P22_REPORTS_TO,',
    '        p_capacity_fte => nvl(:P22_CAPACITY, 1));',
    'end;'], when_button=b, success='تم إنشاء المنصب')
jf = p.static('وظيفة جديدة (تصنيف وظيفي)', 30)
p.text('P22_JOB_CODE', jf, 10, 'رمز الوظيفة', maxlen=50, width=20)
p.text('P22_JOB_NAME', jf, 20, 'اسم الوظيفة')
bj = p.button(jf, 10, 'CREATE_JOB', 'إضافة الوظيفة')
p.process(20, 'AFTER_SUBMIT', 'Create Job', [
    "noona_security_pkg.assert_permission('ORG_JOB.CREATE');",
    "insert into org_job (code, name_ar, status_code) values (upper(:P22_JOB_CODE), :P22_JOB_NAME, 'ACTIVE');"],
    when_button=bj, success='تمت إضافة الوظيفة')
p.branch(10, 'f?p=&APP_ID.:22:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#')

# =============================================================== 23) التعيينات
p = app.page(23, 'Assignments', 'ASSIGNMENTS', 'تعيين الموظفين على المناصب', scheme=ADMIN)
p.ir('التعيينات', 10, [
    'select a.id, pt.display_name_ar as employee_name, e.employee_no, p.name_ar as position_name, u.name_ar as unit_name,',
    '       noona_ui_pkg.code_label(a.assignment_type) as assignment_type, a.fte_pct, a.effective_from, a.effective_to, noona_ui_pkg.status_badge(a.status_code) as status_html',
    '  from org_position_assignment a join hr_employment em on em.id = a.employment_id',
    '  join hr_employee e on e.id = em.employee_id join pty_party pt on pt.id = e.person_party_id',
    '  join org_position p on p.id = a.position_id join org_unit u on u.id = p.org_unit_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('EMPLOYEE_NAME', 'الموظف', {}), ('EMPLOYEE_NO', 'الرقم الوظيفي', {}),
     ('POSITION_NAME', 'المنصب', {}), ('UNIT_NAME', 'الوحدة', {}), ('ASSIGNMENT_TYPE', 'نوع التعيين', {}),
     ('FTE_PCT', 'النسبة %', {'type': 'NUMBER'}), ('EFFECTIVE_FROM', 'من', {'type': 'DATE'}),
     ('EFFECTIVE_TO', 'إلى', {'type': 'DATE'}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('تعيين جديد', 20)
p.select('P23_EMPLOYMENT_ID', f, 10, 'الموظف', required=True, lov_sql=(
    "select pt.display_name_ar || ' (' || e.employee_no || ')' d, em.id r from hr_employment em "
    "join hr_employee e on e.id = em.employee_id join pty_party pt on pt.id = e.person_party_id "
    "where em.status_code in ('PENDING','ACTIVE') order by 1"))
p.select('P23_POSITION_ID', f, 20, 'المنصب', required=True, lov_sql=(
    "select name_ar || ' (' || code || ') - ' || noona_ui_pkg.status_label(status_code) d, id r from org_position "
    "where status_code not in ('CANCELLED','CLOSED','FROZEN','PLANNED') order by 1"))
p.select('P23_TYPE', f, 30, 'نوع التعيين', null_text=None, lov_sql=(
    'STATIC2:أساسي;PRIMARY,إضافي;ADDITIONAL,بالإنابة;ACTING,إعارة;SECONDMENT,مؤقت;TEMPORARY'))
p.date('P23_FROM', f, 40, 'من تاريخ', required=True)
p.number('P23_FTE', f, 50, 'نسبة التفرغ %')
b = p.button(f, 10, 'ASSIGN', 'تعيين', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P23_FROM := nvl(:P23_FROM, to_char(sysdate, 'YYYY-MM-DD')); :P23_FTE := nvl(:P23_FTE, 100);"])
p.process(10, 'AFTER_SUBMIT', 'Assign', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_org_pkg.assign_position(p_employment_id => :P23_EMPLOYMENT_ID, p_position_id => :P23_POSITION_ID,',
    "        p_assignment_type => :P23_TYPE, p_from => to_date(:P23_FROM, 'YYYY-MM-DD'), p_fte_pct => nvl(:P23_FTE, 100));",
    'end;'], when_button=b, success='تم التعيين')
ef = p.static('إنهاء تعيين', 30)
p.select('P23_END_ID', ef, 10, 'التعيين', lov_sql=(
    "select pt.display_name_ar || ' - ' || p.name_ar d, a.id r from org_position_assignment a "
    "join hr_employment em on em.id = a.employment_id join hr_employee e on e.id = em.employee_id "
    "join pty_party pt on pt.id = e.person_party_id join org_position p on p.id = a.position_id "
    "where a.status_code in ('EFFECTIVE','SCHEDULED') order by 1"))
p.date('P23_END_DATE', ef, 20, 'تاريخ الانتهاء')
p.textarea('P23_END_REASON', ef, 30, 'السبب', rows=2)
be = p.button(ef, 10, 'END_ASSIGNMENT', 'إنهاء التعيين')
p.process(20, 'AFTER_SUBMIT', 'End Assignment', [
    "noona_org_pkg.end_assignment(p_assignment_id => :P23_END_ID, p_end_date => to_date(:P23_END_DATE, 'YYYY-MM-DD'), p_reason => :P23_END_REASON);"],
    when_button=be, success='تم إنهاء التعيين')
p.branch(10, 'f?p=&APP_ID.:23:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#')

orgm = app.nav_item('الهيكل التنظيمي', None, 'fa-sitemap', 30, scheme=ADMIN)
app.nav_item('الهياكل والإصدارات', 20, 'fa-sitemap', 31, parent=orgm, scheme=ADMIN)
app.nav_item('المناصب والوظائف', 22, 'fa-id-badge', 32, parent=orgm, scheme=ADMIN)
app.nav_item('تعيين الموظفين', 23, 'fa-user-plus', 33, parent=orgm, scheme=ADMIN)


# ######################################################################## المرحلة 3: المستخدمون والأدوار
ROLE_LOV = "select name_ar || ' (' || code || ')' d, id r from sec_role where status_code = 'ACTIVE' order by 1"
BRANCH_ALL_LOV = ("select b.name_ar || ' - ' || nvl(c.trade_name_ar, c.legal_name_ar) d, b.id r from org_branch b "
                  "join org_company c on c.id = b.company_id where b.status_code = 'ACTIVE' "
                  "and noona_sec_admin_pkg.can_admin_company(b.company_id) = 'Y' order by 1")
# مسؤول الشركة لا يمنح الأدوار المميزة
GRANT_ROLE_LOV = ("select name_ar || ' (' || code || ')' d, id r from sec_role where status_code = 'ACTIVE' "
                  "and (is_privileged = 'N' or noona_sec_admin_pkg.admin_level = 'TENANT') order by 1")

# =============================================================== 30) المستخدمون
p = app.page(30, 'Users', 'USERS', 'المستخدمون', scheme=ORG)
r = p.ir('المستخدمون', 10, [
    'select m.id, u.username, u.display_name, u.email, nvl(c.trade_name_ar, c.legal_name_ar) as company_name,',
    '       noona_ui_pkg.code_label(m.is_tenant_admin) as is_admin, m.clearance_level,',
    "       (select count(*) from sec_role_grant g where g.membership_id = m.id and g.status_code = 'ACTIVE') as roles,",
    '       u.last_login_at, noona_ui_pkg.status_badge(m.status_code) as status_html',
    '  from sec_user_membership m join sec_user u on u.id = m.user_id',
    '  left join org_company c on c.id = m.default_company_id',
    " where noona_sec_admin_pkg.can_admin_member(m.id) = 'Y'"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('USERNAME', 'اسم الدخول', {}), ('DISPLAY_NAME', 'الاسم', {}),
     ('EMAIL', 'البريد', {}), ('COMPANY_NAME', 'الشركة الافتراضية', {}), ('IS_ADMIN', 'مسؤول المؤسسة', {}),
     ('CLEARANCE_LEVEL', 'مستوى السرية', {}), ('ROLES', 'الأدوار', {'type': 'NUMBER'}),
     ('LAST_LOGIN_AT', 'آخر دخول', {'type': 'DATE'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#')
p.button(r, 10, 'CREATE', 'مستخدم جديد', hot=True, redirect='f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::', position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 31) المستخدم
p = app.page(31, 'User', 'USER', 'المستخدم', scheme=ORG)
info = p.static('بيانات المستخدم', 10)
p.hidden('P31_ID', info, 1)
p.text('P31_USERNAME', info, 10, 'اسم الدخول', required=True, maxlen=100, width=30)
p.text('P31_DISPLAY_NAME', info, 20, 'الاسم الكامل', required=True)
p.text('P31_EMAIL', info, 30, 'البريد الإلكتروني', required=True)
p.select('P31_COMPANY_ID', info, 40, 'الشركة الافتراضية', lov_sql=ADMIN_CO_LOV, required=True)
p.select('P31_BRANCH_ID', info, 50, 'الفرع الافتراضي', lov_sql=BRANCH_ALL_LOV)
p.select('P31_CLEARANCE', info, 60, 'مستوى السرية', null_text=None, lov_sql=(
    'STATIC2:عام;PUBLIC,داخلي;INTERNAL,سري;CONFIDENTIAL,سري جداً;SECRET,مقيد للغاية;HIGHLY_RESTRICTED'))
p.yesno('P31_IS_ADMIN', info, 70, 'مسؤول المؤسسة')
p.password('P31_PASSWORD', info, 80, 'كلمة المرور (10 أحرف: كبير وصغير ورقم)')
p.display('P31_STATUS', info, 90, 'الحالة')
b_create = p.button(info, 10, 'CREATE', 'إنشاء المستخدم', hot=True, condition=':P31_ID is null')
b_save = p.button(info, 20, 'SAVE', 'حفظ التعديلات', hot=True, condition=':P31_ID is not null')
b_pwd = p.button(info, 25, 'SET_PASSWORD', 'تعيين كلمة المرور', condition=':P31_ID is not null')
p.button(info, 30, 'BACK', 'رجوع', redirect=back(30))
p.process(10, 'BEFORE_HEADER', 'Load User', [
    'if :P31_ID is not null then',
    "    if noona_sec_admin_pkg.can_admin_member(:P31_ID) = 'N' then",
    "        raise_application_error(-20100, 'NOONA-SEC-261: هذا المستخدم خارج نطاق إدارتك');",
    '    end if;',
    '    select u.username, u.display_name, u.email, m.default_company_id, m.default_branch_id, m.clearance_level,',
    '           m.is_tenant_admin, noona_ui_pkg.status_label(m.status_code)',
    '      into :P31_USERNAME, :P31_DISPLAY_NAME, :P31_EMAIL, :P31_COMPANY_ID, :P31_BRANCH_ID, :P31_CLEARANCE,',
    '           :P31_IS_ADMIN, :P31_STATUS',
    '      from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = :P31_ID;',
    'else',
    "    :P31_CLEARANCE := nvl(:P31_CLEARANCE, 'INTERNAL'); :P31_IS_ADMIN := nvl(:P31_IS_ADMIN, 'N');",
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Create User', [
    ':P31_ID := noona_sec_admin_pkg.create_user(p_username => :P31_USERNAME, p_display_name => :P31_DISPLAY_NAME,',
    '    p_email => :P31_EMAIL, p_company_id => :P31_COMPANY_ID, p_branch_id => :P31_BRANCH_ID,',
    '    p_is_tenant_admin => :P31_IS_ADMIN, p_clearance => :P31_CLEARANCE);',
    '-- كلمة المرور المحلية (SEC_CREDENTIAL)؛ بدونها يدخل المستخدم بحساب APEX إن وجد',
    'if :P31_PASSWORD is not null then',
    '    noona_sec_admin_pkg.set_password(p_membership_id => :P31_ID, p_password => :P31_PASSWORD);',
    'end if;',
    ':P31_PASSWORD := null;'], when_button=b_create, success='تم إنشاء المستخدم؛ امنحه الأدوار المناسبة')
p.process(15, 'AFTER_SUBMIT', 'Set Password', [
    'noona_sec_admin_pkg.set_password(p_membership_id => :P31_ID, p_password => :P31_PASSWORD);',
    ':P31_PASSWORD := null;'], when_button=b_pwd, success='تم تعيين كلمة المرور وفك قفل الحساب')
p.process(20, 'AFTER_SUBMIT', 'Save User', [
    'noona_sec_admin_pkg.update_member(p_membership_id => :P31_ID, p_display_name => :P31_DISPLAY_NAME, p_email => :P31_EMAIL,',
    '    p_company_id => :P31_COMPANY_ID, p_branch_id => :P31_BRANCH_ID, p_clearance => :P31_CLEARANCE);'],
    when_button=b_save, success='تم حفظ بيانات المستخدم')
gr = p.ir('أدوار المستخدم', 20, [
    "select g.id, r.name_ar as role_name, r.code, case when s.scope_type = 'ALL_TENANT' then 'كل المؤسسة'",
    "       else (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c where c.id = s.company_id)",
    "            || case when s.scope_type = 'BRANCH' then ' / فرع: ' || (select b.name_ar from org_branch b where b.id = s.scope_value_id) end end as scope,",
    '       g.effective_from, g.effective_to, g.reason, noona_ui_pkg.status_badge(g.status_code) as status_html',
    '  from sec_role_grant g join sec_role r on r.id = g.role_id',
    '  left join sec_data_scope s on s.role_grant_id = g.id',
    ' where g.membership_id = :P31_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ROLE_NAME', 'الدور', {}), ('CODE', 'الرمز', {}),
     ('SCOPE', 'نطاق البيانات', {}), ('EFFECTIVE_FROM', 'من', {'type': 'DATE'}), ('EFFECTIVE_TO', 'إلى', {'type': 'DATE'}),
     ('REASON', 'السبب', {}), ('STATUS_HTML', 'الحالة', {'html': True})], titled=True)
ga = p.static('منح دور / سحب / حالة الحساب', 30)
p.select('P31_ROLE_ID', ga, 10, 'الدور', lov_sql=GRANT_ROLE_LOV)
p.select('P31_SCOPE_COMPANY', ga, 20, 'نطاق البيانات: الشركة', lov_sql=ADMIN_CO_LOV, null_text='- كل شركات المؤسسة (لمسؤول المؤسسة) -')
p.select('P31_SCOPE_BRANCH', ga, 25, 'أو فرع محدد', lov_sql=BRANCH_ALL_LOV, null_text='- الشركة كاملة -')
p.select('P31_REVOKE_ID', ga, 30, 'منح للسحب', lov_sql=(
    "select r.name_ar || ' (' || r.code || ')' d, g.id r from sec_role_grant g join sec_role r on r.id = g.role_id "
    "where g.membership_id = :P31_ID and g.status_code = 'ACTIVE' order by 1"))
p.select('P31_NEW_STATUS', ga, 40, 'تغيير حالة الحساب إلى', lov_sql='STATIC2:نشط;ACTIVE,معلق;SUSPENDED,منتهي;ENDED')
p.textarea('P31_REASON', ga, 50, 'السبب (إلزامي للسحب وتغيير الحالة)', rows=2)
b_grant = p.button(ga, 10, 'GRANT', 'منح الدور', hot=True, condition=':P31_ID is not null')
b_revoke = p.button(ga, 20, 'REVOKE', 'سحب المنح', condition=':P31_ID is not null')
b_status = p.button(ga, 30, 'CHANGE_STATUS', 'تغيير الحالة', condition=':P31_ID is not null')
p.process(30, 'AFTER_SUBMIT', 'Grant Role', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_sec_admin_pkg.grant_role(p_membership_id => :P31_ID, p_role_id => :P31_ROLE_ID,',
    '                                           p_company_id => :P31_SCOPE_COMPANY, p_reason => :P31_REASON,',
    '                                           p_branch_id => :P31_SCOPE_BRANCH);',
    'end;'], when_button=b_grant, success='تم منح الدور')
p.process(40, 'AFTER_SUBMIT', 'Revoke Grant', 'noona_sec_admin_pkg.revoke_grant(p_grant_id => :P31_REVOKE_ID, p_reason => :P31_REASON);',
          when_button=b_revoke, success='تم سحب المنح')
p.process(50, 'AFTER_SUBMIT', 'Change Status',
          'noona_sec_admin_pkg.set_member_status(p_membership_id => :P31_ID, p_status => :P31_NEW_STATUS, p_reason => :P31_REASON);',
          when_button=b_status, success='تم تغيير حالة الحساب')
p.branch(10, 'f?p=&APP_ID.:31:&SESSION.::&DEBUG.:31:P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 32) الأدوار
p = app.page(32, 'Roles', 'ROLES', 'الأدوار', scheme=ADMIN)
p.ir('الأدوار', 10, [
    'select r.id, r.code, r.name_ar, noona_ui_pkg.code_label(r.role_type) as role_type, noona_ui_pkg.code_label(r.is_privileged) as privileged,',
    '       (select count(*) from sec_role_permission rp where rp.role_id = r.id) as permissions,',
    "       (select count(*) from sec_role_grant g where g.role_id = r.id and g.status_code = 'ACTIVE') as members,",
    '       noona_ui_pkg.status_badge(r.status_code) as status_html',
    '  from sec_role r'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الدور', {}),
     ('ROLE_TYPE', 'النوع', {}), ('PRIVILEGED', 'مميز', {}), ('PERMISSIONS', 'الصلاحيات', {'type': 'NUMBER'}),
     ('MEMBERS', 'الممنوح لهم', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:33:&SESSION.::&DEBUG.:RP,33:P33_ID:#ID#')
f = p.static('دور جديد', 20)
p.text('P32_CODE', f, 10, 'الرمز', required=True, maxlen=50, width=20)
p.text('P32_NAME_AR', f, 20, 'اسم الدور', required=True)
p.select('P32_TYPE', f, 30, 'النوع', null_text=None, lov_sql=(
    'STATIC2:وظيفي;FUNCTIONAL,شركة;COMPANY,فرع;BRANCH,وظيفة;JOB,منصب;POSITION,مشروع;PROJECT,لجنة;COMMITTEE,مؤقت;TEMPORARY,خارجي;EXTERNAL'))
p.yesno('P32_PRIVILEGED', f, 40, 'دور مميز (يمنحه مسؤول المؤسسة فقط)')
b = p.button(f, 10, 'CREATE', 'إنشاء الدور', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P32_PRIVILEGED := nvl(:P32_PRIVILEGED, 'N');"])
p.process(10, 'AFTER_SUBMIT', 'Create Role', [
    ':P33_ID := noona_sec_admin_pkg.create_role(p_code => :P32_CODE, p_name_ar => :P32_NAME_AR,',
    '                                         p_role_type => :P32_TYPE, p_privileged => :P32_PRIVILEGED);'],
    when_button=b, success='تم إنشاء الدور؛ أضف صلاحياته')
p.branch(10, 'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 33) الدور وصلاحياته
p = app.page(33, 'Role', 'ROLE', 'الدور وصلاحياته', scheme=ADMIN)
info = p.static('الدور', 10)
p.hidden('P33_ID', info, 1)
p.display('P33_NAME', info, 10, 'الدور')
p.display('P33_STATUS', info, 20, 'الحالة')
p.select('P33_NEW_STATUS', info, 30, 'تغيير الحالة إلى', lov_sql='STATIC2:نشط;ACTIVE,مسودة;DRAFT,متقاعد;RETIRED')
b_status = p.button(info, 10, 'CHANGE_STATUS', 'تغيير الحالة')
p.button(info, 20, 'BACK', 'رجوع', redirect=back(32))
p.process(10, 'BEFORE_HEADER', 'Load Role', [
    "select name_ar || ' (' || code || ')', noona_ui_pkg.status_label(status_code) into :P33_NAME, :P33_STATUS",
    '  from sec_role where id = :P33_ID;',
    '-- الوحدة الافتراضية: أول وحدة للدور فيها صلاحيات، وإلا أول وحدة',
    'if :P33_MODULE is null then',
    '    select min(m.module_code) keep (dense_rank first order by',
    '               case when exists (select 1 from sec_role_permission rp join sec_permission p on p.id = rp.permission_id',
    '                                  where rp.role_id = :P33_ID and p.module_code = m.module_code) then 0 else 1 end,',
    '               m.package_no)',
    '      into :P33_MODULE from plt_module m;',
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Role Status', 'noona_sec_admin_pkg.set_role_status(:P33_ID, :P33_NEW_STATUS);',
          when_button=b_status, success='تم تغيير حالة الدور')

# مصفوفة الصلاحيات: صف لكل عنصر وعمود لكل فعل؛ رأس العمود/الصف يحدد الكل
mx = p.static('مصفوفة الصلاحيات', 20)
p.select('P33_MODULE', mx, 10, 'الوحدة', null_text=None, submit=True, lov_sql=(
    "select m.module_code || ' - ' || m.name_ar || ' (' || (select count(*) from sec_role_permission rp "
    "join sec_permission p on p.id = rp.permission_id where rp.role_id = :P33_ID and p.module_code = m.module_code "
    "and rp.effect = 'ALLOW') || ')' d, m.module_code r from plt_module m order by m.package_no"))
p.hidden('P33_PERMS', mx, 20, protected=False)
b_save = p.button(mx, 10, 'SAVE_MATRIX', 'حفظ الصلاحيات', hot=True)
p.dynamic('خانات الصلاحيات', 25, 'return noona_ui_pkg.permission_matrix(p_role_id => :P33_ID, p_module_code => :P33_MODULE);',
          hide_header=True)
p.onload([
    '// رؤوس الأعمدة والصفوف تعكس حالة الخانات (محددة إذا كانت كل خاناتها محددة)',
    'function nnSyncHeads() {',
    "    $('.nn-col').each(function () {",
    "        var c = $('.nn-perm[data-col=\"' + $(this).data('col') + '\"]');",
    "        this.checked = c.length > 0 && c.filter(':checked').length === c.length;",
    '    });',
    "    $('.nn-row').each(function () {",
    "        var c = $(this).closest('tr').find('.nn-perm');",
    "        this.checked = c.length > 0 && c.filter(':checked').length === c.length;",
    '    });',
    "    var all = $('.nn-perm'); $('.nn-all').prop('checked', all.length > 0 && all.filter(':checked').length === all.length);",
    '}',
    "$(document).on('change', '.nn-col', function () {",
    "    $('.nn-perm[data-col=\"' + $(this).data('col') + '\"]').prop('checked', this.checked); nnSyncHeads();",
    '});',
    "$(document).on('change', '.nn-row', function () {",
    "    $(this).closest('tr').find('.nn-perm').prop('checked', this.checked); nnSyncHeads();",
    '});',
    "$(document).on('change', '.nn-all', function () { $('.nn-perm').prop('checked', this.checked); nnSyncHeads(); });",
    "$(document).on('change', '.nn-perm', nnSyncHeads);",
    '// قبل الإرسال: أرقام الصلاحيات المختارة في عنصر مخفي',
    "$(document).on('apexbeforepagesubmit', function () {",
    "    $s('P33_PERMS', $('.nn-perm:checked').map(function () { return this.value; }).get().join(','));",
    '});',
    'nnSyncHeads();'])
p.process(20, 'AFTER_SUBMIT', 'Save Permission Matrix', [
    'declare l_r varchar2(50);',
    'begin',
    '    l_r := noona_sec_admin_pkg.sync_module_permissions(:P33_ID, :P33_MODULE, :P33_PERMS);',
    "    apex_application.g_print_success_message := 'تم حفظ الصلاحيات: إضافة ' || substr(l_r, 1, instr(l_r, ':') - 1)",
    "        || ' وإزالة ' || substr(l_r, instr(l_r, ':') + 1);",
    'end;'], when_button=b_save)

# صلاحية بالرمز (سماح أو منع صريح يتقدم على أي سماح)
f = p.static('صلاحية محددة أو منع صريح', 30)
p.text('P33_PERMISSION_CODE', f, 10, 'رمز الصلاحية', maxlen=150)
p.select('P33_EFFECT', f, 20, 'الأثر', null_text=None, lov_sql='STATIC2:منع;DENY,سماح;ALLOW')
p.select('P33_REMOVE_ID', f, 30, 'إزالة صلاحية منع', lov_sql=(
    "select p.permission_code d, rp.id r from sec_role_permission rp join sec_permission p on p.id = rp.permission_id "
    "where rp.role_id = :P33_ID and rp.effect = 'DENY' order by 1"))
b_one = p.button(f, 10, 'ADD_ONE', 'إضافة')
b_rm = p.button(f, 20, 'REMOVE', 'إزالة المنع')
p.process(30, 'AFTER_SUBMIT', 'Add One Permission',
          "noona_sec_admin_pkg.add_permission(:P33_ID, :P33_PERMISSION_CODE, nvl(:P33_EFFECT, 'DENY'));",
          when_button=b_one, success='تمت إضافة الصلاحية')
p.process(40, 'AFTER_SUBMIT', 'Remove Permission', 'noona_sec_admin_pkg.remove_permission(:P33_REMOVE_ID);',
          when_button=b_rm, success='تمت إزالة الصلاحية')
p.branch(10, 'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#')

MEMBER_LOV = ("select u.display_name || ' (' || u.username || ')' d, m.id r from sec_user_membership m "
              "join sec_user u on u.id = m.user_id where m.status_code = 'ACTIVE' order by 1")

# =============================================================== 40) مسارات الاعتماد
p = app.page(40, 'Workflows', 'WORKFLOWS', 'مسارات الاعتماد', scheme=ADMIN)
p.ir('مسارات الاعتماد', 10, [
    'select d.id, d.code, d.name_ar, nvl(e.name_ar, d.object_type) as object_name,',
    '       noona_ui_pkg.code_label(d.workflow_kind) as kind,',
    "       (select max(v.version_no) from wf_definition_version v where v.definition_id = d.id",
    "           and v.status_code in ('PUBLISHED', 'ACTIVE')) as published_version,",
    "       (select count(*) from wf_definition_version v where v.definition_id = d.id and v.status_code = 'DRAFT') as drafts,",
    "       noona_ui_pkg.status_badge(case d.is_active when 'Y' then 'ACTIVE' else 'INACTIVE' end) as status_html",
    '  from wf_definition d left join ref_entity_type e on e.entity_type_code = d.object_type'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المسار', {}),
     ('OBJECT_NAME', 'نوع المستند', {}), ('KIND', 'النوع', {}), ('PUBLISHED_VERSION', 'الإصدار المنشور', {'type': 'NUMBER'}),
     ('DRAFTS', 'مسودات', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:#ID#')
f = p.static('مسار جديد', 20)
p.text('P40_CODE', f, 10, 'الرمز', required=True, maxlen=50, width=20)
p.text('P40_NAME_AR', f, 20, 'اسم المسار', required=True)
p.select('P40_OBJECT_TYPE', f, 30, 'نوع المستند', required=True, lov_sql=(
    "select module_code || ' - ' || name_ar d, entity_type_code r from ref_entity_type "
    "where module_code not in ('PLT', 'SEC', 'REF', 'MIG', 'OPS', 'DEP') order by module_code, name_ar"))
p.select('P40_KIND', f, 40, 'نوع المسار', null_text=None, lov_sql='STATIC2:اعتماد;APPROVAL,مراجعة;REVIEW,توجيه;ROUTING,مهام;TASK')
b = p.button(f, 10, 'CREATE', 'إنشاء المسار', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Create Workflow', [
    'declare l_ver number; l_id number;',
    'begin',
    '    :P41_ID := noona_workflow_pkg.create_definition(p_code => :P40_CODE, p_name_ar => :P40_NAME_AR,',
    "                   p_object_type => :P40_OBJECT_TYPE, p_kind => nvl(:P40_KIND, 'APPROVAL'));",
    '    -- إصدار أول بخطوتي البداية والنهاية',
    '    l_ver := noona_workflow_pkg.new_version(:P41_ID);',
    "    l_id := noona_workflow_pkg.add_step(l_ver, 'START', 'START', 'بداية');",
    "    l_id := noona_workflow_pkg.add_step(l_ver, 'END', 'END', 'نهاية');",
    'end;'], when_button=b, success='تم إنشاء المسار؛ أضف خطوات الاعتماد ثم انشر الإصدار')
p.branch(10, 'f?p=&APP_ID.:41:&SESSION.::&DEBUG.::P41_ID:&P41_ID.&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 41) المسار وإصداراته
p = app.page(41, 'Workflow', 'WORKFLOW', 'مسار الاعتماد', scheme=ADMIN)
hdr = p.static('المسار', 10)
p.hidden('P41_ID', hdr, 1)
p.hidden('P41_IS_DRAFT', hdr, 2)
p.display('P41_NAME', hdr, 10, 'المسار')
p.select('P41_VERSION_ID', hdr, 20, 'الإصدار', null_text=None, submit=True, lov_sql=(
    "select 'الإصدار ' || version_no || ' - ' || noona_ui_pkg.status_label(status_code) d, id r "
    "from wf_definition_version where definition_id = :P41_ID order by version_no desc"))
b_pub = p.button(hdr, 10, 'PUBLISH', 'نشر الإصدار', hot=True, condition=":P41_IS_DRAFT = 'Y'")
b_new = p.button(hdr, 20, 'NEW_VERSION', 'إصدار جديد (نسخ المنشور)', condition=":P41_IS_DRAFT = 'N'")
p.button(hdr, 30, 'BACK', 'رجوع', redirect=back(40))
p.process(10, 'BEFORE_HEADER', 'Load Workflow', [
    "select name_ar || ' (' || code || ')' into :P41_NAME from wf_definition where id = :P41_ID;",
    'declare l_n number;',
    'begin',
    '    select count(*) into l_n from wf_definition_version where definition_id = :P41_ID and id = :P41_VERSION_ID;',
    '    if l_n = 0 then   -- الافتراضي: المسودة إن وجدت وإلا أحدث إصدار',
    "        select max(id) keep (dense_rank last order by case status_code when 'DRAFT' then 1 else 0 end, version_no)",
    '          into :P41_VERSION_ID from wf_definition_version where definition_id = :P41_ID;',
    '    end if;',
    'end;',
    "select case max(status_code) when 'DRAFT' then 'Y' else 'N' end into :P41_IS_DRAFT",
    '  from wf_definition_version where id = :P41_VERSION_ID;'])
p.process(10, 'AFTER_SUBMIT', 'Publish', 'noona_workflow_pkg.publish_version(:P41_VERSION_ID);',
          when_button=b_pub, success='تم نشر الإصدار؛ يطبق على الطلبات الجديدة')
p.process(20, 'AFTER_SUBMIT', 'New Version', ':P41_VERSION_ID := noona_workflow_pkg.copy_version(:P41_ID);',
          when_button=b_new, success='تم إنشاء إصدار مسودة منسوخ من الإصدار المنشور')
p.dynamic('مخطط المسار', 15, 'return noona_ui_pkg.workflow_diagram(:P41_VERSION_ID);')
p.ir('الخطوات', 20, [
    'select s.id, s.step_code, s.name_ar, noona_ui_pkg.code_label(s.step_type) as step_type,',
    '       noona_ui_pkg.assignee_label(s.assignee_rule, s.assignee_ref_id) as assignee,',
    '       noona_ui_pkg.code_label(s.allow_self_approval) as allow_self',
    '  from wf_step_def s where s.version_id = :P41_VERSION_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('STEP_CODE', 'الرمز', {}), ('NAME_AR', 'الخطوة', {}),
     ('STEP_TYPE', 'النوع', {}), ('ASSIGNEE', 'المكلف', {}), ('ALLOW_SELF', 'يعتمد طلبه بنفسه', {})], titled=True)
p.ir('الانتقالات', 25, [
    'select x.id, f.name_ar as from_name, noona_ui_pkg.code_label(nvl(x.outcome_code, \'-\')) as outcome, t.name_ar as to_name,',
    '       noona_ui_pkg.code_label(x.is_default) as is_default, r.name_ar as rule_name',
    '  from wf_transition_def x join wf_step_def f on f.id = x.from_step_id join wf_step_def t on t.id = x.to_step_id',
    '  left join wf_rule r on r.id = x.rule_id where x.version_id = :P41_VERSION_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('FROM_NAME', 'من', {}), ('OUTCOME', 'عند', {}), ('TO_NAME', 'إلى', {}),
     ('IS_DEFAULT', 'افتراضي', {}), ('RULE_NAME', 'بشرط', {})], titled=True)
STEPS_LOV = ("select name_ar || ' (' || step_code || ')' d, step_code r from wf_step_def "
             "where version_id = :P41_VERSION_ID order by id")
st = p.static('إضافة خطوة', 30, condition=":P41_IS_DRAFT = 'Y'")
p.text('P41_STEP_CODE', st, 10, 'رمز الخطوة', maxlen=50, width=20)
p.text('P41_STEP_NAME', st, 20, 'اسم الخطوة')
p.select('P41_STEP_TYPE', st, 30, 'نوع الخطوة', null_text=None, lov_sql=(
    'STATIC2:اعتماد;APPROVAL,مراجعة;REVIEW,مهمة;USER_TASK,إشعار;NOTIFICATION,قرار;DECISION,خطوة نظامية;SYSTEM,نهاية;END'))
p.select('P41_RULE', st, 40, 'المكلف', lov_sql=(
    'STATIC2:المدير المباشر للطالب;MANAGER,رئيس وحدة تنظيمية;HEAD_POSITION,شاغل منصب;POSITION,'
    'أعضاء دور;ROLE,مستخدم محدد;USER,الطالب نفسه;REQUESTER'))
p.select('P41_REF', st, 50, 'تحديد المكلف', cascade='P41_RULE', lov_sql=(
    "select d, r from ("
    "select u.display_name d, m.id r, 'USER' k from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = 'ACTIVE' "
    "union all select p.name_ar, p.id, 'POSITION' from org_position p where p.status_code <> 'CLOSED' "
    "union all select o.name_ar, o.id, 'HEAD_POSITION' from org_unit o "
    "union all select r.name_ar, r.id, 'ROLE' from sec_role r where r.status_code = 'ACTIVE'"
    ") where k = :P41_RULE order by 1"))
p.yesno('P41_ALLOW_SELF', st, 60, 'يسمح أن يعتمد طلبه بنفسه')
b_step = p.button(st, 10, 'ADD_STEP', 'إضافة الخطوة', hot=True)
p.process(30, 'AFTER_SUBMIT', 'Add Step', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_workflow_pkg.add_step(p_version_id => :P41_VERSION_ID, p_step_code => :P41_STEP_CODE,',
    '                p_step_type => :P41_STEP_TYPE, p_name_ar => :P41_STEP_NAME, p_assignee_rule => :P41_RULE,',
    "                p_assignee_ref_id => :P41_REF, p_allow_self => nvl(:P41_ALLOW_SELF, 'N'));",
    'end;'], when_button=b_step, success='تمت إضافة الخطوة؛ اربطها بالانتقالات')
tr = p.static('ربط الخطوات (انتقال)', 35, condition=":P41_IS_DRAFT = 'Y'")
p.select('P41_FROM', tr, 10, 'من الخطوة', lov_sql=STEPS_LOV)
p.select('P41_TO', tr, 20, 'إلى الخطوة', lov_sql=STEPS_LOV)
p.select('P41_OUTCOME', tr, 30, 'عند', null_text='أي نتيجة', lov_sql='STATIC2:الاعتماد;APPROVED,الرفض;REJECTED,الإعادة;RETURNED')
p.select('P41_RULE_ID', tr, 40, 'بشرط (اختياري)', lov_sql="select name_ar || ' (' || code || ')' d, id r from wf_rule order by 1")
p.yesno('P41_IS_DEFAULT', tr, 50, 'انتقال افتراضي')
b_tr = p.button(tr, 10, 'ADD_TRANSITION', 'إضافة الانتقال', hot=True)
p.process(40, 'AFTER_SUBMIT', 'Add Transition',
          "noona_workflow_pkg.add_transition(:P41_VERSION_ID, :P41_FROM, :P41_TO, :P41_OUTCOME, nvl(:P41_IS_DEFAULT, 'N'), :P41_RULE_ID);",
          when_button=b_tr, success='تمت إضافة الانتقال')
rm = p.static('حذف من المسودة', 40, condition=":P41_IS_DRAFT = 'Y'")
p.select('P41_RM_STEP', rm, 10, 'خطوة', lov_sql=(
    "select name_ar || ' (' || step_code || ')' d, id r from wf_step_def where version_id = :P41_VERSION_ID "
    "and step_type not in ('START') order by id"))
p.select('P41_RM_TR', rm, 20, 'انتقال', lov_sql=(
    "select f.name_ar || ' ← ' || t.name_ar || nvl2(x.outcome_code, ' (' || noona_ui_pkg.code_label(x.outcome_code) || ')', '') d, x.id r "
    "from wf_transition_def x join wf_step_def f on f.id = x.from_step_id join wf_step_def t on t.id = x.to_step_id "
    "where x.version_id = :P41_VERSION_ID order by x.id"))
b_rs = p.button(rm, 10, 'REMOVE_STEP', 'حذف الخطوة')
b_rt = p.button(rm, 20, 'REMOVE_TRANSITION', 'حذف الانتقال')
p.process(50, 'AFTER_SUBMIT', 'Remove Step', 'noona_workflow_pkg.remove_step(:P41_RM_STEP);', when_button=b_rs,
          success='تم حذف الخطوة وانتقالاتها')
p.process(60, 'AFTER_SUBMIT', 'Remove Transition', 'noona_workflow_pkg.remove_transition(:P41_RM_TR);', when_button=b_rt,
          success='تم حذف الانتقال')
p.branch(10, 'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:41:P41_ID,P41_VERSION_ID:&P41_ID.,&P41_VERSION_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 42) شروط التوجيه
p = app.page(42, 'Rules', 'RULES', 'شروط التوجيه', scheme=ADMIN)
p.ir('شروط التوجيه', 10, [
    'select id, code, name_ar, dbms_lob.substr(rule_expression, 400, 1) as expression,',
    '       noona_ui_pkg.status_badge(status_code) as status_html from wf_rule'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الشرط', {}),
     ('EXPRESSION', 'التعبير', {}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('شرط جديد (مثال: المبلغ أكبر من أو يساوي 10000)', 20)
p.text('P42_CODE', f, 10, 'الرمز', required=True, maxlen=50, width=20)
p.text('P42_NAME_AR', f, 20, 'اسم الشرط', required=True)
p.select('P42_FIELD', f, 30, 'الحقل', null_text=None, lov_sql=(
    'STATIC2:المبلغ;amount,العملة;currency,الأولوية;priority,الشركة;company_id,الفرع;branch_id,نوع المستند;document_type'))
p.select('P42_OP', f, 40, 'المقارنة', null_text=None, lov_sql=(
    'STATIC2:أكبر من أو يساوي;>=,أكبر من;>,أصغر من;<,أصغر من أو يساوي;<=,يساوي;=,لا يساوي;!=,ضمن القائمة;in'))
p.text('P42_VALUE', f, 50, 'القيمة (للقائمة افصل بفاصلة)', required=True)
b = p.button(f, 10, 'CREATE', 'إنشاء الشرط', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Create Rule', [
    'declare',
    '    l_val varchar2(4000);',
    '    l_id  number;',
    'begin',
    "    if :P42_OP = 'in' then",
    "        select '[' || listagg(case when validate_conversion(trim(column_value) as number) = 1 then trim(column_value)",
    "                                   else '\"' || replace(trim(column_value), '\"') || '\"' end, ',') || ']'",
    "          into l_val from table(apex_string.split(:P42_VALUE, ','));",
    '    elsif validate_conversion(:P42_VALUE as number) = 1 then',
    '        l_val := :P42_VALUE;',
    '    else',
    "        l_val := '\"' || replace(:P42_VALUE, '\"') || '\"';",
    '    end if;',
    "    l_id := noona_workflow_pkg.create_rule(:P42_CODE, :P42_NAME_AR,",
    "        '{\"field\":\"' || :P42_FIELD || '\",\"op\":\"' || :P42_OP || '\",\"value\":' || l_val || '}');",
    'end;'], when_button=b, success='تم إنشاء الشرط؛ استخدمه في انتقالات المسار')

# =============================================================== 43) التفويضات
p = app.page(43, 'Delegations', 'DELEGATIONS', 'التفويضات', scheme=ADMIN)
p.ir('التفويضات', 10, [
    'select d.id, d.delegation_no, noona_ui_pkg.code_label(d.delegation_type) as dtype,',
    '       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = d.grantor_member_id) as grantor,',
    '       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = d.delegate_member_id) as delegate,',
    '       d.starts_at, d.ends_at, d.reason, noona_ui_pkg.status_badge(d.status_code) as status_html',
    '  from dlg_delegation d'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DELEGATION_NO', 'الرقم', {}), ('DTYPE', 'النوع', {}),
     ('GRANTOR', 'المانح', {}), ('DELEGATE', 'المفوض إليه', {}), ('STARTS_AT', 'من', {'type': 'DATE'}),
     ('ENDS_AT', 'إلى', {'type': 'DATE'}), ('REASON', 'السبب', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:44:&SESSION.::&DEBUG.:RP,44:P44_ID:#ID#')
f = p.static('تفويض جديد', 20)
p.select('P43_TYPE', f, 10, 'نوع التفويض', null_text=None, lov_sql=(
    'STATIC2:اعتماد;APPROVAL,مالي;FINANCIAL,تشغيلي;OPERATIONAL,إداري;ADMINISTRATIVE,مراسلات;CORRESPONDENCE,'
    'توقيع;SIGNATURE,بالإنابة;ACTING,طارئ;EMERGENCY'))
p.select('P43_GRANTOR', f, 20, 'المانح', required=True, lov_sql=MEMBER_LOV)
p.select('P43_DELEGATE', f, 30, 'المفوض إليه', required=True, lov_sql=MEMBER_LOV)
p.date('P43_FROM', f, 40, 'من تاريخ', required=True)
p.date('P43_TO', f, 50, 'إلى تاريخ', required=True)
p.textarea('P43_REASON', f, 60, 'السبب', required=True, rows=2)
b = p.button(f, 10, 'CREATE', 'إنشاء التفويض', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    "    :P43_GRANTOR := nvl(:P43_GRANTOR, sys_context('NOONA_CTX', 'MEMBERSHIP_ID'));",
    "    :P43_FROM := nvl(:P43_FROM, to_char(sysdate, 'YYYY-MM-DD'));"])
p.process(10, 'AFTER_SUBMIT', 'Create Delegation', [
    ':P44_ID := noona_delegation_pkg.create_delegation(',
    "    p_delegation_type => nvl(:P43_TYPE, 'APPROVAL'), p_grantor_member_id => :P43_GRANTOR,",
    "    p_delegate_member_id => :P43_DELEGATE, p_starts_at => to_date(:P43_FROM, 'YYYY-MM-DD'),",
    "    p_ends_at => to_date(:P43_TO, 'YYYY-MM-DD') + 1 - 1 / 86400, p_reason => :P43_REASON);"],
    when_button=b, success='تم إنشاء التفويض كمسودة؛ حدد نطاقه وحدوده ثم أرسله للاعتماد')
p.branch(10, 'f?p=&APP_ID.:44:&SESSION.::&DEBUG.::P44_ID:&P44_ID.&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 44) التفويض
p = app.page(44, 'Delegation', 'DELEGATION', 'التفويض', scheme=ADMIN)
p.dynamic('ملخص التفويض', 10, 'return noona_ui_pkg.delegation_header(:P44_ID);', hide_header=True)
hdr = p.static('إجراءات التفويض', 15)
p.hidden('P44_ID', hdr, 1)
p.hidden('P44_STATUS_CODE', hdr, 2)
p.hidden('P44_CAN_DECIDE', hdr, 3)
p.textarea('P44_REASON', hdr, 10, 'السبب أو الملاحظة (إلزامي للرفض والإلغاء والإيقاف)', rows=2)
b_sub = p.button(hdr, 10, 'SUBMIT', 'إرسال للاعتماد', hot=True, condition=":P44_STATUS_CODE = 'DRAFT'")
b_app = p.button(hdr, 20, 'APPROVE', 'اعتماد', hot=True, condition=":P44_STATUS_CODE = 'SUBMITTED' and :P44_CAN_DECIDE = 'Y'")
b_rej = p.button(hdr, 30, 'REJECT', 'رفض', condition=":P44_STATUS_CODE = 'SUBMITTED' and :P44_CAN_DECIDE = 'Y'")
b_sus = p.button(hdr, 40, 'SUSPEND', 'إيقاف مؤقت', condition=":P44_STATUS_CODE = 'ACTIVE'")
b_rev = p.button(hdr, 50, 'REVOKE', 'إلغاء التفويض', condition=":P44_STATUS_CODE in ('APPROVED', 'SCHEDULED', 'ACTIVE', 'SUSPENDED')")
p.button(hdr, 60, 'BACK', 'رجوع', redirect=back(43))
p.process(10, 'BEFORE_HEADER', 'Load Delegation', [
    '-- المانح والمفوض إليه لا يعتمدان التفويض (NOONA-DLG-041): تخفى أزرار القرار عنهما',
    "select status_code, case when sys_context('NOONA_CTX', 'MEMBERSHIP_ID') in (grantor_member_id, delegate_member_id)",
    "                         then 'N' else 'Y' end",
    '  into :P44_STATUS_CODE, :P44_CAN_DECIDE from dlg_delegation where id = :P44_ID;'])
for seq, btn, code, msg in [(10, b_sub, 'noona_delegation_pkg.submit(:P44_ID);', 'تم إرسال التفويض للاعتماد'),
                            (20, b_app, 'noona_delegation_pkg.approve(:P44_ID, :P44_REASON);', 'تم اعتماد التفويض'),
                            (30, b_rej, 'noona_delegation_pkg.reject(:P44_ID, :P44_REASON);', 'تم رفض التفويض'),
                            (40, b_sus, 'noona_delegation_pkg.suspend(:P44_ID, :P44_REASON);', 'تم إيقاف التفويض مؤقتاً'),
                            (50, b_rev, 'noona_delegation_pkg.revoke_delegation(:P44_ID, :P44_REASON);', 'تم إلغاء التفويض')]:
    p.process(seq, 'AFTER_SUBMIT', f'Delegation Action {seq}', code, when_button=btn, success=msg)
p.ir('نطاق التفويض', 20, [
    'select s.id, noona_ui_pkg.code_label(s.dimension_code) as dimension,',
    '       coalesce(s.value_code, (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c',
    "                                where s.dimension_code = 'COMPANY' and c.id = s.value_id),",
    "                (select b.name_ar from org_branch b where s.dimension_code = 'BRANCH' and b.id = s.value_id),",
    "                (select o.name_ar from org_unit o where s.dimension_code = 'ORG_UNIT' and o.id = s.value_id),",
    '                to_char(s.value_id)) as scope_value',
    '  from dlg_scope s where s.delegation_id = :P44_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DIMENSION', 'البعد', {}), ('SCOPE_VALUE', 'القيمة', {})], titled=True)
sc = p.static('تحديد النطاق والحدود (للمسودة)', 25, condition=":P44_STATUS_CODE = 'DRAFT'")
p.select('P44_DIM', sc, 10, 'البعد', lov_sql=(
    'STATIC2:شركة;COMPANY,فرع;BRANCH,وحدة تنظيمية;ORG_UNIT,وحدة النظام;MODULE,مسار اعتماد;WORKFLOW,إجراء;ACTION'))
p.select('P44_VAL', sc, 20, 'القيمة', cascade='P44_DIM', lov_sql=(
    "select d, r from ("
    "select nvl(trade_name_ar, legal_name_ar) d, 'ID:' || id r, 'COMPANY' k from org_company "
    "union all select name_ar, 'ID:' || id, 'BRANCH' from org_branch where status_code = 'ACTIVE' "
    "union all select name_ar, 'ID:' || id, 'ORG_UNIT' from org_unit "
    "union all select module_code || ' - ' || name_ar, 'CODE:' || module_code, 'MODULE' from plt_module "
    "union all select name_ar, 'CODE:' || code, 'WORKFLOW' from wf_definition "
    "union all select noona_ui_pkg.action_label(column_value), 'CODE:' || column_value, 'ACTION' from table(sys.odcivarchar2list("
    "'APPROVE','REJECT','SUBMIT','POST','SIGN','VIEW')) "
    ") where k = :P44_DIM order by 1"))
b_sc = p.button(sc, 10, 'ADD_SCOPE', 'إضافة للنطاق')
p.select('P44_CURRENCY', sc, 30, 'عملة الحد', lov_name='NOONA_CURRENCIES')
p.number('P44_MAX_TXN', sc, 40, 'الحد الأقصى للمعاملة')
p.number('P44_MAX_CUM', sc, 50, 'الحد التراكمي')
b_lim = p.button(sc, 20, 'SET_LIMIT', 'حفظ الحد المالي')
p.process(60, 'AFTER_SUBMIT', 'Add Scope', [
    'noona_delegation_pkg.add_scope(p_delegation_id => :P44_ID, p_dimension => :P44_DIM,',
    "    p_value_id => case when :P44_VAL like 'ID:%' then to_number(substr(:P44_VAL, 4)) end,",
    "    p_value_code => case when :P44_VAL like 'CODE:%' then substr(:P44_VAL, 6) end);"],
    when_button=b_sc, success='تمت إضافة النطاق')
p.process(70, 'AFTER_SUBMIT', 'Set Limit',
          'noona_delegation_pkg.set_limit(:P44_ID, :P44_CURRENCY, :P44_MAX_TXN, :P44_MAX_CUM);',
          when_button=b_lim, success='تم حفظ الحد المالي')
p.ir('سجل الاستخدام', 30, [
    'select e.id, e.created_at, noona_ui_pkg.action_label(e.action_code) as action_name, e.entity_type, e.entity_id,',
    '       e.amount, e.currency_code, e.result_code,',
    '       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id where m.id = e.actor_member_id) as actor',
    '  from dlg_exercise_event e where e.delegation_id = :P44_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CREATED_AT', 'الوقت', {'type': 'DATE'}), ('ACTION_NAME', 'الإجراء', {}),
     ('ENTITY_TYPE', 'المستند', {}), ('ENTITY_ID', 'رقمه', {'type': 'NUMBER'}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
     ('CURRENCY_CODE', 'العملة', {}), ('RESULT_CODE', 'النتيجة', {}), ('ACTOR', 'المنفذ', {})], titled=True)
p.branch(10, 'f?p=&APP_ID.:44:&SESSION.::&DEBUG.:44:P44_ID:&P44_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 50) العملات (مرجع عام للقراءة)
p = app.page(50, 'Currencies', 'CURRENCIES', 'العملات', scheme=ADMIN)
p.ir('العملات', 10, [
    'select id, currency_code, name_ar, name_en, symbol, decimal_places, minor_unit_ar,',
    '       noona_ui_pkg.code_label(rounding_method) as rounding, noona_ui_pkg.code_label(is_active) as active',
    '  from ref_currency'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CURRENCY_CODE', 'الرمز', {}), ('NAME_AR', 'العملة', {}),
     ('NAME_EN', 'بالإنجليزية', {}), ('SYMBOL', 'الرمز المختصر', {}), ('DECIMAL_PLACES', 'الخانات العشرية', {'type': 'NUMBER'}),
     ('MINOR_UNIT_AR', 'الوحدة الصغرى', {}), ('ROUNDING', 'التقريب', {}), ('ACTIVE', 'فعالة', {})])

# =============================================================== 51) أنواع أسعار الصرف
# أنواع الأسعار مرجع للمؤسسة؛ الأسعار نفسها خاصة بكل شركة وتدار من تطبيق المالية (لا تعرض هنا أسعار الشركات)
p = app.page(51, 'Rate Types', 'RATE-TYPES', 'أنواع أسعار الصرف', scheme=ADMIN)
p.ir('أنواع أسعار الصرف', 10, [
    "select t.id, t.code, t.name_ar, case t.rate_category when 'MANUAL' then 'يدوي' when 'OFFICIAL' then 'رسمي'",
    "         when 'CENTRAL_BANK' then 'البنك المركزي' when 'BANK' then 'بنكي' when 'BUY' then 'شراء' when 'SELL' then 'بيع'",
    "         when 'AVERAGE' then 'متوسط' when 'CLOSING' then 'إقفال' else t.rate_category end as category,",
    "       noona_ui_pkg.code_label(t.requires_approval) as approval, noona_ui_pkg.code_label(t.is_active) as active",
    '  from ref_rate_type t order by t.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}),
     ('CATEGORY', 'الفئة', {}), ('APPROVAL', 'يتطلب اعتماداً', {}), ('ACTIVE', 'فعال', {})])
p.static('أسعار الصرف', 20, text='<p class="nn-hint">أسعار الصرف خاصة بكل شركة ومستقلة عن الشركات الأخرى: تدخل وتعتمد من '
                                  'تطبيق <b>المالية ← الأستاذ العام ← أسعار الصرف</b> بعد اختيار الشركة.</p>')
rt = p.static('نوع سعر جديد', 40)
p.text('P51_RT_CODE', rt, 10, 'الرمز', maxlen=50, width=20)
p.text('P51_RT_NAME', rt, 20, 'الاسم')
p.select('P51_RT_CAT', rt, 30, 'الفئة', null_text=None, lov_sql=(
    'STATIC2:يدوي;MANUAL,رسمي;OFFICIAL,البنك المركزي;CENTRAL_BANK,بنكي;BANK,شراء;BUY,بيع;SELL,متوسط;AVERAGE,إقفال;CLOSING'))
p.yesno('P51_RT_APPROVAL', rt, 40, 'يتطلب اعتماد مستخدم آخر')
b_rt = p.button(rt, 10, 'ADD_TYPE', 'إضافة النوع')
p.process(10, 'AFTER_SUBMIT', 'Add Rate Type', [
    'declare l_id number;',
    'begin',
    "    l_id := noona_refdata_pkg.create_rate_type(:P51_RT_CODE, :P51_RT_NAME, :P51_RT_CAT, nvl(:P51_RT_APPROVAL, 'N'));",
    'end;'], when_button=b_rt, success='تمت إضافة نوع السعر')
p.branch(10, 'f?p=&APP_ID.:51:&SESSION.::&DEBUG.:51::&success_msg=#SUCCESS_MSG#')

# =============================================================== 52) شروط الدفع
p = app.page(52, 'Payment Terms', 'PAYMENT-TERMS', 'شروط الدفع', scheme=ADMIN)
p.ir('شروط الدفع', 10, [
    'select t.id, t.code, t.name_ar, noona_ui_pkg.code_label(t.base_date_rule) as base_rule, t.due_days,',
    "       case when t.early_discount_pct is not null then t.early_discount_pct || '% خلال ' || t.early_discount_days || ' يوم' end as discount,",
    "       (select listagg(l.due_pct || '% بعد ' || l.due_days || ' يوم', '، ') within group (order by l.line_no)",
    '          from ref_payment_term_line l where l.payment_term_id = t.id) as installments,',
    "       noona_ui_pkg.status_badge(case t.is_active when 'Y' then 'ACTIVE' else 'INACTIVE' end) as status_html",
    '  from ref_payment_term t'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الشرط', {}),
     ('BASE_RULE', 'يحسب من', {}), ('DUE_DAYS', 'أيام الاستحقاق', {'type': 'NUMBER'}), ('DISCOUNT', 'خصم السداد المبكر', {}),
     ('INSTALLMENTS', 'الأقساط', {}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('شرط دفع جديد', 20)
p.text('P52_CODE', f, 10, 'الرمز', required=True, maxlen=50, width=20)
p.text('P52_NAME_AR', f, 20, 'الاسم (مثال: صافي 30 يوم)', required=True)
p.select('P52_BASE', f, 30, 'يحسب الاستحقاق من', null_text=None, lov_sql=(
    'STATIC2:تاريخ المستند;DOC_DATE,تاريخ التسليم;DELIVERY_DATE,نهاية الشهر;END_OF_MONTH,تاريخ الاستلام;RECEIPT_DATE'))
p.number('P52_DAYS', f, 40, 'أيام الاستحقاق', required=True)
p.number('P52_DISC_PCT', f, 50, 'خصم السداد المبكر %')
p.number('P52_DISC_DAYS', f, 60, 'خلال (يوم)')
b = p.button(f, 10, 'CREATE', 'إنشاء الشرط', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Create Term', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_refdata_pkg.create_payment_term(:P52_CODE, :P52_NAME_AR, :P52_BASE, :P52_DAYS, :P52_DISC_PCT, :P52_DISC_DAYS);',
    'end;'], when_button=b, success='تم إنشاء شرط الدفع')
it = p.static('أقساط وتفعيل', 30)
TERMS = "select name_ar || ' (' || code || ')' d, id r from ref_payment_term order by 1"
p.select('P52_TERM', it, 10, 'شرط الدفع', lov_sql=TERMS)
p.number('P52_INST_PCT', it, 20, 'نسبة القسط %')
p.number('P52_INST_DAYS', it, 30, 'يستحق بعد (يوم)')
b_in = p.button(it, 10, 'ADD_INSTALLMENT', 'إضافة القسط', hot=True)
b_on = p.button(it, 20, 'ACTIVATE', 'تفعيل')
b_off = p.button(it, 30, 'DEACTIVATE', 'إيقاف')
p.process(20, 'AFTER_SUBMIT', 'Add Installment', 'noona_refdata_pkg.add_installment(:P52_TERM, :P52_INST_PCT, :P52_INST_DAYS);',
          when_button=b_in, success='تمت إضافة القسط')
p.process(30, 'AFTER_SUBMIT', 'Activate Term', "noona_refdata_pkg.set_term_active(:P52_TERM, 'Y');", when_button=b_on, success='تم التفعيل')
p.process(40, 'AFTER_SUBMIT', 'Deactivate Term', "noona_refdata_pkg.set_term_active(:P52_TERM, 'N');", when_button=b_off, success='تم الإيقاف')
p.branch(10, 'f?p=&APP_ID.:52:&SESSION.::&DEBUG.:52::&success_msg=#SUCCESS_MSG#')

# =============================================================== 53) تسلسلات المستندات
p = app.page(53, 'Document Sequences', 'DOC-SEQUENCES', 'تسلسلات المستندات', scheme=ADMIN)
p.ir('تسلسلات المستندات', 10, [
    'select s.id, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, b.name_ar as branch_name, s.doc_type_code, s.fiscal_year,',
    '       noona_refdata_pkg.preview_doc_no(s.id) as next_doc_no, noona_ui_pkg.code_label(s.is_gapless) as gapless,',
    "       decode(s.reset_policy, 'YEARLY', 'سنوي', 'MONTHLY', 'شهري', 'بدون') as reset_policy,",
    "       noona_ui_pkg.status_badge(case s.is_active when 'Y' then 'ACTIVE' else 'INACTIVE' end) as status_html",
    '  from ref_doc_sequence s left join org_company c on c.id = s.company_id left join org_branch b on b.id = s.branch_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('COMPANY_NAME', 'الشركة', {}), ('BRANCH_NAME', 'الفرع', {}),
     ('DOC_TYPE_CODE', 'نوع المستند', {}), ('FISCAL_YEAR', 'السنة', {'type': 'NUMBER'}), ('NEXT_DOC_NO', 'الرقم التالي', {}),
     ('GAPLESS', 'بلا فجوات', {}), ('RESET_POLICY', 'إعادة الترقيم', {}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('تسلسل جديد', 20)
p.select('P53_COMPANY', f, 10, 'الشركة', lov_name='NOONA_COMPANIES', required=True)
p.select('P53_BRANCH', f, 20, 'الفرع (اختياري)', cascade='P53_COMPANY', lov_sql=(
    "select name_ar d, id r from org_branch where company_id = :P53_COMPANY and status_code = 'ACTIVE' order by 1"))
p.text('P53_DOC_TYPE', f, 30, 'نوع المستند (مثال: PO, SI, JV)', required=True, maxlen=30, width=15)
p.number('P53_YEAR', f, 40, 'السنة المالية', required=True)
p.text('P53_PREFIX', f, 50, 'البادئة (مثال: PO-)', maxlen=20, width=15)
p.number('P53_PADDING', f, 60, 'عدد الخانات')
p.yesno('P53_GAPLESS', f, 70, 'بلا فجوات (للمستندات الضريبية)')
p.select('P53_RESET', f, 80, 'إعادة الترقيم', null_text=None, lov_sql='STATIC2:سنوي;YEARLY,شهري;MONTHLY,بدون;NEVER')
b = p.button(f, 10, 'CREATE', 'إنشاء التسلسل', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P53_YEAR := nvl(:P53_YEAR, to_char(sysdate, 'YYYY'));",
    ':P53_PADDING := nvl(:P53_PADDING, 6);'])
p.process(10, 'AFTER_SUBMIT', 'Create Sequence', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_refdata_pkg.create_doc_sequence(p_company_id => :P53_COMPANY, p_doc_type => :P53_DOC_TYPE,',
    '                p_fiscal_year => :P53_YEAR, p_prefix => :P53_PREFIX, p_branch_id => :P53_BRANCH,',
    "                p_padding => :P53_PADDING, p_gapless => nvl(:P53_GAPLESS, 'N'), p_reset => :P53_RESET);",
    'end;'], when_button=b, success='تم إنشاء التسلسل')
ed = p.static('تعديل تسلسل', 30)
p.select('P53_SEQ', ed, 10, 'التسلسل', submit=True, lov_sql=(
    "select s.doc_type_code || ' · ' || s.fiscal_year || ' · ' || nvl(c.trade_name_ar, c.legal_name_ar) || ' → '"
    " || noona_refdata_pkg.preview_doc_no(s.id) d, s.id r from ref_doc_sequence s join org_company c on c.id = s.company_id order by 1"))
p.text('P53_E_PREFIX', ed, 20, 'البادئة', maxlen=20, width=15)
p.number('P53_E_NEXT', ed, 30, 'الرقم التالي (لا يقل عن الحالي)')
p.yesno('P53_E_ACTIVE', ed, 40, 'فعال')
b_up = p.button(ed, 10, 'UPDATE', 'حفظ التعديل', hot=True)
p.process(20, 'BEFORE_HEADER', 'Load Sequence', [
    'if :P53_SEQ is not null then',
    '    select prefix, next_number, is_active into :P53_E_PREFIX, :P53_E_NEXT, :P53_E_ACTIVE from ref_doc_sequence where id = :P53_SEQ;',
    'end if;'])
p.process(20, 'AFTER_SUBMIT', 'Update Sequence',
          'noona_refdata_pkg.update_doc_sequence(:P53_SEQ, :P53_E_PREFIX, :P53_E_NEXT, :P53_E_ACTIVE);',
          when_button=b_up, success='تم حفظ التسلسل')
p.branch(10, 'f?p=&APP_ID.:53:&SESSION.::&DEBUG.:53:P53_SEQ:&P53_SEQ.&success_msg=#SUCCESS_MSG#')

# =============================================================== 60) سجل التدقيق
p = app.page(60, 'Audit Log', 'AUDIT', 'سجل التدقيق', scheme=ADMIN)
p.dynamic('سلامة السجل', 5, [
    'declare',
    "    l_bad number := noona_audit_pkg.verify_chain(to_number(sys_context('NOONA_CTX', 'TENANT_ID')));",
    '    l_n   number;',
    'begin',
    '    select count(*) into l_n from aud_event;',
    '    if l_bad is null then',
    "        return '<div class=\"nn-chain is-ok\"><span class=\"fa fa-shield\" aria-hidden=\"true\"></span><div><b>سجل التدقيق سليم</b>'",
    "            || '<small>تم التحقق من سلسلة التجزئة لعدد ' || l_n || ' حدث؛ لم يعدل أو يحذف أي حدث</small></div></div>';",
    '    end if;',
    "    return '<div class=\"nn-chain is-bad\"><span class=\"fa fa-exclamation-triangle\" aria-hidden=\"true\"></span><div><b>تحذير: انقطاع في سلسلة التدقيق</b>'",
    "        || '<small>أول حدث غير مطابق رقم ' || l_bad || '؛ أبلغ مسؤول المنصة فوراً</small></div></div>';",
    'end;'], hide_header=True)
p.ir('سجل التدقيق', 10, [
    "select e.id, to_char(e.occurred_at, 'YYYY-MM-DD HH24:MI:SS') as occurred_at, noona_ui_pkg.code_label(e.event_category) as category,",
    '       nvl(et.name_ar, e.entity_type) as entity_type, e.entity_id,',
    '       e.action_code, noona_ui_pkg.status_badge(e.result_code) as result_html,',
    '       (select u.display_name from sec_user u where u.id = e.actor_user_id) as actor,',
    '       (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c where c.id = e.company_id) as company_name,',
    '       e.reason, e.ip_address, e.request_source',
    '  from aud_event e left join ref_entity_type et on et.entity_type_code = e.entity_type order by e.id desc'],
    [('ID', 'رقم الحدث', {'type': 'NUMBER'}), ('OCCURRED_AT', 'الوقت', {}), ('CATEGORY', 'الفئة', {}),
     ('ENTITY_TYPE', 'الكيان', {}), ('ENTITY_ID', 'رقمه', {'type': 'NUMBER'}), ('ACTION_CODE', 'الإجراء', {}),
     ('RESULT_HTML', 'النتيجة', {'html': True}), ('ACTOR', 'المستخدم', {}), ('COMPANY_NAME', 'الشركة', {}),
     ('REASON', 'السبب', {}), ('IP_ADDRESS', 'عنوان IP', {}), ('REQUEST_SOURCE', 'المصدر', {})])

sec = app.nav_item('المستخدمون والصلاحيات', None, 'fa-users', 40)
app.nav_item('المستخدمون', 30, 'fa-user', 41, parent=sec)
app.nav_item('الأدوار والصلاحيات', 32, 'fa-key', 42, parent=sec, scheme=ADMIN)

wfn = app.nav_item('مسارات الاعتماد والتفويض', None, 'fa-sitemap', 50, scheme=ADMIN)
app.nav_item('مسارات الاعتماد', 40, 'fa-random', 51, parent=wfn, scheme=ADMIN)
app.nav_item('شروط التوجيه', 42, 'fa-filter', 52, parent=wfn, scheme=ADMIN)
app.nav_item('التفويضات', 43, 'fa-share', 53, parent=wfn, scheme=ADMIN)

ref = app.nav_item('البيانات المرجعية', None, 'fa-database', 60, scheme=ADMIN)
app.nav_item('العملات', 50, 'fa-money', 61, parent=ref, scheme=ADMIN)
app.nav_item('أنواع أسعار الصرف', 51, 'fa-exchange', 62, parent=ref, scheme=ADMIN)
app.nav_item('شروط الدفع', 52, 'fa-calendar-check-o', 63, parent=ref, scheme=ADMIN)
app.nav_item('تسلسلات المستندات', 53, 'fa-sort-numeric-asc', 64, parent=ref, scheme=ADMIN)
app.nav_item('سجل التدقيق', 60, 'fa-shield', 70, scheme=ADMIN)
def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'

from api_pages import build_admin as api_pages
api_pages(app, url)
app.finalize()
print('NOONA_ADMIN built:', len(app.pages), 'pages')
