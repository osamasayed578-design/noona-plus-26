prompt --application/pages/page_00088
begin
--   Manifest
--     PAGE: 00088
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
 p_id=>88
,p_name=>'Progress Claim'
,p_alias=>'CLAIM'
,p_step_title=>'المستخلص'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''prj.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000727)
,p_plug_name=>'المستخلص'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob := noona_prj_pkg.claim_json(:P88_ID); l_k varchar2(30); l_d varchar2(30);',
'begin',
'    select max(claim_kind), max(claim_direction) into l_k, l_d from prj_progress_claim where id = :P88_ID;',
'    if l_k is null then return ''<div class="nn-empty">المستخلص غير موجود</div>''; end if;',
'    return ''<div class="nn-prj-chips"><span>'' || apex_escape.html(noona_prj_pkg.kind_label(l_k)) || case when l_d = ''PAYABLE'' then '' - مقاول باطن'' else '' - للعميل'' end',
'        || ''</span><span>'' || apex_escape.html(json_value(l, ''$.no'')) || ''</span><span>'' || apex_escape.html(noona_prj_pkg.status_label(json_value(l, ''$.status''))) || ''</span></div>''',
'        || ''<script type="application/json" id="nnPrjClaimData">'' || replace(l, ''</'', ''<\/'') || ''</script><div id="nnPrjClaim"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000728)
,p_name=>'P88_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000727)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000729)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000730)
,p_name=>'P88_REASON'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_prompt=>'سبب الإلغاء'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000731)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_button_name=>'APPROVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد وترحيل'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.claim_status(:P88_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000732)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_button_name=>'CANCEL_CLAIM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء المستخلص'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.claim_status(:P88_ID) in (''DRAFT'', ''APPROVED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000733)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_button_name=>'PRINT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'طباعة الشهادة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:89:&SESSION.::&DEBUG.::P89_ID:&P88_ID.'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000734)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع للعقد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:87:&SESSION.::&DEBUG.:RP:P87_ID:&P88_CONTRACT.'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000735)
,p_name=>'P88_CONTRACT'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820273000000729)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000736)
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
,p_internal_uid=>91820273000000736
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000737)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Contract'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select max(contract_id) into :P88_CONTRACT from prj_progress_claim where id = :P88_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000737
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000738)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.approve_claim(:P88_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000731)
,p_process_success_message=>'تم اعتماد المستخلص وترحيل قيده وتسجيل الذمة'
,p_internal_uid=>91820273000000738
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000739)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.cancel_claim(:P88_ID, :P88_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000732)
,p_process_success_message=>'تم إلغاء المستخلص'
,p_internal_uid=>91820273000000739
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000740)
,p_branch_action=>'f?p=&APP_ID.:88:&SESSION.::&DEBUG.::P88_ID:&P88_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
