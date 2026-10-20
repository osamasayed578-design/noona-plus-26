"""NOONA PLUS - مولد تطبيقات Oracle APEX 24.2 (صيغة التصدير المجزأ Split Export).

يبدأ من تصدير APEX أصلي (قالب: الثيم والقوالب وصفحة الدخول) ويضيف فوقه:
  * أمان NOONA الموحد: المصادقة والكوكي المشترك و Initialization/Cleanup ومعالج الأخطاء وقواعد الصلاحيات
  * هوية الواجهة: noona.css + خط Cairo كملفات ثابتة مع رقم إصدار من المحتوى
  * صفحات: تقارير تفاعلية IR، تقارير كلاسيكية، مناطق ديناميكية HTML، نماذج إجرائية تستدعي حزم قاعدة البيانات

كل أسماء المعاملات مأخوذة من APEX 24.2 نفسه (dba_arguments) ومجربة بالاستيراد الفعلي.
"""
import os, re, shutil, zlib

# قوالب Universal Theme 42 (ثابتة في كل التطبيقات)
T_STD = 4072358936313175081       # Region: Standard
T_IRR = 2100526641005906379       # Region: Interactive Report
T_ROW = 2538654340625403440       # Classic Report: Standard
T_BTN = 4072362960822175091       # Button: Text
T_LBL = 1609121967514267634       # Label: Optional
T_REQ = 1609122147107268652       # Label: Required
STATIC_DIR = os.path.join(os.path.dirname(__file__), '..', 'apex', 'shared', 'static')

LANG = "sys_context('NOONA_CTX', 'LANGUAGE')"
SHARED_LOVS = [
    ('noona_companies', 'NOONA_COMPANIES', f"select case {LANG} when 'en' then nvl(legal_name_en, legal_name_ar) else nvl(trade_name_ar, legal_name_ar) end as d, id as r from org_company where status_code not in ('CLOSED', 'ARCHIVED') order by 1"),
    ('noona_branches', 'NOONA_BRANCHES', f"select case {LANG} when 'en' then nvl(name_en, name_ar) else name_ar end as d, id as r from org_branch where status_code = 'ACTIVE' and company_id = to_number(sys_context('NOONA_CTX', 'COMPANY_ID')) order by is_head_office desc, 1"),
    ('noona_currencies', 'NOONA_CURRENCIES', f"select currency_code || ' - ' || case {LANG} when 'en' then name_en else name_ar end as d, currency_code as r from ref_currency where is_active = 'Y' order by currency_code"),
    ('noona_countries', 'NOONA_COUNTRIES', f"select case {LANG} when 'en' then name_en else name_ar end as d, country_code as r from ref_country where is_active = 'Y' order by sort_order nulls last, 1"),
]


def q(s):
    return s.replace("'", "''")


def join(lines):
    if isinstance(lines, str):
        lines = lines.split('\n')
    return "wwv_flow_string.join(wwv_flow_t_varchar2(\n" + ",\n".join("'" + q(l) + "'" for l in lines) + "))"


def attrs(**kv):
    body = ",\n".join(f"  '{k}', '{q(str(v))}'" for k, v in kv.items())
    return f"wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(\n{body})).to_clob"



AUTH_PLSQL = [
    '-- مصادقة نونا بلس: بيانات الاعتماد المحلية (SEC_CREDENTIAL، PBKDF2) مع قفل بعد المحاولات الفاشلة؛',
    '-- المستخدم الذي لا يملك كلمة مرور محلية بعد يتحقق عبر حساب APEX (للانتقال التدريجي)',
    'function noona_authenticate(p_username in varchar2, p_password in varchar2) return boolean is',
    '    l_result varchar2(20);',
    'begin',
    '    l_result := noona_apex_pkg.check_password(p_username, p_password);',
    "    if l_result = 'NO_LOCAL' then",
    '        return apex_util.is_login_password_valid(p_username => p_username, p_password => p_password);',
    '    end if;',
    "    return l_result = 'OK';",
    'end noona_authenticate;',
    '',
    '-- بعد نجاح كلمة المرور: إنشاء جلسة NOONA (المؤسسة أو المنصة) وربطها بجلسة APEX',
    'procedure noona_post_auth is',
    '    l_ip varchar2(100);',
    'begin',
    '    begin',
    "        l_ip := owa_util.get_cgi_env('REMOTE_ADDR');",
    '    exception when others then',
    '        l_ip := null;   -- عنوان IP اختياري ولا يمنع الدخول',
    '    end;',
    '    noona_apex_pkg.post_auth(',
    '        p_username        => apex_application.g_user,',
    '        p_apex_session_id => to_number(apex_application.g_instance),',
    '        p_ip_address      => l_ip);',
    'end noona_post_auth;']


def noona_auth_scheme(s):
    """يحول مخطط 'NOONA Auth' إلى مصادقة مخصصة (Custom) تستدعي noona_authenticate."""
    s = s.replace(""",p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'""", """,p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_CUSTOM'
,p_attribute_03=>'noona_authenticate'
,p_attribute_05=>'N'""")
    s, n = re.subn(r",p_plsql_code=>wwv_flow_string\.join\(wwv_flow_t_varchar2\(\n.*?'end noona_post_auth;'\)\)",
                   lambda m: ',p_plsql_code=>' + join(AUTH_PLSQL), s, flags=re.S)
    assert n == 1 and 'NATIVE_CUSTOM' in s, 'NOONA Auth scheme not found'
    return s

class App:
    def __init__(self, template_dir, out_dir, app_id, alias, name, id_base):
        self.app_id, self.alias, self.name, self.base = app_id, alias, name, id_base
        self._n = 0
        self.dir = out_dir
        if os.path.exists(out_dir):
            shutil.rmtree(out_dir)
        shutil.copytree(template_dir, out_dir)
        self.A = os.path.join(out_dir, 'application') + '/'
        self.install_extra_shared = []      # بعد قواعد الصلاحيات
        self.pages = {}
        self.nav = []
        self.schemes = {}
        self.lovs = {}
        self._rewrite_app_id()

    # ------------------------------------------------------------------ أساسيات
    def id(self):
        self._n += 1
        return self.base + self._n

    def hdr(self):
        return f"""wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>{self.app_id}
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);"""

    def comp(self, prompt, manifest, body):
        return (f"prompt --application/{prompt}\nbegin\n--   Manifest\n--     {manifest}\n--   Manifest End\n"
                f"{self.hdr()}\n{body}\nwwv_flow_imp.component_end;\nend;\n/\n")

    def read(self, rel):
        return open(self.A + rel, encoding='utf-8').read()

    def write(self, rel, text):
        path = self.A + rel
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, 'w', encoding='utf-8').write(text)

    def edit(self, rel, old, new, count=1):
        s = self.read(rel)
        assert s.count(old) == count, (rel, old[:80])
        self.write(rel, s.replace(old, new))

    def _rewrite_app_id(self):
        for root, _, files in os.walk(self.dir):
            for f in files:
                if f.endswith('.sql'):
                    p = os.path.join(root, f)
                    s = open(p, encoding='utf-8').read()
                    s2 = re.sub(r"p_default_application_id=>\d+", f"p_default_application_id=>{self.app_id}", s)
                    s2 = re.sub(r"(--\s+(?:FLOW|LANGUAGE MAP|APP STATIC FILES):\s*)\d+", rf"\g<1>{self.app_id}", s2)
                    s2 = re.sub(r"wwv_flow_imp_shared\.create_user_interface\(\n p_id=>wwv_flow_imp\.id\(\d+\)",
                                f"wwv_flow_imp_shared.create_user_interface(\n p_id=>wwv_flow_imp.id({self.app_id})", s2)
                    if s2 != s:
                        open(p, 'w', encoding='utf-8').write(s2)
        ca = self.read('create_application.sql')
        ca = re.sub(r"get_application_name,'[^']*'\)", f"get_application_name,'{q(self.name)}')", ca)
        ca = re.sub(r"get_application_alias,'[^']*'\)", f"get_application_alias,'{self.alias}')", ca)
        ca = re.sub(r",p_logo_text=>'[^']*'", f",p_logo_text=>'{q(self.name)}'", ca)
        ca = re.sub(r",p_substitution_value_01=>'[^']*'", f",p_substitution_value_01=>'{q(self.name)}'", ca)
        ca = re.sub(r",p_flow_language=>'[^']*'", ",p_flow_language=>'ar'", ca)
        self.write('create_application.sql', ca)
        for rel in ('pages/page_09999.sql',):
            s = self.read(rel)
            s = re.sub(r",p_step_title=>'[^']*'", f",p_step_title=>'{q(self.name)} - تسجيل الدخول'", s, count=1)
            s = re.sub(r",p_plug_name=>'[^']*'", f",p_plug_name=>'{q(self.name)}'", s, count=1)
            self.write(rel, s)

    def allow_workspace_api(self):
        """يسمح باستدعاء واجهات إدارة مساحة العمل (مثل apex_util.create_user) أثناء التشغيل."""
        self.edit('create_application.sql', ",p_flow_version=>", ",p_runtime_api_usage=>'W'\n,p_flow_version=>")

    # ------------------------------------------------------------------ أمان NOONA
    def wire_security(self):
        auth_id = re.search(r"p_authentication_id=>wwv_flow_imp\.id\((\d+)\)", self.read('create_application.sql')).group(1)
        self.schemes = {'auth': self.id(), 'tenant': self.id(), 'platform': self.id(), 'admin': None}
        self.edit('create_application.sql', f",p_authentication_id=>wwv_flow_imp.id({auth_id})",
                  f""",p_authentication_id=>wwv_flow_imp.id({auth_id})
,p_security_scheme=>wwv_flow_imp.id({self.schemes['auth']})
,p_vpd=>'noona_apex_pkg.init_request(p_username => :APP_USER, p_apex_session_id => :APP_SESSION);'
,p_vpd_teardown_code=>'noona_apex_pkg.cleanup_request;'
,p_error_handling_function=>'noona_owner.noona_apex_error'""")
        rel = 'shared_components/security/authentications/oracle_apex_accounts.sql'
        s = self.read(rel)
        s = s.replace("--     AUTHENTICATION: Oracle APEX Accounts", "--     AUTHENTICATION: NOONA Auth")
        s = s.replace(""",p_name=>'Oracle APEX Accounts'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'""", """,p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'
,p_cookie_name=>'NOONA_SESSION'
,p_plsql_code=>""" + join([
            '-- بعد نجاح كلمة المرور: إنشاء جلسة NOONA (المؤسسة أو المنصة) وربطها بجلسة APEX',
            'procedure noona_post_auth is',
            '    l_ip varchar2(100);',
            'begin',
            '    begin',
            "        l_ip := owa_util.get_cgi_env('REMOTE_ADDR');",
            '    exception when others then',
            '        l_ip := null;   -- عنوان IP اختياري ولا يمنع الدخول',
            '    end;',
            '    noona_apex_pkg.post_auth(',
            '        p_username        => apex_application.g_user,',
            '        p_apex_session_id => to_number(apex_application.g_instance),',
            '        p_ip_address      => l_ip);',
            'end noona_post_auth;']) + """
,p_post_auth_process=>'noona_post_auth'""")
        assert 'NOONA_SESSION' in s
        self.write(rel, noona_auth_scheme(s))
        rel = 'shared_components/security/authorizations/administration_rights.sql'
        s = self.read(rel)
        self.schemes['admin'] = int(re.search(r"p_id=>wwv_flow_imp\.id\((\d+)\)", s).group(1))
        s = s.replace("--     SECURITY SCHEME: Administration Rights", "--     SECURITY SCHEME: NOONA - Tenant Admin")
        s = s.replace(""",p_name=>'Administration Rights'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return true;'
,p_error_message=>'Insufficient privileges, user is not an Administrator'""", """,p_name=>'NOONA - Tenant Admin'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_apex_pkg.is_tenant_admin = ''Y'';'
,p_error_message=>'هذه الصفحة لمسؤول المؤسسة فقط / Tenant administrators only'""")
        self.write(rel, s)
        for key, fname, name, fn, msg in [
            ('auth', 'noona_authenticated', 'NOONA - Authenticated', "return noona_apex_pkg.is_authenticated = 'Y';",
             'انتهت جلستك أو لا تملك جلسة نونا بلس صالحة؛ سجل الدخول مجدداً / No valid NOONA session'),
            ('tenant', 'noona_tenant_user', 'NOONA - Tenant User', "return noona_apex_pkg.is_tenant_user = 'Y';",
             'هذه الصفحة لمستخدمي المؤسسات / Tenant users only'),
            ('platform', 'noona_platform_admin', 'NOONA - Platform Admin', "return noona_apex_pkg.is_platform_admin = 'Y';",
             'هذه الصفحة لمسؤول المنصة فقط / Platform administrators only')]:
            self.add_scheme(fname, self.schemes[key], name, fn, msg)
        for fname, name, sql in SHARED_LOVS:
            self.add_lov(fname, name, sql)
        # شاشة الدخول: رسالة واضحة لغير المسجلين
        rel = 'pages/page_09999.sql'
        s = self.read(rel)
        m = re.search(r"wwv_flow_imp_page\.create_page_process\(\n p_id=>wwv_flow_imp\.id\(\d+\)\n,p_process_sequence=>10\n,p_process_point=>'AFTER_SUBMIT'", s)
        s = s[:m.start()] + f"""wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id({self.id()})
,p_validation_name=>'NOONA - User Enabled'
,p_validation_sequence=>10
,p_validation=>'return noona_apex_pkg.login_block_reason(:P9999_USERNAME);'
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
""" + s[m.start():]
        self.write(rel, s)

    def add_scheme(self, fname, sid, name, fn, msg):
        path = f'shared_components/security/authorizations/{fname}'
        self.write(path + '.sql', self.comp(path, f'SECURITY SCHEME: {name}', f"""wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id({sid})
,p_name=>'{q(name)}'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'{q(fn)}'
,p_error_message=>'{q(msg)}'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);"""))
        self.install_extra_shared.append(path)
        return sid

    def add_lov(self, fname, name, sql):
        lid = self.id()
        path = f'shared_components/user_interface/lovs/{fname}'
        self.write(path + '.sql', self.comp(path, name, f"""wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id({lid})
,p_lov_name=>'{name}'
,p_lov_query=>'{q(sql)}'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);"""))
        self.install_extra_shared.append(path)
        self.lovs[name] = lid
        return lid

    # ------------------------------------------------------------------ الهوية
    def add_branding(self):
        """ملفات الهوية (CSS + Cairo + الشعار) وصفحة الدخول بالعربية: تطبق عند finalize عبر tools/apex_brand.py"""
        self._branding = True

    # ------------------------------------------------------------------ الصفحات
    def page(self, pid, name, alias, title, scheme=None, protection='C', mode=None):
        p = Page(self, pid, name, alias, title, scheme, protection, mode)
        self.pages[pid] = p
        return p

    def nav_item(self, label, page, icon, seq, parent=None, scheme=None):
        nid = self.id()
        self.nav.append((nid, label, page, icon, seq, parent, scheme))
        return nid

    # ------------------------------------------------------------------ الحفظ
    def finalize(self):
        # الصفحة الرئيسية في القالب تُستبدل بالصفحات المولدة
        for pid, p in self.pages.items():
            self.write(f'pages/page_{pid:05d}.sql', self.comp(f'pages/page_{pid:05d}', f'PAGE: {pid:05d}', p.render()))
        # قائمة التنقل
        rel = 'shared_components/navigation/lists/navigation_menu.sql'
        s = self.read(rel)
        s = re.sub(r"wwv_flow_imp_shared\.create_list_item\(.*?\n\);\n", '', s, flags=re.S)
        items = ''
        for nid, label, page, icon, seq, parent, scheme in self.nav:
            target = f"f?p=&APP_ID.:{page}:&APP_SESSION.::&DEBUG.:::" if page is not None else ''
            items += f"""wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id({nid})
,p_list_item_display_sequence=>{seq}
,p_list_item_link_text=>'{q(label)}'
,p_list_item_link_target=>'{target}'
,p_list_item_icon=>'{icon}'"""
            if parent:
                items += f"\n,p_parent_list_item_id=>wwv_flow_imp.id({parent})"
            if scheme:
                items += f"\n,p_security_scheme=>wwv_flow_imp.id({scheme})"
            if page is not None:
                items += f"\n,p_list_item_current_type=>'TARGET_PAGE'"
            items += "\n);\n"
        i = s.rindex('wwv_flow_imp.component_end;')
        self.write(rel, s[:i] + items + s[i:])
        # install.sql
        inst = os.path.join(self.dir, 'install.sql')
        s = open(inst).read()
        anchor = "@@application/shared_components/security/authorizations/administration_rights.sql\n"
        s = s.replace(anchor, anchor + ''.join(f'@@application/{x}.sql\n' for x in self.install_extra_shared))
        anchor = "@@application/shared_components/files/icons_app_icon_512_png.sql\n"
        s = s.replace(anchor, anchor + ''.join(f'@@application/{x}.sql\n' for x in getattr(self, '_static_files', [])))
        s = re.sub(r"@@application/pages/page_0000[1-9]\.sql\n|@@application/pages/page_000[1-9]\d\.sql\n|@@application/pages/page_00[1-9]\d\d\.sql\n", '', s)
        s = s.replace("@@application/pages/page_00000.sql\n", "@@application/pages/page_00000.sql\n" +
                      ''.join(f'@@application/pages/page_{pid:05d}.sql\n' for pid in sorted(self.pages)))
        open(inst, 'w').write(s)
        if getattr(self, '_branding', False):
            from apex_brand import brand
            brand(self.dir)
        # حذف ملفات صفحات القالب غير المستخدمة
        for f in os.listdir(self.A + 'pages'):
            m = re.match(r'page_(\d+)\.sql', f)
            if m and int(m.group(1)) not in self.pages and int(m.group(1)) not in (0, 9999):
                os.remove(self.A + 'pages/' + f)


class Page:
    def __init__(self, app, pid, name, alias, title, scheme, protection, mode):
        self.app, self.pid, self.parts = app, pid, []
        s = f"""wwv_flow_imp_page.create_page(
 p_id=>{pid}
,p_name=>'{q(name)}'
,p_alias=>'{alias}'
,p_step_title=>'{q(title)}'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'"""
        if scheme:
            s += f"\n,p_required_role=>wwv_flow_imp.id({scheme})"
        s += f"\n,p_protection_level=>'{protection}'\n);\n"
        self.header = s
        self.items_after = []

    def render(self):
        return self.header + ''.join(self.parts)

    def onload(self, code):
        """JavaScript يعمل عند تحميل الصفحة (Execute when Page Loads)."""
        self.header = self.header.replace(",p_protection_level=>", f",p_javascript_code_onload=>{join(code)}\n,p_protection_level=>", 1)

    def add(self, text):
        self.parts.append(text)

    # ---------------------------------------------------------------- مناطق
    @staticmethod
    def _cond(condition):
        if not condition:
            return ''
        return (f"\n,p_plug_display_condition_type=>'EXPRESSION'\n,p_plug_display_when_condition=>'{q(condition)}'"
                "\n,p_plug_display_when_cond2=>'PLSQL'")

    def static(self, name, seq, hide_header=False, text=None, opts='#DEFAULT#', condition=None):
        rid = self.app.id()
        o = opts + (':t-Region--removeHeader js-removeLandmark' if hide_header else '')
        src = f"\n,p_plug_source=>{join(text)}" if text else ''
        self.add(f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'{o}'
,p_plug_template=>{T_STD}
,p_plug_display_sequence=>{seq}{src}{self._cond(condition)}
,p_attributes=>{attrs(expand_shortcuts='N', output_as='HTML', show_line_breaks='Y')}
);
""")
        return rid

    def dynamic(self, name, seq, code, hide_header=False, opts='#DEFAULT#:t-Region--scrollBody', condition=None):
        rid = self.app.id()
        o = opts + (':t-Region--removeHeader js-removeLandmark:t-Region--noUI' if hide_header else '')
        self.add(f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'{o}'
,p_plug_template=>{T_STD}
,p_plug_display_sequence=>{seq}{self._cond(condition)}
,p_function_body_language=>'PLSQL'
,p_plug_source=>{join(code)}
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
""")
        return rid

    def ir(self, name, seq, sql, columns, link=None, link_icon='fa-edit', rows=50, titled=False):
        """columns: [(ALIAS, label, opts)], opts: hidden, type NUMBER|DATE|STRING, html, link=(url, text)"""
        rid, wid, rpt = self.app.id(), self.app.id(), self.app.id()
        self.add(f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'{'#DEFAULT#:t-Region--scrollBody' if titled else '#DEFAULT#'}'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>{T_STD if titled else T_IRR}
,p_plug_display_sequence=>{seq}
,p_query_type=>'SQL'
,p_plug_source=>{join(sql)}
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'{q(name)}'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id({wid})
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'{'C' if link else 'N'}'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'""" + (f"""
,p_detail_link=>'{q(link)}'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa {link_icon}" title="فتح"></span>'""" if link else '') + f"""
,p_owner=>'NOONA'
,p_internal_uid=>{wid}
);
""")
        ident = iter('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
        shown = []
        for order, (alias, label, o) in enumerate(columns, start=1):
            cid = self.app.id()
            ctype = o.get('type', 'STRING')
            s = f"""wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id({cid})
,p_db_column_name=>'{alias}'
,p_display_order=>{order * 10}
,p_column_identifier=>'{next(ident)}'
,p_column_label=>'{q(label)}'
,p_column_type=>'{ctype}'"""
            if o.get('hidden'):
                s += "\n,p_display_text_as=>'HIDDEN'"
            elif o.get('html'):
                s += "\n,p_display_text_as=>'WITHOUT_MODIFICATION'"
            if o.get('link'):
                s += f"\n,p_column_link=>'{q(o['link'][0])}'\n,p_column_linktext=>'{q(o['link'][1])}'"
            if ctype == 'DATE' and o.get('format'):
                s += f"\n,p_format_mask=>'{o['format']}'"
            s += "\n,p_heading_alignment=>'CENTER'\n,p_use_as_row_header=>'N'\n);\n"
            self.add(s)
            if not o.get('hidden'):
                shown.append(alias)
        self.add(f"""wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id({rpt})
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'{rpt % 1000000}'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'{':'.join(shown)}'
);
""")
        return rid

    # ---------------------------------------------------------------- عناصر
    def _item(self, name, region, seq, prompt, display_as, extra='', required=False, attrs_=None, full=False):
        iid = self.app.id()
        # تخطيط بعمودين: كل عنصرين في صف، والعناصر العريضة (full) في صف مستقل
        if prompt is not None:
            col = getattr(self, '_col', {}).get(region, 0)
            self._col = getattr(self, '_col', {})
            if full or col == 0:
                self._col[region] = 0 if full else 1
            else:
                extra += "\n,p_begin_on_new_line=>'N'"
                self._col[region] = 0
        s = f"""wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id({iid})
,p_name=>'{name}'
,p_item_sequence=>{seq}
,p_item_plug_id=>wwv_flow_imp.id({region})"""
        if prompt is not None:
            s += f"\n,p_prompt=>'{q(prompt)}'"
        s += f"\n,p_display_as=>'{display_as}'{extra}"
        if prompt is not None:
            s += f"\n,p_field_template=>{T_REQ if required else T_LBL}\n,p_item_template_options=>'#DEFAULT#'"
        if required:
            # الإلزام يتحقق فقط عند أزرار نفس المنطقة (صفحات بعدة نماذج لا تتعارض)
            self._req = getattr(self, '_req', {})
            self._req.setdefault(region, []).append((name, iid))
        if attrs_:
            s += f"\n,p_attributes=>{attrs_}"
        self.add(s + "\n);\n")
        return iid

    def hidden(self, name, region, seq, protected=True):
        return self._item(name, region, seq, None, 'NATIVE_HIDDEN', "\n,p_protection_level=>'N'" if not protected else '',
                          attrs_=attrs(value_protected='Y' if protected else 'N'))

    def text(self, name, region, seq, prompt, required=False, maxlen=200, width=40):
        return self._item(name, region, seq, prompt, 'NATIVE_TEXT_FIELD', f"\n,p_cSize=>{width}\n,p_cMaxlength=>{maxlen}",
                          required, attrs(disabled='N', submit_when_enter_pressed='N', subtype='TEXT', trim_spaces='BOTH'))

    def number(self, name, region, seq, prompt, required=False):
        return self._item(name, region, seq, prompt, 'NATIVE_NUMBER_FIELD', "\n,p_cSize=>20", required,
                          attrs(number_alignment='left', virtual_keyboard='decimal'))

    def textarea(self, name, region, seq, prompt, required=False, rows=3):
        return self._item(name, region, seq, prompt, 'NATIVE_TEXTAREA', f"\n,p_cSize=>60\n,p_cMaxlength=>1000\n,p_cHeight=>{rows}",
                          required, attrs(auto_height='N', character_counter='Y', resizable='Y', trim_spaces='BOTH'), full=True)

    def select(self, name, region, seq, prompt, lov_name=None, lov_sql=None, required=False, null_text='- اختر -',
               submit=False, cascade=None):
        if lov_name:
            lov = f"\n,p_named_lov=>'{lov_name}'\n,p_lov=>'.'||wwv_flow_imp.id({self.app.lovs[lov_name]})||'.'"
        else:
            lov = f"\n,p_lov=>'{q(lov_sql)}'"
        lov += f"\n,p_lov_display_null=>'YES'\n,p_lov_null_text=>'{q(null_text)}'" if null_text else ''
        if cascade:     # قائمة تابعة: تتحدث عند تغير العنصر الأب
            lov += (f"\n,p_lov_cascade_parent_items=>'{cascade}'\n,p_ajax_items_to_submit=>'{cascade}'"
                    "\n,p_ajax_optimize_refresh=>'Y'")
        return self._item(name, region, seq, prompt, 'NATIVE_SELECT_LIST', lov + "\n,p_cHeight=>1\n,p_lov_display_extra=>'NO'",
                          required, attrs(page_action_on_selection='SUBMIT' if submit else 'NONE'))

    def date(self, name, region, seq, prompt, required=False):
        return self._item(name, region, seq, prompt, 'NATIVE_DATE_PICKER_APEX', "\n,p_cSize=>20\n,p_format_mask=>'YYYY-MM-DD'",
                          required, attrs(display_as='POPUP', max_date='NONE', min_date='NONE', multiple_months='N',
                                          show_time='N', use_defaults='Y'))

    def password(self, name, region, seq, prompt, required=False):
        return self._item(name, region, seq, prompt, 'NATIVE_PASSWORD', "\n,p_cSize=>30\n,p_cMaxlength=>100", required,
                          attrs(submit_when_enter_pressed='N'))

    def file(self, name, region, seq, prompt, file_types='image/png,image/jpeg,image/gif,image/webp', max_kb=512):
        """رفع ملف إلى APEX_APPLICATION_TEMP_FILES (يحذف بنهاية الطلب)؛ تقرأه العملية بالاسم المخزن في العنصر."""
        return self._item(name, region, seq, prompt, 'NATIVE_FILE', '', False,
                          attrs(storage_type='APEX_APPLICATION_TEMP_FILES', purge_file_at='REQUEST',
                                allow_multiple_files='N', file_types=file_types, display_as='DROPZONE_BLOCK',
                                dropzone_title='اسحب الشعار هنا أو اضغط للاختيار',
                                dropzone_description='PNG أو JPG أو GIF أو WEBP حتى 512 كيلوبايت',
                                max_file_size=max_kb), full=True)

    def yesno(self, name, region, seq, prompt):
        # "لا" أولاً: أي خيار حساس (افتراضي، اعتماد ذاتي، مسؤول) يتطلب اختياراً صريحاً
        return self.select(name, region, seq, prompt, lov_sql="STATIC2:لا;N,نعم;Y", null_text=None)

    def display(self, name, region, seq, prompt):
        return self._item(name, region, seq, prompt, 'NATIVE_DISPLAY_ONLY', '', False,
                          attrs(based_on='VALUE', format='PLAIN', send_on_page_submit='Y', show_line_breaks='Y'))

    # ---------------------------------------------------------------- أزرار ومعالجة
    def button(self, region, seq, name, label, hot=False, redirect=None, position='NEXT', condition=None):
        bid = self.app.id()
        s = f"""wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id({bid})
,p_button_sequence=>{seq}
,p_button_plug_id=>wwv_flow_imp.id({region})
,p_button_name=>'{name}'
,p_button_action=>'{'REDIRECT_URL' if redirect else 'SUBMIT'}'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>{T_BTN}"""
        if hot:
            s += "\n,p_button_is_hot=>'Y'"
        s += f"\n,p_button_image_alt=>'{q(label)}'\n,p_button_position=>'{position}'"
        if redirect:
            s += f"\n,p_button_redirect_url=>'{q(redirect)}'"
        else:
            for item, iid in getattr(self, '_req', {}).get(region, []):
                self.parts.append(f"""wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id({self.app.id()})
,p_validation_name=>'{item} required ({name})'
,p_validation_sequence=>{len(self.parts)}
,p_validation=>'{item}'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id({bid})
,p_associated_item=>wwv_flow_imp.id({iid})
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
""")
        if condition:
            s += f"\n,p_button_condition=>'{q(condition)}'\n,p_button_condition2=>'PLSQL'\n,p_button_condition_type=>'EXPRESSION'"
        self.add(s + "\n);\n")
        return bid

    def process(self, seq, point, name, code, when=None, when_button=None, success=None):
        pid = self.app.id()
        s = f"""wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id({pid})
,p_process_sequence=>{seq}
,p_process_point=>'{point}'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'{q(name)}'
,p_process_sql_clob=>{join(code)}
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'"""
        if when:
            s += f"\n,p_process_when=>'{q(when)}'\n,p_process_when_type=>'EXPRESSION'\n,p_process_when2=>'PLSQL'"
        if when_button:
            s += f"\n,p_process_when_button_id=>wwv_flow_imp.id({when_button})"
        if success:
            s += f"\n,p_process_success_message=>'{q(success)}'"
        self.add(s + f"\n,p_internal_uid=>{pid}\n);\n")
        return pid

    def branch(self, seq, url, when_button=None):
        bid = self.app.id()
        s = f"""wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id({bid})
,p_branch_action=>'{q(url)}'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>{seq}"""
        if when_button:
            s += f"\n,p_branch_when_button_id=>wwv_flow_imp.id({when_button})"
        self.add(s + "\n);\n")
        return bid
