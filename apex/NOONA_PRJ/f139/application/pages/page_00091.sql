prompt --application/pages/page_00091
begin
--   Manifest
--     PAGE: 00091
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>139
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>91
,p_name=>'Contract Revenue'
,p_alias=>'CONTRACT-REVENUE'
,p_step_title=>'الاعتراف بإيراد العقود حسب نسبة الإنجاز'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000758)
,p_plug_name=>'الاعتراف بالإيراد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">للمشروعات بطريقة «نسبة الإنجاز»: الإيراد المستحق = نسبة الإنجاز × (قيمة العقد − الغرامات)، ويقارن بالمفوتر بالمستخلصات. الزيادة تسجل <b>أصول عقود</b> (إيراد غير مفوتر) والنقص <b>التزامات عقود</b>، ويرحل الفرق عن آخر اعتراف بقيد تسوية. إن زادت التكلفة المتوقعة على قيمة العقد يثبت <b>مخصص</b> لخسارته المتبقية فوراً.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000759)
,p_name=>'P91_PROJECT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000758)
,p_prompt=>'المشروع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from prj_project where company_id = noona_prj_pkg.company and revenue_method in (''COST_TO_COST'', ''PERCENT_COMPLETE'') and status_code not in (''CANCELLED'') order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000760)
,p_name=>'P91_END'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000758)
,p_prompt=>'نهاية الفترة'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000761)
,p_name=>'P91_EAC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000758)
,p_prompt=>'التكلفة المتوقعة عند الإنجاز (آخر تقدير)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000763)
,p_validation_name=>'P91_PROJECT required (PREVIEW)'
,p_validation_sequence=>4
,p_validation=>'P91_PROJECT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000762)
,p_associated_item=>wwv_flow_imp.id(91820273000000759)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000762)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000758)
,p_button_name=>'PREVIEW'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'معاينة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000765)
,p_validation_name=>'P91_PROJECT required (RUN)'
,p_validation_sequence=>6
,p_validation=>'P91_PROJECT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000764)
,p_associated_item=>wwv_flow_imp.id(91820273000000759)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000764)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000758)
,p_button_name=>'RUN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتراف بالإيراد وترحيل'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000766)
,p_plug_name=>'المعاينة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P91_PROJECT is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; l_t varchar2(4000);',
'begin',
'    if :P91_PROJECT is null then return ''<div class="nn-empty">اختر المشروع</div>''; end if;',
'    l := noona_prj_ctr_pkg.preview_json(:P91_PROJECT, to_date(:P91_END, ''YYYY-MM-DD''), to_number(:P91_EAC));',
'    return ''<div class="nn-prj-fc">'' ||',
'      ''<div><small>قيمة العقد</small><b>'' || to_char(json_value(l, ''$.contractValue'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>غرامات التأخير</small><b>'' || to_char(json_value(l, ''$.penalties'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>التكلفة المتوقعة</small><b>'' || to_char(json_value(l, ''$.eac'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>التكلفة حتى تاريخه</small><b>'' || to_char(json_value(l, ''$.costToDate'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>نسبة الإنجاز</small><b>'' || to_char(json_value(l, ''$.poc'' returning number), ''FM990.00'') || ''%</b></div>'' ||',
'      ''<div><small>الإيراد المستحق</small><b>'' || to_char(json_value(l, ''$.revenueToDate'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>المفوتر بالمستخلصات</small><b>'' || to_char(json_value(l, ''$.billedToDate'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>أصول العقود</small><b>'' || to_char(json_value(l, ''$.contractAsset'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>التزامات العقود</small><b>'' || to_char(json_value(l, ''$.contractLiability'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>الربح المتوقع</small><b>'' || to_char(json_value(l, ''$.expectedProfit'' returning number), ''FM999,999,999,990.00'') || ''</b></div>'' ||',
'      ''<div><small>مخصص الخسارة</small><b>'' || to_char(json_value(l, ''$.lossProvision'' returning number), ''FM999,999,999,990.00'') || ''</b></div></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000767)
,p_plug_name=>'تشغيلات الاعتراف بالإيراد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select r.id, p.code || '' - '' || p.name_ar project, r.period_end, r.poc_pct, r.contract_value, r.estimated_total_cost, r.cost_to_date,',
'       r.revenue_to_date, r.billed_to_date, r.contract_asset, r.contract_liability, r.loss_provision,',
'       case r.status_code when ''POSTED'' then ''مرحل'' else ''معكوس'' end status',
'  from prj_revenue_run r join prj_project p on p.id = r.project_id where r.company_id = noona_prj_pkg.company'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'تشغيلات الاعتراف بالإيراد'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820273000000768)
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
,p_internal_uid=>91820273000000768
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000770)
,p_db_column_name=>'ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'ID'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000771)
,p_db_column_name=>'PROJECT'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المشروع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000772)
,p_db_column_name=>'PERIOD_END'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'نهاية الفترة'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000773)
,p_db_column_name=>'POC_PCT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الإنجاز %'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000774)
,p_db_column_name=>'CONTRACT_VALUE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'قيمة العقد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000775)
,p_db_column_name=>'ESTIMATED_TOTAL_COST'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'التكلفة المتوقعة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000776)
,p_db_column_name=>'COST_TO_DATE'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'التكلفة حتى تاريخه'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000777)
,p_db_column_name=>'REVENUE_TO_DATE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'الإيراد المستحق'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000778)
,p_db_column_name=>'BILLED_TO_DATE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'المفوتر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000779)
,p_db_column_name=>'CONTRACT_ASSET'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'أصول العقود'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000780)
,p_db_column_name=>'CONTRACT_LIABILITY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'التزامات العقود'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000781)
,p_db_column_name=>'LOSS_PROVISION'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'مخصص الخسارة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820273000000782)
,p_db_column_name=>'STATUS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820273000000769)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'769'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PROJECT:PERIOD_END:POC_PCT:CONTRACT_VALUE:ESTIMATED_TOTAL_COST:COST_TO_DATE:REVENUE_TO_DATE:BILLED_TO_DATE:CONTRACT_ASSET:CONTRACT_LIABILITY:LOSS_PROVISION:STATUS'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000783)
,p_plug_name=>'عكس آخر اعتراف (لتصحيح التقدير)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000784)
,p_name=>'P91_RUN'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000783)
,p_prompt=>'التشغيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.code || '' - '' || to_char(r.period_end, ''YYYY-MM-DD'') d, r.id r from prj_revenue_run r join prj_project p on p.id = r.project_id where r.company_id = noona_prj_pkg.company and r.status_code = ''POSTED'' and not exists (select 1 from prj_revenue_run x where x.project_id = r.project_id and x.status_code = ''POSTED'' and x.period_end > r.period_end) order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000785)
,p_name=>'P91_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000783)
,p_prompt=>'السبب'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>500
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000786)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000783)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس الاعتراف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000787)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P91_END := nvl(:P91_END, to_char(last_day(add_months(sysdate, -1)), ''YYYY-MM-DD''));',
'if :P91_PROJECT is not null and :P91_EAC is null then',
'    select estimated_total_cost into :P91_EAC from prj_project where id = :P91_PROJECT;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000787
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000788)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Run'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_prj_ctr_pkg.run_revenue(:P91_PROJECT, to_date(:P91_END, ''YYYY-MM-DD''), to_number(:P91_EAC));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000764)
,p_process_success_message=>'تم الاعتراف بالإيراد وترحيل قيد التسوية'
,p_internal_uid=>91820273000000788
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000789)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_ctr_pkg.reverse_run(:P91_RUN, :P91_REASON); :P91_REASON := null;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000786)
,p_process_success_message=>'تم عكس الاعتراف؛ عدل التقدير ثم أعد التشغيل'
,p_internal_uid=>91820273000000789
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000790)
,p_branch_action=>'f?p=&APP_ID.:91:&SESSION.::&DEBUG.:91:P91_PROJECT,P91_END,P91_EAC:&P91_PROJECT.,&P91_END.,&P91_EAC.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
