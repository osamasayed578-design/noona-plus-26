prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>119
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'نونا بلس - الرئيسية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17766428243443046)
,p_plug_name=>'نونا بلس'
,p_region_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_plug_query_num_rows=>15
,p_region_image=>'#APP_FILES#icons/app-icon-512.png'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820261000001001)
,p_plug_name=>'سياق العمل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select noona_apex_pkg.display_name   as user_name,',
'       noona_apex_pkg.tenant_name    as tenant_name,',
'       noona_apex_pkg.company_name   as company_name,',
'       noona_portal_pkg.open_task_count as open_tasks,',
'       noona_portal_pkg.unread_count as unread_notifications',
'  from dual'))
,p_plug_source_type=>'NATIVE_SQL_REPORT'
,p_plug_query_num_rows=>1
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>1
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_show_nulls_as=>'-'
,p_query_no_data_found=>'لا توجد جلسة نونا بلس'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001011)
,p_query_column_id=>1
,p_column_alias=>'USER_NAME'
,p_column_display_sequence=>1
,p_column_heading=>'المستخدم'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001012)
,p_query_column_id=>2
,p_column_alias=>'TENANT_NAME'
,p_column_display_sequence=>2
,p_column_heading=>'المؤسسة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001013)
,p_query_column_id=>3
,p_column_alias=>'COMPANY_NAME'
,p_column_display_sequence=>3
,p_column_heading=>'الشركة الحالية'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001014)
,p_query_column_id=>4
,p_column_alias=>'OPEN_TASKS'
,p_column_display_sequence=>4
,p_column_heading=>'مهام مفتوحة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001015)
,p_query_column_id=>5
,p_column_alias=>'UNREAD_NOTIFICATIONS'
,p_column_display_sequence=>5
,p_column_heading=>'إشعارات غير مقروءة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820261000001002)
,p_plug_name=>'تطبيقاتي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select v.sort_order,',
'       ''<span class="fa '' || v.icon_class || ''" aria-hidden="true"></span> '' ||',
'       case when a.application_id is not null',
'            then ''<a href="'' || apex_page.get_url(p_application => v.app_alias, p_page => 1) || ''">'' || v.app_name_ar || ''</a>''',
'            else v.app_name_ar end as app_link,',
'       case when a.application_id is not null then ''متاح'' else ''قيد الإنشاء'' end as app_status',
'  from noona_v_apps v',
'  left join apex_applications a on a.alias = v.app_alias',
' order by v.sort_order'))
,p_plug_source_type=>'NATIVE_SQL_REPORT'
,p_plug_query_num_rows=>15
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_show_nulls_as=>'-'
,p_query_no_data_found=>'لا توجد تطبيقات متاحة لحسابك'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001021)
,p_query_column_id=>1
,p_column_alias=>'SORT_ORDER'
,p_column_display_sequence=>1
,p_column_heading=>'#'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_hidden_column=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001022)
,p_query_column_id=>2
,p_column_alias=>'APP_LINK'
,p_column_display_sequence=>2
,p_column_heading=>'التطبيق'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_display_as=>'WITHOUT_MODIFICATION'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001023)
,p_query_column_id=>3
,p_column_alias=>'APP_STATUS'
,p_column_display_sequence=>3
,p_column_heading=>'الحالة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820261000001003)
,p_plug_name=>'مهامي'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select task_id, step_name_ar, workflow_name_ar, object_name_ar, requester,',
'       amount, currency_code, priority_label, on_behalf_of, assigned_at, due_at,',
'       case when is_overdue = ''Y'' then ''متأخرة'' end as overdue',
'  from noona_v_my_tasks',
' order by case priority_code when ''VERY_URGENT'' then 1 when ''URGENT'' then 2 when ''HIGH'' then 3 else 4 end, assigned_at'))
,p_plug_source_type=>'NATIVE_SQL_REPORT'
,p_plug_query_num_rows=>15
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_show_nulls_as=>'-'
,p_query_no_data_found=>'لا توجد مهام بانتظارك'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001031)
,p_query_column_id=>1
,p_column_alias=>'TASK_ID'
,p_column_display_sequence=>1
,p_column_heading=>'#'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_hidden_column=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001032)
,p_query_column_id=>2
,p_column_alias=>'STEP_NAME_AR'
,p_column_display_sequence=>2
,p_column_heading=>'المهمة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_column_link=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP:P2_TASK_ID:#TASK_ID#'
,p_column_linktext=>'#STEP_NAME_AR#'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001033)
,p_query_column_id=>3
,p_column_alias=>'WORKFLOW_NAME_AR'
,p_column_display_sequence=>3
,p_column_heading=>'المسار'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001034)
,p_query_column_id=>4
,p_column_alias=>'OBJECT_NAME_AR'
,p_column_display_sequence=>4
,p_column_heading=>'نوع المعاملة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001035)
,p_query_column_id=>5
,p_column_alias=>'REQUESTER'
,p_column_display_sequence=>5
,p_column_heading=>'الطالب'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001036)
,p_query_column_id=>6
,p_column_alias=>'AMOUNT'
,p_column_display_sequence=>6
,p_column_heading=>'المبلغ'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001037)
,p_query_column_id=>7
,p_column_alias=>'CURRENCY_CODE'
,p_column_display_sequence=>7
,p_column_heading=>'العملة'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001038)
,p_query_column_id=>8
,p_column_alias=>'PRIORITY_LABEL'
,p_column_display_sequence=>8
,p_column_heading=>'الأولوية'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001039)
,p_query_column_id=>9
,p_column_alias=>'ON_BEHALF_OF'
,p_column_display_sequence=>9
,p_column_heading=>'نيابة عن'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001040)
,p_query_column_id=>10
,p_column_alias=>'ASSIGNED_AT'
,p_column_display_sequence=>10
,p_column_heading=>'تاريخ الإسناد'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001041)
,p_query_column_id=>11
,p_column_alias=>'DUE_AT'
,p_column_display_sequence=>11
,p_column_heading=>'الاستحقاق'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001042)
,p_query_column_id=>12
,p_column_alias=>'OVERDUE'
,p_column_display_sequence=>12
,p_column_heading=>'التأخير'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820261000001004)
,p_plug_name=>'الإشعارات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select notification_id,',
'       case when is_read = ''N'' then ''<strong>'' || apex_escape.html(title) || ''</strong>'' else apex_escape.html(title) end as title_html,',
'       case when source_entity_type = ''WF_TASK''',
'            then ''<a href="'' || apex_page.get_url(p_page => 2, p_items => ''P2_TASK_ID'', p_values => source_entity_id) || ''">فتح</a>''',
'       end as open_link,',
'       created_at',
'  from noona_v_my_notifications',
' order by created_at desc'))
,p_plug_source_type=>'NATIVE_SQL_REPORT'
,p_plug_query_num_rows=>10
,p_plug_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>10
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_show_nulls_as=>'-'
,p_query_no_data_found=>'لا توجد إشعارات'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001051)
,p_query_column_id=>1
,p_column_alias=>'NOTIFICATION_ID'
,p_column_display_sequence=>1
,p_column_heading=>'#'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_hidden_column=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001052)
,p_query_column_id=>2
,p_column_alias=>'TITLE_HTML'
,p_column_display_sequence=>2
,p_column_heading=>'الإشعار'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_display_as=>'WITHOUT_MODIFICATION'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001053)
,p_query_column_id=>3
,p_column_alias=>'OPEN_LINK'
,p_column_display_sequence=>3
,p_column_heading=>''
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_display_as=>'WITHOUT_MODIFICATION'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(91820261000001054)
,p_query_column_id=>4
,p_column_alias=>'CREATED_AT'
,p_column_display_sequence=>4
,p_column_heading=>'الوقت'
,p_use_as_row_header=>'N'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820261000001005)
,p_plug_name=>'إجراءات الإشعارات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820261000001061)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820261000001005)
,p_button_name=>'MARK_ALL_READ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعليم الكل كمقروء'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820261000001071)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Mark All Read'
,p_process_sql_clob=>'noona_portal_pkg.mark_all_read;'
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820261000001061)
,p_process_success_message=>'تم تعليم كل الإشعارات كمقروءة'
,p_internal_uid=>91820261000001071
);
wwv_flow_imp.component_end;
end;
/
