-- NOONA PLUS | استيراد تطبيق APEX من مجلد التصدير (يشغل من داخل مجلد fNNN)
--   sqlplus NOONA_APP@//host:port/PDB @..\..\import_app.sql <WORKSPACE> <APP_ID>
SET DEFINE ON
SET VERIFY OFF
WHENEVER SQLERROR EXIT 1
BEGIN
  apex_application_install.set_workspace('&1');
  apex_application_install.set_application_id(&2);
  apex_application_install.generate_offset;
  apex_application_install.set_schema('NOONA_APP');
END;
/
SET DEFINE OFF
@install.sql
EXIT
