-- =============================================================================
-- NOONA PLUS ERP | السماح لقاعدة البيانات بالاتصال بخدمة ربط خارجية (بوابة التأمين أو منصة الوصفات) - يشغله SYS
--   sqlplus sys@//host:1521/PDB as sysdba @admin/03_his_network_acl.sql
-- يمنح صلاحية الاتصال (ACL) لمخطط APEX (الذي ينفذ طلبات REST) ولـ NOONA_OWNER على المضيف والمنفذ المحددين.
-- لعناوين HTTPS: أضف شهادات الجهة إلى محفظة Oracle واضبط مسارها في «إعدادات APEX > Instance > Wallet» أو في حقل
-- «مسار المحفظة» في قناة الربط. قابل للتكرار.
-- =============================================================================
SET VERIFY OFF
SET SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT host = اسم المضيف فقط دون http (مثل api.payer.com أو 10.0.0.5) | port = المنفذ (443 لـ HTTPS، 80 لـ HTTP)
ACCEPT p_host CHAR   PROMPT 'host: '
ACCEPT p_port NUMBER PROMPT 'port [443]: ' DEFAULT 443

DECLARE
  l_apex VARCHAR2(128);
  PROCEDURE grant_to(p_user VARCHAR2) IS
  BEGIN
    -- الاتصال على المنفذ المحدد، وتحليل الاسم (resolve) لا يقبل نطاق منافذ
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host       => TRIM('&p_host'),
      lower_port => &p_port,
      upper_port => &p_port,
      ace        => XS$ACE_TYPE(privilege_list => XS$NAME_LIST('connect'), principal_name => p_user, principal_type => XS_ACL.PTYPE_DB));
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host       => TRIM('&p_host'),
      ace        => XS$ACE_TYPE(privilege_list => XS$NAME_LIST('resolve'), principal_name => p_user, principal_type => XS_ACL.PTYPE_DB));
    DBMS_OUTPUT.PUT_LINE('Granted connect/resolve on ' || TRIM('&p_host') || ':' || &p_port || ' to ' || p_user);
  END grant_to;
BEGIN
  SELECT MAX(username) INTO l_apex FROM dba_users WHERE REGEXP_LIKE(username, '^APEX_[0-9]{6}$');
  IF l_apex IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'APEX schema not found');
  END IF;
  grant_to(l_apex);
  grant_to('NOONA_OWNER');
END;
/
EXIT
