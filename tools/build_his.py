"""NOONA_HIS (المستشفيات والمراكز الطبية): الاستقبال وتسجيل المرضى، لوحة المواعيد والحجز بساعات عمل الأطباء، الزيارات وطلبات
الطبيب (كشوف، تحاليل، أشعة وموجات، رسم وإيكو القلب، إجراءات وعمليات، علاج طبيعي، تنويم)، موافقات التأمين، المحاسبة (حصة المريض
وحصة الجهة)، قوائم عمل الأقسام (كل معمل ووحدة أشعة منفصلة) وإدخال النتائج وصرف المواد، الإعداد (الأقسام، الخدمات ومواردها،
الأطباء وساعاتهم، شركات التأمين والجهات المتعاقدة وفئاتها وأسعارها)، والتقارير والمطالبات.
الاستخدام: python3 tools/build_his.py  ->  apex/NOONA_HIS/f141
المنطق في NOONA_HIS_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_HIS/f141'),
          app_id=141, alias='NOONA_HIS', name='NOONA Hospital & Clinics', id_base=91820275000000000)
app.wire_security()
app.add_branding()
HIS = app.add_scheme('noona_his_view', app.id(), 'NOONA - Hospital',
                     "return noona_security_pkg.has_permission('HIS_VISIT.VIEW', noona_his_pkg.company) = 'Y';",
                     'صفحات المستشفى تتطلب صلاحية عرض الزيارات / Hospital access required')


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


def build_json(fields):
    parts = []
    for k, item, kind in fields:
        v = f'to_number(:{item})' if kind == 'n' else f':{item}'
        parts.append(f"'{k}' value {v}")
    return 'json_object(' + ', '.join(parts) + ' returning clob)'


READY = "noona_his_pkg.is_ready = 'Y'"
CO = 'noona_his_pkg.company'
PATIENT_LOV = (f"select name_ar || ' - ' || mrn || nvl2(mobile, ' - ' || mobile, '') d, id r from his_patient where company_id = {CO} "
               "and status_code = 'ACTIVE' order by name_ar")
DOCTOR_LOV = (f"select d.name_ar || ' - ' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id "
              f"where d.company_id = {CO} and d.status_code = 'ACTIVE' order by p.sort_order, p.name_ar, d.name_ar")
DEPT_LOV = f"select name_ar d, id r from his_department where company_id = {CO} and status_code = 'ACTIVE' order by sort_order, name_ar"
WORK_DEPT_LOV = (f"select name_ar d, id r from his_department where company_id = {CO} and status_code = 'ACTIVE' "
                 "and dept_type not in ('CLINIC', 'EMERGENCY') order by dept_type, name_ar")
SERVICE_LOV = (f"select noona_his_pkg.service_name(s.id) || ' (' || noona_his_pkg.type_label(s.service_type) || ' - ' || to_char(s.price, 'FM999G990D00') || ')' d, s.id r "
               f"from his_service s where s.company_id = {CO} and s.status_code = 'ACTIVE' order by s.service_type, s.name_ar")
PLAN_LOV = (f"select y.name_ar || ' - ' || p.name_ar || ' (المريض ' || p.patient_share_pct || '%)' d, p.id r from his_payer_plan p "
            f"join his_payer y on y.id = p.payer_id where p.company_id = {CO} and p.is_active = 'Y' and y.status_code = 'ACTIVE' order by y.name_ar, p.code")
PAYER_LOV = f"select name_ar d, id r from his_payer where company_id = {CO} order by name_ar"
COUNTRY_LOV = "select name_ar d, country_code r from ref_country order by case country_code when 'SA' then 0 else 1 end, name_ar"
METHOD_LOV = "select name_ar d, code r from ref_payment_method where is_active = 'Y' order by sort_order"
PLACE_LOV = (f"select d, r from (select 'صندوق: ' || name_ar d, 'BOX:' || id r, 1 o from csh_cash_box where company_id = {CO} "
             f"and status_code = 'ACTIVE' union all select 'بنك: ' || name_ar, 'BANK:' || id, 2 from csh_bank_account where company_id = {CO} "
             "and status_code = 'ACTIVE') order by o, d")
ITEM_LOV = ("select i.name_ar || ' (' || u.name_ar || ')' d, i.id r from inv_item i join inv_uom u on u.id = i.base_uom_id "
            "where i.item_type not in ('SERVICE', 'NON_STOCK') and i.status_code = 'ACTIVE' order by i.name_ar")
DEPT_TYPE_LOV = ('STATIC2:عيادة;CLINIC,طوارئ;EMERGENCY,معمل;LAB,أشعة وموجات;RADIOLOGY,تشخيص القلب;CARDIO_DIAG,صيدلية داخلية;PHARMACY,'
                 'جناح تنويم;INPATIENT_WARD,غرف العمليات;OPERATING_THEATER,علاج طبيعي;PHYSIOTHERAPY,وحدة علاجية;THERAPY_UNIT,أسنان;DENTAL,'
                 'غسيل كلوي;DIALYSIS,تمريض;NURSING,أخرى;OTHER')
SRV_TYPE_LOV = ('STATIC2:كشف;CONSULTATION,مراجعة;FOLLOW_UP,طوارئ;EMERGENCY,تحليل مخبري;LAB,أشعة وموجات;RADIOLOGY,تشخيص القلب;CARDIO_DIAG,'
                'إجراء طبي;PROCEDURE,عملية صغرى;MINOR_SURGERY,عملية كبرى;MAJOR_SURGERY,علاج طبيعي;PHYSIOTHERAPY,جلسة علاجية;THERAPY,'
                'خدمة تمريضية;NURSING,أسنان;DENTAL,تنويم (يوم سرير);BED,دواء ومستلزمات;MEDICATION,باقة;PACKAGE,أخرى;OTHER')
MODALITY_LOV = ('STATIC2:أشعة سينية;XRAY,أشعة مقطعية;CT,رنين مغناطيسي;MRI,موجات صوتية;ULTRASOUND,دوبلر;DOPPLER,ماموجرام;MAMMOGRAPHY,'
                'أشعة بالصبغة;FLUOROSCOPY,هشاشة العظام;DEXA,طب نووي;NUCLEAR,مسح PET;PET,رسم قلب;ECG,إيكو القلب;ECHO,جهد;STRESS_TEST,'
                'هولتر;HOLTER,رسم مخ;EEG,رسم عصب وعضلات;EMG,مناظير;ENDOSCOPY')
SAMPLE_LOV = 'STATIC2:دم;BLOOD,مصل;SERUM,بلازما;PLASMA,بول;URINE,براز;STOOL,مسحة;SWAB,سائل شوكي;CSF,نسيج;TISSUE,بلغم;SPUTUM,أخرى;OTHER'
TITLE_LOV = ('STATIC2:استشاري;CONSULTANT,أخصائي;SPECIALIST,مقيم;RESIDENT,طبيب عام;GP,طبيب أسنان;DENTIST,جراح;SURGEON,طبيب تخدير;ANESTHETIST,'
             'أخصائي أشعة;RADIOLOGIST,أخصائي مختبر;PATHOLOGIST,أخصائي علاج طبيعي;PHYSIOTHERAPIST,فني;TECHNICIAN,ممرض;NURSE,صيدلي;PHARMACIST')
DAY_LOV = 'STATIC2:الأحد;1,الاثنين;2,الثلاثاء;3,الأربعاء;4,الخميس;5,الجمعة;6,السبت;7'
PAYER_TYPE_LOV = 'STATIC2:شركة تأمين;INSURANCE,إدارة مطالبات TPA;TPA,شركة متعاقدة;CORPORATE,جهة حكومية;GOVERNMENT,جمعية خيرية;CHARITY'
VISIT_TYPE_LOV = 'STATIC2:عيادات خارجية;OUTPATIENT,طوارئ;EMERGENCY,تنويم;INPATIENT,إقامة يوم واحد;DAY_CASE,تحويل من جهة;REFERRAL_IN'
STATUS_LOV = 'STATIC2:نشط;ACTIVE,موقوف;INACTIVE'
FLAG_LOV = 'STATIC2:طبيعية;NORMAL,غير طبيعية;ABNORMAL,قيمة حرجة;CRITICAL'
CHANNEL_LOV = 'STATIC2:هاتف;PHONE,حضوري;WALK_IN,الموقع;WEB,التطبيق;APP,تحويل;REFERRAL'
BLOOD_LOV = 'STATIC2:A+;A+,A-;A-,B+;B+,B-;B-,AB+;AB+,AB-;AB-,O+;O+,O-;O-'
ID_TYPE_LOV = 'STATIC2:هوية وطنية;NATIONAL_ID,إقامة;IQAMA,جواز سفر;PASSPORT,رقم حدود;BORDER_NO,شهادة ميلاد;BIRTH_CERT'


def get_url(page, item):
    return f"replace(apex_page.get_url(p_page => {page}, p_items => '{item}', p_values => '990000000001'), '990000000001', '#ID#')"


# =============================================================== 1) اللوحة
p = app.page(1, 'Home', 'HOME', 'المستشفى', scheme=HIS)
st = p.static('تجهيز المستشفى', 5, condition="noona_his_pkg.is_ready = 'N'",
              text='<p class="nn-hint">ينشئ حسابات الإيرادات الطبية (4120-4127) وذمم شركات التأمين (1114) والمرضى (1115) والترقيم، '
                   'وأقساماً نموذجية: عيادات، طوارئ، خمسة معامل منفصلة بمستودعاتها، أشعة عادية ومقطعية ورنين وموجات، تشخيص القلب، '
                   'علاج طبيعي، غسيل كلوي، عمليات، تنويم، صيدلية داخلية، ودليل خدمات بأسعار مبدئية قابلة للتعديل.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز المستشفى', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_his_pkg.seed_catalog;', 'end;'], when_button=b,
          success='تم تجهيز المستشفى: الحسابات والأقسام ودليل الخدمات')
p.dynamic('اليوم', 10, 'return noona_his_pkg.summary_html;', hide_header=True, condition=READY)
qa = p.static('إجراءات سريعة', 15, condition=READY)
p.button(qa, 10, 'NEW_PAT', 'مريض جديد', hot=True, redirect=url(11, clear='RP,11'))
p.button(qa, 20, 'BOOK', 'حجز موعد', redirect=url(21, clear='RP,21'))
p.button(qa, 30, 'BOARD', 'لوحة المواعيد', redirect=url(20))
p.button(qa, 40, 'NEW_VISIT', 'زيارة جديدة (حضور مباشر)', redirect=url(32, clear='RP,32'))
p.button(qa, 50, 'CASHIER', 'المحاسبة', redirect=url(40))
p.button(qa, 60, 'WORK', 'قوائم المعامل والأشعة', redirect=url(50))
p.ir('مواعيد اليوم', 20, [
    "select a.id, a.start_time, p.name_ar as patient, p.mrn, p.mobile, d.name_ar as doctor, dp.name_ar as dept,",
    "       noona_his_pkg.appt_status_label(a.status_code) as status",
    "  from his_appointment a join his_patient p on p.id = a.patient_id left join his_doctor d on d.id = a.doctor_id",
    "  join his_department dp on dp.id = a.department_id",
    f" where a.company_id = {CO} and a.appt_date = trunc(sysdate) and a.status_code <> 'CANCELLED' order by a.start_time"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('START_TIME', 'الوقت', {}), ('PATIENT', 'المريض', {}), ('MRN', 'الرقم الطبي', {}),
     ('MOBILE', 'الجوال', {}), ('DOCTOR', 'الطبيب', {}), ('DEPT', 'العيادة', {}), ('STATUS', 'الحالة', {})],
    link=link(22, 'P22_ID'), titled=True, rows=20)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) المرضى
p = app.page(10, 'Patients', 'PATIENTS', 'المرضى', scheme=HIS)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'مريض جديد', hot=True, redirect=url(11, clear='RP,11'))
p.ir('المرضى', 10, [
    "select p.id, p.mrn, p.name_ar, case p.gender when 'M' then 'ذكر' else 'أنثى' end as gender,",
    "       trunc(months_between(sysdate, p.birth_date) / 12) as age, p.id_no, p.mobile, p.nationality,",
    "       (select y.name_ar || ' - ' || pl.name_ar from his_payer_plan pl join his_payer y on y.id = pl.payer_id where pl.id = p.payer_plan_id) as payer,",
    "       p.insurance_expiry, (select max(v.visit_at) from his_visit v where v.patient_id = p.id) as last_visit,",
    "       '<span class=\"fa fa-folder-open-o\" aria-hidden=\"true\"></span> السجل' as emr",
    f"  from his_patient p where p.company_id = {CO} and p.status_code = 'ACTIVE' order by p.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('MRN', 'الرقم الطبي', {}), ('NAME_AR', 'الاسم', {}), ('GENDER', 'الجنس', {}),
     ('AGE', 'العمر', {'type': 'NUMBER'}), ('ID_NO', 'الهوية', {}), ('MOBILE', 'الجوال', {}), ('NATIONALITY', 'الجنسية', {}),
     ('PAYER', 'التأمين/الجهة (اختياري)', {}), ('INSURANCE_EXPIRY', 'انتهاء التأمين', {'type': 'DATE'}), ('LAST_VISIT', 'آخر زيارة', {'type': 'DATE'}),
     ('EMR', 'الملف الطبي', {'html': True, 'link': ('f?p=&APP_ID.:12:&SESSION.::&DEBUG.:RP,12:P12_ID:#ID#', '#EMR#')})],
    link=link(11, 'P11_ID'))

# =============================================================== 11) بيانات المريض
p = app.page(11, 'Patient', 'PATIENT', 'بيانات المريض', scheme=HIS, protection='N')
f = p.static('بيانات المريض', 10)
p.hidden('P11_ID', f, 1, protected=False)
p.text('P11_MRN', f, 5, 'الرقم الطبي (تلقائي)', maxlen=30, width=15)
p.text('P11_NAME', f, 10, 'الاسم', required=True)
p.text('P11_NAME_EN', f, 15, 'الاسم بالإنجليزية')
p.select('P11_GENDER', f, 20, 'الجنس', lov_sql='STATIC2:ذكر;M,أنثى;F', null_text=None)
p.date('P11_BIRTH', f, 25, 'تاريخ الميلاد')
p.select('P11_ID_TYPE', f, 30, 'نوع الهوية', lov_sql=ID_TYPE_LOV)
p.text('P11_ID_NO', f, 35, 'رقم الهوية', maxlen=30, width=20)
p.select('P11_NAT', f, 40, 'الجنسية (السعودي معفى من الضريبة)', lov_sql=COUNTRY_LOV, null_text='- اختر -')
p.text('P11_MOBILE', f, 45, 'الجوال', maxlen=30, width=20)
p.select('P11_BLOOD', f, 50, 'فصيلة الدم', lov_sql=BLOOD_LOV)
p.text('P11_EMERG', f, 55, 'جهة الاتصال للطوارئ')
p.textarea('P11_ALLERGY', f, 60, 'الحساسية')
p.textarea('P11_CHRONIC', f, 65, 'الأمراض المزمنة')
p.text('P11_ADDRESS', f, 70, 'العنوان', maxlen=500)
fi = p.static('التأمين أو الجهة المتعاقدة', 20)
p.select('P11_PLAN', fi, 10, 'الجهة وفئة التغطية (فارغ = نقدي)', lov_sql=PLAN_LOV, null_text='- نقدي -')
p.text('P11_MEMBER', fi, 20, 'رقم العضوية', maxlen=50, width=20)
p.text('P11_POLICY', fi, 30, 'رقم الوثيقة', maxlen=50, width=20)
p.date('P11_INS_EXP', fi, 40, 'انتهاء التأمين')
b_save = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.button(f, 20, 'BOOK', 'حجز موعد', redirect=url(21, 'P21_PATIENT', '&P11_ID.', 'RP,21'), condition=':P11_ID is not null')
p.button(f, 30, 'VISIT', 'فتح زيارة', redirect=url(32, 'P32_PATIENT', '&P11_ID.', 'RP,32'), condition=':P11_ID is not null')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '    select mrn, name_ar, name_en, gender, to_char(birth_date, \'YYYY-MM-DD\'), id_type, id_no, nationality, mobile, blood_group, emergency_contact,',
    "           allergies, chronic_diseases, address, payer_plan_id, member_no, policy_no, to_char(insurance_expiry, 'YYYY-MM-DD')",
    '      into :P11_MRN, :P11_NAME, :P11_NAME_EN, :P11_GENDER, :P11_BIRTH, :P11_ID_TYPE, :P11_ID_NO, :P11_NAT, :P11_MOBILE, :P11_BLOOD, :P11_EMERG,',
    '           :P11_ALLERGY, :P11_CHRONIC, :P11_ADDRESS, :P11_PLAN, :P11_MEMBER, :P11_POLICY, :P11_INS_EXP',
    f'      from his_patient where id = :P11_ID and company_id = {CO};',
    'exception when no_data_found then null;',
    'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('id', 'P11_ID', 'n'), ('name', 'P11_NAME', 's'), ('name_en', 'P11_NAME_EN', 's'), ('gender', 'P11_GENDER', 's'), ('birth', 'P11_BIRTH', 's'),
    ('id_type', 'P11_ID_TYPE', 's'), ('id_no', 'P11_ID_NO', 's'), ('nationality', 'P11_NAT', 's'), ('mobile', 'P11_MOBILE', 's'),
    ('blood', 'P11_BLOOD', 's'), ('allergies', 'P11_ALLERGY', 's'), ('chronic', 'P11_CHRONIC', 's'), ('plan', 'P11_PLAN', 'n'),
    ('member', 'P11_MEMBER', 's'), ('policy', 'P11_POLICY', 's'), ('ins_expiry', 'P11_INS_EXP', 's'), ('address', 'P11_ADDRESS', 's'),
    ('emergency', 'P11_EMERG', 's')]) + ' into l_doc from dual;', '    :P11_ID := noona_his_pkg.save_patient(l_doc);', 'end;'],
    when_button=b_save, success='تم حفظ بيانات المريض')
p.ir('زيارات المريض', 30, [
    "select v.id, v.visit_no, to_char(v.visit_at, 'YYYY-MM-DD HH24:MI') as visit_at, d.name_ar as dept, dr.name_ar as doctor, v.diagnosis,",
    "       v.patient_total, v.payer_total, case v.status_code when 'OPEN' then 'مفتوحة' when 'CLOSED' then 'مقفلة' else 'ملغاة' end as status",
    "  from his_visit v join his_department d on d.id = v.department_id left join his_doctor dr on dr.id = v.doctor_id",
    " where v.patient_id = :P11_ID order by v.visit_at desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('VISIT_NO', 'الزيارة', {}), ('VISIT_AT', 'الوقت', {}), ('DEPT', 'القسم', {}),
     ('DOCTOR', 'الطبيب', {}), ('DIAGNOSIS', 'التشخيص', {}), ('PATIENT_TOTAL', 'على المريض', {'type': 'NUMBER'}),
     ('PAYER_TOTAL', 'على الجهة', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], link=link(31, 'P31_ID'), titled=True, rows=10)
p.branch(10, url(11, 'P11_ID', '&P11_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) لوحة المواعيد
p = app.page(20, 'Appointments Board', 'APPOINTMENTS', 'لوحة المواعيد', scheme=HIS, protection='N')
f = p.static('اليوم والعيادة', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
p.date('P20_DATE', f, 10, 'التاريخ')
p.select('P20_DEPT', f, 20, 'العيادة/القسم', lov_sql=DEPT_LOV, null_text='كل الأقسام', submit=True)
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.button(f, 20, 'BOOK', 'حجز موعد', redirect=url(21, clear='RP,21'))
p.process(5, 'BEFORE_HEADER', 'Defaults', ":P20_DATE := nvl(:P20_DATE, to_char(sysdate, 'YYYY-MM-DD'));")
p.dynamic('الأطباء والمواعيد', 10, "return noona_his_pkg.day_board_html(to_date(:P20_DATE, 'YYYY-MM-DD'), :P20_DEPT);", hide_header=True,
          condition=READY)
p.onload([
    "document.addEventListener('click', function (e) {",
    "  var a = e.target.closest('[data-appt]'); if (!a) return;",
    "  location.href = 'f?p=' + apex.env.APP_ID + ':22:' + apex.env.APP_SESSION + '::NO:RP,22:P22_ID:' + a.dataset.appt;",
    "});"])
p.branch(10, url(20, 'P20_DATE,P20_DEPT', '&P20_DATE.,&P20_DEPT.'))

# =============================================================== 21) حجز موعد
p = app.page(21, 'Book Appointment', 'BOOK', 'حجز موعد', scheme=HIS, protection='N')
f = p.static('الموعد', 10)
p.select('P21_PATIENT', f, 10, 'المريض', lov_sql=PATIENT_LOV, required=True)
p.select('P21_DOCTOR', f, 20, 'الطبيب', lov_sql=DOCTOR_LOV, required=True)
p.date('P21_DATE', f, 30, 'التاريخ', required=True)
p.select('P21_TIME', f, 40, 'الوقت المتاح', cascade='P21_DOCTOR,P21_DATE', null_text='- اختر الوقت -', lov_sql=(
    "select t d, t r from json_table(noona_his_pkg.free_slots(to_number(:P21_DOCTOR), to_date(:P21_DATE, 'YYYY-MM-DD')), '$[*]' "
    "columns (t varchar2(5) path '$'))"))
p.select('P21_SERVICE', f, 50, 'الخدمة (فارغ = كشف الطبيب)', lov_sql=SERVICE_LOV, null_text='- كشف الطبيب -')
p.select('P21_CHANNEL', f, 60, 'القناة', lov_sql=CHANNEL_LOV, null_text=None)
p.textarea('P21_NOTES', f, 70, 'ملاحظات')
p.process(5, 'BEFORE_HEADER', 'Defaults', ":P21_DATE := nvl(:P21_DATE, to_char(sysdate, 'YYYY-MM-DD'));")
b_book = p.button(f, 10, 'BOOK', 'حجز', hot=True)
p.button(f, 20, 'NEWP', 'مريض جديد', redirect=url(11, clear='RP,11'))
p.process(10, 'AFTER_SUBMIT', 'Book', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('patient', 'P21_PATIENT', 'n'), ('doctor', 'P21_DOCTOR', 'n'), ('service', 'P21_SERVICE', 'n'), ('date', 'P21_DATE', 's'),
    ('time', 'P21_TIME', 's'), ('channel', 'P21_CHANNEL', 's'), ('notes', 'P21_NOTES', 's')]) + ' into l_doc from dual;',
    '    :P21_ID := noona_his_pkg.book(l_doc);', 'end;'], when_button=b_book, success='تم الحجز')
p.hidden('P21_ID', f, 90, protected=False)
p.branch(10, url(22, 'P22_ID', '&P21_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 22) الموعد
p = app.page(22, 'Appointment', 'APPOINTMENT', 'الموعد', scheme=HIS, protection='N')
f = p.static('الموعد', 10)
p.hidden('P22_ID', f, 1, protected=False)
p.hidden('P22_VISIT', f, 2, protected=False)
p.dynamic('تفاصيل', 5, [
    'declare l varchar2(4000);', 'begin',
    "    select '<div class=\"nn-his-card\"><div class=\"nn-his-head\"><div><b>' || apex_escape.html(p.name_ar) || '</b> <span class=\"nn-rst-chip\">' || p.mrn",
    "           || '</span><br><small>' || to_char(a.appt_date, 'YYYY-MM-DD') || ' ' || a.start_time || ' · ' || apex_escape.html(nvl(d.name_ar, dp.name_ar))",
    "           || ' · ' || noona_his_pkg.appt_status_label(a.status_code) || ' · ' || a.appt_no || '</small></div></div></div>'",
    "      into l from his_appointment a join his_patient p on p.id = a.patient_id left join his_doctor d on d.id = a.doctor_id",
    "      join his_department dp on dp.id = a.department_id where a.id = :P22_ID;",
    '    return l;', 'exception when no_data_found then return null;', 'end;'], hide_header=True)
p.text('P22_REASON', f, 10, 'سبب الإلغاء')
b_arr = p.button(f, 10, 'ARRIVE', 'وصول المريض وفتح الزيارة', hot=True)
b_can = p.button(f, 20, 'CANCEL', 'إلغاء الموعد')
b_ns = p.button(f, 30, 'NOSHOW', 'لم يحضر')
p.process(10, 'AFTER_SUBMIT', 'Arrive', ':P22_VISIT := noona_his_pkg.arrive(:P22_ID);', when_button=b_arr, success='فتحت الزيارة')
p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_his_pkg.cancel_appointment(:P22_ID, :P22_REASON);', when_button=b_can, success='ألغي الموعد')
p.process(30, 'AFTER_SUBMIT', 'No Show', 'noona_his_pkg.mark_no_show(:P22_ID);', when_button=b_ns, success='سجل عدم الحضور')
p.branch(5, url(31, 'P31_ID', '&P22_VISIT.') + '&success_msg=#SUCCESS_MSG#', when_button=b_arr)
p.branch(10, url(20) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) الزيارات
p = app.page(30, 'Visits', 'VISITS', 'الزيارات', scheme=HIS)
f = p.static('إجراءات', 5, hide_header=True)
p.button(f, 10, 'NEW', 'زيارة جديدة', hot=True, redirect=url(32, clear='RP,32'))
p.ir('الزيارات', 10, [
    "select v.id, v.visit_no, to_char(v.visit_at, 'YYYY-MM-DD HH24:MI') as visit_at, p.name_ar as patient, p.mrn, d.name_ar as dept,",
    "       dr.name_ar as doctor, case v.bill_to when 'PAYER' then 'جهة' else 'نقدي' end as bill_to, v.patient_total, v.payer_total, v.paid_amount,",
    "       noona_his_pkg.unbilled_total(v.id, 'PATIENT') + noona_his_pkg.unbilled_total(v.id, 'PAYER') as unbilled,",
    "       case v.status_code when 'OPEN' then 'مفتوحة' when 'CLOSED' then 'مقفلة' else 'ملغاة' end as status",
    "  from his_visit v join his_patient p on p.id = v.patient_id join his_department d on d.id = v.department_id",
    f"  left join his_doctor dr on dr.id = v.doctor_id where v.company_id = {CO} order by v.visit_at desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('VISIT_NO', 'الزيارة', {}), ('VISIT_AT', 'الوقت', {}), ('PATIENT', 'المريض', {}),
     ('MRN', 'الرقم الطبي', {}), ('DEPT', 'القسم', {}), ('DOCTOR', 'الطبيب', {}), ('BILL_TO', 'الدفع', {}),
     ('PATIENT_TOTAL', 'على المريض', {'type': 'NUMBER'}), ('PAYER_TOTAL', 'على الجهة', {'type': 'NUMBER'}), ('PAID_AMOUNT', 'المدفوع', {'type': 'NUMBER'}),
     ('UNBILLED', 'غير مفوتر', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], link=link(31, 'P31_ID'))

# =============================================================== 31) الزيارة: الطلبات والملاحظات والمحاسبة
p = app.page(31, 'Visit', 'VISIT', 'الزيارة', scheme=HIS, protection='N')
hd = p.static('الزيارة', 1, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P31_ID', hd, 1, protected=False)
p.hidden('P31_INVOICE', hd, 2, protected=False)
p.hidden('P31_PATIENT', hd, 3, protected=False)
OPEN = "noona_his_pkg.is_open(:P31_ID) = 'Y'"
p.dynamic('ملف الزيارة', 5, 'return noona_his_pkg.visit_html(:P31_ID);', hide_header=True, condition=':P31_ID is not null')
fo = p.static('طلب خدمة (كشف، تحليل، أشعة، رسم قلب، إجراء، عملية، جلسة)', 10, condition=OPEN)
p.select('P31_SERVICE', fo, 10, 'الخدمة', lov_sql=SERVICE_LOV)
p.number('P31_QTY', fo, 20, 'الكمية')
p.text('P31_ONOTES', fo, 30, 'ملاحظات الطلب')
b_add = p.button(fo, 10, 'ADD', 'إضافة الطلب', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Order', ['declare l number;', 'begin',
    '    l := noona_his_pkg.add_order(:P31_ID, to_number(:P31_SERVICE), nvl(to_number(:P31_QTY), 1), null, :P31_ONOTES);',
    '    :P31_SERVICE := null; :P31_QTY := null; :P31_ONOTES := null;', 'end;'], when_button=b_add, success='أضيف الطلب')
fb = p.static('باقة خدمات (فحص شامل، متابعة، باقات العروض)', 11, condition=OPEN + " and exists (select 1 from sal_bundle where company_id = noona_prc_pkg.company and status_code = 'ACTIVE')")
p.select('P31_BUNDLE', fb, 10, 'الباقة', lov_sql=(
    "select name_ar || ' - ' || to_char(noona_prc_pkg.bundle_price(id), 'FM999,990.00') d, id r from sal_bundle "
    "where company_id = noona_prc_pkg.company and status_code = 'ACTIVE' and trunc(sysdate) between effective_from and nvl(effective_to, trunc(sysdate)) "
    "and (channels is null or instr(',' || channels || ',', ',HIS,') > 0) order by name_ar"))
b_bnd = p.button(fb, 10, 'ADD_BUNDLE', 'إضافة الباقة')
p.process(11, 'AFTER_SUBMIT', 'Add Bundle', ['declare l number;', 'begin',
    '    l := noona_his_pkg.add_bundle(:P31_ID, to_number(:P31_BUNDLE));',
    "    apex_application.g_print_success_message := 'أضيفت الباقة: ' || l || ' خدمات بسعر الباقة';", '    :P31_BUNDLE := null;', 'end;'],
    when_button=b_bnd)
fpay = p.static('طريقة الدفع والتأمين (اختياري)', 12, condition=OPEN)
p.select('P31_BILLTO', fpay, 10, 'الدفع', lov_sql='STATIC2:نقدي بدون تأمين;CASH,على التأمين/الجهة;PAYER', null_text=None)
b_bt = p.button(fpay, 10, 'SET_BILLING', 'تغيير طريقة الدفع (يعاد تسعير غير المفوتر)')
b_el = p.button(fpay, 20, 'ELIGIBILITY', 'التحقق من أهلية التأمين إلكترونياً')
p.process(8, 'AFTER_SUBMIT', 'Billing', 'noona_his_pkg.set_billing(:P31_ID, :P31_BILLTO);', when_button=b_bt, success='تغيرت طريقة الدفع')
p.process(9, 'AFTER_SUBMIT', 'Eligibility', ['declare l varchar2(30);', 'begin', '    l := noona_his_link_pkg.check_eligibility(:P31_ID);',
    "    apex_application.g_print_success_message := 'الأهلية: ' || noona_his_link_pkg.status_label(l)",
    "        || case when l = 'NOT_ELIGIBLE' then ' - يمكن تحويل الزيارة إلى نقدي' end;", 'end;'], when_button=b_el)
fa = p.static('موافقة التأمين أو إلغاء طلب', 15, condition=OPEN)
p.select('P31_ORDER', fa, 10, 'الطلب', null_text='- اختر -', lov_sql=(
    "select o.line_no || ' - ' || noona_his_pkg.service_name(s.id) || ' (' || noona_his_pkg.order_status_label(o.status_code) || ')' d, o.id r from his_order o "
    "join his_service s on s.id = o.service_id where o.visit_id = :P31_ID and o.status_code in ('ORDERED', 'APPROVAL_PENDING') "
    "and o.invoice_id is null order by o.line_no"))
p.text('P31_APPROVAL', fa, 20, 'رقم الموافقة / سبب الرفض أو الإلغاء')
b_apr = p.button(fa, 10, 'APPROVE', 'تسجيل الموافقة')
b_rej = p.button(fa, 20, 'REJECT', 'رفض التأمين (يحول نقدي)')
b_cno = p.button(fa, 30, 'CANCEL_ORDER', 'إلغاء الطلب')
b_pa = p.button(fa, 40, 'PREAUTH', 'طلب الموافقة إلكترونياً')
b_pp = p.button(fa, 50, 'PREAUTH_POLL', 'متابعة الموافقة')
p.process(23, 'AFTER_SUBMIT', 'Preauth', "apex_application.g_print_success_message := 'طلب الموافقة: ' || noona_his_link_pkg.status_label(noona_his_link_pkg.request_preauth(:P31_ORDER));",
          when_button=b_pa)
p.process(24, 'AFTER_SUBMIT', 'Preauth Poll', "apex_application.g_print_success_message := 'الموافقة: ' || noona_his_link_pkg.status_label(noona_his_link_pkg.poll_preauth(:P31_ORDER));",
          when_button=b_pp)
p.process(20, 'AFTER_SUBMIT', 'Approve', "noona_his_pkg.set_approval(:P31_ORDER, :P31_APPROVAL, 'Y');", when_button=b_apr, success='سجلت الموافقة')
p.process(21, 'AFTER_SUBMIT', 'Reject', "noona_his_pkg.set_approval(:P31_ORDER, :P31_APPROVAL, 'N');", when_button=b_rej,
          success='سجل الرفض وتحولت الخدمة على المريض')
p.process(22, 'AFTER_SUBMIT', 'Cancel Order', 'noona_his_pkg.cancel_order(:P31_ORDER, :P31_APPROVAL);', when_button=b_cno, success='ألغي الطلب')
fd = p.static('الكشف المبدئي', 20, condition=OPEN)
p.text('P31_VITALS', fd, 10, 'العلامات الحيوية (الضغط، الحرارة، النبض، التنفس، الأكسجين، الوزن)', maxlen=1000)
p.textarea('P31_COMPLAINT', fd, 20, 'الشكوى الرئيسية والتاريخ المرضي')
p.textarea('P31_DIAG', fd, 30, 'التشخيص (Diagnosis)')
p.text('P31_ICD', fd, 40, 'رمز التشخيص ICD-10', maxlen=100, width=15)
p.textarea('P31_DNOTES', fd, 50, 'نتائج الفحص والخطة العلاجية', rows=4)
b_notes = p.button(fd, 10, 'SAVE_NOTES', 'حفظ الكشف')
p.onload("$('#P31_VITALS,#P31_COMPLAINT,#P31_DIAG,#P31_ICD,#P31_DNOTES').attr('dir', 'ltr');")
p.process(4, 'BEFORE_HEADER', 'Load', ['begin', '    select vitals, chief_complaint, diagnosis, icd10, doctor_notes, bill_to',
    '      into :P31_VITALS, :P31_COMPLAINT, :P31_DIAG, :P31_ICD, :P31_DNOTES, :P31_BILLTO', f'      from his_visit where id = :P31_ID and company_id = {CO};',
    f'    select patient_id into :P31_PATIENT from his_visit where id = :P31_ID and company_id = {CO};',
    'exception when no_data_found then null;', 'end;'])
p.process(30, 'AFTER_SUBMIT', 'Notes', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('id', 'P31_ID', 'n'), ('vitals', 'P31_VITALS', 's'), ('complaint', 'P31_COMPLAINT', 's'), ('diagnosis', 'P31_DIAG', 's'),
    ('icd10', 'P31_ICD', 's'), ('notes', 'P31_DNOTES', 's')]) + ' into l_doc from dual;', '    noona_his_pkg.update_visit(l_doc);', 'end;'],
    when_button=b_notes, success='حفظت الملاحظات')
fb = p.static('المحاسبة', 25, condition=OPEN)
p.dynamic('المستحق', 24, ["return '<div class=\"nn-his-due\"><span>المطلوب من المريض <b>' || to_char(noona_his_pkg.unbilled_total(:P31_ID, 'PATIENT'), "
                         "'FM999G999G990D00') || '</b></span><span>مطالبة الجهة <b>' || to_char(noona_his_pkg.unbilled_total(:P31_ID, 'PAYER'), "
                         "'FM999G999G990D00') || '</b></span></div>';"], hide_header=True, condition=OPEN)
p.select('P31_METHOD', fb, 10, 'طريقة الدفع (آجل = على حساب المريض)', lov_sql=METHOD_LOV, null_text=None)
p.select('P31_PLACE', fb, 20, 'الصندوق/البنك', lov_sql=PLACE_LOV, null_text='- الافتراضي -')
p.text('P31_REF', fb, 30, 'مرجع الدفع (رقم العملية)', maxlen=100, width=20)
b_inv = p.button(fb, 10, 'INVOICE', 'إصدار الفاتورة والتحصيل', hot=True)
b_close = p.button(fb, 20, 'CLOSE', 'إقفال الزيارة')
p.button(fo, 20, 'RX', 'Prescription - وصفة', redirect=url(33, 'P33_VISIT', '&P31_ID.', 'RP,33'))
p.button(fo, 60, 'NURSING', 'التمريض والعلامات الحيوية', redirect=url(35, 'P35_VISIT', '&P31_ID.', 'RP,35'))
p.button(fo, 65, 'CHART', 'الملف الإلكتروني للمنوم', redirect=url(76, 'P76_VISIT', '&P31_ID.', 'RP,76'))
p.button(fo, 70, 'CERT', 'تقرير طبي / إجازة', redirect=url(36, 'P36_VISIT', '&P31_ID.', 'RP,36'))
p.button(fo, 80, 'EMR', 'الملف الطبي', redirect="javascript:location.href='f?p='+apex.env.APP_ID+':12:'+apex.env.APP_SESSION+'::NO:RP,12:P12_ID:'+$('#P31_PATIENT').val();")
p.button(fo, 30, 'ADMIT', 'التنويم', redirect=url(56))
p.button(fo, 40, 'SURGERY', 'جدولة عملية', redirect=url(57))
p.button(fo, 50, 'THERAPY', 'خطة علاج طبيعي', redirect=url(58))
p.process(40, 'AFTER_SUBMIT', 'Invoice', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('visit', 'P31_ID', 'n'), ('method', 'P31_METHOD', 's'), ('place', 'P31_PLACE', 's'), ('ref', 'P31_REF', 's')]) + ' into l_doc from dual;',
    '    :P31_INVOICE := noona_his_pkg.create_invoice(l_doc);', 'end;'], when_button=b_inv, success='صدرت الفاتورة')
p.process(50, 'AFTER_SUBMIT', 'Close', 'noona_his_pkg.close_visit(:P31_ID);', when_button=b_close, success='أقفلت الزيارة')
p.ir('فواتير الزيارة', 40, [
    "select i.id, i.doc_no, i.doc_date, i.patient_total, i.payer_total, i.paid_amount, i.payment_method,",
    "       case i.status_code when 'POSTED' then 'مرحلة' else 'ملغاة' end as status,",
    "       '<span class=\"fa fa-print\" aria-hidden=\"true\"></span> طباعة' as prn",
    "  from his_invoice i where i.visit_id = :P31_ID order by i.id"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الفاتورة', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE'}),
     ('PATIENT_TOTAL', 'على المريض', {'type': 'NUMBER'}), ('PAYER_TOTAL', 'على الجهة', {'type': 'NUMBER'}), ('PAID_AMOUNT', 'المدفوع', {'type': 'NUMBER'}),
     ('PAYMENT_METHOD', 'الطريقة', {}), ('STATUS', 'الحالة', {}),
     ('PRN', 'طباعة', {'html': True, 'link': ('f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:#ID#', '#PRN#')})], titled=True, rows=10)
p.ir('نتائج الزيارة', 45, [
    "select o.id, noona_his_pkg.service_name(s.id) as service, d.name_ar as dept, case o.result_flag when 'CRITICAL' then 'حرج' when 'ABNORMAL' then 'غير طبيعي'",
    "       else 'طبيعي' end as flag, to_char(o.completed_at, 'YYYY-MM-DD HH24:MI') as done_at,",
    "       '<span class=\"fa fa-file-text-o\" aria-hidden=\"true\"></span> التقرير' as rpt",
    "  from his_order o join his_service s on s.id = o.service_id join his_department d on d.id = o.department_id",
    " where o.visit_id = :P31_ID and o.status_code = 'COMPLETED' order by o.line_no"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('SERVICE', 'الخدمة', {}), ('DEPT', 'القسم', {}), ('FLAG', 'التقييم', {}),
     ('DONE_AT', 'الإنجاز', {}), ('RPT', 'التقرير', {'html': True, 'link': ('f?p=&APP_ID.:52:&SESSION.::&DEBUG.:RP,52:P52_ID:#ID#', '#RPT#')})],
    titled=True, rows=20)
p.branch(5, url(41, 'P41_ID', '&P31_INVOICE.') + '&success_msg=#SUCCESS_MSG#', when_button=b_inv)
p.branch(10, url(31, 'P31_ID', '&P31_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 32) زيارة جديدة
p = app.page(32, 'New Visit', 'NEW-VISIT', 'زيارة جديدة', scheme=HIS, protection='N')
f = p.static('الزيارة', 10)
p.select('P32_PATIENT', f, 10, 'المريض', lov_sql=PATIENT_LOV, required=True)
p.select('P32_DOCTOR', f, 20, 'الطبيب (يضاف كشفه تلقائياً)', lov_sql=DOCTOR_LOV, null_text='- بدون طبيب -')
p.select('P32_DEPT', f, 30, 'القسم (للمعامل والأشعة المباشرة)', lov_sql=DEPT_LOV, null_text='- قسم الطبيب -')
p.select('P32_TYPE', f, 40, 'نوع الزيارة', lov_sql=VISIT_TYPE_LOV, null_text=None)
p.select('P32_BILL', f, 50, 'الدفع (التأمين اختياري)', lov_sql='STATIC2:حسب ملف المريض (التأمين إن وجد);,نقدي بدون تأمين;CASH,على التأمين/الجهة;PAYER', null_text=None)
p.text('P32_APPROVAL', f, 60, 'رقم الموافقة (إن وجد)', maxlen=50, width=20)
p.textarea('P32_COMPLAINT', f, 70, 'الشكوى')
p.hidden('P32_ID', f, 90, protected=False)
b_open = p.button(f, 10, 'OPEN', 'فتح الزيارة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Open', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('patient', 'P32_PATIENT', 'n'), ('doctor', 'P32_DOCTOR', 'n'), ('dept', 'P32_DEPT', 'n'), ('type', 'P32_TYPE', 's'),
    ('bill_to', 'P32_BILL', 's'), ('approval', 'P32_APPROVAL', 's'), ('complaint', 'P32_COMPLAINT', 's')]) + ' into l_doc from dual;',
    '    :P32_ID := noona_his_pkg.open_visit(l_doc);', 'end;'], when_button=b_open, success='فتحت الزيارة')
p.branch(10, url(31, 'P31_ID', '&P32_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 40) المحاسبة
p = app.page(40, 'Cashier', 'CASHIER', 'المحاسبة', scheme=HIS)
p.ir('زيارات بمبالغ غير مفوترة', 10, [
    "select v.id, v.visit_no, to_char(v.visit_at, 'YYYY-MM-DD HH24:MI') as visit_at, p.name_ar as patient, p.mrn, d.name_ar as dept,",
    "       noona_his_pkg.unbilled_total(v.id, 'PATIENT') as patient_due, noona_his_pkg.unbilled_total(v.id, 'PAYER') as payer_due",
    "  from his_visit v join his_patient p on p.id = v.patient_id join his_department d on d.id = v.department_id",
    f" where v.company_id = {CO} and v.status_code = 'OPEN'",
    "   and exists (select 1 from his_order o where o.visit_id = v.id and o.invoice_id is null and o.status_code not in ('CANCELLED', 'APPROVAL_PENDING'))",
    " order by v.visit_at"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('VISIT_NO', 'الزيارة', {}), ('VISIT_AT', 'الوقت', {}), ('PATIENT', 'المريض', {}),
     ('MRN', 'الرقم الطبي', {}), ('DEPT', 'القسم', {}), ('PATIENT_DUE', 'على المريض', {'type': 'NUMBER'}), ('PAYER_DUE', 'على الجهة', {'type': 'NUMBER'})],
    link=link(31, 'P31_ID'), titled=True)
p.ir('فواتير اليوم', 20, [
    "select i.id, i.doc_no, p.name_ar as patient, (select name_ar from his_payer where id = i.payer_id) as payer, i.patient_total, i.payer_total,",
    "       i.paid_amount, i.payment_method, case i.status_code when 'POSTED' then 'مرحلة' else 'ملغاة' end as status",
    f"  from his_invoice i join his_patient p on p.id = i.patient_id where i.company_id = {CO} and i.doc_date = trunc(sysdate) order by i.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الفاتورة', {}), ('PATIENT', 'المريض', {}), ('PAYER', 'الجهة', {}),
     ('PATIENT_TOTAL', 'على المريض', {'type': 'NUMBER'}), ('PAYER_TOTAL', 'على الجهة', {'type': 'NUMBER'}), ('PAID_AMOUNT', 'المدفوع', {'type': 'NUMBER'}),
     ('PAYMENT_METHOD', 'الطريقة', {}), ('STATUS', 'الحالة', {})], link=link(41, 'P41_ID'), titled=True)

# =============================================================== 41) الفاتورة
p = app.page(41, 'Invoice', 'INVOICE', 'فاتورة الزيارة', scheme=HIS, protection='N')
f = p.static('الفاتورة', 10, hide_header=True)
p.hidden('P41_ID', f, 1, protected=False)
p.dynamic('الفاتورة', 5, 'return noona_his_pkg.invoice_html(:P41_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area',
          condition=':P41_ID is not null')
p.text('P41_REASON', f, 10, 'سبب الإلغاء')
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')
b_ci = p.button(f, 20, 'CANCEL_INV', 'إلغاء الفاتورة')
p.button(f, 30, 'BACK', 'الزيارة', redirect=(f"f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P41_VISIT."))
p.hidden('P41_VISIT', f, 2, protected=False)
p.process(5, 'BEFORE_HEADER', 'Visit', f'begin select visit_id into :P41_VISIT from his_invoice where id = :P41_ID; exception when no_data_found then null; end;')
p.process(10, 'AFTER_SUBMIT', 'Cancel', 'noona_his_pkg.cancel_invoice(:P41_ID, :P41_REASON);', when_button=b_ci, success='ألغيت الفاتورة وعكس قيدها')
p.branch(10, url(41, 'P41_ID', '&P41_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 50) قوائم عمل الأقسام
p = app.page(50, 'Worklists', 'WORKLIST', 'قوائم عمل المعامل والأشعة والأقسام', scheme=HIS, protection='N')
f = p.static('القسم', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
p.select('P50_DEPT', f, 10, 'القسم (كل معمل ووحدة مستقلة)', lov_sql=WORK_DEPT_LOV, null_text='كل الأقسام', submit=True)
p.select('P50_SHOW', f, 20, 'العرض', lov_sql='STATIC2:المطلوب والجاري;OPEN,المنجز اليوم;DONE', null_text=None, submit=True)
p.ir('الطلبات', 10, [
    "select o.id, v.visit_no, p.name_ar as patient, p.mrn, case p.gender when 'M' then 'ذكر' else 'أنثى' end as gender,",
    "       trunc(months_between(sysdate, p.birth_date) / 12) as age, noona_his_pkg.service_name(s.id) as service, d.name_ar as dept,",
    "       noona_his_pkg.modality_label(s.modality) as modality, o.sample_no, noona_his_pkg.order_status_label(o.status_code) as status,",
    "       case when o.invoice_id is not null or v.visit_type in ('EMERGENCY', 'INPATIENT', 'DAY_CASE') then 'نعم' else 'لا' end as paid,",
    "       to_char(v.visit_at, 'YYYY-MM-DD HH24:MI') as ordered_at, (select name_ar from his_doctor where id = o.ordered_by_id) as doctor",
    "  from his_order o join his_visit v on v.id = o.visit_id join his_patient p on p.id = v.patient_id",
    "  join his_service s on s.id = o.service_id join his_department d on d.id = o.department_id",
    f" where o.company_id = {CO} and d.dept_type not in ('CLINIC', 'EMERGENCY') and (:P50_DEPT is null or o.department_id = :P50_DEPT)",
    "   and ((nvl(:P50_SHOW, 'OPEN') = 'OPEN' and o.status_code in ('ORDERED', 'IN_PROGRESS', 'APPROVAL_PENDING'))",
    "        or (:P50_SHOW = 'DONE' and o.status_code = 'COMPLETED' and o.completed_at >= trunc(sysdate)))",
    " order by v.visit_at"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('VISIT_NO', 'الزيارة', {}), ('PATIENT', 'المريض', {}), ('MRN', 'الرقم الطبي', {}),
     ('GENDER', 'الجنس', {}), ('AGE', 'العمر', {'type': 'NUMBER'}), ('SERVICE', 'الفحص (Test / Exam)', {}), ('DEPT', 'القسم', {}), ('MODALITY', 'الجهاز', {}),
     ('SAMPLE_NO', 'العينة', {}), ('STATUS', 'الحالة', {}), ('PAID', 'مسدد', {}), ('ORDERED_AT', 'الطلب', {}), ('DOCTOR', 'الطبيب', {})],
    link=link(51, 'P51_ID'))
p.branch(10, url(50, 'P50_DEPT,P50_SHOW', '&P50_DEPT.,&P50_SHOW.'))

# =============================================================== 51) تنفيذ الطلب وإدخال النتيجة
p = app.page(51, 'Perform Order', 'PERFORM', 'تنفيذ الطلب والنتيجة', scheme=HIS, protection='N')
f = p.static('النتيجة', 10)
p.hidden('P51_ID', f, 1, protected=False)
p.dynamic('الطلب', 5, [
    'declare l varchar2(4000);', 'begin',
    "    select '<div class=\"nn-his-card\"><div class=\"nn-his-head\"><div><b>' || apex_escape.html(noona_his_pkg.service_name(s.id)) || '</b> <span class=\"nn-rst-chip\">'",
    "           || noona_his_pkg.order_status_label(o.status_code) || '</span><br><small>' || apex_escape.html(p.name_ar) || ' · ' || p.mrn || ' · '",
    "           || case p.gender when 'M' then 'ذكر' else 'أنثى' end || ' · زيارة ' || v.visit_no || nvl2(o.sample_no, ' · عينة ' || o.sample_no, '')",
    "           || '</small>' || nvl2(s.normal_range, '<br><small>Normal range: ' || apex_escape.html(s.normal_range) || '</small>', '')",
    "           || nvl2(p.allergies, '<br><span class=\"nn-rst-chip is-cancelled\">حساسية: ' || apex_escape.html(p.allergies) || '</span>', '')",
    "           || nvl2(o.notes, '<br><small>Doctor notes: ' || apex_escape.html(o.notes) || '</small>', '') || '</div></div></div>'",
    "      into l from his_order o join his_service s on s.id = o.service_id join his_visit v on v.id = o.visit_id join his_patient p on p.id = v.patient_id",
    f"     where o.id = :P51_ID and o.company_id = {CO};",
    '    return l;', 'exception when no_data_found then return null;', 'end;'], hide_header=True)
p.textarea('P51_RESULT', f, 10, 'النتيجة / التقرير (بالإنجليزية)', rows=10)
p.onload("$('#P51_RESULT, input[name=f01]').attr('dir', 'ltr');")
p.select('P51_FLAG', f, 20, 'التقييم', lov_sql='STATIC2:طبيعي (Normal);NORMAL,غير طبيعي (Abnormal);ABNORMAL,حرج (Critical);CRITICAL', null_text=None)
p.select('P51_BY', f, 30, 'المنفذ/المعتمد', lov_sql=DOCTOR_LOV, null_text='- المستخدم الحالي -')
b_smp = p.button(f, 10, 'SAMPLE', 'سحب العينة')
b_st = p.button(f, 20, 'START', 'بدء التنفيذ')
b_done = p.button(f, 30, 'COMPLETE', 'حفظ النتيجة وإنجاز الطلب (يصرف مواد القسم)', hot=True)
p.button(f, 40, 'REPORT', 'طباعة التقرير', redirect=url(52, 'P52_ID', '&P51_ID.', 'RP,52'))
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', '    select result_text, nvl(result_flag, \'NORMAL\'), performed_by_id into :P51_RESULT, :P51_FLAG, :P51_BY',
                                        f'      from his_order where id = :P51_ID and company_id = {CO};',
                                        '    if :P51_RESULT is null then :P51_RESULT := noona_his_care_pkg.template_for(:P51_ID); end if;',
                                        'exception when no_data_found then null;', 'end;'])
# التحاليل ذات المكونات: جدول القيم بالمعدلات والتقييم الآلي
LAB = "noona_his_care_pkg.has_params(:P51_ID) = 'Y'"
fl = p.static('نتائج المختبر', 8, condition=LAB)
p.dynamic('المكونات', 7, 'return noona_his_care_pkg.lab_grid_html(:P51_ID);', hide_header=True, condition=LAB)
b_lsave = p.button(fl, 10, 'LAB_SAVE', 'حفظ القيم')
b_ldone = p.button(fl, 20, 'LAB_DONE', 'اعتماد النتائج وإصدارها', hot=True)
LAB_JSON = ['declare l clob;', 'begin', "    l := '[';",
            '    for i in 1 .. apex_application.g_f02.count loop',
            "        l := l || case when i > 1 then ',' end || json_object('p' value to_number(apex_application.g_f02(i)),",
            "             'v' value case when regexp_like(trim(apex_application.g_f01(i)), '^-?[0-9]+([.][0-9]+)?$') then to_number(trim(apex_application.g_f01(i)),",
            "                  '9999999999D9999', 'NLS_NUMERIC_CHARACTERS=''.,''') end,",
            "             't' value case when not regexp_like(trim(apex_application.g_f01(i)), '^-?[0-9]+([.][0-9]+)?$') then trim(apex_application.g_f01(i)) end);",
            '    end loop;', "    l := l || ']';"]
p.process(25, 'AFTER_SUBMIT', 'Lab Save', LAB_JSON + ["    noona_his_care_pkg.save_lab_results(:P51_ID, l, 'N');", 'end;'], when_button=b_lsave,
          success='حفظت القيم')
p.process(26, 'AFTER_SUBMIT', 'Lab Release', LAB_JSON + ["    noona_his_care_pkg.save_lab_results(:P51_ID, l, 'Y', to_number(:P51_BY), :P51_RESULT);", 'end;'],
          when_button=b_ldone, success='اعتمدت النتائج وأُنجز الطلب')
p.process(10, 'AFTER_SUBMIT', 'Sample', ['declare l varchar2(30);', 'begin', '    l := noona_his_pkg.collect_sample(:P51_ID);', "    apex_application.g_print_success_message := 'رقم العينة ' || l;", 'end;'],
          when_button=b_smp)
p.process(20, 'AFTER_SUBMIT', 'Start', 'noona_his_pkg.start_order(:P51_ID);', when_button=b_st, success='بدأ التنفيذ')
p.process(30, 'AFTER_SUBMIT', 'Complete', 'noona_his_pkg.complete_order(:P51_ID, :P51_RESULT, :P51_FLAG, to_number(:P51_BY));', when_button=b_done,
          success='حفظت النتيجة وأنجز الطلب')
p.branch(10, url(51, 'P51_ID', '&P51_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 52) تقرير النتيجة
p = app.page(52, 'Result Report', 'RESULT', 'تقرير النتيجة', scheme=HIS, protection='N')
f = p.static('التقرير', 10, hide_header=True)
p.hidden('P52_ID', f, 1, protected=False)
p.dynamic('التقرير', 5, 'return noona_his_pkg.result_html(:P52_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')

# =============================================================== 60) الأقسام
p = app.page(60, 'Departments', 'DEPARTMENTS', 'الأقسام والعيادات والمعامل', scheme=HIS)
f = p.static('قسم جديد / تعديل', 10)
p.select('P60_ID', f, 5, 'تعديل قسم', lov_sql=DEPT_LOV.replace(" and status_code = 'ACTIVE'", ''), null_text='- قسم جديد -', submit=True)
p.text('P60_CODE', f, 10, 'الرمز', maxlen=30, width=12)
p.text('P60_NAME', f, 20, 'الاسم')
p.select('P60_TYPE', f, 30, 'النوع', lov_sql=DEPT_TYPE_LOV, null_text=None)
p.text('P60_SPEC', f, 40, 'التخصص', maxlen=100)
p.yesno('P60_STORE', f, 50, 'مستودع مستقل للقسم (معمل/صيدلية/أشعة)')
p.text('P60_LOC', f, 60, 'الموقع', maxlen=200)
p.select('P60_STATUS', f, 70, 'الحالة', lov_sql=STATUS_LOV, null_text=None)
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', ['begin', "    select code, name_ar, dept_type, specialty, case when warehouse_id is not null then 'Y' else 'N' end, location_text, status_code",
    '      into :P60_CODE, :P60_NAME, :P60_TYPE, :P60_SPEC, :P60_STORE, :P60_LOC, :P60_STATUS', f'      from his_department where id = :P60_ID and company_id = {CO};',
    'exception when no_data_found then null;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l number;', 'begin',
    '    l := noona_his_pkg.save_department(to_number(:P60_ID), :P60_CODE, :P60_NAME, :P60_TYPE, :P60_SPEC, :P60_STORE, :P60_LOC, :P60_STATUS);',
    '    :P60_ID := null; :P60_CODE := null; :P60_NAME := null;', 'end;'], when_button=b, success='تم حفظ القسم')
p.ir('الأقسام', 20, [
    "select d.id, d.code, d.name_ar, noona_his_pkg.dept_type_label(d.dept_type) as dtype, d.specialty, w.name_ar as warehouse, c.code as cc,",
    "       (select count(*) from his_doctor x where x.department_id = d.id and x.status_code = 'ACTIVE') as doctors,",
    "       (select count(*) from his_service x where x.department_id = d.id and x.status_code = 'ACTIVE') as services,",
    "       case d.status_code when 'ACTIVE' then 'نشط' else 'موقوف' end as status",
    "  from his_department d left join inv_warehouse w on w.id = d.warehouse_id left join gl_cost_center c on c.id = d.cost_center_id",
    f" where d.company_id = {CO} order by d.dept_type, d.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'القسم', {}), ('DTYPE', 'النوع', {}), ('SPECIALTY', 'التخصص', {}),
     ('WAREHOUSE', 'المستودع', {}), ('CC', 'مركز التكلفة', {}), ('DOCTORS', 'الأطباء', {'type': 'NUMBER'}), ('SERVICES', 'الخدمات', {'type': 'NUMBER'}),
     ('STATUS', 'الحالة', {})], titled=True)
p.branch(10, url(60) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 61) دليل الخدمات ومواردها
p = app.page(61, 'Services', 'SERVICES', 'دليل الخدمات الطبية', scheme=HIS)
f = p.static('خدمة جديدة / تعديل', 10)
p.select('P61_ID', f, 5, 'تعديل خدمة', lov_sql=SERVICE_LOV.replace(" and s.status_code = 'ACTIVE'", ''), null_text='- خدمة جديدة -', submit=True)
p.text('P61_CODE', f, 10, 'الرمز', maxlen=30, width=12)
p.text('P61_NAME', f, 20, 'الاسم')
p.text('P61_NAME_EN', f, 25, 'Name (English) - للتحاليل والأشعة والأدوية')
p.select('P61_TYPE', f, 30, 'النوع', lov_sql=SRV_TYPE_LOV, null_text=None)
p.select('P61_DEPT', f, 40, 'القسم المنفذ', lov_sql=DEPT_LOV)
p.select('P61_MOD', f, 50, 'جهاز الأشعة/التشخيص', lov_sql=MODALITY_LOV)
p.number('P61_PRICE', f, 60, 'السعر النقدي قبل الضريبة')
p.text('P61_BCODE', f, 70, 'رمز الفوترة (CPT/SBS)', maxlen=50, width=15)
p.select('P61_SAMPLE', f, 80, 'نوع العينة', lov_sql=SAMPLE_LOV)
p.number('P61_TAT', f, 90, 'زمن النتيجة بالساعات')
p.text('P61_RANGE', f, 100, 'المعدل الطبيعي والوحدة', maxlen=500)
p.yesno('P61_APR', f, 110, 'يحتاج موافقة التأمين')
p.select('P61_STATUS', f, 120, 'الحالة', lov_sql=STATUS_LOV, null_text=None)
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', ['begin',
    '    select code, name_ar, name_en, service_type, department_id, modality, price, billing_code, sample_type, turnaround_hours, normal_range, needs_approval, status_code',
    '      into :P61_CODE, :P61_NAME, :P61_NAME_EN, :P61_TYPE, :P61_DEPT, :P61_MOD, :P61_PRICE, :P61_BCODE, :P61_SAMPLE, :P61_TAT, :P61_RANGE, :P61_APR, :P61_STATUS',
    f'      from his_service where id = :P61_ID and company_id = {CO};', 'exception when no_data_found then null;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob; l number;', 'begin', '    select ' + build_json([
    ('id', 'P61_ID', 'n'), ('code', 'P61_CODE', 's'), ('name', 'P61_NAME', 's'), ('name_en', 'P61_NAME_EN', 's'), ('type', 'P61_TYPE', 's'), ('dept', 'P61_DEPT', 'n'),
    ('modality', 'P61_MOD', 's'), ('price', 'P61_PRICE', 'n'), ('billing_code', 'P61_BCODE', 's'), ('sample', 'P61_SAMPLE', 's'),
    ('tat', 'P61_TAT', 'n'), ('range', 'P61_RANGE', 's'), ('approval', 'P61_APR', 's'), ('status', 'P61_STATUS', 's')]) + ' into l_doc from dual;',
    '    l := noona_his_pkg.save_service(l_doc);', 'end;'], when_button=b, success='تم حفظ الخدمة')
fm = p.static('مواد الخدمة (تصرف من مستودع القسم عند الإنجاز)', 15)
p.select('P61_MSRV', fm, 10, 'الخدمة', lov_sql=SERVICE_LOV, submit=True)
p.select('P61_ITEM', fm, 20, 'المادة (كاشف، أنابيب، أفلام، مستلزمات)', lov_sql=ITEM_LOV)
p.number('P61_MQTY', fm, 30, 'الكمية لكل خدمة (0 = حذف)')
b_m = p.button(fm, 10, 'SET_MAT', 'حفظ المادة')
p.process(20, 'AFTER_SUBMIT', 'Material', 'noona_his_pkg.set_material(to_number(:P61_MSRV), to_number(:P61_ITEM), to_number(:P61_MQTY));',
          when_button=b_m, success='تم حفظ مادة الخدمة')
p.ir('مواد الخدمة المختارة', 17, [
    "select m.id, i.name_ar as item, m.quantity, u.name_ar as uom, noona_inv_pkg.avg_cost(m.item_id) as cost",
    "  from his_service_material m join inv_item i on i.id = m.item_id join inv_uom u on u.id = i.base_uom_id where m.service_id = :P61_MSRV"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ITEM', 'المادة', {}), ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('UOM', 'الوحدة', {}),
     ('COST', 'متوسط التكلفة', {'type': 'NUMBER'})], titled=True, rows=20)
p.ir('الخدمات', 20, [
    "select s.id, s.code, s.name_ar, s.name_en, noona_his_pkg.type_label(s.service_type) as stype, noona_his_pkg.modality_label(s.modality) as modality,",
    "       d.name_ar as dept, s.price, s.billing_code, s.turnaround_hours, case s.needs_approval when 'Y' then 'نعم' end as approval,",
    "       (select count(*) from his_service_material m where m.service_id = s.id) as materials,",
    "       case s.status_code when 'ACTIVE' then 'نشط' else 'موقوف' end as status",
    f"  from his_service s left join his_department d on d.id = s.department_id where s.company_id = {CO} order by s.service_type, s.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الخدمة', {}), ('NAME_EN', 'الاسم بالإنجليزية', {}), ('STYPE', 'النوع', {}), ('MODALITY', 'الجهاز', {}),
     ('DEPT', 'القسم', {}), ('PRICE', 'السعر', {'type': 'NUMBER'}), ('BILLING_CODE', 'رمز الفوترة', {}), ('TURNAROUND_HOURS', 'زمن النتيجة', {'type': 'NUMBER'}),
     ('APPROVAL', 'موافقة', {}), ('MATERIALS', 'المواد', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], titled=True)
p.branch(10, url(61, 'P61_MSRV', '&P61_MSRV.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 62) الأطباء وساعات العمل
p = app.page(62, 'Doctors', 'DOCTORS', 'الأطباء وساعات العمل', scheme=HIS)
f = p.static('طبيب جديد / تعديل', 10)
p.select('P62_ID', f, 5, 'تعديل طبيب', lov_sql=DOCTOR_LOV.replace(" and d.status_code = 'ACTIVE'", ''), null_text='- طبيب جديد -', submit=True)
p.text('P62_NAME', f, 10, 'الاسم')
p.select('P62_DEPT', f, 20, 'القسم', lov_sql=DEPT_LOV)
p.select('P62_TITLE', f, 30, 'الدرجة/الوظيفة', lov_sql=TITLE_LOV, null_text=None)
p.text('P62_SPEC', f, 40, 'التخصص', maxlen=100)
p.text('P62_LIC', f, 50, 'رقم الترخيص المهني', maxlen=50, width=20)
p.date('P62_LEXP', f, 60, 'انتهاء الترخيص')
p.text('P62_MOBILE', f, 70, 'الجوال', maxlen=30, width=20)
p.select('P62_CONSULT', f, 80, 'خدمة الكشف الافتراضية', lov_sql=SERVICE_LOV)
p.number('P62_COMM', f, 90, 'نسبة الطبيب %')
p.text('P62_USER', f, 100, 'مستخدم الدخول', maxlen=128, width=20)
p.select('P62_STATUS', f, 110, 'الحالة', lov_sql='STATIC2:نشط;ACTIVE,في إجازة;ON_LEAVE,موقوف;INACTIVE', null_text=None)
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', ['begin',
    "    select name_ar, department_id, title, specialty, license_no, to_char(license_expiry, 'YYYY-MM-DD'), mobile, consult_service_id, commission_pct,",
    '           user_name, status_code into :P62_NAME, :P62_DEPT, :P62_TITLE, :P62_SPEC, :P62_LIC, :P62_LEXP, :P62_MOBILE, :P62_CONSULT, :P62_COMM,',
    f'           :P62_USER, :P62_STATUS from his_doctor where id = :P62_ID and company_id = {CO};', 'exception when no_data_found then null;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('id', 'P62_ID', 'n'), ('name', 'P62_NAME', 's'), ('dept', 'P62_DEPT', 'n'), ('title', 'P62_TITLE', 's'), ('specialty', 'P62_SPEC', 's'),
    ('license', 'P62_LIC', 's'), ('license_expiry', 'P62_LEXP', 's'), ('mobile', 'P62_MOBILE', 's'), ('consult_service', 'P62_CONSULT', 'n'),
    ('commission', 'P62_COMM', 'n'), ('user', 'P62_USER', 's'), ('status', 'P62_STATUS', 's')]) + ' into l_doc from dual;',
    '    :P62_ID := noona_his_pkg.save_doctor(l_doc);', 'end;'], when_button=b, success='تم حفظ الطبيب')
fs = p.static('ساعات العمل', 15, condition=':P62_ID is not null')
p.select('P62_DAY', fs, 10, 'اليوم', lov_sql=DAY_LOV, null_text=None)
p.text('P62_FROM', fs, 20, 'من (HH24:MI)', maxlen=5, width=8)
p.text('P62_TO', fs, 30, 'إلى (HH24:MI)', maxlen=5, width=8)
p.number('P62_SLOT', fs, 40, 'مدة الموعد بالدقائق')
p.text('P62_ROOM', fs, 50, 'الغرفة', maxlen=50, width=12)
b_s = p.button(fs, 10, 'SET_HOURS', 'حفظ الفترة', hot=True)
b_c = p.button(fs, 20, 'CLEAR_DAY', 'مسح اليوم')
p.process(20, 'AFTER_SUBMIT', 'Hours', 'noona_his_pkg.set_schedule(:P62_ID, to_number(:P62_DAY), :P62_FROM, :P62_TO, nvl(to_number(:P62_SLOT), 15), :P62_ROOM);',
          when_button=b_s, success='حفظت ساعات العمل')
p.process(30, 'AFTER_SUBMIT', 'Clear', 'noona_his_pkg.clear_schedule(:P62_ID, to_number(:P62_DAY));', when_button=b_c, success='مسحت فترات اليوم')
p.ir('ساعات عمل الطبيب', 17, [
    "select s.id, case s.weekday when 1 then 'الأحد' when 2 then 'الاثنين' when 3 then 'الثلاثاء' when 4 then 'الأربعاء' when 5 then 'الخميس'",
    "       when 6 then 'الجمعة' else 'السبت' end as day, s.from_time, s.to_time, s.slot_minutes, s.room",
    "  from his_doctor_schedule s where s.doctor_id = :P62_ID order by s.weekday, s.from_time"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DAY', 'اليوم', {}), ('FROM_TIME', 'من', {}), ('TO_TIME', 'إلى', {}),
     ('SLOT_MINUTES', 'مدة الموعد', {'type': 'NUMBER'}), ('ROOM', 'الغرفة', {})], titled=True, rows=20)
p.ir('الأطباء', 20, [
    "select d.id, d.code, d.name_ar, p.name_ar as dept, d.specialty, d.license_no, d.license_expiry,",
    "       (select listagg(case s.weekday when 1 then 'أحد' when 2 then 'اثنين' when 3 then 'ثلاثاء' when 4 then 'أربعاء' when 5 then 'خميس'",
    "        when 6 then 'جمعة' else 'سبت' end || ' ' || s.from_time || '-' || s.to_time, '، ') within group (order by s.weekday, s.from_time)",
    "          from his_doctor_schedule s where s.doctor_id = d.id) as hours,",
    "       case d.status_code when 'ACTIVE' then 'نشط' when 'ON_LEAVE' then 'في إجازة' else 'موقوف' end as status",
    f"  from his_doctor d join his_department p on p.id = d.department_id where d.company_id = {CO} order by p.name_ar, d.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الطبيب', {}), ('DEPT', 'القسم', {}), ('SPECIALTY', 'التخصص', {}),
     ('LICENSE_NO', 'الترخيص', {}), ('LICENSE_EXPIRY', 'انتهاء الترخيص', {'type': 'DATE'}), ('HOURS', 'ساعات العمل', {}), ('STATUS', 'الحالة', {})],
    titled=True)
p.branch(10, url(62, 'P62_ID', '&P62_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 63) شركات التأمين والجهات المتعاقدة
p = app.page(63, 'Payers', 'PAYERS', 'شركات التأمين والجهات المتعاقدة', scheme=HIS)
f = p.static('الجهة', 10)
p.select('P63_ID', f, 5, 'تعديل جهة', lov_sql=PAYER_LOV, null_text='- جهة جديدة -', submit=True)
p.text('P63_CODE', f, 10, 'الرمز', maxlen=30, width=12)
p.text('P63_NAME', f, 20, 'الاسم')
p.select('P63_TYPE', f, 30, 'النوع', lov_sql=PAYER_TYPE_LOV, null_text=None)
p.number('P63_DISC', f, 40, 'الخصم العام على الأسعار %')
p.number('P63_DAYS', f, 50, 'مهلة سداد المطالبات (يوم)')
p.text('P63_CNO', f, 60, 'رقم العقد', maxlen=50, width=15)
p.date('P63_FROM', f, 70, 'بداية العقد')
p.date('P63_TO', f, 80, 'نهاية العقد')
p.text('P63_PHONE', f, 90, 'الهاتف', maxlen=30, width=15)
p.text('P63_EMAIL', f, 100, 'البريد', maxlen=320)
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(5, 'BEFORE_HEADER', 'Load', ['begin',
    "    select code, name_ar, payer_type, discount_pct, claim_days, contract_no, to_char(contract_from, 'YYYY-MM-DD'), to_char(contract_to, 'YYYY-MM-DD'),",
    '           phone, email into :P63_CODE, :P63_NAME, :P63_TYPE, :P63_DISC, :P63_DAYS, :P63_CNO, :P63_FROM, :P63_TO, :P63_PHONE, :P63_EMAIL',
    f'      from his_payer where id = :P63_ID and company_id = {CO};', 'exception when no_data_found then null;', 'end;'])
p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob;', 'begin', '    select ' + build_json([
    ('id', 'P63_ID', 'n'), ('code', 'P63_CODE', 's'), ('name', 'P63_NAME', 's'), ('type', 'P63_TYPE', 's'), ('discount', 'P63_DISC', 'n'),
    ('claim_days', 'P63_DAYS', 'n'), ('contract', 'P63_CNO', 's'), ('from', 'P63_FROM', 's'), ('to', 'P63_TO', 's'), ('phone', 'P63_PHONE', 's'),
    ('email', 'P63_EMAIL', 's')]) + ' into l_doc from dual;', '    :P63_ID := noona_his_pkg.save_payer(l_doc);', 'end;'], when_button=b,
    success='تم حفظ الجهة وحساب مطالباتها')
fp = p.static('فئة تغطية', 15, condition=':P63_ID is not null')
p.text('P63_PCODE', fp, 10, 'رمز الفئة (VIP، A، B...)', maxlen=30, width=10)
p.text('P63_PNAME', fp, 20, 'اسم الفئة')
p.number('P63_PCT', fp, 30, 'نسبة تحمل المريض %')
p.number('P63_MAX', fp, 40, 'الحد الأعلى لتحمل المريض في الزيارة')
p.number('P63_ALIM', fp, 50, 'تحتاج موافقة فوق مبلغ')
p.text('P63_EXCL', fp, 60, 'أنواع غير مغطاة (DENTAL,MEDICATION...)', maxlen=500)
b_pl = p.button(fp, 10, 'ADD_PLAN', 'حفظ الفئة')
p.process(20, 'AFTER_SUBMIT', 'Plan', ['declare l number;', 'begin',
    '    select min(id) into l from his_payer_plan where payer_id = :P63_ID and code = upper(trim(:P63_PCODE));',
    '    l := noona_his_pkg.save_plan(l, :P63_ID, :P63_PCODE, :P63_PNAME, to_number(:P63_PCT), to_number(:P63_MAX), to_number(:P63_ALIM), :P63_EXCL);',
    'end;'], when_button=b_pl, success='حفظت الفئة')
fx = p.static('سعر عقد لخدمة', 17, condition=':P63_ID is not null')
p.select('P63_SRV', fx, 10, 'الخدمة', lov_sql=SERVICE_LOV)
p.number('P63_PRICE', fx, 20, 'سعر العقد (فارغ = النقدي بعد الخصم)')
p.yesno('P63_NCOV', fx, 30, 'غير مغطاة')
p.yesno('P63_NAPR', fx, 40, 'تحتاج موافقة')
b_px = p.button(fx, 10, 'SET_PRICE', 'حفظ السعر')
p.process(30, 'AFTER_SUBMIT', 'Price', "noona_his_pkg.set_payer_price(:P63_ID, to_number(:P63_SRV), to_number(:P63_PRICE), case :P63_NCOV when 'Y' then 'N' else 'Y' end, :P63_NAPR);",
          when_button=b_px, success='حفظ سعر العقد')
p.ir('فئات الجهة', 18, [
    "select p.id, p.code, p.name_ar, p.patient_share_pct, p.max_patient_share, p.approval_limit, p.excluded_types,",
    "       (select count(*) from his_patient x where x.payer_plan_id = p.id) as patients",
    "  from his_payer_plan p where p.payer_id = :P63_ID order by p.code"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الفئة', {}), ('PATIENT_SHARE_PCT', 'تحمل المريض %', {'type': 'NUMBER'}),
     ('MAX_PATIENT_SHARE', 'الحد الأعلى', {'type': 'NUMBER'}), ('APPROVAL_LIMIT', 'موافقة فوق', {'type': 'NUMBER'}), ('EXCLUDED_TYPES', 'غير مغطى', {}),
     ('PATIENTS', 'المرضى', {'type': 'NUMBER'})], titled=True, rows=20)
p.ir('أسعار العقد', 19, [
    "select x.id, s.code, s.name_ar, s.price as cash_price, x.price, case x.is_covered when 'Y' then 'مغطاة' else 'غير مغطاة' end as covered,",
    "       case x.needs_approval when 'Y' then 'نعم' end as approval",
    "  from his_payer_price x join his_service s on s.id = x.service_id where x.payer_id = :P63_ID order by s.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الخدمة', {}), ('CASH_PRICE', 'النقدي', {'type': 'NUMBER'}),
     ('PRICE', 'سعر العقد', {'type': 'NUMBER'}), ('COVERED', 'التغطية', {}), ('APPROVAL', 'موافقة', {})], titled=True, rows=20)
p.ir('الجهات', 20, [
    "select y.id, y.code, y.name_ar, case y.payer_type when 'INSURANCE' then 'تأمين' when 'TPA' then 'إدارة مطالبات' when 'CORPORATE' then 'شركة متعاقدة'",
    "       when 'GOVERNMENT' then 'حكومية' else 'خيرية' end as ptype, y.discount_pct, y.contract_no, y.contract_to,",
    "       noona_sal_pkg.customer_balance(y.customer_account_id) as balance,",
    "       (select count(*) from his_payer_plan p where p.payer_id = y.id) as plans",
    f"  from his_payer y where y.company_id = {CO} order by y.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الجهة', {}), ('PTYPE', 'النوع', {}), ('DISCOUNT_PCT', 'الخصم %', {'type': 'NUMBER'}),
     ('CONTRACT_NO', 'العقد', {}), ('CONTRACT_TO', 'نهاية العقد', {'type': 'DATE'}), ('BALANCE', 'المطالبات المستحقة', {'type': 'NUMBER'}),
     ('PLANS', 'الفئات', {'type': 'NUMBER'})], titled=True)
p.branch(10, url(63, 'P63_ID', '&P63_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 70) التقارير والمطالبات
p = app.page(70, 'Reports', 'REPORTS', 'التقارير والمطالبات', scheme=HIS, protection='N')
f = p.static('المرشحات', 5, opts='#DEFAULT#:nn-rpt-filters')
p.select('P70_REPORT', f, 5, 'التقرير', lov_sql='STATIC2:الإيرادات حسب القسم والجهة والطبيب;REV,كشف مطالبة جهة;CLAIM', null_text=None, submit=True)
p.date('P70_FROM', f, 10, 'من تاريخ')
p.date('P70_TO', f, 20, 'إلى تاريخ')
p.select('P70_PAYER', f, 30, 'الجهة', lov_sql=PAYER_LOV)
p.button(f, 10, 'RUN', 'عرض', hot=True)
p.button(f, 20, 'PRINT', 'طباعة', redirect='javascript:window.print();')
p.process(5, 'BEFORE_HEADER', 'Defaults', [":P70_REPORT := nvl(:P70_REPORT, 'REV');",
    ":P70_FROM := nvl(:P70_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));", ":P70_TO := nvl(:P70_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
p.dynamic('التقرير', 10, ["return case :P70_REPORT when 'CLAIM' then noona_his_pkg.claims_html(:P70_PAYER, to_date(:P70_FROM, 'YYYY-MM-DD'), to_date(:P70_TO, 'YYYY-MM-DD'))",
                          "       else noona_his_pkg.revenue_html(to_date(:P70_FROM, 'YYYY-MM-DD'), to_date(:P70_TO, 'YYYY-MM-DD')) end;"],
          hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')

# =============================================================== القائمة
app.nav_item('لوحة المستشفى', 1, 'fa-hospital-o', 10)
rc = app.nav_item('الاستقبال والمواعيد', None, 'fa-calendar', 20)
app.nav_item('لوحة المواعيد', 20, 'fa-calendar-check-o', 21, parent=rc)
app.nav_item('حجز موعد', 21, 'fa-plus', 22, parent=rc)
app.nav_item('المرضى', 10, 'fa-user', 23, parent=rc)
app.nav_item('زيارة جديدة', 32, 'fa-user-plus', 24, parent=rc)
cl = app.nav_item('الزيارات والمحاسبة', None, 'fa-stethoscope', 30)
app.nav_item('الزيارات', 30, 'fa-list', 31, parent=cl)
app.nav_item('المحاسبة', 40, 'fa-money', 32, parent=cl)
app.nav_item('قوائم المعامل والأشعة والأقسام', 50, 'fa-flask', 40)
st = app.nav_item('الإعداد', None, 'fa-cogs', 50)
app.nav_item('الأقسام والعيادات والمعامل', 60, 'fa-sitemap', 51, parent=st)
app.nav_item('دليل الخدمات ومواردها', 61, 'fa-book', 52, parent=st)
app.nav_item('الأطباء وساعات العمل', 62, 'fa-user-md', 53, parent=st)
app.nav_item('التأمين والجهات المتعاقدة', 63, 'fa-shield', 54, parent=st)
app.nav_item('مكونات التحاليل وقوالب التقارير', 64, 'fa-flask', 55, parent=st)
app.nav_item('الأجهزة الطبية والمعايرة', 66, 'fa-wrench', 56, parent=st)
app.nav_item('التقارير والمطالبات', 70, 'fa-bar-chart', 60)

import his2_pages, his3_pages, his4_pages
his2_pages.build(app, url, link, HIS, dict(PATIENT_LOV=PATIENT_LOV, DOCTOR_LOV=DOCTOR_LOV, DEPT_LOV=DEPT_LOV, PAYER_LOV=PAYER_LOV,
                                          MODALITY_LOV=MODALITY_LOV))
his3_pages.build(app, url, link, HIS, dict(PATIENT_LOV=PATIENT_LOV, DOCTOR_LOV=DOCTOR_LOV, PAYER_LOV=PAYER_LOV, STATUS_LOV=STATUS_LOV))
his4_pages.build(app, url, link, HIS, {})
nr = app.nav_item('التمريض والتنويم', None, 'fa-user-md', 46)
app.nav_item('محطة التمريض', 75, 'fa-bell', 461, parent=nr)
app.nav_item('الملف الإلكتروني للمنوم', 76, 'fa-folder-open', 462, parent=nr)
app.nav_item('ورديات التمريض والمناوبات', 74, 'fa-calendar', 463, parent=nr)
app.nav_item('لوحة الطوارئ', 59, 'fa-ambulance', 25, parent=rc)
app.nav_item('الملف الطبي للمريض', 12, 'fa-folder-open-o', 26, parent=rc)
app.nav_item('التمريض والعلامات الحيوية', 35, 'fa-heart', 33, parent=cl)
app.nav_item('التقارير الطبية والإجازات', 36, 'fa-file-text-o', 34, parent=cl)
app.nav_item('عمولات الأطباء', 73, 'fa-percent', 61)
app.nav_item('الربط الإلكتروني', 67, 'fa-plug', 57, parent=st)
app.nav_item('سجل رسائل الربط', 68, 'fa-exchange', 58, parent=st)

# التسعير والعروض والباقات للخدمات الطبية والأصناف (90-94)
import prc_pages
prc_pages.build(app, url, HIS, 90, ('HIS', 'ITEMS'), 'HIS')
prc_pages.nav(app, 90, 70)

# التحليلات والتنبؤ (NOONA_ANL_PKG + anl.js)
import anl_pages
anl_pages.add(app, ['HIS'], HIS, 11)

app.finalize()
print('NOONA_HIS built:', len(app.pages), 'pages')
