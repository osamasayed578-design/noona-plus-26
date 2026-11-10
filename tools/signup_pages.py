"""التسجيل الذاتي للعملاء: صفحة عامة في التطبيق الرئيسي (NOONA_MASTER) بخطوات: الحساب ← التحقق بالرمز ← المؤسسة ←
الأنظمة والخطة والسعر ← الإنشاء؛ ورابط «إنشاء حساب» في صفحة الدخول. المنطق كله في NOONA_SIGNUP_PKG.
"""
import re

PAGE = 20
STEP = ':P20_STEP'


def add(app):
    p = app.page(PAGE, 'Signup', 'SIGNUP', 'إنشاء حساب مؤسسة - نونا بلس', protection='C', public=True)
    p.process(5, 'BEFORE_HEADER', 'Step', ':P20_STEP := noona_signup_pkg.step(:P20_TOKEN);')
    p.dynamic('الخطوات', 5, [
        'declare l_s number := nvl(:P20_STEP, 1); l_h varchar2(4000);',
        'begin',
        "  l_h := '<div class=\"nn-sgn-hero\"><img src=\"#APP_FILES#icons/app-icon-512.png\" alt=\"\"><div><h1>نونا بلس</h1>'",
        "      || '<p>نظام متكامل لإدارة مؤسستك: المالية والمخزون والمبيعات والموارد البشرية وغيرها. ابدأ بتجربة مجانية 14 يوماً.</p></div></div>'",
        "      || '<ol class=\"nn-sgn-steps\">';",
        "  for i in 1 .. 5 loop",
        "    l_h := l_h || '<li class=\"' || case when i < l_s then 'is-done' when i = l_s then 'is-current' end || '\"><span>' || i || '</span>'",
        "        || case i when 1 then 'الحساب' when 2 then 'التحقق' when 3 then 'المؤسسة' when 4 then 'الأنظمة والخطة' else 'جاهز' end || '</li>';",
        '  end loop;',
        "  return l_h || '</ol>';",
        'end;'], hide_header=True)

    # ---------------------------------------------------------------- 1) الحساب
    a = p.static('بيانات حسابك', 10, condition=f'{STEP} = 1', text=(
        '<p class="nn-hint">ستكون مسؤول مؤسستك في النظام، وتضيف بقية المستخدمين بعد الدخول. '
        'سنرسل رمز تحقق إلى بريدك وجوالك.</p>'))
    p.text('P20_NAME', a, 10, 'الاسم الكامل', maxlen=200)
    p.text('P20_EMAIL', a, 20, 'البريد الإلكتروني', maxlen=320)
    p.text('P20_MOBILE', a, 30, 'رقم الجوال (05xxxxxxxx)', maxlen=20)
    p.text('P20_USERNAME', a, 40, 'اسم الدخول (بالإنجليزية)', maxlen=30)
    p.password('P20_PWD', a, 50, 'كلمة المرور (10 أحرف: كبير وصغير ورقم)')
    p.password('P20_PWD2', a, 60, 'تأكيد كلمة المرور')
    p.checkboxes('P20_TERMS', a, 70, 'الشروط', "STATIC2:أوافق على شروط الاستخدام وسياسة الخصوصية وحماية البيانات الشخصية;Y", columns=1)
    b_start = p.button(a, 10, 'START', 'إنشاء الحساب وإرسال الرمز', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Start', [
        'begin',
        "  if :P20_PWD is null or :P20_PWD <> nvl(:P20_PWD2, '#') then",
        "    raise_application_error(-20500, 'NOONA-SGN-028: كلمة المرور وتأكيدها غير متطابقين');",
        '  end if;',
        "  :P20_TOKEN := noona_signup_pkg.start_signup(:P20_NAME, :P20_EMAIL, :P20_MOBILE, :P20_USERNAME, :P20_PWD, nvl(:P20_TERMS, 'N'),",
        "                                             owa_util.get_cgi_env('REMOTE_ADDR'));",
        '  :P20_DEMO := noona_signup_pkg.demo_message;',
        '  :P20_PWD := null; :P20_PWD2 := null;',
        'end;'], when_button=b_start)

    # ---------------------------------------------------------------- 2) التحقق
    v = p.static('التحقق', 20, condition=f'{STEP} = 2')
    p.dynamic('الرمز', 21, [
        "return '<p class=\"nn-hint\">أدخل الرمز المرسل إلى <b dir=\"ltr\">' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, 'EMAIL'))",
        "  || '</b> و <b dir=\"ltr\">' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, 'MOBILE')) || '</b>. صالح 10 دقائق.</p>'",
        "  || case when :P20_DEMO is not null then '<div class=\"nn-sgn-demo\">' || noona_ui_pkg.esc(:P20_DEMO) || '</div>' end;"],
        hide_header=True, condition=f'{STEP} = 2')
    p.text('P20_ECODE', v, 10, 'رمز البريد', maxlen=6, width=10)
    p.text('P20_MCODE', v, 20, 'رمز الجوال', maxlen=6, width=10)
    b_ver = p.button(v, 10, 'VERIFY', 'تحقق', hot=True)
    b_res = p.button(v, 20, 'RESEND', 'إعادة إرسال الرمز')
    p.process(20, 'AFTER_SUBMIT', 'Verify', 'noona_signup_pkg.verify(:P20_TOKEN, :P20_ECODE, :P20_MCODE); :P20_DEMO := null;', when_button=b_ver)
    p.process(25, 'AFTER_SUBMIT', 'Resend', 'noona_signup_pkg.resend(:P20_TOKEN); :P20_DEMO := noona_signup_pkg.demo_message;',
              when_button=b_res, success='أرسلنا رمزاً جديداً')

    # ---------------------------------------------------------------- 3) المؤسسة
    o = p.static('بيانات المؤسسة', 30, condition=f'{STEP} = 3', text=(
        '<p class="nn-hint">البيانات الأساسية فقط؛ تستكمل الفروع والهيكل والأرصدة بعد الدخول من «بدء التشغيل ونقل البيانات».</p>'))
    p.text('P20_ORG', o, 10, 'اسم المؤسسة (عربي)', maxlen=200)
    p.text('P20_ORG_EN', o, 20, 'الاسم بالإنجليزية (اختياري)', maxlen=200)
    p.select('P20_COUNTRY', o, 30, 'الدولة', lov_sql=(
        'STATIC2:السعودية;SA,الإمارات;AE,البحرين;BH,عُمان;OM,قطر;QA,الكويت;KW,مصر;EG,السودان;SD'), null_text=None)
    p.text('P20_CR', o, 40, 'السجل التجاري', maxlen=20)
    p.text('P20_VAT', o, 50, 'الرقم الضريبي (15 رقماً)', maxlen=20)
    p.text('P20_CITY', o, 60, 'المدينة', maxlen=100)
    b_org = p.button(o, 10, 'SAVE_ORG', 'التالي', hot=True)
    p.process(30, 'AFTER_SUBMIT', 'Org', 'noona_signup_pkg.save_org(:P20_TOKEN, :P20_ORG, :P20_ORG_EN, :P20_COUNTRY, :P20_CR, :P20_VAT, :P20_CITY);',
              when_button=b_org)

    # ---------------------------------------------------------------- 4) الأنظمة والخطة
    p.dynamic('الأنظمة المتاحة', 38, 'return noona_signup_pkg.offerings_html;', condition=f'{STEP} = 4')
    s = p.static('اختر أنظمتك وخطتك', 40, condition=f'{STEP} = 4')
    p.checkboxes('P20_OFF', s, 10, 'الأنظمة', (
        "select name_ar || case when monthly_price > 0 then ' (' || to_char(monthly_price, 'FM999,990') || ' ريال/شهر)' else ' (مشمول)' end d, code r "
        "from plt_offering where is_active = 'Y' order by sort_order"), columns=2)
    p.number('P20_USERS', s, 20, 'عدد المستخدمين')
    p.select('P20_PLAN', s, 30, 'الخطة', lov_sql=(
        "select case code when 'TRIAL' then 'تجربة مجانية 14 يوماً (بلا دفع)' else name_ar end"
        " || case when discount_pct > 0 then ' - خصم ' || to_char(discount_pct) || '%' end d, code r"
        " from plt_plan where is_active = 'Y' and self_service = 'Y'"
        " order by decode(code, 'TRIAL', 0, 'MONTHLY', 1, 'QUARTERLY', 2, 'SEMI_ANNUAL', 3, 'ANNUAL', 4, 9)"), null_text=None, submit=True)
    p.select('P20_PAY', s, 40, 'طريقة الدفع (للخطة المدفوعة)', lov_sql='STATIC2:تحويل بنكي;BANK_TRANSFER,بطاقة (قريباً);CARD', null_text=None)
    p.text('P20_REF', s, 50, 'رقم/مرجع التحويل (إن حولت)', maxlen=100)
    b_calc = p.button(s, 10, 'CALC', 'احسب السعر')
    b_fin = p.button(s, 20, 'FINISH', 'إنشاء مؤسستي', hot=True)
    p.process(6, 'BEFORE_HEADER', 'Defaults', [
        "if :P20_USERS is null then :P20_USERS := 3; end if;",
        "if :P20_PLAN is null then :P20_PLAN := 'TRIAL'; end if;",
        "if :P20_OFF is null then :P20_OFF := 'FIN:DOC'; end if;",
        "if :P20_COUNTRY is null then :P20_COUNTRY := 'SA'; end if;"])
    p.dynamic('السعر', 45, 'return noona_signup_pkg.quote_html(:P20_OFF, to_number(:P20_USERS), :P20_PLAN);', condition=f'{STEP} = 4')
    p.dynamic('بيانات التحويل', 46, [
        "return '<div class=\"nn-sgn-bank\"><b>حول المبلغ المستحق إلى:</b><br>' || noona_ui_pkg.esc(noona_signup_pkg.bank_details)",
        "  || '<br><small>تبدأ مؤسستك فوراً بتجربة، وتتحول للاشتراك المدفوع عند تأكيد التحويل.</small></div>';"],
        hide_header=True, condition=f"{STEP} = 4 and :P20_PLAN <> 'TRIAL'")
    p.process(40, 'AFTER_SUBMIT', 'Finish', [
        'begin',
        '  noona_signup_pkg.save_plan(:P20_TOKEN, :P20_OFF, to_number(:P20_USERS), :P20_PLAN, :P20_PAY, :P20_REF);',
        '  :P20_DONE_USER := noona_signup_pkg.finish(:P20_TOKEN);',
        'end;'], when_button=b_fin)

    # ---------------------------------------------------------------- 5) جاهز
    p.dynamic('مؤسستك جاهزة', 50, [
        "return '<div class=\"nn-sgn-done\"><span class=\"fa fa-check-circle\"></span><h2>تم إنشاء مؤسستك</h2>'",
        "  || '<p>ادخل باسم الدخول <b dir=\"ltr\">' || noona_ui_pkg.esc(noona_signup_pkg.field(:P20_TOKEN, 'USERNAME'))",
        "  || '</b> وكلمة المرور التي اخترتها، ثم ابدأ من «إدارة المؤسسة ← بدء التشغيل ونقل البيانات».</p>'",
        "  || case when noona_signup_pkg.field(:P20_TOKEN, 'STATUS') = 'PAYMENT_PENDING'",
        "          then '<p class=\"nn-hint\">المستحق ' || noona_signup_pkg.field(:P20_TOKEN, 'TOTAL') || ' ريال؛ تعمل مؤسستك الآن بتجربة حتى يؤكد فريقنا التحويل.</p>' end",
        "  || '<a class=\"t-Button t-Button--hot t-Button--large\" href=\"f?p=' || :APP_ID || ':1:0\">الدخول إلى النظام</a></div>';"],
        hide_header=True, condition=f'{STEP} = 5')

    for it in ('P20_TOKEN', 'P20_STEP', 'P20_DEMO', 'P20_DONE_USER'):
        p.hidden(it, a, 900)
    p.branch(10, 'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::')


def login_link(out_dir):
    """رابط «أنشئ حساب مؤسستك» تحت نموذج الدخول في التطبيق الرئيسي"""
    path = out_dir + '/application/pages/page_09999.sql'
    s = open(path, encoding='utf-8').read()
    if 'NOONA-SIGNUP-LINK' in s:
        return
    region = """wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000099001)
,p_plug_name=>'NOONA-SIGNUP-LINK'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>90
,p_plug_source=>'<div class="nn-sgn-login-link">ليس لديك حساب؟ <a href="f?p=&APP_ID.:SIGNUP:0">أنشئ حساب مؤسستك وجرّب مجاناً 14 يوماً</a></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'Y',
  'output_as', 'HTML')).to_clob
);
"""
    i = s.rindex('wwv_flow_imp.component_end;')
    open(path, 'w', encoding='utf-8').write(s[:i] + region + s[i:])
