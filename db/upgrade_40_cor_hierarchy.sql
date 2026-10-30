-- =============================================================================
-- NOONA PLUS ERP | ترقية 40: المراسلات الداخلية حسب الهيكل التنظيمي
--   * عند تفعيل سياسة الشركة يراسل الموظف: رئيسه المباشر ووحدته (الأعلى)، ومرؤوسيه (الأدنى)، وزملاءه تحت نفس الرئيس (الأفقي)؛
--     رئيس الوحدة يراسل الوحدة الأعلى والوحدات التابعة والنظيرة. لا تجاوز للمستويات.
--   * صلاحيات: COR_CONTACT.UP / DOWN / PEER، و COR_CONTACT.ANY لمراسلة أي جهة (مسجل المراسلات، الإدارة العليا)
--   * الرد على من راسلك مسموح دائماً (يمكن إيقافه)، والإحالة تتبع نفس القواعد
--   * دليل المستلمين في نافذة الإنشاء يعرض المسموح فقط مع صفة الجهة (رئيسك المباشر، مرؤوس، زميل)
--   * السياسة غير مفعلة افتراضياً: تفعل لكل شركة من «الإعدادات ← سياسة المراسلات الداخلية» بعد إدخال المناصب
--   sqlplus NOONA_OWNER@//host:1521/PDB @upgrade_40_cor_hierarchy.sql
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
PROMPT ========== جدول سياسة المراسلات
@@upgrade_parts/40_cor_hierarchy.sql
PROMPT ========== صلاحيات اتجاهات الاتصال
DECLARE
  PROCEDURE perm(p_act VARCHAR2, p_ar VARCHAR2, p_risk VARCHAR2) IS
  BEGIN
    INSERT INTO sec_permission (permission_code, module_code, resource_code, action_code, risk_level, requires_mfa, name_ar, name_en)
    SELECT 'COR_CONTACT.' || p_act, 'COR', 'COR_CONTACT', p_act, p_risk, 'N', 'الاتصال: ' || p_ar || ' - ' || p_act, 'COR_CONTACT ' || p_act
      FROM dual WHERE NOT EXISTS (SELECT 1 FROM sec_permission WHERE permission_code = 'COR_CONTACT.' || p_act);
  END;
BEGIN
  NOONA_CORE_PKG.begin_system;
  perm('UP', 'مراسلة الرئيس المباشر والوحدة الأعلى', 'NORMAL');
  perm('DOWN', 'مراسلة المرؤوسين والوحدات التابعة', 'NORMAL');
  perm('PEER', 'مراسلة الزملاء والوحدات النظيرة', 'NORMAL');
  perm('ANY', 'مراسلة أي جهة دون قيد الهيكل', 'HIGH');
  -- الأدوار القائمة تراسل اليوم أي أحد: تمنح الاتجاهات الثلاثة (ANY لمسؤول المؤسسة فقط عبر المزامنة)
  INSERT INTO sec_role_permission (tenant_id, role_id, permission_id, effect)
  SELECT r.tenant_id, r.id, p.id, 'ALLOW'
    FROM sec_role r JOIN sec_permission p ON p.permission_code IN ('COR_CONTACT.UP', 'COR_CONTACT.DOWN', 'COR_CONTACT.PEER')
   WHERE r.tenant_id IS NOT NULL AND r.status_code = 'ACTIVE' AND r.code <> 'TENANT_ADMIN'
     AND NOT EXISTS (SELECT 1 FROM sec_role_permission x WHERE x.role_id = r.id AND x.permission_id = p.id);
  DBMS_OUTPUT.PUT_LINE('Roles granted contact directions: ' || SQL%ROWCOUNT);
  NOONA_CORE_PKG.end_system;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  NOONA_CORE_PKG.end_system;
  RAISE;
END;
/
@@upgrade_parts/sync_admin_roles.sql
PROMPT ========== الحزم
@@plsql/109_noona_cor_pkg.sql

PROMPT ========== التحقق
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)
SELECT object_type, object_name FROM user_objects WHERE status <> 'VALID';
SELECT name||' '||line||':'||position||' '||substr(text,1,140) err FROM user_errors ORDER BY name, type, sequence;
PROMPT ========== Upgrade 40 done
EXIT
