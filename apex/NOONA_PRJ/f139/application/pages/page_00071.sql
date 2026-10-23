prompt --application/pages/page_00071
begin
--   Manifest
--     PAGE: 00071
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
 p_id=>71
,p_name=>'Maintenance Request'
,p_alias=>'MAINT-REQUEST'
,p_step_title=>'بلاغ الصيانة'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820273000000011)
,p_protection_level=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000409)
,p_plug_name=>'البلاغ'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P71_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_mnt_pkg.request_html(:P71_ID);'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000410)
,p_plug_name=>'بلاغ جديد'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">حدد نوع العطل وموقعه (العقار ثم الوحدة أو الغرفة). الأولوية تحدد الموعد المستهدف للإنجاز: طارئ ساعتان، عاجل 4 ساعات، مرتفع يوم، عادي 3 أيام، منخفض أسبوع. يمكن إسناده لفريق مباشرة.</p>'))
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P71_ID is null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000411)
,p_name=>'P71_ID'
,p_item_sequence=>1
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000412)
,p_name=>'P71_NEW_ROOM'
,p_item_sequence=>2
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000413)
,p_name=>'P71_NEW_UNIT'
,p_item_sequence=>3
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000414)
,p_name=>'P71_NEW_PROP'
,p_item_sequence=>4
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000415)
,p_name=>'P71_CAT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'نوع العطل'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from mnt_service_category where is_active = ''Y'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000416)
,p_name=>'P71_PRIORITY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'الأولوية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:عادي;NORMAL,مرتفع;HIGH,عاجل;URGENT,طارئ;EMERGENCY,منخفض;LOW'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- حسب نوع العطل -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000417)
,p_name=>'P71_TITLE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'عنوان مختصر'
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
 p_id=>wwv_flow_imp.id(91820273000000418)
,p_name=>'P71_DESC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'وصف المشكلة'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000419)
,p_name=>'P71_CHANNEL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'طريقة البلاغ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:هاتف;PHONE,الاستقبال;FRONT_DESK,بوابة الخدمة;PORTAL,تطبيق الجوال;APP,بريد إلكتروني;EMAIL,جولة معاينة;INSPECTION,صيانة وقائية;PREVENTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000420)
,p_name=>'P71_PROPERTY'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'العقار'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar || '' ('' || code || '')'' d, id r from re_property where company_id = noona_re_pkg.company and status_code <> ''INACTIVE'' order by code'
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
 p_id=>wwv_flow_imp.id(91820273000000421)
,p_name=>'P71_UNIT'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'الوحدة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select code || '' - '' || name_ar d, id r from re_unit where property_id = :P71_PROPERTY order by code'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P71_PROPERTY'
,p_ajax_items_to_submit=>'P71_PROPERTY'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000422)
,p_name=>'P71_ROOM'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'الغرفة الفندقية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select room_no d, id r from hsp_room where property_id = :P71_PROPERTY order by room_no'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P71_PROPERTY'
,p_ajax_items_to_submit=>'P71_PROPERTY'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000423)
,p_name=>'P71_OOO'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'إيقاف الغرفة الشاغرة حتى الإصلاح'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:لا;N,نعم;Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000424)
,p_name=>'P71_RNAME'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'اسم المبلغ (مستأجر/نزيل/موظف)'
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
 p_id=>wwv_flow_imp.id(91820273000000425)
,p_name=>'P71_RPHONE'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'جوال المبلغ'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000426)
,p_name=>'P71_CHARGE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'تحمل التكلفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:المالك / المنشأة;OWNER,المستأجر / النزيل;LESSEE,الضمان;WARRANTY,المقاول;CONTRACTOR,التأمين;INSURANCE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000427)
,p_name=>'P71_TEAM'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_prompt=>'إسناد لفريق (اختياري)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from mnt_team where company_id = noona_mnt_pkg.company and is_active = ''Y'' order by name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000429)
,p_validation_name=>'P71_CAT required (CREATE)'
,p_validation_sequence=>19
,p_validation=>'P71_CAT'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000428)
,p_associated_item=>wwv_flow_imp.id(91820273000000415)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(91820273000000430)
,p_validation_name=>'P71_DESC required (CREATE)'
,p_validation_sequence=>20
,p_validation=>'P71_DESC'
,p_validation_type=>'ITEM_NOT_NULL'
,p_error_message=>'#LABEL#: قيمة مطلوبة'
,p_when_button_pressed=>wwv_flow_imp.id(91820273000000428)
,p_associated_item=>wwv_flow_imp.id(91820273000000418)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000428)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000410)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'تسجيل البلاغ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000431)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P71_ID is null then',
'        :P71_CHANNEL := nvl(:P71_CHANNEL, case when :P71_NEW_ROOM is not null then ''FRONT_DESK'' else ''PHONE'' end);',
'        :P71_CHARGE := nvl(:P71_CHARGE, ''OWNER''); :P71_OOO := nvl(:P71_OOO, ''N'');',
'        if :P71_NEW_ROOM is not null then',
'            :P71_ROOM := :P71_NEW_ROOM;',
'            select max(property_id) into :P71_PROPERTY from hsp_room where id = :P71_NEW_ROOM;',
'        end if;',
'        :P71_UNIT := nvl(:P71_UNIT, :P71_NEW_UNIT); :P71_PROPERTY := nvl(:P71_PROPERTY, :P71_NEW_PROP);',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000431
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000432)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''category'' value to_number(:P71_CAT), ''priority'' value :P71_PRIORITY, ''title'' value :P71_TITLE, ''description'' value :P71_DESC, ''channel'' value :P71_CHANNEL, ''property'' value to_number(:P71_PROPERTY), ''unit'' value to_number(:P71_UNIT), ''room'' value to_number(:P71_ROOM), ''room_ooo'' value :P71_OOO, ''reporter_name'' value :P71_RNAME, ''reporter_phone'' value :P71_RPHONE, ''chargeable_to'' value :P71_CHARGE, ''team'' value to_number(:P71_TEAM) returning clob) into l_doc from dual;',
'    :P71_ID := noona_mnt_pkg.create_request(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000428)
,p_process_success_message=>'تم تسجيل البلاغ'
,p_internal_uid=>91820273000000432
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820273000000433)
,p_plug_name=>'الإجراءات'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P71_ID is not null and noona_mnt_pkg.request_status(:P71_ID) not in (''CLOSED'', ''CANCELLED'', ''REJECTED'')'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000434)
,p_name=>'P71_A_TEAM'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'الفريق'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from mnt_team where company_id = noona_mnt_pkg.company and is_active = ''Y'' order by name_ar'
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
 p_id=>wwv_flow_imp.id(91820273000000435)
,p_name=>'P71_A_TECH'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'الفني'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select nvl(p.display_name_ar, t.external_name) || nvl2(t.skills, '' - '' || t.skills, '''') d, t.id r from mnt_technician t left join hr_employee e on e.id = t.employee_id left join pty_party p on p.id = e.person_party_id where t.team_id = :P71_A_TEAM and t.is_active = ''Y'' order by 1'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- اختر -'
,p_lov_cascade_parent_items=>'P71_A_TEAM'
,p_ajax_items_to_submit=>'P71_A_TEAM'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000436)
,p_name=>'P71_NOTES'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'ما تم عمله / سبب التعليق أو الإلغاء أو إعادة الفتح'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>3
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'Y',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000437)
,p_name=>'P71_HOURS'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'ساعات عمل الفني'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820273000000438)
,p_name=>'P71_MATERIAL'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'تكلفة المواد وقطع الغيار'
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
 p_id=>wwv_flow_imp.id(91820273000000439)
,p_name=>'P71_RATING'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_prompt=>'تقييم المبلغ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:★★★★★ ممتاز;5,★★★★ جيد جداً;4,★★★ جيد;3,★★ مقبول;2,★ ضعيف;1'
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
 p_id=>wwv_flow_imp.id(91820273000000440)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'ASSIGN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إسناد'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''NEW'', ''TRIAGED'', ''ASSIGNED'', ''ON_HOLD'', ''IN_PROGRESS'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000441)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'START'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'بدء التنفيذ'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''ASSIGNED'', ''ON_HOLD'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000442)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'HOLD'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'تعليق'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''ASSIGNED'', ''IN_PROGRESS'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000443)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'COMPLETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إنجاز'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''ASSIGNED'', ''IN_PROGRESS'', ''ON_HOLD'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000444)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'CLOSE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'إغلاق بالتقييم'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''COMPLETED'', ''VERIFIED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000445)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'REOPEN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إعادة فتح'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''COMPLETED'', ''VERIFIED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000446)
,p_button_sequence=>70
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'CANCEL_REQ'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'إلغاء'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''NEW'', ''TRIAGED'', ''ASSIGNED'', ''ON_HOLD'', ''IN_PROGRESS'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820273000000447)
,p_button_sequence=>80
,p_button_plug_id=>wwv_flow_imp.id(91820273000000433)
,p_button_name=>'REJECT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'رفض'
,p_button_position=>'NEXT'
,p_button_condition=>'noona_mnt_pkg.request_status(:P71_ID) in (''NEW'', ''TRIAGED'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000448)
,p_process_sequence=>6
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    if :P71_ID is not null then',
'        select team_id, technician_id into :P71_A_TEAM, :P71_A_TECH from mnt_request where id = :P71_ID;',
'    end if;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820273000000448
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000449)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Assign'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.assign(:P71_ID, :P71_A_TEAM, :P71_A_TECH);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000440)
,p_process_success_message=>'تم الإسناد وإشعار الفريق'
,p_internal_uid=>91820273000000449
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000450)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Start'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.start_work(:P71_ID);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000441)
,p_process_success_message=>'بدأ التنفيذ'
,p_internal_uid=>91820273000000450
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000451)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Hold'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.hold(:P71_ID, :P71_NOTES);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000442)
,p_process_success_message=>'تم تعليق البلاغ'
,p_internal_uid=>91820273000000451
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000452)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Complete'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.complete(:P71_ID, :P71_NOTES, :P71_HOURS, :P71_MATERIAL);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000443)
,p_process_success_message=>'تم إنجاز البلاغ'
,p_internal_uid=>91820273000000452
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000453)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.close_request(:P71_ID, :P71_RATING);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000444)
,p_process_success_message=>'تم إغلاق البلاغ'
,p_internal_uid=>91820273000000453
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000454)
,p_process_sequence=>70
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reopen'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.reopen(:P71_ID, :P71_NOTES);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000445)
,p_process_success_message=>'أعيد فتح البلاغ'
,p_internal_uid=>91820273000000454
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000455)
,p_process_sequence=>80
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cancel'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.cancel_request(:P71_ID, :P71_NOTES, ''N'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000446)
,p_process_success_message=>'تم إلغاء البلاغ'
,p_internal_uid=>91820273000000455
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820273000000456)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reject'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_mnt_pkg.cancel_request(:P71_ID, :P71_NOTES, ''Y'');'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820273000000447)
,p_process_success_message=>'تم رفض البلاغ'
,p_internal_uid=>91820273000000456
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820273000000457)
,p_branch_action=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.::P71_ID:&P71_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
