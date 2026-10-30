prompt --application/pages/page_00025
begin
--   Manifest
--     PAGE: 00025
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
 p_id=>25
,p_name=>'Correspondence Policy'
,p_alias=>'CORRESPONDENCE-POLICY'
,p_step_title=>'سياسة المراسلات الداخلية'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820267000000009)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000247)
,p_plug_name=>'الاتصال حسب الهيكل التنظيمي'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p class="nn-hint">عند التفعيل يراسل الموظف داخلياً: <b>رئيسه المباشر</b> ووحدته (الأعلى)، و<b>مرؤوسيه</b> (الأدنى)، و<b>زملاءه</b> تحت نفس الرئيس (الأفقي) فقط، ولا يتجاوز المستويات. رئيس الوحدة يراسل الوحدة الأعلى والوحدات التابعة والنظيرة. كل اتجاه بصلاحية في الأدوار: «الاتصال: مراسلة الرئيس المباشر…» (COR_CONTACT.UP)، المرؤوسين (DOWN)، الزملاء (PEER)، و«مراسلة أي جهة» (ANY) لمسجل المراسلات والإدارة العليا. الخطابات الواردة يحيلها المسجل دون قيد.<br>قبل التفعيل: أدخل الهيكل والمناصب وعيّن الموظفين عليها واربط المستخدمين بموظفيهم؛ من لا منصب له لا يراسل إلا بالرد.</p>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(91820267000000248)
,p_name=>'P25_RESTRICT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(91820267000000247)
,p_prompt=>'تقييد المراسلات الداخلية بالهيكل التنظيمي'
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
 p_id=>wwv_flow_imp.id(91820267000000249)
,p_name=>'P25_REPLY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(91820267000000247)
,p_prompt=>'الرد على من راسلك'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:مسموح دائماً;Y,حسب الهيكل فقط;N'
,p_cHeight=>1
,p_lov_display_extra=>'NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000250)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Load Policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare l json_object_t;',
'begin',
'    l := json_object_t.parse(noona_cor_pkg.policy_json);',
'    :P25_RESTRICT := l.get_string(''restrict''); :P25_REPLY := l.get_string(''reply'');',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>91820267000000250
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820267000000251)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820267000000247)
,p_button_name=>'SAVE_POLICY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'حفظ'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(91820267000000252)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Save Policy'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    noona_cor_pkg.save_policy(:P25_RESTRICT, :P25_REPLY);',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(91820267000000251)
,p_process_success_message=>'تم حفظ سياسة المراسلات'
,p_internal_uid=>91820267000000252
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820267000000253)
,p_plug_name=>'من يراسل من (موظفو الشركة ومناصبهم ورؤساؤهم المباشرون)'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.id, u.display_name, pos.name_ar as position_name, un.name_ar as unit_name,',
'       (select u2.display_name from sec_user_membership m2 join sec_user u2 on u2.id = m2.user_id',
'         where m2.id = noona_org_pkg.manager_of(m.id)) as manager_name',
'  from sec_user_membership m join sec_user u on u.id = m.user_id',
'  left join org_position pos on pos.id = noona_org_pkg.primary_position(m.id)',
'  left join org_unit un on un.id = pos.org_unit_id',
' where m.status_code = ''ACTIVE'' and m.default_company_id = noona_dms_pkg.company',
' order by un.name_ar nulls last, u.display_name'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'من يراسل من (موظفو الشركة ومناصبهم ورؤساؤهم المباشرون)'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(91820267000000254)
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
,p_internal_uid=>91820267000000254
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000256)
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
 p_id=>wwv_flow_imp.id(91820267000000257)
,p_db_column_name=>'DISPLAY_NAME'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'المستخدم'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000258)
,p_db_column_name=>'POSITION_NAME'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'المنصب'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000259)
,p_db_column_name=>'UNIT_NAME'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'الوحدة'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(91820267000000260)
,p_db_column_name=>'MANAGER_NAME'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'الرئيس المباشر'
,p_column_type=>'STRING'
,p_heading_alignment=>'CENTER'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(91820267000000255)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'255'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'DISPLAY_NAME:POSITION_NAME:UNIT_NAME:MANAGER_NAME'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(91820267000000261)
,p_branch_action=>'f?p=&APP_ID.:25:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);

wwv_flow_imp.component_end;
end;
/
