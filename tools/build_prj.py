"""NOONA_PRJ (العقارات والضيافة والمشروعات): السجل العقاري (معالج إضافة عقار، المباني والطوابق والوحدات، مخطط الوحدات)،
الضيافة (لوحة الاستقبال وحالة الغرف ومخطط الحجوزات، الحجوزات، الدخول السريع، التمديد ونقل الغرفة والمغادرة، حساب النزيل،
التدبير الفندقي، التدقيق الليلي، الإعداد، التقارير)، والصيانة (لوحة البلاغات، البلاغ ودورته، الفرق والفنيون، الفئات، الأداء).
الاستخدام: python3 tools/build_prj.py  ->  apex/NOONA_PRJ/f139
المنطق في NOONA_RE_PKG و NOONA_HSP_PKG و NOONA_MNT_PKG؛ لوحة الاستقبال في tools/frontdesk.js.
"""
import os, shutil, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand

ROOT = os.path.join(os.path.dirname(__file__), '..')
shutil.copyfile(os.path.join(os.path.dirname(__file__), 'frontdesk.js'), os.path.join(apex_brand.STATIC_DIR, 'frontdesk.js'))
if ('frontdesk.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('frontdesk.js', 'application/javascript'))
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_PRJ/f139'),
          app_id=139, alias='NOONA_PRJ', name='NOONA Real Estate & Hospitality', id_base=91820273000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']
RE = app.add_scheme('noona_re_view', app.id(), 'NOONA - Real Estate',
                    "return noona_security_pkg.has_permission('RE_PROPERTY.VIEW', noona_re_pkg.company) = 'Y' and (noona_platform_pkg.module_enabled('RE') = 'Y' or noona_platform_pkg.module_enabled('HSP') = 'Y');",
                    'صفحات السجل العقاري تتطلب صلاحية عرض العقارات / Real estate access required')
HSP = app.add_scheme('noona_hsp_view', app.id(), 'NOONA - Hospitality',
                     "return noona_security_pkg.has_permission('HSP_RESERVATION.VIEW', noona_hsp_pkg.company) = 'Y' and noona_platform_pkg.module_enabled('HSP') = 'Y';",
                     'صفحات الضيافة تتطلب صلاحية عرض الحجوزات / Hospitality access required')
MNT = app.add_scheme('noona_mnt_view', app.id(), 'NOONA - Maintenance',
                     "return noona_security_pkg.has_permission('MNT_REQUEST.VIEW', noona_mnt_pkg.company) = 'Y' and (noona_platform_pkg.module_enabled('MNT') = 'Y' or noona_platform_pkg.module_enabled('HSP') = 'Y');",
                     'صفحات الصيانة تتطلب صلاحية عرض البلاغات / Maintenance access required')


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


def get_url(page, items, ph='990000000001', sub='#ID#'):
    """رابط صفحة بلا checksum (للصفحات غير المحمية) يستبدل فيه المعرف في HTML أو JS."""
    return f"replace(apex_page.get_url(p_page => {page}, p_items => '{items}', p_values => '{ph}'), '{ph}', '{sub}')"


PROP_LOV = ("select name_ar || ' (' || code || ')' d, id r from re_property where company_id = noona_re_pkg.company "
            "and status_code <> 'INACTIVE' order by code")
HOTEL_LOV = ("select p.name_ar d, p.id r from re_property p where p.company_id = noona_hsp_pkg.company and p.status_code <> 'INACTIVE' "
             "and exists (select 1 from hsp_room r where r.property_id = p.id) order by p.code")
BRANCH_LOV = "select name_ar d, id r from org_branch where company_id = noona_re_pkg.company and status_code = 'ACTIVE' order by name_ar"
# مدن دولة الشركة (المدن عامة على المنصة لكل الدول)
CITY_LOV = ("select name_ar d, id r from ref_city where is_active = 'Y'"
            " and country_code = nvl((select country_code from org_company where id = noona_re_pkg.company), country_code) order by name_ar")
PTYPE_LOV = ('STATIC2:فندق;HOTEL,شقق فندقية;SERVICED_APARTMENTS,عمارة سكنية;BUILDING,برج;TOWER,مجمع سكني;COMPOUND,مجمع فلل;VILLA_COMPOUND,'
             'مركز تجاري;MALL,مجمع مكاتب;OFFICE_PARK,مستودعات;WAREHOUSE_PARK,مخطط أراض;LAND_SUBDIVISION')
UTYPE_LOV = ('STATIC2:شقة;APARTMENT,غرفة فندقية;ROOM,جناح;SUITE,استوديو;STUDIO,فيلا;VILLA,تاون هاوس;TOWNHOUSE,مكتب;OFFICE,محل;SHOP,'
             'معرض;SHOWROOM,مستودع;WAREHOUSE,موقف;PARKING,مخزن;STORAGE,قطعة أرض;LAND_PLOT')
USAGE_LOV = 'STATIC2:للتأجير;LEASE,ضيافة/فندقي;HOSPITALITY,للبيع;SALE,متعدد;MIXED,استخدام المالك;OWNER_USE'
FURN_LOV = 'STATIC2:مفروشة;FURNISHED,شبه مفروشة;SEMI_FURNISHED,غير مفروشة;UNFURNISHED'
USTATUS_LOV = ('STATIC2:متاحة;AVAILABLE,محجوزة;RESERVED,مؤجرة;LEASED,مشغولة;OCCUPIED,مباعة;SOLD,مسلمة;HANDED_OVER,'
               'تحت الصيانة;UNDER_MAINTENANCE,موقوفة;BLOCKED,تحت الإنشاء;UNDER_CONSTRUCTION,مخططة;PLANNED')
MGMT_LOV = 'STATIC2:مملوك للمنشأة;OWNED,مدار لصالح مالك;MANAGED_FOR_OWNER,ملكية مشتركة;JOINT'
OWNER_LOV = ("select display_name_ar d, id r from pty_party p where status_code = 'ACTIVE' and (party_type = 'ORGANIZATION' "
             "or exists (select 1 from pty_party_role x where x.party_id = p.id and x.role_code in ('OWNER', 'LANDLORD', 'PARTNER'))) order by 1")
CHANNEL_LOV = ('STATIC2:هاتف;PHONE,حضور مباشر;WALK_IN,بريد إلكتروني;EMAIL,الموقع;WEBSITE,منصات الحجز (بوكينج وغيرها);OTA,'
               'شركات;CORPORATE,وكيل سفر;TRAVEL_AGENT')
IDTYPE_LOV = 'STATIC2:هوية وطنية;NATIONAL_ID,إقامة;IQAMA,جواز سفر;PASSPORT,أخرى;OTHER'
COUNTRY_LOV = "select name_ar d, country_code r from ref_country where is_active = 'Y' order by nvl(sort_order, 999), name_ar"
COMPANY_PARTY_LOV = "select display_name_ar d, id r from pty_party where party_type = 'ORGANIZATION' and status_code = 'ACTIVE' order by 1"
BANK_LOV = ("select code || ' - ' || name_ar d, id r from csh_bank_account where company_id = noona_hsp_pkg.company "
            "and status_code = 'ACTIVE' order by code")
BOX_LOV = ("select code || ' - ' || name_ar d, id r from csh_cash_box where company_id = noona_hsp_pkg.company "
           "and status_code = 'ACTIVE' order by code")
PAY_LOV = 'STATIC2:نقداً;CASH,شبكة / بطاقة;CARD,تحويل بنكي;BANK_TRANSFER'
EMP_LOV = ("select e.employee_no || ' - ' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
           "where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_mnt_pkg.company "
           "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD')) order by e.employee_no")
PRIORITY_LOV = 'STATIC2:عادي;NORMAL,مرتفع;HIGH,عاجل;URGENT,طارئ;EMERGENCY,منخفض;LOW'
MCHANNEL_LOV = ('STATIC2:هاتف;PHONE,الاستقبال;FRONT_DESK,بوابة الخدمة;PORTAL,تطبيق الجوال;APP,بريد إلكتروني;EMAIL,'
                'جولة معاينة;INSPECTION,صيانة وقائية;PREVENTIVE')
CAT_LOV = "select name_ar d, id r from mnt_service_category where is_active = 'Y' order by name_ar"
TEAM_LOV = "select name_ar d, id r from mnt_team where company_id = noona_mnt_pkg.company and is_active = 'Y' order by name_ar"
CHARGE_LOV = 'STATIC2:المالك / المنشأة;OWNER,المستأجر / النزيل;LESSEE,الضمان;WARRANTY,المقاول;CONTRACTOR,التأمين;INSURANCE'


def build_json(fields):
    """json_object من عناصر الصفحة: [(key, item, kind)] kind: s نص، n رقم."""
    parts = []
    for k, item, kind in fields:
        v = f'to_number(:{item})' if kind == 'n' else f':{item}'
        parts.append(f"'{k}' value {v}")
    return 'json_object(' + ', '.join(parts) + ' returning clob)'


# =============================================================== 1) اللوحة
p = app.page(1, 'Home', 'HOME', 'العقارات والضيافة', scheme=TENANT)
st = p.static('تجهيز الضيافة والصيانة', 5, condition="noona_hsp_pkg.is_ready = 'N' or noona_mnt_pkg.is_ready = 'N'",
              text='<p class="nn-hint">ينشئ حسابات ذمم النزلاء (1112) وحسابات الشركات (1113) وإيرادات الإيواء (4110) والخدمات (4111)، '
                   'وفئات أعطال الصيانة بأزمنة الإنجاز المستهدفة، وفريق صيانة عاماً، والترقيم. مرة واحدة لكل شركة.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز الضيافة والصيانة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_hsp_pkg.quick_setup;',
                                        '    l_n := noona_mnt_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم التجهيز: حسابات الضيافة وفئات الصيانة والفريق العام')
p.dynamic('السجل العقاري', 10, 'return noona_re_pkg.registry_summary;', hide_header=True)
p.dynamic('الاستقبال', 12, [
    'declare l_p number := noona_hsp_pkg.default_property;',
    'begin',
    "    if l_p is null then return null; end if;",
    "    return '<h3 class=\"nn-fa-h\">' || apex_escape.html(noona_re_pkg.property_name(l_p)) || '</h3>' || noona_hsp_pkg.front_summary(l_p);",
    'end;'], hide_header=True, condition="noona_hsp_pkg.default_property is not null")
p.dynamic('الصيانة', 14, 'return noona_mnt_pkg.summary_html;', hide_header=True, condition="noona_mnt_pkg.is_ready = 'Y'")
qa = p.static('إجراءات سريعة', 15)
p.button(qa, 10, 'FD', 'لوحة الاستقبال', hot=True, redirect=url(20))
p.button(qa, 20, 'NEWRES', 'حجز جديد', redirect=url(22, clear='RP,22'))
p.button(qa, 30, 'NEWREQ', 'بلاغ صيانة', redirect=url(71, clear='RP,71'))
p.button(qa, 40, 'WIZ', 'إضافة عقار', redirect=url(11, clear='RP,11'))
p.button(qa, 50, 'HK', 'التدبير الفندقي', redirect=url(25))
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) العقارات
p = app.page(10, 'Properties', 'PROPERTIES', 'العقارات', scheme=RE)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'WIZ', 'إضافة عقار (معالج سريع)', hot=True, redirect=url(11, clear='RP,11'))
p.dynamic('المؤشرات', 8, 'return noona_re_pkg.registry_summary;', hide_header=True)
p.ir('العقارات', 10, [
    "select p.id, p.code, p.name_ar, noona_re_pkg.property_type_label(p.property_type) as ptype, c.name_ar as city, p.address_text,",
    "       (select count(*) from re_building b where b.property_id = p.id) as buildings,",
    "       (select count(*) from re_unit u where u.property_id = p.id) as units,",
    "       (select count(*) from re_unit u where u.property_id = p.id and u.status_code = 'AVAILABLE') as available,",
    "       (select count(*) from hsp_room r where r.property_id = p.id) as rooms,",
    "       noona_re_pkg.unit_status_label(p.status_code) as status",
    "  from re_property p left join ref_city c on c.id = p.city_id where p.company_id = noona_re_pkg.company order by p.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'العقار', {}), ('PTYPE', 'النوع', {}),
     ('CITY', 'المدينة', {}), ('ADDRESS_TEXT', 'العنوان', {}), ('BUILDINGS', 'المباني', {'type': 'NUMBER'}),
     ('UNITS', 'الوحدات', {'type': 'NUMBER'}), ('AVAILABLE', 'المتاحة', {'type': 'NUMBER'}), ('ROOMS', 'غرف الضيافة', {'type': 'NUMBER'}),
     ('STATUS', 'الحالة', {})], link=link(12, 'P12_ID'))

# =============================================================== 11) معالج إضافة عقار
p = app.page(11, 'Property Wizard', 'PROPERTY-WIZARD', 'إضافة عقار', scheme=RE)
a = p.static('1. بيانات العقار', 10)
p.text('P11_NAME', a, 10, 'اسم العقار', required=True, maxlen=200)
p.select('P11_TYPE', a, 20, 'النوع', lov_sql=PTYPE_LOV, null_text=None)
p.select('P11_CITY', a, 30, 'المدينة', lov_sql=CITY_LOV)
p.text('P11_ADDRESS', a, 40, 'العنوان (الحي، الشارع)', maxlen=500)
p.select('P11_BRANCH', a, 50, 'الفرع', lov_sql=BRANCH_LOV)
p.select('P11_MGMT', a, 60, 'الملكية والإدارة', lov_sql=MGMT_LOV, null_text=None)
p.select('P11_OWNER', a, 70, 'المالك (لأملاك الغير)', lov_sql=OWNER_LOV)
p.text('P11_PHONE', a, 80, 'هاتف الاستقبال / الإدارة', maxlen=30, width=15)
p.number('P11_STARS', a, 90, 'التصنيف (نجوم الفندق)')
p.text('P11_LICENSE', a, 100, 'ترخيص السياحة / البلدية', maxlen=100, width=20)
p.textarea('P11_DESC', a, 110, 'الوصف والمرافق (مسبح، مواقف، نادٍ...)')
bl = p.static('2. المباني والطوابق', 20, text='<p class="nn-hint">حتى ثلاثة مبانٍ؛ لكل مبنى عدد الطوابق والدور الأرضي اختيارياً. '
                                            'يمكن إضافة مبانٍ أخرى لاحقاً من بطاقة العقار.</p>')
for i, (code, nm) in enumerate([('A', 'المبنى الرئيسي'), ('B', ''), ('C', '')], 1):
    p.text(f'P11_B{i}_NAME', bl, i * 10, f'المبنى {i}: الاسم', maxlen=200, width=25)
    p.number(f'P11_B{i}_FLOORS', bl, i * 10 + 1, f'المبنى {i}: عدد الطوابق')
    p.yesno(f'P11_B{i}_GROUND', bl, i * 10 + 2, f'المبنى {i}: يوجد دور أرضي بوحدات')
un = p.static('3. توليد الوحدات (لكل طابق)', 30, text='<p class="nn-hint">ترقم الوحدات آلياً: رقم الطابق ثم تسلسل الوحدة (101، 102 ... 201). '
                                                     'تعدّل تفاصيل أي وحدة لاحقاً من مخطط الوحدات.</p>')
p.number('P11_PER_FLOOR', un, 10, 'عدد الوحدات في كل طابق')
p.select('P11_UTYPE', un, 20, 'نوع الوحدات', lov_sql=UTYPE_LOV, null_text=None)
p.select('P11_USAGE', un, 30, 'الاستخدام', lov_sql=USAGE_LOV, null_text=None)
p.number('P11_BEDS', un, 40, 'غرف النوم')
p.number('P11_BATHS', un, 50, 'دورات المياه')
p.number('P11_AREA', un, 60, 'المساحة م2')
p.select('P11_FURN', un, 70, 'التأثيث', lov_sql=FURN_LOV)
p.number('P11_PRICE', un, 80, 'السعر / الإيجار السنوي (اختياري)')
ho = p.static('4. الضيافة (فندق أو شقق فندقية)', 40, text='<p class="nn-hint">عند التفعيل تصبح كل وحدة غرفة أو شقة فندقية جاهزة في لوحة '
                                                          'الاستقبال، بنوع غرفة وسعر أساسي لليلة.</p>')
p.yesno('P11_HSP', ho, 10, 'تشغيل الوحدات فندقياً')
p.text('P11_RT_NAME', ho, 20, 'اسم نوع الغرفة / الشقة', maxlen=200, width=25)
p.number('P11_RT_RATE', ho, 30, 'سعر الليلة الأساسي')
p.number('P11_RT_ADULTS', ho, 40, 'أقصى عدد بالغين')
sv = p.static('حفظ', 50, hide_header=True)
b = p.button(sv, 10, 'CREATE', 'إنشاء العقار ووحداته', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "    :P11_TYPE := nvl(:P11_TYPE, 'BUILDING'); :P11_MGMT := nvl(:P11_MGMT, 'OWNED');",
    "    :P11_B1_NAME := nvl(:P11_B1_NAME, 'المبنى الرئيسي'); :P11_UTYPE := nvl(:P11_UTYPE, 'APARTMENT');",
    "    :P11_USAGE := nvl(:P11_USAGE, 'LEASE'); :P11_HSP := nvl(:P11_HSP, 'N'); :P11_RT_ADULTS := nvl(:P11_RT_ADULTS, 2);",
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Create', [
    'declare',
    '    l_o  json_object_t := json_object_t();',
    '    l_bs json_array_t := json_array_t();',
    '    l_b  json_object_t;',
    '    l_u  json_object_t := json_object_t();',
    '    l_h  json_object_t := json_object_t();',
    '    procedure bld(p_name varchar2, p_floors varchar2, p_ground varchar2, p_code varchar2) is',
    '    begin',
    '        if p_floors is not null then',
    "            l_b := json_object_t(); l_b.put('code', p_code); l_b.put('name', nvl(p_name, 'مبنى ' || p_code));",
    "            l_b.put('floors', to_number(p_floors)); l_b.put('ground', nvl(p_ground, 'N')); l_bs.append(l_b);",
    '        end if;',
    '    end;',
    'begin',
    "    l_o.put('name_ar', :P11_NAME); l_o.put('type', :P11_TYPE); l_o.put('city', :P11_CITY); l_o.put('address', :P11_ADDRESS);",
    "    l_o.put('branch', :P11_BRANCH); l_o.put('management_mode', :P11_MGMT); l_o.put('owner_party', :P11_OWNER);",
    "    l_o.put('phone', :P11_PHONE); l_o.put('star_rating', :P11_STARS); l_o.put('license', :P11_LICENSE); l_o.put('description', :P11_DESC);",
    "    bld(:P11_B1_NAME, :P11_B1_FLOORS, :P11_B1_GROUND, 'A'); bld(:P11_B2_NAME, :P11_B2_FLOORS, :P11_B2_GROUND, 'B');",
    "    bld(:P11_B3_NAME, :P11_B3_FLOORS, :P11_B3_GROUND, 'C');",
    "    l_o.put('buildings', l_bs);",
    '    if :P11_PER_FLOOR is not null then',
    "        l_u.put('per_floor', :P11_PER_FLOOR); l_u.put('unit_type', :P11_UTYPE);",
    "        l_u.put('usage_type', case when :P11_HSP = 'Y' then 'HOSPITALITY' else :P11_USAGE end);",
    "        l_u.put('bedrooms', :P11_BEDS); l_u.put('bathrooms', :P11_BATHS); l_u.put('area', :P11_AREA); l_u.put('furnishing', :P11_FURN);",
    "        l_u.put('price', :P11_PRICE); l_o.put('units', l_u);",
    '    end if;',
    "    if :P11_HSP = 'Y' then",
    "        l_h.put('room_type_name', :P11_RT_NAME); l_h.put('base_rate', :P11_RT_RATE); l_h.put('max_adults', :P11_RT_ADULTS);",
    "        l_o.put('hospitality', l_h);",
    '    end if;',
    '    :P11_ID := noona_re_pkg.setup_wizard(l_o.to_clob);',
    'end;'], when_button=b, success='تم إنشاء العقار ومبانيه ووحداته')
p.hidden('P11_ID', sv, 20)
p.branch(10, url(12, 'P12_ID', '&P11_ID.', 'RP,12') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 12) بطاقة العقار
p = app.page(12, 'Property', 'PROPERTY', 'بطاقة العقار', scheme=RE)
p.dynamic('العقار', 5, 'return noona_re_pkg.property_card_html(:P12_ID);', hide_header=True)
p.dynamic('مخطط الوحدات', 10, f"return noona_re_pkg.stacking_html(:P12_ID, {get_url(13, 'P13_ID')});")
ed = p.static('تعديل بيانات العقار', 20)
p.hidden('P12_ID', ed, 1)
p.text('P12_NAME', ed, 10, 'الاسم', required=True, maxlen=200)
p.text('P12_CODE', ed, 15, 'الرمز', maxlen=50, width=12)
p.select('P12_TYPE', ed, 20, 'النوع', lov_sql=PTYPE_LOV, null_text=None)
p.select('P12_CITY', ed, 30, 'المدينة', lov_sql=CITY_LOV)
p.text('P12_ADDRESS', ed, 40, 'العنوان', maxlen=500)
p.select('P12_BRANCH', ed, 50, 'الفرع', lov_sql=BRANCH_LOV)
p.select('P12_MGMT', ed, 60, 'الملكية والإدارة', lov_sql=MGMT_LOV, null_text=None)
p.select('P12_OWNER', ed, 70, 'المالك', lov_sql=OWNER_LOV)
p.text('P12_PHONE', ed, 80, 'الهاتف', maxlen=30, width=15)
p.number('P12_STARS', ed, 90, 'التصنيف (نجوم)')
p.text('P12_LICENSE', ed, 100, 'الترخيص', maxlen=100, width=20)
p.text('P12_CIN', ed, 110, 'وقت الدخول (HH:MI)', maxlen=5, width=6)
p.text('P12_COUT', ed, 120, 'وقت المغادرة (HH:MI)', maxlen=5, width=6)
p.select('P12_STATUS', ed, 130, 'الحالة', null_text=None, lov_sql='STATIC2:تشغيلي;OPERATIONAL,تحت التطوير;UNDER_DEVELOPMENT,تحت التجديد;UNDER_RENOVATION,'
         'مخطط;PLANNED,مباع بالكامل;SOLD_OUT,غير نشط;INACTIVE')
p.textarea('P12_DESC', ed, 140, 'الوصف والمرافق')
b_save = p.button(ed, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    select name_ar, code, property_type, city_id, address_text, branch_id, management_mode, owner_party_id, phone, star_rating,',
    '           tourism_license_no, checkin_time, checkout_time, status_code, description',
    '      into :P12_NAME, :P12_CODE, :P12_TYPE, :P12_CITY, :P12_ADDRESS, :P12_BRANCH, :P12_MGMT, :P12_OWNER, :P12_PHONE, :P12_STARS,',
    '           :P12_LICENSE, :P12_CIN, :P12_COUT, :P12_STATUS, :P12_DESC',
    '      from re_property where id = :P12_ID and company_id = noona_re_pkg.company;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l_id number; l_doc clob;', 'begin',
    '    select ' + build_json([
        ('id', 'P12_ID', 'n'), ('name_ar', 'P12_NAME', 's'), ('code', 'P12_CODE', 's'), ('type', 'P12_TYPE', 's'), ('city', 'P12_CITY', 'n'),
        ('address', 'P12_ADDRESS', 's'), ('branch', 'P12_BRANCH', 'n'), ('management_mode', 'P12_MGMT', 's'), ('owner_party', 'P12_OWNER', 'n'),
        ('phone', 'P12_PHONE', 's'), ('star_rating', 'P12_STARS', 'n'), ('license', 'P12_LICENSE', 's'), ('checkin_time', 'P12_CIN', 's'),
        ('checkout_time', 'P12_COUT', 's'), ('status', 'P12_STATUS', 's'), ('description', 'P12_DESC', 's')]) + ' into l_doc from dual;',
    '    l_id := noona_re_pkg.save_property(l_doc);',
    'end;'], when_button=b_save, success='تم حفظ بيانات العقار')
nb = p.static('إضافة مبنى وتوليد وحداته', 30)
p.text('P12_B_NAME', nb, 10, 'اسم المبنى', maxlen=200)
p.text('P12_B_CODE', nb, 15, 'الرمز (اختياري)', maxlen=20, width=8)
p.number('P12_B_FLOORS', nb, 20, 'عدد الطوابق')
p.yesno('P12_B_GROUND', nb, 30, 'دور أرضي')
p.number('P12_B_PER', nb, 40, 'وحدات في كل طابق')
p.select('P12_B_UTYPE', nb, 50, 'نوع الوحدات', lov_sql=UTYPE_LOV, null_text=None)
p.select('P12_B_USAGE', nb, 60, 'الاستخدام', lov_sql=USAGE_LOV, null_text=None)
p.number('P12_B_AREA', nb, 70, 'المساحة م2')
p.number('P12_B_BEDS', nb, 80, 'غرف النوم')
p.select('P12_B_RT', nb, 90, 'نوع غرفة الضيافة (لتشغيلها فندقياً)', lov_sql=(
    "select name_ar d, id r from hsp_room_type where property_id = :P12_ID and is_active = 'Y' order by code"))
b_bld = p.button(nb, 10, 'ADD_BUILDING', 'إضافة المبنى وتوليد الوحدات')
p.process(20, 'AFTER_SUBMIT', 'Add Building', [
    'declare l_b number; l_n number; l_doc clob;', 'begin',
    '    l_b := noona_re_pkg.add_building(:P12_ID, :P12_B_CODE, :P12_B_NAME, :P12_B_FLOORS, nvl(:P12_B_GROUND, \'N\'));',
    '    if :P12_B_PER is not null then',
    "        select json_object('building' value l_b, 'per_floor' value to_number(:P12_B_PER),",
    "                 'unit_type' value :P12_B_UTYPE, 'usage_type' value :P12_B_USAGE, 'area' value to_number(:P12_B_AREA),",
    "                 'bedrooms' value to_number(:P12_B_BEDS), 'room_type' value to_number(:P12_B_RT) returning clob) into l_doc from dual;",
    "        l_n := noona_re_pkg.generate_units(l_doc);",
    '    end if;',
    "    apex_application.g_print_success_message := 'تمت إضافة المبنى' || case when l_n > 0 then ' و' || l_n || ' وحدة' end;",
    'end;'], when_button=b_bld)
p.ir('المباني', 40, [
    "select b.id, b.code, b.name_ar, b.floors_count, (select count(*) from re_unit u where u.building_id = b.id) as units,",
    "       noona_re_pkg.unit_status_label(b.status_code) as status from re_building b where b.property_id = :P12_ID order by b.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'المبنى', {}),
     ('FLOORS_COUNT', 'الطوابق', {'type': 'NUMBER'}), ('UNITS', 'الوحدات', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], titled=True, rows=20)
p.branch(10, url(12, 'P12_ID', '&P12_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 13) الوحدة
p = app.page(13, 'Unit', 'UNIT', 'الوحدة العقارية', scheme=RE, protection='N')
p.dynamic('الوحدة', 5, [
    'begin',
    "    return '<div class=\"nn-hr-runbar\"><b>' || apex_escape.html(noona_re_pkg.unit_label(:P13_ID)) || '</b></div>';",
    'end;'], hide_header=True)
f = p.static('تفاصيل الوحدة', 10)
p.hidden('P13_ID', f, 1, protected=False)
p.hidden('P13_PROP', f, 2)
p.text('P13_NAME', f, 10, 'الاسم', maxlen=200)
p.select('P13_UTYPE', f, 20, 'النوع', lov_sql=UTYPE_LOV, null_text=None)
p.select('P13_USAGE', f, 30, 'الاستخدام', lov_sql=USAGE_LOV, null_text=None)
p.number('P13_BEDS', f, 40, 'غرف النوم')
p.number('P13_BATHS', f, 50, 'دورات المياه')
p.number('P13_NET', f, 60, 'المساحة الصافية م2')
p.number('P13_GROSS', f, 70, 'المساحة الإجمالية م2')
p.select('P13_FURN', f, 80, 'التأثيث', lov_sql=FURN_LOV)
p.text('P13_VIEW', f, 90, 'الإطلالة', maxlen=30, width=15)
p.number('P13_PRICE', f, 100, 'السعر / الإيجار')
p.text('P13_DEED', f, 110, 'رقم الصك', maxlen=100, width=20)
p.textarea('P13_AMEN', f, 120, 'التجهيزات (مطبخ، مكيفات، أجهزة...)')
p.textarea('P13_NOTES', f, 130, 'ملاحظات')
b_save = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.button(f, 20, 'BACK', 'بطاقة العقار', redirect=url(12, 'P12_ID', '&P13_PROP.'))
p.button(f, 30, 'REQ', 'بلاغ صيانة لهذه الوحدة', redirect=url(71, 'P71_NEW_UNIT,P71_NEW_PROP', '&P13_ID.,&P13_PROP.', 'RP,71'))
s = p.static('حالة الوحدة', 20)
p.select('P13_STATUS', s, 10, 'الحالة', lov_sql=USTATUS_LOV, null_text=None)
b_st = p.button(s, 10, 'SET_STATUS', 'تغيير الحالة')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    select name_ar, unit_type, usage_type, bedrooms, bathrooms, net_area_sqm, gross_area_sqm, furnishing, view_code, list_price,',
    '           title_deed_no, amenities, notes, status_code, property_id',
    '      into :P13_NAME, :P13_UTYPE, :P13_USAGE, :P13_BEDS, :P13_BATHS, :P13_NET, :P13_GROSS, :P13_FURN, :P13_VIEW, :P13_PRICE,',
    '           :P13_DEED, :P13_AMEN, :P13_NOTES, :P13_STATUS, :P13_PROP',
    '      from re_unit where id = :P13_ID and company_id = noona_re_pkg.company;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('id', 'P13_ID', 'n'), ('name_ar', 'P13_NAME', 's'), ('unit_type', 'P13_UTYPE', 's'), ('usage_type', 'P13_USAGE', 's'),
    ('bedrooms', 'P13_BEDS', 'n'), ('bathrooms', 'P13_BATHS', 'n'), ('net_area', 'P13_NET', 'n'), ('gross_area', 'P13_GROSS', 'n'),
    ('furnishing', 'P13_FURN', 's'), ('view', 'P13_VIEW', 's'), ('price', 'P13_PRICE', 'n'), ('deed', 'P13_DEED', 's'),
    ('amenities', 'P13_AMEN', 's'), ('notes', 'P13_NOTES', 's')]) + ' into l_doc from dual;', '    noona_re_pkg.save_unit(l_doc);', 'end;'],
          when_button=b_save, success='تم حفظ الوحدة')
p.process(20, 'AFTER_SUBMIT', 'Status', 'noona_re_pkg.set_unit_status(:P13_ID, :P13_STATUS);', when_button=b_st, success='تم تغيير الحالة')
p.ir('بلاغات الصيانة على الوحدة', 30, [
    "select r.id, r.doc_no, r.title, noona_mnt_pkg.priority_label(r.priority_code) as priority, noona_mnt_pkg.status_label(r.status_code) as status,",
    "       to_char(r.created_at, 'YYYY-MM-DD HH24:MI') as created from mnt_request r where r.unit_id = :P13_ID order by r.created_at desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'البلاغ', {}), ('TITLE', 'العنوان', {}), ('PRIORITY', 'الأولوية', {}),
     ('STATUS', 'الحالة', {}), ('CREATED', 'التاريخ', {})], link=link(71, 'P71_ID'), titled=True, rows=10)
p.branch(10, url(13, 'P13_ID', '&P13_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== لوحة الاستقبال (عملية AJAX مشتركة)
FD_AJAX = [
    'declare',
    '    l_c  clob;',
    '    l_id number;',
    '    l_op varchar2(30) := apex_application.g_x01;',
    '    l_p  number;',
    '    l_d1 date;',
    '    l_d2 date;',
    '    function n(p varchar2) return number is begin return to_number(p); end;',
    "    function d(p varchar2) return date is begin return to_date(p, 'YYYY-MM-DD'); end;",
    '    procedure out(p clob) is',
    '        l_off pls_integer := 1;',
    '    begin',
    '        while l_off <= dbms_lob.getlength(p) loop',
    '            htp.prn(dbms_lob.substr(p, 8000, l_off));',
    '            l_off := l_off + 8000;',
    '        end loop;',
    '    end;',
    'begin',
    "    l_p := case when l_op in ('TYPES', 'FREE') then n(apex_application.g_x02) end;",
    "    l_d1 := case when l_op = 'FREE' then d(apex_application.g_x03) end;",
    "    l_d2 := case when l_op = 'FREE' then d(apex_application.g_x04) end;",
    '    case l_op',
    "        when 'RACK' then l_c := noona_hsp_pkg.rack_json(n(apex_application.g_x02));",
    "        when 'CHART' then l_c := noona_hsp_pkg.chart_json(n(apex_application.g_x02), d(apex_application.g_x03), n(apex_application.g_x04));",
    "        when 'STAY' then l_c := noona_hsp_pkg.stay_json(n(apex_application.g_x02));",
    "        when 'TYPES' then",
    "            select json_object('types' value (select json_arrayagg(json_object('id' value t.id, 'name' value t.name_ar,",
    "                       'rate' value noona_hsp_pkg.nightly_rate((select min(p.id) from hsp_rate_plan p where p.property_id = t.property_id",
    "                                     and p.is_active = 'Y' and p.stay_type = 'DAILY'), t.id, noona_hsp_pkg.business_date(t.property_id)),",
    "                       'free' value noona_hsp_pkg.available_count(t.property_id, t.id, noona_hsp_pkg.business_date(t.property_id),",
    "                                     noona_hsp_pkg.business_date(t.property_id) + 1)) order by t.code returning clob)",
    "                       from hsp_room_type t where t.property_id = l_p and t.is_active = 'Y'),",
    "                   'plans' value (select json_arrayagg(json_object('id' value p.id, 'name' value p.name_ar) order by p.code returning clob)",
    "                       from hsp_rate_plan p where p.property_id = l_p and p.is_active = 'Y') returning clob)",
    '              into l_c from dual;',
    "        when 'FREE' then",
    "            select json_arrayagg(json_object('id' value r.id, 'no' value r.room_no, 'type' value t.name_ar, 'hk' value r.housekeeping_status)",
    "                   order by r.room_no returning clob) into l_c",
    "              from hsp_room r join hsp_room_type t on t.id = r.room_type_id",
    "             where r.property_id = l_p and r.status_code = 'ACTIVE'",
    "               and noona_hsp_pkg.is_free(r.id, l_d1, l_d2) = 'Y';",
    "            l_c := nvl(l_c, to_clob('[]'));",
    "        when 'PARTIES' then",
    "            select json_arrayagg(json_object('id' value id, 'name' value display_name_ar) order by display_name_ar returning clob) into l_c",
    "              from pty_party where party_type = 'ORGANIZATION' and status_code = 'ACTIVE';",
    "            l_c := nvl(l_c, to_clob('[]'));",
    "        when 'WALKIN' then l_id := noona_hsp_pkg.walk_in(apex_application.g_clob_01); l_c := '{\"stay\":' || l_id || '}';",
    "        when 'CHECKIN' then l_id := noona_hsp_pkg.check_in(n(apex_application.g_x02), n(apex_application.g_x03), nvl(apex_application.g_x04, 'N'));",
    "            l_c := '{\"stay\":' || l_id || '}';",
    "        when 'NOSHOW' then noona_hsp_pkg.mark_no_show(n(apex_application.g_x02));",
    "        when 'EXTEND' then noona_hsp_pkg.change_departure(n(apex_application.g_x02), d(apex_application.g_x03));",
    "        when 'MOVE' then l_id := noona_hsp_pkg.move_room(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04);",
    "            l_c := '{\"stay\":' || l_id || '}';",
    "        when 'CHARGE' then l_id := noona_hsp_pkg.post_charge(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04,",
    "                                                            n(apex_application.g_x05));",
    "        when 'PAY' then l_id := noona_hsp_pkg.post_payment(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04,",
    "                                                          null, null, apex_application.g_x05);",
    "        when 'CHECKOUT' then l_id := noona_hsp_pkg.check_out(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := '{\"folio\":' || l_id || '}';",
    "        when 'HK' then noona_hsp_pkg.set_hk_status(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'RTS' then noona_hsp_pkg.return_to_service(n(apex_application.g_x02));",
    "        when 'SUMMARY' then l_c := noona_hsp_pkg.front_summary(n(apex_application.g_x02));",
    "        else raise_application_error(-20500, 'NOONA-HSP-099: عملية غير معروفة ' || l_op);",
    '    end case;',
    "    out(nvl(l_c, to_clob('{\"ok\":true}')));",
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('err', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']
LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'frontdesk.js'; "
          "document.head.appendChild(s); })();"]


def front_page(pid, name, alias, title, mode):
    p = app.page(pid, name, alias, title, scheme=HSP, protection='N')
    f = p.static('الفندق', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select(f'P{pid}_PROPERTY', f, 10, 'الفندق / العقار', lov_sql=HOTEL_LOV, null_text=None, submit=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', f':P{pid}_PROPERTY := nvl(:P{pid}_PROPERTY, noona_hsp_pkg.default_property);')
    if mode == 'rack':
        p.dynamic('المؤشرات', 8, f"return '<div id=\"nnFdKpi\">' || noona_hsp_pkg.front_summary(:P{pid}_PROPERTY) || '</div>';", hide_header=True,
                  condition=f':P{pid}_PROPERTY is not null')
    p.dynamic(title, 10, [
        'begin',
        f"    return '<div id=\"nnFd\" class=\"nn-fd\" data-mode=\"{mode}\" data-property=\"' || :P{pid}_PROPERTY",
        "        || '\" data-folio=\"' || apex_escape.html_attribute(" + get_url(24, 'P24_ID', sub='990000000001') + ")",
        "        || '\" data-res=\"' || apex_escape.html_attribute(apex_page.get_url(p_page => 22, p_clear_cache => '22',",
        "               p_items => 'P22_PROPERTY,P22_ROOM', p_values => :P" + str(pid) + "_PROPERTY || ',990000000001')) || '\"'",
        "        || ' data-req=\"' || apex_escape.html_attribute(apex_page.get_url(p_page => 71, p_clear_cache => '71',",
        "               p_items => 'P71_NEW_ROOM', p_values => '990000000001')) || '\"'",
        "        || ' data-resv=\"' || apex_escape.html_attribute(" + get_url(23, 'P23_ID', sub='990000000001') + ") || '\"></div>';",
        'end;'], hide_header=True, condition=f':P{pid}_PROPERTY is not null')
    p.static('لا يوجد فندق', 12, condition=f':P{pid}_PROPERTY is null',
             text='<p class="nn-hint">لا توجد غرف فندقية بعد. أضف عقاراً من «إضافة عقار» وفعّل «تشغيل الوحدات فندقياً»، '
                  'أو أنشئ الغرف من «إعداد الضيافة».</p>')
    p.process(1, 'ON_DEMAND', 'FD', FD_AJAX)
    p.onload(LOADER)
    p.branch(10, url(pid, f'P{pid}_PROPERTY', f'&P{pid}_PROPERTY.'))
    return p


# =============================================================== 20) لوحة الاستقبال
front_page(20, 'Front Desk', 'FRONT-DESK', 'لوحة الاستقبال', 'rack')

# =============================================================== 21) الحجوزات
p = app.page(21, 'Reservations', 'RESERVATIONS', 'الحجوزات', scheme=HSP)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'حجز جديد', hot=True, redirect=url(22, clear='RP,22'))
p.button(f, 20, 'FD', 'لوحة الاستقبال', redirect=url(20))
RES_SQL = [
    "select x.id, x.doc_no, pr.name_ar as hotel, noona_hsp_pkg.guest_name(x.guest_party_id) as guest, noona_hsp_pkg.guest_phone(x.guest_party_id) as phone,",
    "       (select listagg(r.room_no, '، ') within group (order by r.room_no) from hsp_reservation_room rr join hsp_room r on r.id = rr.room_id",
    "         where rr.reservation_id = x.id) as rooms, to_char(x.arrival_date, 'YYYY-MM-DD') as arr, to_char(x.departure_date, 'YYYY-MM-DD') as dep,",
    "       x.departure_date - x.arrival_date as nights, x.total_estimate, x.deposit_amount, noona_hsp_pkg.channel_label(x.channel_code) as channel,",
    "       '<span class=\"nn-badge ' || case when x.status_code in ('CHECKED_IN') then 'is-success' when x.status_code in ('CANCELLED', 'NO_SHOW')",
    "       then 'is-danger' when x.status_code = 'CHECKED_OUT' then 'is-info' else 'is-warning' end || '\">' || noona_hsp_pkg.res_status_label(x.status_code)",
    "       || '</span>' as status_html",
    "  from hsp_reservation x join re_property pr on pr.id = x.property_id where x.company_id = noona_hsp_pkg.company"]
RES_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الحجز', {}), ('HOTEL', 'الفندق', {}), ('GUEST', 'النزيل', {}),
            ('PHONE', 'الجوال', {}), ('ROOMS', 'الغرفة', {}), ('ARR', 'الوصول', {}), ('DEP', 'المغادرة', {}),
            ('NIGHTS', 'الليالي', {'type': 'NUMBER'}), ('TOTAL_ESTIMATE', 'الإجمالي التقديري', {'type': 'NUMBER'}),
            ('DEPOSIT_AMOUNT', 'العربون', {'type': 'NUMBER'}), ('CHANNEL', 'القناة', {}), ('STATUS_HTML', 'الحالة', {'html': True})]
p.ir('الوصول المتوقع اليوم', 10, RES_SQL + [
    " and x.status_code in ('TENTATIVE', 'CONFIRMED', 'GUARANTEED') and x.arrival_date <= noona_hsp_pkg.business_date(x.property_id) order by x.arrival_date"],
    RES_COLS, link=link(23, 'P23_ID'), titled=True, rows=20)
p.ir('كل الحجوزات', 20, RES_SQL + [" order by x.arrival_date desc, x.id desc"], RES_COLS, link=link(23, 'P23_ID'), titled=True)

# =============================================================== 22) حجز جديد
p = app.page(22, 'New Reservation', 'NEW-RESERVATION', 'حجز جديد', scheme=HSP, protection='N')
g = p.static('النزيل', 10)
p.select('P22_PROPERTY', g, 5, 'الفندق', lov_sql=HOTEL_LOV, null_text=None, required=True, submit=True)
p.text('P22_GUEST', g, 10, 'اسم النزيل', required=True, maxlen=200)
p.text('P22_PHONE', g, 20, 'الجوال', maxlen=20, width=15)
p.select('P22_IDTYPE', g, 30, 'نوع الهوية', lov_sql=IDTYPE_LOV, null_text=None)
p.text('P22_IDNO', g, 40, 'رقم الهوية / الإقامة / الجواز', maxlen=30, width=20)
p.select('P22_NAT', g, 50, 'الجنسية', lov_sql=COUNTRY_LOV, null_text=None)
p.select('P22_COMPANY', g, 60, 'الشركة الحاجزة (اختياري)', lov_sql=COMPANY_PARTY_LOV)
s = p.static('الإقامة', 20)
p.date('P22_ARR', s, 10, 'الوصول', required=True)
p.date('P22_DEP', s, 20, 'المغادرة', required=True)
p.select('P22_RT', s, 30, 'نوع الغرفة / الشقة', lov_sql=(
    "select name_ar || ' (' || noona_hsp_pkg.available_count(property_id, id, to_date(:P22_ARR, 'YYYY-MM-DD'), to_date(:P22_DEP, 'YYYY-MM-DD'))"
    " || ' متاحة)' d, id r from hsp_room_type where property_id = :P22_PROPERTY and is_active = 'Y' order by code"), cascade='P22_PROPERTY,P22_ARR,P22_DEP')
p.select('P22_ROOM', s, 40, 'غرفة محددة (اختياري)', lov_sql=(
    "select r.room_no || ' - ' || t.name_ar d, r.id r from hsp_room r join hsp_room_type t on t.id = r.room_type_id"
    " where r.property_id = :P22_PROPERTY and r.status_code = 'ACTIVE'"
    " and noona_hsp_pkg.is_free(r.id, to_date(:P22_ARR, 'YYYY-MM-DD'), to_date(:P22_DEP, 'YYYY-MM-DD')) = 'Y' order by r.room_no"),
    cascade='P22_PROPERTY,P22_ARR,P22_DEP', null_text='- أول غرفة متاحة من النوع -')
p.select('P22_PLAN', s, 50, 'خطة السعر', lov_sql="select name_ar d, id r from hsp_rate_plan where property_id = :P22_PROPERTY and is_active = 'Y' order by code",
         cascade='P22_PROPERTY')
p.number('P22_RATE', s, 60, 'سعر الليلة (يترك للسعر المعتمد)')
p.number('P22_ADULTS', s, 70, 'البالغون')
p.number('P22_CHILDREN', s, 80, 'الأطفال')
p.select('P22_CHANNEL', s, 90, 'قناة الحجز', lov_sql=CHANNEL_LOV, null_text=None)
p.text('P22_CREF', s, 100, 'مرجع القناة', maxlen=100, width=20)
p.textarea('P22_REQ', s, 110, 'طلبات خاصة')
dp = p.static('العربون', 30)
p.number('P22_DEPOSIT', dp, 10, 'مبلغ العربون')
p.select('P22_DMETHOD', dp, 20, 'طريقة السداد', lov_sql=PAY_LOV, null_text=None)
p.select('P22_BANK', dp, 30, 'الحساب البنكي (للشبكة والتحويل)', lov_sql=BANK_LOV)
p.select('P22_BOX', dp, 40, 'الصندوق (للنقد)', lov_sql=BOX_LOV)
b = p.button(dp, 10, 'CREATE', 'تأكيد الحجز', hot=True)
p.hidden('P22_ID', dp, 50)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    '    :P22_PROPERTY := nvl(:P22_PROPERTY, noona_hsp_pkg.default_property);',
    "    :P22_ARR := nvl(:P22_ARR, to_char(noona_hsp_pkg.business_date(:P22_PROPERTY), 'YYYY-MM-DD'));",
    "    :P22_DEP := nvl(:P22_DEP, to_char(to_date(:P22_ARR, 'YYYY-MM-DD') + 1, 'YYYY-MM-DD'));",
    "    :P22_ADULTS := nvl(:P22_ADULTS, 1); :P22_CHILDREN := nvl(:P22_CHILDREN, 0); :P22_CHANNEL := nvl(:P22_CHANNEL, 'PHONE');",
    "    :P22_IDTYPE := nvl(:P22_IDTYPE, 'NATIONAL_ID'); :P22_NAT := nvl(:P22_NAT, 'SA'); :P22_DMETHOD := nvl(:P22_DMETHOD, 'CASH');",
    '    if :P22_ROOM is not null and :P22_RT is null then',
    '        select max(room_type_id) into :P22_RT from hsp_room where id = :P22_ROOM;',
    '    end if;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Create', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('property', 'P22_PROPERTY', 'n'), ('guest_name', 'P22_GUEST', 's'), ('phone', 'P22_PHONE', 's'), ('id_type', 'P22_IDTYPE', 's'),
    ('id_no', 'P22_IDNO', 's'), ('nationality', 'P22_NAT', 's'), ('company_party', 'P22_COMPANY', 'n'), ('arrival', 'P22_ARR', 's'),
    ('departure', 'P22_DEP', 's'), ('room_type', 'P22_RT', 'n'), ('room', 'P22_ROOM', 'n'), ('rate_plan', 'P22_PLAN', 'n'),
    ('rate', 'P22_RATE', 'n'), ('adults', 'P22_ADULTS', 'n'), ('children', 'P22_CHILDREN', 'n'), ('channel', 'P22_CHANNEL', 's'),
    ('channel_ref', 'P22_CREF', 's'), ('requests', 'P22_REQ', 's'), ('deposit', 'P22_DEPOSIT', 'n'), ('deposit_method', 'P22_DMETHOD', 's'),
    ('bank_account', 'P22_BANK', 'n'), ('cash_box', 'P22_BOX', 'n')]) + ' into l_doc from dual;',
    '    :P22_ID := noona_hsp_pkg.create_reservation(l_doc);', 'end;'], when_button=b, success='تم تأكيد الحجز')
p.branch(5, url(23, 'P23_ID', '&P22_ID.', 'RP,23') + '&success_msg=#SUCCESS_MSG#', when_button=b)
p.branch(10, url(22, 'P22_PROPERTY', '&P22_PROPERTY.'))

# =============================================================== 23) الحجز
p = app.page(23, 'Reservation', 'RESERVATION', 'الحجز', scheme=HSP, protection='N')
p.dynamic('الحجز', 5, [
    'declare l_r hsp_reservation%rowtype; l_room varchar2(100); l_f number;',
    'begin',
    '    select * into l_r from hsp_reservation where id = :P23_ID and company_id = noona_hsp_pkg.company;',
    "    select listagg(r.room_no || ' (' || t.name_ar || ')', '، ') within group (order by r.room_no) into l_room",
    '      from hsp_reservation_room rr join hsp_room r on r.id = rr.room_id join hsp_room_type t on t.id = rr.room_type_id',
    '     where rr.reservation_id = l_r.id;',
    '    l_f := noona_hsp_pkg.folio_of_reservation(l_r.id);',
    "    return '<div class=\"nn-hr-runbar\"><b>' || l_r.doc_no || '</b> · ' || apex_escape.html(noona_hsp_pkg.guest_name(l_r.guest_party_id))",
    "        || ' · ' || apex_escape.html(noona_hsp_pkg.guest_phone(l_r.guest_party_id)) || ' · <span class=\"nn-badge is-info\">'",
    "        || noona_hsp_pkg.res_status_label(l_r.status_code) || '</span></div><table class=\"nn-rpt\"><tbody>'",
    "        || '<tr><td class=\"nn-rpt-text\">الإقامة</td><td class=\"nn-rpt-text\">' || to_char(l_r.arrival_date, 'YYYY-MM-DD') || ' ← '",
    "        || to_char(l_r.departure_date, 'YYYY-MM-DD') || ' (' || (l_r.departure_date - l_r.arrival_date) || ' ليلة)</td></tr>'",
    "        || '<tr><td class=\"nn-rpt-text\">الغرفة</td><td class=\"nn-rpt-text\">' || apex_escape.html(l_room) || '</td></tr>'",
    "        || '<tr><td class=\"nn-rpt-text\">النزلاء</td><td class=\"nn-rpt-text\">' || l_r.adults || ' بالغ' || case when l_r.children > 0 then ' + '",
    "        || l_r.children || ' طفل' end || '</td></tr><tr><td class=\"nn-rpt-text\">القناة</td><td class=\"nn-rpt-text\">'",
    "        || noona_hsp_pkg.channel_label(l_r.channel_code) || ' ' || apex_escape.html(l_r.channel_reference) || '</td></tr>'",
    "        || '<tr><td class=\"nn-rpt-text\">الإجمالي التقديري</td><td>' || to_char(l_r.total_estimate, 'FM999G999G990D00') || '</td></tr>'",
    "        || '<tr><td class=\"nn-rpt-text\">رصيد الحساب</td><td>' || to_char(noona_hsp_pkg.folio_balance(l_f), 'FM999G999G990D00') || '</td></tr>'",
    "        || '<tr><td class=\"nn-rpt-text\">طلبات وملاحظات</td><td class=\"nn-rpt-text\">' || apex_escape.html(l_r.special_requests) || '</td></tr>'",
    "        || '</tbody></table>';",
    'exception when no_data_found then return null;',
    'end;'], hide_header=True)
act = p.static('الإجراءات', 10)
p.hidden('P23_ID', act, 1, protected=False)
OPEN_RES = "noona_hsp_pkg.res_status(:P23_ID) in ('TENTATIVE', 'CONFIRMED', 'GUARANTEED')"
p.select('P23_ROOM', act, 10, 'غرفة الدخول (اختياري لتغيير الغرفة)', lov_sql=(
    "select r.room_no || ' - ' || t.name_ar || ' · ' || noona_hsp_pkg.hk_label(r.housekeeping_status) d, r.id r from hsp_room r"
    " join hsp_room_type t on t.id = r.room_type_id join hsp_reservation x on x.property_id = r.property_id"
    " where x.id = :P23_ID and r.status_code = 'ACTIVE' and noona_hsp_pkg.is_free(r.id, noona_hsp_pkg.business_date(x.property_id),"
    " x.departure_date, null, (select min(id) from hsp_reservation_room where reservation_id = x.id)) = 'Y' order by r.room_no"),
    null_text='- الغرفة المحجوزة -')
p.yesno('P23_FORCE', act, 20, 'الدخول حتى لو لم تنظف الغرفة')
p.text('P23_REASON', act, 30, 'سبب الإلغاء', maxlen=500)
b_in = p.button(act, 10, 'CHECKIN', 'تسجيل الدخول', hot=True, condition=OPEN_RES)
p.button(act, 20, 'FOLIO', 'كشف حساب النزيل', redirect="javascript:window.open('&P23_FOLIO_URL.', '_blank');")
b_cancel = p.button(act, 30, 'CANCEL_RES', 'إلغاء الحجز', condition=OPEN_RES)
b_ns = p.button(act, 40, 'NOSHOW', 'لم يحضر', condition=OPEN_RES)
p.hidden('P23_FOLIO_URL', act, 40)
p.process(5, 'BEFORE_HEADER', 'Folio URL', [
    "begin",
    "    :P23_FOLIO_URL := apex_page.get_url(p_page => 24, p_items => 'P24_ID', p_values => noona_hsp_pkg.folio_of_reservation(:P23_ID));",
    "    :P23_FORCE := nvl(:P23_FORCE, 'N');",
    "end;"])
p.process(10, 'AFTER_SUBMIT', 'Check-in', ['declare l_s number;', 'begin',
          "    l_s := noona_hsp_pkg.check_in(:P23_ID, :P23_ROOM, nvl(:P23_FORCE, 'N'));", 'end;'], when_button=b_in,
          success='تم تسجيل دخول النزيل')
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_hsp_pkg.cancel_reservation(:P23_ID, :P23_REASON);', when_button=b_cancel, success='تم إلغاء الحجز')
p.process(30, 'AFTER_SUBMIT', 'No show', 'noona_hsp_pkg.mark_no_show(:P23_ID);', when_button=b_ns, success='سجل عدم الحضور')
p.branch(10, url(23, 'P23_ID', '&P23_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 24) كشف حساب النزيل
p = app.page(24, 'Guest Folio', 'FOLIO', 'كشف حساب النزيل', scheme=HSP, protection='N')
f = p.static('الإجراءات', 5, hide_header=True)
p.hidden('P24_ID', f, 1, protected=False)
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
p.dynamic('الفاتورة', 10, 'return noona_hsp_pkg.folio_html(:P24_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 25) التدبير الفندقي
p = front_page(25, 'Housekeeping', 'HOUSEKEEPING', 'التدبير الفندقي', 'hk')
p.ir('مهام التنظيف المفتوحة', 30, [
    "select t.id, r.room_no, case t.task_type when 'DEPARTURE_CLEAN' then 'تنظيف مغادرة' when 'STAYOVER' then 'تنظيف يومي لغرفة مشغولة'",
    "       when 'DEEP_CLEAN' then 'تنظيف عميق' when 'TURNDOWN' then 'تجهيز مسائي' else 'فحص' end as task, to_char(t.task_date, 'YYYY-MM-DD') as d,",
    "       noona_hsp_pkg.res_status_label(t.status_code) as status, p.display_name_ar as worker",
    "  from hsp_housekeeping_task t join hsp_room r on r.id = t.room_id left join hr_employee e on e.id = t.assigned_employee_id",
    "  left join pty_party p on p.id = e.person_party_id",
    " where r.property_id = :P25_PROPERTY and t.status_code in ('PENDING', 'ASSIGNED', 'IN_PROGRESS') order by r.room_no"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ROOM_NO', 'الغرفة', {}), ('TASK', 'المهمة', {}), ('D', 'التاريخ', {}),
     ('STATUS', 'الحالة', {}), ('WORKER', 'العامل', {})], titled=True, rows=50)
a = p.static('إسناد مهمة لعامل', 40)
p.select('P25_TASK', a, 10, 'المهمة', lov_sql=(
    "select r.room_no || ' - ' || case t.task_type when 'DEPARTURE_CLEAN' then 'تنظيف مغادرة' when 'STAYOVER' then 'تنظيف يومي' when 'DEEP_CLEAN' then 'تنظيف عميق' "
    "when 'TURNDOWN' then 'تجهيز مسائي' else 'فحص' end d, t.id r from hsp_housekeeping_task t join hsp_room r on r.id = t.room_id"
    " where r.property_id = :P25_PROPERTY and t.status_code in ('PENDING', 'ASSIGNED') order by r.room_no"))
p.select('P25_EMP', a, 20, 'العامل', lov_sql=EMP_LOV.replace('noona_mnt_pkg', 'noona_hsp_pkg'))
b = p.button(a, 10, 'ASSIGN', 'إسناد')
p.process(20, 'AFTER_SUBMIT', 'Assign', 'noona_hsp_pkg.assign_hk(:P25_TASK, :P25_EMP);', when_button=b, success='تم الإسناد')

# =============================================================== 26) التدقيق الليلي
p = app.page(26, 'Night Audit', 'NIGHT-AUDIT', 'التدقيق الليلي', scheme=HSP)
f = p.static('إقفال يوم العمل', 5, text='<p class="nn-hint">يسجل عدم الحضور للحجوزات التي لم تصل، ويرحل رسوم ليلة اليوم لكل نزيل مقيم '
                                     '(إيراد الإيواء وضريبة القيمة المضافة على حساب النزيل)، ويحسب الإشغال ومتوسط السعر، '
                                     'ويجعل الغرف المشغولة بحاجة لتنظيف يومي، ثم ينقل تاريخ العمل لليوم التالي.</p>')
p.select('P26_PROPERTY', f, 10, 'الفندق', lov_sql=HOTEL_LOV, null_text=None, submit=True)
p.yesno('P26_NOSHOW', f, 20, 'تسجيل عدم الحضور آلياً')
b = p.button(f, 10, 'AUDIT', 'تشغيل التدقيق الليلي', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P26_PROPERTY := nvl(:P26_PROPERTY, noona_hsp_pkg.default_property);",
                                            ":P26_NOSHOW := nvl(:P26_NOSHOW, 'Y');"])
p.process(10, 'AFTER_SUBMIT', 'Audit', ['declare l_id number;', 'begin',
          '    l_id := noona_hsp_pkg.night_audit(:P26_PROPERTY, :P26_NOSHOW);', 'end;'], when_button=b,
          success='تم التدقيق الليلي وترحيل رسوم الغرف ونقل تاريخ العمل')
p.dynamic('الحالة', 8, 'return noona_hsp_pkg.front_summary(:P26_PROPERTY);', hide_header=True, condition=':P26_PROPERTY is not null')
p.ir('سجل التدقيق', 20, [
    "select a.id, to_char(a.business_date, 'YYYY-MM-DD') as bd, a.occupancy_pct, a.room_revenue, a.adr, a.no_shows,",
    "       noona_hsp_pkg.res_status_label(a.status_code) as status, a.created_by, to_char(a.created_at, 'YYYY-MM-DD HH24:MI') as at_time",
    "  from hsp_night_audit a where a.property_id = :P26_PROPERTY order by a.business_date desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('BD', 'يوم العمل', {}), ('OCCUPANCY_PCT', 'الإشغال %', {'type': 'NUMBER'}),
     ('ROOM_REVENUE', 'إيراد الغرف', {'type': 'NUMBER'}), ('ADR', 'متوسط السعر', {'type': 'NUMBER'}), ('NO_SHOWS', 'عدم الحضور', {'type': 'NUMBER'}),
     ('STATUS', 'الحالة', {}), ('CREATED_BY', 'بواسطة', {}), ('AT_TIME', 'الوقت', {})], titled=True, rows=31)
p.branch(10, url(26, 'P26_PROPERTY', '&P26_PROPERTY.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 27) إعداد الضيافة
p = app.page(27, 'Hotel Setup', 'HOTEL-SETUP', 'إعداد الضيافة', scheme=HSP)
f = p.static('الفندق', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P27_PROPERTY', f, 10, 'الفندق / العقار', lov_sql=PROP_LOV, null_text=None, submit=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', '    :P27_PROPERTY := nvl(:P27_PROPERTY, noona_hsp_pkg.default_property);',
          '    if :P27_PROPERTY is null then',
          '        select min(id) into :P27_PROPERTY from re_property where company_id = noona_hsp_pkg.company;', '    end if;', 'end;'])
t = p.static('نوع غرفة / شقة', 10)
p.select('P27_RT_ID', t, 5, 'تعديل نوع', lov_sql="select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code",
         null_text='- نوع جديد -', submit=True)
p.text('P27_RT_CODE', t, 10, 'الرمز', maxlen=30, width=10)
p.text('P27_RT_NAME', t, 20, 'الاسم (ديلوكس، جناح، شقة غرفتين...)', maxlen=200)
p.number('P27_RT_ADULTS', t, 30, 'أقصى بالغين')
p.number('P27_RT_CHILDREN', t, 40, 'أقصى أطفال')
p.text('P27_RT_BEDS', t, 50, 'الأسرة', maxlen=100, width=20)
p.number('P27_RT_RATE', t, 60, 'السعر الأساسي لليلة')
b_rt = p.button(t, 10, 'SAVE_RT', 'حفظ النوع', hot=True)
p.process(6, 'BEFORE_HEADER', 'Load type', [
    'begin',
    '    if :P27_RT_ID is not null then',
    '        select code, name_ar, max_adults, max_children, bed_config, base_rate into :P27_RT_CODE, :P27_RT_NAME, :P27_RT_ADULTS,',
    '               :P27_RT_CHILDREN, :P27_RT_BEDS, :P27_RT_RATE from hsp_room_type where id = :P27_RT_ID;',
    '    end if;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save type', ['begin', '    :P27_RT_ID := noona_hsp_pkg.save_room_type(:P27_RT_ID, :P27_PROPERTY, :P27_RT_CODE, :P27_RT_NAME,',
          '                       :P27_RT_ADULTS, :P27_RT_CHILDREN, :P27_RT_BEDS, :P27_RT_RATE);', 'end;'], when_button=b_rt, success='تم حفظ النوع')
rp = p.static('خطة أسعار وسعر موسمي', 20, text='<p class="nn-hint">الخطة اليومية للفنادق، والأسبوعية والشهرية للشقق الفندقية '
                                               '(يقسم السعر على 7 أو 30 لليلة). السعر الموسمي يسري في فترته على النوع المحدد.</p>')
p.text('P27_PL_CODE', rp, 10, 'رمز الخطة', maxlen=30, width=10)
p.text('P27_PL_NAME', rp, 20, 'اسم الخطة', maxlen=200)
p.select('P27_PL_TYPE', rp, 30, 'نوع الإقامة', null_text=None, lov_sql='STATIC2:يومي;DAILY,أسبوعي;WEEKLY,شهري;MONTHLY')
p.select('P27_PL_MEAL', rp, 40, 'الوجبات', null_text=None, lov_sql='STATIC2:بدون وجبات;ROOM_ONLY,إفطار;BREAKFAST,نصف إقامة;HALF_BOARD,إقامة كاملة;FULL_BOARD')
p.yesno('P27_PL_TAX', rp, 50, 'السعر شامل الضريبة')
p.text('P27_PL_POLICY', rp, 60, 'سياسة الإلغاء', maxlen=500)
b_pl = p.button(rp, 10, 'SAVE_PLAN', 'إضافة الخطة')
p.select('P27_R_PLAN', rp, 70, 'الخطة (للسعر الموسمي)', lov_sql="select name_ar d, id r from hsp_rate_plan where property_id = :P27_PROPERTY order by code")
p.select('P27_R_TYPE', rp, 80, 'نوع الغرفة', lov_sql="select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code")
p.date('P27_R_FROM', rp, 90, 'من')
p.date('P27_R_TO', rp, 100, 'إلى')
p.number('P27_R_AMOUNT', rp, 110, 'السعر (لليلة/الأسبوع/الشهر حسب الخطة)')
b_rate = p.button(rp, 20, 'SAVE_RATE', 'حفظ السعر')
p.process(20, 'AFTER_SUBMIT', 'Save plan', ['declare l_id number;', 'begin',
          "    l_id := noona_hsp_pkg.save_rate_plan(null, :P27_PROPERTY, :P27_PL_CODE, :P27_PL_NAME, :P27_PL_TYPE, :P27_PL_MEAL, :P27_PL_TAX, :P27_PL_POLICY);",
          'end;'], when_button=b_pl, success='تمت إضافة خطة الأسعار')
p.process(30, 'AFTER_SUBMIT', 'Save rate', ['declare l_id number;', 'begin',
          "    l_id := noona_hsp_pkg.set_rate(:P27_R_PLAN, :P27_R_TYPE, to_date(:P27_R_FROM, 'YYYY-MM-DD'), to_date(:P27_R_TO, 'YYYY-MM-DD'), :P27_R_AMOUNT);",
          'end;'], when_button=b_rate, success='تم حفظ السعر')
rm = p.static('الغرف', 30)
p.text('P27_ROOM_NO', rm, 10, 'رقم الغرفة', maxlen=20, width=8)
p.select('P27_ROOM_TYPE', rm, 20, 'النوع', lov_sql="select name_ar d, id r from hsp_room_type where property_id = :P27_PROPERTY order by code")
b_room = p.button(rm, 10, 'ADD_ROOM', 'إضافة غرفة')
b_units = p.button(rm, 20, 'FROM_UNITS', 'إنشاء غرف من وحدات الضيافة في العقار')
p.process(40, 'AFTER_SUBMIT', 'Add room', ['declare l_id number;', 'begin',
          '    l_id := noona_hsp_pkg.add_room(:P27_PROPERTY, :P27_ROOM_TYPE, :P27_ROOM_NO);', 'end;'], when_button=b_room, success='تمت إضافة الغرفة')
p.process(50, 'AFTER_SUBMIT', 'From units', ['declare l_n number;', 'begin',
          '    l_n := noona_hsp_pkg.rooms_from_units(:P27_PROPERTY, :P27_ROOM_TYPE);',
          "    apex_application.g_print_success_message := 'تم إنشاء ' || l_n || ' غرفة من الوحدات';", 'end;'], when_button=b_units)
p.process(7, 'BEFORE_HEADER', 'Defaults2', [":P27_PL_TYPE := nvl(:P27_PL_TYPE, 'DAILY'); :P27_PL_MEAL := nvl(:P27_PL_MEAL, 'ROOM_ONLY');",
                                             ":P27_PL_TAX := nvl(:P27_PL_TAX, 'N');"])
p.ir('أنواع الغرف والأسعار', 40, [
    "select t.id, t.code, t.name_ar, t.max_adults, t.base_rate, (select count(*) from hsp_room r where r.room_type_id = t.id) as rooms,",
    "       (select listagg(pl.name_ar || ': ' || to_char(x.rate_amount, 'FM999G990') || ' (' || to_char(x.date_from, 'MM-DD') || '→' || to_char(x.date_to, 'MM-DD') || ')', ' | ')",
    "          within group (order by x.date_from) from hsp_rate x join hsp_rate_plan pl on pl.id = x.rate_plan_id where x.room_type_id = t.id) as rates",
    "  from hsp_room_type t where t.property_id = :P27_PROPERTY order by t.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('MAX_ADULTS', 'السعة', {'type': 'NUMBER'}),
     ('BASE_RATE', 'السعر الأساسي', {'type': 'NUMBER'}), ('ROOMS', 'الغرف', {'type': 'NUMBER'}), ('RATES', 'الأسعار الموسمية', {})], titled=True, rows=20)
p.ir('الغرف', 50, [
    "select r.id, r.room_no, t.name_ar as rtype, f.name_ar as floor_name, noona_hsp_pkg.hk_label(r.housekeeping_status) as hk,",
    "       case r.status_code when 'ACTIVE' then 'في الخدمة' when 'OUT_OF_ORDER' then 'خارج الخدمة' else r.status_code end as status, r.notes",
    "  from hsp_room r join hsp_room_type t on t.id = r.room_type_id left join re_floor f on f.id = r.floor_id",
    " where r.property_id = :P27_PROPERTY order by f.floor_no, r.room_no"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ROOM_NO', 'الغرفة', {}), ('RTYPE', 'النوع', {}), ('FLOOR_NAME', 'الطابق', {}),
     ('HK', 'النظافة', {}), ('STATUS', 'الحالة', {}), ('NOTES', 'ملاحظات', {})], titled=True, rows=100)
p.branch(10, url(27, 'P27_PROPERTY,P27_RT_ID', '&P27_PROPERTY.,&P27_RT_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 28) تقارير الضيافة
REPORTS = [('INHOUSE', 'النزلاء المقيمون'), ('OCC', 'الإشغال والإيراد اليومي (ADR وRevPAR)'), ('ARRIVALS', 'الوصول والمغادرة القادمة'),
           ('CITY', 'حسابات الشركات المحولة')]
p = app.page(28, 'Hotel Reports', 'HOTEL-REPORTS', 'تقارير الضيافة', scheme=HSP, protection='N')
f = p.static('التقرير', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P28_PROPERTY', f, 5, 'الفندق', lov_sql=HOTEL_LOV, null_text=None)
p.select('P28_REPORT', f, 10, 'التقرير', null_text=None, submit=True, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n in REPORTS))
p.date('P28_FROM', f, 20, 'من')
p.date('P28_TO', f, 30, 'إلى')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "    :P28_PROPERTY := nvl(:P28_PROPERTY, noona_hsp_pkg.default_property); :P28_REPORT := nvl(:P28_REPORT, 'INHOUSE');",
    "    :P28_FROM := nvl(:P28_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD')); :P28_TO := nvl(:P28_TO, to_char(sysdate, 'YYYY-MM-DD'));",
    'end;'])
p.dynamic('الإشغال', 10, "return noona_hsp_pkg.occupancy_html(:P28_PROPERTY, to_date(:P28_FROM, 'YYYY-MM-DD'), to_date(:P28_TO, 'YYYY-MM-DD'));",
          hide_header=True, condition=":P28_REPORT = 'OCC'", opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.ir('النزلاء المقيمون', 20, [
    "select s.id, r.room_no, noona_hsp_pkg.guest_name(x.guest_party_id) as guest, noona_hsp_pkg.guest_phone(x.guest_party_id) as phone,",
    "       to_char(s.check_in_at, 'YYYY-MM-DD HH24:MI') as since, to_char(s.expected_check_out, 'YYYY-MM-DD') as dep, s.nightly_rate,",
    "       noona_hsp_pkg.folio_balance(noona_hsp_pkg.folio_of_stay(s.id)) as balance, x.doc_no",
    "  from hsp_stay s join hsp_room r on r.id = s.room_id join hsp_reservation x on x.id = s.reservation_id",
    " where r.property_id = :P28_PROPERTY and s.status_code = 'IN_HOUSE' and :P28_REPORT = 'INHOUSE' order by r.room_no"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ROOM_NO', 'الغرفة', {}), ('GUEST', 'النزيل', {}), ('PHONE', 'الجوال', {}),
     ('SINCE', 'الدخول', {}), ('DEP', 'المغادرة', {}), ('NIGHTLY_RATE', 'سعر الليلة', {'type': 'NUMBER'}),
     ('BALANCE', 'الرصيد', {'type': 'NUMBER'}), ('DOC_NO', 'الحجز', {})], titled=True, rows=200)
p.ir('الوصول والمغادرة القادمة', 30, [
    "select x.id, x.doc_no, noona_hsp_pkg.guest_name(x.guest_party_id) as guest, to_char(x.arrival_date, 'YYYY-MM-DD') as arr,",
    "       to_char(x.departure_date, 'YYYY-MM-DD') as dep, noona_hsp_pkg.res_status_label(x.status_code) as status",
    "  from hsp_reservation x where x.property_id = :P28_PROPERTY and :P28_REPORT = 'ARRIVALS'",
    "   and x.status_code in ('TENTATIVE', 'CONFIRMED', 'GUARANTEED', 'CHECKED_IN')",
    "   and (x.arrival_date between to_date(:P28_FROM, 'YYYY-MM-DD') and to_date(:P28_TO, 'YYYY-MM-DD') + 7",
    "        or x.departure_date between to_date(:P28_FROM, 'YYYY-MM-DD') and to_date(:P28_TO, 'YYYY-MM-DD') + 7) order by x.arrival_date"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الحجز', {}), ('GUEST', 'النزيل', {}), ('ARR', 'الوصول', {}),
     ('DEP', 'المغادرة', {}), ('STATUS', 'الحالة', {})], link=link(23, 'P23_ID'), titled=True, rows=200)
p.ir('حسابات الشركات', 40, [
    "select f.id, f.folio_no, noona_hsp_pkg.guest_name(f.payer_party_id) as company, noona_hsp_pkg.guest_name(x.guest_party_id) as guest,",
    "       -(select sum(l.amount) from hsp_folio_line l where l.folio_id = f.id and l.line_type = 'TRANSFER') as amount,",
    "       to_char(f.updated_at, 'YYYY-MM-DD') as d",
    "  from hsp_folio f join hsp_reservation x on x.id = f.reservation_id",
    " where x.property_id = :P28_PROPERTY and f.status_code = 'TRANSFERRED' and :P28_REPORT = 'CITY' order by f.updated_at desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('FOLIO_NO', 'الحساب', {}), ('COMPANY', 'الشركة', {}), ('GUEST', 'النزيل', {}),
     ('AMOUNT', 'المبلغ المحول', {'type': 'NUMBER'}), ('D', 'التاريخ', {})], link=link(24, 'P24_ID'), titled=True, rows=100)
p.branch(10, url(28, 'P28_PROPERTY,P28_REPORT,P28_FROM,P28_TO', '&P28_PROPERTY.,&P28_REPORT.,&P28_FROM.,&P28_TO.', '28'))

# =============================================================== 70) لوحة الصيانة
p = app.page(70, 'Maintenance', 'MAINTENANCE', 'لوحة الصيانة', scheme=MNT, protection='N')
f = p.static('الفلاتر', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P70_PROPERTY', f, 10, 'العقار', lov_sql=PROP_LOV, null_text='- كل العقارات -', submit=True)
p.select('P70_TEAM', f, 20, 'الفريق', lov_sql=TEAM_LOV, null_text='- كل الفرق -', submit=True)
p.button(f, 10, 'NEW', 'بلاغ جديد', hot=True, redirect=url(71, clear='RP,71'))
p.dynamic('المؤشرات', 8, 'return noona_mnt_pkg.summary_html;', hide_header=True)
p.dynamic('البلاغات', 10, f"return noona_mnt_pkg.board_html(:P70_PROPERTY, :P70_TEAM, {get_url(71, 'P71_ID')});", hide_header=True)
st = p.static('تجهيز الصيانة', 3, condition="noona_mnt_pkg.is_ready = 'N'")
b = p.button(st, 10, 'SETUP', 'تجهيز الصيانة (فئات الأعطال والفريق العام)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_mnt_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم تجهيز الصيانة')
p.branch(10, url(70, 'P70_PROPERTY,P70_TEAM', '&P70_PROPERTY.,&P70_TEAM.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 71) البلاغ
p = app.page(71, 'Maintenance Request', 'MAINT-REQUEST', 'بلاغ الصيانة', scheme=MNT, protection='N')
rst = 'noona_mnt_pkg.request_status(:P71_ID)'
p.dynamic('البلاغ', 5, 'return noona_mnt_pkg.request_html(:P71_ID);', hide_header=True, condition=':P71_ID is not null')
n = p.static('بلاغ جديد', 10, condition=':P71_ID is null',
             text='<p class="nn-hint">حدد نوع العطل وموقعه (العقار ثم الوحدة أو الغرفة). الأولوية تحدد الموعد المستهدف للإنجاز: '
                  'طارئ ساعتان، عاجل 4 ساعات، مرتفع يوم، عادي 3 أيام، منخفض أسبوع. يمكن إسناده لفريق مباشرة.</p>')
p.hidden('P71_ID', n, 1, protected=False)
p.hidden('P71_NEW_ROOM', n, 2, protected=False)
p.hidden('P71_NEW_UNIT', n, 3, protected=False)
p.hidden('P71_NEW_PROP', n, 4, protected=False)
p.select('P71_CAT', n, 10, 'نوع العطل', lov_sql=CAT_LOV, required=True)
p.select('P71_PRIORITY', n, 20, 'الأولوية', lov_sql=PRIORITY_LOV, null_text='- حسب نوع العطل -')
p.text('P71_TITLE', n, 30, 'عنوان مختصر', maxlen=200)
p.textarea('P71_DESC', n, 40, 'وصف المشكلة', required=True)
p.select('P71_CHANNEL', n, 50, 'طريقة البلاغ', lov_sql=MCHANNEL_LOV, null_text=None)
p.select('P71_PROPERTY', n, 60, 'العقار', lov_sql=PROP_LOV)
p.select('P71_UNIT', n, 70, 'الوحدة', cascade='P71_PROPERTY', lov_sql=(
    "select code || ' - ' || name_ar d, id r from re_unit where property_id = :P71_PROPERTY order by code"))
p.select('P71_ROOM', n, 80, 'الغرفة الفندقية', cascade='P71_PROPERTY', lov_sql=(
    "select room_no d, id r from hsp_room where property_id = :P71_PROPERTY order by room_no"))
p.yesno('P71_OOO', n, 90, 'إيقاف الغرفة الشاغرة حتى الإصلاح')
p.text('P71_RNAME', n, 100, 'اسم المبلغ (مستأجر/نزيل/موظف)', maxlen=200)
p.text('P71_RPHONE', n, 110, 'جوال المبلغ', maxlen=30, width=15)
p.select('P71_CHARGE', n, 120, 'تحمل التكلفة', lov_sql=CHARGE_LOV, null_text=None)
p.select('P71_TEAM', n, 130, 'إسناد لفريق (اختياري)', lov_sql=TEAM_LOV)
b_new = p.button(n, 10, 'CREATE', 'تسجيل البلاغ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    '    if :P71_ID is null then',
    "        :P71_CHANNEL := nvl(:P71_CHANNEL, case when :P71_NEW_ROOM is not null then 'FRONT_DESK' else 'PHONE' end);",
    "        :P71_CHARGE := nvl(:P71_CHARGE, 'OWNER'); :P71_OOO := nvl(:P71_OOO, 'N');",
    '        if :P71_NEW_ROOM is not null then',
    '            :P71_ROOM := :P71_NEW_ROOM;',
    '            select max(property_id) into :P71_PROPERTY from hsp_room where id = :P71_NEW_ROOM;',
    '        end if;',
    '        :P71_UNIT := nvl(:P71_UNIT, :P71_NEW_UNIT); :P71_PROPERTY := nvl(:P71_PROPERTY, :P71_NEW_PROP);',
    '    end if;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Create', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('category', 'P71_CAT', 'n'), ('priority', 'P71_PRIORITY', 's'), ('title', 'P71_TITLE', 's'), ('description', 'P71_DESC', 's'),
    ('channel', 'P71_CHANNEL', 's'), ('property', 'P71_PROPERTY', 'n'), ('unit', 'P71_UNIT', 'n'), ('room', 'P71_ROOM', 'n'),
    ('room_ooo', 'P71_OOO', 's'), ('reporter_name', 'P71_RNAME', 's'), ('reporter_phone', 'P71_RPHONE', 's'),
    ('chargeable_to', 'P71_CHARGE', 's'), ('team', 'P71_TEAM', 'n')]) + ' into l_doc from dual;',
    '    :P71_ID := noona_mnt_pkg.create_request(l_doc);', 'end;'], when_button=b_new, success='تم تسجيل البلاغ')
a = p.static('الإجراءات', 20, condition=f':P71_ID is not null and {rst} not in (\'CLOSED\', \'CANCELLED\', \'REJECTED\')')
p.select('P71_A_TEAM', a, 10, 'الفريق', lov_sql=TEAM_LOV)
p.select('P71_A_TECH', a, 20, 'الفني', cascade='P71_A_TEAM', lov_sql=(
    "select nvl(p.display_name_ar, t.external_name) || nvl2(t.skills, ' - ' || t.skills, '') d, t.id r from mnt_technician t"
    " left join hr_employee e on e.id = t.employee_id left join pty_party p on p.id = e.person_party_id"
    " where t.team_id = :P71_A_TEAM and t.is_active = 'Y' order by 1"))
p.textarea('P71_NOTES', a, 30, 'ما تم عمله / سبب التعليق أو الإلغاء أو إعادة الفتح')
p.number('P71_HOURS', a, 40, 'ساعات عمل الفني')
p.number('P71_MATERIAL', a, 50, 'تكلفة المواد وقطع الغيار')
p.select('P71_RATING', a, 60, 'تقييم المبلغ', lov_sql='STATIC2:★★★★★ ممتاز;5,★★★★ جيد جداً;4,★★★ جيد;3,★★ مقبول;2,★ ضعيف;1')
b_as = p.button(a, 10, 'ASSIGN', 'إسناد', condition=f"{rst} in ('NEW', 'TRIAGED', 'ASSIGNED', 'ON_HOLD', 'IN_PROGRESS')")
b_st = p.button(a, 20, 'START', 'بدء التنفيذ', condition=f"{rst} in ('ASSIGNED', 'ON_HOLD')")
b_ho = p.button(a, 30, 'HOLD', 'تعليق', condition=f"{rst} in ('ASSIGNED', 'IN_PROGRESS')")
b_co = p.button(a, 40, 'COMPLETE', 'إنجاز', hot=True, condition=f"{rst} in ('ASSIGNED', 'IN_PROGRESS', 'ON_HOLD')")
b_cl = p.button(a, 50, 'CLOSE', 'إغلاق بالتقييم', hot=True, condition=f"{rst} in ('COMPLETED', 'VERIFIED')")
b_re = p.button(a, 60, 'REOPEN', 'إعادة فتح', condition=f"{rst} in ('COMPLETED', 'VERIFIED')")
b_ca = p.button(a, 70, 'CANCEL_REQ', 'إلغاء', condition=f"{rst} in ('NEW', 'TRIAGED', 'ASSIGNED', 'ON_HOLD', 'IN_PROGRESS')")
b_rj = p.button(a, 80, 'REJECT', 'رفض', condition=f"{rst} in ('NEW', 'TRIAGED')")
p.process(6, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    if :P71_ID is not null then',
    '        select team_id, technician_id into :P71_A_TEAM, :P71_A_TECH from mnt_request where id = :P71_ID;',
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
p.process(20, 'AFTER_SUBMIT', 'Assign', 'noona_mnt_pkg.assign(:P71_ID, :P71_A_TEAM, :P71_A_TECH);', when_button=b_as, success='تم الإسناد وإشعار الفريق')
p.process(30, 'AFTER_SUBMIT', 'Start', 'noona_mnt_pkg.start_work(:P71_ID);', when_button=b_st, success='بدأ التنفيذ')
p.process(40, 'AFTER_SUBMIT', 'Hold', 'noona_mnt_pkg.hold(:P71_ID, :P71_NOTES);', when_button=b_ho, success='تم تعليق البلاغ')
p.process(50, 'AFTER_SUBMIT', 'Complete', 'noona_mnt_pkg.complete(:P71_ID, :P71_NOTES, :P71_HOURS, :P71_MATERIAL);', when_button=b_co,
          success='تم إنجاز البلاغ')
p.process(60, 'AFTER_SUBMIT', 'Close', 'noona_mnt_pkg.close_request(:P71_ID, :P71_RATING);', when_button=b_cl, success='تم إغلاق البلاغ')
p.process(70, 'AFTER_SUBMIT', 'Reopen', 'noona_mnt_pkg.reopen(:P71_ID, :P71_NOTES);', when_button=b_re, success='أعيد فتح البلاغ')
p.process(80, 'AFTER_SUBMIT', 'Cancel', "noona_mnt_pkg.cancel_request(:P71_ID, :P71_NOTES, 'N');", when_button=b_ca, success='تم إلغاء البلاغ')
p.process(90, 'AFTER_SUBMIT', 'Reject', "noona_mnt_pkg.cancel_request(:P71_ID, :P71_NOTES, 'Y');", when_button=b_rj, success='تم رفض البلاغ')
p.branch(10, url(71, 'P71_ID', '&P71_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 72) كل البلاغات
p = app.page(72, 'Maintenance Requests', 'MAINT-REQUESTS', 'سجل البلاغات', scheme=MNT)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'بلاغ جديد', hot=True, redirect=url(71, clear='RP,71'))
p.ir('البلاغات', 10, [
    "select r.id, r.doc_no, to_char(r.created_at, 'YYYY-MM-DD HH24:MI') as created, c.name_ar as category, r.title,",
    "       noona_mnt_pkg.location_label(r.id) as location, noona_mnt_pkg.priority_label(r.priority_code) as priority,",
    "       noona_mnt_pkg.channel_label(r.channel_code) as channel, t.name_ar as team, noona_mnt_pkg.technician_name(r.technician_id) as tech,",
    "       noona_mnt_pkg.status_label(r.status_code) as status, noona_mnt_pkg.sla_badge(r.due_at, r.resolved_at, r.status_code) as sla_html,",
    "       round((cast(nvl(r.resolved_at, systimestamp) as date) - cast(r.created_at as date)) * 24, 1) as hours, r.satisfaction_score",
    "  from mnt_request r join mnt_service_category c on c.id = r.category_id left join mnt_team t on t.id = r.team_id",
    " where r.company_id = noona_mnt_pkg.company order by r.created_at desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'البلاغ', {}), ('CREATED', 'الوقت', {}), ('CATEGORY', 'النوع', {}),
     ('TITLE', 'العنوان', {}), ('LOCATION', 'الموقع', {}), ('PRIORITY', 'الأولوية', {}), ('CHANNEL', 'القناة', {}), ('TEAM', 'الفريق', {}),
     ('TECH', 'الفني', {}), ('STATUS', 'الحالة', {}), ('SLA_HTML', 'الموعد', {'html': True}), ('HOURS', 'الساعات', {'type': 'NUMBER'}),
     ('SATISFACTION_SCORE', 'التقييم', {'type': 'NUMBER'})], link=link(71, 'P71_ID'))

# =============================================================== 73) الفرق والفنيون
p = app.page(73, 'Maintenance Teams', 'MAINT-TEAMS', 'فرق الصيانة والفنيون', scheme=MNT)
t = p.static('فريق', 10)
p.select('P73_TEAM_ID', t, 5, 'تعديل فريق', lov_sql=TEAM_LOV, null_text='- فريق جديد -', submit=True)
p.text('P73_CODE', t, 10, 'الرمز', maxlen=30, width=10)
p.text('P73_NAME', t, 20, 'الاسم', maxlen=200)
p.text('P73_SPEC', t, 30, 'التخصص', maxlen=200)
p.text('P73_PHONE', t, 40, 'هاتف الفريق', maxlen=30, width=15)
p.select('P73_SUP', t, 50, 'المشرف (يصله إشعار كل بلاغ)', lov_sql=EMP_LOV)
b_t = p.button(t, 10, 'SAVE_TEAM', 'حفظ الفريق', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    if :P73_TEAM_ID is not null then',
    '        select code, name_ar, specialty, phone, supervisor_employee_id into :P73_CODE, :P73_NAME, :P73_SPEC, :P73_PHONE, :P73_SUP',
    '          from mnt_team where id = :P73_TEAM_ID;',
    '    end if;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save team', ['begin', '    :P73_TEAM_ID := noona_mnt_pkg.save_team(:P73_TEAM_ID, :P73_CODE, :P73_NAME, :P73_SPEC, :P73_PHONE, :P73_SUP);',
          'end;'], when_button=b_t, success='تم حفظ الفريق')
te = p.static('فني', 20)
p.select('P73_T_TEAM', te, 10, 'الفريق', lov_sql=TEAM_LOV)
p.select('P73_T_EMP', te, 20, 'موظف', lov_sql=EMP_LOV)
p.text('P73_T_EXT', te, 30, 'أو اسم فني المقاول', maxlen=200)
p.text('P73_T_SKILLS', te, 40, 'المهارات', maxlen=500)
p.number('P73_T_COST', te, 50, 'تكلفة الساعة')
b_te = p.button(te, 10, 'ADD_TECH', 'إضافة الفني')
p.process(20, 'AFTER_SUBMIT', 'Add tech', ['declare l_id number;', 'begin',
          '    l_id := noona_mnt_pkg.add_technician(:P73_T_TEAM, :P73_T_EMP, :P73_T_EXT, :P73_T_SKILLS, :P73_T_COST);', 'end;'],
          when_button=b_te, success='تمت إضافة الفني')
p.ir('الفرق', 30, [
    "select t.id, t.code, t.name_ar, t.specialty, t.phone, p.display_name_ar as supervisor,",
    "       (select count(*) from mnt_technician x where x.team_id = t.id and x.is_active = 'Y') as techs,",
    "       (select count(*) from mnt_request r where r.team_id = t.id and r.status_code in ('ASSIGNED', 'IN_PROGRESS', 'ON_HOLD')) as open_req",
    "  from mnt_team t left join hr_employee e on e.id = t.supervisor_employee_id left join pty_party p on p.id = e.person_party_id",
    " where t.company_id = noona_mnt_pkg.company order by t.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفريق', {}), ('SPECIALTY', 'التخصص', {}),
     ('PHONE', 'الهاتف', {}), ('SUPERVISOR', 'المشرف', {}), ('TECHS', 'الفنيون', {'type': 'NUMBER'}), ('OPEN_REQ', 'بلاغات جارية', {'type': 'NUMBER'})],
    titled=True, rows=20)
p.ir('الفنيون', 40, [
    "select x.id, t.name_ar as team, noona_mnt_pkg.technician_name(x.id) as name, x.skills, x.hourly_cost,",
    "       (select count(*) from mnt_request r where r.technician_id = x.id and r.status_code in ('ASSIGNED', 'IN_PROGRESS', 'ON_HOLD')) as open_req,",
    "       (select nvl(sum(l.hours), 0) from mnt_wo_labor l where l.technician_id = x.id and l.work_date >= trunc(sysdate, 'MM')) as hours_month",
    "  from mnt_technician x join mnt_team t on t.id = x.team_id where x.company_id = noona_mnt_pkg.company order by t.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('TEAM', 'الفريق', {}), ('NAME', 'الفني', {}), ('SKILLS', 'المهارات', {}),
     ('HOURLY_COST', 'تكلفة الساعة', {'type': 'NUMBER'}), ('OPEN_REQ', 'بلاغات جارية', {'type': 'NUMBER'}),
     ('HOURS_MONTH', 'ساعات الشهر', {'type': 'NUMBER'})], titled=True, rows=50)
p.branch(10, url(73, 'P73_TEAM_ID', '&P73_TEAM_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 74) أنواع الأعطال
p = app.page(74, 'Maintenance Categories', 'MAINT-CATEGORIES', 'أنواع الأعطال', scheme=MNT)
f = p.static('نوع عطل', 10)
p.select('P74_ID', f, 5, 'تعديل نوع', lov_sql=CAT_LOV, null_text='- نوع جديد -', submit=True)
p.text('P74_CODE', f, 10, 'الرمز', maxlen=30, width=12)
p.text('P74_NAME', f, 20, 'الاسم', maxlen=200)
p.select('P74_PRIORITY', f, 30, 'الأولوية الافتراضية', lov_sql=PRIORITY_LOV, null_text=None)
p.number('P74_SLA', f, 40, 'زمن الإنجاز المستهدف (ساعة)')
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '    if :P74_ID is not null then',
          '        select code, name_ar, default_priority, sla_hours into :P74_CODE, :P74_NAME, :P74_PRIORITY, :P74_SLA',
          '          from mnt_service_category where id = :P74_ID;', '    end if;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['begin', '    :P74_ID := noona_mnt_pkg.save_category(:P74_ID, :P74_CODE, :P74_NAME, :P74_PRIORITY, :P74_SLA);',
          'end;'], when_button=b, success='تم الحفظ')
p.ir('أنواع الأعطال', 20, [
    "select c.id, c.code, c.name_ar, noona_mnt_pkg.priority_label(c.default_priority) as priority, c.sla_hours,",
    "       (select count(*) from mnt_request r where r.category_id = c.id and r.company_id = noona_mnt_pkg.company) as requests",
    "  from mnt_service_category c where c.is_active = 'Y' order by c.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('PRIORITY', 'الأولوية', {}),
     ('SLA_HOURS', 'زمن الإنجاز (ساعة)', {'type': 'NUMBER'}), ('REQUESTS', 'البلاغات', {'type': 'NUMBER'})], titled=True, rows=50)
p.branch(10, url(74, 'P74_ID', '&P74_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 75) أداء الصيانة
p = app.page(75, 'Maintenance Reports', 'MAINT-REPORTS', 'أداء الصيانة', scheme=MNT, protection='N')
f = p.static('الفترة', 5, opts='#DEFAULT#:nn-rpt-filters')
p.date('P75_FROM', f, 10, 'من')
p.date('P75_TO', f, 20, 'إلى')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P75_FROM := nvl(:P75_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
                                            ":P75_TO := nvl(:P75_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('المؤشرات', 8, 'return noona_mnt_pkg.summary_html;', hide_header=True)
p.dynamic('الأداء حسب نوع العطل', 10, "return noona_mnt_pkg.performance_html(to_date(:P75_FROM, 'YYYY-MM-DD'), to_date(:P75_TO, 'YYYY-MM-DD'));",
          opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.branch(10, url(75, 'P75_FROM,P75_TO', '&P75_FROM.,&P75_TO.', '75'))

# =============================================================== القائمة
app.nav_item('اللوحة', 1, 'fa-home', 10)
re = app.nav_item('السجل العقاري', None, 'fa-building', 20, scheme=RE)
app.nav_item('العقارات', 10, 'fa-list', 1, parent=re, scheme=RE)
app.nav_item('إضافة عقار', url(11, clear='RP,11'), 'fa-plus', 2, parent=re, scheme=RE)
hs = app.nav_item('الضيافة', None, 'fa-bed', 30, scheme=HSP)
app.nav_item('لوحة الاستقبال', 20, 'fa-th', 1, parent=hs, scheme=HSP)
app.nav_item('الحجوزات', 21, 'fa-calendar', 2, parent=hs, scheme=HSP)
app.nav_item('حجز جديد', url(22, clear='RP,22'), 'fa-calendar-plus-o', 3, parent=hs, scheme=HSP)
app.nav_item('التدبير الفندقي', 25, 'fa-paint-brush', 4, parent=hs, scheme=HSP)
app.nav_item('التدقيق الليلي', 26, 'fa-moon-o', 5, parent=hs, scheme=HSP)
app.nav_item('تقارير الضيافة', 28, 'fa-bar-chart', 6, parent=hs, scheme=HSP)
app.nav_item('إعداد الضيافة', 27, 'fa-cog', 7, parent=hs, scheme=HSP)
mn = app.nav_item('الصيانة', None, 'fa-wrench', 40, scheme=MNT)
app.nav_item('لوحة البلاغات', 70, 'fa-columns', 1, parent=mn, scheme=MNT)
app.nav_item('بلاغ جديد', url(71, clear='RP,71'), 'fa-plus', 2, parent=mn, scheme=MNT)
app.nav_item('سجل البلاغات', 72, 'fa-list', 3, parent=mn, scheme=MNT)
app.nav_item('الفرق والفنيون', 73, 'fa-users', 4, parent=mn, scheme=MNT)
app.nav_item('أنواع الأعطال', 74, 'fa-tags', 5, parent=mn, scheme=MNT)
app.nav_item('أداء الصيانة', 75, 'fa-line-chart', 6, parent=mn, scheme=MNT)
PRJ = app.add_scheme('noona_prj_view', app.id(), 'NOONA - Projects',
                     "return noona_security_pkg.has_permission('PRJ_PROJECT.VIEW', noona_prj_pkg.company) = 'Y' and noona_platform_pkg.module_enabled('PRJ') = 'Y';",
                     'صفحات المشروعات تتطلب صلاحية عرض المشروعات / Projects access required')
import prj_pages
prj_pages.build(app, url, link, PRJ)
import res_pages
res_pages.build(app, url, link, get_url)
# التحليلات والتنبؤ (NOONA_ANL_PKG + anl.js)
import anl_pages
anl_pages.add(app, ['HSP', 'RE'], TENANT, 11)

app.finalize()
print('NOONA_PRJ built:', len(app.pages), 'pages')
