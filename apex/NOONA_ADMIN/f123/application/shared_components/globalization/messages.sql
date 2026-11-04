prompt --application/shared_components/globalization/messages
begin
--   Manifest
--     MESSAGES: 8
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>17663301221950901
,p_default_application_id=>123
,p_default_id_offset=>0
,p_default_owner=>'NOONA_APP'
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000797)
,p_name=>'LINK'
,p_message_language=>'ar'
,p_message_text=>'فتح'
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000798)
,p_name=>'FLOW.SINGLE_VALIDATION_ERROR'
,p_message_language=>'ar'
,p_message_text=>'حدث خطأ واحد'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000799)
,p_name=>'FLOW.VALIDATION_ERROR'
,p_message_language=>'ar'
,p_message_text=>'حدثت %0 أخطاء'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000800)
,p_name=>'APEX.ERROR_MESSAGE_HEADING'
,p_message_language=>'ar'
,p_message_text=>'رسالة خطأ'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000801)
,p_name=>'APEX.SUCCESS_MESSAGE_HEADING'
,p_message_language=>'ar'
,p_message_text=>'رسالة نجاح'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000802)
,p_name=>'ERROR_MESSAGE'
,p_message_language=>'ar'
,p_message_text=>'رسالة خطأ'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000803)
,p_name=>'LAYOUT.T_SUCCESS_MSG'
,p_message_language=>'ar'
,p_message_text=>'رسالة نجاح'
,p_is_js_message=>true
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(91820262000000804)
,p_name=>'LAYOUT.T_ALT_SUCCESS_MSG'
,p_message_language=>'ar'
,p_message_text=>'رسالة نجاح'
,p_is_js_message=>true
);

wwv_flow_imp.component_end;
end;
/
