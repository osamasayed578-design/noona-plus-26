prompt --application/pages/page_00074
begin
--   Manifest
--     PAGE: 00074
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
 p_id=>74
,p_name=>'Tax Register'
,p_alias=>'TAX-REGISTER'
,p_step_title=>'السجل الضريبي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000747)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000820)
,p_plug_name=>'التصفية'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000821)
,p_name=>'P74_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000820)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820266000000822)
,p_name=>'P74_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000820)
,p_prompt=>'إلى'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
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
 p_id=>wwv_flow_imp.id(91820266000000823)
,p_name=>'P74_DIR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000820)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مخرجات (مبيعات);SALE,مدخلات (مشتريات);PURCHASE'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000824)
,p_name=>'P74_NATURE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000820)
,p_prompt=>'الطبيعة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:خاضعة بالنسبة الأساسية;STANDARD,نسبة صفرية;ZERO_RATED,صادرات;EXPORT,معفاة;EXEMPT,خارج النطاق;OUT_OF_SCOPE,احتساب عكسي;REVERSE_CHARGE,صحة/تعليم خاص للمواطنين;CITIZEN'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000825)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000820)
,p_button_name=>'GO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000826)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P74_FROM := nvl(:P74_FROM, to_char(trunc(sysdate, ''MM''), ''YYYY-MM-DD''));',
'    :P74_TO := nvl(:P74_TO, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000826
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000827)
,p_plug_name=>'المستندات الضريبية'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_loc_pkg.register_html(to_date(:P74_FROM, ''YYYY-MM-DD''), to_date(:P74_TO, ''YYYY-MM-DD''), :P74_DIR, :P74_NATURE);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
