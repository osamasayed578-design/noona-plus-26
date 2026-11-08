prompt --application/pages/page_00072
begin
--   Manifest
--     PAGE: 00072
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>72
,p_name=>'Tax Returns'
,p_alias=>'TAX-RETURNS'
,p_step_title=>'الإقرارات الضريبية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000746)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000777)
,p_plug_name=>'إقرار جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يحتسب الإقرار من السجل الضريبي الموحد لكل الوحدات (المبيعات ونقاط البيع والمشتريات والمستشفى والفنادق والمستخلصات وبيع الأصول). إقرار الاستقطاع يجمع شهادات الفترة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000778)
,p_name=>'P72_KIND'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000777)
,p_prompt=>'الضريبة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:ضريبة القيمة المضافة;VAT,ضريبة الاستقطاع;WHT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000779)
,p_name=>'P72_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000777)
,p_prompt=>'من'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820266000000780)
,p_name=>'P72_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000777)
,p_prompt=>'إلى'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000782)
,p_validation_name=>'P72_FROM required (CREATE)'
,p_validation_sequence=>4
,p_validation=>'P72_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000781)
,p_associated_item=>wwv_flow_imp.id(91820266000000779)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000783)
,p_validation_name=>'P72_TO required (CREATE)'
,p_validation_sequence=>5
,p_validation=>'P72_TO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000781)
,p_associated_item=>wwv_flow_imp.id(91820266000000780)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000781)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000777)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إعداد الإقرار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000784)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P72_KIND := nvl(:P72_KIND, ''VAT'');',
'    :P72_FROM := nvl(:P72_FROM, to_char(add_months(trunc(sysdate, ''Q''), -3), ''YYYY-MM-DD''));',
'    :P72_TO := nvl(:P72_TO, to_char(trunc(sysdate, ''Q'') - 1, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000784
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000785)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_loc_pkg.new_return(:P72_KIND, to_date(:P72_FROM, ''YYYY-MM-DD''), to_date(:P72_TO, ''YYYY-MM-DD''));',
'    commit;',
'    apex_util.redirect_url(apex_page.get_url(p_page => 73, p_items => ''P73_ID'', p_values => l_id));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000781)
,p_internal_uid=>91820266000000785
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000786)
,p_plug_name=>'الإقرارات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_loc_pkg.returns_html(replace(apex_page.get_url(p_page => 73, p_items => ''P73_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000787)
,p_branch_action=>'f?p=&APP_ID.:72:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
