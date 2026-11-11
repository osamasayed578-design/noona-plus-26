"""صفحات الأصول الثابتة في تطبيق المالية (127): السجل، بطاقة الأصل وحركاته، الإهلاك، الاستبعاد (بيع وتخريد)، التقارير، الفئات.
المنطق كله في NOONA_FA_PKG.
"""


def build(app, url):
    def link(page_no, item, col='ID'):
        return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'

    FA = app.add_scheme('noona_fa_view', app.id(), 'NOONA - Fixed Assets',
                        "return noona_security_pkg.has_permission('FA_ASSET.VIEW', noona_fa_pkg.company) = 'Y';",
                        'صفحات الأصول الثابتة تتطلب صلاحية عرض الأصول / Fixed assets access required')
    READY = "noona_fa_pkg.is_ready = 'Y'"
    CAT_LOV = ("select name_ar d, id r from fa_category where company_id = noona_fa_pkg.company and is_active = 'Y' order by code")
    BRANCH_LOV = "select name_ar d, id r from org_branch where company_id = noona_fa_pkg.company and status_code = 'ACTIVE' order by name_ar"
    CC_LOV = ("select code || ' - ' || name_ar d, id r from gl_cost_center where company_id = noona_fa_pkg.company "
              "and status_code = 'ACTIVE' order by code")
    EMP_LOV = ("select e.employee_no || ' - ' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
               "where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_fa_pkg.company "
               "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD', 'SUSPENDED')) order by e.employee_no")
    BANK_LOV = ("select code || ' - ' || name_ar d, id r from csh_bank_account where company_id = noona_fa_pkg.company "
                "and status_code = 'ACTIVE' order by code")
    BOX_LOV = ("select code || ' - ' || name_ar d, id r from csh_cash_box where company_id = noona_fa_pkg.company "
               "and status_code = 'ACTIVE' order by code")
    PARTY_LOV = ("select p.display_name_ar || case when exists (select 1 from ap_supplier s where s.party_id = p.id) then ' (مورد)' "
                 "else ' (عميل)' end d, p.id r from pty_party p where exists (select 1 from ap_supplier s where s.party_id = p.id) "
                 "or exists (select 1 from ar_customer c where c.party_id = p.id) order by 1")
    ACC_LOV = ("select a.account_code || ' - ' || a.name_ar d, a.id r from gl_account a join gl_ledger g on g.coa_id = a.coa_id "
               "where g.id = noona_gl_pkg.primary_ledger and a.is_postable = 'Y' order by a.account_code")
    METHOD_LOV = ('STATIC2:القسط الثابت;STRAIGHT_LINE,القسط المتناقص (1.5);DECLINING_BALANCE,'
                  'المتناقص المضاعف (2);DOUBLE_DECLINING,لا يهلك (أراض);NONE')
    PRORATE_LOV = ('STATIC2:يومي من تاريخ التشغيل;DAILY,شهر كامل من شهر التشغيل;FULL_MONTH,'
                   'منتصف الشهر (حتى يوم 15 شهر كامل);MID_MONTH,من الشهر التالي;NEXT_MONTH')
    FUND_LOV = ('STATIC2:تحويل بنكي;BANK,نقداً من الصندوق;CASH,آجل على مورد;PAYABLE,حساب محدد;ACCOUNT,'
                'رصيد افتتاحي (أصل قائم قبل النظام);OPENING')
    PERIOD_LOV = ("select p.period_code || case when exists (select 1 from fa_depreciation_run r where r.period_id = p.id "
                  "and r.status_code = 'POSTED') then ' (مهلكة)' end d, p.id r from gl_period p join gl_fiscal_year y on y.id = p.fiscal_year_id "
                  "where p.company_id = noona_fa_pkg.company and p.period_type = 'NORMAL' and y.status_code = 'OPEN' order by p.start_date")
    ACTIVE_ASSETS = ("select asset_no || ' - ' || name_ar d, id r from fa_asset where company_id = noona_fa_pkg.company "
                     "and status_code in ('IN_SERVICE', 'CAPITALIZED', 'FULLY_DEPRECIATED') order by asset_no")
    st = "noona_fa_pkg.asset_status(:P61_ID)"
    IN_SVC = f"{st} in ('IN_SERVICE', 'CAPITALIZED', 'FULLY_DEPRECIATED')"
    # رابط بطاقة الأصل من تقارير HTML (بدون checksum: الصفحة 61 بلا حماية للعنصر)
    CARD_LINK = ("replace(apex_page.get_url(p_page => 61, p_items => 'P61_ID', p_values => '990000000001'), "
                 "'990000000001', '#ID#')")

    # =============================================================== 60) الأصول الثابتة
    p = app.page(60, 'Fixed Assets', 'FIXED-ASSETS', 'الأصول الثابتة', scheme=FA)
    s = p.static('تجهيز الأصول الثابتة', 5, condition="noona_fa_pkg.is_ready = 'N'",
                 text='<p class="nn-hint">ينشئ الدفتر المالي للأصول، وفئات افتراضية مربوطة بدليل الحسابات (الأراضي، المباني، الآلات، '
                      'الأثاث، السيارات، الحاسب) بأعمارها ونسبها، وحسابات أرباح وخسائر الاستبعاد (4204 و5217) والانخفاض (5218) '
                      'وذمم بيع وشراء الأصول (1109 و2110)، والترقيم. مرة واحدة لكل شركة.</p>')
    b = p.button(s, 10, 'SETUP', 'تجهيز الأصول الثابتة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_fa_pkg.quick_setup;', 'end;'],
              when_button=b, success='تم تجهيز الأصول الثابتة: الدفتر والفئات والحسابات والترقيم')
    p.dynamic('مؤشرات الأصول', 10, 'return noona_fa_pkg.fa_summary;', hide_header=True, condition=READY)
    qa = p.static('إجراءات', 15, hide_header=True, condition=READY)
    p.button(qa, 10, 'NEW', 'أصل جديد', hot=True, redirect=url(61, clear='RP,61'))
    p.button(qa, 20, 'DEPR', 'تشغيل الإهلاك', redirect=url(63))
    p.button(qa, 30, 'DISPOSE', 'بيع / تخريد أصل', redirect=url(65, clear='RP,65'))
    p.button(qa, 40, 'REPORTS', 'تقارير الأصول', redirect=url(66))
    p.button(qa, 50, 'CATS', 'فئات الأصول', redirect=url(67))
    p.ir('سجل الأصول', 20, [
        "select a.id, a.asset_no, a.name_ar, c.name_ar as category, br.name_ar as branch, cc.name_ar as cost_center,",
        "       to_char(a.in_service_date, 'YYYY-MM-DD') as in_service, b.cost, b.accumulated_depr,",
        "       case when b.status_code = 'DISPOSED' then 0 else b.cost - b.accumulated_depr end as nbv,",
        "       noona_fa_pkg.method_label(b.depreciation_method) as method,",
        "       '<span class=\"nn-badge ' || case when a.status_code in ('IN_SERVICE', 'CAPITALIZED') then 'is-success'",
        "       when a.status_code = 'DISPOSED' then 'is-danger' else 'is-warning' end || '\">' || noona_fa_pkg.status_label(a.status_code)",
        "       || '</span>' as status_html, a.tag_no, a.serial_no",
        "  from fa_asset a join fa_asset_book b on b.asset_id = a.id and b.book_id = noona_fa_pkg.default_book",
        "  join fa_category c on c.id = a.category_id left join org_branch br on br.id = a.branch_id",
        "  left join gl_cost_center cc on cc.id = a.cost_center_id",
        " where a.company_id = noona_fa_pkg.company order by a.asset_no desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ASSET_NO', 'رقم الأصل', {}), ('NAME_AR', 'الأصل', {}),
         ('CATEGORY', 'الفئة', {}), ('BRANCH', 'الفرع', {}), ('COST_CENTER', 'مركز التكلفة', {}), ('IN_SERVICE', 'التشغيل', {}),
         ('COST', 'التكلفة', {'type': 'NUMBER'}), ('ACCUMULATED_DEPR', 'مجمع الإهلاك', {'type': 'NUMBER'}),
         ('NBV', 'الصافي', {'type': 'NUMBER'}), ('METHOD', 'الطريقة', {}), ('STATUS_HTML', 'الحالة', {'html': True}),
         ('TAG_NO', 'الملصق', {}), ('SERIAL_NO', 'التسلسلي', {})], link=link(61, 'P61_ID'), titled=True, rows=50)
    p.branch(10, url(60) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 61) الأصل
    p = app.page(61, 'Fixed Asset', 'FIXED-ASSET', 'بطاقة الأصل', scheme=FA, protection='N')
    p.dynamic('بطاقة الأصل', 5, 'return noona_fa_pkg.asset_card_html(:P61_ID);', hide_header=True, condition=':P61_ID is not null',
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    f = p.static('بيانات الأصل', 10, condition=':P61_ID is null')
    p.hidden('P61_ID', f, 1, protected=False)
    p.text('P61_NAME', f, 10, 'اسم الأصل', required=True, maxlen=200)
    p.select('P61_CAT', f, 20, 'الفئة', lov_sql=CAT_LOV, required=True)
    p.select('P61_BRANCH', f, 30, 'الفرع', lov_sql=BRANCH_LOV)
    p.select('P61_CC', f, 40, 'مركز التكلفة (يحمل عليه الإهلاك)', lov_sql=CC_LOV)
    p.select('P61_CUSTODIAN', f, 50, 'العهدة (الموظف المسؤول)', lov_sql=EMP_LOV)
    p.text('P61_LOCATION', f, 60, 'الموقع التفصيلي', maxlen=500)
    p.text('P61_TAG', f, 70, 'رقم الملصق / الباركود (افتراضياً رقم الأصل)', maxlen=100, width=20)
    p.text('P61_SERIAL', f, 80, 'الرقم التسلسلي', maxlen=100, width=20)
    p.text('P61_MANUFACTURER', f, 90, 'الصانع', maxlen=200, width=20)
    p.text('P61_MODEL', f, 100, 'الموديل', maxlen=100, width=20)
    p.date('P61_WARRANTY', f, 110, 'نهاية الضمان')
    v = p.static('التكلفة والإهلاك', 20, condition=':P61_ID is null',
                 text='<p class="nn-hint">الطريقة والعمر والقيمة المتبقية تؤخذ من الفئة إن تركت فارغة. يبدأ الإهلاك من تاريخ التشغيل '
                      'حسب قاعدة الفئة، والأشهر الفائتة تلحق في أول تشغيل إهلاك.</p>')
    p.date('P61_ACQ', v, 10, 'تاريخ الاقتناء (تاريخ القيد)', required=True)
    p.date('P61_SVC', v, 20, 'تاريخ التشغيل (بداية الإهلاك)')
    p.number('P61_COST', v, 30, 'التكلفة (دون الضريبة)', required=True)
    p.number('P61_RESIDUAL', v, 40, 'القيمة المتبقية (الخردة)')
    p.number('P61_LIFE', v, 50, 'العمر الإنتاجي بالأشهر')
    p.select('P61_METHOD', v, 60, 'طريقة الإهلاك', lov_sql=METHOD_LOV, null_text='- حسب الفئة -')
    p.select('P61_PRORATE', v, 70, 'بداية الإهلاك', lov_sql=PRORATE_LOV, null_text='- حسب الفئة -')
    fu = p.static('التمويل والسداد', 30, condition=':P61_ID is null')
    p.select('P61_FUNDING', fu, 10, 'مصدر التمويل', lov_sql=FUND_LOV, null_text=None)
    p.select('P61_BANK', fu, 20, 'الحساب البنكي', lov_sql=BANK_LOV)
    p.select('P61_BOX', fu, 30, 'الصندوق', lov_sql=BOX_LOV)
    p.select('P61_PARTY', fu, 40, 'المورد (للشراء الآجل)', lov_sql=PARTY_LOV)
    p.select('P61_ACCOUNT', fu, 50, 'الحساب المقابل (حساب محدد)', lov_sql=ACC_LOV)
    p.number('P61_VAT', fu, 60, 'ضريبة القيمة المضافة على الشراء (مدخلات)')
    p.number('P61_OPEN_ACC', fu, 70, 'مجمع الإهلاك المنقول (للرصيد الافتتاحي)')
    p.text('P61_REF', fu, 80, 'المرجع (رقم فاتورة المورد...)', maxlen=100, width=20)
    p.yesno('P61_CAPITALIZE', fu, 90, 'رسملة وترحيل القيد الآن')
    b_save = p.button(fu, 10, 'SAVE', 'حفظ الأصل', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    :P61_ACQ := nvl(:P61_ACQ, to_char(sysdate, 'YYYY-MM-DD'));",
        "    :P61_FUNDING := nvl(:P61_FUNDING, 'BANK');",
        "    :P61_CAPITALIZE := nvl(:P61_CAPITALIZE, 'Y');",
        "    :P61_DATE := nvl(:P61_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
        "    :P61_AC_FUND := nvl(:P61_AC_FUND, 'BANK');",
        "    if :P61_ID is not null then",
        "        select useful_life_months, residual_value into :P61_NEW_LIFE, :P61_NEW_RES from fa_asset_book",
        "         where asset_id = :P61_ID and book_id = noona_fa_pkg.default_book;",
        "    end if;",
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Create', [
        'declare l_doc clob;',
        'begin',
        "    select json_object('name_ar' value :P61_NAME, 'category' value to_number(:P61_CAT), 'branch' value to_number(:P61_BRANCH),",
        "                       'cost_center' value to_number(:P61_CC), 'custodian' value to_number(:P61_CUSTODIAN), 'location' value :P61_LOCATION,",
        "                       'tag' value :P61_TAG, 'serial' value :P61_SERIAL, 'manufacturer' value :P61_MANUFACTURER, 'model' value :P61_MODEL,",
        "                       'warranty_end' value :P61_WARRANTY, 'acquisition_date' value :P61_ACQ, 'in_service_date' value :P61_SVC,",
        "                       'cost' value :P61_COST, 'residual' value :P61_RESIDUAL, 'life_months' value :P61_LIFE, 'method' value :P61_METHOD,",
        "                       'prorate' value :P61_PRORATE, 'funding' value :P61_FUNDING, 'bank_account' value :P61_BANK, 'cash_box' value :P61_BOX,",
        "                       'party' value :P61_PARTY, 'account' value :P61_ACCOUNT, 'vat' value :P61_VAT, 'opening_accum' value :P61_OPEN_ACC,",
        "                       'reference' value :P61_REF, 'capitalize' value :P61_CAPITALIZE returning clob) into l_doc from dual;",
        '    :P61_ID := noona_fa_pkg.create_asset(l_doc);',
        'end;'], when_button=b_save, success='تم حفظ الأصل')
    # إجراءات الأصل
    a = p.static('الإجراءات', 8, hide_header=True, condition=':P61_ID is not null')
    b_cap = p.button(a, 10, 'CAPITALIZE', 'رسملة وترحيل قيد الاقتناء', hot=True, condition=f"{st} = 'DRAFT'")
    b_del = p.button(a, 20, 'DELETE', 'حذف المسودة', condition=f"{st} = 'DRAFT'")
    p.button(a, 30, 'DISPOSE', 'بيع / تخريد / استبعاد', redirect=url(65, 'P65_ASSET', '&P61_ID.', 'RP,65'), condition=IN_SVC)
    p.button(a, 40, 'BACK', 'سجل الأصول', redirect=url(60))
    p.process(20, 'AFTER_SUBMIT', 'Capitalize', ['declare l_j number;', 'begin', '    l_j := noona_fa_pkg.capitalize(:P61_ID);', 'end;'],
              when_button=b_cap, success='تمت رسملة الأصل وترحيل قيد الاقتناء')
    p.process(25, 'AFTER_SUBMIT', 'Delete', 'noona_fa_pkg.delete_asset(:P61_ID);', when_button=b_del, success='تم حذف الأصل')
    p.branch(5, url(60) + '&success_msg=#SUCCESS_MSG#', when_button=b_del)
    # حركات
    t = p.static('حركة على الأصل', 30, condition=IN_SVC,
                 text='<p class="nn-hint">الإضافة الرأسمالية ترفع التكلفة، والانخفاض يرفع المجمع (مصروف 5218)، وتغيير العمر والقيمة المتبقية '
                      'يطبق على العمر المتبقي من الآن (مستقبلياً)، والنقل لا يولد قيداً ويحمل الإهلاك القادم على مركز التكلفة الجديد. '
                      '<b>الصيانة</b>: الإصلاح والدورية مصروف (5205)، والعمرة أو التجديد الذي يطيل العمر رأسمالية تضاف لتكلفة الأصل مع تمديد عمره. '
                      'البيان في حقل «السبب / البيان».</p>')
    p.select('P61_ACTION', t, 10, 'الحركة', null_text=None, submit=True, lov_sql=(
        'STATIC2:صيانة (مصروف أو رأسمالية);MAINT,تمديد العمر الإنتاجي;EXTEND,إضافة رأسمالية;ADD,انخفاض في القيمة;IMPAIR,'
        'تغيير العمر والقيمة المتبقية;LIFE,نقل (فرع/مركز تكلفة/عهدة/موقع);TRANSFER'))
    p.select('P61_MT_TYPE', t, 22, 'نوع الصيانة', null_text=None, lov_sql=(
        'STATIC2:إصلاح عطل;CORRECTIVE,وقائية دورية;PREVENTIVE,عمرة / تجديد;OVERHAUL,فحص;INSPECTION,إصلاح حادث;ACCIDENT,تطوير وتحسين;UPGRADE'))
    p.select('P61_MT_TREAT', t, 24, 'المعالجة', null_text=None, lov_sql=(
        'STATIC2:مصروف صيانة (5205);EXPENSE,رأسمالية تضاف لتكلفة الأصل;CAPITALIZE'))
    p.select('P61_MT_PLAN', t, 26, 'خطة الصيانة الدورية', lov_sql=(
        "select service_name || ' · ' || to_char(next_due_date, 'YYYY-MM-DD') d, id r from fa_maint_plan "
        "where asset_id = :P61_ID and status_code = 'ACTIVE' order by next_due_date"))
    p.number('P61_MT_EXT', t, 28, 'تمديد العمر (شهر)')
    p.select('P61_MT_VENDOR', t, 29, 'الورشة / المورد', lov_sql=PARTY_LOV)
    p.date('P61_DATE', t, 20, 'التاريخ')
    p.number('P61_AMOUNT', t, 30, 'المبلغ (للإضافة أو الانخفاض)')
    p.select('P61_AC_FUND', t, 40, 'تمويل الإضافة', null_text=None, lov_sql='STATIC2:تحويل بنكي;BANK,نقداً;CASH,آجل على مورد;PAYABLE,حساب محدد;ACCOUNT')
    p.select('P61_AC_BANK', t, 50, 'الحساب البنكي', lov_sql=BANK_LOV)
    p.select('P61_AC_BOX', t, 55, 'الصندوق', lov_sql=BOX_LOV)
    p.select('P61_AC_PARTY', t, 60, 'المورد', lov_sql=PARTY_LOV)
    p.select('P61_AC_ACCOUNT', t, 65, 'الحساب المقابل', lov_sql=ACC_LOV)
    p.number('P61_AC_VAT', t, 70, 'ضريبة المدخلات')
    p.number('P61_NEW_LIFE', t, 80, 'العمر الإنتاجي الكلي الجديد (شهر)')
    p.number('P61_NEW_RES', t, 90, 'القيمة المتبقية الجديدة')
    p.select('P61_TR_BRANCH', t, 100, 'الفرع الجديد', lov_sql=BRANCH_LOV)
    p.select('P61_TR_CC', t, 110, 'مركز التكلفة الجديد', lov_sql=CC_LOV)
    p.select('P61_TR_CUST', t, 120, 'العهدة الجديدة', lov_sql=EMP_LOV)
    p.text('P61_TR_LOC', t, 130, 'الموقع الجديد', maxlen=500)
    p.text('P61_REASON', t, 140, 'السبب / البيان', maxlen=500)
    b_act = p.button(t, 10, 'APPLY', 'تنفيذ الحركة', hot=True)
    p.process(30, 'AFTER_SUBMIT', 'Apply', [
        'declare l_id number; l_doc clob; l_d date := to_date(:P61_DATE, \'YYYY-MM-DD\');',
        'begin',
        "    case nvl(:P61_ACTION, 'ADD')",
        "        when 'ADD' then l_id := noona_fa_pkg.add_cost(:P61_ID, :P61_AMOUNT, l_d, :P61_AC_FUND, :P61_AC_BANK, :P61_AC_BOX,",
        '                                                  :P61_AC_PARTY, :P61_AC_ACCOUNT, :P61_AC_VAT, :P61_REASON);',
        "        when 'IMPAIR' then l_id := noona_fa_pkg.impair(:P61_ID, :P61_AMOUNT, l_d, :P61_REASON);",
        "        when 'LIFE' then l_id := noona_fa_pkg.change_life(:P61_ID, :P61_NEW_LIFE, :P61_NEW_RES, l_d, :P61_REASON);",
        "        when 'TRANSFER' then l_id := noona_fa_pkg.transfer(:P61_ID, l_d, :P61_TR_BRANCH, :P61_TR_CC, :P61_TR_CUST, :P61_TR_LOC, :P61_REASON);",
        "        when 'EXTEND' then l_id := noona_fa_pkg.extend_life(:P61_ID, to_number(:P61_MT_EXT), l_d, :P61_REASON);",
        "        when 'MAINT' then",
        "            select json_object('asset' value to_number(:P61_ID), 'date' value :P61_DATE, 'maint_type' value :P61_MT_TYPE,",
        "                   'treatment' value :P61_MT_TREAT, 'description' value :P61_REASON, 'amount' value to_number(:P61_AMOUNT),",
        "                   'vat' value to_number(:P61_AC_VAT), 'funding' value :P61_AC_FUND, 'bank_account' value to_number(:P61_AC_BANK),",
        "                   'cash_box' value to_number(:P61_AC_BOX), 'party' value to_number(nvl(:P61_AC_PARTY, :P61_MT_VENDOR)),",
        "                   'account' value to_number(:P61_AC_ACCOUNT), 'life_extension' value to_number(:P61_MT_EXT),",
        "                   'plan' value to_number(:P61_MT_PLAN) absent on null returning clob) into l_doc from dual;",
        "            l_id := noona_fa_pkg.record_maintenance(l_doc);",
        '    end case;',
        "    apex_application.g_print_success_message := 'تم تنفيذ الحركة وتحديث الأصل';",
        'end;'], when_button=b_act)
    p.dynamic('الصيانة وتكلفتها', 35, 'return noona_fa_pkg.maintenance_html(:P61_ID);', condition=':P61_ID is not null')
    p.dynamic('جدول الإهلاك المتوقع', 40, 'return noona_fa_pkg.schedule_html(:P61_ID);',
              condition=f"{st} in ('IN_SERVICE', 'CAPITALIZED')")
    # يظهر الحقول المناسبة للحركة المختارة فقط
    p.onload("""
(function(){
  function show(n, on){ var el = document.getElementById(n + '_CONTAINER'); if (el) el.style.display = on ? '' : 'none'; }
  function sync(){
    var a = $v('P61_ACTION') || 'ADD', f = $v('P61_AC_FUND') || 'BANK';
    var pay = a === 'ADD' || a === 'MAINT', m = a === 'MAINT';
    show('P61_AMOUNT', pay || a === 'IMPAIR');
    ['P61_AC_FUND', 'P61_AC_VAT'].forEach(function(n){ show(n, pay); });
    show('P61_AC_BANK', pay && f === 'BANK'); show('P61_AC_BOX', pay && f === 'CASH');
    show('P61_AC_PARTY', pay && f === 'PAYABLE'); show('P61_AC_ACCOUNT', pay && f === 'ACCOUNT');
    ['P61_MT_TYPE', 'P61_MT_TREAT', 'P61_MT_PLAN'].forEach(function(n){ show(n, m); });
    show('P61_MT_VENDOR', m && f !== 'PAYABLE');
    show('P61_MT_EXT', a === 'EXTEND' || (m && $v('P61_MT_TREAT') === 'CAPITALIZE'));
    ['P61_NEW_LIFE', 'P61_NEW_RES'].forEach(function(n){ show(n, a === 'LIFE'); });
    ['P61_TR_BRANCH', 'P61_TR_CC', 'P61_TR_CUST', 'P61_TR_LOC'].forEach(function(n){ show(n, a === 'TRANSFER'); });
    var g = $v('P61_FUNDING') || 'BANK';
    show('P61_BANK', g === 'BANK'); show('P61_BOX', g === 'CASH'); show('P61_PARTY', g === 'PAYABLE');
    show('P61_ACCOUNT', g === 'ACCOUNT'); show('P61_OPEN_ACC', g === 'OPENING' || g === 'ACCOUNT'); show('P61_VAT', g !== 'OPENING');
  }
  ['P61_ACTION', 'P61_AC_FUND', 'P61_FUNDING', 'P61_MT_TREAT'].forEach(function(n){ $('#' + n).off('change.nnfa').on('change.nnfa', sync); });
  sync();
})();
""")
    p.branch(10, url(61, 'P61_ID', '&P61_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 63) الإهلاك
    # 62) صيانة الأصول: الخطط الدورية والمستحق وسجل الصيانات
    p = app.page(62, 'Asset Maintenance', 'ASSET-MAINTENANCE', 'صيانة الأصول', scheme=FA)
    p.dynamic('الصيانات الدورية المستحقة خلال 30 يوماً', 5, 'return noona_fa_pkg.due_maintenance_html(30);')
    pl = p.static('خطة صيانة دورية', 10, text=(
        '<p class="nn-hint">لكل أصل خطط صيانة دورية بالأشهر (فحص، معايرة، تغيير زيت مولد...). تسجيل الصيانة من بطاقة الأصل مع اختيار '
        'الخطة يحدّث موعدها التالي تلقائياً. صيانة عربات النقل تدار من «صيانة الأسطول» في نظام النقل وترحل هنا.</p>'))
    p.select('P62_ASSET', pl, 10, 'الأصل', lov_sql=ACTIVE_ASSETS, required=True)
    p.text('P62_SVC', pl, 20, 'الصيانة', maxlen=200, width=30)
    p.number('P62_EVERY', pl, 30, 'كل (شهر)')
    p.date('P62_NEXT', pl, 40, 'الموعد التالي')
    p.number('P62_COST', pl, 50, 'التكلفة التقديرية')
    b_pl = p.button(pl, 10, 'SAVE_PLAN', 'حفظ الخطة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Plan', [
        'declare x number; begin',
        "  x := noona_fa_pkg.save_maint_plan(null, to_number(:P62_ASSET), :P62_SVC, to_number(:P62_EVERY), to_date(:P62_NEXT, 'YYYY-MM-DD'), to_number(:P62_COST));",
        '  :P62_SVC := null; :P62_EVERY := null; :P62_NEXT := null; :P62_COST := null;', 'end;'], when_button=b_pl, success='حفظت الخطة')
    p.ir('خطط الصيانة الدورية', 20, [
        "select p.id, a.asset_no, a.name_ar, p.service_name, p.every_months, p.last_done_date, p.next_due_date, p.estimated_cost, p.status_code",
        "  from fa_maint_plan p join fa_asset a on a.id = p.asset_id where p.company_id = noona_fa_pkg.company order by p.next_due_date"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ASSET_NO', 'رقم الأصل', {}), ('NAME_AR', 'الأصل', {}), ('SERVICE_NAME', 'الصيانة', {}),
         ('EVERY_MONTHS', 'كل (شهر)', {'type': 'NUMBER'}), ('LAST_DONE_DATE', 'آخر تنفيذ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
         ('NEXT_DUE_DATE', 'الموعد التالي', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('ESTIMATED_COST', 'التكلفة التقديرية', {'type': 'NUMBER'}),
         ('STATUS_CODE', 'الحالة', {})])
    p.ir('سجل صيانة الأصول', 30, [
        "select m.id, m.doc_no, m.doc_date, a.asset_no, nvl(a.name_ar, 'بدون أصل (عربة مستأجرة)') asset_name,",
        "       noona_fa_pkg.maint_type_label(m.maint_type) maint_type, decode(m.treatment, 'CAPITALIZE', 'رأسمالية', 'مصروف') treatment,",
        "       m.description, pt.display_name_ar vendor, m.amount, m.vat_amount, m.life_extension_months,",
        "       decode(m.source_module, 'TRN', 'صيانة الأسطول', 'الأصول') source_name, decode(m.status_code, 'REVERSED', 'معكوسة', 'مرحلة') status_name",
        "  from fa_maintenance m left join fa_asset a on a.id = m.asset_id left join pty_party pt on pt.id = m.vendor_party_id",
        " where m.company_id = noona_fa_pkg.company order by m.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
         ('ASSET_NO', 'رقم الأصل', {}), ('ASSET_NAME', 'الأصل', {}), ('MAINT_TYPE', 'النوع', {}), ('TREATMENT', 'المعالجة', {}),
         ('DESCRIPTION', 'الوصف', {}), ('VENDOR', 'الورشة', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER', 'fmt': '999G999G990D00'}),
         ('VAT_AMOUNT', 'الضريبة', {'type': 'NUMBER'}), ('LIFE_EXTENSION_MONTHS', 'تمديد العمر', {'type': 'NUMBER'}),
         ('SOURCE_NAME', 'المصدر', {}), ('STATUS_NAME', 'الحالة', {})])
    rv = p.static('عكس صيانة مصروف', 40)
    p.select('P62_MAINT', rv, 10, 'الصيانة', lov_sql=(
        "select doc_no || ' · ' || substr(description, 1, 60) || ' · ' || amount d, id r from fa_maintenance "
        "where company_id = noona_fa_pkg.company and status_code = 'POSTED' and treatment = 'EXPENSE' order by id desc"))
    p.text('P62_REASON', rv, 20, 'سبب العكس', maxlen=400, width=30)
    b_rv = p.button(rv, 10, 'REVERSE', 'عكس القيد')
    p.process(20, 'AFTER_SUBMIT', 'Reverse', 'declare x number; begin x := noona_fa_pkg.reverse_maintenance(to_number(:P62_MAINT), :P62_REASON); :P62_MAINT := null; :P62_REASON := null; end;',
              when_button=b_rv, success='عكس قيد الصيانة')

    p = app.page(63, 'Depreciation', 'DEPRECIATION', 'إهلاك الأصول', scheme=FA)
    f = p.static('تشغيل الإهلاك الشهري', 5, condition=READY,
                 text='<p class="nn-hint">يحسب إهلاك كل الأصول في الخدمة حتى نهاية الفترة (مع لحاق الأشهر الفائتة) ويرحل قيداً واحداً: '
                      'من ح/ مصروف الإهلاك (حسب مركز التكلفة) إلى ح/ مجمع الإهلاك. لا تشغل الفترة مرتين، ويعكس آخر تشغيل فقط.</p>')
    p.select('P63_PERIOD', f, 10, 'الفترة', lov_sql=PERIOD_LOV, required=True, submit=True)
    b_run = p.button(f, 10, 'RUN', 'احتساب وترحيل الإهلاك', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ':P63_PERIOD := nvl(:P63_PERIOD, noona_fa_pkg.next_period);')
    p.process(10, 'AFTER_SUBMIT', 'Run', ['begin', '    :P63_RUN := noona_fa_pkg.run_depreciation(:P63_PERIOD);', 'end;'],
              when_button=b_run, success='تم احتساب الإهلاك وترحيل قيده')
    p.hidden('P63_RUN', f, 20)
    p.dynamic('معاينة إهلاك الفترة', 10, 'return noona_fa_pkg.preview_html(:P63_PERIOD);', condition=':P63_PERIOD is not null')
    p.ir('تشغيلات الإهلاك', 20, [
        "select r.id, p.period_code, to_char(p.end_date, 'YYYY-MM-DD') as end_d, r.total_amount,",
        "       (select count(*) from fa_depreciation_line l where l.run_id = r.id) as assets, j.doc_no as journal_no,",
        "       '<span class=\"nn-badge ' || case r.status_code when 'POSTED' then 'is-success' else 'is-warning' end || '\">'",
        "       || noona_fa_pkg.status_label(r.status_code) || '</span>' as status_html, r.created_by",
        "  from fa_depreciation_run r join gl_period p on p.id = r.period_id left join gl_journal j on j.id = r.journal_id",
        " where r.company_id = noona_fa_pkg.company order by p.start_date desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PERIOD_CODE', 'الفترة', {}), ('END_D', 'نهاية الفترة', {}),
         ('TOTAL_AMOUNT', 'إجمالي الإهلاك', {'type': 'NUMBER'}), ('ASSETS', 'الأصول', {'type': 'NUMBER'}),
         ('JOURNAL_NO', 'القيد', {}), ('STATUS_HTML', 'الحالة', {'html': True}), ('CREATED_BY', 'بواسطة', {})],
        link=link(64, 'P64_ID'), titled=True, rows=24)
    p.branch(5, url(64, 'P64_ID', '&P63_RUN.', 'RP,64') + '&success_msg=#SUCCESS_MSG#', when_button=b_run)
    p.branch(10, url(63, 'P63_PERIOD', '&P63_PERIOD.'))

    # =============================================================== 64) تفاصيل تشغيل الإهلاك
    p = app.page(64, 'Depreciation Run', 'DEPRECIATION-RUN', 'تشغيل الإهلاك', scheme=FA)
    p.dynamic('التفاصيل', 10, 'return noona_fa_pkg.run_html(:P64_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('عكس التشغيل', 5, condition="noona_fa_pkg.run_status(:P64_ID) = 'POSTED'",
                 text='<p class="nn-hint">يعكس قيد الإهلاك ويعيد أرصدة الأصول لما قبل التشغيل لإعادة الاحتساب (آخر تشغيل فقط).</p>')
    p.hidden('P64_ID', a, 1)
    p.text('P64_REASON', a, 10, 'سبب العكس', maxlen=500, required=True)
    b_rev = p.button(a, 10, 'REVERSE', 'عكس التشغيل')
    p.button(a, 20, 'BACK', 'تشغيلات الإهلاك', redirect=url(63))
    p.process(10, 'AFTER_SUBMIT', 'Reverse', ['declare l_j number;', 'begin', '    l_j := noona_fa_pkg.reverse_run(:P64_ID, :P64_REASON);', 'end;'],
              when_button=b_rev, success='تم عكس تشغيل الإهلاك')
    p.branch(10, url(64, 'P64_ID', '&P64_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 65) الاستبعاد: بيع وتخريد
    p = app.page(65, 'Asset Disposal', 'ASSET-DISPOSAL', 'بيع وتخريد الأصول', scheme=FA)
    f = p.static('استبعاد أصل', 10, condition=READY,
                 text='<p class="nn-hint">يلحق الإهلاك حتى تاريخ الاستبعاد، ثم يقفل تكلفة الأصل ومجمع إهلاكه ويثبت المتحصلات '
                      '(بنك/صندوق/مدينو بيع الأصول) وضريبة المخرجات على البيع، والفرق ربح (4204) أو خسارة (5217).</p>')
    p.select('P65_ASSET', f, 10, 'الأصل', lov_sql=ACTIVE_ASSETS, required=True, submit=True)
    p.select('P65_METHOD', f, 20, 'طريقة الاستبعاد', null_text=None, lov_sql=(
        'STATIC2:بيع;SALE,تخريد (بيع خردة أو إتلاف);SCRAP,تبرع;DONATION,فقد أو تلف;LOSS,سرقة;THEFT,استبدال بأصل جديد;TRADE_IN'))
    p.date('P65_DATE', f, 30, 'تاريخ الاستبعاد', required=True)
    p.number('P65_PROCEEDS', f, 40, 'سعر البيع / المتحصلات (دون الضريبة)')
    p.number('P65_VAT', f, 50, 'ضريبة القيمة المضافة (15% على البيع)')
    p.select('P65_RECEIPT', f, 60, 'التحصيل', null_text=None,
             lov_sql='STATIC2:تحويل بنكي;BANK,نقداً في الصندوق;CASH,آجل على المشتري;RECEIVABLE')
    p.select('P65_BANK', f, 70, 'الحساب البنكي', lov_sql=BANK_LOV)
    p.select('P65_BOX', f, 80, 'الصندوق', lov_sql=BOX_LOV)
    p.select('P65_PARTY', f, 90, 'المشتري / الجهة', lov_sql=PARTY_LOV)
    p.text('P65_REASON', f, 100, 'السبب والملاحظات', maxlen=500)
    b_dis = p.button(f, 10, 'DISPOSE', 'ترحيل الاستبعاد', hot=True)
    p.dynamic('الأصل المختار', 15, [
        'declare l_b fa_asset_book%rowtype;',
        'begin',
        '    if :P65_ASSET is null then return null; end if;',
        '    select * into l_b from fa_asset_book where asset_id = :P65_ASSET and book_id = noona_fa_pkg.default_book;',
        "    return '<div class=\"nn-hr-runbar\">' || apex_escape.html(noona_fa_pkg.asset_label(:P65_ASSET)) || ' · التكلفة '",
        "        || to_char(l_b.cost, 'FM999G999G990D00') || ' · المجمع ' || to_char(l_b.accumulated_depr, 'FM999G999G990D00')",
        "        || ' · الصافي ' || to_char(l_b.cost - l_b.accumulated_depr, 'FM999G999G990D00') || ' · إهلاك حتى تاريخ الاستبعاد '",
        "        || to_char(noona_fa_pkg.depreciation_for(l_b.id, to_date(:P65_DATE, 'YYYY-MM-DD')), 'FM999G999G990D00') || '</div>';",
        'end;'], hide_header=True, condition=':P65_ASSET is not null')
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        "begin",
        "    :P65_DATE := nvl(:P65_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
        "    :P65_METHOD := nvl(:P65_METHOD, 'SALE');",
        "    :P65_RECEIPT := nvl(:P65_RECEIPT, 'BANK');",
        "end;"])
    p.process(10, 'AFTER_SUBMIT', 'Dispose', [
        'begin',
        "    :P65_DISPOSAL := noona_fa_pkg.dispose(:P65_ASSET, :P65_METHOD, to_date(:P65_DATE, 'YYYY-MM-DD'), :P65_PROCEEDS, :P65_VAT,",
        '                                          :P65_RECEIPT, :P65_BANK, :P65_BOX, :P65_PARTY, :P65_REASON);',
        'end;'], when_button=b_dis, success='تم ترحيل الاستبعاد وقيد الربح أو الخسارة')
    p.hidden('P65_DISPOSAL', f, 200)
    r = p.static('عكس استبعاد', 30, text='<p class="nn-hint">يعكس قيد الاستبعاد ويعيد الأصل إلى الخدمة بأرصدته السابقة.</p>')
    p.select('P65_REV', r, 10, 'الاستبعاد', lov_sql=(
        "select d.doc_no || ' · ' || a.asset_no || ' - ' || a.name_ar || ' · ' || noona_fa_pkg.disposal_label(d.disposal_method) d, d.id r "
        "from fa_disposal d join fa_asset a on a.id = d.asset_id where d.company_id = noona_fa_pkg.company and d.status_code = 'POSTED' "
        "order by d.disposal_date desc"))
    p.text('P65_REV_REASON', r, 20, 'سبب العكس', maxlen=500)
    b_rev = p.button(r, 10, 'REVERSE', 'عكس الاستبعاد')
    p.process(20, 'AFTER_SUBMIT', 'Reverse', ['declare l_j number;', 'begin',
              '    l_j := noona_fa_pkg.reverse_disposal(:P65_REV, :P65_REV_REASON);', 'end;'],
              when_button=b_rev, success='تم عكس الاستبعاد وإعادة الأصل إلى الخدمة')
    p.ir('الاستبعادات', 40, [
        "select d.id, d.doc_no, to_char(d.disposal_date, 'YYYY-MM-DD') as d_date, a.asset_no, a.name_ar as asset,",
        "       noona_fa_pkg.disposal_label(d.disposal_method) as method, pt.display_name_ar as party, d.proceeds, d.vat_amount,",
        "       d.nbv_at_disposal, d.gain_loss, noona_fa_pkg.status_label(d.status_code) as status, d.reason",
        "  from fa_disposal d join fa_asset a on a.id = d.asset_id left join pty_party pt on pt.id = d.buyer_party_id",
        " where d.company_id = noona_fa_pkg.company order by d.disposal_date desc, d.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'المستند', {}), ('D_DATE', 'التاريخ', {}), ('ASSET_NO', 'رقم الأصل', {}),
         ('ASSET', 'الأصل', {}), ('METHOD', 'الطريقة', {}), ('PARTY', 'الطرف', {}), ('PROCEEDS', 'المتحصلات', {'type': 'NUMBER'}),
         ('VAT_AMOUNT', 'الضريبة', {'type': 'NUMBER'}), ('NBV_AT_DISPOSAL', 'الصافي عند الاستبعاد', {'type': 'NUMBER'}),
         ('GAIN_LOSS', 'ربح / خسارة', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {}), ('REASON', 'السبب', {})], titled=True, rows=20)
    p.onload("""
(function(){
  function show(n, on){ var el = document.getElementById(n + '_CONTAINER'); if (el) el.style.display = on ? '' : 'none'; }
  function sync(){
    var m = $v('P65_METHOD') || 'SALE', r = $v('P65_RECEIPT') || 'BANK', paid = m === 'SALE' || m === 'SCRAP' || m === 'TRADE_IN';
    ['P65_PROCEEDS', 'P65_RECEIPT'].forEach(function(n){ show(n, paid); });
    show('P65_VAT', paid && m !== 'TRADE_IN');
    show('P65_BANK', paid && r === 'BANK'); show('P65_BOX', paid && r === 'CASH');
    show('P65_PARTY', m === 'SALE' || m === 'DONATION' || m === 'TRADE_IN' || r === 'RECEIVABLE');
  }
  $('#P65_PROCEEDS').off('change.nnfa').on('change.nnfa', function(){
    var m = $v('P65_METHOD'), v = parseFloat(($v('P65_PROCEEDS') || '0').replace(/,/g, ''));
    if ((m === 'SALE' || m === 'SCRAP') && !isNaN(v)) $s('P65_VAT', (Math.round(v * 15) / 100).toFixed(2));
  });
  ['P65_METHOD', 'P65_RECEIPT'].forEach(function(n){ $('#' + n).off('change.nnfa').on('change.nnfa', sync); });
  sync();
})();
""")
    p.branch(5, url(61, 'P61_ID', '&P65_ASSET.', 'RP,61') + '&success_msg=#SUCCESS_MSG#', when_button=b_dis)
    p.branch(10, url(65, 'P65_ASSET', '&P65_ASSET.') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 66) التقارير
    REPORTS = [('REGISTER', 'سجل الأصول'), ('ROLL', 'حركة الأصول (التكلفة والمجمع) ومطابقة الأستاذ'),
               ('DISPOSALS', 'الاستبعادات وأرباحها وخسائرها'), ('DISPOSED', 'الأصول المستبعدة')]
    p = app.page(66, 'Asset Reports', 'ASSET-REPORTS', 'تقارير الأصول الثابتة', scheme=FA, protection='N')
    f = p.static('التقرير', 5, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P66_REPORT', f, 10, 'التقرير', null_text=None, submit=True, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n in REPORTS))
    p.date('P66_FROM', f, 20, 'من')
    p.date('P66_TO', f, 30, 'إلى')
    p.select('P66_CAT', f, 40, 'الفئة', lov_sql=CAT_LOV, null_text='- الكل -')
    p.select('P66_BRANCH', f, 50, 'الفرع', lov_sql=BRANCH_LOV, null_text='- الكل -')
    p.button(f, 10, 'RUN', 'عرض', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        "begin",
        "    :P66_REPORT := nvl(:P66_REPORT, 'REGISTER');",
        "    :P66_FROM := nvl(:P66_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
        "    :P66_TO := nvl(:P66_TO, to_char(sysdate, 'YYYY-MM-DD'));",
        "end;"])
    p.dynamic('التقرير', 10, [
        "declare l_f date := to_date(:P66_FROM, 'YYYY-MM-DD'); l_t date := to_date(:P66_TO, 'YYYY-MM-DD');",
        'begin',
        '    return case :P66_REPORT',
        f"        when 'REGISTER' then noona_fa_pkg.register_html(:P66_CAT, :P66_BRANCH, 'ACTIVE', {CARD_LINK})",
        f"        when 'DISPOSED' then noona_fa_pkg.register_html(:P66_CAT, :P66_BRANCH, 'DISPOSED', {CARD_LINK})",
        "        when 'ROLL' then noona_fa_pkg.rollforward_html(l_f, l_t)",
        "        when 'DISPOSALS' then noona_fa_pkg.disposals_html(l_f, l_t)",
        '    end;',
        'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    p.branch(10, url(66, 'P66_REPORT,P66_FROM,P66_TO,P66_CAT,P66_BRANCH',
                     '&P66_REPORT.,&P66_FROM.,&P66_TO.,&P66_CAT.,&P66_BRANCH.', '66'))

    # =============================================================== 67) فئات الأصول
    p = app.page(67, 'Asset Categories', 'ASSET-CATEGORIES', 'فئات الأصول', scheme=FA)
    s = p.static('التجهيز', 5, condition="noona_fa_pkg.is_ready = 'N'")
    b = p.button(s, 10, 'SETUP', 'تجهيز الأصول الثابتة (الدفتر والفئات الافتراضية والحسابات)', hot=True)
    p.process(5, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_fa_pkg.quick_setup;', 'end;'],
              when_button=b, success='تم التجهيز')
    f = p.static('فئة جديدة / تعديل فئة', 10, condition=READY)
    p.select('P67_ID', f, 5, 'الفئة (للتعديل)', lov_sql=(
        "select code || ' - ' || name_ar d, id r from fa_category where company_id = noona_fa_pkg.company order by code"),
        null_text='- فئة جديدة -', submit=True)
    p.text('P67_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=15)
    p.text('P67_NAME', f, 20, 'الاسم', required=True, maxlen=200)
    p.select('P67_METHOD', f, 30, 'طريقة الإهلاك', lov_sql=METHOD_LOV, null_text=None)
    p.number('P67_LIFE', f, 40, 'العمر الإنتاجي (شهر)')
    p.number('P67_RES', f, 50, 'القيمة المتبقية %')
    p.select('P67_PRORATE', f, 60, 'بداية الإهلاك', lov_sql=PRORATE_LOV, null_text=None)
    p.select('P67_ASSET_ACC', f, 70, 'حساب الأصل', lov_sql=ACC_LOV, required=True)
    p.select('P67_ACCUM_ACC', f, 80, 'حساب مجمع الإهلاك', lov_sql=ACC_LOV)
    p.select('P67_EXP_ACC', f, 90, 'حساب مصروف الإهلاك', lov_sql=ACC_LOV)
    p.number('P67_THRESHOLD', f, 100, 'الحد الأدنى للرسملة')
    b_save = p.button(f, 10, 'SAVE', 'حفظ الفئة', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin',
        '    if :P67_ID is not null then',
        '        select code, name_ar, depreciation_method, useful_life_months, residual_pct, prorate_convention, asset_account_id,',
        '               accum_depr_account_id, depr_expense_account_id, capitalization_threshold',
        '          into :P67_CODE, :P67_NAME, :P67_METHOD, :P67_LIFE, :P67_RES, :P67_PRORATE, :P67_ASSET_ACC, :P67_ACCUM_ACC, :P67_EXP_ACC,',
        '               :P67_THRESHOLD',
        '          from fa_category where id = :P67_ID and company_id = noona_fa_pkg.company;',
        '    else',
        "        :P67_METHOD := nvl(:P67_METHOD, 'STRAIGHT_LINE');",
        "        :P67_PRORATE := nvl(:P67_PRORATE, 'DAILY');",
        "        :P67_ACCUM_ACC := nvl(:P67_ACCUM_ACC, noona_fa_pkg.acc('1209'));",
        "        :P67_EXP_ACC := nvl(:P67_EXP_ACC, noona_fa_pkg.acc('5206'));",
        '    end if;',
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', ['begin',
              '    :P67_ID := noona_fa_pkg.save_category(:P67_ID, :P67_CODE, :P67_NAME, :P67_METHOD, :P67_LIFE, :P67_RES, :P67_PRORATE,',
              '                                          :P67_ASSET_ACC, :P67_ACCUM_ACC, :P67_EXP_ACC, :P67_THRESHOLD);', 'end;'],
              when_button=b_save, success='تم حفظ الفئة')
    p.ir('الفئات', 20, [
        "select c.id, c.code, c.name_ar, noona_fa_pkg.method_label(c.depreciation_method) as method, c.useful_life_months,",
        "       round(c.useful_life_months / 12, 1) as years, c.residual_pct, aa.account_code || ' - ' || aa.name_ar as asset_acc,",
        "       ad.account_code as accum_acc, ae.account_code as exp_acc,",
        "       (select count(*) from fa_asset a where a.category_id = c.id and a.status_code not in ('DISPOSED', 'DRAFT')) as assets",
        "  from fa_category c left join gl_account aa on aa.id = c.asset_account_id left join gl_account ad on ad.id = c.accum_depr_account_id",
        "  left join gl_account ae on ae.id = c.depr_expense_account_id where c.company_id = noona_fa_pkg.company order by c.code"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفئة', {}), ('METHOD', 'الطريقة', {}),
         ('USEFUL_LIFE_MONTHS', 'العمر (شهر)', {'type': 'NUMBER'}), ('YEARS', 'العمر (سنة)', {'type': 'NUMBER'}),
         ('RESIDUAL_PCT', 'المتبقية %', {'type': 'NUMBER'}), ('ASSET_ACC', 'حساب الأصل', {}), ('ACCUM_ACC', 'المجمع', {}),
         ('EXP_ACC', 'المصروف', {}), ('ASSETS', 'الأصول القائمة', {'type': 'NUMBER'})], titled=True, rows=30)
    p.branch(10, url(67, 'P67_ID', '&P67_ID.') + '&success_msg=#SUCCESS_MSG#')

    fa = app.nav_item('الأصول الثابتة', None, 'fa-building-o', 65, scheme=FA)
    app.nav_item('سجل الأصول', 60, 'fa-cubes', 1, parent=fa, scheme=FA)
    app.nav_item('أصل جديد', url(61, clear='RP,61'), 'fa-plus', 2, parent=fa, scheme=FA)
    app.nav_item('إهلاك الأصول', 63, 'fa-line-chart', 3, parent=fa, scheme=FA)
    app.nav_item('صيانة الأصول', 62, 'fa-wrench', 3, parent=fa, scheme=FA)
    app.nav_item('بيع وتخريد الأصول', url(65, clear='RP,65'), 'fa-recycle', 4, parent=fa, scheme=FA)
    app.nav_item('تقارير الأصول', 66, 'fa-bar-chart', 5, parent=fa, scheme=FA)
    app.nav_item('فئات الأصول', 67, 'fa-tags', 6, parent=fa, scheme=FA)
