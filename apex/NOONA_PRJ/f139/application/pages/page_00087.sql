prompt --application/pages/page_00087
begin
--   Manifest
--     PAGE: 00087
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
 p_id=>87
,p_name=>'Contract'
,p_alias=>'CONTRACT'
,p_step_title=>'العقد وجدول الكميات'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000563)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'(function () { var s = document.createElement(''script''); s.src = apex.env.APP_FILES + ''prj.js''; document.head.appendChild(s); })();'))
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000678)
,p_plug_name=>'العقد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P87_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_pkg.contract_html(:P87_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000679)
,p_plug_name=>'بيانات العقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'nvl(noona_prj_pkg.contract_status(:P87_ID), ''DRAFT'') = ''DRAFT'''
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000680)
,p_name=>'P87_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000681)
,p_name=>'P87_PROJECT'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000682)
,p_name=>'P87_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'نوع العقد'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:العقد الرئيسي مع العميل (المالك);MAIN_CONTRACT,عقد مقاول باطن;SUBCONTRACT'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000683)
,p_name=>'P87_NO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'رقم العقد (فارغ = تلقائي)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
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
 p_id=>wwv_flow_imp.id(91820273000000684)
,p_name=>'P87_CUSTOMER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'العميل (المالك)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, a.id r from ar_customer_account a join ar_customer c on c.id = a.customer_id join pty_party p on p.id = c.party_id where a.company_id = noona_prj_pkg.company and a.status_code = ''ACTIVE'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000685)
,p_name=>'P87_SUPPLIER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'مقاول الباطن'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.display_name_ar d, a.id r from ap_supplier_account a join ap_supplier s on s.id = a.supplier_id join pty_party p on p.id = s.party_id where a.company_id = noona_prj_pkg.company and a.status_code = ''ACTIVE'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820273000000686)
,p_name=>'P87_PRICING'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'التسعير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:إعادة قياس (بالكميات المنفذة);REMEASURED,مبلغ مقطوع;LUMP_SUM,سعر الوحدة;UNIT_RATE,التكلفة زائد ربح;COST_PLUS'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000687)
,p_name=>'P87_VALUE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'قيمة العقد (إن لم يدخل جدول كميات)'
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
 p_id=>wwv_flow_imp.id(91820273000000688)
,p_name=>'P87_RET'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'المحتجز %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000689)
,p_name=>'P87_RETCAP'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'سقف المحتجز % من العقد'
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
 p_id=>wwv_flow_imp.id(91820273000000690)
,p_name=>'P87_ADV'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'الدفعة المقدمة %'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000691)
,p_name=>'P87_ADVREC'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'استرداد المقدم من كل مستخلص %'
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
 p_id=>wwv_flow_imp.id(91820273000000692)
,p_name=>'P87_START'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'البداية'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_format_mask=>'YYYY-MM-DD'
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
 p_id=>wwv_flow_imp.id(91820273000000693)
,p_name=>'P87_END'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'النهاية'
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
 p_id=>wwv_flow_imp.id(91820273000000694)
,p_name=>'P87_DLP'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_prompt=>'فترة الضمان (شهر)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000695)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000679)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ العقد'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000696)
,p_plug_name=>'جدول الكميات (BOQ)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P87_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_w clob; l_u clob;',
'begin',
'    select json_arrayagg(json_object(''v'' value id, ''n'' value code || '' - '' || name_ar) order by code returning clob) into l_w',
'      from prj_wbs where project_id = :P87_PROJECT and status_code <> ''CANCELLED'';',
'    select json_arrayagg(json_object(''v'' value id, ''n'' value name_ar) order by name_ar returning clob) into l_u',
'      from inv_uom where is_active = ''Y'';',
'    return ''<script type="application/json" id="nnPrjLists">'' || replace(''{"wbs":'' || nvl(l_w, ''[]'') || '',"uoms":'' || nvl(l_u, ''[]'') || ''}'', ''</'', ''<\/'') || ''</script>''',
'        || ''<script type="application/json" id="nnPrjBoqData">'' || replace(noona_prj_pkg.boq_json(:P87_ID), ''</'', ''<\/'') || ''</script>''',
'        || ''<div id="nnPrjBoq" data-contract="'' || :P87_ID || ''" data-locked="'' || case when noona_prj_pkg.contract_status(:P87_ID) = ''DRAFT'' then ''N'' else ''Y'' end || ''"></div>'';',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000697)
,p_plug_name=>'إجراءات العقد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P87_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000698)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'ACTIVATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد العقد'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''DRAFT'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000699)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'NEW_CLAIM'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'مستخلص جديد'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000700)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'NEW_ADVANCE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'دفعة مقدمة'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.can_advance(:P87_ID) = ''Y'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000701)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'NEW_RELEASE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إفراج عن المحتجز'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'' and noona_prj_pkg.retention_held(:P87_ID) > 0'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000702)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إنهاء العقد'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'''
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000703)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820273000000697)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع للمشروع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:81:&SESSION.::&DEBUG.::P81_ID:&P87_PROJECT.'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000704)
,p_plug_name=>'أمر تغيير جديد'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'''
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return ''<div id="nnPrjVo" data-contract="'' || :P87_ID || ''"></div>'';'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000705)
,p_plug_name=>'أوامر التغيير المسودة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>45
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'' and noona_prj_pkg.draft_variations(:P87_ID) > 0'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l clob; n pls_integer := 0;',
'begin',
'    for v in (select id, doc_no, description, amount from prj_variation_order where contract_id = :P87_ID and status_code = ''DRAFT'') loop',
'        n := n + 1; l := l || ''<li>'' || apex_escape.html(v.doc_no || '' - '' || v.description) || '' ('' || to_char(v.amount, ''FM999G999G990D00'') || '')</li>'';',
'    end loop;',
'    return case when n > 0 then ''<ul class="nn-prj-list">'' || l || ''</ul>'' end;',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000706)
,p_plug_name=>'اعتماد أمر تغيير'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>46
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>'noona_prj_pkg.contract_status(:P87_ID) = ''ACTIVE'' and noona_prj_pkg.draft_variations(:P87_ID) > 0'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000707)
,p_name=>'P87_VO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000706)
,p_prompt=>'أمر التغيير'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select doc_no || '' - '' || description d, id r from prj_variation_order where contract_id = :P87_ID and status_code = ''DRAFT'''
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
 p_id=>wwv_flow_imp.id(91820273000000708)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000706)
,p_button_name=>'APPROVE_VO'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'اعتماد أمر التغيير'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000709)
,p_plug_name=>'المستخلصات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P87_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_prj_pkg.claims_html(:P87_ID, ''f?p='' || :APP_ID || '':88:'' || :APP_SESSION || ''::NO:RP,88:P88_ID:#ID#'');'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000710)
,p_process_sequence=>1
,p_process_point=>'ON_DEMAND'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRJ'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_c clob;',
'    function n(p varchar2) return number is begin return to_number(p); end;',
'begin',
'    case apex_application.g_x01',
'        when ''BOQ'' then l_c := ''{"n":'' || noona_prj_pkg.save_boq(n(apex_application.g_x02), apex_application.g_clob_01) || ''}'';',
'        when ''VO'' then l_c := ''{"id":'' || noona_prj_pkg.save_variation(apex_application.g_clob_01) || ''}'';',
'        when ''BUDGET'' then l_c := ''{"id":'' || noona_prj_pkg.save_budget(n(apex_application.g_x02), apex_application.g_clob_01,',
'                                                                       apex_application.g_x03) || ''}'';',
'        when ''CLAIM'' then noona_prj_pkg.save_claim(apex_application.g_clob_01);',
'            l_c := noona_prj_pkg.claim_json(json_value(apex_application.g_clob_01, ''$.id'' returning number));',
'        when ''REV'' then noona_prj_pkg.reverse_cost(n(apex_application.g_x02), apex_application.g_x03);',
'        else raise_application_error(-20500, ''NOONA-PRJ-099: عملية غير معروفة'');',
'    end case;',
'    htp.prn(nvl(l_c, to_clob(''{"ok":true}'')));',
'exception when others then',
'    rollback;',
'    apex_json.open_object;',
'    apex_json.write(''err'', regexp_replace(nvl(trim(regexp_substr(sqlerrm, ''NOONA-[A-Z]+-[0-9]+: [^'' || chr(10) || '']+'')), sqlerrm),',
'                                          ''\s*\[cid=[^]]+\]'', ''''));',
'    apex_json.close_object;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000710
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000711)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P87_ID is not null then',
'        select project_id, contract_type, contract_no, customer_account_id, supplier_account_id, pricing_type, original_value, retention_pct,',
'               retention_cap_pct, advance_pct, advance_recovery_pct, to_char(start_date, ''YYYY-MM-DD''), to_char(end_date, ''YYYY-MM-DD''), defects_liability_months',
'          into :P87_PROJECT, :P87_TYPE, :P87_NO, :P87_CUSTOMER, :P87_SUPPLIER, :P87_PRICING, :P87_VALUE, :P87_RET, :P87_RETCAP, :P87_ADV,',
'               :P87_ADVREC, :P87_START, :P87_END, :P87_DLP',
'          from prj_contract where id = :P87_ID and company_id = noona_prj_pkg.company;',
'    else',
'        :P87_TYPE := nvl(:P87_TYPE, ''MAIN_CONTRACT''); :P87_PRICING := nvl(:P87_PRICING, ''REMEASURED'');',
'        if :P87_CUSTOMER is null and :P87_TYPE = ''MAIN_CONTRACT'' then select customer_account_id into :P87_CUSTOMER from prj_project where id = :P87_PROJECT; end if;',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000711
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000712)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P87_ID), ''project'' value to_number(:P87_PROJECT), ''type'' value :P87_TYPE, ''no'' value :P87_NO,',
'                       ''customer'' value to_number(:P87_CUSTOMER), ''supplier'' value to_number(:P87_SUPPLIER), ''pricing'' value :P87_PRICING,',
'                       ''value'' value to_number(:P87_VALUE), ''ret'' value to_number(:P87_RET), ''retCap'' value to_number(:P87_RETCAP),',
'                       ''adv'' value to_number(:P87_ADV), ''advRec'' value to_number(:P87_ADVREC), ''start'' value :P87_START, ''end'' value :P87_END,',
'                       ''dlp'' value to_number(:P87_DLP) returning clob) into l_doc from dual;',
'    :P87_ID := noona_prj_pkg.save_contract(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000695)
,p_process_success_message=>'تم حفظ العقد؛ أدخل جدول الكميات ثم اعتمده'
,p_internal_uid=>91820273000000712
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000713)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Activate'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.activate_contract(:P87_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000698)
,p_process_success_message=>'تم اعتماد العقد'
,p_internal_uid=>91820273000000713
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000714)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.close_contract(:P87_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000702)
,p_process_success_message=>'تم إنهاء العقد'
,p_internal_uid=>91820273000000714
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000715)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve VO'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_prj_pkg.approve_variation(:P87_VO);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000708)
,p_process_success_message=>'تم اعتماد أمر التغيير وتحديث قيمة العقد'
,p_internal_uid=>91820273000000715
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000716)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New Claim'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l number;',
'begin',
'    l := noona_prj_pkg.new_claim(:P87_ID, case :REQUEST when ''NEW_ADVANCE'' then ''ADVANCE'' when ''NEW_RELEASE'' then ''RETENTION_RELEASE'' else ''PROGRESS'' end);',
'    apex_util.redirect_url(apex_page.get_url(p_page => 88, p_clear_cache => ''88'', p_items => ''P88_ID'', p_values => l));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>':REQUEST in (''NEW_CLAIM'', ''NEW_ADVANCE'', ''NEW_RELEASE'')'
,p_process_when_type=>'EXPRESSION'
,p_process_when2=>'PLSQL'
,p_internal_uid=>91820273000000716
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000717)
,p_branch_action=>'f?p=&APP_ID.:87:&SESSION.::&DEBUG.::P87_ID:&P87_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
