"""صفحات الضرائب والتوطين في تطبيق المالية (127): لوحة الضرائب وحزمة الدولة، التسجيلات القانونية، الإقرارات وإقرار الفترة،
السجل الضريبي، الاستقطاع وشهاداته، الفوترة الإلكترونية (الإعداد والطابور وتفاصيل الإرسال).
المنطق كله في NOONA_LOC_PKG و NOONA_EINV_PKG.
"""


def build(app, url):
    CO = 'noona_loc_pkg.company'
    TAX = app.add_scheme('noona_tax_view', app.id(), 'NOONA - Tax',
                         f"return noona_security_pkg.has_permission('LOC_TAX_RETURN.VIEW', {CO}) = 'Y';",
                         'صفحات الضرائب تتطلب صلاحية عرض الإقرارات الضريبية / Tax access required')
    PLACE_LOV = (f"select 'صندوق: ' || name_ar d, 'BOX:' || id r from csh_cash_box where company_id = {CO} and status_code = 'ACTIVE' "
                 f"union all select 'بنك: ' || name_ar, 'BANK:' || id from csh_bank_account where company_id = {CO} and status_code = 'ACTIVE'")
    REG_TYPE_LOV = ("select t.name_ar || case when t.is_tax_registration = 'Y' then ' (ضريبي)' end d, t.id r from loc_registration_type t "
                    "where t.country_pack_id = noona_loc_pkg.company_pack and t.is_active = 'Y' order by t.is_tax_registration desc, t.code")
    SUP_LOV = (f"select p.display_name_ar || case when p.country_code is not null and p.country_code <> noona_loc_pkg.company_country "
               f"then ' (' || p.country_code || ' - غير مقيم)' end d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id "
               f"join pty_party p on p.id = s.party_id where a.company_id = {CO} order by 1")
    WHT_LOV = ("select c.code || ' - ' || c.name_ar d, c.code r from loc_tax_code c join loc_tax_type t on t.id = c.tax_type_id "
               "where t.country_pack_id = noona_loc_pkg.company_pack and t.tax_category = 'WITHHOLDING' and c.status_code = 'ACTIVE' order by c.code")
    BRANCH_LOV = f"select name_ar d, id r from org_branch where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"
    PACK_READY = "noona_loc_pkg.company_pack is not null"

    def get_url(page, item, placeholder='990000000001'):
        # رابط بمعامل من تقارير HTML (الصفحات الهدف بلا حماية للعنصر)
        return (f"replace(apex_page.get_url(p_page => {page}, p_items => '{item}', p_values => '{placeholder}'), "
                f"'{placeholder}', '#ID#')")

    # =============================================================== 70) لوحة الضرائب
    p = app.page(70, 'Tax Dashboard', 'TAX', 'الضرائب والتوطين', scheme=TAX)
    s = p.static('تطبيق حزمة الدولة', 5, condition="noona_loc_pkg.company_pack is null",
                 text='<p class="nn-hint">يربط الشركة بحزمة دولتها (أكواد الضرائب ونسبها النظامية، التسجيلات وصيغ أرقامها، الأشكال القانونية) '
                      'وينشئ حسابات الضرائب: المخرجات 2104، المدخلات 1107، الاستقطاع 2106، المستحق للجهة 2107.</p>')
    b = p.button(s, 10, 'SETUP', 'تطبيق حزمة الدولة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_loc_pkg.setup_company;', 'end;'],
              when_button=b, success='تم تطبيق حزمة الدولة وتجهيز حسابات الضرائب')
    p.dynamic('مؤشرات الضرائب', 10, 'return noona_loc_pkg.summary_html;', hide_header=True, condition=PACK_READY)
    qa = p.static('إجراءات', 15, hide_header=True, condition=PACK_READY)
    p.button(qa, 10, 'RETURNS', 'الإقرارات الضريبية', hot=True, redirect=url(72))
    p.button(qa, 20, 'REGISTER', 'السجل الضريبي', redirect=url(74))
    p.button(qa, 30, 'WHT', 'الاستقطاع', redirect=url(75))
    p.button(qa, 40, 'EINV', 'الفوترة الإلكترونية', redirect=url(77))
    p.button(qa, 50, 'REGS', 'التسجيلات القانونية', redirect=url(71))
    b2 = p.button(qa, 60, 'RESYNC', 'تحديث حسابات الضرائب')
    p.process(20, 'AFTER_SUBMIT', 'Resync', ['declare l_n number;', 'begin', '    l_n := noona_loc_pkg.setup_company;',
                                            "    apex_application.g_print_success_message := 'أضيف ' || l_n || ' ربط حساب لأكواد الضرائب';", 'end;'],
              when_button=b2)
    p.dynamic('حزمة الدولة', 20, 'return noona_loc_pkg.pack_html;', condition=PACK_READY)
    p.branch(10, url(70) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 71) التسجيلات القانونية
    p = app.page(71, 'Legal Registrations', 'TAX-REGISTRATIONS', 'التسجيلات القانونية', scheme=TAX)
    p.dynamic('تسجيلات الشركة', 10, 'return noona_loc_pkg.registrations_html;')
    f = p.static('تسجيل جديد / تحديث', 20, text='<p class="nn-hint">يتحقق الرقم من صيغة التسجيل في حزمة الدولة (مثل الرقم الضريبي السعودي '
                                                 '15 رقماً يبدأ وينتهي بـ 3). التسجيل الضريبي الرئيسي يظهر في الفواتير والإقرارات.</p>')
    p.select('P71_TYPE', f, 10, 'نوع التسجيل', lov_sql=REG_TYPE_LOV, required=True)
    p.text('P71_NUMBER', f, 20, 'الرقم', required=True, maxlen=100, width=25)
    p.text('P71_AUTHORITY', f, 30, 'الجهة المصدرة', maxlen=200)
    p.date('P71_ISSUE', f, 40, 'تاريخ الإصدار')
    p.date('P71_EXPIRY', f, 50, 'تاريخ الانتهاء')
    b_save = p.button(f, 10, 'SAVE', 'حفظ التسجيل', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Save', [
        'declare l_id number;', 'begin',
        "    l_id := noona_loc_pkg.save_registration(json_object('type' value to_number(:P71_TYPE), 'number' value :P71_NUMBER,",
        "              'authority' value :P71_AUTHORITY, 'issue' value :P71_ISSUE, 'expiry' value :P71_EXPIRY, 'primary' value 'Y'));",
        'end;'], when_button=b_save, success='تم حفظ التسجيل')
    e = p.static('إنهاء تسجيل', 30)
    p.select('P71_END', e, 10, 'التسجيل', lov_sql=(
        f"select t.name_ar || ' - ' || g.reg_number d, g.id r from org_legal_registration g join loc_registration_type t on t.id = g.reg_type_id "
        f"where g.company_id = {CO} and g.status_code <> 'CANCELLED' order by t.code"))
    b_end = p.button(e, 10, 'END', 'إنهاء التسجيل')
    p.process(20, 'AFTER_SUBMIT', 'End', 'noona_loc_pkg.end_registration(:P71_END);', when_button=b_end, success='تم إنهاء التسجيل')
    p.branch(10, url(71, clear='71') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 72) الإقرارات
    p = app.page(72, 'Tax Returns', 'TAX-RETURNS', 'الإقرارات الضريبية', scheme=TAX)
    f = p.static('إقرار جديد', 10, text='<p class="nn-hint">يحتسب الإقرار من السجل الضريبي الموحد لكل الوحدات (المبيعات ونقاط البيع '
                                         'والمشتريات والمستشفى والفنادق والمستخلصات وبيع الأصول). إقرار الاستقطاع يجمع شهادات الفترة.</p>')
    p.select('P72_KIND', f, 10, 'الضريبة', lov_sql='STATIC2:ضريبة القيمة المضافة;VAT,ضريبة الاستقطاع;WHT', null_text=None)
    p.date('P72_FROM', f, 20, 'من', required=True)
    p.date('P72_TO', f, 30, 'إلى', required=True)
    b_new = p.button(f, 10, 'CREATE', 'إعداد الإقرار', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    :P72_KIND := nvl(:P72_KIND, 'VAT');",
        "    :P72_FROM := nvl(:P72_FROM, to_char(add_months(trunc(sysdate, 'Q'), -3), 'YYYY-MM-DD'));",
        "    :P72_TO := nvl(:P72_TO, to_char(trunc(sysdate, 'Q') - 1, 'YYYY-MM-DD'));",
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Create', [
        'declare l_id number;', 'begin',
        "    l_id := noona_loc_pkg.new_return(:P72_KIND, to_date(:P72_FROM, 'YYYY-MM-DD'), to_date(:P72_TO, 'YYYY-MM-DD'));",
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 73, p_items => 'P73_ID', p_values => l_id));",
        'end;'], when_button=b_new)
    p.dynamic('الإقرارات', 20, f'return noona_loc_pkg.returns_html({get_url(73, "P73_ID")});')
    p.branch(10, url(72) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 73) الإقرار
    st = "noona_loc_pkg.return_status(:P73_ID)"
    p = app.page(73, 'Tax Return', 'TAX-RETURN', 'الإقرار الضريبي', scheme=TAX, protection='N')
    p.dynamic('الإقرار', 10, 'return noona_loc_pkg.return_html(:P73_ID);', hide_header=True,
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P73_ID', a, 1, protected=False)
    b_calc = p.button(a, 10, 'RECALC', 'إعادة الاحتساب', condition=f"{st} in ('DRAFT', 'REOPENED')")
    b_rev = p.button(a, 20, 'REVIEW', 'تمت المراجعة', hot=True, condition=f"{st} in ('DRAFT', 'REOPENED')")
    b_apr = p.button(a, 30, 'APPROVE', 'اعتماد الإقرار', hot=True, condition=f"{st} = 'REVIEWED'")
    p.button(a, 40, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(a, 50, 'BACK', 'الإقرارات', redirect=url(72))
    adj = p.static('تصحيحات الفترات السابقة (خانة 14)', 30, condition=f"{st} in ('DRAFT', 'REOPENED')")
    p.number('P73_ADJ', adj, 10, 'مبلغ التصحيح (موجب يزيد الضريبة، سالب ينقصها)')
    p.text('P73_ADJ_NOTE', adj, 20, 'السبب والمرجع', maxlen=500)
    b_adj = p.button(adj, 10, 'ADJUST', 'تسجيل التصحيح')
    fl = p.static('تقديم الإقرار للجهة', 40, condition=f"{st} = 'APPROVED'")
    p.text('P73_REF', fl, 10, 'رقم الإقرار / مرجع التقديم في البوابة', maxlen=200, width=30)
    p.date('P73_FILED', fl, 20, 'تاريخ التقديم')
    b_file = p.button(fl, 10, 'FILE', 'تسجيل التقديم', hot=True)
    pay = p.static('سداد الضريبة المستحقة', 50, condition=f"{st} in ('FILED', 'APPROVED')")
    p.select('P73_PLACE', pay, 10, 'السداد من', lov_sql=PLACE_LOV)
    p.date('P73_PAY_DATE', pay, 20, 'تاريخ السداد')
    b_pay = p.button(pay, 10, 'PAY', 'سداد', hot=True)
    ro = p.static('إعادة فتح الإقرار (قبل التقديم)', 60, condition=f"{st} in ('REVIEWED', 'APPROVED')")
    p.text('P73_REASON', ro, 10, 'السبب', maxlen=500)
    b_ro = p.button(ro, 10, 'REOPEN', 'إعادة الفتح')
    p.process(10, 'AFTER_SUBMIT', 'Recalc', 'noona_loc_pkg.recalc_return(:P73_ID);', when_button=b_calc, success='تم إعادة الاحتساب')
    p.process(20, 'AFTER_SUBMIT', 'Review', 'noona_loc_pkg.review_return(:P73_ID);', when_button=b_rev, success='تمت مراجعة الإقرار')
    p.process(30, 'AFTER_SUBMIT', 'Approve', 'noona_loc_pkg.approve_return(:P73_ID);', when_button=b_apr,
              success='تم اعتماد الإقرار وترحيل قيد التسوية')
    p.process(40, 'AFTER_SUBMIT', 'Adjust', "noona_loc_pkg.set_adjustment(:P73_ID, '14', to_number(:P73_ADJ), :P73_ADJ_NOTE);",
              when_button=b_adj, success='تم تسجيل التصحيح')
    p.process(50, 'AFTER_SUBMIT', 'File', "noona_loc_pkg.file_return(:P73_ID, :P73_REF, to_date(:P73_FILED, 'YYYY-MM-DD'));",
              when_button=b_file, success='تم تسجيل تقديم الإقرار')
    p.process(60, 'AFTER_SUBMIT', 'Pay', "noona_loc_pkg.pay_return(:P73_ID, :P73_PLACE, to_date(:P73_PAY_DATE, 'YYYY-MM-DD'));",
              when_button=b_pay, success='تم سداد الضريبة')
    p.process(70, 'AFTER_SUBMIT', 'Reopen', 'noona_loc_pkg.reopen_return(:P73_ID, :P73_REASON);', when_button=b_ro,
              success='تم إعادة فتح الإقرار وعكس قيد التسوية')
    p.branch(10, url(73, 'P73_ID', '&P73_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 74) السجل الضريبي
    p = app.page(74, 'Tax Register', 'TAX-REGISTER', 'السجل الضريبي', scheme=TAX, protection='N')
    f = p.static('التصفية', 10, hide_header=True)
    p.date('P74_FROM', f, 10, 'من')
    p.date('P74_TO', f, 20, 'إلى')
    p.select('P74_DIR', f, 30, 'النوع', lov_sql='STATIC2:مخرجات (مبيعات);SALE,مدخلات (مشتريات);PURCHASE', null_text='- الكل -')
    p.select('P74_NATURE', f, 40, 'الطبيعة', lov_sql=('STATIC2:خاضعة بالنسبة الأساسية;STANDARD,نسبة صفرية;ZERO_RATED,صادرات;EXPORT,'
                                                       'معفاة;EXEMPT,خارج النطاق;OUT_OF_SCOPE,احتساب عكسي;REVERSE_CHARGE,'
                                                       'صحة/تعليم خاص للمواطنين;CITIZEN'), null_text='- الكل -')
    p.button(f, 10, 'GO', 'عرض', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    :P74_FROM := nvl(:P74_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
        "    :P74_TO := nvl(:P74_TO, to_char(sysdate, 'YYYY-MM-DD'));",
        'end;'])
    p.dynamic('المستندات الضريبية', 20, "return noona_loc_pkg.register_html(to_date(:P74_FROM, 'YYYY-MM-DD'), to_date(:P74_TO, 'YYYY-MM-DD'), "
                                         ":P74_DIR, :P74_NATURE);", opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

    # =============================================================== 75) الاستقطاع
    p = app.page(75, 'Withholding Tax', 'TAX-WHT', 'ضريبة الاستقطاع', scheme=TAX, protection='N')
    f = p.static('استقطاع من مورد', 10, text='<p class="nn-hint">يخصم الاستقطاع من المستحق للمورد (أقدم فواتيره المفتوحة) ويقيد مستحقاً للجهة '
                                             'في 2106، وتصدر شهادة مرقمة. يورد شهرياً بإقرار الاستقطاع.</p>')
    p.select('P75_SUP', f, 10, 'المورد', lov_sql=SUP_LOV, required=True)
    p.select('P75_CODE', f, 20, 'نوع الاستقطاع ونسبته', lov_sql=WHT_LOV, required=True)
    p.number('P75_BASE', f, 30, 'المبلغ المدفوع (الأساس)', required=True)
    p.date('P75_DATE', f, 40, 'تاريخ الدفع')
    p.text('P75_SERVICE', f, 50, 'طبيعة الخدمة', maxlen=500)
    b_w = p.button(f, 10, 'WITHHOLD', 'إصدار الشهادة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Withhold', [
        'declare l_id number;', 'begin',
        "    l_id := noona_loc_pkg.withhold(json_object('supplier' value to_number(:P75_SUP), 'code' value :P75_CODE, 'base' value to_number(:P75_BASE),",
        "              'date' value :P75_DATE, 'service' value :P75_SERVICE));",
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 76, p_items => 'P76_ID', p_values => l_id));",
        'end;'], when_button=b_w)
    flt = p.static('الفترة', 20, hide_header=True)
    p.date('P75_FROM', flt, 10, 'من')
    p.date('P75_TO', flt, 20, 'إلى')
    p.button(flt, 10, 'GO', 'عرض')
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    :P75_FROM := nvl(:P75_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
        "    :P75_TO := nvl(:P75_TO, to_char(sysdate, 'YYYY-MM-DD'));",
        "    :P75_DATE := nvl(:P75_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
        'end;'])
    p.dynamic('شهادات الاستقطاع', 30, "return noona_loc_pkg.withholding_html(to_date(:P75_FROM, 'YYYY-MM-DD'), to_date(:P75_TO, 'YYYY-MM-DD'));")
    p.dynamic('مدفوعات لموردين غير مقيمين', 40, "return noona_loc_pkg.wht_due_html(to_date(:P75_FROM, 'YYYY-MM-DD'), to_date(:P75_TO, 'YYYY-MM-DD'));")
    c = p.static('إلغاء شهادة', 50)
    p.select('P75_CERT', c, 10, 'الشهادة', lov_sql=(
        f"select w.certificate_no || ' - ' || p.display_name_ar || ' - ' || w.withheld_amount d, w.id r from loc_withholding_cert w "
        f"join pty_party p on p.id = w.party_id where w.company_id = {CO} and w.status_code = 'ISSUED' order by w.id desc"))
    p.text('P75_REASON', c, 20, 'السبب', maxlen=500)
    b_c = p.button(c, 10, 'CANCEL_CERT', 'إلغاء الشهادة')
    b_v = p.button(c, 20, 'VIEW_CERT', 'عرض وطباعة')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_loc_pkg.cancel_withholding(:P75_CERT, :P75_REASON);', when_button=b_c,
              success='تم إلغاء الشهادة وإعادة المبلغ مستحقاً للمورد')
    p.branch(5, "f?p=&APP_ID.:76:&SESSION.::&DEBUG.:RP:P76_ID:&P75_CERT.", when_button=b_v)
    p.branch(10, url(75) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 76) شهادة الاستقطاع
    p = app.page(76, 'Withholding Certificate', 'TAX-WHT-CERT', 'شهادة استقطاع', scheme=TAX, protection='N')
    p.dynamic('الشهادة', 10, 'return noona_loc_pkg.certificate_html(:P76_ID);', hide_header=True,
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P76_ID', a, 1, protected=False)
    p.button(a, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
    p.button(a, 20, 'BACK', 'الاستقطاع', redirect=url(75))

    # =============================================================== 77) الفوترة الإلكترونية
    p = app.page(77, 'E-Invoicing', 'EINVOICING', 'الفوترة الإلكترونية', scheme=TAX)
    p.dynamic('حالة الربط', 10, 'return noona_einv_pkg.summary_html;', hide_header=True)
    p.dynamic('إعدادات الربط', 20, 'return noona_einv_pkg.profiles_html;')
    f = p.static('إعداد الربط', 30, text=(
        '<p class="nn-hint">المرحلة الثانية (الربط والتكامل): كل فاتورة مبيعات مرحلة تولد بصيغة UBL 2.1 مع العداد التسلسلي وتجزئة '
        'السلسلة ورمز QR، وترسل للاعتماد (الضريبية) أو الإبلاغ (المبسطة). <b>المحاكي</b> يحاكي ردود الهيئة للاختبار. للإنتاج: '
        'خدمة التوقيع (REST) توقع بشهادة CSID (ECDSA) وترسل لبوابة فاتورة وتعيد النتيجة والتوقيع.</p>'))
    p.hidden('P77_PROFILE', f, 1)
    p.select('P77_BRANCH', f, 10, 'الفرع', lov_sql=BRANCH_LOV, null_text='- كل الفروع -')
    p.select('P77_ADAPTER', f, 20, 'المحول', lov_sql='STATIC2:المحاكي (اختبار);SIMULATOR,خدمة التوقيع والبوابة (REST);REST', null_text=None)
    p.select('P77_MODE', f, 30, 'النمط', lov_sql='STATIC2:اعتماد للضريبية وإبلاغ للمبسطة;CLEARANCE,إبلاغ فقط;REPORTING', null_text=None)
    p.text('P77_DEVICE', f, 40, 'معرف وحدة الفوترة (EGS)', maxlen=200, width=30)
    p.text('P77_ENDPOINT', f, 50, 'عنوان خدمة التوقيع (https://...)', maxlen=200)
    p.text('P77_CERT', f, 60, 'مرجع الشهادة (CSID) في خدمة التوقيع', maxlen=200, width=30)
    p.select('P77_SANDBOX', f, 70, 'البيئة', lov_sql='STATIC2:اختبار (Sandbox);Y,إنتاج;N', null_text=None)
    p.select('P77_STATUS', f, 80, 'الحالة', lov_sql='STATIC2:فعال;ACTIVE,قيد الربط;ONBOARDING,موقوف;SUSPENDED', null_text=None)
    b_sv = p.button(f, 10, 'SAVE', 'حفظ الإعداد', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Load', [
        'begin',
        '    select max(id) into :P77_PROFILE from loc_einvoice_profile where company_id = noona_loc_pkg.company;',
        '    if :P77_PROFILE is not null then',
        '        select branch_id, adapter_code, integration_mode, device_id, endpoint_ref, certificate_ref, is_sandbox, status_code',
        '          into :P77_BRANCH, :P77_ADAPTER, :P77_MODE, :P77_DEVICE, :P77_ENDPOINT, :P77_CERT, :P77_SANDBOX, :P77_STATUS',
        '          from loc_einvoice_profile where id = :P77_PROFILE;',
        '    end if;',
        "    :P77_ADAPTER := nvl(:P77_ADAPTER, 'SIMULATOR'); :P77_MODE := nvl(:P77_MODE, 'CLEARANCE');",
        "    :P77_SANDBOX := nvl(:P77_SANDBOX, 'Y'); :P77_STATUS := nvl(:P77_STATUS, 'ACTIVE');",
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', [
        'declare l_id number;', 'begin',
        "    l_id := noona_einv_pkg.save_profile(json_object('id' value to_number(:P77_PROFILE), 'branch' value to_number(:P77_BRANCH),",
        "              'adapter' value :P77_ADAPTER, 'mode' value :P77_MODE, 'device' value :P77_DEVICE, 'endpoint' value :P77_ENDPOINT,",
        "              'certificate' value :P77_CERT, 'sandbox' value :P77_SANDBOX, 'status' value :P77_STATUS));",
        'end;'], when_button=b_sv, success='تم حفظ إعداد الفوترة الإلكترونية')
    q = p.static('طابور الإرسال', 40, hide_header=True)
    p.hidden('P77_SUB', q, 1, protected=False)
    p.select('P77_FILTER', q, 10, 'عرض', lov_sql=('STATIC2:بانتظار الإرسال أو بها مشكلة;OPEN,معتمدة;CLEARED,مبلغة;ACCEPTED,مرفوضة;REJECTED,'
                                                 'فشل التحقق;VALIDATION_FAILED'), null_text='- الكل -')
    p.button(q, 10, 'GO', 'عرض')
    b_q = p.button(q, 20, 'PROCESS', 'إرسال كل المعلق', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Process', ['declare l_n number;', 'begin', '    l_n := noona_einv_pkg.process_queue;',
                                             "    apex_application.g_print_success_message := 'تمت معالجة ' || l_n || ' إرسال';", 'end;'],
              when_button=b_q)
    p.process(30, 'AFTER_SUBMIT', 'Send', 'noona_einv_pkg.submit(to_number(:P77_SUB));', when=":REQUEST = 'SEND'", success='تم الإرسال')
    p.process(40, 'AFTER_SUBMIT', 'Resend', ['declare l_id number;', 'begin', '    l_id := noona_einv_pkg.resubmit(to_number(:P77_SUB));',
                                            '    noona_einv_pkg.submit(l_id);', 'end;'],
              when=":REQUEST = 'RESEND'", success='تمت إعادة الإرسال')
    p.dynamic('الإرسالات', 50, f"return noona_einv_pkg.queue_html(:P77_FILTER, {get_url(78, 'P78_ID')});")
    p.onload([
        "$(document).on('click', '.nn-einv-send, .nn-einv-resend', function () {",
        "  $s('P77_SUB', $(this).data('sub'));",
        "  apex.submit({ request: $(this).hasClass('nn-einv-send') ? 'SEND' : 'RESEND', showWait: true });",
        "});"])
    p.branch(10, url(77) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 78) تفاصيل الإرسال
    p = app.page(78, 'E-Invoice Submission', 'EINVOICE', 'إرسال فاتورة إلكترونية', scheme=TAX, protection='N')
    p.dynamic('الإرسال', 10, 'return noona_einv_pkg.submission_html(:P78_ID);', hide_header=True)
    a = p.static('الإجراءات', 20, hide_header=True)
    p.hidden('P78_ID', a, 1, protected=False)
    p.button(a, 10, 'BACK', 'طابور الإرسال', redirect=url(77))

    tx = app.nav_item('الضرائب', None, 'fa-percent', 67, scheme=TAX)
    app.nav_item('لوحة الضرائب', 70, 'fa-dashboard', 1, parent=tx, scheme=TAX)
    app.nav_item('الإقرارات الضريبية', 72, 'fa-file-text-o', 2, parent=tx, scheme=TAX)
    app.nav_item('السجل الضريبي', 74, 'fa-list', 3, parent=tx, scheme=TAX)
    app.nav_item('ضريبة الاستقطاع', 75, 'fa-scissors', 4, parent=tx, scheme=TAX)
    app.nav_item('الفوترة الإلكترونية', 77, 'fa-qrcode', 5, parent=tx, scheme=TAX)
    app.nav_item('التسجيلات القانونية', 71, 'fa-id-card-o', 6, parent=tx, scheme=TAX)
