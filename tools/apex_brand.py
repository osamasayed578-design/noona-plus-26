# هوية نونا بلس لأي تطبيق APEX مصدر: ملفات التصميم (CSS + Cairo + الشعار) وصفحة الدخول بالعربية
# الاستخدام: python3 tools/apex_brand.py apex/NOONA_MASTER/f115 apex/NOONA_PORTAL/f119
# آمن لإعادة التشغيل: يحتفظ بمعرفات الملفات الموجودة ويحدث محتواها ورقم إصدارها.
import os, re, sys, zlib

STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'apex', 'shared', 'static')
FILES = [('noona.css', 'text/css'), ('noona.js', 'application/javascript'), ('cairo-arabic.woff2', 'font/woff2'), ('cairo-latin.woff2', 'font/woff2'),
         ('noona-logo.svg', 'image/svg+xml'), ('noona-logo-white.svg', 'image/svg+xml')]
# صورة خلفية صفحة الدخول: أرقام ثابتة بعيدة عن ملفات التطبيقات الإضافية (aut.js, mfg.js...) التي تلحق بـ FILES
# أيقونات التطبيق (المفضلة وأيقونة الجوال): أيقونة NP نفسها في كل الأنظمة، مولدة من noona-logo.svg
APP_ICONS = [('icon_32.png', 'icons_app_icon_32_png'), ('icon_144_r.png', 'icons_app_icon_144_rounded_png'),
             ('icon_192.png', 'icons_app_icon_192_png'), ('icon_256_r.png', 'icons_app_icon_256_rounded_png'),
             ('icon_512.png', 'icons_app_icon_512_png')]
# نسخة 26: «مساعد نونا» (tools/ai_brand.py + ai.js) يضاف لكل التطبيقات عند وجوده
try:
    import ai_brand
except ImportError:
    ai_brand = None
if ai_brand:
    ai_brand.files(STATIC_DIR, FILES)

SLOT_FILES = [(21, 'noona-login-bg.jpg', 'image/jpeg'), (22, 'noona-login-bg-sm.jpg', 'image/jpeg')]
LOGIN_LABELS = [(",p_button_image_alt=>'Sign In'", ",p_button_image_alt=>'تسجيل الدخول'"),
                (",p_prompt=>'Username'", ",p_prompt=>'اسم المستخدم'"),
                (",p_placeholder=>'Username'", ",p_placeholder=>'اسم المستخدم'"),
                (",p_prompt=>'Password'", ",p_prompt=>'كلمة المرور'"),
                (",p_placeholder=>'Password'", ",p_placeholder=>'كلمة المرور'"),
                (",p_prompt=>'Remember username'", ",p_prompt=>'تذكر اسم المستخدم'")]


LOGO_PROCESS = [
    '-- شعار الشركة الحالية (شعار المشترك) من إدارة المستندات؛ يستدعى من شارة الشركة في الترويسة',
    'declare',
    '    l_blob blob;',
    '    l_mime varchar2(100);',
    '    l_hash varchar2(128);',
    'begin',
    '    noona_brand_pkg.get_company_logo(null, l_blob, l_mime, l_hash);',
    '    if l_blob is null then',
    "        owa_util.status_line(404, 'Not Found');",
    '    else',
    '        owa_util.mime_header(l_mime, false);',
    "        htp.p('Content-Length: ' || dbms_lob.getlength(l_blob));",
    "        htp.p('Cache-Control: private, max-age=600');",
    "        htp.p('X-Content-Type-Options: nosniff');",
    '        owa_util.http_header_close;',
    '        wpg_docload.download_file(l_blob);',
    '    end if;',
    '    apex_application.stop_apex_engine;',
    'exception',
    '    when apex_application.e_stop_apex_engine then',
    '        null;',
    'end;']


def q(s):
    return s.replace("'", "''")


def join(lines):
    return "wwv_flow_string.join(wwv_flow_t_varchar2(\n" + ",\n".join("'" + q(l) + "'" for l in lines) + "))"


def component(rel, manifest, app_id, ws, body):
    return (f"prompt --application/{rel}\nbegin\n--   Manifest\n--     {manifest}\n--   Manifest End\n"
            f"wwv_flow_imp.component_begin (\n p_version_yyyy_mm_dd=>'2024.11.30'\n,p_release=>'24.2.0'\n"
            f",p_default_workspace_id=>{ws}\n,p_default_application_id=>{app_id}\n,p_default_id_offset=>0\n"
            f",p_default_owner=>'NOONA_APP'\n);\n{body}\nwwv_flow_imp.component_end;\nend;\n/\n")


def brand(app_dir):
    a = os.path.join(app_dir, 'application') + '/'
    ca = open(a + 'create_application.sql', encoding='utf-8').read()
    app_id = int(re.search(r"p_default_application_id=>(\d+)", ca).group(1))
    ws = re.search(r"p_default_workspace_id=>(\d+)", ca).group(1)
    content = b''
    paths = []
    for k, fname, mime in [(k, f, m) for k, (f, m) in enumerate(FILES, start=1)] + SLOT_FILES:
        rel = f'shared_components/files/noona_{k}'
        path = a + rel + '.sql'
        old = open(path, encoding='utf-8').read() if os.path.exists(path) else ''
        m = re.search(r"p_id=>wwv_flow_imp\.id\((\d+)\)", old)
        fid = m.group(1) if m else str(91820260000990000 + app_id * 100 + k)   # معرف ثابت لكل تطبيق وملف
        data = open(os.path.join(STATIC_DIR, fname), 'rb').read()
        content += data
        hexd = data.hex().upper()
        body = "wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;\n" + ''.join(
            f"wwv_flow_imp.g_varchar2_table({i}) := '{hexd[j:j + 200]}';\n" for i, j in enumerate(range(0, len(hexd), 200), 1))
        body += f"""wwv_flow_imp_shared.create_app_static_file(
 p_id=>wwv_flow_imp.id({fid})
,p_file_name=>'{fname}'
,p_mime_type=>'{mime}'
,p_file_charset=>'utf-8'
,p_file_content => wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);"""
        text = component(rel, f'APP STATIC FILES: {app_id}', app_id, ws, body)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, 'w', encoding='utf-8').write(text)
        paths.append(rel)
    for src, name in APP_ICONS:
        path = a + 'shared_components/files/' + name + '.sql'
        if not os.path.exists(path):
            continue
        hexd = open(os.path.join(STATIC_DIR, 'icons', src), 'rb').read().hex().upper()
        table = "wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;\n" + ''.join(
            f"wwv_flow_imp.g_varchar2_table({i}) := '{hexd[j:j + 200]}';\n" for i, j in enumerate(range(0, len(hexd), 200), 1))
        old = open(path, encoding='utf-8').read()
        new = re.sub(r"wwv_flow_imp\.g_varchar2_table := wwv_flow_imp\.empty_varchar2_table;\n(?:wwv_flow_imp\.g_varchar2_table\(\d+\) := '[0-9A-F]*';\n)+",
                     lambda m: table, old, count=1)
        assert new != old or table in old, path
        open(path, 'w', encoding='utf-8').write(new)
    # install.sql: إدراج الملفات بعد أيقونات التطبيق
    inst = os.path.join(app_dir, 'install.sql')
    s = open(inst, encoding='utf-8').read()
    anchor = "@@application/shared_components/files/icons_app_icon_512_png.sql\n"
    # عملية عند الطلب: صورة شعار الشركة الحالية
    rel = 'shared_components/logic/application_processes/noona_company_logo'
    body = f"""wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id({91820260000990000 + app_id * 100 + 40})
,p_process_sequence=>10
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'NOONA_COMPANY_LOGO'
,p_process_sql_clob=>{join(LOGO_PROCESS)}
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>'MUST_NOT_BE_PUBLIC_USER'
);"""
    os.makedirs(os.path.dirname(a + rel), exist_ok=True)
    open(a + rel + '.sql', 'w', encoding='utf-8').write(component(rel, 'APPLICATION PROCESS: NOONA_COMPANY_LOGO', app_id, ws, body))
    paths.append(rel)
    if ai_brand:
        rel = 'shared_components/logic/application_processes/noona_ai'
        body = f"""wwv_flow_imp_shared.create_flow_process(
 p_id=>wwv_flow_imp.id({91820260000990000 + app_id * 100 + 41})
,p_process_sequence=>20
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'NOONA_AI'
,p_process_sql_clob=>{join(ai_brand.PROCESS)}
,p_process_clob_language=>'PLSQL'
,p_security_scheme=>'MUST_NOT_BE_PUBLIC_USER'
);"""
        open(a + rel + '.sql', 'w', encoding='utf-8').write(component(rel, 'APPLICATION PROCESS: NOONA_AI', app_id, ws, body))
        paths.append(rel)
    missing = ''.join(f'@@application/{p}.sql\n' for p in paths if f'@@application/{p}.sql' not in s)
    assert anchor in s, 'install.sql anchor not found'
    open(inst, 'w', encoding='utf-8').write(s.replace(anchor, anchor + missing, 1))
    # رقم إصدار الملفات يتغير مع المحتوى (يكسر ذاكرة المتصفح)
    ver = 1 + zlib.crc32(content) % 900000
    # عرض المستندات داخل إطار في نفس التطبيق (معاينة الأرشيف): السماح بالإطار من نفس الأصل فقط بدل المنع الكامل
    ca = ca.replace(",p_browser_frame=>'D'", ",p_browser_frame=>'S'")
    open(a + 'create_application.sql', 'w', encoding='utf-8').write(re.sub(r",p_files_version=>\d+", f",p_files_version=>{ver}", ca))
    ui = open(a + 'user_interfaces.sql', encoding='utf-8').read()
    if 'noona.css' not in ui:
        ui = ui.replace(",p_nav_bar_template_options=>'#DEFAULT#'",
                        ",p_nav_bar_template_options=>'#DEFAULT#'\n,p_css_file_urls=>'#APP_FILES#noona.css'", 1)
        assert 'noona.css' in ui, 'user_interfaces anchor not found'
        open(a + 'user_interfaces.sql', 'w', encoding='utf-8').write(ui)
    # تحسينات الوصول العامة (noona.js) في كل صفحات التطبيق
    if 'noona.js' not in ui:
        ui = ui.replace(",p_css_file_urls=>'#APP_FILES#noona.css'", ",p_javascript_file_urls=>'#APP_FILES#noona.js'\n,p_css_file_urls=>'#APP_FILES#noona.css'", 1)
        assert 'noona.js' in ui, 'user_interfaces css anchor not found'
        open(a + 'user_interfaces.sql', 'w', encoding='utf-8').write(ui)
    if ai_brand and 'ai.js' not in ui:
        ui = ui.replace(",p_javascript_file_urls=>'#APP_FILES#noona.js'", ",p_javascript_file_urls=>'#APP_FILES#noona.js'||chr(10)||'#APP_FILES#ai.js'", 1)
        assert 'ai.js' in ui, 'user_interfaces js anchor not found'
        open(a + 'user_interfaces.sql', 'w', encoding='utf-8').write(ui)
    # الصفحة 0: شارة الشركة الحالية (شعار المشترك واسمها) في ترويسة كل الصفحات
    p = a + 'pages/page_00000.sql'
    s = open(p, encoding='utf-8').read()
    if 'noona_brand_pkg.header_badge' not in s:
        region = f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({91820260000990000 + app_id * 100 + 50})
,p_plug_name=>'NOONA Company Badge'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_plug_display_point=>'BEFORE_NAVIGATION_BAR'
,p_function_body_language=>'PLSQL'
,p_plug_source=>'return noona_brand_pkg.header_badge(p_app_id => :APP_ID, p_session => :APP_SESSION);'
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
"""
        i = s.rindex('wwv_flow_imp.component_end;')
        open(p, 'w', encoding='utf-8').write(s[:i] + region + s[i:])
    # صفحة الدخول بالعربية
    p = a + 'pages/page_09999.sql'
    s = open(p, encoding='utf-8').read()
    for old, new in LOGIN_LABELS:
        s = s.replace(old, new)
    open(p, 'w', encoding='utf-8').write(s)
    alias = re.search(r"get_application_alias,'([^']*)'\)", ca)
    is_master = bool(alias) and alias.group(1) == 'NOONA_MASTER'
    p = a + 'shared_components/navigation/lists/navigation_bar.sql'
    if os.path.exists(p):
        s = open(p, encoding='utf-8').read().replace(",p_list_item_link_text=>'Sign Out'", ",p_list_item_link_text=>'تسجيل الخروج'")
        # شريط التنقل: الرجوع لشاشة الأنظمة، وتغيير كلمة المرور (في التطبيق الرئيسي) من قائمة المستخدم
        user_item = re.search(r"p_id=>wwv_flow_imp\.id\((\d+)\)\n,p_list_item_display_sequence=>10\n,p_list_item_link_text=>'&APP_USER\.'", s)
        items = ''
        if not is_master and 'NOONA_MASTER:1:' not in s:
            items += f"""wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id({91820260000990000 + app_id * 100 + 60})
,p_list_item_display_sequence=>5
,p_list_item_link_text=>'الأنظمة'
,p_list_item_link_target=>'f?p=NOONA_MASTER:1:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-th'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_list_item_current_type=>'TARGET_PAGE'
);
"""
        if user_item and 'CHANGE-PASSWORD' not in s:
            items += f"""wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id({91820260000990000 + app_id * 100 + 61})
,p_list_item_display_sequence=>15
,p_list_item_link_text=>'تغيير كلمة المرور'
,p_list_item_link_target=>'f?p=NOONA_MASTER:CHANGE-PASSWORD:&SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-key'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id({user_item.group(1)})
,p_list_item_current_type=>'TARGET_PAGE'
);
"""
        if items:
            i = s.rindex('wwv_flow_imp.component_end;')
            s = s[:i] + items + s[i:]
        open(p, 'w', encoding='utf-8').write(s)
    # دخول موحد: كل التطبيقات عدا الرئيسي تحيل غير المسجلين وتسجيل الخروج إلى دخول التطبيق الرئيسي
    p = a + 'shared_components/security/authentications/oracle_apex_accounts.sql'
    if os.path.exists(p) and not is_master:
        s = open(p, encoding='utf-8').read()
        if "p_invalid_session_url" not in s:
            s = s.replace(",p_invalid_session_type=>'LOGIN'",
                          ",p_invalid_session_type=>'URL'\n,p_invalid_session_url=>'f?p=NOONA_MASTER:LOGIN'"
                          "\n,p_logout_url=>'f?p=NOONA_MASTER:LOGIN'", 1)
            assert "p_invalid_session_url" in s, 'auth scheme anchor not found'
            open(p, 'w', encoding='utf-8').write(s)
    print(f'{app_dir}: NOONA branding applied (files v{ver})')


if __name__ == '__main__':
    for d in sys.argv[1:]:
        brand(d)
