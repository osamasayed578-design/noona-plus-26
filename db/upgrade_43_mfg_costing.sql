-- =============================================================================
-- NOONA PLUS ERP | ترقية 43: إعدادات تكلفة التصنيع
--   * معالجة انحراف التكلفة عند إقفال أمر الإنتاج إعداد لكل شركة (التصنيع ← الهندسة والإعداد ← إعدادات التكلفة):
--     مصروف على انحرافات الإنتاج 5105 (الافتراضي)، أو على المخزون (التكلفة الفعلية): يحمل على قيمة الكمية الموجودة في المخزون
--     فيتعدل متوسط تكلفتها، والباقي (المباع) على تكلفة المبيعات
--   * التكلفة المعيارية في بطاقة الصنف تتحدث من التصنيع عند إطلاق كل أمر (يقرؤها محرك التسعير)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_43_mfg_costing.sql
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
PROMPT ========== جدول إعدادات التصنيع والصلاحيات
@@upgrade_parts/43_mfg_costing.sql
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزمة
@@plsql/108_noona_mfg_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 43 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP and import apex/NOONA_MFG/f135
EXIT
