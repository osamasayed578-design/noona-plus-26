"""لوحة الأرشفة المشتركة: المستندات المؤرشفة لمستند أعمال ونموذج أرشفة مرجعه الورقي (رقم الأصل وموقعه وصورته اختيارياً).
تستخدم في صفحات القيود والسندات وأي مستند أعمال لاحقاً؛ التنزيل عبر صفحة download_page.
"""

DOC_FILE_TYPES = ('application/pdf,image/png,image/jpeg,image/tiff,image/webp,'
                  '.docx,.xlsx')
DOC_TYPES_LOV = ("select t.name_ar d, t.code r from dms_document_type t where t.is_active = 'Y' "
                 "and t.code <> 'COMPANY_LOGO' order by t.name_ar")


def dl_link(page_no, with_version=False):
    """رابط صفحة التنزيل بصيغة الروابط الودية (apex_page.get_url)؛ #ID# و #VER# يستبدلان في الحزمة."""
    if with_version:
        return (f"replace(replace(apex_page.get_url(p_page => {page_no}, p_items => 'P{page_no}_DOC,P{page_no}_VER', "
                "p_values => '990000000001,990000000002'), '990000000001', '#ID#'), '990000000002', '#VER#')")
    return (f"replace(apex_page.get_url(p_page => {page_no}, p_items => 'P{page_no}_DOC', p_values => '990000000001'), "
            "'990000000001', '#ID#')")


def dms_panel(p, seq, entity_type, id_item, download_page, condition=None, process_seq=90):
    """منطقة الأرشفة: قائمة المستندات + نموذج الأرشفة؛ يعيد زر الأرشفة."""
    pre = id_item.split('_')[0]
    link = dl_link(download_page)
    r = p.dynamic('المستندات المؤرشفة (المرجع الورقي)', seq,
                  f"return noona_dms_pkg.attachments_html('{entity_type}', :{id_item}, {link});",
                  condition=condition or f':{id_item} is not null')
    f = p.static('أرشفة المرجع الورقي', seq + 1, condition=condition or f':{id_item} is not null')
    p.text(f'{pre}_ARC_REF', f, 10, 'رقم الأصل الورقي (فاتورة / شيك / خطاب)', maxlen=100, width=25)
    p.text(f'{pre}_ARC_LOC', f, 20, 'موقع الأصل (الملف / الرف)', maxlen=200, width=30)
    p.select(f'{pre}_ARC_TYPE', f, 30, 'نوع المستند', lov_sql=DOC_TYPES_LOV, null_text='- تلقائي حسب المستند -')
    p.text(f'{pre}_ARC_TITLE', f, 40, 'العنوان (اختياري)', maxlen=500)
    p.file(f'{pre}_ARC_FILE', f, 50, 'صورة الأصل (اختياري)', file_types=DOC_FILE_TYPES, max_kb=20480,
           title='اسحب صورة الأصل أو ملف PDF هنا', hint='PDF أو صورة أو Word/Excel حتى 20 ميجابايت')
    b = p.button(f, 10, 'ARCHIVE', 'أرشفة', hot=True)
    p.process(process_seq, 'AFTER_SUBMIT', 'Archive Reference', [
        'declare',
        '    l_blob blob;',
        '    l_name varchar2(400);',
        '    l_mime varchar2(255);',
        '    l_id   number;',
        'begin',
        f'    if :{pre}_ARC_FILE is not null then',
        f'        select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :{pre}_ARC_FILE;',
        '    end if;',
        f"    l_id := noona_dms_pkg.archive_document(p_entity_type => '{entity_type}', p_entity_id => :{id_item},",
        f'                p_type_code => :{pre}_ARC_TYPE, p_title => :{pre}_ARC_TITLE, p_external_ref => :{pre}_ARC_REF,',
        f'                p_location => :{pre}_ARC_LOC, p_file_name => l_name, p_mime => l_mime, p_content => l_blob);',
        'end;'], when_button=b, success='تمت الأرشفة وصدر رقم الأرشيف')
    return b


def download_page(app, pid, scheme):
    """صفحة تنزيل/عرض ملف مؤرشف (P{pid}_DOC و P{pid}_VER) مع سجل الوصول."""
    p = app.page(pid, 'Document File', 'DOCUMENT-FILE', 'ملف المستند', scheme=scheme, protection='N')
    f = p.static('الملف', 10, hide_header=True)
    p.hidden(f'P{pid}_DOC', f, 1, protected=False)
    p.hidden(f'P{pid}_VER', f, 2, protected=False)
    p.process(10, 'BEFORE_HEADER', 'Download', [
        'begin',
        f'    noona_dms_pkg.download(:P{pid}_DOC, :P{pid}_VER);',
        '    apex_application.stop_apex_engine;',
        'exception',
        '    when apex_application.e_stop_apex_engine then',
        '        null;',
        'end;'])
    return p
