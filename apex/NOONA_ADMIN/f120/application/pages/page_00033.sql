prompt --application/pages/page_00033
begin
--   Manifest
--     PAGE: 00033
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>120
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>33
,p_name=>'Role'
,p_alias=>'ROLE'
,p_step_title=>'الدور وصلاحياته'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(17758617306442989)
,p_javascript_code_onload=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// رؤوس الأعمدة والصفوف تعكس حالة الخانات (محددة إذا كانت كل خاناتها محددة)',
'function nnSyncHeads() {',
'    $(''.nn-col'').each(function () {',
'        var c = $(''.nn-perm[data-col="'' + $(this).data(''col'') + ''"]'');',
'        this.checked = c.length > 0 && c.filter('':checked'').length === c.length;',
'    });',
'    $(''.nn-row'').each(function () {',
'        var c = $(this).closest(''tr'').find(''.nn-perm'');',
'        this.checked = c.length > 0 && c.filter('':checked'').length === c.length;',
'    });',
'    var all = $(''.nn-perm''); $(''.nn-all'').prop(''checked'', all.length > 0 && all.filter('':checked'').length === all.length);',
'}',
'$(document).on(''change'', ''.nn-col'', function () {',
'    $(''.nn-perm[data-col="'' + $(this).data(''col'') + ''"]'').prop(''checked'', this.checked); nnSyncHeads();',
'});',
'$(document).on(''change'', ''.nn-row'', function () {',
'    $(this).closest(''tr'').find(''.nn-perm'').prop(''checked'', this.checked); nnSyncHeads();',
'});',
'$(document).on(''change'', ''.nn-all'', function () { $(''.nn-perm'').prop(''checked'', this.checked); nnSyncHeads(); });',
'$(document).on(''change'', ''.nn-perm'', nnSyncHeads);',
'// قبل الإرسال: أرقام الصلاحيات المختارة في عنصر مخفي',
'$(document).on(''apexbeforepagesubmit'', function () {',
'    $s(''P33_PERMS'', $(''.nn-perm:checked'').map(function () { return this.value; }).get().join('',''));',
'});',
'nnSyncHeads();'))
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000352)
,p_plug_name=>'الدور'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000353)
,p_name=>'P33_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000354)
,p_name=>'P33_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'الدور'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000355)
,p_name=>'P33_STATUS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000356)
,p_name=>'P33_NEW_STATUS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_prompt=>'تغيير الحالة إلى'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,مسودة;DRAFT,متقاعد;RETIRED'
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
 p_id=>wwv_flow_imp.id(91820262000000357)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_button_name=>'CHANGE_STATUS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تغيير الحالة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000358)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000352)
,p_button_name=>'BACK'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رجوع'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:32:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000359)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Role'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select name_ar || '' ('' || code || '')'', noona_ui_pkg.status_label(status_code) into :P33_NAME, :P33_STATUS',
'  from sec_role where id = :P33_ID;',
'-- الوحدة الافتراضية: أول وحدة للدور فيها صلاحيات، وإلا أول وحدة',
'if :P33_MODULE is null then',
'    select min(m.module_code) keep (dense_rank first order by',
'               case when exists (select 1 from sec_role_permission rp join sec_permission p on p.id = rp.permission_id',
'                                  where rp.role_id = :P33_ID and p.module_code = m.module_code) then 0 else 1 end,',
'               m.package_no)',
'      into :P33_MODULE from plt_module m;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820262000000359
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000360)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Role Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.set_role_status(:P33_ID, :P33_NEW_STATUS);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000357)
,p_process_success_message=>'تم تغيير حالة الدور'
,p_internal_uid=>91820262000000360
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000361)
,p_plug_name=>'مصفوفة الصلاحيات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000362)
,p_name=>'P33_MODULE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000361)
,p_prompt=>'الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select m.module_code || '' - '' || m.name_ar || '' ('' || (select count(*) from sec_role_permission rp join sec_permission p on p.id = rp.permission_id where rp.role_id = :P33_ID and p.module_code = m.module_code and rp.effect = ''ALLOW'') || '')'' d, m.module_code r from plt_module m order by m.package_no'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000363)
,p_name=>'P33_PERMS'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000361)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000364)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000361)
,p_button_name=>'SAVE_MATRIX'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الصلاحيات'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000365)
,p_plug_name=>'خانات الصلاحيات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>25
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_ui_pkg.permission_matrix(p_role_id => :P33_ID, p_module_code => :P33_MODULE);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000366)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Permission Matrix'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_r varchar2(50);',
'begin',
'    l_r := noona_sec_admin_pkg.sync_module_permissions(:P33_ID, :P33_MODULE, :P33_PERMS);',
'    apex_application.g_print_success_message := ''تم حفظ الصلاحيات: إضافة '' || substr(l_r, 1, instr(l_r, '':'') - 1)',
'        || '' وإزالة '' || substr(l_r, instr(l_r, '':'') + 1);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000364)
,p_internal_uid=>91820262000000366
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000367)
,p_plug_name=>'صلاحية محددة أو منع صريح'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000368)
,p_name=>'P33_PERMISSION_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820262000000367)
,p_prompt=>'رمز الصلاحية'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>150
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000369)
,p_name=>'P33_EFFECT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820262000000367)
,p_prompt=>'الأثر'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:منع;DENY,سماح;ALLOW'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820262000000370)
,p_name=>'P33_REMOVE_ID'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820262000000367)
,p_prompt=>'إزالة صلاحية منع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select p.permission_code d, rp.id r from sec_role_permission rp join sec_permission p on p.id = rp.permission_id where rp.role_id = :P33_ID and rp.effect = ''DENY'' order by 1'
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
 p_id=>wwv_flow_imp.id(91820262000000371)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000367)
,p_button_name=>'ADD_ONE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إضافة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000372)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000367)
,p_button_name=>'REMOVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إزالة المنع'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000373)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add One Permission'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.add_permission(:P33_ID, :P33_PERMISSION_CODE, nvl(:P33_EFFECT, ''DENY''));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000371)
,p_process_success_message=>'تمت إضافة الصلاحية'
,p_internal_uid=>91820262000000373
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820262000000374)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Permission'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_sec_admin_pkg.remove_permission(:P33_REMOVE_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820262000000372)
,p_process_success_message=>'تمت إزالة الصلاحية'
,p_internal_uid=>91820262000000374
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820262000000375)
,p_branch_action=>'f?p=&APP_ID.:33:&SESSION.::&DEBUG.::P33_ID:&P33_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
