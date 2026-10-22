prompt --application/pages/page_00005
begin
--   Manifest
--     PAGE: 00005
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>125
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>5
,p_name=>'Platform Audit'
,p_alias=>'AUDIT'
,p_step_title=>'سجل تدقيق المنصة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820265000000003)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000177)
,p_plug_name=>'سلامة سجل المنصة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_bad number := noona_platform_admin_pkg.verify_tenant_chain(null);',
'begin',
'    return case when l_bad is null then ''<div class="nn-chain is-ok"><span class="fa fa-shield" aria-hidden="true"></span>''',
'        || ''<div><b>سجل تدقيق المنصة سليم</b><small>سلسلة التجزئة مطابقة</small></div></div>''',
'        else ''<div class="nn-chain is-bad"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span>''',
'        || ''<div><b>انقطاع في سلسلة التدقيق</b><small>أول حدث غير مطابق رقم '' || l_bad || ''</small></div></div>'' end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820265000000178)
,p_plug_name=>'أحداث المنصة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_platform_admin_pkg.audit_html(null, 200);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
