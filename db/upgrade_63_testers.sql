-- =============================================================================
-- NOONA PLUS ERP | ترقية 63: إصلاحات المراجعة النهائية لبيئة المختبرين
--   * رقم العميل فريد على مستوى المؤسسة مع ترقيم لكل شركة (المؤسسات متعددة الشركات)
--   * تقرير السلف والقروض: خطأ تحويل رقمي عند المبالغ بالآلاف
--   * سجل تدقيق المنصة: إعادة ختم السلسلة بعد الحذف الشامل (في وضع الحذف فقط)
--   * مساعدة الشاشة: فيديو النظام الخاص بمؤسسة المستخدم (الصفحة 0) ثم فيديو النظام العام
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
PROMPT ========== الحزم
@@plsql/05_noona_audit_pkg.sql
@@plsql/106_noona_sal_pkg.sql
@@plsql/111_noona_pay_pkg.sql
@@plsql/142_noona_eng_pkg.sql
GRANT EXECUTE ON NOONA_SAL_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_PAY_PKG TO NOONA_APP;
GRANT EXECUTE ON NOONA_ENG_PKG TO NOONA_APP;
PROMPT ========== اكتملت الترقية 63
EXIT
