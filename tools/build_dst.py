"""NOONA_DST (التوزيع والمبيعات الميدانية): تطبيق المندوب على الهاتف (خطة اليوم، الزيارة بالموقع، البيع من السيارة، التحصيل برقم
المرجع، المرتجع، الطلبية المسبقة، عدم الشراء وسببه، إرسال الفاتورة وكشف الحساب بواتساب، تحميل السيارة، تسوية نهاية اليوم، إضافة
محل بموقعه) وشاشات مدير التوزيع (المندوبون، خطوط السير، المحلات وخريطتها، الزيارات، تأكيد التحويلات والشيكات، أوامر التوريد،
التسويات، الأداء، المحلات الراكدة، العمولات).
الاستخدام: python3 tools/build_dst.py  ->  apex/NOONA_DST/f149
المنطق كله في NOONA_DST_PKG؛ الواجهة التفاعلية في tools/dst.js.
"""
import os, shutil, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand

ROOT = os.path.join(os.path.dirname(__file__), '..')
shutil.copyfile(os.path.join(os.path.dirname(__file__), 'dst.js'), os.path.join(apex_brand.STATIC_DIR, 'dst.js'))
if ('dst.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('dst.js', 'application/javascript'))
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_DST/f149'),
          app_id=149, alias='NOONA_DST', name='NOONA Distribution & Field Sales', id_base=91820300000000000)
app.wire_security()
app.add_branding()
DST = app.add_scheme('noona_dst_field', app.id(), 'NOONA - Distribution Field',
                     "return noona_security_pkg.has_permission('DST_VISIT.VIEW', noona_dst_pkg.company) = 'Y' "
                     "and noona_platform_pkg.module_enabled('DST') = 'Y';",
                     'شاشات التوزيع تتطلب صلاحية الزيارات واشتراك التوزيع / Distribution access required')
MGR = app.add_scheme('noona_dst_manager', app.id(), 'NOONA - Distribution Manager',
                     "return noona_security_pkg.has_permission('DST_REP.UPDATE', noona_dst_pkg.company) = 'Y' "
                     "and noona_platform_pkg.module_enabled('DST') = 'Y';",
                     'شاشات مدير التوزيع تتطلب صلاحية تعديل المندوبين / Distribution manager access required')
CO = 'noona_dst_pkg.company'
READY = "noona_dst_pkg.is_ready = 'Y'"


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'dst.js'; "
          "document.head.appendChild(s); })();"]


def field_js(p, methods=None, extra=None):
    code = []
    if methods:
        code.append('window.DST_METHODS = ' + methods + ';')
    code += extra or []
    p.onload(code + LOADER)


REP_LOV = f"select full_name || ' (' || code || ')' d, id r from dst_rep where company_id = {CO} and status_code = 'ACTIVE' order by full_name"
ROUTE_LOV = (f"select r.name_ar || nvl2(r.rep_id, ' · ' || noona_dst_pkg.rep_label(r.rep_id), '') d, r.id r from dst_route r "
             f"where r.company_id = {CO} and r.status_code = 'ACTIVE' order by r.name_ar")
WH_LOV = (f"select w.name_ar || ' (' || w.code || ')' d, w.id r from inv_warehouse w where w.company_id = {CO} and w.status_code = 'ACTIVE' "
          "and not exists (select 1 from dst_rep x where x.van_warehouse_id = w.id) order by w.name_ar")
BOX_LOV = (f"select b.name_ar || ' (' || b.code || ')' d, b.id r from csh_cash_box b where b.company_id = {CO} and b.status_code = 'ACTIVE' "
           "and not exists (select 1 from dst_rep x where x.cash_box_id = b.id) order by decode(b.box_type, 'MAIN', 0, 1), b.name_ar")
BANK_LOV = (f"select a.name_ar || ' · ' || a.account_no_masked d, a.id r from csh_bank_account a where a.company_id = {CO} "
            "and a.status_code = 'ACTIVE' order by a.name_ar")
USER_LOV = ("select nvl(u.display_name, u.username) || ' (' || u.username || ')' d, upper(u.username) r "
            "from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = 'ACTIVE' order by 1")
CUST_LOV = ("select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id "
            f"where a.company_id = {CO} and a.status_code = 'ACTIVE' and nvl(c.is_walk_in, 'N') = 'N' order by 1")
SHOP_TYPE = ('STATIC2:بقالة;GROCERY,سوبرماركت;SUPERMARKET,صيدلية;PHARMACY,مطعم;RESTAURANT,مقهى;CAFE,جملة;WHOLESALE,كشك;KIOSK,'
             'محطة وقود;STATION,أخرى;OTHER')
PAY = 'STATIC2:نقداً;CASH,تحويل بنكي (رقم الإشعار);BANK_TRANSFER,شيك;CHEQUE,شبكة / بطاقة;CARD,محفظة إلكترونية;WALLET'
NO_SALE = ('STATIC2:المحل مغلق;CLOSED,لديه مخزون كافٍ;STOCKED,لا توجد سيولة;NO_CASH,صاحب المحل غير موجود;OWNER_ABSENT,'
           'يشتري من منافس;COMPETITOR,السعر مرتفع;PRICE,سبب آخر;OTHER')
EMP_LOV = ("select e.employee_no || ' - ' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
           "where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_dst_pkg.company "
           "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD')) order by e.employee_no")
PAYM = 'STATIC2:مع الراتب (مسير الرواتب);PAYROLL,نقداً (سند صرف);CASH,تحويل بنكي (سند صرف);BANK_TRANSFER,لا يستحق عمولة;NONE'
BASIS = 'STATIC2:نسبة من المبيعات;SALES,نسبة من التحصيل;COLLECTION,مبلغ لكل زيارة منفذة;VISIT,بلا عمولة;NONE'
DAYS_HINT = 'أيام الزيارة مفصولة بفواصل: SUN,MON,TUE,WED,THU,FRI,SAT'
REP_OF_USER = 'noona_dst_pkg.my_rep'


def pay_items(p, r, px, seq, amount_label='المبلغ المدفوع', fill=False):
    """طريقة الدفع والمبلغ ورقم المرجع والبنك وتاريخ الشيك (تظهر حسب الطريقة)"""
    p.select(f'{px}M', r, seq, 'طريقة الدفع', lov_sql=PAY, null_text=None)
    p.number(f'{px}AMT', r, seq + 1, amount_label)
    p.text(f'{px}REF', r, seq + 2, 'رقم المرجع', maxlen=100, width=24)
    p.text(f'{px}BANK', r, seq + 3, 'البنك المحول منه / بنك الشيك', maxlen=100, width=24)
    p.date(f'{px}CHQ', r, seq + 4, 'تاريخ استحقاق الشيك')
    return "{item:'%sM',ref:'%sREF',bank:'%sBANK',chq:'%sCHQ'}" % (px, px, px, px)


PAY_JSON = '''  l_p := json_object_t();
  l_p.put('method', nvl(:{px}M, 'CASH')); l_p.put('amount', to_number(:{px}AMT)); l_p.put('ref', :{px}REF);
  l_p.put('bank', :{px}BANK); l_p.put('chequeDate', :{px}CHQ);'''


def pay_json(px):
    return PAY_JSON.replace('{px}', px)


# =============================================================== 1) الرئيسية: خطة اليوم للمندوب ولوحة المدير
p = app.page(1, 'Home', 'HOME', 'التوزيع والمبيعات الميدانية', scheme=DST, protection='N')
st = p.static('تجهيز التوزيع', 5, condition="noona_dst_pkg.is_ready = 'N'",
              text='<p class="nn-hint">يجهز التسلسلات والإعدادات الافتراضية للتوزيع. أضف بعدها المندوبين (ينشأ لكل مندوب مستودع سيارة '
                   'وعهدة نقدية تلقائياً)، ثم خطوط السير وأيام الزيارة، ثم المحلات بمواقعها. مرة واحدة لكل شركة.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز التوزيع', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_dst_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم تجهيز التوزيع')
p.dynamic('اختصارات', 6, 'return noona_dst_pkg.quick_links_html;', hide_header=True, condition=READY)
p.dynamic('خطة اليوم', 10, [
    "return noona_dst_pkg.plan_html(noona_dst_pkg.my_rep, trunc(sysdate),",
    "  replace(apex_page.get_url(p_page => 2, p_clear_cache => '2', p_items => 'P2_SHOP', p_values => 'XSHOPX'), 'XSHOPX', '#SHOP#'));"],
    condition=READY + ' and noona_dst_pkg.my_rep is not null')
p.dynamic('يومي حتى الآن', 20, 'return noona_dst_pkg.rep_day_html(noona_dst_pkg.my_rep, trunc(sysdate));',
          condition=READY + ' and noona_dst_pkg.my_rep is not null')
p.dynamic('أداء اليوم لكل المندوبين', 30, 'return noona_dst_pkg.performance_html(trunc(sysdate), trunc(sysdate));',
          condition=READY + " and noona_security_pkg.has_permission('DST_REP.UPDATE', noona_dst_pkg.company) = 'Y'")
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 2) الزيارة (الهاتف)
p = app.page(2, 'Visit', 'VISIT', 'زيارة محل', scheme=DST, protection='N')
h = p.static('بيانات الزيارة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P2_SHOP', h, 1, protected=False)
p.hidden('P2_VISIT', h, 2)
p.hidden('P2_LAT', h, 3, protected=False)
p.hidden('P2_LNG', h, 4, protected=False)
p.process(5, 'BEFORE_HEADER', 'Visit', [
    'declare l_v number := noona_dst_pkg.open_visit(noona_dst_pkg.my_rep);',
    'begin',
    '  :P2_VISIT := null;',
    '  for v in (select id from dst_visit where id = l_v and shop_id = :P2_SHOP) loop :P2_VISIT := v.id; end loop;',
    'end;'])
p.dynamic('المحل', 5, 'return noona_dst_pkg.shop_card_html(:P2_SHOP);', hide_header=True)
p.dynamic('زيارة جارية لمحل آخر', 6, [
    'declare l_v number := noona_dst_pkg.open_visit(noona_dst_pkg.my_rep);',
    'begin',
    "  for v in (select shop_id from dst_visit where id = l_v) loop",
    "    return '<p class=\"nn-hint\">لديك زيارة جارية في <b>' || apex_escape.html(noona_dst_pkg.shop_label(v.shop_id)) || '</b>. أنهِها أولاً.</p>'",
    "        || '<a class=\"nn-dst-btn nn-dst-go\" href=\"' || apex_page.get_url(p_page => 2, p_items => 'P2_SHOP', p_values => v.shop_id) || '\">الانتقال للزيارة الجارية</a>';",
    '  end loop;',
    '  return null;',
    'end;'], condition=":P2_VISIT is null and noona_dst_pkg.open_visit(noona_dst_pkg.my_rep) is not null")
ck = p.static('تسجيل الوصول', 7, hide_header=True,
              condition=":P2_VISIT is null and noona_dst_pkg.open_visit(noona_dst_pkg.my_rep) is null and noona_dst_pkg.my_rep is not null",
              text='<button type="button" class="nn-dst-btn nn-dst-checkin" data-lat="P2_LAT" data-lng="P2_LNG" data-req="CHECKIN">'
                   '<span class="fa fa-map-marker"></span> تسجيل الوصول</button>'
                   '<p class="nn-hint">يسجل وقت الوصول وموقعك ويحسب بعدك عن موقع المحل. أول زيارة لمحل بلا موقع تحفظ موقعه للتوزيع التالي.</p>')
p.process(10, 'AFTER_SUBMIT', 'Check-in', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  l.put('shop', to_number(:P2_SHOP)); l.put('lat', to_number(:P2_LAT)); l.put('lng', to_number(:P2_LNG));",
    '  :P2_VISIT := noona_dst_pkg.start_visit(l.to_clob);',
    'end;'], when=":REQUEST = 'CHECKIN'", success='تم تسجيل الوصول')
OPEN = ':P2_VISIT is not null'
p.dynamic('الزيارة', 10, 'return noona_dst_pkg.visit_html(:P2_VISIT);', condition=OPEN)

sale = p.static('بيع من السيارة', 20, condition=OPEN)
p.dynamic('أصناف السيارة', 21, ["return '<div data-item=\"P2_LINES\">' || noona_dst_pkg.items_picker_html(noona_dst_pkg.my_rep, 'SALE') || '</div>"
                                 "<span data-dst-total=\"0\" hidden></span>';"], hide_header=True, condition=OPEN)
pay = p.static('الدفع عند البيع', 22, condition=OPEN,
               text='<p class="nn-hint">اترك المبلغ فارغاً للبيع الآجل ضمن حد المحل، أو <a href="#" class="nn-dst-fill" data-target="P2_SAMT">'
                    'ادفع الإجمالي كاملاً</a>. النقد والشبكة يرحلان فوراً؛ التحويل والشيك بعد تأكيد المحاسب.</p>')
p.hidden('P2_LINES', pay, 1, protected=False)
m_sale = pay_items(p, pay, 'P2_S', 10)
b_sale = p.button(pay, 10, 'SALE', 'إصدار الفاتورة', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Sale', [
    'declare l json_object_t := json_object_t(); l_p json_object_t; l_id number;',
    'begin',
    "  l.put('visit', to_number(:P2_VISIT));",
    "  l.put('lines', json_array_t(nvl(:P2_LINES, '[]')));",
    pay_json('P2_S'),
    "  if to_number(:P2_SAMT) > 0 then l.put('pay', l_p); end if;",
    '  l_id := noona_dst_pkg.visit_sale(l.to_clob);',
    "  :P2_LINES := null; :P2_SAMT := null; :P2_SREF := null; :P2_SBANK := null; :P2_SCHQ := null;",
    'end;'], when_button=b_sale, success='تم إصدار الفاتورة. أرسلها للمحل بواتساب من الأسفل.')

col = p.static('تحصيل من الرصيد', 30, condition=OPEN)
p.select('P2_CINV', col, 5, 'الفاتورة المسددة (اختياري)', lov_sql=(
    "select i.doc_no || ' · ' || to_char(i.doc_date, 'YYYY-MM-DD') || ' · ' || to_char(i.total_amount, 'FM999G999G990D00') d, i.id r "
    "from sal_invoice i join dst_shop s on s.customer_account_id = i.customer_account_id "
    "where s.id = :P2_SHOP and i.status_code = 'POSTED' and i.doc_type in ('INVOICE', 'SIMPLIFIED_INVOICE') "
    "and exists (select 1 from ar_open_item o where o.source_entity_id = i.id and o.source_entity_type = 'SAL_INVOICE' and o.status_code in ('OPEN', 'PARTIALLY_PAID')) order by i.id desc"),
    null_text='- أقدم الفواتير أولاً -')
m_col = pay_items(p, col, 'P2_C', 10, amount_label='المبلغ المحصل')
b_col = p.button(col, 10, 'COLLECT', 'تسجيل التحصيل', hot=True)
p.process(30, 'AFTER_SUBMIT', 'Collect', [
    'declare l json_object_t; l_p json_object_t; l_id number;',
    'begin',
    pay_json('P2_C'),
    "  l := l_p; l.put('visit', to_number(:P2_VISIT)); l.put('invoice', to_number(:P2_CINV));",
    '  l_id := noona_dst_pkg.collect(l.to_clob);',
    "  :P2_CAMT := null; :P2_CREF := null; :P2_CBANK := null; :P2_CCHQ := null; :P2_CINV := null;",
    'end;'], when_button=b_col, success='تم تسجيل التحصيل')

od = p.static('طلبية مسبقة (توريد لاحق)', 40, condition=OPEN)
p.dynamic('أصناف الطلبية', 41, ["return '<div data-item=\"P2_OLINES\">' || noona_dst_pkg.items_picker_html(noona_dst_pkg.my_rep, 'ORDER') || '</div>';"],
          hide_header=True, condition=OPEN)
od2 = p.static('تسليم الطلبية', 42, hide_header=True, condition=OPEN)
p.hidden('P2_OLINES', od2, 1, protected=False)
p.date('P2_ODATE', od2, 10, 'تاريخ التسليم المطلوب')
p.text('P2_ONOTES', od2, 20, 'ملاحظات الطلبية', maxlen=500, width=40)
b_ord = p.button(od2, 10, 'ORDER', 'إرسال الطلبية')
p.process(40, 'AFTER_SUBMIT', 'Order', [
    'declare l json_object_t := json_object_t(); l_id number;',
    'begin',
    "  l.put('visit', to_number(:P2_VISIT)); l.put('lines', json_array_t(nvl(:P2_OLINES, '[]')));",
    "  l.put('date', :P2_ODATE); l.put('notes', :P2_ONOTES);",
    '  l_id := noona_dst_pkg.place_order(l.to_clob);',
    '  :P2_OLINES := null; :P2_ODATE := null; :P2_ONOTES := null;',
    'end;'], when_button=b_ord, success='تم إرسال الطلبية للتوريد')

rt = p.static('مرتجع', 50, condition=OPEN)
p.select('P2_RINV', rt, 5, 'فاتورة المرتجع', lov_sql=(
    "select i.doc_no || ' · ' || to_char(i.doc_date, 'YYYY-MM-DD') || ' · ' || to_char(i.total_amount, 'FM999G999G990D00') d, i.id r "
    "from sal_invoice i join dst_shop s on s.customer_account_id = i.customer_account_id "
    "where s.id = :P2_SHOP and i.status_code = 'POSTED' and i.doc_type in ('INVOICE', 'SIMPLIFIED_INVOICE') "
    "and i.doc_date >= trunc(sysdate) - 180 order by i.id desc"), submit=True)
p.dynamic('أصناف المرتجع', 51, ["return '<div data-item=\"P2_RLINES\">' || noona_dst_pkg.return_picker_html(:P2_RINV) || '</div>';"],
          hide_header=True, condition=OPEN + ' and :P2_RINV is not null')
rt2 = p.static('سبب المرتجع', 52, hide_header=True, condition=OPEN + ' and :P2_RINV is not null')
p.hidden('P2_RLINES', rt2, 1, protected=False)
p.text('P2_RREASON', rt2, 10, 'سبب المرتجع', maxlen=500, width=40)
b_ret = p.button(rt2, 10, 'RETURN', 'تسجيل المرتجع')
p.process(50, 'AFTER_SUBMIT', 'Return', [
    'declare l json_object_t := json_object_t(); l_id number;',
    'begin',
    "  l.put('visit', to_number(:P2_VISIT)); l.put('invoice', to_number(:P2_RINV)); l.put('reason', nvl(:P2_RREASON, 'مرتجع ميداني'));",
    "  l.put('lines', json_array_t(nvl(:P2_RLINES, '[]')));",
    '  l_id := noona_dst_pkg.visit_return(l.to_clob);',
    '  :P2_RLINES := null; :P2_RINV := null; :P2_RREASON := null;',
    'end;'], when_button=b_ret, success='تم تسجيل المرتجع وإشعار الدائن')

p.dynamic('إرسال بواتساب', 60, 'return noona_dst_pkg.visit_actions_html(:P2_VISIT);', condition=OPEN)
cl = p.static('إنهاء الزيارة', 70, condition=OPEN,
              text='<p class="nn-hint">إذا لم يشترِ المحل ولم يسدد اختر السبب (مطلوب). يحسب النظام نتيجة الزيارة تلقائياً.</p>')
p.select('P2_NOSALE', cl, 10, 'سبب عدم الشراء', lov_sql=NO_SALE, null_text='- تم البيع أو التحصيل -')
p.text('P2_CNOTES', cl, 20, 'ملاحظات الزيارة', maxlen=1000, width=40)
b_close = p.button(cl, 10, 'CLOSE', 'إنهاء الزيارة والمغادرة', hot=True)
p.process(60, 'AFTER_SUBMIT', 'Close', 'noona_dst_pkg.close_visit(:P2_VISIT, :P2_NOSALE, :P2_CNOTES); :P2_NOSALE := null; :P2_CNOTES := null;',
          when_button=b_close, success='تم إنهاء الزيارة')
field_js(p, '[' + m_sale + ',' + m_col + ']')
p.branch(5, url(1) + '&success_msg=#SUCCESS_MSG#', when_button=b_close)
p.branch(10, url(2, 'P2_SHOP', '&P2_SHOP.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 3) تحميل وتفريغ السيارة
p = app.page(3, 'Van Load', 'LOAD', 'تحميل وتفريغ السيارة', scheme=DST, protection='N')
f = p.static('الحركة', 10, text='<p class="nn-hint">التحميل ينقل من مستودع الشركة إلى مستودع السيارة، والتفريغ يعيد المتبقي. '
                                 'يغير الاتجاه أو المستودع قائمة الأصناف.</p>')
p.select('P3_REP', f, 5, 'المندوب', lov_sql=REP_LOV, submit=True)
p.select('P3_DIR', f, 10, 'الاتجاه', lov_sql='STATIC2:تحميل من المستودع;LOAD,تفريغ إلى المستودع;UNLOAD', null_text=None, submit=True)
p.select('P3_WH', f, 20, 'مستودع الشركة', lov_sql=WH_LOV, submit=True)
p.hidden('P3_LINES', f, 30, protected=False)
p.text('P3_NOTES', f, 40, 'ملاحظات', maxlen=500, width=40)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    '  if :P3_REP is null then :P3_REP := noona_dst_pkg.my_rep; end if;',
    "  if :P3_DIR is null then :P3_DIR := 'LOAD'; end if;",
    '  if :P3_WH is null then :P3_WH := noona_inv_pkg.default_warehouse; end if;',
    'end;'])
p.dynamic('الأصناف', 20, ["return '<div data-item=\"P3_LINES\">' || noona_dst_pkg.items_picker_html(:P3_REP, :P3_DIR, :P3_WH) || '</div>';"],
          condition=':P3_REP is not null')
b = p.button(f, 10, 'POST', 'ترحيل الحركة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Post', [
    'declare l json_object_t := json_object_t(); l_id number;',
    'begin',
    "  l.put('rep', to_number(:P3_REP)); l.put('direction', :P3_DIR); l.put('wh', to_number(:P3_WH)); l.put('notes', :P3_NOTES);",
    "  l.put('lines', json_array_t(nvl(:P3_LINES, '[]')));",
    '  l_id := noona_dst_pkg.load_van(l.to_clob);',
    '  :P3_LINES := null; :P3_NOTES := null;',
    'end;'], when_button=b, success='تم ترحيل حركة السيارة')
p.dynamic('مخزون السيارة الآن', 30, 'return noona_dst_pkg.van_stock_html(:P3_REP);', condition=':P3_REP is not null')
field_js(p)
p.branch(10, url(3) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 4) نهاية اليوم
p = app.page(4, 'End of Day', 'END-OF-DAY', 'تسوية نهاية اليوم', scheme=DST, protection='N')
f = p.static('اليوم', 5)
p.select('P4_REP', f, 5, 'المندوب', lov_sql=REP_LOV, submit=True)
p.date('P4_DATE', f, 10, 'اليوم')
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    '  if :P4_REP is null then :P4_REP := noona_dst_pkg.my_rep; end if;',
    "  if :P4_DATE is null then :P4_DATE := to_char(sysdate, 'YYYY-MM-DD'); end if;",
    'end;'])
b_show = p.button(f, 10, 'SHOW', 'عرض')
p.dynamic('ملخص اليوم', 10, "return noona_dst_pkg.settlement_preview_html(:P4_REP, to_date(:P4_DATE, 'YYYY-MM-DD'));",
          condition=':P4_REP is not null')
s = p.static('تسليم النقد', 20, condition=':P4_REP is not null',
             text='<p class="nn-hint">أدخل النقد الذي تسلمه فعلاً. ينقل للصندوق المختار، والعجز يبقى على عهدة المندوب حتى يسوى. '
                  'إشعارات التحويل والشيكات تؤكد من المحاسب.</p>')
p.number('P4_COUNTED', s, 10, 'النقد المسلم', required=False)
p.select('P4_BOX', s, 20, 'الصندوق المستلم', lov_sql=BOX_LOV)
p.text('P4_NOTES', s, 30, 'ملاحظات', maxlen=500, width=40)
b = p.button(s, 10, 'SETTLE', 'تسوية اليوم', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Settle', [
    'declare l json_object_t := json_object_t(); l_id number;',
    'begin',
    "  l.put('rep', to_number(:P4_REP)); l.put('date', :P4_DATE); l.put('counted', nvl(to_number(:P4_COUNTED), 0));",
    "  l.put('box', to_number(:P4_BOX)); l.put('notes', :P4_NOTES);",
    '  l_id := noona_dst_pkg.settle_day(l.to_clob);',
    '  :P4_COUNTED := null; :P4_NOTES := null;',
    'end;'], when_button=b, success='تمت تسوية اليوم وتسليم النقد')
p.branch(10, url(4) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 5) محل جديد (من الميدان)
p = app.page(5, 'New Shop', 'NEW-SHOP', 'محل جديد', scheme=DST, protection='N')
f = p.static('المحل', 10, text='<p class="nn-hint">من أمام المحل اضغط «موقعي» ليحفظ موقعه للتوزيع التالي. ينشأ حساب العميل تلقائياً.</p>'
                               '<button type="button" class="nn-dst-btn nn-dst-mygeo" data-lat="P5_LAT" data-lng="P5_LNG">'
                               '<span class="fa fa-crosshairs"></span> موقعي</button>')
p.text('P5_NAME', f, 10, 'اسم المحل', required=True, maxlen=200)
p.text('P5_OWNER', f, 20, 'صاحب المحل', maxlen=200)
p.text('P5_PHONE', f, 30, 'الجوال', maxlen=30, width=16)
p.text('P5_WA', f, 40, 'واتساب (إن اختلف)', maxlen=30, width=16)
p.select('P5_TYPE', f, 50, 'النوع', lov_sql=SHOP_TYPE, null_text=None)
p.select('P5_ROUTE', f, 60, 'خط السير', lov_sql=ROUTE_LOV)
p.number('P5_SEQ', f, 70, 'ترتيب الزيارة في الخط')
p.text('P5_LAT', f, 80, 'خط العرض', maxlen=20, width=14)
p.text('P5_LNG', f, 90, 'خط الطول', maxlen=20, width=14)
p.text('P5_ADDR', f, 100, 'العنوان', maxlen=500)
p.text('P5_LANDMARK', f, 110, 'علامة مميزة', maxlen=500)
p.text('P5_TAX', f, 120, 'الرقم الضريبي', maxlen=30, width=20)
p.text('P5_CR', f, 130, 'السجل التجاري', maxlen=30, width=20)
p.number('P5_LIMIT', f, 140, 'حد الائتمان (فارغ = نقدي فقط حسب سياسة الشركة)')
p.hidden('P5_ID', f, 1)
b = p.button(f, 10, 'SAVE', 'حفظ المحل', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  l.put('name', :P5_NAME); l.put('owner', :P5_OWNER); l.put('phone', :P5_PHONE); l.put('whatsapp', :P5_WA); l.put('type', :P5_TYPE);",
    "  l.put('route', to_number(:P5_ROUTE)); l.put('seq', to_number(:P5_SEQ)); l.put('lat', to_number(:P5_LAT)); l.put('lng', to_number(:P5_LNG));",
    "  l.put('address', :P5_ADDR); l.put('landmark', :P5_LANDMARK); l.put('tax', :P5_TAX); l.put('cr', :P5_CR); l.put('limit', to_number(:P5_LIMIT));",
    '  :P5_ID := noona_dst_pkg.save_shop(l.to_clob);',
    'end;'], when_button=b, success='تم حفظ المحل')
field_js(p)
p.branch(10, url(2, 'P2_SHOP', '&P5_ID.', clear='RP,2,5') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 6) مخزون السيارة
p = app.page(6, 'Van Stock', 'VAN-STOCK', 'مخزون السيارة', scheme=DST, protection='N')
f = p.static('المندوب', 5)
p.select('P6_REP', f, 10, 'المندوب', lov_sql=REP_LOV, submit=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', 'if :P6_REP is null then :P6_REP := noona_dst_pkg.my_rep; end if;')
p.dynamic('المخزون', 10, 'return noona_dst_pkg.van_stock_html(:P6_REP);', condition=':P6_REP is not null')

# =============================================================== 10-11) المندوبون
p = app.page(10, 'Reps', 'REPS', 'المندوبون', scheme=MGR)
r = p.static('مندوب جديد', 5)
p.button(r, 10, 'NEW', 'مندوب جديد', hot=True, redirect=url(11, clear='RP,11'))
p.ir('المندوبون', 10, [
    'select r.id, r.code, r.full_name, r.user_name, r.phone, r.vehicle_plate, w.name_ar van_wh, b.name_ar cash_box,',
    "       nvl(noona_wrk_pkg.employee_name(r.employee_id), '— غير مربوط —') emp, noona_wrk_pkg.method_label(r.earnings_method) paym,",
    '       noona_dst_pkg.label(r.commission_basis) basis, r.commission_rate, r.commission_per_visit, r.monthly_target,',
    "       (select count(*) from dst_route x where x.rep_id = r.id and x.status_code = 'ACTIVE') routes,",
    '       noona_dst_pkg.badge(r.status_code) status_html',
    '  from dst_rep r join inv_warehouse w on w.id = r.van_warehouse_id join csh_cash_box b on b.id = r.cash_box_id',
    f' where r.company_id = {CO} order by r.full_name'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('FULL_NAME', 'الاسم', {}), ('EMP', 'الموظف (الموارد البشرية)', {}), ('PAYM', 'صرف العمولة', {}), ('USER_NAME', 'المستخدم', {}),
     ('PHONE', 'الجوال', {}), ('VEHICLE_PLATE', 'اللوحة', {}), ('VAN_WH', 'مستودع السيارة', {}), ('CASH_BOX', 'العهدة', {}),
     ('BASIS', 'أساس العمولة', {}), ('COMMISSION_RATE', 'النسبة %', {'type': 'NUMBER'}), ('COMMISSION_PER_VISIT', 'للزيارة', {'type': 'NUMBER'}),
     ('MONTHLY_TARGET', 'الهدف الشهري', {'type': 'NUMBER'}), ('ROUTES', 'الخطوط', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link=link(11, 'P11_ID'))

p = app.page(11, 'Rep', 'REP', 'مندوب', scheme=MGR, protection='N')
f = p.static('المندوب', 10, text='<p class="nn-hint">إذا تركت مستودع السيارة والعهدة فارغين ينشئهما النظام (VAN-رمز، REP-رمز). '
                                 'اربط المندوب بمستخدم النظام ليفتح له تطبيق الهاتف خطته تلقائياً.</p>')
p.hidden('P11_ID', f, 1, protected=False)
p.select('P11_EMP', f, 5, 'الموظف من الموارد البشرية', lov_sql=EMP_LOV)
p.text('P11_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=12)
p.text('P11_NAME', f, 20, 'الاسم (فارغ = من ملف الموظف)', maxlen=200)
p.select('P11_USER', f, 30, 'مستخدم النظام', lov_sql=USER_LOV)
p.text('P11_PHONE', f, 40, 'الجوال', maxlen=30, width=16)
p.text('P11_PLATE', f, 50, 'لوحة السيارة', maxlen=30, width=14)
p.select('P11_WH', f, 60, 'مستودع السيارة (موجود)', lov_sql=(
    f"select name_ar || ' (' || code || ')' d, id r from inv_warehouse where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"),
    null_text='- إنشاء تلقائي -')
p.select('P11_BOX', f, 70, 'العهدة النقدية (موجودة)', lov_sql=(
    f"select name_ar || ' (' || code || ')' d, id r from csh_cash_box where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"),
    null_text='- إنشاء تلقائي -')
p.yesno('P11_CREDIT', f, 80, 'يبيع آجلاً ضمن حد المحل')
c = p.static('العمولة والهدف', 20)
p.select('P11_BASIS', c, 10, 'أساس العمولة', lov_sql=BASIS, null_text=None)
p.number('P11_RATE', c, 20, 'النسبة %')
p.number('P11_PERVISIT', c, 30, 'مبلغ لكل زيارة منفذة')
p.number('P11_TARGET', c, 40, 'الهدف الشهري للمبيعات')
p.select('P11_PAYM', c, 45, 'صرف العمولة', lov_sql=PAYM, null_text=None)
p.select('P11_STATUS', c, 50, 'الحالة', lov_sql='STATIC2:نشط;ACTIVE,موقوف;INACTIVE', null_text=None)
p.textarea('P11_NOTES', c, 60, 'ملاحظات', rows=2)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for r in (select * from dst_rep where id = :P11_ID and company_id = {CO}) loop',
    '    :P11_CODE := r.code; :P11_NAME := r.full_name; :P11_USER := r.user_name; :P11_PHONE := r.phone; :P11_PLATE := r.vehicle_plate;',
    '    :P11_WH := r.van_warehouse_id; :P11_BOX := r.cash_box_id; :P11_CREDIT := r.credit_allowed; :P11_BASIS := r.commission_basis;',
    '    :P11_RATE := r.commission_rate; :P11_PERVISIT := r.commission_per_visit; :P11_TARGET := r.monthly_target;',
    '    :P11_STATUS := r.status_code; :P11_NOTES := r.notes; :P11_EMP := r.employee_id; :P11_PAYM := r.earnings_method;',
    '  end loop;',
    "  if :P11_ID is null and :P11_CREDIT is null then :P11_CREDIT := 'Y'; end if;",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    '  if :P11_EMP is not null then',
    "    for e in (select * from json_table(noona_wrk_pkg.employee_json(to_number(:P11_EMP)), '$' columns (n varchar2(400) path '$.name', ph varchar2(40) path '$.phone'))) loop",
    '      :P11_NAME := nvl(:P11_NAME, e.n); :P11_PHONE := nvl(:P11_PHONE, e.ph);',
    '    end loop;',
    '  end if;',
    "  l.put('id', to_number(:P11_ID)); l.put('code', :P11_CODE); l.put('name', :P11_NAME); l.put('user', :P11_USER); l.put('phone', :P11_PHONE);",
    "  l.put('plate', :P11_PLATE); l.put('vanWarehouse', to_number(:P11_WH)); l.put('cashBox', to_number(:P11_BOX)); l.put('credit', :P11_CREDIT);",
    "  l.put('basis', :P11_BASIS); l.put('rate', to_number(:P11_RATE)); l.put('perVisit', to_number(:P11_PERVISIT));",
    "  l.put('target', to_number(:P11_TARGET)); l.put('status', :P11_STATUS); l.put('notes', :P11_NOTES);",
    '  :P11_ID := noona_dst_pkg.save_rep(l.to_clob);',
    "  noona_wrk_pkg.set_worker('REP', :P11_ID, to_number(:P11_EMP), nvl(:P11_PAYM, 'PAYROLL'));",
    'end;'], when_button=b, success='تم حفظ المندوب')
p.branch(10, url(11, 'P11_ID', '&P11_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 12-13) خطوط السير
p = app.page(12, 'Routes', 'ROUTES', 'خطوط السير', scheme=MGR)
r = p.static('خط جديد', 5)
p.button(r, 10, 'NEW', 'خط سير جديد', hot=True, redirect=url(13, clear='RP,13'))
p.ir('خطوط السير', 10, [
    "select r.id, r.code, r.name_ar, r.region_name, r.visit_days, nvl2(r.rep_id, noona_dst_pkg.rep_label(r.rep_id), '-') rep,",
    "       (select count(*) from dst_shop s where s.route_id = r.id and s.status_code = 'ACTIVE') shops,",
    "       (select count(*) from dst_shop s where s.route_id = r.id and s.latitude is not null) located,",
    '       noona_dst_pkg.badge(r.status_code) status_html',
    f'  from dst_route r where r.company_id = {CO} order by r.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الخط', {}), ('REGION_NAME', 'المنطقة', {}),
     ('VISIT_DAYS', 'أيام الزيارة', {}), ('REP', 'المندوب', {}), ('SHOPS', 'المحلات', {'type': 'NUMBER'}),
     ('LOCATED', 'بموقع', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(13, 'P13_ID'))

p = app.page(13, 'Route', 'ROUTE', 'خط سير', scheme=MGR, protection='N')
f = p.static('خط السير', 10, text=f'<p class="nn-hint">{DAYS_HINT}. المحل يرث أيام خطه ما لم تحدد له أياماً خاصة.</p>')
p.hidden('P13_ID', f, 1, protected=False)
p.text('P13_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=12)
p.text('P13_NAME', f, 20, 'الاسم', required=True, maxlen=200)
p.select('P13_REP', f, 30, 'المندوب', lov_sql=REP_LOV)
p.text('P13_REGION', f, 40, 'المنطقة', maxlen=100)
p.checkboxes('P13_DAYS', f, 50, 'أيام الزيارة', 'STATIC2:الأحد;SUN,الاثنين;MON,الثلاثاء;TUE,الأربعاء;WED,الخميس;THU,الجمعة;FRI,السبت;SAT',
             columns=7)
p.select('P13_STATUS', f, 60, 'الحالة', lov_sql='STATIC2:نشط;ACTIVE,موقوف;INACTIVE', null_text=None)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for r in (select * from dst_route where id = :P13_ID and company_id = {CO}) loop',
    "    :P13_CODE := r.code; :P13_NAME := r.name_ar; :P13_REP := r.rep_id; :P13_REGION := r.region_name;",
    "    :P13_DAYS := replace(r.visit_days, ',', ':'); :P13_STATUS := r.status_code;",
    '  end loop;',
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  l.put('id', to_number(:P13_ID)); l.put('code', :P13_CODE); l.put('name', :P13_NAME); l.put('rep', to_number(:P13_REP));",
    "  l.put('region', :P13_REGION); l.put('days', replace(:P13_DAYS, ':', ',')); l.put('status', :P13_STATUS);",
    '  :P13_ID := noona_dst_pkg.save_route(l.to_clob);',
    'end;'], when_button=b, success='تم حفظ خط السير')
p.dynamic('محلات الخط', 20, [
    'declare l_h clob;',
    'begin',
    "  for s in (select id, route_seq, noona_sal_pkg.customer_label(customer_account_id) nm, landmark, latitude from dst_shop",
    "             where route_id = :P13_ID order by route_seq nulls last, id) loop",
    "    l_h := l_h || '<tr><td>' || s.route_seq || '</td><td><a href=\"' || apex_page.get_url(p_page => 15, p_clear_cache => '15', p_items => 'P15_ID', p_values => s.id)",
    "        || '\">' || apex_escape.html(s.nm) || '</a></td><td>' || apex_escape.html(s.landmark) || '</td><td>'",
    "        || case when s.latitude is not null then '<span class=\"fa fa-map-marker\"></span>' else '-' end || '</td></tr>';",
    '  end loop;',
    "  return case when l_h is null then '<p class=\"nn-hint\">لا محلات في هذا الخط بعد.</p>'",
    "    else '<table class=\"nn-table\"><thead><tr><th>الترتيب</th><th>المحل</th><th>علامة</th><th>الموقع</th></tr></thead><tbody>' || l_h || '</tbody></table>' end;",
    'end;'], condition=':P13_ID is not null')
p.branch(10, url(13, 'P13_ID', '&P13_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 14-15) المحلات
p = app.page(14, 'Shops', 'SHOPS', 'المحلات', scheme=MGR)
r = p.static('محل جديد', 5)
p.button(r, 10, 'NEW', 'محل جديد', hot=True, redirect=url(15, clear='RP,15'))
p.button(r, 20, 'MAP', 'الخريطة', redirect=url(16))
p.ir('المحلات', 10, [
    'select s.id, noona_sal_pkg.customer_label(s.customer_account_id) shop, noona_dst_pkg.label(s.shop_type) shop_type, s.owner_name, s.phone,',
    "       r.name_ar route, s.route_seq, nvl(s.visit_days, r.visit_days) days, s.landmark,",
    "       case when s.latitude is not null then 'نعم' else 'لا' end located, s.last_visit_at, s.last_sale_at,",
    '       noona_sal_pkg.customer_balance(s.customer_account_id) balance, noona_sal_pkg.credit_limit(s.customer_account_id) credit_limit,',
    '       noona_dst_pkg.badge(s.status_code) status_html',
    '  from dst_shop s left join dst_route r on r.id = s.route_id',
    f' where s.company_id = {CO} order by r.code, s.route_seq nulls last, s.id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('SHOP', 'المحل', {}), ('SHOP_TYPE', 'النوع', {}), ('OWNER_NAME', 'صاحب المحل', {}),
     ('PHONE', 'الجوال', {}), ('ROUTE', 'خط السير', {}), ('ROUTE_SEQ', 'الترتيب', {'type': 'NUMBER'}), ('DAYS', 'أيام الزيارة', {}),
     ('LANDMARK', 'علامة', {}), ('LOCATED', 'بموقع', {}), ('LAST_VISIT_AT', 'آخر زيارة', {}), ('LAST_SALE_AT', 'آخر شراء', {}),
     ('BALANCE', 'الرصيد', {'type': 'NUMBER'}), ('CREDIT_LIMIT', 'حد الائتمان', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link=link(15, 'P15_ID'))

p = app.page(15, 'Shop', 'SHOP', 'محل', scheme=MGR, protection='N')
f = p.static('المحل', 10, text='<p class="nn-hint">اختر عميلاً موجوداً أو اترك الحقل فارغاً واكتب الاسم لإنشاء عميل جديد.</p>'
                               '<button type="button" class="nn-dst-btn nn-dst-mygeo" data-lat="P15_LAT" data-lng="P15_LNG">'
                               '<span class="fa fa-crosshairs"></span> موقعي الحالي</button>')
p.hidden('P15_ID', f, 1, protected=False)
p.select('P15_CUST', f, 5, 'العميل (موجود)', lov_sql=CUST_LOV, null_text='- عميل جديد -')
p.text('P15_NAME', f, 10, 'اسم المحل (للعميل الجديد)', maxlen=200)
p.text('P15_OWNER', f, 20, 'صاحب المحل', maxlen=200)
p.text('P15_PHONE', f, 30, 'الجوال', maxlen=30, width=16)
p.text('P15_WA', f, 40, 'واتساب', maxlen=30, width=16)
p.select('P15_TYPE', f, 50, 'النوع', lov_sql=SHOP_TYPE, null_text=None)
p.select('P15_ROUTE', f, 60, 'خط السير', lov_sql=ROUTE_LOV)
p.number('P15_SEQ', f, 70, 'ترتيب الزيارة')
p.checkboxes('P15_DAYS', f, 75, 'أيام خاصة (فارغ = أيام الخط)',
             'STATIC2:الأحد;SUN,الاثنين;MON,الثلاثاء;TUE,الأربعاء;WED,الخميس;THU,الجمعة;FRI,السبت;SAT', columns=7)
p.text('P15_LAT', f, 80, 'خط العرض', maxlen=20, width=14)
p.text('P15_LNG', f, 90, 'خط الطول', maxlen=20, width=14)
p.text('P15_ADDR', f, 100, 'العنوان', maxlen=500)
p.text('P15_LANDMARK', f, 110, 'علامة مميزة', maxlen=500)
p.number('P15_LIMIT', f, 120, 'حد الائتمان (للعميل الجديد)')
p.select('P15_STATUS', f, 130, 'الحالة', lov_sql='STATIC2:نشط;ACTIVE,موقوف;INACTIVE,محظور;BLOCKED', null_text=None)
p.textarea('P15_NOTES', f, 140, 'ملاحظات', rows=2)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for s in (select * from dst_shop where id = :P15_ID and company_id = {CO}) loop',
    '    :P15_CUST := s.customer_account_id; :P15_OWNER := s.owner_name; :P15_PHONE := s.phone; :P15_WA := s.whatsapp; :P15_TYPE := s.shop_type;',
    "    :P15_ROUTE := s.route_id; :P15_SEQ := s.route_seq; :P15_DAYS := replace(s.visit_days, ',', ':');",
    "    :P15_LAT := to_char(s.latitude, 'FM990.0000000'); :P15_LNG := to_char(s.longitude, 'FM990.0000000');",
    '    :P15_ADDR := s.address_text; :P15_LANDMARK := s.landmark; :P15_STATUS := s.status_code; :P15_NOTES := s.notes;',
    '  end loop;',
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  l.put('id', to_number(:P15_ID)); l.put('customer', to_number(:P15_CUST)); l.put('name', :P15_NAME); l.put('owner', :P15_OWNER);",
    "  l.put('phone', :P15_PHONE); l.put('whatsapp', :P15_WA); l.put('type', :P15_TYPE); l.put('route', to_number(:P15_ROUTE));",
    "  l.put('seq', to_number(:P15_SEQ)); l.put('days', replace(:P15_DAYS, ':', ',')); l.put('lat', to_number(:P15_LAT));",
    "  l.put('lng', to_number(:P15_LNG)); l.put('address', :P15_ADDR); l.put('landmark', :P15_LANDMARK); l.put('limit', to_number(:P15_LIMIT));",
    "  l.put('status', :P15_STATUS); l.put('notes', :P15_NOTES);",
    '  :P15_ID := noona_dst_pkg.save_shop(l.to_clob);',
    'end;'], when_button=b, success='تم حفظ المحل')
p.dynamic('بطاقة المحل', 20, 'return noona_dst_pkg.shop_card_html(:P15_ID);', condition=':P15_ID is not null')
field_js(p)
p.branch(10, url(15, 'P15_ID', '&P15_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 16) خريطة المحلات
p = app.page(16, 'Shops Map', 'MAP', 'خريطة المحلات', scheme=MGR, protection='N')
f = p.static('المرشحات', 5)
p.select('P16_ROUTE', f, 10, 'خط السير', lov_sql=ROUTE_LOV, null_text='- كل الخطوط -', submit=True)
p.dynamic('الخريطة', 10, [
    "return '<div id=\"dstMap\" class=\"nn-dst-map\" data-geo=\"' || apex_escape.html_attribute(noona_dst_pkg.shops_geo_json(to_number(:P16_ROUTE))) || '\"'",
    "    || ' data-url=\"' || apex_page.get_url(p_page => 15, p_clear_cache => '15', p_items => 'P15_ID', p_values => 'XSHOPX') || '\"></div>'",
    "    || '<p class=\"nn-hint\">الأخضر: اشترى خلال 14 يوماً، البرتقالي: راكد. المحلات بلا موقع لا تظهر حتى تُزار أول مرة أو يحدد موقعها.</p>';"])
p.onload([
    "(function () {",
    "  function css(h) { var l = document.createElement('link'); l.rel = 'stylesheet'; l.href = h; document.head.appendChild(l); }",
    "  css('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');",
    "  var s = document.createElement('script'); s.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';",
    "  function fallback(el, pts) {",
    "    el.classList.remove('nn-dst-map'); el.innerHTML = '<p class=\"nn-hint\">تعذر تحميل الخريطة؛ مواقع المحلات على خرائط Google:</p>';",
    "    pts.forEach(function (p) { var a = document.createElement('a'); a.className = 'nn-dst-btn'; a.target = '_blank'; a.rel = 'noopener';",
    "      a.href = 'https://www.google.com/maps?q=' + p.lat + ',' + p.lng; a.textContent = p.n; el.appendChild(a); });",
    "  }",
    "  s.onerror = function () { var el = document.getElementById('dstMap'); if (el) fallback(el, JSON.parse(el.getAttribute('data-geo') || '[]')); };",
    "  s.onload = function () {",
    "    var el = document.getElementById('dstMap'); if (!el) return;",
    "    if (!window.L) { fallback(el, JSON.parse(el.getAttribute('data-geo') || '[]')); return; }",
    "    var pts = JSON.parse(el.getAttribute('data-geo') || '[]'), u = el.getAttribute('data-url');",
    "    var m = L.map(el).setView(pts.length ? [pts[0].lat, pts[0].lng] : [24.7136, 46.6753], pts.length ? 12 : 6);",
    "    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '&copy; OpenStreetMap' }).addTo(m);",
    "    var b = [];",
    "    pts.forEach(function (p) {",
    "      var c = L.circleMarker([p.lat, p.lng], { radius: 9, weight: 2, color: '#fff', fillOpacity: .9, fillColor: p.s === 'A' ? '#16a34a' : '#f59e0b' }).addTo(m);",
    "      var a = document.createElement('a'); a.href = u.replace('XSHOPX', p.id); a.textContent = p.n;",
    "      var d = document.createElement('div'); d.appendChild(a); if (p.r) { var r = document.createElement('div'); r.textContent = p.r; d.appendChild(r); }",
    "      c.bindPopup(d); b.push([p.lat, p.lng]);",
    "    });",
    "    if (b.length > 1) m.fitBounds(b, { padding: [30, 30] });",
    "  };",
    "  document.head.appendChild(s);",
    "})();"])

# =============================================================== 20-21) الزيارات
p = app.page(20, 'Visits', 'VISITS', 'الزيارات', scheme=MGR)
p.ir('الزيارات', 10, [
    'select v.id, v.doc_no, v.doc_date, noona_dst_pkg.rep_label(v.rep_id) rep, noona_dst_pkg.shop_label(v.shop_id) shop,',
    "       to_char(v.checkin_at, 'HH24:MI') checkin, to_char(v.checkout_at, 'HH24:MI') checkout,",
    '       round((cast(v.checkout_at as date) - cast(v.checkin_at as date)) * 1440) minutes, round(v.distance_m) distance_m,',
    '       noona_dst_pkg.label(v.outcome) outcome, noona_dst_pkg.label(v.no_sale_reason) reason, v.sales_amount, v.collected_amount, v.returns_amount,',
    '       noona_dst_pkg.badge(v.status_code) status_html',
    f'  from dst_visit v where v.company_id = {CO} order by v.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'اليوم', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REP', 'المندوب', {}), ('SHOP', 'المحل', {}), ('CHECKIN', 'الوصول', {}), ('CHECKOUT', 'المغادرة', {}), ('MINUTES', 'المدة (د)', {'type': 'NUMBER'}),
     ('DISTANCE_M', 'البعد عن المحل (م)', {'type': 'NUMBER'}), ('OUTCOME', 'النتيجة', {}), ('REASON', 'سبب عدم الشراء', {}),
     ('SALES_AMOUNT', 'المبيعات', {'type': 'NUMBER'}), ('COLLECTED_AMOUNT', 'المحصل', {'type': 'NUMBER'}),
     ('RETURNS_AMOUNT', 'المرتجعات', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(21, 'P21_ID'))

p = app.page(21, 'Visit View', 'VISIT-VIEW', 'زيارة', scheme=MGR, protection='N')
f = p.static('الزيارة', 5, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P21_ID', f, 1, protected=False)
p.dynamic('الزيارة', 10, 'return noona_dst_pkg.visit_html(:P21_ID);')
p.dynamic('واتساب', 20, 'return noona_dst_pkg.visit_actions_html(:P21_ID);')

# =============================================================== 22-23) التحصيلات وتأكيد التحويلات والشيكات
p = app.page(22, 'Collections', 'COLLECTIONS', 'التحصيلات', scheme=MGR)
p.ir('التحصيلات', 10, [
    'select c.id, c.doc_no, c.doc_date, noona_dst_pkg.rep_label(c.rep_id) rep, noona_dst_pkg.shop_label(c.shop_id) shop,',
    '       noona_dst_pkg.label(c.payment_method) method, c.amount, c.reference_no, c.bank_name, c.cheque_due_date,',
    '       (select i.doc_no from sal_invoice i where i.id = c.sales_invoice_id) invoice, c.verified_by, c.verified_at,',
    "       noona_dst_pkg.badge(c.status_code) status_html, decode(c.status_code, 'PENDING_VERIFY', 0, 1) ord",
    f'  from dst_collection c where c.company_id = {CO} order by ord, c.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'اليوم', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REP', 'المندوب', {}), ('SHOP', 'المحل', {}), ('METHOD', 'الطريقة', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
     ('REFERENCE_NO', 'رقم المرجع', {}), ('BANK_NAME', 'البنك', {}), ('CHEQUE_DUE_DATE', 'استحقاق الشيك', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('INVOICE', 'الفاتورة', {}), ('VERIFIED_BY', 'أكده', {}), ('VERIFIED_AT', 'وقت التأكيد', {}), ('STATUS_HTML', 'الحالة', {'html': True}),
     ('ORD', 'ord', {'hidden': True, 'type': 'NUMBER'})], link=link(23, 'P23_ID'))

p = app.page(23, 'Collection', 'COLLECTION', 'تحصيل', scheme=MGR, protection='N')
f = p.static('التحصيل', 10)
p.hidden('P23_ID', f, 1, protected=False)
p.dynamic('البيانات', 5, [
    'declare l_h varchar2(32767);',
    'begin',
    f'  for c in (select * from dst_collection where id = :P23_ID and company_id = {CO}) loop',
    "    l_h := '<table class=\"nn-table\"><tbody>'",
    "      || '<tr><th>الرقم</th><td>' || c.doc_no || ' · ' || noona_dst_pkg.badge(c.status_code) || '</td></tr>'",
    "      || '<tr><th>المندوب</th><td>' || apex_escape.html(noona_dst_pkg.rep_label(c.rep_id)) || '</td></tr>'",
    "      || '<tr><th>المحل</th><td>' || apex_escape.html(noona_dst_pkg.shop_label(c.shop_id)) || '</td></tr>'",
    "      || '<tr><th>الطريقة</th><td>' || noona_dst_pkg.label(c.payment_method) || '</td></tr>'",
    "      || '<tr><th>المبلغ</th><td><b>' || to_char(c.amount, 'FM999G999G990D00') || '</b></td></tr>'",
    "      || '<tr><th>رقم المرجع</th><td><b>' || apex_escape.html(c.reference_no) || '</b></td></tr>'",
    "      || '<tr><th>البنك</th><td>' || apex_escape.html(c.bank_name) || '</td></tr>'",
    "      || '<tr><th>استحقاق الشيك</th><td>' || to_char(c.cheque_due_date, 'YYYY-MM-DD') || '</td></tr>'",
    "      || '<tr><th>ملاحظات</th><td>' || apex_escape.html(c.notes) || '</td></tr></tbody></table>';",
    '  end loop;',
    '  return l_h;',
    'end;'])
PEND = "noona_dst_pkg.collection_status(:P23_ID) = 'PENDING_VERIFY'"
v = p.static('التأكيد', 20, condition=PEND,
             text='<p class="nn-hint">طابق رقم الإشعار أو الشيك مع كشف البنك ثم أكد: يرحل سند القبض على حساب البنك ويخصم من رصيد المحل. '
                  'الرفض يبقي الرصيد على المحل.</p>')
p.select('P23_BANK', v, 10, 'حساب البنك المستلم', lov_sql=BANK_LOV, null_text='- الحساب الافتراضي -')
p.text('P23_REASON', v, 20, 'سبب الرفض', maxlen=500, width=40)
b_ok = p.button(v, 10, 'VERIFY', 'تأكيد وترحيل', hot=True)
b_no = p.button(v, 20, 'REJECT', 'رفض')
p.process(10, 'AFTER_SUBMIT', 'Verify', 'noona_dst_pkg.verify_collection(:P23_ID, to_number(:P23_BANK));', when_button=b_ok,
          success='تم تأكيد التحصيل وترحيله')
p.process(20, 'AFTER_SUBMIT', 'Reject', 'noona_dst_pkg.reject_collection(:P23_ID, :P23_REASON);', when_button=b_no, success='تم رفض التحصيل')
p.branch(10, url(22) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 24-25) أوامر التوريد
p = app.page(24, 'Orders', 'ORDERS', 'أوامر التوريد', scheme=MGR)
p.ir('أوامر التوريد', 10, [
    'select o.id, o.doc_no, o.doc_date, noona_dst_pkg.rep_label(o.rep_id) rep, noona_dst_pkg.shop_label(o.shop_id) shop, o.delivery_date,',
    '       o.total_amount, (select count(*) from dst_order_line l where l.order_id = o.id) lines,',
    '       (select i.doc_no from sal_invoice i where i.id = o.sales_invoice_id) invoice, noona_dst_pkg.badge(o.status_code) status_html',
    f'  from dst_order o where o.company_id = {CO} order by decode(o.status_code, \'SUBMITTED\', 0, 1), o.delivery_date, o.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REP', 'المندوب', {}), ('SHOP', 'المحل', {}), ('DELIVERY_DATE', 'التسليم المطلوب', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}), ('LINES', 'الأسطر', {'type': 'NUMBER'}), ('INVOICE', 'الفاتورة', {}),
     ('STATUS_HTML', 'الحالة', {'html': True})], link=link(25, 'P25_ID'))

p = app.page(25, 'Order', 'ORDER', 'أمر توريد', scheme=MGR, protection='N')
f = p.static('الأمر', 5, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P25_ID', f, 1, protected=False)
p.dynamic('الأمر', 10, [
    'declare l_h clob;',
    'begin',
    f'  for o in (select * from dst_order where id = :P25_ID and company_id = {CO}) loop',
    "    l_h := '<p><b>' || o.doc_no || '</b> · ' || noona_dst_pkg.badge(o.status_code) || ' · ' || apex_escape.html(noona_dst_pkg.shop_label(o.shop_id))",
    "        || ' · التسليم ' || to_char(o.delivery_date, 'YYYY-MM-DD') || ' · المندوب ' || apex_escape.html(noona_dst_pkg.rep_label(o.rep_id)) || '</p>'",
    "        || '<table class=\"nn-table\"><thead><tr><th>الصنف</th><th>الكمية</th><th>السعر</th><th>المبلغ</th></tr></thead><tbody>';",
    '    for l in (select l.*, i.name_ar from dst_order_line l join inv_item i on i.id = l.item_id where l.order_id = o.id order by l.id) loop',
    "      l_h := l_h || '<tr><td>' || apex_escape.html(l.name_ar) || '</td><td>' || l.quantity || '</td><td>' || to_char(l.unit_price, 'FM999G999G990D00')",
    "          || '</td><td>' || to_char(l.amount, 'FM999G999G990D00') || '</td></tr>';",
    '    end loop;',
    "    l_h := l_h || '</tbody></table><p>الإجمالي: <b>' || to_char(o.total_amount, 'FM999G999G990D00') || '</b></p>';",
    '  end loop;',
    '  return l_h;',
    'end;'])
SUB = "noona_dst_pkg.order_status(:P25_ID) in ('SUBMITTED', 'APPROVED')"
d = p.static('التسليم', 20, condition=SUB, text='<p class="nn-hint">يصدر فاتورة آجلة على المحل ويصرف من المستودع المختار.</p>')
p.select('P25_WH', d, 10, 'مستودع التسليم', lov_sql=(
    f"select name_ar || ' (' || code || ')' d, id r from inv_warehouse where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"),
    null_text='- المستودع الافتراضي -')
p.text('P25_REASON', d, 20, 'سبب الإلغاء', maxlen=500, width=40)
b_dl = p.button(d, 10, 'DELIVER', 'تسليم وإصدار الفاتورة', hot=True)
b_cn = p.button(d, 20, 'CANCEL_ORDER', 'إلغاء الأمر')
p.process(10, 'AFTER_SUBMIT', 'Deliver', ['declare l number;', 'begin', '  l := noona_dst_pkg.deliver_order(:P25_ID, to_number(:P25_WH));', 'end;'],
          when_button=b_dl, success='تم التسليم وإصدار الفاتورة')
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_dst_pkg.cancel_order(:P25_ID, :P25_REASON);', when_button=b_cn, success='تم إلغاء الأمر')
p.branch(10, url(25, 'P25_ID', '&P25_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 26-27) التسويات
p = app.page(26, 'Settlements', 'SETTLEMENTS', 'تسويات نهاية اليوم', scheme=MGR)
p.ir('التسويات', 10, [
    'select s.id, s.doc_no, s.settle_date, noona_dst_pkg.rep_label(s.rep_id) rep, s.visits_planned, s.visits_done, s.sales_amount, s.credit_sales,',
    '       s.returns_amount, s.cash_expected, s.cash_counted, s.cash_diff, s.transfers_amount, s.cheques_amount, s.cards_amount,',
    '       s.approved_by, noona_dst_pkg.badge(s.status_code) status_html',
    f'  from dst_settlement s where s.company_id = {CO} order by s.settle_date desc, s.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('SETTLE_DATE', 'اليوم', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REP', 'المندوب', {}), ('VISITS_PLANNED', 'المخطط', {'type': 'NUMBER'}), ('VISITS_DONE', 'المنفذ', {'type': 'NUMBER'}),
     ('SALES_AMOUNT', 'المبيعات', {'type': 'NUMBER'}), ('CREDIT_SALES', 'منها آجل', {'type': 'NUMBER'}), ('RETURNS_AMOUNT', 'المرتجعات', {'type': 'NUMBER'}),
     ('CASH_EXPECTED', 'النقد المتوقع', {'type': 'NUMBER'}), ('CASH_COUNTED', 'المسلم', {'type': 'NUMBER'}), ('CASH_DIFF', 'العجز/الزيادة', {'type': 'NUMBER'}),
     ('TRANSFERS_AMOUNT', 'التحويلات', {'type': 'NUMBER'}), ('CHEQUES_AMOUNT', 'الشيكات', {'type': 'NUMBER'}), ('CARDS_AMOUNT', 'الشبكة', {'type': 'NUMBER'}),
     ('APPROVED_BY', 'المعتمد', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(27, 'P27_ID'))

p = app.page(27, 'Settlement', 'SETTLEMENT', 'تسوية', scheme=MGR, protection='N')
f = p.static('التسوية', 5, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P27_ID', f, 1, protected=False)
p.dynamic('اليوم', 10, [
    'begin',
    f'  for s in (select rep_id, settle_date from dst_settlement where id = :P27_ID and company_id = {CO}) loop',
    '    return noona_dst_pkg.rep_day_html(s.rep_id, s.settle_date);',
    '  end loop;',
    '  return null;',
    'end;'])
a = p.static('الاعتماد', 20, condition="noona_dst_pkg.settlement_status(:P27_ID) = 'SUBMITTED'")
b = p.button(a, 10, 'APPROVE', 'اعتماد التسوية', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Approve', 'noona_dst_pkg.approve_settlement(:P27_ID);', when_button=b, success='تم اعتماد التسوية')
p.branch(10, url(27, 'P27_ID', '&P27_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 28) حركات السيارات
p = app.page(28, 'Van Loads', 'LOADS', 'حركات تحميل وتفريغ السيارات', scheme=MGR)
p.ir('الحركات', 10, [
    'select l.id, l.doc_no, l.doc_date, noona_dst_pkg.rep_label(l.rep_id) rep, noona_dst_pkg.label(l.direction) direction,',
    '       f.name_ar from_wh, t.name_ar to_wh, l.items_count, l.total_qty, l.created_by, noona_dst_pkg.badge(l.status_code) status_html',
    '  from dst_load l join inv_warehouse f on f.id = l.from_warehouse_id join inv_warehouse t on t.id = l.to_warehouse_id',
    f' where l.company_id = {CO} order by l.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REP', 'المندوب', {}), ('DIRECTION', 'الاتجاه', {}), ('FROM_WH', 'من', {}), ('TO_WH', 'إلى', {}), ('ITEMS_COUNT', 'الأصناف', {'type': 'NUMBER'}),
     ('TOTAL_QTY', 'الكمية', {'type': 'NUMBER'}), ('CREATED_BY', 'بواسطة', {}), ('STATUS_HTML', 'الحالة', {'html': True})])

# =============================================================== 30-32) الأداء والراكدة والعمولات
p = app.page(30, 'Performance', 'PERFORMANCE', 'أداء المندوبين', scheme=MGR, protection='N')
f = p.static('الفترة', 5)
p.date('P30_FROM', f, 10, 'من')
p.date('P30_TO', f, 20, 'إلى')
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "  if :P30_FROM is null then :P30_FROM := to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'); end if;",
    "  if :P30_TO is null then :P30_TO := to_char(sysdate, 'YYYY-MM-DD'); end if;",
    'end;'])
p.dynamic('الأداء', 10, "return noona_dst_pkg.performance_html(to_date(:P30_FROM, 'YYYY-MM-DD'), to_date(:P30_TO, 'YYYY-MM-DD'));")

p = app.page(31, 'Idle Shops', 'IDLE-SHOPS', 'المحلات الراكدة', scheme=MGR, protection='N')
f = p.static('المرشح', 5)
p.number('P31_DAYS', f, 10, 'لم تشترِ منذ (يوم)')
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', 'if :P31_DAYS is null then :P31_DAYS := 14; end if;')
p.dynamic('المحلات', 10, 'return noona_dst_pkg.idle_shops_html(to_number(:P31_DAYS));')

p = app.page(32, 'Commissions', 'COMMISSIONS', 'عمولات المندوبين', scheme=MGR, protection='N')
f = p.static('الحساب', 5, text='<p class="nn-hint">تحسب العمولة لكل مندوب حسب أساسه (نسبة من المبيعات الصافية أو من التحصيل أو مبلغ لكل '
                               'زيارة منفذة) مع نسبة إنجاز الهدف. إعادة الحساب تحدث الشهر نفسه.</p>')
p.date('P32_MONTH', f, 10, 'أي يوم من الشهر')
b = p.button(f, 10, 'CALC', 'حساب العمولات', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', "if :P32_MONTH is null then :P32_MONTH := to_char(sysdate, 'YYYY-MM-DD'); end if;")
p.process(10, 'AFTER_SUBMIT', 'Calc', ['declare l number;', 'begin',
                                       "  l := noona_dst_pkg.calc_commissions(to_date(:P32_MONTH, 'YYYY-MM-DD'));", 'end;'],
          when_button=b, success='تم حساب العمولات')
p.ir('العمولات', 10, [
    "select c.id, to_char(c.period_start, 'YYYY-MM') month, noona_dst_pkg.rep_label(c.rep_id) rep, noona_dst_pkg.label(c.basis) basis,",
    '       c.base_amount, c.visits_count, c.target_amount, c.achievement_pct, c.commission_amount, noona_dst_pkg.badge(c.status_code) status_html',
    f'  from dst_commission c where c.company_id = {CO} order by c.period_start desc, c.commission_amount desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('MONTH', 'الشهر', {}), ('REP', 'المندوب', {}), ('BASIS', 'الأساس', {}),
     ('BASE_AMOUNT', 'المبلغ الأساس', {'type': 'NUMBER'}), ('VISITS_COUNT', 'الزيارات', {'type': 'NUMBER'}),
     ('TARGET_AMOUNT', 'الهدف', {'type': 'NUMBER'}), ('ACHIEVEMENT_PCT', 'الإنجاز %', {'type': 'NUMBER'}),
     ('COMMISSION_AMOUNT', 'العمولة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})])
p.branch(10, url(32) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== القائمة
app.nav_item('خطة اليوم', 1, 'fa-map-signs', 10)
fld = app.nav_item('الميدان', None, 'fa-mobile', 20)
app.nav_item('تحميل وتفريغ السيارة', 3, 'fa-truck', 21, parent=fld)
app.nav_item('مخزون السيارة', 6, 'fa-cubes', 22, parent=fld)
app.nav_item('محل جديد', 5, 'fa-plus-circle', 23, parent=fld)
app.nav_item('تسوية نهاية اليوم', 4, 'fa-calculator', 24, parent=fld)
op = app.nav_item('المتابعة', None, 'fa-tasks', 30, scheme=MGR)
app.nav_item('الزيارات', 20, 'fa-map-marker', 31, parent=op, scheme=MGR)
app.nav_item('التحصيلات والتأكيد', 22, 'fa-check-square-o', 32, parent=op, scheme=MGR)
app.nav_item('أوامر التوريد', 24, 'fa-list-alt', 33, parent=op, scheme=MGR)
app.nav_item('التسويات', 26, 'fa-balance-scale', 34, parent=op, scheme=MGR)
app.nav_item('حركات السيارات', 28, 'fa-exchange', 35, parent=op, scheme=MGR)
st = app.nav_item('الإعداد', None, 'fa-cogs', 40, scheme=MGR)
app.nav_item('المندوبون', 10, 'fa-id-badge', 41, parent=st, scheme=MGR)
app.nav_item('خطوط السير', 12, 'fa-road', 42, parent=st, scheme=MGR)
app.nav_item('المحلات', 14, 'fa-shopping-basket', 43, parent=st, scheme=MGR)
app.nav_item('خريطة المحلات', 16, 'fa-map', 44, parent=st, scheme=MGR)
rp = app.nav_item('التقارير', None, 'fa-bar-chart', 50, scheme=MGR)
app.nav_item('أداء المندوبين', 30, 'fa-line-chart', 51, parent=rp, scheme=MGR)
app.nav_item('المحلات الراكدة', 31, 'fa-hourglass-half', 52, parent=rp, scheme=MGR)
app.nav_item('العمولات', 32, 'fa-percent', 53, parent=rp, scheme=MGR)

app.finalize()
# تطبيق قابل للتثبيت على شاشة الهاتف (PWA)
_ca = os.path.join(app.dir, 'application', 'create_application.sql')
if os.path.exists(_ca):
    _s = open(_ca, encoding='utf-8').read().replace(",p_pwa_is_installable=>'N'", ",p_pwa_is_installable=>'Y'")
    open(_ca, 'w', encoding='utf-8').write(_s)
print('NOONA_DST built:', len(app.pages), 'pages')
