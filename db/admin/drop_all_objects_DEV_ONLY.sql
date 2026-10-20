-- =============================================================================
-- NOONA PLUS ERP | حذف كل كائنات المخطط الحالي (بيئة تطوير فقط - لا يمكن التراجع)
--   يحذف: الجداول وبياناتها نهائياً (PURGE)، الحزم، الإجراءات، الدوال، الـViews، الـTriggers،
--          الـSequences، الأنواع، المرادفات، المهام المجدولة، وسلة المحذوفات.
--   لا يحذف المستخدم نفسه ولا صلاحياته؛ بعده يمكن تشغيل install.sql مباشرة.
--
--   sqlplus NOONA_OWNER@//host:1521/PDB @admin/drop_all_objects_DEV_ONLY.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @admin/drop_all_objects_DEV_ONLY.sql   (لحذف المرادفات)
-- =============================================================================
SET SERVEROUTPUT ON
SET FEEDBACK OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ============================================================
PROMPT  ALL objects of the current schema will be dropped permanently
PROMPT ============================================================
SELECT USER AS schema_name, COUNT(*) AS objects_before FROM user_objects;

ACCEPT confirm CHAR PROMPT 'Type the schema name to confirm (NOONA_OWNER / NOONA_APP): '

DECLARE
  l_confirm VARCHAR2(128) := UPPER(TRIM('&confirm'));
  l_dropped PLS_INTEGER := 0;
  l_failed  PLS_INTEGER := 0;

  PROCEDURE run(p_sql VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
    l_dropped := l_dropped + 1;
  EXCEPTION WHEN OTHERS THEN
    l_failed := l_failed + 1;
    DBMS_OUTPUT.PUT_LINE('SKIP: ' || p_sql || ' -> ' || SQLERRM);
  END run;
BEGIN
  IF l_confirm IS NULL OR l_confirm <> USER THEN
    RAISE_APPLICATION_ERROR(-20000, 'تم الإلغاء: اسم المخطط غير مطابق (' || USER || ')');
  END IF;
  IF USER IN ('SYS', 'SYSTEM', 'APEX_PUBLIC_USER', 'XDB') OR USER LIKE 'APEX\_%' ESCAPE '\' THEN
    RAISE_APPLICATION_ERROR(-20000, 'مرفوض: لا يشغل على مخطط نظام');
  END IF;

  -- 1) المهام المجدولة
  FOR j IN (SELECT job_name FROM user_scheduler_jobs) LOOP
    BEGIN
      DBMS_SCHEDULER.DROP_JOB(j.job_name, force => TRUE);
      l_dropped := l_dropped + 1;
    EXCEPTION WHEN OTHERS THEN
      l_failed := l_failed + 1;
    END;
  END LOOP;

  -- 2) الجداول (مع القيود والسياسات والـTriggers والفهارس والـIdentity) نهائياً بلا سلة محذوفات
  FOR t IN (SELECT table_name FROM user_tables
             WHERE table_name NOT LIKE 'BIN$%' AND nested = 'NO'
               AND (iot_type IS NULL OR iot_type = 'IOT')) LOOP
    run('DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE');
  END LOOP;

  -- 3) باقي الكائنات (الأجسام تحذف مع رؤوس الحزم والأنواع)
  FOR o IN (SELECT object_name, object_type FROM user_objects
             WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW', 'PACKAGE', 'PROCEDURE', 'FUNCTION',
                                   'TRIGGER', 'SEQUENCE', 'SYNONYM', 'TYPE', 'JAVA SOURCE')
               AND object_name NOT LIKE 'ISEQ$$%' AND object_name NOT LIKE 'BIN$%'
             ORDER BY CASE object_type WHEN 'MATERIALIZED VIEW' THEN 1 WHEN 'VIEW' THEN 2
                                       WHEN 'TYPE' THEN 9 ELSE 5 END) LOOP
    run('DROP ' || o.object_type || ' "' || o.object_name || '"' ||
        CASE o.object_type WHEN 'TYPE' THEN ' FORCE' END);
  END LOOP;

  EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
  DBMS_OUTPUT.PUT_LINE('Dropped: ' || l_dropped || ', skipped: ' || l_failed);
END;
/

SELECT COUNT(*) AS objects_after FROM user_objects;
PROMPT Done. Context NOONA_CTX is owned by SYS and is recreated by install.sql.
