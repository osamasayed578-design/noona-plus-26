-- =============================================================================
-- NOONA PLUS 26 | ترقية AI-01: مساعد الذكاء الاصطناعي (Oracle AI Database 26ai + APEX 26.2 فقط)
--   * مزودان على مستوى المنصة: Claude و OCI Generative AI؛ مرجع كل منهما الرمز الثابت لخدمة الذكاء الاصطناعي في مساحة عمل APEX
--     (NOONA_AI_CLAUDE و NOONA_AI_OCI) ينشئها مسؤول مساحة العمل ويدخل المفتاح بنفسه (docs/ai_setup_26.md)
--   * نماذج المحادثة، أدوات القراءة السبع، والحزمة NOONA_AI_PKG
--   sqlplus NOONA_OWNER@//host:1521/FREEPDB1 @upgrade_ai26_01.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== المزودون والنماذج والأدوات (مستوى المنصة)
DECLARE
  l_p NUMBER;
  PROCEDURE provider(p_code VARCHAR2, p_ar VARCHAR2, p_en VARCHAR2, p_type VARCHAR2, p_ref VARCHAR2, p_region VARCHAR2) IS
  BEGIN
    MERGE INTO ai_provider p USING (SELECT p_code c FROM dual) x ON (p.code = x.c AND p.tenant_id IS NULL)
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, provider_type, endpoint_ref, processing_region, training_opt_out, status_code)
          VALUES (NULL, p_code, p_ar, p_en, p_type, p_ref, p_region, 'Y', 'ACTIVE');
  END;
  PROCEDURE model(p_prov VARCHAR2, p_code VARCHAR2, p_ar VARCHAR2, p_ident VARCHAR2, p_ctx NUMBER, p_cin NUMBER, p_cout NUMBER) IS
  BEGIN
    SELECT id INTO l_p FROM ai_provider WHERE code = p_prov AND tenant_id IS NULL;
    MERGE INTO ai_model m USING (SELECT p_code c FROM dual) x ON (m.code = x.c AND m.tenant_id IS NULL)
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, provider_id, model_kind, model_identifier, max_context_tokens,
                                   cost_per_1k_input, cost_per_1k_output, status_code)
          VALUES (NULL, p_code, p_ar, p_code, l_p, 'CHAT', p_ident, p_ctx, p_cin, p_cout, 'ACTIVE');
  END;
  PROCEDURE tool(p_code VARCHAR2, p_ar VARCHAR2, p_perm VARCHAR2) IS
  BEGIN
    MERGE INTO ai_tool t USING (SELECT p_code c FROM dual) x ON (t.code = x.c AND t.tenant_id IS NULL)
     WHEN NOT MATCHED THEN INSERT (tenant_id, code, name_ar, name_en, operation_class, permission_code, handler_api, requires_human_confirm, status_code)
          VALUES (NULL, p_code, p_ar, LOWER(p_code), 'READ', p_perm, 'NOONA_AI_PKG.run_tool', 'N', 'ENABLED');
  END;
BEGIN
  NOONA_CTX_PKG.enable_system_mode;
  provider('CLAUDE', 'Anthropic Claude', 'Anthropic Claude', 'CLOUD_API', 'NOONA_AI_CLAUDE', 'Anthropic API');
  provider('OCI_GENAI', 'Oracle OCI Generative AI', 'Oracle OCI Generative AI', 'ORACLE_OCI_GENAI', 'NOONA_AI_OCI', 'OCI region');
  model('CLAUDE', 'CLAUDE_SONNET', 'Claude Sonnet (متوازن)', 'claude-sonnet-5-5', 200000, NULL, NULL);
  model('CLAUDE', 'CLAUDE_HAIKU', 'Claude Haiku (سريع واقتصادي)', 'claude-haiku-5-5', 200000, NULL, NULL);
  model('CLAUDE', 'CLAUDE_OPUS', 'Claude Opus (الأقوى)', 'claude-opus-5-5', 200000, NULL, NULL);
  model('OCI_GENAI', 'OCI_LLAMA', 'Meta Llama على OCI', 'meta.llama-3.3-70b-instruct', 128000, NULL, NULL);
  tool('LIST_METRICS', 'قائمة المؤشرات المتاحة', NULL);
  tool('GET_KPI', 'قيمة مؤشر لفترة', NULL);
  tool('GET_SERIES', 'سلسلة زمنية لمؤشر', NULL);
  tool('GET_FORECAST', 'تنبؤ مؤشر', NULL);
  tool('GET_ANOMALIES', 'القيم غير المعتادة', NULL);
  tool('GET_MODULE_DASHBOARD', 'لوحة موديول', NULL);
  tool('GET_PAGE_CONTEXT', 'سياق الصفحة الحالية', NULL);
  tool('GET_COMPANY_BREAKDOWN', 'توزيع مؤشر على شركات المجموعة', NULL);
  NOONA_CTX_PKG.disable_system_mode;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CTX_PKG.disable_system_mode;
  RAISE;
END;
/
PROMPT ========== الحزمة
@@plsql26/140_noona_ai_pkg.sql
GRANT EXECUTE ON NOONA_AI_PKG TO NOONA_APP;

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade AI-01 done. As NOONA_APP: CREATE OR REPLACE SYNONYM NOONA_AI_PKG FOR NOONA_OWNER.NOONA_AI_PKG;
EXIT
