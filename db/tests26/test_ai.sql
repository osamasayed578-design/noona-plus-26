-- =============================================================================
-- NOONA PLUS 26 | اختبار مساعد الذكاء الاصطناعي بحساب NOONA_APP مع الخادم التجريبي (db/dev/ai_mock_service.sql)
--   التفعيل والحصة، المحادثة مع الأدوات بصلاحيات المستخدم، السجل والاستهلاك، المحادثات، الملخص التنفيذي - يتراجع في النهاية
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_prov NUMBER;
  l_mod  NUMBER;
  l_c    CLOB;
  l_j    JSON_OBJECT_T;
  l_conv NUMBER;
  l_msg  NUMBER;
  l_n    NUMBER;
  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE rejects(p_name VARCHAR2, p_code VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    ok(p_name, FALSE, 'accepted');
  EXCEPTION WHEN OTHERS THEN
    ok(p_name, INSTR(SQLERRM, p_code) > 0, SUBSTR(SQLERRM, 1, 200));
  END rejects;
  FUNCTION ask(p_q VARCHAR2, p_conv NUMBER DEFAULT NULL) RETURN JSON_OBJECT_T IS
  BEGIN
    RETURN JSON_OBJECT_T.parse(NOONA_AI_PKG.chat('{"question":"' || p_q || '","conversationId":'
      || NVL(TO_CHAR(p_conv), 'null') || ',"app":"NOONA_FIN","page":"98","pageTitle":"التحليلات والتنبؤ","module":"FIN",'
      || '"pageText":"الإيرادات 0 المصروفات 0"}'));
  END ask;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => 'ADMIN');
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  DELETE FROM ai_tenant_setting;
  ok('assistant off before setup', NOONA_AI_PKG.is_enabled = 'N');
  rejects('chat refused when not enabled', 'NOONA-AI-011',
    'DECLARE c CLOB; BEGIN c := NOONA_AI_PKG.chat(''{"question":"مرحبا"}''); END;');

  -- مزود ونموذج تجريبيان للمؤسسة (الخادم التجريبي)
  INSERT INTO ai_provider (code, name_ar, provider_type, endpoint_ref, status_code)
  VALUES ('TEST_MOCK', 'خادم تجريبي', 'PRIVATE_HOSTED', 'NOONA_AI_MOCK', 'ACTIVE') RETURNING id INTO l_prov;
  INSERT INTO ai_model (code, name_ar, provider_id, model_kind, model_identifier, max_context_tokens, cost_per_1k_input, cost_per_1k_output, status_code)
  VALUES ('TEST_MOCK_CHAT', 'نموذج تجريبي', l_prov, 'CHAT', 'noona-mock', 8000, 0.003, 0.015, 'ACTIVE') RETURNING id INTO l_mod;
  rejects('enabling needs an active chat model', 'NOONA-AI-003',
    'BEGIN NOONA_AI_PKG.save_settings(''{"enabled":"Y","modelId":-1}''); END;');
  rejects('quota at least 1000', 'NOONA-AI-004',
    'BEGIN NOONA_AI_PKG.save_settings(''{"enabled":"Y","modelId":' || l_mod || ',"quota":10}''); END;');
  NOONA_AI_PKG.save_settings('{"enabled":"Y","modelId":' || l_mod || ',"quota":500000,"retentionDays":30}');
  ok('assistant on after setup', NOONA_AI_PKG.is_enabled = 'Y');
  l_j := JSON_OBJECT_T.parse(NOONA_AI_PKG.settings_json);
  ok('settings show model and service', l_j.get_string('model') = 'noona-mock' AND l_j.get_string('service') = 'NOONA_AI_MOCK');

  -- الأدوات مباشرة بصلاحيات المستخدم
  l_c := NOONA_AI_PKG.run_tool('list_metrics', '{"module":"FIN"}');
  ok('tool list_metrics returns finance metrics', JSON_ARRAY_T.parse(l_c).get_size = 6);
  l_c := NOONA_AI_PKG.run_tool('get_kpi', '{"metric":"REVENUE","period":"THIS_YEAR"}');
  ok('tool get_kpi returns value', JSON_OBJECT_T.parse(l_c).has('value'));
  l_c := NOONA_AI_PKG.run_tool('get_kpi', '{"metric":"NO_SUCH"}');
  ok('tool errors are returned to the model, not raised', JSON_OBJECT_T.parse(l_c).has('error'));
  l_c := NOONA_AI_PKG.run_tool('get_forecast', '{"metric":"REVENUE","periods":2}');
  ok('tool get_forecast returns 2 periods', JSON_OBJECT_T.parse(l_c).get_array('forecast').get_size = 2);

  -- المحادثة: النموذج يستدعي get_kpi ثم يلخص نتيجتها
  l_j := ask('كم الإيرادات هذا الشهر؟');
  l_conv := l_j.get_number('conversationId'); l_msg := l_j.get_number('messageId');
  ok('chat answers from tool data', INSTR(l_j.get_string('answer'), 'بحسب بيانات النظام') > 0 AND INSTR(l_j.get_string('answer'), '"metric":"REVENUE"') > 0,
     SUBSTR(l_j.get_string('answer'), 1, 200));
  ok('chat reports the tool used', l_j.get_array('tools').get_size = 1 AND l_j.get_array('tools').get_string(0) = 'get_kpi');
  SELECT COUNT(*) INTO l_n FROM ai_message WHERE conversation_id = l_conv;
  ok('user + assistant messages stored', l_n = 2);
  SELECT COUNT(*) INTO l_n FROM ai_tool_call c JOIN ai_message m ON m.id = c.message_id WHERE m.conversation_id = l_conv AND c.result_code = 'SUCCESS';
  ok('tool call audited under the user', l_n = 1);
  SELECT COUNT(*) INTO l_n FROM ai_usage WHERE usage_date = TRUNC(SYSDATE) AND model_id = l_mod AND feature_code = 'CHAT' AND request_count = 1;
  ok('usage recorded', l_n = 1);
  -- متابعة في نفس المحادثة: تنبؤ
  l_j := ask('ما توقع الإيرادات للأشهر القادمة؟', l_conv);
  ok('follow-up stays in the conversation', l_j.get_number('conversationId') = l_conv);
  ok('forecast question uses get_forecast', l_j.get_array('tools').get_string(0) = 'get_forecast');
  l_j := ask('قارن الإيرادات هذا العام بالعام الماضي', l_conv);
  ok('year question uses get_year_comparison', l_j.get_array('tools').get_string(0) = 'get_year_comparison');
  ok('year comparison answer carries the years', INSTR(l_j.get_string('answer'), '"years"') > 0 OR INSTR(l_j.get_string('answer'), 'ytd') > 0,
     SUBSTR(l_j.get_string('answer'), 1, 200));
  l_j := ask('ما الذي في هذه الصفحة؟', l_conv);
  ok('page question uses the page context', INSTR(l_j.get_string('answer'), 'التحليلات والتنبؤ') > 0, SUBSTR(l_j.get_string('answer'), 1, 200));
  ok('conversation listed for the user', DBMS_LOB.INSTR(NOONA_AI_PKG.conversations_json, '"id":' || l_conv) > 0);
  ok('messages of the conversation', JSON_ARRAY_T.parse(NOONA_AI_PKG.messages_json(l_conv)).get_size = 8);
  NOONA_AI_PKG.feedback(l_msg, 1, 'مفيدة');
  SELECT COUNT(*) INTO l_n FROM ai_feedback WHERE message_id = l_msg AND rating = 1;
  ok('feedback stored', l_n = 1);
  rejects('feedback rating validated', 'NOONA-AI-017', 'BEGIN NOONA_AI_PKG.feedback(' || l_msg || ', 7); END;');
  rejects('unknown conversation refused', 'NOONA-AI-014',
    'DECLARE c CLOB; BEGIN c := NOONA_AI_PKG.chat(''{"question":"x","conversationId":-5}''); END;');
  rejects('empty question refused', 'NOONA-AI-013', 'DECLARE c CLOB; BEGIN c := NOONA_AI_PKG.chat(''{"question":""}''); END;');

  -- الملخص التنفيذي
  l_j := JSON_OBJECT_T.parse(NOONA_AI_PKG.executive_summary('FIN,SAL'));
  ok('executive summary returned', LENGTH(l_j.get_string('summary')) > 10);

  -- الحصة الشهرية
  NOONA_AI_PKG.save_settings('{"enabled":"Y","modelId":' || l_mod || ',"quota":1000}');
  ok('usage counted this month', NOONA_AI_PKG.month_tokens > 1000, NOONA_AI_PKG.month_tokens);
  rejects('quota exhausted refuses chat', 'NOONA-AI-012', 'DECLARE c CLOB; BEGIN c := NOONA_AI_PKG.chat(''{"question":"مرحبا"}''); END;');

  NOONA_AI_PKG.delete_conversation(l_conv);
  ok('deleted conversation hidden', DBMS_LOB.INSTR(NOONA_AI_PKG.conversations_json, '"id":' || l_conv) = 0);
  NOONA_AI_PKG.save_settings('{"enabled":"N"}');
  ok('disabling turns the assistant off', NOONA_AI_PKG.is_enabled = 'N');

  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('========== ai: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  DBMS_OUTPUT.PUT_LINE('========== ai: ' || g_pass || ' passed, ' || (g_fail + 1) || ' failed');
END;
/
EXIT
