prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>145
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'Job Cards'
,p_alias=>'JOB-CARDS'
,p_step_title=>'أوامر الإصلاح'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000063)
,p_plug_name=>'إجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000064)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000063)
,p_button_name=>'NEW'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'استلام سيارة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:RP,2::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000065)
,p_plug_name=>'أوامر الإصلاح'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select j.id, j.doc_no, to_char(j.checkin_at, ''YYYY-MM-DD HH24:MI'') as checkin, noona_aut_pkg.plate_label(v.plate_no) as plate_no, v.make || '' '' || v.model as vehicle, j.customer_name,',
'       j.customer_phone, case j.payer_type when ''INSURANCE'' then ''تأمين'' when ''WARRANTY'' then ''ضمان'' when ''INTERNAL'' then ''داخلي'' else ''العميل'' end as payer,',
'       (select name_ar from aut_insurer where id = j.insurer_id) as insurer, j.claim_no,',
'       (select listagg(distinct t.name_ar, ''، '') within group (order by t.name_ar) from aut_job_line l join aut_technician t on t.id = l.technician_id',
'         where l.job_card_id = j.id) as techs,',
'       j.services_amount, j.parts_amount, j.total_amount,',
'       round((cast(nvl(j.delivered_at, systimestamp) as date) - cast(j.checkin_at as date)) * 24, 1) as hours,',
'       case j.status_code when ''OPEN'' then ''مفتوح'' when ''IN_PROGRESS'' then ''قيد العمل'' when ''WAITING_PARTS'' then ''بانتظار قطع'' when ''COMPLETED'' then ''جاهز'' when ''INVOICED'' then ''مفوتر'' when ''DELIVERED'' then ''مسلم'' when ''CANCELLED'' then ''ملغى'' end as status, (select doc_no from sal_invoice where id = j.sales_invoice_id) as invoice_no',
'  from aut_job_card j join aut_vehicle v on v.id = j.vehicle_id where j.company_id = noona_aut_pkg.company order by j.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'أوامر الإصلاح'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000066)
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
,p_detail_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:RP,3:P3_ID:#ID#'
,p_detail_link_text=>'<span role="img" aria-label="تعديل" class="fa fa-edit" title="فتح"></span>'
,p_owner=>'NOONA'
,p_internal_uid=>91820280000000066
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000068)
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
 p_id=>wwv_flow_imp.id(91820280000000069)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الأمر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000070)
,p_db_column_name=>'CHECKIN'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الاستلام'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000071)
,p_db_column_name=>'PLATE_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'اللوحة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000072)
,p_db_column_name=>'VEHICLE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'المركبة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000073)
,p_db_column_name=>'CUSTOMER_NAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000074)
,p_db_column_name=>'CUSTOMER_PHONE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الجوال'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000075)
,p_db_column_name=>'PAYER'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'السداد'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000076)
,p_db_column_name=>'INSURER'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'التأمين'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000077)
,p_db_column_name=>'CLAIM_NO'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'المطالبة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000078)
,p_db_column_name=>'TECHS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'الفنيون'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000079)
,p_db_column_name=>'SERVICES_AMOUNT'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الخدمات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000080)
,p_db_column_name=>'PARTS_AMOUNT'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'القطع'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000081)
,p_db_column_name=>'TOTAL_AMOUNT'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'الإجمالي'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000082)
,p_db_column_name=>'HOURS'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'ساعات البقاء'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000083)
,p_db_column_name=>'STATUS'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000084)
,p_db_column_name=>'INVOICE_NO'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'الفاتورة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000067)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'67'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:CHECKIN:PLATE_NO:VEHICLE:CUSTOMER_NAME:CUSTOMER_PHONE:PAYER:INSURER:CLAIM_NO:TECHS:SERVICES_AMOUNT:PARTS_AMOUNT:TOTAL_AMOUNT:HOURS:STATUS:INVOICE_NO'
);

wwv_flow_imp.component_end;
end;
/
