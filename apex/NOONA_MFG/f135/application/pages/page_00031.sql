prompt --application/pages/page_00031
begin
--   Manifest
--     PAGE: 00031
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>31
,p_name=>'Production Order'
,p_alias=>'ORDER'
,p_step_title=>'أمر إنتاج'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''mfg.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000142)
,p_plug_name=>'الأمر'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>1
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000143)
,p_name=>'P31_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820270000000142)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000144)
,p_plug_name=>'منضدة أمر الإنتاج'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    function js(p clob) return clob is begin return replace(p, ''</'', ''<\/''); end;',
'begin',
'    return ''<script type="application/json" id="nnMfgData">'' || js(noona_mfg_pkg.order_json(:P31_ID)) || ''</script>''',
'        || ''<script type="application/json" id="nnMfgLists">'' || js(noona_mfg_pkg.lists_json(''products,whs,ccs'')) || ''</script>''',
'        || ''<div id="nnMo" class="nn-doc nn-td nn-mfg" data-co="''',
'        || apex_escape.html_attribute(noona_apex_pkg.company_name) || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000145)
,p_plug_name=>'طباعة'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P31_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000146)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000145)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بطاقة التشغيل'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32:P32_ID,P32_KIND:&P31_ID.,JOB'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000147)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820270000000145)
,p_button_name=>'COST'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بطاقة التكلفة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32:P32_ID,P32_KIND:&P31_ID.,COST'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000148)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SAVE_MO'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    l_id := noona_mfg_pkg.save_order(apex_application.g_clob_01);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    if l_id is not null then apex_json.write(''url'', apex_page.get_url(p_page => 31, p_clear_cache => ''31'', p_items => ''P31_ID'', p_values => l_id)); end if;',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000148
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000149)
,p_process_sequence=>2
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ACT'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    case apex_application.g_x01',
'        when ''APPROVE'' then noona_mfg_pkg.approve_order(apex_application.g_x02);',
'        when ''RELEASE'' then noona_mfg_pkg.release_order(apex_application.g_x02);',
'        when ''HOLD'' then noona_mfg_pkg.hold_order(apex_application.g_x02, apex_application.g_x03);',
'        when ''RESUME'' then noona_mfg_pkg.resume_order(apex_application.g_x02);',
'        when ''CANCEL'' then noona_mfg_pkg.cancel_order(apex_application.g_x02, apex_application.g_x03);',
'        when ''COMPLETE'' then noona_mfg_pkg.complete_order(apex_application.g_x02);',
'        when ''CLOSE'' then l_id := noona_mfg_pkg.close_order(apex_application.g_x02, trunc(sysdate));',
'    end case;',
'    l_id := null;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000149
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000150)
,p_process_sequence=>3
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'POST'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    case apex_application.g_x01',
'        when ''ISSUE'' then l_id := noona_mfg_pkg.issue_materials(apex_application.g_clob_01);',
'        when ''RETURN'' then l_id := noona_mfg_pkg.return_materials(apex_application.g_clob_01);',
'        when ''OP'' then l_id := noona_mfg_pkg.report_operation(apex_application.g_clob_01);',
'        when ''OUTPUT'' then l_id := noona_mfg_pkg.report_output(apex_application.g_clob_01);',
'        when ''INSPECT'' then l_id := noona_mfg_pkg.inspect_output(apex_application.g_clob_01);',
'    end case;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000150
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000151)
,p_process_sequence=>4
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'SUBST'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_id number;',
'    l_c clob;',
'begin',
'    noona_mfg_pkg.substitute_material(apex_application.g_x01, apex_application.g_x02);',
'    apex_json.open_object;',
'    apex_json.write(''ok'', true);',
'    apex_json.write(''id'', l_id);',
'    apex_json.close_object;',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''ok'', false);',
'    apex_json.write(''msg'', nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^['' || chr(10) || '']+'')), sqlerrm));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000151
);

wwv_flow_imp.component_end;
end;
/
