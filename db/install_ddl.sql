-- =============================================================================
-- NOONA PLUS ERP  |  Oracle Database 21c  |  Oracle APEX 24.2
-- DDL install order (tables, constraints, indexes, comments)
-- ملف مولد آلياً من tools/model - لا تعدله يدوياً. شغل: python3 tools/generate.py
-- =============================================================================

SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT == p06_ref: Shared Reference Data & Global Party Model
@@ddl/p06_ref.sql
PROMPT == p01_plt: Platform Core, Tenancy, Licensing & Companies
@@ddl/p01_plt.sql
PROMPT == p02_sec: Organization Structure, Identity & Security
@@ddl/p02_sec.sql
PROMPT == p03_wf: Workflow, Requests, Approvals & Delegation
@@ddl/p03_wf.sql
PROMPT == p04_dms: Document Management & Archive
@@ddl/p04_dms.sql
PROMPT == p05_cor: Correspondence, Notifications & Audit
@@ddl/p05_cor.sql
PROMPT == p25_loc: Country Packs, Localization & Tax Engine
@@ddl/p25_loc.sql
PROMPT == p07_gl: General Ledger & Accounting Engine
@@ddl/p07_gl.sql
PROMPT == p08_ar: Customers & Accounts Receivable
@@ddl/p08_ar.sql
PROMPT == p09_ap: Suppliers & Accounts Payable
@@ddl/p09_ap.sql
PROMPT == p10_csh: Cash & Banks
@@ddl/p10_csh.sql
PROMPT == p11_inv: Inventory & Item Master
@@ddl/p11_inv.sql
PROMPT == p12_pur: Procurement
@@ddl/p12_pur.sql
PROMPT == p13_sal: Sales & Point of Sale
@@ddl/p13_sal.sql
PROMPT == p14_fa: Fixed Assets
@@ddl/p14_fa.sql
PROMPT == p15_prj: Projects, Contracting & Construction
@@ddl/p15_prj.sql
PROMPT == p16_re: Real Estate Development & Unit Sales
@@ddl/p16_re.sql
PROMPT == p17_prp: Property Management, Leasing & Hospitality
@@ddl/p17_prp.sql
PROMPT == p18_mnt: Maintenance & Facility Management
@@ddl/p18_mnt.sql
PROMPT == p19_hr: Human Resources
@@ddl/p19_hr.sql
PROMPT == p20_pay: Payroll
@@ddl/p20_pay.sql
PROMPT == p21_mfg: Manufacturing
@@ddl/p21_mfg.sql
PROMPT == p31_his: Hospital & Clinics
@@ddl/p31_his.sql
PROMPT == p32_aut: Auto Service Centers
@@ddl/p32_aut.sql
PROMPT == p33_trn: Transport & Logistics
@@ddl/p33_trn.sql
PROMPT == p36_dst: Distribution & Field Sales
@@ddl/p36_dst.sql
PROMPT == p37_eng: Management & Engagement Hub
@@ddl/p37_eng.sql
PROMPT == p22_bi: Reporting & Business Intelligence
@@ddl/p22_bi.sql
PROMPT == p23_api: ORDS, APIs & Integrations
@@ddl/p23_api.sql
PROMPT == p24_ai: AI, RAG & Agents
@@ddl/p24_ai.sql
PROMPT == p26_qa: Quality Assurance & Traceability
@@ddl/p26_qa.sql
PROMPT == p27_mig: Data Migration
@@ddl/p27_mig.sql
PROMPT == p28_pil: Pilot Launch
@@ddl/p28_pil.sql
PROMPT == p29_dep: Deployment & Release Management
@@ddl/p29_dep.sql
PROMPT == p30_ops: Operations, Support & Continuous Improvement
@@ddl/p30_ops.sql
