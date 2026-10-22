-- =============================================================================
-- NOONA PLUS ERP | ترقية 17: التصنيع - مراكز العمل، قوائم المواد ومسارات التصنيع بإصدارات، أوامر الإنتاج
--                  (صرف الخامات، تقارير العمليات، استلام الإنتاج، فحص الجودة، الإقفال وتسوية الانحرافات)،
--                  تخطيط احتياجات المواد MRP، أحمال مراكز العمل، ومحاسبة الإنتاج تحت التشغيل
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_17_manufacturing.sql
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
PROMPT ========== الأعمدة الجديدة لجداول التصنيع
@@upgrade_parts/17_manufacturing.sql
PROMPT ========== حركة إرجاع الخامات وأحداث التصنيع المحاسبية
@@seed/07_manufacturing.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_INV_PKG / NOONA_MFG_PKG / NOONA_FIN_RPT_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/108_noona_mfg_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
GRANT EXECUTE ON NOONA_MFG_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 17 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
