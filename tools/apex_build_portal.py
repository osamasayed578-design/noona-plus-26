# يبني تعديلات NOONA_PORTAL (التطبيق 119) فوق تصدير APEX الأصلي: الأمان، الصفحات، الهوية (CSS + Cairo)
# الاستخدام: انسخ التصدير الأصلي إلى apex/NOONA_PORTAL/f119 ثم: python3 tools/apex_build_portal.py
import os, re
os.chdir('/home/user/noona-plus/apex/NOONA_PORTAL/f119')
A='application/'
APP=119
B=91820261000000000           # قاعدة المعرفات الجديدة لهذا التطبيق
def ID(n): return B+n
T_STD=4072358936313175081     # Region: Standard
T_HERO=2674017834225413037
T_ROW=2538654340625403440     # Report: Standard
T_BTN=4072362960822175091     # Button: Text
T_LBL=1609121967514267634     # Label: Optional
S_AUTH, S_TENANT, S_PLATFORM = ID(101), ID(102), ID(103)
L_COMPANIES=ID(201)

def q(s): return s.replace("'", "''")
def join(lines):
    return "wwv_flow_string.join(wwv_flow_t_varchar2(\n" + ",\n".join("'"+q(l)+"'" for l in lines) + "))"
HDR=f"""wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>{APP}
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);"""
def comp(prompt, manifest, body):
    return f"prompt --application/{prompt}\nbegin\n--   Manifest\n--     {manifest}\n--   Manifest End\n{HDR}\n{body}\nwwv_flow_imp.component_end;\nend;\n/\n"
def edit(p, old, new):
    s=open(p,encoding='utf-8').read(); assert s.count(old)==1,(p,old); open(p,'w',encoding='utf-8').write(s.replace(old,new))
def write(p, s):
    os.makedirs(os.path.dirname(p), exist_ok=True); open(p,'w',encoding='utf-8').write(s)
STATIC_ATTR="""wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob"""

# ---------------------------------------------------------------- 1) الأمان المشترك (نفس NOONA_MASTER)
p=A+'create_application.sql'
edit(p,",p_authentication_id=>wwv_flow_imp.id(17753165707442907)",
f""",p_authentication_id=>wwv_flow_imp.id(17753165707442907)
,p_security_scheme=>wwv_flow_imp.id({S_AUTH})
,p_vpd=>'noona_apex_pkg.init_request(p_username => :APP_USER, p_apex_session_id => :APP_SESSION);'
,p_vpd_teardown_code=>'noona_apex_pkg.cleanup_request;'
,p_error_handling_function=>'noona_owner.noona_apex_error'""")

p=A+'shared_components/security/authentications/oracle_apex_accounts.sql'
edit(p,"--     AUTHENTICATION: Oracle APEX Accounts","--     AUTHENTICATION: NOONA Auth")
edit(p,""",p_name=>'Oracle APEX Accounts'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'""",""",p_name=>'NOONA Auth'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'
,p_cookie_name=>'NOONA_SESSION'
,p_plsql_code=>"""+join([
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
'end noona_post_auth;'])+"""
,p_post_auth_process=>'noona_post_auth'""")

p=A+'shared_components/security/authorizations/administration_rights.sql'
edit(p,"--     SECURITY SCHEME: Administration Rights","--     SECURITY SCHEME: NOONA - Tenant Admin")
edit(p,""",p_name=>'Administration Rights'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return true;'
,p_error_message=>'Insufficient privileges, user is not an Administrator'""",""",p_name=>'NOONA - Tenant Admin'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return noona_apex_pkg.is_tenant_admin = ''Y'';'
,p_error_message=>'هذه الصفحة لمسؤول المؤسسة فقط / Tenant administrators only'""")

new_install=[]
for fname, sid, name, fn, msg in [
  ('noona_authenticated', S_AUTH, 'NOONA - Authenticated', "return noona_apex_pkg.is_authenticated = 'Y';",
   'انتهت جلستك أو لا تملك جلسة نونا بلس صالحة؛ سجل الدخول مجدداً / No valid NOONA session'),
  ('noona_tenant_user', S_TENANT, 'NOONA - Tenant User', "return noona_apex_pkg.is_tenant_user = 'Y';",
   'هذه الصفحة لمستخدمي المؤسسات / Tenant users only'),
  ('noona_platform_admin', S_PLATFORM, 'NOONA - Platform Admin', "return noona_apex_pkg.is_platform_admin = 'Y';",
   'هذه الصفحة لمسؤول المنصة فقط / Platform administrators only')]:
    path=f'shared_components/security/authorizations/{fname}'
    write(A+path+'.sql', comp(path, f'SECURITY SCHEME: {name}', f"""wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id({sid})
,p_name=>'{name}'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'{q(fn)}'
,p_error_message=>'{q(msg)}'
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);"""))
    new_install.append(path)

LANG="sys_context('NOONA_CTX', 'LANGUAGE')"
for fname, lid, name, sql in [
 ('noona_companies', ID(201), 'NOONA_COMPANIES', f"select case {LANG} when 'en' then nvl(legal_name_en, legal_name_ar) else nvl(trade_name_ar, legal_name_ar) end as d, id as r from org_company where status_code not in ('CLOSED', 'ARCHIVED') order by 1"),
 ('noona_branches', ID(202), 'NOONA_BRANCHES', f"select case {LANG} when 'en' then nvl(name_en, name_ar) else name_ar end as d, id as r from org_branch where status_code = 'ACTIVE' and company_id = to_number(sys_context('NOONA_CTX', 'COMPANY_ID')) order by is_head_office desc, 1"),
 ('noona_currencies', ID(203), 'NOONA_CURRENCIES', f"select currency_code || ' - ' || case {LANG} when 'en' then name_en else name_ar end as d, currency_code as r from ref_currency where is_active = 'Y' order by currency_code"),
 ('noona_countries', ID(204), 'NOONA_COUNTRIES', f"select case {LANG} when 'en' then name_en else name_ar end as d, country_code as r from ref_country where is_active = 'Y' order by sort_order nulls last, 1")]:
    path=f'shared_components/user_interface/lovs/{fname}'
    write(A+path+'.sql', comp(path, name, f"""wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id({lid})
,p_lov_name=>'{name}'
,p_lov_query=>'{q(sql)}'
,p_source_type=>'LEGACY_SQL'
,p_location=>'LOCAL'
);"""))
    new_install.append(path)

# شاشة الدخول: رسالة واضحة لغير المسجلين
p=A+'pages/page_09999.sql'
anchor="wwv_flow_imp_page.create_page_process(\n p_id=>wwv_flow_imp.id(17763337713443034)"
edit(p, anchor, f"""wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id({ID(301)})
,p_validation_name=>'NOONA - User Enabled'
,p_validation_sequence=>10
,p_validation=>'return noona_apex_pkg.login_block_reason(:P9999_USERNAME);'
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
);
"""+anchor)

# ---------------------------------------------------------------- 2) مكونات الصفحات
def report_region(rid, name, seq, sql_lines, cols, no_data, rows=15, extra=''):
    out=f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_plug_template=>{T_STD}
,p_plug_display_sequence=>{seq}
,p_query_type=>'SQL'
,p_plug_source=>{join(sql_lines)}
,p_plug_source_type=>'NATIVE_SQL_REPORT'{extra}
,p_plug_query_num_rows=>{rows}
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_plug_query_row_template=>{T_ROW}
,p_plug_query_show_nulls_as=>'-'
,p_plug_query_no_data_found=>'{q(no_data)}'
,p_plug_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
"""
    for i,(cid, alias, heading, opts) in enumerate(cols, start=1):
        o=f"""wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id({cid})
,p_query_column_id=>{i}
,p_column_alias=>'{alias}'
,p_column_display_sequence=>{i}
,p_column_heading=>'{q(heading)}'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'"""
        if opts.get('hidden'): o+="\n,p_hidden_column=>'Y'"
        if opts.get('html'): o+="\n,p_display_as=>'WITHOUT_MODIFICATION'"
        if opts.get('link'): o+=f"\n,p_column_link=>'{q(opts['link'])}'\n,p_column_linktext=>'{q(opts['linktext'])}'"
        out+=o+"\n);\n"
    return out

def static_region(rid, name, seq):
    return f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>{T_STD}
,p_plug_display_sequence=>{seq}
,p_attributes=>{STATIC_ATTR}
);
"""
def button(bid, region, seq, name, label, hot=False, redirect=None):
    s=f"""wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id({bid})
,p_button_sequence=>{seq}
,p_button_plug_id=>wwv_flow_imp.id({region})
,p_button_name=>'{name}'
,p_button_action=>'{'REDIRECT_URL' if redirect else 'SUBMIT'}'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>{T_BTN}"""
    if hot: s+="\n,p_button_is_hot=>'Y'"
    s+=f"\n,p_button_image_alt=>'{q(label)}'\n,p_button_position=>'NEXT'"
    if redirect: s+=f"\n,p_button_redirect_url=>'{q(redirect)}'"
    return s+"\n);\n"
def plsql_process(pid, seq, point, name, code, when=None, when_button=None, success=None):
    s=f"""wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id({pid})
,p_process_sequence=>{seq}
,p_process_point=>'{point}'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'{q(name)}'
,p_process_sql_clob=>'{q(code)}'
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'"""
    if when: s+=f"\n,p_process_when=>'{q(when)}'\n,p_process_when_type=>'EXPRESSION'\n,p_process_when2=>'PLSQL'"
    if when_button: s+=f"\n,p_process_when_button_id=>wwv_flow_imp.id({when_button})"
    if success: s+=f"\n,p_process_success_message=>'{q(success)}'"
    return s+f"\n,p_internal_uid=>{pid}\n);\n"
def branch_home(bid, seq=10):
    return f"""wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id({bid})
,p_branch_name=>'Go Home'
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>{seq}
);
"""


def dyn_region(rid, name, seq, code_lines, opts='#DEFAULT#:t-Region--scrollBody', hide_header=False):
    o = opts + (':t-Region--removeHeader js-removeLandmark:t-Region--noUI' if hide_header else '')
    return f"""wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id({rid})
,p_plug_name=>'{q(name)}'
,p_region_template_options=>'{o}'
,p_plug_template=>{T_STD}
,p_plug_display_sequence=>{seq}
,p_function_body_language=>'PLSQL'
,p_plug_source=>{join(code_lines)}
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
"""

def static_file(fid, fname, mime, path):
    data = open(path, 'rb').read().hex().upper()
    chunks = [data[i:i+200] for i in range(0, len(data), 200)]
    body = "wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;\n"
    body += ''.join(f"wwv_flow_imp.g_varchar2_table({i}) := '{c}';\n" for i, c in enumerate(chunks, 1))
    body += f"""wwv_flow_imp_shared.create_app_static_file(
 p_id=>wwv_flow_imp.id({fid})
,p_file_name=>'{fname}'
,p_mime_type=>'{mime}'
,p_file_charset=>'utf-8'
,p_file_content => wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);"""
    return body

# ---------------------------------------------------------------- 3) الصفحة الرئيسية
p=A+'pages/page_00001.sql'
edit(p,"""wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'NOONA Portal'""","""wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'نونا بلس - الرئيسية'""")
hero_start = open(p,encoding='utf-8').read()
_h = hero_start.index("wwv_flow_imp_page.create_page_plug(\n p_id=>wwv_flow_imp.id(17766428243443046)")
_e = hero_start.index(");\n", _h) + 3
open(p,'w',encoding='utf-8').write(hero_start[:_h] + hero_start[_e:])
home = dyn_region(ID(1001), 'لوحة اليوم', 20, ['return noona_ui_pkg.home_summary(p_session => :APP_SESSION);'], hide_header=True)
home += dyn_region(ID(1002), 'تطبيقاتي', 30, [
  'declare',
  '    l_aliases varchar2(4000);',
  'begin',
  '    select listagg(alias, \',\') within group (order by alias) into l_aliases from apex_applications;',
  '    return noona_ui_pkg.app_cards(p_session => :APP_SESSION, p_existing_aliases => l_aliases);',
  'end;'])
home += dyn_region(ID(1003), 'مهامي', 40, ['return noona_ui_pkg.task_cards(p_session => :APP_SESSION);'])
home += dyn_region(ID(1004), 'الإشعارات', 50, ['return noona_ui_pkg.notification_list(p_session => :APP_SESSION);'])
home += button(ID(1061),ID(1004),10,'MARK_ALL_READ','تعليم الكل كمقروء')
home += plsql_process(ID(1071),10,'AFTER_SUBMIT','Mark All Read','noona_portal_pkg.mark_all_read;',
                      when_button=ID(1061), success='تم تعليم كل الإشعارات كمقروءة')
s=open(p,encoding='utf-8').read()
i=s.rindex('wwv_flow_imp.component_end;')
open(p,'w',encoding='utf-8').write(s[:i]+home+s[i:])

# ---------------------------------------------------------------- 4) صفحة المهمة TASK
P2=f"""wwv_flow_imp_page.create_page(
 p_id=>2
,p_name=>'Task'
,p_alias=>'TASK'
,p_step_title=>'نونا بلس - المهمة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id({S_TENANT})
,p_protection_level=>'N'
);
"""
P2+=dyn_region(ID(2001),'تفاصيل المهمة',10,['return noona_ui_pkg.task_header(p_task_id => :P2_TASK_ID);'])
P2+=static_region(ID(2002),'الإجراء',20)
P2+=dyn_region(ID(2003),'سجل المسار',30,['return noona_ui_pkg.task_timeline(p_task_id => :P2_TASK_ID);'])
P2+=button(ID(2041),ID(2002),10,'APPROVE','اعتماد',hot=True)
P2+=button(ID(2042),ID(2002),20,'REJECT','رفض')
P2+=button(ID(2043),ID(2002),30,'RETURN','إرجاع')
P2+=button(ID(2044),ID(2002),40,'REQUEST_INFO','طلب معلومات')
P2+=button(ID(2045),ID(2002),50,'BACK','رجوع',redirect='f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::')
P2+=branch_home(ID(2051))
P2+=f"""wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id({ID(2061)})
,p_name=>'P2_TASK_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id({ID(2002)})
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id({ID(2062)})
,p_name=>'P2_COMMENTS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id({ID(2002)})
,p_prompt=>'الملاحظات (إلزامية للرفض والإرجاع وطلب المعلومات)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>{T_LBL}
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
"""
P2+=plsql_process(ID(2071),10,'AFTER_SUBMIT','Task Action',
  'noona_portal_pkg.task_action(p_task_id => :P2_TASK_ID, p_action => :REQUEST, p_comments => :P2_COMMENTS);',
  when=":REQUEST in ('APPROVE', 'REJECT', 'RETURN', 'REQUEST_INFO')", success='تم تنفيذ الإجراء على المهمة')
write(A+'pages/page_00002.sql', comp('pages/page_00002','PAGE: 00002',P2))

# ---------------------------------------------------------------- 5) صفحة تبديل الشركة
P3=f"""wwv_flow_imp_page.create_page(
 p_id=>3
,p_name=>'Switch Company'
,p_alias=>'COMPANY'
,p_step_title=>'نونا بلس - تبديل الشركة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id({S_TENANT})
,p_protection_level=>'C'
);
"""
P3+=static_region(ID(3001),'تبديل الشركة',10)
P3+=button(ID(3011),ID(3001),10,'SWITCH','تبديل',hot=True)
P3+=button(ID(3012),ID(3001),20,'CANCEL','إلغاء',redirect='f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::')
P3+=branch_home(ID(3021))
P3+=f"""wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id({ID(3031)})
,p_name=>'P3_COMPANY_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id({ID(3001)})
,p_prompt=>'الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COMPANIES'
,p_lov=>'.'||wwv_flow_imp.id({L_COMPANIES})||'.'
,p_cHeight=>1
,p_field_template=>{T_LBL}
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
"""
P3+=plsql_process(ID(3041),10,'BEFORE_HEADER','Current Company',
  ":P3_COMPANY_ID := sys_context('NOONA_CTX', 'COMPANY_ID');")
P3+=plsql_process(ID(3042),10,'AFTER_SUBMIT','Switch Company',
  'noona_apex_pkg.switch_company(p_company_id => :P3_COMPANY_ID);', when_button=ID(3011), success='تم تبديل الشركة')
write(A+'pages/page_00003.sql', comp('pages/page_00003','PAGE: 00003',P3))

# ---------------------------------------------------------------- 6) قائمة التنقل
p=A+'shared_components/navigation/lists/navigation_menu.sql'
edit(p,",p_list_item_link_text=>'Home'",",p_list_item_link_text=>'الرئيسية'")
s=open(p,encoding='utf-8').read(); i=s.rindex('wwv_flow_imp.component_end;')
s=s[:i]+f"""wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id({ID(4001)})
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'تبديل الشركة'
,p_list_item_link_target=>'f?p=&APP_ID.:3:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-exchange'
,p_list_item_current_type=>'TARGET_PAGE'
);
"""+s[i:]
open(p,'w',encoding='utf-8').write(s)

# ---------------------------------------------------------------- 7) install.sql
p='install.sql'; s=open(p).read()
old="@@application/shared_components/security/authorizations/administration_rights.sql\n"
s=s.replace(old, old+''.join(f'@@application/{x}.sql\n' for x in new_install))
s=s.replace("@@application/pages/page_00001.sql\n","@@application/pages/page_00001.sql\n@@application/pages/page_00002.sql\n@@application/pages/page_00003.sql\n")
open(p,'w').write(s)
print('done')

# ---------------------------------------------------------------- 8) هوية NOONA: CSS وخط Cairo
STATIC='/home/user/noona-plus/apex/shared/static/'
files=[]
for k,(fname,mime) in enumerate([('noona.css','text/css'),('cairo-arabic.woff2','font/woff2'),('cairo-latin.woff2','font/woff2')], start=1):
    path=f'shared_components/files/noona_{k}'
    write(A+path+'.sql', comp(path, f'APP STATIC FILES: {APP}', static_file(ID(5000+k), fname, mime, STATIC+fname)))
    files.append(path)
p='install.sql'; s2=open(p).read()
old="@@application/shared_components/files/icons_app_icon_512_png.sql\n"
s2=s2.replace(old, old+''.join(f'@@application/{x}.sql\n' for x in files)); open(p,'w').write(s2)
# رقم إصدار الملفات الثابتة يتغير مع محتواها (يكسر ذاكرة المتصفح بعد كل تعديل للتصميم)
import zlib
_ver = 1 + zlib.crc32(b''.join(open(STATIC+f,'rb').read() for f in ('noona.css','cairo-arabic.woff2','cairo-latin.woff2'))) % 900000
_ca = open(A+'create_application.sql',encoding='utf-8').read()
open(A+'create_application.sql','w',encoding='utf-8').write(re.sub(r",p_files_version=>\d+", f",p_files_version=>{_ver}", _ca))
edit(A+'user_interfaces.sql', ",p_nav_bar_template_options=>'#DEFAULT#'", ",p_nav_bar_template_options=>'#DEFAULT#'\n,p_css_file_urls=>'#APP_FILES#noona.css'")
print('ui done')
