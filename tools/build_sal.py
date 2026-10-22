"""NOONA_POS (المبيعات ونقاط البيع): العملاء والعميل النقدي العام، فواتير المبيعات (آجل/نقدي) ومرتجعاتها، التحصيل،
شاشة نقطة البيع السريعة (pos.js) والورديات وإقفالها، طباعة الإيصال الحراري برمز ZATCA، ومركز تقارير بمرشحات موحدة.
الاستخدام: python3 tools/build_sal.py  ->  apex/NOONA_POS/f133
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand
from trade_doc import TD_JS, POS_JS, QR_JS, trade_region, save_ajax, clob_ajax, FIND_ITEMS

if ('qrcode.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('qrcode.js', 'application/javascript'))
ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_POS/f133'),
          app_id=133, alias='NOONA_POS', name='NOONA Sales & POS', id_base=91820269000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


CUST_LOV = ("select c.customer_no || ' - ' || p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id "
            "join pty_party p on p.id = c.party_id where a.company_id = noona_sal_pkg.company order by c.is_walk_in desc, p.display_name_ar")
WH_LOV = "select code || ' - ' || name_ar d, id r from inv_warehouse where company_id = noona_inv_pkg.company and status_code = 'ACTIVE' order by code"
CAT_LOV = "select name_ar d, id r from inv_item_category where is_active = 'Y' order by name_ar"
CC_LOV = "select code || ' - ' || name_ar d, id r from gl_cost_center where company_id = noona_gl_pkg.company order by code"
TERM_LOV = "select name_ar d, code r from ref_payment_term where is_active = 'Y' order by due_days"
PLACE_LOV = ("select d, r from (select 'صندوق: ' || name_ar d, 'BOX:' || id r, 1 o from csh_cash_box where company_id = noona_gl_pkg.company "
             "and status_code = 'ACTIVE' union all select 'بنك: ' || name_ar || ' ' || account_no_masked, 'BANK:' || id, 2 from csh_bank_account "
             "where company_id = noona_gl_pkg.company and status_code = 'ACTIVE') order by o, d")
METHOD_LOV = "select name_ar d, code r from ref_payment_method where is_active = 'Y' and method_type <> 'CREDIT' order by sort_order"
TERM_POS_LOV = "select code || ' - ' || name_ar d, id r from pos_terminal where company_id = noona_pos_pkg.company and status_code = 'ACTIVE' order by code"
READY = "noona_pos_pkg.is_ready = 'Y'"

# =============================================================== 1) لوحة المبيعات
p = app.page(1, 'Home', 'HOME', 'المبيعات ونقاط البيع', scheme=TENANT)
st = p.static('تجهيز المبيعات ونقاط البيع', 5, condition="noona_pos_pkg.is_ready = 'N'")
b = p.button(st, 10, 'SETUP', 'تجهيز المبيعات (العميل النقدي العام، طرق السداد، نقطة بيع ودرج نقدي، الترقيم)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_pos_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم التجهيز: العميل النقدي العام، طرق السداد (نقدي، مدى، بطاقات، Apple Pay، STC Pay، تطبيقات بنكية، آجل)، '
                  'نقطة بيع افتراضية بدرج نقدي، وترقيم الفواتير والإيصالات')
p.dynamic('نقاط البيع', 10, 'return noona_pos_pkg.pos_summary;', hide_header=True, condition=READY)
p.dynamic('المبيعات', 12, 'return noona_sal_pkg.sal_summary;', hide_header=True, condition=READY)
qa = p.static('إجراءات سريعة', 15, condition=READY)
p.button(qa, 10, 'POS', 'فتح نقطة البيع', hot=True, redirect=url(30))
p.button(qa, 20, 'NEW_SI', 'فاتورة مبيعات', redirect=url(21, clear='RP,21'))
p.button(qa, 30, 'RECEIVE', 'تحصيل من عميل', redirect=url(24, clear='RP,24'))
p.button(qa, 40, 'NEW_CUST', 'عميل جديد', redirect=url(11, clear='RP,11'))
p.button(qa, 50, 'CLOSE_SHIFT', 'إقفال وردية', redirect=url(32))
p.button(qa, 60, 'REPORTS', 'التقارير', redirect=url(50))
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10/11) العملاء
p = app.page(10, 'Customers', 'CUSTOMERS', 'العملاء', scheme=TENANT)
r = p.ir('العملاء', 10, [
    "select a.id, c.customer_no, p.display_name_ar as name_ar, case c.is_walk_in when 'Y' then 'عميل عام' else 'مسجل' end as kind, p.tax_number,",
    "       (select max(mobile) from ref_contact where party_id = p.id and is_primary = 'Y') as phone,",
    "       (select name_ar from ref_payment_term where id = a.payment_term_id) as term, noona_sal_pkg.credit_limit(a.id) as credit_limit,",
    '       noona_sal_pkg.customer_balance(a.id) as balance,',
    "       (select nvl(sum(open_amount), 0) from ar_open_item o where o.customer_account_id = a.id and o.item_type = 'INVOICE'",
    '           and o.due_date < trunc(sysdate)) as overdue, noona_ui_pkg.status_badge(a.status_code) as status_html',
    '  from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party p on p.id = c.party_id',
    ' where a.company_id = noona_sal_pkg.company'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CUSTOMER_NO', 'رقم العميل', {}), ('NAME_AR', 'العميل', {}), ('KIND', 'النوع', {}),
     ('TAX_NUMBER', 'الرقم الضريبي', {}), ('PHONE', 'الجوال', {}), ('TERM', 'شروط الدفع', {}), ('CREDIT_LIMIT', 'حد الائتمان', {'type': 'NUMBER'}),
     ('BALANCE', 'الرصيد', {'type': 'NUMBER'}), ('OVERDUE', 'المتأخر', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link=link(11, 'P11_ID'))
p.button(r, 10, 'NEW', 'عميل جديد', hot=True, redirect=url(11, clear='RP,11'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(11, 'Customer', 'CUSTOMER', 'بيانات العميل', scheme=TENANT)
f = p.static('بيانات العميل', 10)
p.hidden('P11_ID', f, 1)
p.text('P11_NAME', f, 10, 'اسم العميل', required=True)
p.text('P11_NAME_EN', f, 20, 'الاسم بالإنجليزية')
p.select('P11_PERSON', f, 30, 'نوع العميل', null_text=None, lov_sql='STATIC2:فرد;Y,منشأة;N')
p.text('P11_TAX', f, 40, 'الرقم الضريبي (للفاتورة الضريبية)', maxlen=15, width=20)
p.text('P11_CR', f, 50, 'السجل التجاري', maxlen=20, width=20)
p.text('P11_PHONE', f, 60, 'الجوال', maxlen=20, width=20)
p.text('P11_EMAIL', f, 70, 'البريد الإلكتروني')
p.text('P11_ADDRESS', f, 80, 'العنوان')
p.select('P11_TERM', f, 90, 'شروط الدفع', null_text=None, lov_sql=TERM_LOV)
p.number('P11_LIMIT', f, 100, 'حد الائتمان (فارغ = بلا حد)')
p.select('P11_STATUS', f, 110, 'الحالة', null_text=None, lov_sql='STATIC2:نشط;ACTIVE,موقوف مؤقتاً;ON_HOLD,محظور;BLOCKED')
p.process(10, 'BEFORE_HEADER', 'Load', [
    'declare l clob;',
    'begin',
    '    if :P11_ID is not null and :P11_NAME is null then',
    '        l := noona_sal_pkg.customer_json(:P11_ID);',
    "        :P11_NAME := json_value(l, '$.name'); :P11_NAME_EN := json_value(l, '$.nameEn'); :P11_PERSON := json_value(l, '$.person');",
    "        :P11_TAX := json_value(l, '$.tax'); :P11_CR := json_value(l, '$.cr'); :P11_PHONE := json_value(l, '$.phone');",
    "        :P11_EMAIL := json_value(l, '$.email'); :P11_ADDRESS := json_value(l, '$.address'); :P11_TERM := json_value(l, '$.term');",
    "        :P11_LIMIT := json_value(l, '$.limit'); :P11_STATUS := json_value(l, '$.status');",
    '    end if;',
    "    :P11_TERM := nvl(:P11_TERM, 'NET30'); :P11_STATUS := nvl(:P11_STATUS, 'ACTIVE'); :P11_PERSON := nvl(:P11_PERSON, 'Y');",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.button(f, 20, 'BACK', 'رجوع', redirect=url(10))
p.process(20, 'AFTER_SUBMIT', 'Save', [
    ':P11_ID := noona_sal_pkg.save_customer(json_object(',
    "    'id' value to_number(:P11_ID), 'name' value :P11_NAME, 'nameEn' value :P11_NAME_EN, 'person' value :P11_PERSON, 'tax' value :P11_TAX,",
    "    'cr' value :P11_CR, 'phone' value :P11_PHONE, 'email' value :P11_EMAIL, 'address' value :P11_ADDRESS, 'term' value :P11_TERM,",
    "    'limit' value to_number(:P11_LIMIT), 'status' value :P11_STATUS));"], when_button=b, success='تم حفظ العميل')
p.ir('الذمم المفتوحة', 30, [
    "select o.source_entity_type, o.source_entity_id, o.doc_no, to_char(o.due_date, 'YYYY-MM-DD') as due_date, o.original_amount, o.open_amount,",
    '       greatest(trunc(sysdate) - o.due_date, 0) as days_late',
    "  from ar_open_item o where o.customer_account_id = :P11_ID and o.open_amount > 0 and o.item_type = 'INVOICE' order by o.due_date"],
    [('SOURCE_ENTITY_TYPE', 'المصدر', {'hidden': True}), ('SOURCE_ENTITY_ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'المستند', {}),
     ('DUE_DATE', 'الاستحقاق', {}), ('ORIGINAL_AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}),
     ('DAYS_LATE', 'أيام التأخير', {'type': 'NUMBER'})], titled=True)
p.branch(10, url(11, 'P11_ID', '&P11_ID.', '11') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20/21) فواتير المبيعات
p = app.page(20, 'Sales Invoices', 'INVOICES', 'فواتير المبيعات والمرتجعات', scheme=TENANT)
r = p.ir('فواتير المبيعات', 10, [
    "select i.id, i.doc_no, to_char(i.doc_date, 'YYYY-MM-DD') as doc_date,",
    "       case i.doc_type when 'CREDIT_NOTE' then 'مرتجع' when 'INVOICE' then 'ضريبية' else 'مبسطة' end as doc_type,",
    '       i.customer_name_snapshot as customer, noona_sal_pkg.mode_label(i.payment_mode) as pay_mode, i.subtotal, i.tax_amount, i.total_amount,',
    "       i.subtotal - i.cogs_amount as gross_profit,",
    "       (select sum(open_amount) from ar_open_item where source_entity_type = 'SAL_INVOICE' and source_entity_id = i.id) as open_amount,",
    '       noona_ui_pkg.status_badge(i.status_code) as status_html',
    '  from sal_invoice i where i.company_id = noona_sal_pkg.company order by i.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {}), ('DOC_TYPE', 'النوع', {}),
     ('CUSTOMER', 'العميل', {}), ('PAY_MODE', 'الطريقة', {}), ('SUBTOTAL', 'الصافي', {'type': 'NUMBER'}), ('TAX_AMOUNT', 'الضريبة', {'type': 'NUMBER'}),
     ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}), ('GROSS_PROFIT', 'مجمل الربح', {'type': 'NUMBER'}), ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})], link=link(21, 'P21_ID'))
p.button(r, 10, 'NEW', 'فاتورة مبيعات جديدة', hot=True, redirect=url(21, clear='RP,21'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(21, 'Sales Invoice', 'INVOICE', 'فاتورة مبيعات', scheme=TENANT, protection='N')
hd = p.static('الفاتورة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P21_ID', hd, 1)
p.hidden('P21_STATUS', hd, 2)
p.hidden('P21_CUST', hd, 3)
p.hidden('P21_DTYPE', hd, 4)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'if :P21_ID is not null then',
    '    select status_code, customer_account_id, doc_type into :P21_STATUS, :P21_CUST, :P21_DTYPE',
    '      from sal_invoice where id = :P21_ID and company_id = noona_sal_pkg.company;',
    'end if;'])
p.dynamic('فاتورة المبيعات', 10, trade_region(
    {'kind': 'SI', 'title': 'فاتورة مبيعات', 'purpose': 'SALE', 'cols': ['d', 'q', 'p', 'inc', 'disc', 'tc'], 'free': True, 'lots': False,
     'header': [{'k': 'cust', 'l': 'العميل', 't': 'select', 'o': 'custs', 'req': True}, {'k': 'date', 'l': 'التاريخ', 't': 'date'},
                {'k': 'mode', 'l': 'طريقة البيع', 't': 'select', 'o': [{'v': 'CASH', 'n': 'نقدي / فوري'}, {'v': 'CREDIT', 'n': 'آجل (على حساب العميل)'}], 'req': True},
                {'k': 'place', 'l': 'التحصيل في', 't': 'select', 'o': 'places', 'show': 'mode=CASH'},
                {'k': 'wh', 'l': 'مستودع الصرف', 't': 'select', 'o': 'whs'}, {'k': 'cc', 'l': 'مركز الربحية', 't': 'select', 'o': 'ccs'},
                {'k': 'name', 'l': 'اسم العميل على الفاتورة (للعميل العام)', 't': 'text'}, {'k': 'taxNo', 'l': 'الرقم الضريبي للعميل', 't': 'text'},
                {'k': 'rx', 'l': 'رقم الوصفة الطبية (للأدوية الوصفية)', 't': 'text'}],
     'actions': [{'a': 'SAVE', 'n': 'حفظ مسودة'},
                 {'a': 'POST', 'n': 'ترحيل الفاتورة', 'hot': True, 'confirm': 'سيتم صرف الأصناف من المخزون وترحيل القيد. متابعة؟'}]},
    'noona_sal_pkg.invoice_json(:P21_ID)', "'N'", 'custs,whs,taxes,ccs,places,revs'), hide_header=True, opts='#DEFAULT#:t-Region--noUI',
    condition=":P21_ID is null or :P21_STATUS = 'DRAFT'")
p.dynamic('الفاتورة', 12, 'return noona_sal_pkg.invoice_print(:P21_ID);', hide_header=True,
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area', condition=":P21_ID is not null and :P21_STATUS <> 'DRAFT'")
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_sal_pkg.save_invoice', 21))
p.process(2, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
ac = p.static('الإجراءات', 30, condition=':P21_ID is not null')
p.button(ac, 10, 'PRINT', 'طباعة', redirect='javascript:window.print();', condition=":P21_STATUS <> 'DRAFT'")
p.button(ac, 20, 'RETURN', 'مرتجع من الفاتورة', redirect=url(22, 'P22_INV', '&P21_ID.', 'RP,22'),
         condition=":P21_STATUS in ('POSTED', 'PARTIALLY_PAID', 'PAID') and :P21_DTYPE <> 'CREDIT_NOTE'")
p.button(ac, 30, 'RECEIVE', 'تحصيل', hot=True, redirect=url(24, 'P24_CUST', '&P21_CUST.', 'RP,24'),
         condition=":P21_STATUS in ('POSTED', 'PARTIALLY_PAID') and :P21_DTYPE <> 'CREDIT_NOTE'")
b = p.button(ac, 40, 'CANCEL_INV', 'إلغاء المسودة', condition=":P21_STATUS = 'DRAFT'")
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_sal_pkg.cancel_invoice(:P21_ID);', when_button=b, success='تم إلغاء المسودة')
p.onload(TD_JS + QR_JS)
p.branch(10, url(21, 'P21_ID', '&P21_ID.', '21') + '&success_msg=#SUCCESS_MSG#')

p = app.page(22, 'Sales Return', 'SALES-RETURN', 'مرتجع مبيعات', scheme=TENANT, protection='N')
hd = p.static('المرتجع', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P22_INV', hd, 1, protected=False)
p.dynamic('مرتجع المبيعات', 10, trade_region(
    {'kind': 'RET', 'title': 'مرتجع مبيعات (إشعار دائن)', 'cols': ['sold', 'done', 'q', 'p'], 'carry': ['inv'], 'search': False,
     'header': [{'k': 'date', 'l': 'التاريخ', 't': 'date'}, {'k': 'reason', 'l': 'سبب المرتجع', 't': 'text', 'req': True, 'w': True}],
     'actions': [{'a': 'POST', 'n': 'ترحيل المرتجع', 'hot': True, 'confirm': 'سيتم إعادة الأصناف للمخزون وتخفيض حساب العميل أو رد المبلغ. متابعة؟'}]},
    'noona_sal_pkg.return_doc_json(:P22_INV)',
    "'N'", 'taxes'), hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_sal_pkg.post_return', 21, 'P21_ID'))
p.onload(TD_JS)

# =============================================================== 23/24) التحصيل
p = app.page(23, 'Receipts', 'RECEIPTS', 'التحصيل من العملاء', scheme=TENANT)
r = p.ir('التحصيلات', 10, [
    "select y.id, y.doc_no, to_char(y.doc_date, 'YYYY-MM-DD') as doc_date, noona_sal_pkg.customer_label(y.customer_account_id) as customer,",
    '       (select name_ar from ref_payment_method where id = y.payment_method_id) as method, y.external_reference,',
    "       nvl((select 'صندوق: ' || name_ar from csh_cash_box where id = y.cash_box_id), (select 'بنك: ' || name_ar from csh_bank_account where id = y.bank_account_id)) as place,",
    '       y.amount, y.unapplied_amount, noona_ui_pkg.status_badge(y.status_code) as status_html',
    '  from ar_receipt y where y.company_id = noona_sal_pkg.company order by y.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {}), ('CUSTOMER', 'العميل', {}),
     ('METHOD', 'الطريقة', {}), ('EXTERNAL_REFERENCE', 'المرجع', {}), ('PLACE', 'إلى', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
     ('UNAPPLIED_AMOUNT', 'دفعة مقدمة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})])
p.button(r, 10, 'NEW', 'تحصيل جديد', hot=True, redirect=url(24, clear='RP,24'), position='RIGHT_OF_IR_SEARCH_BAR')
f = p.static('عكس تحصيل (شيك مرتد أو خطأ)', 20)
p.select('P23_RCP', f, 10, 'التحصيل', lov_sql=(
    "select doc_no || ' - ' || noona_sal_pkg.customer_label(customer_account_id) || ' - ' || amount d, id r from ar_receipt "
    "where company_id = noona_sal_pkg.company and status_code = 'CONFIRMED' order by id desc"))
p.text('P23_REASON', f, 20, 'السبب', required=True)
b = p.button(f, 10, 'REVERSE', 'عكس التحصيل')
p.process(10, 'AFTER_SUBMIT', 'Reverse', ['declare l number;', 'begin',
    '    l := noona_sal_pkg.reverse_receipt(:P23_RCP, trunc(sysdate), :P23_REASON);', 'end;'], when_button=b,
    success='تم عكس التحصيل وإعادة فتح الذمم')
p.branch(10, url(23, clear='23') + '&success_msg=#SUCCESS_MSG#')

p = app.page(24, 'Receive', 'RECEIVE', 'تحصيل من عميل', scheme=TENANT, protection='N')
f = p.static('التحصيل', 10)
p.select('P24_CUST', f, 10, 'العميل', lov_sql=CUST_LOV, required=True)
p.date('P24_DATE', f, 20, 'التاريخ')
p.number('P24_AMOUNT', f, 30, 'المبلغ', required=True)
p.select('P24_PLACE', f, 40, 'التحصيل في', lov_sql=PLACE_LOV, required=True)
p.select('P24_METHOD', f, 50, 'طريقة الدفع', null_text=None, lov_sql=METHOD_LOV)
p.text('P24_REF', f, 60, 'المرجع (رقم العملية / الشيك)')
p.text('P24_NOTES', f, 70, 'البيان')
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P24_DATE := nvl(:P24_DATE, to_char(sysdate, 'YYYY-MM-DD'));"])
b = p.button(f, 10, 'RECEIVE', 'تنفيذ التحصيل (يخصص على الأقدم استحقاقاً)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Receive', ['declare l number;', 'begin',
    "    l := noona_sal_pkg.receive(json_object('cust' value to_number(:P24_CUST), 'date' value :P24_DATE, 'amount' value to_number(:P24_AMOUNT),",
    "        'place' value :P24_PLACE, 'method' value :P24_METHOD, 'ref' value :P24_REF, 'notes' value :P24_NOTES));", 'end;'], when_button=b,
    success='تم التحصيل وترحيل القيد وتحديث رصيد الصندوق أو البنك')
p.ir('الذمم المفتوحة للعميل', 20, [
    "select o.doc_no, to_char(o.due_date, 'YYYY-MM-DD') as due_date, o.original_amount, o.open_amount, greatest(trunc(sysdate) - o.due_date, 0) as days_late",
    "  from ar_open_item o where o.customer_account_id = :P24_CUST and o.open_amount > 0 and o.item_type = 'INVOICE' order by o.due_date"],
    [('DOC_NO', 'المستند', {}), ('DUE_DATE', 'الاستحقاق', {}), ('ORIGINAL_AMOUNT', 'المبلغ', {'type': 'NUMBER'}),
     ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}), ('DAYS_LATE', 'أيام التأخير', {'type': 'NUMBER'})], titled=True)
p.branch(10, url(23) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) اختيار نقطة البيع
p = app.page(30, 'POS Terminals', 'POS-START', 'نقاط البيع', scheme=TENANT)
p.ir('اختر نقطة البيع', 10, [
    "select t.id, t.code, t.name_ar, w.name_ar as warehouse, (select name_ar from csh_cash_box where id = t.cash_box_id) as drawer,",
    "       (select max(s.id) from pos_shift s where s.terminal_id = t.id and s.status_code = 'OPEN') as open_shift,",
    "       (select max(u.display_name) from pos_shift s join sec_user_membership m on m.id = s.cashier_member_id join sec_user u on u.id = m.user_id",
    "         where s.terminal_id = t.id and s.status_code = 'OPEN') as cashier,",
    "       '<span class=\"t-Button t-Button--hot t-Button--small\">بدء البيع</span>' as go",
    '  from pos_terminal t join inv_warehouse w on w.id = t.warehouse_id',
    " where t.company_id = noona_pos_pkg.company and t.status_code = 'ACTIVE' order by t.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'نقطة البيع', {}), ('WAREHOUSE', 'المستودع', {}),
     ('DRAWER', 'الدرج النقدي', {}), ('OPEN_SHIFT', 'وردية مفتوحة', {'type': 'NUMBER'}), ('CASHIER', 'الكاشير', {}),
     ('GO', 'فتح', {'html': True, 'link': ('f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_TERM:#ID#', '#GO#')})], titled=True)

# =============================================================== 31) شاشة نقطة البيع
p = app.page(31, 'POS', 'POS', 'نقطة البيع', scheme=TENANT, protection='N')
hd = p.static('المحطة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P31_TERM', hd, 1, protected=False)
p.dynamic('نقطة البيع', 10, [
    'begin',
    "    if :P31_TERM is null then return '<div class=\"nn-empty\">اختر نقطة البيع من قائمة نقاط البيع</div>'; end if;",
    "    return '<script type=\"application/json\" id=\"nnPosBoot\">' || replace(noona_pos_pkg.boot_json(:P31_TERM), '</', '<\\/') || '</script>'",
    "        || '<div id=\"nnPos\" class=\"nn-pos\"></div>';",
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SALE', clob_ajax('noona_pos_pkg.sale(apex_application.g_clob_01)'))
p.process(2, 'ON_DEMAND', 'RETURN', clob_ajax('noona_pos_pkg.return_sale(apex_application.g_clob_01)'))
p.process(3, 'ON_DEMAND', 'FIND_RECEIPT', clob_ajax('noona_pos_pkg.find_receipt(apex_application.g_x01)'))
p.process(4, 'ON_DEMAND', 'FIND_CUST', clob_ajax("'{\"list\":' || noona_sal_pkg.customers_json(apex_application.g_x01) || '}'"))
p.process(5, 'ON_DEMAND', 'OPEN_SHIFT', clob_ajax(
    "'{\"shift\":' || noona_pos_pkg.open_shift(to_number(apex_application.g_x02), to_number(nvl(apex_application.g_x01, '0'))) || '}'"))
ac = p.static('الوردية', 30, condition=':P31_TERM is not null')
p.button(ac, 10, 'CLOSE_SHIFT', 'تقرير X / إقفال الوردية', redirect=url(32, 'P32_TERM', '&P31_TERM.', 'RP,32'))
p.onload(POS_JS)

# =============================================================== 32) إقفال الوردية
p = app.page(32, 'Close Shift', 'CLOSE-SHIFT', 'تقرير الوردية وإقفالها', scheme=TENANT, protection='N')
f = p.static('الوردية', 10)
p.hidden('P32_TERM', f, 1, protected=False)
p.select('P32_SHIFT', f, 10, 'الوردية', lov_sql=(
    "select t.name_ar || ' - وردية ' || s.id || ' - ' || to_char(s.opened_at, 'YYYY-MM-DD HH24:MI') || case s.status_code when 'OPEN' then ' (مفتوحة)' else '' end d, s.id r "
    "from pos_shift s join pos_terminal t on t.id = s.terminal_id where s.company_id = noona_pos_pkg.company "
    "and (s.status_code = 'OPEN' or s.opened_at > sysdate - 7) order by s.id desc"))
p.number('P32_COUNTED', f, 20, 'النقد المعدود في الدرج')
p.process(5, 'BEFORE_HEADER', 'Default Shift', [
    "if :P32_SHIFT is null then select max(id) into :P32_SHIFT from pos_shift where company_id = noona_pos_pkg.company and status_code = 'OPEN'",
    '    and (terminal_id = :P32_TERM or :P32_TERM is null); end if;'])
p.button(f, 10, 'SHOW', 'عرض التقرير')
b = p.button(f, 20, 'CLOSE', 'إقفال الوردية وترحيل القيد', hot=True)
p.button(f, 30, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'AFTER_SUBMIT', 'Close', ['declare l number;', 'begin',
    "    if :P32_COUNTED is null then raise_application_error(-20001, 'أدخل النقد المعدود في الدرج'); end if;",
    '    l := noona_pos_pkg.close_shift(:P32_SHIFT, to_number(:P32_COUNTED));', 'end;'], when_button=b,
    success='تم إقفال الوردية وترحيل قيد مبيعات نقطة البيع (مع فرق النقدية إن وجد)')
p.dynamic('تقرير الوردية', 20, 'return case when :P32_SHIFT is not null then noona_pos_pkg.x_report(:P32_SHIFT) end;', hide_header=True,
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.branch(10, url(32, 'P32_SHIFT', '&P32_SHIFT.', '32') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 33) طباعة الإيصال
p = app.page(33, 'Receipt', 'RECEIPT', 'إيصال', scheme=TENANT, protection='N')
hd = p.static('الإيصال', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P33_ID', hd, 1, protected=False)
p.hidden('P33_AUTO', hd, 2, protected=False)
p.dynamic('الإيصال', 10, 'return noona_pos_pkg.receipt_html(:P33_ID);', hide_header=True, opts='#DEFAULT#:t-Region--noUI',
          condition=':P33_ID is not null')
p.onload([
    "document.body.classList.add('nn-receipt-page');",
] + QR_JS + [
    "if ($v('P33_AUTO') === 'Y') { setTimeout(function () { window.print(); }, 700); }"])

# =============================================================== 40) نقاط البيع (الإعداد)
p = app.page(40, 'Terminals', 'TERMINALS', 'إعداد نقاط البيع', scheme=TENANT)
p.ir('نقاط البيع', 10, [
    "select t.id, t.code, t.name_ar, w.name_ar as warehouse, (select name_ar from csh_cash_box where id = t.cash_box_id) as drawer,",
    '       (select name_ar from csh_bank_account where id = t.bank_account_id) as bank,',
    '       (select code || \' - \' || name_ar from gl_cost_center where id = t.cost_center_id) as cost_center, noona_ui_pkg.status_badge(t.status_code) as status_html',
    '  from pos_terminal t join inv_warehouse w on w.id = t.warehouse_id where t.company_id = noona_pos_pkg.company order by t.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'نقطة البيع', {}), ('WAREHOUSE', 'المستودع', {}),
     ('DRAWER', 'الدرج النقدي', {}), ('BANK', 'حساب التسوية البنكية (مدى/بطاقات/محافظ)', {}), ('COST_CENTER', 'مركز الربحية', {}),
     ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('نقطة بيع جديدة', 20)
p.text('P40_CODE', f, 10, 'الرمز', required=True, maxlen=20, width=10)
p.text('P40_NAME', f, 20, 'الاسم', required=True)
p.select('P40_WH', f, 30, 'المستودع', lov_sql=WH_LOV, required=True)
p.select('P40_BOX', f, 40, 'الدرج النقدي (صندوق)', lov_sql=(
    "select name_ar d, id r from csh_cash_box where company_id = noona_gl_pkg.company and status_code = 'ACTIVE' order by name_ar"), required=True)
p.select('P40_BANK', f, 50, 'حساب التسوية البنكية', lov_sql=(
    "select name_ar || ' ' || account_no_masked d, id r from csh_bank_account where company_id = noona_gl_pkg.company and status_code = 'ACTIVE'"))
p.select('P40_CC', f, 60, 'مركز الربحية', lov_sql=CC_LOV)
b = p.button(f, 10, 'ADD', 'إضافة نقطة البيع', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add', ['declare l number;', 'begin',
    '    l := noona_pos_pkg.create_terminal(:P40_CODE, :P40_NAME, :P40_WH, :P40_BOX, :P40_BANK, :P40_CC);', 'end;'], when_button=b,
    success='تمت إضافة نقطة البيع')
p.branch(10, url(40, clear='40') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 50) مركز التقارير
REPORTS = [
    ('SREG', 'سجل المبيعات ومجمل الربح', ['FROM', 'TO', 'CUST']),
    ('SITEM', 'المبيعات والربحية حسب الصنف', ['FROM', 'TO', 'CAT']),
    ('POSR', 'مبيعات نقاط البيع والورديات', ['FROM', 'TO', 'TERM']),
    ('CSTMT', 'كشف حساب عميل', ['CUST', 'FROM', 'TO']),
    ('AGING', 'أعمار ديون العملاء', ['ASOF']),
]
p = app.page(50, 'Reports', 'REPORTS', 'تقارير المبيعات', scheme=TENANT, protection='N')
f = p.static('التقرير والمرشحات', 10, opts='#DEFAULT#:nn-rpt-filters')
p.select('P50_REPORT', f, 5, 'التقرير', null_text=None, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n, _ in REPORTS))
p.date('P50_FROM', f, 10, 'من تاريخ')
p.date('P50_TO', f, 20, 'إلى تاريخ')
p.date('P50_ASOF', f, 25, 'في تاريخ')
p.select('P50_CUST', f, 30, 'العميل', lov_sql=CUST_LOV, null_text='- اختر -')
p.select('P50_CAT', f, 40, 'الفئة', lov_sql=CAT_LOV, null_text='كل الفئات')
p.select('P50_TERM', f, 50, 'نقطة البيع', lov_sql=TERM_POS_LOV, null_text='كل نقاط البيع')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P50_REPORT := nvl(:P50_REPORT, 'SREG');",
    ":P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
    ":P50_TO := nvl(:P50_TO, to_char(sysdate, 'YYYY-MM-DD'));",
    ":P50_ASOF := nvl(:P50_ASOF, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('التقرير', 20, [
    'declare',
    "    l_from date := to_date(:P50_FROM, 'YYYY-MM-DD');",
    "    l_to date := to_date(:P50_TO, 'YYYY-MM-DD');",
    'begin',
    '    return case :P50_REPORT',
    "        when 'SREG' then noona_sal_pkg.sales_register(l_from, l_to, :P50_CUST, 'f?p=' || :APP_ID || ':21:' || :APP_SESSION || '::NO:RP:P21_ID:#ID#')",
    "        when 'SITEM' then noona_sal_pkg.sales_by_item(l_from, l_to, :P50_CAT)",
    "        when 'POSR' then noona_pos_pkg.pos_sales_report(l_from, l_to, :P50_TERM)",
    "        when 'CSTMT' then noona_sal_pkg.customer_statement(:P50_CUST, l_from, l_to)",
    "        when 'AGING' then noona_sal_pkg.ar_aging(to_date(:P50_ASOF, 'YYYY-MM-DD'),",
    "             'f?p=' || :APP_ID || ':50:' || :APP_SESSION || '::NO::P50_REPORT,P50_CUST:CSTMT,#ID#')",
    '    end;',
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
FILTERS = ['FROM', 'TO', 'ASOF', 'CUST', 'CAT', 'TERM']
p.onload([
    '(function () {',
    '    var map = {' + ', '.join(f"{c}: {f!r}".replace("'", '"') for c, _, f in REPORTS) + '};',
    '    var all = ' + str(FILTERS).replace("'", '"') + ';',
    "    var sel = document.getElementById('P50_REPORT');",
    '    function sync() { var on = map[sel.value] || [];',
    "        all.forEach(function (k) { var c = document.getElementById('P50_' + k + '_CONTAINER'); if (c) c.style.display = on.indexOf(k) >= 0 ? '' : 'none'; }); }",
    "    sel.addEventListener('change', function () { sync(); apex.submit('RUN'); });",
    '    sync();',
    '})();'])

# =============================================================== القائمة
app.nav_item('لوحة المبيعات', 1, 'fa-line-chart', 10)
app.nav_item('نقطة البيع', 30, 'fa-shopping-basket', 15)
sa = app.nav_item('المبيعات والعملاء', None, 'fa-file-text-o', 20)
app.nav_item('فاتورة مبيعات جديدة', 21, 'fa-plus', 21, parent=sa)
app.nav_item('فواتير المبيعات والمرتجعات', 20, 'fa-files-o', 22, parent=sa)
app.nav_item('العملاء', 10, 'fa-users', 23, parent=sa)
app.nav_item('التحصيل من العملاء', 23, 'fa-money', 24, parent=sa)
po = app.nav_item('إدارة نقاط البيع', None, 'fa-desktop', 30)
app.nav_item('تقرير الوردية وإقفالها', 32, 'fa-lock', 31, parent=po)
app.nav_item('إعداد نقاط البيع', 40, 'fa-cogs', 32, parent=po)
app.nav_item('التقارير', 50, 'fa-bar-chart', 40)

app.finalize()
print('NOONA_POS built:', len(app.pages), 'pages')
