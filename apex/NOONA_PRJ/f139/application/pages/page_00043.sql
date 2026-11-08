prompt --application/pages/page_00043
begin
--   Manifest
--     PAGE: 00043
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
 p_id=>43
,p_name=>'Leases'
,p_alias=>'LEASES'
,p_step_title=>'عقود الإيجار وقائمة الإيجارات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000859)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001093)
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
 p_id=>wwv_flow_imp.id(91820273000001094)
,p_name=>'P43_STATUS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000001093)
,p_prompt=>'حالة العقود'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المفتوحة;OPEN,سارية;ACTIVE,مسودة;DRAFT,بانتظار التجديد;RENEWAL_PENDING,مجددة;RENEWED,منتهية;EXPIRED,منهية;TERMINATED'
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
 p_id=>wwv_flow_imp.id(91820273000001095)
,p_name=>'P43_PROPERTY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000001093)
,p_prompt=>'العقار (قائمة الإيجارات)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.name_ar d, p.id r from re_property p where p.company_id = noona_res_pkg.company and p.status_code <> ''INACTIVE'' and exists (select 1 from re_unit u where u.property_id = p.id and u.usage_type in (''LEASE'', ''MIXED'')) order by p.code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- كل العقارات -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001096)
,p_plug_name=>'العقود'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.leases_html(:P43_STATUS, replace(apex_page.get_url(p_page => 42, p_items => ''P42_ID'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000001097)
,p_plug_name=>'قائمة الإيجارات (Rent Roll)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:nn-print-area'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prp_pkg.rent_roll_html(:P43_PROPERTY);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
