prompt --application/pages/page_00021
begin
--   Manifest
--     PAGE: 00021
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
 p_id=>21
,p_name=>'Cost Sheets'
,p_alias=>'COST-SHEETS'
,p_step_title=>'بطاقات التكلفة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820280000000010)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000368)
,p_plug_name=>'الخدمة أو الصنف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">تكلفة الخدمة = موادها المعرفة في دليل الخدمات (الكواشف والمستلزمات أو القطع) + العناصر الإضافية هنا: مواد أخرى، عمالة (دقائق × تكلفة الساعة)، أعباء ثابتة، أو أعباء نسبة من التكلفة المباشرة. وللمنتج التام يمكن تفصيل تكلفته هنا إن لم يكن من التصنيع.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000369)
,p_name=>'P21_TARGET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000368)
,p_prompt=>'الخدمة أو الصنف'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'with z (d, r, o) as (select ''صنف: '' || i.item_no || '' - '' || i.name_ar || '' ('' || to_char(nvl(c.sale_price, 0), ''FM999,990.00'') || '')'', ''ITEM-'' || i.id, 3 from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' union all select ''خدمة سيارات: '' || code || '' - '' || name_ar || '' ('' || to_char(price, ''FM999,990.00'') || '')'', ''AUT_SERVICE-'' || id, 9 from aut_service where company_id = noona_prc_pkg.company and is_active = ''Y'') select d, r from z order by o, d'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000370)
,p_plug_name=>'بطاقة التكلفة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_TARGET is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    return noona_prc_pkg.cost_html(regexp_substr(:P21_TARGET, ''^[A-Z_]+''), to_number(regexp_substr(:P21_TARGET, ''[0-9]+$'')));',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000371)
,p_plug_name=>'العناصر الإضافية'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>25
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select e.id, case e.element_type when ''MATERIAL'' then ''مادة'' when ''LABOR'' then ''عمالة'' when ''OVERHEAD_AMOUNT'' then ''أعباء ثابتة''',
'            when ''OVERHEAD_PCT'' then ''أعباء نسبية'' else ''أخرى'' end as kind, e.description, i.name_ar as item, e.quantity, e.minutes,',
'       e.hourly_rate, e.amount, e.pct',
'  from sal_cost_element e left join inv_item i on i.id = e.item_id',
' where e.company_id = noona_prc_pkg.company and e.target_type || ''-'' || e.target_id = :P21_TARGET order by e.sort_order, e.id'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'العناصر الإضافية'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820280000000372)
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
,p_internal_uid=>91820280000000372
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000374)
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
 p_id=>wwv_flow_imp.id(91820280000000375)
,p_db_column_name=>'KIND'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'العنصر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000376)
,p_db_column_name=>'DESCRIPTION'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'البيان'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000377)
,p_db_column_name=>'ITEM'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'المادة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000378)
,p_db_column_name=>'QUANTITY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000379)
,p_db_column_name=>'MINUTES'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الدقائق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000380)
,p_db_column_name=>'HOURLY_RATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'تكلفة الساعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000381)
,p_db_column_name=>'AMOUNT'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المبلغ'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820280000000382)
,p_db_column_name=>'PCT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'النسبة %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820280000000373)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'373'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'KIND:DESCRIPTION:ITEM:QUANTITY:MINUTES:HOURLY_RATE:AMOUNT:PCT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000383)
,p_plug_name=>'إضافة عنصر تكلفة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_TARGET is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000384)
,p_name=>'P21_ET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'نوع العنصر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عمالة (دقائق × تكلفة الساعة);LABOR,مادة مستهلكة;MATERIAL,أعباء ثابتة (مبلغ);OVERHEAD_AMOUNT,أعباء نسبة من التكلفة المباشرة;OVERHEAD_PCT,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000385)
,p_name=>'P21_DESC'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'البيان (مثل: وقت الطبيب، تشغيل الجهاز)'
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
 p_id=>wwv_flow_imp.id(91820280000000386)
,p_name=>'P21_ITEM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'المادة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.item_no || '' - '' || i.name_ar d, i.id r from inv_item i join inv_item_company c on c.item_id = i.id where c.company_id = noona_prc_pkg.company and i.status_code = ''ACTIVE'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820280000000387)
,p_name=>'P21_QTY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'الكمية'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000388)
,p_name=>'P21_MIN'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'الدقائق'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000389)
,p_name=>'P21_RATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'تكلفة الساعة'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000390)
,p_name=>'P21_AMT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'المبلغ'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000391)
,p_name=>'P21_PCT'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_prompt=>'النسبة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000392)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000383)
,p_button_name=>'ADD_ELEMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إضافة العنصر'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000393)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Element'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l number;',
'    l_j clob;',
'begin',
'    select json_object(''targetType'' value regexp_substr(:P21_TARGET, ''^[A-Z_]+''),',
'           ''targetId'' value to_number(regexp_substr(:P21_TARGET, ''[0-9]+$'')), ''type'' value :P21_ET,',
'           ''desc'' value :P21_DESC, ''itemId'' value to_number(:P21_ITEM), ''qty'' value to_number(:P21_QTY),',
'           ''minutes'' value to_number(:P21_MIN), ''rate'' value to_number(:P21_RATE), ''amount'' value to_number(:P21_AMT),',
'           ''pct'' value to_number(:P21_PCT) absent on null) into l_j from dual;',
'    l := noona_prc_pkg.save_cost_element(l_j);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000392)
,p_process_success_message=>'تمت إضافة عنصر التكلفة'
,p_internal_uid=>91820280000000393
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820280000000394)
,p_plug_name=>'حذف عنصر'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P21_TARGET is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820280000000395)
,p_name=>'P21_DEL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820280000000394)
,p_prompt=>'العنصر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(description, element_type) || '' #'' || id d, id r from sal_cost_element where company_id = noona_prc_pkg.company and target_type || ''-'' || target_id = :P21_TARGET order by id'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820280000000396)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820280000000394)
,p_button_name=>'DEL_ELEMENT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حذف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820280000000397)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete Element'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prc_pkg.delete_cost_element(:P21_DEL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820280000000396)
,p_process_success_message=>'تم الحذف'
,p_internal_uid=>91820280000000397
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820280000000398)
,p_branch_action=>'f?p=&APP_ID.:21:&SESSION.::&DEBUG.:21:P21_TARGET:&P21_TARGET.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
