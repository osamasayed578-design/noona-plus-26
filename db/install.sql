-- =============================================================================
-- NOONA PLUS ERP | Oracle Database 21c | Oracle APEX 24.2
-- سكربت التثبيت الرئيسي - يشغل بحساب NOONA_OWNER من داخل مجلد db
--
--   cd db
--   sqlplus system@//host:1521/PDB  @admin/00_create_schemas.sql     -- مرة واحدة كـ DBA
--   sqlplus sys@//host:1521/PDB as sysdba @admin/01_sys_grants.sql
--   sqlplus NOONA_OWNER@//host:1521/PDB @install.sql
--   sqlplus NOONA_APP@//host:1521/PDB   @security/41_synonyms_noona_app.sql
--   (اختياري للتطوير) sqlplus NOONA_OWNER@... @seed/90_demo_tenant_DEV_ONLY.sql
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

PROMPT ========== 1/7 Application context (NOONA_CTX)
@@security/10_noona_ctx_pkg.sql

PROMPT ========== 2/7 Tables, constraints, indexes, comments (30 packages)
@@install_ddl.sql

PROMPT ========== 3/7 Audit columns & tenant triggers
@@install_triggers.sql

PROMPT ========== 4/7 Core PL/SQL services
@@plsql/03_noona_core_pkg.sql
@@plsql/05_noona_audit_pkg.sql
@@plsql/10_noona_security_pkg.sql
@@plsql/20_noona_reference_pkg.sql
@@plsql/40_noona_platform_pkg.sql
@@plsql/50_noona_org_pkg.sql
@@plsql/60_noona_delegation_pkg.sql
@@plsql/70_noona_workflow_pkg.sql
@@plsql/80_noona_apex_pkg.sql
@@plsql/85_noona_portal.sql

PROMPT ========== 5/7 Seed: registry & reference data
@@seed/01_registry_seed.sql
@@seed/02_reference_data.sql

PROMPT ========== 6/7 Row-Level Security (VPD)
@@security/20_noona_vpd_pkg.sql
@@security/30_vpd_policies.sql

PROMPT ========== 7/7 Grants to NOONA_APP
@@security/40_grants_noona_app.sql

PROMPT ========== Invalid objects (should be none)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';

PROMPT ========== NOONA PLUS database installed.
