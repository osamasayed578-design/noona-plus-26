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
-- تعديل الجداول ينتظر حتى دقيقتين إذا كان جدول مستخدماً في جلسة أخرى (بدلاً من الخطأ ORA-00054)
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;

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
@@plsql/86_noona_ui_pkg.sql
@@plsql/87_noona_apex_error.sql
@@plsql/88_noona_sec_admin_pkg.sql
@@plsql/89_noona_brand_pkg.sql
@@plsql/90_noona_refdata_pkg.sql
@@plsql/91_noona_platform_admin_pkg.sql
@@plsql/95_noona_dms_pkg.sql
@@plsql/96_noona_pty_pkg.sql
@@plsql/100_noona_gl_pkg.sql
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/105_noona_pur_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/107_noona_pos_pkg.sql
@@plsql/108_noona_mfg_pkg.sql
@@plsql/109_noona_cor_pkg.sql
@@plsql/110_noona_hr_pkg.sql
@@plsql/111_noona_pay_pkg.sql
@@plsql/112_noona_fa_pkg.sql
@@plsql/113_noona_re_pkg.sql
@@plsql/114_noona_hsp_pkg.sql
@@plsql/115_noona_mnt_pkg.sql
@@plsql/116_noona_rst_pkg.sql
@@plsql/117_noona_his_pkg.sql
@@plsql/118_noona_his_care_pkg.sql
@@plsql/119_noona_his_claim_pkg.sql
@@plsql/120_noona_his_link_pkg.sql
@@plsql/121_noona_his_clin_pkg.sql
@@plsql/122_noona_his_nurse_pkg.sql
@@plsql/123_noona_bi_pkg.sql
@@plsql/124_noona_prj_pkg.sql
@@plsql/125_noona_loc_pkg.sql
@@plsql/126_noona_einv_pkg.sql
@@plsql/127_noona_res_pkg.sql
@@plsql/128_noona_prp_pkg.sql
@@plsql/129_noona_api_pkg.sql
@@plsql/130_noona_conn_pkg.sql
@@plsql/131_noona_aut_pkg.sql
@@plsql/132_noona_dms_agent_pkg.sql
@@plsql/133_noona_prc_pkg.sql
@@plsql/134_noona_anl_pkg.sql
@@plsql/135_noona_trn_pkg.sql
@@plsql/136_noona_consol_pkg.sql
@@plsql/137_noona_prj_ctr_pkg.sql
@@plsql/138_noona_signup_pkg.sql
@@plsql/139_noona_mail_pkg.sql
@@plsql/140_noona_account_pkg.sql
@@plsql/141_noona_dst_pkg.sql
@@plsql/142_noona_eng_pkg.sql

PROMPT ========== 5/7 Seed: registry & reference data
@@seed/01_registry_seed.sql
@@seed/02_reference_data.sql
@@seed/03_banks.sql
@@seed/04_dms_types.sql
@@seed/05_journal_types.sql
@@seed/06_supply_chain.sql
@@seed/07_manufacturing.sql
@@seed/08_subscription_plans.sql
@@seed/09_correspondence.sql
@@seed/10_hr_payroll.sql
@@seed/11_fixed_assets.sql
@@seed/12_property_hospitality.sql
@@seed/13_healthcare.sql
@@seed/15_projects.sql
@@seed/16_country_packs.sql
@@seed/17_real_estate.sql
@@seed/18_api.sql
@@seed/19_cities.sql
@@seed/20_onboarding.sql
@@seed/21_signup.sql
@@seed/22_mail.sql
@@seed/14_reports_catalog.sql

PROMPT ========== 6/7 Row-Level Security (VPD)
@@security/20_noona_vpd_pkg.sql
@@security/30_vpd_policies.sql

PROMPT ========== 7/7 Grants to NOONA_APP
@@security/40_grants_noona_app.sql

PROMPT ========== Compile (cross-package dependencies)
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
@@upgrade_parts/28_his_alert_job.sql
@@upgrade_parts/52_account_job.sql
@@upgrade_parts/33_api_job.sql
@@upgrade_parts/57_trn_alerts.sql
PROMPT ========== Invalid objects (should be none)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';

PROMPT ========== NOONA PLUS database installed.
