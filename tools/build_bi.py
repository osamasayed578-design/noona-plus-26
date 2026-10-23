"""NOONA_BI (مركز التقارير): كل تقارير الأنظمة المشترك فيها في مكان واحد، مقسمة بكروت الوحدات في الشاشة الرئيسية،
مع المفضلة وآخر ما فتح والبحث. يفتح التقرير في تطبيق وحدته بنفس الجلسة (الكتالوج في tools/bi_catalog.py).
الاستخدام: python3 tools/build_bi.py  ->  apex/NOONA_BI/f143
"""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from apexgen import App

ROOT = os.path.join(os.path.dirname(__file__), '..')
app = App(template_dir=os.path.join(ROOT, 'apex/_templates/f119_original'),
          out_dir=os.path.join(ROOT, 'apex/NOONA_BI/f143'),
          app_id=143, alias='NOONA_BI', name='NOONA Reports Center', id_base=91820277000000000)
app.wire_security()
app.add_branding()
TENANT = app.schemes['tenant']

# التطبيقات المثبتة في مساحة العمل: تقارير التطبيق غير المثبت تظهر معطلة
APPS = "    select listagg(alias, ',') within group (order by alias) into l_apps from apex_applications;"
FAV = ['declare', '    l_fav varchar2(1);', 'begin',
       '    l_fav := noona_bi_pkg.toggle_favorite(to_number(apex_application.g_x01));',
       "    apex_json.open_object; apex_json.write('ok', true); apex_json.write('fav', l_fav); apex_json.close_object;",
       'exception when others then',
       "    apex_json.open_object; apex_json.write('ok', false);",
       "    apex_json.write('msg', regexp_replace(sqlerrm, '^ORA-[0-9]+: ', '')); apex_json.close_object;",
       'end;']
# المفضلة بنقرة (AJAX)؛ والبحث: في الرئيسية يبحث في كل التقارير عند Enter، وفي الوحدة يصفي البطاقات فوراً
JS_FAV = [
    "document.addEventListener('click', function (e) {",
    "  var b = e.target.closest('.nn-rh-fav'); if (!b) return;",
    "  e.preventDefault(); b.disabled = true;",
    "  apex.server.process('FAV', { x01: b.dataset.id }, { dataType: 'json' }).then(function (d) {",
    "    b.disabled = false;",
    "    if (!d.ok) { apex.message.clearErrors(); apex.message.showErrors([{ type: 'error', location: 'page', message: d.msg, unsafe: false }]); return; }",
    "    var on = d.fav === 'Y';",
    "    document.querySelectorAll('.nn-rh-fav[data-id=\"' + b.dataset.id + '\"]').forEach(function (x) {",
    "      x.classList.toggle('is-on', on); x.title = on ? 'إزالة من المفضلة' : 'إضافة للمفضلة';",
    "      x.firstElementChild.className = 'fa ' + (on ? 'fa-star' : 'fa-star-o'); });",
    "    apex.message.showPageSuccess(on ? 'أضيف التقرير إلى المفضلة' : 'أزيل التقرير من المفضلة');",
    "  }, function () { b.disabled = false; });",
    "});"]

# =============================================================== 1) الرئيسية: كروت الوحدات
p = app.page(1, 'Home', 'HOME', 'مركز التقارير', scheme=TENANT, protection='N')
r = p.dynamic('مركز التقارير', 10, ['declare', '    l_apps varchar2(4000);', 'begin', APPS,
                                    '    return noona_bi_pkg.home_html(:APP_SESSION, l_apps, :P1_SEARCH);', 'end;'],
              hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P1_SEARCH', r, 10, protected=False)
p.process(1, 'ON_DEMAND', 'FAV', FAV)
p.onload(JS_FAV + [
    "var s = document.getElementById('nnRhSearch');",
    "if (s) {",
    "  s.addEventListener('keydown', function (e) {",
    "    if (e.key === 'Enter') { e.preventDefault(); $s('P1_SEARCH', s.value.trim()); apex.submit('SEARCH'); }",
    "    if (e.key === 'Escape' && $v('P1_SEARCH')) { $s('P1_SEARCH', ''); apex.submit('SEARCH'); } });",
    "  if (!s.value) s.focus();",
    "}"])
p.branch(10, 'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::')

# =============================================================== 2) تقارير الوحدة
p = app.page(2, 'Module Reports', 'MODULE', 'تقارير الوحدة', scheme=TENANT, protection='N')
r = p.dynamic('التقارير', 10, ['declare', '    l_apps varchar2(4000);', 'begin', APPS,
                              '    return noona_bi_pkg.module_html(:P2_MODULE, :APP_SESSION, l_apps, :P2_TYPE);', 'end;'],
              hide_header=True, opts='#DEFAULT#:t-Region--noUI')
p.hidden('P2_MODULE', r, 10, protected=False)
p.hidden('P2_TYPE', r, 20, protected=False)
p.process(1, 'ON_DEMAND', 'FAV', FAV)
p.onload(JS_FAV + [
    "var s = document.getElementById('nnRhSearch');",
    "function nnFilter() {",
    "  var q = s.value.trim().toLowerCase(), n = 0;",
    "  document.querySelectorAll('.nn-rh-rep').forEach(function (c) {",
    "    var on = !q || c.textContent.toLowerCase().indexOf(q) >= 0; c.style.display = on ? '' : 'none'; if (on) n++; });",
    "  var em = document.getElementById('nnRhNone');",
    "  if (!n && !em) { em = document.createElement('div'); em.id = 'nnRhNone'; em.className = 'nn-empty'; em.textContent = 'لا توجد تقارير مطابقة';",
    "    var g = document.querySelector('.nn-rh-reps'); if (g) g.after(em); }",
    "  if (em) em.style.display = n ? 'none' : '';",
    "}",
    "if (s) { s.addEventListener('input', nnFilter); s.addEventListener('keydown', function (e) { if (e.key === 'Escape') { s.value = ''; nnFilter(); } }); s.focus(); }"])

# =============================================================== 3) فتح التقرير في تطبيق وحدته (يسجل الفتح)
p = app.page(3, 'Open Report', 'OPEN', 'فتح التقرير', scheme=TENANT, protection='N')
r = p.static('فتح التقرير', 10, hide_header=True)
p.hidden('P3_ID', r, 10, protected=False)
p.process(1, 'BEFORE_HEADER', 'Open Report', 'apex_util.redirect_url(noona_bi_pkg.open_url(:P3_ID, :APP_SESSION));')

app.nav_item('مركز التقارير', 1, 'fa-bar-chart', 10)

app.finalize()
print('NOONA_BI built:', len(app.pages), 'pages')
