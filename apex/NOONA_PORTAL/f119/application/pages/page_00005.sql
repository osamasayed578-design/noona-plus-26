prompt --application/pages/page_00005
begin
--   Manifest
--     PAGE: 00005
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>5
,p_name=>'My Delegations'
,p_alias=>'MY-DELEGATIONS'
,p_step_title=>'تفويضاتي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820264000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820264000000046)
,p_plug_name=>'تفويضاتي'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.delegation_no, noona_ui_pkg.code_label(d.delegation_type) as dtype,',
'       case when d.grantor_member_id = to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'')) then ''مني'' else ''إلي'' end as direction,',
'       (select u.display_name from sec_user_membership m join sec_user u on u.id = m.user_id',
'         where m.id = case when d.grantor_member_id = to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID''))',
'                          then d.delegate_member_id else d.grantor_member_id end) as other_party,',
'       to_char(d.starts_at, ''YYYY-MM-DD'') as starts_at, to_char(d.ends_at, ''YYYY-MM-DD'') as ends_at, d.reason,',
'       noona_ui_pkg.status_badge(d.status_code) as status_html',
'  from dlg_delegation d',
' where to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'')) in (d.grantor_member_id, d.delegate_member_id)',
' order by d.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تفويضاتي'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820264000000047)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_owner=>'NOONA'
,p_internal_uid=>91820264000000047
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000049)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'#'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000050)
,p_db_column_name=>'DELEGATION_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000051)
,p_db_column_name=>'DTYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000052)
,p_db_column_name=>'DIRECTION'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الاتجاه'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000053)
,p_db_column_name=>'OTHER_PARTY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطرف الآخر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000054)
,p_db_column_name=>'STARTS_AT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000055)
,p_db_column_name=>'ENDS_AT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000056)
,p_db_column_name=>'REASON'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820264000000057)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820264000000048)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'48'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DELEGATION_NO:DTYPE:DIRECTION:OTHER_PARTY:STARTS_AT:ENDS_AT:REASON:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820264000000058)
,p_plug_name=>'تفويض صلاحياتي لزميل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820264000000059)
,p_name=>'P5_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_prompt=>'نوع التفويض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اعتماد;APPROVAL,بالإنابة;ACTING,تشغيلي;OPERATIONAL,مراسلات;CORRESPONDENCE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820264000000060)
,p_name=>'P5_DELEGATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_prompt=>'المفوض إليه'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select u.display_name || '' ('' || u.username || '')'' d, m.id r from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = ''ACTIVE'' and m.id <> to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'')) order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820264000000061)
,p_name=>'P5_FROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_prompt=>'من تاريخ'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820264000000062)
,p_name=>'P5_TO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_prompt=>'إلى تاريخ'
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
 p_id=>wwv_flow_imp.id(91820264000000063)
,p_name=>'P5_REASON'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_prompt=>'السبب (مثال: إجازة سنوية)'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820264000000065)
,p_validation_name=>'P5_DELEGATE required (CREATE)'
,p_validation_sequence=>17
,p_validation=>'P5_DELEGATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820264000000064)
,p_associated_item=>wwv_flow_imp.id(91820264000000060)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820264000000066)
,p_validation_name=>'P5_FROM required (CREATE)'
,p_validation_sequence=>18
,p_validation=>'P5_FROM'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820264000000064)
,p_associated_item=>wwv_flow_imp.id(91820264000000061)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820264000000067)
,p_validation_name=>'P5_TO required (CREATE)'
,p_validation_sequence=>19
,p_validation=>'P5_TO'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820264000000064)
,p_associated_item=>wwv_flow_imp.id(91820264000000062)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820264000000068)
,p_validation_name=>'P5_REASON required (CREATE)'
,p_validation_sequence=>20
,p_validation=>'P5_REASON'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820264000000064)
,p_associated_item=>wwv_flow_imp.id(91820264000000063)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820264000000064)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820264000000058)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إرسال التفويض للاعتماد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820264000000069)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P5_FROM := nvl(:P5_FROM, to_char(sysdate, ''YYYY-MM-DD''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820264000000069
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820264000000070)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Delegation'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_delegation_pkg.create_delegation(p_delegation_type => nvl(:P5_TYPE, ''APPROVAL''),',
'        p_grantor_member_id => to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'')), p_delegate_member_id => :P5_DELEGATE,',
'        p_starts_at => to_date(:P5_FROM, ''YYYY-MM-DD''), p_ends_at => to_date(:P5_TO, ''YYYY-MM-DD'') + 1 - 1 / 86400,',
'        p_reason => :P5_REASON);',
'    noona_delegation_pkg.submit(l_id);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820264000000064)
,p_process_success_message=>'تم إرسال التفويض؛ يسري بعد اعتماده'
,p_internal_uid=>91820264000000070
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820264000000071)
,p_plug_name=>'إلغاء تفويض'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820264000000072)
,p_name=>'P5_CANCEL_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820264000000071)
,p_prompt=>'التفويض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select delegation_no || '' · '' || to_char(starts_at, ''YYYY-MM-DD'') || '' - '' || to_char(ends_at, ''YYYY-MM-DD'') d, id r from dlg_delegation where grantor_member_id = to_number(sys_context(''NOONA_CTX'', ''MEMBERSHIP_ID'')) and status_code in (''SUBMITTED'', ''APPROVED'', ''SCHEDULED'', ''ACTIVE'', ''SUSPENDED'') order by id desc'
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
 p_id=>wwv_flow_imp.id(91820264000000073)
,p_name=>'P5_CANCEL_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820264000000071)
,p_prompt=>'سبب الإلغاء'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(91820264000000074)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820264000000071)
,p_button_name=>'REVOKE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء التفويض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820264000000075)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Revoke Delegation'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_delegation_pkg.revoke_delegation(:P5_CANCEL_ID, :P5_CANCEL_REASON);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820264000000074)
,p_process_success_message=>'تم إلغاء التفويض'
,p_internal_uid=>91820264000000075
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820264000000076)
,p_branch_action=>'f?p=&APP_ID.:5:&SESSION.::&DEBUG.:5::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
