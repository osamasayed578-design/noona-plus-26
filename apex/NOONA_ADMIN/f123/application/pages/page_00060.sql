prompt --application/pages/page_00060
begin
--   Manifest
--     PAGE: 00060
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
 p_id=>60
,p_name=>'Audit Log'
,p_alias=>'AUDIT'
,p_step_title=>'سجل التدقيق'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000672)
,p_plug_name=>'سلامة السجل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_bad number := noona_audit_pkg.verify_chain(to_number(sys_context(''NOONA_CTX'', ''TENANT_ID'')));',
'    l_n   number;',
'begin',
'    select count(*) into l_n from aud_event;',
'    if l_bad is null then',
'        return ''<div class="nn-chain is-ok"><span class="fa fa-shield" aria-hidden="true"></span><div><b>سجل التدقيق سليم</b>''',
'            || ''<small>تم التحقق من سلسلة التجزئة لعدد '' || l_n || '' حدث؛ لم يعدل أو يحذف أي حدث</small></div></div>'';',
'    end if;',
'    return ''<div class="nn-chain is-bad"><span class="fa fa-exclamation-triangle" aria-hidden="true"></span><div><b>تحذير: انقطاع في سلسلة التدقيق</b>''',
'        || ''<small>أول حدث غير مطابق رقم '' || l_bad || ''؛ أبلغ مسؤول المنصة فوراً</small></div></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000673)
,p_plug_name=>'سجل التدقيق'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select e.id, to_char(e.occurred_at, ''YYYY-MM-DD HH24:MI:SS'') as occurred_at, noona_ui_pkg.code_label(e.event_category) as category,',
'       nvl(et.name_ar, e.entity_type) as entity_type, e.entity_id,',
'       e.action_code, noona_ui_pkg.status_badge(e.result_code) as result_html,',
'       (select u.display_name from sec_user u where u.id = e.actor_user_id) as actor,',
'       (select nvl(c.trade_name_ar, c.legal_name_ar) from org_company c where c.id = e.company_id) as company_name,',
'       e.reason, e.ip_address, e.request_source',
'  from aud_event e left join ref_entity_type et on et.entity_type_code = e.entity_type order by e.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'سجل التدقيق'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820262000000674)
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
,p_internal_uid=>91820262000000674
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000676)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'رقم الحدث'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000677)
,p_db_column_name=>'OCCURRED_AT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الوقت'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000678)
,p_db_column_name=>'CATEGORY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الفئة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000679)
,p_db_column_name=>'ENTITY_TYPE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الكيان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000680)
,p_db_column_name=>'ENTITY_ID'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'رقمه'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000681)
,p_db_column_name=>'ACTION_CODE'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الإجراء'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000682)
,p_db_column_name=>'RESULT_HTML'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'النتيجة'
,p_column_type=>'STRING'
,p_display_text_as=>'WITHOUT_MODIFICATION'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000683)
,p_db_column_name=>'ACTOR'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المستخدم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000684)
,p_db_column_name=>'COMPANY_NAME'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الشركة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000685)
,p_db_column_name=>'REASON'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000686)
,p_db_column_name=>'IP_ADDRESS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'عنوان IP'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820262000000687)
,p_db_column_name=>'REQUEST_SOURCE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'المصدر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820262000000675)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'675'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID:OCCURRED_AT:CATEGORY:ENTITY_TYPE:ENTITY_ID:ACTION_CODE:RESULT_HTML:ACTOR:COMPANY_NAME:REASON:IP_ADDRESS:REQUEST_SOURCE'
);

wwv_flow_imp.component_end;
end;
/
