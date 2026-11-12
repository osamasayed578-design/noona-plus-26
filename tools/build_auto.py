"""NOONA_AUTO (مراكز خدمة السيارات): لوحة الورشة، استلام السيارة وفتح أمر الإصلاح، شاشة أمر الإصلاح (كروت الخدمات وبحث القطع
والفني والفاتورة الواحدة والتسليم)، أوامر الإصلاح، الحجوزات، المركبات وسجلها، مطالبات التأمين وشركاته، إعداد الخدمات والقطع
الافتراضية، الرافعات والفنيون، والتقارير.
الاستخدام: python3 tools/build_auto.py  ->  apex/NOONA_AUTO/f145
المنطق كله في NOONA_AUT_PKG؛ الواجهة التفاعلية في tools/aut.js.
"""
import os, shutil, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
import apex_brand

ROOT = os.path.join(os.path.dirname(__file__), '..')
shutil.copyfile(os.path.join(os.path.dirname(__file__), 'aut.js'), os.path.join(apex_brand.STATIC_DIR, 'aut.js'))
if ('aut.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('aut.js', 'application/javascript'))
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_AUTO/f145'),
          app_id=145, alias='NOONA_AUTO', name='NOONA Auto Service Centers', id_base=91820280000000000)
app.wire_security()
app.add_branding()
AUT = app.add_scheme('noona_aut_view', app.id(), 'NOONA - Auto Service',
                     "return noona_security_pkg.has_permission('AUT_JOB_CARD.VIEW', noona_aut_pkg.company) = 'Y';",
                     'شاشات مركز الخدمة تتطلب صلاحية عرض أوامر الإصلاح / Auto service access required')
SETUP = app.add_scheme('noona_aut_setup', app.id(), 'NOONA - Auto Service Setup',
                       "return noona_security_pkg.has_permission('AUT_SERVICE.UPDATE', noona_aut_pkg.company) = 'Y';",
                       'إعداد مركز الخدمة يتطلب صلاحية تعديل الخدمات / Setup access required')
READY = "noona_aut_pkg.is_ready = 'Y'"


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


JOB_LINK = 'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
CAT_LOV = "select name_ar d, id r from aut_service_category where company_id = noona_aut_pkg.company and is_active = 'Y' order by sort_order nulls last, name_ar"
SVC_LOV = ("select s.name_ar || ' (' || to_char(s.price, 'FM999G990D00') || ')' d, s.id r from aut_service s where s.company_id = noona_aut_pkg.company "
           "and s.is_active = 'Y' order by s.sort_order nulls last, s.name_ar")
BAY_LOV = "select name_ar d, id r from aut_bay where company_id = noona_aut_pkg.company and is_active = 'Y' order by sort_order nulls last, code"
TECH_LOV = "select name_ar d, id r from aut_technician where company_id = noona_aut_pkg.company and is_active = 'Y' order by name_ar"
INS_LOV = "select name_ar d, id r from aut_insurer where company_id = noona_aut_pkg.company and status_code = 'ACTIVE' order by name_ar"
PART_LOV = ("select i.item_no || ' - ' || i.name_ar || nvl2(i.manufacturer_part_no, ' [' || i.manufacturer_part_no || ']', '') d, i.id r from inv_item i "
            "where i.status_code = 'ACTIVE' and i.is_sellable = 'Y' and i.item_type not in ('SERVICE', 'ASSET', 'REAL_ESTATE_UNIT') order by i.name_ar")
EMP_LOV = ("select e.employee_no || ' - ' || p.display_name_ar d, e.id r from hr_employee e join pty_party p on p.id = e.person_party_id "
           "where exists (select 1 from hr_employment m where m.employee_id = e.id and m.company_id = noona_aut_pkg.company "
           "and m.status_code in ('ACTIVE', 'NOTICE_PERIOD')) order by e.employee_no")
PAYER_LOV = 'STATIC2:العميل;CUSTOMER,شركة التأمين;INSURANCE,الضمان;WARRANTY,داخلي;INTERNAL'
FUEL_LOV = 'STATIC2:فارغ;EMPTY,ربع;QUARTER,نصف;HALF,ثلاثة أرباع;THREE_QUARTERS,ممتلئ;FULL'
PTYPE_LOV = ('STATIC2:خصوصي;PRIVATE,نقل خاص;COMMERCIAL,أجرة;TAXI,نقل عام;TRANSPORT,دراجة نارية;MOTORCYCLE,مؤقتة;TEMPORARY,'
             'دبلوماسية;DIPLOMATIC,تصدير;EXPORT')
FUELT_LOV = 'STATIC2:بنزين;PETROL,ديزل;DIESEL,هجين;HYBRID,كهربائي;ELECTRIC,غاز;GAS'
TRANS_LOV = 'STATIC2:أوتوماتيك;AUTOMATIC,عادي;MANUAL,CVT;CVT'
SOURCE_LOV = 'STATIC2:هاتف;PHONE,حضور مباشر;WALK_IN,واتساب;WHATSAPP,الموقع;WEB,التطبيق;APP'
BAYTYPE_LOV = ('STATIC2:رافعة;LIFT,أرضي;FLOOR,غسيل;WASH,دهان;PAINT,وزن أذرعة;ALIGNMENT,فحص كمبيوتر;DIAGNOSTIC,إطارات;TIRE')
CLAIM_LOV = ('STATIC2:المفتوحة;OPEN,لم تقدم;NOT_SUBMITTED,مقدمة;SUBMITTED,معتمدة;APPROVED,معتمدة جزئياً;PARTIALLY_APPROVED,'
             'مرفوضة;REJECTED,مدفوعة;PAID')
STATUS_LOV = 'STATIC2:نشط;Y,موقوف;N'
KIND_LOV = ('STATIC2:إجمالي العمليات (خدمات وقطع);SUMMARY,الخدمات المنفذة;SERVICES,مبيعات قطع الغيار;PARTS,أكثر الخدمات طلباً;TOP_SERVICES,'
            'أكثر القطع مبيعاً;TOP_PARTS,إنتاجية الفنيين وعمولاتهم;TECHNICIANS,مدة بقاء المركبات;STAY,مطالبات التأمين;INSURANCE,'
            'الحجوزات ونسبة الحضور;APPOINTMENTS,الخدمات والتجديدات المستحقة;DUE,حسب الشركة المصنعة;MAKES,أعلى المركبات إنفاقاً;VEHICLES')
JOB_STATUS = ("case j.status_code when 'OPEN' then 'مفتوح' when 'IN_PROGRESS' then 'قيد العمل' when 'WAITING_PARTS' then 'بانتظار قطع' "
              "when 'COMPLETED' then 'جاهز' when 'INVOICED' then 'مفوتر' when 'DELIVERED' then 'مسلم' when 'CANCELLED' then 'ملغى' end")

AUT_AJAX = [
    'declare',
    '    l_c  clob;',
    '    l_h  clob;',
    '    l_id number;',
    '    l_op varchar2(30) := apex_application.g_x01;',
    '    function n(p varchar2) return number is begin return to_number(p); end;',
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
    "        when 'JOB' then l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'ADDSVC' then l_id := noona_aut_pkg.add_service(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'ADDBND' then l_id := noona_aut_pkg.add_bundle(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'ADDPART' then l_id := noona_aut_pkg.add_part(n(apex_application.g_x02), n(apex_application.g_x03), n(apex_application.g_x04));",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'ADDLINE' then l_id := noona_aut_pkg.add_line(apex_application.g_clob_01);",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'UPDLINE' then noona_aut_pkg.update_line(apex_application.g_clob_01);",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'DELLINE' then noona_aut_pkg.remove_line(n(apex_application.g_x02));",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x03));",
    "        when 'LACT' then noona_aut_pkg.line_action(n(apex_application.g_x02), apex_application.g_x03);",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x04));",
    "        when 'STATUS' then noona_aut_pkg.set_job_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'UPDJOB' then noona_aut_pkg.update_job(apex_application.g_clob_01);",
    "            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, '$.id' returning number));",
    "        when 'CLAIM' then noona_aut_pkg.set_claim(apex_application.g_clob_01);",
    "            l_c := noona_aut_pkg.job_json(json_value(apex_application.g_clob_01, '$.job' returning number));",
    "        when 'INVOICE' then l_id := noona_aut_pkg.invoice_job(n(apex_application.g_x02), apex_application.g_clob_01);",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'DELIVER' then noona_aut_pkg.deliver_job(n(apex_application.g_x02), n(apex_application.g_x03));",
    "            l_c := noona_aut_pkg.job_json(n(apex_application.g_x02));",
    "        when 'PARTS' then l_c := '{\"list\":' || noona_aut_pkg.search_parts_json(apex_application.g_x02, n(apex_application.g_x03)) || '}';",
    "        when 'APPT' then noona_aut_pkg.set_appointment_status(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04);",
    "        when 'CHECKIN' then l_id := noona_aut_pkg.check_in(n(apex_application.g_x02), apex_application.g_clob_01);",
    "            l_c := '{\"id\":' || l_id || '}';",
    "        when 'PRINT' then l_h := noona_aut_pkg.job_print(n(apex_application.g_x02));",
    "            select json_object('html' value l_h returning clob) into l_c from dual;",
    "        else raise_application_error(-20500, 'NOONA-AUT-099: عملية غير معروفة ' || l_op);",
    '    end case;',
    "    out(nvl(l_c, to_clob('{\"ok\":true}')));",
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('err', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']
LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'aut.js'; "
          "document.head.appendChild(s); })();"]


def ajax_page(p):
    p.process(1, 'ON_DEMAND', 'AUT', AUT_AJAX)
    p.onload(LOADER)


# =============================================================== 1) لوحة الورشة
p = app.page(1, 'Home', 'HOME', 'مركز خدمة السيارات', scheme=AUT, protection='N')
st = p.static('تجهيز مركز الخدمة', 5, condition="noona_aut_pkg.is_ready = 'N'",
              text='<p class="nn-hint">ينشئ حساب إيرادات خدمات الصيانة (4160) ورافعتين افتراضيتين وترقيم أوامر الإصلاح والحجوزات. '
                   'أضف بعدها فئات الخدمات والخدمات (الكروت) والفنيين من الإعداد. مرة واحدة لكل شركة.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز مركز الخدمة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_aut_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم التجهيز: حساب الإيرادات والرافعات والترقيم')
p.dynamic('المؤشرات', 10, 'return noona_aut_pkg.summary_html;', hide_header=True, condition=READY)
qa = p.static('إجراءات سريعة', 15, condition=READY)
p.button(qa, 10, 'CHECKIN', 'استلام سيارة', hot=True, redirect=url(2, clear='RP,2'))
p.button(qa, 20, 'BOOK', 'الحجوزات', redirect=url(5))
p.button(qa, 30, 'JOBS', 'أوامر الإصلاح', redirect=url(4))
p.button(qa, 40, 'VEH', 'المركبات', redirect=url(6))
p.button(qa, 50, 'CLAIMS', 'مطالبات التأمين', redirect=url(8))
p.button(qa, 60, 'RPT', 'التقارير', redirect=url(12))
p.dynamic('السيارات في الورشة', 20, 'return noona_aut_pkg.board_html;', condition=READY, opts='#DEFAULT#:t-Region--scrollBody')
ajax_page(p)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 2) استلام السيارة
p = app.page(2, 'Check-in', 'CHECK-IN', 'استلام سيارة وفتح أمر إصلاح', scheme=AUT)
v = p.static('المركبة', 10, text='<p class="nn-hint">اكتب رقم اللوحة واضغط «بحث»: تملأ بيانات المركبة المسجلة. اللوحة الجديدة تسجل مع الأمر.</p>')
p.text('P2_PLATE', v, 10, 'رقم اللوحة', required=True, maxlen=30, width=15)
b_find = p.button(v, 10, 'FIND', 'بحث')
p.hidden('P2_VEH', v, 15)
p.text('P2_MAKE', v, 20, 'الشركة المصنعة', maxlen=100, width=20)
p.text('P2_MODEL', v, 30, 'الطراز', maxlen=100, width=20)
p.number('P2_YEAR', v, 40, 'سنة الصنع')
p.text('P2_COLOR', v, 50, 'اللون', maxlen=50, width=12)
p.text('P2_VIN', v, 60, 'رقم الهيكل (VIN)', maxlen=30, width=22)
p.text('P2_OWNER', v, 70, 'اسم المالك / العميل', maxlen=200, width=30)
p.text('P2_PHONE', v, 80, 'الجوال', maxlen=30, width=15)
j = p.static('الاستلام', 20)
p.number('P2_ODO', j, 10, 'قراءة العداد (كم)')
p.select('P2_FUEL', j, 20, 'مستوى الوقود', lov_sql=FUEL_LOV)
p.select('P2_BAY', j, 30, 'الرافعة / موقع العمل', lov_sql=BAY_LOV)
p.text('P2_PROMISED', j, 40, 'الموعد المتوقع للتسليم (YYYY-MM-DD HH24:MI)', maxlen=16, width=16)
p.textarea('P2_COMPLAINT', j, 50, 'شكوى العميل / المطلوب')
p.textarea('P2_INSPECT', j, 60, 'فحص الاستلام: الأضرار والخدوش والمتعلقات')
p.checkboxes('P2_SERVICES', j, 70, 'الخدمات المطلوبة (اختياري؛ تضاف من الكروت لاحقاً)', SVC_LOV, columns=3)
ins = p.static('جهة السداد والتأمين', 30)
p.select('P2_PAYER', ins, 10, 'جهة السداد', lov_sql=PAYER_LOV, null_text=None)
p.select('P2_INSURER', ins, 20, 'شركة التأمين', lov_sql=INS_LOV)
p.text('P2_CLAIM', ins, 30, 'رقم المطالبة', maxlen=50, width=20)
p.text('P2_POLICY', ins, 40, 'رقم الوثيقة', maxlen=50, width=20)
p.text('P2_ACCIDENT', ins, 50, 'رقم تقرير الحادث (نجم / المرور)', maxlen=50, width=20)
p.number('P2_DEDUCT', ins, 60, 'تحمل العميل (فارغ = الافتراضي لشركة التأمين)')
sv = p.static('حفظ', 40, hide_header=True)
b_open = p.button(sv, 10, 'OPEN', 'فتح أمر الإصلاح', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "    :P2_PAYER := nvl(:P2_PAYER, 'CUSTOMER');",
    "    :P2_PROMISED := nvl(:P2_PROMISED, to_char(sysdate + 3 / 24, 'YYYY-MM-DD HH24:MI'));",
    '    if :P2_VEH is not null and :P2_PLATE is null then',
    '        select noona_aut_pkg.plate_label(plate_no) into :P2_PLATE from aut_vehicle where id = :P2_VEH and company_id = noona_aut_pkg.company;',
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Find', [
    'declare v aut_vehicle%rowtype;',
    'begin',
    '    :P2_VEH := noona_aut_pkg.vehicle_by_plate(:P2_PLATE);',
    '    if :P2_VEH is null then',
    "        apex_application.g_print_success_message := 'مركبة جديدة؛ أكمل بياناتها وستسجل مع الأمر';",
    '        return;',
    '    end if;',
    '    select * into v from aut_vehicle where id = :P2_VEH;',
    '    :P2_PLATE := noona_aut_pkg.plate_label(v.plate_no); :P2_MAKE := v.make; :P2_MODEL := v.model; :P2_YEAR := v.model_year; :P2_COLOR := v.color; :P2_VIN := v.vin;',
    '    :P2_OWNER := v.owner_name; :P2_PHONE := v.owner_phone; :P2_INSURER := v.insurer_id; :P2_POLICY := v.policy_no;',
    "    apex_application.g_print_success_message := 'مركبة مسجلة: ' || noona_aut_pkg.vehicle_label(v.id)",
    "        || case when v.odometer is not null then ' · آخر عداد ' || v.odometer end;",
    'end;'], when_button=b_find)
p.process(20, 'AFTER_SUBMIT', 'Open', [
    'declare',
    '    l_o  json_object_t := json_object_t();',
    '    l_s  json_array_t := json_array_t();',
    '    l_i  json_object_t;',
    'begin',
    "    if :P2_VEH is not null then l_o.put('vehicle', to_number(:P2_VEH)); else l_o.put('plate', :P2_PLATE); end if;",
    "    l_o.put('make', :P2_MAKE); l_o.put('model', :P2_MODEL); l_o.put('year', to_number(:P2_YEAR)); l_o.put('color', :P2_COLOR);",
    "    l_o.put('vin', :P2_VIN); l_o.put('ownerName', :P2_OWNER); l_o.put('ownerPhone', :P2_PHONE); l_o.put('phone', :P2_PHONE);",
    "    l_o.put('odometer', to_number(:P2_ODO)); l_o.put('fuel', :P2_FUEL); l_o.put('bay', to_number(:P2_BAY));",
    "    l_o.put('promised', :P2_PROMISED); l_o.put('complaint', :P2_COMPLAINT);",
    "    l_o.put('payer', :P2_PAYER); l_o.put('insurer', to_number(:P2_INSURER)); l_o.put('claim', :P2_CLAIM); l_o.put('policy', :P2_POLICY);",
    "    l_o.put('accident', :P2_ACCIDENT); l_o.put('deductible', to_number(:P2_DEDUCT));",
    "    if :P2_INSPECT is not null then l_i := json_object_t(); l_i.put('notes', :P2_INSPECT); l_o.put('inspection', l_i); end if;",
    "    for s in (select to_number(column_value) id from table(apex_string.split(:P2_SERVICES, ':')) where column_value is not null) loop",
    '        l_s.append(s.id);',
    '    end loop;',
    "    l_o.put('services', l_s);",
    '    :P2_VEH := noona_aut_pkg.open_job(l_o.to_clob);   -- يعاد استخدام العنصر لرقم الأمر في التحويل',
    'end;'], when_button=b_open)
p.branch(10, url(3, 'P3_ID', '&P2_VEH.', 'RP,3'), when_button=b_open)
p.branch(20, url(2) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 3) أمر الإصلاح
p = app.page(3, 'Job Card', 'JOB-CARD', 'أمر الإصلاح', scheme=AUT, protection='N')
r = p.dynamic('أمر الإصلاح', 10, [
    'begin',
    "    if :P3_ID is null then return '<div class=\"nn-empty\">اختر أمر الإصلاح من اللوحة أو القائمة</div>'; end if;",
    "    return '<script type=\"application/json\" id=\"nnAutBoot\">' || replace(noona_aut_pkg.boot_json, '</', '<\\/') || '</script>'",
    "        || '<div id=\"nnAut\" class=\"nn-aut\" data-job=\"' || to_number(:P3_ID) || '\"></div>';",
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P3_ID', r, 10, protected=False)
p.dynamic('سجل المركبة', 20, [
    'declare l number;', 'begin',
    '    select max(vehicle_id) into l from aut_job_card where id = to_number(:P3_ID) and company_id = noona_aut_pkg.company;',
    '    return noona_aut_pkg.vehicle_html(l);', 'end;'], condition=':P3_ID is not null')
ajax_page(p)

# =============================================================== 4) أوامر الإصلاح
p = app.page(4, 'Job Cards', 'JOB-CARDS', 'أوامر الإصلاح', scheme=AUT)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'استلام سيارة', hot=True, redirect=url(2, clear='RP,2'))
p.ir('أوامر الإصلاح', 10, [
    f"select j.id, j.doc_no, to_char(j.checkin_at, 'YYYY-MM-DD HH24:MI') as checkin, noona_aut_pkg.plate_label(v.plate_no) as plate_no, v.make || ' ' || v.model as vehicle, j.customer_name,",
    "       j.customer_phone, case j.payer_type when 'INSURANCE' then 'تأمين' when 'WARRANTY' then 'ضمان' when 'INTERNAL' then 'داخلي' else 'العميل' end as payer,",
    "       (select name_ar from aut_insurer where id = j.insurer_id) as insurer, j.claim_no,",
    "       (select listagg(distinct t.name_ar, '، ') within group (order by t.name_ar) from aut_job_line l join aut_technician t on t.id = l.technician_id",
    "         where l.job_card_id = j.id) as techs,",
    "       j.services_amount, j.parts_amount, j.total_amount,",
    "       round((cast(nvl(j.delivered_at, systimestamp) as date) - cast(j.checkin_at as date)) * 24, 1) as hours,",
    f"       {JOB_STATUS} as status, (select doc_no from sal_invoice where id = j.sales_invoice_id) as invoice_no",
    "  from aut_job_card j join aut_vehicle v on v.id = j.vehicle_id where j.company_id = noona_aut_pkg.company order by j.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الأمر', {}), ('CHECKIN', 'الاستلام', {}), ('PLATE_NO', 'اللوحة', {}),
     ('VEHICLE', 'المركبة', {}), ('CUSTOMER_NAME', 'العميل', {}), ('CUSTOMER_PHONE', 'الجوال', {}), ('PAYER', 'السداد', {}),
     ('INSURER', 'التأمين', {}), ('CLAIM_NO', 'المطالبة', {}), ('TECHS', 'الفنيون', {}),
     ('SERVICES_AMOUNT', 'الخدمات', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('PARTS_AMOUNT', 'القطع', {'type': 'NUMBER', 'fmt': '999G999G990D00'}),
     ('TOTAL_AMOUNT', 'الإجمالي', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('HOURS', 'ساعات البقاء', {'type': 'NUMBER'}),
     ('STATUS', 'الحالة', {}), ('INVOICE_NO', 'الفاتورة', {})], link=JOB_LINK, titled=True, rows=25)

# =============================================================== 5) الحجوزات
p = app.page(5, 'Appointments', 'APPOINTMENTS', 'حجوزات الصيانة', scheme=AUT, protection='N')
f = p.static('اليوم', 5, opts='#DEFAULT#:nn-rpt-filters')
p.date('P5_DATE', f, 10, 'التاريخ')
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.button(f, 20, 'NOSHOW', 'تحديث من لم يحضر')
p.process(5, 'BEFORE_HEADER', 'Defaults', ":P5_DATE := nvl(:P5_DATE, to_char(sysdate, 'YYYY-MM-DD'));")
p.dynamic('حجوزات اليوم', 10, "return noona_aut_pkg.appointments_html(to_date(:P5_DATE, 'YYYY-MM-DD'));", opts='#DEFAULT#:t-Region--scrollBody')
bk = p.static('حجز جديد', 20)
p.text('P5_PLATE', bk, 10, 'رقم اللوحة', maxlen=30, width=15)
p.text('P5_NAME', bk, 20, 'اسم العميل', maxlen=200, width=25)
p.text('P5_PHONE', bk, 30, 'الجوال', maxlen=30, width=15)
p.text('P5_START', bk, 40, 'الموعد (YYYY-MM-DD HH24:MI)', required=True, maxlen=16, width=16)
p.number('P5_MINUTES', bk, 50, 'المدة بالدقائق (فارغ = من الخدمات)')
p.select('P5_BAY', bk, 60, 'الرافعة', lov_sql=BAY_LOV)
p.select('P5_TECH', bk, 70, 'الفني', lov_sql=TECH_LOV)
p.select('P5_SOURCE', bk, 80, 'المصدر', lov_sql=SOURCE_LOV, null_text=None)
p.checkboxes('P5_SERVICES', bk, 90, 'الخدمات المطلوبة', SVC_LOV, columns=3)
p.textarea('P5_COMPLAINT', bk, 100, 'ملاحظات / الشكوى')
b_book = p.button(bk, 10, 'BOOK', 'حفظ الحجز', hot=True)
p.process(6, 'BEFORE_HEADER', 'Start Default', [":P5_START := nvl(:P5_START, to_char(to_date(:P5_DATE, 'YYYY-MM-DD') + 9 / 24, 'YYYY-MM-DD HH24:MI'));",
                                                 ":P5_SOURCE := nvl(:P5_SOURCE, 'PHONE');"])
p.process(10, 'AFTER_SUBMIT', 'Book', [
    'declare',
    '    l_o json_object_t := json_object_t();',
    '    l_s json_array_t := json_array_t();',
    '    l   number;',
    'begin',
    "    l_o.put('plate', :P5_PLATE); l_o.put('name', :P5_NAME); l_o.put('phone', :P5_PHONE); l_o.put('start', :P5_START);",
    "    l_o.put('minutes', to_number(:P5_MINUTES)); l_o.put('bay', to_number(:P5_BAY)); l_o.put('tech', to_number(:P5_TECH));",
    "    l_o.put('source', :P5_SOURCE); l_o.put('complaint', :P5_COMPLAINT);",
    "    for s in (select to_number(column_value) id from table(apex_string.split(:P5_SERVICES, ':')) where column_value is not null) loop",
    '        l_s.append(s.id);',
    '    end loop;',
    "    l_o.put('services', l_s);",
    '    l := noona_aut_pkg.book(l_o.to_clob);',
    "    :P5_DATE := substr(:P5_START, 1, 10);",
    "    :P5_PLATE := null; :P5_NAME := null; :P5_PHONE := null; :P5_START := null; :P5_COMPLAINT := null; :P5_SERVICES := null;",
    'end;'], when_button=b_book, success='تم حفظ الحجز')
p.process(20, 'AFTER_SUBMIT', 'No Shows', ['declare l number;', 'begin', '    l := noona_aut_pkg.mark_no_shows;',
          "    apex_application.g_print_success_message := 'حجوزات لم تحضر: ' || l;", 'end;'], when='apex_application.g_request = \'NOSHOW\'')
ajax_page(p)
p.branch(10, url(5, 'P5_DATE', '&P5_DATE.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 6) المركبات
p = app.page(6, 'Vehicles', 'VEHICLES', 'المركبات', scheme=AUT)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'مركبة جديدة', hot=True, redirect=url(7, clear='RP,7'))
p.ir('المركبات', 10, [
    "select v.id, noona_aut_pkg.plate_label(v.plate_no) as plate_no, v.make, v.model, v.model_year, v.color, v.vin, v.owner_name, v.owner_phone, v.odometer,",
    "       (select name_ar from aut_insurer where id = v.insurer_id) as insurer, v.policy_expiry, v.registration_expiry,",
    "       v.next_service_date, v.next_service_km, to_char(v.last_visit_at, 'YYYY-MM-DD') as last_visit,",
    "       (select count(*) from aut_job_card j where j.vehicle_id = v.id and j.status_code <> 'CANCELLED') as visits,",
    "       (select nvl(sum(total_amount), 0) from aut_job_card j where j.vehicle_id = v.id and j.status_code in ('INVOICED', 'DELIVERED')) as spent",
    "  from aut_vehicle v where v.company_id = noona_aut_pkg.company order by v.last_visit_at desc nulls last, v.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PLATE_NO', 'اللوحة', {}), ('MAKE', 'الشركة', {}), ('MODEL', 'الطراز', {}),
     ('MODEL_YEAR', 'السنة', {'type': 'NUMBER'}), ('COLOR', 'اللون', {}), ('VIN', 'رقم الهيكل', {}), ('OWNER_NAME', 'المالك', {}),
     ('OWNER_PHONE', 'الجوال', {}), ('ODOMETER', 'العداد', {'type': 'NUMBER'}), ('INSURER', 'التأمين', {}),
     ('POLICY_EXPIRY', 'انتهاء التأمين', {'type': 'DATE'}), ('REGISTRATION_EXPIRY', 'انتهاء الاستمارة', {'type': 'DATE'}),
     ('NEXT_SERVICE_DATE', 'الخدمة التالية', {'type': 'DATE'}), ('NEXT_SERVICE_KM', 'عند (كم)', {'type': 'NUMBER'}),
     ('LAST_VISIT', 'آخر زيارة', {}), ('VISITS', 'الزيارات', {'type': 'NUMBER'}), ('SPENT', 'الإنفاق', {'type': 'NUMBER', 'fmt': '999G999G990D00'})],
    link=link(7, 'P7_ID'), titled=True, rows=25)

# =============================================================== 7) بطاقة المركبة
p = app.page(7, 'Vehicle', 'VEHICLE', 'بطاقة المركبة', scheme=AUT, protection='N')
a = p.static('بيانات المركبة', 10)
p.hidden('P7_ID', a, 5, protected=False)
p.text('P7_PLATE', a, 10, 'رقم اللوحة', required=True, maxlen=30, width=15)
p.select('P7_PTYPE', a, 20, 'نوع اللوحة', lov_sql=PTYPE_LOV, null_text=None)
p.text('P7_MAKE', a, 30, 'الشركة المصنعة', required=True, maxlen=100, width=20)
p.text('P7_MODEL', a, 40, 'الطراز', maxlen=100, width=20)
p.number('P7_YEAR', a, 50, 'سنة الصنع')
p.text('P7_COLOR', a, 60, 'اللون', maxlen=50, width=12)
p.text('P7_VIN', a, 70, 'رقم الهيكل (VIN)', maxlen=30, width=22)
p.text('P7_ENGINE', a, 80, 'المحرك', maxlen=100, width=20)
p.select('P7_FUEL', a, 90, 'الوقود', lov_sql=FUELT_LOV)
p.select('P7_TRANS', a, 100, 'ناقل الحركة', lov_sql=TRANS_LOV)
p.number('P7_ODO', a, 110, 'العداد (كم)')
o = p.static('المالك والتأمين', 20)
p.text('P7_OWNER', o, 10, 'اسم المالك', maxlen=200, width=30)
p.text('P7_PHONE', o, 20, 'جوال المالك', maxlen=30, width=15)
p.text('P7_DRIVER', o, 30, 'السائق', maxlen=200, width=25)
p.text('P7_DPHONE', o, 40, 'جوال السائق', maxlen=30, width=15)
p.select('P7_INSURER', o, 50, 'شركة التأمين', lov_sql=INS_LOV)
p.text('P7_POLICY', o, 60, 'رقم الوثيقة', maxlen=50, width=20)
p.date('P7_POLEXP', o, 70, 'انتهاء التأمين')
p.date('P7_REGEXP', o, 80, 'انتهاء الاستمارة')
p.textarea('P7_NOTES', o, 90, 'ملاحظات')
sv = p.static('حفظ', 30, hide_header=True)
b_sv = p.button(sv, 10, 'SAVE', 'حفظ', hot=True)
p.button(sv, 20, 'JOB', 'فتح أمر إصلاح', redirect=url(2, 'P2_VEH', '&P7_ID.', 'RP,2'), condition=':P7_ID is not null')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'declare v aut_vehicle%rowtype;',
    'begin',
    "    :P7_PTYPE := nvl(:P7_PTYPE, 'PRIVATE');",
    '    if :P7_ID is not null and :P7_PLATE is null then',
    '        select * into v from aut_vehicle where id = :P7_ID and company_id = noona_aut_pkg.company;',
    '        :P7_PLATE := noona_aut_pkg.plate_label(v.plate_no); :P7_PTYPE := v.plate_type; :P7_MAKE := v.make; :P7_MODEL := v.model; :P7_YEAR := v.model_year;',
    '        :P7_COLOR := v.color; :P7_VIN := v.vin; :P7_ENGINE := v.engine; :P7_FUEL := v.fuel_type; :P7_TRANS := v.transmission;',
    '        :P7_ODO := v.odometer; :P7_OWNER := v.owner_name; :P7_PHONE := v.owner_phone; :P7_DRIVER := v.driver_name;',
    "        :P7_DPHONE := v.driver_phone; :P7_INSURER := v.insurer_id; :P7_POLICY := v.policy_no;",
    "        :P7_POLEXP := to_char(v.policy_expiry, 'YYYY-MM-DD'); :P7_REGEXP := to_char(v.registration_expiry, 'YYYY-MM-DD'); :P7_NOTES := v.notes;",
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l_o json_object_t := json_object_t();',
    'begin',
    "    l_o.put('id', to_number(:P7_ID)); l_o.put('plate', :P7_PLATE); l_o.put('plateType', :P7_PTYPE); l_o.put('make', :P7_MAKE);",
    "    l_o.put('model', :P7_MODEL); l_o.put('year', to_number(:P7_YEAR)); l_o.put('color', :P7_COLOR); l_o.put('vin', :P7_VIN);",
    "    l_o.put('engine', :P7_ENGINE); l_o.put('fuel', :P7_FUEL); l_o.put('trans', :P7_TRANS); l_o.put('odometer', to_number(:P7_ODO));",
    "    l_o.put('ownerName', :P7_OWNER); l_o.put('ownerPhone', :P7_PHONE); l_o.put('driverName', :P7_DRIVER); l_o.put('driverPhone', :P7_DPHONE);",
    "    l_o.put('insurer', to_number(:P7_INSURER)); l_o.put('policy', :P7_POLICY); l_o.put('policyExpiry', :P7_POLEXP);",
    "    l_o.put('regExpiry', :P7_REGEXP); l_o.put('notes', :P7_NOTES);",
    '    :P7_ID := noona_aut_pkg.save_vehicle(l_o.to_clob);',
    'end;'], when_button=b_sv, success='تم حفظ المركبة')
p.dynamic('سجل الزيارات', 40, 'return noona_aut_pkg.vehicle_html(:P7_ID);', condition=':P7_ID is not null')
ajax_page(p)
p.branch(10, url(7, 'P7_ID', '&P7_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 8) مطالبات التأمين
p = app.page(8, 'Insurance Claims', 'CLAIMS', 'مطالبات التأمين', scheme=AUT, protection='N')
f = p.static('تصفية', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P8_INSURER', f, 10, 'شركة التأمين', lov_sql=INS_LOV, null_text='كل الشركات', submit=True)
p.select('P8_STATUS', f, 20, 'الحالة', lov_sql=CLAIM_LOV, null_text='كل الحالات', submit=True)
p.dynamic('المطالبات', 10, 'return noona_aut_pkg.claims_html(to_number(:P8_INSURER), :P8_STATUS);', opts='#DEFAULT#:t-Region--scrollBody')
ajax_page(p)
p.branch(10, url(8, 'P8_INSURER,P8_STATUS', '&P8_INSURER.,&P8_STATUS.'))

# =============================================================== 9) شركات التأمين
p = app.page(9, 'Insurers', 'INSURERS', 'شركات التأمين', scheme=SETUP)
a = p.static('شركة التأمين', 10)
p.hidden('P9_ID', a, 5, protected=False)
p.text('P9_CODE', a, 10, 'الرمز', required=True, maxlen=30, width=12)
p.text('P9_NAME', a, 20, 'الاسم', required=True, maxlen=200, width=30)
p.number('P9_LDISC', a, 30, 'خصم الخدمات المتفق عليه %')
p.number('P9_PDISC', a, 40, 'خصم القطع المتفق عليه %')
p.number('P9_DED', a, 50, 'تحمل العميل الافتراضي')
p.number('P9_DAYS', a, 60, 'مهلة سداد المطالبات (يوم)')
p.text('P9_CONTACT', a, 70, 'مسؤول التواصل', maxlen=200, width=25)
p.text('P9_PHONE', a, 80, 'الهاتف', maxlen=30, width=15)
p.text('P9_EMAIL', a, 90, 'البريد', maxlen=320, width=25)
b_sv = p.button(a, 10, 'SAVE', 'حفظ', hot=True)
p.button(a, 20, 'NEW', 'جديد', redirect=url(9, clear='RP,9'))
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    if :P9_ID is not null and :P9_CODE is null then',
    '        select code, name_ar, labor_discount_pct, parts_discount_pct, default_deductible, claim_days, contact_name, phone, email',
    '          into :P9_CODE, :P9_NAME, :P9_LDISC, :P9_PDISC, :P9_DED, :P9_DAYS, :P9_CONTACT, :P9_PHONE, :P9_EMAIL',
    '          from aut_insurer where id = :P9_ID and company_id = noona_aut_pkg.company;',
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l_o json_object_t := json_object_t();',
    'begin',
    "    l_o.put('id', to_number(:P9_ID)); l_o.put('code', :P9_CODE); l_o.put('name', :P9_NAME); l_o.put('laborDisc', to_number(:P9_LDISC));",
    "    l_o.put('partsDisc', to_number(:P9_PDISC)); l_o.put('deductible', to_number(:P9_DED)); l_o.put('claimDays', to_number(:P9_DAYS));",
    "    l_o.put('contact', :P9_CONTACT); l_o.put('phone', :P9_PHONE); l_o.put('email', :P9_EMAIL);",
    '    :P9_ID := noona_aut_pkg.save_insurer(l_o.to_clob);',
    'end;'], when_button=b_sv, success='تم الحفظ؛ لشركة التأمين حساب ذمة لمطالباتها')
p.ir('شركات التأمين', 20, [
    "select i.id, i.code, i.name_ar, i.labor_discount_pct, i.parts_discount_pct, i.default_deductible, i.claim_days, i.contact_name, i.phone,",
    "       (select count(*) from aut_job_card j where j.insurer_id = i.id and j.status_code <> 'CANCELLED') as jobs,",
    "       (select nvl(sum(s.total_amount), 0) from aut_job_card j join sal_invoice s on s.id = j.insurer_invoice_id where j.insurer_id = i.id) as invoiced",
    "  from aut_insurer i where i.company_id = noona_aut_pkg.company order by i.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الشركة', {}),
     ('LABOR_DISCOUNT_PCT', 'خصم الخدمات %', {'type': 'NUMBER'}), ('PARTS_DISCOUNT_PCT', 'خصم القطع %', {'type': 'NUMBER'}),
     ('DEFAULT_DEDUCTIBLE', 'التحمل', {'type': 'NUMBER'}), ('CLAIM_DAYS', 'مهلة السداد', {'type': 'NUMBER'}), ('CONTACT_NAME', 'التواصل', {}),
     ('PHONE', 'الهاتف', {}), ('JOBS', 'الأوامر', {'type': 'NUMBER'}), ('INVOICED', 'المفوتر', {'type': 'NUMBER', 'fmt': '999G999G990D00'})],
    link=link(9, 'P9_ID'), titled=True)
p.branch(10, url(9, 'P9_ID', '&P9_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) الخدمات وكروتها
p = app.page(10, 'Services', 'SERVICES', 'الخدمات (الكروت) وقطعها', scheme=SETUP)
c = p.static('فئة جديدة', 5)
p.text('P10_C_CODE', c, 10, 'الرمز', maxlen=30, width=12)
p.text('P10_C_NAME', c, 20, 'الفئة (ميكانيكا، كهرباء، زيوت، إطارات، سمكرة ودهان...)', maxlen=200, width=30)
p.text('P10_C_ICON', c, 30, 'أيقونة Font Awesome (fa-cogs)', maxlen=50, width=15)
p.text('P10_C_COLOR', c, 40, 'لون الكرت (#1565c0)', maxlen=20, width=10)
b_cat = p.button(c, 10, 'ADD_CAT', 'إضافة الفئة')
a = p.static('الخدمة', 10)
p.select('P10_ID', a, 5, 'تعديل خدمة قائمة', lov_sql=SVC_LOV, null_text='- خدمة جديدة -', submit=True)
p.text('P10_CODE', a, 10, 'الرمز', maxlen=30, width=12)
p.text('P10_NAME', a, 20, 'اسم الخدمة', maxlen=200, width=30)
p.select('P10_CAT', a, 30, 'الفئة', lov_sql=CAT_LOV, null_text=None)
p.number('P10_PRICE', a, 40, 'السعر')
p.yesno('P10_INC', a, 50, 'السعر شامل الضريبة')
p.number('P10_MIN', a, 60, 'الوقت القياسي (دقيقة)')
p.number('P10_WDAYS', a, 70, 'ضمان العمل (يوم)')
p.number('P10_NDAYS', a, 80, 'الخدمة التالية بعد (يوم)')
p.number('P10_NKM', a, 90, 'الخدمة التالية بعد (كم)')
p.text('P10_ICON', a, 100, 'أيقونة الكرت (fa-tint)', maxlen=50, width=15)
p.number('P10_SORT', a, 110, 'الترتيب')
p.select('P10_ACTIVE', a, 120, 'الحالة', lov_sql=STATUS_LOV, null_text=None)
b_svc = p.button(a, 10, 'SAVE', 'حفظ الخدمة', hot=True)
pp = p.static('القطع الافتراضية للخدمة', 15, condition=':P10_ID is not null',
              text='<p class="nn-hint">تضاف القطع الإلزامية تلقائياً مع الخدمة في أمر الإصلاح وتصرف من المخزون مع الفاتورة؛ '
                   'الاختيارية تقترح فقط.</p>')
p.select('P10_P_ITEM', pp, 10, 'القطعة', lov_sql=PART_LOV)
p.number('P10_P_QTY', pp, 20, 'الكمية')
p.yesno('P10_P_OPT', pp, 30, 'اختيارية')
b_padd = p.button(pp, 10, 'ADD_PART', 'إضافة / تعديل القطعة')
b_pdel = p.button(pp, 20, 'DEL_PART', 'حذف القطعة')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    "    :P10_INC := nvl(:P10_INC, 'N'); :P10_ACTIVE := nvl(:P10_ACTIVE, 'Y'); :P10_P_QTY := nvl(:P10_P_QTY, 1); :P10_P_OPT := nvl(:P10_P_OPT, 'N');",
    '    if :P10_ID is not null then',
    '        select code, name_ar, category_id, price, price_includes_tax, standard_minutes, warranty_days, next_service_days, next_service_km,',
    '               icon, sort_order, is_active',
    '          into :P10_CODE, :P10_NAME, :P10_CAT, :P10_PRICE, :P10_INC, :P10_MIN, :P10_WDAYS, :P10_NDAYS, :P10_NKM, :P10_ICON, :P10_SORT, :P10_ACTIVE',
    '          from aut_service where id = :P10_ID and company_id = noona_aut_pkg.company;',
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
SVC_DOC = ["    l_o.put('id', to_number(:P10_ID)); l_o.put('code', :P10_CODE); l_o.put('name', :P10_NAME); l_o.put('cat', to_number(:P10_CAT));",
           "    l_o.put('price', to_number(:P10_PRICE)); l_o.put('inc', :P10_INC); l_o.put('minutes', to_number(:P10_MIN));",
           "    l_o.put('warrantyDays', to_number(:P10_WDAYS)); l_o.put('nextDays', to_number(:P10_NDAYS)); l_o.put('nextKm', to_number(:P10_NKM));",
           "    l_o.put('icon', :P10_ICON); l_o.put('sort', to_number(:P10_SORT)); l_o.put('active', :P10_ACTIVE);"]
p.process(10, 'AFTER_SUBMIT', 'Category', ['declare l_o json_object_t := json_object_t(); l number;', 'begin',
          "    l_o.put('code', :P10_C_CODE); l_o.put('name', :P10_C_NAME); l_o.put('icon', :P10_C_ICON); l_o.put('color', :P10_C_COLOR);",
          '    l := noona_aut_pkg.save_category(l_o.to_clob); :P10_CAT := l;', 'end;'], when_button=b_cat, success='تمت إضافة الفئة')
p.process(20, 'AFTER_SUBMIT', 'Service', ['declare l_o json_object_t := json_object_t();', 'begin'] + SVC_DOC
          + ['    :P10_ID := noona_aut_pkg.save_service(l_o.to_clob);', 'end;'], when_button=b_svc, success='تم حفظ الخدمة')
# تعديل قائمة القطع يعيد إرسال القائمة كاملة (parts) مع بيانات الخدمة
PARTS = ['declare',
         '    l_o json_object_t := json_object_t();',
         '    l_a json_array_t := json_array_t();',
         '    l_p json_object_t;',
         'begin'] + SVC_DOC + [
         '    for x in (select item_id, quantity, is_optional from aut_service_part where service_id = to_number(:P10_ID)',
         '               and item_id <> nvl(to_number(:P10_P_ITEM), -1) order by id) loop',
         "        l_p := json_object_t(); l_p.put('item', x.item_id); l_p.put('qty', x.quantity); l_p.put('optional', x.is_optional); l_a.append(l_p);",
         '    end loop;',
         "    if :REQUEST = 'ADD_PART' and :P10_P_ITEM is not null then",
         "        l_p := json_object_t(); l_p.put('item', to_number(:P10_P_ITEM)); l_p.put('qty', to_number(:P10_P_QTY)); l_p.put('optional', :P10_P_OPT);",
         '        l_a.append(l_p);',
         '    end if;',
         "    l_o.put('parts', l_a);",
         '    :P10_ID := noona_aut_pkg.save_service(l_o.to_clob); :P10_P_ITEM := null;',
         'end;']
p.process(30, 'AFTER_SUBMIT', 'Part Add', PARTS, when_button=b_padd, success='تم تحديث قطع الخدمة')
p.process(40, 'AFTER_SUBMIT', 'Part Remove', PARTS, when_button=b_pdel, success='تم حذف القطعة من الخدمة')
p.ir('قطع الخدمة', 16, [
    "select sp.id, i.item_no, i.name_ar, i.manufacturer_part_no, sp.quantity, case sp.is_optional when 'Y' then 'اختيارية' else 'إلزامية' end as opt,",
    "       c.sale_price, noona_inv_pkg.on_hand(i.id, noona_aut_pkg.default_warehouse) as on_hand",
    "  from aut_service_part sp join inv_item i on i.id = sp.item_id left join inv_item_company c on c.item_id = i.id and c.company_id = noona_aut_pkg.company",
    " where sp.service_id = to_number(:P10_ID) order by sp.id"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ITEM_NO', 'رقم الصنف', {}), ('NAME_AR', 'القطعة', {}), ('MANUFACTURER_PART_NO', 'رقم القطعة', {}),
     ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('OPT', 'النوع', {}), ('SALE_PRICE', 'السعر', {'type': 'NUMBER', 'fmt': '999G999G990D00'}),
     ('ON_HAND', 'المتوفر', {'type': 'NUMBER'})], titled=True, rows=20)
p.ir('الخدمات', 20, [
    "select s.id, g.name_ar as cat, s.code, s.name_ar, s.price, case s.price_includes_tax when 'Y' then 'شامل' else 'غير شامل' end as inc,",
    "       s.standard_minutes, s.next_service_days, s.next_service_km,",
    "       (select count(*) from aut_service_part p where p.service_id = s.id) as parts, case s.is_active when 'Y' then 'نشطة' else 'موقوفة' end as status",
    "  from aut_service s join aut_service_category g on g.id = s.category_id where s.company_id = noona_aut_pkg.company",
    " order by g.sort_order nulls last, g.name_ar, s.sort_order nulls last, s.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CAT', 'الفئة', {}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الخدمة', {}),
     ('PRICE', 'السعر', {'type': 'NUMBER', 'fmt': '999G999G990D00'}), ('INC', 'الضريبة', {}), ('STANDARD_MINUTES', 'الدقائق', {'type': 'NUMBER'}),
     ('NEXT_SERVICE_DAYS', 'التالية (يوم)', {'type': 'NUMBER'}), ('NEXT_SERVICE_KM', 'التالية (كم)', {'type': 'NUMBER'}),
     ('PARTS', 'القطع', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], link=link(10, 'P10_ID'), titled=True)
p.branch(10, url(10, 'P10_ID', '&P10_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 11) الرافعات والفنيون
p = app.page(11, 'Bays & Technicians', 'BAYS-TECHNICIANS', 'الرافعات والفنيون', scheme=SETUP)
bb = p.static('رافعة / موقع عمل', 10)
p.text('P11_B_CODE', bb, 10, 'الرمز', maxlen=30, width=10)
p.text('P11_B_NAME', bb, 20, 'الاسم', maxlen=200, width=25)
p.select('P11_B_TYPE', bb, 30, 'النوع', lov_sql=BAYTYPE_LOV, null_text=None)
p.number('P11_B_SORT', bb, 40, 'الترتيب')
b_bay = p.button(bb, 10, 'ADD_BAY', 'إضافة')
tt = p.static('فني', 20)
p.hidden('P11_T_ID', tt, 5, protected=False)
p.text('P11_T_CODE', tt, 10, 'الرمز', maxlen=30, width=10)
p.text('P11_T_NAME', tt, 20, 'الاسم', maxlen=200, width=25)
p.select('P11_T_EMP', tt, 30, 'الموظف من الموارد البشرية', lov_sql=EMP_LOV)
p.select('P11_T_PAYM', tt, 72, 'صرف العمولة', lov_sql='STATIC2:مع الراتب (مسير الرواتب);PAYROLL,نقداً (سند صرف);CASH,تحويل بنكي (سند صرف);BANK_TRANSFER,لا يستحق عمولة;NONE',
         null_text=None)
p.text('P11_T_SPEC', tt, 40, 'التخصص', maxlen=200, width=25)
p.text('P11_T_PHONE', tt, 50, 'الجوال', maxlen=30, width=15)
p.number('P11_T_COST', tt, 60, 'تكلفة الساعة')
p.number('P11_T_COMM', tt, 70, 'عمولة من الخدمات %')
p.select('P11_T_USER', tt, 75, 'مستخدم النظام (شاشة الفني على الهاتف)', lov_sql=(
    "select nvl(u.display_name, u.username) || ' (' || u.username || ')' d, upper(u.username) r "
    "from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = 'ACTIVE' order by 1"))
p.select('P11_T_ACTIVE', tt, 80, 'الحالة', lov_sql=STATUS_LOV, null_text=None)
b_tech = p.button(tt, 10, 'SAVE_TECH', 'حفظ الفني', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    "    :P11_B_TYPE := nvl(:P11_B_TYPE, 'LIFT'); :P11_T_ACTIVE := nvl(:P11_T_ACTIVE, 'Y');",
    '    if :P11_T_ID is not null and :P11_T_CODE is null then',
    '        select code, name_ar, employee_id, specialty, phone, hourly_cost, commission_pct, is_active, user_name, earnings_method',
    '          into :P11_T_CODE, :P11_T_NAME, :P11_T_EMP, :P11_T_SPEC, :P11_T_PHONE, :P11_T_COST, :P11_T_COMM, :P11_T_ACTIVE, :P11_T_USER, :P11_T_PAYM',
    '          from aut_technician where id = :P11_T_ID and company_id = noona_aut_pkg.company;',
    '    end if;',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Bay', ['declare l_o json_object_t := json_object_t(); l number;', 'begin',
          "    l_o.put('code', :P11_B_CODE); l_o.put('name', :P11_B_NAME); l_o.put('type', :P11_B_TYPE); l_o.put('sort', to_number(:P11_B_SORT));",
          '    l := noona_aut_pkg.save_bay(l_o.to_clob);', "    :P11_B_CODE := null; :P11_B_NAME := null;", 'end;'], when_button=b_bay, success='تمت الإضافة')
p.process(20, 'AFTER_SUBMIT', 'Technician', ['declare l_o json_object_t := json_object_t();', 'begin',
          '    if :P11_T_EMP is not null then',
          "      for e in (select * from json_table(noona_wrk_pkg.employee_json(to_number(:P11_T_EMP)), '$' columns (n varchar2(400) path '$.name', ph varchar2(40) path '$.phone'))) loop",
          '        :P11_T_NAME := nvl(:P11_T_NAME, e.n); :P11_T_PHONE := nvl(:P11_T_PHONE, e.ph);',
          '      end loop;',
          '    end if;',
          "    l_o.put('id', to_number(:P11_T_ID)); l_o.put('code', :P11_T_CODE); l_o.put('name', :P11_T_NAME); l_o.put('employee', to_number(:P11_T_EMP));",
          "    l_o.put('specialty', :P11_T_SPEC); l_o.put('phone', :P11_T_PHONE); l_o.put('hourly', to_number(:P11_T_COST));",
          "    l_o.put('commission', to_number(:P11_T_COMM)); l_o.put('active', :P11_T_ACTIVE);",
          '    :P11_T_ID := noona_aut_pkg.save_technician(l_o.to_clob);',
          '    noona_aut_pkg.set_technician_user(:P11_T_ID, :P11_T_USER);',
          "    noona_wrk_pkg.set_worker('TECH', :P11_T_ID, to_number(:P11_T_EMP), nvl(:P11_T_PAYM, 'PAYROLL'));", 'end;'], when_button=b_tech, success='تم حفظ الفني')
p.ir('الرافعات ومواقع العمل', 30, [
    "select b.id, b.code, b.name_ar, b.bay_type, b.sort_order,",
    "       (select max(j.doc_no) from aut_job_card j where j.bay_id = b.id and j.status_code in ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS')) as busy_with",
    "  from aut_bay b where b.company_id = noona_aut_pkg.company order by b.sort_order nulls last, b.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الاسم', {}), ('BAY_TYPE', 'النوع', {}),
     ('SORT_ORDER', 'الترتيب', {'type': 'NUMBER'}), ('BUSY_WITH', 'مشغولة بالأمر', {})], titled=True)
p.ir('الفنيون', 40, [
    "select t.id, t.code, t.name_ar, t.specialty, t.phone, t.hourly_cost, t.commission_pct,",
    "       (select count(*) from aut_job_line l join aut_job_card j on j.id = l.job_card_id where l.technician_id = t.id",
    "           and l.line_status = 'IN_PROGRESS') as working_now,",
    "       case t.is_active when 'Y' then 'نشط' else 'موقوف' end as status",
    "  from aut_technician t where t.company_id = noona_aut_pkg.company order by t.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفني', {}), ('SPECIALTY', 'التخصص', {}),
     ('PHONE', 'الجوال', {}), ('HOURLY_COST', 'تكلفة الساعة', {'type': 'NUMBER'}), ('COMMISSION_PCT', 'العمولة %', {'type': 'NUMBER'}),
     ('WORKING_NOW', 'بنود قيد العمل', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], link=link(11, 'P11_T_ID'), titled=True)
p.branch(10, url(11) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 12) التقارير
p = app.page(12, 'Reports', 'REPORTS', 'تقارير مركز الخدمة', scheme=AUT, protection='N')
f = p.static('التقرير', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P12_KIND', f, 10, 'التقرير', lov_sql=KIND_LOV, null_text=None, submit=True)
p.select('P12_PERIOD', f, 20, 'الفترة', lov_sql='STATIC2:مخصصة;CUSTOM,اليوم;TODAY,هذا الشهر;MONTH,الشهر السابق;LAST_MONTH,هذه السنة;YEAR', null_text=None, submit=True)
p.date('P12_FROM', f, 30, 'من')
p.date('P12_TO', f, 40, 'إلى')
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "    :P12_KIND := nvl(:P12_KIND, 'SUMMARY'); :P12_PERIOD := nvl(:P12_PERIOD, 'MONTH');",
    "    :P12_FROM := nvl(:P12_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD')); :P12_TO := nvl(:P12_TO, to_char(sysdate, 'YYYY-MM-DD'));",
    'end;'])
p.dynamic('التقرير', 20, "return noona_aut_pkg.report_html(:P12_KIND, to_date(:P12_FROM, 'YYYY-MM-DD'), to_date(:P12_TO, 'YYYY-MM-DD'));",
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
# اختيار الفترة يحسب التاريخين؛ تعديل التاريخين يدوياً ثم «عرض» يبقيهما
p.process(10, 'AFTER_SUBMIT', 'Period', [
    'begin',
    '    case :P12_PERIOD',
    "        when 'TODAY' then :P12_FROM := to_char(sysdate, 'YYYY-MM-DD'); :P12_TO := :P12_FROM;",
    "        when 'MONTH' then :P12_FROM := to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'); :P12_TO := to_char(sysdate, 'YYYY-MM-DD');",
    "        when 'LAST_MONTH' then :P12_FROM := to_char(add_months(trunc(sysdate, 'MM'), -1), 'YYYY-MM-DD');",
    "            :P12_TO := to_char(trunc(sysdate, 'MM') - 1, 'YYYY-MM-DD');",
    "        when 'YEAR' then :P12_FROM := to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'); :P12_TO := to_char(sysdate, 'YYYY-MM-DD');",
    '        else null;',
    '    end case;',
    "    if :P12_KIND = 'DUE' then :P12_TO := to_char(greatest(to_date(:P12_TO, 'YYYY-MM-DD'), sysdate + 30), 'YYYY-MM-DD'); end if;",
    "end;"], when=":REQUEST in ('P12_PERIOD', 'P12_KIND')")
p.branch(10, url(12, 'P12_KIND,P12_PERIOD,P12_FROM,P12_TO', '&P12_KIND.,&P12_PERIOD.,&P12_FROM.,&P12_TO.'))

# =============================================================== 70) مهامي (الفني على الهاتف)
p = app.page(70, 'My Tasks', 'MY-TASKS', 'مهامي', scheme=AUT, protection='N')
h = p.static('المهام', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P70_LINE', h, 1, protected=False)
p.dynamic('مهامي', 10, 'return noona_aut_pkg.tech_tasks_html(noona_aut_pkg.my_technician);', hide_header=True)
p.process(10, 'AFTER_SUBMIT', 'Start', "noona_aut_pkg.line_action(to_number(:P70_LINE), 'START');", when=":REQUEST = 'LINE_START'", success='بدأ العمل على البند')
p.process(20, 'AFTER_SUBMIT', 'Done', "noona_aut_pkg.line_action(to_number(:P70_LINE), 'DONE');", when=":REQUEST = 'LINE_DONE'", success='تم إنجاز البند')
p.onload(["document.addEventListener('click', function (e) {",
          "  var b = e.target.closest('[data-line][data-req]'); if (!b) return;",
          "  b.disabled = true; apex.submit({ request: b.getAttribute('data-req'), set: { P70_LINE: b.getAttribute('data-line') } });",
          "});"])
p.branch(10, url(70) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== القائمة
app.nav_item('لوحة الورشة', 1, 'fa-dashboard', 10)
app.nav_item('مهامي (الفني)', 70, 'fa-mobile', 15)
app.nav_item('استلام سيارة', url(2, clear='RP,2'), 'fa-sign-in', 20)
app.nav_item('أوامر الإصلاح', 4, 'fa-list', 30)
app.nav_item('الحجوزات', 5, 'fa-calendar', 40)
app.nav_item('المركبات', 6, 'fa-car', 50)
app.nav_item('مطالبات التأمين', 8, 'fa-shield', 60)
app.nav_item('التقارير', 12, 'fa-bar-chart', 70)
st = app.nav_item('الإعداد', None, 'fa-cogs', 80, scheme=SETUP)
app.nav_item('الخدمات وقطعها', 10, 'fa-th-large', 1, parent=st, scheme=SETUP)
app.nav_item('الرافعات والفنيون', 11, 'fa-users', 2, parent=st, scheme=SETUP)
app.nav_item('شركات التأمين', 9, 'fa-building', 3, parent=st, scheme=SETUP)

# التسعير والعروض والباقات لخدمات السيارات وقطعها (20-24)
import prc_pages
prc_pages.build(app, url, SETUP, 20, ('AUT', 'ITEMS'), 'AUT')
prc_pages.nav(app, 20, 75)

# التحليلات والتنبؤ (NOONA_ANL_PKG + anl.js)
import anl_pages
anl_pages.add(app, ['AUT'], AUT, 11)

app.finalize()
print('NOONA_AUTO built:', len(app.pages), 'pages')
