-- =============================================================================
-- NOONA PLUS ERP | ترقية 00: كل الجداول والأعمدة المضافة في الترقيات (قبل أي حزمة أو بيانات أساس)
--   update_windows.bat يعيد تشغيل كل الترقيات بالترتيب بالكود الحالي للحزم والبيانات الأساسية؛ والكود الحالي يحتاج
--   أعمدة وجداول ترقيات لاحقة. هذه الخطوة تنشئها كلها أولاً (أجزاء آمنة لإعادة التشغيل: لا تغيير لما هو موجود).
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_00_schema.sql
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
@@upgrade_parts/13_dms_rule.sql
@@upgrade_parts/14_dms_required.sql
@@upgrade_parts/15_journal_types.sql
@@upgrade_parts/16_supply_chain.sql
@@upgrade_parts/17_manufacturing.sql
@@upgrade_parts/20_correspondence.sql
@@upgrade_parts/21_hr_payroll.sql
@@upgrade_parts/22_fixed_assets.sql
@@upgrade_parts/23_property_hospitality.sql
@@upgrade_parts/24_restaurant.sql
@@upgrade_parts/25_healthcare.sql
@@upgrade_parts/26_healthcare2.sql
@@upgrade_parts/27_healthcare3.sql
@@upgrade_parts/28_healthcare4.sql
@@upgrade_parts/29_reports_hub.sql
@@upgrade_parts/30_projects.sql
@@upgrade_parts/31_localization.sql
@@upgrade_parts/32_real_estate.sql
@@upgrade_parts/33_api.sql
@@upgrade_parts/34_cash_check.sql
@@upgrade_parts/35_auto_service.sql
@@upgrade_parts/37_dms_agent.sql
@@upgrade_parts/38_pay_allowances.sql
@@upgrade_parts/39_cor_delivery.sql
@@upgrade_parts/40_cor_hierarchy.sql
@@upgrade_parts/42_pricing.sql
PROMPT ========== Upgrade 00 done (schema)
EXIT
