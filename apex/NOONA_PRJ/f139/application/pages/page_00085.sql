prompt --application/pages/page_00085
begin
--   Manifest
--     PAGE: 00085
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>85
,p_name=>'Project Budget'
,p_alias=>'PROJECT-BUDGET'
,p_step_title=>'موازنة المشروع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''prj.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000647)
,p_plug_name=>'الموازنة مقابل الفعلي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_pkg.budget_html(:P85_PROJECT);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000648)
,p_plug_name=>'الموازنة حسب بند العمل ونوع التكلفة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_w clob; l_u clob;',
'begin',
'    select json_arrayagg(json_object(''v'' value id, ''n'' value code || '' - '' || name_ar) order by code returning clob) into l_w',
'      from prj_wbs where project_id = :P85_PROJECT and status_code <> ''CANCELLED'';',
'    return ''<script type="application/json" id="nnPrjBudgetData">'' || noona_prj_pkg.budget_json(:P85_PROJECT) || ''</script>''',
'        || ''<script type="application/json" id="nnPrjLists">'' || replace(''{"wbs":'' || nvl(l_w, ''[]'') || ''}'', ''</'', ''<\/'') || ''</script>''',
'        || ''<div id="nnPrjBudget" data-project="'' || :P85_PROJECT || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000649)
,p_name=>'P85_PROJECT'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000648)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000650)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRJ'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c clob;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'begin',
'    case apex_application.g_x01',
'        when ''BOQ'' then l_c := ''{"n":'' || noona_prj_pkg.save_boq(n(apex_application.g_x02), apex_application.g_clob_01) || ''}'';',
'        when ''VO'' then l_c := ''{"id":'' || noona_prj_pkg.save_variation(apex_application.g_clob_01) || ''}'';',
'        when ''BUDGET'' then l_c := ''{"id":'' || noona_prj_pkg.save_budget(n(apex_application.g_x02), apex_application.g_clob_01,',
'                                                                       apex_application.g_x03) || ''}'';',
'        when ''CLAIM'' then noona_prj_pkg.save_claim(apex_application.g_clob_01);',
'            l_c := noona_prj_pkg.claim_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''REV'' then noona_prj_pkg.reverse_cost(n(apex_application.g_x02), apex_application.g_x03);',
'        else raise_application_error(-20500, ''NOONA-PRJ-099: عملية غير معروفة'');',
'    end case;',
'    htp.prn(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000650
);

wwv_flow_imp.component_end;
end;
/
