"""صفحات المرحلة الرابعة في تطبيق المستشفى (141): ورديات التمريض وجدول المناوبات، محطة التمريض بتنبيهات مواعيد الجرعات والمتابعة،
والملف الإلكتروني للمريض المنوم (جدول الجرعات وتسجيلها، خطة المتابعة، العلامات الحيوية، الملاحظات). المنطق في NOONA_HIS_NURSE_PKG.
"""

CO = 'noona_his_pkg.company'


def build(app, url, link, scheme, L):
    WARD_LOV = f"select name_ar d, id r from his_department where company_id = {CO} and dept_type in ('INPATIENT_WARD', 'EMERGENCY', 'NURSING') order by name_ar"
    SHIFT_LOV = (f"select name_ar || ' (' || start_time || ' - ' || end_time || ')' d, id r from his_nurse_shift where company_id = {CO} "
                 "and is_active = 'Y' order by sort_order")
    NURSE_LOV = (f"select name_ar || case title when 'NURSE' then '' else ' - ' || title end d, id r from his_doctor where company_id = {CO} "
                 "and status_code = 'ACTIVE' order by case title when 'NURSE' then 0 else 1 end, name_ar")
    INPT_LOV = (f"select b.bed_no || ' - ' || p.name_ar || ' (' || p.mrn || ')' d, v.id r from his_admission a join his_visit v on v.id = a.visit_id "
                f"join his_patient p on p.id = v.patient_id join his_bed b on b.id = a.bed_id where a.company_id = {CO} and a.status_code = 'ADMITTED' "
                "order by b.bed_no")
    DOSE_LOV = ("select to_char(m.due_at, 'MM-DD HH24:MI') || ' - ' || nvl(i.name_en, i.name_ar) || ' ' || m.dose || ' ' || m.route "
                "|| case when m.due_at < systimestamp - interval '30' minute then ' (overdue)' end d, m.id r "
                "from his_med_schedule m join his_prescription_line l on l.id = m.line_id join inv_item i on i.id = l.item_id "
                "where m.visit_id = :P76_VISIT and m.status_code = 'DUE' and m.due_at <= systimestamp + interval '2' hour order by m.due_at")
    TASK_LOV = ("select noona_his_nurse_pkg.task_label(t.task_type) || nvl2(t.description, ': ' || t.description, '') || ' (every ' || t.every_hours "
                "|| 'h, next ' || to_char(t.next_due_at, 'HH24:MI') || ')' d, t.id r from his_care_task t where t.visit_id = :P76_VISIT "
                "and t.status_code = 'ACTIVE' order by t.next_due_at")
    TASK_TYPES = ('STATIC2:العلامات الحيوية;VITALS,سكر الدم;BLOOD_SUGAR,تغيير الوضعية;TURNING,العناية بالجرح;WOUND_CARE,السوائل الداخلة والخارجة;INTAKE_OUTPUT,'
                  'Doctor round;DOCTOR_ROUND,Observation;OBSERVATION,Other;OTHER')

    # =========================================================== 74) ورديات التمريض والمناوبات
    p = app.page(74, 'Nursing Roster', 'NURSE-ROSTER', 'ورديات التمريض والمناوبات', scheme=scheme, protection='N')
    p.dynamic('المناوبون الآن', 3, 'return noona_his_nurse_pkg.on_duty_html;')
    f = p.static('تسجيل مناوبة', 10)
    p.date('P74_DATE', f, 10, 'التاريخ (بداية الوردية)', required=True)
    p.select('P74_SHIFT', f, 20, 'الوردية', lov_sql=SHIFT_LOV, required=True)
    p.select('P74_WARD', f, 30, 'الجناح أو القسم', lov_sql=WARD_LOV, required=True)
    p.select('P74_NURSE', f, 40, 'الممرض', lov_sql=NURSE_LOV, required=True)
    p.select('P74_ROLE', f, 50, 'الدور', lov_sql='STATIC2:ممرض;STAFF,مسؤول الوردية;CHARGE,مساعد تمريض;ASSISTANT', null_text=None)
    p.text('P74_ROOMS', f, 60, 'الغرف المسندة (101,102 - فارغ = كل الجناح)', maxlen=200, width=20)
    p.text('P74_NOTES', f, 70, 'ملاحظات', maxlen=500)
    b_as = p.button(f, 10, 'ASSIGN', 'حفظ المناوبة', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['declare l number;', 'begin', '    l := noona_his_nurse_pkg.seed_shifts;',
                                               "    :P74_DATE := nvl(:P74_DATE, to_char(sysdate, 'YYYY-MM-DD'));",
                                               "    :P74_COPY_FROM := nvl(:P74_COPY_FROM, to_char(sysdate, 'YYYY-MM-DD'));",
                                               "    :P74_COPY_TO := nvl(:P74_COPY_TO, to_char(sysdate + 1, 'YYYY-MM-DD'));", 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Assign', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('date' value :P74_DATE, 'shift' value to_number(:P74_SHIFT), 'ward' value to_number(:P74_WARD), 'nurse' value to_number(:P74_NURSE),",
        "           'role' value :P74_ROLE, 'rooms' value :P74_ROOMS, 'notes' value :P74_NOTES returning clob) into l_doc from dual;",
        '    l := noona_his_nurse_pkg.assign_duty(l_doc);', '    :P74_NURSE := null; :P74_ROOMS := null; :P74_NOTES := null;', 'end;'],
        when_button=b_as, success='حفظت المناوبة')
    fc = p.static('نسخ جدول يوم', 15)
    p.date('P74_COPY_FROM', fc, 10, 'من يوم')
    p.date('P74_COPY_TO', fc, 20, 'إلى يوم')
    p.select('P74_COPY_WARD', fc, 30, 'الجناح', lov_sql=WARD_LOV, null_text='كل الأجنحة')
    b_cp = p.button(fc, 10, 'COPY', 'نسخ المناوبات')
    p.process(20, 'AFTER_SUBMIT', 'Copy', ['declare l number;', 'begin',
        "    l := noona_his_nurse_pkg.copy_roster(to_date(:P74_COPY_FROM, 'YYYY-MM-DD'), to_date(:P74_COPY_TO, 'YYYY-MM-DD'), to_number(:P74_COPY_WARD));",
        "    apex_application.g_print_success_message := 'نسخت ' || l || ' مناوبة';", 'end;'], when_button=b_cp)
    fd = p.static('حذف مناوبة', 17)
    p.select('P74_DEL', fd, 10, 'المناوبة', lov_sql=(
        "select to_char(r.duty_date, 'YYYY-MM-DD') || ' - ' || s.name_ar || ' - ' || w.name_ar || ' - ' || d.name_ar dd, r.id r from his_nurse_roster r "
        "join his_nurse_shift s on s.id = r.shift_id join his_department w on w.id = r.ward_id join his_doctor d on d.id = r.nurse_id "
        f"where r.company_id = {CO} and r.duty_date >= trunc(sysdate) - 1 order by r.duty_date, s.sort_order, w.name_ar"))
    b_dl = p.button(fd, 10, 'REMOVE', 'حذف')
    p.process(30, 'AFTER_SUBMIT', 'Remove', 'noona_his_nurse_pkg.remove_duty(:P74_DEL);', when_button=b_dl, success='حذفت المناوبة')
    fs = p.static('الورديات', 18)
    p.select('P74_SID', fs, 10, 'تعديل وردية', lov_sql=SHIFT_LOV, null_text='- وردية جديدة -')
    p.text('P74_SCODE', fs, 20, 'الرمز', maxlen=30, width=8)
    p.text('P74_SNAME', fs, 30, 'الاسم', maxlen=200)
    p.text('P74_SFROM', fs, 40, 'من (HH24:MI)', maxlen=5, width=6)
    p.text('P74_STO', fs, 50, 'إلى (HH24:MI)', maxlen=5, width=6)
    b_sh = p.button(fs, 10, 'SAVE_SHIFT', 'حفظ الوردية')
    p.process(40, 'AFTER_SUBMIT', 'Shift', ['declare l number;', 'begin',
        '    l := noona_his_nurse_pkg.save_shift(to_number(:P74_SID), :P74_SCODE, :P74_SNAME, :P74_SFROM, :P74_STO);', 'end;'], when_button=b_sh,
        success='حفظت الوردية')
    p.ir('جدول المناوبات', 20, [
        "select r.id, r.duty_date, s.name_ar || ' ' || s.start_time || '-' || s.end_time as shift, w.name_ar as ward, d.name_ar as nurse,",
        "       case r.duty_role when 'CHARGE' then 'مسؤول الوردية' when 'ASSISTANT' then 'مساعد' else 'ممرض' end as duty_role, r.rooms, d.mobile, r.notes",
        "  from his_nurse_roster r join his_nurse_shift s on s.id = r.shift_id join his_department w on w.id = r.ward_id join his_doctor d on d.id = r.nurse_id",
        f" where r.company_id = {CO} and r.duty_date between trunc(sysdate) - 7 and trunc(sysdate) + 14 order by r.duty_date, s.sort_order, w.name_ar"],
        [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DUTY_DATE', 'التاريخ', {'type': 'DATE'}), ('SHIFT', 'الوردية', {}), ('WARD', 'الجناح', {}),
         ('NURSE', 'الممرض', {}), ('DUTY_ROLE', 'الدور', {}), ('ROOMS', 'الغرف', {}), ('MOBILE', 'الجوال', {}), ('NOTES', 'ملاحظات', {})], titled=True)
    p.branch(10, url(74) + '&success_msg=#SUCCESS_MSG#')

    # =========================================================== 75) محطة التمريض
    p = app.page(75, 'Nurse Station', 'NURSE-STATION', 'محطة التمريض', scheme=scheme, protection='N')
    f = p.static('الجناح', 3, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P75_WARD', f, 10, 'الجناح', lov_sql=WARD_LOV, submit=True)
    p.select('P75_HOURS', f, 20, 'المستحق خلال', lov_sql='STATIC2:ساعة;1,ساعتين;2,4 ساعات;4,8 ساعات;8,24 ساعة;24', null_text=None, submit=True)
    p.button(f, 10, 'ENABLE_SOUND', 'تفعيل تنبيه الصوت والمتصفح', redirect='javascript:nnNurseEnable();')
    p.process(2, 'BEFORE_HEADER', 'Defaults', ['begin', "    :P75_HOURS := nvl(:P75_HOURS, '2');",
        f"    if :P75_WARD is null then select min(id) into :P75_WARD from his_department where company_id = {CO} and dept_type = 'INPATIENT_WARD'; end if;",
        'end;'])
    W = ':P75_WARD is not null'
    p.dynamic('التنبيهات', 4, "return '<div id=\"nnNurseAlerts\" class=\"nn-his-alerts\"></div>';", hide_header=True, condition=W)
    p.dynamic('المناوبون', 5, 'return noona_his_nurse_pkg.on_duty_html(:P75_WARD);', hide_header=True, condition=W)
    p.dynamic('المرضى', 10, 'return noona_his_nurse_pkg.station_html(:P75_WARD);', hide_header=True, condition=W)
    p.dynamic('المستحق من الجرعات والمتابعة', 20, 'return noona_his_nurse_pkg.due_html(:P75_WARD, to_number(:P75_HOURS));', condition=W)
    p.process(1, 'ON_DEMAND', 'ALERTS', ['declare l clob := noona_his_nurse_pkg.alerts_json(to_number(apex_application.g_x01)); i pls_integer := 1;', 'begin',
        '    while i <= dbms_lob.getlength(l) loop', '        htp.prn(dbms_lob.substr(l, 8000, i));', '        i := i + 8000;', '    end loop;', 'end;'])
    p.onload([
        "document.addEventListener('click', function (e) {",
        "  var b = e.target.closest('.nn-his-pt[data-visit]'); if (!b) return;",
        "  location.href = 'f?p=' + apex.env.APP_ID + ':76:' + apex.env.APP_SESSION + '::NO:RP,76:P76_VISIT:' + b.dataset.visit;",
        "});",
        "var nnSeen = {}, nnSound = false;",
        "try { nnSound = localStorage.getItem('nnNurseSound') === 'Y'; } catch (e) {}",
        "window.nnNurseEnable = function () {",
        "  nnSound = true; try { localStorage.setItem('nnNurseSound', 'Y'); } catch (e) {}",
        "  if (window.Notification && Notification.permission === 'default') Notification.requestPermission();",
        "  nnBeep(); apex.message.showPageSuccess('تم تفعيل التنبيه الصوتي وتنبيهات المتصفح');",
        "};",
        "function nnBeep() {",
        "  try { var c = new (window.AudioContext || window.webkitAudioContext)(), o = c.createOscillator(), g = c.createGain();",
        "    o.frequency.value = 880; o.connect(g); g.connect(c.destination); g.gain.value = 0.15; o.start(); setTimeout(function () { o.stop(); c.close(); }, 450);",
        "  } catch (e) {}",
        "}",
        "function nnPoll() {",
        "  var w = $v('P75_WARD'); if (!w) return;",
        "  apex.server.process('ALERTS', { x01: w }, { dataType: 'json' }).then(function (d) {",
        "    var box = document.getElementById('nnNurseAlerts'); if (!box) return;",
        "    var fresh = 0, html = '';",
        "    (d.items || []).forEach(function (it) {",
        "      if (!nnSeen[it.k + it.late]) { nnSeen[it.k + it.late] = 1; fresh++;",
        "        if (nnSound && window.Notification && Notification.permission === 'granted')",
        "          new Notification((it.late === 'Y' ? 'متأخرة: ' : 'حان الموعد: ') + it.what, { body: it.bed + ' - ' + it.patient + ' (' + it.at + ')' }); }",
        "      html += '<span class=\"nn-his-alert' + (it.late === 'Y' ? ' is-late' : '') + '\"><b>' + apex.util.escapeHTML(it.at) + '</b> '",
        "            + apex.util.escapeHTML(it.bed + ' · ' + it.patient) + '<br><small dir=\"ltr\">' + apex.util.escapeHTML(it.what) + '</small></span>';",
        "    });",
        "    box.innerHTML = html ? '<div class=\"hd\">' + (d.overdue ? d.overdue + ' متأخرة · ' : '') + d.due + ' حان موعدها</div>' + html",
        "                         : '<div class=\"hd ok\">لا توجد جرعات أو متابعات مستحقة الآن</div>';",
        "    if (fresh && nnSound) nnBeep();",
        "  });",
        "}",
        "nnPoll(); setInterval(nnPoll, 60000);",
        "setTimeout(function () { location.reload(); }, 600000);"])
    p.branch(10, url(75, 'P75_WARD,P75_HOURS', '&P75_WARD.,&P75_HOURS.'))

    # =========================================================== 76) الملف الإلكتروني للمنوم
    p = app.page(76, 'Inpatient Chart', 'INPATIENT-CHART', 'Inpatient chart - الملف الإلكتروني للمنوم', scheme=scheme, protection='N')
    hd = p.static('المريض', 1, hide_header=True, opts='#DEFAULT#:nn-rpt-filters')
    p.select('P76_VISIT', hd, 10, 'المريض المنوم', lov_sql=INPT_LOV, submit=True)
    p.button(hd, 10, 'NURSING', 'العلامات الحيوية والملاحظات', redirect="f?p=&APP_ID.:35:&SESSION.::&DEBUG.:RP,35:P35_VISIT:&P76_VISIT.")
    p.button(hd, 20, 'RX', 'وصفة جديدة', redirect="f?p=&APP_ID.:33:&SESSION.::&DEBUG.:RP,33:P33_VISIT:&P76_VISIT.")
    p.button(hd, 30, 'VISIT', 'ملف الزيارة', redirect="f?p=&APP_ID.:31:&SESSION.::&DEBUG.:RP,31:P31_ID:&P76_VISIT.")
    p.button(hd, 40, 'PRINT', 'طباعة', redirect='javascript:window.print();')
    V = ':P76_VISIT is not null'
    fd = p.static('Record a dose - تسجيل جرعة', 5, condition=V)
    p.select('P76_DOSE', fd, 10, 'الجرعة المستحقة', lov_sql=DOSE_LOV)
    p.select('P76_OUTCOME', fd, 20, 'النتيجة', lov_sql='STATIC2:أُعطيت;GIVEN,أُجّلت;HELD,رفضها المريض;REFUSED,فاتت;MISSED', null_text=None)
    p.text('P76_DGIVEN', fd, 30, 'الجرعة المعطاة (إن اختلفت)', maxlen=100, width=12)
    p.select('P76_NURSE', fd, 40, 'الممرض', lov_sql=NURSE_LOV, null_text='- المستخدم الحالي -')
    p.text('P76_DNOTES', fd, 50, 'ملاحظات / سبب', maxlen=500)
    b_d = p.button(fd, 10, 'RECORD_DOSE', 'السجل', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Dose', ['declare l number;', 'begin',
        '    l := noona_his_nurse_pkg.record_dose(:P76_DOSE, :P76_OUTCOME, to_number(:P76_NURSE), :P76_DNOTES, :P76_DGIVEN);',
        '    :P76_DOSE := null; :P76_DNOTES := null; :P76_DGIVEN := null;', 'end;'], when_button=b_d, success='Dose recorded')
    ft = p.static('Care plan - خطة المتابعة', 6, condition=V)
    p.select('P76_TASK', ft, 10, 'المهمة', lov_sql=TASK_LOV)
    p.text('P76_TVALUE', ft, 20, 'النتيجة (مثلاً 140 ملجم/دسل، مدخول 500 مل)', maxlen=200)
    p.text('P76_TNOTES', ft, 30, 'ملاحظات', maxlen=500)
    b_tc = p.button(ft, 10, 'DONE_TASK', 'تم', hot=True)
    b_ts = p.button(ft, 20, 'STOP_TASK', 'إيقاف المهمة')
    p.select('P76_TTYPE', ft, 40, 'مهمة جديدة', lov_sql=TASK_TYPES, null_text='-')
    p.text('P76_TDESC', ft, 50, 'الوصف', maxlen=500)
    p.number('P76_TEVERY', ft, 60, 'كل (ساعات)')
    b_ta = p.button(ft, 30, 'ADD_TASK', 'إضافة مهمة')
    p.process(20, 'AFTER_SUBMIT', 'Task Done', ['declare l number;', 'begin',
        '    l := noona_his_nurse_pkg.complete_task(:P76_TASK, :P76_TVALUE, :P76_TNOTES, to_number(:P76_NURSE));',
        '    :P76_TVALUE := null; :P76_TNOTES := null;', 'end;'], when_button=b_tc, success='Task recorded')
    p.process(30, 'AFTER_SUBMIT', 'Task Stop', 'noona_his_nurse_pkg.stop_task(:P76_TASK);', when_button=b_ts, success='Task stopped')
    p.process(40, 'AFTER_SUBMIT', 'Task Add', ['declare l number; l_doc clob;', 'begin',
        "    select json_object('visit' value to_number(:P76_VISIT), 'type' value :P76_TTYPE, 'desc' value :P76_TDESC, 'every' value to_number(:P76_TEVERY)",
        "           returning clob) into l_doc from dual;",
        '    l := noona_his_nurse_pkg.add_task(l_doc);', 'end;'], when_button=b_ta, success='Task added')
    p.dynamic('المخطط', 10, 'return noona_his_nurse_pkg.inpatient_chart_html(:P76_VISIT);', hide_header=True,
              opts='#DEFAULT#:t-Region--scrollBody:nn-print-area', condition=V)
    p.onload("$('#P76_DGIVEN,#P76_DNOTES,#P76_TVALUE,#P76_TNOTES,#P76_TDESC').attr('dir', 'ltr');")
    p.branch(10, url(76, 'P76_VISIT', '&P76_VISIT.') + '&success_msg=#SUCCESS_MSG#')
