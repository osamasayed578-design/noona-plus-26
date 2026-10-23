"""صفحات المطاعم والكافتريا في تطبيق المبيعات ونقاط البيع (133): لوحة المطعم، شاشة الصالة والطلب، شاشة المطبخ،
العملاء الآجلون والتحصيل، لوحة المبيعات، الإعداد (الصالات والطاولات وقائمة الطعام)، سجل الطلبات.
المنطق كله في NOONA_RST_PKG؛ الواجهة التفاعلية في tools/rst.js.
"""
import os, shutil
import apex_brand

shutil.copyfile(os.path.join(os.path.dirname(__file__), 'rst.js'), os.path.join(apex_brand.STATIC_DIR, 'rst.js'))
if ('rst.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('rst.js', 'application/javascript'))

RST_AJAX = [
    'declare',
    '    l_c  clob;',
    '    l_h  clob;',
    '    l_id number;',
    '    l_op varchar2(30) := apex_application.g_x01;',
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
    '    case l_op',
    "        when 'FLOOR' then l_c := noona_rst_pkg.floor_json(n(apex_application.g_x02));",
    "        when 'OPEN' then l_id := noona_rst_pkg.open_order(apex_application.g_clob_01); l_c := '{\"id\":' || l_id || '}';",
    "        when 'ORDER' then l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));",
    "        when 'ADD' then noona_rst_pkg.add_items(n(apex_application.g_x02), apex_application.g_clob_01);",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));",
    "        when 'QTY' then noona_rst_pkg.set_qty(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x04));",
    "        when 'VOID' then noona_rst_pkg.void_line(n(apex_application.g_x02), apex_application.g_x03);",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x04));",
    "        when 'UPD' then noona_rst_pkg.update_order(apex_application.g_clob_01);",
    "            l_c := noona_rst_pkg.order_json(json_value(apex_application.g_clob_01, '$.id' returning number));",
    "        when 'SEND' then l_id := noona_rst_pkg.send_kitchen(n(apex_application.g_x02));",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));",
    "        when 'MOVE' then noona_rst_pkg.move_table(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));",
    "        when 'MERGE' then noona_rst_pkg.merge_orders(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_rst_pkg.order_json(n(apex_application.g_x03));",
    "        when 'SPLIT' then l_id := noona_rst_pkg.split_order(n(apex_application.g_x02), apex_application.g_clob_01);",
    "            l_c := '{\"id\":' || l_id || '}';",
    "        when 'CANCEL' then noona_rst_pkg.cancel_order(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'BILL' then l_h := noona_rst_pkg.bill_html(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            select json_object('html' value l_h returning clob) into l_c from dual;",
    "        when 'DUE' then l_c := '{\"due\":' || to_char(noona_rst_pkg.orders_total(apex_application.g_x02), 'FM9999999990D00',",
    "                                 'NLS_NUMERIC_CHARACTERS=''.,''') || '}';",
    "        when 'SETTLE' then l_c := noona_rst_pkg.settle(apex_application.g_clob_01);",
    "        when 'CUSTS' then l_c := '{\"list\":' || noona_rst_pkg.credit_customers_json(apex_application.g_x02) || '}';",
    "        when 'NEWCUST' then l_id := noona_rst_pkg.quick_customer(apex_application.g_x02, apex_application.g_x03, n(apex_application.g_x04));",
    "            l_c := '{\"id\":' || l_id || '}';",
    "        when 'KITCHEN' then l_c := '{\"list\":' || noona_rst_pkg.kitchen_json(n(apex_application.g_x02)) || '}';",
    "        when 'KREADY' then noona_rst_pkg.kitchen_ready(n(apex_application.g_x02), n(apex_application.g_x03));",
    "        when 'KSERVED' then noona_rst_pkg.kitchen_served(n(apex_application.g_x02));",
    "        when 'CREDIT' then l_h := noona_rst_pkg.credit_html(apex_application.g_x02);",
    "            select json_object('html' value l_h returning clob) into l_c from dual;",
    "        when 'COLLECT' then l_id := noona_rst_pkg.collect(apex_application.g_clob_01);",
    "            select json_object('id' value id, 'no' value doc_no returning clob) into l_c from ar_receipt where id = l_id;",
    "        when 'STMT' then l_h := noona_sal_pkg.customer_statement(n(apex_application.g_x02), d(apex_application.g_x03), d(apex_application.g_x04));",
    "            select json_object('html' value l_h returning clob) into l_c from dual;",
    "        else raise_application_error(-20500, 'NOONA-RST-099: عملية غير معروفة ' || l_op);",
    '    end case;',
    "    out(nvl(l_c, to_clob('{\"ok\":true}')));",
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('err', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']
LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'rst.js'; "
          "document.head.appendChild(s); })();"]


def build(app, url, scheme):
    def link(page_no, item, col='ID'):
        return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'

    READY = "noona_rst_pkg.is_ready = 'Y'"
    TERM_LOV = ("select code || ' - ' || name_ar d, id r from pos_terminal where company_id = noona_rst_pkg.company "
                "and status_code = 'ACTIVE' order by code")
    AREA_LOV = "select name_ar || ' (' || code || ')' d, id r from rst_area where company_id = noona_rst_pkg.company order by sort_order, code"
    TABLE_LOV = ("select a.name_ar || ' - ' || t.code d, t.id r from rst_table t join rst_area a on a.id = t.area_id "
                 "where t.company_id = noona_rst_pkg.company order by a.sort_order, t.sort_order, t.code")
    MCAT_LOV = ("select name_ar d, id r from inv_item_category where code = 'MENU' or parent_category_id = "
                "(select min(id) from inv_item_category where code = 'MENU') order by case when code = 'MENU' then 0 else 1 end, name_ar")
    MENU_ITEM_LOV = ("select i.name_ar d, i.id r from inv_item i where i.category_id in (select id from inv_item_category where code = 'MENU' "
                     "or parent_category_id = (select min(id) from inv_item_category where code = 'MENU')) order by i.name_ar")
    STATUS_LOV = 'STATIC2:نشط;ACTIVE,موقوف;INACTIVE'
    SHAPE_LOV = 'STATIC2:مربعة;SQUARE,دائرية;ROUND,طويلة;LONG,ركن;BOOTH'

    # =========================================================== 60) لوحة المطعم
    p = app.page(60, 'Restaurant', 'RESTAURANT', 'المطاعم والكافتريا', scheme=scheme)
    st = p.static('تجهيز المطعم', 5, condition="noona_rst_pkg.is_ready = 'N'",
                  text='<p class="nn-hint">ينشئ نقطة البيع والدرج النقدي إن لم تكن موجودة، وصالة رئيسية بعشر طاولات، وفئة «قائمة الطعام»، '
                       'وترقيم الطلبات. يمكنك بعدها تعديل الصالات والطاولات وإضافة أصناف القائمة من «إعداد المطعم».</p>')
    b = p.button(st, 10, 'SETUP', 'تجهيز المطعم', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_rst_pkg.quick_setup;', 'end;'], when_button=b,
              success='تم تجهيز المطعم: الصالة الرئيسية بعشر طاولات وفئة قائمة الطعام وترقيم الطلبات')
    p.dynamic('اليوم', 10, 'return noona_rst_pkg.today_html;', hide_header=True, condition=READY)
    qa = p.static('إجراءات سريعة', 15, condition=READY)
    p.button(qa, 10, 'FLOOR', 'شاشة الصالة والطلبات', hot=True, redirect=url(61))
    p.button(qa, 20, 'KITCHEN', 'شاشة المطبخ', redirect=url(62))
    p.button(qa, 30, 'CREDIT', 'العملاء الآجلون والتحصيل', redirect=url(63))
    p.button(qa, 40, 'DASH', 'لوحة مبيعات المطعم', redirect=url(64))
    p.button(qa, 50, 'ORDERS', 'سجل الطلبات', redirect=url(66))
    p.button(qa, 60, 'SHIFT', 'إقفال الوردية', redirect=url(32))
    p.button(qa, 70, 'SETUPP', 'إعداد المطعم والقائمة', redirect=url(65))
    p.ir('الطلبات المفتوحة الآن', 20, [
        "select o.id, o.order_no, noona_rst_pkg.type_label(o.order_type) as otype, t.code as tbl, o.guests, o.waiter_name,",
        "       nvl(o.customer_name, noona_sal_pkg.customer_label(o.customer_account_id)) as cust, noona_rst_pkg.status_label(o.status_code) as status,",
        "       o.total_amount, round((cast(systimestamp as date) - cast(o.opened_at as date)) * 1440) as mins",
        "  from rst_order o left join rst_table t on t.id = o.table_id",
        " where o.company_id = noona_rst_pkg.company and o.status_code in ('OPEN', 'BILLED') order by o.opened_at"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ORDER_NO', 'الطلب', {}), ('OTYPE', 'النوع', {}), ('TBL', 'الطاولة', {}),
         ('GUESTS', 'الأشخاص', {'type': 'NUMBER'}), ('WAITER_NAME', 'النادل', {}), ('CUST', 'العميل', {}), ('STATUS', 'الحالة', {}),
         ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('MINS', 'منذ (دقيقة)', {'type': 'NUMBER'})],
        titled=True, rows=15)
    p.branch(10, url(60) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 61) الصالة والطلبات
    p = app.page(61, 'Restaurant Floor', 'RESTAURANT-FLOOR', 'الصالة والطلبات', scheme=scheme, protection='N')
    f = p.static('نقطة البيع', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P61_TERM', f, 10, 'نقطة البيع', lov_sql=TERM_LOV, null_text=None, submit=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ':P61_TERM := nvl(:P61_TERM, noona_rst_pkg.default_terminal);')
    p.dynamic('الصالة', 10, [
        'begin',
        "    if :P61_TERM is null then return '<div class=\"nn-empty\">جهز المطعم من لوحة المطعم أولاً</div>'; end if;",
        "    return '<script type=\"application/json\" id=\"nnRstBoot\">' || replace(noona_rst_pkg.boot_json(:P61_TERM), '</', '<\\/') || '</script>'",
        "        || '<div id=\"nnRst\" class=\"nn-rst\" data-mode=\"pos\" data-term=\"' || :P61_TERM || '\"></div>';",
        'end;'], hide_header=True, opts='#DEFAULT#:t-Region--noUI')
    p.process(1, 'ON_DEMAND', 'RST', RST_AJAX)
    p.onload(LOADER)
    p.branch(10, url(61, 'P61_TERM', '&P61_TERM.'))

    # =========================================================== 62) المطبخ
    p = app.page(62, 'Kitchen Display', 'KITCHEN', 'شاشة المطبخ', scheme=scheme, protection='N')
    f = p.static('نقطة البيع', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P62_TERM', f, 10, 'نقطة البيع', lov_sql=TERM_LOV, null_text='كل نقاط البيع', submit=True)
    p.dynamic('المطبخ', 10, "return '<div id=\"nnRst\" class=\"nn-rst\" data-mode=\"kitchen\" data-term=\"' || :P62_TERM || '\"></div>';",
              hide_header=True, opts='#DEFAULT#:t-Region--noUI')
    p.process(1, 'ON_DEMAND', 'RST', RST_AJAX)
    p.onload(LOADER)
    p.branch(10, url(62, 'P62_TERM', '&P62_TERM.'))

    # =========================================================== 63) العملاء الآجلون والتحصيل
    p = app.page(63, 'Credit Customers', 'RESTAURANT-CREDIT', 'العملاء الآجلون والتحصيل', scheme=scheme, protection='N')
    p.dynamic('العملاء الآجلون', 10, "return '<div id=\"nnRst\" class=\"nn-rst\" data-mode=\"credit\"></div>';", hide_header=True,
              opts='#DEFAULT#:t-Region--noUI')
    p.process(1, 'ON_DEMAND', 'RST', RST_AJAX)
    p.onload(LOADER)
    p.ir('آخر سندات التحصيل', 20, [
        "select r.id, r.doc_no, r.doc_date, noona_sal_pkg.customer_label(r.customer_account_id) as cust, m.name_ar as method, r.amount,",
        "       r.external_reference, case r.status_code when 'CONFIRMED' then 'مؤكد' when 'REVERSED' then 'معكوس' else r.status_code end as status",
        "  from ar_receipt r left join ref_payment_method m on m.id = r.payment_method_id",
        " where r.company_id = noona_rst_pkg.company",
        "   and r.customer_account_id in (select customer_account_id from rst_order where status_code = 'CHARGED')",
        " order by r.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'السند', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE'}), ('CUST', 'العميل', {}),
         ('METHOD', 'الطريقة', {}), ('AMOUNT', 'المبلغ', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('EXTERNAL_REFERENCE', 'المرجع', {}),
         ('STATUS', 'الحالة', {})], titled=True, rows=10)

    # =========================================================== 64) لوحة مبيعات المطعم
    p = app.page(64, 'Restaurant Dashboard', 'RESTAURANT-DASHBOARD', 'لوحة مبيعات المطعم', scheme=scheme, protection='N')
    f = p.static('الفترة', 5, opts='#DEFAULT#:nn-rpt-filters')
    p.date('P64_FROM', f, 10, 'من تاريخ')
    p.date('P64_TO', f, 20, 'إلى تاريخ')
    p.select('P64_TERM', f, 30, 'نقطة البيع', lov_sql=TERM_LOV, null_text='كل نقاط البيع')
    p.button(f, 10, 'RUN', 'عرض', hot=True)
    p.button(f, 20, 'TODAY', 'اليوم', redirect=url(64, 'P64_FROM,P64_TO', '&P64_TODAY.,&P64_TODAY.'))
    p.button(f, 30, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.hidden('P64_TODAY', f, 90, protected=False)
    p.process(10, 'BEFORE_HEADER', 'Defaults', [
        ":P64_TODAY := to_char(sysdate, 'YYYY-MM-DD');",
        ":P64_FROM := nvl(:P64_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
        ":P64_TO := nvl(:P64_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
    p.dynamic('لوحة المبيعات', 20, "return noona_rst_pkg.dashboard_html(to_date(:P64_FROM, 'YYYY-MM-DD'), to_date(:P64_TO, 'YYYY-MM-DD'), :P64_TERM);",
              hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

    # =========================================================== 65) الإعداد
    p = app.page(65, 'Restaurant Setup', 'RESTAURANT-SETUP', 'إعداد المطعم والقائمة', scheme=scheme)
    fa = p.static('صالة جديدة', 10)
    p.text('P65_A_CODE', fa, 10, 'الرمز', maxlen=30, width=10)
    p.text('P65_A_NAME', fa, 20, 'اسم الصالة (داخلية، خارجية، عائلات، VIP...)', maxlen=200, width=30)
    p.select('P65_A_TERM', fa, 30, 'نقطة البيع', lov_sql=TERM_LOV, null_text=None)
    p.number('P65_A_SORT', fa, 40, 'الترتيب')
    b_area = p.button(fa, 10, 'ADD_AREA', 'إضافة الصالة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Area', ['declare l number;', 'begin',
        '    l := noona_rst_pkg.save_area(null, :P65_A_CODE, :P65_A_NAME, :P65_A_TERM, to_number(:P65_A_SORT));', 'end;'],
        when_button=b_area, success='تمت إضافة الصالة')
    ft = p.static('إضافة طاولات', 20)
    p.select('P65_T_AREA', ft, 10, 'الصالة', lov_sql=AREA_LOV, null_text=None)
    p.number('P65_T_COUNT', ft, 20, 'عدد الطاولات')
    p.text('P65_T_PREFIX', ft, 30, 'بادئة الرقم', maxlen=5, width=6)
    p.number('P65_T_SEATS', ft, 40, 'المقاعد لكل طاولة')
    b_tab = p.button(ft, 10, 'ADD_TABLES', 'إضافة الطاولات', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [":P65_T_PREFIX := nvl(:P65_T_PREFIX, 'T');", ':P65_T_SEATS := nvl(:P65_T_SEATS, 4);',
                                                ':P65_T_COUNT := nvl(:P65_T_COUNT, 5);'])
    p.process(20, 'AFTER_SUBMIT', 'Tables', ['declare l number;', 'begin',
        '    l := noona_rst_pkg.add_tables(:P65_T_AREA, to_number(:P65_T_COUNT), :P65_T_PREFIX, to_number(:P65_T_SEATS));', 'end;'],
        when_button=b_tab, success='تمت إضافة الطاولات')
    fe = p.static('تعديل طاولة', 25)
    p.select('P65_E_TABLE', fe, 10, 'الطاولة', lov_sql=TABLE_LOV, null_text='- اختر -')
    p.number('P65_E_SEATS', fe, 20, 'المقاعد')
    p.select('P65_E_SHAPE', fe, 30, 'الشكل', lov_sql=SHAPE_LOV, null_text='- بلا تغيير -')
    p.select('P65_E_STATUS', fe, 40, 'الحالة', lov_sql=STATUS_LOV, null_text='- بلا تغيير -')
    b_ed = p.button(fe, 10, 'SAVE_TABLE', 'حفظ الطاولة')
    p.process(25, 'AFTER_SUBMIT', 'Edit Table', ['declare l number; l_area number; l_code varchar2(30);', 'begin',
        '    select area_id, code into l_area, l_code from rst_table where id = :P65_E_TABLE and company_id = noona_rst_pkg.company;',
        '    l := noona_rst_pkg.save_table(:P65_E_TABLE, l_area, l_code, null, to_number(:P65_E_SEATS), :P65_E_SHAPE, :P65_E_STATUS);', 'end;'],
        when_button=b_ed, success='تم حفظ الطاولة')
    fm = p.static('صنف في قائمة الطعام', 30)
    p.select('P65_M_ITEM', fm, 5, 'تعديل صنف قائم', lov_sql=MENU_ITEM_LOV, null_text='- صنف جديد -', submit=True)
    p.process(6, 'BEFORE_HEADER', 'Load Item', [
        'begin',
        '    if :P65_M_ITEM is not null then',
        "        select i.name_ar, i.category_id, c.sale_price, case i.status_code when 'ACTIVE' then 'ACTIVE' else 'INACTIVE' end",
        '          into :P65_M_NAME, :P65_M_CAT, :P65_M_PRICE, :P65_M_STATUS',
        '          from inv_item i left join inv_item_company c on c.item_id = i.id and c.company_id = noona_rst_pkg.company where i.id = :P65_M_ITEM;',
        '    end if;',
        'exception when no_data_found then null;',
        'end;'])
    p.text('P65_M_NAME', fm, 10, 'اسم الصنف', maxlen=200, width=30)
    p.select('P65_M_CAT', fm, 20, 'فئة القائمة', lov_sql=MCAT_LOV, null_text=None)
    p.number('P65_M_PRICE', fm, 30, 'السعر شامل الضريبة')
    p.select('P65_M_STATUS', fm, 40, 'الحالة', lov_sql=STATUS_LOV, null_text=None)
    b_item = p.button(fm, 10, 'SAVE_ITEM', 'حفظ الصنف', hot=True)
    fc = p.static('فئة جديدة في القائمة', 35)
    p.text('P65_C_CODE', fc, 10, 'الرمز', maxlen=30, width=12)
    p.text('P65_C_NAME', fc, 20, 'اسم الفئة (مشروبات ساخنة، وجبات، حلويات...)', maxlen=200, width=30)
    b_cat = p.button(fc, 10, 'ADD_CAT', 'إضافة الفئة')
    p.process(30, 'AFTER_SUBMIT', 'Item', ['declare l number;', 'begin',
        '    l := noona_rst_pkg.save_menu_item(to_number(:P65_M_ITEM), :P65_M_NAME, to_number(:P65_M_CAT), to_number(:P65_M_PRICE), :P65_M_STATUS);',
        "    :P65_M_ITEM := null; :P65_M_NAME := null; :P65_M_PRICE := null;", 'end;'],
        when_button=b_item, success='تم حفظ صنف القائمة')
    p.process(35, 'AFTER_SUBMIT', 'Category', ['declare l number;', 'begin',
        '    l := noona_rst_pkg.menu_category(:P65_C_CODE, :P65_C_NAME);', 'end;'], when_button=b_cat, success='تمت إضافة الفئة')
    p.ir('الصالات والطاولات', 40, [
        "select t.id, a.name_ar as area, t.code, t.name_ar, t.seats, case t.shape when 'ROUND' then 'دائرية' when 'LONG' then 'طويلة'",
        "       when 'BOOTH' then 'ركن' else 'مربعة' end as shape, (select code from pos_terminal where id = a.terminal_id) as terminal,",
        "       case t.status_code when 'ACTIVE' then 'نشطة' else 'موقوفة' end as status",
        "  from rst_table t join rst_area a on a.id = t.area_id where t.company_id = noona_rst_pkg.company order by a.sort_order, t.sort_order, t.code"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('AREA', 'الصالة', {}), ('CODE', 'الرقم', {}), ('NAME_AR', 'الاسم', {}),
         ('SEATS', 'المقاعد', {'type': 'NUMBER'}), ('SHAPE', 'الشكل', {}), ('TERMINAL', 'نقطة البيع', {}), ('STATUS', 'الحالة', {})],
        titled=True, rows=25)
    p.ir('قائمة الطعام', 50, [
        "select i.id, g.name_ar as cat, i.item_no, i.name_ar, c.sale_price, case c.prices_include_tax when 'Y' then 'شامل' else 'غير شامل' end as incl,",
        "       case i.status_code when 'ACTIVE' then 'نشط' else 'موقوف' end as status",
        "  from inv_item i join inv_item_category g on g.id = i.category_id",
        "  left join inv_item_company c on c.item_id = i.id and c.company_id = noona_rst_pkg.company",
        " where g.code = 'MENU' or g.parent_category_id = (select min(id) from inv_item_category where code = 'MENU') order by g.name_ar, i.name_ar"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CAT', 'الفئة', {}), ('ITEM_NO', 'رقم الصنف', {}), ('NAME_AR', 'الصنف', {}),
         ('SALE_PRICE', 'السعر', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('INCL', 'الضريبة', {}), ('STATUS', 'الحالة', {})],
        titled=True, rows=50)
    p.static('ملاحظة', 60, text='<p class="nn-hint">تظهر في شاشة الطلب كل الأصناف القابلة للبيع ولها سعر بيع (ومنها أصناف المخزون كالمشروبات المعلبة '
                                 'التي تصرف من المستودع تلقائياً). أصناف القائمة المضافة هنا أصناف خدمية لا تتبع مخزونياً.</p>')
    p.branch(10, url(65) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 66) سجل الطلبات
    p = app.page(66, 'Restaurant Orders', 'RESTAURANT-ORDERS', 'سجل طلبات المطعم', scheme=scheme)
    p.ir('الطلبات', 10, [
        "select o.id, o.order_no, to_char(o.opened_at, 'YYYY-MM-DD HH24:MI') as opened, noona_rst_pkg.type_label(o.order_type) as otype,",
        "       t.code as tbl, o.guests, o.waiter_name, nvl(o.customer_name, noona_sal_pkg.customer_label(o.customer_account_id)) as cust,",
        "       o.customer_phone, noona_rst_pkg.status_label(o.status_code) as status,",
        "       case o.settle_mode when 'PAID' then 'مدفوع' when 'CREDIT' then 'آجل' when 'MIXED' then 'مختلط' end as settle,",
        "       o.discount_pct, o.total_amount, s.receipt_no, o.pos_sale_id, to_char(o.closed_at, 'YYYY-MM-DD HH24:MI') as closed, o.cancel_reason,",
        "       case when o.pos_sale_id is not null then '<span class=\"fa fa-print\" aria-hidden=\"true\"></span> الإيصال' end as rcpt",
        "  from rst_order o left join rst_table t on t.id = o.table_id left join pos_sale s on s.id = o.pos_sale_id",
        " where o.company_id = noona_rst_pkg.company order by o.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ORDER_NO', 'الطلب', {}), ('OPENED', 'الفتح', {}), ('OTYPE', 'النوع', {}),
         ('TBL', 'الطاولة', {}), ('GUESTS', 'الأشخاص', {'type': 'NUMBER'}), ('WAITER_NAME', 'النادل', {}), ('CUST', 'العميل', {}),
         ('CUSTOMER_PHONE', 'الجوال', {}), ('STATUS', 'الحالة', {}), ('SETTLE', 'السداد', {}), ('DISCOUNT_PCT', 'خصم %', {'type': 'NUMBER'}),
         ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('RECEIPT_NO', 'الإيصال', {}),
         ('POS_SALE_ID', 'رقم البيع', {'hidden': True, 'type': 'NUMBER'}), ('CLOSED', 'الإقفال', {}), ('CANCEL_REASON', 'سبب الإلغاء', {}),
         ('RCPT', 'طباعة', {'html': True, 'link': ('f?p=&APP_ID.:33:&SESSION.::&DEBUG.:RP,33:P33_ID:#POS_SALE_ID#', '#RCPT#')})],
        titled=True, rows=25)

    # القائمة
    rs = app.nav_item('المطاعم والكافتريا', None, 'fa-cutlery', 35)
    app.nav_item('لوحة المطعم', 60, 'fa-dashboard', 351, parent=rs)
    app.nav_item('الصالة والطلبات', 61, 'fa-th-large', 352, parent=rs)
    app.nav_item('شاشة المطبخ', 62, 'fa-fire', 353, parent=rs)
    app.nav_item('العملاء الآجلون والتحصيل', 63, 'fa-user-circle', 354, parent=rs)
    app.nav_item('لوحة مبيعات المطعم', 64, 'fa-pie-chart', 355, parent=rs)
    app.nav_item('سجل الطلبات', 66, 'fa-list', 356, parent=rs)
    app.nav_item('إعداد المطعم والقائمة', 65, 'fa-cogs', 357, parent=rs)
