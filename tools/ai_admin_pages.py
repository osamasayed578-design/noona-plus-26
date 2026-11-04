"""NOONA PLUS 26: صفحة «الذكاء الاصطناعي» في إدارة المؤسسة (التطبيق 123): التفعيل، النموذج، الحصة الشهرية، الاحتفاظ بالمحادثات،
والاستهلاك اليومي حسب الوظيفة. المفاتيح لا تدخل هنا: يضبطها مسؤول مساحة عمل APEX في خدمة الذكاء الاصطناعي (docs/ai_setup_26.md).
"""
PAGE = 80


def add(app, scheme, nav_seq):
    p = app.page(PAGE, 'AI Settings', 'AI-SETTINGS', 'الذكاء الاصطناعي', scheme=scheme)
    r = p.static('الحالة', 5, text=[
        "<div class=\"nn-hint\">مساعد نونا يجيب من بيانات النظام بصلاحيات كل مستخدم وشركته وفرعه، ولا ينفذ عمليات. "
        "المزود (Claude أو OCI) ومفتاحه يضبطهما مسؤول مساحة عمل APEX في خدمات الذكاء الاصطناعي؛ هنا تختار المؤسسة النموذج والحصة.</div>"])
    p.dynamic('الاستهلاك', 6, [
        'declare l json_object_t := json_object_t.parse(noona_ai_pkg.settings_json);',
        'begin',
        "    return '<div class=\"nn-ai-stat\"><b>الحالة:</b> ' || case l.get_string('available') when 'Y' then 'مفعل ويعمل' else 'غير متاح' end",
        "        || ' &middot; <b>النموذج:</b> ' || apex_escape.html(nvl(l.get_string('model'), '—'))",
        "        || ' &middot; <b>المزود:</b> ' || apex_escape.html(nvl(l.get_string('provider'), '—'))",
        "        || ' &middot; <b>استهلاك هذا الشهر:</b> ' || to_char(l.get_number('used'), 'FM999G999G999G990')",
        "        || case when l.get_number('quota') is not null then ' من ' || to_char(l.get_number('quota'), 'FM999G999G999G990') || ' رمز' else ' رمز (بلا حد)' end",
        "        || '</div>';",
        'end;'], hide_header=True)
    f = p.static('إعدادات المؤسسة', 10)
    p.yesno('P80_ENABLED', f, 10, 'تفعيل مساعد نونا لكل مستخدمي المؤسسة')
    p.select('P80_MODEL', f, 20, 'نموذج المحادثة', lov_sql=(
        "select p.name_ar || ' — ' || m.name_ar d, m.id r from ai_model m join ai_provider p on p.id = m.provider_id "
        "where m.model_kind = 'CHAT' and m.status_code = 'ACTIVE' and p.status_code = 'ACTIVE' order by p.name_ar, m.name_ar"))
    p.number('P80_QUOTA', f, 30, 'الحصة الشهرية بالرموز (فارغ = بلا حد)')
    p.number('P80_RET', f, 40, 'الاحتفاظ بالمحادثات (يوم)')
    p.process(10, 'BEFORE_HEADER', 'Load Settings', [
        'declare l json_object_t := json_object_t.parse(noona_ai_pkg.settings_json);',
        'begin',
        "    :P80_ENABLED := l.get_string('enabled'); :P80_MODEL := l.get_number('modelId');",
        "    :P80_QUOTA := l.get_number('quota'); :P80_RET := nvl(l.get_number('retentionDays'), 90);",
        'end;'])
    b = p.button(f, 10, 'SAVE_AI', 'حفظ', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Save AI Settings', [
        'declare l clob;',
        'begin',
        "    select json_object('enabled' value :P80_ENABLED, 'modelId' value to_number(:P80_MODEL), 'quota' value to_number(:P80_QUOTA),",
        "                       'retentionDays' value to_number(:P80_RET)) into l from dual;",
        '    noona_ai_pkg.save_settings(l);',
        'end;'], when_button=b, success='تم حفظ إعدادات الذكاء الاصطناعي')
    p.ir('الاستهلاك اليومي', 30, [
        "select u.usage_date, decode(u.feature_code, 'CHAT', 'المحادثة', 'SUMMARY', 'الملخص التنفيذي', u.feature_code) feature,",
        '       m.name_ar model, u.request_count, u.input_tokens, u.output_tokens, u.input_tokens + u.output_tokens total_tokens, u.cost_amount',
        '  from ai_usage u join ai_model m on m.id = u.model_id order by u.usage_date desc'],
        [('USAGE_DATE', 'اليوم', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('FEATURE', 'الوظيفة', {}), ('MODEL', 'النموذج', {}),
         ('REQUEST_COUNT', 'الطلبات', {'type': 'NUMBER'}), ('INPUT_TOKENS', 'رموز الإدخال', {'type': 'NUMBER'}),
         ('OUTPUT_TOKENS', 'رموز الإخراج', {'type': 'NUMBER'}), ('TOTAL_TOKENS', 'الإجمالي', {'type': 'NUMBER'}),
         ('COST_AMOUNT', 'التكلفة التقديرية', {'type': 'NUMBER'})])
    p.branch(10, f'f?p=&APP_ID.:{PAGE}:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#')
    app.nav_item('الذكاء الاصطناعي', PAGE, 'fa-magic', nav_seq, scheme=scheme)
