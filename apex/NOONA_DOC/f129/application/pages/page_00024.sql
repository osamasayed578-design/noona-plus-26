prompt --application/pages/page_00024
begin
--   Manifest
--     PAGE: 00024
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>24
,p_name=>'Correspondence Mail'
,p_alias=>'CORRESPONDENCE-MAIL'
,p_step_title=>'بريد المراسلات الخارجية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000224)
,p_plug_name=>'بريد الشركة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">الخطاب الصادر الذي يختار مرسله «بريد إلكتروني» يرسل من هذا العنوان مع نسخة الخطاب الرسمية ومرفقاته، ويظهر في الخطاب: في طابور البريد ثم أرسل أو فشل مع السبب وإمكانية إعادة الإرسال. الإرسال يتم عبر خادم البريد (SMTP) المعرف في إدارة APEX؛ ويجب أن يكون عنوان المرسل مسموحاً به في ذلك الخادم. ردود الجهات تصل إلى «عنوان الرد» وتسجل وارداً بقناة «بريد إلكتروني».</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000225)
,p_name=>'P24_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'عنوان المرسل'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>320
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000226)
,p_name=>'P24_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'اسم المرسل الظاهر'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000227)
,p_name=>'P24_REPLY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'عنوان الرد (صندوق الوارد الذي تتابعه الإدارة)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>320
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000228)
,p_name=>'P24_BCC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'نسخة مخفية للأرشيف (اختياري)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>320
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000229)
,p_name=>'P24_SIGN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'التذييل'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000230)
,p_name=>'P24_ACTIVE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_prompt=>'مفعل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000231)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Mail'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t;',
'begin',
'    l := json_object_t.parse(noona_cor_pkg.mail_profile_json);',
'    :P24_FROM := l.get_string(''from''); :P24_NAME := l.get_string(''name''); :P24_REPLY := l.get_string(''reply_to'');',
'    :P24_BCC := l.get_string(''bcc''); :P24_SIGN := l.get_string(''signature'');',
'    :P24_ACTIVE := case when :P24_FROM is null then ''Y'' else l.get_string(''active'') end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000231
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000232)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000224)
,p_button_name=>'SAVE_MAIL'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000233)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Mail'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    noona_cor_pkg.save_mail_profile(:P24_FROM, :P24_NAME, :P24_REPLY, :P24_BCC, :P24_SIGN, :P24_ACTIVE);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000232)
,p_process_success_message=>'تم حفظ بريد المراسلات'
,p_internal_uid=>91820267000000233
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000234)
,p_plug_name=>'آخر عمليات الإرسال الخارجي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, c.correspondence_no, c.subject, case d.channel when ''EMAIL'' then ''بريد إلكتروني'' else ''تسليم ورقي'' end as ch,',
'       d.destination, case d.status_code when ''QUEUED'' then ''بانتظار'' when ''SENDING'' then ''في طابور البريد'' when ''SENT'' then ''أرسل''',
'       when ''DELIVERED'' then ''سُلّم'' when ''FAILED'' then ''فشل'' else d.status_code end as st, d.received_by, d.error_message,',
'       to_char(nvl(d.delivered_at, d.created_at), ''YYYY-MM-DD HH24:MI'') as at',
'  from cor_dispatch d join cor_correspondence c on c.id = d.correspondence_id',
' where c.company_id = noona_dms_pkg.company order by d.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'آخر عمليات الإرسال الخارجي'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000235)
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
,p_internal_uid=>91820267000000235
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000237)
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
 p_id=>wwv_flow_imp.id(91820267000000238)
,p_db_column_name=>'CORRESPONDENCE_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرقم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000239)
,p_db_column_name=>'SUBJECT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الموضوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000240)
,p_db_column_name=>'CH'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000241)
,p_db_column_name=>'DESTINATION'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000242)
,p_db_column_name=>'ST'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000243)
,p_db_column_name=>'RECEIVED_BY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المستلم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000244)
,p_db_column_name=>'ERROR_MESSAGE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الخطأ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000245)
,p_db_column_name=>'AT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000236)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'236'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CORRESPONDENCE_NO:SUBJECT:CH:DESTINATION:ST:RECEIVED_BY:ERROR_MESSAGE:AT'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000246)
,p_branch_action=>'f?p=&APP_ID.:24:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
