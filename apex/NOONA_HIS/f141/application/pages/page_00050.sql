prompt --application/pages/page_00050
begin
--   Manifest
--     PAGE: 00050
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
 p_id=>50
,p_name=>'Worklists'
,p_alias=>'WORKLIST'
,p_step_title=>'قوائم عمل المعامل والأشعة والأقسام'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000272)
,p_plug_name=>'القسم'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000273)
,p_name=>'P50_DEPT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000272)
,p_prompt=>'القسم (كل معمل ووحدة مستقلة)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' and dept_type not in (''CLINIC'', ''EMERGENCY'') order by dept_type, name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل الأقسام'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000274)
,p_name=>'P50_SHOW'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000272)
,p_prompt=>'العرض'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المطلوب والجاري;OPEN,المنجز اليوم;DONE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000275)
,p_plug_name=>'الطلبات'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.id, v.visit_no, p.name_ar as patient, p.mrn, case p.gender when ''M'' then ''ذكر'' else ''أنثى'' end as gender,',
'       trunc(months_between(sysdate, p.birth_date) / 12) as age, noona_his_pkg.service_name(s.id) as service, d.name_ar as dept,',
'       noona_his_pkg.modality_label(s.modality) as modality, o.sample_no, noona_his_pkg.order_status_label(o.status_code) as status,',
'       case when o.invoice_id is not null or v.visit_type in (''EMERGENCY'', ''INPATIENT'', ''DAY_CASE'') then ''نعم'' else ''لا'' end as paid,',
'       to_char(v.visit_at, ''YYYY-MM-DD HH24:MI'') as ordered_at, (select name_ar from his_doctor where id = o.ordered_by_id) as doctor',
'  from his_order o join his_visit v on v.id = o.visit_id join his_patient p on p.id = v.patient_id',
'  join his_service s on s.id = o.service_id join his_department d on d.id = o.department_id',
' where o.company_id = noona_his_pkg.company and d.dept_type not in (''CLINIC'', ''EMERGENCY'') and (:P50_DEPT is null or o.department_id = :P50_DEPT)',
'   and ((nvl(:P50_SHOW, ''OPEN'') = ''OPEN'' and o.status_code in (''ORDERED'', ''IN_PROGRESS'', ''APPROVAL_PENDING''))',
'        or (:P50_SHOW = ''DONE'' and o.status_code = ''COMPLETED'' and o.completed_at >= trunc(sysdate)))',
' order by v.visit_at'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الطلبات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000276)
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
,p_detail_link=>'f?p=&APP_ID.:51:&SESSION.::&DEBUG.:RP,51:P51_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820275000000276
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000278)
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
 p_id=>wwv_flow_imp.id(91820275000000279)
,p_db_column_name=>'VISIT_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الزيارة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000280)
,p_db_column_name=>'PATIENT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000281)
,p_db_column_name=>'MRN'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الرقم الطبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000282)
,p_db_column_name=>'GENDER'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الجنس'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000283)
,p_db_column_name=>'AGE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العمر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000284)
,p_db_column_name=>'SERVICE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Test / Exam'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000285)
,p_db_column_name=>'DEPT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000286)
,p_db_column_name=>'MODALITY'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الجهاز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000287)
,p_db_column_name=>'SAMPLE_NO'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'العينة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000288)
,p_db_column_name=>'STATUS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000289)
,p_db_column_name=>'PAID'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'مسدد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000290)
,p_db_column_name=>'ORDERED_AT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الطلب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000291)
,p_db_column_name=>'DOCTOR'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000277)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'277'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'VISIT_NO:PATIENT:MRN:GENDER:AGE:SERVICE:DEPT:MODALITY:SAMPLE_NO:STATUS:PAID:ORDERED_AT:DOCTOR'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000292)
,p_branch_action=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.::P50_DEPT,P50_SHOW:&P50_DEPT.,&P50_SHOW.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
