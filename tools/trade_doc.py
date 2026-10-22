"""أدوات شاشات سلسلة الإمداد والمبيعات: المستند التجاري (trade_doc.js)، بطاقة الصنف (item_editor.js)، نقطة البيع (pos.js)،
عرض رمز ZATCA بمكتبة qrcode.js، وعمليات AJAX الموحدة (SAVE_DOC / FIND_ITEMS).
"""
import json, os

_DIR = os.path.dirname(__file__)
TD_JS = open(os.path.join(_DIR, 'trade_doc.js'), encoding='utf-8').read().splitlines()
ITEM_JS = open(os.path.join(_DIR, 'item_editor.js'), encoding='utf-8').read().splitlines()
POS_JS = open(os.path.join(_DIR, 'pos.js'), encoding='utf-8').read().splitlines()

# رمز الاستجابة السريعة لكل عنصر .nn-qr[data-qr] (تحميل المكتبة عند الحاجة فقط)
QR_JS = [
    '(function () {',
    "    var els = document.querySelectorAll('.nn-qr[data-qr]'); if (!els.length) return;",
    '    var draw = function () { els.forEach(function (el) { var q = qrcode(0, \'M\'); q.addData(el.dataset.qr); q.make();',
    "        el.innerHTML = q.createSvgTag({cellSize: 3, margin: 2, scalable: true}); }); };",
    "    if (window.qrcode) { draw(); return; }",
    "    var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'qrcode.js'; s.onload = draw; document.head.appendChild(s);",
    '})();']


def _q(s):
    return s.replace("'", "''")


def trade_region(conf, data_sql, ro_sql, lists, container='nnTd', data_id='nnTdData'):
    """منطقة المستند: JSON البيانات والإعداد والقوائم، وحاوية يبنيها JS. conf: dict ثابت؛ lists: أسماء قوائم lists_json"""
    return [
        'declare',
        f'    l_ro varchar2(1) := {ro_sql};',
        "    function js(p clob) return clob is begin return replace(p, '</', '<\\/'); end;",
        'begin',
        f"    return '<script type=\"application/json\" id=\"{data_id}\">' || js({data_sql}) || '</script>'",
        f"        || '<script type=\"application/json\" id=\"nnTdConf\">' || js(q'~{json.dumps(conf, ensure_ascii=False)}~') || '</script>'",
        f"        || '<script type=\"application/json\" id=\"nnTdLists\">' || js(noona_inv_pkg.lists_json('{lists}')) || '</script>'",
        f"        || '<div id=\"{container}\" class=\"nn-doc nn-td\" data-ro=\"' || l_ro || '\" data-co=\"'",
        "        || apex_escape.html_attribute(noona_apex_pkg.company_name) || '\"></div>';",
        'end;']


def save_ajax(save_fn, page_no, item=None):
    """SAVE_DOC: يحفظ JSON المستند (p_clob_01) ويعيد رابط فتحه أو رسالة الخطأ"""
    item = item or f'P{page_no}_ID'
    return [
        'declare',
        '    l_id number;',
        'begin',
        f'    l_id := {save_fn}(apex_application.g_clob_01);',
        '    apex_json.open_object;',
        "    apex_json.write('ok', true);",
        "    apex_json.write('id', l_id);",
        f"    apex_json.write('url', apex_page.get_url(p_page => {page_no}, p_clear_cache => '{page_no}', p_items => '{item}', p_values => l_id));",
        '    apex_json.close_object;',
        'exception when others then',
        '    rollback;',
        '    apex_json.open_object;',
        "    apex_json.write('ok', false);",
        "    apex_json.write('msg', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^[' || chr(10) || ']+')), sqlerrm));",
        '    apex_json.close_object;',
        'end;']


def clob_ajax(expr):
    """عملية AJAX تعيد CLOB (JSON) كما هو، أو {"ok":false,"msg"} عند الخطأ"""
    return [
        'begin',
        f'    apex_util.prn({expr}, false);',
        'exception when others then',
        '    rollback;',
        '    apex_json.open_object;',
        "    apex_json.write('ok', false);",
        "    apex_json.write('msg', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^[' || chr(10) || ']+')), sqlerrm));",
        '    apex_json.close_object;',
        'end;']


FIND_ITEMS = clob_ajax("noona_inv_pkg.find_items(apex_application.g_x01, null, 15, nvl(apex_application.g_x02, 'ALL'))")
