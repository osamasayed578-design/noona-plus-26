"""صفحة «بدء التشغيل ونقل البيانات» في إدارة المؤسسة (NOONA_ADMIN): خطوات نقل بيانات العميل من نظامه السابق بالترتيب
(شجرة الحسابات، العملاء، الموردون، الأصناف، الموظفون، ثم الأرصدة الافتتاحية للحسابات والنقدية والعملاء والموردين والمخزون)،
باستيراد ملفات Excel (xlsx) أو CSV، ونماذج الملفات، ونتيجة كل استيراد، ودفعات الأرصدة وإلغاؤها، ومطابقة الأرصدة.
"""

PAGE = 90
TYPES = ('STATIC2:شجرة الحسابات;ACCOUNTS,العملاء;CUSTOMERS,الموردون;SUPPLIERS,الأصناف;ITEMS,الموظفون;EMPLOYEES,'
         'أرصدة الحسابات والنقدية والبنوك;OPENING_GL,أرصدة العملاء (فواتير مفتوحة);OPENING_AR,'
         'أرصدة الموردين (فواتير مستحقة);OPENING_AP,أرصدة المخزون (كمية وتكلفة);OPENING_STOCK')

READ = [
    "    if :P90_FILE is null then raise_application_error(-20500, 'NOONA-CON-025: اختر الملف أولاً'); end if;",
    '    select blob_content, filename into l_blob, l_name from apex_application_temp_files where name = :P90_FILE;',
    '    l_csv := noona_conn_pkg.file_to_csv(l_blob, l_name);',
]


def add(app, scheme, nav_seq):
    p = app.page(PAGE, 'Onboarding', 'ONBOARDING', 'بدء التشغيل ونقل البيانات', scheme=scheme)
    p.dynamic('الشركة', 4, [
        "return '<div class=\"nn-hint\">نقل بيانات <b>' || noona_ui_pkg.esc(noona_apex_pkg.company_name) || '</b> من النظام السابق. "
        "اتبع الخطوات بالترتيب: البيانات الأساسية أولاً ثم الأرصدة الافتتاحية في تاريخ بدء العمل على النظام. "
        "كل ملف أرصدة يرحل كاملاً أو لا يرحل منه شيء، فصحح الأخطاء الظاهرة وأعد رفعه. "
        "لتغيير الشركة استخدم مبدل الشركة أعلى الشاشة.</div>';"], hide_header=True)
    st = p.static('تجهيز الأنظمة', 8, condition='noona_gl_pkg.primary_ledger is null', text=(
        '<p class="nn-hint">الشركة لم تجهز بعد: يجهز هذا الزر دليل الحسابات القياسي والسنة المالية والنقدية والمخزون والمبيعات '
        'والمشتريات وباقي الأنظمة المشترك فيها، ثم تبدأ الاستيراد.</p>'))
    b_setup = p.button(st, 10, 'SETUP', 'تجهيز الأنظمة', hot=True)
    p.process(3, 'AFTER_SUBMIT', 'Setup', "apex_application.g_print_success_message := 'جهز: ' || noona_account_pkg.setup_company;",
              when_button=b_setup)
    p.dynamic('خطوات بدء التشغيل', 10, [
        "return noona_conn_pkg.onboarding_html('APEX:90:P90_TYPE');"])

    f = p.static('استيراد ملف', 20, text=(
        '<p class="nn-hint">ملف Excel (xlsx، الورقة الأولى) أو CSV. السطر الأول عناوين الأعمدة بالعربي أو الإنجليزي '
        '(مثل: رمز الحساب، مدين، دائن، العميل، رقم الفاتورة، المبلغ، الصنف، الكمية، التكلفة). حتى 5000 صف للملف. '
        'نزّل نموذج النوع المختار وعبئه في Excel ثم ارفعه.</p>'))
    p.select('P90_TYPE', f, 10, 'نوع البيانات', lov_sql=TYPES, null_text=None, submit=True)
    p.date('P90_DATE', f, 20, 'تاريخ الأرصدة الافتتاحية')
    p.file('P90_FILE', f, 30, 'الملف', file_types='.xlsx,.csv,text/csv,text/plain,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
           max_kb=10240, title='اسحب ملف Excel أو CSV هنا أو اضغط للاختيار', hint='xlsx أو CSV حتى 10 ميجابايت')
    p.hidden('P90_JOB', f, 90)
    b_imp = p.button(f, 10, 'IMPORT', 'استيراد', hot=True)
    # التنزيل بطلب GET (إرسال الصفحة في APEX يتوقع JSON): الرابط يحمل الطلب TEMPLATE ونوع الملف من حالة الجلسة
    p.button(f, 20, 'TEMPLATE', 'تنزيل نموذج الملف', redirect='f?p=&APP_ID.:90:&SESSION.:TEMPLATE:&DEBUG.:::')
    p.process(5, 'BEFORE_HEADER', 'Defaults', [
        "if :P90_TYPE is null then :P90_TYPE := 'ACCOUNTS'; end if;",
        "if :P90_DATE is null then :P90_DATE := to_char(trunc(sysdate, 'YYYY'), 'YYYY-MM-DD'); end if;"])
    p.process(6, 'BEFORE_HEADER', 'Template', [
        'declare l varchar2(32767) := noona_conn_pkg.template_csv(:P90_TYPE);',
        'begin',
        "    owa_util.mime_header('text/csv', false, 'UTF-8');",
        "    htp.p('Content-Disposition: attachment; filename=\"noona_' || lower(:P90_TYPE) || '.csv\"');",
        '    owa_util.http_header_close;',
        "    htp.prn(unistr('\\FEFF') || l);",
        '    apex_application.stop_apex_engine;',
        'end;'], when=":REQUEST = 'TEMPLATE'")
    p.process(20, 'AFTER_SUBMIT', 'Import', [
        'declare l_blob blob; l_name varchar2(400); l_csv clob; l_job number; l_ok number; l_bad number; l_st varchar2(30);', 'begin',
        *READ,
        "    l_job := noona_conn_pkg.import_csv(:P90_TYPE, l_name, l_csv, to_date(:P90_DATE, 'YYYY-MM-DD'));",
        '    select ok_rows, failed_rows, status_code into l_ok, l_bad, l_st from api_import_job where id = l_job;',
        '    :P90_JOB := l_job;',
        "    apex_application.g_print_success_message := case",
        "        when :P90_TYPE like 'OPENING%' and l_st = 'FAILED' then 'لم ترحل الأرصدة: ' || l_bad || ' صف به أخطاء (التفاصيل أدناه)'",
        "        when :P90_TYPE like 'OPENING%' then 'رحلت الأرصدة الافتتاحية: ' || l_ok || ' صف'",
        "        else 'تم استيراد ' || l_ok || ' صف' || case when l_bad > 0 then '، ورفض ' || l_bad || ' (التفاصيل أدناه)' end end;",
        'end;'], when_button=b_imp)
    p.dynamic('أعمدة الملف', 25, [
        "return '<pre dir=\"ltr\" class=\"nn-csv\">' || noona_ui_pkg.esc(noona_conn_pkg.template_csv(nvl(:P90_TYPE, 'ACCOUNTS'))) || '</pre>';"])
    p.dynamic('نتيجة الاستيراد', 30, 'return noona_conn_pkg.job_html(to_number(:P90_JOB));', condition=':P90_JOB is not null')

    b = p.static('دفعات الأرصدة الافتتاحية', 40)
    p.select('P90_BATCH', b, 10, 'إلغاء دفعة', lov_sql=(
        "select batch_no || ' - ' || case scope_code when 'GL' then 'الحسابات' when 'AR' then 'العملاء' when 'AP' then 'الموردين' end d, id r "
        "from gl_opening_batch where status_code = 'POSTED' and scope_code in ('GL', 'AR', 'AP') "
        "and company_id = to_number(sys_context('NOONA_CTX', 'COMPANY_ID')) order by id desc"))
    p.text('P90_REASON', b, 20, 'سبب الإلغاء', maxlen=400)
    b_can = p.button(b, 10, 'CANCEL_BATCH', 'إلغاء الدفعة بقيد عكسي')
    p.process(30, 'AFTER_SUBMIT', 'Cancel batch', [
        "if :P90_BATCH is null then raise_application_error(-20500, 'NOONA-CON-085: اختر الدفعة'); end if;",
        'noona_conn_pkg.cancel_opening(to_number(:P90_BATCH), :P90_REASON);',
        ':P90_BATCH := null; :P90_REASON := null;'], when_button=b_can, success='ألغيت الدفعة وعكس قيدها')
    p.dynamic('الدفعات', 45, 'return noona_conn_pkg.openings_html;', hide_header=True)
    p.dynamic('عمليات الاستيراد السابقة', 50, 'return noona_conn_pkg.jobs_html;')
    app.nav_item('بدء التشغيل ونقل البيانات', PAGE, 'fa-upload', nav_seq, scheme=scheme)
