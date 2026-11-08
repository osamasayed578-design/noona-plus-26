prompt --application/pages/page_00032
begin
--   Manifest
--     PAGE: 00032
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
 p_id=>32
,p_name=>'Unit Deals'
,p_alias=>'UNIT-DEALS'
,p_step_title=>'الحجوزات وعقود البيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000858)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000901)
,p_plug_name=>'التصفية'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000902)
,p_name=>'P32_STATUS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000901)
,p_prompt=>'حالة الحجوزات'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سارية;ACTIVE,منتهية;EXPIRED,محولة لعقود;CONVERTED,ملغاة;CANCELLED,مستردة;REFUNDED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000903)
,p_name=>'P32_CSTATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000901)
,p_prompt=>'حالة العقود'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المفتوحة;OPEN,مسودة;DRAFT,موقعة;SIGNED,موثقة;REGISTERED,جاهزة للتسليم;READY_FOR_HANDOVER,مسلمة;HANDED_OVER,تم الإفراغ;TITLE_TRANSFERRED,مفسوخة;TERMINATED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000904)
,p_plug_name=>'عقود البيع'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.contracts_html(:P32_CSTATUS, replace(apex_page.get_url(p_page => 33, p_items => ''P33_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000905)
,p_plug_name=>'الحجوزات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_res_pkg.reservations_html(:P32_STATUS);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000906)
,p_plug_name=>'تحويل حجز إلى عقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000907)
,p_name=>'P32_RES'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_prompt=>'الحجز الساري'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.doc_no || '' - '' || noona_re_pkg.unit_label(r.unit_id) || '' - '' || p.display_name_ar d, r.id r from re_reservation r join pty_party p on p.id = r.buyer_party_id where r.company_id = noona_res_pkg.company and r.status_code = ''ACTIVE'' order by r.id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000908)
,p_name=>'P32_PLAN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_prompt=>'خطة السداد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from re_payment_plan where company_id = noona_res_pkg.company and is_active = ''Y'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- دفعة واحدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000909)
,p_name=>'P32_HANDOVER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_prompt=>'التسليم المتوقع'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000910)
,p_name=>'P32_COMMISSION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_prompt=>'عمولة الوسيط %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000911)
,p_name=>'P32_ELIGIBLE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_prompt=>'تستحق عند تحصيل %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000912)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000906)
,p_button_name=>'CONVERT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء العقد من الحجز'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000913)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Convert'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_res_pkg.create_contract(json_object(''reservation'' value to_number(:P32_RES), ''plan'' value to_number(:P32_PLAN),',
'              ''handover'' value :P32_HANDOVER, ''commission'' value to_number(:P32_COMMISSION), ''eligible'' value to_number(:P32_ELIGIBLE)));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 33, p_items => ''P33_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000912)
,p_internal_uid=>91820273000000913
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000914)
,p_plug_name=>'إلغاء حجز'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000915)
,p_name=>'P32_CANCEL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000914)
,p_prompt=>'الحجز'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.doc_no || '' - '' || noona_re_pkg.unit_label(r.unit_id) || '' (عربون '' || r.deposit_amount || '')'' d, r.id r from re_reservation r where r.company_id = noona_res_pkg.company and r.status_code in (''ACTIVE'', ''EXPIRED'') order by r.id desc'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000916)
,p_name=>'P32_FORFEIT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000914)
,p_prompt=>'المبلغ المصادر من العربون'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000917)
,p_name=>'P32_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000914)
,p_prompt=>'السبب'
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
 p_id=>wwv_flow_imp.id(91820273000000918)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000914)
,p_button_name=>'CANCEL_RES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الحجز ورد العربون'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000919)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_res_pkg.cancel_reservation(:P32_CANCEL, :P32_REASON, nvl(to_number(:P32_FORFEIT), 0));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000918)
,p_process_success_message=>'تم إلغاء الحجز وتحرير الوحدة'
,p_internal_uid=>91820273000000919
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000920)
,p_branch_action=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
