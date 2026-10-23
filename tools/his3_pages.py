"""صفحات المرحلة الثالثة في تطبيق المستشفى (141): الملف الطبي، التمريض والعلامات الحيوية وإعطاء الأدوية، التقارير الطبية والإجازات،
طباعة الوصفة، لوحة الطوارئ، قنوات الربط الإلكتروني وسجل رسائلها، وعمولات الأطباء. المنطق في NOONA_HIS_CLIN_PKG و NOONA_HIS_LINK_PKG.
"""

CO = 'noona_his_pkg.company'


def build(app, url, link, scheme, L):
    VISIT_LOV = (f"select v.visit_no || ' - ' || p.name_ar || ' (' || p.mrn || ')' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id "
                 f"where v.company_id = {CO} and v.status_code <> 'CANCELLED' and v.visit_at >= sysdate - 60 order by v.visit_at desc")
    LINE_LOV = ("select nvl(i.name_en, i.name_ar) || ' - ' || l.dose || ' ' || l.frequency || ' (' || x.rx_no || ')' d, l.id r "
                "from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id "
                "where x.visit_id = :P35_VISIT and x.status_code not in ('CANCELLED', 'EXPIRED') order by x.rx_at, l.line_no")
    NURSE_LOV = (f"select name_ar d, id r from his_doctor where company_id = {CO} and status_code = 'ACTIVE' order by case title when 'NURSE' then 0 else 1 end, name_ar")
    CHANNEL_LOV = f"select code || ' - ' || name_ar d, id r from his_integration where company_id = {CO} order by code"
    INS_CHANNEL_LOV = f"select code || ' - ' || name_ar d, id r from his_integration where company_id = {CO} and kind = 'INSURANCE' order by code"
    TRIAGE_LOV = 'STATIC2:1 - Resuscitation;1,2 - Emergent;2,3 - Urgent;3,4 - Less urgent;4,5 - Non urgent;5'

    # =========================================================== 12) الملف الطبي
    p = app.page(12, 'Patient Record', 'PATIENT-RECORD', 'Patient record - الملف الطبي', scheme=scheme, protection='N')
    f = p.static('Patient', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P12_ID', f, 10, 'المريض', lov_sql=L['PATIENT_LOV'], submit=True)
    p.dynamic('Record', 10, 'return noona_his_clin_pkg.patient_history_html(:P12_ID);', hide_header=True,
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area', condition=':P12_ID is not null')
    p.button(f, 10, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(f, 20, 'EDIT', 'بيانات المريض', redirect="f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:&P12_ID.")

    # =========================================================== 35) التمريض: الفرز والعلامات الحيوية والملاحظات وإعطاء الأدوية
    p = app.page(35, 'Nursing', 'NURSING', 'Nursing chart - التمريض', scheme=scheme, protection='N')
    hd = p.static('Visit', 1, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P35_VISIT', hd, 10, 'الزيارة', lov_sql=VISIT_LOV.replace("v.status_code <> 'CANCELLED'", "v.status_code = 'OPEN'"), submit=True)
    p.button(hd, 10, 'VISIT', 'ملف الزيارة', redirect="f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P35_VISIT.")
    OPEN = ':P35_VISIT is not null'
    p.dynamic('ملف الزيارة', 2, 'return noona_his_pkg.visit_html(:P35_VISIT);', hide_header=True, condition=OPEN)
    ft = p.static('Triage (Emergency) - الفرز', 5, condition=OPEN)
    p.select('P35_TRIAGE', ft, 10, 'CTAS level', lov_sql=TRIAGE_LOV)
    b_tr = p.button(ft, 10, 'TRIAGE', 'Save triage')
    p.process(10, 'AFTER_SUBMIT', 'Triage', 'noona_his_clin_pkg.set_triage(:P35_VISIT, :P35_TRIAGE);', when_button=b_tr, success='Triage saved')
    fv = p.static('Vital signs - العلامات الحيوية', 10, condition=OPEN)
    p.text('P35_BP', fv, 10, 'BP (e.g. 120/80)', maxlen=10, width=8)
    p.number('P35_HR', fv, 20, 'Pulse (bpm)')
    p.number('P35_TEMP', fv, 30, 'Temp (°C)')
    p.number('P35_RR', fv, 40, 'Resp. rate')
    p.number('P35_SPO2', fv, 50, 'SpO2 %')
    p.number('P35_WT', fv, 60, 'Weight (kg)')
    p.number('P35_HT', fv, 70, 'Height (cm)')
    p.number('P35_PAIN', fv, 80, 'Pain (0-10)')
    p.number('P35_GLU', fv, 90, 'RBS (mg/dL)')
    p.text('P35_VNOTES', fv, 100, 'Notes', maxlen=500)
    b_v = p.button(fv, 10, 'SAVE_VITALS', 'Save vital signs', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Vitals', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('visit' value to_number(:P35_VISIT), 'bp' value :P35_BP, 'pulse' value to_number(:P35_HR), 'temp' value to_number(:P35_TEMP),",
        "           'rr' value to_number(:P35_RR), 'spo2' value to_number(:P35_SPO2), 'weight' value to_number(:P35_WT), 'height' value to_number(:P35_HT),",
        "           'pain' value to_number(:P35_PAIN), 'glucose' value to_number(:P35_GLU), 'notes' value :P35_VNOTES returning clob) into l_doc from dual;",
        '    l := noona_his_clin_pkg.record_vitals(l_doc);', 'end;'], when_button=b_v, success='Vital signs saved')
    p.dynamic('Vitals chart', 12, 'return noona_his_clin_pkg.vitals_html(:P35_VISIT);', condition=OPEN)
    fn = p.static('Clinical notes - الملاحظات', 20, condition=OPEN)
    p.select('P35_NTYPE', fn, 10, 'Type', lov_sql='STATIC2:Nursing;NURSING,Progress;PROGRESS,Consultation;CONSULTATION,Procedure;PROCEDURE,Discharge;DISCHARGE',
             null_text=None)
    p.select('P35_AUTHOR', fn, 20, 'Author', lov_sql=NURSE_LOV, null_text='- current user -')
    p.textarea('P35_NOTE', fn, 30, 'Note (English)', rows=3)
    b_n = p.button(fn, 10, 'ADD_NOTE', 'Add note')
    p.process(30, 'AFTER_SUBMIT', 'Note', ['declare l number;', 'begin',
        '    l := noona_his_clin_pkg.add_note(:P35_VISIT, :P35_NTYPE, :P35_NOTE, to_number(:P35_AUTHOR));', '    :P35_NOTE := null;', 'end;'],
        when_button=b_n, success='Note added')
    p.dynamic('Notes', 22, 'return noona_his_clin_pkg.notes_html(:P35_VISIT);', condition=OPEN)
    fm = p.static('Medication administration (MAR) - إعطاء الأدوية', 30, condition=OPEN)
    p.select('P35_LINE', fm, 10, 'Medicine', lov_sql=LINE_LOV)
    p.select('P35_OUTCOME', fm, 20, 'Outcome', lov_sql='STATIC2:Given;GIVEN,Held;HELD,Refused;REFUSED,Missed;MISSED', null_text=None)
    p.select('P35_ROUTE', fm, 30, 'Route', lov_sql='STATIC2:Oral;ORAL,IV;IV,IM;IM,SC;SC,Inhaled;INHALED,Topical;TOPICAL,Rectal;RECTAL,Other;OTHER', null_text=None)
    p.text('P35_DOSE', fm, 40, 'Dose given', maxlen=100, width=12)
    p.select('P35_NURSE', fm, 50, 'Nurse', lov_sql=NURSE_LOV, null_text='- current user -')
    p.text('P35_MNOTES', fm, 60, 'Notes / reason', maxlen=500)
    b_m = p.button(fm, 10, 'GIVE', 'Record administration')
    p.process(40, 'AFTER_SUBMIT', 'MAR', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('line' value to_number(:P35_LINE), 'outcome' value :P35_OUTCOME, 'route' value :P35_ROUTE, 'dose' value :P35_DOSE,",
        "           'nurse' value to_number(:P35_NURSE), 'notes' value :P35_MNOTES returning clob) into l_doc from dual;",
        '    l := noona_his_clin_pkg.give_medication(l_doc);', 'end;'], when_button=b_m, success='Administration recorded')
    p.dynamic('MAR', 32, 'return noona_his_clin_pkg.mar_html(:P35_VISIT);', condition=OPEN)
    p.process(5, 'BEFORE_HEADER', 'Load', ['begin', f'    select triage_level into :P35_TRIAGE from his_visit where id = :P35_VISIT and company_id = {CO};',
                                           'exception when no_data_found then null;', 'end;'])
    p.onload("$('#P35_BP,#P35_VNOTES,#P35_NOTE,#P35_DOSE,#P35_MNOTES').attr('dir', 'ltr');")
    p.branch(10, url(35, 'P35_VISIT', '&P35_VISIT.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 36) التقارير الطبية والإجازات
    p = app.page(36, 'Medical Certificates', 'CERTIFICATES', 'Medical reports & sick leave - التقارير الطبية', scheme=scheme, protection='N')
    f = p.static('Issue', 10)
    p.select('P36_VISIT', f, 10, 'الزيارة', lov_sql=VISIT_LOV, required=True)
    p.select('P36_TYPE', f, 20, 'Type', lov_sql='STATIC2:Sick leave;SICK_LEAVE,Medical report;MEDICAL_REPORT,Referral letter;REFERRAL,'
             'Fitness certificate;FITNESS,Companion certificate;COMPANION', null_text=None)
    p.date('P36_FROM', f, 30, 'From')
    p.date('P36_TO', f, 40, 'To')
    p.text('P36_REF', f, 50, 'Referred to (hospital / specialty)', maxlen=200)
    p.select('P36_DOCTOR', f, 60, 'Doctor', lov_sql=L['DOCTOR_LOV'], null_text='- visit doctor -')
    p.textarea('P36_BODY', f, 70, 'Text (English; empty = standard wording)', rows=4)
    p.hidden('P36_ID', f, 90, protected=False)
    b_i = p.button(f, 10, 'ISSUE', 'Issue', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Issue', ['declare l_doc clob;', 'begin',
        "    select json_object('visit' value to_number(:P36_VISIT), 'type' value :P36_TYPE, 'from' value :P36_FROM, 'to' value :P36_TO,",
        "           'referral_to' value :P36_REF, 'doctor' value to_number(:P36_DOCTOR), 'body' value :P36_BODY returning clob) into l_doc from dual;",
        '    :P36_ID := noona_his_clin_pkg.issue_certificate(l_doc);', 'end;'], when_button=b_i, success='Issued')
    fc = p.static('Cancel', 15)
    p.select('P36_CERT', fc, 10, 'Certificate', lov_sql=(
        "select c.cert_no || ' - ' || noona_his_clin_pkg.cert_type_label(c.cert_type) d, c.id r from his_certificate c "
        f"where c.company_id = {CO} and c.status_code = 'ISSUED' and c.visit_id = :P36_VISIT order by c.id desc"))
    p.text('P36_REASON', fc, 20, 'Reason', maxlen=200)
    b_c = p.button(fc, 10, 'CANCEL_CERT', 'Cancel certificate')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_his_clin_pkg.cancel_certificate(:P36_CERT, :P36_REASON);', when_button=b_c, success='Cancelled')
    p.ir('Certificates', 20, [
        "select c.id, c.cert_no, noona_his_clin_pkg.cert_type_label(c.cert_type) as cert_type, c.issued_on, p.name_ar as patient, p.mrn,",
        "       c.from_date, c.to_date, c.days, c.referral_to, d.name_ar as doctor, c.verify_code,",
        "       case c.status_code when 'ISSUED' then 'Issued' else 'Cancelled' end as status,",
        "       '<span class=\"fa fa-print\" aria-hidden=\"true\"></span> Print' as prn",
        "  from his_certificate c join his_visit v on v.id = c.visit_id join his_patient p on p.id = v.patient_id left join his_doctor d on d.id = c.doctor_id",
        f" where c.company_id = {CO} and (:P36_VISIT is null or c.visit_id = :P36_VISIT) order by c.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CERT_NO', 'No.', {}), ('CERT_TYPE', 'Type', {}), ('ISSUED_ON', 'Issued', {'type': 'DATE'}),
         ('PATIENT', 'المريض', {}), ('MRN', 'MRN', {}), ('FROM_DATE', 'From', {'type': 'DATE'}), ('TO_DATE', 'To', {'type': 'DATE'}),
         ('DAYS', 'Days', {'type': 'NUMBER'}), ('REFERRAL_TO', 'Referred to', {}), ('DOCTOR', 'Doctor', {}), ('VERIFY_CODE', 'Code', {}), ('STATUS', 'Status', {}),
         ('PRN', 'Print', {'html': True, 'link': ('f?p=&APP_ID.:37:&SESSION.::&DEBUG.:RP,37:P37_ID:#ID#', '#PRN#')})], titled=True)
    p.onload("$('#P36_REF,#P36_BODY,#P36_REASON').attr('dir', 'ltr');")
    p.branch(5, url(37, 'P37_ID', '&P36_ID.'), when_button=b_i)
    p.branch(10, url(36, 'P36_VISIT', '&P36_VISIT.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 37) طباعة التقرير الطبي / 38) طباعة الوصفة
    for pid, alias, title, item, fn in ((37, 'CERTIFICATE', 'Medical certificate', 'P37_ID', 'noona_his_clin_pkg.certificate_html'),
                                        (38, 'RX-PRINT', 'Prescription', 'P38_ID', 'noona_his_care_pkg.rx_html')):
        p = app.page(pid, title, alias, title, scheme=scheme, protection='N')
        f = p.static(title, 10, hide_header=True)
        p.hidden(item, f, 1, protected=False)
        p.dynamic(title, 5, f'return {fn}(:{item});', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
        p.button(f, 10, 'PRINT', 'طباعة', hot=True, redirect='javascript:window.print();')

    # =========================================================== 59) لوحة الطوارئ
    p = app.page(59, 'Emergency Board', 'ER-BOARD', 'لوحة الطوارئ', scheme=scheme, protection='N')
    f = p.static('إجراءات', 3, hide_header=True)
    p.button(f, 10, 'NEW', 'تسجيل مريض طوارئ', hot=True, redirect=url(32, clear='RP,32'))
    p.button(f, 20, 'REFRESH', 'تحديث', redirect=url(59))
    p.dynamic('الطوارئ', 5, 'return noona_his_clin_pkg.er_board_html;', hide_header=True)
    p.onload(["document.addEventListener('click', function (e) {",
              "  var b = e.target.closest('.nn-his-ercard[data-visit]'); if (!b) return;",
              "  location.href = 'f?p=' + apex.env.APP_ID + ':35:' + apex.env.APP_SESSION + '::NO:RP,35:P35_VISIT:' + b.dataset.visit;",
              "});",
              "setTimeout(function () { location.reload(); }, 120000);"])

    # =========================================================== 67) قنوات الربط الإلكتروني
    p = app.page(67, 'Integrations', 'INTEGRATIONS', 'الربط الإلكتروني (التأمين والوصفات)', scheme=scheme, protection='N')
    f = p.static('قناة ربط', 10)
    p.select('P67_ID', f, 5, 'تعديل قناة', lov_sql=CHANNEL_LOV, null_text='- قناة جديدة -', submit=True)
    p.text('P67_CODE', f, 10, 'الرمز', maxlen=30, width=12)
    p.text('P67_NAME', f, 20, 'الاسم')
    p.select('P67_KIND', f, 30, 'النوع', lov_sql='STATIC2:تأمين (أهلية وموافقات ومطالبات);INSURANCE,منصة الوصفات الإلكترونية;ERX', null_text=None)
    p.select('P67_MODE', f, 40, 'طريقة الربط', lov_sql='STATIC2:محاكاة للتجربة;SIMULATOR,REST (JSON);REST,بريد إلكتروني;EMAIL', null_text=None)
    p.text('P67_URL', f, 50, 'عنوان الخدمة (REST)', maxlen=1000)
    p.select('P67_AUTH', f, 60, 'المصادقة', lov_sql='STATIC2:بدون;NONE,Basic;BASIC,Bearer token;BEARER,API key;API_KEY', null_text=None)
    p.text('P67_USER', f, 70, 'المستخدم / بريد المرسل', maxlen=200)
    p.password('P67_SECRET', f, 80, 'كلمة المرور أو المفتاح (فارغ = يبقى الحالي)')
    p.text('P67_KEYH', f, 90, 'ترويسة المفتاح (API key)', maxlen=100, width=15)
    p.text('P67_PROV', f, 100, 'رمز المنشأة لدى القناة (Provider ID)', maxlen=100, width=15)
    p.text('P67_EMAIL', f, 110, 'بريد الجهة', maxlen=320)
    p.number('P67_TIMEOUT', f, 120, 'مهلة الاتصال (ثانية)')
    p.text('P67_WALLET', f, 130, 'مسار محفظة الشهادات (اختياري)', maxlen=500)
    p.select('P67_STATUS', f, 140, 'الحالة', lov_sql=L['STATUS_LOV'], null_text=None)
    p.display('P67_SECRET_ST', f, 150, 'السر المحفوظ')
    b_s = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
    b_t = p.button(f, 20, 'TEST', 'اختبار الاتصال')
    p.process(5, 'BEFORE_HEADER', 'Load', ['begin',
        '    select code, name_ar, kind, link_mode, base_url, auth_type, username, key_header, provider_code, email, timeout_sec, wallet_path, status_code,',
        "           case when secret_enc is not null then 'محفوظ (مشفر)' else 'لا يوجد' end",
        '      into :P67_CODE, :P67_NAME, :P67_KIND, :P67_MODE, :P67_URL, :P67_AUTH, :P67_USER, :P67_KEYH, :P67_PROV, :P67_EMAIL, :P67_TIMEOUT, :P67_WALLET,',
        '           :P67_STATUS, :P67_SECRET_ST',
        f'      from his_integration where id = :P67_ID and company_id = {CO};', 'exception when no_data_found then null;', 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', ['declare l_doc clob;', 'begin',
        "    select json_object('id' value to_number(:P67_ID), 'code' value :P67_CODE, 'name' value :P67_NAME, 'kind' value :P67_KIND, 'mode' value :P67_MODE,",
        "           'url' value :P67_URL, 'auth' value :P67_AUTH, 'user' value :P67_USER, 'secret' value :P67_SECRET, 'key_header' value :P67_KEYH,",
        "           'provider' value :P67_PROV, 'email' value :P67_EMAIL, 'timeout' value to_number(:P67_TIMEOUT), 'wallet' value :P67_WALLET,",
        "           'status' value :P67_STATUS returning clob) into l_doc from dual;",
        '    :P67_ID := noona_his_link_pkg.save_integration(l_doc);', '    :P67_SECRET := null;', 'end;'], when_button=b_s, success='حفظت القناة')
    p.process(20, 'AFTER_SUBMIT', 'Test', "apex_application.g_print_success_message := 'نتيجة الاختبار: ' || noona_his_link_pkg.test_connection(:P67_ID);",
              when_button=b_t)
    fp = p.static('ربط شركة تأمين أو جهة بالقناة', 20)
    p.select('P67_PAYER', fp, 10, 'الجهة', lov_sql=L['PAYER_LOV'])
    p.select('P67_PCH', fp, 20, 'القناة', lov_sql=INS_CHANNEL_LOV, null_text='- بدون ربط (يدوي) -')
    p.text('P67_LCODE', fp, 30, 'رمز الجهة لدى القناة (Payer ID)', maxlen=100, width=15)
    b_l = p.button(fp, 10, 'LINK', 'حفظ الربط')
    p.process(30, 'AFTER_SUBMIT', 'Link', 'noona_his_link_pkg.set_payer_link(:P67_PAYER, to_number(:P67_PCH), :P67_LCODE);', when_button=b_l,
              success='حفظ ربط الجهة')
    p.ir('القنوات', 30, [
        "select i.id, i.code, i.name_ar, case i.kind when 'ERX' then 'وصفات إلكترونية' else 'تأمين' end as kind,",
        "       case i.link_mode when 'SIMULATOR' then 'محاكاة' when 'REST' then 'REST' else 'بريد' end as link_mode, i.base_url, i.provider_code,",
        "       (select listagg(y.name_ar || nvl2(y.link_code, ' (' || y.link_code || ')', ''), '، ') within group (order by y.name_ar) from his_payer y",
        "         where y.integration_id = i.id) as payers, i.last_ok_at, i.last_error,",
        "       case i.status_code when 'ACTIVE' then 'نشطة' else 'موقوفة' end as status",
        f"  from his_integration i where i.company_id = {CO} order by i.code"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'القناة', {}), ('KIND', 'النوع', {}), ('LINK_MODE', 'الطريقة', {}),
         ('BASE_URL', 'العنوان', {}), ('PROVIDER_CODE', 'رمز المنشأة', {}), ('PAYERS', 'الجهات المرتبطة', {}), ('LAST_OK_AT', 'آخر نجاح', {'type': 'DATE'}),
         ('LAST_ERROR', 'آخر خطأ', {}), ('STATUS', 'الحالة', {})], titled=True)
    p.onload("$('#P67_URL,#P67_USER,#P67_EMAIL,#P67_WALLET,#P67_KEYH,#P67_PROV,#P67_LCODE').attr('dir', 'ltr');")
    p.branch(10, url(67, 'P67_ID', '&P67_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 68) سجل رسائل الربط / 69) الرسالة
    p = app.page(68, 'Integration Log', 'LINK-LOG', 'سجل رسائل الربط', scheme=scheme, protection='N')
    f = p.static('إجراءات', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P68_STATUS', f, 10, 'الحالة', lov_sql='STATIC2:مقبولة;ACCEPTED,قيد المراجعة;PENDING,مرفوضة;REJECTED,خطأ اتصال;ERROR,مرسلة;SENT',
             null_text='الكل', submit=True)
    b_pp = p.button(f, 10, 'PROCESS', 'متابعة الموافقات والمطالبات المعلقة وإعادة الوصفات المتعثرة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Process', ['declare l number;', 'begin', '    l := noona_his_link_pkg.process_pending;',
        "    apex_application.g_print_success_message := 'عولجت ' || l || ' رسالة';", 'end;'], when_button=b_pp)
    p.ir('الرسائل', 10, [
        "select m.id, m.msg_no, noona_his_link_pkg.type_label(m.msg_type) as msg_type, i.name_ar as channel, y.name_ar as payer, m.entity_type, m.entity_id,",
        "       to_char(m.sent_at, 'YYYY-MM-DD HH24:MI:SS') as sent_at, m.http_status, m.attempts, m.external_ref, noona_his_link_pkg.status_label(m.status_code) as status,",
        "       m.outcome",
        "  from his_link_message m join his_integration i on i.id = m.integration_id left join his_payer y on y.id = m.payer_id",
        f" where m.company_id = {CO} and (:P68_STATUS is null or m.status_code = :P68_STATUS) order by m.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('MSG_NO', 'الرسالة', {}), ('MSG_TYPE', 'النوع', {}), ('CHANNEL', 'القناة', {}), ('PAYER', 'الجهة', {}),
         ('ENTITY_TYPE', 'المستند', {}), ('ENTITY_ID', 'المعرف', {'type': 'NUMBER'}), ('SENT_AT', 'الوقت', {}), ('HTTP_STATUS', 'HTTP', {'type': 'NUMBER'}),
         ('ATTEMPTS', 'المحاولات', {'type': 'NUMBER'}), ('EXTERNAL_REF', 'مرجع الجهة', {}), ('STATUS', 'الحالة', {}), ('OUTCOME', 'الخلاصة', {})],
        link=link(69, 'P69_ID'))
    p.branch(10, url(68, 'P68_STATUS', '&P68_STATUS.') + '&success_msg=#SUCCESS_MSG#')

    p = app.page(69, 'Integration Message', 'LINK-MESSAGE', 'رسالة ربط', scheme=scheme, protection='N')
    f = p.static('الإجراءات', 10, hide_header=True)
    p.hidden('P69_ID', f, 1, protected=False)
    p.dynamic('الرسالة', 5, 'return noona_his_link_pkg.message_html(:P69_ID);', hide_header=True)
    b_r = p.button(f, 10, 'RETRY', 'إعادة الإرسال', hot=True,
                   condition="noona_his_link_pkg.can_retry(:P69_ID) = 'Y'")
    p.process(10, 'AFTER_SUBMIT', 'Retry', "apex_application.g_print_success_message := 'النتيجة: ' || noona_his_link_pkg.status_label(noona_his_link_pkg.retry(:P69_ID));",
              when_button=b_r)
    p.button(f, 20, 'BACK', 'السجل', redirect=url(68))
    p.branch(10, url(69, 'P69_ID', '&P69_ID.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 73) عمولات الأطباء
    p = app.page(73, 'Doctor Commissions', 'COMMISSIONS', 'عمولات الأطباء', scheme=scheme, protection='N')
    f = p.static('الفترة', 5, opts='#DEFAULT#:nn-rpt-filters')
    p.date('P73_FROM', f, 10, 'من')
    p.date('P73_TO', f, 20, 'إلى')
    p.select('P73_DOCTOR', f, 30, 'الطبيب', lov_sql=L['DOCTOR_LOV'], null_text='كل الأطباء ذوي النسبة')
    p.button(f, 10, 'SHOW', 'عرض المستحق')
    b_st = p.button(f, 20, 'SETTLE', 'تسوية وقيد الاستحقاق', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [":P73_FROM := nvl(:P73_FROM, to_char(trunc(add_months(sysdate, -1), 'MM'), 'YYYY-MM-DD'));",
                                               ":P73_TO := nvl(:P73_TO, to_char(trunc(sysdate, 'MM') - 1, 'YYYY-MM-DD'));"])
    p.process(10, 'AFTER_SUBMIT', 'Settle', ['declare l number;', 'begin',
        "    l := noona_his_clin_pkg.settle_commissions(to_date(:P73_FROM, 'YYYY-MM-DD'), to_date(:P73_TO, 'YYYY-MM-DD'), to_number(:P73_DOCTOR));",
        "    apex_application.g_print_success_message := 'سويت عمولات ' || l || ' طبيب؛ تصرف بسند صرف من حساب 2111';", 'end;'], when_button=b_st)
    p.dynamic('المستحق غير المسوى', 10, "return noona_his_clin_pkg.commission_preview_html(to_date(:P73_FROM, 'YYYY-MM-DD'), to_date(:P73_TO, 'YYYY-MM-DD'));")
    fc = p.static('إلغاء تسوية', 15)
    p.select('P73_SET', fc, 10, 'التسوية', lov_sql=(
        "select c.doc_no || ' - ' || d.name_ar || ' (' || to_char(c.amount, 'FM999G999G990D00') || ')' d, c.id r from his_commission c "
        f"join his_doctor d on d.id = c.doctor_id where c.company_id = {CO} and c.status_code = 'POSTED' order by c.id desc"))
    p.text('P73_REASON', fc, 20, 'السبب', maxlen=200)
    b_cc = p.button(fc, 10, 'CANCEL_SET', 'إلغاء التسوية وعكس القيد')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_his_clin_pkg.cancel_commission(:P73_SET, :P73_REASON);', when_button=b_cc, success='ألغيت التسوية')
    p.ir('التسويات', 20, [
        "select c.id, c.doc_no, c.doc_date, d.name_ar as doctor, c.period_from, c.period_to, c.base_amount, c.commission_pct, c.amount,",
        "       case c.status_code when 'POSTED' then 'مرحلة' else 'ملغاة' end as status",
        f"  from his_commission c join his_doctor d on d.id = c.doctor_id where c.company_id = {CO} order by c.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'التسوية', {}), ('DOC_DATE', 'التاريخ', {'type': 'DATE'}), ('DOCTOR', 'الطبيب', {}),
         ('PERIOD_FROM', 'من', {'type': 'DATE'}), ('PERIOD_TO', 'إلى', {'type': 'DATE'}), ('BASE_AMOUNT', 'الإيراد', {'type': 'NUMBER'}),
         ('COMMISSION_PCT', 'النسبة', {'type': 'NUMBER'}), ('AMOUNT', 'العمولة', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {})], titled=True)
    p.branch(10, url(73, 'P73_FROM,P73_TO,P73_DOCTOR', '&P73_FROM.,&P73_TO.,&P73_DOCTOR.') + '&success_msg=#SUCCESS_MSG#')
