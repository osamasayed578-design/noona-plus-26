-- =============================================================================
-- NOONA PLUS ERP | Oracle Database 21c | إنشاء المخططات (يشغل بحساب DBA داخل PDB)
--
--   NOONA_OWNER : مالك الجداول والحزم (لا يستخدمه APEX ولا ORDS مباشرة)
--   NOONA_APP   : مخطط التحليل Parsing Schema لتطبيقات APEX وخدمات ORDS
--
-- الاستخدام:
--   sqlplus system@//host:1521/XEPDB1 @db/admin/00_create_schemas.sql
-- غيّر كلمات المرور قبل التشغيل في أي بيئة غير تطويرية.
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
DEFINE owner_pwd = 'NoonaOwner#2026'
DEFINE app_pwd   = 'NoonaApp#2026'
DEFINE data_ts   = 'USERS'

DECLARE
  PROCEDURE create_user(p_user VARCHAR2, p_pwd VARCHAR2) IS
    l_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_cnt FROM dba_users WHERE username = p_user;
    IF l_cnt = 0 THEN
      EXECUTE IMMEDIATE 'CREATE USER ' || p_user || ' IDENTIFIED BY "' || p_pwd ||
                        '" DEFAULT TABLESPACE &data_ts QUOTA UNLIMITED ON &data_ts';
    END IF;
  END;
BEGIN
  create_user('NOONA_OWNER', '&owner_pwd');
  create_user('NOONA_APP',   '&app_pwd');
END;
/

-- مالك البيانات
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE,
      CREATE TRIGGER, CREATE TYPE, CREATE SYNONYM, CREATE MATERIALIZED VIEW,
      CREATE JOB TO NOONA_OWNER;
GRANT CREATE ANY CONTEXT, DROP ANY CONTEXT TO NOONA_OWNER;
-- منح حزم SYS (DBMS_RLS / DBMS_CRYPTO) في الملف 01_sys_grants.sql ويشغل بحساب SYS

-- مخطط التطبيق: لا يملك جداول، يصل عبر GRANTs ومرادفات وحزم المالك
GRANT CREATE SESSION, CREATE SYNONYM, CREATE VIEW, CREATE PROCEDURE TO NOONA_APP;
