-- =============================================================================
-- NOONA PLUS ERP | فحص ترميز الحروف (قاعدة البيانات والعميل)
--   set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
--   sqlplus NOONA_OWNER@//localhost:1521/PDB @check_charset.sql
-- =============================================================================
SET SERVEROUTPUT ON
SET FEEDBACK OFF
SET LINES 200
COLUMN parameter FORMAT A28
COLUMN value FORMAT A30
SELECT parameter, value FROM nls_database_parameters
 WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET', 'NLS_LENGTH_SEMANTICS');
DECLARE
  l_db VARCHAR2(64);
BEGIN
  SELECT value INTO l_db FROM nls_database_parameters WHERE parameter = 'NLS_CHARACTERSET';
  DBMS_OUTPUT.PUT_LINE(CASE WHEN l_db = 'AL32UTF8' THEN 'OK   Database character set: AL32UTF8'
                            ELSE 'FAIL Database character set is ' || l_db || ' (AL32UTF8 required for Arabic)' END);
  DBMS_OUTPUT.PUT_LINE(CASE WHEN LENGTH('نونا') = 4 THEN 'OK   Client (NLS_LANG) is UTF-8'
                            ELSE 'FAIL Client is not UTF-8: run  set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then sqlplus again' END);
END;
/
EXIT
