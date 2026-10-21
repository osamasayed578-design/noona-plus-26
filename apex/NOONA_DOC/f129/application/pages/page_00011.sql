prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>129
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>11
,p_name=>'Document'
,p_alias=>'DOCUMENT'
,p_step_title=>'المستند المؤرشف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000002)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000044)
,p_plug_name=>'المستند'
,p_region_template_options=>'#DEFAULT#:t-Region--noUI:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000045)
,p_name=>'P11_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820267000000044)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000046)
,p_plug_name=>'تفاصيل المستند'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_pkg.document_html(:P11_ID, replace(replace(apex_page.get_url(p_page => 49, p_items => ''P49_DOC,P49_VER'', p_values => ''990000000001,990000000002''), ''990000000001'', ''#ID#''), ''990000000002'', ''#VER#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000047)
,p_plug_name=>'إصدار جديد لصورة الأصل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000048)
,p_name=>'P11_FILE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000047)
,p_prompt=>'الملف'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', 'application/pdf,image/png,image/jpeg,image/tiff,image/webp,.docx,.xlsx',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب الملف هنا أو اضغط للاختيار',
  'dropzone_description', 'PDF أو صورة أو Word/Excel حتى 20 ميجابايت',
  'max_file_size', '20480')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000049)
,p_name=>'P11_REASON'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000047)
,p_prompt=>'سبب الإصدار (مثل: صورة أوضح)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>200
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000050)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000047)
,p_button_name=>'ADD_VERSION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'رفع الإصدار'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000051)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Version'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_blob blob; l_name varchar2(400); l_mime varchar2(255); l_id number;',
'begin',
'    if :P11_FILE is null then',
'        raise_application_error(-20500, ''NOONA-DMS-110: اختر الملف أولاً'');',
'    end if;',
'    select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :P11_FILE;',
'    l_id := noona_dms_pkg.add_version(:P11_ID, l_name, l_mime, l_blob, :P11_REASON);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000050)
,p_process_success_message=>'تم رفع الإصدار الجديد؛ السابق محفوظ في الأرشيف'
,p_internal_uid=>91820267000000051
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000052)
,p_plug_name=>'ربط بمستند أعمال'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000053)
,p_name=>'P11_ENTITY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000052)
,p_prompt=>'نوع المستند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:سندات القبض والصرف والمصروفات;CSH_TRANSACTION,القيود اليومية;GL_JOURNAL,فواتير الموردين;AP_INVOICE,فواتير العملاء;AR_INVOICE,أوامر الشراء;PUR_ORDER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000054)
,p_name=>'P11_ENTITY_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000052)
,p_prompt=>'الرقم الداخلي للمستند'
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
 p_id=>wwv_flow_imp.id(91820267000000055)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000052)
,p_button_name=>'LINK'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'ربط'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000056)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Link'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_dms_pkg.link_document(:P11_ID, :P11_ENTITY, :P11_ENTITY_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000055)
,p_process_success_message=>'تم الربط'
,p_internal_uid=>91820267000000056
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000057)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000052)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع للأرشيف'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000058)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:11:P11_ID:&P11_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
