prompt --application/pages/page_00040
begin
--   Manifest
--     PAGE: 00040
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
 p_id=>40
,p_name=>'Party Documents'
,p_alias=>'PARTY-DOCUMENTS'
,p_step_title=>'مستندات وشهادات الأطراف'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// عارض المستندات: بطاقات .nn-dv-card (data-kind pdf|img|office|paper) تعرض في إطار المعاينة داخل الصفحة',
'(function () {',
'    var esc = function (s) { return String(s == null ? '''' : s).replace(/[&<>"'']/g, function (c) { return {''&'': ''&amp;'', ''<'': ''&lt;'', ''>'': ''&gt;'', ''"'': ''&quot;'', "''": ''&#39;''}[c]; }); };',
'    document.querySelectorAll(''.nn-dv'').forEach(function (dv) {',
'        var view = dv.querySelector(''.nn-dv-view'');',
'        function show(card) {',
'            dv.querySelectorAll(''.nn-dv-card'').forEach(function (c) { c.classList.toggle(''is-active'', c === card); });',
'            var k = card.dataset.kind, u = card.dataset.view, t = card.dataset.title;',
'            var h = ''<div class="nn-dv-bar"><b>'' + esc(t) + ''</b>'' + (u ? ''<span><a href="'' + esc(u) + ''" target="_blank" rel="noopener">''',
'                  + ''<span class="fa fa-external-link" aria-hidden="true"></span> فتح في نافذة</a><a href="'' + esc(card.dataset.dl) + ''">''',
'                  + ''<span class="fa fa-download" aria-hidden="true"></span> تنزيل</a></span>'' : '''') + ''</div>'';',
'            if (k === ''pdf'') h += ''<iframe class="nn-dv-frame" src="'' + esc(u) + ''" title="'' + esc(t) + ''"></iframe>'';',
'            else if (k === ''img'') h += ''<div class="nn-dv-img"><img src="'' + esc(u) + ''" alt="'' + esc(t) + ''"></div>'';',
'            else if (k === ''office'') h += ''<div class="nn-dv-msg"><span class="fa fa-file-text-o" aria-hidden="true"></span>لا تتوفر معاينة لمستندات Word/Excel داخل الصفحة؛ ''',
'                                        + ''<a href="'' + esc(card.dataset.dl) + ''">نزّل الملف</a></div>'';',
'            else h += ''<div class="nn-dv-msg"><span class="fa fa-archive" aria-hidden="true"></span><b>أصل ورقي فقط (لا توجد صورة)</b>'' + esc(card.dataset.paper) + ''</div>'';',
'            view.innerHTML = h;',
'        }',
'        dv.addEventListener(''click'', function (e) {',
'            if (e.target.closest(''a'')) return;',
'            var img = e.target.closest(''.nn-dv-img''); if (img) { img.classList.toggle(''is-zoom''); return; }',
'            var c = e.target.closest(''.nn-dv-card''); if (c) show(c);',
'        });',
'        dv.addEventListener(''keydown'', function (e) { if (e.key === ''Enter'') { var c = e.target.closest(''.nn-dv-card''); if (c) show(c); } });',
'        if (dv.dataset.auto === ''Y'') {',
'            var first = dv.querySelector(''.nn-dv-card[data-kind="pdf"], .nn-dv-card[data-kind="img"]'') || dv.querySelector(''.nn-dv-card'');',
'            if (first) show(first);',
'        }',
'    });',
'})();'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000134)
,p_plug_name=>'الطرف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000135)
,p_name=>'P40_PARTY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000134)
,p_prompt=>'الطرف (مورد / عميل ...)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.party_no || '' - '' || p.display_name_ar || '' ('' || noona_pty_pkg.party_roles(p.id) || '')'' d, p.id r from pty_party p where p.status_code = ''ACTIVE'' order by p.display_name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000136)
,p_name=>'P40_ROLE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000134)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مورد;SUPPLIER,عميل;CUSTOMER,مقاول;CONTRACTOR,شريك;PARTNER,مستأجر;LESSEE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000137)
,p_plug_name=>'حالة مستندات الطرف'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P40_PARTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_dms_pkg.compliance_html(:P40_PARTY, nvl(:P40_ROLE, ''SUPPLIER''), replace(apex_page.get_url(p_page => 49, p_items => ''P49_DOC'', p_values => ''990000000001''), ''990000000001'', ''#ID#''));'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000138)
,p_plug_name=>'أرشفة مستند أو شهادة للطرف'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P40_PARTY is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000139)
,p_name=>'P40_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'نوع المستند'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select t.name_ar d, t.code r from dms_document_type t join dms_category c on c.id = t.category_id where c.code = ''PTY'' and t.is_active = ''Y'' order by t.name_ar'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000140)
,p_name=>'P40_REF'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'رقم المستند / الشهادة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>25
,p_cMaxlength=>100
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
 p_id=>wwv_flow_imp.id(91820267000000141)
,p_name=>'P40_VFROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'تاريخ الإصدار'
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
 p_id=>wwv_flow_imp.id(91820267000000142)
,p_name=>'P40_VTO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'تاريخ الانتهاء'
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
 p_id=>wwv_flow_imp.id(91820267000000143)
,p_name=>'P40_LOC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'موقع الأصل الورقي'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000144)
,p_name=>'P40_FILE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_prompt=>'صورة المستند'
,p_display_as=>'NATIVE_FILE'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'storage_type', 'APEX_APPLICATION_TEMP_FILES',
  'purge_file_at', 'REQUEST',
  'allow_multiple_files', 'N',
  'file_types', 'application/pdf,image/png,image/jpeg,image/tiff,image/webp,.docx,.xlsx',
  'display_as', 'DROPZONE_BLOCK',
  'dropzone_title', 'اسحب صورة الشهادة أو ملف PDF هنا',
  'dropzone_description', 'PDF أو صورة حتى 20 ميجابايت',
  'max_file_size', '20480')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000145)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000138)
,p_button_name=>'ARCHIVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'أرشفة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000146)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Archive Party Document'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_blob blob; l_name varchar2(400); l_mime varchar2(255); l_id number;',
'begin',
'    if :P40_FILE is not null then',
'        select blob_content, filename, mime_type into l_blob, l_name, l_mime from apex_application_temp_files where name = :P40_FILE;',
'    end if;',
'    l_id := noona_dms_pkg.archive_document(p_entity_type => ''PTY_PARTY'', p_entity_id => :P40_PARTY, p_type_code => :P40_TYPE,',
'        p_title => null, p_external_ref => :P40_REF, p_location => :P40_LOC, p_file_name => l_name, p_mime => l_mime, p_content => l_blob,',
'        p_valid_from => to_date(:P40_VFROM, ''YYYY-MM-DD''), p_valid_to => to_date(:P40_VTO, ''YYYY-MM-DD''));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000145)
,p_process_success_message=>'تمت أرشفة المستند للطرف'
,p_internal_uid=>91820267000000146
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000147)
,p_plug_name=>'طرف جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000148)
,p_name=>'P40_NEW_TYPE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:منشأة;ORGANIZATION,فرد;PERSON'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000149)
,p_name=>'P40_NEW_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820267000000150)
,p_name=>'P40_NEW_ROLE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مورد;SUPPLIER,عميل;CUSTOMER,مقاول;CONTRACTOR,شريك;PARTNER,مستأجر;LESSEE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000151)
,p_name=>'P40_NEW_VAT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_prompt=>'الرقم الضريبي'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
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
 p_id=>wwv_flow_imp.id(91820267000000152)
,p_name=>'P40_NEW_CR'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_prompt=>'رقم السجل التجاري'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000153)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000147)
,p_button_name=>'ADD_PARTY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة الطرف'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000154)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Party'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    :P40_PARTY := noona_pty_pkg.create_party(:P40_NEW_TYPE, :P40_NEW_NAME, :P40_NEW_ROLE, null, :P40_NEW_VAT, :P40_NEW_CR);',
'    :P40_ROLE := :P40_NEW_ROLE;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000153)
,p_process_success_message=>'تمت إضافة الطرف'
,p_internal_uid=>91820267000000154
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000155)
,p_branch_action=>'f?p=&APP_ID.:40:&SESSION.::&DEBUG.:40:P40_PARTY,P40_ROLE:&P40_PARTY.,&P40_ROLE.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
