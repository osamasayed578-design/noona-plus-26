"""NOONA_HR (الموارد البشرية والرواتب): لوحة، ملفات الموظفين (البيانات والوظيفة وهيكل الراتب والحركات)، الإجازات واعتمادها،
الحضور والإضافي، تشغيلات الرواتب (الحساب والمراجعة والاعتماد والترحيل والصرف وملف WPS)، المدخلات المتغيرة، السلف، قسيمة الراتب،
مخالصة نهاية الخدمة، التقارير، الإعدادات.
الاستخدام: python3 tools/build_hr.py  ->  apex/NOONA_HR/f137
المنطق كله في NOONA_HR_PKG و NOONA_PAY_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_HR/f137'),
          app_id=137, alias='NOONA_HR', name='NOONA HR & Payroll', id_base=91820272000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']
# الرواتب سرية: صفحاتها لمن يملك عرض تشغيلات الرواتب
PAY = app.add_scheme('noona_pay_view', app.id(), 'NOONA - Payroll',
                     "return noona_security_pkg.has_permission('PAY_RUN.VIEW', noona_pay_pkg.company) = 'Y';",
                     'صفحات الرواتب تتطلب صلاحية عرض الرواتب / Payroll access required')
HR = app.add_scheme('noona_hr_view', app.id(), 'NOONA - HR',
                    "return noona_security_pkg.has_permission('HR_EMPLOYEE.VIEW', noona_hr_pkg.company) = 'Y';",
                    'صفحات الموارد البشرية تتطلب صلاحية عرض الموظفين / HR access required')


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


READY = "noona_pay_pkg.is_ready = 'Y'"
EMP_LOV = ("select e.employee_no || ' - ' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
           "where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_hr_pkg.company "
           "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED')) order by e.employee_no")
EMPLOYMENT_LOV = ("select noona_hr_pkg.employment_label(m.id) d, m.id r from hr_employment m where m.company_id = noona_hr_pkg.company "
                  "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED') "
                  "and exists (select 1 from pay_employee_element x where x.employment_id = m.id) order by 1")
COUNTRY_LOV = "select name_ar d, country_code r from ref_country where is_active = 'Y' order by nvl(sort_order, 999), name_ar"
UNIT_LOV = "select name_ar d, id r from org_unit where company_id = noona_hr_pkg.company and status_code = 'ACTIVE' order by name_ar"
BRANCH_LOV = "select name_ar d, id r from org_branch where company_id = noona_hr_pkg.company and status_code = 'ACTIVE' order by name_ar"
CC_LOV = "select code || ' - ' || name_ar d, id r from gl_cost_center where company_id = noona_hr_pkg.company order by code"
BANK_LOV = "select name_ar d, id r from ref_bank where is_active = 'Y' order by name_ar"
COMPANY_BANK_LOV = ("select code || ' - ' || name_ar d, id r from csh_bank_account where company_id = noona_pay_pkg.company "
                    "and status_code = 'ACTIVE' order by code")
PERIOD_LOV = ("select p.period_code || case when exists (select 1 from pay_run r where r.period_id = p.id and r.run_type = 'REGULAR') "
              "then ' (له تشغيل)' end d, p.id r from pay_period p where p.company_id = noona_pay_pkg.company "
              "and p.payroll_group_id = noona_pay_pkg.default_group order by p.start_date desc")
LEAVE_TYPE_LOV = ("select max(name_ar) keep (dense_rank first order by case when tenant_id is null then 1 else 0 end) d, code r "
                  "from hr_leave_type where is_active = 'Y' group by code order by min(id)")
METHOD_LOV = 'STATIC2:مبلغ ثابت;FIXED,نسبة من الأساسي;PERCENT,حسب سياسة الشركة;POLICY'
EL_METHOD_LOV = 'STATIC2:مبلغ ثابت;FIXED,نسبة من عنصر;PERCENT,حسب سياسة الشركة;POLICY,مستثنى (لا يصرف);EXCLUDED'
# عناصر الراتب الثابتة (للموظف وللسياسة)، والأساس للنسب
REC_EL_LOV = ("select name_ar || case when element_type <> 'EARNING' then ' (استقطاع)' end d, code r from pay_element "
              "where is_active = 'Y' and is_recurring = 'Y' and element_type in ('EARNING', 'DEDUCTION') order by sort_order, name_ar")
ALLOW_EL_LOV = REC_EL_LOV.replace("element_type in ('EARNING', 'DEDUCTION')", "element_type in ('EARNING', 'DEDUCTION') and code <> 'BASIC'")
BASIS_LOV = ("select name_ar d, code r from pay_element where is_active = 'Y' and element_type = 'EARNING' and is_recurring = 'Y' "
             "order by case code when 'BASIC' then 0 else 1 end, sort_order")
CAT_LOV = ("select noona_hr_pkg.category_label(c) d, c r from (select noona_hr_pkg.category_for(noona_hr_pkg.company_country) c, 1 o from dual "
           "union all select noona_hr_pkg.category_for('ZZ'), 2 from dual) order by o")
TYPE_LOV = ('STATIC2:دائم;PERMANENT,محدد المدة;FIXED_TERM,دوام جزئي;PART_TIME,مؤقت;TEMPORARY,متدرب;INTERN,مستشار;CONSULTANT')
EMP_SQL = [
    "select m.id, e.employee_no, p.display_name_ar as name_ar, m.job_title, u.name_ar as unit_name,",
    "       case when noona_hr_pkg.is_citizen(m.employee_category) = 'Y' then noona_hr_pkg.category_label(m.employee_category) else nvl(c.name_ar, e.nationality) end as nationality,",
    "       to_char(m.start_date, 'YYYY-MM-DD') as hire_date, round(noona_hr_pkg.service_years(m.id), 1) as years,",
    "       noona_pay_pkg.monthly_wage(m.id) as wage, noona_hr_pkg.leave_available(m.employee_id) as leave_bal,",
    "       '<span class=\"nn-badge ' || case m.status_code when 'ACTIVE' then 'is-success' when 'TERMINATED' then 'is-danger' else 'is-warning' end",
    "       || '\">' || noona_hr_pkg.status_label(m.status_code) || '</span>' as status_html",
    "  from hr_employment m join hr_employee e on e.id = m.employee_id join pty_party p on p.id = e.person_party_id",
    "  left join org_unit u on u.id = m.org_unit_id left join ref_country c on c.country_code = e.nationality",
    " where m.company_id = noona_hr_pkg.company and exists (select 1 from pay_employee_element x where x.employment_id = m.id)"]
EMP_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('EMPLOYEE_NO', 'الرقم الوظيفي', {}), ('NAME_AR', 'الاسم', {}),
            ('JOB_TITLE', 'المسمى', {}), ('UNIT_NAME', 'الإدارة', {}), ('NATIONALITY', 'الجنسية', {}), ('HIRE_DATE', 'التعيين', {}),
            ('YEARS', 'الخدمة (سنة)', {'type': 'NUMBER'}), ('WAGE', 'الراتب الشهري', {'type': 'NUMBER'}),
            ('LEAVE_BAL', 'رصيد الإجازة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})]

# =============================================================== 1) اللوحة
p = app.page(1, 'Home', 'HOME', 'الموارد البشرية والرواتب', scheme=TENANT)
st = p.static('تجهيز الموارد البشرية والرواتب', 5, condition="noona_pay_pkg.is_ready = 'N'",
              text='<p class="nn-hint">ينشئ حسابات التأمينات الاجتماعية والمخصصات (نهاية الخدمة والإجازات)، ومجموعة الرواتب الشهرية '
                   'وفترات السنة، والوردية الرسمية، والترقيم. مرة واحدة لكل شركة.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز الموارد البشرية والرواتب', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_pay_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم التجهيز: الحسابات 2108 و2109 و5214 و5215 و5216، ومجموعة الرواتب الشهرية وفترات السنة')
p.dynamic('مؤشرات الموارد البشرية', 10, 'return noona_hr_pkg.hr_summary;', hide_header=True)
p.dynamic('مؤشرات الرواتب', 12, 'return noona_pay_pkg.pay_summary;', hide_header=True,
          condition=READY + " and noona_security_pkg.has_permission('PAY_RUN.VIEW', noona_pay_pkg.company) = 'Y'")
qa = p.static('إجراءات سريعة', 15)
p.button(qa, 10, 'NEW_EMP', 'موظف جديد', hot=True, redirect=url(11, clear='RP,11'))
p.button(qa, 20, 'LEAVE', 'طلب إجازة', redirect=url(21, clear='RP,21'))
p.button(qa, 30, 'ATT', 'الحضور والإضافي', redirect=url(25))
p.button(qa, 40, 'RUNS', 'تشغيلات الرواتب', redirect=url(40))
p.button(qa, 50, 'EOS', 'نهاية الخدمة', redirect=url(50, clear='RP,50'))
p.ir('طلبات الإجازة بانتظار الاعتماد', 20, [
    "select r.id, r.doc_no, noona_hr_pkg.employee_name(r.employee_id) as emp, t.name_ar as leave_type,",
    "       to_char(r.start_date, 'YYYY-MM-DD') as from_d, to_char(r.end_date, 'YYYY-MM-DD') as to_d, r.duration",
    "  from hr_leave_request r join hr_leave_type t on t.id = r.leave_type_id",
    " where r.status_code = 'SUBMITTED' and exists (select 1 from hr_employment m where m.employee_id = r.employee_id",
    "   and m.company_id = noona_hr_pkg.company) order by r.start_date"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الطلب', {}), ('EMP', 'الموظف', {}), ('LEAVE_TYPE', 'النوع', {}),
     ('FROM_D', 'من', {}), ('TO_D', 'إلى', {}), ('DURATION', 'المدة', {'type': 'NUMBER'})], link=url(20), titled=True, rows=10)
p.dynamic('مستندات تنتهي قريباً (الهويات والعقود والتجربة)', 30, 'return noona_hr_pkg.expiring_report(60);')
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) الموظفون
p = app.page(10, 'Employees', 'EMPLOYEES', 'الموظفون', scheme=HR)
p.ir('الموظفون', 10, EMP_SQL + [" order by e.employee_no"], EMP_COLS, link=link(11, 'P11_ID'))
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'موظف جديد', hot=True, redirect=url(11, clear='RP,11'))

# =============================================================== 11) ملف الموظف
p = app.page(11, 'Employee', 'EMPLOYEE', 'ملف الموظف', scheme=HR)
p.dynamic('بطاقة الموظف', 5, 'return noona_hr_pkg.employee_card(:P11_ID);', hide_header=True, condition=':P11_ID is not null')
f = p.static('البيانات الشخصية', 10)
p.hidden('P11_ID', f, 1)
p.text('P11_NAME_AR', f, 10, 'الاسم الكامل بالعربية', required=True, maxlen=200)
p.text('P11_NAME_EN', f, 20, 'الاسم بالإنجليزية', maxlen=200)
p.select('P11_NATIONALITY', f, 30, 'الجنسية', lov_sql=COUNTRY_LOV, null_text=None)
p.text('P11_NATIONAL_ID', f, 40, 'رقم الهوية / الإقامة', maxlen=10, width=15)
p.date('P11_ID_EXPIRY', f, 50, 'انتهاء الهوية / الإقامة')
p.select('P11_GENDER', f, 60, 'الجنس', lov_sql='STATIC2:ذكر;M,أنثى;F')
p.date('P11_BIRTH', f, 70, 'تاريخ الميلاد')
p.text('P11_MOBILE', f, 80, 'الجوال', maxlen=20, width=15)
p.text('P11_EMAIL', f, 90, 'البريد الإلكتروني', maxlen=200)
j = p.static('الوظيفة والراتب البنكي', 20)
p.date('P11_HIRE', j, 10, 'تاريخ المباشرة', required=True)
p.select('P11_TYPE', j, 20, 'نوع التوظيف', lov_sql=TYPE_LOV, null_text=None)
p.text('P11_JOB', j, 30, 'المسمى الوظيفي', maxlen=200)
p.select('P11_UNIT', j, 40, 'الإدارة / القسم', lov_sql=UNIT_LOV)
p.select('P11_BRANCH', j, 50, 'الفرع', lov_sql=BRANCH_LOV)
p.select('P11_CC', j, 60, 'مركز التكلفة', lov_sql=CC_LOV)
p.select('P11_MANAGER', j, 70, 'المدير المباشر', lov_sql=EMP_LOV)
p.select('P11_BANK', j, 80, 'بنك الراتب', lov_sql=BANK_LOV)
p.text('P11_IBAN', j, 90, 'الآيبان (SA + 22 رقماً)', maxlen=34, width=30)
p.text('P11_GOSI', j, 100, 'رقم التأمينات الاجتماعية', maxlen=30, width=15)
p.number('P11_LEAVE_DAYS', j, 110, 'الإجازة السنوية (يوم)')
p.select('P11_CONTRACT_TYPE', j, 120, 'نوع العقد', lov_sql='STATIC2:غير محدد المدة;UNLIMITED,محدد المدة;FIXED_TERM,دوام جزئي;PART_TIME,مؤقت;TEMPORARY')
p.date('P11_CONTRACT_END', j, 130, 'نهاية العقد (المحدد المدة)')
s = p.static('هيكل الراتب الشهري', 30, condition=':P11_ID is null',
             text='<p class="nn-hint">لكل بدل: مبلغ ثابت، أو نسبة من الأساسي (اكتب النسبة مثل 25)، أو «حسب سياسة الشركة» '
                  'المعرفة في الإعدادات لكل شركة أو دولة. البدلات التلقائية في السياسة تضاف دون إدخال. '
                  'بعد التعيين يعدل أي عنصر من «هيكل الراتب» بحركة مؤرخة.</p>')
p.number('P11_BASIC', s, 10, 'الراتب الأساسي', required=True)
for k, (item, label) in enumerate([('HOUSING', 'بدل السكن'), ('TRANSPORT', 'بدل النقل'), ('OTHER', 'بدلات أخرى')]):
    p.select(f'P11_{item}_M', s, 20 + k * 10, f'{label}: الطريقة', lov_sql=METHOD_LOV, null_text='- لا يوجد -')
    p.number(f'P11_{item}', s, 25 + k * 10, f'{label}: المبلغ أو النسبة %')
sv = p.static('حفظ', 40, hide_header=True)
b_save = p.button(sv, 10, 'SAVE', 'حفظ الملف', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    if :P11_ID is not null then',
    '        select p.display_name_ar, p.display_name_en, e.nationality, e.national_id, to_char(e.id_expiry_date, \'YYYY-MM-DD\'), e.gender,',
    "               to_char(e.birth_date, 'YYYY-MM-DD'), e.work_mobile, e.work_email, to_char(m.start_date, 'YYYY-MM-DD'), m.employment_type,",
    '               m.job_title, m.org_unit_id, m.branch_id, m.cost_center_id, m.manager_employee_id, m.bank_id, m.iban, m.gosi_no,',
    "               m.annual_leave_days, (select max(c.contract_type) from hr_contract c where c.employment_id = m.id and c.status_code = 'ACTIVE'),",
    "               (select to_char(max(c.end_date), 'YYYY-MM-DD') from hr_contract c where c.employment_id = m.id and c.status_code = 'ACTIVE')",
    '          into :P11_NAME_AR, :P11_NAME_EN, :P11_NATIONALITY, :P11_NATIONAL_ID, :P11_ID_EXPIRY, :P11_GENDER, :P11_BIRTH, :P11_MOBILE,',
    '               :P11_EMAIL, :P11_HIRE, :P11_TYPE, :P11_JOB, :P11_UNIT, :P11_BRANCH, :P11_CC, :P11_MANAGER, :P11_BANK, :P11_IBAN, :P11_GOSI,',
    '               :P11_LEAVE_DAYS, :P11_CONTRACT_TYPE, :P11_CONTRACT_END',
    '          from hr_employment m join hr_employee e on e.id = m.employee_id join pty_party p on p.id = e.person_party_id',
    '         where m.id = :P11_ID and m.company_id = noona_hr_pkg.company;',
    '    else',
    "        :P11_HIRE := nvl(:P11_HIRE, to_char(sysdate, 'YYYY-MM-DD'));",
    "        :P11_NATIONALITY := nvl(:P11_NATIONALITY, noona_hr_pkg.company_country);",
    "        :P11_LEAVE_DAYS := nvl(:P11_LEAVE_DAYS, case when noona_hr_pkg.company_country = 'SA' then 21 end);",
    "        :P11_HOUSING_M := nvl(:P11_HOUSING_M, 'FIXED'); :P11_TRANSPORT_M := nvl(:P11_TRANSPORT_M, 'FIXED');",
    '    end if;',
    "    :P11_SAL_DATE := nvl(:P11_SAL_DATE, to_char(add_months(trunc(sysdate, 'MM'), 1), 'YYYY-MM-DD'));",
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare',
    '    l_doc clob;',
    '    l_o   json_object_t;',
    '    l_s   json_object_t := json_object_t();',
    '    procedure el(p_code varchar2, p_method varchar2, p_value varchar2) is',
    '        l json_object_t := json_object_t();',
    '    begin',
    "        if p_method is null or (p_method <> 'POLICY' and p_value is null) then return; end if;",
    "        l.put('method', p_method);",
    "        if p_value is not null then l.put('value', to_number(p_value)); end if;",
    '        l_s.put(p_code, l);',
    '    end;',
    'begin',
    "    select json_object('id' value to_number(:P11_ID), 'name_ar' value :P11_NAME_AR, 'name_en' value :P11_NAME_EN,",
    "                       'nationality' value :P11_NATIONALITY, 'national_id' value :P11_NATIONAL_ID, 'id_expiry' value :P11_ID_EXPIRY,",
    "                       'gender' value :P11_GENDER, 'birth_date' value :P11_BIRTH, 'mobile' value :P11_MOBILE, 'email' value :P11_EMAIL,",
    "                       'hire_date' value :P11_HIRE, 'type' value :P11_TYPE, 'job_title' value :P11_JOB, 'unit' value to_number(:P11_UNIT),",
    "                       'branch' value to_number(:P11_BRANCH), 'cost_center' value to_number(:P11_CC), 'manager' value to_number(:P11_MANAGER),",
    "                       'bank' value to_number(:P11_BANK), 'iban' value :P11_IBAN, 'gosi_no' value :P11_GOSI,",
    "                       'leave_days' value to_number(:P11_LEAVE_DAYS), 'contract_type' value :P11_CONTRACT_TYPE, 'contract_end' value :P11_CONTRACT_END",
    '                       returning clob) into l_doc from dual;',
    '    if :P11_ID is null then',
    '        l_o := json_object_t.parse(l_doc);',
    "        l_s.put('BASIC', to_number(:P11_BASIC));",
    "        el('HOUSING', :P11_HOUSING_M, :P11_HOUSING);",
    "        el('TRANSPORT', :P11_TRANSPORT_M, :P11_TRANSPORT);",
    "        el('OTHER_ALLOW', :P11_OTHER_M, :P11_OTHER);",
    "        l_o.put('salary', l_s);",
    '        l_doc := l_o.to_clob;',
    '    end if;',
    '    :P11_ID := noona_hr_pkg.save_employee(l_doc);',
    'end;'], when_button=b_save, success='تم حفظ ملف الموظف')
# هيكل الراتب: كل عنصر بطريقته (ثابت / نسبة / سياسة الشركة / مستثنى) وتعديله بحركة مؤرخة
p.dynamic('هيكل الراتب', 45, 'return noona_pay_pkg.structure_html(:P11_ID);', condition=':P11_ID is not null')
sc = p.static('تعديل عنصر في الراتب (حركة مؤرخة)', 50, condition=':P11_ID is not null',
              text='<p class="nn-hint">مثال: بدل السكن نسبة 25 من الأساسي، أو بدل النقل حسب سياسة الشركة، أو استثناء الموظف من بدل تلقائي. '
                   'تعديل الأساسي يغير البدلات المحسوبة كنسبة منه تلقائياً.</p>')
p.select('P11_EL', sc, 10, 'العنصر', lov_sql=REC_EL_LOV)
p.select('P11_EL_M', sc, 20, 'طريقة الاحتساب', lov_sql=EL_METHOD_LOV, null_text=None)
p.number('P11_EL_V', sc, 30, 'المبلغ أو النسبة %')
p.select('P11_EL_BASIS', sc, 40, 'النسبة من', lov_sql=BASIS_LOV, null_text=None)
p.date('P11_SAL_DATE', sc, 50, 'يسري من')
p.text('P11_SAL_REASON', sc, 60, 'السبب (ترقية، علاوة سنوية...)', maxlen=500)
b_sal = p.button(sc, 10, 'CHANGE_SALARY', 'اعتماد التعديل')
p.process(20, 'AFTER_SUBMIT', 'Change Salary', [
    'declare l_id number;', 'begin',
    "    l_id := noona_hr_pkg.set_element(:P11_ID, :P11_EL, :P11_EL_M, to_number(:P11_EL_V), :P11_EL_BASIS,",
    "                                     to_date(:P11_SAL_DATE, 'YYYY-MM-DD'), :P11_SAL_REASON);",
    'end;'], when_button=b_sal, success='تم تعديل الراتب بحركة مؤرخة')
tr = p.static('نقل / تغيير المسمى', 60, condition=':P11_ID is not null')
p.select('P11_TR_UNIT', tr, 10, 'الإدارة الجديدة', lov_sql=UNIT_LOV)
p.select('P11_TR_BRANCH', tr, 20, 'الفرع الجديد', lov_sql=BRANCH_LOV)
p.select('P11_TR_CC', tr, 30, 'مركز التكلفة الجديد', lov_sql=CC_LOV)
p.text('P11_TR_JOB', tr, 40, 'المسمى الجديد', maxlen=200)
p.select('P11_TR_MGR', tr, 50, 'المدير الجديد', lov_sql=EMP_LOV)
p.text('P11_TR_REASON', tr, 60, 'السبب', maxlen=500)
b_tr = p.button(tr, 10, 'TRANSFER', 'اعتماد النقل')
p.process(30, 'AFTER_SUBMIT', 'Transfer', [
    'declare l_id number;', 'begin',
    '    l_id := noona_hr_pkg.transfer(:P11_ID, trunc(sysdate), :P11_TR_UNIT, :P11_TR_BRANCH, :P11_TR_CC, :P11_TR_JOB, :P11_TR_MGR, :P11_TR_REASON);',
    'end;'], when_button=b_tr, success='تم النقل وتسجيل الحركة')
p.ir('الإجازات', 70, [
    "select r.id, r.doc_no, t.name_ar as leave_type, to_char(r.start_date, 'YYYY-MM-DD') as from_d, to_char(r.end_date, 'YYYY-MM-DD') as to_d,",
    "       r.duration, noona_hr_pkg.status_label(r.status_code) as status",
    "  from hr_leave_request r join hr_leave_type t on t.id = r.leave_type_id join hr_employment m on m.employee_id = r.employee_id",
    " where m.id = :P11_ID order by r.start_date desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الطلب', {}), ('LEAVE_TYPE', 'النوع', {}), ('FROM_D', 'من', {}),
     ('TO_D', 'إلى', {}), ('DURATION', 'المدة', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], titled=True, rows=10)
p.ir('قسائم الرواتب', 80, [
    "select re.id, pp.period_code, r.run_no, re.gross_amount, re.deduction_amount, re.net_amount, noona_pay_pkg.status_label(r.status_code) as status",
    "  from pay_run_employee re join pay_run r on r.id = re.run_id join pay_period pp on pp.id = r.period_id",
    " where re.employment_id = :P11_ID and noona_security_pkg.has_permission('PAY_RUN.VIEW', noona_pay_pkg.company) = 'Y'",
    " order by pp.start_date desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PERIOD_CODE', 'الفترة', {}), ('RUN_NO', 'التشغيل', {}),
     ('GROSS_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}), ('DEDUCTION_AMOUNT', 'الخصومات', {'type': 'NUMBER'}),
     ('NET_AMOUNT', 'الصافي', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], link=link(45, 'P45_ID'), titled=True, rows=12)
p.branch(10, url(11, 'P11_ID', '&P11_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) الإجازات
p = app.page(20, 'Leaves', 'LEAVES', 'الإجازات', scheme=HR)
ap = p.static('الاعتماد', 5)
p.select('P20_PENDING', ap, 10, 'طلب بانتظار الاعتماد', lov_sql=(
    "select r.doc_no || ' · ' || noona_hr_pkg.employee_name(r.employee_id) || ' · ' || t.name_ar || ' ' || to_char(r.start_date, 'YYYY-MM-DD')"
    " || ' (' || r.duration || ')' d, r.id r from hr_leave_request r join hr_leave_type t on t.id = r.leave_type_id"
    " where r.status_code in ('SUBMITTED', 'APPROVED') and exists (select 1 from hr_employment m where m.employee_id = r.employee_id"
    " and m.company_id = noona_hr_pkg.company) order by r.status_code desc, r.start_date"))
p.text('P20_REASON', ap, 20, 'السبب (للرفض أو الإلغاء)', maxlen=500)
b1 = p.button(ap, 10, 'APPROVE', 'اعتماد', hot=True)
b2 = p.button(ap, 20, 'REJECT', 'رفض')
b3 = p.button(ap, 30, 'CANCEL_LEAVE', 'إلغاء إجازة معتمدة')
b4 = p.button(ap, 40, 'NEW', 'طلب إجازة', redirect=url(21, clear='RP,21'))
p.process(10, 'AFTER_SUBMIT', 'Approve', 'noona_hr_pkg.approve_leave(:P20_PENDING);', when_button=b1, success='تم اعتماد الإجازة وخصمها من الرصيد')
p.process(20, 'AFTER_SUBMIT', 'Reject', 'noona_hr_pkg.reject_leave(:P20_PENDING, :P20_REASON);', when_button=b2, success='تم رفض الطلب')
p.process(30, 'AFTER_SUBMIT', 'Cancel', 'noona_hr_pkg.cancel_leave(:P20_PENDING, :P20_REASON);', when_button=b3, success='تم إلغاء الإجازة وإعادة الرصيد')
p.ir('طلبات الإجازات', 10, [
    "select r.id, r.doc_no, noona_hr_pkg.employee_name(r.employee_id) as emp, t.name_ar as leave_type,",
    "       to_char(r.start_date, 'YYYY-MM-DD') as from_d, to_char(r.end_date, 'YYYY-MM-DD') as to_d, r.duration,",
    "       '<span class=\"nn-badge ' || case r.status_code when 'APPROVED' then 'is-success' when 'SUBMITTED' then 'is-warning'",
    "       when 'REJECTED' then 'is-danger' else 'is-muted' end || '\">' || noona_hr_pkg.status_label(r.status_code) || '</span>' as status_html,",
    "       r.reason, r.created_by",
    "  from hr_leave_request r join hr_leave_type t on t.id = r.leave_type_id",
    " where exists (select 1 from hr_employment m where m.employee_id = r.employee_id and m.company_id = noona_hr_pkg.company)",
    " order by r.start_date desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الطلب', {}), ('EMP', 'الموظف', {}), ('LEAVE_TYPE', 'النوع', {}),
     ('FROM_D', 'من', {}), ('TO_D', 'إلى', {}), ('DURATION', 'المدة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True}),
     ('REASON', 'السبب', {}), ('CREATED_BY', 'أدخله', {})])
p.branch(10, url(20, clear='20') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 21) طلب إجازة
p = app.page(21, 'Leave Request', 'LEAVE-REQUEST', 'طلب إجازة', scheme=HR)
f = p.static('طلب إجازة', 10, text='<p class="nn-hint">الإجازة السنوية 21 يوماً (30 بعد خمس سنوات خدمة) تستحق يومياً؛ '
                                    'الاستئذان بالساعات في يوم واحد. الإجازة غير المدفوعة تخصم من الراتب.</p>')
p.select('P21_EMP', f, 10, 'الموظف', lov_sql=EMP_LOV, required=True, submit=True)
p.select('P21_TYPE', f, 20, 'نوع الإجازة', lov_sql=LEAVE_TYPE_LOV, null_text=None, submit=True)
p.date('P21_FROM', f, 30, 'من تاريخ', required=True)
p.date('P21_TO', f, 40, 'إلى تاريخ')
p.text('P21_T1', f, 50, 'من الساعة (للاستئذان) HH:MI', maxlen=5, width=6)
p.text('P21_T2', f, 60, 'إلى الساعة', maxlen=5, width=6)
p.select('P21_SUB', f, 70, 'البديل أثناء الإجازة', lov_sql=EMP_LOV)
p.textarea('P21_REASON', f, 80, 'السبب / الملاحظات')
p.dynamic('الرصيد المتاح', 20, [
    'begin',
    "    return '<div class=\"nn-hr-bal\">الرصيد المتاح: <b>' || nvl(noona_hr_pkg.fnum(noona_hr_pkg.leave_available(:P21_EMP, nvl(:P21_TYPE, 'ANNUAL')), 1), 'بلا حد سنوي')",
    "        || '</b></div>';",
    'end;'], condition=':P21_EMP is not null')
b = p.button(f, 10, 'SUBMIT_LEAVE', 'إرسال للاعتماد', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Request', [
    'declare l_id number; l_doc clob;', 'begin',
    "    select json_object('employee' value to_number(:P21_EMP), 'type' value nvl(:P21_TYPE, 'ANNUAL'), 'start' value :P21_FROM,",
    "                       'end' value nvl(:P21_TO, :P21_FROM), 'start_time' value :P21_T1, 'end_time' value :P21_T2,",
    "                       'substitute' value to_number(:P21_SUB), 'reason' value :P21_REASON returning clob) into l_doc from dual;",
    '    l_id := noona_hr_pkg.request_leave(l_doc);',
    'end;'], when_button=b, success='تم إرسال طلب الإجازة للاعتماد')
p.branch(10, url(20) + '&success_msg=#SUCCESS_MSG#', when_button=b)
p.branch(20, url(21, 'P21_EMP,P21_TYPE,P21_FROM,P21_TO', '&P21_EMP.,&P21_TYPE.,&P21_FROM.,&P21_TO.'))

# =============================================================== 25) الحضور والإضافي
p = app.page(25, 'Attendance', 'ATTENDANCE', 'الحضور والعمل الإضافي', scheme=HR)
f = p.static('تسجيل الحضور', 10, text='<p class="nn-hint">الدوام الرسمي من الإعدادات (08:00 – 17:00 باستراحة ساعة وسماحية 15 دقيقة). '
                                       'الغياب يخصم من الراتب بالأجر اليومي.</p>')
p.select('P25_EMP', f, 10, 'الموظف', lov_sql=EMP_LOV, required=True)
p.date('P25_DATE', f, 20, 'التاريخ', required=True)
p.text('P25_IN', f, 30, 'الدخول HH:MI', maxlen=5, width=6)
p.text('P25_OUT', f, 40, 'الخروج HH:MI', maxlen=5, width=6)
b_in = p.button(f, 10, 'RECORD', 'تسجيل الحضور', hot=True)
b_abs = p.button(f, 20, 'ABSENT', 'تسجيل غياب')
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P25_DATE := nvl(:P25_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
                                            ":P25_MONTH := nvl(:P25_MONTH, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));"])
p.process(10, 'AFTER_SUBMIT', 'Record', ['declare l_id number;', 'begin',
          "    l_id := noona_hr_pkg.record_attendance(:P25_EMP, to_date(:P25_DATE, 'YYYY-MM-DD'), :P25_IN, :P25_OUT);", 'end;'],
          when_button=b_in, success='تم تسجيل الحضور')
p.process(20, 'AFTER_SUBMIT', 'Absent', ['declare l_id number;', 'begin',
          "    l_id := noona_hr_pkg.mark_absent(:P25_EMP, to_date(:P25_DATE, 'YYYY-MM-DD'));", 'end;'],
          when_button=b_abs, success='تم تسجيل الغياب')
o = p.static('طلب عمل إضافي', 20)
p.select('P25_OT_EMP', o, 10, 'الموظف', lov_sql=EMP_LOV)
p.date('P25_OT_DATE', o, 20, 'التاريخ')
p.number('P25_OT_HOURS', o, 30, 'الساعات')
p.text('P25_OT_REASON', o, 40, 'السبب', maxlen=500)
b_ot = p.button(o, 10, 'REQUEST_OT', 'طلب الإضافي')
p.process(30, 'AFTER_SUBMIT', 'Request OT', ['declare l_id number;', 'begin',
          "    l_id := noona_hr_pkg.request_overtime(:P25_OT_EMP, to_date(:P25_OT_DATE, 'YYYY-MM-DD'), :P25_OT_HOURS, :P25_OT_REASON);", 'end;'],
          when_button=b_ot, success='تم إرسال طلب الإضافي')
oa = p.static('اعتماد الإضافي', 30)
p.select('P25_OT_PENDING', oa, 10, 'طلب معلق', lov_sql=(
    "select noona_hr_pkg.employee_name(employee_id) || ' · ' || to_char(work_date, 'YYYY-MM-DD') || ' · ' || planned_hours || ' ساعة' d, id r"
    " from hr_overtime_request where company_id = noona_hr_pkg.company and status_code = 'SUBMITTED' order by work_date"))
p.number('P25_OT_ACTUAL', oa, 20, 'الساعات الفعلية (اختياري)')
b_oa = p.button(oa, 10, 'APPROVE_OT', 'اعتماد', hot=True)
b_or = p.button(oa, 20, 'REJECT_OT', 'رفض')
p.process(40, 'AFTER_SUBMIT', 'Approve OT', 'noona_hr_pkg.approve_overtime(:P25_OT_PENDING, :P25_OT_ACTUAL);', when_button=b_oa,
          success='تم اعتماد الإضافي؛ يدخل في رواتب الفترة')
p.process(50, 'AFTER_SUBMIT', 'Reject OT', 'noona_hr_pkg.reject_overtime(:P25_OT_PENDING);', when_button=b_or, success='تم رفض الطلب')
m = p.static('الملخص الشهري', 40)
p.date('P25_MONTH', m, 10, 'الشهر (أي يوم فيه)')
p.button(m, 10, 'SHOW', 'عرض')
p.dynamic('ملخص الحضور', 50, "return noona_hr_pkg.attendance_report(to_date(:P25_MONTH, 'YYYY-MM-DD'));", hide_header=True)
p.branch(10, url(25, 'P25_MONTH', '&P25_MONTH.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) السلف والقروض
p = app.page(30, 'Loans', 'LOANS', 'السلف والقروض', scheme=PAY)
f = p.static('سلفة / قرض جديد', 10, text='<p class="nn-hint">القسط لا يتجاوز نصف الأجر الشهري؛ يخصم آلياً من رواتب الفترات '
                                         'المجدولة، والرصيد كاملاً من مخالصة نهاية الخدمة.</p>')
p.select('P30_EMP', f, 10, 'الموظف', lov_sql=EMPLOYMENT_LOV, required=True)
p.select('P30_TYPE', f, 20, 'النوع', lov_sql='STATIC2:سلفة راتب;SALARY_ADVANCE,قرض;LOAN,سلفة سكن;HOUSING_ADVANCE,أخرى;OTHER', null_text=None)
p.number('P30_AMOUNT', f, 30, 'المبلغ', required=True)
p.number('P30_COUNT', f, 40, 'عدد الأقساط', required=True)
p.select('P30_PERIOD', f, 50, 'بداية الخصم', lov_sql=PERIOD_LOV)
b_new = p.button(f, 10, 'CREATE_LOAN', 'إنشاء وجدولة الأقساط', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Create Loan', ['declare l_id number;', 'begin',
          '    l_id := noona_pay_pkg.create_loan(:P30_EMP, :P30_TYPE, :P30_AMOUNT, :P30_COUNT, :P30_PERIOD);', 'end;'],
          when_button=b_new, success='تم إنشاء السلفة وجدولة أقساطها؛ اصرفها لتصبح قائمة')
d = p.static('صرف السلفة', 20)
p.select('P30_PENDING', d, 10, 'سلفة بانتظار الصرف', lov_sql=(
    "select doc_no || ' · ' || noona_hr_pkg.employment_label(employment_id) || ' · ' || principal_amount d, id r from pay_loan"
    " where company_id = noona_pay_pkg.company and status_code = 'APPROVED' order by doc_date"))
p.select('P30_BANK', d, 20, 'من الحساب البنكي', lov_sql=COMPANY_BANK_LOV)
b_dis = p.button(d, 10, 'DISBURSE', 'صرف وترحيل', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Disburse', ['declare l_id number;', 'begin',
          '    l_id := noona_pay_pkg.disburse_loan(:P30_PENDING, :P30_BANK);', 'end;'],
          when_button=b_dis, success='تم صرف السلفة وترحيل قيدها (مدين سلف الموظفين / دائن البنك)')
p.dynamic('السلف القائمة', 30, 'return noona_pay_pkg.loans_report_html;')
p.branch(10, url(30, clear='30') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 40) تشغيلات الرواتب
p = app.page(40, 'Payroll Runs', 'PAYROLL-RUNS', 'تشغيلات الرواتب', scheme=PAY)
f = p.static('تشغيل جديد', 5, condition=READY)
p.select('P40_PERIOD', f, 10, 'الفترة', lov_sql=PERIOD_LOV, required=True)
b = p.button(f, 10, 'CREATE_RUN', 'إنشاء وحساب الرواتب', hot=True)
p.button(f, 20, 'INPUTS', 'المدخلات المتغيرة للفترة', redirect=url(42))
p.process(10, 'AFTER_SUBMIT', 'Create Run', ['declare l_n number;', 'begin',
          '    :P40_RUN := noona_pay_pkg.create_run(:P40_PERIOD);', '    l_n := noona_pay_pkg.calculate(:P40_RUN);', 'end;'], when_button=b)
p.hidden('P40_RUN', f, 20)
p.branch(5, url(41, 'P41_ID', '&P40_RUN.', 'RP,41'), when_button=b)
p.ir('التشغيلات', 10, [
    "select r.id, r.run_no, pp.period_code, case r.run_type when 'FINAL_SETTLEMENT' then 'مخالصة نهاية خدمة' else 'شهري' end as run_type,",
    "       r.employee_count, r.total_gross, r.total_deductions, r.total_net, r.total_employer_cost,",
    "       '<span class=\"nn-badge ' || case when r.status_code in ('PAID', 'CLOSED') then 'is-success' when r.status_code in ('POSTED', 'APPROVED')",
    "       then 'is-info' else 'is-warning' end || '\">' || noona_pay_pkg.status_label(r.status_code) || '</span>' as status_html",
    "  from pay_run r join pay_period pp on pp.id = r.period_id where r.company_id = noona_pay_pkg.company order by pp.start_date desc, r.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('RUN_NO', 'التشغيل', {}), ('PERIOD_CODE', 'الفترة', {}), ('RUN_TYPE', 'النوع', {}),
     ('EMPLOYEE_COUNT', 'الموظفون', {'type': 'NUMBER'}), ('TOTAL_GROSS', 'الإجمالي', {'type': 'NUMBER'}),
     ('TOTAL_DEDUCTIONS', 'الخصومات', {'type': 'NUMBER'}), ('TOTAL_NET', 'الصافي', {'type': 'NUMBER'}),
     ('TOTAL_EMPLOYER_COST', 'تكلفة المنشأة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(41, 'P41_ID'))

# =============================================================== 41) منضدة التشغيل
p = app.page(41, 'Payroll Run', 'PAYROLL-RUN', 'تشغيل الرواتب', scheme=PAY)
st = "noona_pay_pkg.run_status(:P41_ID)"
p.dynamic('الملخص', 5, 'return noona_pay_pkg.run_header_html(:P41_ID);', hide_header=True)
a = p.static('الإجراءات', 8, hide_header=True)
p.hidden('P41_ID', a, 1)
b_calc = p.button(a, 10, 'CALCULATE', 'إعادة الحساب', condition=f"{st} in ('OPEN', 'CALCULATED')")
b_app = p.button(a, 20, 'APPROVE', 'اعتماد الرواتب', hot=True, condition=f"{st} = 'CALCULATED'")
b_post = p.button(a, 30, 'POST', 'ترحيل القيد', hot=True, condition=f"{st} = 'APPROVED'")
b_del = p.button(a, 40, 'DELETE_RUN', 'حذف التشغيل', condition=f"{st} in ('OPEN', 'CALCULATED', 'APPROVED')")
p.button(a, 50, 'WPS', 'تنزيل ملف التحويل (WPS)', redirect=url(46, 'P46_RUN', '&P41_ID.'), condition=f"{st} = 'PAID'")
p.button(a, 60, 'INPUTS', 'المدخلات المتغيرة', redirect=url(42), condition=f"{st} in ('OPEN', 'CALCULATED')")
p.process(10, 'AFTER_SUBMIT', 'Calculate', ['declare l_n number;', 'begin', '    l_n := noona_pay_pkg.calculate(:P41_ID);', 'end;'],
          when_button=b_calc, success='تم حساب الرواتب')
p.process(20, 'AFTER_SUBMIT', 'Approve', 'noona_pay_pkg.approve_run(:P41_ID);', when_button=b_app, success='تم اعتماد الرواتب')
p.process(30, 'AFTER_SUBMIT', 'Post', ['declare l_j number;', 'begin', '    l_j := noona_pay_pkg.post_run(:P41_ID);', 'end;'],
          when_button=b_post, success='تم ترحيل قيد الرواتب ومخصصات نهاية الخدمة والإجازات')
p.process(40, 'AFTER_SUBMIT', 'Delete', 'noona_pay_pkg.delete_run(:P41_ID);', when_button=b_del, success='تم حذف التشغيل')
pay = p.static('صرف الرواتب', 9, condition=f"{st} = 'POSTED'")
p.select('P41_BANK', pay, 10, 'من الحساب البنكي', lov_sql=COMPANY_BANK_LOV)
b_pay = p.button(pay, 10, 'PAY', 'صرف وإنشاء ملف التحويل', hot=True)
p.process(50, 'AFTER_SUBMIT', 'Pay', ['declare l_f number;', 'begin', '    l_f := noona_pay_pkg.pay_out(:P41_ID, :P41_BANK);', 'end;'],
          when_button=b_pay, success='تم صرف الرواتب وترحيل قيد التحويل؛ نزّل ملف WPS للبنك')
p.dynamic('مسير الرواتب', 10, [
    'begin',
    "    return noona_pay_pkg.run_register_html(:P41_ID, replace(apex_page.get_url(p_page => 45, p_items => 'P45_ID',",
    "                                                     p_values => '990000000001'), '990000000001', '#ID#'));",
    'end;'], opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.dynamic('ملخص العناصر', 20, 'return noona_pay_pkg.element_summary_html(:P41_ID);', condition=f"{st} <> 'OPEN'")
p.dynamic('التأمينات الاجتماعية', 30, 'return noona_pay_pkg.gosi_report_html(:P41_ID);', condition=f"{st} <> 'OPEN'")
p.dynamic('التوزيع على مراكز التكلفة', 40, 'return noona_pay_pkg.cost_center_html(:P41_ID);', condition=f"{st} <> 'OPEN'")
p.branch(5, url(40) + '&success_msg=#SUCCESS_MSG#', when_button=b_del)
p.branch(10, url(41, 'P41_ID', '&P41_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 42) المدخلات المتغيرة
p = app.page(42, 'Payroll Inputs', 'PAYROLL-INPUTS', 'المدخلات المتغيرة', scheme=PAY)
f = p.static('إدخال', 10, text='<p class="nn-hint">الإضافي بالساعات (يحسب آلياً: ساعة الأجر + 50% من ساعة الأساسي) أو بمبلغ، '
                                 'والمكافآت والعمولات والجزاءات والخصومات بمبالغ، والغياب بالأيام.</p>')
p.select('P42_PERIOD', f, 10, 'الفترة', lov_sql=PERIOD_LOV, required=True, submit=True)
p.select('P42_EMP', f, 20, 'الموظف', lov_sql=EMPLOYMENT_LOV)
p.select('P42_ELEMENT', f, 30, 'العنصر', null_text=None, lov_sql=(
    'STATIC2:مكافأة;BONUS,عمولة;COMMISSION,عمل إضافي (ساعات);OVERTIME,بدلات أخرى (مرة واحدة);OTHER_ALLOW,'
    'جزاء;PENALTY,خصم آخر;OTHER_DED,غياب (أيام);ABSENCE'))
p.number('P42_QTY', f, 40, 'الكمية (ساعات / أيام)')
p.number('P42_AMOUNT', f, 50, 'المبلغ')
b_add = p.button(f, 10, 'ADD', 'إضافة', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', '    if :P42_PERIOD is null then',
          "        :P42_PERIOD := noona_pay_pkg.period_for(trunc(sysdate));", '    end if;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Add', ['declare l_id number;', 'begin',
          '    l_id := noona_pay_pkg.add_input(:P42_PERIOD, :P42_EMP, :P42_ELEMENT, :P42_QTY, :P42_AMOUNT);', 'end;'],
          when_button=b_add, success='تمت الإضافة؛ أعد حساب التشغيل إن كان محسوباً')
dl = p.static('حذف مدخل', 20)
p.select('P42_DEL', dl, 10, 'المدخل', lov_sql=(
    "select noona_hr_pkg.employment_label(i.employment_id) || ' · ' || e.name_ar || ' · ' || nvl(to_char(i.amount), i.quantity) d, i.id r"
    " from pay_input i join pay_element e on e.id = i.element_id where i.period_id = :P42_PERIOD and i.status_code in ('PENDING', 'VALIDATED')"))
b_del = p.button(dl, 10, 'DELETE', 'حذف')
p.process(20, 'AFTER_SUBMIT', 'Delete', 'noona_pay_pkg.delete_input(:P42_DEL);', when_button=b_del, success='تم الحذف')
p.ir('مدخلات الفترة', 30, [
    "select i.id, noona_hr_pkg.employment_label(i.employment_id) as emp, e.name_ar as element, i.quantity, i.amount,",
    "       case i.status_code when 'APPLIED' then 'مطبق' else 'بانتظار التشغيل' end as status, i.created_by",
    "  from pay_input i join pay_element e on e.id = i.element_id where i.period_id = :P42_PERIOD and i.company_id = noona_pay_pkg.company"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('EMP', 'الموظف', {}), ('ELEMENT', 'العنصر', {}),
     ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {}),
     ('CREATED_BY', 'أدخله', {})])
p.branch(10, url(42, 'P42_PERIOD', '&P42_PERIOD.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 45) قسيمة الراتب
p = app.page(45, 'Payslip', 'PAYSLIP', 'قسيمة الراتب', scheme=PAY, protection='N')
f = p.static('طباعة', 5, hide_header=True)
p.hidden('P45_ID', f, 1, protected=False)
p.button(f, 10, 'PRINT', 'طباعة القسيمة', hot=True, redirect='javascript:window.print();')
p.dynamic('القسيمة', 10, 'return noona_pay_pkg.payslip_html(:P45_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 46) تنزيل ملف التحويل
p = app.page(46, 'WPS File', 'WPS-FILE', 'ملف التحويل', scheme=PAY, protection='N')
f = p.static('الملف', 10, hide_header=True)
p.hidden('P46_RUN', f, 1, protected=False)
p.process(10, 'BEFORE_HEADER', 'Download', [
    'declare',
    '    l_c   clob;',
    '    l_off pls_integer := 1;',
    'begin',
    '    l_c := noona_pay_pkg.bank_file_csv(noona_pay_pkg.run_file(:P46_RUN));',
    "    owa_util.mime_header('text/csv', false, 'UTF-8');",
    "    htp.p('Content-Disposition: attachment; filename=\"WPS-' || :P46_RUN || '.csv\"');",
    '    owa_util.http_header_close;',
    "    htp.prn(unistr('\\FEFF'));",
    '    while l_off <= dbms_lob.getlength(l_c) loop',
    '        htp.prn(dbms_lob.substr(l_c, 8000, l_off));',
    '        l_off := l_off + 8000;',
    '    end loop;',
    '    apex_application.stop_apex_engine;',
    'exception',
    '    when apex_application.e_stop_apex_engine then',
    '        null;',
    'end;'])

# =============================================================== 50) نهاية الخدمة
p = app.page(50, 'End of Service', 'END-OF-SERVICE', 'مخالصة نهاية الخدمة', scheme=PAY)
f = p.static('حساب المخالصة', 10, text='<p class="nn-hint">المكافأة: نصف أجر شهر عن كل سنة من الخمس الأولى، وأجر شهر عن كل سنة بعدها '
                                        '(الأجر = الأساسي + السكن + النقل). الاستقالة: أقل من سنتين لا شيء، من 2 إلى 5 الثلث، من 5 إلى 10 الثلثان، '
                                        '10 فأكثر كاملة. يضاف بدل رصيد الإجازات وتخصم السلف القائمة.</p>')
p.hidden('P50_ID', f, 1)
p.select('P50_EMP', f, 10, 'الموظف', lov_sql=EMPLOYMENT_LOV, required=True)
p.date('P50_LAST', f, 20, 'آخر يوم عمل', required=True)
p.select('P50_TYPE', f, 30, 'سبب انتهاء الخدمة', null_text=None, lov_sql=(
    'STATIC2:انتهاء العقد;END_OF_CONTRACT,استقالة;RESIGNATION,إنهاء من صاحب العمل;TERMINATION,تقاعد;RETIREMENT,وفاة;DEATH,'
    'فصل لسبب مشروع (المادة 80);OTHER'))
p.text('P50_REASON', f, 40, 'التفاصيل', maxlen=500)
b_calc = p.button(f, 10, 'CALC', 'حساب المخالصة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Calc', [
    'begin', "    :P50_ID := noona_pay_pkg.calc_settlement(:P50_EMP, to_date(:P50_LAST, 'YYYY-MM-DD'), :P50_TYPE, :P50_REASON);", 'end;'],
    when_button=b_calc, success='تم حساب المخالصة؛ راجعها ثم اعتمدها')
r = p.static('المخالصة', 20, condition=':P50_ID is not null')
p.dynamic('تفاصيل المخالصة', 25, 'return noona_pay_pkg.settlement_html(:P50_ID);', hide_header=True, condition=':P50_ID is not null')
b_app = p.button(r, 10, 'APPROVE', 'اعتماد وإنشاء تشغيل التسوية', hot=True)
p.hidden('P50_RUN', r, 1)
p.process(20, 'AFTER_SUBMIT', 'Approve', ['begin', '    :P50_RUN := noona_pay_pkg.approve_settlement(:P50_ID);', 'end;'], when_button=b_app)
p.ir('المخالصات', 30, [
    "select s.id, s.doc_no, noona_hr_pkg.employment_label(s.employment_id) as emp, to_char(s.last_working_date, 'YYYY-MM-DD') as last_day,",
    "       s.eos_amount, s.leave_encashment, s.deductions, s.net_settlement, noona_pay_pkg.status_label(s.status_code) as status",
    "  from hr_end_of_service s where s.company_id = noona_pay_pkg.company order by s.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'المخالصة', {}), ('EMP', 'الموظف', {}), ('LAST_DAY', 'آخر يوم', {}),
     ('EOS_AMOUNT', 'المكافأة', {'type': 'NUMBER'}), ('LEAVE_ENCASHMENT', 'بدل الإجازات', {'type': 'NUMBER'}),
     ('DEDUCTIONS', 'السلف', {'type': 'NUMBER'}), ('NET_SETTLEMENT', 'الصافي', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})],
    link=link(50, 'P50_ID'))
p.branch(5, url(41, 'P41_ID', '&P50_RUN.', 'RP,41') + '&success_msg=' + 'تم إنشاء تشغيل التسوية؛ اعتمده ورحله واصرفه', when_button=b_app)
p.branch(10, url(50, 'P50_ID', '&P50_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 60) التقارير
REPORTS = [('HEADCOUNT', 'القوى العاملة ونسبة التوطين'), ('LEAVES', 'أرصدة الإجازات'), ('ATTENDANCE', 'الحضور الشهري'),
           ('EXPIRING', 'الهويات والعقود القريبة الانتهاء'), ('EOS', 'التزام مكافأة نهاية الخدمة'), ('LOANS', 'السلف القائمة'),
           ('REGISTER', 'مسير رواتب تشغيل'), ('ELEMENTS', 'ملخص عناصر الرواتب'), ('GOSI', 'تقرير التأمينات الاجتماعية'),
           ('CC', 'تكلفة الرواتب حسب مركز التكلفة')]
p = app.page(60, 'Reports', 'REPORTS', 'تقارير الموارد البشرية والرواتب', scheme=TENANT, protection='N')
f = p.static('التقرير', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P60_REPORT', f, 10, 'التقرير', null_text=None, submit=True, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n in REPORTS))
p.select('P60_RUN', f, 20, 'التشغيل (لتقارير الرواتب)', lov_sql=(
    "select r.run_no d, r.id r from pay_run r join pay_period p on p.id = r.period_id where r.company_id = noona_pay_pkg.company "
    "order by p.start_date desc, r.id desc"))
p.date('P60_DATE', f, 30, 'التاريخ / الشهر')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P60_REPORT := nvl(:P60_REPORT, 'HEADCOUNT');",
                                            ":P60_DATE := nvl(:P60_DATE, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('التقرير', 10, [
    'declare l_d date := to_date(:P60_DATE, \'YYYY-MM-DD\');',
    'begin',
    '    if :P60_REPORT in (\'EOS\', \'LOANS\', \'REGISTER\', \'ELEMENTS\', \'GOSI\', \'CC\')',
    "       and noona_security_pkg.has_permission('PAY_RUN.VIEW', noona_pay_pkg.company) = 'N' then",
    "        return '<p class=\"nn-hint\">تقارير الرواتب تتطلب صلاحية عرض الرواتب</p>';",
    '    end if;',
    '    return case :P60_REPORT',
    "        when 'HEADCOUNT' then noona_hr_pkg.headcount_report",
    "        when 'LEAVES' then noona_hr_pkg.leave_balances_report(l_d)",
    "        when 'ATTENDANCE' then noona_hr_pkg.attendance_report(l_d)",
    "        when 'EXPIRING' then noona_hr_pkg.expiring_report(90)",
    "        when 'EOS' then noona_pay_pkg.eos_liability_html(l_d)",
    "        when 'LOANS' then noona_pay_pkg.loans_report_html",
    "        when 'REGISTER' then case when :P60_RUN is not null then noona_pay_pkg.run_register_html(:P60_RUN) end",
    "        when 'ELEMENTS' then case when :P60_RUN is not null then noona_pay_pkg.element_summary_html(:P60_RUN) end",
    "        when 'GOSI' then case when :P60_RUN is not null then noona_pay_pkg.gosi_report_html(:P60_RUN) end",
    "        when 'CC' then case when :P60_RUN is not null then noona_pay_pkg.cost_center_html(:P60_RUN) end",
    '    end;',
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.branch(10, url(60, 'P60_REPORT,P60_RUN,P60_DATE', '&P60_REPORT.,&P60_RUN.,&P60_DATE.', '60'))

# =============================================================== 70) الإعدادات
p = app.page(70, 'Settings', 'SETTINGS', 'إعدادات الموارد البشرية والرواتب', scheme=PAY)
f = p.static('التجهيز', 5)
b = p.button(f, 10, 'SETUP', 'تجهيز / استكمال الإعدادات (الحسابات والفترات والوردية)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_pay_pkg.quick_setup;',
          "    apex_application.g_print_success_message := 'تم التجهيز (' || l_n || ' إضافة)';", 'end;'], when_button=b)
p.ir('عناصر الراتب', 10, [
    "select e.id, e.code, e.name_ar, case e.element_type when 'EARNING' then 'استحقاق' when 'EMPLOYER_CONTRIBUTION' then 'على المنشأة'",
    "       else 'استقطاع' end as typ, noona_ui_pkg.code_label(e.affects_eos) as eos, noona_ui_pkg.code_label(e.is_recurring) as rec,",
    "       case when e.tenant_id is null then 'النظام' else 'المؤسسة' end as owner",
    "  from pay_element e where e.is_active = 'Y' order by e.sort_order"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'العنصر', {}), ('TYP', 'النوع', {}),
     ('EOS', 'يدخل في نهاية الخدمة', {}), ('REC', 'ثابت شهري', {}), ('OWNER', 'المصدر', {})], titled=True, rows=20)
ne = p.static('إضافة عنصر خاص بالمؤسسة', 12,
              text='<p class="nn-hint">مثل بدل وجبة أو بدل اتصال أو بدل طبيعة عمل أو استقطاع ثابت. بعد الإضافة حدد قيمته في سياسة البدلات '
                   'أو في هيكل راتب الموظف.</p>')
p.text('P70_EL_CODE', ne, 10, 'الرمز بالإنجليزية (MEAL_ALLOW)', maxlen=30, width=20)
p.text('P70_EL_NAME', ne, 20, 'اسم العنصر', maxlen=200)
p.select('P70_EL_TYPE', ne, 30, 'النوع', lov_sql='STATIC2:استحقاق (بدل);EARNING,استقطاع ثابت;DEDUCTION', null_text=None)
p.yesno('P70_EL_EOS', ne, 40, 'يدخل في أجر نهاية الخدمة')
p.select('P70_EL_PRO', ne, 50, 'بالتناسب مع أيام العمل', lov_sql='STATIC2:نعم;Y,لا (يصرف كاملاً);N', null_text=None)
b_el = p.button(ne, 10, 'ADD_ELEMENT', 'إضافة العنصر')
p.process(20, 'AFTER_SUBMIT', 'Add Element', ['declare l_id number;', 'begin',
          "    l_id := noona_pay_pkg.save_element(null, :P70_EL_CODE, :P70_EL_NAME, :P70_EL_TYPE, 'Y', :P70_EL_PRO, :P70_EL_EOS);",
          'end;'], when_button=b_el, success='تمت إضافة العنصر')
p.ir('سياسة البدلات (لكل شركة أو دولة)', 15, [
    "select r.id, e.name_ar as element, case when r.company_id is not null then 'الشركة: ' || c.name_ar",
    "       when r.country_code is not null then 'شركات الدولة: ' || nvl(k.name_ar, r.country_code) else 'كل الشركات' end as scope,",
    "       noona_hr_pkg.category_label(r.employee_category) as category, noona_pay_pkg.rule_text(r.id) as rule_txt,",
    "       case r.is_auto when 'Y' then 'تلقائي لكل الموظفين' else 'لمن يختار «حسب السياسة»' end as auto_txt,",
    "       to_char(r.effective_from, 'YYYY-MM-DD') as eff, to_char(r.effective_to, 'YYYY-MM-DD') as eff_to",
    "  from pay_element_rule r join pay_element e on e.id = r.element_id left join org_company c on c.id = r.company_id",
    "  left join ref_country k on k.country_code = r.country_code",
    " where r.formula_type in ('FIXED', 'PCT_OF_ELEMENT') and r.status_code = 'ACTIVE' and r.tenant_id is not null",
    "   and (r.company_id is null or r.company_id = noona_pay_pkg.company)",
    " order by e.sort_order, r.effective_from desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ELEMENT', 'البدل', {}), ('SCOPE', 'النطاق', {}), ('CATEGORY', 'الفئة', {}),
     ('RULE_TXT', 'القيمة', {}), ('AUTO_TXT', 'التطبيق', {}), ('EFF', 'ساري من', {}), ('EFF_TO', 'حتى', {})], titled=True, rows=20)
pr = p.static('قاعدة بدل جديدة', 16,
              text='<p class="nn-hint">قاعدة الشركة تتقدم على قاعدة الدولة. القاعدة الجديدة لنفس البدل والنطاق والفئة تحل محل السابقة من تاريخ '
                   'سريانها وتبقى السابقة للفترات الماضية. مثال: بدل السكن 25% من الأساسي بحد أعلى 5000 لكل شركات المؤسسة في السعودية.</p>')
p.select('P70_R_EL', pr, 10, 'البدل', lov_sql=ALLOW_EL_LOV)
p.select('P70_R_SCOPE', pr, 20, 'النطاق', lov_sql='STATIC2:الشركة الحالية فقط;COMPANY,كل شركات المؤسسة في دولة;COUNTRY', null_text=None)
p.select('P70_R_COUNTRY', pr, 30, 'الدولة (للنطاق دولة)', lov_sql=COUNTRY_LOV)
p.select('P70_R_METHOD', pr, 40, 'الطريقة', lov_sql='STATIC2:نسبة من عنصر;PERCENT,مبلغ ثابت;FIXED', null_text=None)
p.number('P70_R_VALUE', pr, 50, 'النسبة % أو المبلغ')
p.select('P70_R_BASIS', pr, 60, 'النسبة من', lov_sql=BASIS_LOV, null_text=None)
p.number('P70_R_MIN', pr, 70, 'حد أدنى للمبلغ')
p.number('P70_R_MAX', pr, 80, 'حد أعلى للمبلغ')
p.select('P70_R_CAT', pr, 90, 'فئة الموظفين', lov_sql=CAT_LOV, null_text='الكل')
p.select('P70_R_AUTO', pr, 100, 'التطبيق', lov_sql='STATIC2:تلقائي لكل موظفي النطاق;Y,لمن يحدد له «حسب سياسة الشركة» فقط;N', null_text=None)
p.date('P70_R_FROM', pr, 110, 'يسري من')
b_r = p.button(pr, 10, 'ADD_RULE', 'حفظ القاعدة', hot=True)
p.process(30, 'AFTER_SUBMIT', 'Add Rule', ['declare l_id number;', 'begin',
          '    l_id := noona_pay_pkg.save_allowance_rule(:P70_R_EL, :P70_R_SCOPE, :P70_R_COUNTRY, :P70_R_METHOD, to_number(:P70_R_VALUE),',
          "        :P70_R_BASIS, to_number(:P70_R_MIN), to_number(:P70_R_MAX), :P70_R_CAT, :P70_R_AUTO, to_date(:P70_R_FROM, 'YYYY-MM-DD'));",
          'end;'], when_button=b_r, success='تم حفظ قاعدة البدل')
er = p.static('إيقاف قاعدة', 17)
p.select('P70_END_RULE', er, 10, 'القاعدة', lov_sql=(
    "select e.name_ar || ' - ' || noona_pay_pkg.rule_text(r.id) || ' (من ' || to_char(r.effective_from, 'YYYY-MM-DD') || ')' d, r.id r "
    "from pay_element_rule r join pay_element e on e.id = r.element_id where r.formula_type in ('FIXED', 'PCT_OF_ELEMENT') "
    "and r.status_code = 'ACTIVE' and r.tenant_id is not null and r.effective_to is null "
    "and (r.company_id is null or r.company_id = noona_pay_pkg.company) order by 1"))
p.date('P70_END_DATE', er, 20, 'آخر يوم لتطبيقها')
b_er = p.button(er, 10, 'END_RULE', 'إيقاف القاعدة')
p.process(40, 'AFTER_SUBMIT', 'End Rule', ['begin',
          "    noona_pay_pkg.end_rule(:P70_END_RULE, to_date(:P70_END_DATE, 'YYYY-MM-DD'));",
          'end;'], when_button=b_er, success='تم إيقاف القاعدة')
p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin',
          "    :P70_R_COUNTRY := nvl(:P70_R_COUNTRY, noona_hr_pkg.company_country);",
          "    :P70_R_FROM := nvl(:P70_R_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
          'end;'])
p.ir('قواعد التأمينات الاجتماعية والإضافي', 20, [
    "select r.id, e.name_ar as element, nvl(k.name_ar, 'كل الدول') as country, noona_hr_pkg.category_label(r.employee_category) as category,",
    "       json_value(r.parameters, '$.pct') as pct, json_value(r.parameters, '$.min') as min_base, json_value(r.parameters, '$.max') as max_base,",
    "       (select listagg(b.name_ar, ' + ') within group (order by b.sort_order) from pay_element b",
    "         where b.code in (select j.c from json_table(r.parameters, '$.base[*]' columns (c varchar2(50) path '$')) j)) as base,",
    "       to_char(r.effective_from, 'YYYY-MM-DD') as eff",
    "  from pay_element_rule r join pay_element e on e.id = r.element_id left join ref_country k on k.country_code = r.country_code",
    " where r.status_code = 'ACTIVE' and r.formula_type not in ('FIXED', 'PCT_OF_ELEMENT') order by e.sort_order, r.version_no"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ELEMENT', 'العنصر', {}), ('COUNTRY', 'الدولة', {}), ('CATEGORY', 'الفئة', {}),
     ('PCT', 'النسبة %', {}), ('BASE', 'أساس الاشتراك', {}), ('MIN_BASE', 'الحد الأدنى للأجر', {}), ('MAX_BASE', 'الحد الأعلى للأجر', {}),
     ('EFF', 'ساري من', {})], titled=True, rows=10)
p.ir('أنواع الإجازات', 30, [
    "select t.id, t.code, t.name_ar, noona_ui_pkg.code_label(t.is_paid) as paid, decode(t.unit_code, 'HOUR', 'ساعة', 'يوم') as unit,",
    "       t.max_per_year from hr_leave_type t where t.is_active = 'Y' order by t.id"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('PAID', 'مدفوعة', {}),
     ('UNIT', 'الوحدة', {}), ('MAX_PER_YEAR', 'الحد السنوي', {'type': 'NUMBER'})], titled=True, rows=15)
p.ir('فترات الرواتب', 40, [
    "select p.id, p.period_code, to_char(p.start_date, 'YYYY-MM-DD') as s, to_char(p.end_date, 'YYYY-MM-DD') as e,",
    "       to_char(p.pay_date, 'YYYY-MM-DD') as pay from pay_period p where p.company_id = noona_pay_pkg.company order by p.start_date desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PERIOD_CODE', 'الفترة', {}), ('S', 'من', {}), ('E', 'إلى', {}), ('PAY', 'تاريخ الصرف', {})],
    titled=True, rows=12)
p.branch(10, url(70) + '&success_msg=#SUCCESS_MSG#')

app.nav_item('اللوحة', 1, 'fa-home', 10)
em = app.nav_item('الموظفون', None, 'fa-users', 20, scheme=HR)
app.nav_item('ملفات الموظفين', 10, 'fa-id-card-o', 21, parent=em, scheme=HR)
app.nav_item('موظف جديد', url(11, clear='RP,11'), 'fa-user-plus', 22, parent=em, scheme=HR)
lv = app.nav_item('الإجازات والحضور', None, 'fa-calendar', 30, scheme=HR)
app.nav_item('الإجازات واعتمادها', 20, 'fa-plane', 31, parent=lv, scheme=HR)
app.nav_item('طلب إجازة', url(21, clear='RP,21'), 'fa-plus', 32, parent=lv, scheme=HR)
app.nav_item('الحضور والإضافي', 25, 'fa-clock-o', 33, parent=lv, scheme=HR)
py = app.nav_item('الرواتب', None, 'fa-money', 40, scheme=PAY)
app.nav_item('تشغيلات الرواتب', 40, 'fa-calculator', 41, parent=py, scheme=PAY)
app.nav_item('المدخلات المتغيرة', 42, 'fa-pencil-square-o', 42, parent=py, scheme=PAY)
app.nav_item('السلف والقروض', 30, 'fa-credit-card', 43, parent=py, scheme=PAY)
app.nav_item('مخالصة نهاية الخدمة', url(50, clear='RP,50'), 'fa-sign-out', 44, parent=py, scheme=PAY)
app.nav_item('التقارير', 60, 'fa-bar-chart', 50)
app.nav_item('الإعدادات', 70, 'fa-cog', 60, scheme=PAY)
app.finalize()
print('NOONA_HR built:', len(app.pages), 'pages')
