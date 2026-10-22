prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
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
 p_id=>21
,p_name=>'Archiving Rules'
,p_alias=>'ARCHIVING-RULES'
,p_step_title=>'قواعد الأرشفة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000104)
,p_plug_name=>'قواعد الأرشفة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, decode(r.entity_type, ''CSH_TRANSACTION'', ''سندات القبض والصرف والمصروفات'', ''GL_JOURNAL'', ''القيود اليومية'',',
'              ''AP_INVOICE'', ''فواتير الموردين'', ''AR_INVOICE'', ''فواتير العملاء'', ''PUR_ORDER'', ''أوامر الشراء'', r.entity_type) as entity,',
'       t.name_ar as doc_type, noona_ui_pkg.code_label(r.is_required) as required, noona_ui_pkg.code_label(r.require_file) as file_req,',
'       noona_ui_pkg.code_label(r.is_active) as active, r.updated_by, r.updated_at',
'  from dms_archive_rule r join dms_document_type t on t.id = r.document_type_id',
' where r.company_id = noona_dms_pkg.company order by 2'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'قواعد الأرشفة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000105)
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
,p_internal_uid=>91820267000000105
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000107)
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
 p_id=>wwv_flow_imp.id(91820267000000108)
,p_db_column_name=>'ENTITY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'مستند الأعمال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000109)
,p_db_column_name=>'DOC_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'نوع المستند المؤرشف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000110)
,p_db_column_name=>'REQUIRED'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المرجع الورقي إلزامي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000111)
,p_db_column_name=>'FILE_REQ'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'صورة الأصل إلزامية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000112)
,p_db_column_name=>'ACTIVE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'نشطة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000113)
,p_db_column_name=>'UPDATED_BY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'عدلها'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000114)
,p_db_column_name=>'UPDATED_AT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'وقت التعديل'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000106)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'106'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ENTITY:DOC_TYPE:REQUIRED:FILE_REQ:ACTIVE:UPDATED_BY:UPDATED_AT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000115)
,p_plug_name=>'قاعدة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">عند تفعيل القاعدة لا يعتمد مستند الأعمال حتى يؤرشف مرجعه الورقي (رقم الأصل أو صورته)، أو صورة الأصل إن كانت إلزامية.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000116)
,p_name=>'P21_ENTITY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_prompt=>'مستند الأعمال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سندات القبض والصرف والمصروفات;CSH_TRANSACTION,القيود اليومية;GL_JOURNAL,فواتير الموردين;AP_INVOICE,فواتير العملاء;AR_INVOICE,أوامر الشراء;PUR_ORDER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000117)
,p_name=>'P21_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_prompt=>'نوع المستند المؤرشف الافتراضي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar d, t.code r from dms_document_type t where t.is_active = ''Y'' and t.code <> ''COMPANY_LOGO'' order by t.name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000118)
,p_name=>'P21_REQ'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_prompt=>'المرجع الورقي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إلزامي قبل الاعتماد;Y,اختياري;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000119)
,p_name=>'P21_FILE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_prompt=>'صورة الأصل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اختيارية;N,إلزامية;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000120)
,p_name=>'P21_ACTIVE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشطة;Y,موقوفة;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000121)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000115)
,p_button_name=>'SAVE_RULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ القاعدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000122)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Rule'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_pkg.set_rule(:P21_ENTITY, :P21_TYPE, :P21_REQ, :P21_FILE, :P21_ACTIVE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000121)
,p_process_success_message=>'تم حفظ القاعدة'
,p_internal_uid=>91820267000000122
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000123)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
