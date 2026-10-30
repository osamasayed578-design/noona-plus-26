-- =============================================================================
-- NOONA PLUS ERP | ترقية 39: إيصال المراسلات الخارجية (بريد إلكتروني / طباعة وتسليم / الاثنان)
--   * لكل خطاب صادر طريقة إيصال يختارها المرسل: طباعة وتسليم يدوي، أو بريد إلكتروني من بريد الشركة، أو الاثنان
--   * البريد يرسل عبر APEX_MAIL (خادم البريد المعرف في إدارة APEX) مع نسخة الخطاب الرسمية والمرفقات
--   * سجل لكل محاولة: في طابور البريد / أرسل / فشل (مع السبب وإعادة الإرسال)، والتسليم الورقي باسم المستلم
--   * بريد الشركة للمراسلات: المرسل وعنوان الرد ونسخة الأرشيف والتذييل
--   * الوارد يسجل بقناة وروده (يدوي، بريد إلكتروني، بوابة، مسح ضوئي)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_39_cor_delivery.sql
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
PROMPT ========== بريد الشركة وطريقة الإيصال وسجل التسليم
@@upgrade_parts/39_cor_delivery.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/95_noona_dms_pkg.sql
@@plsql/109_noona_cor_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 39 done
EXIT
