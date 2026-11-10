"""صفحة «اشتراكي» في إدارة المؤسسة: الخطة والفترة والأنظمة والمستخدمون، وطلب إضافة أنظمة أو مستخدمين أو تجديد أو ترقية
بالسعر فوراً (يطبق عند تأكيد مسؤول المنصة للتحويل). المنطق في NOONA_ACCOUNT_PKG و NOONA_SIGNUP_PKG.
"""
PAGE = 91


def add(app, scheme, nav_seq):
    p = app.page(PAGE, 'My Subscription', 'MY-SUBSCRIPTION', 'اشتراكي', scheme=scheme)
    p.dynamic('اشتراك المؤسسة', 10, 'return noona_account_pkg.my_subscription_html;')
    f = p.static('طلب تجديد أو إضافة أنظمة أو مستخدمين', 20, text=(
        '<p class="nn-hint">حدد الأنظمة كما تريدها بعد التعديل (المشترك فيها محددة مسبقاً) وعدد المستخدمين والخطة، ثم حوّل المبلغ '
        'واكتب مرجع التحويل. نفعل الطلب ونرسل الفاتورة عند تأكيد وصول التحويل.</p>'))
    p.checkboxes('P91_OFF', f, 10, 'الأنظمة', (
        "select name_ar || case when monthly_price > 0 then ' (' || to_char(monthly_price, 'FM999,990') || ' ريال/شهر)' else ' (مشمول)' end d, code r "
        "from plt_offering where is_active = 'Y' order by sort_order"), columns=2)
    p.number('P91_USERS', f, 20, 'عدد المستخدمين')
    p.select('P91_PLAN', f, 30, 'الخطة', lov_sql=(
        "select name_ar || case when discount_pct > 0 then ' - خصم ' || to_char(discount_pct) || '%' end d, code r"
        " from plt_plan where is_active = 'Y' and self_service = 'Y' and code <> 'TRIAL'"
        " order by decode(code, 'MONTHLY', 1, 'QUARTERLY', 2, 'SEMI_ANNUAL', 3, 'ANNUAL', 4, 9)"), null_text=None, submit=True)
    p.text('P91_REF', f, 40, 'مرجع التحويل', maxlen=100)
    b_calc = p.button(f, 10, 'CALC', 'احسب السعر')
    b_req = p.button(f, 20, 'REQUEST', 'إرسال الطلب', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'if :P91_OFF is null then :P91_OFF := noona_account_pkg.tenant_offerings; end if;',
        'if :P91_USERS is null then :P91_USERS := nvl(noona_account_pkg.user_limit, 3); end if;',
        "if :P91_PLAN is null then :P91_PLAN := 'ANNUAL'; end if;"])
    p.process(10, 'AFTER_SUBMIT', 'Request', [
        'declare l number;', 'begin',
        '  l := noona_account_pkg.request_change(:P91_OFF, to_number(:P91_USERS), :P91_PLAN, :P91_REF);',
        '  :P91_REF := null;', 'end;'], when_button=b_req, success='أرسل الطلب؛ نفعله عند تأكيد التحويل')
    p.dynamic('السعر', 25, 'return noona_signup_pkg.quote_html(:P91_OFF, to_number(:P91_USERS), :P91_PLAN);')
    p.dynamic('بيانات التحويل', 26, [
        "return '<div class=\"nn-sgn-bank\"><b>حول المبلغ المستحق إلى:</b><br>' || noona_ui_pkg.esc(noona_signup_pkg.bank_details) || '</div>';"],
        hide_header=True)
    r = p.static('طلباتي', 30)
    p.select('P91_REQ', r, 10, 'إلغاء طلب قائم', lov_sql=(
        "select '#' || id || ' ' || plan_code || ' - ' || to_char(amount_due, 'FM999,999,990.00') || ' ريال' d, id r from plt_sub_request"
        " where status_code = 'PENDING' and tenant_id = noona_account_pkg.tenant order by id desc"))
    b_can = p.button(r, 10, 'CANCEL_REQ', 'إلغاء الطلب')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_account_pkg.cancel_request(to_number(:P91_REQ)); :P91_REQ := null;', when_button=b_can,
              success='ألغي الطلب')
    p.dynamic('الطلبات', 35, 'return noona_account_pkg.my_requests_html;', hide_header=True)
    app.nav_item('اشتراكي', PAGE, 'fa-credit-card', nav_seq, scheme=scheme)
