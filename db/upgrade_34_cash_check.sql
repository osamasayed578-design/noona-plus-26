-- =============================================================================
-- NOONA PLUS ERP | ترقية 34: منع الصرف فوق الرصيد في كل الأنظمة
--   * الصندوق لا يصرف فوق رصيده من أي نظام (السندات، المشتريات، المبيعات، نقاط البيع، المشروعات، العقارات، الإيجارات، الضرائب)
--   * الحساب البنكي كذلك، إلا بحد سحب على المكشوف يحدد للحساب (تسهيل بنكي)
--   * تقرير الأرصدة السالبة الحالية في شاشة الصناديق والبنوك لتسويتها (لا تعدل تلقائياً)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_34_cash_check.sql
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
PROMPT ========== حد السحب على المكشوف للحسابات البنكية
@@upgrade_parts/34_cash_check.sql
PROMPT ========== النقدية والبنوك
@@plsql/102_noona_csh_pkg.sql
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 34 done. Negative cash balances (if any) are listed in Finance > Cash and Banks
EXIT
