"""صفحات التسعير والعروض والباقات (NOONA_PRC_PKG) تضاف لأي تطبيق بنطاقه:
المبيعات ونقاط البيع (الأصناف + كل الخدمات)، المستشفيات (الخدمات الطبية والأصناف)، خدمة السيارات (خدماتها وقطعها).
  build(app, url, scheme, base, kinds)   kinds: مجموعة من ITEMS, HIS, AUT
الصفحات: base سياسات التسعير، +1 بطاقات تكلفة الخدمات، +2 إعادة التسعير وتقرير الهوامش، +3 العروض والتخفيضات، +4 الباقات.
"""

HIS_TYPES = [('CONSULTATION', 'كشف'), ('FOLLOW_UP', 'متابعة'), ('EMERGENCY', 'طوارئ'), ('LAB', 'تحاليل'), ('RADIOLOGY', 'أشعة'),
             ('CARDIO_DIAG', 'تشخيص القلب'), ('PROCEDURE', 'إجراء'), ('MINOR_SURGERY', 'جراحة صغرى'), ('MAJOR_SURGERY', 'جراحة كبرى'),
             ('PHYSIOTHERAPY', 'علاج طبيعي'), ('THERAPY', 'جلسات علاجية'), ('NURSING', 'تمريض'), ('DENTAL', 'أسنان'), ('BED', 'إقامة'),
             ('MEDICATION', 'أدوية'), ('PACKAGE', 'باقات'), ('OTHER', 'أخرى')]
CHANNELS = "STATIC2:نقاط البيع;POS,فواتير المبيعات;SALES,المستشفيات;HIS,خدمة السيارات;AUT,المطاعم;RST"
DAYS = "STATIC2:الأحد;1,الاثنين;2,الثلاثاء;3,الأربعاء;4,الخميس;5,الجمعة;6,السبت;7"
CO = 'noona_prc_pkg.company'


def target_lov(kinds, components=False):
    """قائمة واحدة للأهداف بقيمة النوع-المعرف (لا «:» لأنها فاصل روابط APEX)؛ components=True للأصناف والخدمات المفردة فقط (مكونات الباقات وبطاقات التكلفة)"""
    parts = []
    if 'ITEMS' in kinds:
        if not components:
            parts += ["select '★ كل الأصناف' d, 'ALL_ITEMS' r, 1 o from dual",
                      "select 'فئة أصناف: ' || name_ar, 'ITEM_CATEGORY-' || id, 2 from inv_item_category where is_active = 'Y'"]
        parts.append("select 'صنف: ' || i.item_no || ' - ' || i.name_ar || ' (' || to_char(nvl(c.sale_price, 0), 'FM999,990.00') || ')', "
                     f"'ITEM-' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = {CO} "
                     "and i.status_code = 'ACTIVE'")
    if 'HIS' in kinds:
        if not components:
            parts.append("select '★ كل الخدمات الطبية', 'ALL_HIS', 4 from dual")
            parts += [f"select 'نوع خدمة طبية: {a}', 'HIS_SERVICE_TYPE-{c}', 5 from dual" for c, a in HIS_TYPES]
        parts.append("select 'خدمة طبية: ' || code || ' - ' || name_ar || ' (' || to_char(price, 'FM999,990.00') || ')', 'HIS_SERVICE-' || id, 6 "
                     f"from his_service where company_id = {CO} and status_code = 'ACTIVE'")
    if 'AUT' in kinds:
        if not components:
            parts += ["select '★ كل خدمات السيارات', 'ALL_AUT', 7 from dual",
                      f"select 'فئة خدمات سيارات: ' || name_ar, 'AUT_CATEGORY-' || id, 8 from aut_service_category where company_id = {CO}"]
        parts.append("select 'خدمة سيارات: ' || code || ' - ' || name_ar || ' (' || to_char(price, 'FM999,990.00') || ')', 'AUT_SERVICE-' || id, 9 "
                     f"from aut_service where company_id = {CO} and is_active = 'Y'")
    # أعمدة أول استعلام تسمي الاتحاد كله؛ يغلف بأسماء ثابتة
    return 'with z (d, r, o) as (' + ' union all '.join(parts) + ') select d, r from z order by o, d'


def scope_filter(kinds, col='target_type'):
    types = []
    if 'ITEMS' in kinds:
        types += ['ITEM', 'ITEM_CATEGORY', 'ALL_ITEMS']
    if 'HIS' in kinds:
        types += ['HIS_SERVICE', 'HIS_SERVICE_TYPE', 'ALL_HIS']
    if 'AUT' in kinds:
        types += ['AUT_SERVICE', 'AUT_CATEGORY', 'ALL_AUT']
    return f"{col} in (" + ', '.join(f"'{t}'" for t in types) + ')'


SPLIT = []


# الهدف «النوع:المعرف» إلى أجزائه داخل SQL (الدوال المحلية لا تستخدم في SQL)
def tt(x):
    return f"regexp_substr({x}, '^[A-Z_]+')"


def tid(x):
    return f"case when instr({x}, '-') > 0 and {x} not like 'HIS_SERVICE_TYPE-%' then to_number(substr({x}, instr({x}, '-') + 1)) end"


def tcd(x):
    return f"case when {x} like 'HIS_SERVICE_TYPE-%' then substr({x}, instr({x}, '-') + 1) end"


def build(app, url, scheme, base=80, kinds=('ITEMS', 'HIS', 'AUT'), channel='POS'):
    pp, pc, pr, pm, pb = base, base + 1, base + 2, base + 3, base + 4
    P = lambda n, x: f'P{n}_{x}'
    TLOV, CLOV = target_lov(kinds), target_lov(kinds, components=True)
    scope = 'ALL' if len(kinds) > 1 else {'ITEMS': 'ITEMS', 'HIS': 'HIS', 'AUT': 'AUT'}[kinds[0]]

    # =========================================================== سياسات التسعير
    p = app.page(pp, 'Pricing Policies', 'PRICING', 'سياسات التسعير', scheme=scheme)
    p.static('كيف يحسب سعر البيع', 5, text=(
        '<p class="nn-hint">التكلفة: الصنف بمتوسط تكلفته المرجح (أو آخر سعر شراء أو التكلفة المعيارية)، والخدمة ببطاقة تكلفتها '
        '(موادها + العمالة بالدقائق × تكلفة الساعة + الأعباء). ثم سعر البيع حسب السياسة: <b>نسبة فوق التكلفة</b> (100 + 25% = 125)، '
        '<b>هامش من سعر البيع</b> (100 ÷ (1 - 20%) = 125)، <b>مبلغ ثابت</b> فوق التكلفة، أو <b>معامل</b> (التكلفة × 1.5)؛ '
        'مع أدنى هامش يحدد أدنى سعر بيع دون موافقة، وتقريب لأعلى. تطبق السياسة الأخص: الصنف أو الخدمة، ثم الفئة أو النوع، ثم الكل.</p>'))
    p.ir('سياسات التسعير', 10, [
        "select p.id, p.code, p.name_ar, noona_prc_pkg.target_label(p.target_type, p.target_id, p.target_code) as target,",
        '       noona_prc_pkg.policy_text(p.id) as rule_text, p.priority_no, p.effective_from, p.effective_to,',
        '       noona_ui_pkg.status_badge(p.status_code) as status_html',
        f'  from sal_pricing_policy p where p.company_id = {CO} and {scope_filter(kinds, "p.target_type")} order by p.status_code, p.priority_no, p.code'],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'السياسة', {}), ('TARGET', 'تنطبق على', {}),
         ('RULE_TEXT', 'القاعدة', {}), ('PRIORITY_NO', 'الأولوية', {'type': 'NUMBER'}), ('EFFECTIVE_FROM', 'من', {'type': 'DATE'}),
         ('EFFECTIVE_TO', 'إلى', {'type': 'DATE'}), ('STATUS_HTML', 'الحالة', {'html': True})])
    f = p.static('سياسة جديدة', 20)
    p.text(P(pp, 'CODE'), f, 10, 'الرمز', required=True, maxlen=30, width=12)
    p.text(P(pp, 'NAME'), f, 20, 'الاسم', required=True)
    p.select(P(pp, 'TARGET'), f, 30, 'تنطبق على', lov_sql=TLOV, required=True)
    p.select(P(pp, 'BASIS'), f, 40, 'أساس التكلفة', null_text=None, lov_sql=(
        'STATIC2:متوسط التكلفة المرجح;AVERAGE,آخر سعر شراء;LAST_PURCHASE,التكلفة المعيارية;STANDARD,بطاقة التكلفة;COST_SHEET'))
    p.select(P(pp, 'METHOD'), f, 50, 'طريقة سعر البيع', null_text=None, lov_sql=(
        'STATIC2:نسبة فوق التكلفة (Markup);MARKUP_PCT,هامش من سعر البيع (Margin);MARGIN_PCT,مبلغ ثابت فوق التكلفة;FIXED_AMOUNT,معامل × التكلفة;MULTIPLIER'))
    p.number(P(pp, 'VALUE'), f, 60, 'النسبة / المبلغ / المعامل', required=True)
    p.number(P(pp, 'MINM'), f, 70, 'أدنى هامش % (أدنى سعر بيع)')
    p.select(P(pp, 'ROUND'), f, 80, 'التقريب لأعلى', null_text=None, lov_sql=(
        'STATIC2:بدون;NONE,0.05;R005,0.25;R025,0.50;R050,1;R1,5;R5,10;R10,ينتهي بـ .99;END99'))
    p.number(P(pp, 'PRIO'), f, 90, 'الأولوية (الأصغر أولاً)')
    p.date(P(pp, 'FROM'), f, 100, 'سارية من')
    p.date(P(pp, 'TO'), f, 110, 'إلى')
    b = p.button(f, 10, 'SAVE_POLICY', 'حفظ السياسة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Save Policy', ['declare', '    l number;', '    l_j clob;', *SPLIT, 'begin',
        f"    select json_object('code' value :{P(pp, 'CODE')}, 'name' value :{P(pp, 'NAME')}, 'targetType' value {tt(':' + P(pp, 'TARGET'))},",
        f"           'targetId' value {tid(':' + P(pp, 'TARGET'))}, 'targetCode' value {tcd(':' + P(pp, 'TARGET'))}, 'basis' value :{P(pp, 'BASIS')},",
        f"           'method' value :{P(pp, 'METHOD')}, 'value' value to_number(:{P(pp, 'VALUE')}), 'minMargin' value to_number(:{P(pp, 'MINM')}),",
        f"           'rounding' value :{P(pp, 'ROUND')}, 'priority' value to_number(:{P(pp, 'PRIO')}), 'from' value :{P(pp, 'FROM')},",
        f"           'to' value :{P(pp, 'TO')} absent on null) into l_j from dual;",
        '    l := noona_prc_pkg.save_policy(l_j);', 'end;'], when_button=b, success='تم حفظ السياسة')
    s = p.static('إيقاف أو تفعيل سياسة', 30)
    p.select(P(pp, 'POL'), s, 10, 'السياسة', lov_sql=(
        f"select code || ' - ' || name_ar d, id r from sal_pricing_policy where company_id = {CO} and {scope_filter(kinds)} order by code"))
    p.select(P(pp, 'PST'), s, 20, 'الحالة', null_text=None, lov_sql='STATIC2:موقوفة;INACTIVE,نشطة;ACTIVE')
    b2 = p.button(s, 10, 'SET_POLICY', 'تطبيق')
    p.process(20, 'AFTER_SUBMIT', 'Policy Status', f"noona_prc_pkg.set_policy_status(:{P(pp, 'POL')}, :{P(pp, 'PST')});",
              when_button=b2, success='تم تغيير حالة السياسة')
    p.branch(10, url(pp, clear=str(pp)) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== بطاقات تكلفة الخدمات
    p = app.page(pc, 'Cost Sheets', 'COST-SHEETS', 'بطاقات التكلفة', scheme=scheme)
    t = p.static('الخدمة أو الصنف', 10, text=(
        '<p class="nn-hint">تكلفة الخدمة = موادها المعرفة في دليل الخدمات (الكواشف والمستلزمات أو القطع) + العناصر الإضافية هنا: '
        'مواد أخرى، عمالة (دقائق × تكلفة الساعة)، أعباء ثابتة، أو أعباء نسبة من التكلفة المباشرة. '
        'وللمنتج التام يمكن تفصيل تكلفته هنا إن لم يكن من التصنيع.</p>'))
    p.select(P(pc, 'TARGET'), t, 10, 'الخدمة أو الصنف', lov_sql=CLOV, submit=True)
    p.dynamic('بطاقة التكلفة', 20, [
        'begin',
        f"    return noona_prc_pkg.cost_html(regexp_substr(:{P(pc, 'TARGET')}, '^[A-Z_]+'), to_number(regexp_substr(:{P(pc, 'TARGET')}, '[0-9]+$')));",
        'end;'], condition=f':{P(pc, "TARGET")} is not null')
    p.ir('العناصر الإضافية', 25, [
        "select e.id, case e.element_type when 'MATERIAL' then 'مادة' when 'LABOR' then 'عمالة' when 'OVERHEAD_AMOUNT' then 'أعباء ثابتة'",
        "            when 'OVERHEAD_PCT' then 'أعباء نسبية' else 'أخرى' end as kind, e.description, i.name_ar as item, e.quantity, e.minutes,",
        '       e.hourly_rate, e.amount, e.pct',
        '  from sal_cost_element e left join inv_item i on i.id = e.item_id',
        f" where e.company_id = {CO} and e.target_type || '-' || e.target_id = :{P(pc, 'TARGET')} order by e.sort_order, e.id"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('KIND', 'العنصر', {}), ('DESCRIPTION', 'البيان', {}), ('ITEM', 'المادة', {}),
         ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('MINUTES', 'الدقائق', {'type': 'NUMBER'}), ('HOURLY_RATE', 'تكلفة الساعة', {'type': 'NUMBER'}),
         ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('PCT', 'النسبة %', {'type': 'NUMBER'})])
    f = p.static('إضافة عنصر تكلفة', 30, condition=f':{P(pc, "TARGET")} is not null')
    p.select(P(pc, 'ET'), f, 10, 'نوع العنصر', null_text=None, lov_sql=(
        'STATIC2:عمالة (دقائق × تكلفة الساعة);LABOR,مادة مستهلكة;MATERIAL,أعباء ثابتة (مبلغ);OVERHEAD_AMOUNT,أعباء نسبة من التكلفة المباشرة;OVERHEAD_PCT,أخرى;OTHER'))
    p.text(P(pc, 'DESC'), f, 20, 'البيان (مثل: وقت الطبيب، تشغيل الجهاز)')
    p.select(P(pc, 'ITEM'), f, 30, 'المادة', lov_sql=(
        f"select i.item_no || ' - ' || i.name_ar d, i.id r from inv_item i join inv_item_company c on c.item_id = i.id "
        f"where c.company_id = {CO} and i.status_code = 'ACTIVE' order by 1"))
    p.number(P(pc, 'QTY'), f, 40, 'الكمية')
    p.number(P(pc, 'MIN'), f, 50, 'الدقائق')
    p.number(P(pc, 'RATE'), f, 60, 'تكلفة الساعة')
    p.number(P(pc, 'AMT'), f, 70, 'المبلغ')
    p.number(P(pc, 'PCT'), f, 80, 'النسبة %')
    b = p.button(f, 10, 'ADD_ELEMENT', 'إضافة العنصر', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Add Element', ['declare', '    l number;', '    l_j clob;', 'begin',
        f"    select json_object('targetType' value regexp_substr(:{P(pc, 'TARGET')}, '^[A-Z_]+'),",
        f"           'targetId' value to_number(regexp_substr(:{P(pc, 'TARGET')}, '[0-9]+$')), 'type' value :{P(pc, 'ET')},",
        f"           'desc' value :{P(pc, 'DESC')}, 'itemId' value to_number(:{P(pc, 'ITEM')}), 'qty' value to_number(:{P(pc, 'QTY')}),",
        f"           'minutes' value to_number(:{P(pc, 'MIN')}), 'rate' value to_number(:{P(pc, 'RATE')}), 'amount' value to_number(:{P(pc, 'AMT')}),",
        f"           'pct' value to_number(:{P(pc, 'PCT')}) absent on null) into l_j from dual;",
        '    l := noona_prc_pkg.save_cost_element(l_j);', 'end;'], when_button=b, success='تمت إضافة عنصر التكلفة')
    d = p.static('حذف عنصر', 40, condition=f':{P(pc, "TARGET")} is not null')
    p.select(P(pc, 'DEL'), d, 10, 'العنصر', lov_sql=(
        f"select nvl(description, element_type) || ' #' || id d, id r from sal_cost_element where company_id = {CO} "
        f"and target_type || '-' || target_id = :{P(pc, 'TARGET')} order by id"))
    b2 = p.button(d, 10, 'DEL_ELEMENT', 'حذف')
    p.process(20, 'AFTER_SUBMIT', 'Delete Element', f"noona_prc_pkg.delete_cost_element(:{P(pc, 'DEL')});", when_button=b2, success='تم الحذف')
    p.branch(10, url(pc, P(pc, 'TARGET'), f'&{P(pc, "TARGET")}.', str(pc)) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== إعادة التسعير
    p = app.page(pr, 'Repricing', 'REPRICING', 'إعادة التسعير والهوامش', scheme=scheme)
    f = p.static('تشغيل جديد', 10, text=(
        '<p class="nn-hint">يحسب السعر المقترح لكل صنف وخدمة من تكلفته الحالية وسياسته، ويعرضه أمام السعر الحالي والهامش. '
        'راجع الأسطر (عدل السعر أو استبعد سطراً) ثم «تطبيق الأسعار»؛ ويسجل كل تغيير في سجل الأسعار.</p>'))
    p.select(P(pr, 'SCOPE'), f, 10, 'النطاق', null_text=None, lov_sql='STATIC2:' + ','.join(
        x for x in [('الكل;ALL' if len(kinds) > 1 else None), ('الأصناف;ITEMS' if 'ITEMS' in kinds else None),
                    ('الخدمات الطبية;HIS' if 'HIS' in kinds else None), ('خدمات السيارات;AUT' if 'AUT' in kinds else None)] if x))
    p.yesno(P(pr, 'ALL'), f, 20, 'إظهار الأسطر التي لا يتغير سعرها')
    p.hidden(P(pr, 'NEWRUN'), f, 90)
    b = p.button(f, 10, 'NEW_RUN', 'احسب الأسعار المقترحة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'New Run', [
        f"    :{P(pr, 'NEWRUN')} := noona_prc_pkg.new_run(:{P(pr, 'SCOPE')}, case :{P(pr, 'ALL')} when 'Y' then 'N' else 'Y' end);"],
        when_button=b, success='تم حساب الأسعار المقترحة؛ راجعها ثم طبقها')
    r = p.static('مراجعة وتطبيق', 20)
    p.select(P(pr, 'RUN'), r, 10, 'التشغيل', submit=True, lov_sql=(
        "select doc_no || ' - ' || case status_code when 'DRAFT' then 'مسودة' when 'APPLIED' then 'مطبق' else 'ملغى' end"
        " || ' (' || lines_count || ' سطر)' d, id r from sal_price_run where company_id = " + CO + " order by id desc"))
    p.select(P(pr, 'LINE'), r, 20, 'السطر', cascade=P(pr, 'RUN'), lov_sql=(
        f"select noona_prc_pkg.target_name(target_type, target_id) || ' : ' || to_char(new_price, 'FM999,990.00') d, id r "
        f"from sal_price_run_line where run_id = :{P(pr, 'RUN')} order by 1"))
    p.number(P(pr, 'PRICE'), r, 30, 'السعر المعدل')
    p.select(P(pr, 'SEL'), r, 40, 'يطبق', null_text=None, lov_sql='STATIC2:نعم;Y,لا (استبعاد);N')
    b2 = p.button(r, 10, 'SET_LINE', 'تعديل السطر')
    b3 = p.button(r, 20, 'APPLY', 'تطبيق الأسعار', hot=True)
    b4 = p.button(r, 30, 'CANCEL_RUN', 'إلغاء التشغيل')
    p.process(20, 'AFTER_SUBMIT', 'Set Line', f"noona_prc_pkg.set_run_line(:{P(pr, 'LINE')}, :{P(pr, 'SEL')}, to_number(:{P(pr, 'PRICE')}));",
              when_button=b2, success='تم تعديل السطر')
    p.process(30, 'AFTER_SUBMIT', 'Apply', ['declare l number;', 'begin', f"    l := noona_prc_pkg.apply_run(:{P(pr, 'RUN')});",
        "    apex_application.g_print_success_message := 'تم تطبيق ' || l || ' سعر جديد';", 'end;'], when_button=b3)
    p.process(40, 'AFTER_SUBMIT', 'Cancel', f"noona_prc_pkg.cancel_run(:{P(pr, 'RUN')});", when_button=b4, success='تم إلغاء التشغيل')
    p.process(5, 'BEFORE_HEADER', 'Latest Run', [
        f"    if :{P(pr, 'NEWRUN')} is not null then :{P(pr, 'RUN')} := :{P(pr, 'NEWRUN')}; :{P(pr, 'NEWRUN')} := null; end if;",
        f"    :{P(pr, 'SCOPE')} := nvl(:{P(pr, 'SCOPE')}, '{scope}');"])
    p.ir('الأسعار المقترحة', 30, [
        "select l.id, case l.target_type when 'ITEM' then 'صنف' when 'HIS_SERVICE' then 'خدمة طبية' else 'خدمة سيارات' end as kind,",
        '       noona_prc_pkg.target_name(l.target_type, l.target_id) as target, l.cost_amount, l.old_price, l.new_price, l.new_min_price,',
        "       l.margin_pct, case when l.old_price > 0 then round((l.new_price - l.old_price) / l.old_price * 100, 2) end as change_pct,",
        "       case l.is_selected when 'Y' then 'نعم' else 'لا' end as selected, noona_prc_pkg.policy_text(l.policy_id) as rule_text",
        f"  from sal_price_run_line l where l.run_id = :{P(pr, 'RUN')} order by 2, 3"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('KIND', 'النوع', {}), ('TARGET', 'الصنف / الخدمة', {}),
         ('COST_AMOUNT', 'التكلفة', {'type': 'NUMBER'}), ('OLD_PRICE', 'السعر الحالي', {'type': 'NUMBER'}),
         ('NEW_PRICE', 'السعر المقترح', {'type': 'NUMBER'}), ('NEW_MIN_PRICE', 'أدنى سعر', {'type': 'NUMBER'}),
         ('MARGIN_PCT', 'الهامش %', {'type': 'NUMBER'}), ('CHANGE_PCT', 'التغير %', {'type': 'NUMBER'}), ('SELECTED', 'يطبق', {}),
         ('RULE_TEXT', 'السياسة', {})], rows=100)
    p.dynamic('تقرير الهوامش الحالية', 40, f"return noona_prc_pkg.margin_html(nvl(:{P(pr, 'SCOPE')}, '{scope}'));", opts='#DEFAULT#:t-Region--scrollBody:is-collapsed')
    p.ir('سجل تغيير الأسعار', 50, [
        "select h.id, h.created_at, case h.target_type when 'ITEM' then 'صنف' when 'HIS_SERVICE' then 'خدمة طبية' else 'خدمة سيارات' end as kind,",
        "       noona_prc_pkg.target_name(h.target_type, h.target_id) as target, h.old_price, h.new_price, h.cost_amount,",
        "       case h.source_code when 'RUN' then 'إعادة تسعير' else 'يدوي' end as src, h.created_by",
        f"  from sal_price_history h where h.company_id = {CO} and {scope_filter(kinds, 'h.target_type')} order by h.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CREATED_AT', 'الوقت', {'type': 'DATE'}), ('KIND', 'النوع', {}),
         ('TARGET', 'الصنف / الخدمة', {}), ('OLD_PRICE', 'السابق', {'type': 'NUMBER'}), ('NEW_PRICE', 'الجديد', {'type': 'NUMBER'}),
         ('COST_AMOUNT', 'التكلفة', {'type': 'NUMBER'}), ('SRC', 'المصدر', {}), ('CREATED_BY', 'بواسطة', {})])
    p.branch(10, url(pr, P(pr, 'RUN'), f'&{P(pr, "RUN")}.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== العروض والتخفيضات
    p = app.page(pm, 'Promotions', 'PROMOTIONS', 'العروض والتخفيضات', scheme=scheme)
    p.ir('العروض والتخفيضات', 10, [
        "select p.id, p.code, p.name_ar, noona_prc_pkg.promotion_text(p.id) as rule_text, p.channels,",
        "       (select listagg(noona_prc_pkg.target_label(t.target_type, t.target_id, t.target_code), '، ') within group (order by t.id)",
        '          from sal_promotion_target t where t.promotion_id = p.id) as targets,',
        '       p.priority_no, noona_ui_pkg.status_badge(p.status_code) as status_html',
        f'  from sal_promotion p where p.company_id = {CO} order by decode(p.status_code, \'ACTIVE\', 0, 1), p.priority_no, p.id desc'],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'العرض', {}), ('RULE_TEXT', 'الشروط', {}),
         ('CHANNELS', 'القنوات', {}), ('TARGETS', 'يشمل', {}), ('PRIORITY_NO', 'الأولوية', {'type': 'NUMBER'}),
         ('STATUS_HTML', 'الحالة', {'html': True})])
    f = p.static('عرض جديد', 20)
    p.text(P(pm, 'CODE'), f, 10, 'الرمز', required=True, maxlen=30, width=12)
    p.text(P(pm, 'NAME'), f, 20, 'اسم العرض', required=True)
    p.select(P(pm, 'TYPE'), f, 30, 'النوع', null_text=None, lov_sql=(
        'STATIC2:خصم نسبة;PCT_OFF,خصم مبلغ للوحدة;AMOUNT_OFF,سعر خاص;FIXED_PRICE,اشتر X واحصل على Y مجاناً;BUY_X_GET_Y,'
        'خصم نسبة على قيمة الفاتورة;SPEND_PCT,خصم مبلغ على قيمة الفاتورة;SPEND_AMOUNT'))
    p.number(P(pm, 'VALUE'), f, 40, 'النسبة / المبلغ / السعر الخاص')
    p.number(P(pm, 'BUY'), f, 50, 'اشتر (كمية)')
    p.number(P(pm, 'GET'), f, 60, 'واحصل مجاناً على')
    p.number(P(pm, 'MINQ'), f, 70, 'أدنى كمية للسطر')
    p.number(P(pm, 'MINA'), f, 80, 'أدنى قيمة للفاتورة')
    p.number(P(pm, 'MAXD'), f, 90, 'أقصى خصم')
    p.select(P(pm, 'TARGET'), f, 100, 'يشمل (ويضاف غيره بعد الحفظ)', lov_sql=TLOV)
    p.checkboxes(P(pm, 'CH'), f, 110, 'القنوات (بلا اختيار = الكل)', CHANNELS, columns=5)
    p.checkboxes(P(pm, 'DAYS'), f, 120, 'الأيام (بلا اختيار = كل الأيام)', DAYS, columns=7)
    p.number(P(pm, 'HF'), f, 130, 'من الساعة (0-23)')
    p.number(P(pm, 'HT'), f, 140, 'إلى الساعة (1-24)')
    p.text(P(pm, 'COUPON'), f, 150, 'كود الكوبون (اختياري)', maxlen=50, width=15)
    p.number(P(pm, 'PRIO'), f, 160, 'الأولوية')
    p.yesno(P(pm, 'STACK'), f, 170, 'يجمع مع عروض أخرى')
    p.date(P(pm, 'FROM'), f, 180, 'من تاريخ')
    p.date(P(pm, 'TO'), f, 190, 'إلى تاريخ')
    b = p.button(f, 10, 'SAVE_PROMO', 'حفظ العرض', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Save Promotion', ['declare', '    l number;', '    l_j clob;', '    l_t clob;', *SPLIT, 'begin',
        f"    if :{P(pm, 'TARGET')} is not null then",
        f"        select json_array(json_object('type' value {tt(':' + P(pm, 'TARGET'))}, 'id' value {tid(':' + P(pm, 'TARGET'))},",
        f"               'code' value {tcd(':' + P(pm, 'TARGET'))} absent on null)) into l_t from dual;",
        '    end if;',
        f"    select json_object('code' value :{P(pm, 'CODE')}, 'name' value :{P(pm, 'NAME')}, 'type' value :{P(pm, 'TYPE')},",
        f"           'value' value to_number(:{P(pm, 'VALUE')}), 'buyQty' value to_number(:{P(pm, 'BUY')}), 'getQty' value to_number(:{P(pm, 'GET')}),",
        f"           'minQty' value to_number(:{P(pm, 'MINQ')}), 'minAmount' value to_number(:{P(pm, 'MINA')}), 'maxDiscount' value to_number(:{P(pm, 'MAXD')}),",
        f"           'channels' value replace(:{P(pm, 'CH')}, ':', ','), 'days' value replace(:{P(pm, 'DAYS')}, ':', ','),",
        f"           'hourFrom' value to_number(:{P(pm, 'HF')}), 'hourTo' value to_number(:{P(pm, 'HT')}), 'coupon' value :{P(pm, 'COUPON')},",
        f"           'priority' value to_number(:{P(pm, 'PRIO')}), 'stackable' value :{P(pm, 'STACK')}, 'from' value :{P(pm, 'FROM')},",
        f"           'to' value :{P(pm, 'TO')}, 'targets' value l_t format json absent on null) into l_j from dual;",
        '    l := noona_prc_pkg.save_promotion(l_j);', 'end;'], when_button=b, success='تم حفظ العرض وتفعيله')
    s = p.static('إدارة عرض', 30)
    p.select(P(pm, 'PROMO'), s, 10, 'العرض', lov_sql=f"select code || ' - ' || name_ar d, id r from sal_promotion where company_id = {CO} order by id desc")
    p.select(P(pm, 'ADD'), s, 20, 'إضافة صنف أو خدمة أو فئة', lov_sql=TLOV)
    p.select(P(pm, 'PST'), s, 30, 'الحالة', null_text=None, lov_sql='STATIC2:نشط;ACTIVE,موقوف مؤقتاً;PAUSED,ملغى;CANCELLED')
    b2 = p.button(s, 10, 'ADD_TARGET', 'إضافة للعرض')
    b3 = p.button(s, 20, 'SET_PROMO', 'تغيير الحالة')
    p.process(20, 'AFTER_SUBMIT', 'Add Target', f"noona_prc_pkg.add_promotion_target(:{P(pm, 'PROMO')}, :{P(pm, 'ADD')});", when_button=b2,
              success='تمت الإضافة للعرض')
    p.process(30, 'AFTER_SUBMIT', 'Promotion Status', f"noona_prc_pkg.set_promotion_status(:{P(pm, 'PROMO')}, :{P(pm, 'PST')});",
              when_button=b3, success='تم تغيير حالة العرض')
    p.branch(10, url(pm, clear=str(pm)) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== الباقات
    p = app.page(pb, 'Bundles', 'BUNDLES', 'الباقات', scheme=scheme)
    p.ir('الباقات', 10, [
        "select b.id, b.code, b.name_ar, noona_prc_pkg.bundle_text(b.id) as rule_text,",
        "       (select count(*) from sal_bundle_line l where l.bundle_id = b.id) as lines_count, noona_prc_pkg.bundle_price(b.id) as price,",
        '       b.channels, b.effective_from, b.effective_to, noona_ui_pkg.status_badge(b.status_code) as status_html',
        f'  from sal_bundle b where b.company_id = {CO} order by b.status_code, b.name_ar'],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الباقة', {}), ('RULE_TEXT', 'التسعير', {}),
         ('LINES_COUNT', 'المكونات', {'type': 'NUMBER'}), ('PRICE', 'سعر الباقة', {'type': 'NUMBER'}), ('CHANNELS', 'القنوات', {}),
         ('EFFECTIVE_FROM', 'من', {'type': 'DATE'}), ('EFFECTIVE_TO', 'إلى', {'type': 'DATE'}), ('STATUS_HTML', 'الحالة', {'html': True})])
    f = p.static('باقة جديدة', 20, text='<p class="nn-hint">الباقة مكونان على الأقل؛ ويضاف غيرهما بعد الحفظ من «إدارة باقة».</p>')
    p.text(P(pb, 'CODE'), f, 10, 'الرمز', required=True, maxlen=30, width=12)
    p.text(P(pb, 'NAME'), f, 20, 'اسم الباقة', required=True)
    p.textarea(P(pb, 'DESC'), f, 30, 'الوصف')
    p.select(P(pb, 'METHOD'), f, 40, 'طريقة السعر', null_text=None, lov_sql=(
        'STATIC2:سعر ثابت للباقة;FIXED_PRICE,خصم نسبة من مجموع المكونات;PCT_OFF,خصم مبلغ من مجموع المكونات;AMOUNT_OFF'))
    p.number(P(pb, 'VALUE'), f, 50, 'السعر / النسبة / المبلغ', required=True)
    for i in (1, 2):
        p.select(P(pb, f'C{i}'), f, 50 + i * 10, f'المكون {i}', lov_sql=CLOV, required=True)
        p.number(P(pb, f'Q{i}'), f, 55 + i * 10, f'كمية المكون {i}')
    p.checkboxes(P(pb, 'CH'), f, 90, 'القنوات (بلا اختيار = الكل)', CHANNELS, columns=5)
    p.yesno(P(pb, 'INCL'), f, 100, 'السعر شامل الضريبة')
    p.date(P(pb, 'FROM'), f, 110, 'من تاريخ')
    p.date(P(pb, 'TO'), f, 120, 'إلى تاريخ')
    b = p.button(f, 10, 'SAVE_BUNDLE', 'حفظ الباقة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Save Bundle', ['declare', '    l number;', '    l_j clob;', *SPLIT, 'begin',
        f"    select json_object('code' value :{P(pb, 'CODE')}, 'name' value :{P(pb, 'NAME')}, 'desc' value :{P(pb, 'DESC')},",
        f"           'method' value :{P(pb, 'METHOD')}, 'value' value to_number(:{P(pb, 'VALUE')}), 'incl' value :{P(pb, 'INCL')},",
        f"           'channels' value replace(:{P(pb, 'CH')}, ':', ','), 'from' value :{P(pb, 'FROM')}, 'to' value :{P(pb, 'TO')},",
        f"           'lines' value json_array(json_object('type' value {tt(':' + P(pb, 'C1'))}, 'id' value {tid(':' + P(pb, 'C1'))},",
        f"                                   'qty' value nvl(to_number(:{P(pb, 'Q1')}), 1)),",
        f"                       json_object('type' value {tt(':' + P(pb, 'C2'))}, 'id' value {tid(':' + P(pb, 'C2'))},",
        f"                                   'qty' value nvl(to_number(:{P(pb, 'Q2')}), 1))) absent on null) into l_j from dual;",
        f"    l := noona_prc_pkg.save_bundle(l_j);", f"    :{P(pb, 'BUNDLE')} := l;", 'end;'], when_button=b, success='تم حفظ الباقة')
    s = p.static('إدارة باقة', 30)
    p.select(P(pb, 'BUNDLE'), s, 10, 'الباقة', submit=True, lov_sql=f"select code || ' - ' || name_ar d, id r from sal_bundle where company_id = {CO} order by name_ar")
    p.select(P(pb, 'ADD'), s, 20, 'إضافة مكون', lov_sql=CLOV)
    p.number(P(pb, 'ADDQ'), s, 30, 'الكمية')
    p.select(P(pb, 'DEL'), s, 40, 'حذف مكون', cascade=P(pb, 'BUNDLE'), lov_sql=(
        f"select noona_prc_pkg.target_name(target_type, target_id) || ' × ' || quantity d, id r from sal_bundle_line "
        f"where bundle_id = :{P(pb, 'BUNDLE')} order by sort_order"))
    p.select(P(pb, 'BST'), s, 50, 'الحالة', null_text=None, lov_sql='STATIC2:نشطة;ACTIVE,موقوفة;INACTIVE')
    b2 = p.button(s, 10, 'ADD_LINE', 'إضافة المكون')
    b3 = p.button(s, 20, 'DEL_LINE', 'حذف المكون')
    b4 = p.button(s, 30, 'SET_BUNDLE', 'تغيير الحالة')
    p.process(20, 'AFTER_SUBMIT', 'Add Line', f"noona_prc_pkg.add_bundle_line(:{P(pb, 'BUNDLE')}, :{P(pb, 'ADD')}, nvl(to_number(:{P(pb, 'ADDQ')}), 1));",
              when_button=b2, success='تمت إضافة المكون')
    p.process(30, 'AFTER_SUBMIT', 'Delete Line', f"noona_prc_pkg.remove_bundle_line(:{P(pb, 'DEL')});", when_button=b3, success='تم حذف المكون')
    p.process(40, 'AFTER_SUBMIT', 'Bundle Status', f"noona_prc_pkg.set_bundle_status(:{P(pb, 'BUNDLE')}, :{P(pb, 'BST')});",
              when_button=b4, success='تم تغيير حالة الباقة')
    p.dynamic('مكونات الباقة وتوزيع سعرها', 40, f"return noona_prc_pkg.bundle_html(:{P(pb, 'BUNDLE')});", condition=f':{P(pb, "BUNDLE")} is not null')
    p.branch(10, url(pb, P(pb, 'BUNDLE'), f'&{P(pb, "BUNDLE")}.') + '&success_msg=#SUCCESS_MSG#')
    return pp


def nav(app, base, seq, parent_label='التسعير والعروض'):
    g = app.nav_item(parent_label, None, 'fa-tags', seq)
    app.nav_item('العروض والتخفيضات', base + 3, 'fa-percent', seq + 1, parent=g)
    app.nav_item('الباقات', base + 4, 'fa-gift', seq + 2, parent=g)
    app.nav_item('سياسات التسعير', base, 'fa-calculator', seq + 3, parent=g)
    app.nav_item('بطاقات التكلفة', base + 1, 'fa-list-alt', seq + 4, parent=g)
    app.nav_item('إعادة التسعير والهوامش', base + 2, 'fa-refresh', seq + 5, parent=g)
    return g
