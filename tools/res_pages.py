"""صفحات بيع الوحدات وإدارة الأملاك في تطبيق العقارات والضيافة والمشروعات (139).
البيع: لوحة المبيعات وتوفر الوحدات، الحجز والعقد الجديد، الحجوزات والعقود، العقد (التوقيع، الفوترة، التسليم والمعاينة، الإفراغ، الفسخ)،
التحصيل والعمولات، الأسعار وخطط السداد ورسملة التكاليف، التسليمات، التقارير.
الإيجار: لوحة الإيجارات، عقد الإيجار، العقد (التفعيل، الفوترة، التأمين، التجديد، الإنهاء)، العقود وقائمة الإيجارات، الملاك وكشوفهم، العدادات.
المنطق في NOONA_RES_PKG و NOONA_PRP_PKG.
"""

CO = 'noona_res_pkg.company'
PROP_SALE_LOV = (f"select p.name_ar d, p.id r from re_property p where p.company_id = {CO} and p.status_code <> 'INACTIVE' "
                 "and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in ('SALE', 'MIXED')) order by p.code")
PROP_LEASE_LOV = (f"select p.name_ar d, p.id r from re_property p where p.company_id = {CO} and p.status_code <> 'INACTIVE' "
                  "and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in ('LEASE', 'MIXED')) order by p.code")
PROP_ALL_LOV = f"select name_ar d, id r from re_property where company_id = {CO} and status_code <> 'INACTIVE' order by code"
AVAIL_UNIT_LOV = (f"select p.name_ar || ' / ' || u.code || ' (' || noona_re_pkg.unit_type_label(u.unit_type) || ')' d, u.id r from re_unit u "
                  f"join re_property p on p.id = u.property_id where u.company_id = {CO} and u.status_code = 'AVAILABLE' "
                  "and u.usage_type in ('SALE', 'MIXED') order by p.code, u.code")
PARTY_LOV = ("select p.display_name_ar d, p.id r from pty_party p where p.status_code = 'ACTIVE' "
             f"and exists (select 1 from ar_customer c join ar_customer_account a on a.customer_id = c.id where c.party_id = p.id "
             f"and a.company_id = {CO} and c.is_walk_in = 'N') order by 1")
BROKER_LOV = ("select display_name_ar d, id r from pty_party p where status_code = 'ACTIVE' and exists (select 1 from pty_party_role x "
              "where x.party_id = p.id and x.role_code in ('BROKER', 'AGENT')) order by 1")
OWNER_LOV = ("select display_name_ar d, id r from pty_party p where status_code = 'ACTIVE' and exists (select 1 from pty_party_role x "
             "where x.party_id = p.id and x.role_code in ('OWNER', 'LANDLORD')) order by 1")
PLAN_LOV = (f"select name_ar d, id r from re_payment_plan where company_id = {CO} and is_active = 'Y' "
            "and (property_id is null or property_id = (select property_id from re_unit where id = :P31_UNIT)) order by name_ar")
PLACE_LOV = (f"select 'صندوق: ' || name_ar d, 'BOX:' || id r from csh_cash_box where company_id = {CO} and status_code = 'ACTIVE' "
             f"union all select 'بنك: ' || name_ar, 'BANK:' || id from csh_bank_account where company_id = {CO} and status_code = 'ACTIVE'")
LEASE_TYPE_LOV = 'STATIC2:سكني;RESIDENTIAL,تجاري (مكتب/معرض);COMMERCIAL,محل تجزئة;RETAIL,صناعي/مستودع;INDUSTRIAL,أرض;LAND,مواقف;PARKING'
FREQ_LOV = 'STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY,نصف سنوي;SEMI_ANNUAL,سنوي;ANNUAL,مقدماً دفعة واحدة;UPFRONT'
YN_LOV = 'STATIC2:نعم;Y,لا;N'


def build(app, url, link, get_url):
    RES = app.add_scheme('noona_res_view', app.id(), 'NOONA - Unit Sales',
                         f"return noona_security_pkg.has_permission('RE_SALE_CONTRACT.VIEW', {CO}) = 'Y' and noona_platform_pkg.module_enabled('RE') = 'Y';",
                         'صفحات بيع الوحدات تتطلب صلاحية عرض عقود البيع / Unit sales access required')
    PRP = app.add_scheme('noona_prp_view', app.id(), 'NOONA - Leasing',
                         f"return noona_security_pkg.has_permission('PRP_LEASE.VIEW', {CO}) = 'Y' and noona_platform_pkg.module_enabled('PRP') = 'Y';",
                         'صفحات الإيجارات تتطلب صلاحية عرض عقود الإيجار / Leasing access required')

    # =========================================================== 30) لوحة المبيعات
    p = app.page(30, 'Unit Sales', 'UNIT-SALES', 'بيع الوحدات', scheme=RES)
    p.dynamic('مؤشرات المبيعات', 10, 'return noona_res_pkg.summary_html;', hide_header=True)
    qa = p.static('إجراءات', 15, hide_header=True)
    p.button(qa, 10, 'NEW', 'حجز / عقد جديد', hot=True, redirect=url(31, clear='RP,31'))
    p.button(qa, 20, 'DEALS', 'الحجوزات والعقود', redirect=url(32))
    p.button(qa, 30, 'COLLECT', 'التحصيل والعمولات', redirect=url(34))
    p.button(qa, 40, 'PRICES', 'الأسعار وخطط السداد', redirect=url(35))
    b_bill = p.button(qa, 50, 'BILL', 'فوترة الأقساط المستحقة')
    b_exp = p.button(qa, 60, 'EXPIRE', 'إنهاء الحجوزات المنتهية')
    p.process(10, 'AFTER_SUBMIT', 'Bill', ['declare l_n number;', 'begin', '    l_n := noona_res_pkg.bill_installments;',
                                          "    apex_application.g_print_success_message := 'صدرت ' || l_n || ' فاتورة قسط';", 'end;'], when_button=b_bill)
    p.process(20, 'AFTER_SUBMIT', 'Expire', ['declare l_n number;', 'begin', '    l_n := noona_res_pkg.expire_reservations;',
                                            "    apex_application.g_print_success_message := 'انتهى ' || l_n || ' حجز وتحررت وحداته';", 'end;'], when_button=b_exp)
    f = p.static('توفر الوحدات', 20)
    p.select('P30_PROPERTY', f, 10, 'العقار', lov_sql=PROP_SALE_LOV, submit=True)
    p.process(5, 'BEFORE_HEADER', 'Default', ['begin', f"    select nvl(:P30_PROPERTY, min(p.id)) into :P30_PROPERTY from re_property p where p.company_id = {CO}",
                                              "       and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in ('SALE', 'MIXED'));", 'end;'])
    p.dynamic('الوحدات', 30, f"return noona_res_pkg.availability_html(:P30_PROPERTY, {get_url(31, 'P31_UNIT')});", hide_header=True,
              condition=':P30_PROPERTY is not null')
    p.branch(10, url(30) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 31) حجز / عقد جديد
    p = app.page(31, 'New Unit Deal', 'UNIT-DEAL', 'حجز أو عقد بيع جديد', scheme=RES, protection='N')
    u = p.static('الوحدة والمشتري', 10, text='<p class="nn-hint">اختر مشترياً مسجلاً أو اكتب اسم مشترٍ جديد. السعر الافتراضي من قائمة الأسعار الفعالة؛ '
                                                 'الخصم تحت الحد الأدنى يحتاج صلاحية اعتماد.</p>')
    p.select('P31_UNIT', u, 10, 'الوحدة', lov_sql=AVAIL_UNIT_LOV, required=True, submit=True)
    p.select('P31_BUYER', u, 20, 'المشتري (مسجل)', lov_sql=PARTY_LOV, null_text='- مشتر جديد -')
    p.text('P31_BUYER_NAME', u, 30, 'أو اسم مشترٍ جديد', maxlen=200)
    p.text('P31_PHONE', u, 40, 'الجوال', maxlen=30, width=20)
    p.text('P31_TAX', u, 50, 'الرقم الضريبي (للشركات)', maxlen=20, width=20)
    p.number('P31_PRICE', u, 60, 'السعر')
    p.number('P31_DISCOUNT', u, 70, 'الخصم')
    p.select('P31_BROKER', u, 80, 'الوسيط', lov_sql=BROKER_LOV)
    r = p.static('الحجز بعربون', 20)
    p.number('P31_DEPOSIT', r, 10, 'العربون')
    p.select('P31_PLACE', r, 20, 'استلام العربون في', lov_sql=PLACE_LOV)
    p.number('P31_DAYS', r, 30, 'صلاحية الحجز (أيام)')
    p.text('P31_NOTES', r, 40, 'ملاحظات', maxlen=1000)
    b_res = p.button(r, 10, 'RESERVE', 'حجز الوحدة', hot=True)
    c = p.static('أو عقد بيع مباشر', 30)
    p.select('P31_PLAN', c, 10, 'خطة السداد', lov_sql=PLAN_LOV, null_text='- دفعة واحدة عند التوقيع -')
    p.date('P31_HANDOVER', c, 20, 'التسليم المتوقع')
    p.select('P31_METHOD', c, 30, 'الاعتراف بالإيراد', lov_sql='STATIC2:عند التسليم;POINT_IN_TIME,على مدى الإنشاء (مع كل قسط);OVER_TIME', null_text=None)
    p.number('P31_COMMISSION', c, 40, 'عمولة الوسيط %')
    p.number('P31_ELIGIBLE', c, 50, 'تستحق العمولة عند تحصيل %')
    b_ctr = p.button(c, 10, 'CONTRACT', 'إنشاء عقد البيع')
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    if :P31_UNIT is not null and :P31_PRICE is null then :P31_PRICE := noona_res_pkg.unit_price(:P31_UNIT); end if;",
        "    :P31_DAYS := nvl(:P31_DAYS, 7); :P31_METHOD := nvl(:P31_METHOD, 'POINT_IN_TIME');",
        'end;'])
    common = ("'unit' value to_number(:P31_UNIT), 'buyer' value to_number(:P31_BUYER), 'buyerName' value :P31_BUYER_NAME, 'phone' value :P31_PHONE, "
              "'tax' value :P31_TAX, 'price' value to_number(:P31_PRICE), 'discount' value to_number(:P31_DISCOUNT), 'broker' value to_number(:P31_BROKER)")
    p.process(10, 'AFTER_SUBMIT', 'Reserve', [
        'declare l_id number;', 'begin',
        f"    l_id := noona_res_pkg.reserve(json_object({common}, 'deposit' value to_number(:P31_DEPOSIT), 'place' value :P31_PLACE,",
        "              'days' value to_number(:P31_DAYS), 'notes' value :P31_NOTES));",
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 32, p_items => 'P32_STATUS', p_values => 'ACTIVE'));",
        'end;'], when_button=b_res)
    p.process(20, 'AFTER_SUBMIT', 'Contract', [
        'declare l_id number;', 'begin',
        f"    l_id := noona_res_pkg.create_contract(json_object({common}, 'plan' value to_number(:P31_PLAN), 'handover' value :P31_HANDOVER,",
        "              'method' value :P31_METHOD, 'commission' value to_number(:P31_COMMISSION), 'eligible' value to_number(:P31_ELIGIBLE)));",
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 33, p_items => 'P33_ID', p_values => l_id));",
        'end;'], when_button=b_ctr)
    p.branch(10, url(31, 'P31_UNIT', '&P31_UNIT.'))

    # =========================================================== 32) الحجوزات والعقود
    p = app.page(32, 'Unit Deals', 'UNIT-DEALS', 'الحجوزات وعقود البيع', scheme=RES, protection='N')
    f = p.static('التصفية', 5, hide_header=True)
    p.select('P32_STATUS', f, 10, 'حالة الحجوزات', lov_sql='STATIC2:سارية;ACTIVE,منتهية;EXPIRED,محولة لعقود;CONVERTED,ملغاة;CANCELLED,مستردة;REFUNDED',
             null_text='- الكل -', submit=True)
    p.select('P32_CSTATUS', f, 20, 'حالة العقود', lov_sql=('STATIC2:المفتوحة;OPEN,مسودة;DRAFT,موقعة;SIGNED,موثقة;REGISTERED,جاهزة للتسليم;READY_FOR_HANDOVER,'
                                                          'مسلمة;HANDED_OVER,تم الإفراغ;TITLE_TRANSFERRED,مفسوخة;TERMINATED'), null_text='- الكل -', submit=True)
    p.dynamic('عقود البيع', 10, f"return noona_res_pkg.contracts_html(:P32_CSTATUS, {get_url(33, 'P33_ID')});")
    p.dynamic('الحجوزات', 20, 'return noona_res_pkg.reservations_html(:P32_STATUS);')
    cv = p.static('تحويل حجز إلى عقد', 30)
    p.select('P32_RES', cv, 10, 'الحجز الساري', lov_sql=(f"select r.doc_no || ' - ' || noona_re_pkg.unit_label(r.unit_id) || ' - ' || p.display_name_ar d, r.id r "
                                                         f"from re_reservation r join pty_party p on p.id = r.buyer_party_id where r.company_id = {CO} "
                                                         "and r.status_code = 'ACTIVE' order by r.id desc"))
    p.select('P32_PLAN', cv, 20, 'خطة السداد', lov_sql=f"select name_ar d, id r from re_payment_plan where company_id = {CO} and is_active = 'Y' order by 1",
             null_text='- دفعة واحدة -')
    p.date('P32_HANDOVER', cv, 30, 'التسليم المتوقع')
    p.number('P32_COMMISSION', cv, 40, 'عمولة الوسيط %')
    p.number('P32_ELIGIBLE', cv, 50, 'تستحق عند تحصيل %')
    b_cv = p.button(cv, 10, 'CONVERT', 'إنشاء العقد من الحجز', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Convert', [
        'declare l_id number;', 'begin',
        "    l_id := noona_res_pkg.create_contract(json_object('reservation' value to_number(:P32_RES), 'plan' value to_number(:P32_PLAN),",
        "              'handover' value :P32_HANDOVER, 'commission' value to_number(:P32_COMMISSION), 'eligible' value to_number(:P32_ELIGIBLE)));",
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 33, p_items => 'P33_ID', p_values => l_id));",
        'end;'], when_button=b_cv)
    cn = p.static('إلغاء حجز', 40)
    p.select('P32_CANCEL', cn, 10, 'الحجز', lov_sql=(f"select r.doc_no || ' - ' || noona_re_pkg.unit_label(r.unit_id) || ' (عربون ' || r.deposit_amount || ')' d, "
                                                     f"r.id r from re_reservation r where r.company_id = {CO} and r.status_code in ('ACTIVE', 'EXPIRED') order by r.id desc"))
    p.number('P32_FORFEIT', cn, 20, 'المبلغ المصادر من العربون')
    p.text('P32_REASON', cn, 30, 'السبب', maxlen=500)
    b_cn = p.button(cn, 10, 'CANCEL_RES', 'إلغاء الحجز ورد العربون')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_res_pkg.cancel_reservation(:P32_CANCEL, :P32_REASON, nvl(to_number(:P32_FORFEIT), 0));',
              when_button=b_cn, success='تم إلغاء الحجز وتحرير الوحدة')
    p.branch(10, url(32) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 33) العقد
    st = 'noona_res_pkg.contract_status(:P33_ID)'
    SIGNED = f"{st} in ('SIGNED', 'REGISTERED', 'UNDER_CONSTRUCTION', 'READY_FOR_HANDOVER')"
    p = app.page(33, 'Sale Contract', 'SALE-CONTRACT', 'عقد بيع وحدة', scheme=RES, protection='N')
    p.dynamic('العقد', 10, 'return noona_res_pkg.contract_html(:P33_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P33_ID', a, 1, protected=False)
    b_bill = p.button(a, 10, 'BILL', 'فوترة المستحق', condition=f"{st} not in ('DRAFT', 'TERMINATED', 'CANCELLED')")
    p.button(a, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(a, 30, 'BACK', 'العقود', redirect=url(32))
    s = p.static('توقيع العقد', 30, condition=f"{st} in ('DRAFT', 'APPROVED')")
    p.date('P33_SIGN_DATE', s, 10, 'تاريخ التوقيع')
    p.text('P33_REG', s, 20, 'رقم التوثيق (اختياري)', maxlen=100, width=25)
    b_sign = p.button(s, 10, 'SIGN', 'توقيع العقد', hot=True)
    h = p.static('التسليم', 40, condition=SIGNED)
    p.date('P33_HO_DATE', h, 10, 'موعد/تاريخ التسليم')
    p.textarea('P33_SNAGS_OPEN', h, 20, 'ملاحظات المعاينة المفتوحة (سطر لكل ملاحظة)', rows=3)
    p.textarea('P33_SNAGS_FIXED', h, 30, 'ملاحظات تم إصلاحها (سطر لكل ملاحظة)', rows=2)
    p.number('P33_KEYS', h, 40, 'عدد المفاتيح')
    b_sched = p.button(h, 10, 'SCHEDULE', 'جدولة التسليم')
    b_snag = p.button(h, 20, 'SNAGS', 'حفظ ملاحظات المعاينة')
    b_ho = p.button(h, 30, 'HANDOVER', 'تسليم الوحدة', hot=True)
    t = p.static('الإفراغ (نقل الملكية)', 50, condition=f"{st} in ('SIGNED', 'REGISTERED', 'READY_FOR_HANDOVER', 'HANDED_OVER')")
    p.text('P33_DEED', t, 10, 'رقم الصك الجديد', maxlen=100, width=25)
    p.text('P33_AUTH_REF', t, 20, 'مرجع الجهة', maxlen=100, width=25)
    p.date('P33_TT_DATE', t, 30, 'تاريخ الإفراغ')
    p.number('P33_FEES', t, 40, 'الرسوم')
    p.select('P33_FINANCED', t, 50, 'بتمويل بنكي (قبل السداد الكامل)', lov_sql=YN_LOV, null_text=None)
    b_tt = p.button(t, 10, 'TITLE', 'تسجيل الإفراغ')
    x = p.static('فسخ العقد', 60, condition=f"{st} in ('DRAFT', 'APPROVED', 'SIGNED', 'REGISTERED', 'UNDER_CONSTRUCTION', 'READY_FOR_HANDOVER')")
    p.text('P33_T_REASON', x, 10, 'السبب', maxlen=500)
    p.number('P33_FORFEIT', x, 20, 'المبلغ المصادر من المحصل')
    p.select('P33_T_PLACE', x, 30, 'رد الباقي من', lov_sql=PLACE_LOV)
    b_term = p.button(x, 10, 'TERMINATE', 'فسخ العقد')
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P33_SIGN_DATE := nvl(:P33_SIGN_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
                                               "    :P33_HO_DATE := nvl(:P33_HO_DATE, to_char(sysdate, 'YYYY-MM-DD')); :P33_FINANCED := nvl(:P33_FINANCED, 'N');", 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Sign', "noona_res_pkg.sign_contract(:P33_ID, to_date(:P33_SIGN_DATE, 'YYYY-MM-DD'), :P33_REG);", when_button=b_sign,
              success='تم توقيع العقد وفوترة الدفعة الأولى')
    p.process(20, 'AFTER_SUBMIT', 'Bill', ['declare l_n number;', 'begin', '    l_n := noona_res_pkg.bill_installments(:P33_ID);',
                                          "    apex_application.g_print_success_message := 'صدرت ' || l_n || ' فاتورة قسط';", 'end;'], when_button=b_bill)
    p.process(30, 'AFTER_SUBMIT', 'Schedule', ['declare l_id number;', 'begin',
                                              "    l_id := noona_res_pkg.schedule_handover(:P33_ID, to_date(:P33_HO_DATE, 'YYYY-MM-DD'));", 'end;'],
              when_button=b_sched, success='تمت جدولة التسليم')
    snag_json = ["    select json_arrayagg(json_object('item' value v, 'status' value s) returning clob) into l_j from (",
                 "      select trim(column_value) v, 'OPEN' s from table(apex_string.split(:P33_SNAGS_OPEN, chr(10))) where trim(column_value) is not null",
                 "      union all select trim(column_value), 'FIXED' from table(apex_string.split(:P33_SNAGS_FIXED, chr(10))) where trim(column_value) is not null);"]
    ho_id = ["    select max(id) into l_h from re_handover where contract_id = :P33_ID and status_code <> 'HANDED_OVER';",
             "    if l_h is null then l_h := noona_res_pkg.schedule_handover(:P33_ID, to_date(:P33_HO_DATE, 'YYYY-MM-DD')); end if;"]
    p.process(40, 'AFTER_SUBMIT', 'Snags', ['declare l_h number; l_j clob;', 'begin'] + ho_id + snag_json +
              ["    noona_res_pkg.save_snags(l_h, nvl(l_j, to_clob('[]')));", 'end;'], when_button=b_snag, success='تم حفظ ملاحظات المعاينة')
    p.process(50, 'AFTER_SUBMIT', 'Handover', ['declare l_h number; l_j clob;', 'begin'] + ho_id +
              ["    if :P33_SNAGS_OPEN is not null or :P33_SNAGS_FIXED is not null then"] + ['    ' + x for x in snag_json] +
              ["        noona_res_pkg.save_snags(l_h, nvl(l_j, to_clob('[]')));", '    end if;',
               "    noona_res_pkg.complete_handover(l_h, to_date(:P33_HO_DATE, 'YYYY-MM-DD'), to_number(:P33_KEYS));", 'end;'],
              when_button=b_ho, success='تم تسليم الوحدة والاعتراف بالإيراد')
    p.process(60, 'AFTER_SUBMIT', 'Title', ['declare l_id number;', 'begin',
                                           "    l_id := noona_res_pkg.transfer_title(:P33_ID, json_object('deed' value :P33_DEED, 'ref' value :P33_AUTH_REF,",
                                           "              'date' value :P33_TT_DATE, 'fees' value to_number(:P33_FEES), 'financed' value :P33_FINANCED));", 'end;'],
              when_button=b_tt, success='تم تسجيل الإفراغ ونقل الملكية')
    p.process(70, 'AFTER_SUBMIT', 'Terminate', "noona_res_pkg.terminate_contract(:P33_ID, :P33_T_REASON, nvl(to_number(:P33_FORFEIT), 0), :P33_T_PLACE);",
              when_button=b_term, success='تم فسخ العقد وتحرير الوحدة')
    p.branch(10, url(33, 'P33_ID', '&P33_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 34) التحصيل والعمولات
    p = app.page(34, 'Collections & Commissions', 'UNIT-COLLECTIONS', 'التحصيل والعمولات', scheme=RES, protection='N')
    f = p.static('الفترة', 5, hide_header=True)
    p.date('P34_FROM', f, 10, 'الاستحقاق من')
    p.date('P34_TO', f, 20, 'إلى')
    p.button(f, 10, 'GO', 'عرض', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P34_FROM := nvl(:P34_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
                                               "    :P34_TO := nvl(:P34_TO, to_char(last_day(sysdate) + 30, 'YYYY-MM-DD'));", 'end;'])
    p.dynamic('الأقساط المستحقة والمتأخرة', 10, "return noona_res_pkg.collections_html(to_date(:P34_FROM, 'YYYY-MM-DD'), to_date(:P34_TO, 'YYYY-MM-DD'));",
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    p.dynamic('عمولات الوسطاء', 20, 'return noona_res_pkg.commissions_html;')
    cm = p.static('اعتماد وسداد عمولة', 30, text='<p class="nn-hint">التحصيل من المشترين يتم من شاشة التحصيل في المبيعات على فواتير الأقساط.</p>')
    p.select('P34_COM', cm, 10, 'العمولة', lov_sql=(f"select p.display_name_ar || ' - ' || c.doc_no || ' - ' || b.commission_amount || ' (' || "
                                                    "noona_res_pkg.status_label(b.status_code) || ')' d, b.id r from re_broker_commission b "
                                                    "join pty_party p on p.id = b.broker_party_id join re_sale_contract c on c.id = b.contract_id "
                                                    f"where b.company_id = {CO} and b.status_code in ('ELIGIBLE', 'APPROVED', 'ACCRUED') order by b.id desc"))
    p.select('P34_PLACE', cm, 20, 'السداد من', lov_sql=PLACE_LOV)
    b_ap = p.button(cm, 10, 'APPROVE_COM', 'اعتماد')
    b_pay = p.button(cm, 20, 'PAY_COM', 'سداد', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Approve', 'noona_res_pkg.approve_commission(:P34_COM);', when_button=b_ap, success='تم اعتماد العمولة')
    p.process(20, 'AFTER_SUBMIT', 'Pay', 'noona_res_pkg.pay_commission(:P34_COM, :P34_PLACE);', when_button=b_pay, success='تم سداد العمولة')
    p.branch(10, url(34) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 35) الأسعار وخطط السداد
    p = app.page(35, 'Prices & Payment Plans', 'UNIT-PRICING', 'الأسعار وخطط السداد', scheme=RES)
    pl = p.static('قائمة أسعار جديدة', 10, text='<p class="nn-hint">تتولد أسعار كل وحدات البيع في العقار من سعر المتر وعلاوة الطابق '
                                                 '(نسبة لكل طابق)، والحد الأدنى بنسبة خصم مسموحة. تبقى مسودة حتى تفعيلها.</p>')
    p.select('P35_PROPERTY', pl, 10, 'العقار', lov_sql=PROP_SALE_LOV, required=True)
    p.text('P35_NAME', pl, 20, 'اسم القائمة', required=True, maxlen=200)
    p.number('P35_SQM', pl, 30, 'سعر المتر', required=True)
    p.number('P35_FLOOR_PCT', pl, 40, 'علاوة كل طابق %')
    p.number('P35_MAX_DISC', pl, 50, 'أقصى خصم دون موافقة %')
    p.date('P35_FROM', pl, 60, 'سارية من')
    b_pl = p.button(pl, 10, 'CREATE_LIST', 'إنشاء القائمة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Price List', [
        'declare l_a json_array_t := json_array_t(); l_o json_object_t; l_p number; l_id number; l_doc json_object_t := json_object_t();', 'begin',
        '    for u in (select u.id, nvl(u.net_area_sqm, u.gross_area_sqm) area, nvl(f.floor_no, 0) fl from re_unit u left join re_floor f on f.id = u.floor_id',
        "               where u.property_id = :P35_PROPERTY and u.usage_type in ('SALE', 'MIXED') and nvl(u.net_area_sqm, u.gross_area_sqm) > 0) loop",
        '        l_p := round(u.area * to_number(:P35_SQM) * (1 + nvl(to_number(:P35_FLOOR_PCT), 0) * u.fl / 100), -2);',
        "        l_o := json_object_t(); l_o.put('unit', u.id); l_o.put('price', l_p);",
        "        if :P35_MAX_DISC is not null then l_o.put('min', round(l_p * (1 - to_number(:P35_MAX_DISC) / 100), -2)); end if;",
        '        l_a.append(l_o);',
        '    end loop;',
        "    l_doc.put('property', to_number(:P35_PROPERTY)); l_doc.put('name', :P35_NAME); l_doc.put('from', :P35_FROM); l_doc.put('lines', l_a);",
        '    l_id := noona_res_pkg.save_price_list(l_doc.to_clob);',
        'end;'], when_button=b_pl, success='تم إنشاء قائمة الأسعار (مسودة)')
    p.dynamic('قوائم الأسعار', 20, 'return noona_res_pkg.price_lists_html;')
    ac = p.static('تفعيل قائمة', 25)
    p.select('P35_LIST', ac, 10, 'القائمة', lov_sql=f"select name_ar d, id r from re_price_list where company_id = {CO} and status_code in ('DRAFT', 'APPROVED') order by id desc")
    b_act = p.button(ac, 10, 'ACTIVATE', 'تفعيل وتحديث أسعار الوحدات', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Activate', 'noona_res_pkg.activate_price_list(:P35_LIST);', when_button=b_act, success='تم تفعيل القائمة')
    pp = p.static('خطة سداد جديدة', 30)
    p.text('P35_PLAN_NAME', pp, 10, 'اسم الخطة', required=True, maxlen=200)
    p.select('P35_PLAN_PROP', pp, 20, 'العقار', lov_sql=PROP_SALE_LOV, null_text='- كل العقارات -')
    p.number('P35_DOWN', pp, 30, 'الدفعة الأولى %')
    p.number('P35_COUNT', pp, 40, 'عدد الأقساط')
    p.select('P35_FREQ', pp, 50, 'تكرار الأقساط', lov_sql='STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY,نصف سنوي;SEMI_ANNUAL,سنوي;ANNUAL', null_text=None)
    p.number('P35_HO', pp, 60, 'دفعة عند التسليم %')
    b_plan = p.button(pp, 10, 'SAVE_PLAN', 'حفظ الخطة')
    p.process(30, 'AFTER_SUBMIT', 'Plan', ['declare l_id number;', 'begin',
                                          "    l_id := noona_res_pkg.save_plan(json_object('name' value :P35_PLAN_NAME, 'property' value to_number(:P35_PLAN_PROP),",
                                          "              'down' value to_number(:P35_DOWN), 'count' value to_number(:P35_COUNT), 'freq' value :P35_FREQ,",
                                          "              'handover' value to_number(:P35_HO)));", 'end;'], when_button=b_plan, success='تم حفظ خطة السداد')
    p.dynamic('خطط السداد', 40, 'return noona_res_pkg.plans_html;')
    cc = p.static('رسملة تكاليف التطوير على الوحدات', 50, text='<p class="nn-hint">تنقل تكاليف مشروع التطوير المرتبط بالعقار (غير المرسملة) إلى '
                                                                '«وحدات عقارية معدة للبيع» وتوزع على الوحدات التي لم تسلم، فتصبح تكلفة الوحدة عند تسليمها.</p>')
    p.select('P35_CAP_PROP', cc, 10, 'العقار', lov_sql=(f"select name_ar d, id r from re_property where company_id = {CO} and project_id is not null order by code"))
    p.select('P35_BASIS', cc, 20, 'أساس التوزيع', lov_sql='STATIC2:المساحة;AREA,سعر البيع;SALE_VALUE,عدد الوحدات;UNIT_COUNT', null_text=None)
    b_cap = p.button(cc, 10, 'CAPITALIZE', 'رسملة التكاليف')
    p.process(40, 'AFTER_SUBMIT', 'Capitalize', ['declare l_id number;', 'begin', '    l_id := noona_res_pkg.capitalize_costs(:P35_CAP_PROP, :P35_BASIS);', 'end;'],
              when_button=b_cap, success='تمت رسملة تكاليف التطوير')
    p.dynamic('الرسملات', 60, 'return noona_res_pkg.allocations_html;')
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P35_FREQ := nvl(:P35_FREQ, 'QUARTERLY'); :P35_BASIS := nvl(:P35_BASIS, 'AREA');",
                                               "    :P35_FROM := nvl(:P35_FROM, to_char(sysdate, 'YYYY-MM-DD'));", 'end;'])
    p.branch(10, url(35) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 36) التسليمات والتقارير
    p = app.page(36, 'Unit Sales Reports', 'UNIT-REPORTS', 'تقارير البيع والتسليم', scheme=RES, protection='N')
    f = p.static('الفترة', 5, hide_header=True)
    p.date('P36_FROM', f, 10, 'من')
    p.date('P36_TO', f, 20, 'إلى')
    p.button(f, 10, 'GO', 'عرض', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P36_FROM := nvl(:P36_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
                                               "    :P36_TO := nvl(:P36_TO, to_char(sysdate, 'YYYY-MM-DD'));", 'end;'])
    p.dynamic('المبيعات حسب العقار', 10, "return noona_res_pkg.sales_report_html(to_date(:P36_FROM, 'YYYY-MM-DD'), to_date(:P36_TO, 'YYYY-MM-DD'));",
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    p.dynamic('التسليمات', 20, 'return noona_res_pkg.handovers_html;')

    # =========================================================== 40) لوحة الإيجارات
    p = app.page(40, 'Leasing', 'LEASING', 'الإيجارات وإدارة الأملاك', scheme=PRP)
    p.dynamic('مؤشرات الإيجار', 10, 'return noona_prp_pkg.summary_html;', hide_header=True)
    qa = p.static('إجراءات', 15, hide_header=True)
    p.button(qa, 10, 'NEW', 'عقد إيجار جديد', hot=True, redirect=url(41, clear='RP,41'))
    p.button(qa, 20, 'LEASES', 'العقود وقائمة الإيجارات', redirect=url(43))
    p.button(qa, 30, 'OWNERS', 'الملاك وكشوفهم', redirect=url(44))
    p.button(qa, 40, 'METERS', 'العدادات', redirect=url(46))
    b_bill = p.button(qa, 50, 'BILL', 'فوترة الإيجارات المستحقة')
    b_exp = p.button(qa, 60, 'EXPIRE', 'إنهاء العقود المنتهية')
    p.process(10, 'AFTER_SUBMIT', 'Bill', ['declare l_n number;', 'begin', '    l_n := noona_prp_pkg.bill_rent;',
                                          "    apex_application.g_print_success_message := 'صدرت ' || l_n || ' فاتورة إيجار';", 'end;'], when_button=b_bill)
    p.process(20, 'AFTER_SUBMIT', 'Expire', ['declare l_n number;', 'begin', '    l_n := noona_prp_pkg.expire_leases;',
                                            "    apex_application.g_print_success_message := 'انتهى ' || l_n || ' عقد وتحررت وحداته';", 'end;'], when_button=b_exp)
    p.dynamic('عقود تنتهي خلال 60 يوماً', 20, f"return noona_prp_pkg.expiring_html(60, {get_url(42, 'P42_ID')});")
    p.dynamic('الإيجارات المتأخرة', 30, 'return noona_prp_pkg.overdue_html;')
    p.dynamic('الإشغال حسب العقار', 40, 'return noona_prp_pkg.occupancy_html;')
    p.branch(10, url(40) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 41) عقد إيجار
    p = app.page(41, 'Lease', 'LEASE-EDIT', 'عقد إيجار', scheme=PRP, protection='N')
    f = p.static('العقار والوحدات', 10)
    p.hidden('P41_ID', f, 1, protected=False)
    p.select('P41_PROPERTY', f, 10, 'العقار', lov_sql=PROP_LEASE_LOV, required=True)
    p.select('P41_TYPE', f, 20, 'نوع العقد', lov_sql=LEASE_TYPE_LOV, null_text=None)
    p.checkboxes('P41_UNITS', f, 30, 'الوحدات', lov_sql=("select u.code || ' - ' || noona_re_pkg.unit_type_label(u.unit_type) || ' (' || "
                                                       "noona_re_pkg.unit_status_label(u.status_code) || ')' d, u.id r from re_unit u where u.property_id = :P41_PROPERTY "
                                                       "and u.usage_type in ('LEASE', 'MIXED', 'OWNER_USE') and u.status_code not in ('SOLD', 'HANDED_OVER', 'BLOCKED') order by u.code"),
                 columns=6, cascade='P41_PROPERTY')
    t = p.static('المستأجر', 20)
    p.select('P41_TENANT', t, 10, 'المستأجر (مسجل)', lov_sql=PARTY_LOV, null_text='- مستأجر جديد -')
    p.text('P41_TENANT_NAME', t, 20, 'أو اسم مستأجر جديد', maxlen=200)
    p.text('P41_PHONE', t, 30, 'الجوال', maxlen=30, width=20)
    p.text('P41_TAX', t, 40, 'الرقم الضريبي (للشركات)', maxlen=20, width=20)
    m = p.static('المدة والإيجار', 30)
    p.date('P41_START', m, 10, 'البداية', required=True)
    p.date('P41_END', m, 20, 'النهاية', required=True)
    p.number('P41_RENT', m, 30, 'الإيجار السنوي', required=True)
    p.select('P41_FREQ', m, 40, 'دورية الفوترة', lov_sql=FREQ_LOV, null_text=None)
    p.select('P41_ADVANCE', m, 50, 'الفوترة مقدماً (أول الفترة)', lov_sql=YN_LOV, null_text=None)
    p.number('P41_ESC', m, 60, 'الزيادة السنوية %')
    p.number('P41_DEPOSIT', m, 70, 'التأمين')
    p.number('P41_GRACE', m, 80, 'فترة السماح للسداد (أيام)')
    p.number('P41_NOTICE', m, 90, 'مدة الإشعار (أيام)')
    p.text('P41_REG', m, 100, 'رقم التوثيق (إيجار)', maxlen=100, width=25)
    c = p.static('بنود إضافية', 40)
    p.number('P41_SERVICE', c, 10, 'رسوم الخدمات (شهرياً)')
    p.number('P41_PARKING', c, 20, 'المواقف (شهرياً)')
    p.number('P41_ONETIME', c, 30, 'رسوم لمرة واحدة (عمولة/إدارة)')
    p.text('P41_NOTES', c, 40, 'ملاحظات', maxlen=1000)
    b_save = p.button(c, 10, 'SAVE', 'حفظ مسودة')
    b_act = p.button(c, 20, 'SAVE_ACTIVATE', 'حفظ وتفعيل العقد', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin',
        '    if :P41_ID is not null and :P41_PROPERTY is null then',
        '        select property_id, lease_type, lessee_party_id, to_char(start_date, \'YYYY-MM-DD\'), to_char(end_date, \'YYYY-MM-DD\'), annual_rent,',
        "               billing_frequency, billing_in_advance, json_value(escalation_rule, '$.pct'), deposit_amount, grace_days, notice_days, registration_no, notes",
        '          into :P41_PROPERTY, :P41_TYPE, :P41_TENANT, :P41_START, :P41_END, :P41_RENT, :P41_FREQ, :P41_ADVANCE, :P41_ESC, :P41_DEPOSIT,',
        '               :P41_GRACE, :P41_NOTICE, :P41_REG, :P41_NOTES',
        f'          from prp_lease where id = :P41_ID and company_id = {CO};',
        "        select listagg(unit_id, ':') within group (order by unit_id) into :P41_UNITS from prp_lease_unit where lease_id = :P41_ID;",
        '    end if;',
        "    :P41_TYPE := nvl(:P41_TYPE, 'RESIDENTIAL'); :P41_FREQ := nvl(:P41_FREQ, 'MONTHLY'); :P41_ADVANCE := nvl(:P41_ADVANCE, 'Y');",
        "    :P41_START := nvl(:P41_START, to_char(trunc(sysdate), 'YYYY-MM-DD'));",
        "    :P41_END := nvl(:P41_END, to_char(add_months(trunc(sysdate), 12) - 1, 'YYYY-MM-DD'));",
        'end;'])
    save = [
        'declare l_o json_object_t := json_object_t(); l_u json_array_t := json_array_t(); l_c json_array_t := json_array_t(); l_x json_object_t;', 'begin',
        "    for u in (select column_value v from table(apex_string.split(:P41_UNITS, ':')) where column_value is not null) loop l_u.append(to_number(u.v)); end loop;",
        "    if :P41_SERVICE > 0 then l_x := json_object_t(); l_x.put('type', 'SERVICE_CHARGE'); l_x.put('amount', to_number(:P41_SERVICE)); l_x.put('freq', 'MONTHLY'); l_c.append(l_x); end if;",
        "    if :P41_PARKING > 0 then l_x := json_object_t(); l_x.put('type', 'PARKING'); l_x.put('amount', to_number(:P41_PARKING)); l_x.put('freq', 'MONTHLY'); l_c.append(l_x); end if;",
        "    if :P41_ONETIME > 0 then l_x := json_object_t(); l_x.put('type', 'OTHER'); l_x.put('amount', to_number(:P41_ONETIME)); l_x.put('freq', 'ONE_TIME'); l_c.append(l_x); end if;",
        "    if :P41_ID is not null then l_o.put('id', to_number(:P41_ID)); end if;",
        "    l_o.put('type', :P41_TYPE); l_o.put('property', to_number(:P41_PROPERTY)); l_o.put('units', l_u); l_o.put('charges', l_c);",
        "    if :P41_TENANT is not null then l_o.put('tenant', to_number(:P41_TENANT)); end if;",
        "    l_o.put('tenantName', :P41_TENANT_NAME); l_o.put('phone', :P41_PHONE); l_o.put('tax', :P41_TAX);",
        "    l_o.put('start', :P41_START); l_o.put('end', :P41_END); l_o.put('rent', to_number(:P41_RENT)); l_o.put('freq', :P41_FREQ);",
        "    l_o.put('advance', :P41_ADVANCE); l_o.put('deposit', nvl(to_number(:P41_DEPOSIT), 0)); l_o.put('escalation', to_number(:P41_ESC));",
        "    l_o.put('grace', to_number(:P41_GRACE)); l_o.put('notice', to_number(:P41_NOTICE)); l_o.put('registration', :P41_REG); l_o.put('notes', :P41_NOTES);",
        '    :P41_ID := noona_prp_pkg.save_lease(l_o.to_clob);']
    p.process(10, 'AFTER_SUBMIT', 'Save', save + ['    commit;',
                                                 "    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => 'P42_ID', p_values => :P41_ID));", 'end;'],
              when_button=b_save)
    p.process(20, 'AFTER_SUBMIT', 'Save Activate', save + ['    noona_prp_pkg.activate_lease(:P41_ID);', '    commit;',
                                                          "    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => 'P42_ID', p_values => :P41_ID));", 'end;'],
              when_button=b_act)

    # =========================================================== 42) العقد
    ls = 'noona_prp_pkg.lease_status(:P42_ID)'
    p = app.page(42, 'Lease Card', 'LEASE', 'عقد الإيجار', scheme=PRP, protection='N')
    p.dynamic('العقد', 10, 'return noona_prp_pkg.lease_html(:P42_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P42_ID', a, 1, protected=False)
    p.button(a, 10, 'EDIT', 'تعديل', redirect="f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:&P42_ID.", condition=f"{ls} = 'DRAFT'")
    b_act = p.button(a, 20, 'ACTIVATE', 'تفعيل العقد', hot=True, condition=f"{ls} in ('DRAFT', 'APPROVED')")
    b_bill = p.button(a, 30, 'BILL', 'فوترة المستحق', condition=f"{ls} in ('ACTIVE', 'RENEWAL_PENDING', 'RENEWED', 'EXPIRED', 'TERMINATED')")
    p.button(a, 40, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(a, 50, 'BACK', 'العقود', redirect=url(43))
    d = p.static('التأمين', 30, condition=f"{ls} not in ('DRAFT', 'CANCELLED')")
    p.select('P42_PLACE', d, 10, 'الصندوق أو البنك', lov_sql=PLACE_LOV)
    p.number('P42_DEDUCT', d, 20, 'خصومات من التأمين (عند الإخلاء)')
    p.text('P42_DEDUCT_REASON', d, 30, 'سبب الخصم', maxlen=300)
    b_dep = p.button(d, 10, 'DEPOSIT', 'استلام التأمين', condition=f"{ls} in ('ACTIVE', 'RENEWAL_PENDING') and noona_prp_pkg.has_deposit(:P42_ID) = 'N'")
    b_set = p.button(d, 20, 'SETTLE', 'تسوية ورد التأمين', condition=f"{ls} in ('TERMINATED', 'EXPIRED', 'RENEWED') and noona_prp_pkg.has_deposit(:P42_ID) = 'Y'")
    r = p.static('التجديد', 40, condition=f"{ls} in ('ACTIVE', 'RENEWAL_PENDING', 'EXPIRED')")
    p.date('P42_NEW_END', r, 10, 'نهاية العقد الجديد')
    p.number('P42_NEW_RENT', r, 20, 'الإيجار السنوي الجديد')
    b_ren = p.button(r, 10, 'RENEW', 'إنشاء عقد التجديد')
    x = p.static('الإنهاء والإخلاء', 50, condition=f"{ls} in ('ACTIVE', 'RENEWAL_PENDING', 'SIGNED')")
    p.date('P42_END_DATE', x, 10, 'تاريخ الإخلاء')
    p.text('P42_REASON', x, 20, 'السبب', maxlen=500)
    b_term = p.button(x, 10, 'TERMINATE', 'إنهاء العقد')
    p.process(10, 'AFTER_SUBMIT', 'Activate', 'noona_prp_pkg.activate_lease(:P42_ID);', when_button=b_act, success='تم تفعيل العقد وتوليد جدول الاستحقاقات')
    p.process(20, 'AFTER_SUBMIT', 'Bill', ['declare l_n number;', 'begin', '    l_n := noona_prp_pkg.bill_rent(:P42_ID);',
                                          "    apex_application.g_print_success_message := 'صدرت ' || l_n || ' فاتورة';", 'end;'], when_button=b_bill)
    p.process(30, 'AFTER_SUBMIT', 'Deposit', ['declare l_id number;', 'begin', '    l_id := noona_prp_pkg.receive_deposit(:P42_ID, :P42_PLACE);', 'end;'],
              when_button=b_dep, success='تم استلام التأمين')
    p.process(40, 'AFTER_SUBMIT', 'Settle', [
        'begin',
        "    noona_prp_pkg.settle_deposit(:P42_ID, case when to_number(:P42_DEDUCT) > 0 then json_array(json_object('reason' value :P42_DEDUCT_REASON,",
        "                                 'amount' value to_number(:P42_DEDUCT))) end, :P42_PLACE);",
        'end;'], when_button=b_set, success='تمت تسوية التأمين')
    p.process(50, 'AFTER_SUBMIT', 'Renew', ['declare l_id number;', 'begin',
                                           "    l_id := noona_prp_pkg.renew_lease(:P42_ID, to_date(:P42_NEW_END, 'YYYY-MM-DD'), to_number(:P42_NEW_RENT));",
                                           '    commit;', "    apex_util.redirect_url(apex_page.get_url(p_page => 42, p_items => 'P42_ID', p_values => l_id));", 'end;'],
              when_button=b_ren)
    p.process(60, 'AFTER_SUBMIT', 'Terminate', "noona_prp_pkg.terminate_lease(:P42_ID, to_date(:P42_END_DATE, 'YYYY-MM-DD'), :P42_REASON);",
              when_button=b_term, success='تم إنهاء العقد وتحرير الوحدات')
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P42_END_DATE := nvl(:P42_END_DATE, to_char(sysdate, 'YYYY-MM-DD'));", 'end;'])
    p.branch(10, url(42, 'P42_ID', '&P42_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 43) العقود وقائمة الإيجارات
    p = app.page(43, 'Leases', 'LEASES', 'عقود الإيجار وقائمة الإيجارات', scheme=PRP, protection='N')
    f = p.static('التصفية', 5, hide_header=True)
    p.select('P43_STATUS', f, 10, 'حالة العقود', lov_sql=('STATIC2:المفتوحة;OPEN,سارية;ACTIVE,مسودة;DRAFT,بانتظار التجديد;RENEWAL_PENDING,مجددة;RENEWED,'
                                                         'منتهية;EXPIRED,منهية;TERMINATED'), null_text='- الكل -', submit=True)
    p.select('P43_PROPERTY', f, 20, 'العقار (قائمة الإيجارات)', lov_sql=PROP_LEASE_LOV, null_text='- كل العقارات -', submit=True)
    p.dynamic('العقود', 10, f"return noona_prp_pkg.leases_html(:P43_STATUS, {get_url(42, 'P42_ID')});")
    p.dynamic('قائمة الإيجارات (Rent Roll)', 20, 'return noona_prp_pkg.rent_roll_html(:P43_PROPERTY);', opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

    # =========================================================== 44) الملاك
    p = app.page(44, 'Owners', 'PROPERTY-OWNERS', 'إدارة أملاك الغير', scheme=PRP)
    p.dynamic('اتفاقيات الإدارة', 10, 'return noona_prp_pkg.agreements_html;')
    g = p.static('اتفاقية جديدة', 20, text='<p class="nn-hint">إيجارات العقار المدار تقيد مستحقة للمالك، وتخصم الأتعاب والمصروفات في كشف المالك ثم يحول الصافي.</p>')
    p.select('P44_OWNER', g, 10, 'المالك (مسجل)', lov_sql=OWNER_LOV, null_text='- مالك جديد -')
    p.text('P44_OWNER_NAME', g, 20, 'أو اسم مالك جديد', maxlen=200)
    p.select('P44_PROPERTY', g, 30, 'العقار', lov_sql=PROP_ALL_LOV, required=True)
    p.select('P44_FEE_TYPE', g, 40, 'الأتعاب', lov_sql='STATIC2:نسبة من المحصل;PCT_OF_COLLECTION,نسبة من الإيجار;PCT_OF_RENT,مبلغ شهري ثابت;FIXED_MONTHLY,نسبة ومبلغ;MIXED',
             null_text=None)
    p.number('P44_FEE_PCT', g, 50, 'النسبة %')
    p.number('P44_FEE_FIXED', g, 60, 'المبلغ الشهري')
    p.select('P44_REMIT', g, 70, 'التحويل للمالك', lov_sql='STATIC2:شهري;MONTHLY,ربع سنوي;QUARTERLY', null_text=None)
    p.date('P44_FROM', g, 80, 'من')
    b_agr = p.button(g, 10, 'SAVE_AGR', 'حفظ الاتفاقية', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Agreement', ['declare l_id number;', 'begin',
                                               "    l_id := noona_prp_pkg.save_agreement(json_object('owner' value to_number(:P44_OWNER), 'ownerName' value :P44_OWNER_NAME,",
                                               "              'property' value to_number(:P44_PROPERTY), 'feeType' value :P44_FEE_TYPE, 'feePct' value to_number(:P44_FEE_PCT),",
                                               "              'feeFixed' value to_number(:P44_FEE_FIXED), 'remit' value :P44_REMIT, 'from' value :P44_FROM));", 'end;'],
              when_button=b_agr, success='تم حفظ الاتفاقية')
    p.dynamic('كشوف الملاك', 30, f"return noona_prp_pkg.statements_html({get_url(45, 'P45_ID')});")
    s = p.static('كشف جديد', 40)
    p.select('P44_AGR', s, 10, 'الاتفاقية', lov_sql=(f"select a.doc_no || ' - ' || p.display_name_ar || ' - ' || noona_re_pkg.property_name(a.property_id) d, a.id r "
                                                     "from prp_management_agreement a join pty_party p on p.id = a.owner_party_id "
                                                     f"where a.company_id = {CO} and a.status_code = 'ACTIVE' order by a.id desc"))
    p.date('P44_S_FROM', s, 20, 'من')
    p.date('P44_S_TO', s, 30, 'إلى')
    p.number('P44_EXPENSES', s, 40, 'مصروفات دفعت عن المالك')
    b_st = p.button(s, 10, 'STATEMENT', 'إعداد الكشف')
    p.process(20, 'AFTER_SUBMIT', 'Statement', ['declare l_id number;', 'begin',
                                               "    l_id := noona_prp_pkg.owner_statement(:P44_AGR, to_date(:P44_S_FROM, 'YYYY-MM-DD'), to_date(:P44_S_TO, 'YYYY-MM-DD'),",
                                               '              nvl(to_number(:P44_EXPENSES), 0));', '    commit;',
                                               "    apex_util.redirect_url(apex_page.get_url(p_page => 45, p_items => 'P45_ID', p_values => l_id));", 'end;'],
              when_button=b_st)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P44_FEE_TYPE := nvl(:P44_FEE_TYPE, 'PCT_OF_COLLECTION'); :P44_REMIT := nvl(:P44_REMIT, 'MONTHLY');",
                                               "    :P44_S_FROM := nvl(:P44_S_FROM, to_char(add_months(trunc(sysdate, 'MM'), -1), 'YYYY-MM-DD'));",
                                               "    :P44_S_TO := nvl(:P44_S_TO, to_char(trunc(sysdate, 'MM') - 1, 'YYYY-MM-DD'));", 'end;'])
    p.branch(10, url(44) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 45) كشف المالك
    sst = 'noona_prp_pkg.statement_status(:P45_ID)'
    p = app.page(45, 'Owner Statement', 'OWNER-STATEMENT', 'كشف حساب المالك', scheme=PRP, protection='N')
    p.dynamic('الكشف', 10, 'return noona_prp_pkg.statement_html(:P45_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P45_ID', a, 1, protected=False)
    p.select('P45_PLACE', a, 10, 'التحويل من', lov_sql=PLACE_LOV)
    b_ap = p.button(a, 10, 'APPROVE', 'اعتماد الكشف', hot=True, condition=f"{sst} = 'DRAFT'")
    b_rm = p.button(a, 20, 'REMIT', 'تحويل الصافي للمالك', hot=True, condition=f"{sst} in ('APPROVED', 'SENT')")
    p.button(a, 30, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(a, 40, 'BACK', 'الملاك', redirect=url(44))
    p.process(10, 'AFTER_SUBMIT', 'Approve', 'noona_prp_pkg.approve_statement(:P45_ID);', when_button=b_ap, success='تم اعتماد الكشف وقيد الأتعاب')
    p.process(20, 'AFTER_SUBMIT', 'Remit', 'noona_prp_pkg.remit_statement(:P45_ID, :P45_PLACE);', when_button=b_rm, success='تم التحويل للمالك')
    p.branch(10, url(45, 'P45_ID', '&P45_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 46) العدادات
    p = app.page(46, 'Meters', 'METERS', 'العدادات والاستهلاك', scheme=PRP)
    p.dynamic('العدادات', 10, 'return noona_prp_pkg.meters_html;')
    m = p.static('عداد جديد', 20)
    p.select('P46_UNIT', m, 10, 'الوحدة', lov_sql=(f"select p.name_ar || ' / ' || u.code d, u.id r from re_unit u join re_property p on p.id = u.property_id "
                                                   f"where u.company_id = {CO} and u.usage_type in ('LEASE', 'MIXED') order by p.code, u.code"), required=True)
    p.select('P46_TYPE', m, 20, 'النوع', lov_sql='STATIC2:كهرباء;ELECTRICITY,مياه;WATER,غاز;GAS,تبريد مركزي;CHILLED_WATER', null_text=None)
    p.text('P46_NO', m, 30, 'رقم العداد', required=True, maxlen=100, width=20)
    p.text('P46_ACC', m, 40, 'رقم حساب المرفق', maxlen=100, width=20)
    p.number('P46_RATE', m, 50, 'سعر وحدة الاستهلاك للفوترة')
    b_m = p.button(m, 10, 'SAVE_METER', 'حفظ العداد')
    p.process(10, 'AFTER_SUBMIT', 'Meter', ['declare l_id number;', 'begin',
                                           "    l_id := noona_prp_pkg.save_meter(json_object('unit' value to_number(:P46_UNIT), 'type' value :P46_TYPE, 'no' value :P46_NO,",
                                           "              'account' value :P46_ACC, 'rate' value to_number(:P46_RATE)));", 'end;'], when_button=b_m, success='تم حفظ العداد')
    rd = p.static('قراءة', 30)
    p.select('P46_METER', rd, 10, 'العداد', lov_sql=(f"select meter_no || ' - ' || nvl(noona_re_pkg.unit_label(unit_id), 'مشترك') d, id r from prp_meter "
                                                     f"where company_id = {CO} and status_code = 'ACTIVE' order by meter_no"), required=True)
    p.date('P46_DATE', rd, 20, 'التاريخ', required=True)
    p.number('P46_VALUE', rd, 30, 'القراءة', required=True)
    b_r = p.button(rd, 10, 'READING', 'حفظ القراءة', hot=True)
    b_b = p.button(rd, 20, 'BILL_READINGS', 'إضافة الاستهلاك لعقود الوحدات')
    p.process(20, 'AFTER_SUBMIT', 'Reading', ['declare l_id number;', 'begin',
                                             "    l_id := noona_prp_pkg.add_reading(:P46_METER, to_date(:P46_DATE, 'YYYY-MM-DD'), to_number(:P46_VALUE));", 'end;'],
              when_button=b_r, success='تم حفظ القراءة')
    p.process(30, 'AFTER_SUBMIT', 'Bill', ['declare l_n number;', 'begin', '    l_n := noona_prp_pkg.bill_readings;',
                                          "    apex_application.g_print_success_message := 'أضيف استهلاك ' || l_n || ' قراءة لجداول العقود (تفوتر مع الإيجار)';", 'end;'],
              when_button=b_b)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P46_DATE := nvl(:P46_DATE, to_char(sysdate, 'YYYY-MM-DD')); :P46_TYPE := nvl(:P46_TYPE, 'ELECTRICITY');", 'end;'])
    p.branch(10, url(46) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== القائمة
    sl = app.nav_item('بيع الوحدات', None, 'fa-key', 25, scheme=RES)
    app.nav_item('لوحة المبيعات', 30, 'fa-th-large', 1, parent=sl, scheme=RES)
    app.nav_item('حجز / عقد جديد', url(31, clear='RP,31'), 'fa-plus', 2, parent=sl, scheme=RES)
    app.nav_item('الحجوزات والعقود', 32, 'fa-file-text-o', 3, parent=sl, scheme=RES)
    app.nav_item('التحصيل والعمولات', 34, 'fa-money', 4, parent=sl, scheme=RES)
    app.nav_item('الأسعار وخطط السداد', 35, 'fa-tags', 5, parent=sl, scheme=RES)
    app.nav_item('التقارير والتسليم', 36, 'fa-bar-chart', 6, parent=sl, scheme=RES)
    le = app.nav_item('الإيجارات وإدارة الأملاك', None, 'fa-building-o', 27, scheme=PRP)
    app.nav_item('لوحة الإيجارات', 40, 'fa-th-large', 1, parent=le, scheme=PRP)
    app.nav_item('عقد إيجار جديد', url(41, clear='RP,41'), 'fa-plus', 2, parent=le, scheme=PRP)
    app.nav_item('العقود وقائمة الإيجارات', 43, 'fa-list', 3, parent=le, scheme=PRP)
    app.nav_item('إدارة أملاك الغير', 44, 'fa-handshake-o', 4, parent=le, scheme=PRP)
    app.nav_item('العدادات', 46, 'fa-tachometer', 5, parent=le, scheme=PRP)
