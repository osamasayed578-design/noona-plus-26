"""صفحات واجهات API والتكاملات:
  * تطبيق إدارة المؤسسة (123) صفحات 70-77: لوحة التكاملات، عملاء API، سجل الطلبات، Webhooks، الأحداث الصادرة، قنوات الرسائل،
    استيراد البيانات (CSV)، نقاط النهاية وتوثيق OpenAPI.
  * تطبيق المالية (127) صفحتا 79-80: كشوف الحساب البنكية والمطابقة التلقائية.
المنطق كله في NOONA_API_PKG و NOONA_CONN_PKG.
"""

EVENTS = ('STATIC2:كل الأحداث;*,فاتورة مبيعات مرحلة;SAL_INVOICE.POSTED,تحصيل من عميل;AR_RECEIPT.CREATED,'
          'فاتورة مورد مرحلة;AP_INVOICE.POSTED,توقيع عقد بيع وحدة;RE_SALE_CONTRACT.SIGNED,تفعيل عقد إيجار;PRP_LEASE.ACTIVATED,سيارة جاهزة للاستلام;AUT_JOB_CARD.READY,'
          'طلب متجر إلكتروني;ORDER.CREATED')

# قراءة ملف مرفوع (APEX_APPLICATION_TEMP_FILES) نصاً UTF-8
READ_FILE = [
    "    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = {item};",
    "    l_csv := apex_util.blob_to_clob(p_blob => l_blob, p_charset => 'AL32UTF8');",
]


def build_admin(app, url):
    CO = 'noona_api_pkg.company'
    API = app.add_scheme('noona_api_view', app.id(), 'NOONA - Integrations',
                         f"return noona_security_pkg.has_permission('API_CLIENT.VIEW', {CO}) = 'Y';",
                         'صفحات التكاملات تتطلب صلاحية عرض عملاء API / Integrations access required')
    CLIENT_LOV = "select name_ar || ' (' || client_id || ')' d, id r from api_client order by id desc"
    WH_LOV = ("select noona_api_pkg.event_label(event_type) || ' ← ' || target_url d, id r from api_webhook_subscription where status_code <> 'DISABLED' "
              "order by id desc")
    ROLE_LOV = "select name_ar d, id r from sec_role where status_code = 'ACTIVE' order by name_ar"
    CO_LOV = ("select nvl(trade_name_ar, legal_name_ar) d, id r from org_company where status_code not in ('CLOSED', 'ARCHIVED') "
              "and noona_sec_admin_pkg.can_admin_company(id) = 'Y' order by 1")

    # =============================================================== 70) لوحة التكاملات
    p = app.page(70, 'Integrations', 'INTEGRATIONS', 'التكاملات وواجهات API', scheme=API)
    p.dynamic('مؤشرات التكاملات', 10, 'return noona_api_pkg.summary_html;', hide_header=True)
    qa = p.static('إجراءات', 15, hide_header=True)
    p.button(qa, 10, 'CLIENTS', 'عملاء API', hot=True, redirect=url(71))
    p.button(qa, 20, 'WEBHOOKS', 'Webhooks', redirect=url(73))
    p.button(qa, 30, 'OUTBOX', 'الأحداث الصادرة', redirect=url(74))
    p.button(qa, 40, 'CHANNELS', 'الرسائل SMS / واتساب', redirect=url(75))
    p.button(qa, 50, 'IMPORT', 'استيراد البيانات', redirect=url(76))
    p.button(qa, 60, 'DOCS', 'نقاط النهاية والتوثيق', redirect=url(77))
    p.static('كيف تتكامل', 20, text=(
        '<ol class="nn-hint"><li>أنشئ <b>عميل API</b> لكل نظام خارجي (متجر، تطبيق جوال، نظام شريك) بدور يحدد ما يستطيع الوصول إليه.</li>'
        '<li>النظام يطلب رمز دخول: <code dir="ltr">POST /ords/noona/v1/token</code> بمعرف العميل والسر، ثم يرسل '
        '<code dir="ltr">Authorization: Bearer &lt;token&gt;</code> مع كل طلب.</li>'
        '<li>العمليات المالية (الفواتير والتحصيل) تتطلب ترويسة <code dir="ltr">Idempotency-Key</code> فلا تتكرر عند إعادة الإرسال.</li>'
        '<li>للإشعار الفوري بالأحداث سجل <b>Webhook</b>: يصل كل حدث موقعاً بـ <code dir="ltr">X-Noona-Signature</code> '
        '(HMAC-SHA256) ويعاد إرساله تلقائياً عند الفشل.</li></ol>'))
    p.dynamic('آخر الطلبات', 30, 'return noona_api_pkg.requests_html;')

    # =============================================================== 71) عملاء API
    p = app.page(71, 'API Clients', 'API-CLIENTS', 'عملاء API', scheme=API)
    p.dynamic('العملاء', 10, 'return noona_api_pkg.clients_html;')
    f = p.static('عميل جديد', 20, text='<p class="nn-hint">ينشأ لكل عميل حساب خدمة بالدور والشركة المحددين، فتطبق عليه نفس صلاحيات '
                                        'المستخدمين وعزل البيانات. <b>السر يظهر مرة واحدة فقط</b> بعد الإنشاء؛ احفظه في النظام المتكامل.</p>')
    p.text('P71_NAME', f, 10, 'اسم العميل / النظام', required=True, maxlen=200)
    p.select('P71_ROLE', f, 20, 'الدور (الصلاحيات)', lov_sql=ROLE_LOV, required=True)
    p.select('P71_COMPANY', f, 30, 'الشركة', lov_sql=CO_LOV, null_text=None)
    p.number('P71_RATE', f, 40, 'حد الطلبات في الدقيقة')
    p.number('P71_TTL', f, 50, 'مدة رمز الدخول (دقائق)')
    p.text('P71_IPS', f, 60, 'عناوين IP المسموحة (اختياري، مفصولة بفواصل، تقبل *)', maxlen=1000)
    p.text('P71_DESC', f, 70, 'الوصف', maxlen=1000)
    b_new = p.button(f, 10, 'CREATE', 'إنشاء العميل', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', ['begin', '    :P71_RATE := nvl(:P71_RATE, 60);', '    :P71_TTL := nvl(:P71_TTL, 60);', 'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Create', [
        'declare l clob;', 'begin',
        "    l := noona_api_pkg.create_client(json_object('name' value :P71_NAME, 'role' value to_number(:P71_ROLE),",
        "             'company' value to_number(:P71_COMPANY), 'rate' value to_number(:P71_RATE), 'ttl' value to_number(:P71_TTL),",
        "             'ips' value :P71_IPS, 'description' value :P71_DESC));",
        "    apex_application.g_print_success_message := 'تم إنشاء العميل. معرف العميل: ' || json_value(l, '$.clientId')",
        "        || ' — السر (يظهر مرة واحدة فقط): ' || json_value(l, '$.clientSecret');",
        'end;'], when_button=b_new)
    m = p.static('إدارة عميل', 30)
    p.select('P71_CLIENT', m, 10, 'العميل', lov_sql=CLIENT_LOV)
    b_rot = p.button(m, 10, 'ROTATE', 'إصدار سر جديد')
    b_sus = p.button(m, 20, 'SUSPEND', 'إيقاف')
    b_act = p.button(m, 30, 'ACTIVATE', 'تفعيل')
    b_rev = p.button(m, 40, 'REVOKE', 'إلغاء نهائي')
    b_tok = p.button(m, 50, 'TOKENS', 'إلغاء رموز الدخول')
    p.process(20, 'AFTER_SUBMIT', 'Rotate', [
        'declare l varchar2(200);', 'begin',
        '    l := noona_api_pkg.rotate_secret(:P71_CLIENT);',
        "    apex_application.g_print_success_message := 'السر الجديد (يظهر مرة واحدة فقط، والسر القديم ورموزه ألغيت): ' || l;",
        'end;'], when_button=b_rot)
    p.process(30, 'AFTER_SUBMIT', 'Suspend', "noona_api_pkg.set_client_status(:P71_CLIENT, 'SUSPENDED');", when_button=b_sus,
              success='تم إيقاف العميل وإلغاء رموزه')
    p.process(40, 'AFTER_SUBMIT', 'Activate', "noona_api_pkg.set_client_status(:P71_CLIENT, 'ACTIVE');", when_button=b_act,
              success='تم تفعيل العميل')
    p.process(50, 'AFTER_SUBMIT', 'Revoke', "noona_api_pkg.set_client_status(:P71_CLIENT, 'REVOKED');", when_button=b_rev,
              success='تم إلغاء العميل نهائياً')
    p.process(60, 'AFTER_SUBMIT', 'Tokens', 'noona_api_pkg.revoke_tokens(:P71_CLIENT);', when_button=b_tok,
              success='تم إلغاء رموز الدخول الحالية')
    p.branch(10, url(71, clear='71') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 72) سجل الطلبات
    p = app.page(72, 'API Requests', 'API-REQUESTS', 'سجل طلبات API', scheme=API)
    fl = p.static('تصفية', 5, hide_header=True)
    p.select('P72_CLIENT', fl, 10, 'العميل', lov_sql=CLIENT_LOV, null_text='- كل العملاء -')
    p.button(fl, 10, 'GO', 'عرض', hot=True)
    p.dynamic('الطلبات (آخر 200)', 10, 'return noona_api_pkg.requests_html(to_number(:P72_CLIENT));')
    p.static('ملاحظة', 20, text='<p class="nn-hint">لا يسجل جسم الطلب ولا الأسرار. معرف الطلب يظهر للعميل في كل رد خطأ وفي ترويسة '
                                 '<code dir="ltr">X-Request-Id</code> لتتبع المشكلة.</p>')

    # =============================================================== 73) Webhooks
    p = app.page(73, 'Webhooks', 'WEBHOOKS', 'اشتراكات Webhook', scheme=API)
    p.dynamic('الاشتراكات', 10, 'return noona_api_pkg.webhooks_html;')
    f = p.static('اشتراك جديد', 20, text='<p class="nn-hint">يرسل الحدث POST بصيغة JSON إلى العنوان، مع الترويسات '
                                          '<code dir="ltr">X-Noona-Event</code> و<code dir="ltr">X-Noona-Timestamp</code> و'
                                          '<code dir="ltr">X-Noona-Signature: sha256=HMAC(السر, timestamp.body)</code>. '
                                          'الفشل يعاد بعد 2، 4، 8... دقائق حتى 10 محاولات.</p>')
    p.select('P73_EVENT', f, 10, 'الحدث', lov_sql=EVENTS, null_text=None)
    p.text('P73_URL', f, 20, 'عنوان الاستقبال (https://)', required=True, maxlen=1000, width=60)
    p.text('P73_DESC', f, 30, 'الوصف', maxlen=500)
    b_new = p.button(f, 10, 'CREATE', 'إضافة الاشتراك', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Create', [
        'declare l clob;', 'begin',
        "    l := noona_api_pkg.save_webhook(json_object('event' value :P73_EVENT, 'url' value :P73_URL, 'description' value :P73_DESC));",
        "    apex_application.g_print_success_message := 'تمت إضافة الاشتراك. سر التوقيع (يظهر مرة واحدة فقط): ' || json_value(l, '$.secret');",
        'end;'], when_button=b_new)
    m = p.static('إدارة اشتراك', 30)
    p.select('P73_WH', m, 10, 'الاشتراك', lov_sql=WH_LOV)
    b_test = p.button(m, 10, 'TEST', 'إرسال حدث اختبار', hot=True)
    b_pause = p.button(m, 20, 'PAUSE', 'إيقاف مؤقت')
    b_resume = p.button(m, 30, 'RESUME', 'تفعيل')
    b_del = p.button(m, 40, 'DISABLE', 'حذف الاشتراك')
    p.process(20, 'AFTER_SUBMIT', 'Test', ['declare l number;', 'begin', '    l := noona_api_pkg.test_webhook(:P73_WH);',
                                          '    l := noona_api_pkg.dispatch(20);', 'end;'], when_button=b_test,
              success='أرسل حدث الاختبار؛ النتيجة في الأحداث الصادرة')
    p.process(30, 'AFTER_SUBMIT', 'Pause', "noona_api_pkg.set_webhook_status(:P73_WH, 'PAUSED');", when_button=b_pause, success='تم الإيقاف')
    p.process(40, 'AFTER_SUBMIT', 'Resume', "noona_api_pkg.set_webhook_status(:P73_WH, 'ACTIVE');", when_button=b_resume, success='تم التفعيل')
    p.process(50, 'AFTER_SUBMIT', 'Disable', "noona_api_pkg.set_webhook_status(:P73_WH, 'DISABLED');", when_button=b_del,
              success='تم حذف الاشتراك وإلغاء أحداثه المعلقة')
    p.branch(10, url(73, clear='73') + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 74) الأحداث الصادرة
    p = app.page(74, 'Outbox', 'OUTBOX', 'الأحداث الصادرة', scheme=API)
    fl = p.static('تصفية', 5, hide_header=True)
    p.select('P74_STATUS', fl, 10, 'الحالة', lov_sql=('STATIC2:بالانتظار;PENDING,فشل (سيعاد);FAILED,متوقف بعد المحاولات;DEAD,'
                                                      'أرسل;SENT,ملغى;CANCELLED'), null_text='- الكل -')
    p.button(fl, 10, 'GO', 'عرض')
    b_send = p.button(fl, 20, 'SEND', 'إرسال المستحق الآن', hot=True)
    p.number('P74_RETRY', fl, 20, 'رقم الحدث لإعادة المحاولة')
    b_retry = p.button(fl, 30, 'RETRY', 'إعادة المحاولة')
    p.process(10, 'AFTER_SUBMIT', 'Send', ['declare l number;', 'begin', '    l := noona_api_pkg.dispatch(200);',
                                          "    apex_application.g_print_success_message := 'تمت معالجة ' || l || ' حدث';", 'end;'],
              when_button=b_send)
    p.process(20, 'AFTER_SUBMIT', 'Retry', 'noona_api_pkg.retry_outbox(to_number(:P74_RETRY));', when_button=b_retry,
              success='أعيد الحدث إلى الطابور')
    p.dynamic('الأحداث (آخر 200)', 10, 'return noona_api_pkg.outbox_html(:P74_STATUS);')

    # =============================================================== 75) قنوات الرسائل
    p = app.page(75, 'Messaging', 'MESSAGING', 'الرسائل النصية وواتساب', scheme=API)
    p.dynamic('القنوات', 10, 'return noona_api_pkg.channels_html;')
    f = p.static('إعداد قناة', 20, text=(
        '<p class="nn-hint"><b>المحاكي</b> يسجل الرسالة كمرسلة دون اتصال (للتجربة). <b>مزود REST</b> يرسل POST لعنوان المزود بالجسم '
        'المحدد ({{to}} و{{text}} و{{sender}})، والمفتاح يحفظ مشفراً ويوضع مكان {{secret}} في ترويسة التفويض.<br>'
        'القواعد: سطر لكل حدث بالصيغة <code dir="ltr">EVENT|النص</code> مثل '
        '<code>AR_RECEIPT.CREATED|شكراً {{name}}، استلمنا {{total}} - {{company}}</code>. '
        'المتغيرات: {{name}} {{number}} {{total}} {{company}}. ترسل لجوال العميل المسجل.</p>'))
    p.select('P75_CHANNEL', f, 10, 'القناة', lov_sql='STATIC2:رسائل نصية SMS;SMS,واتساب;WHATSAPP', null_text=None)
    p.select('P75_ADAPTER', f, 20, 'المحول', lov_sql='STATIC2:المحاكي (تجربة);SIMULATOR,مزود REST;REST', null_text=None)
    p.text('P75_URL', f, 30, 'عنوان مزود الخدمة', maxlen=1000, width=60)
    p.text('P75_AUTH', f, 40, 'ترويسة التفويض', maxlen=500)
    p.password('P75_SECRET', f, 50, 'مفتاح المزود (يترك فارغاً لإبقاء الحالي)')
    p.text('P75_SENDER', f, 60, 'اسم المرسل', maxlen=50)
    p.textarea('P75_BODY', f, 70, 'جسم الطلب للمزود (JSON)', rows=2)
    p.textarea('P75_RULES', f, 80, 'قواعد الإرسال التلقائي', rows=4)
    b_save = p.button(f, 10, 'SAVE', 'حفظ القناة', hot=True)
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        'begin',
        "    :P75_AUTH := nvl(:P75_AUTH, 'Authorization: Bearer {{secret}}');",
        '    :P75_BODY := nvl(:P75_BODY, \'{"to":"{{to}}","text":"{{text}}","sender":"{{sender}}"}\');',
        'end;'])
    p.process(10, 'AFTER_SUBMIT', 'Save', [
        'declare l_id number; l_r json_array_t := json_array_t(); l_o json_object_t;', 'begin',
        "    for r in (select trim(column_value) v from table(apex_string.split(:P75_RULES, chr(10))) where instr(column_value, '|') > 0) loop",
        "        l_o := json_object_t(); l_o.put('event', trim(substr(r.v, 1, instr(r.v, '|') - 1)));",
        "        l_o.put('template', trim(substr(r.v, instr(r.v, '|') + 1))); l_r.append(l_o);",
        '    end loop;',
        "    l_o := json_object_t(); l_o.put('channel', :P75_CHANNEL); l_o.put('adapter', :P75_ADAPTER); l_o.put('url', :P75_URL);",
        "    l_o.put('authHeader', :P75_AUTH); l_o.put('secret', :P75_SECRET); l_o.put('sender', :P75_SENDER); l_o.put('body', :P75_BODY);",
        "    l_o.put('rules', l_r);",
        '    l_id := noona_api_pkg.save_channel(l_o.to_clob);',
        'end;'], when_button=b_save, success='تم حفظ القناة')
    t = p.static('رسالة تجريبية', 30)
    p.select('P75_TCH', t, 10, 'القناة', lov_sql='STATIC2:رسائل نصية SMS;SMS,واتساب;WHATSAPP', null_text=None)
    p.text('P75_TO', t, 20, 'رقم الجوال', maxlen=20)
    p.text('P75_TEXT', t, 30, 'النص', maxlen=1000, width=60)
    b_send = p.button(t, 10, 'SEND', 'إرسال')
    p.process(20, 'AFTER_SUBMIT', 'Send', ['declare l number;', 'begin', '    l := noona_api_pkg.send_message(:P75_TCH, :P75_TO, :P75_TEXT);',
                                          '    l := noona_api_pkg.dispatch(20);', 'end;'], when_button=b_send,
              success='أرسلت الرسالة؛ حالتها في الأحداص الصادرة'.replace('الأحداص', 'الأحداث'))
    p.branch(10, url(75) + '&success_msg=#SUCCESS_MSG#')

    # =============================================================== 76) استيراد البيانات
    p = app.page(76, 'Data Import', 'DATA-IMPORT', 'استيراد البيانات', scheme=API)
    f = p.static('ملف CSV', 10, text=(
        '<p class="nn-hint">السطر الأول عناوين الأعمدة (عربي أو إنجليزي)، والفاصل فاصلة أو فاصلة منقوطة. كل صف مستقل: الصفوف '
        'الخاطئة أو المكررة تظهر في تقرير الاستيراد ولا توقف الباقي. حتى 5000 صف للملف.<br>'
        'العملاء والموردون: <code dir="ltr">name, phone, email, tax, cr, address, term</code> — '
        'الأصناف: <code dir="ltr">no, name, nameEn, type, price, barcode, category</code> — '
        'شجرة الحسابات: <code dir="ltr">code, name, parent, type, postable</code></p>'))
    p.select('P76_TYPE', f, 10, 'نوع البيانات', lov_sql='STATIC2:العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,شجرة الحسابات;ACCOUNTS', null_text=None)
    p.file('P76_FILE', f, 20, 'الملف', file_types='.csv,text/csv,text/plain', max_kb=5120,
           title='اسحب ملف CSV هنا أو اضغط للاختيار', hint='CSV بترميز UTF-8 حتى 5 ميجابايت')
    b_imp = p.button(f, 10, 'IMPORT', 'استيراد', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Import', [
        'declare l_blob blob; l_name varchar2(400); l_csv clob; l_job number; l_ok number; l_bad number;', 'begin',
        *[x.format(item=':P76_FILE') for x in READ_FILE],
        '    l_job := noona_conn_pkg.import_csv(:P76_TYPE, l_name, l_csv);',
        '    select ok_rows, failed_rows into l_ok, l_bad from api_import_job where id = l_job;',
        '    :P76_JOB := l_job;',
        "    apex_application.g_print_success_message := 'تم استيراد ' || l_ok || ' صف' || case when l_bad > 0 then '، ورفض ' || l_bad || ' (التفاصيل أدناه)' end;",
        'end;'], when_button=b_imp)
    p.hidden('P76_JOB', f, 90)
    p.dynamic('نتيجة الاستيراد', 20, 'return noona_conn_pkg.job_html(to_number(:P76_JOB));', condition=':P76_JOB is not null')
    tp = p.static('نماذج الملفات', 25)
    p.select('P76_TPL', tp, 10, 'النموذج', lov_sql='STATIC2:العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,شجرة الحسابات;ACCOUNTS,كشف حساب بنكي;BANK_STATEMENT',
             null_text=None)
    p.button(tp, 10, 'SHOW', 'عرض النموذج')
    p.dynamic('النموذج', 26, "return '<pre dir=\"ltr\" class=\"nn-csv\">' || noona_ui_pkg.esc(noona_conn_pkg.template_csv(nvl(:P76_TPL, 'CUSTOMERS'))) || '</pre>';",
              hide_header=True)
    p.dynamic('عمليات الاستيراد السابقة', 30, 'return noona_conn_pkg.jobs_html;')

    # =============================================================== 77) نقاط النهاية
    p = app.page(77, 'API Endpoints', 'API-ENDPOINTS', 'نقاط النهاية والتوثيق', scheme=API)
    p.static('العنوان الأساسي', 5, text=(
        '<p>العنوان: <code dir="ltr">https://&lt;الخادم&gt;/ords/noona/v1/</code> — توصيف OpenAPI 3 (لـ Postman وSwagger): '
        '<code dir="ltr">GET /ords/noona/v1/openapi.json</code></p>'
        '<pre dir="ltr" class="nn-csv">curl -X POST https://server/ords/noona/v1/token -H "Content-Type: application/json" \\\n'
        '     -d \'{"client_id":"nn_...","client_secret":"..."}\'\n\n'
        'curl https://server/ords/noona/v1/customers?q=النور -H "Authorization: Bearer &lt;token&gt;"\n\n'
        'curl -X POST https://server/ords/noona/v1/sales-invoices -H "Authorization: Bearer &lt;token&gt;" \\\n'
        '     -H "Idempotency-Key: ORDER-1001" -H "Content-Type: application/json" \\\n'
        '     -d \'{"customer":12,"lines":[{"sku":"6281000000011","qty":2,"price":50}]}\'</pre>'
        '<p class="nn-hint">الأخطاء: <code dir="ltr">{"error":{"code","message","requestId"}}</code> — 400 طلب غير صالح، 401 دخول، '
        '403 صلاحية أو IP، 404 غير موجود، 409 تعارض مفتاح منع التكرار، 422 قاعدة عمل، 429 تجاوز حد الطلبات.</p>'))
    p.dynamic('نقاط النهاية', 10, 'return noona_api_pkg.endpoints_html;')

    it = app.nav_item('التكاملات وواجهات API', None, 'fa-plug', 65, scheme=API)
    app.nav_item('لوحة التكاملات', 70, 'fa-dashboard', 651, parent=it, scheme=API)
    app.nav_item('عملاء API', 71, 'fa-key', 652, parent=it, scheme=API)
    app.nav_item('Webhooks', 73, 'fa-bolt', 653, parent=it, scheme=API)
    app.nav_item('الأحداث الصادرة', 74, 'fa-paper-plane', 654, parent=it, scheme=API)
    app.nav_item('الرسائل SMS / واتساب', 75, 'fa-comments', 655, parent=it, scheme=API)
    app.nav_item('استيراد البيانات', 76, 'fa-upload', 656, parent=it, scheme=API)
    app.nav_item('سجل الطلبات', 72, 'fa-list', 657, parent=it, scheme=API)
    app.nav_item('نقاط النهاية والتوثيق', 77, 'fa-book', 658, parent=it, scheme=API)


def build_fin(app, url):
    CO = 'noona_conn_pkg.company'
    BANK = app.add_scheme('noona_bank_recon', app.id(), 'NOONA - Bank Reconciliation',
                          f"return noona_security_pkg.has_permission('CSH_BANK_STATEMENT.VIEW', {CO}) = 'Y';",
                          'المطابقة البنكية تتطلب صلاحية كشوف الحساب / Bank statement access required')
    BANK_LOV = f"select name_ar d, id r from csh_bank_account where company_id = {CO} and status_code = 'ACTIVE' order by name_ar"

    # =============================================================== 79) كشوف الحساب البنكية
    p = app.page(79, 'Bank Statements', 'BANK-STATEMENTS', 'كشوف الحساب البنكية', scheme=BANK)
    f = p.static('استيراد كشف', 10, text=(
        '<p class="nn-hint">ملف CSV من البنك: أعمدة التاريخ والمبلغ (موجب إيداع، سالب سحب) أو عمودا مدين ودائن، والمرجع والبيان. '
        'الأسطر المستوردة سابقاً تتجاهل تلقائياً. بعد الاستيراد يقترح النظام الحركة المقابلة لكل سطر (نفس الحساب والاتجاه والمبلغ '
        'خلال 3 أيام، والمرجع يرفع الثقة).</p>'))
    p.select('P79_BANK', f, 10, 'الحساب البنكي', lov_sql=BANK_LOV, required=True)
    p.file('P79_FILE', f, 20, 'ملف الكشف', file_types='.csv,text/csv,text/plain', max_kb=5120,
           title='اسحب ملف الكشف هنا أو اضغط للاختيار', hint='CSV بترميز UTF-8')
    p.number('P79_OPENING', f, 30, 'الرصيد الافتتاحي (اختياري)')
    p.number('P79_CLOSING', f, 40, 'الرصيد الختامي (اختياري)')
    b_imp = p.button(f, 10, 'IMPORT', 'استيراد ومطابقة', hot=True)
    p.process(10, 'AFTER_SUBMIT', 'Import', [
        'declare l_blob blob; l_name varchar2(400); l_csv clob; l_st number;', 'begin',
        *[x.format(item=':P79_FILE') for x in READ_FILE],
        '    l_st := noona_conn_pkg.import_bank_statement(to_number(:P79_BANK), l_name, l_csv, to_number(:P79_OPENING), to_number(:P79_CLOSING));',
        '    commit;',
        "    apex_util.redirect_url(apex_page.get_url(p_page => 80, p_items => 'P80_ID', p_values => l_st));",
        'end;'], when_button=b_imp)
    p.dynamic('الكشوف', 20, 'return noona_conn_pkg.statements_html;')
    p.onload("$(document).on('click', '.nn-st-open', function (e) { e.preventDefault(); "
             "window.location.href = apex.item('P79_GO').getValue().replace('990000000001', $(this).data('id')); });")
    g = p.static('go', 90, hide_header=True, opts='#DEFAULT#:u-hidden')
    p.hidden('P79_GO', g, 1, protected=False)
    p.process(5, 'BEFORE_HEADER', 'Link', ["begin :P79_GO := apex_page.get_url(p_page => 80, p_items => 'P80_ID', p_values => '990000000001'); end;"])

    # =============================================================== 80) مطابقة كشف
    p = app.page(80, 'Bank Reconciliation', 'BANK-RECON', 'مطابقة كشف الحساب', scheme=BANK, protection='N')
    a = p.static('الإجراءات', 5, hide_header=True)
    p.hidden('P80_ID', a, 1, protected=False)
    p.hidden('P80_MATCH', a, 2, protected=False)
    p.hidden('P80_LINE', a, 3, protected=False)
    b_all = p.button(a, 10, 'CONFIRM_ALL', 'اعتماد كل المقترحات', hot=True)
    b_auto = p.button(a, 20, 'AUTO', 'إعادة المطابقة التلقائية')
    p.button(a, 30, 'BACK', 'الكشوف', redirect=url(79))
    p.dynamic('الكشف', 10, 'return noona_conn_pkg.statement_html(to_number(:P80_ID));', hide_header=True)
    p.process(10, 'AFTER_SUBMIT', 'Confirm all', ['declare l number;', 'begin', '    l := noona_conn_pkg.confirm_all(to_number(:P80_ID));',
                                                 "    apex_application.g_print_success_message := 'تم اعتماد ' || l || ' مطابقة';", 'end;'],
              when_button=b_all)
    p.process(20, 'AFTER_SUBMIT', 'Auto', ['declare l number;', 'begin', '    l := noona_conn_pkg.auto_match(to_number(:P80_ID));',
                                          "    apex_application.g_print_success_message := 'مقترحات جديدة: ' || l;", 'end;'], when_button=b_auto)
    p.process(30, 'AFTER_SUBMIT', 'Confirm', 'noona_conn_pkg.confirm_match(to_number(:P80_MATCH));', when=":REQUEST = 'OK'",
              success='تم اعتماد المطابقة')
    p.process(40, 'AFTER_SUBMIT', 'Reject', 'noona_conn_pkg.reject_match(to_number(:P80_MATCH));', when=":REQUEST = 'NO'",
              success='تم إلغاء المطابقة')
    p.process(50, 'AFTER_SUBMIT', 'Ignore', 'noona_conn_pkg.ignore_line(to_number(:P80_LINE));', when=":REQUEST = 'IGNORE'",
              success='تم تجاهل السطر')
    p.onload("$(document).on('click', '.nn-recon-ok, .nn-recon-no, .nn-recon-ign', function () { var b = $(this); "
             "if (b.hasClass('nn-recon-ign')) { apex.item('P80_LINE').setValue(b.data('id')); apex.submit('IGNORE'); } "
             "else { apex.item('P80_MATCH').setValue(b.data('id')); apex.submit(b.hasClass('nn-recon-ok') ? 'OK' : 'NO'); } });")
    p.branch(10, url(80, 'P80_ID', '&P80_ID.') + '&success_msg=#SUCCESS_MSG#')

    cs = app.nav_item('المطابقة البنكية', None, 'fa-check-square', 38, scheme=BANK)
    app.nav_item('كشوف الحساب والمطابقة', 79, 'fa-university', 381, parent=cs, scheme=BANK)
