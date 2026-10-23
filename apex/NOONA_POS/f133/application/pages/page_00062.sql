prompt --application/pages/page_00062
begin
--   Manifest
--     PAGE: 00062
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
 p_id=>62
,p_name=>'Kitchen Display'
,p_alias=>'KITCHEN'
,p_step_title=>'شاشة المطبخ'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820269000000002)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''rst.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000253)
,p_plug_name=>'نقطة البيع'
,p_region_template_options=>'#DEFAULT#:nn-rpt-filters:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820269000000254)
,p_name=>'P62_TERM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820269000000253)
,p_prompt=>'نقطة البيع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from pos_terminal where company_id = noona_rst_pkg.company and status_code = ''ACTIVE'' order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'كل نقاط البيع'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820269000000255)
,p_plug_name=>'المطبخ'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="nnRst" class="nn-rst" data-mode="kitchen" data-term="'' || :P62_TERM || ''"></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820269000000256)
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
,p_internal_uid=>91820269000000256
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820269000000257)
,p_branch_action=>'f?p=&APP_ID.:62:&SESSION.::&DEBUG.::P62_TERM:&P62_TERM.'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
