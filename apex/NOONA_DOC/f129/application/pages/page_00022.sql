prompt --application/pages/page_00022
begin
--   Manifest
--     PAGE: 00022
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
 p_id=>22
,p_name=>'Required Documents'
,p_alias=>'REQUIRED-DOCUMENTS'
,p_step_title=>'المستندات المطلوبة للأطراف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000159)
,p_plug_name=>'المستندات المطلوبة'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select q.id, noona_pty_pkg.role_label(q.role_code) as role_name, t.name_ar as doc_type, noona_ui_pkg.code_label(q.is_mandatory) as mandatory,',
'       noona_ui_pkg.code_label(q.requires_validity) as validity, noona_ui_pkg.code_label(q.is_active) as active, q.sort_order',
'  from dms_required_document q join dms_document_type t on t.id = q.document_type_id',
' where q.company_id = noona_dms_pkg.company order by q.role_code, q.sort_order'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'المستندات المطلوبة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000160)
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
,p_internal_uid=>91820267000000160
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000162)
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
 p_id=>wwv_flow_imp.id(91820267000000163)
,p_db_column_name=>'ROLE_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الدور'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000164)
,p_db_column_name=>'DOC_TYPE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000165)
,p_db_column_name=>'MANDATORY'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إلزامي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000166)
,p_db_column_name=>'VALIDITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'يشترط سريانه'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000167)
,p_db_column_name=>'ACTIVE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'نشط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000168)
,p_db_column_name=>'SORT_ORDER'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الترتيب'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000161)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'161'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ROLE_NAME:DOC_TYPE:MANDATORY:VALIDITY:ACTIVE:SORT_ORDER'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000169)
,p_plug_name=>'متطلب'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000170)
,p_name=>'P22_ROLE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مورد;SUPPLIER,عميل;CUSTOMER,مقاول;CONTRACTOR,شريك;PARTNER,مستأجر;LESSEE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000171)
,p_name=>'P22_TYPE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_prompt=>'المستند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar d, t.code r from dms_document_type t join dms_category c on c.id = t.category_id where c.code = ''PTY'' and t.is_active = ''Y'' order by t.name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000172)
,p_name=>'P22_MAND'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_prompt=>'إلزامي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000173)
,p_name=>'P22_VALID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_prompt=>'يشترط سريانه'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000174)
,p_name=>'P22_ACTIVE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;Y,موقوف;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000175)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_button_name=>'SAVE_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000176)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000169)
,p_button_name=>'SEED_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة المتطلبات الافتراضية'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000177)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Requirement'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_pkg.set_requirement(:P22_ROLE, :P22_TYPE, :P22_MAND, :P22_VALID, :P22_ACTIVE);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000175)
,p_process_success_message=>'تم الحفظ'
,p_internal_uid=>91820267000000177
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000178)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Seed Requirements'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_dms_pkg.seed_requirements;',
'    apex_application.g_print_success_message := case when l_n > 0 then ''أضيف '' || l_n || '' متطلباً'' else ''توجد متطلبات مسبقاً'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000176)
,p_internal_uid=>91820267000000178
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000179)
,p_branch_action=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
