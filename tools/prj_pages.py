"""صفحات المشروعات والمقاولات في تطبيق العقارات والضيافة والمشروعات (139): لوحة المشروعات، المشروع (مساحة العمل)، بيانات المشروع،
بنود العمل ونسب الإنجاز، الموازنة، التكاليف الفعلية، العقد وجدول الكميات وأوامر التغيير، المستخلص وطباعته، التقارير.
المنطق في NOONA_PRJ_PKG؛ المحررات التفاعلية في tools/prj.js.
"""
import os, shutil
import apex_brand

shutil.copyfile(os.path.join(os.path.dirname(__file__), 'prj.js'), os.path.join(apex_brand.STATIC_DIR, 'prj.js'))
if ('prj.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('prj.js', 'application/javascript'))
LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'prj.js'; document.head.appendChild(s); })();"]

AJAX = [
    'declare',
    '    l_c clob;',
    '    function n(p varchar2) return number is begin return to_number(p); end;',
    'begin',
    '    case apex_application.g_x01',
    "        when 'BOQ' then l_c := '{\"n\":' || noona_prj_pkg.save_boq(n(apex_application.g_x02), apex_application.g_clob_01) || '}';",
    "        when 'VO' then l_c := '{\"id\":' || noona_prj_pkg.save_variation(apex_application.g_clob_01) || '}';",
    "        when 'BUDGET' then l_c := '{\"id\":' || noona_prj_pkg.save_budget(n(apex_application.g_x02), apex_application.g_clob_01,",
    '                                                                       apex_application.g_x03) || \'}\';',
    "        when 'CLAIM' then noona_prj_pkg.save_claim(apex_application.g_clob_01);",
    "            l_c := noona_prj_pkg.claim_json(json_value(apex_application.g_clob_01, '$.id' returning number));",
    "        when 'REV' then noona_prj_pkg.reverse_cost(n(apex_application.g_x02), apex_application.g_x03);",
    "        else raise_application_error(-20500, 'NOONA-PRJ-099: عملية غير معروفة');",
    '    end case;',
    "    htp.prn(nvl(l_c, to_clob('{\"ok\":true}')));",
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('err', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']

CO = 'noona_prj_pkg.company'
PROJECT_LOV = f"select code || ' - ' || name_ar d, id r from prj_project where company_id = {CO} order by code"
OPEN_PROJECT_LOV = (f"select code || ' - ' || name_ar d, id r from prj_project where company_id = {CO} "
                    "and status_code not in ('CLOSED', 'CANCELLED') order by code")
TYPE_LOV = ('STATIC2:مشروع لعميل;CLIENT_CONTRACT,مقاولات وإنشاءات;CONSTRUCTION,تطوير عقاري;REAL_ESTATE_DEVELOPMENT,داخلي;INTERNAL,'
            'صيانة;MAINTENANCE,رأسمالي;CAPEX,برنامج;PROGRAM')
STATUS_LOV = ('STATIC2:مخطط;PLANNED,معتمد;APPROVED,قيد التنفيذ;ACTIVE,متوقف مؤقتاً;ON_HOLD,منجز;COMPLETED,مغلق;CLOSED,ملغى;CANCELLED')
CUST_LOV = ("select p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id "
            f"join pty_party p on p.id = c.party_id where a.company_id = {CO} and a.status_code = 'ACTIVE' order by 1")
SUP_LOV = ("select p.display_name_ar d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id "
           f"join pty_party p on p.id = s.party_id where a.company_id = {CO} and a.status_code = 'ACTIVE' order by 1")
EMP_LOV = ("select p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
           f"where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = {CO}) order by 1")
PROP_LOV = (f"select name_ar || ' (' || code || ')' d, id r from re_property where company_id = {CO} order by code")
PLACE_LOV = (f"select 'صندوق: ' || name_ar d, 'BOX:' || id r from csh_cash_box where company_id = {CO} and status_code = 'ACTIVE' "
             f"union all select 'بنك: ' || name_ar, 'BANK:' || id from csh_bank_account where company_id = {CO} and status_code = 'ACTIVE'")
WH_LOV = f"select name_ar d, id r from inv_warehouse where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"
ITEM_LOV = ("select i.name_ar || ' (' || i.item_no || ')' d, i.id r from inv_item i where i.status_code = 'ACTIVE' "
            "and i.item_type not in ('SERVICE', 'NON_STOCK') order by i.name_ar")
COST_LOV = ('STATIC2:مواد;MATERIAL,عمالة;LABOR,معدات;EQUIPMENT,مقاولو باطن;SUBCONTRACT,مصروفات غير مباشرة;OVERHEAD,أخرى;OTHER')
CTYPE_LOV = 'STATIC2:العقد الرئيسي مع العميل (المالك);MAIN_CONTRACT,عقد مقاول باطن;SUBCONTRACT'
PRICING_LOV = 'STATIC2:إعادة قياس (بالكميات المنفذة);REMEASURED,مبلغ مقطوع;LUMP_SUM,سعر الوحدة;UNIT_RATE,التكلفة زائد ربح;COST_PLUS'


def wbs_lov(item):
    return (f"select lpad(' ', (wbs_level - 1) * 2) || code || ' - ' || name_ar d, id r from prj_wbs where project_id = :{item} "
            "and status_code <> 'CANCELLED' order by code")


def build(app, url, link, scheme):
    def lists_region(p, pid_expr):
        """قوائم المحررات (الوحدات وبنود العمل) كـ JSON داخل الصفحة"""
        return ['declare l_w clob; l_u clob;', 'begin',
                "    select json_arrayagg(json_object('v' value id, 'n' value code || ' - ' || name_ar) order by code returning clob) into l_w",
                f"      from prj_wbs where project_id = {pid_expr} and status_code <> 'CANCELLED';",
                "    select json_arrayagg(json_object('v' value id, 'n' value name_ar) order by name_ar returning clob) into l_u",
                "      from inv_uom where is_active = 'Y';",
                "    return '<script type=\"application/json\" id=\"nnPrjLists\">' || replace('{\"wbs\":' || nvl(l_w, '[]') || ',\"uoms\":' || nvl(l_u, '[]') || '}', '</', '<\\/') || '</script>';",
                'end;']

    # =========================================================== 80) لوحة المشروعات
    p = app.page(80, 'Projects', 'PROJECTS', 'المشروعات والمقاولات', scheme=scheme)
    p.dynamic('المؤشرات', 5, 'return noona_prj_pkg.summary_html;', hide_header=True)
    r = p.ir('المشروعات', 10, [
        'select p.id, p.code, p.name_ar, noona_prj_pkg.type_label(p.project_type) type_name,',
        "       (select max(pt.display_name_ar) from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party pt on pt.id = c.party_id",
        '         where a.id = p.customer_account_id) customer,',
        '       p.planned_start, p.planned_end, p.percent_complete, p.contract_value, p.budget_amount,',
        "       (select nvl(sum(c.amount_func), 0) from prj_cost_line c where c.project_id = p.id and c.status_code = 'POSTED') actual_cost,",
        '       noona_prj_pkg.status_label(p.status_code) status',
        f'  from prj_project p where p.company_id = {CO}'],
        [('ID', 'ID', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المشروع', {}), ('TYPE_NAME', 'النوع', {}),
         ('CUSTOMER', 'العميل', {}), ('PLANNED_START', 'البداية', {'type': 'DATE'}), ('PLANNED_END', 'النهاية', {'type': 'DATE'}),
         ('PERCENT_COMPLETE', 'الإنجاز %', {'type': 'NUMBER'}), ('CONTRACT_VALUE', 'قيمة العقد', {'type': 'NUMBER'}),
         ('BUDGET_AMOUNT', 'الموازنة', {'type': 'NUMBER'}), ('ACTUAL_COST', 'التكلفة الفعلية', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})],
        link=link(81, 'P81_ID'), titled=True)
    p.button(r, 10, 'NEW', 'مشروع جديد', hot=True, redirect=url(82, clear='RP,82'))

    # =========================================================== 82) بيانات المشروع (جديد / تعديل)
    p = app.page(82, 'Project Form', 'PROJECT-FORM', 'بيانات المشروع', scheme=scheme, protection='N')
    f = p.static('بيانات المشروع', 10, text=('<p class="nn-hint">المشروع العام يكفيه الاسم والنوع. مشروع التطوير العقاري يرتبط بعقار من السجل '
                                              'العقاري لتوزع تكلفته على الوحدات. ينشأ للمشروع مركز تكلفة باسمه تحمل عليه تكاليفه وإيراداته.</p>'))
    p.hidden('P82_ID', f, 1, protected=False)
    p.text('P82_CODE', f, 10, 'الرمز (فارغ = تلقائي)', maxlen=50, width=15)
    p.text('P82_NAME', f, 20, 'اسم المشروع', required=True, maxlen=400)
    p.text('P82_NAME_EN', f, 25, 'اسم المشروع بالإنجليزية', maxlen=400)
    p.select('P82_TYPE', f, 30, 'النوع', lov_sql=TYPE_LOV, null_text=None)
    p.select('P82_CUSTOMER', f, 40, 'العميل (المالك)', lov_sql=CUST_LOV, null_text='- بدون (داخلي) -')
    p.select('P82_MANAGER', f, 50, 'مدير المشروع', lov_sql=EMP_LOV)
    p.select('P82_PROPERTY', f, 60, 'العقار (للتطوير العقاري)', lov_sql=PROP_LOV)
    p.select('P82_PARENT', f, 65, 'البرنامج الأم', lov_sql=PROJECT_LOV)
    p.date('P82_START', f, 70, 'البداية المخططة')
    p.date('P82_END', f, 80, 'النهاية المخططة')
    p.number('P82_CONTRACT', f, 90, 'قيمة العقد (تتحدث من العقد الرئيسي)')
    b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
    p.button(f, 20, 'CANCEL', 'رجوع', redirect=url(80))
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin',
        '    if :P82_ID is not null then',
        '        select code, name_ar, name_en, project_type, customer_account_id, manager_employee_id, parent_project_id,',
        "               to_char(planned_start, 'YYYY-MM-DD'), to_char(planned_end, 'YYYY-MM-DD'), contract_value,",
        '               (select min(id) from re_property where project_id = p.id)',
        '          into :P82_CODE, :P82_NAME, :P82_NAME_EN, :P82_TYPE, :P82_CUSTOMER, :P82_MANAGER, :P82_PARENT, :P82_START, :P82_END,',
        '               :P82_CONTRACT, :P82_PROPERTY',
        f'          from prj_project p where id = :P82_ID and company_id = {CO};',
        '    else',
        "        :P82_TYPE := nvl(:P82_TYPE, 'CLIENT_CONTRACT');",
        '    end if;',
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', [
        'declare l_doc clob;', 'begin',
        "    select json_object('id' value to_number(:P82_ID), 'code' value :P82_CODE, 'name' value :P82_NAME, 'nameEn' value :P82_NAME_EN,",
        "                       'type' value :P82_TYPE, 'customer' value to_number(:P82_CUSTOMER), 'manager' value to_number(:P82_MANAGER),",
        "                       'property' value to_number(:P82_PROPERTY), 'parent' value to_number(:P82_PARENT), 'start' value :P82_START,",
        "                       'end' value :P82_END, 'contract' value to_number(:P82_CONTRACT) returning clob) into l_doc from dual;",
        '    :P82_ID := noona_prj_pkg.save_project(l_doc);', 'end;'], when_button=b, success='تم حفظ المشروع')
    p.branch(10, url(81, 'P81_ID', '&P82_ID.', '81') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 81) مساحة عمل المشروع
    p = app.page(81, 'Project', 'PROJECT', 'المشروع', scheme=scheme, protection='N')
    p.dynamic('المشروع', 5, 'return noona_prj_pkg.project_card_html(:P81_ID);', hide_header=True)
    a = p.static('الإجراءات', 6, hide_header=True)
    p.hidden('P81_ID', a, 1, protected=False)
    p.select('P81_STATUS', a, 10, 'تغيير الحالة', lov_sql=STATUS_LOV, null_text='- الحالة -')
    bs = p.button(a, 10, 'SET_STATUS', 'تطبيق الحالة')
    p.button(a, 20, 'EDIT', 'تعديل البيانات', redirect=url(82, 'P82_ID', '&P81_ID.', '82'))
    p.button(a, 30, 'WBS', 'بنود العمل والإنجاز', redirect=url(84, 'P84_PROJECT', '&P81_ID.', '84'))
    p.button(a, 40, 'BUDGET', 'الموازنة', redirect=url(85, 'P85_PROJECT', '&P81_ID.', '85'))
    p.button(a, 50, 'COSTS', 'التكاليف الفعلية', redirect=url(86, 'P86_PROJECT', '&P81_ID.', '86'))
    p.button(a, 60, 'NEW_CONTRACT', 'عقد جديد', hot=True, redirect=url(87, 'P87_PROJECT', '&P81_ID.', '87'))
    p.process(10, 'AFTER_SUBMIT', 'Status', 'noona_prj_pkg.set_status(:P81_ID, :P81_STATUS);', when_button=bs, success='تم تغيير حالة المشروع')
    p.dynamic('بنود العمل ونسب الإنجاز', 10, 'return noona_prj_pkg.wbs_html(:P81_ID);')
    p.dynamic('الموازنة مقابل الفعلي', 20, 'return noona_prj_pkg.budget_html(:P81_ID);')
    p.dynamic('العقود (العميل ومقاولو الباطن)', 30,
              f"return noona_prj_pkg.contracts_html(:P81_ID, 'f?p=' || :APP_ID || ':87:' || :APP_SESSION || '::NO:RP,87:P87_ID:#ID#');")
    p.dynamic('توزيع تكلفة التطوير على الوحدات', 40, "return noona_prj_pkg.unit_costs_html(:P81_ID, 'AREA');",
              condition="noona_prj_pkg.has_property(:P81_ID) = 'Y'")
    p.dynamic('آخر التكاليف', 50, 'return noona_prj_pkg.costs_html(:P81_ID, 15);')
    p.branch(10, url(81, 'P81_ID', '&P81_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 84) بنود العمل ونسب الإنجاز
    p = app.page(84, 'WBS', 'WBS', 'بنود العمل ونسب الإنجاز', scheme=scheme, protection='N')
    p.dynamic('بنود العمل', 5, 'return noona_prj_pkg.wbs_html(:P84_PROJECT);')
    f = p.static('إضافة / تعديل بند', 10)
    p.hidden('P84_PROJECT', f, 1, protected=False)
    p.select('P84_WBS', f, 5, 'البند (فارغ = جديد)', lov_sql=wbs_lov('P84_PROJECT'), null_text='- بند جديد -', submit=True)
    p.text('P84_CODE', f, 10, 'الرمز', maxlen=50, width=10)
    p.text('P84_NAME', f, 20, 'الاسم', maxlen=400)
    p.select('P84_PARENT', f, 30, 'البند الأب', lov_sql=wbs_lov('P84_PROJECT'))
    p.number('P84_WEIGHT', f, 40, 'الوزن في الإنجاز %')
    p.date('P84_START', f, 50, 'البداية')
    p.date('P84_END', f, 60, 'النهاية')
    b1 = p.button(f, 10, 'SAVE_WBS', 'حفظ البند', hot=True)
    b3 = p.button(f, 20, 'DELETE_WBS', 'حذف البند', condition=':P84_WBS is not null')
    p.button(f, 30, 'BACK', 'رجوع للمشروع', redirect=url(81, 'P81_ID', '&P84_PROJECT.'))
    g = p.static('تحديث نسبة الإنجاز', 20)
    p.select('P84_PWBS', g, 10, 'البند', lov_sql=wbs_lov('P84_PROJECT'), required=True)
    p.number('P84_PCT', g, 20, 'نسبة الإنجاز الفعلية %', required=True)
    p.text('P84_REMARKS', g, 30, 'ملاحظات / الإثبات', maxlen=2000)
    b2 = p.button(g, 10, 'PROGRESS', 'تسجيل الإنجاز', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin', '    if :P84_WBS is not null then',
        "        select code, name_ar, parent_wbs_id, weight_pct, to_char(planned_start, 'YYYY-MM-DD'), to_char(planned_end, 'YYYY-MM-DD')",
        '          into :P84_CODE, :P84_NAME, :P84_PARENT, :P84_WEIGHT, :P84_START, :P84_END from prj_wbs where id = :P84_WBS;',
        '    end if;', 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save WBS', [
        'declare l_doc clob; l_id number;', 'begin',
        "    select json_object('id' value to_number(:P84_WBS), 'project' value to_number(:P84_PROJECT), 'parent' value to_number(:P84_PARENT),",
        "                       'code' value :P84_CODE, 'name' value :P84_NAME, 'weight' value to_number(:P84_WEIGHT), 'start' value :P84_START,",
        "                       'end' value :P84_END returning clob) into l_doc from dual;",
        '    l_id := noona_prj_pkg.save_wbs(l_doc);',
        '    :P84_WBS := null; :P84_CODE := null; :P84_NAME := null; :P84_PARENT := null; :P84_WEIGHT := null; :P84_START := null; :P84_END := null;',
        'end;'], when_button=b1, success='تم حفظ البند')
    p.process(20, 'AFTER_SUBMIT', 'Delete WBS', 'noona_prj_pkg.delete_wbs(:P84_WBS); :P84_WBS := null;', when_button=b3, success='تم حذف البند')
    p.process(30, 'AFTER_SUBMIT', 'Progress', 'noona_prj_pkg.update_progress(:P84_PWBS, to_number(:P84_PCT), :P84_REMARKS);',
              when_button=b2, success='تم تسجيل نسبة الإنجاز')
    p.branch(10, url(84, 'P84_PROJECT', '&P84_PROJECT.', '84') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 85) الموازنة
    p = app.page(85, 'Project Budget', 'PROJECT-BUDGET', 'موازنة المشروع', scheme=scheme, protection='N')
    p.dynamic('الموازنة مقابل الفعلي', 5, 'return noona_prj_pkg.budget_html(:P85_PROJECT);')
    r = p.dynamic('الموازنة حسب بند العمل ونوع التكلفة', 10, lists_region(p, ':P85_PROJECT')[:4] + [
        "    return '<script type=\"application/json\" id=\"nnPrjBudgetData\">' || noona_prj_pkg.budget_json(:P85_PROJECT) || '</script>'",
        "        || '<script type=\"application/json\" id=\"nnPrjLists\">' || replace('{\"wbs\":' || nvl(l_w, '[]') || '}', '</', '<\\/') || '</script>'",
        "        || '<div id=\"nnPrjBudget\" data-project=\"' || :P85_PROJECT || '\"></div>';", 'end;'])
    p.hidden('P85_PROJECT', r, 1, protected=False)
    p.process(1, 'ON_DEMAND', 'PRJ', AJAX)
    p.onload(LOADER)

    # =========================================================== 86) التكاليف الفعلية
    p = app.page(86, 'Project Costs', 'PROJECT-COSTS', 'التكاليف الفعلية للمشروع', scheme=scheme, protection='N')
    e = p.static('مصروف مباشر (من الصندوق أو البنك)', 10)
    p.hidden('P86_PROJECT', e, 1, protected=False)
    p.select('P86_WBS', e, 10, 'بند العمل', lov_sql=wbs_lov('P86_PROJECT'))
    p.select('P86_TYPE', e, 20, 'نوع التكلفة', lov_sql=COST_LOV, null_text=None)
    p.number('P86_AMOUNT', e, 30, 'المبلغ')
    p.select('P86_PLACE', e, 40, 'مدفوع من', lov_sql=PLACE_LOV)
    p.text('P86_DESC', e, 50, 'البيان', maxlen=500)
    p.text('P86_REF', e, 60, 'المرجع (فاتورة/إيصال)', maxlen=100, width=15)
    be = p.button(e, 10, 'POST_EXPENSE', 'ترحيل المصروف', hot=True)
    m = p.static('صرف مواد من المخزون', 20)
    p.select('P86_MWBS', m, 10, 'بند العمل', lov_sql=wbs_lov('P86_PROJECT'))
    p.select('P86_WH', m, 20, 'المستودع', lov_sql=WH_LOV)
    p.select('P86_ITEM', m, 30, 'الصنف', lov_sql=ITEM_LOV)
    p.number('P86_QTY', m, 40, 'الكمية')
    bm = p.button(m, 10, 'ISSUE', 'صرف للمشروع', hot=True)
    t = p.static('ساعات العمل', 30)
    p.select('P86_EMP', t, 10, 'الموظف', lov_sql=EMP_LOV)
    p.select('P86_TWBS', t, 20, 'بند العمل', lov_sql=wbs_lov('P86_PROJECT'))
    p.date('P86_TDATE', t, 30, 'التاريخ')
    p.number('P86_HOURS', t, 40, 'الساعات')
    p.number('P86_RATE', t, 50, 'تكلفة الساعة (فارغ = من الراتب)')
    bt = p.button(t, 10, 'TIMESHEET', 'تسجيل الساعات')
    bp = p.button(t, 20, 'POST_TS', 'تحميل الساعات المعتمدة على المشروع', hot=True)
    p.dynamic('ساعات بانتظار التحميل', 35, [
        "declare l clob := '<table class=\"nn-prj-t\"><thead><tr><th>التاريخ</th><th>الموظف</th><th>البند</th><th class=\"n\">الساعات</th><th class=\"n\">تكلفة الساعة</th></tr></thead><tbody>';",
        '    n pls_integer := 0;', 'begin',
        "    for r in (select t.work_date, noona_hr_pkg.employee_name(t.employee_id) emp, w.code, t.hours, t.cost_rate from prj_timesheet t",
        "               join prj_wbs w on w.id = t.wbs_id where t.project_id = :P86_PROJECT and t.status_code in ('DRAFT', 'SUBMITTED') order by t.work_date) loop",
        "        n := n + 1; l := l || '<tr><td>' || to_char(r.work_date, 'YYYY-MM-DD') || '</td><td>' || apex_escape.html(r.emp) || '</td><td>'",
        "            || apex_escape.html(r.code) || '</td><td class=\"n\">' || r.hours || '</td><td class=\"n\">' || r.cost_rate || '</td></tr>';",
        '    end loop;',
        "    return case when n = 0 then '<div class=\"nn-empty\">لا توجد ساعات بانتظار التحميل</div>' else l || '</tbody></table>' end;", 'end;'])
    p.dynamic('حركات التكلفة', 40, 'return noona_prj_pkg.costs_html(:P86_PROJECT, 200);')
    p.process(1, 'ON_DEMAND', 'PRJ', AJAX)
    p.onload(LOADER)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [":P86_TYPE := nvl(:P86_TYPE, 'OTHER'); :P86_TDATE := nvl(:P86_TDATE, to_char(sysdate, 'YYYY-MM-DD'));"])
    p.process(10, 'AFTER_SUBMIT', 'Expense', [
        'declare l_doc clob; l_id number;', 'begin',
        "    select json_object('project' value to_number(:P86_PROJECT), 'wbs' value to_number(:P86_WBS), 'type' value :P86_TYPE,",
        "                       'amount' value to_number(:P86_AMOUNT), 'place' value :P86_PLACE, 'desc' value :P86_DESC, 'ref' value :P86_REF",
        '                       returning clob) into l_doc from dual;',
        '    l_id := noona_prj_pkg.post_expense(l_doc); :P86_AMOUNT := null; :P86_DESC := null; :P86_REF := null;', 'end;'],
              when_button=be, success='تم ترحيل المصروف على المشروع')
    p.process(20, 'AFTER_SUBMIT', 'Issue', [
        'declare l_doc clob; l_id number;', 'begin',
        "    select json_object('project' value to_number(:P86_PROJECT), 'wbs' value to_number(:P86_MWBS), 'wh' value to_number(:P86_WH),",
        "                       'lines' value json_array(json_object('i' value to_number(:P86_ITEM), 'q' value to_number(:P86_QTY))) returning clob)",
        '      into l_doc from dual;',
        '    l_id := noona_prj_pkg.issue_material(l_doc); :P86_QTY := null;', 'end;'], when_button=bm, success='تم صرف المواد وتحميل تكلفتها')
    p.process(30, 'AFTER_SUBMIT', 'Timesheet', [
        'declare l_doc clob; l_id number;', 'begin',
        "    select json_object('employee' value to_number(:P86_EMP), 'project' value to_number(:P86_PROJECT), 'wbs' value to_number(:P86_TWBS),",
        "                       'date' value :P86_TDATE, 'hours' value to_number(:P86_HOURS), 'rate' value to_number(:P86_RATE) returning clob)",
        '      into l_doc from dual;',
        '    l_id := noona_prj_pkg.save_timesheet(l_doc); :P86_HOURS := null;', 'end;'], when_button=bt, success='تم تسجيل الساعات')
    p.process(40, 'AFTER_SUBMIT', 'Post Timesheets', [
        'declare l number;', 'begin', '    l := noona_prj_pkg.post_timesheets(:P86_PROJECT);',
        "    apex_application.g_print_success_message := 'تم تحميل ' || l || ' سجل ساعات على المشروع';", 'end;'], when_button=bp)
    p.branch(10, url(86, 'P86_PROJECT', '&P86_PROJECT.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 87) العقد وجدول الكميات
    p = app.page(87, 'Contract', 'CONTRACT', 'العقد وجدول الكميات', scheme=scheme, protection='N')
    p.dynamic('العقد', 5, 'return noona_prj_pkg.contract_html(:P87_ID);', hide_header=True, condition=':P87_ID is not null')
    f = p.static('بيانات العقد', 10, condition="nvl(noona_prj_pkg.contract_status(:P87_ID), 'DRAFT') = 'DRAFT'")
    p.hidden('P87_ID', f, 1, protected=False)
    p.hidden('P87_PROJECT', f, 2, protected=False)
    p.select('P87_TYPE', f, 10, 'نوع العقد', lov_sql=CTYPE_LOV, null_text=None, submit=True)
    p.text('P87_NO', f, 20, 'رقم العقد (فارغ = تلقائي)', maxlen=50, width=15)
    p.select('P87_CUSTOMER', f, 30, 'العميل (المالك)', lov_sql=CUST_LOV)
    p.select('P87_SUPPLIER', f, 40, 'مقاول الباطن', lov_sql=SUP_LOV)
    p.select('P87_PRICING', f, 50, 'التسعير', lov_sql=PRICING_LOV, null_text=None)
    p.number('P87_VALUE', f, 60, 'قيمة العقد (إن لم يدخل جدول كميات)')
    p.number('P87_RET', f, 70, 'المحتجز %')
    p.number('P87_RETCAP', f, 80, 'سقف المحتجز % من العقد')
    p.number('P87_ADV', f, 90, 'الدفعة المقدمة %')
    p.number('P87_ADVREC', f, 100, 'استرداد المقدم من كل مستخلص %')
    p.date('P87_START', f, 110, 'البداية')
    p.date('P87_END', f, 120, 'النهاية')
    p.number('P87_DLP', f, 130, 'فترة الضمان (شهر)')
    bsv = p.button(f, 10, 'SAVE', 'حفظ العقد', hot=True)
    bq = p.dynamic('جدول الكميات (BOQ)', 20, lists_region(p, ':P87_PROJECT')[:-2] + [
        "    return '<script type=\"application/json\" id=\"nnPrjLists\">' || replace('{\"wbs\":' || nvl(l_w, '[]') || ',\"uoms\":' || nvl(l_u, '[]') || '}', '</', '<\\/') || '</script>'",
        "        || '<script type=\"application/json\" id=\"nnPrjBoqData\">' || replace(noona_prj_pkg.boq_json(:P87_ID), '</', '<\\/') || '</script>'",
        "        || '<div id=\"nnPrjBoq\" data-contract=\"' || :P87_ID || '\" data-locked=\"' || case when noona_prj_pkg.contract_status(:P87_ID) = 'DRAFT' then 'N' else 'Y' end || '\"></div>';",
        'end;'], condition=':P87_ID is not null')
    ac = p.static('إجراءات العقد', 30, condition=':P87_ID is not null')
    ba = p.button(ac, 10, 'ACTIVATE', 'اعتماد العقد', hot=True, condition="noona_prj_pkg.contract_status(:P87_ID) = 'DRAFT'")
    act = "noona_prj_pkg.contract_status(:P87_ID) = 'ACTIVE'"
    bn = p.button(ac, 20, 'NEW_CLAIM', 'مستخلص جديد', hot=True, condition=act)
    bv = p.button(ac, 30, 'NEW_ADVANCE', 'دفعة مقدمة', condition="noona_prj_pkg.can_advance(:P87_ID) = 'Y'")
    br = p.button(ac, 40, 'NEW_RELEASE', 'إفراج عن المحتجز', condition=act + ' and noona_prj_pkg.retention_held(:P87_ID) > 0')
    bc = p.button(ac, 50, 'CLOSE', 'إنهاء العقد', condition=act)
    p.button(ac, 60, 'BACK', 'رجوع للمشروع', redirect=url(81, 'P81_ID', '&P87_PROJECT.'))
    p.dynamic('أمر تغيير جديد', 40, "return '<div id=\"nnPrjVo\" data-contract=\"' || :P87_ID || '\"></div>';", condition=act)
    p.dynamic('أوامر التغيير المسودة', 45, [
        "declare l clob; n pls_integer := 0;", 'begin',
        "    for v in (select id, doc_no, description, amount from prj_variation_order where contract_id = :P87_ID and status_code = 'DRAFT') loop",
        "        n := n + 1; l := l || '<li>' || apex_escape.html(v.doc_no || ' - ' || v.description) || ' (' || to_char(v.amount, 'FM999G999G990D00') || ')</li>';",
        '    end loop;',
        "    return case when n > 0 then '<ul class=\"nn-prj-list\">' || l || '</ul>' end;", 'end;'],
              condition=act + ' and noona_prj_pkg.draft_variations(:P87_ID) > 0')
    vo = p.static('اعتماد أمر تغيير', 46, condition=act + ' and noona_prj_pkg.draft_variations(:P87_ID) > 0')
    p.select('P87_VO', vo, 10, 'أمر التغيير', lov_sql="select doc_no || ' - ' || description d, id r from prj_variation_order where contract_id = :P87_ID and status_code = 'DRAFT'")
    bva = p.button(vo, 10, 'APPROVE_VO', 'اعتماد أمر التغيير', hot=True)
    p.dynamic('المستخلصات', 50, "return noona_prj_pkg.claims_html(:P87_ID, 'f?p=' || :APP_ID || ':88:' || :APP_SESSION || '::NO:RP,88:P88_ID:#ID#');",
              condition=':P87_ID is not null')
    p.process(1, 'ON_DEMAND', 'PRJ', AJAX)
    p.onload(LOADER)
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin', '    if :P87_ID is not null then',
        '        select project_id, contract_type, contract_no, customer_account_id, supplier_account_id, pricing_type, original_value, retention_pct,',
        "               retention_cap_pct, advance_pct, advance_recovery_pct, to_char(start_date, 'YYYY-MM-DD'), to_char(end_date, 'YYYY-MM-DD'), defects_liability_months",
        '          into :P87_PROJECT, :P87_TYPE, :P87_NO, :P87_CUSTOMER, :P87_SUPPLIER, :P87_PRICING, :P87_VALUE, :P87_RET, :P87_RETCAP, :P87_ADV,',
        '               :P87_ADVREC, :P87_START, :P87_END, :P87_DLP',
        f'          from prj_contract where id = :P87_ID and company_id = {CO};',
        '    else',
        "        :P87_TYPE := nvl(:P87_TYPE, 'MAIN_CONTRACT'); :P87_PRICING := nvl(:P87_PRICING, 'REMEASURED');",
        "        if :P87_CUSTOMER is null and :P87_TYPE = 'MAIN_CONTRACT' then select customer_account_id into :P87_CUSTOMER from prj_project where id = :P87_PROJECT; end if;",
        '    end if;', 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', [
        'declare l_doc clob;', 'begin',
        "    select json_object('id' value to_number(:P87_ID), 'project' value to_number(:P87_PROJECT), 'type' value :P87_TYPE, 'no' value :P87_NO,",
        "                       'customer' value to_number(:P87_CUSTOMER), 'supplier' value to_number(:P87_SUPPLIER), 'pricing' value :P87_PRICING,",
        "                       'value' value to_number(:P87_VALUE), 'ret' value to_number(:P87_RET), 'retCap' value to_number(:P87_RETCAP),",
        "                       'adv' value to_number(:P87_ADV), 'advRec' value to_number(:P87_ADVREC), 'start' value :P87_START, 'end' value :P87_END,",
        "                       'dlp' value to_number(:P87_DLP) returning clob) into l_doc from dual;",
        '    :P87_ID := noona_prj_pkg.save_contract(l_doc);', 'end;'], when_button=bsv, success='تم حفظ العقد؛ أدخل جدول الكميات ثم اعتمده')
    p.process(20, 'AFTER_SUBMIT', 'Activate', 'noona_prj_pkg.activate_contract(:P87_ID);', when_button=ba, success='تم اعتماد العقد')
    p.process(30, 'AFTER_SUBMIT', 'Close', 'noona_prj_pkg.close_contract(:P87_ID);', when_button=bc, success='تم إنهاء العقد')
    p.process(40, 'AFTER_SUBMIT', 'Approve VO', 'noona_prj_pkg.approve_variation(:P87_VO);', when_button=bva, success='تم اعتماد أمر التغيير وتحديث قيمة العقد')
    p.process(50, 'AFTER_SUBMIT', 'New Claim', [
        'declare l number;', 'begin',
        "    l := noona_prj_pkg.new_claim(:P87_ID, case :REQUEST when 'NEW_ADVANCE' then 'ADVANCE' when 'NEW_RELEASE' then 'RETENTION_RELEASE' else 'PROGRESS' end);",
        '    commit;   -- التحويل يوقف محرك APEX قبل الحفظ التلقائي',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 88, p_clear_cache => '88', p_items => 'P88_ID', p_values => l));", 'end;'],
              when=":REQUEST in ('NEW_CLAIM', 'NEW_ADVANCE', 'NEW_RELEASE')")
    p.branch(10, url(87, 'P87_ID', '&P87_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 88) المستخلص
    p = app.page(88, 'Progress Claim', 'CLAIM', 'المستخلص', scheme=scheme, protection='N')
    r = p.dynamic('المستخلص', 10, [
        'declare l clob := noona_prj_pkg.claim_json(:P88_ID); l_k varchar2(30); l_d varchar2(30);', 'begin',
        "    select max(claim_kind), max(claim_direction) into l_k, l_d from prj_progress_claim where id = :P88_ID;",
        "    if l_k is null then return '<div class=\"nn-empty\">المستخلص غير موجود</div>'; end if;",
        "    return '<div class=\"nn-prj-chips\"><span>' || apex_escape.html(noona_prj_pkg.kind_label(l_k)) || case when l_d = 'PAYABLE' then ' - مقاول باطن' else ' - للعميل' end",
        "        || '</span><span>' || apex_escape.html(json_value(l, '$.no')) || '</span><span>' || apex_escape.html(noona_prj_pkg.status_label(json_value(l, '$.status'))) || '</span></div>'",
        "        || '<script type=\"application/json\" id=\"nnPrjClaimData\">' || replace(l, '</', '<\\/') || '</script><div id=\"nnPrjClaim\"></div>';",
        'end;'], hide_header=True)
    p.hidden('P88_ID', r, 1, protected=False)
    a = p.static('الإجراءات', 20, hide_header=True)
    draft = "noona_prj_pkg.claim_status(:P88_ID) = 'DRAFT'"
    p.text('P88_REASON', a, 10, 'سبب الإلغاء', maxlen=500)
    bap = p.button(a, 10, 'APPROVE', 'اعتماد وترحيل', hot=True, condition=draft)
    bca = p.button(a, 20, 'CANCEL_CLAIM', 'إلغاء المستخلص', condition="noona_prj_pkg.claim_status(:P88_ID) in ('DRAFT', 'APPROVED')")
    p.button(a, 30, 'PRINT', 'طباعة الشهادة', redirect=url(89, 'P89_ID', '&P88_ID.'))
    p.button(a, 40, 'BACK', 'رجوع للعقد', redirect="f?p=&APP_ID.:87:&SESSION.::&DEBUG.:RP:P87_ID:&P88_CONTRACT.")
    p.hidden('P88_CONTRACT', a, 5, protected=False)
    p.process(1, 'ON_DEMAND', 'PRJ', AJAX)
    p.onload(LOADER)
    p.process(5, 'BEFORE_HEADER', 'Contract', 'select max(contract_id) into :P88_CONTRACT from prj_progress_claim where id = :P88_ID;')
    p.process(10, 'AFTER_SUBMIT', 'Approve', 'noona_prj_pkg.approve_claim(:P88_ID);', when_button=bap, success='تم اعتماد المستخلص وترحيل قيده وتسجيل الذمة')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_prj_pkg.cancel_claim(:P88_ID, :P88_REASON);', when_button=bca, success='تم إلغاء المستخلص')
    p.branch(10, url(88, 'P88_ID', '&P88_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 89) طباعة المستخلص
    p = app.page(89, 'Claim Certificate', 'CLAIM-PRINT', 'شهادة المستخلص', scheme=scheme, protection='N')
    r = p.dynamic('الشهادة', 10, 'return noona_prj_pkg.claim_print(:P89_ID);', hide_header=True, opts='#DEFAULT#:t-Region--noUI:nn-print-area')
    p.hidden('P89_ID', r, 1, protected=False)
    b = p.static('طباعة', 20, hide_header=True)
    p.button(b, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
    p.button(b, 20, 'BACK', 'رجوع', redirect=url(88, 'P88_ID', '&P89_ID.'))

    # =========================================================== 90) تقارير المشروعات
    REPORTS = [('PORTFOLIO', 'محفظة المشروعات والربحية'), ('CLAIMS', 'سجل المستخلصات'), ('RETENTION', 'المحتجزات والدفعات المقدمة'),
               ('COSTS', 'تكاليف المشروعات حسب النوع'), ('UNITS', 'توزيع تكلفة التطوير على الوحدات')]
    p = app.page(90, 'Project Reports', 'PROJECT-REPORTS', 'تقارير المشروعات', scheme=scheme, protection='N')
    f = p.static('التقرير والمرشحات', 5, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P90_REPORT', f, 5, 'التقرير', null_text=None, submit=True, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n in REPORTS))
    p.date('P90_FROM', f, 10, 'من تاريخ')
    p.date('P90_TO', f, 20, 'إلى تاريخ')
    p.select('P90_DIR', f, 30, 'الاتجاه', lov_sql='STATIC2:مستخلصات العملاء;RECEIVABLE,مستخلصات مقاولي الباطن;PAYABLE', null_text='الكل')
    p.select('P90_STATUS', f, 35, 'حالة المشروع', lov_sql=STATUS_LOV, null_text='كل الحالات القائمة')
    p.select('P90_PROJECT', f, 40, 'المشروع', lov_sql=PROJECT_LOV, null_text='كل المشروعات')
    p.select('P90_BASIS', f, 50, 'أساس التوزيع', null_text=None, lov_sql='STATIC2:المساحة;AREA,سعر البيع;SALE_VALUE,عدد الوحدات;UNIT_COUNT')
    p.button(f, 10, 'RUN', 'عرض', hot=True)
    p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.process(5, 'BEFORE_HEADER', 'Defaults', [":P90_REPORT := nvl(:P90_REPORT, 'PORTFOLIO'); :P90_BASIS := nvl(:P90_BASIS, 'AREA');",
                                                ":P90_FROM := nvl(:P90_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
                                                ":P90_TO := nvl(:P90_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
    p.dynamic('التقرير', 10, [
        "declare l_f date := to_date(:P90_FROM, 'YYYY-MM-DD'); l_t date := to_date(:P90_TO, 'YYYY-MM-DD');", 'begin',
        '    return case :P90_REPORT',
        "        when 'CLAIMS' then noona_prj_pkg.claims_register_html(l_f, l_t, :P90_DIR)",
        "        when 'RETENTION' then noona_prj_pkg.retention_html",
        "        when 'COSTS' then noona_prj_pkg.cost_report_html(l_f, l_t, :P90_PROJECT)",
        "        when 'UNITS' then case when :P90_PROJECT is null then '<div class=\"nn-empty\">اختر مشروع التطوير العقاري</div>'",
        '                             else noona_prj_pkg.unit_costs_html(:P90_PROJECT, :P90_BASIS) end',
        "        else noona_prj_pkg.portfolio_html(:P90_STATUS, 'f?p=' || :APP_ID || ':81:' || :APP_SESSION || '::NO:RP,81:P81_ID:#ID#') end;",
        'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    FILTERS = {'PORTFOLIO': ['STATUS'], 'CLAIMS': ['FROM', 'TO', 'DIR'], 'RETENTION': [], 'COSTS': ['FROM', 'TO', 'PROJECT'], 'UNITS': ['PROJECT', 'BASIS']}
    import json
    p.onload([
        '(function () {',
        f"    var map = {json.dumps(FILTERS)}, all = ['FROM', 'TO', 'DIR', 'STATUS', 'PROJECT', 'BASIS'];",
        "    var on = map[$v('P90_REPORT')] || [];",
        "    all.forEach(function (k) { var c = document.getElementById('P90_' + k + '_CONTAINER'); if (c) c.style.display = on.indexOf(k) >= 0 ? '' : 'none'; });",
        '})();'])

    # =========================================================== القائمة
    pj = app.nav_item('المشروعات والمقاولات', None, 'fa-briefcase', 35, scheme=scheme)
    app.nav_item('لوحة المشروعات', 80, 'fa-th-large', 1, parent=pj, scheme=scheme)
    app.nav_item('مشروع جديد', url(82, clear='RP,82'), 'fa-plus', 2, parent=pj, scheme=scheme)
    app.nav_item('تقارير المشروعات', 90, 'fa-bar-chart', 3, parent=pj, scheme=scheme)
