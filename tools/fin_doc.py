"""المستند الورقي للقيود والسندات: منطقة HTML ببيانات JSON مضمنة + عملية AJAX واحدة SAVE_DOC.
الواجهة في tools/fin_doc.js (رأس وتذييل) و GRID_JS في tools/fin_grid.py (السطور).
"""
import os

DOC_JS = open(os.path.join(os.path.dirname(__file__), 'fin_doc.js'), encoding='utf-8').read().splitlines()


def _blob(elem_id, expr):
    return f"        || '<script type=\"application/json\" id=\"{elem_id}\">' || js({expr}) || '</script>'"


def doc_region(kind, doc_sql, accounts_sql, readonly_sql, extra=()):
    """منطقة المستند: JSON للمستند والحسابات ومراكز التكلفة والعملات (و extra)، وحاوية nnDoc يبنيها DOC_JS."""
    return ([
        'declare',
        f'    l_ro varchar2(1) := {readonly_sql};',
        "    function js(p clob) return clob is begin return replace(p, '</', '<\\/'); end;",
        'begin',
        "    return '<!-- nn-doc -->'",
        _blob('nnDocData', doc_sql),
        "        || case when l_ro = 'N' then '<script type=\"application/json\" id=\"nnJeAccts\">' || js(" + accounts_sql + ") || '</script>' end",
        _blob('nnJeCcs', 'noona_gl_pkg.cost_centers_json'),
        _blob('nnDocCurs', 'noona_gl_pkg.currencies_json'),
    ] + [_blob(k, v) for k, v in extra] + [
        f"        || '<div id=\"nnDoc\" class=\"nn-doc\" data-kind=\"{kind}\" data-ro=\"' || l_ro || '\" data-co=\"'",
        "        || apex_escape.html_attribute(noona_apex_pkg.company_name) || '\" data-fc=\"' || noona_gl_pkg.ledger_currency || '\"></div>';",
        'end;'])


def doc_ajax(save_fn, page_no):
    """عملية AJAX: تحفظ المستند (رأس وسطور JSON في p_clob_01) وتعيد رابط المستند أو رسالة الخطأ."""
    return [
        'declare',
        '    l_id number;',
        'begin',
        f'    l_id := {save_fn}(apex_application.g_clob_01);',
        '    apex_json.open_object;',
        "    apex_json.write('ok', true);",
        "    apex_json.write('id', l_id);",
        f"    apex_json.write('url', apex_page.get_url(p_page => {page_no}, p_clear_cache => '{page_no}', p_items => 'P{page_no}_ID', p_values => l_id));",
        '    apex_json.close_object;',
        'exception when others then',
        '    rollback;',
        '    apex_json.open_object;',
        "    apex_json.write('ok', false);",
        "    apex_json.write('msg', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^[' || chr(10) || ']+')), sqlerrm));",
        '    apex_json.close_object;',
        'end;']
