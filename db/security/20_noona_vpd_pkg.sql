-- =============================================================================
-- NOONA PLUS ERP | Virtual Private Database - دوال سياسات العزل
-- Tenant Isolation by Design: كل استعلام من APEX أو ORDS أو الوظائف الخلفية أو AI
-- يرشح على TENANT_ID من NOONA_CTX. غياب السياق = لا صفوف (Default Deny).
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_VPD_PKG AUTHID DEFINER AS
  -- جداول مملوكة للمؤسسة/الشركة (النطاق T و C)
  FUNCTION tenant_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2;
  -- جداول مشتركة (النطاق TO): قراءة صفوف المنصة + المؤسسة
  FUNCTION shared_select_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2;
  -- جداول مشتركة: الكتابة على صفوف المؤسسة فقط (صفوف المنصة لمسؤول المنصة في وضع النظام)
  FUNCTION shared_dml_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE add_tenant_policy(p_table IN VARCHAR2);
  PROCEDURE add_shared_policy(p_table IN VARCHAR2);
  PROCEDURE drop_all_policies;
END NOONA_VPD_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_VPD_PKG AS
  c_ctx CONSTANT VARCHAR2(30) := 'NOONA_CTX';

  FUNCTION system_mode RETURN BOOLEAN IS
  BEGIN
    RETURN NVL(SYS_CONTEXT(c_ctx, 'SYSTEM_MODE'), 'N') = 'Y';
  END;

  FUNCTION tenant_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF system_mode THEN
      RETURN NULL;
    ELSIF SYS_CONTEXT(c_ctx, 'TENANT_ID') IS NULL THEN
      RETURN '1 = 0';
    END IF;
    RETURN 'TENANT_ID = TO_NUMBER(SYS_CONTEXT(''NOONA_CTX'', ''TENANT_ID''))';
  END tenant_predicate;

  FUNCTION shared_select_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF system_mode THEN
      RETURN NULL;
    ELSIF SYS_CONTEXT(c_ctx, 'TENANT_ID') IS NULL THEN
      RETURN 'TENANT_ID IS NULL';
    END IF;
    RETURN '(TENANT_ID IS NULL OR TENANT_ID = TO_NUMBER(SYS_CONTEXT(''NOONA_CTX'', ''TENANT_ID'')))';
  END shared_select_predicate;

  FUNCTION shared_dml_predicate(p_schema IN VARCHAR2, p_object IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF system_mode THEN
      RETURN NULL;
    ELSIF SYS_CONTEXT(c_ctx, 'TENANT_ID') IS NULL THEN
      -- مسؤول المنصة يدير صفوف المنصة الافتراضية فقط (TENANT_ID فارغ)
      RETURN CASE WHEN SYS_CONTEXT(c_ctx, 'PLATFORM_ADMIN') = 'Y' THEN 'TENANT_ID IS NULL' ELSE '1 = 0' END;
    END IF;
    RETURN 'TENANT_ID = TO_NUMBER(SYS_CONTEXT(''NOONA_CTX'', ''TENANT_ID''))';
  END shared_dml_predicate;

  PROCEDURE drop_if_exists(p_table VARCHAR2, p_policy VARCHAR2) IS
  BEGIN
    DBMS_RLS.DROP_POLICY(USER, p_table, p_policy);
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE <> -28102 THEN RAISE; END IF;   -- policy does not exist
  END;

  PROCEDURE add_tenant_policy(p_table IN VARCHAR2) IS
  BEGIN
    drop_if_exists(p_table, 'NP_TENANT_ISOLATION');
    DBMS_RLS.ADD_POLICY(
      object_schema   => USER,
      object_name     => p_table,
      policy_name     => 'NP_TENANT_ISOLATION',
      function_schema => USER,
      policy_function => 'NOONA_VPD_PKG.TENANT_PREDICATE',
      statement_types => 'SELECT, INSERT, UPDATE, DELETE, INDEX',
      update_check    => TRUE,
      policy_type     => DBMS_RLS.SHARED_CONTEXT_SENSITIVE);
  END add_tenant_policy;

  PROCEDURE add_shared_policy(p_table IN VARCHAR2) IS
  BEGIN
    drop_if_exists(p_table, 'NP_SHARED_SELECT');
    drop_if_exists(p_table, 'NP_SHARED_DML');
    DBMS_RLS.ADD_POLICY(
      object_schema   => USER,
      object_name     => p_table,
      policy_name     => 'NP_SHARED_SELECT',
      function_schema => USER,
      policy_function => 'NOONA_VPD_PKG.SHARED_SELECT_PREDICATE',
      statement_types => 'SELECT',
      policy_type     => DBMS_RLS.SHARED_CONTEXT_SENSITIVE);
    DBMS_RLS.ADD_POLICY(
      object_schema   => USER,
      object_name     => p_table,
      policy_name     => 'NP_SHARED_DML',
      function_schema => USER,
      policy_function => 'NOONA_VPD_PKG.SHARED_DML_PREDICATE',
      statement_types => 'INSERT, UPDATE, DELETE',
      update_check    => TRUE,
      policy_type     => DBMS_RLS.SHARED_CONTEXT_SENSITIVE);
  END add_shared_policy;

  PROCEDURE drop_all_policies IS
  BEGIN
    FOR r IN (SELECT object_name, policy_name FROM user_policies WHERE policy_name LIKE 'NP\_%' ESCAPE '\') LOOP
      DBMS_RLS.DROP_POLICY(USER, r.object_name, r.policy_name);
    END LOOP;
  END drop_all_policies;

END NOONA_VPD_PKG;
/
