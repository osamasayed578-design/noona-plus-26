"""صفحة «التحليلات والتنبؤ» تضاف لأي تطبيق (NOONA_ANL_PKG + tools/anl.js):
مؤشرات الشهر الحالي مقارنة بالفترة المماثلة لكل موديول مع رسم مصغر لـ12 شهراً، ورسم كبير شهري/أسبوعي/يومي مع تنبؤ
Holt-Winters ونطاق ثقة 95%، ومرشح الفرع، وعرض جدول. كل الأرقام بصلاحيات المستخدم وشركته وفرعه.
  add(app, page_no, modules, scheme, nav_seq, unified=False, nav_parent=None)
"""
import os
import shutil
import apex_brand

_DIR = os.path.dirname(os.path.abspath(__file__))
shutil.copyfile(os.path.join(_DIR, 'anl.js'), os.path.join(apex_brand.STATIC_DIR, 'anl.js'))
if ('anl.js', 'application/javascript') not in apex_brand.FILES:
    apex_brand.FILES.append(('anl.js', 'application/javascript'))

PAGE = 98
AJAX = [
    'declare',
    '    l clob;',
    '    l_pos pls_integer := 1;',
    "    l_br number := to_number(nullif(apex_application.g_x03, ''));",
    'begin',
    '    l := case apex_application.g_x01',
    "           when 'VIEW' then noona_anl_pkg.view_json(apex_application.g_x02, l_br, apex_application.g_x06)",
    "           when 'CHART' then noona_anl_pkg.chart_json(apex_application.g_x02, apex_application.g_x04,",
    "                                                      to_number(nvl(apex_application.g_x05, '3')), l_br, apex_application.g_x06)",
    "           when 'ANOM' then noona_anl_pkg.anomalies_json(12, 2, apex_application.g_x06)",
    "           when 'COMPANIES' then noona_anl_pkg.companies_json(apex_application.g_x02, trunc(sysdate, 'MM'), trunc(sysdate))",
    "           else '{\"ok\":false,\"msg\":\"طلب غير معروف\"}' end;",
    "    owa_util.mime_header('application/json', false); owa_util.http_header_close;",
    '    while l_pos <= dbms_lob.getlength(l) loop',
    '        htp.prn(dbms_lob.substr(l, 8000, l_pos)); l_pos := l_pos + 8000;',
    '    end loop;',
    'exception when others then',
    '    apex_json.open_object; apex_json.write(\'ok\', false);',
    "    apex_json.write('msg', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']
LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'anl.js'; "
          "document.head.appendChild(s); })();"]


def add(app, modules, scheme, nav_seq, unified=False, nav_parent=None, page_no=PAGE,
        title='التحليلات والتنبؤ', icon='fa-line-chart'):
    p = app.page(page_no, 'Analytics', 'ANALYTICS', title, scheme=scheme, protection='N')
    p.static(title, 10, hide_header=True, opts='#DEFAULT#:t-Region--noUI',
             text=f'<div id="nnAnl" class="nn-anl" data-modules="{",".join(modules)}" data-unified="{"Y" if unified else "N"}"></div>')
    p.process(1, 'ON_DEMAND', 'ANL', AJAX)
    p.onload(LOADER)
    app.nav_item(title, page_no, icon, nav_seq, parent=nav_parent)
    return p
