-- =============================================================================
-- NOONA PLUS ERP | إعادة ترجمة حزم المستندات والمالية بالترتيب الصحيح
--   (NOONA_DMS_PKG, NOONA_PTY_PKG, NOONA_UI_PKG, NOONA_GL_PKG, NOONA_ACE_PKG, NOONA_CSH_PKG, NOONA_FIN_RPT_PKG)
--   sqlplus NOONA_OWNER@//host:1521/PDB @fix_packages.sql
-- قابل للتكرار: ينشئ الجداول الناقصة فقط ثم يترجم الحزم ويعرض أي أخطاء متبقية.
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
PROMPT ========== 1) جداول المستندات (قواعد الأرشفة، المستندات المطلوبة، مكان الحفظ)
@@upgrade_parts/13_dms_rule.sql
@@upgrade_parts/14_dms_required.sql
PROMPT ========== 2) أنواع المستندات وصلاحيات مسؤول المؤسسة
@@seed/04_dms_types.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== 3) NOONA_DMS_PKG / NOONA_PTY_PKG
@@plsql/95_noona_dms_pkg.sql
@@plsql/96_noona_pty_pkg.sql
PROMPT ========== 4) NOONA_UI_PKG / NOONA_GL_PKG / NOONA_ACE_PKG / NOONA_CSH_PKG / NOONA_FIN_RPT_PKG
@@plsql/86_noona_ui_pkg.sql
@@plsql/100_noona_gl_pkg.sql
@@plsql/101_noona_ace_pkg.sql
@@plsql/102_noona_csh_pkg.sql
@@plsql/103_noona_fin_rpt_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/105_noona_pur_pkg.sql
GRANT EXECUTE ON NOONA_DMS_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PTY_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_UI_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_GL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_CSH_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_FIN_RPT_PKG TO NOONA_APP;
PROMPT ========== 5) إعادة ترجمة المخطط
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
PROMPT ========== الكائنات غير الصالحة (يجب أن تكون القائمة فارغة)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
SELECT 'حالة الحزم: ' || LISTAGG(object_name || '=' || status, ', ') WITHIN GROUP (ORDER BY object_name) st
  FROM user_objects
 WHERE object_type = 'PACKAGE BODY'
   AND object_name IN ('NOONA_DMS_PKG', 'NOONA_PTY_PKG', 'NOONA_UI_PKG', 'NOONA_GL_PKG', 'NOONA_ACE_PKG', 'NOONA_CSH_PKG', 'NOONA_FIN_RPT_PKG');
PROMPT ========== Done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
