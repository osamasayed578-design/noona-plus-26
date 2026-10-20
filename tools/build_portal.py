"""NOONA_PORTAL (مهامي وإشعاراتي) - يبني التطبيق من القالب عبر tools/apexgen.py
الاستخدام: python3 tools/build_portal.py   ->  apex/NOONA_PORTAL/f119
رابط الإشعار: f?p=NOONA_PORTAL:TASK:::NO::P2_TASK_ID:<id> (الصفحة والعنصر بلا حماية لأن الرابط من خارج الجلسة)
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_PORTAL/f119'),
          app_id=119, alias='NOONA_PORTAL', name='NOONA Portal', id_base=91820264000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']
HOME = 'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
MEMBER_LOV = ("select u.display_name || ' (' || u.username || ')' d, m.id r from sec_user_membership m "
              "join sec_user u on u.id = m.user_id where m.status_code = 'ACTIVE' "
              "and m.id <> to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID')) order by 1")

# =============================================================== 1) مهامي
p = app.page(1, 'Home', 'HOME', 'مهامي وإشعاراتي', scheme=TENANT)
p.dynamic('لوحة اليوم', 10, 'return noona_ui_pkg.home_summary(p_session => :APP_SESSION);', hide_header=True)
p.dynamic('مهامي', 20, 'return noona_ui_pkg.task_cards(p_session => :APP_SESSION);')
nt = p.dynamic('الإشعارات', 30, 'return noona_ui_pkg.notification_list(p_session => :APP_SESSION);')
b = p.button(nt, 10, 'MARK_ALL_READ', 'تعليم الكل كمقروء')
p.process(10, 'AFTER_SUBMIT', 'Mark All Read', 'noona_portal_pkg.mark_all_read;', when_button=b, success='تم تعليم الإشعارات كمقروءة')
p.branch(10, HOME + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 2) المهمة
p = app.page(2, 'Task', 'TASK', 'المهمة', scheme=TENANT, protection='N')
p.dynamic('تفاصيل المهمة', 10, 'return noona_ui_pkg.task_header(p_task_id => :P2_TASK_ID);')
act = p.static('الإجراء', 20)
p.hidden('P2_TASK_ID', act, 1, protected=False)
p.textarea('P2_COMMENTS', act, 10, 'الملاحظات (إلزامية للرفض والإرجاع وطلب المعلومات)', rows=3)
for seq, name, label, hot in [(10, 'APPROVE', 'اعتماد', True), (20, 'REJECT', 'رفض', False),
                              (30, 'RETURN', 'إرجاع للطالب', False), (40, 'REQUEST_INFO', 'طلب معلومات', False)]:
    p.button(act, seq, name, label, hot=hot)
p.button(act, 50, 'BACK', 'رجوع', redirect=HOME)
p.process(10, 'AFTER_SUBMIT', 'Task Action',
          'noona_portal_pkg.task_action(p_task_id => :P2_TASK_ID, p_action => :REQUEST, p_comments => :P2_COMMENTS);',
          when=":REQUEST in ('APPROVE', 'REJECT', 'RETURN', 'REQUEST_INFO')", success='تم تنفيذ الإجراء')
p.dynamic('سجل المسار', 30, 'return noona_ui_pkg.task_timeline(p_task_id => :P2_TASK_ID);')
p.branch(10, HOME + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 3) تبديل الشركة
p = app.page(3, 'Switch Company', 'COMPANY', 'تبديل الشركة', scheme=TENANT)
f = p.static('تبديل الشركة', 10)
p.select('P3_COMPANY_ID', f, 10, 'الشركة', lov_name='NOONA_COMPANIES', required=True)
b = p.button(f, 10, 'SWITCH', 'تبديل', hot=True)
p.button(f, 20, 'CANCEL', 'إلغاء', redirect=HOME)
p.process(10, 'BEFORE_HEADER', 'Current Company', ":P3_COMPANY_ID := sys_context('NOONA_CTX', 'COMPANY_ID');")
p.process(10, 'AFTER_SUBMIT', 'Switch Company', 'noona_apex_pkg.switch_company(p_company_id => :P3_COMPANY_ID);',
          when_button=b, success='تم تبديل الشركة')
p.branch(10, HOME + '&success_msg=#SUCCESS_MSG#', when_button=b)

# =============================================================== 4) طلباتي
p = app.page(4, 'My Requests', 'MY-REQUESTS', 'طلباتي', scheme=TENANT)
p.ir('طلباتي', 10, [
    'select i.id, d.name_ar as workflow_name, nvl(e.name_ar, i.object_type) as object_name, i.object_id,',
    "       to_char(i.started_at, 'YYYY-MM-DD HH24:MI') as started_at,",
    '       (select listagg(s.name_ar, \'، \') within group (order by t.id) from wf_task t join wf_step_def s on s.id = t.step_id',
    "         where t.instance_id = i.id and t.status_code in ('OPEN', 'CLAIMED', 'WAITING')) as current_step,",
    '       noona_ui_pkg.status_badge(i.status_code) as status_html,',
    "       case i.outcome_code when 'APPROVED' then 'معتمد' when 'REJECTED' then 'مرفوض' when 'RETURNED' then 'معاد' end as outcome",
    '  from wf_instance i join wf_definition_version v on v.id = i.version_id join wf_definition d on d.id = v.definition_id',
    '  left join ref_entity_type e on e.entity_type_code = i.object_type',
    " where i.initiator_member_id = to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID'))",
    ' order by i.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('WORKFLOW_NAME', 'المسار', {}), ('OBJECT_NAME', 'المستند', {}),
     ('OBJECT_ID', 'رقمه', {'type': 'NUMBER'}), ('STARTED_AT', 'تاريخ الطلب', {}), ('CURRENT_STEP', 'عند', {}),
     ('STATUS_HTML', 'الحالة', {'html': True}), ('OUTCOME', 'النتيجة', {})])

# =============================================================== 5) تفويضاتي (خدمة ذاتية: قبل الإجازة مثلاً)
p = app.page(5, 'My Delegations', 'MY-DELEGATIONS', 'تفويضاتي', scheme=TENANT)
p.ir('تفويضاتي', 10, [
    'select d.id, d.delegation_no, noona_ui_pkg.code_label(d.delegation_type) as dtype,',
    "       case when d.grantor_member_id = to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID')) then 'مني' else 'إلي' end as direction,",
    '       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id',
    "         where m.id = case when d.grantor_member_id = to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID'))",
    '                          then d.delegate_member_id else d.grantor_member_id end) as other_party,',
    "       to_char(d.starts_at, 'YYYY-MM-DD') as starts_at, to_char(d.ends_at, 'YYYY-MM-DD') as ends_at, d.reason,",
    '       noona_ui_pkg.status_badge(d.status_code) as status_html',
    '  from dlg_delegation d',
    " where to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID')) in (d.grantor_member_id, d.delegate_member_id)",
    ' order by d.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('DELEGATION_NO', 'الرقم', {}), ('DTYPE', 'النوع', {}),
     ('DIRECTION', 'الاتجاه', {}), ('OTHER_PARTY', 'الطرف الآخر', {}), ('STARTS_AT', 'من', {}), ('ENDS_AT', 'إلى', {}),
     ('REASON', 'السبب', {}), ('STATUS_HTML', 'الحالة', {'html': True})])
f = p.static('تفويض صلاحياتي لزميل', 20)
p.select('P5_TYPE', f, 10, 'نوع التفويض', null_text=None, lov_sql=(
    'STATIC2:اعتماد;APPROVAL,بالإنابة;ACTING,تشغيلي;OPERATIONAL,مراسلات;CORRESPONDENCE'))
p.select('P5_DELEGATE', f, 20, 'المفوض إليه', required=True, lov_sql=MEMBER_LOV)
p.date('P5_FROM', f, 30, 'من تاريخ', required=True)
p.date('P5_TO', f, 40, 'إلى تاريخ', required=True)
p.textarea('P5_REASON', f, 50, 'السبب (مثال: إجازة سنوية)', required=True, rows=2)
b = p.button(f, 10, 'CREATE', 'إرسال التفويض للاعتماد', hot=True)
p.process(10, 'BEFORE_HEADER', 'Defaults', [":P5_FROM := nvl(:P5_FROM, to_char(sysdate, 'YYYY-MM-DD'));"])
p.process(10, 'AFTER_SUBMIT', 'Create Delegation', [
    'declare l_id number;',
    'begin',
    "    l_id := noona_delegation_pkg.create_delegation(p_delegation_type => nvl(:P5_TYPE, 'APPROVAL'),",
    "        p_grantor_member_id => to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID')), p_delegate_member_id => :P5_DELEGATE,",
    "        p_starts_at => to_date(:P5_FROM, 'YYYY-MM-DD'), p_ends_at => to_date(:P5_TO, 'YYYY-MM-DD') + 1 - 1 / 86400,",
    '        p_reason => :P5_REASON);',
    '    noona_delegation_pkg.submit(l_id);',
    'end;'], when_button=b, success='تم إرسال التفويض؛ يسري بعد اعتماده')
cx = p.static('إلغاء تفويض', 30)
p.select('P5_CANCEL_ID', cx, 10, 'التفويض', lov_sql=(
    "select delegation_no || ' · ' || to_char(starts_at, 'YYYY-MM-DD') || ' - ' || to_char(ends_at, 'YYYY-MM-DD') d, id r "
    "from dlg_delegation where grantor_member_id = to_number(sys_context('NOONA_CTX', 'MEMBERSHIP_ID')) "
    "and status_code in ('SUBMITTED', 'APPROVED', 'SCHEDULED', 'ACTIVE', 'SUSPENDED') order by id desc"))
p.text('P5_CANCEL_REASON', cx, 20, 'سبب الإلغاء')
b2 = p.button(cx, 10, 'REVOKE', 'إلغاء التفويض')
p.process(20, 'AFTER_SUBMIT', 'Revoke Delegation', 'noona_delegation_pkg.revoke_delegation(:P5_CANCEL_ID, :P5_CANCEL_REASON);',
          when_button=b2, success='تم إلغاء التفويض')
p.branch(10, 'f?p=&APP_ID.:5:&SESSION.::&DEBUG.:5::&success_msg=#SUCCESS_MSG#')

app.nav_item('مهامي وإشعاراتي', 1, 'fa-inbox', 10)
app.nav_item('طلباتي', 4, 'fa-paper-plane-o', 20)
app.nav_item('تفويضاتي', 5, 'fa-share', 30)
app.nav_item('تبديل الشركة', 3, 'fa-building-o', 40)

app.finalize()
print('NOONA_PORTAL built:', len(app.pages), 'pages')
