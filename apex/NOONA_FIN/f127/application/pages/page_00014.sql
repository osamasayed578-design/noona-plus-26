prompt --application/pages/page_00014
begin
--   Manifest
--     PAGE: 00014
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>14
,p_name=>'Journal Types'
,p_alias=>'JOURNAL-TYPES'
,p_step_title=>'أنواع القيود'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000353)
,p_plug_name=>'أنواع القيود'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select t.code, t.name_ar, case t.type_group when ''MANUAL'' then ''يدوي'' else ''آلي من مستند'' end as grp,',
'       case when t.tenant_id is null then ''النظام'' else ''المؤسسة'' end as owner,',
'       noona_ui_pkg.code_label(t.allow_manual) as manual, noona_ui_pkg.code_label(t.is_opening) as opening,',
'       noona_ui_pkg.code_label(t.is_adjustment) as adjustment, noona_ui_pkg.code_label(t.auto_reverse) as auto_reverse,',
'       noona_ui_pkg.code_label(t.requires_reference) as req_ref, noona_ui_pkg.code_label(t.is_active) as active, t.description,',
'       (select count(*) from gl_journal j where j.company_id = noona_gl_pkg.company and j.journal_category = t.code) as journals',
'  from gl_journal_type t',
' order by case t.type_group when ''MANUAL'' then 1 else 2 end, t.sort_order, t.code'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أنواع القيود'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000354)
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
,p_internal_uid=>91820266000000354
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000356)
,p_db_column_name=>'CODE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000357)
,p_db_column_name=>'NAME_AR'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000358)
,p_db_column_name=>'GRP'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المجموعة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000359)
,p_db_column_name=>'OWNER'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000360)
,p_db_column_name=>'MANUAL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'إدخال يدوي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000361)
,p_db_column_name=>'OPENING'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'افتتاحي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000362)
,p_db_column_name=>'ADJUSTMENT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'تسوية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000363)
,p_db_column_name=>'AUTO_REVERSE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'عكس آلي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000364)
,p_db_column_name=>'REQ_REF'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'مرجع إلزامي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000365)
,p_db_column_name=>'ACTIVE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'نشط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000366)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الوصف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000367)
,p_db_column_name=>'JOURNALS'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'عدد القيود'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000355)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'355'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:GRP:OWNER:MANUAL:OPENING:ADJUSTMENT:AUTO_REVERSE:REQ_REF:ACTIVE:DESCRIPTION:JOURNALS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000368)
,p_plug_name=>'نوع يدوي خاص بالمؤسسة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">أنواع النظام ثابتة. أضف نوعاً يدوياً خاصاً بمؤسستك (مثل استحقاق المكافآت) برمز إنجليزي؛ تعديل نوع موجود بنفس الرمز يحدّثه.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000369)
,p_name=>'P14_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'الرمز (إنجليزي)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000370)
,p_name=>'P14_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820266000000371)
,p_name=>'P14_ADJ'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'قيد تسوية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000372)
,p_name=>'P14_REV'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'يعكس آلياً في الفترة التالية'
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
 p_id=>wwv_flow_imp.id(91820266000000373)
,p_name=>'P14_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'يتطلب مرجعاً'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000374)
,p_name=>'P14_ACTIVE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;Y,موقوف;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000375)
,p_name=>'P14_DESC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_prompt=>'الوصف ومتى يستخدم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>1000
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000376)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000368)
,p_button_name=>'SAVE_TYPE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ النوع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000377)
,p_plug_name=>'العكس الآلي للاستحقاقات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">قيود الاستحقاق وإعادة التقييم المرحلة تحمل تاريخ عكس آلي (أول يوم في الفترة التالية). نفذ العكس بعد فتح الفترة الجديدة؛ القيود التي حل تاريخ عكسها فقط تعكس.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000378)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000377)
,p_button_name=>'AUTO_REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس القيود المستحقة الآن'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000379)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Type'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_gl_pkg.save_journal_type(:P14_CODE, :P14_NAME, null, :P14_ADJ, :P14_REV, :P14_REF, :P14_ACTIVE, :P14_DESC);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000376)
,p_process_success_message=>'تم حفظ نوع القيد'
,p_internal_uid=>91820266000000379
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000380)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Auto Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_gl_pkg.process_auto_reversals;',
'    apex_application.g_print_success_message := case when l_n > 0 then ''تم عكس '' || l_n || '' قيد'' else ''لا توجد قيود حل تاريخ عكسها'' end;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000378)
,p_internal_uid=>91820266000000380
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000381)
,p_branch_action=>'f?p=&APP_ID.:14:&SESSION.::&DEBUG.:14::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
