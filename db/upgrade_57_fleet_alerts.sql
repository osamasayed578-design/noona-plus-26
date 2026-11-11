-- =============================================================================
-- NOONA PLUS ERP | ترقية 57: تنبيهات استبدال قطع الغيار والصيانة الدورية للأسطول
--   * مهمة NOONA_TRN_MAINT_ALERTS كل 6 ساعات: القطع التي اقترب أو حان موعد استبدالها بالمسافة أو بالمدة
--     (الإطارات بأيهما أقرب، البطاريات بالمدة) والصيانات الدورية المستحقة → إشعار داخل النظام لمدير المؤسسة
--     ومن له صلاحية أوامر الصيانة (مرة عند الاقتراب ومرة عند التجاوز) وملخص بالبريد إن كان مفعلاً
--   * تنبيه في لوحة الحركة بعدد البنود المستحقة
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_57_fleet_alerts.sql
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
PROMPT ========== الحزمة
WHENEVER SQLERROR CONTINUE
@@plsql/135_noona_trn_pkg.sql
PROMPT ========== أنواع الإشعارات والمهمة
@@upgrade_parts/57_trn_alerts.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 57 done
EXIT
