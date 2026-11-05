"""NOONA_TRN (النقل والشحن والترحيل): لوحة الحركة، أوامر الشحن بالتسعير التلقائي، الرحلات وشاشة الرحلة (الشحنات، نقاط التوقف،
التحرك والوصول والتسليم والإقفال، المصروفات، البلاغات)، الأعطال والبلاغات بالاستجابة، الأسطول، السائقون، المدن والمسارات،
أنواع الشحنات، تعرفة الترحيل، الفوترة، والتقارير.
الاستخدام: python3 tools/build_trn.py  ->  apex/NOONA_TRN/f147
المنطق كله في NOONA_TRN_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_TRN/f147'),
          app_id=147, alias='NOONA_TRN', name='NOONA Transport & Logistics', id_base=91820290000000000)
app.wire_security()
app.add_branding()
TRN = app.add_scheme('noona_trn_view', app.id(), 'NOONA - Transport',
                     "return noona_security_pkg.has_permission('TRN_TRIP.VIEW', noona_trn_pkg.company) = 'Y';",
                     'شاشات النقل تتطلب صلاحية عرض الرحلات / Transport access required')
SETUP = app.add_scheme('noona_trn_setup', app.id(), 'NOONA - Transport Setup',
                       "return noona_security_pkg.has_permission('TRN_VEHICLE.UPDATE', noona_trn_pkg.company) = 'Y';",
                       'إعداد النقل يتطلب صلاحية تعديل الأسطول / Setup access required')
CO = 'noona_trn_pkg.company'
READY = "noona_trn_pkg.is_ready = 'Y'"


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


def jsobj(pairs):
    """json_object من أزواج (المفتاح، العنصر، النوع N|S)"""
    parts = []
    for k, item, t in pairs:
        v = f'to_number(:{item})' if t == 'N' else f':{item}'
        parts.append(f"'{k}' value {v}")
    return 'json_object(' + ', '.join(parts) + ' absent on null)'


LOC_LOV = f"select name_ar || ' (' || code || ')' d, id r from trn_location where company_id = {CO} and is_active = 'Y' order by name_ar"
ROUTE_LOV = (f"select r.name_ar || ' · ' || r.distance_km || ' كم · ' || r.standard_hours || ' س' d, r.id r from trn_route r "
             f"where r.company_id = {CO} and r.is_active = 'Y' order by r.name_ar")
CARGO_LOV = f"select name_ar d, id r from trn_cargo_type where company_id = {CO} and is_active = 'Y' order by name_ar"
CUST_LOV = ("select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id "
            f"where a.company_id = {CO} and a.status_code = 'ACTIVE' and nvl(c.is_walk_in, 'N') = 'N' order by 1")
VEH_LOV = (f"select v.plate_no || ' · ' || v.vehicle_type || ' · ' || v.capacity_tons || ' طن · ' || noona_trn_pkg.status_label(v.status_code) d, v.id r "
           f"from trn_vehicle v where v.company_id = {CO} and v.status_code in ('AVAILABLE', 'ON_TRIP') order by v.plate_no")
DRV_LOV = (f"select d.full_name || ' · ' || d.license_no || ' · ' || noona_trn_pkg.status_label(d.status_code) d, d.id r from trn_driver d "
           f"where d.company_id = {CO} and d.status_code in ('AVAILABLE', 'ON_TRIP') order by d.full_name")
UOM = ('STATIC2:طن متري;METRIC_TON,طن قصير (أمريكي);SHORT_TON,طن طويل (بريطاني);LONG_TON,كيلوجرام;KG,متر مكعب;M3,لتر;LITER,'
       'حاوية;CONTAINER,طبلية;PALLET,قطعة;PIECE,رحلة;TRIP')
BASIS = ('STATIC2:للطن المتري;PER_METRIC_TON,للطن القصير;PER_SHORT_TON,للطن الطويل;PER_LONG_TON,للكيلوجرام;PER_KG,للمتر المكعب;PER_M3,'
         'للتر;PER_LITER,للكيلومتر;PER_KM,للطن-كيلومتر;PER_TON_KM,للرحلة;PER_TRIP,للحاوية;PER_CONTAINER,للطبلية;PER_PALLET,للقطعة;PER_PIECE')
VTYPE = ('STATIC2:شاحنة;TRUCK,مقطورة;TRAILER,صهريج;TANKER,مبردة;REFRIGERATED,سطحة;FLATBED,ناقلة حاويات;CONTAINER_CARRIER,قلاب;TIPPER,'
         'لوبد (معدات ثقيلة);LOWBED,بيك أب;PICKUP,فان;VAN')
INC_TYPE = ('STATIC2:عطل ميكانيكي;BREAKDOWN,إطار;TIRE,حادث;ACCIDENT,تأخير;DELAY,تلف الشحنة;CARGO_DAMAGE,سرقة;THEFT,إيقاف أمني/مروري;POLICE,'
            'طقس;WEATHER,إغلاق طريق;ROAD_CLOSURE,حالة صحية;MEDICAL,احتجاز حدودي;BORDER_HOLD,أخرى;OTHER')
SEV = 'STATIC2:منخفضة;LOW,متوسطة;MEDIUM,عالية;HIGH,حرجة;CRITICAL'
STOP = ('STATIC2:تحميل;LOADING,تفريغ;UNLOADING,استراحة;REST,تزود بالوقود;FUEL,نقطة تفتيش;CHECKPOINT,جمارك;CUSTOMS,منفذ حدودي;BORDER,'
        'ميزان;WEIGHBRIDGE,إصلاح;REPAIR,أخرى;OTHER')
EXP = ('STATIC2:وقود;FUEL,رسوم طرق;TOLL,بدل سائق;DRIVER_ALLOWANCE,تحميل;LOADING,تفريغ;UNLOADING,مواقف;PARKING,إصلاح;REPAIR,إطارات;TIRES,'
       'مخالفات;FINE,ميزان;WEIGHBRIDGE,جمارك;CUSTOMS,أخرى;OTHER')
CARGO_CAT = ('STATIC2:عامة;GENERAL,سائبة;BULK,سائلة;LIQUID,مبردة;REFRIGERATED,خطرة;HAZARDOUS,حاويات;CONTAINER,مركبات;VEHICLES,مواشي;LIVESTOCK,'
             'قابلة للكسر;FRAGILE,بأبعاد استثنائية;OVERSIZED')
LTYPE = ('STATIC2:مدينة;CITY,ميناء;PORT,مستودع;WAREHOUSE,مصنع;FACTORY,منفذ حدودي;BORDER,نقطة تفتيش;CHECKPOINT,محطة وقود;FUEL_STATION,'
         'استراحة;REST_AREA,موقع عميل;CUSTOMER_SITE,أخرى;OTHER')

# =============================================================== 1) لوحة الحركة
p = app.page(1, 'Home', 'HOME', 'النقل والشحن', scheme=TRN, protection='N')
st = p.static('تجهيز النقل والشحن', 5, condition="noona_trn_pkg.is_ready = 'N'",
              text='<p class="nn-hint">ينشئ حساب إيرادات النقل والشحن (4170) وأنواع شحنات افتراضية. أضف بعدها المدن والمسارات والعربات '
                   'والسائقين وتعرفة الترحيل. مرة واحدة لكل شركة.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز النقل والشحن', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_trn_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم التجهيز: حساب الإيرادات وأنواع الشحنات')
qa = p.static('إجراءات سريعة', 8, condition=READY)
p.button(qa, 10, 'NEW_ORDER', 'أمر شحن جديد', hot=True, redirect=url(11, clear='RP,11'))
p.button(qa, 20, 'NEW_TRIP', 'رحلة جديدة', redirect=url(22, clear='RP,22'))
p.button(qa, 30, 'NEW_INC', 'تسجيل عطل أو بلاغ', redirect=url(31, clear='RP,31'))
p.button(qa, 40, 'INVOICE', 'فوترة الترحيل', redirect=url(55))
p.dynamic('لوحة الحركة', 10, 'return noona_trn_pkg.board_html;', hide_header=True, condition=READY)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) أوامر الشحن
p = app.page(10, 'Shipment Orders', 'ORDERS', 'أوامر الشحن', scheme=TRN)
p.ir('أوامر الشحن', 10, [
    'select o.id, o.doc_no, o.doc_date, noona_sal_pkg.customer_label(o.customer_account_id) customer, f.name_ar from_loc, t.name_ar to_loc,',
    '       c.name_ar cargo, o.quantity, noona_trn_pkg.uom_label(o.uom_code) uom, round(o.weight_kg / 1000, 3) tons,',
    '       noona_trn_pkg.basis_label(o.rate_basis) basis, o.rate_amount, o.total_amount, o.pickup_date, o.required_delivery_date,',
    '       o.delivered_qty, o.shortage_qty, noona_trn_pkg.badge(o.status_code) status_html',
    '  from trn_order o join trn_location f on f.id = o.from_location_id join trn_location t on t.id = o.to_location_id',
    '  join trn_cargo_type c on c.id = o.cargo_type_id',
    f' where o.company_id = {CO} order by o.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرقم', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('CUSTOMER', 'العميل', {}), ('FROM_LOC', 'من', {}), ('TO_LOC', 'إلى', {}), ('CARGO', 'الشحنة', {}), ('QUANTITY', 'الكمية', {'type': 'NUMBER'}),
     ('UOM', 'الوحدة', {}), ('TONS', 'طن متري', {'type': 'NUMBER'}), ('BASIS', 'أساس السعر', {}), ('RATE_AMOUNT', 'السعر', {'type': 'NUMBER'}),
     ('TOTAL_AMOUNT', 'الترحيل', {'type': 'NUMBER'}), ('PICKUP_DATE', 'التحميل', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('REQUIRED_DELIVERY_DATE', 'التسليم المطلوب', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('DELIVERED_QTY', 'المسلم', {'type': 'NUMBER'}),
     ('SHORTAGE_QTY', 'العجز', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(11, 'P11_ID'))
r = p.static('أمر جديد', 5)
p.button(r, 10, 'NEW', 'أمر شحن جديد', hot=True, redirect=url(11, clear='RP,11'))

# =============================================================== 11) أمر الشحن
p = app.page(11, 'Shipment Order', 'ORDER', 'أمر شحن', scheme=TRN, protection='N')
f = p.static('بيانات الشحنة', 10)
p.hidden('P11_ID', f, 1, protected=False)
p.display('P11_INFO', f, 2, 'الأمر')
p.select('P11_CUST', f, 10, 'العميل', lov_sql=CUST_LOV, required=True)
p.text('P11_REF', f, 15, 'مرجع العميل', maxlen=100, width=20)
p.select('P11_FROM', f, 20, 'مكان التحميل', lov_sql=LOC_LOV, required=True)
p.select('P11_TO', f, 30, 'مكان التفريغ', lov_sql=LOC_LOV, required=True)
p.select('P11_CARGO', f, 40, 'نوع الشحنة', lov_sql=CARGO_LOV, required=True)
p.textarea('P11_DESC', f, 45, 'وصف البضاعة', rows=2)
p.number('P11_QTY', f, 50, 'الكمية', required=True)
p.select('P11_UOM', f, 60, 'الوحدة', lov_sql=UOM, null_text=None)
p.number('P11_KG', f, 70, 'الوزن بالكيلوجرام (يحسب تلقائياً للأطنان)')
p.number('P11_VOL', f, 80, 'الحجم (م³)')
p.number('P11_PKG', f, 90, 'عدد الطرود')
p.number('P11_VALUE', f, 100, 'القيمة المصرح بها')
p.date('P11_PICKUP', f, 110, 'تاريخ التحميل')
p.date('P11_DELIVERY', f, 120, 'تاريخ التسليم المطلوب')
p.number('P11_OTHER', f, 130, 'رسوم أخرى (تحميل، تفريغ، انتظار)')
pr = p.static('السعر', 20, text='<p class="nn-hint">يطبق تلقائياً أخص تعرفة سارية (العميل ثم المسار ثم نوع الشحنة). '
                              'لسعر متفق عليه خاص بهذا الأمر اختر الأساس وأدخل السعر.</p>')
p.select('P11_BASIS', pr, 10, 'أساس سعر يدوي (اختياري)', lov_sql=BASIS)
p.number('P11_RATE', pr, 20, 'السعر اليدوي')
p.display('P11_PRICE', pr, 30, 'الترحيل المحسوب')
p.textarea('P11_NOTES', pr, 40, 'ملاحظات', rows=2)
p.text('P11_REASON', pr, 50, 'سبب الإلغاء', maxlen=500, width=40)
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    '  for o in (select * from trn_order where id = :P11_ID and company_id = noona_trn_pkg.company) loop',
    '    :P11_CUST := o.customer_account_id; :P11_REF := o.customer_ref; :P11_FROM := o.from_location_id; :P11_TO := o.to_location_id;',
    '    :P11_CARGO := o.cargo_type_id; :P11_DESC := o.cargo_description; :P11_QTY := o.quantity; :P11_UOM := o.uom_code;',
    '    :P11_KG := o.weight_kg; :P11_VOL := o.volume_m3; :P11_PKG := o.packages_count; :P11_VALUE := o.declared_value;',
    "    :P11_PICKUP := to_char(o.pickup_date, 'YYYY-MM-DD'); :P11_DELIVERY := to_char(o.required_delivery_date, 'YYYY-MM-DD');",
    '    :P11_OTHER := o.other_charges; :P11_NOTES := o.notes;',
    "    :P11_INFO := o.doc_no || ' · ' || noona_trn_pkg.status_label(o.status_code);",
    "    :P11_PRICE := noona_trn_pkg.basis_label(o.rate_basis) || ' ' || o.rate_amount || ' = ' || to_char(o.freight_amount, 'FM999G999G990D00')",
    "                  || ' + رسوم ' || to_char(o.other_charges, 'FM999G990D00') || ' = ' || to_char(o.total_amount, 'FM999G999G990D00');",
    '    if o.rate_id is null then :P11_BASIS := o.rate_basis; :P11_RATE := o.rate_amount; end if;',
    '  end loop;',
    'end;'])
b_save = p.button(f, 10, 'SAVE', 'حفظ وتسعير', hot=True)
b_conf = p.button(f, 20, 'CONFIRM', 'تأكيد الأمر', condition="noona_trn_pkg.order_status(:P11_ID) = 'DRAFT'")
b_can = p.button(pr, 10, 'CANCEL_ORDER', 'إلغاء الأمر', condition="noona_trn_pkg.order_status(:P11_ID) in ('DRAFT','CONFIRMED')")
DOC = jsobj([('id', 'P11_ID', 'N'), ('customer', 'P11_CUST', 'N'), ('customerRef', 'P11_REF', 'S'), ('from', 'P11_FROM', 'N'),
             ('to', 'P11_TO', 'N'), ('cargo', 'P11_CARGO', 'N'), ('description', 'P11_DESC', 'S'), ('qty', 'P11_QTY', 'N'),
             ('uom', 'P11_UOM', 'S'), ('weightKg', 'P11_KG', 'N'), ('volume', 'P11_VOL', 'N'), ('packages', 'P11_PKG', 'N'),
             ('declaredValue', 'P11_VALUE', 'N'), ('pickupDate', 'P11_PICKUP', 'S'), ('deliveryDate', 'P11_DELIVERY', 'S'),
             ('otherCharges', 'P11_OTHER', 'N'), ('basis', 'P11_BASIS', 'S'), ('rate', 'P11_RATE', 'N'), ('notes', 'P11_NOTES', 'S')])
p.process(20, 'AFTER_SUBMIT', 'Save', ['declare l clob;', 'begin', f'  select {DOC} into l from dual;',
                                       '  :P11_ID := noona_trn_pkg.save_order(l);', 'end;'], when_button=b_save, success='تم حفظ أمر الشحن وتسعيره')
p.process(30, 'AFTER_SUBMIT', 'Confirm', 'noona_trn_pkg.confirm_order(:P11_ID);', when_button=b_conf, success='تم تأكيد الأمر؛ جاهز للتحميل على رحلة')
p.process(40, 'AFTER_SUBMIT', 'Cancel', 'noona_trn_pkg.cancel_order(:P11_ID, :P11_REASON);', when_button=b_can, success='تم إلغاء الأمر')
p.branch(10, url(11, 'P11_ID', '&P11_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) الرحلات
p = app.page(20, 'Trips', 'TRIPS', 'الرحلات', scheme=TRN)
r = p.static('رحلة جديدة', 5)
p.button(r, 10, 'NEW', 'رحلة جديدة', hot=True, redirect=url(22, clear='RP,22'))
p.ir('الرحلات', 10, [
    'select t.id, t.doc_no, v.plate_no, d.full_name driver, f.name_ar from_loc, tl.name_ar to_loc, t.planned_departure, t.actual_departure, t.eta,',
    '       t.actual_arrival, t.delay_minutes, round(t.load_kg / 1000, 2) tons, t.actual_distance_km, t.revenue_amount, t.expense_amount,',
    '       t.revenue_amount - t.expense_amount net_amount, noona_trn_pkg.badge(t.status_code) status_html,',
    '       noona_trn_pkg.badge(noona_trn_pkg.timeliness(t.id)) time_html',
    '  from trn_trip t join trn_vehicle v on v.id = t.vehicle_id join trn_driver d on d.id = t.driver_id',
    '  join trn_location f on f.id = t.from_location_id join trn_location tl on tl.id = t.to_location_id',
    f' where t.company_id = {CO} order by t.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الرحلة', {}), ('PLATE_NO', 'العربة', {}), ('DRIVER', 'السائق', {}),
     ('FROM_LOC', 'من', {}), ('TO_LOC', 'إلى', {}), ('PLANNED_DEPARTURE', 'التحرك المخطط', {}), ('ACTUAL_DEPARTURE', 'التحرك الفعلي', {}),
     ('ETA', 'الوصول المتوقع', {}), ('ACTUAL_ARRIVAL', 'الوصول الفعلي', {}), ('DELAY_MINUTES', 'التأخير (د)', {'type': 'NUMBER'}),
     ('TONS', 'الحمولة (طن)', {'type': 'NUMBER'}), ('ACTUAL_DISTANCE_KM', 'المسافة (كم)', {'type': 'NUMBER'}),
     ('REVENUE_AMOUNT', 'الإيراد', {'type': 'NUMBER'}), ('EXPENSE_AMOUNT', 'المصروف', {'type': 'NUMBER'}), ('NET_AMOUNT', 'الصافي', {'type': 'NUMBER'}),
     ('STATUS_HTML', 'الحالة', {'html': True}), ('TIME_HTML', 'المواعيد', {'html': True})], link=link(21, 'P21_ID'))

# =============================================================== 22) رحلة جديدة
p = app.page(22, 'New Trip', 'NEW-TRIP', 'رحلة جديدة', scheme=TRN, protection='N')
f = p.static('الرحلة', 10, text='<p class="nn-hint">يتحقق النظام من توفر العربة والسائق وسريان الرخص والتأمين، ومن الحمولة ونوع العربة '
                               'والمواد الخطرة لكل شحنة. زمن الوصول المتوقع من الزمن القياسي للمسار ونقاط التوقف.</p>')
p.select('P22_VEH', f, 10, 'العربة', lov_sql=VEH_LOV, required=True)
p.select('P22_DRV', f, 20, 'السائق', lov_sql=DRV_LOV, required=True)
p.select('P22_CODRV', f, 30, 'السائق المساعد', lov_sql=DRV_LOV)
p.select('P22_ROUTE', f, 40, 'المسار', lov_sql=ROUTE_LOV)
p.select('P22_FROM', f, 50, 'أو من', lov_sql=LOC_LOV)
p.select('P22_TO', f, 60, 'إلى', lov_sql=LOC_LOV)
p.text('P22_DEP', f, 70, 'موعد التحرك (YYYY-MM-DD HH24:MI)', required=True, maxlen=16, width=16)
p.checkboxes('P22_ORDERS', f, 80, 'الشحنات المؤكدة المراد تحميلها', (
    "select o.doc_no || ' · ' || noona_sal_pkg.customer_label(o.customer_account_id) || ' · ' || noona_trn_pkg.order_label(o.id) d, o.id r "
    f"from trn_order o where o.company_id = {CO} and o.status_code = 'CONFIRMED' order by o.pickup_date nulls last, o.id"), columns=1)
p.textarea('P22_NOTES', f, 90, 'ملاحظات', rows=2)
p.process(10, 'BEFORE_HEADER', 'Defaults', "if :P22_DEP is null then :P22_DEP := to_char(sysdate + 1/24, 'YYYY-MM-DD HH24') || ':00'; end if;")
b = p.button(f, 10, 'CREATE', 'إنشاء الرحلة', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Create', [
    'declare l clob; l_o varchar2(4000);',
    'begin',
    "  l_o := '[' || replace(:P22_ORDERS, ':', ',') || ']';",
    "  select json_object('vehicle' value to_number(:P22_VEH), 'driver' value to_number(:P22_DRV), 'coDriver' value to_number(:P22_CODRV),",
    "         'route' value to_number(:P22_ROUTE), 'from' value to_number(:P22_FROM), 'to' value to_number(:P22_TO), 'departure' value :P22_DEP,",
    "         'notes' value :P22_NOTES, 'orders' value l_o format json absent on null) into l from dual;",
    '  :P21_ID := noona_trn_pkg.create_trip(l);',
    'end;'], when_button=b, success='تم إنشاء الرحلة')
p.hidden('P22_DUMMY', f, 100)
p.branch(10, url(21, 'P21_ID', '&P21_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 21) شاشة الرحلة
p = app.page(21, 'Trip', 'TRIP', 'الرحلة', scheme=TRN, protection='N')
h = p.dynamic('الرحلة', 5, 'return noona_trn_pkg.trip_html(:P21_ID);', hide_header=True)
p.hidden('P21_ID', h, 1, protected=False)
ST = lambda s: f"noona_trn_pkg.trip_status(:P21_ID) in ({s})"
# الشحنات
p.ir('الشحنات', 10, [
    'select o.id, o.doc_no, noona_sal_pkg.customer_label(o.customer_account_id) customer, c.name_ar cargo, o.quantity, noona_trn_pkg.uom_label(o.uom_code) uom,',
    '       round(x.loaded_kg / 1000, 3) tons, f.name_ar from_loc, tl.name_ar to_loc, o.total_amount, o.delivered_qty, o.shortage_qty, o.receiver_name,',
    '       o.delivered_at, o.damage_notes, noona_trn_pkg.badge(o.status_code) status_html',
    '  from trn_trip_order x join trn_order o on o.id = x.order_id join trn_cargo_type c on c.id = o.cargo_type_id',
    '  join trn_location f on f.id = o.from_location_id join trn_location tl on tl.id = o.to_location_id',
    ' where x.trip_id = :P21_ID order by o.id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الأمر', {}), ('CUSTOMER', 'العميل', {}), ('CARGO', 'الشحنة', {}),
     ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('UOM', 'الوحدة', {}), ('TONS', 'طن', {'type': 'NUMBER'}), ('FROM_LOC', 'من', {}), ('TO_LOC', 'إلى', {}),
     ('TOTAL_AMOUNT', 'الترحيل', {'type': 'NUMBER'}), ('DELIVERED_QTY', 'المسلم', {'type': 'NUMBER'}), ('SHORTAGE_QTY', 'العجز', {'type': 'NUMBER'}),
     ('RECEIVER_NAME', 'المستلم', {}), ('DELIVERED_AT', 'وقت التسليم', {}), ('DAMAGE_NOTES', 'الأضرار', {}), ('STATUS_HTML', 'الحالة', {'html': True})],
    titled=True, rows=25)
s = p.static('إضافة أو إخراج شحنة', 15, condition=ST("'PLANNED'"))
p.select('P21_ADD_ORDER', s, 10, 'شحنة مؤكدة', lov_sql=(
    f"select noona_trn_pkg.order_label(o.id) d, o.id r from trn_order o where o.company_id = {CO} and o.status_code = 'CONFIRMED' order by o.id"))
p.select('P21_DEL_ORDER', s, 20, 'شحنة في الرحلة', lov_sql=(
    "select noona_trn_pkg.order_label(x.order_id) d, x.order_id r from trn_trip_order x where x.trip_id = :P21_ID order by 1"))
b_add = p.button(s, 10, 'ADD_ORDER', 'تحميل على الرحلة')
b_del = p.button(s, 20, 'DEL_ORDER', 'إخراج من الرحلة')
p.process(20, 'AFTER_SUBMIT', 'Add Order', 'noona_trn_pkg.add_order(:P21_ID, :P21_ADD_ORDER);', when_button=b_add, success='تم تحميل الشحنة')
p.process(21, 'AFTER_SUBMIT', 'Remove Order', 'noona_trn_pkg.remove_order(:P21_ID, :P21_DEL_ORDER);', when_button=b_del, success='أخرجت الشحنة')
# نقاط التوقف
p.ir('نقاط التوقف', 20, [
    "select s.id, s.sort_order, l.name_ar location, decode(s.stop_purpose, 'LOADING', 'تحميل', 'UNLOADING', 'تفريغ', 'REST', 'استراحة', 'FUEL', 'وقود',",
    "       'CHECKPOINT', 'تفتيش', 'CUSTOMS', 'جمارك', 'BORDER', 'حدود', 'WEIGHBRIDGE', 'ميزان', 'REPAIR', 'إصلاح', 'أخرى') purpose,",
    '       s.planned_minutes, s.actual_arrival, s.actual_departure,',
    '       round((cast(s.actual_departure as date) - cast(s.actual_arrival as date)) * 1440) actual_minutes',
    '  from trn_trip_stop s join trn_location l on l.id = s.location_id where s.trip_id = :P21_ID order by s.sort_order, s.id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('SORT_ORDER', 'الترتيب', {'type': 'NUMBER'}), ('LOCATION', 'الموقع', {}), ('PURPOSE', 'الغرض', {}),
     ('PLANNED_MINUTES', 'المخطط (د)', {'type': 'NUMBER'}), ('ACTUAL_ARRIVAL', 'الوصول', {}), ('ACTUAL_DEPARTURE', 'المغادرة', {}),
     ('ACTUAL_MINUTES', 'الفعلي (د)', {'type': 'NUMBER'})], titled=True, rows=25)
s = p.static('نقاط التوقف', 25, condition=ST("'PLANNED','DISPATCHED','IN_TRANSIT'"))
p.select('P21_STOP_LOC', s, 10, 'الموقع', lov_sql=LOC_LOV)
p.select('P21_STOP_PURPOSE', s, 20, 'الغرض', lov_sql=STOP, null_text=None)
p.number('P21_STOP_MIN', s, 30, 'المدة المخططة (دقيقة)')
p.select('P21_STOP', s, 40, 'نقطة للتسجيل', lov_sql=(
    "select s.sort_order || ' · ' || l.name_ar || case when s.actual_arrival is null then ' (لم يصل)' when s.actual_departure is null then ' (متوقف)' else ' (غادر)' end d, s.id r "
    "from trn_trip_stop s join trn_location l on l.id = s.location_id where s.trip_id = :P21_ID order by s.sort_order"))
b_stop = p.button(s, 10, 'ADD_STOP', 'إضافة نقطة توقف')
b_sarr = p.button(s, 20, 'STOP_ARRIVE', 'وصل للنقطة')
b_sdep = p.button(s, 30, 'STOP_DEPART', 'غادر النقطة')
b_sdel = p.button(s, 40, 'STOP_DEL', 'حذف النقطة')
p.process(30, 'AFTER_SUBMIT', 'Add Stop', ['declare l number;', 'begin',
          '  l := noona_trn_pkg.add_stop(:P21_ID, :P21_STOP_LOC, :P21_STOP_PURPOSE, nvl(to_number(:P21_STOP_MIN), 0));', 'end;'],
          when_button=b_stop, success='أضيفت نقطة التوقف وتحدث زمن الوصول المتوقع')
p.process(31, 'AFTER_SUBMIT', 'Stop Arrive', 'noona_trn_pkg.stop_arrive(:P21_STOP);', when_button=b_sarr, success='سجل الوصول للنقطة')
p.process(32, 'AFTER_SUBMIT', 'Stop Depart', 'noona_trn_pkg.stop_depart(:P21_STOP);', when_button=b_sdep, success='سجلت المغادرة (يضاف أي تجاوز للتأخير)')
p.process(33, 'AFTER_SUBMIT', 'Stop Delete', 'noona_trn_pkg.remove_stop(:P21_STOP);', when_button=b_sdel, success='حذفت النقطة')
# حركة الرحلة
a = p.static('حركة الرحلة', 30, condition=ST("'PLANNED','IN_TRANSIT','ARRIVED'"))
p.number('P21_ODO', a, 10, 'قراءة العداد (كم)')
p.number('P21_FUEL', a, 20, 'إجمالي الوقود (لتر) عند الإقفال')
p.text('P21_REASON', a, 30, 'سبب الإلغاء', maxlen=500, width=40)
b_dep = p.button(a, 10, 'DEPART', 'تحرك الرحلة', hot=True, condition=ST("'PLANNED'"))
b_arr = p.button(a, 20, 'ARRIVE', 'وصلت الرحلة', condition=ST("'IN_TRANSIT'"))
b_cmp = p.button(a, 30, 'COMPLETE', 'إقفال الرحلة', condition=ST("'IN_TRANSIT','ARRIVED'"))
b_cnl = p.button(a, 40, 'CANCEL_TRIP', 'إلغاء الرحلة', condition=ST("'PLANNED'"))
p.process(40, 'AFTER_SUBMIT', 'Depart', 'noona_trn_pkg.depart(:P21_ID, to_number(:P21_ODO));', when_button=b_dep, success='تحركت الرحلة')
p.process(41, 'AFTER_SUBMIT', 'Arrive', 'noona_trn_pkg.arrive(:P21_ID);', when_button=b_arr, success='سجل وصول الرحلة')
p.process(42, 'AFTER_SUBMIT', 'Complete', 'noona_trn_pkg.complete_trip(:P21_ID, to_number(:P21_ODO), to_number(:P21_FUEL));',
          when_button=b_cmp, success='أقفلت الرحلة؛ العربة والسائق متاحان')
p.process(43, 'AFTER_SUBMIT', 'Cancel', 'noona_trn_pkg.cancel_trip(:P21_ID, :P21_REASON);', when_button=b_cnl, success='ألغيت الرحلة')
# التسليم
dl = p.static('التسليم والتفريغ', 35, condition=ST("'IN_TRANSIT','ARRIVED'"))
p.select('P21_DLV_ORDER', dl, 10, 'الشحنة', lov_sql=(
    "select noona_trn_pkg.order_label(o.id) d, o.id r from trn_trip_order x join trn_order o on o.id = x.order_id "
    "where x.trip_id = :P21_ID and o.status_code = 'IN_TRANSIT' order by o.id"))
p.number('P21_DLV_QTY', dl, 20, 'الكمية المسلمة')
p.text('P21_DLV_RCV', dl, 30, 'المستلم', maxlen=200, width=30)
p.text('P21_DLV_DMG', dl, 40, 'الأضرار (إن وجدت)', maxlen=1000, width=40)
b_dlv = p.button(dl, 10, 'DELIVER', 'تسجيل التسليم', hot=True)
p.process(50, 'AFTER_SUBMIT', 'Deliver', 'noona_trn_pkg.deliver_order(:P21_ID, :P21_DLV_ORDER, to_number(:P21_DLV_QTY), :P21_DLV_RCV, :P21_DLV_DMG);',
          when_button=b_dlv, success='سجل التسليم (والعجز إن وجد)')
# المصروفات
p.ir('مصروفات الرحلة', 40, [
    "select e.id, e.expense_date, decode(e.expense_type, 'FUEL', 'وقود', 'TOLL', 'رسوم طرق', 'DRIVER_ALLOWANCE', 'بدل سائق', 'LOADING', 'تحميل',",
    "       'UNLOADING', 'تفريغ', 'PARKING', 'مواقف', 'REPAIR', 'إصلاح', 'TIRES', 'إطارات', 'FINE', 'مخالفات', 'WEIGHBRIDGE', 'ميزان', 'CUSTOMS', 'جمارك', 'أخرى') expense_type,",
    '       e.amount, e.liters, e.reference_no, e.notes from trn_trip_expense e where e.trip_id = :P21_ID order by e.expense_date, e.id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('EXPENSE_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('EXPENSE_TYPE', 'النوع', {}),
     ('AMOUNT', 'المبلغ', {'type': 'NUMBER'}), ('LITERS', 'لتر', {'type': 'NUMBER'}), ('REFERENCE_NO', 'الإيصال', {}), ('NOTES', 'ملاحظات', {})],
    titled=True, rows=25)
ex = p.static('مصروف جديد', 45, condition="noona_trn_pkg.trip_status(:P21_ID) <> 'CANCELLED'")
p.select('P21_EXP_TYPE', ex, 10, 'النوع', lov_sql=EXP, null_text=None)
p.number('P21_EXP_AMT', ex, 20, 'المبلغ')
p.number('P21_EXP_L', ex, 30, 'اللترات (للوقود)')
p.text('P21_EXP_REF', ex, 40, 'رقم الإيصال', maxlen=100, width=15)
b_exp = p.button(ex, 10, 'ADD_EXP', 'إضافة المصروف')
p.process(60, 'AFTER_SUBMIT', 'Expense', ['declare l number;', 'begin',
          '  l := noona_trn_pkg.add_expense(:P21_ID, :P21_EXP_TYPE, to_number(:P21_EXP_AMT), to_number(:P21_EXP_L), trunc(sysdate), :P21_EXP_REF);',
          'end;'], when_button=b_exp, success='أضيف المصروف')
# البلاغات
p.ir('الأعطال والبلاغات', 50, [
    'select i.id, i.doc_no, i.reported_at, noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, i.description, i.assigned_to, i.response_action, i.downtime_minutes, i.cost_amount,',
    '       noona_trn_pkg.badge(i.status_code) status_html from trn_incident i where i.trip_id = :P21_ID order by i.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'البلاغ', {}), ('REPORTED_AT', 'الوقت', {}), ('INCIDENT_TYPE', 'النوع', {}),
     ('SEVERITY', 'الخطورة', {}), ('DESCRIPTION', 'الوصف', {}), ('ASSIGNED_TO', 'المكلف', {}), ('RESPONSE_ACTION', 'الاستجابة', {}),
     ('DOWNTIME_MINUTES', 'التوقف (د)', {'type': 'NUMBER'}), ('COST_AMOUNT', 'التكلفة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    link=link(31, 'P31_ID'), titled=True, rows=25)
ib = p.static('بلاغ', 55)
p.button(ib, 10, 'NEW_INC', 'تسجيل عطل أو بلاغ لهذه الرحلة', redirect=url(31, 'P31_TRIP', '&P21_ID.', 'RP,31'))
p.branch(10, url(21, 'P21_ID', '&P21_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) الأعطال والبلاغات
p = app.page(30, 'Incidents', 'INCIDENTS', 'الأعطال والبلاغات', scheme=TRN)
r = p.static('بلاغ جديد', 5)
p.button(r, 10, 'NEW', 'تسجيل عطل أو بلاغ', hot=True, redirect=url(31, clear='RP,31'))
p.ir('الأعطال والبلاغات', 10, [
    'select i.id, i.doc_no, i.reported_at, t.doc_no trip_no, v.plate_no, d.full_name driver, noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, i.location_text, i.description,',
    '       i.assigned_to, round((cast(i.acknowledged_at as date) - cast(i.reported_at as date)) * 1440) ack_minutes,',
    '       round((cast(i.resolved_at as date) - cast(i.reported_at as date)) * 1440) resolve_minutes, i.downtime_minutes, i.cost_amount,',
    '       noona_trn_pkg.badge(i.status_code) status_html',
    '  from trn_incident i join trn_vehicle v on v.id = i.vehicle_id left join trn_trip t on t.id = i.trip_id left join trn_driver d on d.id = i.driver_id',
    f' where i.company_id = {CO} order by i.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'البلاغ', {}), ('REPORTED_AT', 'الوقت', {}), ('TRIP_NO', 'الرحلة', {}),
     ('PLATE_NO', 'العربة', {}), ('DRIVER', 'السائق', {}), ('INCIDENT_TYPE', 'النوع', {}), ('SEVERITY', 'الخطورة', {}), ('LOCATION_TEXT', 'المكان', {}),
     ('DESCRIPTION', 'الوصف', {}), ('ASSIGNED_TO', 'المكلف', {}), ('ACK_MINUTES', 'زمن الاستلام (د)', {'type': 'NUMBER'}),
     ('RESOLVE_MINUTES', 'زمن الحل (د)', {'type': 'NUMBER'}), ('DOWNTIME_MINUTES', 'التوقف (د)', {'type': 'NUMBER'}),
     ('COST_AMOUNT', 'التكلفة', {'type': 'NUMBER'}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(31, 'P31_ID'))

# =============================================================== 31) البلاغ
p = app.page(31, 'Incident', 'INCIDENT', 'عطل أو بلاغ', scheme=TRN, protection='N')
f = p.static('البلاغ', 10, condition=':P31_ID is null')
p.hidden('P31_ID', f, 1, protected=False)
p.select('P31_TRIP', f, 10, 'الرحلة', lov_sql=(
    "select t.doc_no || ' · ' || v.plate_no || ' · ' || d.full_name d, t.id r from trn_trip t join trn_vehicle v on v.id = t.vehicle_id "
    f"join trn_driver d on d.id = t.driver_id where t.company_id = {CO} and t.status_code in ('PLANNED','DISPATCHED','IN_TRANSIT','ARRIVED') order by t.id desc"))
p.select('P31_VEH', f, 20, 'أو العربة (خارج رحلة)', lov_sql=f"select plate_no d, id r from trn_vehicle where company_id = {CO} order by plate_no")
p.select('P31_TYPE', f, 30, 'النوع', lov_sql=INC_TYPE, null_text=None)
p.select('P31_SEV', f, 40, 'الخطورة', lov_sql=SEV, null_text=None)
p.textarea('P31_DESC', f, 50, 'الوصف', required=True, rows=3)
p.select('P31_LOC', f, 60, 'أقرب موقع', lov_sql=LOC_LOV)
p.text('P31_LOC_TXT', f, 70, 'وصف المكان (كيلومتر، طريق...)', maxlen=500, width=40)
p.text('P31_BY', f, 80, 'المبلّغ', maxlen=200, width=25)
b_rep = p.button(f, 10, 'REPORT', 'تسجيل البلاغ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Report', ['declare l clob;', 'begin',
    "  select json_object('trip' value to_number(:P31_TRIP), 'vehicle' value to_number(:P31_VEH), 'type' value :P31_TYPE, 'severity' value :P31_SEV,",
    "         'description' value :P31_DESC, 'location' value to_number(:P31_LOC), 'locationText' value :P31_LOC_TXT, 'reportedBy' value :P31_BY",
    '         absent on null) into l from dual;',
    '  :P31_ID := noona_trn_pkg.report_incident(l);', 'end;'], when_button=b_rep, success='سجل البلاغ؛ تابع الاستجابة من هنا')
v = p.dynamic('تفاصيل البلاغ', 15, [
    'declare l clob;', 'begin',
    '  for i in (select i.*, v.plate_no, t.doc_no trip_no from trn_incident i join trn_vehicle v on v.id = i.vehicle_id left join trn_trip t on t.id = i.trip_id',
    '             where i.id = :P31_ID and i.company_id = noona_trn_pkg.company) loop',
    "    l := '<dl class=\"nn-trn-facts\"><div><dt>البلاغ</dt><dd>' || apex_escape.html(i.doc_no) || ' ' || noona_trn_pkg.badge(i.status_code) || '</dd></div>'",
    "      || '<div><dt>العربة</dt><dd>' || apex_escape.html(i.plate_no) || '</dd></div><div><dt>الرحلة</dt><dd>' || apex_escape.html(nvl(i.trip_no, '—')) || '</dd></div>'",
    "      || '<div><dt>النوع / الخطورة</dt><dd>' || i.incident_type || ' / ' || i.severity || '</dd></div>'",
    "      || '<div><dt>وقت البلاغ</dt><dd>' || to_char(i.reported_at, 'YYYY-MM-DD HH24:MI') || '</dd></div>'",
    "      || '<div><dt>الاستلام</dt><dd>' || nvl(to_char(i.acknowledged_at, 'YYYY-MM-DD HH24:MI'), '—') || '</dd></div>'",
    "      || '<div><dt>الحل</dt><dd>' || nvl(to_char(i.resolved_at, 'YYYY-MM-DD HH24:MI'), '—') || '</dd></div>'",
    "      || '<div><dt>المكلف</dt><dd>' || apex_escape.html(nvl(i.assigned_to, '—')) || '</dd></div>'",
    "      || '<div><dt>الوصف</dt><dd>' || apex_escape.html(i.description) || '</dd></div>'",
    "      || '<div><dt>الاستجابة</dt><dd>' || apex_escape.html(nvl(i.response_action, '—')) || '</dd></div></dl>';",
    '  end loop;', '  return l;', 'end;'], condition=':P31_ID is not null')
w = p.static('الاستجابة', 20, condition="noona_trn_pkg.incident_status(:P31_ID) in ('REPORTED','ACKNOWLEDGED','IN_PROGRESS','RESOLVED')")
p.text('P31_ASSIGN', w, 10, 'المكلف بالاستجابة', maxlen=200, width=30)
p.textarea('P31_ACTION', w, 20, 'الإجراء', rows=2)
p.number('P31_DOWN', w, 30, 'مدة التوقف (دقيقة)')
p.number('P31_COST', w, 40, 'التكلفة')
I = lambda s: f"noona_trn_pkg.incident_status(:P31_ID) in ({s})"
b_ack = p.button(w, 10, 'ACK', 'استلام وتكليف', condition=I("'REPORTED'"))
b_rsp = p.button(w, 20, 'RESPOND', 'بدء الاستجابة', condition=I("'REPORTED','ACKNOWLEDGED'"))
b_res = p.button(w, 30, 'RESOLVE', 'تم الحل', hot=True, condition=I("'REPORTED','ACKNOWLEDGED','IN_PROGRESS'"))
b_cls = p.button(w, 40, 'CLOSE', 'إغلاق البلاغ', condition=I("'RESOLVED'"))
p.process(30, 'AFTER_SUBMIT', 'Ack', 'noona_trn_pkg.acknowledge_incident(:P31_ID, :P31_ASSIGN);', when_button=b_ack, success='استلم البلاغ')
p.process(31, 'AFTER_SUBMIT', 'Respond', 'noona_trn_pkg.respond_incident(:P31_ID, :P31_ACTION);', when_button=b_rsp, success='بدأت الاستجابة')
p.process(32, 'AFTER_SUBMIT', 'Resolve', 'noona_trn_pkg.resolve_incident(:P31_ID, :P31_ACTION, to_number(:P31_DOWN), to_number(:P31_COST));',
          when_button=b_res, success='تم الحل؛ أضيف التوقف لتأخير الرحلة والتكلفة لمصروفاتها')
p.process(33, 'AFTER_SUBMIT', 'Close', 'noona_trn_pkg.close_incident(:P31_ID);', when_button=b_cls, success='أغلق البلاغ')
p.branch(10, url(31, 'P31_ID', '&P31_ID.') + '&success_msg=#SUCCESS_MSG#')


# =============================================================== صفحات الإعداد: قائمة + نموذج على نفس الصفحة
def master(pid, alias, title, ir_sql, cols, form, save_call, nav_scheme=SETUP):
    p = app.page(pid, alias.title(), alias, title, scheme=nav_scheme)
    p.ir(title, 10, ir_sql, cols, link=f'f?p=&APP_ID.:{pid}:&SESSION.::&DEBUG.:RP:P{pid}_ID:#ID#')
    f = p.static('إضافة / تعديل', 20)
    p.hidden(f'P{pid}_ID', f, 1)
    pairs = [('id', f'P{pid}_ID', 'N')]
    for seq, (key, item, kind, label, extra) in enumerate(form, 1):
        name = f'P{pid}_{item}'
        if kind == 'T':
            p.text(name, f, seq * 10, label, maxlen=extra or 200, width=30)
        elif kind == 'N':
            p.number(name, f, seq * 10, label)
        elif kind == 'D':
            p.date(name, f, seq * 10, label)
        elif kind == 'S':
            p.select(name, f, seq * 10, label, lov_sql=extra)
        elif kind == 'S1':
            p.select(name, f, seq * 10, label, lov_sql=extra, null_text=None)
        elif kind == 'YN':
            p.yesno(name, f, seq * 10, label)
        pairs.append((key, name, 'N' if kind == 'N' else 'S'))
    b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l clob; l_id number;', 'begin', f'  select {jsobj(pairs)} into l from dual;',
                                           f'  l_id := {save_call}(l);', 'end;'], when_button=b, success='تم الحفظ')
    p.branch(10, f'f?p=&APP_ID.:{pid}:&SESSION.::&DEBUG.:RP,{pid}::&success_msg=#SUCCESS_MSG#')
    return p


# 40) الأسطول
p = master(40, 'FLEET', 'العربات والشاحنات', [
    "select v.id, v.plate_no, decode(v.vehicle_type, 'TRUCK', 'شاحنة', 'TRAILER', 'مقطورة', 'TANKER', 'صهريج', 'REFRIGERATED', 'مبردة', 'FLATBED', 'سطحة',",
    "       'CONTAINER_CARRIER', 'ناقلة حاويات', 'TIPPER', 'قلاب', 'LOWBED', 'لوبد', 'PICKUP', 'بيك أب', 'VAN', 'فان', v.vehicle_type) vehicle_type,",
    '       v.make, v.model, v.model_year, v.capacity_tons, v.capacity_m3, v.odometer_km, v.license_expiry, v.insurance_expiry,',
    "       noona_trn_pkg.badge(v.status_code) status_html,",
    "       (select count(*) from trn_trip t where t.vehicle_id = v.id and t.status_code = 'COMPLETED') trips,",
    "       (select count(*) from trn_incident i where i.vehicle_id = v.id) incidents",
    f'  from trn_vehicle v where v.company_id = {CO} order by v.plate_no'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PLATE_NO', 'اللوحة', {}), ('VEHICLE_TYPE', 'النوع', {}), ('MAKE', 'الصانع', {}),
     ('MODEL', 'الطراز', {}), ('MODEL_YEAR', 'السنة', {'type': 'NUMBER'}), ('CAPACITY_TONS', 'الحمولة (طن)', {'type': 'NUMBER'}),
     ('CAPACITY_M3', 'م³', {'type': 'NUMBER'}), ('ODOMETER_KM', 'العداد', {'type': 'NUMBER'}),
     ('LICENSE_EXPIRY', 'انتهاء الترخيص', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('INSURANCE_EXPIRY', 'انتهاء التأمين', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('STATUS_HTML', 'الحالة', {'html': True}), ('TRIPS', 'الرحلات', {'type': 'NUMBER'}), ('INCIDENTS', 'البلاغات', {'type': 'NUMBER'})],
    [('plate', 'PLATE', 'T', 'رقم اللوحة', 30), ('type', 'TYPE', 'S1', 'النوع', VTYPE), ('make', 'MAKE', 'T', 'الصانع', 100),
     ('model', 'MODEL', 'T', 'الطراز', 100), ('year', 'YEAR', 'N', 'سنة الصنع', None), ('capacityTons', 'CAP', 'N', 'الحمولة القصوى (طن متري)', None),
     ('capacityM3', 'M3', 'N', 'السعة (م³)', None), ('odometer', 'ODO', 'N', 'العداد (كم)', None), ('fuelPer100', 'FUEL', 'N', 'استهلاك الوقود لتر/100كم', None),
     ('licenseExpiry', 'LIC', 'D', 'انتهاء الترخيص', None), ('insuranceExpiry', 'INS', 'D', 'انتهاء التأمين', None)],
    'noona_trn_pkg.save_vehicle')
f = p.static('حالة العربة', 30)
p.select('P40_SET', f, 10, 'الحالة', lov_sql='STATIC2:متاحة;AVAILABLE,في الصيانة;MAINTENANCE,خارج الخدمة;OUT_OF_SERVICE,مباعة;SOLD', null_text=None)
b = p.button(f, 10, 'SET_STATUS', 'تغيير حالة العربة المختارة')
p.process(20, 'AFTER_SUBMIT', 'Status', 'noona_trn_pkg.set_vehicle_status(:P40_ID, :P40_SET);', when_button=b, success='تم تغيير الحالة')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for v in (select * from trn_vehicle where id = :P40_ID and company_id = noona_trn_pkg.company) loop',
    '    :P40_PLATE := v.plate_no; :P40_TYPE := v.vehicle_type; :P40_MAKE := v.make; :P40_MODEL := v.model; :P40_YEAR := v.model_year;',
    '    :P40_CAP := v.capacity_tons; :P40_M3 := v.capacity_m3; :P40_ODO := v.odometer_km; :P40_FUEL := v.fuel_l_per_100km;',
    "    :P40_LIC := to_char(v.license_expiry, 'YYYY-MM-DD'); :P40_INS := to_char(v.insurance_expiry, 'YYYY-MM-DD'); :P40_SET := v.status_code;",
    '  end loop;', 'end;'])

# 42) السائقون
p = master(42, 'DRIVERS', 'السائقون', [
    'select d.id, d.full_name, d.phone, d.license_no, d.license_class, d.license_expiry, d.hazmat_certified, noona_trn_pkg.badge(d.status_code) status_html,',
    "       (select count(*) from trn_trip t where t.driver_id = d.id and t.status_code = 'COMPLETED') trips,",
    "       (select nvl(sum(t.actual_distance_km), 0) from trn_trip t where t.driver_id = d.id and t.status_code = 'COMPLETED') km",
    f'  from trn_driver d where d.company_id = {CO} order by d.full_name'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('FULL_NAME', 'السائق', {}), ('PHONE', 'الجوال', {}), ('LICENSE_NO', 'الرخصة', {}),
     ('LICENSE_CLASS', 'الفئة', {}), ('LICENSE_EXPIRY', 'انتهاء الرخصة', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('HAZMAT_CERTIFIED', 'مواد خطرة', {}), ('STATUS_HTML', 'الحالة', {'html': True}), ('TRIPS', 'الرحلات', {'type': 'NUMBER'}), ('KM', 'الكيلومترات', {'type': 'NUMBER'})],
    [('name', 'NAME', 'T', 'الاسم', 200), ('phone', 'PHONE', 'T', 'الجوال', 30), ('nationalId', 'NID', 'T', 'رقم الهوية', 30),
     ('licenseNo', 'LICNO', 'T', 'رقم الرخصة', 50), ('licenseClass', 'LICCLS', 'T', 'فئة الرخصة', 30), ('licenseExpiry', 'LICEXP', 'D', 'انتهاء الرخصة', None),
     ('hazmat', 'HAZ', 'YN', 'مؤهل للمواد الخطرة', None), ('allowance', 'ALW', 'N', 'بدل الرحلة الافتراضي', None)],
    'noona_trn_pkg.save_driver')
f = p.static('حالة السائق', 30)
p.select('P42_SET', f, 10, 'الحالة', lov_sql='STATIC2:متاح;AVAILABLE,خارج الدوام;OFF_DUTY,موقوف;SUSPENDED,ترك العمل;LEFT', null_text=None)
b = p.button(f, 10, 'SET_STATUS', 'تغيير حالة السائق المختار')
p.process(20, 'AFTER_SUBMIT', 'Status', 'noona_trn_pkg.set_driver_status(:P42_ID, :P42_SET);', when_button=b, success='تم تغيير الحالة')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for d in (select * from trn_driver where id = :P42_ID and company_id = noona_trn_pkg.company) loop',
    '    :P42_NAME := d.full_name; :P42_PHONE := d.phone; :P42_NID := d.national_id; :P42_LICNO := d.license_no; :P42_LICCLS := d.license_class;',
    "    :P42_LICEXP := to_char(d.license_expiry, 'YYYY-MM-DD'); :P42_HAZ := d.hazmat_certified; :P42_ALW := d.trip_allowance; :P42_SET := d.status_code;",
    '  end loop;', 'end;'])

# 50) المدن والمواقع
p = master(50, 'LOCATIONS', 'المدن والمواقع', [
    'select l.id, l.code, l.name_ar, l.location_type, l.city_name, l.region_name, l.country_code, l.contact_name, l.phone',
    f'  from trn_location l where l.company_id = {CO} order by l.name_ar'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الاسم', {}), ('LOCATION_TYPE', 'النوع', {}),
     ('CITY_NAME', 'المدينة', {}), ('REGION_NAME', 'المنطقة', {}), ('COUNTRY_CODE', 'الدولة', {}), ('CONTACT_NAME', 'جهة الاتصال', {}), ('PHONE', 'الهاتف', {})],
    [('code', 'CODE', 'T', 'الرمز', 50), ('name', 'NAME', 'T', 'الاسم', 200), ('type', 'TYPE', 'S1', 'النوع', LTYPE), ('city', 'CITY', 'T', 'المدينة', 100),
     ('region', 'REGION', 'T', 'المنطقة/الولاية', 100), ('country', 'COUNTRY', 'S', 'الدولة', "select name_ar d, country_code r from ref_country where is_active = 'Y' order by nvl(sort_order, 999), name_ar"), ('address', 'ADDR', 'T', 'العنوان', 500),
     ('lat', 'LAT', 'N', 'خط العرض', None), ('lng', 'LNG', 'N', 'خط الطول', None), ('contact', 'CONTACT', 'T', 'جهة الاتصال', 200), ('phone', 'PHONE', 'T', 'الهاتف', 30)],
    'noona_trn_pkg.save_location')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for l in (select * from trn_location where id = :P50_ID and company_id = noona_trn_pkg.company) loop',
    '    :P50_CODE := l.code; :P50_NAME := l.name_ar; :P50_TYPE := l.location_type; :P50_CITY := l.city_name; :P50_REGION := l.region_name;',
    '    :P50_COUNTRY := l.country_code; :P50_ADDR := l.address_text; :P50_LAT := l.latitude; :P50_LNG := l.longitude; :P50_CONTACT := l.contact_name; :P50_PHONE := l.phone;',
    '  end loop;', 'end;'])

# 52) المسارات
p = master(52, 'ROUTES', 'المسارات والمسافات', [
    'select r.id, r.code, r.name_ar, f.name_ar from_loc, t.name_ar to_loc, r.distance_km, r.standard_hours, round(r.distance_km / r.standard_hours) avg_speed,',
    '       r.toll_amount, r.road_type from trn_route r join trn_location f on f.id = r.from_location_id join trn_location t on t.id = r.to_location_id',
    f' where r.company_id = {CO} order by r.name_ar'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المسار', {}), ('FROM_LOC', 'من', {}), ('TO_LOC', 'إلى', {}),
     ('DISTANCE_KM', 'المسافة (كم)', {'type': 'NUMBER'}), ('STANDARD_HOURS', 'الزمن (ساعة)', {'type': 'NUMBER'}), ('AVG_SPEED', 'متوسط السرعة', {'type': 'NUMBER'}),
     ('TOLL_AMOUNT', 'رسوم الطرق', {'type': 'NUMBER'}), ('ROAD_TYPE', 'نوع الطريق', {})],
    [('from', 'FROM', 'S', 'من', LOC_LOV), ('to', 'TO', 'S', 'إلى', LOC_LOV), ('distance', 'DIST', 'N', 'المسافة (كم)', None),
     ('hours', 'HRS', 'N', 'الزمن القياسي بالساعات (فارغ = بسرعة 70 كم/س)', None), ('toll', 'TOLL', 'N', 'رسوم الطرق', None),
     ('roadType', 'ROAD', 'S1', 'نوع الطريق', 'STATIC2:سريع;HIGHWAY,معبد;PAVED,غير معبد;UNPAVED,مختلط;MIXED'), ('name', 'NAME', 'T', 'اسم المسار (اختياري)', 200)],
    'noona_trn_pkg.save_route')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for r in (select * from trn_route where id = :P52_ID and company_id = noona_trn_pkg.company) loop',
    '    :P52_FROM := r.from_location_id; :P52_TO := r.to_location_id; :P52_DIST := r.distance_km; :P52_HRS := r.standard_hours;',
    '    :P52_TOLL := r.toll_amount; :P52_ROAD := r.road_type; :P52_NAME := r.name_ar;', '  end loop;', 'end;'])

# 53) أنواع الشحنات
p = master(53, 'CARGO-TYPES', 'أنواع الشحنات', [
    'select c.id, c.code, c.name_ar, c.cargo_category, noona_trn_pkg.uom_label(c.default_unit) unit, c.required_vehicle_type, c.hazard_class, c.handling_notes',
    f'  from trn_cargo_type c where c.company_id = {CO} order by c.name_ar'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('CARGO_CATEGORY', 'الفئة', {}), ('UNIT', 'الوحدة', {}),
     ('REQUIRED_VEHICLE_TYPE', 'العربة المطلوبة', {}), ('HAZARD_CLASS', 'فئة الخطورة', {}), ('HANDLING_NOTES', 'تعليمات المناولة والتفريغ', {})],
    [('code', 'CODE', 'T', 'الرمز', 50), ('name', 'NAME', 'T', 'الاسم', 200), ('category', 'CAT', 'S1', 'الفئة', CARGO_CAT), ('unit', 'UNIT', 'S1', 'الوحدة الافتراضية', UOM),
     ('vehicleType', 'VT', 'S', 'نوع العربة المطلوب', VTYPE), ('hazardClass', 'HAZ', 'T', 'فئة الخطورة (UN)', 20), ('handling', 'HND', 'T', 'تعليمات المناولة والتفريغ', 1000)],
    'noona_trn_pkg.save_cargo_type')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for c in (select * from trn_cargo_type where id = :P53_ID and company_id = noona_trn_pkg.company) loop',
    '    :P53_CODE := c.code; :P53_NAME := c.name_ar; :P53_CAT := c.cargo_category; :P53_UNIT := c.default_unit; :P53_VT := c.required_vehicle_type;',
    '    :P53_HAZ := c.hazard_class; :P53_HND := c.handling_notes;', '  end loop;', 'end;'])

# 54) تعرفة الترحيل
p = master(54, 'RATES', 'تعرفة الترحيل', [
    'select r.id, r.name_ar, noona_sal_pkg.customer_label(r.customer_account_id) customer, rt.name_ar route, c.name_ar cargo,',
    '       noona_trn_pkg.basis_label(r.rate_basis) basis, r.rate_amount, r.min_charge, r.priority_no, r.effective_from, r.effective_to,',
    '       noona_trn_pkg.badge(r.status_code) status_html',
    '  from trn_rate r left join trn_route rt on rt.id = r.route_id left join trn_cargo_type c on c.id = r.cargo_type_id',
    f' where r.company_id = {CO} order by r.priority_no, r.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('NAME_AR', 'التعرفة', {}), ('CUSTOMER', 'العميل', {}), ('ROUTE', 'المسار', {}), ('CARGO', 'الشحنة', {}),
     ('BASIS', 'الأساس', {}), ('RATE_AMOUNT', 'السعر', {'type': 'NUMBER'}), ('MIN_CHARGE', 'أدنى ترحيل', {'type': 'NUMBER'}),
     ('PRIORITY_NO', 'الأولوية', {'type': 'NUMBER'}), ('EFFECTIVE_FROM', 'من', {'type': 'DATE', 'format': 'YYYY-MM-DD'}),
     ('EFFECTIVE_TO', 'إلى', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('STATUS_HTML', 'الحالة', {'html': True})],
    [('name', 'NAME', 'T', 'اسم التعرفة', 200), ('customer', 'CUST', 'S', 'العميل (فارغ = الكل)', CUST_LOV), ('route', 'ROUTE', 'S', 'المسار (فارغ = الكل)', ROUTE_LOV),
     ('cargo', 'CARGO', 'S', 'نوع الشحنة (فارغ = الكل)', CARGO_LOV), ('basis', 'BASIS', 'S1', 'أساس الحساب', BASIS), ('rate', 'RATE', 'N', 'السعر', None),
     ('minCharge', 'MIN', 'N', 'أدنى ترحيل', None), ('priority', 'PRIO', 'N', 'الأولوية (الأقل أولاً)', None), ('from', 'FROM', 'D', 'سارية من', None),
     ('to', 'TO', 'D', 'سارية إلى', None)],
    'noona_trn_pkg.save_rate')
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '  for r in (select * from trn_rate where id = :P54_ID and company_id = noona_trn_pkg.company) loop',
    '    :P54_NAME := r.name_ar; :P54_CUST := r.customer_account_id; :P54_ROUTE := r.route_id; :P54_CARGO := r.cargo_type_id; :P54_BASIS := r.rate_basis;',
    "    :P54_RATE := r.rate_amount; :P54_MIN := r.min_charge; :P54_PRIO := r.priority_no; :P54_FROM := to_char(r.effective_from, 'YYYY-MM-DD');",
    "    :P54_TO := to_char(r.effective_to, 'YYYY-MM-DD');", '  end loop;', 'end;'])

# =============================================================== 55) الفوترة
p = app.page(55, 'Invoicing', 'INVOICING', 'فوترة الترحيل', scheme=TRN)
f = p.static('الفوترة', 10, text='<p class="nn-hint">اختر العميل ثم أوامر الشحن المسلمة: تصدر فاتورة مبيعات آجلة مرحلة على حساب إيرادات النقل '
                                 '(4170) وتظهر في ذمة العميل والإقرار الضريبي.</p>')
p.select('P55_CUST', f, 10, 'العميل', lov_sql=(
    "select noona_sal_pkg.customer_label(o.customer_account_id) || ' (' || count(*) || ' أمر)' d, o.customer_account_id r from trn_order o "
    f"where o.company_id = {CO} and o.status_code = 'DELIVERED' group by o.customer_account_id order by 1"), submit=True)
p.checkboxes('P55_ORDERS', f, 20, 'الأوامر المسلمة', (
    "select noona_trn_pkg.order_label(o.id) || ' · ' || to_char(o.total_amount, 'FM999G999G990D00') d, o.id r from trn_order o "
    f"where o.company_id = {CO} and o.status_code = 'DELIVERED' and o.customer_account_id = :P55_CUST order by o.id"), columns=1, cascade='P55_CUST')
b = p.button(f, 10, 'INVOICE', 'إصدار الفاتورة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Invoice', ['declare l number;', 'begin',
          "  l := noona_trn_pkg.invoice_orders(replace(:P55_ORDERS, ':', ','));", "  :P55_INV := l;", 'end;'], when_button=b,
          success='صدرت فاتورة الترحيل ورحلت')
p.hidden('P55_INV', f, 30)
p.ir('أوامر مفوترة', 20, [
    'select o.id, o.doc_no, noona_sal_pkg.customer_label(o.customer_account_id) customer, o.total_amount, i.doc_no invoice_no, i.doc_date invoice_date',
    f'  from trn_order o join sal_invoice i on i.id = o.sales_invoice_id where o.company_id = {CO} and o.status_code = \'INVOICED\' order by o.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الأمر', {}), ('CUSTOMER', 'العميل', {}), ('TOTAL_AMOUNT', 'الترحيل', {'type': 'NUMBER'}),
     ('INVOICE_NO', 'الفاتورة', {}), ('INVOICE_DATE', 'تاريخ الفاتورة', {'type': 'DATE', 'format': 'YYYY-MM-DD'})], titled=True)
p.branch(10, url(55) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 61-65) التقارير
REPORTS = [
    (61, 'TRIPS-REPORT', 'تقرير الرحلات والالتزام بالمواعيد', [
        'select t.doc_no, t.doc_date, v.plate_no, d.full_name driver, f.name_ar || \' ← \' || tl.name_ar route, t.planned_departure, t.actual_departure,',
        '       t.eta, t.actual_arrival, t.delay_minutes, noona_trn_pkg.status_label(noona_trn_pkg.timeliness(t.id)) timeliness,',
        '       round(t.load_kg / 1000, 2) tons, t.actual_distance_km, t.fuel_liters, t.revenue_amount, t.expense_amount, t.revenue_amount - t.expense_amount net_amount,',
        '       noona_trn_pkg.status_label(t.status_code) status',
        '  from trn_trip t join trn_vehicle v on v.id = t.vehicle_id join trn_driver d on d.id = t.driver_id',
        '  join trn_location f on f.id = t.from_location_id join trn_location tl on tl.id = t.to_location_id',
        f' where t.company_id = {CO} and t.status_code <> \'CANCELLED\' order by t.doc_date desc, t.id desc'],
     [('DOC_NO', 'الرحلة', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('PLATE_NO', 'العربة', {}), ('DRIVER', 'السائق', {}),
      ('ROUTE', 'المسار', {}), ('PLANNED_DEPARTURE', 'التحرك المخطط', {}), ('ACTUAL_DEPARTURE', 'التحرك الفعلي', {}), ('ETA', 'الوصول المتوقع', {}),
      ('ACTUAL_ARRIVAL', 'الوصول الفعلي', {}), ('DELAY_MINUTES', 'التأخير (د)', {'type': 'NUMBER'}), ('TIMELINESS', 'الالتزام', {}),
      ('TONS', 'طن', {'type': 'NUMBER'}), ('ACTUAL_DISTANCE_KM', 'كم', {'type': 'NUMBER'}), ('FUEL_LITERS', 'وقود (لتر)', {'type': 'NUMBER'}),
      ('REVENUE_AMOUNT', 'الإيراد', {'type': 'NUMBER'}), ('EXPENSE_AMOUNT', 'المصروف', {'type': 'NUMBER'}), ('NET_AMOUNT', 'الصافي', {'type': 'NUMBER'}),
      ('STATUS', 'الحالة', {})]),
    (62, 'FLEET-REPORT', 'استغلال الأسطول وربحية العربات', [
        'select v.plate_no, v.vehicle_type, v.capacity_tons, count(t.id) trips, nvl(sum(t.actual_distance_km), 0) km,',
        '       round(nvl(sum(t.load_kg), 0) / 1000, 2) tons, round(avg(t.load_kg / 10 / v.capacity_tons)) avg_load_pct, nvl(sum(t.fuel_liters), 0) fuel,',
        '       round(nvl(sum(t.fuel_liters), 0) / nullif(sum(t.actual_distance_km), 0) * 100, 1) l_per_100, nvl(sum(t.revenue_amount), 0) revenue,',
        '       nvl(sum(t.expense_amount), 0) expense, nvl(sum(t.revenue_amount - t.expense_amount), 0) net_amount,',
        '       (select count(*) from trn_incident i where i.vehicle_id = v.id) incidents',
        "  from trn_vehicle v left join trn_trip t on t.vehicle_id = v.id and t.status_code = 'COMPLETED'",
        f' where v.company_id = {CO} group by v.id, v.plate_no, v.vehicle_type, v.capacity_tons order by revenue desc'],
     [('PLATE_NO', 'العربة', {}), ('VEHICLE_TYPE', 'النوع', {}), ('CAPACITY_TONS', 'الحمولة', {'type': 'NUMBER'}), ('TRIPS', 'الرحلات', {'type': 'NUMBER'}),
      ('KM', 'الكيلومترات', {'type': 'NUMBER'}), ('TONS', 'الأطنان', {'type': 'NUMBER'}), ('AVG_LOAD_PCT', 'متوسط التحميل %', {'type': 'NUMBER'}),
      ('FUEL', 'الوقود (لتر)', {'type': 'NUMBER'}), ('L_PER_100', 'لتر/100كم', {'type': 'NUMBER'}), ('REVENUE', 'الإيراد', {'type': 'NUMBER'}),
      ('EXPENSE', 'المصروف', {'type': 'NUMBER'}), ('NET_AMOUNT', 'الصافي', {'type': 'NUMBER'}), ('INCIDENTS', 'الأعطال', {'type': 'NUMBER'})]),
    (63, 'DRIVERS-REPORT', 'أداء السائقين', [
        'select d.full_name, d.license_expiry, count(t.id) trips, nvl(sum(t.actual_distance_km), 0) km,',
        "       sum(case when noona_trn_pkg.timeliness(t.id) in ('ON_TIME', 'EARLY') then 1 else 0 end) on_time,",
        "       round(sum(case when noona_trn_pkg.timeliness(t.id) in ('ON_TIME', 'EARLY') then 1 else 0 end) / nullif(count(t.id), 0) * 100) on_time_pct,",
        '       (select count(*) from trn_incident i where i.driver_id = d.id) incidents,',
        '       (select nvl(sum(o.shortage_qty), 0) from trn_trip_order x join trn_order o on o.id = x.order_id join trn_trip tt on tt.id = x.trip_id where tt.driver_id = d.id) shortage',
        "  from trn_driver d left join trn_trip t on t.driver_id = d.id and t.status_code = 'COMPLETED'",
        f' where d.company_id = {CO} group by d.id, d.full_name, d.license_expiry order by trips desc'],
     [('FULL_NAME', 'السائق', {}), ('LICENSE_EXPIRY', 'انتهاء الرخصة', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('TRIPS', 'الرحلات', {'type': 'NUMBER'}),
      ('KM', 'الكيلومترات', {'type': 'NUMBER'}), ('ON_TIME', 'في الموعد', {'type': 'NUMBER'}), ('ON_TIME_PCT', 'الالتزام %', {'type': 'NUMBER'}),
      ('INCIDENTS', 'البلاغات', {'type': 'NUMBER'}), ('SHORTAGE', 'العجز', {'type': 'NUMBER'})]),
    (64, 'INCIDENTS-REPORT', 'الأعطال والبلاغات وزمن الاستجابة', [
        'select noona_trn_pkg.incident_label(i.incident_type) incident_type, noona_trn_pkg.severity_label(i.severity) severity, count(*) incidents,',
        '       round(avg((cast(i.acknowledged_at as date) - cast(i.reported_at as date)) * 1440)) avg_ack_min,',
        '       round(avg((cast(i.responded_at as date) - cast(i.reported_at as date)) * 1440)) avg_response_min,',
        '       round(avg((cast(i.resolved_at as date) - cast(i.reported_at as date)) * 1440)) avg_resolve_min,',
        "       sum(case when i.status_code in ('REPORTED','ACKNOWLEDGED','IN_PROGRESS') then 1 else 0 end) open_count,",
        '       nvl(sum(i.downtime_minutes), 0) downtime, nvl(sum(i.cost_amount), 0) cost',
        f'  from trn_incident i where i.company_id = {CO} group by i.incident_type, i.severity order by incidents desc'],
     [('INCIDENT_TYPE', 'النوع', {}), ('SEVERITY', 'الخطورة', {}), ('INCIDENTS', 'العدد', {'type': 'NUMBER'}),
      ('AVG_ACK_MIN', 'متوسط زمن الاستلام (د)', {'type': 'NUMBER'}), ('AVG_RESPONSE_MIN', 'متوسط زمن الاستجابة (د)', {'type': 'NUMBER'}),
      ('AVG_RESOLVE_MIN', 'متوسط زمن الحل (د)', {'type': 'NUMBER'}), ('OPEN_COUNT', 'مفتوحة', {'type': 'NUMBER'}),
      ('DOWNTIME', 'التوقف (د)', {'type': 'NUMBER'}), ('COST', 'التكلفة', {'type': 'NUMBER'})]),
    (65, 'CUSTOMERS-REPORT', 'الترحيل حسب العملاء والمسارات', [
        'select noona_sal_pkg.customer_label(o.customer_account_id) customer, f.name_ar || \' ← \' || t.name_ar route, count(*) orders,',
        '       round(sum(o.weight_kg) / 1000, 2) tons, sum(o.total_amount) freight, nvl(sum(o.shortage_qty), 0) shortage,',
        "       sum(case when o.status_code = 'INVOICED' then o.total_amount else 0 end) invoiced,",
        "       sum(case when o.status_code = 'DELIVERED' then o.total_amount else 0 end) not_invoiced",
        '  from trn_order o join trn_location f on f.id = o.from_location_id join trn_location t on t.id = o.to_location_id',
        f" where o.company_id = {CO} and o.status_code not in ('DRAFT', 'CANCELLED')",
        ' group by o.customer_account_id, f.name_ar, t.name_ar order by freight desc'],
     [('CUSTOMER', 'العميل', {}), ('ROUTE', 'المسار', {}), ('ORDERS', 'الأوامر', {'type': 'NUMBER'}), ('TONS', 'الأطنان', {'type': 'NUMBER'}),
      ('FREIGHT', 'الترحيل', {'type': 'NUMBER'}), ('SHORTAGE', 'العجز', {'type': 'NUMBER'}), ('INVOICED', 'المفوتر', {'type': 'NUMBER'}),
      ('NOT_INVOICED', 'غير المفوتر', {'type': 'NUMBER'})]),
]
for pid, alias, title, sql, cols in REPORTS:
    p = app.page(pid, alias.title(), alias, title, scheme=TRN, protection='N')   # يفتح من مركز التقارير برابط يمسح مرشحاته
    p.ir(title, 10, sql, cols)

# التحليلات والتنبؤ
import anl_pages
anl_pages.add(app, ['TRN'], TRN, 11)

# =============================================================== القائمة
app.nav_item('لوحة الحركة', 1, 'fa-truck', 10)
op = app.nav_item('العمليات', None, 'fa-road', 20)
app.nav_item('أوامر الشحن', 10, 'fa-cubes', 21, parent=op)
app.nav_item('الرحلات', 20, 'fa-road', 22, parent=op)
app.nav_item('رحلة جديدة', 22, 'fa-plus', 23, parent=op)
app.nav_item('الأعطال والبلاغات', 30, 'fa-exclamation-triangle', 24, parent=op)
app.nav_item('فوترة الترحيل', 55, 'fa-file-text-o', 25, parent=op)
fl = app.nav_item('الأسطول', None, 'fa-bus', 30, scheme=SETUP)
app.nav_item('العربات والشاحنات', 40, 'fa-truck', 31, parent=fl, scheme=SETUP)
app.nav_item('السائقون', 42, 'fa-id-card', 32, parent=fl, scheme=SETUP)
st = app.nav_item('الإعداد', None, 'fa-cogs', 40, scheme=SETUP)
app.nav_item('المدن والمواقع', 50, 'fa-map-marker', 41, parent=st, scheme=SETUP)
app.nav_item('المسارات والمسافات', 52, 'fa-map', 42, parent=st, scheme=SETUP)
app.nav_item('أنواع الشحنات', 53, 'fa-archive', 43, parent=st, scheme=SETUP)
app.nav_item('تعرفة الترحيل', 54, 'fa-money', 44, parent=st, scheme=SETUP)
rp = app.nav_item('التقارير', None, 'fa-bar-chart', 50)
for pid, alias, title, _, _ in REPORTS:
    app.nav_item(title, pid, 'fa-file-text-o', 50 + pid - 60, parent=rp)

app.finalize()
print('NOONA_TRN built:', len(app.pages), 'pages')
