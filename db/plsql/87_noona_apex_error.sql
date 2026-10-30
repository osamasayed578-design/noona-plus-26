-- =============================================================================
-- NOONA PLUS ERP | دالة معالجة أخطاء APEX (Error Handling Function) لكل تطبيقات NOONA
--   * أخطاء الأعمال (-20500) والأمن (-20100): تعرض رسالة NOONA النظيفة فقط بدون ORA-xxxxx
--     ورمز المتابعة cid ينقل إلى تفاصيل الخطأ للدعم الفني (لا يظهر للمستخدم)
--   * أخطاء غير متوقعة: رسالة عامة للمستخدم + رقم مرجعي؛ التفاصيل في سجل APEX
-- تحتاج APEX مثبتاً؛ تنشأ فقط إن وجد (التثبيت على قاعدة بدون APEX يتخطاها بأمان).
-- في التطبيق: Application Definition ← Error Handling Function = noona_owner.noona_apex_error
-- =============================================================================
SET DEFINE OFF
DECLARE
  l_has_apex NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_has_apex FROM all_objects
   WHERE object_name = 'APEX_ERROR' AND object_type = 'SYNONYM' AND owner = 'PUBLIC';
  IF l_has_apex = 0 THEN
    DBMS_OUTPUT.PUT_LINE('APEX not installed: NOONA_APEX_ERROR skipped');
    RETURN;
  END IF;
  EXECUTE IMMEDIATE q'~
CREATE OR REPLACE FUNCTION NOONA_APEX_ERROR(p_error IN apex_error.t_error)
  RETURN apex_error.t_error_result AUTHID DEFINER IS
  l_result apex_error.t_error_result;
  l_msg    VARCHAR2(32767);
  l_cid    VARCHAR2(100);
BEGIN
  l_result := apex_error.init_error_result(p_error => p_error);
  IF p_error.ora_sqlcode IN (-20500, -20100, -20001, -20002, -20200) THEN
    l_msg := apex_error.get_first_ora_error_text(p_error => p_error);
    l_cid := REGEXP_SUBSTR(l_msg, '\[cid=([^]]+)\]', 1, 1, NULL, 1);
    l_result.message := TRIM(REGEXP_REPLACE(l_msg, '\s*\[cid=[^]]+\]', ''));
    l_result.additional_info := CASE WHEN l_cid IS NOT NULL THEN 'cid=' || l_cid END;
    l_result.display_location := apex_error.c_inline_in_notification;
  ELSIF p_error.is_internal_error = FALSE AND p_error.ora_sqlcode IN (100, -1403, -1400, -1407, -1, -12899, -1722, -6502,
                                                                       -1830, -1840, -1841, -1843, -1847, -1858, -1861, -2292) THEN
    -- أخطاء الإدخال الشائعة: رسالة واضحة بدل «خطأ غير متوقع» (النص التقني يبقى في السجل)
    l_result.message := CASE
      WHEN p_error.ora_sqlcode IN (100, -1403) THEN 'لم يُختر السجل المطلوب أو لم يعد موجوداً؛ اختره من القائمة ثم أعد المحاولة'
      WHEN p_error.ora_sqlcode IN (-1400, -1407) THEN 'حقل إلزامي فارغ؛ أكمل البيانات المطلوبة ثم أعد المحاولة'
      WHEN p_error.ora_sqlcode = -1 THEN 'القيمة مسجلة مسبقاً (مكررة)؛ استخدم قيمة أخرى'
      WHEN p_error.ora_sqlcode = -12899 THEN 'إحدى القيم أطول من المسموح؛ اختصرها ثم أعد المحاولة'
      WHEN p_error.ora_sqlcode IN (-1722, -6502) THEN 'قيمة غير صحيحة في أحد الحقول (رقم أو طول غير مسموح)'
      WHEN p_error.ora_sqlcode = -2292 THEN 'لا يمكن الحذف لوجود سجلات مرتبطة به'
      ELSE 'تاريخ غير صحيح؛ استخدم الصيغة سنة-شهر-يوم' END;
    l_result.additional_info := p_error.ora_sqlerrm;
    l_result.display_location := apex_error.c_inline_in_notification;
  ELSIF p_error.is_internal_error = FALSE AND p_error.ora_sqlcode IS NOT NULL THEN
    l_result.message := 'حدث خطأ غير متوقع؛ أبلغ الدعم الفني بالرقم المرجعي / Unexpected error, reference: '
                        || NVL(SYS_CONTEXT('NOONA_CTX', 'CORRELATION_ID'), TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3'));
    l_result.additional_info := p_error.ora_sqlerrm;
  END IF;
  RETURN l_result;
END NOONA_APEX_ERROR;~';
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON NOONA_APEX_ERROR TO NOONA_APP';
END;
/
