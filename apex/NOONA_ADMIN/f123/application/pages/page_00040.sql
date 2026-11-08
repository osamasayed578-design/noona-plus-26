prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Workflows'
,p_alias=>'WORKFLOWS'
,p_step_title=>'مسارات الاعتماد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000432)
,p_plug_name=>'مسارات الاعتماد'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.code, d.name_ar, nvl(e.name_ar, d.object_type) as object_name,',
'       noona_ui_pkg.code_label(d.workflow_kind) as kind,',
'       (select max(v.version_no) from wf_definition_version v where v.definition_id = d.id',
'           and v.status_code in (''PUBLISHED'', ''ACTIVE'')) as published_version,',
'       (select count(*) from wf_definition_version v where v.definition_id = d.id and v.status_code = ''DRAFT'') as drafts,',
'       noona_ui_pkg.status_badge(case d.is_active when ''Y'' then ''ACTIVE'' else ''INACTIVE'' end) as status_html',
'  from wf_definition d left join ref_entity_type e on e.entity_type_code = d.object_type'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مسارات الاعتماد'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000433)
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
,p_detail_link=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:RP,41:P41_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820262000000433
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000435)
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
 p_id=>wwv_flow_imp.id(91820262000000436)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000437)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المسار'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000438)
,p_db_column_name=>'OBJECT_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'نوع المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000439)
,p_db_column_name=>'KIND'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000440)
,p_db_column_name=>'PUBLISHED_VERSION'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الإصدار المنشور'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000441)
,p_db_column_name=>'DRAFTS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'مسودات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000442)
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
 p_id=>wwv_flow_imp.id(91820262000000434)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'434'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:OBJECT_NAME:KIND:PUBLISHED_VERSION:DRAFTS:STATUS_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000443)
,p_plug_name=>'مسار جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000444)
,p_name=>'P40_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000443)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000445)
,p_name=>'P40_NAME_AR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000443)
,p_prompt=>'اسم المسار'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000446)
,p_name=>'P40_OBJECT_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000443)
,p_prompt=>'نوع المستند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select module_code || '' - '' || name_ar d, entity_type_code r from ref_entity_type where module_code not in (''PLT'', ''SEC'', ''REF'', ''MIG'', ''OPS'', ''DEP'') order by module_code, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000447)
,p_name=>'P40_KIND'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000443)
,p_prompt=>'نوع المسار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اعتماد;APPROVAL,مراجعة;REVIEW,توجيه;ROUTING,مهام;TASK'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000449)
,p_validation_name=>'P40_CODE required (CREATE)'
,p_validation_sequence=>15
,p_validation=>'P40_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000448)
,p_associated_item=>wwv_flow_imp.id(91820262000000444)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000450)
,p_validation_name=>'P40_NAME_AR required (CREATE)'
,p_validation_sequence=>16
,p_validation=>'P40_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000448)
,p_associated_item=>wwv_flow_imp.id(91820262000000445)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000451)
,p_validation_name=>'P40_OBJECT_TYPE required (CREATE)'
,p_validation_sequence=>17
,p_validation=>'P40_OBJECT_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000448)
,p_associated_item=>wwv_flow_imp.id(91820262000000446)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000448)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000443)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء المسار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000452)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Workflow'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_ver number; l_id number;',
'begin',
'    :P41_ID := noona_workflow_pkg.create_definition(p_code => :P40_CODE, p_name_ar => :P40_NAME_AR,',
'                   p_object_type => :P40_OBJECT_TYPE, p_kind => nvl(:P40_KIND, ''APPROVAL''));',
'    -- إصدار أول بخطوتي البداية والنهاية',
'    l_ver := noona_workflow_pkg.new_version(:P41_ID);',
'    l_id := noona_workflow_pkg.add_step(l_ver, ''START'', ''START'', ''بداية'');',
'    l_id := noona_workflow_pkg.add_step(l_ver, ''END'', ''END'', ''نهاية'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000448)
,p_process_success_message=>'تم إنشاء المسار؛ أضف خطوات الاعتماد ثم انشر الإصدار'
,p_internal_uid=>91820262000000452
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000453)
,p_branch_action=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.::P41_ID:&P41_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
,p_branch_when_button_id=>wwv_flow_imp.id(91820262000000448)
);

wwv_flow_imp.component_end;
end;
/
