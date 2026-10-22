-- =============================================================================
-- NOONA PLUS ERP | ترقية 16: سلسلة الإمداد والمخزون والمشتريات والموردين (أصناف بملفات: عام، قطع غيار، أدوية، خامات ومنتجات مصنعة)
--                  باركود متعدد، توافق المركبات، البدائل، الدفعات والصلاحية، قوائم المواد والإنتاج، ربط الحسابات ومراكز التكلفة
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_16_supply_chain.sql
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
PROMPT ========== الجداول والأعمدة الجديدة
@@upgrade_parts/16_supply_chain.sql
PROMPT ========== طرق السداد: إضافة البيع الآجل
DECLARE
  l NUMBER;
BEGIN
  SELECT COUNT(*) INTO l FROM user_constraints WHERE constraint_name = 'REF_PAYMENT_METHOD_METHOD_TYPE_CK'
     AND search_condition_vc LIKE '%''CREDIT''%';
  IF l = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE REF_PAYMENT_METHOD DROP CONSTRAINT REF_PAYMENT_METHOD_METHOD_TYPE_CK';
    EXECUTE IMMEDIATE 'ALTER TABLE REF_PAYMENT_METHOD ADD CONSTRAINT REF_PAYMENT_METHOD_METHOD_TYPE_CK CHECK (METHOD_TYPE IN '
      || '(''CASH'', ''BANK_TRANSFER'', ''CHEQUE'', ''CARD'', ''WALLET'', ''GATEWAY'', ''DIRECT_DEBIT'', ''OFFSET'', ''CREDIT''))';
  END IF;
END;
/
PROMPT ========== أنواع حركات المخزون والضريبة والأحداث المحاسبية
@@seed/06_supply_chain.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_CSH_PKG / NOONA_INV_PKG / NOONA_PUR_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/105_noona_pur_pkg.sql
GRANT EXECUTE ON NOONA_INV_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PUR_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 16 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
