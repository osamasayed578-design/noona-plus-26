-- =============================================================================
-- NOONA PLUS ERP | ترقية 03: دالة معالجة أخطاء APEX (رسائل نظيفة بدون ORA-xxxxx)
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_03_apex_error.sql
-- ثم أعد استيراد التطبيقين 115 و 119 (يشيران إلى noona_owner.noona_apex_error)
-- =============================================================================
SET DEFINE OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
-- تعديل الجداول ينتظر حتى دقيقتين إذا كان جدول مستخدماً في جلسة أخرى (بدلاً من الخطأ ORA-00054)
ALTER SESSION SET DDL_LOCK_TIMEOUT = 120;
@@plsql/87_noona_apex_error.sql
SELECT object_name, status FROM user_objects WHERE object_name = 'NOONA_APEX_ERROR';
PROMPT ========== Upgrade 03 done.
EXIT
