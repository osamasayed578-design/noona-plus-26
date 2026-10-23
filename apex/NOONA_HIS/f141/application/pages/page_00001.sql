prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'المستشفى'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000010)
,p_plug_name=>'تجهيز المستشفى'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">ينشئ حسابات الإيرادات الطبية (4120-4127) وذمم شركات التأمين (1114) والمرضى (1115) والترقيم، وأقساماً نموذجية: عيادات، طوارئ، خمسة معامل منفصلة بمستودعاتها، أشعة عادية ومقطعية ورنين وموجات، تشخيص القلب، علاج طبيعي، غسيل كلوي، عمليات، تنويم، صيدلية داخلية، ودليل خدمات بأسعار مبدئية قابلة للتعديل.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_ready = ''N'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000011)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000010)
,p_button_name=>'SETUP'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تجهيز المستشفى'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000012)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Setup'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_n number;',
'begin',
'    l_n := noona_his_pkg.seed_catalog;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000011)
,p_process_success_message=>'تم تجهيز المستشفى: الحسابات والأقسام ودليل الخدمات'
,p_internal_uid=>91820275000000012
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000013)
,p_plug_name=>'اليوم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_his_pkg.summary_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000014)
,p_plug_name=>'إجراءات سريعة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_his_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000015)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'NEW_PAT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مريض جديد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000016)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'BOOK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حجز موعد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:RP,21::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000017)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'BOARD'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'لوحة المواعيد'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000018)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'NEW_VISIT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'زيارة جديدة (حضور مباشر)'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:RP,32::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000019)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'CASHIER'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'المحاسبة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000020)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820275000000014)
,p_button_name=>'WORK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'قوائم المعامل والأشعة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:50:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000021)
,p_plug_name=>'مواعيد اليوم'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select a.id, a.start_time, p.name_ar as patient, p.mrn, p.mobile, d.name_ar as doctor, dp.name_ar as dept,',
'       noona_his_pkg.appt_status_label(a.status_code) as status',
'  from his_appointment a join his_patient p on p.id = a.patient_id left join his_doctor d on d.id = a.doctor_id',
'  join his_department dp on dp.id = a.department_id',
' where a.company_id = noona_his_pkg.company and a.appt_date = trunc(sysdate) and a.status_code <> ''CANCELLED'' order by a.start_time'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مواعيد اليوم'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000022)
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
,p_detail_link=>'f?p=&APP_ID.:22:&SESSION.::&DEBUG.:RP,22:P22_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820275000000022
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000024)
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
 p_id=>wwv_flow_imp.id(91820275000000025)
,p_db_column_name=>'START_TIME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000026)
,p_db_column_name=>'PATIENT'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المريض'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000027)
,p_db_column_name=>'MRN'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الرقم الطبي'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000028)
,p_db_column_name=>'MOBILE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000029)
,p_db_column_name=>'DOCTOR'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000030)
,p_db_column_name=>'DEPT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'العيادة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000031)
,p_db_column_name=>'STATUS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000023)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'23'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'START_TIME:PATIENT:MRN:MOBILE:DOCTOR:DEPT:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000032)
,p_branch_action=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
