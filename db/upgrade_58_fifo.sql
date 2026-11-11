-- =============================================================================
-- NOONA PLUS ERP | ترقية 58: الصرف بطريقة FIFO (الوارد أولاً يصرف أولاً)
--   * طريقة التكلفة لكل صنف أو لفئة كاملة: المتوسط المرجح (الافتراضي) أو FIFO
--   * كل استلام طبقة بسعره، وكل صرف (مبيعات، نقاط بيع، تصنيع، صيانة، إتلاف، مرتجع مشتريات) يستهلك الأقدم فالأحدث
--   * التحول إلى FIFO يجعل الرصيد القائم أول طبقة بتكلفته الحالية؛ التحويل بين المستودعات لا يغير الطبقات
--   * صفحة «طريقة التكلفة» في سلسلة الإمداد مع طبقات كل صنف
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_58_fifo.sql
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
PROMPT ========== طبقات التكلفة
@@upgrade_parts/58_fifo.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/104_noona_inv_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 58 done. Now import app 131
EXIT
