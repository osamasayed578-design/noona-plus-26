"""NOONA_MASTER (التطبيق الرئيسي) - الدخول الموحد وشاشة الأنظمة المشترك فيها
الاستخدام: python3 tools/build_master.py   ->  apex/NOONA_MASTER/f115
كل التطبيقات الأخرى تحيل غير المسجلين إلى صفحة الدخول هنا (tools/apex_brand.py).
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_MASTER/f115'),
          app_id=115, alias='NOONA_MASTER', name='NOONA PLUS', id_base=91820263000000000)
app.wire_security()
app.add_branding()

# =============================================================== 1) شاشة الأنظمة
p = app.page(1, 'Home', 'HOME', 'الأنظمة')
p.dynamic('الأنظمة', 10, [
    'declare',
    '    l_aliases varchar2(4000);',
    'begin',
    '    -- التطبيقات المثبتة فعلاً في مساحة العمل (غير المثبت يظهر "قيد الإنشاء")',
    "    select listagg(alias, ',') within group (order by alias) into l_aliases from apex_applications;",
    '    return noona_ui_pkg.launcher(p_session => :APP_SESSION, p_existing_aliases => l_aliases);',
    'end;'], hide_header=True, opts='#DEFAULT#:t-Region--noPadding')

# =============================================================== 10) تغيير كلمة المرور
p = app.page(10, 'Change Password', 'CHANGE-PASSWORD', 'تغيير كلمة المرور')
f = p.static('تغيير كلمة المرور', 10)
p.password('P10_OLD', f, 10, 'كلمة المرور الحالية', required=True)
p.password('P10_NEW', f, 20, 'كلمة المرور الجديدة (10 أحرف: كبير وصغير ورقم)', required=True)
p.password('P10_CONFIRM', f, 30, 'تأكيد كلمة المرور الجديدة', required=True)
b = p.button(f, 10, 'CHANGE', 'تغيير كلمة المرور', hot=True)
p.button(f, 20, 'BACK', 'رجوع', redirect='f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::')
p.process(10, 'AFTER_SUBMIT', 'Change Password', [
    'declare',
    "    l_verified varchar2(1) := 'N';",
    'begin',
    '    if :P10_NEW <> :P10_CONFIRM then',
    "        raise_application_error(-20500, 'NOONA-SEC-255: كلمة المرور الجديدة وتأكيدها غير متطابقين');",
    '    end if;',
    '    -- مستخدم ما زال يدخل بحساب APEX: يتحقق من كلمته الحالية هناك',
    "    if noona_apex_pkg.check_password(:APP_USER, :P10_OLD) = 'NO_LOCAL'",
    '       and apex_util.is_login_password_valid(p_username => :APP_USER, p_password => :P10_OLD) then',
    "        l_verified := 'Y';",
    '    end if;',
    '    noona_sec_admin_pkg.change_password(p_old_password => :P10_OLD, p_new_password => :P10_NEW,',
    '                                        p_old_verified => l_verified);',
    '    :P10_OLD := null; :P10_NEW := null; :P10_CONFIRM := null;',
    'end;'], when_button=b, success='تم تغيير كلمة المرور؛ استخدمها في الدخول القادم')
p.branch(10, 'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:10::&success_msg=#SUCCESS_MSG#')

app.nav_item('الأنظمة', 1, 'fa-th', 10)
app.nav_item('تغيير كلمة المرور', 10, 'fa-key', 20)

# =============================================================== 20) التسجيل الذاتي (صفحة عامة)
import signup_pages
signup_pages.add(app)
signup_pages.add_reset(app)

app.finalize()
signup_pages.login_link(os.path.join(ROOT, 'apex/NOONA_MASTER/f115'))
print('NOONA_MASTER built:', len(app.pages), 'pages')
