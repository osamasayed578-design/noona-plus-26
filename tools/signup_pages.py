"""التسجيل الذاتي للعملاء: صفحة عامة في التطبيق الرئيسي (NOONA_MASTER) بخطوات: الحساب ← التحقق بالرمز ← المؤسسة ←
الأنظمة والخطة والسعر ← الإنشاء؛ ورابط «إنشاء حساب» في صفحة الدخول. المنطق كله في NOONA_SIGNUP_PKG.
"""
import re

PAGE = 20
STEP = ':P20_STEP'


def add(app):
    p = app.page(PAGE, 'Signup', 'SIGNUP', 'إنشاء حساب مؤسسة - نونا بلس', protection='C', public=True)
    p.process(5, 'BEFORE_HEADER', 'Step', ':P20_STEP := noona_signup_pkg.step(:P20_TOKEN);')
    p.static('رأس الموقع', 1, hide_header=True, text=SITE_NAV)
    p.dynamic('الخطوات', 5, [
        'declare l_s number := nvl(:P20_STEP, 1); l_h varchar2(4000);',
        'begin',
        "  l_h := '<div class=\"nn-sgn-hero\"><div><h1>أنشئ حساب مؤسستك</h1>'",
        "      || '<p>خمس خطوات وتبدأ تجربتك المجانية 14 يوماً بكل الأنظمة التي تختارها.</p></div></div>'",
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


def add_reset(app):
    """«نسيت كلمة المرور»: رمز للبريد ثم كلمة مرور جديدة (NOONA_ACCOUNT_PKG)"""
    p = app.page(21, 'Reset Password', 'RESET-PASSWORD', 'استعادة كلمة المرور - نونا بلس', protection='C', public=True)
    p.static('رأس الموقع', 1, hide_header=True, text=SITE_NAV)
    a = p.static('استعادة كلمة المرور', 10, condition=':P21_TOKEN is null', text=(
        '<p class="nn-hint">أدخل اسم الدخول أو البريد المسجل؛ نرسل رمزاً صالحاً 15 دقيقة إلى بريدك.</p>'))
    p.text('P21_LOGIN', a, 10, 'اسم الدخول أو البريد الإلكتروني', maxlen=320)
    b_send = p.button(a, 10, 'SEND', 'إرسال الرمز', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Send', ":P21_TOKEN := noona_account_pkg.request_reset(:P21_LOGIN, owa_util.get_cgi_env('REMOTE_ADDR'));",
              when_button=b_send, success='إن كان الحساب مسجلاً فقد أرسلنا رمزاً إلى بريده')
    c = p.static('كلمة مرور جديدة', 20, condition=':P21_TOKEN is not null and :P21_DONE is null', text=(
        '<p class="nn-hint">أدخل الرمز المرسل إلى بريدك وكلمة المرور الجديدة (10 أحرف على الأقل: حرف كبير وصغير ورقم).</p>'))
    p.text('P21_CODE', c, 10, 'الرمز', maxlen=6, width=10)
    p.password('P21_NEW', c, 20, 'كلمة المرور الجديدة')
    p.password('P21_NEW2', c, 30, 'تأكيد كلمة المرور')
    b_set = p.button(c, 10, 'SET', 'تغيير كلمة المرور', hot=True)
    b_again = p.button(c, 20, 'AGAIN', 'طلب رمز جديد')
    p.process(20, 'AFTER_SUBMIT', 'Set', [
        'noona_account_pkg.complete_reset(:P21_TOKEN, :P21_CODE, :P21_NEW, :P21_NEW2);',
        ":P21_NEW := null; :P21_NEW2 := null; :P21_DONE := 'Y';"], when_button=b_set)
    p.process(25, 'AFTER_SUBMIT', 'Again', ':P21_TOKEN := null; :P21_CODE := null;', when_button=b_again)
    p.dynamic('تم', 30, [
        "return '<div class=\"nn-sgn-done\"><span class=\"fa fa-check-circle\"></span><h2>تم تغيير كلمة المرور</h2>'",
        "  || '<a class=\"t-Button t-Button--hot t-Button--large\" href=\"f?p=' || :APP_ID || ':1:0\">الدخول إلى النظام</a></div>';"],
        hide_header=True, condition=":P21_DONE = 'Y'")
    for it in ('P21_TOKEN', 'P21_DONE'):
        p.hidden(it, a, 900)
    p.branch(10, 'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:::')


def login_link(out_dir):
    """رابط «أنشئ حساب مؤسستك» تحت نموذج الدخول في التطبيق الرئيسي"""
    path = out_dir + '/application/pages/page_09999.sql'
    s = open(path, encoding='utf-8').read()
    if 'NOONA-SIGNUP-LINK' in s:
        return  # يعاد توليد الصفحة من القالب في كل بناء
    region = """wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820263000099001)
,p_plug_name=>'NOONA-SIGNUP-LINK'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>90
,p_plug_source=>'<div class="nn-sgn-login-link"><a href="f?p=&APP_ID.:RESET-PASSWORD:0">نسيت كلمة المرور؟</a> · <a href="f?p=&APP_ID.:WELCOME:0">تعرّف على نونا بلس والأسعار</a><br>ليس لديك حساب؟ <a href="f?p=&APP_ID.:SIGNUP:0">أنشئ حساب مؤسستك وجرّب مجاناً 14 يوماً</a></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'Y',
  'output_as', 'HTML')).to_clob
);
"""
    i = s.rindex('wwv_flow_imp.component_end;')
    open(path, 'w', encoding='utf-8').write(s[:i] + region + s[i:])



LOGIN_JS = r"""<script>
(function(){
  var root = document.getElementById('nnlShow'); if (!root) return;
  document.body.appendChild(root);   // خارج منطقة الصفحة: يملأ الشاشة بجانب عمود الدخول
  document.body.classList.add('nnl-page');
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var back = null; try { back = JSON.parse(localStorage.getItem('nn_back') || 'null'); } catch (e) {}
  var neu = root.querySelector('.nnl-new'), old = root.querySelector('.nnl-back');
  var slides = [].slice.call(root.querySelectorAll('.nnl-new .nnl-slide')), dots = [].slice.call(root.querySelectorAll('.nnl-dot'));
  var cur = 0, timer = null, hold = false;
  function show(i){ slides[cur].classList.remove('is-on'); dots[cur] && dots[cur].classList.remove('is-on');
    cur = (i + slides.length) % slides.length; slides[cur].classList.add('is-on'); dots[cur] && dots[cur].classList.add('is-on'); }
  function play(){ if (reduce || slides.length < 2) return; clearInterval(timer); timer = setInterval(function(){ if (!hold) show(cur + 1); }, 6000); }
  dots.forEach(function(d, i){ d.addEventListener('click', function(){ show(i); play(); }); });
  var box = root.querySelector('.nnl-new .nnl-slides');
  box.addEventListener('mouseenter', function(){ hold = true; }); box.addEventListener('mouseleave', function(){ hold = false; });
  function count(){ root.querySelectorAll('[data-count]').forEach(function(b){ var t = +b.getAttribute('data-count'), n = 0, s = Math.max(1, Math.round(t / 30));
    if (reduce) { b.textContent = t; return; } var k = setInterval(function(){ n = Math.min(t, n + s); b.textContent = n; if (n >= t) clearInterval(k); }, 40); }); }
  function tour(){ old.hidden = true; neu.hidden = false; play(); count(); }
  if (back && back.org !== undefined) {
    neu.hidden = true; old.hidden = false;
    var o = old.querySelector('.nnl-org'); if (back.org) o.textContent = '، ' + back.org;
    var subs = (back.subs || []), pick = slides.filter(function(s){ return subs.indexOf(s.getAttribute('data-code')) < 0 && s.getAttribute('data-code') !== 'DOC'; });
    var promo = old.querySelector('.nnl-promo');
    if (pick.length) { var c = pick[Math.floor(Math.random() * pick.length)].cloneNode(true); c.classList.add('is-on'); promo.appendChild(c); }
    else { promo.remove(); old.querySelector('.nnl-promo-h').remove(); }
    old.querySelector('.nnl-tour').addEventListener('click', function(e){ e.preventDefault(); tour(); });
  } else { play(); count(); }
})();
</script>"""


def login_showcase(out_dir):
    """صفحة الدخول: عمود الدخول يمين الشاشة والعرض المتحرك للأنظمة في باقيها (أو «أهلاً بعودتك» لمن دخل سابقاً)"""
    path = out_dir + '/application/pages/page_09999.sql'
    s = open(path, encoding='utf-8').read()
    if 'NOONA-LOGIN-SHOWCASE' in s:
        return
    js = LOGIN_JS.replace("'", "''''")   # الاقتباس داخل نص PL/SQL داخل ملف التصدير
    lines = ["'return noona_signup_pkg.login_showcase_html(''f?p='' || :APP_ID || '':SIGNUP:0'', ''f?p='' || :APP_ID || '':WELCOME:0'')',"]
    for ln in js.split('\n'):
        lines.append("'  || ''" + ln + "'' || chr(10)',")
    lines.append("';'")
    region = ("wwv_flow_imp_page.create_page_plug(\n p_id=>wwv_flow_imp.id(91820263000099002)\n,p_plug_name=>'NOONA-LOGIN-SHOWCASE'\n"
              ",p_region_template_options=>'#DEFAULT#'\n,p_plug_template=>4501440665235496320\n,p_plug_display_sequence=>95\n"
              ",p_function_body_language=>'PLSQL'\n,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(\n"
              + '\n'.join(lines) + "))\n,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'\n);\n")
    i = s.rindex('wwv_flow_imp.component_end;')
    open(path, 'w', encoding='utf-8').write(s[:i] + region + s[i:])

SITE_NAV = (
    '<header class="nnw-top"><div class="nnw-wrap nnw-top-in">'
    '<a class="nnw-logo" href="f?p=&APP_ID.:WELCOME:&SESSION."><img src="#APP_FILES#noona-logo.svg" alt="">نونا بلس</a>'
    '<nav class="nnw-nav"><a href="f?p=&APP_ID.:WELCOME:&SESSION.#features">المزايا</a>'
    '<a href="f?p=&APP_ID.:WELCOME:&SESSION.#systems">الأنظمة</a>'
    '<a href="f?p=&APP_ID.:WELCOME:&SESSION.#pricing">الأسعار</a>'
    '<a href="f?p=&APP_ID.:WELCOME:&SESSION.#faq">الأسئلة</a></nav>'
    '<div class="nnw-act"><a class="nnw-link" href="f?p=&APP_ID.:1:&SESSION.">تسجيل الدخول</a>'
    '<a class="nnw-btn nnw-btn-primary" href="f?p=&APP_ID.:SIGNUP:&SESSION.">ابدأ مجاناً</a></div></div></header>')

FEATURES = [
    ('fa-sitemap', 'مؤسسة وشركات وفروع', 'شركة قابضة وتابعاتها وفروع بعملات مختلفة، وقوائم مالية موحدة بضغطة.'),
    ('fa-file-text-o', 'فاتورة إلكترونية', 'متوافقة مع متطلبات هيئة الزكاة والضريبة والدخل (فاتورة)، مع الإقرار الضريبي.'),
    ('fa-magic', 'مساعد ذكي', '«اسأل نونا» يجيب من بياناتك بالعربية، وملخصات وتحليلات وتنبؤات.'),
    ('fa-upload', 'انتقال سهل', 'استورد حساباتك وعملاءك وأصنافك وموظفيك وأرصدتك من ملفات Excel.'),
    ('fa-shield', 'أمان وصلاحيات', 'عزل تام لبيانات كل مؤسسة، وأدوار وصلاحيات دقيقة، وسجل تدقيق لا يعدل.'),
    ('fa-mobile', 'من أي جهاز', 'يعمل من المتصفح على الحاسب والجوال، عربي بالكامل من اليمين لليسار.'),
]
STEPS = [('أنشئ حسابك', 'بريدك وجوالك ورمز تحقق'), ('أدخل مؤسستك', 'الاسم والسجل والرقم الضريبي'),
         ('اختر أنظمتك', 'وعدد المستخدمين، والسعر يظهر فوراً'), ('ابدأ العمل', 'تجربة 14 يوماً وانقل بياناتك من Excel')]
FAQ = [
    ('هل أحتاج بطاقة للتجربة؟', 'لا. التجربة المجانية 14 يوماً بلا أي دفع، وبكل الأنظمة التي تختارها.'),
    ('ماذا يحدث لبياناتي بعد التجربة؟', 'تبقى كما هي. عند الاشتراك تستمر عليها، وإن لم تشترك تتحول المؤسسة للقراءة فقط دون حذف.'),
    ('كيف أدفع؟', 'بالتحويل البنكي حالياً: تكتب مرجع التحويل، ونفعل اشتراكك ونرسل فاتورتك الضريبية بالبريد.'),
    ('هل أستطيع إضافة أنظمة أو مستخدمين لاحقاً؟', 'نعم، من «إدارة المؤسسة ← اشتراكي» في أي وقت، بالسعر المعلن.'),
    ('كيف أنقل بياناتي من نظامي الحالي؟', 'من «بدء التشغيل ونقل البيانات» بملفات Excel جاهزة النماذج، مع مطابقة الأرصدة الافتتاحية.'),
]


def add_site(app):
    """صفحة الموقع العامة (WELCOME): الرأس والتنقل، البطل، المزايا، الأنظمة بأسعارها، الباقات، الخطوات، الأسئلة، التذييل"""
    p = app.page(22, 'Welcome', 'WELCOME', 'نونا بلس - نظام إدارة المؤسسات', protection='C', public=True)
    signup = 'f?p=&APP_ID.:SIGNUP:&SESSION.'
    p.static('الرأس', 5, hide_header=True, text=SITE_NAV + (
        '<section class="nnw-hero"><div class="nnw-wrap nnw-hero-in"><div class="nnw-hero-txt">'
        '<span class="nnw-pill">نظام سحابي سعودي · عربي بالكامل</span>'
        '<h1>أدر مؤسستك كلها من نظام واحد</h1>'
        '<p>المالية والمخزون والمبيعات والموارد البشرية والعقارات والمقاولات والمستشفيات وغيرها، بفاتورة إلكترونية '
        'ومساعد ذكي، وقوائم موحدة لمجموعتك.</p>'
        f'<div class="nnw-cta"><a class="nnw-btn nnw-btn-primary nnw-btn-lg" href="{signup}">ابدأ تجربتك المجانية 14 يوماً</a>'
        '<a class="nnw-btn nnw-btn-ghost nnw-btn-lg" href="f?p=&APP_ID.:WELCOME:&SESSION.#pricing">شاهد الأسعار</a></div>'
        '<ul class="nnw-ticks"><li>بلا بطاقة</li><li>جاهز خلال دقائق</li><li>انقل بياناتك من Excel</li></ul></div>'
        '<div class="nnw-hero-art"><img src="#APP_FILES#noona-logo-white.svg" alt=""><div class="nnw-kpi"><b>12</b><span>نظاماً متكاملاً</span></div>'
        '<div class="nnw-kpi"><b>8</b><span>دول خليجية وعربية</span></div><div class="nnw-kpi"><b>14</b><span>يوماً مجاناً</span></div></div>'
        '</div></section>'))
    p.static('المزايا', 10, hide_header=True, text=(
        '<section class="nnw-sec" id="features"><div class="nnw-wrap"><h2>لماذا نونا بلس؟</h2><p class="nnw-sub">صُمم لمؤسسات المنطقة: '
        'لغتها وأنظمتها الضريبية وطريقة عملها.</p><div class="nnw-grid nnw-feat">'
        + ''.join(f'<div class="nnw-card"><div class="nnw-ic"><span class="fa {i}"></span></div><h3>{t}</h3><p>{d}</p></div>' for i, t, d in FEATURES)
        + '</div></div></section>'))
    p.dynamic('الأنظمة', 20, [
        "return '<section class=\"nnw-sec nnw-alt\" id=\"systems\"><div class=\"nnw-wrap\"><h2>اختر الأنظمة التي تحتاجها</h2>'",
        "  || '<p class=\"nnw-sub\">ادفع فقط لما تستخدمه، وأضف غيره متى احتجت.</p>'",
        "  || noona_signup_pkg.site_systems_html('f?p=' || :APP_ID || ':SIGNUP:' || :APP_SESSION) || '</div></section>';"], hide_header=True)
    p.dynamic('الأسعار', 30, [
        "return '<section class=\"nnw-sec\" id=\"pricing\"><div class=\"nnw-wrap\"><h2>أسعار واضحة</h2>'",
        "  || '<p class=\"nnw-sub\">كلما طالت المدة زاد الخصم.</p>'",
        "  || noona_signup_pkg.site_plans_html('f?p=' || :APP_ID || ':SIGNUP:' || :APP_SESSION) || '</div></section>';"], hide_header=True)
    p.static('الخطوات والأسئلة', 40, hide_header=True, text=(
        '<section class="nnw-sec nnw-alt"><div class="nnw-wrap"><h2>ابدأ في أربع خطوات</h2><ol class="nnw-steps">'
        + ''.join(f'<li><span>{n}</span><b>{t}</b><small>{d}</small></li>' for n, (t, d) in enumerate(STEPS, 1))
        + '</ol></div></section>'
        '<section class="nnw-sec" id="faq"><div class="nnw-wrap nnw-narrow"><h2>أسئلة شائعة</h2>'
        + ''.join(f'<details class="nnw-faq"><summary>{q}</summary><p>{a}</p></details>' for q, a in FAQ)
        + '</div></section>'
        f'<section class="nnw-final"><div class="nnw-wrap"><h2>جاهز تبدأ؟</h2><p>أنشئ مؤسستك الآن وجرّب كل شيء مجاناً.</p>'
        f'<a class="nnw-btn nnw-btn-light nnw-btn-lg" href="{signup}">ابدأ مجاناً</a></div></section>'
        '<footer class="nnw-foot"><div class="nnw-wrap nnw-foot-in"><span><img src="#APP_FILES#noona-logo-white.svg" alt=""> نونا بلس</span>'
        '<span>© 2026 جميع الحقوق محفوظة</span><span><a href="f?p=&APP_ID.:1:&SESSION.">تسجيل الدخول</a> · '
        f'<a href="{signup}">إنشاء حساب</a></span></div></footer>'))
