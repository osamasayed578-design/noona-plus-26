prompt --application/pages/page_00065
begin
--   Manifest
--     PAGE: 00065
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>127
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>65
,p_name=>'Asset Disposal'
,p_alias=>'ASSET-DISPOSAL'
,p_step_title=>'بيع وتخريد الأصول'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820266000000507)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'(function(){',
'  function show(n, on){ var el = document.getElementById(n + ''_CONTAINER''); if (el) el.style.display = on ? '''' : ''none''; }',
'  function sync(){',
'    var m = $v(''P65_METHOD'') || ''SALE'', r = $v(''P65_RECEIPT'') || ''BANK'', paid = m === ''SALE'' || m === ''SCRAP'' || m === ''TRADE_IN'';',
'    [''P65_PROCEEDS'', ''P65_RECEIPT''].forEach(function(n){ show(n, paid); });',
'    show(''P65_VAT'', paid && m !== ''TRADE_IN'');',
'    show(''P65_BANK'', paid && r === ''BANK''); show(''P65_BOX'', paid && r === ''CASH'');',
'    show(''P65_PARTY'', m === ''SALE'' || m === ''DONATION'' || m === ''TRADE_IN'' || r === ''RECEIVABLE'');',
'  }',
'  $(''#P65_PROCEEDS'').off(''change.nnfa'').on(''change.nnfa'', function(){',
'    var m = $v(''P65_METHOD''), v = parseFloat(($v(''P65_PROCEEDS'') || ''0'').replace(/,/g, ''''));',
'    if ((m === ''SALE'' || m === ''SCRAP'') && !isNaN(v)) $s(''P65_VAT'', (Math.round(v * 15) / 100).toFixed(2));',
'  });',
'  [''P65_METHOD'', ''P65_RECEIPT''].forEach(function(n){ $(''#'' + n).off(''change.nnfa'').on(''change.nnfa'', sync); });',
'  sync();',
'})();',
''))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000630)
,p_plug_name=>'استبعاد أصل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يلحق الإهلاك حتى تاريخ الاستبعاد، ثم يقفل تكلفة الأصل ومجمع إهلاكه ويثبت المتحصلات (بنك/صندوق/مدينو بيع الأصول) وضريبة المخرجات على البيع، والفرق ربح (4204) أو خسارة (5217).</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_fa_pkg.is_ready = ''Y'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000631)
,p_name=>'P65_ASSET'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الأصل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select asset_no || '' - '' || name_ar d, id r from fa_asset where company_id = noona_fa_pkg.company and status_code in (''IN_SERVICE'', ''CAPITALIZED'', ''FULLY_DEPRECIATED'') order by asset_no'
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
 p_id=>wwv_flow_imp.id(91820266000000632)
,p_name=>'P65_METHOD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'طريقة الاستبعاد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:بيع;SALE,تخريد (بيع خردة أو إتلاف);SCRAP,تبرع;DONATION,فقد أو تلف;LOSS,سرقة;THEFT,استبدال بأصل جديد;TRADE_IN'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000633)
,p_name=>'P65_DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'تاريخ الاستبعاد'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609122147107268652
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
 p_id=>wwv_flow_imp.id(91820266000000634)
,p_name=>'P65_PROCEEDS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'سعر البيع / المتحصلات (دون الضريبة)'
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
 p_id=>wwv_flow_imp.id(91820266000000635)
,p_name=>'P65_VAT'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'ضريبة القيمة المضافة (15% على البيع)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000636)
,p_name=>'P65_RECEIPT'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'التحصيل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:تحويل بنكي;BANK,نقداً في الصندوق;CASH,آجل على المشتري;RECEIVABLE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000637)
,p_name=>'P65_BANK'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الحساب البنكي'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_bank_account where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000638)
,p_name=>'P65_BOX'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'الصندوق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from csh_cash_box where company_id = noona_fa_pkg.company and status_code = ''ACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820266000000639)
,p_name=>'P65_PARTY'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'المشتري / الجهة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar || case when exists (select 1 from ap_supplier s where s.party_id = p.id) then '' (مورد)'' else '' (عميل)'' end d, p.id r from pty_party p where exists (select 1 from ap_supplier s where s.party_id = p.id) or exists (select 1 from ar_customer c where c.party_id = p.id) order by 1'
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
 p_id=>wwv_flow_imp.id(91820266000000640)
,p_name=>'P65_REASON'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_prompt=>'السبب والملاحظات'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000642)
,p_validation_name=>'P65_ASSET required (DISPOSE)'
,p_validation_sequence=>11
,p_validation=>'P65_ASSET'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000641)
,p_associated_item=>wwv_flow_imp.id(91820266000000631)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820266000000643)
,p_validation_name=>'P65_DATE required (DISPOSE)'
,p_validation_sequence=>12
,p_validation=>'P65_DATE'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820266000000641)
,p_associated_item=>wwv_flow_imp.id(91820266000000633)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820266000000641)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_button_name=>'DISPOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'ترحيل الاستبعاد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000644)
,p_plug_name=>'الأصل المختار'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P65_ASSET is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_b fa_asset_book%rowtype;',
'begin',
'    if :P65_ASSET is null then return null; end if;',
'    select * into l_b from fa_asset_book where asset_id = :P65_ASSET and book_id = noona_fa_pkg.default_book;',
'    return ''<div class="nn-hr-runbar">'' || apex_escape.html(noona_fa_pkg.asset_label(:P65_ASSET)) || '' · التكلفة ''',
'        || to_char(l_b.cost, ''FM999G999G990D00'') || '' · المجمع '' || to_char(l_b.accumulated_depr, ''FM999G999G990D00'')',
'        || '' · الصافي '' || to_char(l_b.cost - l_b.accumulated_depr, ''FM999G999G990D00'') || '' · إهلاك حتى تاريخ الاستبعاد ''',
'        || to_char(noona_fa_pkg.depreciation_for(l_b.id, to_date(:P65_DATE, ''YYYY-MM-DD'')), ''FM999G999G990D00'') || ''</div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000645)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P65_DATE := nvl(:P65_DATE, to_char(sysdate, ''YYYY-MM-DD''));',
'    :P65_METHOD := nvl(:P65_METHOD, ''SALE'');',
'    :P65_RECEIPT := nvl(:P65_RECEIPT, ''BANK'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820266000000645
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000646)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Dispose'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P65_DISPOSAL := noona_fa_pkg.dispose(:P65_ASSET, :P65_METHOD, to_date(:P65_DATE, ''YYYY-MM-DD''), :P65_PROCEEDS, :P65_VAT,',
'                                          :P65_RECEIPT, :P65_BANK, :P65_BOX, :P65_PARTY, :P65_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000641)
,p_process_success_message=>'تم ترحيل الاستبعاد وقيد الربح أو الخسارة'
,p_internal_uid=>91820266000000646
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000647)
,p_name=>'P65_DISPOSAL'
,p_item_sequence=>200
,p_item_plug_id=>wwv_flow_imp.id(91820266000000630)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000648)
,p_plug_name=>'عكس استبعاد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يعكس قيد الاستبعاد ويعيد الأصل إلى الخدمة بأرصدته السابقة.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820266000000649)
,p_name=>'P65_REV'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820266000000648)
,p_prompt=>'الاستبعاد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.doc_no || '' · '' || a.asset_no || '' - '' || a.name_ar || '' · '' || noona_fa_pkg.disposal_label(d.disposal_method) d, d.id r from fa_disposal d join fa_asset a on a.id = d.asset_id where d.company_id = noona_fa_pkg.company and d.status_code = ''POSTED'' order by d.disposal_date desc'
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
 p_id=>wwv_flow_imp.id(91820266000000650)
,p_name=>'P65_REV_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820266000000648)
,p_prompt=>'سبب العكس'
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
 p_id=>wwv_flow_imp.id(91820266000000651)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820266000000648)
,p_button_name=>'REVERSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'عكس الاستبعاد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820266000000652)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reverse'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_j number;',
'begin',
'    l_j := noona_fa_pkg.reverse_disposal(:P65_REV, :P65_REV_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820266000000651)
,p_process_success_message=>'تم عكس الاستبعاد وإعادة الأصل إلى الخدمة'
,p_internal_uid=>91820266000000652
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820266000000653)
,p_plug_name=>'الاستبعادات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.doc_no, to_char(d.disposal_date, ''YYYY-MM-DD'') as d_date, a.asset_no, a.name_ar as asset,',
'       noona_fa_pkg.disposal_label(d.disposal_method) as method, pt.display_name_ar as party, d.proceeds, d.vat_amount,',
'       d.nbv_at_disposal, d.gain_loss, noona_fa_pkg.status_label(d.status_code) as status, d.reason',
'  from fa_disposal d join fa_asset a on a.id = d.asset_id left join pty_party pt on pt.id = d.buyer_party_id',
' where d.company_id = noona_fa_pkg.company order by d.disposal_date desc, d.id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الاستبعادات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820266000000654)
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
,p_internal_uid=>91820266000000654
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000656)
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
 p_id=>wwv_flow_imp.id(91820266000000657)
,p_db_column_name=>'DOC_NO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المستند'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000658)
,p_db_column_name=>'D_DATE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'التاريخ'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000659)
,p_db_column_name=>'ASSET_NO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'رقم الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000660)
,p_db_column_name=>'ASSET'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الأصل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000661)
,p_db_column_name=>'METHOD'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الطريقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000662)
,p_db_column_name=>'PARTY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'الطرف'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000663)
,p_db_column_name=>'PROCEEDS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'المتحصلات'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000664)
,p_db_column_name=>'VAT_AMOUNT'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الضريبة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000665)
,p_db_column_name=>'NBV_AT_DISPOSAL'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'الصافي عند الاستبعاد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000666)
,p_db_column_name=>'GAIN_LOSS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'ربح / خسارة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000667)
,p_db_column_name=>'STATUS'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820266000000668)
,p_db_column_name=>'REASON'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'السبب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820266000000655)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'655'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DOC_NO:D_DATE:ASSET_NO:ASSET:METHOD:PARTY:PROCEEDS:VAT_AMOUNT:NBV_AT_DISPOSAL:GAIN_LOSS:STATUS:REASON'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000669)
,p_branch_action=>'f?p=&APP_ID.:61:&SESSION.::&DEBUG.:RP,61:P61_ID:&P65_ASSET.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>5
,p_branch_when_button_id=>wwv_flow_imp.id(91820266000000641)
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820266000000670)
,p_branch_action=>'f?p=&APP_ID.:65:&SESSION.::&DEBUG.::P65_ASSET:&P65_ASSET.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
