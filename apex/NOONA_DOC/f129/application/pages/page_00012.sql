prompt --application/pages/page_00012
begin
--   Manifest
--     PAGE: 00012
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
 p_id=>12
,p_name=>'New Document'
,p_alias=>'NEW-DOCUMENT'
,p_step_title=>'أرشفة مستند'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000067)
,p_plug_name=>'بيانات المستند'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">يصدر رقم أرشيف يكتب على الأصل الورقي. سجل رقم الأصل (المرجع الورقي) أو أرفق صورته، أو الاثنين معاً.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000068)
,p_name=>'P12_NEW_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000069)
,p_name=>'P12_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'نوع المستند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar d, t.code r from dms_document_type t where t.is_active = ''Y'' and t.code <> ''COMPANY_LOGO'' order by t.name_ar'
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
 p_id=>wwv_flow_imp.id(91820267000000070)
,p_name=>'P12_TITLE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'العنوان'
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
 p_id=>wwv_flow_imp.id(91820267000000071)
,p_name=>'P12_REF'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'المرجع الورقي (رقم الأصل)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000072)
,p_name=>'P12_LOC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'موقع الأصل (الملف / الرف / الصندوق)'
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
 p_id=>wwv_flow_imp.id(91820267000000073)
,p_name=>'P12_DATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'تاريخ المستند'
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
 p_id=>wwv_flow_imp.id(91820267000000074)
,p_name=>'P12_CONF'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'السرية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عام;PUBLIC,داخلي;INTERNAL,سري;CONFIDENTIAL,سري جداً;SECRET'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- حسب النوع -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000075)
,p_name=>'P12_VFROM'
,p_item_sequence=>62
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'ساري من (للشهادات)'
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
 p_id=>wwv_flow_imp.id(91820267000000076)
,p_name=>'P12_VTO'
,p_item_sequence=>64
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'ينتهي في'
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
 p_id=>wwv_flow_imp.id(91820267000000077)
,p_name=>'P12_DESC'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'الوصف'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000078)
,p_name=>'P12_FILE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_prompt=>'صورة الأصل (اختياري)'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', 'application/pdf,image/png,image/jpeg,image/tiff,image/webp,.docx,.xlsx',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب صورة الأصل أو ملف PDF هنا',
  'dropzone_description', 'PDF أو صورة أو Word/Excel حتى 20 ميجابايت',
  'max_file_size', '20480')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000079)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_button_name=>'ARCHIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'أرشفة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000080)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820267000000067)
,p_button_name=>'CANCEL'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:10:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000081)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Archive'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_blob blob; l_name varchar2(400); l_mime varchar2(255);',
'begin',
'    if :P12_FILE is not null then',
'        select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :P12_FILE;',
'    end if;',
'    :P12_NEW_ID := noona_dms_pkg.archive_document(p_entity_type => null, p_entity_id => null, p_type_code => nvl(:P12_TYPE, ''GENERAL''),',
'        p_title => :P12_TITLE, p_external_ref => :P12_REF, p_location => :P12_LOC, p_doc_date => to_date(:P12_DATE, ''YYYY-MM-DD''),',
'        p_description => :P12_DESC, p_file_name => l_name, p_mime => l_mime, p_content => l_blob, p_confidentiality => :P12_CONF,',
'        p_valid_from => to_date(:P12_VFROM, ''YYYY-MM-DD''), p_valid_to => to_date(:P12_VTO, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000079)
,p_process_success_message=>'تمت الأرشفة'
,p_internal_uid=>91820267000000081
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000082)
,p_branch_action=>'f?p=&APP_ID.:11:&SESSION.::&DEBUG.:RP,11:P11_ID:&P12_NEW_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
