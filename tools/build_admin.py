"""NOONA_ADMIN (إدارة المؤسسة) - يبني التطبيق من القالب عبر tools/apexgen.py
الاستخدام: python3 tools/build_admin.py   ->  apex/NOONA_ADMIN/f120
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_ADMIN/f120'),
          app_id=120, alias='NOONA_ADMIN', name='NOONA Administration', id_base=91820262000000000)
app.wire_security()
app.add_branding()
ADMIN = app.schemes['admin']
HOME = 'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'

def back(page_no):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:::'

STATUS_HTML = "noona_ui_pkg.status_badge(status_code) as status_html"

# =============================================================== 1) لوحة الإدارة
p = app.page(1, 'Home', 'HOME', 'إدارة المؤسسة', scheme=ADMIN)
p.dynamic('لوحة الإدارة', 10, 'return noona_ui_pkg.admin_summary(p_session => :APP_SESSION);', hide_header=True)
p.ir('الشركات', 20, [
    'select id, code, nvl(trade_name_ar, legal_name_ar) as company_name, country_code, functional_currency,',
    f'       {STATUS_HTML}',
    '  from org_company'],
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
p = app.page(12, 'Branches', 'BRANCHES', 'الفروع', scheme=ADMIN)
r = p.ir('الفروع', 10, [
    'select b.id, b.code, b.name_ar, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, noona_ui_pkg.code_label(b.branch_type) as branch_type,',
    '       noona_ui_pkg.code_label(b.is_head_office) as is_head_office, b.country_code, b.currency_code, noona_ui_pkg.status_badge(b.status_code) as status_html',
    '  from org_branch b join org_company c on c.id = b.company_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفرع', {}),
     ('COMPANY_NAME', 'الشركة', {}), ('BRANCH_TYPE', 'النوع', {}), ('IS_HEAD_OFFICE', 'رئيسي', {}),
     ('COUNTRY_CODE', 'الدولة', {}), ('CURRENCY_CODE', 'العملة', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13:P13_ID:#ID#')
p.button(r, 10, 'CREATE', 'فرع جديد', hot=True, redirect='f?p=&APP_ID.:13:&SESSION.::&DEBUG.:RP,13::', position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 13) الفرع
p = app.page(13, 'Branch', 'BRANCH', 'الفرع', scheme=ADMIN)
info = p.static('بيانات الفرع', 10)
p.hidden('P13_ID', info, 1)
p.select('P13_COMPANY_ID', info, 10, 'الشركة', lov_name='NOONA_COMPANIES', required=True)
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
    '      from org_branch where id = :P13_ID;',
    "elsif :P13_IS_HEAD_OFFICE is null then",
    "    :P13_IS_HEAD_OFFICE := 'N';",
    'end if;'])
p.process(10, 'AFTER_SUBMIT', 'Create Branch', [
    ':P13_ID := noona_platform_pkg.create_branch(',
    '    p_company_id => :P13_COMPANY_ID, p_code => :P13_CODE, p_name_ar => :P13_NAME_AR, p_name_en => :P13_NAME_EN,',
    '    p_branch_type => :P13_BRANCH_TYPE, p_is_head_office => :P13_IS_HEAD_OFFICE, p_country_code => :P13_COUNTRY_CODE);'],
    when_button=b_create, success='تم إنشاء الفرع')
p.process(20, 'AFTER_SUBMIT', 'Save Branch', [
    "noona_security_pkg.assert_permission('ORG_BRANCH.UPDATE', :P13_COMPANY_ID);",
    'update org_branch set name_ar = :P13_NAME_AR, name_en = :P13_NAME_EN, branch_type = :P13_BRANCH_TYPE',
    ' where id = :P13_ID;'],
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
app.nav_item('الشركات', 10, 'fa-building', 21, parent=org)
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

orgm = app.nav_item('الهيكل التنظيمي', None, 'fa-sitemap', 30)
app.nav_item('الهياكل والإصدارات', 20, 'fa-sitemap', 31, parent=orgm)
app.nav_item('المناصب والوظائف', 22, 'fa-id-badge', 32, parent=orgm)
app.nav_item('تعيين الموظفين', 23, 'fa-user-plus', 33, parent=orgm)


# ######################################################################## المرحلة 3: المستخدمون والأدوار
ROLE_LOV = "select name_ar || ' (' || code || ')' d, id r from sec_role where status_code = 'ACTIVE' order by 1"
BRANCH_ALL_LOV = ("select b.name_ar || ' - ' || nvl(c.trade_name_ar, c.legal_name_ar) d, b.id r from org_branch b "
                  "join org_company c on c.id = b.company_id where b.status_code = 'ACTIVE' order by 1")

# =============================================================== 30) المستخدمون
p = app.page(30, 'Users', 'USERS', 'المستخدمون', scheme=ADMIN)
r = p.ir('المستخدمون', 10, [
    'select m.id, u.username, u.display_name, u.email, nvl(c.trade_name_ar, c.legal_name_ar) as company_name,',
    '       noona_ui_pkg.code_label(m.is_tenant_admin) as is_admin, m.clearance_level,',
    "       (select count(*) from sec_role_grant g where g.membership_id = m.id and g.status_code = 'ACTIVE') as roles,",
    '       u.last_login_at, noona_ui_pkg.status_badge(m.status_code) as status_html',
    '  from sec_user_membership m join sec_user u on u.id = m.user_id',
    '  left join org_company c on c.id = m.default_company_id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('USERNAME', 'اسم الدخول', {}), ('DISPLAY_NAME', 'الاسم', {}),
     ('EMAIL', 'البريد', {}), ('COMPANY_NAME', 'الشركة الافتراضية', {}), ('IS_ADMIN', 'مسؤول المؤسسة', {}),
     ('CLEARANCE_LEVEL', 'مستوى السرية', {}), ('ROLES', 'الأدوار', {'type': 'NUMBER'}),
     ('LAST_LOGIN_AT', 'آخر دخول', {'type': 'DATE'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link='f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:#ID#')
p.button(r, 10, 'CREATE', 'مستخدم جديد', hot=True, redirect='f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31::', position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 31) المستخدم
p = app.page(31, 'User', 'USER', 'المستخدم', scheme=ADMIN)
info = p.static('بيانات المستخدم', 10)
p.hidden('P31_ID', info, 1)
p.text('P31_USERNAME', info, 10, 'اسم الدخول', required=True, maxlen=100, width=30)
p.text('P31_DISPLAY_NAME', info, 20, 'الاسم الكامل', required=True)
p.text('P31_EMAIL', info, 30, 'البريد الإلكتروني', required=True)
p.select('P31_COMPANY_ID', info, 40, 'الشركة الافتراضية', lov_name='NOONA_COMPANIES', required=True)
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
    "       else (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c where c.id = s.company_id) end as scope,",
    '       g.effective_from, g.effective_to, g.reason, noona_ui_pkg.status_badge(g.status_code) as status_html',
    '  from sec_role_grant g join sec_role r on r.id = g.role_id',
    '  left join sec_data_scope s on s.role_grant_id = g.id',
    ' where g.membership_id = :P31_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ROLE_NAME', 'الدور', {}), ('CODE', 'الرمز', {}),
     ('SCOPE', 'نطاق البيانات', {}), ('EFFECTIVE_FROM', 'من', {'type': 'DATE'}), ('EFFECTIVE_TO', 'إلى', {'type': 'DATE'}),
     ('REASON', 'السبب', {}), ('STATUS_HTML', 'الحالة', {'html': True})], titled=True)
ga = p.static('منح دور / سحب / حالة الحساب', 30)
p.select('P31_ROLE_ID', ga, 10, 'الدور', lov_sql=ROLE_LOV)
p.select('P31_SCOPE_COMPANY', ga, 20, 'نطاق البيانات', lov_name='NOONA_COMPANIES', null_text='- كل شركات المؤسسة -')
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
    '                                           p_company_id => :P31_SCOPE_COMPANY, p_reason => :P31_REASON);',
    'end;'], when_button=b_grant, success='تم منح الدور')
p.process(40, 'AFTER_SUBMIT', 'Revoke Grant', 'noona_sec_admin_pkg.revoke_grant(p_grant_id => :P31_REVOKE_ID, p_reason => :P31_REASON);',
          when_button=b_revoke, success='تم سحب المنح')
p.process(50, 'AFTER_SUBMIT', 'Change Status',
          'noona_sec_admin_pkg.set_member_status(p_membership_id => :P31_ID, p_status => :P31_NEW_STATUS, p_reason => :P31_REASON);',
          when_button=b_status, success='تم تغيير حالة الحساب')
p.branch(10, 'f?p=&APP_ID.:31:&SESSION.::&DEBUG.::P31_ID:&P31_ID.&success_msg=#SUCCESS_MSG#')

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
    '  from sec_role where id = :P33_ID;'])
p.process(10, 'AFTER_SUBMIT', 'Role Status', 'noona_sec_admin_pkg.set_role_status(:P33_ID, :P33_NEW_STATUS);',
          when_button=b_status, success='تم تغيير حالة الدور')
p.ir('صلاحيات الدور', 20, [
    'select rp.id, p.module_code, p.permission_code, p.name_ar, p.action_code, noona_ui_pkg.code_label(rp.effect) as effect, p.risk_level',
    '  from sec_role_permission rp join sec_permission p on p.id = rp.permission_id',
    ' where rp.role_id = :P33_ID'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('MODULE_CODE', 'الوحدة', {}), ('PERMISSION_CODE', 'رمز الصلاحية', {}),
     ('NAME_AR', 'الصلاحية', {}), ('ACTION_CODE', 'الفعل', {}), ('EFFECT', 'الأثر', {}), ('RISK_LEVEL', 'الخطورة', {})], titled=True)
f = p.static('إضافة صلاحيات', 30)
p.select('P33_MODULE', f, 10, 'الوحدة', lov_sql=(
    "select module_code || ' - ' || name_ar d, module_code r from plt_module order by package_no"))
ACTION_PRESETS = [('عرض فقط', 'VIEW'), ('عرض وتصدير وطباعة', 'VIEW,EXPORT,PRINT'),
                  ('إدخال (عرض وإنشاء وتعديل)', 'VIEW,CREATE,UPDATE'),
                  ('إدخال وإرسال للاعتماد', 'VIEW,CREATE,UPDATE,SUBMIT,PRINT,EXPORT'),
                  ('اعتماد ورفض', 'VIEW,APPROVE,REJECT'), ('ترحيل وعكس', 'VIEW,POST,REVERSE'),
                  ('كل الأفعال', 'VIEW,CREATE,UPDATE,DELETE,EXPORT,PRINT,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL')]
p.select('P33_ACTIONS', f, 20, 'الأفعال', null_text=None, lov_sql='select d, r from (' + ' union all '.join(
    f"select '{d}' d, '{r}' r, {i} s from dual" for i, (d, r) in enumerate(ACTION_PRESETS)) + ') order by s')
p.select('P33_EFFECT', f, 30, 'الأثر', null_text=None, lov_sql='STATIC2:سماح;ALLOW,منع;DENY')
p.text('P33_PERMISSION_CODE', f, 40, 'أو صلاحية محددة (رمز)', maxlen=150)
b_mod = p.button(f, 10, 'ADD_MODULE', 'إضافة صلاحيات الوحدة', hot=True)
b_one = p.button(f, 20, 'ADD_ONE', 'إضافة الصلاحية المحددة')
p.select('P33_REMOVE_ID', f, 50, 'إزالة صلاحية', lov_sql=(
    "select p.permission_code d, rp.id r from sec_role_permission rp join sec_permission p on p.id = rp.permission_id "
    "where rp.role_id = :P33_ID order by 1"))
b_rm = p.button(f, 30, 'REMOVE', 'إزالة')
p.process(20, 'AFTER_SUBMIT', 'Add Module Permissions', [
    'declare l_n number;',
    'begin',
    "    l_n := noona_sec_admin_pkg.add_module_permissions(:P33_ID, :P33_MODULE, :P33_ACTIONS, nvl(:P33_EFFECT, 'ALLOW'));",
    "    apex_application.g_print_success_message := 'تمت إضافة ' || l_n || ' صلاحية';",
    'end;'], when_button=b_mod)
p.process(30, 'AFTER_SUBMIT', 'Add One Permission',
          "noona_sec_admin_pkg.add_permission(:P33_ID, :P33_PERMISSION_CODE, nvl(:P33_EFFECT, 'ALLOW'));",
          when_button=b_one, success='تمت إضافة الصلاحية')
p.process(40, 'AFTER_SUBMIT', 'Remove Permission', 'noona_sec_admin_pkg.remove_permission(:P33_REMOVE_ID);',
          when_button=b_rm, success='تمت إزالة الصلاحية')
p.branch(10, 'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#')

sec = app.nav_item('المستخدمون والصلاحيات', None, 'fa-users', 40)
app.nav_item('المستخدمون', 30, 'fa-user', 41, parent=sec)
app.nav_item('الأدوار والصلاحيات', 32, 'fa-key', 42, parent=sec)

app.finalize()
print('NOONA_ADMIN built:', len(app.pages), 'pages')
