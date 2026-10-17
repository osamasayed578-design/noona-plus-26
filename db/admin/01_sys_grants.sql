-- =============================================================================
-- NOONA PLUS ERP | منح حزم SYS - يشغل بحساب SYS AS SYSDBA داخل الـPDB
--   sqlplus sys@//host:1521/XEPDB1 as sysdba @db/admin/01_sys_grants.sql
-- =============================================================================
GRANT EXECUTE ON SYS.DBMS_RLS     TO NOONA_OWNER;
GRANT EXECUTE ON SYS.DBMS_CRYPTO  TO NOONA_OWNER;
GRANT EXECUTE ON SYS.DBMS_SESSION TO NOONA_OWNER;
GRANT SELECT  ON SYS.V_$SESSION   TO NOONA_OWNER;
