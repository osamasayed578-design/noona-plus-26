# هوية نونا بلس لأي تطبيق APEX مصدر: ملفات التصميم (CSS + Cairo + الشعار) وصفحة الدخول بالعربية
# الاستخدام: python3 tools/apex_brand.py apex/NOONA_MASTER/f115 apex/NOONA_PORTAL/f119
# آمن لإعادة التشغيل: يحتفظ بمعرفات الملفات الموجودة ويحدث محتواها ورقم إصدارها.
import os, re, sys, zlib

STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'apex', 'shared', 'static')
FILES = [('noona.css', 'text/css'), ('cairo-arabic.woff2', 'font/woff2'), ('cairo-latin.woff2', 'font/woff2'),
         ('noona-logo.svg', 'image/svg+xml'), ('noona-logo-white.svg', 'image/svg+xml')]
LOGIN_LABELS = [(",p_button_image_alt=>'Sign In'", ",p_button_image_alt=>'تسجيل الدخول'"),
                (",p_prompt=>'Username'", ",p_prompt=>'اسم المستخدم'"),
                (",p_placeholder=>'Username'", ",p_placeholder=>'اسم المستخدم'"),
                (",p_prompt=>'Password'", ",p_prompt=>'كلمة المرور'"),
                (",p_placeholder=>'Password'", ",p_placeholder=>'كلمة المرور'"),
                (",p_prompt=>'Remember username'", ",p_prompt=>'تذكر اسم المستخدم'")]


def brand(app_dir):
    a = os.path.join(app_dir, 'application') + '/'
    ca = open(a + 'create_application.sql', encoding='utf-8').read()
    app_id = int(re.search(r"p_default_application_id=>(\d+)", ca).group(1))
    ws = re.search(r"p_default_workspace_id=>(\d+)", ca).group(1)
    content = b''
    paths = []
    for k, (fname, mime) in enumerate(FILES, start=1):
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
        text = (f"prompt --application/{rel}\nbegin\n--   Manifest\n--     APP STATIC FILES: {app_id}\n--   Manifest End\n"
                f"wwv_flow_imp.component_begin (\n p_version_yyyy_mm_dd=>'2024.11.30'\n,p_release=>'24.2.0'\n"
                f",p_default_workspace_id=>{ws}\n,p_default_application_id=>{app_id}\n,p_default_id_offset=>0\n"
                f",p_default_owner=>'NOONA_APP'\n);\n{body}\nwwv_flow_imp.component_end;\nend;\n/\n")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, 'w', encoding='utf-8').write(text)
        paths.append(rel)
    # install.sql: إدراج الملفات بعد أيقونات التطبيق
    inst = os.path.join(app_dir, 'install.sql')
    s = open(inst, encoding='utf-8').read()
    anchor = "@@application/shared_components/files/icons_app_icon_512_png.sql\n"
    missing = ''.join(f'@@application/{p}.sql\n' for p in paths if f'@@application/{p}.sql' not in s)
    assert anchor in s, 'install.sql anchor not found'
    open(inst, 'w', encoding='utf-8').write(s.replace(anchor, anchor + missing, 1))
    # رقم إصدار الملفات يتغير مع المحتوى (يكسر ذاكرة المتصفح)
    ver = 1 + zlib.crc32(content) % 900000
    open(a + 'create_application.sql', 'w', encoding='utf-8').write(re.sub(r",p_files_version=>\d+", f",p_files_version=>{ver}", ca))
    ui = open(a + 'user_interfaces.sql', encoding='utf-8').read()
    if 'noona.css' not in ui:
        ui = ui.replace(",p_nav_bar_template_options=>'#DEFAULT#'",
                        ",p_nav_bar_template_options=>'#DEFAULT#'\n,p_css_file_urls=>'#APP_FILES#noona.css'", 1)
        assert 'noona.css' in ui, 'user_interfaces anchor not found'
        open(a + 'user_interfaces.sql', 'w', encoding='utf-8').write(ui)
    # صفحة الدخول بالعربية
    p = a + 'pages/page_09999.sql'
    s = open(p, encoding='utf-8').read()
    for old, new in LOGIN_LABELS:
        s = s.replace(old, new)
    open(p, 'w', encoding='utf-8').write(s)
    p = a + 'shared_components/navigation/lists/navigation_bar.sql'
    if os.path.exists(p):
        s = open(p, encoding='utf-8').read().replace(",p_list_item_link_text=>'Sign Out'", ",p_list_item_link_text=>'تسجيل الخروج'")
        open(p, 'w', encoding='utf-8').write(s)
    print(f'{app_dir}: NOONA branding applied (files v{ver})')


if __name__ == '__main__':
    for d in sys.argv[1:]:
        brand(d)
