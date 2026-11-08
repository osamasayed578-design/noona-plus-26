prompt --application/pages/page_00070
begin
--   Manifest
--     PAGE: 00070
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_page.create_page(
 p_id=>70
,p_name=>'Integrations'
,p_alias=>'INTEGRATIONS'
,p_step_title=>'التكاملات وواجهات API'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(91820262000000701)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000702)
,p_plug_name=>'مؤشرات التكاملات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:t-Region--removeHeader js-removeLandmark:t-Region--noUI'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.summary_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000703)
,p_plug_name=>'إجراءات'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>15
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000704)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'CLIENTS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'عملاء API'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:71:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000705)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'WEBHOOKS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Webhooks'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:73:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000706)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'OUTBOX'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الأحداث الصادرة'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:74:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000707)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'CHANNELS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'الرسائل SMS / واتساب'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:75:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000708)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'IMPORT'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'استيراد البيانات'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:76:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(91820262000000709)
,p_button_sequence=>60
,p_button_plug_id=>wwv_flow_imp.id(91820262000000703)
,p_button_name=>'DOCS'
,p_button_action=>'REDIRECT_URL'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'نقاط النهاية والتوثيق'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:77:&SESSION.::&DEBUG.:::'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000710)
,p_plug_name=>'كيف تتكامل'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<ol class="nn-hint"><li>أنشئ <b>عميل API</b> لكل نظام خارجي (متجر، تطبيق جوال، نظام شريك) بدور يحدد ما يستطيع الوصول إليه.</li><li>النظام يطلب رمز دخول: <code dir="ltr">POST /ords/noona/v1/token</code> بمعرف العميل والسر، ثم يرسل <code dir="ltr">Authorization: Bearer &lt;token&gt;</code> مع كل طلب.</li><li>العمليات المالية (الفواتير والتحصيل) تتطلب ترويسة <code dir="ltr">Idempotency-Key</code> فلا تتكرر عند إعادة الإرسال.</li><li>للإشعار الفوري بالأحداث سجل <b>Webhook</b>: يصل كل حدث موقعاً بـ <code dir="ltr">X-Noona-Signature</code> (HMAC-SHA256) ويعاد إرساله تلقائياً عند الفشل.</li></ol>'))
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(91820262000000711)
,p_plug_name=>'آخر الطلبات'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'return noona_api_pkg.requests_html;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);

wwv_flow_imp.component_end;
end;
/
