"""NOONA_MFG (التصنيع): لوحة الإنتاج، مراكز العمل، قوائم المواد ومسارات التصنيع بإصداراتها، أوامر الإنتاج (منضدة واحدة: الخامات
والعمليات والإنتاج والجودة والتكلفة والقيود)، فحوصات الجودة، تخطيط الاحتياجات MRP، أحمال مراكز العمل، ومركز تقارير بمرشحات موحدة.
الاستخدام: python3 tools/build_mfg.py  ->  apex/NOONA_MFG/f135
"""
import json, os, shutil, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand
from trade_doc import FIND_ITEMS

ROOT = os.path.join(os.path.dirname(__file__), '..')
# الشاشات التفاعلية ملف ثابت للتطبيق (أكبر من حد كود الصفحة في APEX) يحمل عند الحاجة
shutil.copyfile(os.path.join(os.path.dirname(__file__), 'mfg.js'), os.path.join(apex_brand.STATIC_DIR, 'mfg.js'))
if ('mfg.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('mfg.js', 'application/javascript'))
MFG_JS = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'mfg.js'; document.head.appendChild(s); })();"]
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_MFG/f135'),
          app_id=135, alias='NOONA_MFG', name='NOONA Manufacturing', id_base=91820270000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


def mfg_region(data_sql, lists, container):
    """منطقة شاشة تفاعلية: JSON البيانات والقوائم وحاوية تبنيها mfg.js"""
    return [
        'declare',
        "    function js(p clob) return clob is begin return replace(p, '</', '<\\/'); end;",
        'begin',
        f"    return '<script type=\"application/json\" id=\"nnMfgData\">' || js({data_sql}) || '</script>'",
        f"        || '<script type=\"application/json\" id=\"nnMfgLists\">' || js(noona_mfg_pkg.lists_json('{lists}')) || '</script>'",
        f"        || '<div id=\"{container}\" class=\"nn-doc nn-td nn-mfg\" data-co=\"'",
        "        || apex_escape.html_attribute(noona_apex_pkg.company_name) || '\"></div>';",
        'end;']


def ack_ajax(body, page_no=None, item=None):
    """عملية AJAX تنفذ body (يضبط l_id) وتعيد {ok,id,url} أو {ok:false,msg}"""
    out = ['declare', '    l_id number;', '    l_c clob;', 'begin'] + ['    ' + x for x in body] + [
        '    apex_json.open_object;',
        "    apex_json.write('ok', true);",
        "    apex_json.write('id', l_id);"]
    if page_no:
        out.append(f"    if l_id is not null then apex_json.write('url', apex_page.get_url(p_page => {page_no}, p_clear_cache => '{page_no}', "
                   f"p_items => '{item}', p_values => l_id)); end if;")
    out += [
        '    apex_json.close_object;',
        'exception when others then',
        '    rollback;',
        '    apex_json.open_object;',
        "    apex_json.write('ok', false);",
        "    apex_json.write('msg', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^[' || chr(10) || ']+')), sqlerrm));",
        '    apex_json.close_object;',
        'end;']
    return out


READY = "noona_mfg_pkg.is_ready = 'Y'"
ITEM_LOV = ("select item_no || ' - ' || name_ar d, id r from inv_item where status_code = 'ACTIVE' "
            "and item_type not in ('SERVICE', 'NON_STOCK') order by item_no")
PRODUCT_LOV = ("select i.item_no || ' - ' || i.name_ar d, i.id r from inv_item i where i.status_code = 'ACTIVE' and exists "
               "(select 1 from mfg_bom b where b.item_id = i.id and b.company_id = noona_mfg_pkg.company and b.status_code = 'PUBLISHED') order by i.item_no")
CC_LOV = "select code || ' - ' || name_ar d, id r from gl_cost_center where company_id = noona_gl_pkg.company order by code"
STATUS_LOV = ('STATIC2:مخطط;PLANNED,معتمد;APPROVED,مطلق للتنفيذ;RELEASED,قيد التنفيذ;IN_PROGRESS,منجز جزئياً;PARTIALLY_COMPLETED,'
              'مكتمل;COMPLETED,مقفل;CLOSED,موقوف;ON_HOLD,ملغى;CANCELLED')
ORDER_SQL = [
    "select o.id, o.doc_no, to_char(o.doc_date, 'YYYY-MM-DD') as doc_date, noona_inv_pkg.item_label(o.item_id) as product,",
    '       o.planned_qty, o.completed_qty, o.scrapped_qty, noona_mfg_pkg.order_progress(o.id) as progress,',
    "       to_char(o.planned_start, 'YYYY-MM-DD') as p_start, to_char(o.planned_end, 'YYYY-MM-DD') as p_end,",
    '       noona_mfg_pkg.priority_label(o.priority) as priority, o.estimated_cost, o.actual_cost,',
    '       noona_mfg_pkg.wip_balance(o.id) as wip,',
    "       '<span class=\"nn-badge ' || case when o.status_code in ('COMPLETED', 'CLOSED') then 'is-success' when o.status_code = 'CANCELLED' then 'is-danger'",
    "            when o.status_code = 'ON_HOLD' or (o.planned_end < trunc(sysdate) and o.status_code not in ('COMPLETED', 'CLOSED')) then 'is-warning'",
    "            when o.status_code in ('RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED') then 'is-info' end || '\">'",
    "            || noona_mfg_pkg.status_label(o.status_code) || '</span>' as status_html",
    '  from mfg_production_order o where o.company_id = noona_mfg_pkg.company']
ORDER_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'رقم الأمر', {}), ('DOC_DATE', 'التاريخ', {}), ('PRODUCT', 'المنتج', {}),
              ('PLANNED_QTY', 'المخطط', {'type': 'NUMBER'}), ('COMPLETED_QTY', 'المقبول', {'type': 'NUMBER'}), ('SCRAPPED_QTY', 'الهالك', {'type': 'NUMBER'}),
              ('PROGRESS', 'الإنجاز %', {'type': 'NUMBER'}), ('P_START', 'البداية', {}), ('P_END', 'النهاية', {}), ('PRIORITY', 'الأولوية', {}),
              ('ESTIMATED_COST', 'التقديرية', {'type': 'NUMBER'}), ('ACTUAL_COST', 'الفعلية', {'type': 'NUMBER'}), ('WIP', 'تحت التشغيل', {'type': 'NUMBER'}),
              ('STATUS_HTML', 'الحالة', {'html': True})]

# =============================================================== 1) لوحة التصنيع
p = app.page(1, 'Home', 'HOME', 'التصنيع', scheme=TENANT)
st = p.static('تجهيز التصنيع', 5, condition="noona_mfg_pkg.is_ready = 'N'")
b = p.button(st, 10, 'SETUP', 'تجهيز التصنيع (حسابات الإنتاج تحت التشغيل والتحميل والانحرافات، الترقيم، مركز عمل افتراضي)', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_mfg_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم تجهيز التصنيع: الحسابات 1110 الإنتاج تحت التشغيل، 5103 العمالة المحملة، 5104 الأعباء المحملة، 5105 الانحرافات، وترقيم أوامر الإنتاج')
p.dynamic('مؤشرات الإنتاج', 10, 'return noona_mfg_pkg.mfg_summary;', hide_header=True, condition=READY)
qa = p.static('إجراءات سريعة', 15, condition=READY)
p.button(qa, 10, 'NEW_MO', 'أمر إنتاج جديد', hot=True, redirect=url(31, clear='RP,31'))
p.button(qa, 20, 'NEW_BOM', 'قائمة مواد', redirect=url(21, clear='RP,21'))
p.button(qa, 30, 'NEW_RT', 'مسار تصنيع', redirect=url(23, clear='RP,23'))
p.button(qa, 40, 'MRP', 'تخطيط الاحتياجات', redirect=url(40))
p.button(qa, 50, 'CAP', 'أحمال مراكز العمل', redirect=url(41))
p.button(qa, 60, 'REPORTS', 'التقارير', redirect=url(50))
p.ir('الأوامر المفتوحة', 20, ORDER_SQL + [
    "   and o.status_code in ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED', 'ON_HOLD', 'COMPLETED')",
    " order by decode(o.priority, 'URGENT', 0, 'HIGH', 1, 'NORMAL', 2, 3), o.planned_end nulls last, o.id"],
    ORDER_COLS, link=link(31, 'P31_ID'), titled=True, rows=15)
p.ir('بانتظار فحص الجودة', 30, [
    "select t.order_id as id, o.doc_no, noona_inv_pkg.item_label(o.item_id) as product, t.quantity, t.lot_no,",
    "       to_char(t.output_date, 'YYYY-MM-DD') as output_date",
    "  from mfg_order_output t join mfg_production_order o on o.id = t.order_id",
    " where t.company_id = noona_mfg_pkg.company and t.status_code = 'PENDING_QUALITY' order by t.id"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'أمر الإنتاج', {}), ('PRODUCT', 'المنتج', {}), ('QUANTITY', 'الكمية', {'type': 'NUMBER'}),
     ('LOT_NO', 'الدفعة', {}), ('OUTPUT_DATE', 'التاريخ', {})], link=link(31, 'P31_ID'), titled=True, rows=10)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10/11) مراكز العمل
p = app.page(10, 'Work Centers', 'WORK-CENTERS', 'مراكز العمل', scheme=TENANT)
r = p.ir('مراكز العمل', 10, [
    "select w.id, w.code, w.name_ar, w.capacity_hours_day, w.labor_rate, w.machine_rate, w.overhead_rate,",
    '       w.labor_rate + w.machine_rate + w.overhead_rate as total_rate,',
    "       (select code || ' - ' || name_ar from gl_cost_center where id = w.cost_center_id) as cost_center,",
    "       (select count(*) from mfg_order_operation p where p.work_center_id = w.id and p.status_code in ('PENDING', 'IN_PROGRESS')) as open_ops,",
    "       case w.is_active when 'Y' then 'نشط' else 'موقوف' end as active",
    '  from mfg_work_center w where w.company_id = noona_mfg_pkg.company order by w.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'مركز العمل', {}),
     ('CAPACITY_HOURS_DAY', 'الطاقة اليومية (ساعة)', {'type': 'NUMBER'}), ('LABOR_RATE', 'العمالة/ساعة', {'type': 'NUMBER'}),
     ('MACHINE_RATE', 'الآلات/ساعة', {'type': 'NUMBER'}), ('OVERHEAD_RATE', 'التحميل/ساعة', {'type': 'NUMBER'}),
     ('TOTAL_RATE', 'إجمالي المعدل', {'type': 'NUMBER'}), ('COST_CENTER', 'مركز التكلفة', {}), ('OPEN_OPS', 'عمليات مفتوحة', {'type': 'NUMBER'}),
     ('ACTIVE', 'الحالة', {})], link=link(11, 'P11_ID'))
p.button(r, 10, 'NEW', 'مركز عمل جديد', hot=True, redirect=url(11, clear='RP,11'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(11, 'Work Center', 'WORK-CENTER', 'مركز عمل', scheme=TENANT)
f = p.static('مركز العمل', 10)
p.hidden('P11_ID', f, 1)
p.text('P11_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=15)
p.text('P11_NAME', f, 20, 'الاسم', required=True)
p.number('P11_CAP', f, 30, 'الطاقة اليومية بالساعات', required=True)
p.number('P11_LABOR', f, 40, 'معدل العمالة للساعة')
p.number('P11_MACHINE', f, 50, 'معدل الآلات للساعة (إهلاك وتشغيل)')
p.number('P11_OVERHEAD', f, 60, 'معدل التحميل الصناعي للساعة')
p.select('P11_CC', f, 70, 'مركز التكلفة', lov_sql=CC_LOV)
p.yesno('P11_ACTIVE', f, 80, 'نشط')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'declare l_j clob;', 'begin',
    '    if :P11_ID is not null then',
    '        l_j := noona_mfg_pkg.work_center_json(:P11_ID);',
    "        :P11_CODE := json_value(l_j, '$.code'); :P11_NAME := json_value(l_j, '$.name'); :P11_CAP := json_value(l_j, '$.cap');",
    "        :P11_LABOR := json_value(l_j, '$.labor'); :P11_MACHINE := json_value(l_j, '$.machine'); :P11_OVERHEAD := json_value(l_j, '$.overhead');",
    "        :P11_CC := json_value(l_j, '$.cc'); :P11_ACTIVE := json_value(l_j, '$.active');",
    '    else',
    "        :P11_CAP := nvl(:P11_CAP, 8); :P11_ACTIVE := nvl(:P11_ACTIVE, 'Y');",
    '    end if;', 'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'begin',
    "    :P11_ID := noona_mfg_pkg.save_work_center(json_object('id' value to_number(:P11_ID), 'code' value :P11_CODE, 'name' value :P11_NAME,",
    "        'cap' value to_number(:P11_CAP), 'labor' value to_number(:P11_LABOR), 'machine' value to_number(:P11_MACHINE),",
    "        'overhead' value to_number(:P11_OVERHEAD), 'cc' value to_number(:P11_CC), 'active' value nvl(:P11_ACTIVE, 'Y')));",
    'end;'], when_button=b, success='تم حفظ مركز العمل')
p.button(f, 20, 'BACK', 'رجوع', redirect=url(10))
p.branch(10, url(10) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20/21) قوائم المواد
p = app.page(20, 'Bills of Materials', 'BOMS', 'قوائم المواد', scheme=TENANT)
r = p.ir('قوائم المواد', 10, [
    "select b.id, noona_inv_pkg.item_label(b.item_id) as product, b.version_no, b.name_ar,",
    "       decode(b.bom_type, 'PRODUCTION', 'إنتاج', 'PHANTOM', 'وهمية', 'KIT', 'طقم', 'ENGINEERING', 'هندسية', b.bom_type) as bom_type,",
    "       b.base_quantity, (select count(*) from mfg_bom_line l where l.bom_id = b.id and l.is_co_product = 'N') as components,",
    "       case when b.status_code = 'PUBLISHED' then noona_mfg_pkg.std_unit_cost(b.item_id) end as std_cost,",
    "       case b.is_default when 'Y' then '★' end as is_default, noona_mfg_pkg.bom_in_use(b.id) as in_use,",
    "       '<span class=\"nn-badge ' || case b.status_code when 'PUBLISHED' then 'is-success' when 'OBSOLETE' then 'is-danger' end || '\">'",
    "            || noona_mfg_pkg.status_label(b.status_code) || '</span>' as status_html",
    '  from mfg_bom b where b.company_id = noona_mfg_pkg.company order by b.code, b.version_no desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PRODUCT', 'المنتج', {}), ('VERSION_NO', 'الإصدار', {'type': 'NUMBER'}),
     ('NAME_AR', 'الاسم', {}), ('BOM_TYPE', 'النوع', {}), ('BASE_QUANTITY', 'الكمية المرجعية', {'type': 'NUMBER'}),
     ('COMPONENTS', 'المكونات', {'type': 'NUMBER'}), ('STD_COST', 'التكلفة المعيارية للوحدة', {'type': 'NUMBER'}),
     ('IS_DEFAULT', 'الافتراضية', {}), ('IN_USE', 'مستخدمة', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(21, 'P21_ID'))
p.button(r, 10, 'NEW', 'قائمة مواد جديدة', hot=True, redirect=url(21, clear='RP,21'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(21, 'Bill of Materials', 'BOM', 'قائمة المواد', scheme=TENANT, protection='N')
hd = p.static('القائمة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P21_ID', hd, 1)
p.hidden('P21_ITEM', hd, 2)
p.process(5, 'BEFORE_HEADER', 'Load', ['if :P21_ID is not null then',
                                         '    select item_id into :P21_ITEM from mfg_bom where id = :P21_ID and company_id = noona_mfg_pkg.company;',
                                         'end if;'])
p.dynamic('محرر قائمة المواد', 10, mfg_region('noona_mfg_pkg.bom_doc_json(:P21_ID)', 'items', 'nnBom'),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.dynamic('شجرة المواد والتكلفة المجمعة', 20, 'return noona_mfg_pkg.bom_tree(:P21_ITEM, 1);', condition=':P21_ITEM is not null')
p.process(1, 'ON_DEMAND', 'SAVE_BOM', ack_ajax(['l_id := noona_mfg_pkg.save_bom(apex_application.g_clob_01);'], 21, 'P21_ID'))
p.process(2, 'ON_DEMAND', 'ACT', ack_ajax([
    'case apex_application.g_x01',
    "    when 'PUBLISH' then noona_mfg_pkg.publish_bom(apex_application.g_x02);",
    "    when 'OBSOLETE' then noona_mfg_pkg.obsolete_bom(apex_application.g_x02);",
    "    when 'NEWVER' then l_id := noona_mfg_pkg.new_bom_version(apex_application.g_x02);",
    'end case;'], 21, 'P21_ID'))
p.process(3, 'ON_DEMAND', 'FIND_ITEMS', FIND_ITEMS)
p.onload(MFG_JS)

# =============================================================== 22/23) مسارات التصنيع
p = app.page(22, 'Routings', 'ROUTINGS', 'مسارات التصنيع', scheme=TENANT)
r = p.ir('مسارات التصنيع', 10, [
    "select r.id, noona_inv_pkg.item_label(r.item_id) as product, r.version_no, r.name_ar,",
    '       (select count(*) from mfg_routing_operation o where o.routing_id = r.id) as ops,',
    '       (select sum(o.run_minutes_per_unit) from mfg_routing_operation o where o.routing_id = r.id) as run_minutes,',
    '       (select sum(o.setup_minutes) from mfg_routing_operation o where o.routing_id = r.id) as setup_minutes,',
    "       noona_mfg_pkg.routing_in_use(r.id) as in_use,",
    "       '<span class=\"nn-badge ' || case r.status_code when 'PUBLISHED' then 'is-success' when 'OBSOLETE' then 'is-danger' end || '\">'",
    "            || noona_mfg_pkg.status_label(r.status_code) || '</span>' as status_html",
    '  from mfg_routing r where r.company_id = noona_mfg_pkg.company order by r.code, r.version_no desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PRODUCT', 'المنتج', {}), ('VERSION_NO', 'الإصدار', {'type': 'NUMBER'}),
     ('NAME_AR', 'الاسم', {}), ('OPS', 'العمليات', {'type': 'NUMBER'}), ('RUN_MINUTES', 'دقائق التشغيل للوحدة', {'type': 'NUMBER'}),
     ('SETUP_MINUTES', 'دقائق الإعداد', {'type': 'NUMBER'}), ('IN_USE', 'مستخدم', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(23, 'P23_ID'))
p.button(r, 10, 'NEW', 'مسار جديد', hot=True, redirect=url(23, clear='RP,23'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(23, 'Routing', 'ROUTING', 'مسار التصنيع', scheme=TENANT, protection='N')
hd = p.static('المسار', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P23_ID', hd, 1)
p.dynamic('محرر مسار التصنيع', 10, mfg_region('noona_mfg_pkg.routing_doc_json(:P23_ID)', 'items,wcs', 'nnRt'),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'SAVE_RT', ack_ajax(['l_id := noona_mfg_pkg.save_routing(apex_application.g_clob_01);'], 23, 'P23_ID'))
p.process(2, 'ON_DEMAND', 'ACT', ack_ajax([
    'case apex_application.g_x01',
    "    when 'PUBLISH' then noona_mfg_pkg.publish_routing(apex_application.g_x02);",
    "    when 'OBSOLETE' then noona_mfg_pkg.obsolete_routing(apex_application.g_x02);",
    "    when 'NEWVER' then l_id := noona_mfg_pkg.new_routing_version(apex_application.g_x02);",
    'end case;'], 23, 'P23_ID'))
p.onload(MFG_JS)

# =============================================================== 30/31) أوامر الإنتاج
p = app.page(30, 'Production Orders', 'ORDERS', 'أوامر الإنتاج', scheme=TENANT)
r = p.ir('أوامر الإنتاج', 10, ORDER_SQL + [' order by o.id desc'], ORDER_COLS, link=link(31, 'P31_ID'), rows=50)
p.button(r, 10, 'NEW', 'أمر إنتاج جديد', hot=True, redirect=url(31, clear='RP,31'), position='RIGHT_OF_IR_SEARCH_BAR')

p = app.page(31, 'Production Order', 'ORDER', 'أمر إنتاج', scheme=TENANT, protection='N')
hd = p.static('الأمر', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P31_ID', hd, 1)
p.dynamic('منضدة أمر الإنتاج', 10, mfg_region('noona_mfg_pkg.order_json(:P31_ID)', 'products,whs,ccs', 'nnMo'),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
tb = p.static('طباعة', 15, condition=':P31_ID is not null', opts='#DEFAULT#:t-Region--noUI')
p.button(tb, 10, 'PRINT', 'بطاقة التشغيل', redirect=url(32, 'P32_ID,P32_KIND', '&P31_ID.,JOB', 'RP,32'))
p.button(tb, 20, 'COST', 'بطاقة التكلفة', redirect=url(32, 'P32_ID,P32_KIND', '&P31_ID.,COST', 'RP,32'))
p.process(1, 'ON_DEMAND', 'SAVE_MO', ack_ajax(['l_id := noona_mfg_pkg.save_order(apex_application.g_clob_01);'], 31, 'P31_ID'))
p.process(2, 'ON_DEMAND', 'ACT', ack_ajax([
    'case apex_application.g_x01',
    "    when 'APPROVE' then noona_mfg_pkg.approve_order(apex_application.g_x02);",
    "    when 'RELEASE' then noona_mfg_pkg.release_order(apex_application.g_x02);",
    "    when 'HOLD' then noona_mfg_pkg.hold_order(apex_application.g_x02, apex_application.g_x03);",
    "    when 'RESUME' then noona_mfg_pkg.resume_order(apex_application.g_x02);",
    "    when 'CANCEL' then noona_mfg_pkg.cancel_order(apex_application.g_x02, apex_application.g_x03);",
    "    when 'COMPLETE' then noona_mfg_pkg.complete_order(apex_application.g_x02);",
    "    when 'CLOSE' then l_id := noona_mfg_pkg.close_order(apex_application.g_x02, trunc(sysdate));",
    'end case;',
    'l_id := null;']))
p.process(3, 'ON_DEMAND', 'POST', ack_ajax([
    'case apex_application.g_x01',
    "    when 'ISSUE' then l_id := noona_mfg_pkg.issue_materials(apex_application.g_clob_01);",
    "    when 'RETURN' then l_id := noona_mfg_pkg.return_materials(apex_application.g_clob_01);",
    "    when 'OP' then l_id := noona_mfg_pkg.report_operation(apex_application.g_clob_01);",
    "    when 'OUTPUT' then l_id := noona_mfg_pkg.report_output(apex_application.g_clob_01);",
    "    when 'INSPECT' then l_id := noona_mfg_pkg.inspect_output(apex_application.g_clob_01);",
    'end case;']))
p.process(4, 'ON_DEMAND', 'SUBST', ack_ajax(['noona_mfg_pkg.substitute_material(apex_application.g_x01, apex_application.g_x02);']))
p.onload(MFG_JS)

p = app.page(32, 'Order Print', 'ORDER-PRINT', 'طباعة أمر الإنتاج', scheme=TENANT)
f = p.static('الطباعة', 5, opts='#DEFAULT#:nn-rpt-filters')
p.hidden('P32_ID', f, 1)
p.hidden('P32_KIND', f, 2)
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
p.button(f, 20, 'BACK', 'رجوع للأمر', redirect=url(31, 'P31_ID', '&P32_ID.', '31'))
p.dynamic('المستند', 10, ["return case :P32_KIND when 'COST' then noona_mfg_pkg.order_cost_sheet(:P32_ID) else noona_mfg_pkg.order_print(:P32_ID) end;"],
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== 35) فحوصات الجودة
p = app.page(35, 'Quality', 'QUALITY', 'فحوصات الجودة', scheme=TENANT)
p.ir('فحوصات الجودة', 10, [
    "select q.order_id as id, o.doc_no, noona_inv_pkg.item_label(o.item_id) as product, t.lot_no, q.inspected_qty, q.passed_qty, q.failed_qty,",
    "       case when q.status_code <> 'PENDING' and q.inspected_qty > 0 then round(q.passed_qty / q.inspected_qty * 100, 1) end as pass_rate,",
    "       to_char(q.inspection_date, 'YYYY-MM-DD') as inspection_date, q.notes,",
    "       '<span class=\"nn-badge ' || case q.status_code when 'PASSED' then 'is-success' when 'FAILED' then 'is-danger' else 'is-warning' end || '\">'",
    "            || noona_mfg_pkg.status_label(q.status_code) || '</span>' as status_html",
    '  from mfg_quality_inspection q join mfg_production_order o on o.id = q.order_id left join mfg_order_output t on t.id = q.output_id',
    " where q.company_id = noona_mfg_pkg.company order by decode(q.status_code, 'PENDING', 0, 1), q.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'أمر الإنتاج', {}), ('PRODUCT', 'المنتج', {}), ('LOT_NO', 'الدفعة', {}),
     ('INSPECTED_QTY', 'المفحوص', {'type': 'NUMBER'}), ('PASSED_QTY', 'المقبول', {'type': 'NUMBER'}), ('FAILED_QTY', 'المرفوض', {'type': 'NUMBER'}),
     ('PASS_RATE', 'نسبة القبول %', {'type': 'NUMBER'}), ('INSPECTION_DATE', 'التاريخ', {}), ('NOTES', 'ملاحظات', {}),
     ('STATUS_HTML', 'النتيجة', {'html': True})], link=link(31, 'P31_ID'))

# =============================================================== 40) تخطيط الاحتياجات
p = app.page(40, 'MRP', 'MRP', 'تخطيط احتياجات المواد', scheme=TENANT, protection='N')
f = p.static('الخيارات', 5, opts='#DEFAULT#:nn-rpt-filters')
p.yesno('P40_REORDER', f, 10, 'الوصول لحدود الطلب (الحد الأدنى والأعلى)')
p.button(f, 10, 'RUN', 'إعادة الحساب', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P40_REORDER := nvl(:P40_REORDER, 'Y');"])
p.dynamic('المقترحات', 10, mfg_region("noona_mfg_pkg.mrp_json(nvl(:P40_REORDER, 'Y'))", 'whs', 'nnMrp'),
          hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.process(1, 'ON_DEMAND', 'EXEC', [
    'declare l_c clob;', 'begin',
    '    l_c := noona_mfg_pkg.mrp_execute(apex_application.g_clob_01);',
    '    apex_json.open_object;',
    "    apex_json.write('ok', true);",
    "    apex_json.write('orders', json_value(l_c, '$.orders' returning number));",
    "    apex_json.write('req', json_value(l_c, '$.reqNo'));",
    "    apex_json.write('url', apex_page.get_url(p_page => 30));",
    '    apex_json.close_object;',
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('ok', false);",
    "    apex_json.write('msg', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^[' || chr(10) || ']+')), sqlerrm));",
    '    apex_json.close_object;',
    'end;'])
p.onload(MFG_JS)
p.branch(10, url(40, 'P40_REORDER', '&P40_REORDER.', '40'))

# =============================================================== 41) أحمال مراكز العمل
p = app.page(41, 'Capacity', 'CAPACITY', 'أحمال مراكز العمل', scheme=TENANT, protection='N')
f = p.static('الفترة', 5, opts='#DEFAULT#:nn-rpt-filters')
p.date('P41_FROM', f, 10, 'من تاريخ')
p.number('P41_DAYS', f, 20, 'عدد الأيام')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P41_FROM := nvl(:P41_FROM, to_char(sysdate, 'YYYY-MM-DD'));", ':P41_DAYS := nvl(:P41_DAYS, 14);'])
p.dynamic('الأحمال', 10, ["return noona_mfg_pkg.capacity_load(to_date(:P41_FROM, 'YYYY-MM-DD'), :P41_DAYS);"],
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.branch(10, url(41, 'P41_FROM,P41_DAYS', '&P41_FROM.,&P41_DAYS.', '41'))

# =============================================================== 50) مركز التقارير
REPORTS = [
    ('ORDERS', 'سجل أوامر الإنتاج', ['FROM', 'TO', 'STATUS']),
    ('WIP', 'الإنتاج تحت التشغيل ومطابقته مع الأستاذ', []),
    ('VAR', 'انحرافات تكاليف الإنتاج', ['FROM', 'TO']),
    ('USAGE', 'استهلاك الخامات', ['FROM', 'TO']),
    ('SUMMARY', 'ملخص الإنتاج حسب المنتج', ['FROM', 'TO']),
    ('UTIL', 'استغلال مراكز العمل وكفاءتها', ['FROM', 'TO']),
    ('LOAD', 'أحمال مراكز العمل', ['FROM', 'DAYS']),
    ('TREE', 'شجرة قائمة المواد والتكلفة المجمعة', ['ITEM', 'QTY']),
    ('USED', 'أين يستخدم الصنف', ['ITEM']),
    ('MRP', 'تخطيط احتياجات المواد', []),
    ('QC', 'فحوصات الجودة', ['FROM', 'TO']),
]
p = app.page(50, 'Reports', 'REPORTS', 'تقارير التصنيع', scheme=TENANT, protection='N')
f = p.static('التقرير والمرشحات', 10, opts='#DEFAULT#:nn-rpt-filters')
p.select('P50_REPORT', f, 5, 'التقرير', null_text=None, lov_sql='STATIC2:' + ','.join(f'{n};{c}' for c, n, _ in REPORTS))
p.date('P50_FROM', f, 10, 'من تاريخ')
p.date('P50_TO', f, 20, 'إلى تاريخ')
p.select('P50_STATUS', f, 30, 'الحالة', lov_sql=STATUS_LOV, null_text='كل الحالات')
p.select('P50_ITEM', f, 40, 'الصنف', lov_sql=ITEM_LOV, null_text='- اختر -')
p.number('P50_QTY', f, 50, 'الكمية')
p.number('P50_DAYS', f, 60, 'عدد الأيام')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(10, 'BEFORE_HEADER', 'Defaults', [
    ":P50_REPORT := nvl(:P50_REPORT, 'ORDERS');",
    ":P50_FROM := nvl(:P50_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
    ":P50_TO := nvl(:P50_TO, to_char(sysdate, 'YYYY-MM-DD'));",
    ':P50_QTY := nvl(:P50_QTY, 1);',
    ':P50_DAYS := nvl(:P50_DAYS, 14);'])
p.dynamic('التقرير', 20, [
    'declare',
    "    l_from date := to_date(:P50_FROM, 'YYYY-MM-DD');",
    "    l_to date := to_date(:P50_TO, 'YYYY-MM-DD');",
    "    l_mo varchar2(300) := 'f?p=' || :APP_ID || ':31:' || :APP_SESSION || '::NO:RP:P31_ID:#ID#';",
    "    l_none varchar2(200) := '<div class=\"nn-empty\">اختر الصنف</div>';",
    'begin',
    '    return case :P50_REPORT',
    "        when 'ORDERS' then noona_mfg_pkg.orders_register(l_from, l_to, :P50_STATUS, l_mo)",
    "        when 'WIP' then noona_mfg_pkg.wip_report(l_mo)",
    "        when 'VAR' then noona_mfg_pkg.variance_report(l_from, l_to, l_mo)",
    "        when 'USAGE' then noona_mfg_pkg.material_usage(l_from, l_to)",
    "        when 'SUMMARY' then noona_mfg_pkg.production_summary(l_from, l_to)",
    "        when 'UTIL' then noona_mfg_pkg.wc_utilization(l_from, l_to)",
    "        when 'LOAD' then noona_mfg_pkg.capacity_load(l_from, :P50_DAYS)",
    "        when 'TREE' then case when :P50_ITEM is null then l_none else noona_mfg_pkg.bom_tree(:P50_ITEM, :P50_QTY) end",
    "        when 'USED' then case when :P50_ITEM is null then l_none else noona_mfg_pkg.where_used(:P50_ITEM) end",
    "        when 'MRP' then noona_mfg_pkg.mrp_report",
    "        when 'QC' then noona_mfg_pkg.quality_report(l_from, l_to)",
    '    end;',
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
FILTERS = ['FROM', 'TO', 'STATUS', 'ITEM', 'QTY', 'DAYS']
p.onload([
    '(function () {',
    '    // المرشحات الموحدة: يظهر لكل تقرير ما يخصه فقط',
    '    var map = ' + json.dumps({c: fl for c, _, fl in REPORTS}) + ';',
    '    var all = ' + json.dumps(FILTERS) + ';',
    "    var sel = document.getElementById('P50_REPORT');",
    '    function sync() { var on = map[sel.value] || [];',
    "        all.forEach(function (k) { var c = document.getElementById('P50_' + k + '_CONTAINER'); if (c) c.style.display = on.indexOf(k) >= 0 ? '' : 'none'; }); }",
    "    sel.addEventListener('change', function () { sync(); apex.submit('RUN'); });",
    '    sync();',
    '})();'])

# =============================================================== القائمة
app.nav_item('لوحة التصنيع', 1, 'fa-industry', 10)
pr = app.nav_item('الإنتاج', None, 'fa-cogs', 20)
app.nav_item('أمر إنتاج جديد', 'f?p=&APP_ID.:31:&APP_SESSION.::&DEBUG.:RP,31::', 'fa-plus', 21, parent=pr)
app.nav_item('أوامر الإنتاج', 30, 'fa-list-alt', 22, parent=pr)
app.nav_item('فحوصات الجودة', 35, 'fa-check-square-o', 23, parent=pr)
pl = app.nav_item('التخطيط', None, 'fa-calendar', 30)
app.nav_item('تخطيط احتياجات المواد', 40, 'fa-sitemap', 31, parent=pl)
app.nav_item('أحمال مراكز العمل', 41, 'fa-tasks', 32, parent=pl)
en = app.nav_item('الهندسة والإعداد', None, 'fa-wrench', 40)
app.nav_item('قوائم المواد', 20, 'fa-list-ul', 41, parent=en)
app.nav_item('مسارات التصنيع', 22, 'fa-random', 42, parent=en)
app.nav_item('مراكز العمل', 10, 'fa-building-o', 43, parent=en)
app.nav_item('التقارير', 50, 'fa-bar-chart', 50)

app.finalize()
print('NOONA_MFG built:', len(app.pages), 'pages')
