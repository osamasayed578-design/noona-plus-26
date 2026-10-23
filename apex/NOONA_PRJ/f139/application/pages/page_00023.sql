prompt --application/pages/page_00023
begin
--   Manifest
--     PAGE: 00023
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
 p_id=>23
,p_name=>'Reservation'
,p_alias=>'RESERVATION'
,p_step_title=>'الحجز'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000010)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000240)
,p_plug_name=>'الحجز'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_r hsp_reservation%rowtype; l_room varchar2(100); l_f number;',
'begin',
'    select * into l_r from hsp_reservation where id = :P23_ID and company_id = noona_hsp_pkg.company;',
'    select listagg(r.room_no || '' ('' || t.name_ar || '')'', ''، '') within group (order by r.room_no) into l_room',
'      from hsp_reservation_room rr join hsp_room r on r.id = rr.room_id join hsp_room_type t on t.id = rr.room_type_id',
'     where rr.reservation_id = l_r.id;',
'    l_f := noona_hsp_pkg.folio_of_reservation(l_r.id);',
'    return ''<div class="nn-hr-runbar"><b>'' || l_r.doc_no || ''</b> · '' || apex_escape.html(noona_hsp_pkg.guest_name(l_r.guest_party_id))',
'        || '' · '' || apex_escape.html(noona_hsp_pkg.guest_phone(l_r.guest_party_id)) || '' · <span class="nn-badge is-info">''',
'        || noona_hsp_pkg.res_status_label(l_r.status_code) || ''</span></div><table class="nn-rpt"><tbody>''',
'        || ''<tr><td class="nn-rpt-text">الإقامة</td><td class="nn-rpt-text">'' || to_char(l_r.arrival_date, ''YYYY-MM-DD'') || '' ← ''',
'        || to_char(l_r.departure_date, ''YYYY-MM-DD'') || '' ('' || (l_r.departure_date - l_r.arrival_date) || '' ليلة)</td></tr>''',
'        || ''<tr><td class="nn-rpt-text">الغرفة</td><td class="nn-rpt-text">'' || apex_escape.html(l_room) || ''</td></tr>''',
'        || ''<tr><td class="nn-rpt-text">النزلاء</td><td class="nn-rpt-text">'' || l_r.adults || '' بالغ'' || case when l_r.children > 0 then '' + ''',
'        || l_r.children || '' طفل'' end || ''</td></tr><tr><td class="nn-rpt-text">القناة</td><td class="nn-rpt-text">''',
'        || noona_hsp_pkg.channel_label(l_r.channel_code) || '' '' || apex_escape.html(l_r.channel_reference) || ''</td></tr>''',
'        || ''<tr><td class="nn-rpt-text">الإجمالي التقديري</td><td>'' || to_char(l_r.total_estimate, ''FM999G999G990D00'') || ''</td></tr>''',
'        || ''<tr><td class="nn-rpt-text">رصيد الحساب</td><td>'' || to_char(noona_hsp_pkg.folio_balance(l_f), ''FM999G999G990D00'') || ''</td></tr>''',
'        || ''<tr><td class="nn-rpt-text">طلبات وملاحظات</td><td class="nn-rpt-text">'' || apex_escape.html(l_r.special_requests) || ''</td></tr>''',
'        || ''</tbody></table>'';',
'exception when no_data_found then return null;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000241)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000242)
,p_name=>'P23_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000243)
,p_name=>'P23_ROOM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_prompt=>'غرفة الدخول (اختياري لتغيير الغرفة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select r.room_no || '' - '' || t.name_ar || '' · '' || noona_hsp_pkg.hk_label(r.housekeeping_status) d, r.id r from hsp_room r join hsp_room_type t on t.id = r.room_type_id join hsp_reservation x on x.property_id = r.property_id where x.id = :P23_ID and r.status_code = ''ACTIVE'' and noona_hsp_pkg.is_free(r.id, noona_hsp_pkg.business_date(x.property_id), x.departure_date, null, (select min(id) from hsp_reservation_room where reservation_id = x.id)) = ''Y'' order by r.room_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- الغرفة المحجوزة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000244)
,p_name=>'P23_FORCE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_prompt=>'الدخول حتى لو لم تنظف الغرفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000245)
,p_name=>'P23_REASON'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000241)
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
 p_id=>wwv_flow_imp.id(91820273000000246)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_button_name=>'CHECKIN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل الدخول'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_hsp_pkg.res_status(:P23_ID) in (''TENTATIVE'', ''CONFIRMED'', ''GUARANTEED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000247)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_button_name=>'FOLIO'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'كشف حساب النزيل'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'javascript:window.open(''&P23_FOLIO_URL.'', ''_blank'');'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000248)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_button_name=>'CANCEL_RES'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء الحجز'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_hsp_pkg.res_status(:P23_ID) in (''TENTATIVE'', ''CONFIRMED'', ''GUARANTEED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000249)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_button_name=>'NOSHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'لم يحضر'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_hsp_pkg.res_status(:P23_ID) in (''TENTATIVE'', ''CONFIRMED'', ''GUARANTEED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000250)
,p_name=>'P23_FOLIO_URL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000241)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000251)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Folio URL'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P23_FOLIO_URL := apex_page.get_url(p_page => 24, p_items => ''P24_ID'', p_values => noona_hsp_pkg.folio_of_reservation(:P23_ID));',
'    :P23_FORCE := nvl(:P23_FORCE, ''N'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000251
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000252)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Check-in'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_s number;',
'begin',
'    l_s := noona_hsp_pkg.check_in(:P23_ID, :P23_ROOM, nvl(:P23_FORCE, ''N''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000246)
,p_process_success_message=>'تم تسجيل دخول النزيل'
,p_internal_uid=>91820273000000252
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000253)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_hsp_pkg.cancel_reservation(:P23_ID, :P23_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000248)
,p_process_success_message=>'تم إلغاء الحجز'
,p_internal_uid=>91820273000000253
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000254)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'No show'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_hsp_pkg.mark_no_show(:P23_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000249)
,p_process_success_message=>'سجل عدم الحضور'
,p_internal_uid=>91820273000000254
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000255)
,p_branch_action=>'f?p=&APP_ID.:23:&SESSION.::&DEBUG.::P23_ID:&P23_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
