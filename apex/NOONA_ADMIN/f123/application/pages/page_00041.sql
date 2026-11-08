prompt --application/pages/page_00041
begin
--   Manifest
--     PAGE: 00041
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
 p_id=>41
,p_name=>'Workflow'
,p_alias=>'WORKFLOW'
,p_step_title=>'مسار الاعتماد'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000423)
,p_plug_name=>'المسار'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000424)
,p_name=>'P41_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000425)
,p_name=>'P41_IS_DRAFT'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000426)
,p_name=>'P41_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_prompt=>'المسار'
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
 p_id=>wwv_flow_imp.id(91820262000000427)
,p_name=>'P41_VERSION_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_prompt=>'الإصدار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select ''الإصدار '' || version_no || '' - '' || noona_ui_pkg.status_label(status_code) d, id r from wf_definition_version where definition_id = :P41_ID order by version_no desc'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000428)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_button_name=>'PUBLISH'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'نشر الإصدار'
,p_button_position=>'NEXT'
,p_button_condition=>':P41_IS_DRAFT = ''Y'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000429)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_button_name=>'NEW_VERSION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إصدار جديد (نسخ المنشور)'
,p_button_position=>'NEXT'
,p_button_condition=>':P41_IS_DRAFT = ''N'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000430)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000423)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000431)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Workflow'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select name_ar || '' ('' || code || '')'' into :P41_NAME from wf_definition where id = :P41_ID;',
'declare l_n number;',
'begin',
'    select count(*) into l_n from wf_definition_version where definition_id = :P41_ID and id = :P41_VERSION_ID;',
'    if l_n = 0 then   -- الافتراضي: المسودة إن وجدت وإلا أحدث إصدار',
'        select max(id) keep (dense_rank last order by case status_code when ''DRAFT'' then 1 else 0 end, version_no)',
'          into :P41_VERSION_ID from wf_definition_version where definition_id = :P41_ID;',
'    end if;',
'end;',
'select case max(status_code) when ''DRAFT'' then ''Y'' else ''N'' end into :P41_IS_DRAFT',
'  from wf_definition_version where id = :P41_VERSION_ID;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000431
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000432)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Publish'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_workflow_pkg.publish_version(:P41_VERSION_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000428)
,p_process_success_message=>'تم نشر الإصدار؛ يطبق على الطلبات الجديدة'
,p_internal_uid=>91820262000000432
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000433)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New Version'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P41_VERSION_ID := noona_workflow_pkg.copy_version(:P41_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000429)
,p_process_success_message=>'تم إنشاء إصدار مسودة منسوخ من الإصدار المنشور'
,p_internal_uid=>91820262000000433
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000434)
,p_plug_name=>'مخطط المسار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_ui_pkg.workflow_diagram(:P41_VERSION_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000435)
,p_plug_name=>'الخطوات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, s.step_code, s.name_ar, noona_ui_pkg.code_label(s.step_type) as step_type,',
'       noona_ui_pkg.assignee_label(s.assignee_rule, s.assignee_ref_id) as assignee,',
'       noona_ui_pkg.code_label(s.allow_self_approval) as allow_self',
'  from wf_step_def s where s.version_id = :P41_VERSION_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الخطوات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000436)
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
,p_internal_uid=>91820262000000436
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000438)
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
 p_id=>wwv_flow_imp.id(91820262000000439)
,p_db_column_name=>'STEP_CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000440)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الخطوة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000441)
,p_db_column_name=>'STEP_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000442)
,p_db_column_name=>'ASSIGNEE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المكلف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000443)
,p_db_column_name=>'ALLOW_SELF'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'يعتمد طلبه بنفسه'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000437)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'437'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'STEP_CODE:NAME_AR:STEP_TYPE:ASSIGNEE:ALLOW_SELF'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000444)
,p_plug_name=>'الانتقالات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select x.id, f.name_ar as from_name, noona_ui_pkg.code_label(nvl(x.outcome_code, ''-'')) as outcome, t.name_ar as to_name,',
'       noona_ui_pkg.code_label(x.is_default) as is_default, r.name_ar as rule_name',
'  from wf_transition_def x join wf_step_def f on f.id = x.from_step_id join wf_step_def t on t.id = x.to_step_id',
'  left join wf_rule r on r.id = x.rule_id where x.version_id = :P41_VERSION_ID'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الانتقالات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000445)
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
,p_internal_uid=>91820262000000445
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000447)
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
 p_id=>wwv_flow_imp.id(91820262000000448)
,p_db_column_name=>'FROM_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000449)
,p_db_column_name=>'OUTCOME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'عند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000450)
,p_db_column_name=>'TO_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000451)
,p_db_column_name=>'IS_DEFAULT'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'افتراضي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000452)
,p_db_column_name=>'RULE_NAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'بشرط'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000446)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'446'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'FROM_NAME:OUTCOME:TO_NAME:IS_DEFAULT:RULE_NAME'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000453)
,p_plug_name=>'إضافة خطوة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P41_IS_DRAFT = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000454)
,p_name=>'P41_STEP_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'رمز الخطوة'
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
 p_id=>wwv_flow_imp.id(91820262000000455)
,p_name=>'P41_STEP_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'اسم الخطوة'
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
 p_id=>wwv_flow_imp.id(91820262000000456)
,p_name=>'P41_STEP_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'نوع الخطوة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:اعتماد;APPROVAL,مراجعة;REVIEW,مهمة;USER_TASK,إشعار;NOTIFICATION,قرار;DECISION,خطوة نظامية;SYSTEM,نهاية;END'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000457)
,p_name=>'P41_RULE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'المكلف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المدير المباشر للطالب;MANAGER,رئيس وحدة تنظيمية;HEAD_POSITION,شاغل منصب;POSITION,أعضاء دور;ROLE,مستخدم محدد;USER,الطالب نفسه;REQUESTER'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000458)
,p_name=>'P41_REF'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'تحديد المكلف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d, r from (select u.display_name d, m.id r, ''USER'' k from sec_user_membership m join sec_user u on u.id = m.user_id where m.status_code = ''ACTIVE'' union all select p.name_ar, p.id, ''POSITION'' from org_position p where p.status_code <> ''CLOSED'' union all select o.name_ar, o.id, ''HEAD_POSITION'' from org_unit o union all select r.name_ar, r.id, ''ROLE'' from sec_role r where r.status_code = ''ACTIVE'') where k = :P41_RULE order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P41_RULE'
,p_ajax_items_to_submit=>'P41_RULE'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000459)
,p_name=>'P41_ALLOW_SELF'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_prompt=>'يسمح أن يعتمد طلبه بنفسه'
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000460)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000453)
,p_button_name=>'ADD_STEP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الخطوة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000461)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Step'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_id number;',
'begin',
'    l_id := noona_workflow_pkg.add_step(p_version_id => :P41_VERSION_ID, p_step_code => :P41_STEP_CODE,',
'                p_step_type => :P41_STEP_TYPE, p_name_ar => :P41_STEP_NAME, p_assignee_rule => :P41_RULE,',
'                p_assignee_ref_id => :P41_REF, p_allow_self => nvl(:P41_ALLOW_SELF, ''N''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000460)
,p_process_success_message=>'تمت إضافة الخطوة؛ اربطها بالانتقالات'
,p_internal_uid=>91820262000000461
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000462)
,p_plug_name=>'ربط الخطوات (انتقال)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P41_IS_DRAFT = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000463)
,p_name=>'P41_FROM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_prompt=>'من الخطوة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || step_code || '')'' d, step_code r from wf_step_def where version_id = :P41_VERSION_ID order by id'
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
 p_id=>wwv_flow_imp.id(91820262000000464)
,p_name=>'P41_TO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_prompt=>'إلى الخطوة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || step_code || '')'' d, step_code r from wf_step_def where version_id = :P41_VERSION_ID order by id'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000465)
,p_name=>'P41_OUTCOME'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_prompt=>'عند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:الاعتماد;APPROVED,الرفض;REJECTED,الإعادة;RETURNED'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'أي نتيجة'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000466)
,p_name=>'P41_RULE_ID'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_prompt=>'بشرط (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from wf_rule order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000467)
,p_name=>'P41_IS_DEFAULT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_prompt=>'انتقال افتراضي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000468)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000462)
,p_button_name=>'ADD_TRANSITION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة الانتقال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000469)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Transition'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_workflow_pkg.add_transition(:P41_VERSION_ID, :P41_FROM, :P41_TO, :P41_OUTCOME, nvl(:P41_IS_DEFAULT, ''N''), :P41_RULE_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000468)
,p_process_success_message=>'تمت إضافة الانتقال'
,p_internal_uid=>91820262000000469
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000470)
,p_plug_name=>'حذف من المسودة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P41_IS_DRAFT = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000471)
,p_name=>'P41_RM_STEP'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000470)
,p_prompt=>'خطوة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || step_code || '')'' d, id r from wf_step_def where version_id = :P41_VERSION_ID and step_type not in (''START'') order by id'
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
 p_id=>wwv_flow_imp.id(91820262000000472)
,p_name=>'P41_RM_TR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000470)
,p_prompt=>'انتقال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select f.name_ar || '' ← '' || t.name_ar || nvl2(x.outcome_code, '' ('' || noona_ui_pkg.code_label(x.outcome_code) || '')'', '''') d, x.id r from wf_transition_def x join wf_step_def f on f.id = x.from_step_id join wf_step_def t on t.id = x.to_step_id where x.version_id = :P41_VERSION_ID order by x.id'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000473)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000470)
,p_button_name=>'REMOVE_STEP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف الخطوة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000474)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000470)
,p_button_name=>'REMOVE_TRANSITION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف الانتقال'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000475)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Step'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_workflow_pkg.remove_step(:P41_RM_STEP);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000473)
,p_process_success_message=>'تم حذف الخطوة وانتقالاتها'
,p_internal_uid=>91820262000000475
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000476)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Transition'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_workflow_pkg.remove_transition(:P41_RM_TR);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000474)
,p_process_success_message=>'تم حذف الانتقال'
,p_internal_uid=>91820262000000476
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000477)
,p_branch_action=>'f?p=&APP_ID.:41:&SESSION.::&DEBUG.:41:P41_ID,P41_VERSION_ID:&P41_ID.,&P41_VERSION_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
