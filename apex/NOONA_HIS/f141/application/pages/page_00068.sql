prompt --application/pages/page_00068
begin
--   Manifest
--     PAGE: 00068
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>68
,p_name=>'Integration Log'
,p_alias=>'LINK-LOG'
,p_step_title=>'سجل رسائل الربط'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000980)
,p_plug_name=>'إجراءات'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000981)
,p_name=>'P68_STATUS'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000980)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مقبولة;ACCEPTED,قيد المراجعة;PENDING,مرفوضة;REJECTED,خطأ اتصال;ERROR,مرسلة;SENT'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'الكل'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000982)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000980)
,p_button_name=>'PROCESS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'متابعة الموافقات والمطالبات المعلقة وإعادة الوصفات المتعثرة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000983)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Process'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_his_link_pkg.process_pending;',
'    apex_application.g_print_success_message := ''عولجت '' || l || '' رسالة'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000982)
,p_internal_uid=>91820275000000983
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000984)
,p_plug_name=>'الرسائل'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.id, m.msg_no, noona_his_link_pkg.type_label(m.msg_type) as msg_type, i.name_ar as channel, y.name_ar as payer, m.entity_type, m.entity_id,',
'       to_char(m.sent_at, ''YYYY-MM-DD HH24:MI:SS'') as sent_at, m.http_status, m.attempts, m.external_ref, noona_his_link_pkg.status_label(m.status_code) as status,',
'       m.outcome',
'  from his_link_message m join his_integration i on i.id = m.integration_id left join his_payer y on y.id = m.payer_id',
' where m.company_id = noona_his_pkg.company and (:P68_STATUS is null or m.status_code = :P68_STATUS) order by m.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الرسائل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000985)
,p_max_row_count=>'1000000'
,p_no_data_found_message=>'لا توجد بيانات'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'N'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'N'
,p_detail_link=>'f?p=&APP_ID.:69:&SESSION.::&DEBUG.:RP,69:P69_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820275000000985
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000987)
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
 p_id=>wwv_flow_imp.id(91820275000000988)
,p_db_column_name=>'MSG_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرسالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000989)
,p_db_column_name=>'MSG_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000990)
,p_db_column_name=>'CHANNEL'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'القناة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000991)
,p_db_column_name=>'PAYER'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الجهة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000992)
,p_db_column_name=>'ENTITY_TYPE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000993)
,p_db_column_name=>'ENTITY_ID'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المعرف'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000994)
,p_db_column_name=>'SENT_AT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000995)
,p_db_column_name=>'HTTP_STATUS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'HTTP'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000996)
,p_db_column_name=>'ATTEMPTS'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'المحاولات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000997)
,p_db_column_name=>'EXTERNAL_REF'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'مرجع الجهة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000998)
,p_db_column_name=>'STATUS'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000999)
,p_db_column_name=>'OUTCOME'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الخلاصة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000986)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'986'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'MSG_NO:MSG_TYPE:CHANNEL:PAYER:ENTITY_TYPE:ENTITY_ID:SENT_AT:HTTP_STATUS:ATTEMPTS:EXTERNAL_REF:STATUS:OUTCOME'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000001000)
,p_branch_action=>'f?p=&APP_ID.:68:&SESSION.::&DEBUG.::P68_STATUS:&P68_STATUS.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
