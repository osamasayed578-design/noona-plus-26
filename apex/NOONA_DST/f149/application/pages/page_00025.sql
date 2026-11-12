prompt --application/pages/page_00025
begin
--   Manifest
--     PAGE: 00025
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>149
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>25
,p_name=>'Order'
,p_alias=>'ORDER'
,p_step_title=>'أمر توريد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820300000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000305)
,p_plug_name=>'الأمر'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000306)
,p_name=>'P25_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820300000000305)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000307)
,p_plug_name=>'الأمر'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_h clob;',
'begin',
'  for o in (select * from dst_order where id = :P25_ID and company_id = noona_dst_pkg.company) loop',
'    l_h := ''<p><b>'' || o.doc_no || ''</b> · '' || noona_dst_pkg.badge(o.status_code) || '' · '' || apex_escape.html(noona_dst_pkg.shop_label(o.shop_id))',
'        || '' · التسليم '' || to_char(o.delivery_date, ''YYYY-MM-DD'') || '' · المندوب '' || apex_escape.html(noona_dst_pkg.rep_label(o.rep_id)) || ''</p>''',
'        || ''<table class="nn-table"><thead><tr><th>الصنف</th><th>الكمية</th><th>السعر</th><th>المبلغ</th></tr></thead><tbody>'';',
'    for l in (select l.*, i.name_ar from dst_order_line l join inv_item i on i.id = l.item_id where l.order_id = o.id order by l.id) loop',
'      l_h := l_h || ''<tr><td>'' || apex_escape.html(l.name_ar) || ''</td><td>'' || l.quantity || ''</td><td>'' || to_char(l.unit_price, ''FM999G999G990D00'')',
'          || ''</td><td>'' || to_char(l.amount, ''FM999G999G990D00'') || ''</td></tr>'';',
'    end loop;',
'    l_h := l_h || ''</tbody></table><p>الإجمالي: <b>'' || to_char(o.total_amount, ''FM999G999G990D00'') || ''</b></p>'';',
'  end loop;',
'  return l_h;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820300000000308)
,p_plug_name=>'التسليم'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يصدر فاتورة آجلة على المحل ويصرف من المستودع المختار.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_dst_pkg.order_status(:P25_ID) in (''SUBMITTED'', ''APPROVED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000309)
,p_name=>'P25_WH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820300000000308)
,p_prompt=>'مستودع التسليم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from inv_warehouse where company_id = noona_dst_pkg.company and status_code = ''ACTIVE'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- المستودع الافتراضي -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820300000000310)
,p_name=>'P25_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820300000000308)
,p_prompt=>'سبب الإلغاء'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000311)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820300000000308)
,p_button_name=>'DELIVER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسليم وإصدار الفاتورة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820300000000312)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820300000000308)
,p_button_name=>'CANCEL_ORDER'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الأمر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000313)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Deliver'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'  l := noona_dst_pkg.deliver_order(:P25_ID, to_number(:P25_WH));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000311)
,p_process_success_message=>'تم التسليم وإصدار الفاتورة'
,p_internal_uid=>91820300000000313
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820300000000314)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dst_pkg.cancel_order(:P25_ID, :P25_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820300000000312)
,p_process_success_message=>'تم إلغاء الأمر'
,p_internal_uid=>91820300000000314
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820300000000315)
,p_branch_action=>'f?p=&APP_ID.:25:&SESSION.::&DEBUG.::P25_ID:&P25_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
