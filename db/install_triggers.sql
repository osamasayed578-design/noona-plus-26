-- =============================================================================
-- NOONA PLUS ERP  |  Oracle Database 21c  |  Oracle APEX 24.2
-- Audit / tenant triggers install order
-- ملف مولد آلياً من tools/model - لا تعدله يدوياً. شغل: python3 tools/generate.py
-- =============================================================================

SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

@@triggers/p06_ref_trg.sql
@@triggers/p01_plt_trg.sql
@@triggers/p02_sec_trg.sql
@@triggers/p03_wf_trg.sql
@@triggers/p04_dms_trg.sql
@@triggers/p05_cor_trg.sql
@@triggers/p25_loc_trg.sql
@@triggers/p07_gl_trg.sql
@@triggers/p08_ar_trg.sql
@@triggers/p09_ap_trg.sql
@@triggers/p10_csh_trg.sql
@@triggers/p11_inv_trg.sql
@@triggers/p12_pur_trg.sql
@@triggers/p13_sal_trg.sql
@@triggers/p14_fa_trg.sql
@@triggers/p15_prj_trg.sql
@@triggers/p16_re_trg.sql
@@triggers/p17_prp_trg.sql
@@triggers/p18_mnt_trg.sql
@@triggers/p19_hr_trg.sql
@@triggers/p20_pay_trg.sql
@@triggers/p21_mfg_trg.sql
@@triggers/p31_his_trg.sql
@@triggers/p32_aut_trg.sql
@@triggers/p33_trn_trg.sql
@@triggers/p36_dst_trg.sql
@@triggers/p37_eng_trg.sql
@@triggers/p22_bi_trg.sql
@@triggers/p23_api_trg.sql
@@triggers/p24_ai_trg.sql
@@triggers/p26_qa_trg.sql
@@triggers/p27_mig_trg.sql
@@triggers/p28_pil_trg.sql
@@triggers/p29_dep_trg.sql
@@triggers/p30_ops_trg.sql
