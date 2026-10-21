"""NOONA_DOC (المستندات والأرشيف): محرك الأرشفة - رقم الأرشيف والمرجع الورقي وموقع الأصل وصورته بإصدارات،
البحث في الأرشيف، أنواع المستندات، قواعد الأرشفة (المرجع الورقي إلزامي قبل الاعتماد)، سجل الوصول.
الاستخدام: python3 tools/build_doc.py   ->  apex/NOONA_DOC/f129
المنطق كله في NOONA_DMS_PKG.
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App
from dms_panel import DOC_FILE_TYPES, DOC_TYPES_LOV, download_page, dl_link

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_DOC/f129'),
          app_id=129, alias='NOONA_DOC', name='NOONA Documents', id_base=91820267000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']


def url(page_no, items='', values='', clear=''):
    return f'f?p=&APP_ID.:{page_no}:&SESSION.::&DEBUG.:{clear}:{items}:{values}'


DOCS_SQL = [
    "select d.id, d.reference_no, t.name_ar as type_name, d.title, d.external_ref, d.physical_location,",
    "       to_char(d.document_date, 'YYYY-MM-DD') as document_date,",
    "       (select listagg(noona_dms_pkg.entity_label(k.entity_type, k.entity_id), '، ') within group (order by k.id)",
    "          from dms_document_link k where k.document_id = d.id and k.status_code = 'ACTIVE') as linked_to,",
    "       case when d.current_version_id is null then '<span class=\"nn-badge is-muted\">ورقي فقط</span>'",
    "            else '<span class=\"nn-badge is-success\">' || (select c.file_name from dms_document_version v join dms_file_content c on c.id = v.content_id",
    "                                                            where v.id = d.current_version_id) || '</span>' end as file_html,",
    '       d.created_by, d.created_at',
    '  from dms_document d join dms_document_type t on t.id = d.document_type_id',
    " where d.company_id = noona_dms_pkg.company and d.is_deleted = 'N' and t.code <> 'COMPANY_LOGO'"]
DOCS_COLS = [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('REFERENCE_NO', 'رقم الأرشيف', {}), ('TYPE_NAME', 'النوع', {}),
             ('TITLE', 'العنوان', {}), ('EXTERNAL_REF', 'المرجع الورقي', {}), ('PHYSICAL_LOCATION', 'موقع الأصل', {}),
             ('DOCUMENT_DATE', 'التاريخ', {}), ('LINKED_TO', 'مرتبط بـ', {}), ('FILE_HTML', 'الصورة', {'html': True}),
             ('CREATED_BY', 'أرشفه', {}), ('CREATED_AT', 'وقت الأرشفة', {'type': 'DATE'})]
DOC_LINK = 'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:#ID#'
ENTITIES = ("STATIC2:سندات القبض والصرف والمصروفات;CSH_TRANSACTION,القيود اليومية;GL_JOURNAL,"
            "فواتير الموردين;AP_INVOICE,فواتير العملاء;AR_INVOICE,أوامر الشراء;PUR_ORDER")

# =============================================================== 1) لوحة الأرشيف
p = app.page(1, 'Home', 'HOME', 'المستندات والأرشيف', scheme=TENANT)
p.dynamic('الأرشيف', 10, 'return noona_dms_pkg.summary(p_session => :APP_SESSION);', hide_header=True)
st = p.static('تجهيز الأرشيف', 15, condition="noona_dms_pkg.is_ready = 'N'", text=(
    '<p class="nn-hint">ينشئ تسلسل أرقام الأرشيف (ARC-السنة-الرقم) وقواعد الأرشفة الافتراضية: لا يعتمد سند نقدي ولا قيد يومية '
    'حتى يسجل مرجعه الورقي (رقم الأصل أو صورته).</p>'))
b = p.button(st, 10, 'SETUP', 'تجهيز الأرشيف', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Setup', ['declare l_n number;', 'begin', '    l_n := noona_dms_pkg.quick_setup;', 'end;'],
          when_button=b, success='تم تجهيز الأرشيف وقواعد الأرشفة')
r = p.ir('آخر المستندات المؤرشفة', 20, DOCS_SQL[:-1] + [DOCS_SQL[-1] + ' order by d.id desc fetch first 15 rows only'],
         DOCS_COLS, link=DOC_LINK, titled=True)
p.button(r, 10, 'NEW_DOC', 'أرشفة مستند', hot=True, redirect=url(12, clear='RP,12'), position='RIGHT_OF_IR_SEARCH_BAR')
p.branch(10, url(1) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 10) البحث في الأرشيف
p = app.page(10, 'Archive', 'ARCHIVE', 'البحث في الأرشيف', scheme=TENANT)
r = p.ir('الأرشيف', 10, DOCS_SQL + [' order by d.id desc'], DOCS_COLS, link=DOC_LINK, rows=100)
p.button(r, 10, 'NEW_DOC', 'أرشفة مستند', hot=True, redirect=url(12, clear='RP,12'), position='RIGHT_OF_IR_SEARCH_BAR')

# =============================================================== 11) المستند
p = app.page(11, 'Document', 'DOCUMENT', 'المستند المؤرشف', scheme=TENANT)
f = p.static('المستند', 5, hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P11_ID', f, 1)
p.dynamic('تفاصيل المستند', 10, [
    f"return noona_dms_pkg.document_html(:P11_ID, {dl_link(49, True)});"],
    hide_header=True)
fv = p.static('إصدار جديد لصورة الأصل', 20)
p.file('P11_FILE', fv, 10, 'الملف', file_types=DOC_FILE_TYPES, max_kb=20480,
       title='اسحب الملف هنا أو اضغط للاختيار', hint='PDF أو صورة أو Word/Excel حتى 20 ميجابايت')
p.text('P11_REASON', fv, 20, 'سبب الإصدار (مثل: صورة أوضح)')
bv = p.button(fv, 10, 'ADD_VERSION', 'رفع الإصدار', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Version', [
    'declare',
    '    l_blob blob; l_name varchar2(400); l_mime varchar2(255); l_id number;',
    'begin',
    '    if :P11_FILE is null then',
    "        raise_application_error(-20500, 'NOONA-DMS-110: اختر الملف أولاً');",
    '    end if;',
    '    select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :P11_FILE;',
    '    l_id := noona_dms_pkg.add_version(:P11_ID, l_name, l_mime, l_blob, :P11_REASON);',
    'end;'], when_button=bv, success='تم رفع الإصدار الجديد؛ السابق محفوظ في الأرشيف')
fl = p.static('ربط بمستند أعمال', 30)
p.select('P11_ENTITY', fl, 10, 'نوع المستند', null_text=None, lov_sql=ENTITIES)
p.number('P11_ENTITY_ID', fl, 20, 'الرقم الداخلي للمستند')
bl = p.button(fl, 10, 'LINK', 'ربط')
p.process(20, 'AFTER_SUBMIT', 'Link', 'noona_dms_pkg.link_document(:P11_ID, :P11_ENTITY, :P11_ENTITY_ID);', when_button=bl,
          success='تم الربط')
p.button(fl, 20, 'BACK', 'رجوع للأرشيف', redirect=url(10))
p.branch(10, 'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:11:P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 12) أرشفة مستند جديد
p = app.page(12, 'New Document', 'NEW-DOCUMENT', 'أرشفة مستند', scheme=TENANT)
f = p.static('بيانات المستند', 10, text=(
    '<p class="nn-hint">يصدر رقم أرشيف يكتب على الأصل الورقي. سجل رقم الأصل (المرجع الورقي) أو أرفق صورته، أو الاثنين معاً.</p>'))
p.hidden('P12_NEW_ID', f, 1)
p.select('P12_TYPE', f, 10, 'نوع المستند', lov_sql=DOC_TYPES_LOV)
p.text('P12_TITLE', f, 20, 'العنوان')
p.text('P12_REF', f, 30, 'المرجع الورقي (رقم الأصل)', maxlen=100, width=25)
p.text('P12_LOC', f, 40, 'موقع الأصل (الملف / الرف / الصندوق)', maxlen=200)
p.date('P12_DATE', f, 50, 'تاريخ المستند')
p.select('P12_CONF', f, 60, 'السرية', null_text='- حسب النوع -',
         lov_sql='STATIC2:عام;PUBLIC,داخلي;INTERNAL,سري;CONFIDENTIAL,سري جداً;SECRET')
p.textarea('P12_DESC', f, 70, 'الوصف', rows=2)
p.file('P12_FILE', f, 80, 'صورة الأصل (اختياري)', file_types=DOC_FILE_TYPES, max_kb=20480,
       title='اسحب صورة الأصل أو ملف PDF هنا', hint='PDF أو صورة أو Word/Excel حتى 20 ميجابايت')
b = p.button(f, 10, 'ARCHIVE', 'أرشفة', hot=True)
p.button(f, 20, 'CANCEL', 'إلغاء', redirect=url(10))
p.process(10, 'AFTER_SUBMIT', 'Archive', [
    'declare',
    '    l_blob blob; l_name varchar2(400); l_mime varchar2(255);',
    'begin',
    '    if :P12_FILE is not null then',
    '        select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :P12_FILE;',
    '    end if;',
    '    :P12_NEW_ID := noona_dms_pkg.archive_document(p_entity_type => null, p_entity_id => null, p_type_code => nvl(:P12_TYPE, \'GENERAL\'),',
    "        p_title => :P12_TITLE, p_external_ref => :P12_REF, p_location => :P12_LOC, p_doc_date => to_date(:P12_DATE, 'YYYY-MM-DD'),",
    '        p_description => :P12_DESC, p_file_name => l_name, p_mime => l_mime, p_content => l_blob, p_confidentiality => :P12_CONF);',
    'end;'], when_button=b, success='تمت الأرشفة')
p.branch(10, 'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:&P12_NEW_ID.&success_msg=#SUCCESS_MSG#')

# =============================================================== 20) أنواع المستندات
p = app.page(20, 'Document Types', 'DOCUMENT-TYPES', 'أنواع المستندات', scheme=TENANT)
p.ir('أنواع المستندات', 10, [
    "select t.id, t.code, t.name_ar, c.name_ar as category, noona_ui_pkg.code_label(t.default_confidentiality) as conf,",
    "       t.max_file_mb, replace(replace(replace(t.allowed_mime_types, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'Word'),",
    "       'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'Excel'), ',', '، ') as mime,",
    "       case when t.tenant_id is null then 'المنصة' else 'المؤسسة' end as owner_name, noona_ui_pkg.code_label(t.is_active) as active",
    '  from dms_document_type t left join dms_category c on c.id = t.category_id',
    " where t.code <> 'COMPANY_LOGO' order by c.sort_order nulls last, t.name_ar"],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CODE', 'الرمز', {}), ('NAME_AR', 'النوع', {}), ('CATEGORY', 'الفئة', {}),
     ('CONF', 'السرية', {}), ('MAX_FILE_MB', 'الحد (MB)', {'type': 'NUMBER'}), ('MIME', 'الملفات المسموحة', {}),
     ('OWNER_NAME', 'تعريف', {}), ('ACTIVE', 'نشط', {})], rows=100)
f = p.static('نوع خاص بالمؤسسة', 20)
p.text('P20_CODE', f, 10, 'الرمز', maxlen=50, width=20)
p.text('P20_NAME', f, 20, 'الاسم')
p.select('P20_CAT', f, 30, 'الفئة', null_text=None, lov_sql="select name_ar d, code r from dms_category where is_active = 'Y' order by sort_order")
p.number('P20_MAX', f, 40, 'حد الحجم (ميجابايت)')
p.select('P20_CONF', f, 50, 'السرية الافتراضية', null_text=None,
         lov_sql='STATIC2:داخلي;INTERNAL,عام;PUBLIC,سري;CONFIDENTIAL,سري جداً;SECRET')
b = p.button(f, 10, 'ADD_TYPE', 'إضافة النوع', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Add Type', [
    'declare l_id number;', 'begin',
    '    l_id := noona_dms_pkg.create_type(:P20_CODE, :P20_NAME, :P20_CAT, null, nvl(:P20_MAX, 20), :P20_CONF);', 'end;'],
    when_button=b, success='تمت إضافة النوع')
p.branch(10, url(20, clear='20') + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 21) قواعد الأرشفة
p = app.page(21, 'Archiving Rules', 'ARCHIVING-RULES', 'قواعد الأرشفة', scheme=TENANT)
p.ir('قواعد الأرشفة', 10, [
    "select r.id, decode(r.entity_type, 'CSH_TRANSACTION', 'سندات القبض والصرف والمصروفات', 'GL_JOURNAL', 'القيود اليومية',",
    "              'AP_INVOICE', 'فواتير الموردين', 'AR_INVOICE', 'فواتير العملاء', 'PUR_ORDER', 'أوامر الشراء', r.entity_type) as entity,",
    "       t.name_ar as doc_type, noona_ui_pkg.code_label(r.is_required) as required, noona_ui_pkg.code_label(r.require_file) as file_req,",
    '       noona_ui_pkg.code_label(r.is_active) as active, r.updated_by, r.updated_at',
    '  from dms_archive_rule r join dms_document_type t on t.id = r.document_type_id',
    ' where r.company_id = noona_dms_pkg.company order by 2'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('ENTITY', 'مستند الأعمال', {}), ('DOC_TYPE', 'نوع المستند المؤرشف', {}),
     ('REQUIRED', 'المرجع الورقي إلزامي', {}), ('FILE_REQ', 'صورة الأصل إلزامية', {}), ('ACTIVE', 'نشطة', {}),
     ('UPDATED_BY', 'عدلها', {}), ('UPDATED_AT', 'وقت التعديل', {'type': 'DATE'})])
f = p.static('قاعدة', 20, text='<p class="nn-hint">عند تفعيل القاعدة لا يعتمد مستند الأعمال حتى يؤرشف مرجعه الورقي '
                               '(رقم الأصل أو صورته)، أو صورة الأصل إن كانت إلزامية.</p>')
p.select('P21_ENTITY', f, 10, 'مستند الأعمال', null_text=None, lov_sql=ENTITIES)
p.select('P21_TYPE', f, 20, 'نوع المستند المؤرشف الافتراضي', null_text=None, lov_sql=DOC_TYPES_LOV)
p.select('P21_REQ', f, 30, 'المرجع الورقي', null_text=None, lov_sql='STATIC2:إلزامي قبل الاعتماد;Y,اختياري;N')
p.select('P21_FILE', f, 40, 'صورة الأصل', null_text=None, lov_sql='STATIC2:اختيارية;N,إلزامية;Y')
p.select('P21_ACTIVE', f, 50, 'الحالة', null_text=None, lov_sql='STATIC2:نشطة;Y,موقوفة;N')
b = p.button(f, 10, 'SAVE_RULE', 'حفظ القاعدة', hot=True)
p.process(10, 'AFTER_SUBMIT', 'Save Rule', 'noona_dms_pkg.set_rule(:P21_ENTITY, :P21_TYPE, :P21_REQ, :P21_FILE, :P21_ACTIVE);',
          when_button=b, success='تم حفظ القاعدة')
p.branch(10, url(21) + '&success_msg=#SUCCESS_MSG#')

# =============================================================== 30) سجل الوصول
p = app.page(30, 'Access Log', 'ACCESS-LOG', 'سجل الوصول للمستندات', scheme=TENANT)
p.ir('سجل الوصول', 10, [
    "select l.id, l.created_at, d.reference_no, d.title, decode(l.access_type, 'DOWNLOAD', 'تنزيل/عرض', l.access_type) as access_type,",
    "       nvl(u.username, l.created_by) as username,",
    "       case l.result_code when 'ALLOWED' then '<span class=\"nn-badge is-success\">مسموح</span>' else '<span class=\"nn-badge is-danger\">مرفوض</span>' end as result_html",
    '  from dms_access_log l join dms_document d on d.id = l.document_id',
    '  left join sec_user_membership m on m.id = l.membership_id left join sec_user u on u.id = m.user_id',
    ' where d.company_id = noona_dms_pkg.company order by l.id desc'],
    [('ID', '#', {'hidden': True, 'type': 'NUMBER'}), ('CREATED_AT', 'الوقت', {'type': 'DATE'}), ('REFERENCE_NO', 'رقم الأرشيف', {}),
     ('TITLE', 'المستند', {}), ('ACCESS_TYPE', 'الإجراء', {}), ('USERNAME', 'المستخدم', {}), ('RESULT_HTML', 'النتيجة', {'html': True})],
    rows=100)

download_page(app, 49, TENANT)

app.nav_item('لوحة الأرشيف', 1, 'fa-archive', 10)
app.nav_item('البحث في الأرشيف', 10, 'fa-search', 20)
app.nav_item('أرشفة مستند', 12, 'fa-upload', 30)
st = app.nav_item('الإعدادات', None, 'fa-cog', 40)
app.nav_item('أنواع المستندات', 20, 'fa-files-o', 41, parent=st)
app.nav_item('قواعد الأرشفة', 21, 'fa-gavel', 42, parent=st)
app.nav_item('سجل الوصول', 30, 'fa-eye', 43, parent=st)

app.finalize()
print('NOONA_DOC built:', len(app.pages), 'pages')
