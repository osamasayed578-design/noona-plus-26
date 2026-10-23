-- =============================================================================
-- NOONA PLUS ERP | ترقية 23: العقارات والضيافة والصيانة (التطبيق 139)
--   * السجل العقاري: العقار والمباني والطوابق والوحدات بمعالج سريع وتوليد آلي للوحدات ومخطط الوحدات
--   * الضيافة: أنواع الغرف والغرف وخطط الأسعار، الحجز والدخول السريع والتمديد ونقل الغرفة والمغادرة،
--     حساب النزيل وقيوده، التدبير الفندقي، الإيقاف للصيانة، التدقيق الليلي، لوحة الاستقبال ومخطط الحجوزات
--   * الصيانة: فئات الخدمة وزمن الإنجاز، الفرق والفنيون، البلاغات بقنواتها وأوامر العمل والإشعارات
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_23_property_hospitality.sql
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
PROMPT ========== أعمدة العقارات والضيافة والصيانة الجديدة
@@upgrade_parts/23_property_hospitality.sql
PROMPT ========== أحداث وأنواع قيود الضيافة وإشعار الصيانة
@@seed/12_property_hospitality.sql
PROMPT ========== صلاحيات مسؤول المؤسسة
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== NOONA_ACE_PKG / NOONA_RE_PKG / NOONA_HSP_PKG / NOONA_MNT_PKG / NOONA_PORTAL_PKG
@@plsql/101_noona_ace_pkg.sql
@@plsql/113_noona_re_pkg.sql
@@plsql/114_noona_hsp_pkg.sql
@@plsql/115_noona_mnt_pkg.sql
@@plsql/85_noona_portal.sql
GRANT EXECUTE ON NOONA_RE_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_HSP_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_MNT_PKG TO NOONA_APP;
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 23 done. Now run security/41_synonyms_noona_app.sql as NOONA_APP
EXIT
