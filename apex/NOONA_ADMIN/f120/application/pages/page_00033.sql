prompt --application/pages/page_00033
begin
--   Manifest
--     PAGE: 00033
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>120
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>33
,p_name=>'Role'
,p_alias=>'ROLE'
,p_step_title=>'الدور وصلاحياته'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000352)
,p_plug_name=>'الدور'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000353)
,p_name=>'P33_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000354)
,p_name=>'P33_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000355)
,p_name=>'P33_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000356)
,p_name=>'P33_NEW_STATUS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'تغيير الحالة إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,مسودة;DRAFT,متقاعد;RETIRED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000357)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_button_name=>'CHANGE_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000358)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000359)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Role'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select name_ar || '' ('' || code || '')'', noona_ui_pkg.status_label(status_code) into :P33_NAME, :P33_STATUS',
'  from sec_role where id = :P33_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000359
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000360)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Role Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.set_role_status(:P33_ID, :P33_NEW_STATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000357)
,p_process_success_message=>'تم تغيير حالة الدور'
,p_internal_uid=>91820262000000360
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000361)
,p_plug_name=>'صلاحيات الدور'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select rp.id, p.module_code, p.permission_code, p.name_ar, p.action_code, noona_ui_pkg.code_label(rp.effect) as effect, p.risk_level',
'  from sec_role_permission rp join sec_permission p on p.id = rp.permission_id',
' where rp.role_id = :P33_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'صلاحيات الدور'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000362)
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
,p_internal_uid=>91820262000000362
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000364)
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
 p_id=>wwv_flow_imp.id(91820262000000365)
,p_db_column_name=>'MODULE_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000366)
,p_db_column_name=>'PERMISSION_CODE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'رمز الصلاحية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000367)
,p_db_column_name=>'NAME_AR'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الصلاحية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000368)
,p_db_column_name=>'ACTION_CODE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الفعل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000369)
,p_db_column_name=>'EFFECT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الأثر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000370)
,p_db_column_name=>'RISK_LEVEL'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الخطورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000363)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'363'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'MODULE_CODE:PERMISSION_CODE:NAME_AR:ACTION_CODE:EFFECT:RISK_LEVEL'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000371)
,p_plug_name=>'إضافة صلاحيات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000372)
,p_name=>'P33_MODULE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_prompt=>'الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select module_code || '' - '' || name_ar d, module_code r from plt_module order by package_no'
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
 p_id=>wwv_flow_imp.id(91820262000000373)
,p_name=>'P33_ACTIONS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_prompt=>'الأفعال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d, r from (select ''عرض فقط'' d, ''VIEW'' r, 0 s from dual union all select ''عرض وتصدير وطباعة'' d, ''VIEW,EXPORT,PRINT'' r, 1 s from dual union all select ''إدخال (عرض وإنشاء وتعديل)'' d, ''VIEW,CREATE,UPDATE'' r, 2 s from dual union all select ''إدخال وإرسال للاعتماد'' d, ''VIEW,CREATE,UPDATE,SUBMIT,PRINT,EXPORT'' r, 3 s from dual union all select ''اعتماد ورفض'' d, ''VIEW,APPROVE,REJECT'' r, 4 s from dual union all select ''ترحيل وعكس'' d, ''VIEW,POST,REVERSE'' r, 5 s from dual union all select ''كل الأفعال'' d, ''VIEW,CREATE,UPDATE,DELETE,EXPORT,PRINT,SUBMIT,APPROVE,REJECT,POST,REVERSE,CANCEL'' r, 6 s from dual) order by s'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000374)
,p_name=>'P33_EFFECT'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_prompt=>'الأثر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سماح;ALLOW,منع;DENY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000375)
,p_name=>'P33_PERMISSION_CODE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_prompt=>'أو صلاحية محددة (رمز)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>150
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
 p_id=>wwv_flow_imp.id(91820262000000376)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_button_name=>'ADD_MODULE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة صلاحيات الوحدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000377)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_button_name=>'ADD_ONE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة الصلاحية المحددة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000378)
,p_name=>'P33_REMOVE_ID'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_prompt=>'إزالة صلاحية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.permission_code d, rp.id r from sec_role_permission rp join sec_permission p on p.id = rp.permission_id where rp.role_id = :P33_ID order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000379)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000371)
,p_button_name=>'REMOVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إزالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000380)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Module Permissions'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_sec_admin_pkg.add_module_permissions(:P33_ID, :P33_MODULE, :P33_ACTIONS, nvl(:P33_EFFECT, ''ALLOW''));',
'    apex_application.g_print_success_message := ''تمت إضافة '' || l_n || '' صلاحية'';',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000376)
,p_internal_uid=>91820262000000380
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000381)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add One Permission'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.add_permission(:P33_ID, :P33_PERMISSION_CODE, nvl(:P33_EFFECT, ''ALLOW''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000377)
,p_process_success_message=>'تمت إضافة الصلاحية'
,p_internal_uid=>91820262000000381
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000382)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Permission'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.remove_permission(:P33_REMOVE_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000379)
,p_process_success_message=>'تمت إزالة الصلاحية'
,p_internal_uid=>91820262000000382
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000383)
,p_branch_action=>'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
