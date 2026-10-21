-- =============================================================================
-- NOONA PLUS ERP | ترقية 10: المالية - المحرك المحاسبي والنقدية (سندات القبض والصرف والمصروفات)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_10_cash.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/
PROMPT ========== CSH_TRANSACTION: بيان السند، نوع المصروفات، حالة الإرسال
DECLARE
  l_n NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_n FROM user_tab_columns WHERE table_name = 'CSH_TRANSACTION' AND column_name = 'DESCRIPTION';
  IF l_n = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE CSH_TRANSACTION ADD (DESCRIPTION VARCHAR2(1000 CHAR))';
    EXECUTE IMMEDIATE q'[COMMENT ON COLUMN CSH_TRANSACTION.DESCRIPTION IS 'بيان السند']';
  END IF;
  EXECUTE IMMEDIATE 'ALTER TABLE CSH_TRANSACTION DROP CONSTRAINT CSH_TRANSACTION_TXN_TYPE_CK';
  EXECUTE IMMEDIATE q'[ALTER TABLE CSH_TRANSACTION ADD CONSTRAINT CSH_TRANSACTION_TXN_TYPE_CK CHECK (TXN_TYPE IN ('RECEIPT', 'PAYMENT', 'EXPENSE', 'TRANSFER_OUT', 'TRANSFER_IN', 'BANK_CHARGE', 'INTEREST', 'FX_ADJUSTMENT', 'ADJUSTMENT', 'REPLENISHMENT'))]';
  EXECUTE IMMEDIATE 'ALTER TABLE CSH_TRANSACTION DROP CONSTRAINT CSH_TRANSACTION_STATUS_CODE_CK';
  EXECUTE IMMEDIATE q'[ALTER TABLE CSH_TRANSACTION ADD CONSTRAINT CSH_TRANSACTION_STATUS_CODE_CK CHECK (STATUS_CODE IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'SUBMITTED_TO_BANK', 'SETTLED', 'FAILED', 'REVERSED', 'CANCELLED'))]';
END;
/
PROMPT ========== البنوك المحلية
@@seed/03_banks.sql
PROMPT ========== NOONA_UI_PKG / NOONA_GL_PKG / NOONA_ACE_PKG / NOONA_CSH_PKG
@@plsql/86_noona_ui_pkg.sql
@@plsql/100_noona_gl_pkg.sql
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_CSH_PKG TO NOONA_APP;
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
PROMPT ========== Upgrade 10 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
EXIT
