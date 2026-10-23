"""صفحات المرحلة الثانية في تطبيق المستشفى (141): الوصفات والصيدلية الداخلية، لوحة الأسرة والتنويم، جدول العمليات، خطط العلاج
الطبيعي، إعداد مكونات التحاليل والقوالب، الأجهزة الطبية، دفعات مطالبات التأمين. المنطق في NOONA_HIS_CARE_PKG و NOONA_HIS_CLAIM_PKG.
"""

CO = 'noona_his_pkg.company'


def build(app, url, link, scheme, L):
    """L: قوائم القيم المشتركة من build_his (PATIENT_LOV, DOCTOR_LOV, ...)."""
    OPEN_VISIT_LOV = (f"select v.visit_no || ' - ' || p.name_ar || ' (' || p.mrn || ')' d, v.id r from his_visit v join his_patient p on p.id = v.patient_id "
                      f"where v.company_id = {CO} and v.status_code = 'OPEN' order by v.visit_at desc")
    MED_LOV = ("select nvl(i.name_en, i.name_ar) || ' (' || to_char(c.sale_price, 'FM999G990D00') || ')' d, i.id r from inv_item i "
               f"join inv_item_company c on c.item_id = i.id and c.company_id = {CO} where i.item_type not in ('SERVICE', 'NON_STOCK') "
               "and i.status_code = 'ACTIVE' and i.is_sellable = 'Y' and c.sale_price is not null order by nvl(i.name_en, i.name_ar)")
    BED_FREE_LOV = (f"select d.name_ar || ' - ' || b.bed_no || nvl2(b.room_no, ' (' || b.room_no || ')', '') d, b.id r from his_bed b "
                    f"join his_department d on d.id = b.ward_id where b.company_id = {CO} and b.status_code = 'AVAILABLE' order by d.name_ar, b.bed_no")
    BED_LOV = (f"select d.name_ar || ' - ' || b.bed_no d, b.id r from his_bed b join his_department d on d.id = b.ward_id where b.company_id = {CO} "
               "order by d.name_ar, b.bed_no")
    ADM_LOV = (f"select a.admission_no || ' - ' || p.name_ar || ' - ' || b.bed_no d, a.id r from his_admission a join his_visit v on v.id = a.visit_id "
               f"join his_patient p on p.id = v.patient_id left join his_bed b on b.id = a.bed_id where a.company_id = {CO} and a.status_code = 'ADMITTED' "
               "order by b.bed_no")
    WARD_LOV = f"select name_ar d, id r from his_department where company_id = {CO} and dept_type = 'INPATIENT_WARD' order by name_ar"
    SURG_SRV_LOV = (f"select noona_his_pkg.service_name(s.id) || ' (' || to_char(s.price, 'FM999G990D00') || ')' d, s.id r from his_service s "
                    f"where s.company_id = {CO} and s.status_code = 'ACTIVE' and s.service_type in ('MINOR_SURGERY', 'MAJOR_SURGERY', 'PROCEDURE') order by 1")
    THER_SRV_LOV = (f"select s.name_ar || ' (' || to_char(s.price, 'FM999G990D00') || ')' d, s.id r from his_service s "
                    f"where s.company_id = {CO} and s.status_code = 'ACTIVE' and s.service_type in ('PHYSIOTHERAPY', 'THERAPY', 'NURSING', 'DENTAL') order by 1")
    SURGERY_LOV = (f"select to_char(s.start_at, 'YYYY-MM-DD HH24:MI') || ' - ' || noona_his_pkg.service_name(s.service_id) || ' - ' || p.name_ar d, s.id r "
                   f"from his_surgery s join his_visit v on v.id = s.visit_id join his_patient p on p.id = v.patient_id where s.company_id = {CO} "
                   "and s.status_code in ('SCHEDULED', 'IN_PROGRESS') order by s.start_at")
    PLAN_LOV = (f"select p.name_ar || ' - ' || s.name_ar || ' (' || t.sessions_done || '/' || t.sessions_total || ')' d, t.id r from his_therapy_plan t "
                f"join his_visit v on v.id = t.visit_id join his_patient p on p.id = v.patient_id join his_service s on s.id = t.service_id "
                f"where t.company_id = {CO} and t.status_code = 'ACTIVE' order by p.name_ar")
    LAB_SRV_LOV = (f"select noona_his_pkg.service_name(id) d, id r from his_service where company_id = {CO} and service_type = 'LAB' order by 1")
    DEVICE_LOV = f"select code || ' - ' || name_ar d, id r from his_device where company_id = {CO} order by code"
    RX_LOV = (f"select x.rx_no || ' - ' || p.name_ar || ' (' || case x.status_code when 'ACTIVE' then 'جديدة' else 'جزئية' end || ')' d, x.id r "
              f"from his_prescription x join his_visit v on v.id = x.visit_id join his_patient p on p.id = v.patient_id where x.company_id = {CO} "
              "and x.status_code in ('ACTIVE', 'PARTIAL') order by x.rx_at desc")
    MODALITY_LOV = L['MODALITY_LOV']

    # =========================================================== 33) الوصفة الطبية
    p = app.page(33, 'Prescription', 'PRESCRIPTION', 'Prescription - الوصفة الطبية', scheme=scheme, protection='N')
    f = p.static('Prescription', 10)
    p.select('P33_VISIT', f, 5, 'Visit', lov_sql=OPEN_VISIT_LOV, required=True)
    for k in (1, 2, 3):
        p.select(f'P33_D{k}', f, 10 * k, f'Medicine {k}', lov_sql=MED_LOV, null_text='-')
        p.number(f'P33_Q{k}', f, 10 * k + 1, f'Qty {k}')
        p.text(f'P33_DOSE{k}', f, 10 * k + 2, f'Dose {k} (e.g. 500 mg)', maxlen=100, width=15)
        p.text(f'P33_FREQ{k}', f, 10 * k + 3, f'Frequency {k} (e.g. TID)', maxlen=100, width=15)
        p.number(f'P33_DAYS{k}', f, 10 * k + 4, f'Days {k}')
    p.text('P33_INSTR', f, 50, 'Instructions (e.g. after meals)', maxlen=500)
    p.hidden('P33_RX', f, 90, protected=False)
    b = p.button(f, 10, 'PRESCRIBE', 'Prescribe', hot=True)
    lines = []
    for k in (1, 2, 3):
        lines.append(f"case when :P33_D{k} is not null then json_object('i' value to_number(:P33_D{k}), 'q' value to_number(:P33_Q{k}), "
                     f"'dose' value :P33_DOSE{k}, 'freq' value :P33_FREQ{k}, 'days' value to_number(:P33_DAYS{k}), 'instr' value :P33_INSTR) end")
    p.process(10, 'AFTER_SUBMIT', 'Prescribe', ['declare l_doc clob; l_lines clob;', 'begin',
        "    select json_arrayagg(x.l format json returning clob) into l_lines from (select " + lines[0] + " l from dual union all select "
        + lines[1] + " from dual union all select " + lines[2] + " from dual) x where x.l is not null;",
        "    select json_object('visit' value to_number(:P33_VISIT), 'lines' value nvl(l_lines, to_clob('[]')) format json returning clob) into l_doc from dual;",
        '    :P33_RX := noona_his_care_pkg.prescribe(l_doc);', 'end;'], when_button=b, success='Prescription created - أرسلت الوصفة للصيدلية')
    p.ir('Prescriptions of the visit', 20, [
        "select x.id, x.rx_no, to_char(x.rx_at, 'YYYY-MM-DD HH24:MI') as rx_at, nvl(i.name_en, i.name_ar) as medicine, l.dose, l.frequency, l.duration_days,",
        "       l.quantity, l.dispensed_qty, case x.status_code when 'ACTIVE' then 'New' when 'PARTIAL' then 'Partial' when 'DISPENSED' then 'Dispensed'",
        "       else 'Cancelled' end as status",
        "  from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id",
        " where x.visit_id = :P33_VISIT order by x.id desc, l.line_no"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('RX_NO', 'Rx', {}), ('RX_AT', 'Date', {}), ('MEDICINE', 'Medicine', {}), ('DOSE', 'Dose', {}),
         ('FREQUENCY', 'Frequency', {}), ('DURATION_DAYS', 'Days', {'type': 'NUMBER'}), ('QUANTITY', 'Qty', {'type': 'NUMBER'}),
         ('DISPENSED_QTY', 'Dispensed', {'type': 'NUMBER'}), ('STATUS', 'Status', {})], titled=True, rows=20)
    p.button(f, 20, 'BACK', 'الزيارة', redirect="f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P33_VISIT.")
    p.onload("$('#P33_INSTR,[id^=P33_DOSE],[id^=P33_FREQ]').attr('dir', 'ltr');")
    p.branch(10, url(33, 'P33_VISIT', '&P33_VISIT.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 55) الصيدلية الداخلية
    p = app.page(55, 'Pharmacy', 'PHARMACY', 'الصيدلية الداخلية', scheme=scheme, protection='N')
    f = p.static('صرف الوصفة', 10)
    p.select('P55_RX', f, 10, 'الوصفة', lov_sql=RX_LOV)
    b_bill = p.button(f, 10, 'BILL', 'إرسال للمحاسبة (فوترة الأدوية)', hot=True)
    b_del = p.button(f, 20, 'DELIVER', 'تسليم الأدوية (يصرف من مستودع الصيدلية)')
    b_can = p.button(f, 30, 'CANCEL', 'إلغاء الوصفة')
    p.process(10, 'AFTER_SUBMIT', 'Bill', 'noona_his_care_pkg.bill_prescription(:P55_RX);', when_button=b_bill, success='أرسلت الأدوية للمحاسبة')
    p.process(20, 'AFTER_SUBMIT', 'Deliver', 'noona_his_care_pkg.deliver_prescription(:P55_RX);', when_button=b_del, success='سلمت الأدوية')
    p.process(30, 'AFTER_SUBMIT', 'Cancel', 'noona_his_care_pkg.cancel_prescription(:P55_RX);', when_button=b_can, success='ألغيت الوصفة')
    p.ir('الوصفات', 20, [
        "select x.id, x.rx_no, to_char(x.rx_at, 'YYYY-MM-DD HH24:MI') as rx_at, p.name_ar as patient, p.mrn, nvl(i.name_en, i.name_ar) as medicine,",
        "       l.dose || ' ' || l.frequency || nvl2(l.duration_days, ' x ' || l.duration_days || 'd', '') as sig, l.quantity, l.dispensed_qty,",
        "       case when l.order_id is null then 'لم تفوتر' when o.invoice_id is null and v.visit_type not in ('INPATIENT', 'EMERGENCY', 'DAY_CASE') then 'بانتظار السداد'",
        "            when o.status_code = 'COMPLETED' then 'مسلمة' else 'جاهزة للتسليم' end as state,",
        "       (select nvl(sum(h.on_hand_qty), 0) from inv_onhand h join his_department d on d.id = x.pharmacy_id where h.item_id = l.item_id",
        "         and h.warehouse_id = d.warehouse_id) as stock",
        "  from his_prescription x join his_prescription_line l on l.prescription_id = x.id join inv_item i on i.id = l.item_id",
        "  join his_visit v on v.id = x.visit_id join his_patient p on p.id = v.patient_id left join his_order o on o.id = l.order_id",
        f" where x.company_id = {CO} and x.status_code in ('ACTIVE', 'PARTIAL') order by x.rx_at desc, l.line_no"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('RX_NO', 'الوصفة', {}), ('RX_AT', 'الوقت', {}), ('PATIENT', 'المريض', {}), ('MRN', 'الرقم الطبي', {}),
         ('MEDICINE', 'Medicine', {}), ('SIG', 'Sig', {}), ('QUANTITY', 'الكمية', {'type': 'NUMBER'}), ('DISPENSED_QTY', 'المصروف', {'type': 'NUMBER'}),
         ('STATE', 'الحالة', {}), ('STOCK', 'رصيد الصيدلية', {'type': 'NUMBER'})], titled=True)
    p.branch(10, url(55) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 56) التنويم ولوحة الأسرة
    p = app.page(56, 'Inpatient', 'INPATIENT', 'التنويم ولوحة الأسرة', scheme=scheme, protection='N')
    p.dynamic('الأسرة', 5, 'return noona_his_care_pkg.bed_board_html;', hide_header=True)
    fa = p.static('دخول مريض', 10)
    p.select('P56_PATIENT', fa, 10, 'المريض', lov_sql=L['PATIENT_LOV'])
    p.select('P56_BED', fa, 20, 'السرير المتاح', lov_sql=BED_FREE_LOV)
    p.select('P56_DOCTOR', fa, 30, 'الطبيب المعالج', lov_sql=L['DOCTOR_LOV'])
    p.select('P56_BILL', fa, 40, 'الدفع', lov_sql='STATIC2:حسب ملف المريض;,نقدي;CASH,على التأمين/الجهة;PAYER', null_text=None)
    p.text('P56_APPROVAL', fa, 50, 'رقم موافقة التنويم', maxlen=50, width=15)
    p.text('P56_REASON', fa, 60, 'Admission reason (English)', maxlen=1000)
    b_adm = p.button(fa, 10, 'ADMIT', 'دخول', hot=True)
    b_chg = p.button(fa, 20, 'CHARGE', 'ترحيل أيام السرير حتى اليوم')
    p.process(10, 'AFTER_SUBMIT', 'Admit', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('patient' value to_number(:P56_PATIENT), 'bed' value to_number(:P56_BED), 'doctor' value to_number(:P56_DOCTOR),",
        "           'bill_to' value :P56_BILL, 'approval' value :P56_APPROVAL, 'reason' value :P56_REASON returning clob) into l_doc from dual;",
        '    l := noona_his_care_pkg.admit(l_doc);', 'end;'], when_button=b_adm, success='تم الدخول')
    p.process(15, 'AFTER_SUBMIT', 'Charge', ['declare l number;', 'begin', '    l := noona_his_care_pkg.charge_beds;',
        "    apex_application.g_print_success_message := 'رحلت ' || l || ' يوم سرير';", 'end;'], when_button=b_chg)
    fm = p.static('نقل أو خروج', 20)
    p.select('P56_ADM', fm, 10, 'المريض المنوم', lov_sql=ADM_LOV)
    p.select('P56_NEWBED', fm, 20, 'النقل إلى سرير', lov_sql=BED_FREE_LOV)
    p.select('P56_DTYPE', fm, 30, 'نوع الخروج', lov_sql='STATIC2:إلى المنزل;HOME,تحويل لمستشفى آخر;TRANSFER,على مسؤوليته;AGAINST_ADVICE,وفاة;DECEASED')
    p.textarea('P56_SUMMARY', fm, 40, 'Discharge summary / transfer reason (English)')
    b_tr = p.button(fm, 10, 'TRANSFER', 'نقل')
    b_dis = p.button(fm, 20, 'DISCHARGE', 'خروج', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Transfer', 'noona_his_care_pkg.transfer_bed(:P56_ADM, to_number(:P56_NEWBED), :P56_SUMMARY);', when_button=b_tr,
              success='تم النقل')
    p.process(30, 'AFTER_SUBMIT', 'Discharge', 'noona_his_care_pkg.discharge(:P56_ADM, :P56_DTYPE, :P56_SUMMARY);', when_button=b_dis,
              success='تم الخروج؛ أكمل المحاسبة من ملف الزيارة')
    fb = p.static('الأسرة', 30)
    p.select('P56_SBED', fb, 10, 'السرير', lov_sql=BED_LOV)
    p.select('P56_SSTATUS', fb, 20, 'الحالة', lov_sql='STATIC2:متاح;AVAILABLE,تحت التنظيف;CLEANING,موقوف;BLOCKED', null_text=None)
    b_bs = p.button(fb, 10, 'SET_BED', 'تغيير حالة السرير')
    p.select('P56_WARD', fb, 30, 'الجناح (لسرير جديد)', lov_sql=WARD_LOV)
    p.text('P56_BEDNO', fb, 40, 'رقم السرير', maxlen=30, width=10)
    p.text('P56_ROOM', fb, 50, 'الغرفة', maxlen=30, width=10)
    p.select('P56_CLASS', fb, 60, 'الفئة', lov_sql='STATIC2:عام;WARD,شبه خاص;SEMI_PRIVATE,خاص;PRIVATE,جناح;SUITE,عناية مركزة;ICU,حضانة;NICU,عزل;ISOLATION',
             null_text=None)
    b_nb = p.button(fb, 20, 'ADD_BED', 'إضافة سرير')
    p.process(40, 'AFTER_SUBMIT', 'Bed Status', 'noona_his_care_pkg.set_bed_status(:P56_SBED, :P56_SSTATUS);', when_button=b_bs, success='تغيرت حالة السرير')
    p.process(50, 'AFTER_SUBMIT', 'Add Bed', ['declare l number;', 'begin',
        '    l := noona_his_care_pkg.save_bed(null, to_number(:P56_WARD), :P56_BEDNO, :P56_ROOM, :P56_CLASS);', 'end;'], when_button=b_nb,
        success='أضيف السرير')
    p.onload(["$('#P56_REASON,#P56_SUMMARY').attr('dir', 'ltr');", "document.addEventListener('click', function (e) {",
              "  var b = e.target.closest('[data-visit]'); if (!b || !b.dataset.visit) return;",
              "  location.href = 'f?p=' + apex.env.APP_ID + ':31:' + apex.env.APP_SESSION + '::NO:RP,31:P31_ID:' + b.dataset.visit;",
              "});"])
    p.branch(10, url(56) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 57) جدول العمليات
    p = app.page(57, 'Operating Theater', 'OR-SCHEDULE', 'جدول العمليات', scheme=scheme, protection='N')
    fd = p.static('اليوم', 5, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.date('P57_DATE', fd, 10, 'التاريخ')
    p.button(fd, 10, 'SHOW', 'عرض', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ":P57_DATE := nvl(:P57_DATE, to_char(sysdate, 'YYYY-MM-DD'));")
    p.dynamic('غرف العمليات', 8, "return noona_his_care_pkg.or_board_html(to_date(:P57_DATE, 'YYYY-MM-DD'));", hide_header=True)
    fs = p.static('جدولة عملية', 10)
    p.select('P57_VISIT', fs, 10, 'الزيارة (المنوم أو الإقامة اليومية)', lov_sql=OPEN_VISIT_LOV)
    p.select('P57_SRV', fs, 20, 'Procedure', lov_sql=SURG_SRV_LOV)
    p.text('P57_THEATER', fs, 30, 'غرفة العمليات', maxlen=30, width=8)
    p.select('P57_SURGEON', fs, 40, 'الجراح', lov_sql=L['DOCTOR_LOV'])
    p.select('P57_ANES', fs, 50, 'طبيب التخدير', lov_sql=L['DOCTOR_LOV'])
    p.select('P57_ANTYPE', fs, 60, 'التخدير', lov_sql='STATIC2:General;GENERAL,Spinal;SPINAL,Local;LOCAL,Sedation;SEDATION')
    p.date('P57_SDATE', fs, 70, 'التاريخ')
    p.text('P57_STIME', fs, 80, 'الوقت (HH24:MI)', maxlen=5, width=8)
    p.number('P57_DUR', fs, 90, 'المدة بالدقائق')
    b_sc = p.button(fs, 10, 'SCHEDULE', 'جدولة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Schedule', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('visit' value to_number(:P57_VISIT), 'service' value to_number(:P57_SRV), 'theater' value :P57_THEATER,",
        "           'surgeon' value to_number(:P57_SURGEON), 'anesthetist' value to_number(:P57_ANES), 'anesthesia' value :P57_ANTYPE,",
        "           'start' value :P57_SDATE || ' ' || :P57_STIME, 'duration' value to_number(nvl(:P57_DUR, 60)) returning clob) into l_doc from dual;",
        '    l := noona_his_care_pkg.schedule_surgery(l_doc);', '    :P57_DATE := :P57_SDATE;', 'end;'], when_button=b_sc, success='جدولت العملية')
    fx = p.static('تنفيذ العملية', 20)
    p.select('P57_SURGERY', fx, 10, 'العملية', lov_sql=SURGERY_LOV)
    p.textarea('P57_NOTES', fx, 20, 'Operative notes (English) / cancel reason', rows=4)
    b_st = p.button(fx, 10, 'START', 'بدء العملية')
    b_fin = p.button(fx, 20, 'FINISH', 'إنهاء وحفظ التقرير', hot=True)
    b_cn = p.button(fx, 30, 'CANCEL', 'إلغاء')
    p.process(20, 'AFTER_SUBMIT', 'Start', 'noona_his_care_pkg.start_surgery(:P57_SURGERY);', when_button=b_st, success='بدأت العملية')
    p.process(30, 'AFTER_SUBMIT', 'Finish', 'noona_his_care_pkg.finish_surgery(:P57_SURGERY, :P57_NOTES);', when_button=b_fin, success='أنهيت العملية')
    p.process(40, 'AFTER_SUBMIT', 'Cancel', 'noona_his_care_pkg.cancel_surgery(:P57_SURGERY, :P57_NOTES);', when_button=b_cn, success='ألغيت العملية')
    p.onload("$('#P57_NOTES').attr('dir', 'ltr');")
    p.branch(10, url(57, 'P57_DATE', '&P57_DATE.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 58) العلاج الطبيعي والوحدات العلاجية
    p = app.page(58, 'Therapy', 'THERAPY', 'العلاج الطبيعي والجلسات', scheme=scheme, protection='N')
    fc = p.static('خطة علاج', 10)
    p.select('P58_VISIT', fc, 10, 'الزيارة', lov_sql=OPEN_VISIT_LOV)
    p.select('P58_SRV', fc, 20, 'الجلسة', lov_sql=THER_SRV_LOV)
    p.number('P58_SESS', fc, 30, 'عدد الجلسات')
    p.select('P58_THER', fc, 40, 'المعالج', lov_sql=L['DOCTOR_LOV'])
    p.text('P58_FREQ', fc, 50, 'Frequency (e.g. 3/week)', maxlen=100, width=15)
    p.textarea('P58_GOALS', fc, 60, 'Treatment goals (English)')
    b_pl = p.button(fc, 10, 'PLAN', 'إنشاء الخطة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Plan', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('visit' value to_number(:P58_VISIT), 'service' value to_number(:P58_SRV), 'sessions' value to_number(:P58_SESS),",
        "           'therapist' value to_number(:P58_THER), 'frequency' value :P58_FREQ, 'goals' value :P58_GOALS returning clob) into l_doc from dual;",
        '    l := noona_his_care_pkg.create_plan(l_doc);', 'end;'], when_button=b_pl, success='أنشئت الخطة؛ تسدد قبل أول جلسة')
    fs = p.static('تسجيل جلسة', 20)
    p.select('P58_PLAN', fs, 10, 'الخطة', lov_sql=PLAN_LOV)
    p.select('P58_STHER', fs, 20, 'المعالج', lov_sql=L['DOCTOR_LOV'], null_text='- معالج الخطة -')
    p.textarea('P58_SNOTES', fs, 30, 'Session notes / progress (English)')
    b_se = p.button(fs, 10, 'SESSION', 'تسجيل الجلسة', hot=True)
    p.process(20, 'AFTER_SUBMIT', 'Session', ['declare l number;', 'begin',
        '    l := noona_his_care_pkg.record_session(:P58_PLAN, to_number(:P58_STHER), :P58_SNOTES);',
        "    apex_application.g_print_success_message := 'سجلت الجلسة رقم ' || l;", 'end;'], when_button=b_se)
    p.ir('الخطط', 30, [
        "select t.id, p.name_ar as patient, p.mrn, s.name_ar as service, t.sessions_done || ' / ' || t.sessions_total as progress, t.frequency,",
        "       (select name_ar from his_doctor where id = t.therapist_id) as therapist,",
        "       case t.status_code when 'ACTIVE' then 'جارية' when 'COMPLETED' then 'مكتملة' else 'ملغاة' end as status,",
        "       case when o.invoice_id is not null then 'نعم' else 'لا' end as paid,",
        "       (select to_char(max(x.session_at), 'YYYY-MM-DD') from his_therapy_session x where x.plan_id = t.id) as last_session",
        "  from his_therapy_plan t join his_visit v on v.id = t.visit_id join his_patient p on p.id = v.patient_id join his_service s on s.id = t.service_id",
        f"  join his_order o on o.id = t.order_id where t.company_id = {CO} order by t.status_code, p.name_ar"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('PATIENT', 'المريض', {}), ('MRN', 'الرقم الطبي', {}), ('SERVICE', 'الجلسة', {}),
         ('PROGRESS', 'المنفذ', {}), ('FREQUENCY', 'التكرار', {}), ('THERAPIST', 'المعالج', {}), ('STATUS', 'الحالة', {}), ('PAID', 'مسددة', {}),
         ('LAST_SESSION', 'آخر جلسة', {})], titled=True)
    p.onload("$('#P58_GOALS,#P58_SNOTES,#P58_FREQ').attr('dir', 'ltr');")
    p.branch(10, url(58) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 64) مكونات التحاليل والقوالب
    p = app.page(64, 'Lab Setup', 'LAB-SETUP', 'Lab parameters & report templates', scheme=scheme)
    fp = p.static('Test parameters', 10)
    p.select('P64_SRV', fp, 10, 'Test', lov_sql=LAB_SRV_LOV, submit=True)
    p.text('P64_CODE', fp, 20, 'Code (e.g. HB)', maxlen=30, width=10)
    p.text('P64_NAME_EN', fp, 30, 'Name (English)', maxlen=200)
    p.text('P64_NAME_AR', fp, 40, 'الاسم بالعربية', maxlen=200)
    p.text('P64_UNIT', fp, 50, 'Unit', maxlen=30, width=10)
    p.select('P64_GENDER', fp, 60, 'Sex', lov_sql='STATIC2:Male;M,Female;F', null_text='All')
    p.number('P64_LOW', fp, 70, 'Reference low')
    p.number('P64_HIGH', fp, 80, 'Reference high')
    p.number('P64_CLOW', fp, 90, 'Critical below')
    p.number('P64_CHIGH', fp, 100, 'Critical above')
    p.text('P64_REF', fp, 110, 'Text reference (e.g. Negative)', maxlen=200)
    b_pa = p.button(fp, 10, 'SAVE_PARAM', 'Save parameter', hot=True)
    b_sd = p.button(fp, 20, 'SEED', 'Load default parameters, English names & templates')
    p.process(5, 'AFTER_SUBMIT', 'Seed', ['declare l number;', 'begin', '    l := noona_his_care_pkg.seed_defaults;',
        "    apex_application.g_print_success_message := 'Loaded: ' || l;", 'end;'], when_button=b_sd)
    p.process(10, 'AFTER_SUBMIT', 'Param', ['declare l number;', 'begin',
        '    l := noona_his_care_pkg.set_lab_param(to_number(:P64_SRV), :P64_CODE, nvl(:P64_NAME_AR, :P64_NAME_EN), :P64_UNIT, to_number(:P64_LOW),',
        '         to_number(:P64_HIGH), to_number(:P64_CLOW), to_number(:P64_CHIGH), :P64_GENDER, null, null, :P64_REF, :P64_NAME_EN);',
        '    :P64_CODE := null; :P64_NAME_EN := null; :P64_NAME_AR := null;', 'end;'], when_button=b_pa, success='Parameter saved')
    p.ir('Parameters', 15, [
        "select p.id, p.code, p.name_en, p.name_ar, p.unit, decode(p.gender, 'M', 'Male', 'F', 'Female', 'All') as sex, p.ref_low, p.ref_high,",
        "       p.crit_low, p.crit_high, p.ref_text from his_lab_param p where p.service_id = :P64_SRV order by p.sort_order, p.gender"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'Code', {}), ('NAME_EN', 'Name', {}), ('NAME_AR', 'الاسم', {}), ('UNIT', 'Unit', {}),
         ('SEX', 'Sex', {}), ('REF_LOW', 'Low', {'type': 'NUMBER'}), ('REF_HIGH', 'High', {'type': 'NUMBER'}), ('CRIT_LOW', 'Crit. low', {'type': 'NUMBER'}),
         ('CRIT_HIGH', 'Crit. high', {'type': 'NUMBER'}), ('REF_TEXT', 'Text ref.', {})], titled=True, rows=40)
    ft = p.static('Report templates (radiology / cardiology)', 20)
    p.text('P64_TCODE', ft, 10, 'Template code', maxlen=30, width=12)
    p.text('P64_TNAME', ft, 20, 'Name', maxlen=200)
    p.select('P64_TMOD', ft, 30, 'Modality', lov_sql=MODALITY_LOV)
    p.textarea('P64_TBODY', ft, 40, 'Template text (English)', rows=6)
    b_tp = p.button(ft, 10, 'SAVE_TPL', 'Save template')
    p.process(20, 'AFTER_SUBMIT', 'Template', ['declare l number;', 'begin',
        '    l := noona_his_care_pkg.save_template(null, :P64_TCODE, :P64_TNAME, null, :P64_TMOD, :P64_TBODY);', 'end;'], when_button=b_tp,
        success='Template saved')
    p.ir('Templates', 25, [f"select t.id, t.code, t.name_ar, noona_his_pkg.modality_label(t.modality) as modality, substr(t.body, 1, 200) as body "
                           f"from his_report_template t where t.company_id = {CO} order by t.code"],
         [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'Code', {}), ('NAME_AR', 'Name', {}), ('MODALITY', 'Modality', {}), ('BODY', 'Text', {})],
         titled=True, rows=20)
    p.onload("$('#P64_TBODY,#P64_NAME_EN,#P64_REF').attr('dir', 'ltr');")
    p.branch(10, url(64, 'P64_SRV', '&P64_SRV.') + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 66) الأجهزة الطبية
    p = app.page(66, 'Medical Devices', 'DEVICES', 'الأجهزة الطبية والمعايرة', scheme=scheme)
    p.dynamic('المؤشرات', 5, 'return noona_his_care_pkg.devices_html;', hide_header=True)
    fd = p.static('جهاز', 10)
    p.text('P66_CODE', fd, 10, 'الرمز', maxlen=30, width=12)
    p.text('P66_NAME', fd, 20, 'Device name')
    p.select('P66_DEPT', fd, 30, 'القسم', lov_sql=L['DEPT_LOV'])
    p.select('P66_MOD', fd, 40, 'Modality', lov_sql=MODALITY_LOV)
    p.text('P66_MFR', fd, 50, 'Manufacturer', maxlen=100, width=15)
    p.text('P66_MODEL', fd, 60, 'Model', maxlen=100, width=15)
    p.text('P66_SN', fd, 70, 'Serial no.', maxlen=100, width=15)
    p.select('P66_ASSET', fd, 80, 'الأصل الثابت', lov_sql=f"select asset_no || ' - ' || name_ar d, id r from fa_asset where company_id = {CO} order by asset_no")
    p.date('P66_INST', fd, 90, 'تاريخ التركيب')
    p.date('P66_WARR', fd, 100, 'نهاية الضمان')
    p.number('P66_CAL', fd, 110, 'دورية المعايرة (يوم)')
    b_dv = p.button(fd, 10, 'SAVE_DEVICE', 'حفظ الجهاز', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Device', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('code' value :P66_CODE, 'name' value :P66_NAME, 'dept' value to_number(:P66_DEPT), 'modality' value :P66_MOD,",
        "           'manufacturer' value :P66_MFR, 'model' value :P66_MODEL, 'serial' value :P66_SN, 'asset' value to_number(:P66_ASSET),",
        "           'installed' value :P66_INST, 'warranty' value :P66_WARR, 'cal_days' value to_number(:P66_CAL) returning clob) into l_doc from dual;",
        '    l := noona_his_care_pkg.save_device(l_doc);', 'end;'], when_button=b_dv, success='حفظ الجهاز')
    fl = p.static('سجل صيانة أو معايرة', 20)
    p.select('P66_DEV', fl, 10, 'الجهاز', lov_sql=DEVICE_LOV)
    p.select('P66_LTYPE', fl, 20, 'النوع', lov_sql='STATIC2:معايرة;CALIBRATION,صيانة وقائية;PREVENTIVE,إصلاح;REPAIR,عطل (إيقاف);BREAKDOWN,عودة للخدمة;RETURN_TO_SERVICE',
             null_text=None)
    p.date('P66_LDATE', fl, 30, 'التاريخ')
    p.text('P66_VENDOR', fl, 40, 'الجهة المنفذة', maxlen=200)
    p.number('P66_COST', fl, 50, 'التكلفة')
    p.text('P66_LNOTES', fl, 60, 'ملاحظات', maxlen=1000)
    b_lg = p.button(fl, 10, 'LOG', 'تسجيل')
    p.process(20, 'AFTER_SUBMIT', 'Log', "noona_his_care_pkg.log_device(:P66_DEV, :P66_LTYPE, to_date(:P66_LDATE, 'YYYY-MM-DD'), :P66_VENDOR, to_number(:P66_COST), :P66_LNOTES);",
              when_button=b_lg, success='سجل في دفتر الجهاز')
    p.ir('الأجهزة', 30, [
        "select v.id, v.code, v.name_ar, d.name_ar as dept, noona_his_pkg.modality_label(v.modality) as modality, v.manufacturer, v.model, v.serial_no,",
        "       v.last_calibration, v.next_calibration, case when v.next_calibration <= trunc(sysdate) then 'متأخرة' when v.next_calibration <= trunc(sysdate) + 14",
        "       then 'قريبة' end as due, case v.status_code when 'IN_SERVICE' then 'في الخدمة' when 'OUT_OF_SERVICE' then 'خارج الخدمة' else 'مستبعد' end as status,",
        "       (select nvl(sum(cost), 0) from his_device_log l where l.device_id = v.id) as service_cost",
        f"  from his_device v join his_department d on d.id = v.department_id where v.company_id = {CO} order by v.next_calibration nulls last"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'Device', {}), ('DEPT', 'القسم', {}), ('MODALITY', 'الجهاز', {}),
         ('MANUFACTURER', 'المصنع', {}), ('MODEL', 'الطراز', {}), ('SERIAL_NO', 'الرقم التسلسلي', {}), ('LAST_CALIBRATION', 'آخر معايرة', {'type': 'DATE'}),
         ('NEXT_CALIBRATION', 'المعايرة القادمة', {'type': 'DATE'}), ('DUE', 'الاستحقاق', {}), ('STATUS', 'الحالة', {}),
         ('SERVICE_COST', 'تكلفة الصيانة', {'type': 'NUMBER'})], titled=True)
    p.branch(10, url(66) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 71) دفعات المطالبات
    p = app.page(71, 'Claims', 'CLAIMS', 'مطالبات التأمين', scheme=scheme, protection='N')
    fc = p.static('دفعة جديدة', 10)
    p.select('P71_PAYER', fc, 10, 'الجهة', lov_sql=L['PAYER_LOV'])
    p.date('P71_FROM', fc, 20, 'من')
    p.date('P71_TO', fc, 30, 'إلى')
    p.hidden('P71_ID', fc, 90, protected=False)
    b_cb = p.button(fc, 10, 'CREATE', 'إنشاء الدفعة من الفواتير غير المطالب بها', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [":P71_FROM := nvl(:P71_FROM, to_char(trunc(sysdate, 'MM'), 'YYYY-MM-DD'));",
                                               ":P71_TO := nvl(:P71_TO, to_char(sysdate, 'YYYY-MM-DD'));"])
    p.process(10, 'AFTER_SUBMIT', 'Create', ":P71_ID := noona_his_claim_pkg.create_batch(:P71_PAYER, to_date(:P71_FROM, 'YYYY-MM-DD'), to_date(:P71_TO, 'YYYY-MM-DD'));",
              when_button=b_cb, success='أنشئت الدفعة')
    p.ir('الدفعات', 20, [
        "select b.id, b.doc_no, y.name_ar as payer, b.period_from, b.period_to, b.claimed_amount, b.approved_amount, b.rejected_amount,",
        "       noona_his_claim_pkg.status_label(b.status_code) as status, b.reference_no,",
        "       (select count(*) from his_claim_line l where l.batch_id = b.id) as invoices",
        f"  from his_claim_batch b join his_payer y on y.id = b.payer_id where b.company_id = {CO} order by b.id desc"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الدفعة', {}), ('PAYER', 'الجهة', {}), ('PERIOD_FROM', 'من', {'type': 'DATE'}),
         ('PERIOD_TO', 'إلى', {'type': 'DATE'}), ('CLAIMED_AMOUNT', 'المطالب', {'type': 'NUMBER'}), ('APPROVED_AMOUNT', 'المقبول', {'type': 'NUMBER'}),
         ('REJECTED_AMOUNT', 'المرفوض', {'type': 'NUMBER'}), ('STATUS', 'الحالة', {}), ('REFERENCE_NO', 'مرجع الجهة', {}),
         ('INVOICES', 'الفواتير', {'type': 'NUMBER'})], link=link(72, 'P72_ID'), titled=True)
    p.branch(5, url(72, 'P72_ID', '&P71_ID.') + '&success_msg=#SUCCESS_MSG#', when_button=b_cb)
    p.branch(10, url(71))

    # =========================================================== 72) الدفعة: الإرسال والرد والتحصيل
    p = app.page(72, 'Claim Batch', 'CLAIM-BATCH', 'دفعة مطالبات', scheme=scheme, protection='N')
    f = p.static('الإجراءات', 10)
    p.hidden('P72_ID', f, 1, protected=False)
    p.dynamic('الدفعة', 5, 'return noona_his_claim_pkg.batch_html(:P72_ID);', hide_header=True, opts='#DEFAULT#:t-Region--scrollBody:nn-print-area')
    p.text('P72_REF', f, 10, 'مرجع الإرسال لدى الجهة', maxlen=100, width=20)
    b_sub = p.button(f, 10, 'SUBMIT_BATCH', 'إرسال الدفعة', hot=True)
    b_cn = p.button(f, 20, 'CANCEL_BATCH', 'إلغاء الدفعة')
    b_rf = p.button(f, 30, 'REFRESH', 'تحديث حالة السداد')
    p.button(f, 40, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    p.button(f, 50, 'EXPORT', 'تنزيل ملف المطالبة الإلكتروني (JSON)', redirect="javascript:nnClaimExport();")
    p.process(10, 'AFTER_SUBMIT', 'Submit', 'noona_his_claim_pkg.submit_batch(:P72_ID, :P72_REF);', when_button=b_sub, success='أرسلت الدفعة')
    p.process(20, 'AFTER_SUBMIT', 'Cancel', 'noona_his_claim_pkg.cancel_batch(:P72_ID);', when_button=b_cn, success='ألغيت الدفعة')
    p.process(30, 'AFTER_SUBMIT', 'Refresh', 'noona_his_claim_pkg.refresh_batch(:P72_ID);', when_button=b_rf, success='حدثت الحالة')
    fr = p.static('رد الجهة (خصم أو رفض على فاتورة)', 20)
    p.select('P72_INV', fr, 10, 'الفاتورة', lov_sql=(
        "select i.doc_no || ' - ' || p.name_ar || ' (' || to_char(l.claimed_amount, 'FM999G990D00') || ')' d, i.id r from his_claim_line l "
        "join his_invoice i on i.id = l.invoice_id join his_patient p on p.id = i.patient_id where l.batch_id = :P72_ID order by i.doc_no"))
    p.number('P72_APPROVED', fr, 20, 'المبلغ المقبول')
    p.text('P72_REASON', fr, 30, 'Rejection reason', maxlen=500)
    b_ad = p.button(fr, 10, 'ADD_DECISION', 'إضافة للرد')
    b_rs = p.button(fr, 20, 'RECORD', 'تسجيل رد الجهة (الباقي مقبول بالكامل)', hot=True)
    p.process(40, 'AFTER_SUBMIT', 'Add Decision', ['begin',
        "    if not apex_collection.collection_exists('HIS_CLAIM_RESP') then apex_collection.create_collection('HIS_CLAIM_RESP'); end if;",
        "    apex_collection.add_member('HIS_CLAIM_RESP', p_c001 => :P72_ID, p_c002 => :P72_INV, p_c003 => :P72_APPROVED, p_c004 => :P72_REASON);",
        "    :P72_INV := null; :P72_APPROVED := null; :P72_REASON := null;", 'end;'], when_button=b_ad, success='أضيف للرد')
    p.process(50, 'AFTER_SUBMIT', 'Record', ['declare l clob;', 'begin',
        "    if apex_collection.collection_exists('HIS_CLAIM_RESP') then",
        "        select json_arrayagg(json_object('inv' value to_number(c002), 'approved' value to_number(c003), 'reason' value c004) returning clob)",
        "          into l from apex_collections where collection_name = 'HIS_CLAIM_RESP' and c001 = :P72_ID;",
        '    end if;',
        '    noona_his_claim_pkg.record_response(:P72_ID, l);',
        "    if apex_collection.collection_exists('HIS_CLAIM_RESP') then apex_collection.delete_collection('HIS_CLAIM_RESP'); end if;",
        'end;'], when_button=b_rs, success='سجل رد الجهة وقيد المرفوض')
    p.ir('قرارات الرد المضافة', 25, [
        "select c.seq_id as id, i.doc_no, c.c003 as approved, c.c004 as reason from apex_collections c join his_invoice i on i.id = to_number(c.c002)",
        " where c.collection_name = 'HIS_CLAIM_RESP' and c.c001 = :P72_ID"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DOC_NO', 'الفاتورة', {}), ('APPROVED', 'المقبول', {}), ('REASON', 'السبب', {})], titled=True, rows=20)
    p.dynamic('ملف المطالبة', 40, ["return '<script type=\"application/json\" id=\"nnClaimJson\">' || replace(noona_his_claim_pkg.batch_json(:P72_ID), '</', '<\\/')",
                                   "    || '</script>';"], hide_header=True, opts='#DEFAULT#:t-Region--noUI', condition=':P72_ID is not null')
    p.onload(["window.nnClaimExport = function () {",
              "  var el = document.getElementById('nnClaimJson'); if (!el) return;",
              "  var blob = new Blob([JSON.stringify(JSON.parse(el.textContent), null, 2)], { type: 'application/json' });",
              "  var a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = 'claim-' + $v('P72_ID') + '.json';",
              "  document.body.appendChild(a); a.click(); a.remove();",
              "};"])
    p.branch(10, url(72, 'P72_ID', '&P72_ID.') + '&success_msg=#SUCCESS_MSG#')

    # القائمة
    cl = app.nav_item('الرعاية السريرية', None, 'fa-heartbeat', 45)
    app.nav_item('الصيدلية الداخلية', 55, 'fa-medkit', 451, parent=cl)
    app.nav_item('التنويم ولوحة الأسرة', 56, 'fa-bed', 452, parent=cl)
    app.nav_item('جدول العمليات', 57, 'fa-scissors', 453, parent=cl)
    app.nav_item('العلاج الطبيعي والجلسات', 58, 'fa-child', 454, parent=cl)
    app.nav_item('مطالبات التأمين', 71, 'fa-file-text', 65)
