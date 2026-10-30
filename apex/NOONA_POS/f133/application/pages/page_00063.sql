prompt --application/pages/page_00063
begin
--   Manifest
--     PAGE: 00063
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>133
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>63
,p_name=>'Credit Customers'
,p_alias=>'RESTAURANT-CREDIT'
,p_step_title=>'العملاء الآجلون والتحصيل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''rst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000261)
,p_plug_name=>'العملاء الآجلون'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="nnRst" class="nn-rst" data-mode="credit"></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000262)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'RST'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c  clob;',
'    l_h  clob;',
'    l_id number;',
'    l_op varchar2(30) := apex_application.g_x01;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'    function d(p varchar2) return date is begin return to_date(p, ''YYYY-MM-DD''); end;',
'    procedure out(p clob) is',
'        l_off pls_integer := 1;',
'    begin',
'        while l_off <= dbms_lob.getlength(p) loop',
'            htp.prn(dbms_lob.substr(p, 8000, l_off));',
'            l_off := l_off + 8000;',
'        end loop;',
'    end;',
'begin',
'    case l_op',
'        when ''FLOOR'' then l_c := noona_rst_pkg.floor_json(n(apex_application.g_x02));',
'        when ''OPEN'' then l_id := noona_rst_pkg.open_order(apex_application.g_clob_01); l_c := ''{"id":'' || l_id || ''}'';',
'        when ''ORDER'' then l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));',
'        when ''ADD'' then noona_rst_pkg.add_items(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));',
'        when ''QTY'' then noona_rst_pkg.set_qty(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x04));',
'        when ''VOID'' then noona_rst_pkg.void_line(n(apex_application.g_x02), apex_application.g_x03);',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x04));',
'        when ''UPD'' then noona_rst_pkg.update_order(apex_application.g_clob_01);',
'            l_c := noona_rst_pkg.order_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''SEND'' then l_id := noona_rst_pkg.send_kitchen(n(apex_application.g_x02));',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));',
'        when ''MOVE'' then noona_rst_pkg.move_table(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x02));',
'        when ''MERGE'' then noona_rst_pkg.merge_orders(n(apex_application.g_x02), n(apex_application.g_x03));',
'            l_c := noona_rst_pkg.order_json(n(apex_application.g_x03));',
'        when ''SPLIT'' then l_id := noona_rst_pkg.split_order(n(apex_application.g_x02), apex_application.g_clob_01);',
'            l_c := ''{"id":'' || l_id || ''}'';',
'        when ''CANCEL'' then noona_rst_pkg.cancel_order(n(apex_application.g_x02), apex_application.g_x03);',
'        when ''BILL'' then l_h := noona_rst_pkg.bill_html(n(apex_application.g_x02), n(apex_application.g_x03));',
'            select json_object(''html'' value l_h returning clob) into l_c from dual;',
'        when ''DUE'' then l_c := ''{"due":'' || to_char(noona_rst_pkg.orders_total(apex_application.g_x02), ''FM9999999990D00'',',
'                                 ''NLS_NUMERIC_CHARACTERS=''''.,'''''') || ''}'';',
'        when ''SETTLE'' then l_c := noona_rst_pkg.settle(apex_application.g_clob_01);',
'        when ''CUSTS'' then l_c := ''{"list":'' || noona_rst_pkg.credit_customers_json(apex_application.g_x02) || ''}'';',
'        when ''NEWCUST'' then l_id := noona_rst_pkg.quick_customer(apex_application.g_x02, apex_application.g_x03, n(apex_application.g_x04));',
'            l_c := ''{"id":'' || l_id || ''}'';',
'        when ''KITCHEN'' then l_c := ''{"list":'' || noona_rst_pkg.kitchen_json(n(apex_application.g_x02)) || ''}'';',
'        when ''KREADY'' then noona_rst_pkg.kitchen_ready(n(apex_application.g_x02), n(apex_application.g_x03));',
'        when ''KSERVED'' then noona_rst_pkg.kitchen_served(n(apex_application.g_x02));',
'        when ''CREDIT'' then l_h := noona_rst_pkg.credit_html(apex_application.g_x02);',
'            select json_object(''html'' value l_h returning clob) into l_c from dual;',
'        when ''COLLECT'' then l_id := noona_rst_pkg.collect(apex_application.g_clob_01);',
'            select json_object(''id'' value id, ''no'' value doc_no returning clob) into l_c from ar_receipt where id = l_id;',
'        when ''STMT'' then l_h := noona_sal_pkg.customer_statement(n(apex_application.g_x02), d(apex_application.g_x03), d(apex_application.g_x04));',
'            select json_object(''html'' value l_h returning clob) into l_c from dual;',
'        else raise_application_error(-20500, ''NOONA-RST-099: عملية غير معروفة '' || l_op);',
'    end case;',
'    out(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820269000000262
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000263)
,p_plug_name=>'آخر سندات التحصيل'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, r.doc_no, r.doc_date, noona_sal_pkg.customer_label(r.customer_account_id) as cust, m.name_ar as method, r.amount,',
'       r.external_reference, case r.status_code when ''CONFIRMED'' then ''مؤكد'' when ''REVERSED'' then ''معكوس'' else r.status_code end as status',
'  from ar_receipt r left join ref_payment_method m on m.id = r.payment_method_id',
' where r.company_id = noona_rst_pkg.company',
'   and r.customer_account_id in (select customer_account_id from rst_order where status_code = ''CHARGED'')',
' order by r.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'آخر سندات التحصيل'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820269000000264)
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
,p_internal_uid=>91820269000000264
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000266)
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
 p_id=>wwv_flow_imp.id(91820269000000267)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'السند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000268)
,p_db_column_name=>'DOC_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000269)
,p_db_column_name=>'CUST'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'العميل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000270)
,p_db_column_name=>'METHOD'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000271)
,p_db_column_name=>'AMOUNT'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000272)
,p_db_column_name=>'EXTERNAL_REFERENCE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'المرجع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820269000000273)
,p_db_column_name=>'STATUS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820269000000265)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'265'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:DOC_DATE:CUST:METHOD:AMOUNT:EXTERNAL_REFERENCE:STATUS'
);

wwv_flow_imp.component_end;
end;
/
