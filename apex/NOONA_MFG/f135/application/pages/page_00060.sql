prompt --application/pages/page_00060
begin
--   Manifest
--     PAGE: 00060
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>135
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>60
,p_name=>'Costing Settings'
,p_alias=>'COSTING'
,p_step_title=>'إعدادات تكلفة التصنيع'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820270000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820270000000198)
,p_plug_name=>'معالجة التكلفة'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">المنتج يدخل المخزون بتكلفته المعيارية عند الاستلام. عند إقفال الأمر يقارن النظام التكلفة الفعلية (الخامات المصروفة والعمالة والتحميل) بالمعيارية؛ والفرق (الانحراف) يعالج حسب اختيارك:</p><ul class="nn-hint"><li><b>مصروف</b>: يقيد على حساب انحرافات الإنتاج (5105)، وتبقى قيمة المخزون بالتكلفة المعيارية.</li><li><b>على المخزون (التكلفة الفعلية)</b>: يحمل على قيمة الكمية التي ما زالت في المخزون فيتعدل متوسط تكلفتها، وما بيع منها يحمل على تكلفة المبيعات.</li></ul>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000199)
,p_name=>'P60_TREAT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820270000000198)
,p_prompt=>'معالجة انحراف التكلفة عند الإقفال'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مصروف (انحرافات الإنتاج 5105);EXPENSE,على المخزون والمبيعات (التكلفة الفعلية);INVENTORY'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820270000000200)
,p_name=>'P60_STD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820270000000198)
,p_prompt=>'تحديث التكلفة المعيارية في بطاقة الصنف عند إطلاق الأمر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نعم;Y,لا;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000201)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P60_TREAT := noona_mfg_pkg.variance_treatment;',
':P60_STD := noona_mfg_pkg.update_item_std_cost;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820270000000201
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820270000000202)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820270000000198)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الإعدادات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820270000000203)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mfg_pkg.save_settings(:P60_TREAT, :P60_STD);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820270000000202)
,p_process_success_message=>'تم حفظ إعدادات التكلفة'
,p_internal_uid=>91820270000000203
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820270000000204)
,p_branch_action=>'f?p=&APP_ID.:60:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
