"""NOONA_SCM (سلسلة الإمداد): الأصناف (سلع، قطع غيار، أدوية، خامات ومنتجات مصنعة)، المستودعات والفئات وربطها بالحسابات،
مستندات المخزون، قوائم المواد والإنتاج، الموردون، أوامر الشراء، فواتير المشتريات والمرتجعات، سداد الموردين،
ومركز تقارير واحد بمرشحات موحدة.
الاستخدام: python3 tools/build_scm.py  ->  apex/NOONA_SCM/f131
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand
from trade_doc import TD_JS, ITEM_JS, QR_JS, trade_region, save_ajax, clob_ajax, FIND_ITEMS

if ('qrcode.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('qrcode.js', 'application/javascript'))
ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_SCM/f131'),
          app_id=131, alias='NOONA_SCM', name='NOONA Supply Chain', id_base=91820268000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


SUP_LOV = ("select s.supplier_no || ' - ' || p.display_name_ar d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id "
           "join pty_party p on p.id = s.party_id where a.company_id = noona_pur_pkg.company order by p.display_name_ar")
WH_LOV = "select code || ' - ' || name_ar d, id r from inv_warehouse where company_id = noona_inv_pkg.company and status_code = 'ACTIVE' order by code"
CAT_LOV = "select name_ar d, id r from inv_item_category where is_active = 'Y' order by name_ar"
CC_LOV = "select code || ' - ' || name_ar d, id r from gl_cost_center where company_id = noona_gl_pkg.company order by code"
TERM_LOV = "select name_ar d, code r from ref_payment_term where is_active = 'Y' order by due_days"
PLACE_LOV = ("select d, r from (select 'صندوق: ' || name_ar d, 'BOX:' || id r, 1 o from csh_cash_box where company_id = noona_gl_pkg.company "
             "and status_code = 'ACTIVE' union all select 'بنك: ' || name_ar || ' ' || account_no_masked, 'BANK:' || id, 2 from csh_bank_account "
             "where company_id = noona_gl_pkg.company and status_code = 'ACTIVE') order by o, d")
METHOD_LOV = "select name_ar d, code r from ref_payment_method where is_active = 'Y' and method_type <> 'CREDIT' order by sort_order"
ACC_LOV = ("select a.account_code || ' - ' || a.name_ar d, a.account_code r from gl_account a where a.coa_id = noona_gl_pkg.primary_coa "
           "and a.is_postable = 'Y' and a.account_type = '{t}' order by a.account_code")
PROFILE_LOV = ('STATIC2:بضائع عامة;GENERAL,قطع غيار السيارات;AUTO_PART,الأدوية والمستحضرات;PHARMA,أغذية;FOOD,إلكترونيات;ELECTRONICS,'
               'ملابس;APPAREL,خامات ومواد أولية;RAW_MATERIAL')
PROFILE_SQL = ("decode({c}, 'GENERAL', 'عام', 'AUTO_PART', 'قطع غيار', 'PHARMA', 'أدوية', 'RAW_MATERIAL', 'خامات', 'FOOD', 'أغذية', "
               "'ELECTRONICS', 'إلكترونيات', 'APPAREL', 'ملابس', {c})")
READY = "noona_pur_pkg.is_ready = 'Y'"

# =============================================================== 1) لوحة سلسلة الإمداد
p = app.page(1, 'Home', 'HOME', 'سلسلة الإمداد', scheme=TENANT)
st = p.static('تجهيز سلسلة الإمداد', 5, condition="noona_pur_pkg.is_ready = 'N'")
b = p.button(st, 10, 'SETUP', 'تجهيز المخزون والمشتريات (الفئات بحساباتها، المستودع الرئيسي، الضريبة، طرق السداد، الترقيم)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_pur_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم تجهيز سلسلة الإمداد: الفئات الافتراضية (عام، قطع غيار، أدوية، خامات، منتجات تامة، خدمات)، المستودع الرئيسي، '
                  'حسابات الضريبة، طرق السداد وشروط الدفع')
p.dynamic('المخزون', 10, 'return noona_inv_pkg.inv_summary;', hide_header=True, condition=READY)
p.dynamic('المشتريات', 12, 'return noona_pur_pkg.pur_summary;', hide_header=True, condition=READY)
qa = p.static('إجراءات سريعة', 15, condition=READY)
p.button(qa, 10, 'NEW_PI', 'فاتورة مشتريات', hot=True, redirect=url(35, clear='RP,35'))
p.button(qa, 20, 'NEW_ITEM', 'صنف جديد', redirect=url(11, clear='RP,11'))
p.button(qa, 30, 'NEW_PO', 'أمر شراء', redirect=url(33, clear='RP,33'))
p.button(qa, 40, 'PAY', 'سداد مورد', redirect=url(38, clear='RP,38'))
p.button(qa, 50, 'OPENING', 'رصيد افتتاحي للمخزون', redirect=url(21, 'P21_TYPE', 'OPENING', 'RP,21'))
p.button(qa, 60, 'REPORTS', 'التقارير', redirect=url(50))
p.ir('آخر فواتير المشتريات', 20, [
    "select i.id, i.doc_no, to_char(i.gl_date, 'YYYY-MM-DD') as gl_date,",
    "       case i.invoice_type when 'CREDIT_MEMO' then 'مرتجع' else 'فاتورة' end as inv_type,",
    '       noona_pur_pkg.supplier_label(i.supplier_account_id) as supplier, noona_pur_pkg.mode_label(i.payment_mode) as pay_mode,',
    '       i.total_amount, noona_ui_pkg.status_badge(i.status_code) as status_html',
    '  from ap_invoice i where i.company_id = noona_pur_pkg.company order by i.id desc fetch first 10 rows only'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('GL_DATE', 'التاريخ', {}), ('INV_TYPE', 'النوع', {}),
     ('SUPPLIER', 'المورد', {}), ('PAY_MODE', 'الطريقة', {}), ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})], link=link(35, 'P35_ID'), titled=True)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) الأصناف
p = app.page(10, 'Items', 'ITEMS', 'الأصناف', scheme=TENANT)
r = p.ir('الأصناف', 10, [
    "select i.id, i.item_no, i.item_code, i.name_ar, g.name_ar as category, " + PROFILE_SQL.format(c='i.product_profile') + " as profile,",
    "       decode(i.item_type, 'STOCK', 'سلعة', 'SPARE_PART', 'قطعة غيار', 'RAW_MATERIAL', 'خامة', 'FINISHED_GOOD', 'منتج تام',",
    "              'SEMI_FINISHED', 'نصف مصنع', 'SERVICE', 'خدمة', 'CONSUMABLE', 'مستهلكات', 'NON_STOCK', 'غير مخزني', i.item_type) as item_type,",
    '       (select min(b.barcode) from inv_item_barcode b where b.item_id = i.id) as barcode,',
    '       i.brand, i.manufacturer_part_no, i.generic_name, c.sale_price, c.last_purchase_price,',
    '       noona_inv_pkg.on_hand(i.id) as on_hand, noona_ui_pkg.status_badge(i.status_code) as status_html',
    '  from inv_item i join inv_item_category g on g.id = i.category_id',
    '  left join inv_item_company c on c.item_id = i.id and c.company_id = noona_inv_pkg.company'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ITEM_NO', 'رقم الصنف', {}), ('ITEM_CODE', 'الكود', {}), ('NAME_AR', 'الصنف', {}),
     ('CATEGORY', 'الفئة', {}), ('PROFILE', 'الملف', {}), ('ITEM_TYPE', 'النوع', {}), ('BARCODE', 'الباركود', {}), ('BRAND', 'العلامة', {}),
     ('MANUFACTURER_PART_NO', 'رقم OEM', {}), ('GENERIC_NAME', 'المادة الفعالة', {}), ('SALE_PRICE', 'سعر البيع', {'type': 'NUMBER'}),
     ('LAST_PURCHASE_PRICE', 'آخر سعر شراء', {'type': 'NUMBER'}), ('ON_HAND', 'الرصيد', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})], link=link(11, 'P11_ID'), rows=100)
p.button(r, 10, 'NEW', 'صنف جديد', hot=True, redirect=url(11, clear='RP,11'), position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 11) بطاقة الصنف
p = app.page(11, 'Item', 'ITEM', 'بطاقة صنف', scheme=TENANT)
hd = p.static('الصنف', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P11_ID', hd, 1)
p.dynamic('بطاقة الصنف', 10, trade_region({}, 'noona_inv_pkg.item_json(:P11_ID)', "'N'", 'cats,uoms,taxes,whs,ccs',
                                         container='nnItem', data_id='nnItemData'), hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_inv_pkg.save_item', 11))
p.ir('الرصيد حسب المستودع والدفعة', 20, [
    "select w.code || ' - ' || w.name_ar as warehouse, l.lot_no, to_char(l.expiry_date, 'YYYY-MM-DD') as expiry_date, o.on_hand_qty",
    '  from inv_onhand o join inv_warehouse w on w.id = o.warehouse_id left join inv_lot l on l.id = o.lot_id',
    ' where o.item_id = :P11_ID and o.company_id = noona_inv_pkg.company and o.on_hand_qty <> 0 order by l.expiry_date nulls last'],
    [('WAREHOUSE', 'المستودع', {}), ('LOT_NO', 'الدفعة', {}), ('EXPIRY_DATE', 'الانتهاء', {}), ('ON_HAND_QTY', 'الكمية', {'type': 'NUMBER'})],
    titled=True)
p.dynamic('بطاقة الحركة (آخر 90 يوماً)', 30, "return noona_inv_pkg.item_card(:P11_ID, trunc(sysdate) - 90, trunc(sysdate));",
          condition=':P11_ID is not null')
p.onload(ITEM_JS)

# =============================================================== 12) الفئات وحساباتها
p = app.page(12, 'Categories', 'CATEGORIES', 'فئات الأصناف والحسابات', scheme=TENANT)
acc = lambda a: f"(select account_code || ' - ' || name_ar from gl_account where id = {a})"
p.ir('فئات الأصناف', 10, [
    f"select g.id, g.code, g.name_ar, {PROFILE_SQL.format(c='g.product_profile')} as profile,",
    f"       {acc('g.inventory_account_id')} as inv_acc, {acc('g.cogs_account_id')} as cogs_acc,",
    f"       {acc('g.revenue_account_id')} as rev_acc, {acc('g.expense_account_id')} as exp_acc,",
    '       (select count(*) from inv_item i where i.category_id = g.id) as items',
    '  from inv_item_category g order by g.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفئة', {}), ('PROFILE', 'ملف الأصناف', {}),
     ('INV_ACC', 'حساب المخزون', {}), ('COGS_ACC', 'تكلفة المبيعات', {}), ('REV_ACC', 'الإيراد', {}), ('EXP_ACC', 'المصروف', {}),
     ('ITEMS', 'الأصناف', {'type': 'NUMBER'})])
f = p.static('فئة جديدة', 20)
p.text('P12_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=15)
p.text('P12_NAME', f, 20, 'اسم الفئة', required=True)
p.select('P12_PROFILE', f, 30, 'ملف الأصناف', null_text=None, lov_sql=PROFILE_LOV)
p.select('P12_INV', f, 40, 'حساب المخزون', lov_sql=ACC_LOV.format(t='ASSET'), null_text='الافتراضي 1105')
p.select('P12_COGS', f, 50, 'حساب تكلفة المبيعات', lov_sql=ACC_LOV.format(t='EXPENSE'), null_text='الافتراضي 5101')
p.select('P12_REV', f, 60, 'حساب الإيراد', lov_sql=ACC_LOV.format(t='REVENUE'), null_text='الافتراضي 4101')
p.select('P12_EXP', f, 70, 'حساب المصروف (للصرف والخدمات)', lov_sql=ACC_LOV.format(t='EXPENSE'), null_text='الافتراضي 5299')
b = p.button(f, 10, 'ADD', 'إضافة الفئة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Category', [
    'declare l_id number;',
    'begin',
    '    l_id := noona_inv_pkg.create_category(:P12_CODE, :P12_NAME, :P12_PROFILE, null, :P12_INV, :P12_COGS, :P12_REV, :P12_EXP);',
    'end;'], when_button=b, success='تمت إضافة الفئة')
p.branch(10, url(12, clear='12') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 14) المستودعات
p = app.page(14, 'Warehouses', 'WAREHOUSES', 'المستودعات', scheme=TENANT)
p.ir('المستودعات', 10, [
    "select w.id, w.code, w.name_ar, decode(w.warehouse_type, 'MAIN', 'رئيسي', 'STORE', 'فرعي / معرض', 'PRODUCTION', 'إنتاج',",
    "       'DAMAGED', 'تالف', 'TRANSIT', 'عبور', w.warehouse_type) as wh_type,",
    "       (select code || ' - ' || name_ar from gl_cost_center where id = w.cost_center_id) as cost_center,",
    "       noona_ui_pkg.code_label(w.allow_negative) as allow_negative,",
    '       (select count(distinct item_id) from inv_onhand o where o.warehouse_id = w.id and o.on_hand_qty > 0) as items,',
    '       noona_ui_pkg.status_badge(w.status_code) as status_html',
    '  from inv_warehouse w where w.company_id = noona_inv_pkg.company order by w.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المستودع', {}), ('WH_TYPE', 'النوع', {}),
     ('COST_CENTER', 'مركز التكلفة', {}), ('ALLOW_NEGATIVE', 'يسمح بالسالب', {}), ('ITEMS', 'أصناف بها رصيد', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('مستودع جديد', 20)
p.text('P14_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=15)
p.text('P14_NAME', f, 20, 'اسم المستودع', required=True)
p.select('P14_TYPE', f, 30, 'النوع', null_text=None,
         lov_sql='STATIC2:رئيسي;MAIN,فرعي / معرض;STORE,مستودع إنتاج;PRODUCTION,مستودع التالف;DAMAGED,عبور;TRANSIT')
p.select('P14_CC', f, 40, 'مركز التكلفة', lov_sql=CC_LOV)
b = p.button(f, 10, 'ADD', 'إضافة المستودع', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Warehouse', [
    'declare l_id number;', 'begin', '    l_id := noona_inv_pkg.create_warehouse(:P14_CODE, :P14_NAME, :P14_TYPE, :P14_CC);', 'end;'],
    when_button=b, success='تمت إضافة المستودع')
p.branch(10, url(14, clear='14') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 13) قائمة المواد والإنتاج
p = app.page(13, 'Production', 'PRODUCTION', 'قائمة المواد والإنتاج', scheme=TENANT, protection='N')
f = p.static('المنتج', 5)
p.select('P13_ITEM', f, 10, 'المنتج المصنع', lov_sql=(
    "select item_no || ' - ' || name_ar d, id r from inv_item where status_code = 'ACTIVE' "
    "and item_type in ('FINISHED_GOOD', 'SEMI_FINISHED') order by name_ar"))
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.dynamic('قائمة المواد', 10, trade_region(
    {'kind': 'BOM', 'title': 'قائمة المواد', 'purpose': 'PURCHASE', 'cols': ['q', 's'], 'lots': False,
     'header': [{'k': 'base', 'l': 'الكمية الأساسية للمنتج (المكونات لكل)', 't': 'number', 'def': 1}],
     'actions': [{'a': 'SAVE', 'n': 'حفظ قائمة المواد', 'hot': True}]},
    'noona_inv_pkg.bom_json(:P13_ITEM)', "'N'", 'taxes'), hide_header=True, opts='#DEFAULT#:t-Region--noUI', condition=':P13_ITEM is not null')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_inv_pkg.save_bom_doc', 13, 'P13_ITEM'))
p.process(2, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
pr = p.static('تسجيل إنتاج', 20, condition=':P13_ITEM is not null')
p.number('P13_QTY', pr, 10, 'الكمية المنتجة', required=True)
p.select('P13_WH', pr, 20, 'المستودع', lov_sql=WH_LOV, null_text='الرئيسي')
p.text('P13_LOT', pr, 30, 'رقم دفعة الإنتاج (اختياري)', maxlen=60, width=20)
p.date('P13_EXP', pr, 40, 'تاريخ الانتهاء (اختياري)')
p.text('P13_DESC', pr, 50, 'البيان')
b = p.button(pr, 10, 'PRODUCE', 'صرف المكونات واستلام المنتج', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Produce', [
    'declare l_id number;', 'begin',
    "    l_id := noona_inv_pkg.produce(:P13_ITEM, :P13_QTY, :P13_WH, trunc(sysdate), :P13_DESC, :P13_LOT, to_date(:P13_EXP, 'YYYY-MM-DD'));",
    'end;'], when_button=b, success='تم الإنتاج: صرف المكونات بمتوسط التكلفة واستلام المنتج التام وترحيل قيد الإنتاج')
p.onload(TD_JS)
p.branch(10, url(13, 'P13_ITEM', '&P13_ITEM.', '13') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) مستندات المخزون
p = app.page(20, 'Stock Documents', 'STOCK-DOCS', 'حركات ومستندات المخزون', scheme=TENANT)
r = p.ir('حركات المخزون', 10, [
    "select t.id, t.doc_no, to_char(t.doc_date, 'YYYY-MM-DD') as doc_date, y.name_ar as txn_type, w.name_ar as warehouse,",
    '       (select name_ar from inv_warehouse where id = t.to_warehouse_id) as to_warehouse, t.reason_code, t.source_entity_type,',
    '       (select sum(abs(l.total_cost)) from inv_transaction_line l where l.transaction_id = t.id) as total_value,',
    '       noona_ui_pkg.status_badge(t.status_code) as status_html',
    '  from inv_transaction t join inv_txn_type y on y.id = t.txn_type_id join inv_warehouse w on w.id = t.warehouse_id',
    ' where t.company_id = noona_inv_pkg.company order by t.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {}), ('TXN_TYPE', 'الحركة', {}),
     ('WAREHOUSE', 'المستودع', {}), ('TO_WAREHOUSE', 'إلى مستودع', {}), ('REASON_CODE', 'السبب', {}), ('SOURCE_ENTITY_TYPE', 'المصدر', {}),
     ('TOTAL_VALUE', 'القيمة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(21, 'P21_ID'))
p.button(r, 10, 'NEW', 'مستند مخزون جديد', hot=True, redirect=url(21, clear='RP,21'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(21, 'Stock Document', 'STOCK-DOC', 'مستند مخزون', scheme=TENANT, protection='N')
hd = p.static('المستند', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P21_ID', hd, 1)
p.hidden('P21_TYPE', hd, 2, protected=False)
p.hidden('P21_STATUS', hd, 3)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'if :P21_ID is not null then',
    '    select status_code into :P21_STATUS from inv_transaction where id = :P21_ID and company_id = noona_inv_pkg.company;',
    'end if;'])
p.dynamic('مستند المخزون', 10, trade_region(
    {'kind': 'STK', 'title': 'مستند مخزون', 'purpose': 'ALL', 'cols': ['q', 'c', 'lot', 'exp'],
     'header': [{'k': 'type', 'l': 'نوع المستند', 't': 'select', 'o': 'stypes', 'req': True},
                {'k': 'date', 'l': 'التاريخ', 't': 'date'},
                {'k': 'wh', 'l': 'المستودع', 't': 'select', 'o': 'whs', 'req': True},
                {'k': 'toWh', 'l': 'إلى المستودع', 't': 'select', 'o': 'whs', 'show': 'type=TRANSFER_OUT'},
                {'k': 'cc', 'l': 'مركز التكلفة المستفيد', 't': 'select', 'o': 'ccs', 'show': 'type=CONSUMPTION'},
                {'k': 'reason', 'l': 'السبب / البيان', 't': 'text', 'w': True,
                 'ph': 'إلزامي للتسويات والإتلاف (جرد، تالف، منتهي الصلاحية...)'}],
     'actions': [{'a': 'SAVE', 'n': 'حفظ مسودة'},
                 {'a': 'POST', 'n': 'ترحيل', 'hot': True, 'confirm': 'ترحيل المستند يحدث الأرصدة ويولد القيد ولا يمكن تعديله بعدها. متابعة؟'}]},
    'noona_inv_pkg.stock_doc_json(:P21_ID, :P21_TYPE)', "case when :P21_ID is null or :P21_STATUS = 'DRAFT' then 'N' else 'Y' end",
    'stypes,whs,ccs,taxes'), hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_inv_pkg.save_stock_doc', 21))
p.process(2, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
ac = p.static('الإجراءات', 30, condition=":P21_STATUS = 'DRAFT'")
b = p.button(ac, 10, 'CANCEL_DOC', 'إلغاء المسودة')
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_inv_pkg.cancel_stock_doc(:P21_ID);', when_button=b, success='تم إلغاء المسودة')
p.onload(TD_JS)
p.branch(10, url(21, 'P21_ID', '&P21_ID.', '21') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) الموردون
p = app.page(30, 'Suppliers', 'SUPPLIERS', 'الموردون', scheme=TENANT)
r = p.ir('الموردون', 10, [
    "select a.id, s.supplier_no, p.display_name_ar as name_ar, p.tax_number,",
    "       (select max(mobile) from ref_contact where party_id = p.id and is_primary = 'Y') as phone,",
    "       (select name_ar from ref_payment_term where id = a.payment_term_id) as term,",
    '       noona_pur_pkg.supplier_balance(a.id) as balance,',
    "       (select nvl(sum(open_amount), 0) from ap_open_item o where o.supplier_account_id = a.id and o.item_type = 'INVOICE'",
    '           and o.due_date < trunc(sysdate)) as overdue,',
    "       case a.required_docs_ok when 'Y' then 'مكتملة' else 'ناقصة' end as docs, noona_ui_pkg.status_badge(a.status_code) as status_html",
    '  from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id join pty_party p on p.id = s.party_id',
    ' where a.company_id = noona_pur_pkg.company'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('SUPPLIER_NO', 'رقم المورد', {}), ('NAME_AR', 'المورد', {}), ('TAX_NUMBER', 'الرقم الضريبي', {}),
     ('PHONE', 'الجوال', {}), ('TERM', 'شروط الدفع', {}), ('BALANCE', 'الرصيد المستحق', {'type': 'NUMBER'}),
     ('OVERDUE', 'المتأخر', {'type': 'NUMBER'}), ('DOCS', 'المستندات', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(31, 'P31_ID'))
p.button(r, 10, 'NEW', 'مورد جديد', hot=True, redirect=url(31, clear='RP,31'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(31, 'Supplier', 'SUPPLIER', 'بيانات المورد', scheme=TENANT)
f = p.static('بيانات المورد', 10)
p.hidden('P31_ID', f, 1)
p.hidden('P31_PARTY', f, 2)
p.text('P31_NAME', f, 10, 'اسم المورد', required=True)
p.text('P31_NAME_EN', f, 20, 'الاسم بالإنجليزية')
p.select('P31_PERSON', f, 30, 'نوع الطرف', null_text=None, lov_sql='STATIC2:منشأة;N,فرد;Y')
p.select('P31_TYPE', f, 40, 'نوع المورد', null_text=None, lov_sql=(
    'STATIC2:بضائع;GOODS,خدمات;SERVICES,مقاول;CONTRACTOR,مقاول باطن;SUBCONTRACTOR,استشاري;CONSULTANT,خدمات عامة;UTILITY,جهة حكومية;GOVERNMENT'))
p.text('P31_TAX', f, 50, 'الرقم الضريبي (15 رقماً)', maxlen=15, width=20)
p.text('P31_CR', f, 60, 'السجل التجاري', maxlen=20, width=20)
p.text('P31_PHONE', f, 70, 'الجوال', maxlen=20, width=20)
p.text('P31_EMAIL', f, 80, 'البريد الإلكتروني')
p.text('P31_ADDRESS', f, 90, 'العنوان')
p.select('P31_TERM', f, 100, 'شروط الدفع', null_text=None, lov_sql=TERM_LOV)
p.select('P31_STATUS', f, 110, 'الحالة', null_text=None, lov_sql='STATIC2:نشط;ACTIVE,موقوف مؤقتاً;ON_HOLD,محظور;BLOCKED')
p.process(10, 'BEFORE_HEADER', 'Load', [
    'declare l clob;',
    'begin',
    '    if :P31_ID is not null and :P31_NAME is null then',
    '        l := noona_pur_pkg.supplier_json(:P31_ID);',
    "        :P31_NAME := json_value(l, '$.name'); :P31_NAME_EN := json_value(l, '$.nameEn'); :P31_PERSON := json_value(l, '$.person');",
    "        :P31_TYPE := json_value(l, '$.type'); :P31_TAX := json_value(l, '$.tax'); :P31_CR := json_value(l, '$.cr');",
    "        :P31_PHONE := json_value(l, '$.phone'); :P31_EMAIL := json_value(l, '$.email'); :P31_ADDRESS := json_value(l, '$.address');",
    "        :P31_TERM := json_value(l, '$.term'); :P31_STATUS := json_value(l, '$.status'); :P31_PARTY := json_value(l, '$.party');",
    '    end if;',
    "    :P31_TERM := nvl(:P31_TERM, 'NET30'); :P31_STATUS := nvl(:P31_STATUS, 'ACTIVE'); :P31_PERSON := nvl(:P31_PERSON, 'N');",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.button(f, 20, 'BACK', 'رجوع', redirect=url(30))
p.process(20, 'AFTER_SUBMIT', 'Save', [
    ':P31_ID := noona_pur_pkg.save_supplier(json_object(',
    "    'id' value to_number(:P31_ID), 'name' value :P31_NAME, 'nameEn' value :P31_NAME_EN, 'person' value :P31_PERSON, 'type' value :P31_TYPE,",
    "    'tax' value :P31_TAX, 'cr' value :P31_CR, 'phone' value :P31_PHONE, 'email' value :P31_EMAIL, 'address' value :P31_ADDRESS,",
    "    'term' value :P31_TERM, 'status' value :P31_STATUS));"], when_button=b, success='تم حفظ المورد')
p.dynamic('مستندات المورد الإلزامية', 20, "return noona_dms_pkg.compliance_html(:P31_PARTY, 'SUPPLIER');", condition=':P31_PARTY is not null')
p.ir('الفواتير المفتوحة', 30, [
    "select o.invoice_id, o.doc_no, to_char(o.due_date, 'YYYY-MM-DD') as due_date, o.original_amount, o.open_amount,",
    '       greatest(trunc(sysdate) - o.due_date, 0) as days_late',
    "  from ap_open_item o where o.supplier_account_id = :P31_ID and o.open_amount > 0 and o.item_type = 'INVOICE' order by o.due_date"],
    [('INVOICE_ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الفاتورة', {}), ('DUE_DATE', 'الاستحقاق', {}),
     ('ORIGINAL_AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}), ('DAYS_LATE', 'أيام التأخير', {'type': 'NUMBER'})],
    link=link(35, 'P35_ID', 'INVOICE_ID'), titled=True)
p.branch(10, url(31, 'P31_ID', '&P31_ID.', '31') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 32/33) أوامر الشراء
p = app.page(32, 'Purchase Orders', 'POS-LIST', 'أوامر الشراء', scheme=TENANT)
r = p.ir('أوامر الشراء', 10, [
    "select o.id, o.doc_no, to_char(o.doc_date, 'YYYY-MM-DD') as doc_date, noona_pur_pkg.supplier_label(o.supplier_account_id) as supplier,",
    "       to_char(o.promised_date, 'YYYY-MM-DD') as need_date, o.total_amount, noona_ui_pkg.status_badge(o.status_code) as status_html",
    '  from pur_order o where o.company_id = noona_pur_pkg.company order by o.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {}), ('SUPPLIER', 'المورد', {}),
     ('NEED_DATE', 'تاريخ التوريد', {}), ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link=link(33, 'P33_ID'))
p.button(r, 10, 'NEW', 'أمر شراء جديد', hot=True, redirect=url(33, clear='RP,33'), position='RIGHT_OF_IR_SEARCH_BAR')

TD_COMMON = {'taxes'}
p = app.page(33, 'Purchase Order', 'PO', 'أمر شراء', scheme=TENANT)
hd = p.static('الأمر', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P33_ID', hd, 1)
p.hidden('P33_STATUS', hd, 2)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'if :P33_ID is not null then select status_code into :P33_STATUS from pur_order where id = :P33_ID; end if;'])
p.dynamic('أمر الشراء', 10, trade_region(
    {'kind': 'PO', 'title': 'أمر شراء', 'purpose': 'PURCHASE', 'cols': ['d', 'q', 'p', 'disc', 'tc'], 'free': True,
     'header': [{'k': 'sup', 'l': 'المورد', 't': 'select', 'o': 'sups', 'req': True}, {'k': 'date', 'l': 'التاريخ', 't': 'date'},
                {'k': 'wh', 'l': 'مستودع الاستلام', 't': 'select', 'o': 'whs'}, {'k': 'need', 'l': 'تاريخ التوريد المطلوب', 't': 'date'}],
     'actions': [{'a': 'SAVE', 'n': 'حفظ مسودة'}, {'a': 'APPROVE', 'n': 'اعتماد الأمر', 'hot': True}]},
    'noona_pur_pkg.order_json(:P33_ID)', "case when :P33_ID is null or :P33_STATUS = 'DRAFT' then 'N' else 'Y' end", 'sups,whs,taxes'),
    hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_pur_pkg.save_order', 33))
p.process(2, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
ac = p.static('الإجراءات', 30, condition=":P33_ID is not null")
p.button(ac, 10, 'TO_INVOICE', 'استلام وفاتورة من الأمر', hot=True, redirect=url(35, 'P35_PO', '&P33_ID.', 'RP,35'),
         condition=":P33_STATUS in ('APPROVED', 'PARTIALLY_RECEIVED')")
b = p.button(ac, 20, 'CANCEL_PO', 'إلغاء الأمر', condition=":P33_STATUS in ('DRAFT', 'APPROVED')")
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_pur_pkg.cancel_order(:P33_ID);', when_button=b, success='تم إلغاء أمر الشراء')
p.onload(TD_JS)
p.branch(10, url(33, 'P33_ID', '&P33_ID.', '33') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 34/35) فواتير المشتريات
p = app.page(34, 'Purchase Invoices', 'PURCHASES', 'فواتير المشتريات والمرتجعات', scheme=TENANT)
r = p.ir('فواتير المشتريات', 10, [
    "select i.id, i.doc_no, to_char(i.gl_date, 'YYYY-MM-DD') as gl_date, case i.invoice_type when 'CREDIT_MEMO' then 'مرتجع' else 'فاتورة' end as inv_type,",
    "       noona_pur_pkg.supplier_label(i.supplier_account_id) as supplier, case when i.supplier_invoice_no not like '#%' then i.supplier_invoice_no end as sup_inv,",
    '       noona_pur_pkg.mode_label(i.payment_mode) as pay_mode, i.subtotal, i.tax_amount, i.total_amount,',
    "       (select sum(open_amount) from ap_open_item where invoice_id = i.id and item_type = 'INVOICE') as open_amount,",
    '       noona_ui_pkg.status_badge(i.status_code) as status_html',
    '  from ap_invoice i where i.company_id = noona_pur_pkg.company order by i.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('GL_DATE', 'التاريخ', {}), ('INV_TYPE', 'النوع', {}),
     ('SUPPLIER', 'المورد', {}), ('SUP_INV', 'فاتورة المورد', {}), ('PAY_MODE', 'الطريقة', {}), ('SUBTOTAL', 'الصافي', {'type': 'NUMBER'}),
     ('TAX_AMOUNT', 'الضريبة', {'type': 'NUMBER'}), ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER'}), ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})], link=link(35, 'P35_ID'))
p.button(r, 10, 'NEW', 'فاتورة مشتريات جديدة', hot=True, redirect=url(35, clear='RP,35'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(35, 'Purchase Invoice', 'PURCHASE', 'فاتورة مشتريات', scheme=TENANT, protection='N')
hd = p.static('الفاتورة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P35_ID', hd, 1)
p.hidden('P35_PO', hd, 2, protected=False)
p.hidden('P35_STATUS', hd, 3)
p.hidden('P35_SUP', hd, 4)
p.hidden('P35_ITYPE', hd, 5)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'if :P35_ID is not null then',
    '    select status_code, supplier_account_id, invoice_type into :P35_STATUS, :P35_SUP, :P35_ITYPE',
    '      from ap_invoice where id = :P35_ID and company_id = noona_pur_pkg.company;',
    'end if;'])
p.dynamic('فاتورة المشتريات', 10, trade_region(
    {'kind': 'PI', 'title': 'فاتورة مشتريات', 'purpose': 'PURCHASE', 'cols': ['d', 'q', 'p', 'disc', 'tc', 'acc', 'cc', 'lot', 'exp'],
     'free': True, 'carry': ['po'],
     'header': [{'k': 'sup', 'l': 'المورد', 't': 'select', 'o': 'sups', 'req': True}, {'k': 'date', 'l': 'تاريخ القيد', 't': 'date'},
                {'k': 'supInv', 'l': 'رقم فاتورة المورد', 't': 'text'}, {'k': 'supDate', 'l': 'تاريخ فاتورة المورد', 't': 'date'},
                {'k': 'wh', 'l': 'مستودع الاستلام', 't': 'select', 'o': 'whs'},
                {'k': 'mode', 'l': 'طريقة الدفع', 't': 'select', 'o': [{'v': 'CREDIT', 'n': 'آجل (على حساب المورد)'}, {'v': 'CASH', 'n': 'نقدي / فوري'}], 'req': True},
                {'k': 'place', 'l': 'الدفع من', 't': 'select', 'o': 'places', 'show': 'mode=CASH'},
                {'k': 'cc', 'l': 'مركز التكلفة', 't': 'select', 'o': 'ccs'}],
     'actions': [{'a': 'SAVE', 'n': 'حفظ مسودة'},
                 {'a': 'POST', 'n': 'ترحيل واستلام', 'hot': True, 'confirm': 'سيتم استلام الأصناف في المستودع وترحيل القيد. متابعة؟'}]},
    "case when :P35_ID is null and :P35_PO is not null then noona_pur_pkg.invoice_from_order(:P35_PO) else noona_pur_pkg.invoice_json(:P35_ID) end",
    "'N'", 'sups,whs,taxes,accts,ccs,places'), hide_header=True, opts='#DEFAULT#:t-Region--noUI',
    condition=":P35_ID is null or :P35_STATUS = 'DRAFT'")
p.dynamic('الفاتورة', 12, 'return noona_pur_pkg.invoice_print(:P35_ID);', hide_header=True,
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area', condition=":P35_ID is not null and :P35_STATUS <> 'DRAFT'")
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_pur_pkg.save_invoice', 35))
p.process(2, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
ac = p.static('الإجراءات', 30, condition=':P35_ID is not null')
p.button(ac, 10, 'PRINT', 'طباعة', redirect='javascript:window.print();', condition=":P35_STATUS <> 'DRAFT'")
p.button(ac, 20, 'RETURN', 'مرتجع من الفاتورة', redirect=url(36, 'P36_INV', '&P35_ID.', 'RP,36'),
         condition=":P35_STATUS in ('POSTED', 'PARTIALLY_PAID', 'PAID') and :P35_ITYPE = 'STANDARD'")
p.button(ac, 30, 'PAY', 'سداد للمورد', hot=True, redirect=url(38, 'P38_SUP', '&P35_SUP.', 'RP,38'),
         condition=":P35_STATUS in ('POSTED', 'PARTIALLY_PAID')")
b = p.button(ac, 40, 'CANCEL_INV', 'إلغاء المسودة', condition=":P35_STATUS = 'DRAFT'")
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_pur_pkg.cancel_invoice(:P35_ID);', when_button=b, success='تم إلغاء المسودة')
p.onload(TD_JS)
p.branch(10, url(35, 'P35_ID', '&P35_ID.', '35') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 36) مرتجع المشتريات
p = app.page(36, 'Purchase Return', 'PURCHASE-RETURN', 'مرتجع مشتريات', scheme=TENANT, protection='N')
hd = p.static('المرتجع', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P36_INV', hd, 1, protected=False)
p.dynamic('مرتجع المشتريات', 10, trade_region(
    {'kind': 'RET', 'title': 'مرتجع مشتريات (إشعار مدين للمورد)', 'cols': ['sold', 'done', 'q', 'p'], 'carry': ['inv'], 'search': False,
     'header': [{'k': 'date', 'l': 'التاريخ', 't': 'date'}, {'k': 'reason', 'l': 'سبب المرتجع', 't': 'text', 'req': True, 'w': True}],
     'actions': [{'a': 'POST', 'n': 'ترحيل المرتجع', 'hot': True, 'confirm': 'سيتم إخراج الكميات من المخزون وتخفيض حساب المورد. متابعة؟'}]},
    'noona_pur_pkg.return_doc_json(:P36_INV)',
    "'N'", 'taxes'), hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_DOC', save_ajax('noona_pur_pkg.post_return', 35, 'P35_ID'))
p.onload(TD_JS)

# =============================================================== 37/38) سداد الموردين
p = app.page(37, 'Supplier Payments', 'PAYMENTS', 'سداد الموردين', scheme=TENANT)
r = p.ir('المدفوعات', 10, [
    "select y.id, y.doc_no, to_char(y.doc_date, 'YYYY-MM-DD') as doc_date, noona_pur_pkg.supplier_label(y.supplier_account_id) as supplier,",
    '       (select name_ar from ref_payment_method where id = y.payment_method_id) as method,',
    "       nvl((select 'صندوق: ' || name_ar from csh_cash_box where id = y.cash_box_id), (select 'بنك: ' || name_ar from csh_bank_account where id = y.company_bank_account_id)) as place,",
    '       y.amount, y.unapplied_amount, noona_ui_pkg.status_badge(y.status_code) as status_html',
    '  from ap_payment y where y.company_id = noona_pur_pkg.company order by y.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {}), ('SUPPLIER', 'المورد', {}),
     ('METHOD', 'الطريقة', {}), ('PLACE', 'من', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('UNAPPLIED_AMOUNT', 'دفعة مقدمة غير مخصصة', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True})])
p.button(r, 10, 'NEW', 'سداد جديد', hot=True, redirect=url(38, clear='RP,38'), position='RIGHT_OF_IR_SEARCH_BAR')
f = p.static('عكس سداد', 20)
p.select('P37_PAY', f, 10, 'السداد', lov_sql=(
    "select doc_no || ' - ' || noona_pur_pkg.supplier_label(supplier_account_id) || ' - ' || amount d, id r from ap_payment "
    "where company_id = noona_pur_pkg.company and status_code = 'SETTLED' order by id desc"))
p.text('P37_REASON', f, 20, 'سبب العكس', required=True)
b = p.button(f, 10, 'REVERSE', 'عكس السداد')
p.process(10, 'AFTER_SUBMIT', 'Reverse', ['declare l number;', 'begin',
    '    l := noona_pur_pkg.reverse_payment(:P37_PAY, trunc(sysdate), :P37_REASON);', 'end;'], when_button=b,
    success='تم عكس السداد وإعادة فتح الفواتير')
p.branch(10, url(37, clear='37') + '&success_msg=#SUCCESS_MSG#')

p = app.page(38, 'Pay Supplier', 'PAY', 'سداد لمورد', scheme=TENANT, protection='N')
f = p.static('السداد', 10)
p.select('P38_SUP', f, 10, 'المورد', lov_sql=SUP_LOV, required=True)
p.date('P38_DATE', f, 20, 'التاريخ')
p.number('P38_AMOUNT', f, 30, 'المبلغ', required=True)
p.select('P38_PLACE', f, 40, 'الدفع من', lov_sql=PLACE_LOV, required=True)
p.select('P38_METHOD', f, 50, 'طريقة الدفع', null_text=None, lov_sql=METHOD_LOV)
p.text('P38_REF', f, 60, 'المرجع (رقم الحوالة / الشيك)')
p.text('P38_NOTES', f, 70, 'البيان')
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P38_DATE := nvl(:P38_DATE, to_char(sysdate, 'YYYY-MM-DD'));"])
b = p.button(f, 10, 'PAY', 'تنفيذ السداد (يخصص على الأقدم استحقاقاً)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Pay', ['declare l number;', 'begin',
    "    l := noona_pur_pkg.pay_supplier(json_object('sup' value to_number(:P38_SUP), 'date' value :P38_DATE, 'amount' value to_number(:P38_AMOUNT),",
    "        'place' value :P38_PLACE, 'method' value :P38_METHOD, 'ref' value :P38_REF, 'notes' value :P38_NOTES));", 'end;'], when_button=b,
    success='تم السداد وترحيل القيد وتحديث رصيد الصندوق أو البنك')
p.ir('الفواتير المفتوحة للمورد', 20, [
    "select o.invoice_id, o.doc_no, to_char(o.due_date, 'YYYY-MM-DD') as due_date, o.original_amount, o.open_amount,",
    '       greatest(trunc(sysdate) - o.due_date, 0) as days_late',
    "  from ap_open_item o where o.supplier_account_id = :P38_SUP and o.open_amount > 0 and o.item_type = 'INVOICE' order by o.due_date"],
    [('INVOICE_ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الفاتورة', {}), ('DUE_DATE', 'الاستحقاق', {}),
     ('ORIGINAL_AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('OPEN_AMOUNT', 'المتبقي', {'type': 'NUMBER'}), ('DAYS_LATE', 'أيام التأخير', {'type': 'NUMBER'})],
    titled=True)
p.branch(10, url(37) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 50) مركز التقارير (مرشحات موحدة)
REPORTS = [
    ('STOCK', 'أرصدة المخزون وقيمته', ['WH', 'CAT', 'ZERO']),
    ('CARD', 'بطاقة صنف (حركة تفصيلية)', ['ITEM', 'FROM', 'TO', 'WH']),
    ('EXPIRY', 'الدفعات المنتهية والقريبة الانتهاء', ['DAYS', 'WH']),
    ('REORDER', 'الأصناف تحت حد الطلب', []),
    ('FIT', 'بحث قطع الغيار بالمركبة', ['MAKE', 'MODEL', 'YEAR', 'WH']),
    ('PREG', 'سجل المشتريات', ['FROM', 'TO', 'SUP']),
    ('PITEM', 'المشتريات حسب الصنف', ['FROM', 'TO', 'CAT']),
    ('SSTMT', 'كشف حساب مورد', ['SUP', 'FROM', 'TO']),
    ('AGING', 'أعمار ديون الموردين', ['ASOF']),
]
p = app.page(50, 'Reports', 'REPORTS', 'تقارير سلسلة الإمداد', scheme=TENANT, protection='N')
f = p.static('التقرير والمرشحات', 10, opts='#DEFAULT#:nn-rpt-filters')
p.select('P50_REPORT', f, 5, 'التقرير', null_text=None, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n, _ in REPORTS))
p.date('P50_FROM', f, 10, 'من تاريخ')
p.date('P50_TO', f, 20, 'إلى تاريخ')
p.date('P50_ASOF', f, 25, 'في تاريخ')
p.select('P50_WH', f, 30, 'المستودع', lov_sql=WH_LOV, null_text='كل المستودعات')
p.select('P50_CAT', f, 40, 'الفئة', lov_sql=CAT_LOV, null_text='كل الفئات')
p.text('P50_ITEM', f, 50, 'الصنف (رقم / كود / باركود)', maxlen=60, width=25)
p.select('P50_SUP', f, 60, 'المورد', lov_sql=SUP_LOV, null_text='- اختر -')
p.number('P50_DAYS', f, 70, 'خلال (يوم)')
p.text('P50_MAKE', f, 80, 'شركة المركبة', maxlen=60, width=20)
p.text('P50_MODEL', f, 90, 'الطراز', maxlen=60, width=20)
p.number('P50_YEAR', f, 100, 'سنة الصنع')
p.yesno('P50_ZERO', f, 110, 'إظهار الأرصدة الصفرية')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P50_REPORT := nvl(:P50_REPORT, 'STOCK');",
    ":P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'));",
    ":P50_TO := nvl(:P50_TO, to_char(sysdate, 'YYYY-MM-DD'));",
    ":P50_ASOF := nvl(:P50_ASOF, to_char(sysdate, 'YYYY-MM-DD'));",
    ':P50_DAYS := nvl(:P50_DAYS, 90);'])
p.dynamic('التقرير', 20, [
    'declare',
    "    l_from date := to_date(:P50_FROM, 'YYYY-MM-DD');",
    "    l_to date := to_date(:P50_TO, 'YYYY-MM-DD');",
    "    l_card varchar2(300) := 'f?p=' || :APP_ID || ':50:' || :APP_SESSION || '::NO::P50_REPORT,P50_ITEM:CARD,';",
    'begin',
    '    return case :P50_REPORT',
    "        when 'STOCK' then noona_inv_pkg.stock_balance(:P50_WH, :P50_CAT, nvl(:P50_ZERO, 'N'),",
    "             'f?p=' || :APP_ID || ':11:' || :APP_SESSION || '::NO:RP:P11_ID:#ID#')",
    "        when 'CARD' then case when :P50_ITEM is null then '<div class=\"nn-empty\">أدخل رقم الصنف أو الباركود</div>'",
    '             else noona_inv_pkg.item_card(noona_inv_pkg.item_by_barcode(:P50_ITEM), l_from, l_to, :P50_WH) end',
    "        when 'EXPIRY' then noona_inv_pkg.expiry_report(:P50_DAYS, :P50_WH)",
    "        when 'REORDER' then noona_inv_pkg.reorder_report",
    "        when 'FIT' then noona_inv_pkg.fitment_search(:P50_MAKE, :P50_MODEL, :P50_YEAR, :P50_WH)",
    "        when 'PREG' then noona_pur_pkg.purchase_register(l_from, l_to, :P50_SUP, 'f?p=' || :APP_ID || ':35:' || :APP_SESSION || '::NO:RP:P35_ID:#ID#')",
    "        when 'PITEM' then noona_pur_pkg.purchases_by_item(l_from, l_to, :P50_CAT)",
    "        when 'SSTMT' then noona_pur_pkg.supplier_statement(:P50_SUP, l_from, l_to)",
    "        when 'AGING' then noona_pur_pkg.ap_aging(to_date(:P50_ASOF, 'YYYY-MM-DD'),",
    "             'f?p=' || :APP_ID || ':50:' || :APP_SESSION || '::NO::P50_REPORT,P50_SUP:SSTMT,#ID#')",
    '    end;',
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
FILTERS = ['FROM', 'TO', 'ASOF', 'WH', 'CAT', 'ITEM', 'SUP', 'DAYS', 'MAKE', 'MODEL', 'YEAR', 'ZERO']
p.onload([
    '(function () {',
    '    // المرشحات الموحدة: يظهر لكل تقرير ما يخصه فقط',
    '    var map = {' + ', '.join(f"{c}: {f!r}".replace("'", '"') for c, _, f in REPORTS) + '};',
    '    var all = ' + str(FILTERS).replace("'", '"') + ';',
    "    var sel = document.getElementById('P50_REPORT');",
    '    function sync() { var on = map[sel.value] || [];',
    "        all.forEach(function (k) { var c = document.getElementById('P50_' + k + '_CONTAINER'); if (c) c.style.display = on.indexOf(k) >= 0 ? '' : 'none'; }); }",
    "    sel.addEventListener('change', function () { sync(); apex.submit('RUN'); });",
    '    sync();',
    '})();'])

# =============================================================== القائمة
app.nav_item('لوحة سلسلة الإمداد', 1, 'fa-truck', 10)
it = app.nav_item('المخزون والأصناف', None, 'fa-cubes', 20)
app.nav_item('الأصناف', 10, 'fa-cube', 21, parent=it)
app.nav_item('صنف جديد', 11, 'fa-plus', 22, parent=it)
app.nav_item('حركات المخزون', 20, 'fa-exchange', 23, parent=it)
app.nav_item('مستند مخزون جديد', 21, 'fa-file-o', 24, parent=it)
app.nav_item('قائمة المواد والإنتاج', 13, 'fa-industry', 25, parent=it)
app.nav_item('الفئات وحساباتها', 12, 'fa-tags', 26, parent=it)
app.nav_item('المستودعات', 14, 'fa-building-o', 27, parent=it)
pu = app.nav_item('المشتريات والموردون', None, 'fa-shopping-cart', 30)
app.nav_item('فاتورة مشتريات جديدة', 35, 'fa-plus', 31, parent=pu)
app.nav_item('فواتير المشتريات والمرتجعات', 34, 'fa-files-o', 32, parent=pu)
app.nav_item('أوامر الشراء', 32, 'fa-file-text-o', 33, parent=pu)
app.nav_item('الموردون', 30, 'fa-users', 34, parent=pu)
app.nav_item('سداد الموردين', 37, 'fa-money', 35, parent=pu)
app.nav_item('التقارير', 50, 'fa-bar-chart', 40)

app.finalize()
print('NOONA_SCM built:', len(app.pages), 'pages')
