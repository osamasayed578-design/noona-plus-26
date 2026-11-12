-- =============================================================================
-- NOONA PLUS ERP | حذف كل المؤسسات والشركات وبياناتها (تشغل بحساب NOONA_OWNER بعد نسخة احتياطية)
--   * يحذف كل صف له TENANT_ID في كل الجداول، وسجل المؤسسات PLT_TENANT، ومستخدمي المؤسسات وبيانات دخولهم،
--     وطلبات التسجيل الذاتي وإعادة تعيين كلمات المرور
--   * يبقي بيانات المنصة: مستخدمي المنصة (PLATFORM_ADMIN والدعم)، الوحدات والعروض والأسعار والإعدادات،
--     البيانات المرجعية العامة، حزم الدول، القيم الافتراضية للمنصة (TENANT_ID فارغ)
--   * المشغلات والقيود المرجعية تعطل أثناء الحذف ثم تعاد كما كانت
-- لا يستدعى إلا من tools/vm/reset_nine_orgs.sh بعد النسخة الاحتياطية.
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
DECLARE
  TYPE t_names IS TABLE OF VARCHAR2(261);
  l_trg  t_names;
  l_fk   t_names;
  l_rows NUMBER := 0;
  l_n    NUMBER;
  l_bad  NUMBER := 0;
  PROCEDURE ex(p VARCHAR2) IS BEGIN EXECUTE IMMEDIATE p; END ex;
BEGIN
  -- المهام المجدولة تتوقف أثناء الحذف
  FOR j IN (SELECT job_name FROM user_scheduler_jobs WHERE enabled = 'TRUE') LOOP
    BEGIN DBMS_SCHEDULER.DISABLE(j.job_name, TRUE); EXCEPTION WHEN OTHERS THEN NULL; END;
  END LOOP;
  SELECT trigger_name BULK COLLECT INTO l_trg FROM user_triggers WHERE status = 'ENABLED' AND base_object_type = 'TABLE';
  SELECT table_name || '.' || constraint_name BULK COLLECT INTO l_fk FROM user_constraints WHERE constraint_type = 'R' AND status = 'ENABLED';
  FOR i IN 1 .. l_trg.COUNT LOOP ex('ALTER TRIGGER ' || l_trg(i) || ' DISABLE'); END LOOP;
  FOR i IN 1 .. l_fk.COUNT LOOP
    ex('ALTER TABLE ' || SUBSTR(l_fk(i), 1, INSTR(l_fk(i), '.') - 1) || ' DISABLE CONSTRAINT ' || SUBSTR(l_fk(i), INSTR(l_fk(i), '.') + 1));
  END LOOP;
  NOONA_CORE_PKG.begin_system;
  NOONA_CTX_PKG.enable_purge_mode;

  -- كل بيانات المؤسسات
  FOR t IN (SELECT t.table_name FROM user_tables t
             WHERE EXISTS (SELECT 1 FROM user_tab_columns c WHERE c.table_name = t.table_name AND c.column_name = 'TENANT_ID')
               AND t.table_name NOT LIKE 'BIN$%' AND t.temporary = 'N' AND t.iot_type IS NULL
               AND NOT EXISTS (SELECT 1 FROM user_mviews m WHERE m.mview_name = t.table_name)) LOOP
    EXECUTE IMMEDIATE 'DELETE FROM ' || t.table_name || ' WHERE tenant_id IS NOT NULL';
    l_rows := l_rows + SQL%ROWCOUNT;
  END LOOP;
  -- السجلات العامة المرتبطة بالمؤسسات
  DELETE FROM plt_tenant;                  l_rows := l_rows + SQL%ROWCOUNT;
  DELETE FROM plt_password_reset;          l_rows := l_rows + SQL%ROWCOUNT;
  DELETE FROM plt_signup;                  l_rows := l_rows + SQL%ROWCOUNT;
  DELETE FROM plt_license_activation;      l_rows := l_rows + SQL%ROWCOUNT;
  FOR t IN (SELECT 'SEC_CREDENTIAL' n FROM dual UNION ALL SELECT 'SEC_DEVICE' FROM dual UNION ALL SELECT 'SEC_MFA_FACTOR' FROM dual
            UNION ALL SELECT 'SEC_LOGIN_NAME_HIST' FROM dual) LOOP
    EXECUTE IMMEDIATE 'DELETE FROM ' || t.n || ' WHERE user_id IN (SELECT id FROM sec_user WHERE user_type NOT IN (''PLATFORM_ADMIN'', ''SUPPORT'', ''BREAK_GLASS''))';
    l_rows := l_rows + SQL%ROWCOUNT;
  END LOOP;
  DELETE FROM sec_login_attempt;           l_rows := l_rows + SQL%ROWCOUNT;
  DELETE FROM sec_user WHERE user_type NOT IN ('PLATFORM_ADMIN', 'SUPPORT', 'BREAK_GLASS');
  l_rows := l_rows + SQL%ROWCOUNT;
  -- أحداث تدقيق المنصة التي تشير لمؤسسات أو مستخدمين حذفوا
  DELETE FROM aud_event WHERE (company_id IS NOT NULL AND company_id NOT IN (SELECT id FROM org_company))
                           OR (actor_user_id IS NOT NULL AND actor_user_id NOT IN (SELECT id FROM sec_user));
  l_rows := l_rows + SQL%ROWCOUNT;
  -- سلسلة تدقيق المنصة: حذف صفوف منها يكسر ترابطها، فتعاد ختمها على الصفوف الباقية (المشغلات معطلة الآن)
  l_n := NOONA_AUDIT_PKG.reseal_chain(NULL);
  COMMIT;

  NOONA_CTX_PKG.disable_purge_mode;
  NOONA_CORE_PKG.end_system;
  FOR i IN 1 .. l_fk.COUNT LOOP
    BEGIN
      ex('ALTER TABLE ' || SUBSTR(l_fk(i), 1, INSTR(l_fk(i), '.') - 1) || ' ENABLE VALIDATE CONSTRAINT ' || SUBSTR(l_fk(i), INSTR(l_fk(i), '.') + 1));
    EXCEPTION WHEN OTHERS THEN
      -- صفوف يتيمة في جدول عام: يفعل القيد للصفوف الجديدة ويبلغ عنه
      ex('ALTER TABLE ' || SUBSTR(l_fk(i), 1, INSTR(l_fk(i), '.') - 1) || ' ENABLE NOVALIDATE CONSTRAINT ' || SUBSTR(l_fk(i), INSTR(l_fk(i), '.') + 1));
      l_bad := l_bad + 1;
      DBMS_OUTPUT.PUT_LINE('NOVALIDATE ' || l_fk(i));
    END;
  END LOOP;
  FOR i IN 1 .. l_trg.COUNT LOOP ex('ALTER TRIGGER ' || l_trg(i) || ' ENABLE'); END LOOP;
  FOR j IN (SELECT job_name FROM user_scheduler_jobs WHERE enabled = 'FALSE' AND job_name LIKE 'NOONA%') LOOP
    BEGIN DBMS_SCHEDULER.ENABLE(j.job_name); EXCEPTION WHEN OTHERS THEN NULL; END;
  END LOOP;
  SELECT COUNT(*) INTO l_n FROM sec_user;
  DBMS_OUTPUT.PUT_LINE('PURGE_OK rows=' || l_rows || ' platform_users=' || l_n || ' fk_novalidate=' || l_bad);
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  BEGIN NOONA_CTX_PKG.disable_purge_mode; NOONA_CORE_PKG.end_system; EXCEPTION WHEN OTHERS THEN NULL; END;
  -- إعادة المشغلات والقيود حتى لا يبقى النظام بلا حماية
  IF l_fk IS NOT NULL THEN
    FOR i IN 1 .. l_fk.COUNT LOOP
      BEGIN ex('ALTER TABLE ' || SUBSTR(l_fk(i), 1, INSTR(l_fk(i), '.') - 1) || ' ENABLE NOVALIDATE CONSTRAINT ' || SUBSTR(l_fk(i), INSTR(l_fk(i), '.') + 1));
      EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
  END IF;
  IF l_trg IS NOT NULL THEN
    FOR i IN 1 .. l_trg.COUNT LOOP BEGIN ex('ALTER TRIGGER ' || l_trg(i) || ' ENABLE'); EXCEPTION WHEN OTHERS THEN NULL; END; END LOOP;
  END IF;
  DBMS_OUTPUT.PUT_LINE('PURGE_FAILED ' || SQLERRM);
  RAISE;
END;
/
EXIT
