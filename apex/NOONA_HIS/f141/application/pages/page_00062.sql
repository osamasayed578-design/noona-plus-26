prompt --application/pages/page_00062
begin
--   Manifest
--     PAGE: 00062
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>141
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>62
,p_name=>'Doctors'
,p_alias=>'DOCTORS'
,p_step_title=>'الأطباء وساعات العمل'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000392)
,p_plug_name=>'طبيب جديد / تعديل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000393)
,p_name=>'P62_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'تعديل طبيب'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select d.name_ar || '' - '' || p.name_ar d, d.id r from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company order by p.sort_order, p.name_ar, d.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- طبيب جديد -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000394)
,p_name=>'P62_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
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
 p_id=>wwv_flow_imp.id(91820275000000395)
,p_name=>'P62_DEPT'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'القسم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by sort_order, name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000396)
,p_name=>'P62_TITLE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'الدرجة/الوظيفة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:استشاري;CONSULTANT,أخصائي;SPECIALIST,مقيم;RESIDENT,طبيب عام;GP,طبيب أسنان;DENTIST,جراح;SURGEON,طبيب تخدير;ANESTHETIST,أخصائي أشعة;RADIOLOGIST,أخصائي مختبر;PATHOLOGIST,أخصائي علاج طبيعي;PHYSIOTHERAPIST,فني;TECHNICIAN,ممرض;NURSE,صيدلي;PHARMACIST'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000397)
,p_name=>'P62_SPEC'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'التخصص'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
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
 p_id=>wwv_flow_imp.id(91820275000000398)
,p_name=>'P62_LIC'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'رقم الترخيص المهني'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
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
 p_id=>wwv_flow_imp.id(91820275000000399)
,p_name=>'P62_LEXP'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'انتهاء الترخيص'
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
 p_id=>wwv_flow_imp.id(91820275000000400)
,p_name=>'P62_MOBILE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'الجوال'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>30
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
 p_id=>wwv_flow_imp.id(91820275000000401)
,p_name=>'P62_CONSULT'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'خدمة الكشف الافتراضية'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_his_pkg.service_name(s.id) || '' ('' || noona_his_pkg.type_label(s.service_type) || '' - '' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company and s.status_code = ''ACTIVE'' order by s.service_type, s.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000402)
,p_name=>'P62_COMM'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'نسبة الطبيب %'
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
 p_id=>wwv_flow_imp.id(91820275000000403)
,p_name=>'P62_USER'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'مستخدم الدخول'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>128
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000404)
,p_name=>'P62_STATUS'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,في إجازة;ON_LEAVE,موقوف;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000405)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000392)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000406)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select name_ar, department_id, title, specialty, license_no, to_char(license_expiry, ''YYYY-MM-DD''), mobile, consult_service_id, commission_pct,',
'           user_name, status_code into :P62_NAME, :P62_DEPT, :P62_TITLE, :P62_SPEC, :P62_LIC, :P62_LEXP, :P62_MOBILE, :P62_CONSULT, :P62_COMM,',
'           :P62_USER, :P62_STATUS from his_doctor where id = :P62_ID and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000406
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000407)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob;',
'begin',
'    select json_object(''id'' value to_number(:P62_ID), ''name'' value :P62_NAME, ''dept'' value to_number(:P62_DEPT), ''title'' value :P62_TITLE, ''specialty'' value :P62_SPEC, ''license'' value :P62_LIC, ''license_expiry'' value :P62_LEXP, ''mobile'' value :P62_MOBILE, ''consult_service'' value to_number(:P62_CONSULT), ''commission'' value to_number(:P62_COMM), ''user'' value :P62_USER, ''status'' value :P62_STATUS returning clob) into l_doc from dual;',
'    :P62_ID := noona_his_pkg.save_doctor(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000405)
,p_process_success_message=>'تم حفظ الطبيب'
,p_internal_uid=>91820275000000407
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000408)
,p_plug_name=>'ساعات العمل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_plug_display_condition_type=>'EXPRESSION'
,p_plug_display_when_condition=>':P62_ID is not null'
,p_plug_display_when_cond2=>'PLSQL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000409)
,p_name=>'P62_DAY'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_prompt=>'اليوم'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:الأحد;1,الاثنين;2,الثلاثاء;3,الأربعاء;4,الخميس;5,الجمعة;6,السبت;7'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000410)
,p_name=>'P62_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_prompt=>'من (HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
,p_cMaxlength=>5
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
 p_id=>wwv_flow_imp.id(91820275000000411)
,p_name=>'P62_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_prompt=>'إلى (HH24:MI)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>8
,p_cMaxlength=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000412)
,p_name=>'P62_SLOT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_prompt=>'مدة الموعد بالدقائق'
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
 p_id=>wwv_flow_imp.id(91820275000000413)
,p_name=>'P62_ROOM'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_prompt=>'الغرفة'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000414)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_button_name=>'SET_HOURS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ الفترة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000415)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820275000000408)
,p_button_name=>'CLEAR_DAY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'مسح اليوم'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000416)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Hours'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.set_schedule(:P62_ID, to_number(:P62_DAY), :P62_FROM, :P62_TO, nvl(to_number(:P62_SLOT), 15), :P62_ROOM);'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000414)
,p_process_success_message=>'حفظت ساعات العمل'
,p_internal_uid=>91820275000000416
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000417)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Clear'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.clear_schedule(:P62_ID, to_number(:P62_DAY));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000415)
,p_process_success_message=>'مسحت فترات اليوم'
,p_internal_uid=>91820275000000417
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000418)
,p_plug_name=>'ساعات عمل الطبيب'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>17
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, case s.weekday when 1 then ''الأحد'' when 2 then ''الاثنين'' when 3 then ''الثلاثاء'' when 4 then ''الأربعاء'' when 5 then ''الخميس''',
'       when 6 then ''الجمعة'' else ''السبت'' end as day, s.from_time, s.to_time, s.slot_minutes, s.room',
'  from his_doctor_schedule s where s.doctor_id = :P62_ID order by s.weekday, s.from_time'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'ساعات عمل الطبيب'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000419)
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
,p_internal_uid=>91820275000000419
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000421)
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
 p_id=>wwv_flow_imp.id(91820275000000422)
,p_db_column_name=>'DAY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'اليوم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000423)
,p_db_column_name=>'FROM_TIME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'من'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000424)
,p_db_column_name=>'TO_TIME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'إلى'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000425)
,p_db_column_name=>'SLOT_MINUTES'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'مدة الموعد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000426)
,p_db_column_name=>'ROOM'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الغرفة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000420)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'420'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DAY:FROM_TIME:TO_TIME:SLOT_MINUTES:ROOM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000427)
,p_plug_name=>'الأطباء'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select d.id, d.code, d.name_ar, p.name_ar as dept, d.specialty, d.license_no, d.license_expiry,',
'       (select listagg(case s.weekday when 1 then ''أحد'' when 2 then ''اثنين'' when 3 then ''ثلاثاء'' when 4 then ''أربعاء'' when 5 then ''خميس''',
'        when 6 then ''جمعة'' else ''سبت'' end || '' '' || s.from_time || ''-'' || s.to_time, ''، '') within group (order by s.weekday, s.from_time)',
'          from his_doctor_schedule s where s.doctor_id = d.id) as hours,',
'       case d.status_code when ''ACTIVE'' then ''نشط'' when ''ON_LEAVE'' then ''في إجازة'' else ''موقوف'' end as status',
'  from his_doctor d join his_department p on p.id = d.department_id where d.company_id = noona_his_pkg.company order by p.name_ar, d.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الأطباء'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000428)
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
,p_internal_uid=>91820275000000428
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000430)
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
 p_id=>wwv_flow_imp.id(91820275000000431)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000432)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الطبيب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000433)
,p_db_column_name=>'DEPT'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000434)
,p_db_column_name=>'SPECIALTY'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'التخصص'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000435)
,p_db_column_name=>'LICENSE_NO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الترخيص'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000436)
,p_db_column_name=>'LICENSE_EXPIRY'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'انتهاء الترخيص'
,p_column_type=>'DATE'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000437)
,p_db_column_name=>'HOURS'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'ساعات العمل'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000438)
,p_db_column_name=>'STATUS'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000429)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'429'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:DEPT:SPECIALTY:LICENSE_NO:LICENSE_EXPIRY:HOURS:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000439)
,p_branch_action=>'f?p=&APP_ID.:62:&SESSION.::&DEBUG.::P62_ID:&P62_ID.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
