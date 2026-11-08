prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
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
 p_id=>20
,p_name=>'Structures'
,p_alias=>'STRUCTURES'
,p_step_title=>'الهياكل التنظيمية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000192)
,p_plug_name=>'الهياكل التنظيمية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, s.code, s.name_ar, nvl(c.trade_name_ar, c.legal_name_ar) as company_name, noona_ui_pkg.code_label(s.structure_type) as structure_type,',
'       noona_ui_pkg.code_label(s.is_primary) as is_primary,',
'       (select max(v.version_no) from org_structure_version v where v.structure_id = s.id and v.status_code = ''ACTIVE'') as active_version,',
'       (select count(*) from org_structure_version v where v.structure_id = s.id) as versions',
'  from org_structure s join org_company c on c.id = s.company_id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الهياكل التنظيمية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000193)
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
,p_detail_link=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21:P21_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820262000000193
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000195)
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
 p_id=>wwv_flow_imp.id(91820262000000196)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000197)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الهيكل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000198)
,p_db_column_name=>'COMPANY_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الشركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000199)
,p_db_column_name=>'STRUCTURE_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000200)
,p_db_column_name=>'IS_PRIMARY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'أساسي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000201)
,p_db_column_name=>'ACTIVE_VERSION'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الإصدار الساري'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000202)
,p_db_column_name=>'VERSIONS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'عدد الإصدارات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000194)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'194'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:COMPANY_NAME:STRUCTURE_TYPE:IS_PRIMARY:ACTIVE_VERSION:VERSIONS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000203)
,p_plug_name=>'هيكل جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000204)
,p_name=>'P20_COMPANY_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_prompt=>'الشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'NOONA_COMPANIES'
,p_lov=>'.'||wwv_flow_imp.id(91820262000000004)||'.'
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
 p_id=>wwv_flow_imp.id(91820262000000205)
,p_name=>'P20_CODE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>50
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
 p_id=>wwv_flow_imp.id(91820262000000206)
,p_name=>'P20_NAME_AR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_prompt=>'الاسم'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000207)
,p_name=>'P20_TYPE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إداري;ADMINISTRATIVE,مالي;FINANCIAL,تشغيلي;OPERATIONAL,مشروعات;PROJECT,مراسلات;CORRESPONDENCE,تقارير;REPORTING,مصفوفي;MATRIX'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000208)
,p_name=>'P20_IS_PRIMARY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_prompt=>'الهيكل الإداري الأساسي للشركة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000210)
,p_validation_name=>'P20_COMPANY_ID required (CREATE)'
,p_validation_sequence=>16
,p_validation=>'P20_COMPANY_ID'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000209)
,p_associated_item=>wwv_flow_imp.id(91820262000000204)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000211)
,p_validation_name=>'P20_CODE required (CREATE)'
,p_validation_sequence=>17
,p_validation=>'P20_CODE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000209)
,p_associated_item=>wwv_flow_imp.id(91820262000000205)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000212)
,p_validation_name=>'P20_NAME_AR required (CREATE)'
,p_validation_sequence=>18
,p_validation=>'P20_NAME_AR'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000209)
,p_associated_item=>wwv_flow_imp.id(91820262000000206)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820262000000213)
,p_validation_name=>'P20_TYPE required (CREATE)'
,p_validation_sequence=>19
,p_validation=>'P20_TYPE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820262000000209)
,p_associated_item=>wwv_flow_imp.id(91820262000000207)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000209)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000203)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنشاء الهيكل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000214)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create Structure'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number; l_ver number;',
'begin',
'    l_id := noona_org_pkg.create_structure(p_company_id => :P20_COMPANY_ID, p_code => :P20_CODE, p_name_ar => :P20_NAME_AR,',
'                                           p_structure_type => :P20_TYPE, p_is_primary => nvl(:P20_IS_PRIMARY, ''N''));',
'    l_ver := noona_org_pkg.new_version(l_id, ''الإصدار الأول'');',
'    :P21_ID := l_id;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000209)
,p_process_success_message=>'تم إنشاء الهيكل وإصداره الأول (مسودة)؛ أضف الوحدات ثم فعّل الإصدار'
,p_internal_uid=>91820262000000214
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000215)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.::P21_ID:&P21_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
,p_branch_when_button_id=>wwv_flow_imp.id(91820262000000209)
);

wwv_flow_imp.component_end;
end;
/
