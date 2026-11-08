prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>21
,p_name=>'Structure'
,p_alias=>'STRUCTURE'
,p_step_title=>'الهيكل التنظيمي'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000185)
,p_plug_name=>'الإصدار'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000186)
,p_name=>'P21_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000187)
,p_name=>'P21_VERSION_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_prompt=>'الإصدار المعروض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''إصدار '' || version_no || '' - '' || noona_ui_pkg.status_label(status_code) d, id r from org_structure_version where structure_id = :P21_ID order by version_no desc'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000188)
,p_name=>'P21_VERSION_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_prompt=>'حالة الإصدار'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000189)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_button_name=>'SHOW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عرض'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000190)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_button_name=>'NEW_VERSION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إصدار جديد (نسخ الساري)'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000191)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تفعيل هذا الإصدار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000192)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000185)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000193)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Default Version'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P21_VERSION_ID is null then',
'    select max(id) keep (dense_rank first order by case status_code when ''DRAFT'' then 1 when ''ACTIVE'' then 2 else 3 end, version_no desc)',
'      into :P21_VERSION_ID from org_structure_version where structure_id = :P21_ID;',
'end if;',
'select max(noona_ui_pkg.status_label(status_code)) into :P21_VERSION_STATUS from org_structure_version where id = :P21_VERSION_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000193
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000194)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New Version'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P21_VERSION_ID := noona_org_pkg.new_version(:P21_ID, ''إعادة هيكلة'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000190)
,p_process_success_message=>'تم إنشاء إصدار جديد (مسودة) منسوخ من الإصدار الساري'
,p_internal_uid=>91820262000000194
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000195)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate Version'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_org_pkg.activate_version(:P21_VERSION_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000191)
,p_process_success_message=>'تم تفعيل الإصدار؛ انتقلت المناصب إلى وحداته'
,p_internal_uid=>91820262000000195
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000196)
,p_plug_name=>'وحدات الإصدار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select u.id, replace(rpad('' '', (u.hier_level - 1) * 4, '' ''), '' '', ''&nbsp;'') || case when u.hier_level > 1 then ''&#8627; '' end || noona_ui_pkg.esc(u.name_ar) as unit_name,',
'       u.code, noona_ui_pkg.code_label(u.unit_type) as unit_type, u.hier_path,',
'       (select p.name_ar from org_position p where p.id = u.head_position_id) as head_position,',
'       (select count(*) from org_position p where p.org_unit_id = u.id and p.status_code not in (''CANCELLED'',''CLOSED'')) as positions,',
'       noona_ui_pkg.status_badge(u.status_code) as status_html',
'  from org_unit u where u.structure_version_id = :P21_VERSION_ID',
' order by u.hier_path'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'وحدات الإصدار'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000197)
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
,p_internal_uid=>91820262000000197
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000199)
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
 p_id=>wwv_flow_imp.id(91820262000000200)
,p_db_column_name=>'UNIT_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000201)
,p_db_column_name=>'CODE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000202)
,p_db_column_name=>'UNIT_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000203)
,p_db_column_name=>'HIER_PATH'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المسار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000204)
,p_db_column_name=>'HEAD_POSITION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'منصب الرئيس'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000205)
,p_db_column_name=>'POSITIONS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المناصب'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000206)
,p_db_column_name=>'STATUS_HTML'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000198)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'198'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'UNIT_NAME:CODE:UNIT_TYPE:HIER_PATH:HEAD_POSITION:POSITIONS:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000207)
,p_plug_name=>'إضافة وحدة إلى الإصدار (مسودة فقط)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000208)
,p_name=>'P21_UNIT_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000207)
,p_prompt=>'رمز الوحدة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000209)
,p_name=>'P21_UNIT_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000207)
,p_prompt=>'اسم الوحدة'
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
 p_id=>wwv_flow_imp.id(91820262000000210)
,p_name=>'P21_UNIT_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000207)
,p_prompt=>'نوع الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إدارة عليا;EXECUTIVE,قطاع;SECTOR,إدارة;DEPARTMENT,قسم;SECTION,وحدة;UNIT,فريق;TEAM,مكتب;OFFICE,لجنة;COMMITTEE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000211)
,p_name=>'P21_PARENT_CODE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000207)
,p_prompt=>'الوحدة الأم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select lpad('' '', (hier_level - 1) * 4, '' '') || name_ar d, code r from org_unit where structure_version_id = :P21_VERSION_ID order by hier_path'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- بدون (وحدة جذرية) -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000212)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000207)
,p_button_name=>'ADD_UNIT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الوحدة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000213)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Unit'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_org_pkg.add_unit(p_version_id => :P21_VERSION_ID, p_code => :P21_UNIT_CODE, p_name_ar => :P21_UNIT_NAME,',
'                                   p_unit_type => :P21_UNIT_TYPE, p_parent_code => :P21_PARENT_CODE);',
'    :P21_UNIT_CODE := null; :P21_UNIT_NAME := null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000212)
,p_process_success_message=>'تمت إضافة الوحدة'
,p_internal_uid=>91820262000000213
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000214)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID,P21_VERSION_ID:&P21_ID.,&P21_VERSION_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
