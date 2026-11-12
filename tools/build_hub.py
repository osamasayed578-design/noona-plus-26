"""NOONA_HUB (مركز الإدارة والتواصل): لوحة المدير على الهاتف، توقع النقد 90 يوماً، الإنذار المبكر وقواعده، بوابة العملاء
(روابط آمنة + صفحة عامة)، واتساب (الإعدادات والقوالب والإرسال والسجل والتذكير بالسداد)، تصدير البيانات إلى Excel،
سجل التغييرات المقروء، ومساعدة كل شاشة.
الاستخدام: python3 tools/build_hub.py  ->  apex/NOONA_HUB/f151
المنطق كله في NOONA_ENG_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_HUB/f151'),
          app_id=151, alias='NOONA_HUB', name='NOONA Management Hub', id_base=91820310000000000)
app.wire_security()
app.add_branding()
HUB = app.add_scheme('noona_hub_view', app.id(), 'NOONA - Hub',
                     "return noona_security_pkg.has_permission('ENG_ALERT.VIEW', noona_eng_pkg.company) = 'Y';",
                     'مركز الإدارة يتطلب صلاحية عرض التنبيهات / Hub access required')
WA = app.add_scheme('noona_hub_wa', app.id(), 'NOONA - Hub Messaging',
                    "return noona_security_pkg.has_permission('ENG_MESSAGE.VIEW', noona_eng_pkg.company) = 'Y';",
                    'الرسائل تتطلب صلاحية سجل الرسائل / Messaging access required')
SETUP = app.add_scheme('noona_hub_setup', app.id(), 'NOONA - Hub Setup',
                       "return noona_security_pkg.has_permission('ENG_WA_SETTING.UPDATE', noona_eng_pkg.company) = 'Y';",
                       'الإعدادات تتطلب صلاحية تعديل إعدادات واتساب / Setup access required')
ANY = app.add_scheme('noona_hub_any', app.id(), 'NOONA - Hub Any User',
                     "return noona_eng_pkg.company is not null;", 'سجل الدخول / Sign in required')
CO = 'noona_eng_pkg.company'


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


def link(page_no, item, col='ID'):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:RP,{page_no}:{item}:#{col}#'


CUST_LOV = ("select noona_sal_pkg.customer_label(a.id) d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id "
            f"where a.company_id = {CO} and a.status_code = 'ACTIVE' and nvl(c.is_walk_in, 'N') = 'N' order by 1")
EVENTS = ('STATIC2:فاتورة;INVOICE,كشف حساب;STATEMENT,تأكيد سداد;PAYMENT,تذكير بالسداد;REMINDER,رابط البوابة;PORTAL,'
          'طلبية;ORDER,تنبيه للمدير;ALERT,عامة;GENERAL')
METRICS = ('STATIC2:انخفاض النقد عن حد;CASH_LOW,عجز نقدي متوقع خلال أيام;FORECAST_NEGATIVE,الذمم المتأخرة تتجاوز حداً;AR_OVERDUE,'
           'عملاء تجاوزوا حد الائتمان;OVER_CREDIT_LIMIT,أصناف تحت الحد الأدنى;STOCK_BELOW_MIN,انخفاض المبيعات بنسبة %;SALES_DROP,'
           'تحويلات ميدانية لم تؤكد;PENDING_COLLECTIONS,شيكات تستحق قريباً;CHEQUES_DUE,مستحقات موردين قريبة;AP_DUE')
SEV = 'STATIC2:منخفضة;LOW,متوسطة;MEDIUM,عالية;HIGH,حرجة;CRITICAL'
WA_LINK_JS = ["document.addEventListener('click', function (e) {",
              "  var a = e.target.closest('a.nn-wa-open'); if (!a) return;",
              "  e.preventDefault(); window.open(a.href, '_blank', 'noopener');",
              "});"]

# =============================================================== 1) لوحة المدير
p = app.page(1, 'Home', 'HOME', 'لوحة المدير', scheme=HUB, protection='N')
st = p.static('تجهيز المركز', 5, condition="noona_eng_pkg.is_ready = 'N'",
    text='<p class="nn-hint">ينشئ قوالب رسائل واتساب الافتراضية وقواعد الإنذار المبكر (النقد، العجز المتوقع، الذمم المتأخرة، '
         'حدود الائتمان، المخزون، انخفاض المبيعات، التحصيلات والشيكات، مستحقات الموردين). مرة واحدة لكل شركة، ويمكن تعديلها لاحقاً.</p>')
b = p.button(st, 10, 'SETUP', 'تجهيز المركز', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '  l_n := noona_eng_pkg.quick_setup;', 'end;'], when_button=b,
          success='تم تجهيز القوالب وقواعد الإنذار')
qa = p.static('إجراءات', 6, hide_header=True)
b_run = p.button(qa, 10, 'RUN', 'فحص التنبيهات الآن')
p.button(qa, 20, 'FORECAST', 'توقع النقد', redirect=url(2))
p.button(qa, 30, 'SEND', 'إرسال واتساب', redirect=url(24, clear='RP,24'))
p.process(20, 'AFTER_SUBMIT', 'Run', ['declare l_n number;', 'begin', '  l_n := noona_eng_pkg.run_alerts(noona_eng_pkg.company);',
                                      "  apex_application.g_print_success_message := 'تم الفحص: ' || l_n || ' تنبيه جديد';", 'end;'],
          when_button=b_run)
p.dynamic('اللوحة', 10, 'return noona_eng_pkg.dashboard_html;', hide_header=True)
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 2) توقع النقد
p = app.page(2, 'Cash Forecast', 'FORECAST', 'توقع النقد', scheme=HUB, protection='N')
f = p.static('الفترة', 5)
p.select('P2_DAYS', f, 10, 'المدى', lov_sql='STATIC2:30 يوماً;30,60 يوماً;60,90 يوماً;90,180 يوماً;180', null_text=None, submit=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', "if :P2_DAYS is null then :P2_DAYS := '90'; end if;")
p.dynamic('التوقع الأسبوعي', 10, 'return noona_eng_pkg.forecast_html(to_number(:P2_DAYS));')

# =============================================================== 3-4) التنبيهات
p = app.page(3, 'Alerts', 'ALERTS', 'تنبيهات الإنذار المبكر', scheme=HUB)
p.ir('التنبيهات', 10, [
    'select a.id, a.alert_date, r.name_ar rule_name, noona_eng_pkg.badge(a.severity) severity_html, a.title, a.detail, a.metric_value,',
    '       a.ack_by, a.ack_at, noona_eng_pkg.badge(a.status_code) status_html',
    '  from eng_alert a join eng_alert_rule r on r.id = a.rule_id',
    f" where a.company_id = {CO} order by decode(a.status_code, 'OPEN', 0, 1), a.alert_date desc, a.id desc"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ALERT_DATE', 'اليوم', {'type': 'DATE', 'format': 'YYYY-MM-DD'}), ('RULE_NAME', 'القاعدة', {}),
     ('SEVERITY_HTML', 'الخطورة', {'html': True}), ('TITLE', 'التنبيه', {}), ('DETAIL', 'التفاصيل', {}), ('METRIC_VALUE', 'القيمة', {'type': 'NUMBER'}),
     ('ACK_BY', 'استلمه', {}), ('ACK_AT', 'وقت الاستلام', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(4, 'P4_ID'))

p = app.page(4, 'Alert', 'ALERT', 'تنبيه', scheme=HUB, protection='N')
f = p.static('التنبيه', 10)
p.hidden('P4_ID', f, 1, protected=False)
p.dynamic('التفاصيل', 5, [
    'declare l_h varchar2(32767);',
    'begin',
    f'  for a in (select a.*, r.name_ar rn from eng_alert a join eng_alert_rule r on r.id = a.rule_id where a.id = :P4_ID and a.company_id = {CO}) loop',
    "    l_h := '<div class=\"nn-al nn-al-' || lower(a.severity) || '\">' || noona_eng_pkg.badge(a.severity) || ' <b>' || apex_escape.html(a.title) || '</b>'",
    "        || '<small>' || apex_escape.html(a.rn) || ' · ' || to_char(a.alert_date, 'YYYY-MM-DD') || ' · ' || noona_eng_pkg.badge(a.status_code) || '</small>'",
    "        || case when a.detail is not null then '<p>' || apex_escape.html(a.detail) || '</p>' end || '</div>';",
    '  end loop;',
    '  return l_h;',
    'end;'])
b1 = p.button(f, 10, 'ACK', 'استلام', hot=True)
b2 = p.button(f, 20, 'CLOSE_ALERT', 'إغلاق')
p.process(10, 'AFTER_SUBMIT', 'Ack', 'noona_eng_pkg.ack_alert(:P4_ID);', when_button=b1, success='تم استلام التنبيه')
p.process(20, 'AFTER_SUBMIT', 'Close', 'noona_eng_pkg.close_alert(:P4_ID);', when_button=b2, success='تم إغلاق التنبيه')
p.branch(10, url(3) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 5-6) قواعد الإنذار
p = app.page(5, 'Alert Rules', 'RULES', 'قواعد الإنذار المبكر', scheme=SETUP)
r = p.static('قاعدة جديدة', 5)
p.button(r, 10, 'NEW', 'قاعدة جديدة', hot=True, redirect=url(6, clear='RP,6'))
p.ir('القواعد', 10, [
    'select r.id, r.code, r.name_ar, noona_eng_pkg.metric_label(r.metric) metric, r.threshold, r.days, noona_eng_pkg.badge(r.severity) severity_html,',
    "       r.notify_whatsapp, r.last_run_at, r.last_value, decode(r.is_active, 'Y', 'نعم', 'لا') active",
    f'  from eng_alert_rule r where r.company_id = {CO} order by r.id'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'القاعدة', {}), ('METRIC', 'المؤشر', {}),
     ('THRESHOLD', 'الحد', {'type': 'NUMBER'}), ('DAYS', 'الأيام', {'type': 'NUMBER'}), ('SEVERITY_HTML', 'الخطورة', {'html': True}),
     ('NOTIFY_WHATSAPP', 'واتساب المدير', {}), ('LAST_RUN_AT', 'آخر فحص', {}), ('LAST_VALUE', 'آخر قيمة', {'type': 'NUMBER'}),
     ('ACTIVE', 'نشطة', {})], link=link(6, 'P6_ID'))

p = app.page(6, 'Alert Rule', 'RULE', 'قاعدة إنذار', scheme=SETUP, protection='N')
f = p.static('القاعدة', 10, text='<p class="nn-hint">الحد: مبلغ (النقد، الذمم، المستحقات) أو عدد (العملاء، الأصناف، التحصيلات، الشيكات) أو نسبة % '
                                 '(انخفاض المبيعات). الأيام: مدى التوقع أو عمر التأخير أو نافذة الاستحقاق. يفحص النظام القواعد كل 3 ساعات '
                                 'ويبلغ مسؤولي المؤسسة، ويرسل واتساب للمدير إن أدخلت رقمه.</p>')
p.hidden('P6_ID', f, 1, protected=False)
p.text('P6_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=14)
p.text('P6_NAME', f, 20, 'الاسم', required=True, maxlen=200)
p.select('P6_METRIC', f, 30, 'المؤشر', lov_sql=METRICS, required=True)
p.number('P6_THRESHOLD', f, 40, 'الحد')
p.number('P6_DAYS', f, 50, 'الأيام')
p.select('P6_SEV', f, 60, 'الخطورة', lov_sql=SEV, null_text=None)
p.text('P6_WA', f, 70, 'واتساب المدير (اختياري)', maxlen=30, width=16)
p.yesno('P6_ACTIVE', f, 80, 'نشطة')
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for r in (select * from eng_alert_rule where id = :P6_ID and company_id = {CO}) loop',
    '    :P6_CODE := r.code; :P6_NAME := r.name_ar; :P6_METRIC := r.metric; :P6_THRESHOLD := r.threshold; :P6_DAYS := r.days;',
    '    :P6_SEV := r.severity; :P6_WA := r.notify_whatsapp; :P6_ACTIVE := r.is_active;',
    '  end loop;',
    "  if :P6_ID is null and :P6_ACTIVE is null then :P6_ACTIVE := 'Y'; :P6_SEV := 'MEDIUM'; end if;",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Save', [
    'begin',
    '  noona_security_pkg.assert_permission(\'ENG_ALERT_RULE.UPDATE\', noona_eng_pkg.company);',
    '  if :P6_ID is null then',
    '    insert into eng_alert_rule (company_id, code, name_ar, name_en, metric, threshold, days, severity, notify_whatsapp, is_active)',
    '    values (noona_eng_pkg.company, upper(:P6_CODE), :P6_NAME, upper(:P6_CODE), :P6_METRIC, to_number(:P6_THRESHOLD), to_number(:P6_DAYS),',
    '            :P6_SEV, :P6_WA, :P6_ACTIVE) returning id into :P6_ID;',
    '  else',
    '    update eng_alert_rule set code = upper(:P6_CODE), name_ar = :P6_NAME, metric = :P6_METRIC, threshold = to_number(:P6_THRESHOLD),',
    '           days = to_number(:P6_DAYS), severity = :P6_SEV, notify_whatsapp = :P6_WA, is_active = :P6_ACTIVE',
    '     where id = :P6_ID and company_id = noona_eng_pkg.company;',
    '  end if;',
    'end;'], when_button=b, success='تم حفظ القاعدة')
p.branch(10, url(6, 'P6_ID', '&P6_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10-11) بوابة العملاء
p = app.page(10, 'Portal Links', 'PORTAL-LINKS', 'روابط بوابة العملاء', scheme=WA)
r = p.static('رابط جديد', 5, text='<p class="nn-hint">رابط خاص لكل عميل أو محل يفتح بدون كلمة مرور: الفواتير والرصيد وكشف الحساب '
                                 'وتتبع الشحنات والطلبيات. يخزن الرمز مشفراً ويمكن إلغاؤه في أي وقت.</p>')
p.button(r, 10, 'NEW', 'رابط لعميل', hot=True, redirect=url(11, clear='RP,11'))
p.ir('الروابط', 10, [
    'select l.id, noona_sal_pkg.customer_label(l.customer_account_id) customer, l.phone, l.created_at, l.expires_at, l.last_access_at,',
    "       l.access_count, '…' || l.token_hint hint, noona_eng_pkg.badge(l.status_code) status_html",
    f'  from eng_portal_link l where l.company_id = {CO} order by l.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CUSTOMER', 'العميل', {}), ('PHONE', 'الجوال', {}), ('CREATED_AT', 'أنشئ', {}),
     ('EXPIRES_AT', 'ينتهي', {}), ('LAST_ACCESS_AT', 'آخر دخول', {}), ('ACCESS_COUNT', 'مرات الدخول', {'type': 'NUMBER'}),
     ('HINT', 'الرمز', {}), ('STATUS_HTML', 'الحالة', {'html': True})], link=link(11, 'P11_ID'))

p = app.page(11, 'Portal Link', 'PORTAL-LINK', 'رابط بوابة', scheme=WA, protection='N')
f = p.static('الرابط', 10)
p.hidden('P11_ID', f, 1, protected=False)
p.select('P11_CUST', f, 10, 'العميل', lov_sql=CUST_LOV, required=True)
p.number('P11_DAYS', f, 20, 'الصلاحية (أيام، 0 = دائم)')
p.text('P11_PHONE', f, 30, 'جوال الإرسال (فارغ = جوال العميل)', maxlen=30, width=16)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for l in (select * from eng_portal_link where id = :P11_ID and company_id = {CO}) loop',
    '    :P11_CUST := l.customer_account_id; :P11_PHONE := l.phone;',
    '  end loop;',
    "  if :P11_DAYS is null then :P11_DAYS := '365'; end if;",
    'end;'])
b_new = p.button(f, 10, 'CREATE', 'إنشاء الرابط', hot=True, condition=':P11_ID is null')
p.process(10, 'AFTER_SUBMIT', 'Create', ':P11_ID := noona_eng_pkg.create_link(to_number(:P11_CUST), to_number(:P11_DAYS), :P11_PHONE);',
          when_button=b_new, success='تم إنشاء الرابط')
p.dynamic('الرابط', 20, [
    'declare l_u varchar2(4000) := noona_eng_pkg.link_url(:P11_ID);',
    'begin',
    "  if l_u is null then return '<p class=\"nn-hint\">الرابط ملغى أو منتهٍ؛ أنشئ رابطاً جديداً.</p>'; end if;",
    "  return '<p><input class=\"nn-dst-find\" readonly value=\"' || apex_escape.html_attribute(l_u) || '\" onclick=\"this.select()\"></p>'",
    "      || '<div class=\"nn-dst-actions\"><a class=\"nn-dst-btn\" target=\"_blank\" rel=\"noopener\" href=\"' || apex_escape.html_attribute(l_u)",
    "      || '\"><span class=\"fa fa-external-link\"></span> فتح البوابة</a>'",
    "      || '<button type=\"button\" class=\"nn-dst-btn\" onclick=\"navigator.clipboard.writeText(this.closest(''.t-Region'').querySelector(''input'').value);apex.message.showPageSuccess(''تم النسخ'')\">'",
    "      || '<span class=\"fa fa-copy\"></span> نسخ</button></div>';",
    'end;'], condition=':P11_ID is not null')
a = p.static('الإرسال', 30, condition="noona_eng_pkg.link_url(:P11_ID) is not null")
b_send = p.button(a, 10, 'SEND_WA', 'إرسال الرابط بواتساب', hot=True)
b_rev = p.button(a, 20, 'REVOKE', 'إلغاء الرابط')
p.hidden('P11_MSG', a, 5)
p.process(20, 'AFTER_SUBMIT', 'Send', ':P11_MSG := noona_eng_pkg.send_event(\'PORTAL\', to_number(:P11_CUST), \'ENG_PORTAL_LINK\', :P11_ID, :P11_PHONE);',
          when_button=b_send, success='تم تجهيز الرسالة')
p.process(30, 'AFTER_SUBMIT', 'Revoke', 'noona_eng_pkg.revoke_link(:P11_ID);', when_button=b_rev, success='تم إلغاء الرابط')
p.dynamic('رسالة واتساب', 40, [
    'declare l_l varchar2(4000) := noona_eng_pkg.message_link(:P11_MSG);',
    'begin',
    "  if l_l is null then return '<p class=\"nn-hint\">أرسلت الرسالة عبر WhatsApp Cloud API. راجع «سجل الرسائل».</p>'; end if;",
    "  return '<a class=\"nn-dst-btn nn-dst-wa nn-wa-open\" href=\"' || apex_escape.html_attribute(l_l) || '\"><span class=\"fa fa-whatsapp\"></span> فتح واتساب وإرسال</a>';",
    'end;'], condition=':P11_MSG is not null')
p.onload(WA_LINK_JS)
p.branch(10, url(11, 'P11_ID,P11_MSG', '&P11_ID.,&P11_MSG.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) إعدادات واتساب
p = app.page(20, 'WhatsApp Settings', 'WHATSAPP', 'إعدادات واتساب', scheme=SETUP, protection='N')
f = p.static('طريقة الإرسال', 10, text=(
    '<p class="nn-hint"><b>روابط wa.me</b> (بدون اشتراك): يفتح واتساب على الجهاز برسالة جاهزة ويضغط الموظف إرسال. '
    '<b>WhatsApp Cloud API</b>: إرسال تلقائي من رقم الشركة؛ يتطلب حساب Meta Business ورقماً مفعلاً ورمز وصول دائم. '
    'الرسائل التي يبدؤها النظام (كالتذكير) تحتاج قالباً معتمداً من Meta: اكتب اسمه في القالب. '
    'رمز الوصول يدخله المسؤول هنا فقط ويحفظ مشفراً ولا يعرض بعد الحفظ.</p>'))
p.select('P20_PROVIDER', f, 10, 'الطريقة', lov_sql='STATIC2:روابط wa.me (يدوي);LINK,WhatsApp Cloud API (تلقائي);CLOUD_API', null_text=None)
p.text('P20_PHONEID', f, 20, 'Phone number ID', maxlen=50, width=24)
p.text('P20_BIZID', f, 30, 'WhatsApp Business Account ID', maxlen=50, width=24)
p.text('P20_VERSION', f, 40, 'إصدار Graph API', maxlen=10, width=8)
p.password('P20_TOKEN', f, 50, 'رمز الوصول (فارغ = إبقاء الحالي)')
p.display('P20_HAS', f, 55, 'رمز الوصول المحفوظ')
p.text('P20_CC', f, 60, 'رمز الدولة الافتراضي للأرقام المحلية', maxlen=5, width=6)
p.text('P20_SENDER', f, 70, 'رقم الإرسال (للعرض)', maxlen=30, width=16)
p.yesno('P20_ENABLED', f, 80, 'مفعل')
p.yesno('P20_CLEAR', f, 90, 'حذف رمز الوصول المحفوظ')
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for s in (select * from eng_wa_setting where company_id = {CO}) loop',
    '    :P20_PROVIDER := s.provider; :P20_PHONEID := s.phone_number_id; :P20_BIZID := s.business_account_id; :P20_VERSION := s.api_version;',
    '    :P20_CC := s.default_cc; :P20_SENDER := s.sender_phone; :P20_ENABLED := s.is_enabled;',
    '  end loop;',
    "  :P20_HAS := case noona_eng_pkg.wa_has_token when 'Y' then 'محفوظ (مشفر)' else 'لا يوجد' end;",
    "  :P20_TOKEN := null; :P20_CLEAR := 'N';",
    "  if :P20_PROVIDER is null then :P20_PROVIDER := 'LINK'; :P20_VERSION := 'v21.0'; :P20_CC := '966'; :P20_ENABLED := 'Y'; end if;",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  l.put('provider', :P20_PROVIDER); l.put('phoneId', :P20_PHONEID); l.put('businessId', :P20_BIZID); l.put('version', :P20_VERSION);",
    "  l.put('token', :P20_TOKEN); l.put('cc', :P20_CC); l.put('sender', :P20_SENDER); l.put('enabled', :P20_ENABLED); l.put('clearToken', :P20_CLEAR);",
    '  noona_eng_pkg.save_wa_setting(l.to_clob);',
    '  :P20_TOKEN := null;',
    'end;'], when_button=b, success='تم حفظ إعدادات واتساب')
t = p.static('رسالة تجربة', 20)
p.text('P20_TEST_PHONE', t, 10, 'الجوال', maxlen=30, width=16)
p.hidden('P20_MSG', t, 5)
b_t = p.button(t, 10, 'TEST', 'إرسال تجربة')
p.process(20, 'AFTER_SUBMIT', 'Test', ":P20_MSG := noona_eng_pkg.send_text(:P20_TEST_PHONE, 'رسالة تجربة من نونا بلس - ' || to_char(sysdate, 'YYYY-MM-DD HH24:MI'));",
          when_button=b_t, success='تمت المحاولة؛ راجع النتيجة')
p.dynamic('نتيجة التجربة', 30, [
    'begin',
    f'  for m in (select * from eng_message where id = :P20_MSG and company_id = {CO}) loop',
    "    return noona_eng_pkg.badge(m.status_code) || case when m.error_text is not null then ' <b>' || apex_escape.html(m.error_text) || '</b>' end",
    "        || case when m.link_url is not null then ' <a class=\"nn-dst-btn nn-dst-wa nn-wa-open\" href=\"' || apex_escape.html_attribute(m.link_url)",
    "             || '\"><span class=\"fa fa-whatsapp\"></span> فتح واتساب</a>' end;",
    '  end loop;',
    '  return null;',
    'end;'], condition=':P20_MSG is not null')
p.onload(WA_LINK_JS)
p.branch(10, url(20, 'P20_MSG', '&P20_MSG.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 21-22) القوالب
p = app.page(21, 'Templates', 'TEMPLATES', 'قوالب الرسائل', scheme=SETUP)
r = p.static('قالب جديد', 5)
p.button(r, 10, 'NEW', 'قالب جديد', hot=True, redirect=url(22, clear='RP,22'))
p.ir('القوالب', 10, [
    "select t.id, t.code, t.name_ar, t.event_code, t.body_text, t.cloud_template, t.language_code, decode(t.is_active, 'Y', 'نعم', 'لا') active",
    f'  from eng_wa_template t where t.company_id = {CO} order by t.event_code, t.code'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'الاسم', {}), ('EVENT_CODE', 'المناسبة', {}),
     ('BODY_TEXT', 'النص', {}), ('CLOUD_TEMPLATE', 'قالب Meta', {}), ('LANGUAGE_CODE', 'اللغة', {}), ('ACTIVE', 'نشط', {})], link=link(22, 'P22_ID'))

p = app.page(22, 'Template', 'TEMPLATE', 'قالب رسالة', scheme=SETUP, protection='N')
f = p.static('القالب', 10, text='<p class="nn-hint">المتغيرات: {customer} {amount} {invoice} {date} {balance} {overdue} {days} {link} {company} {title}. '
                                 'لـ Cloud API: اكتب اسم القالب المعتمد في Meta، وتمرر المتغيرات بترتيب ظهورها في النص.</p>')
p.hidden('P22_ID', f, 1, protected=False)
p.text('P22_CODE', f, 10, 'الرمز', required=True, maxlen=30, width=14)
p.text('P22_NAME', f, 20, 'الاسم', required=True, maxlen=200)
p.select('P22_EVENT', f, 30, 'المناسبة', lov_sql=EVENTS, null_text=None)
p.textarea('P22_BODY', f, 40, 'النص', required=True, rows=4)
p.text('P22_CLOUD', f, 50, 'اسم القالب المعتمد في Meta (اختياري)', maxlen=100)
p.text('P22_LANG', f, 60, 'لغة القالب', maxlen=10, width=6)
p.yesno('P22_ACTIVE', f, 70, 'نشط')
p.process(10, 'BEFORE_HEADER', 'Load', [
    'begin',
    f'  for t in (select * from eng_wa_template where id = :P22_ID and company_id = {CO}) loop',
    '    :P22_CODE := t.code; :P22_NAME := t.name_ar; :P22_EVENT := t.event_code; :P22_BODY := t.body_text; :P22_CLOUD := t.cloud_template;',
    '    :P22_LANG := t.language_code; :P22_ACTIVE := t.is_active;',
    '  end loop;',
    "  if :P22_ID is null and :P22_ACTIVE is null then :P22_ACTIVE := 'Y'; :P22_LANG := 'ar'; end if;",
    'end;'])
b = p.button(f, 10, 'SAVE', 'حفظ', hot=True)
p.process(20, 'AFTER_SUBMIT', 'Save', [
    'begin',
    "  noona_security_pkg.assert_permission('ENG_WA_TEMPLATE.UPDATE', noona_eng_pkg.company);",
    '  if :P22_ID is null then',
    '    insert into eng_wa_template (company_id, code, name_ar, name_en, event_code, body_text, cloud_template, language_code, is_active)',
    '    values (noona_eng_pkg.company, upper(:P22_CODE), :P22_NAME, upper(:P22_CODE), :P22_EVENT, :P22_BODY, :P22_CLOUD, nvl(:P22_LANG, \'ar\'), :P22_ACTIVE)',
    '    returning id into :P22_ID;',
    '  else',
    '    update eng_wa_template set code = upper(:P22_CODE), name_ar = :P22_NAME, event_code = :P22_EVENT, body_text = :P22_BODY,',
    "           cloud_template = :P22_CLOUD, language_code = nvl(:P22_LANG, 'ar'), is_active = :P22_ACTIVE",
    '     where id = :P22_ID and company_id = noona_eng_pkg.company;',
    '  end if;',
    'end;'], when_button=b, success='تم حفظ القالب')
p.branch(10, url(22, 'P22_ID', '&P22_ID.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 23) سجل الرسائل
p = app.page(23, 'Messages', 'MESSAGES', 'سجل الرسائل', scheme=WA)
p.ir('الرسائل', 10, [
    'select m.id, m.created_at, m.to_phone, noona_sal_pkg.customer_label(m.customer_account_id) customer, m.body_text, m.entity_type,',
    "       noona_eng_pkg.badge(m.status_code) status_html, m.error_text, m.sent_at, m.created_by,",
    "       case when m.link_url is not null then '<a class=\"nn-dst-btn nn-dst-wa nn-wa-open\" href=\"' || apex_escape.html_attribute(m.link_url)",
    "            || '\"><span class=\"fa fa-whatsapp\"></span> فتح</a>' end open_html",
    f'  from eng_message m where m.company_id = {CO} order by m.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CREATED_AT', 'الوقت', {}), ('TO_PHONE', 'إلى', {}), ('CUSTOMER', 'العميل', {}),
     ('BODY_TEXT', 'النص', {}), ('ENTITY_TYPE', 'المرتبط', {}), ('STATUS_HTML', 'الحالة', {'html': True}), ('ERROR_TEXT', 'الخطأ', {}),
     ('SENT_AT', 'أرسلت', {}), ('CREATED_BY', 'بواسطة', {}), ('OPEN_HTML', 'واتساب', {'html': True})])
p.onload(WA_LINK_JS)

# =============================================================== 24) إرسال
p = app.page(24, 'Send WhatsApp', 'SEND', 'إرسال واتساب', scheme=WA, protection='N')
f = p.static('رسالة لعميل', 10)
p.select('P24_CUST', f, 10, 'العميل', lov_sql=CUST_LOV, required=True)
p.select('P24_EVENT', f, 20, 'الرسالة', lov_sql='STATIC2:كشف الحساب والرصيد;STATEMENT,تذكير بالسداد;REMINDER,رابط البوابة;PORTAL', null_text=None)
p.text('P24_PHONE', f, 30, 'الجوال (فارغ = جوال العميل)', maxlen=30, width=16)
p.hidden('P24_MSG', f, 5)
b = p.button(f, 10, 'SEND', 'تجهيز وإرسال', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Send', ":P24_MSG := noona_eng_pkg.send_event(:P24_EVENT, to_number(:P24_CUST), 'AR_CUSTOMER_ACCOUNT', to_number(:P24_CUST), :P24_PHONE);",
          when_button=b, success='تم تجهيز الرسالة')
p.dynamic('الرسالة', 20, [
    'begin',
    f'  for m in (select * from eng_message where id = :P24_MSG and company_id = {CO}) loop',
    "    return '<p>' || apex_escape.html(m.body_text) || '</p>' || noona_eng_pkg.badge(m.status_code)",
    "        || case when m.error_text is not null then ' ' || apex_escape.html(m.error_text) end",
    "        || case when m.link_url is not null then ' <a class=\"nn-dst-btn nn-dst-wa nn-wa-open\" href=\"' || apex_escape.html_attribute(m.link_url)",
    "             || '\"><span class=\"fa fa-whatsapp\"></span> فتح واتساب وإرسال</a>' end;",
    '  end loop;',
    '  return null;',
    'end;'], condition=':P24_MSG is not null')
rm = p.static('تذكير جماعي بالسداد', 30, text='<p class="nn-hint">يجهز رسالة تذكير لكل عميل عليه مبالغ متأخرة. مع Cloud API ترسل تلقائياً؛ '
                                            'مع روابط wa.me تظهر في «سجل الرسائل» بزر فتح لكل عميل.</p>')
p.number('P24_DAYS', rm, 10, 'متأخر أكثر من (يوم)')
b2 = p.button(rm, 10, 'REMIND', 'تجهيز التذكيرات')
p.process(20, 'AFTER_SUBMIT', 'Remind', ['declare l_n number;', 'begin', '  l_n := noona_eng_pkg.send_reminders(nvl(to_number(:P24_DAYS), 1));',
                                         "  apex_application.g_print_success_message := 'تم تجهيز ' || l_n || ' رسالة تذكير';", 'end;'], when_button=b2)
p.onload(WA_LINK_JS)
p.branch(5, url(23) + '&success_msg=#SUCCESS_MSG#', when_button=b2)
p.branch(10, url(24, 'P24_MSG,P24_CUST', '&P24_MSG.,&P24_CUST.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) تصدير البيانات
p = app.page(30, 'Data Export', 'EXPORT', 'تصدير البيانات', scheme=ANY, protection='N')
p.header = p.header.replace(",p_protection_level=>", ",p_reload_on_submit=>'A'\n,p_protection_level=>", 1)   # التنزيل يتطلب إعادة التحميل دائماً
f = p.static('مجموعة البيانات', 10, text='<p class="nn-hint">يصدر بيانات الشركة الحالية التي لديك صلاحية عرضها، بعناوين أعمدة عربية، '
                                         'دون الأعمدة الحساسة. لتصدير تقرير بمرشحاته استخدم «الإجراءات ← تنزيل» في التقرير نفسه.</p>')
p.select('P30_TABLE', f, 10, 'البيانات', lov_sql=(
    "select e.name_ar || ' (' || e.module_code || ')' d, e.table_name r from ref_entity_type e where e.is_active = 'Y' "
    "and noona_security_pkg.has_permission(e.table_name || '.VIEW', noona_eng_pkg.company) = 'Y' order by e.module_code, e.name_ar"), required=True)
p.select('P30_FMT', f, 20, 'الصيغة', lov_sql='STATIC2:Excel (xlsx);XLSX,CSV;CSV', null_text=None)
b = p.button(f, 10, 'EXPORT', 'تصدير وتنزيل', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Export', [
    'declare',
    '  l_ctx apex_exec.t_context;',
    '  l_exp apex_data_export.t_export;',
    'begin',
    '  l_ctx := apex_exec.open_query_context(p_location => apex_exec.c_location_local_db, p_sql_query => noona_eng_pkg.export_sql(:P30_TABLE));',
    '  l_exp := apex_data_export.export(p_context => l_ctx,',
    "            p_format => case :P30_FMT when 'CSV' then apex_data_export.c_format_csv else apex_data_export.c_format_xlsx end,",
    '            p_file_name => noona_eng_pkg.export_name(:P30_TABLE));',
    '  apex_exec.close(l_ctx);',
    '  apex_data_export.download(p_export => l_exp);',
    'exception when others then',
    '  apex_exec.close(l_ctx);',
    '  raise;',
    'end;'], when_button=b)

# =============================================================== 31) سجل التغييرات
p = app.page(31, 'Change History', 'HISTORY', 'سجل التغييرات', scheme=HUB, protection='N')
f = p.static('المرشحات', 10, text='<p class="nn-hint">من غيّر ماذا ومتى، بالقيمة السابقة والجديدة، على الجداول الرئيسية (العملاء، الموردون، '
                                  'الأصناف، الأسعار، الحسابات، الصناديق والبنوك، الموظفون، المندوبون والمحلات، الأسطول...).</p>')
p.select('P31_TABLE', f, 10, 'البيانات', lov_sql=(
    "select distinct noona_eng_pkg.table_label(table_name) d, table_name r from eng_change_log order by 1"), null_text='- الكل -')
p.number('P31_ROW', f, 20, 'رقم السجل (اختياري)')
p.date('P31_FROM', f, 30, 'من')
p.date('P31_TO', f, 40, 'إلى')
p.text('P31_USER', f, 50, 'المستخدم', maxlen=128, width=16)
p.button(f, 10, 'SHOW', 'عرض', hot=True)
p.process(5, 'BEFORE_HEADER', 'Defaults', [
    'begin',
    "  if :P31_FROM is null then :P31_FROM := to_char(sysdate - 30, 'YYYY-MM-DD'); end if;",
    "  if :P31_TO is null then :P31_TO := to_char(sysdate, 'YYYY-MM-DD'); end if;",
    'end;'])
p.dynamic('التغييرات', 20, "return noona_eng_pkg.history_html(:P31_TABLE, to_number(:P31_ROW), to_date(:P31_FROM, 'YYYY-MM-DD'), "
                           "to_date(:P31_TO, 'YYYY-MM-DD'), :P31_USER);")

# =============================================================== 40) المساعدة
p = app.page(40, 'Screen Help', 'HELP', 'مساعدة الشاشة', scheme=ANY, protection='N')
f = p.static('الشاشة', 5, hide_header=True)
p.hidden('P40_APP', f, 1, protected=False)
p.hidden('P40_PAGE', f, 2, protected=False)
p.dynamic('المساعدة', 10, "return noona_eng_pkg.help_html(to_number(:P40_APP), to_number(:P40_PAGE));", hide_header=True,
          condition=':P40_APP is not null')

e = p.static('تعديل الشرح', 20, condition=(":P40_APP is not null and noona_security_pkg.has_permission('ENG_HELP.UPDATE', noona_eng_pkg.company) = 'Y'"))
p.textarea('P40_PURPOSE', e, 10, 'الغرض من الشاشة', rows=3)
p.textarea('P40_STEPS', e, 20, 'خطوات العمل (سطر لكل خطوة)', rows=5)
p.textarea('P40_TIPS', e, 30, 'تنبيهات ونصائح', rows=3)
p.text('P40_VIDEO', e, 40, 'رابط فيديو الشرح', maxlen=500)
p.process(5, 'BEFORE_HEADER', 'Load', [
    'begin',
    '  for h in (select h.* from eng_help h join apex_applications a on a.alias = h.app_alias',
    '             where a.application_id = :P40_APP and h.page_id = :P40_PAGE order by nvl2(h.tenant_id, 0, 1) fetch first 1 rows only) loop',
    '    :P40_PURPOSE := h.purpose; :P40_STEPS := h.steps; :P40_TIPS := h.tips; :P40_VIDEO := h.video_url;',
    '  end loop;',
    'end;'])
b = p.button(e, 10, 'SAVE', 'حفظ الشرح', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Save', [
    'declare l json_object_t := json_object_t();',
    'begin',
    "  for a in (select alias from apex_applications where application_id = :P40_APP) loop l.put('app', a.alias); end loop;",
    "  l.put('page', :P40_PAGE); l.put('purpose', :P40_PURPOSE); l.put('steps', :P40_STEPS); l.put('tips', :P40_TIPS); l.put('video', :P40_VIDEO);",
    '  noona_eng_pkg.save_help(l.to_clob);',
    'end;'], when_button=b, success='تم حفظ الشرح')
p.branch(10, url(40, 'P40_APP,P40_PAGE', '&P40_APP.,&P40_PAGE.') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 41) دليل الشاشات
p = app.page(41, 'Screens Guide', 'GUIDE', 'دليل الشاشات', scheme=ANY, protection='N')
p.dynamic('دليل الأنظمة', 10, [
    'declare l_h clob;',
    'begin',
    "  for a in (select application_id, application_name from apex_applications where alias like 'NOONA%' order by application_id) loop",
    "    l_h := l_h || '<h3>' || apex_escape.html(a.application_name) || '</h3><div class=\"nn-dst-actions\">';",
    "    for g in (select page_id, nvl(page_title, page_name) t from apex_application_pages where application_id = a.application_id",
    "               and page_id not in (0, 9999) and nvl(page_title, page_name) is not null order by page_id) loop",
    "      l_h := l_h || '<a class=\"nn-dst-btn\" href=\"' || apex_page.get_url(p_page => 40, p_items => 'P40_APP,P40_PAGE', p_values => a.application_id || ',' || g.page_id)",
    "          || '\">' || apex_escape.html(g.t) || '</a>';",
    '    end loop;',
    "    l_h := l_h || '</div>';",
    '  end loop;',
    '  return l_h;',
    'end;'], hide_header=True)

# =============================================================== 100) بوابة العملاء (عامة)
p = app.page(100, 'Customer Portal', 'PORTAL', 'حسابي', protection='N', public=True)
f = p.static('البوابة', 5, hide_header=True)
p.hidden('P100_T', f, 1, protected=False)
p.hidden('P100_TAB', f, 2, protected=False)
p.dynamic('حسابي', 10, 'return noona_eng_pkg.portal_html(:P100_T, :P100_TAB);', hide_header=True)

# =============================================================== القائمة
app.nav_item('لوحة المدير', 1, 'fa-tachometer', 10)
app.nav_item('توقع النقد', 2, 'fa-line-chart', 20, scheme=HUB)
al = app.nav_item('الإنذار المبكر', None, 'fa-bell', 30, scheme=HUB)
app.nav_item('التنبيهات', 3, 'fa-bell-o', 31, parent=al, scheme=HUB)
app.nav_item('القواعد', 5, 'fa-sliders', 32, parent=al, scheme=SETUP)
wa = app.nav_item('واتساب والعملاء', None, 'fa-whatsapp', 40, scheme=WA)
app.nav_item('إرسال رسالة', 24, 'fa-paper-plane', 41, parent=wa, scheme=WA)
app.nav_item('سجل الرسائل', 23, 'fa-list', 42, parent=wa, scheme=WA)
app.nav_item('روابط بوابة العملاء', 10, 'fa-link', 43, parent=wa, scheme=WA)
app.nav_item('قوالب الرسائل', 21, 'fa-file-text-o', 44, parent=wa, scheme=SETUP)
app.nav_item('إعدادات واتساب', 20, 'fa-cog', 45, parent=wa, scheme=SETUP)
dt = app.nav_item('البيانات', None, 'fa-database', 50)
app.nav_item('تصدير إلى Excel', 30, 'fa-file-excel-o', 51, parent=dt)
app.nav_item('سجل التغييرات', 31, 'fa-history', 52, parent=dt, scheme=HUB)
app.nav_item('دليل الشاشات', 41, 'fa-question-circle', 53, parent=dt)

app.finalize()
_ca = os.path.join(app.dir, 'application', 'create_application.sql')
if os.path.exists(_ca):
    _s = open(_ca, encoding='utf-8').read().replace(",p_pwa_is_installable=>'N'", ",p_pwa_is_installable=>'Y'")
    open(_ca, 'w', encoding='utf-8').write(_s)
print('NOONA_HUB built:', len(app.pages), 'pages')
