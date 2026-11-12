prompt --application/pages/page_00041
begin
--   Manifest
--     PAGE: 00041
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>151
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>41
,p_name=>'Screens Guide'
,p_alias=>'GUIDE'
,p_step_title=>'دليل الشاشات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820310000000012)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820310000000220)
,p_plug_name=>'دليل الأنظمة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h clob;',
'begin',
'  for a in (select application_id, application_name from apex_applications where alias like ''NOONA%'' order by application_id) loop',
'    l_h := l_h || ''<h3>'' || apex_escape.html(a.application_name) || ''</h3><div class="nn-dst-actions">'';',
'    for g in (select page_id, nvl(page_title, page_name) t from apex_application_pages where application_id = a.application_id',
'               and page_id not in (0, 9999) and nvl(page_title, page_name) is not null order by page_id) loop',
'      l_h := l_h || ''<a class="nn-dst-btn" href="'' || apex_page.get_url(p_page => 40, p_items => ''P40_APP,P40_PAGE'', p_values => a.application_id || '','' || g.page_id)',
'          || ''">'' || apex_escape.html(g.t) || ''</a>'';',
'    end loop;',
'    l_h := l_h || ''</div>'';',
'  end loop;',
'  return l_h;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
