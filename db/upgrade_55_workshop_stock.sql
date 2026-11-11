-- =============================================================================
-- NOONA PLUS ERP | ترقية 55: ورشة الصيانة الداخلية تصرف قطع الغيار والزيوت والإطارات من المخزون
--   * بند أمر الصيانة بصنف مخزني يصرف فوراً من مستودع الورشة بالمتوسط المرجح (حركة MAINT_ISSUE)
--     وقيد: مدين «صيانة تحت التنفيذ» 1116 / دائن المخزون؛ حذف البند أو إلغاء الأمر يعيد القطع (MAINT_RETURN)
--   * عند الإقفال تنقل المواد من 1116 إلى مصروف الصيانة أو إلى تكلفة أصل العربة (رأسمالية)، والجزء الخارجي من مصدر السداد
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_55_workshop_stock.sql
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
PROMPT ========== الأعمدة وأنواع الحركات وحساب الصيانة تحت التنفيذ
@@upgrade_parts/55_maint_stock.sql
@@upgrade_parts/55_maint_stock_seed.sql
PROMPT ========== الحزم
WHENEVER SQLERROR CONTINUE
@@plsql/100_noona_gl_pkg.sql
@@plsql/104_noona_inv_pkg.sql
@@plsql/112_noona_fa_pkg.sql
@@plsql/135_noona_trn_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 55 done. Now import app 147
EXIT
