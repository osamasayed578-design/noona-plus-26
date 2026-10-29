prompt --application/pages/page_00061
begin
--   Manifest
--     PAGE: 00061
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
 p_id=>61
,p_name=>'Services'
,p_alias=>'SERVICES'
,p_step_title=>'دليل الخدمات الطبية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820275000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000344)
,p_plug_name=>'خدمة جديدة / تعديل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000345)
,p_name=>'P61_ID'
,p_item_sequence=>5
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'تعديل خدمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_his_pkg.service_name(s.id) || '' ('' || noona_his_pkg.type_label(s.service_type) || '' - '' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company order by s.service_type, s.name_ar'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- خدمة جديدة -'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'SUBMIT')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000346)
,p_name=>'P61_CODE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'الرمز'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>12
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
 p_id=>wwv_flow_imp.id(91820275000000347)
,p_name=>'P61_NAME'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'الاسم'
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
 p_id=>wwv_flow_imp.id(91820275000000348)
,p_name=>'P61_NAME_EN'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'Name (English) - للتحاليل والأشعة والأدوية'
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
 p_id=>wwv_flow_imp.id(91820275000000349)
,p_name=>'P61_TYPE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'النوع'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:كشف;CONSULTATION,مراجعة;FOLLOW_UP,طوارئ;EMERGENCY,تحليل مخبري;LAB,أشعة وموجات;RADIOLOGY,تشخيص القلب;CARDIO_DIAG,إجراء طبي;PROCEDURE,عملية صغرى;MINOR_SURGERY,عملية كبرى;MAJOR_SURGERY,علاج طبيعي;PHYSIOTHERAPY,جلسة علاجية;THERAPY,خدمة تمريضية;NURSING,أسنان;DENTAL,تنويم (يوم سرير);BED,دواء ومستلزمات;MEDICATION,باقة;PACKAGE,أخرى;OTHER'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000350)
,p_name=>'P61_DEPT'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'القسم المنفذ'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select name_ar d, id r from his_department where company_id = noona_his_pkg.company and status_code = ''ACTIVE'' order by sort_order, name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000351)
,p_name=>'P61_MOD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'جهاز الأشعة/التشخيص'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:أشعة سينية;XRAY,أشعة مقطعية;CT,رنين مغناطيسي;MRI,موجات صوتية;ULTRASOUND,دوبلر;DOPPLER,ماموجرام;MAMMOGRAPHY,أشعة بالصبغة;FLUOROSCOPY,هشاشة العظام;DEXA,طب نووي;NUCLEAR,مسح PET;PET,رسم قلب;ECG,إيكو القلب;ECHO,جهد;STRESS_TEST,هولتر;HOLTER,رسم مخ;EEG,رسم عصب وعضلات;EMG,مناظير;ENDOSCOPY'
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
 p_id=>wwv_flow_imp.id(91820275000000352)
,p_name=>'P61_PRICE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'السعر النقدي قبل الضريبة'
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
 p_id=>wwv_flow_imp.id(91820275000000353)
,p_name=>'P61_BCODE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'رمز الفوترة (CPT/SBS)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>15
,p_cMaxlength=>50
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000354)
,p_name=>'P61_SAMPLE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'نوع العينة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:دم;BLOOD,مصل;SERUM,بلازما;PLASMA,بول;URINE,براز;STOOL,مسحة;SWAB,سائل شوكي;CSF,نسيج;TISSUE,بلغم;SPUTUM,أخرى;OTHER'
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
 p_id=>wwv_flow_imp.id(91820275000000355)
,p_name=>'P61_TAT'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'زمن النتيجة بالساعات'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000356)
,p_name=>'P61_RANGE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'المعدل الطبيعي والوحدة'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000357)
,p_name=>'P61_APR'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'يحتاج موافقة التأمين'
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
 p_id=>wwv_flow_imp.id(91820275000000358)
,p_name=>'P61_STATUS'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_prompt=>'الحالة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:نشط;ACTIVE,موقوف;INACTIVE'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000359)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000344)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000360)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    select code, name_ar, name_en, service_type, department_id, modality, price, billing_code, sample_type, turnaround_hours, normal_range, needs_approval, status_code',
'      into :P61_CODE, :P61_NAME, :P61_NAME_EN, :P61_TYPE, :P61_DEPT, :P61_MOD, :P61_PRICE, :P61_BCODE, :P61_SAMPLE, :P61_TAT, :P61_RANGE, :P61_APR, :P61_STATUS',
'      from his_service where id = :P61_ID and company_id = noona_his_pkg.company;',
'exception when no_data_found then null;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820275000000360
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000361)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l_doc clob; l number;',
'begin',
'    select json_object(''id'' value to_number(:P61_ID), ''code'' value :P61_CODE, ''name'' value :P61_NAME, ''name_en'' value :P61_NAME_EN, ''type'' value :P61_TYPE, ''dept'' value to_number(:P61_DEPT), ''modality'' value :P61_MOD, ''price'' value to_number(:P61_PRICE), ''billing_code'' value :P61_BCODE, ''sample'' value :P61_SAMPLE, ''tat'' value to_number(:P61_TAT), ''range'' value :P61_RANGE, ''approval'' value :P61_APR, ''status'' value :P61_STATUS returning clob) into l_doc from dual;',
'    l := noona_his_pkg.save_service(l_doc);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000359)
,p_process_success_message=>'تم حفظ الخدمة'
,p_internal_uid=>91820275000000361
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000362)
,p_plug_name=>'مواد الخدمة (تصرف من مستودع القسم عند الإنجاز)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820275000000363)
,p_name=>'P61_MSRV'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820275000000362)
,p_prompt=>'الخدمة'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select noona_his_pkg.service_name(s.id) || '' ('' || noona_his_pkg.type_label(s.service_type) || '' - '' || to_char(s.price, ''FM999G990D00'') || '')'' d, s.id r from his_service s where s.company_id = noona_his_pkg.company and s.status_code = ''ACTIVE'' order by s.service_type, s.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000364)
,p_name=>'P61_ITEM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820275000000362)
,p_prompt=>'المادة (كاشف، أنابيب، أفلام، مستلزمات)'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select i.name_ar || '' ('' || u.name_ar || '')'' d, i.id r from inv_item i join inv_uom u on u.id = i.base_uom_id where i.item_type not in (''SERVICE'', ''NON_STOCK'') and i.status_code = ''ACTIVE'' order by i.name_ar'
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
 p_id=>wwv_flow_imp.id(91820275000000365)
,p_name=>'P61_MQTY'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(91820275000000362)
,p_prompt=>'الكمية لكل خدمة (0 = حذف)'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820275000000366)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820275000000362)
,p_button_name=>'SET_MAT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'حفظ المادة'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820275000000367)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Material'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'noona_his_pkg.set_material(to_number(:P61_MSRV), to_number(:P61_ITEM), to_number(:P61_MQTY));'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820275000000366)
,p_process_success_message=>'تم حفظ مادة الخدمة'
,p_internal_uid=>91820275000000367
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000368)
,p_plug_name=>'مواد الخدمة المختارة'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>17
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.id, i.name_ar as item, m.quantity, u.name_ar as uom, noona_inv_pkg.avg_cost(m.item_id) as cost',
'  from his_service_material m join inv_item i on i.id = m.item_id join inv_uom u on u.id = i.base_uom_id where m.service_id = :P61_MSRV'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'مواد الخدمة المختارة'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000369)
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
,p_internal_uid=>91820275000000369
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000371)
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
 p_id=>wwv_flow_imp.id(91820275000000372)
,p_db_column_name=>'ITEM'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المادة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000373)
,p_db_column_name=>'QUANTITY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الكمية'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000374)
,p_db_column_name=>'UOM'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000375)
,p_db_column_name=>'COST'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'متوسط التكلفة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000370)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'370'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ITEM:QUANTITY:UOM:COST'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820275000000376)
,p_plug_name=>'الخدمات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select s.id, s.code, s.name_ar, s.name_en, noona_his_pkg.type_label(s.service_type) as stype, noona_his_pkg.modality_label(s.modality) as modality,',
'       d.name_ar as dept, s.price, s.billing_code, s.turnaround_hours, case s.needs_approval when ''Y'' then ''نعم'' end as approval,',
'       (select count(*) from his_service_material m where m.service_id = s.id) as materials,',
'       case s.status_code when ''ACTIVE'' then ''نشط'' else ''موقوف'' end as status',
'  from his_service s left join his_department d on d.id = s.department_id where s.company_id = noona_his_pkg.company order by s.service_type, s.name_ar'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'الخدمات'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820275000000377)
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
,p_internal_uid=>91820275000000377
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000379)
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
 p_id=>wwv_flow_imp.id(91820275000000380)
,p_db_column_name=>'CODE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'الرمز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000381)
,p_db_column_name=>'NAME_AR'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'الخدمة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000382)
,p_db_column_name=>'NAME_EN'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الاسم بالإنجليزية'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000383)
,p_db_column_name=>'STYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'النوع'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000384)
,p_db_column_name=>'MODALITY'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'الجهاز'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000385)
,p_db_column_name=>'DEPT'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'القسم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000386)
,p_db_column_name=>'PRICE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'السعر'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000387)
,p_db_column_name=>'BILLING_CODE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'رمز الفوترة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000388)
,p_db_column_name=>'TURNAROUND_HOURS'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'زمن النتيجة'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000389)
,p_db_column_name=>'APPROVAL'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'موافقة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000390)
,p_db_column_name=>'MATERIALS'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'المواد'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820275000000391)
,p_db_column_name=>'STATUS'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'الحالة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820275000000378)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'378'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CODE:NAME_AR:NAME_EN:STYPE:MODALITY:DEPT:PRICE:BILLING_CODE:TURNAROUND_HOURS:APPROVAL:MATERIALS:STATUS'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820275000000392)
,p_branch_action=>'f?p=&APP_ID.:61:&SESSION.::&DEBUG.::P61_MSRV:&P61_MSRV.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
