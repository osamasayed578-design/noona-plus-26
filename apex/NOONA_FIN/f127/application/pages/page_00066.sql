prompt --application/pages/page_00066
begin
--   Manifest
--     PAGE: 00066
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
 p_id=>66
,p_name=>'Asset Reports'
,p_alias=>'ASSET-REPORTS'
,p_step_title=>'تقارير الأصول الثابتة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000529)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000693)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000694)
,p_name=>'P66_REPORT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_prompt=>'التقرير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سجل الأصول;REGISTER,حركة الأصول (التكلفة والمجمع) ومطابقة الأستاذ;ROLL,الاستبعادات وأرباحها وخسائرها;DISPOSALS,الأصول المستبعدة;DISPOSED'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000695)
,p_name=>'P66_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_prompt=>'من'
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
 p_id=>wwv_flow_imp.id(91820266000000696)
,p_name=>'P66_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_prompt=>'إلى'
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
 p_id=>wwv_flow_imp.id(91820266000000697)
,p_name=>'P66_CAT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_prompt=>'الفئة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from fa_category where company_id = noona_fa_pkg.company and is_active = ''Y'' order by code'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000698)
,p_name=>'P66_BRANCH'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_prompt=>'الفرع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from org_branch where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الكل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000699)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000693)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000700)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P66_REPORT := nvl(:P66_REPORT, ''REGISTER'');',
'    :P66_FROM := nvl(:P66_FROM, to_char(trunc(sysdate, ''YYYY''), ''YYYY-MM-DD''));',
'    :P66_TO := nvl(:P66_TO, to_char(sysdate, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000700
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000701)
,p_plug_name=>'التقرير'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_f date := to_date(:P66_FROM, ''YYYY-MM-DD''); l_t date := to_date(:P66_TO, ''YYYY-MM-DD'');',
'begin',
'    return case :P66_REPORT',
'        when ''REGISTER'' then noona_fa_pkg.register_html(:P66_CAT, :P66_BRANCH, ''ACTIVE'', replace(apex_page.get_url(p_page => 61, p_items => ''P61_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''))',
'        when ''DISPOSED'' then noona_fa_pkg.register_html(:P66_CAT, :P66_BRANCH, ''DISPOSED'', replace(apex_page.get_url(p_page => 61, p_items => ''P61_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''))',
'        when ''ROLL'' then noona_fa_pkg.rollforward_html(l_f, l_t)',
'        when ''DISPOSALS'' then noona_fa_pkg.disposals_html(l_f, l_t)',
'    end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000702)
,p_branch_action=>'f?p=&APP_ID.:66:&SESSION.::&DEBUG.:66:P66_REPORT,P66_FROM,P66_TO,P66_CAT,P66_BRANCH:&P66_REPORT.,&P66_FROM.,&P66_TO.,&P66_CAT.,&P66_BRANCH.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
