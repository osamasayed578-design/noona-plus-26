-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للمراسلات (بعد التحديث 20) - تشغل بحساب NOONA_APP ولا تكرر
-- (تكتشف الخطاب الوارد ذا الرقم الخارجي DEMO/1447/001):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_correspondence.sql ADMIN
-- ينشئ مستخدمين تجريبيين بلا كلمات مرور (الاتصالات الإدارية، الموارد البشرية، المبيعات) ويستخدم DEMO_APPROVER إن وجد.
-- المحتوى في صندوق مسؤول المؤسسة:
--   * خطاب وارد من هيئة الزكاة والضريبة والجمارك بمرفق PDF، أحالته الاتصالات الإدارية للدراسة، فأحاله المسؤول
--     للمعتمد المالي لإبداء الرأي، فرد عليه، ثم صدر خطاب الرد للهيئة برقم صادر
--   * تعميم الموارد البشرية بمواعيد الدوام (للعلم) لكل الفريق
--   * مذكرة عاجلة من المبيعات تطلب اعتماد خصم استثنائي (مطلوب منك، غير مقروءة، بنجمة)
--   * مذكرة من المسؤول للمبيعات بطلب خطة الربع القادم (للإفادة) ونسخة للمعتمد المالي، اطلع عليها المستلم
--   * خطاب وارد ثانٍ من بنك (للعلم) وخطاب صادر لمورد، ومسودة غير مرسلة
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  c_admin CONSTANT VARCHAR2(128) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co    NUMBER;
  l_n     NUMBER;
  l_adm   NUMBER;
  l_sec   NUMBER;
  l_hr    NUMBER;
  l_sal   NUMBER;
  l_fin   NUMBER;
  l_role  NUMBER;
  l_in1   NUMBER;
  l_rep   NUMBER;
  l_out1  NUMBER;
  l_circ  NUMBER;
  l_disc  NUMBER;
  l_plan  NUMBER;
  l_in2   NUMBER;
  l_doc   NUMBER;
  l_pdf   BLOB;

  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
  FUNCTION member(p_user VARCHAR2, p_name VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(m.id) INTO l FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE u.username = p_user;
    IF l IS NULL THEN
      l := NOONA_SEC_ADMIN_PKG.create_user(p_user, p_name, LOWER(REPLACE(p_user, '_', '.')) || '@noona.local', l_co);
    END IF;
    RETURN l;
  END member;
  FUNCTION u(p_member NUMBER) RETURN VARCHAR2 IS BEGIN RETURN '{"k":"U","id":' || p_member || '}'; END;
  FUNCTION d(p_days NUMBER) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(TRUNC(SYSDATE) + p_days, 'YYYY-MM-DD'); END;
  -- تقديم وقت الإرسال ليبدو الصندوق واقعياً (بالساعات)
  PROCEDURE ago(p_id NUMBER, p_hours NUMBER) IS
    l_ts TIMESTAMP WITH LOCAL TIME ZONE := SYSTIMESTAMP - NUMTODSINTERVAL(p_hours, 'HOUR');
  BEGIN
    UPDATE cor_correspondence SET sent_at = CASE WHEN sent_at IS NOT NULL THEN l_ts END,
                                  received_at = CASE WHEN received_at IS NOT NULL THEN l_ts END
     WHERE id = p_id;
    UPDATE cor_recipient SET delivered_at = l_ts WHERE correspondence_id = p_id;
  END ago;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  l_adm := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  SELECT COUNT(*) INTO l_n FROM cor_correspondence WHERE company_id = l_co AND external_no = 'DEMO/1447/001';
  IF l_n > 0 THEN
    say('بيانات المراسلات التجريبية محملة سابقاً - لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;

  -- ====================================================== المستخدمون
  l_sec := member('DEMO_SECRETARY', 'نورة - الاتصالات الإدارية (تجريبي)');
  l_hr  := member('DEMO_HR', 'فهد - الموارد البشرية (تجريبي)');
  l_sal := member('DEMO_SALES', 'ريم - مديرة المبيعات (تجريبي)');
  l_fin := member('DEMO_APPROVER', 'المعتمد المالي (تجريبي)');
  -- الاتصالات الإدارية تسجل الوارد والصادر وتطلع على سجلهما
  SELECT MIN(id) INTO l_role FROM sec_role WHERE code = 'DEMO_CORRESPONDENCE';
  IF l_role IS NULL THEN
    l_role := NOONA_SEC_ADMIN_PKG.create_role('DEMO_CORRESPONDENCE', 'الاتصالات الإدارية (تجريبي)');
    l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'COR', 'VIEW,CREATE');
  END IF;
  SELECT COUNT(*) INTO l_n FROM sec_role_grant WHERE membership_id = l_sec AND role_id = l_role AND status_code = 'ACTIVE';
  IF l_n = 0 THEN
    l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_sec, l_role, NULL, 'بيانات تجريبية');
  END IF;
  say('المستخدمون: الاتصالات الإدارية، الموارد البشرية، المبيعات، المعتمد المالي');

  -- PDF صغير يمثل صورة الخطاب الوارد
  l_pdf := UTL_RAW.CAST_TO_RAW('%PDF-1.4' || CHR(10)
    || '1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj 2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj' || CHR(10)
    || '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 595 842]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj' || CHR(10)
    || '4 0 obj<</Length 120>>stream' || CHR(10)
    || 'BT /F1 18 Tf 72 760 Td (ZATCA - Request to update tax return data) Tj 0 -30 Td (Ref: DEMO/1447/001) Tj ET' || CHR(10)
    || 'endstream endobj 5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj' || CHR(10)
    || 'trailer<</Root 1 0 R>>' || CHR(10) || '%%EOF');

  -- ====================================================== 1) خطاب وارد بمرفق، إحالة، رأي، ورد صادر
  login('DEMO_SECRETARY');
  l_in1 := NOONA_COR_PKG.save_draft('{"kind":"INCOMING","to":[' || u(l_adm) || '],"subject":"طلب تحديث بيانات الإقرار الضريبي للربع الثالث",'
        || '"party":"هيئة الزكاة والضريبة والجمارك","ext_no":"DEMO/1447/001","letter_date":"' || d(-6) || '",'
        || '"priority":"HIGH","instr":"STUDY","due":"' || d(4) || '",'
        || '"body":"السادة / الشركة المحترمين\nالسلام عليكم ورحمة الله وبركاته،\n\nنفيدكم بضرورة تحديث بيانات الإقرار الضريبي للربع الثالث '
        || 'وتزويدنا بكشف المشتريات الخاضعة للضريبة خلال خمسة عشر يوماً من تاريخه.\n\nوتقبلوا تحياتنا."}');
  l_doc := NOONA_COR_PKG.attach(l_in1, 'خطاب الهيئة DEMO-1447-001.pdf', 'application/pdf', l_pdf);
  l_n := NOONA_COR_PKG.send('{"id":' || l_in1 || ',"kind":"INCOMING","to":[' || u(l_adm) || '],"subject":"طلب تحديث بيانات الإقرار الضريبي للربع الثالث",'
        || '"party":"هيئة الزكاة والضريبة والجمارك","ext_no":"DEMO/1447/001","letter_date":"' || d(-6) || '",'
        || '"priority":"HIGH","instr":"STUDY","due":"' || d(4) || '",'
        || '"body":"السادة / الشركة المحترمين\nالسلام عليكم ورحمة الله وبركاته،\n\nنفيدكم بضرورة تحديث بيانات الإقرار الضريبي للربع الثالث '
        || 'وتزويدنا بكشف المشتريات الخاضعة للضريبة خلال خمسة عشر يوماً من تاريخه.\n\nوتقبلوا تحياتنا."}');
  ago(l_in1, 70);
  login(c_admin);
  l_n := DBMS_LOB.GETLENGTH(NOONA_COR_PKG.thread_json(l_in1));
  NOONA_COR_PKG.refer(l_in1, l_fin, 'OPINION', TRUNC(SYSDATE) + 2, 'أرجو مراجعة كشف المشتريات وإبداء الرأي قبل الرد على الهيئة.');
  login('DEMO_APPROVER');
  l_rep := NOONA_COR_PKG.send('{"kind":"INTERNAL","parent":' || l_in1 || ',"rel":"REPLY","to":[' || u(l_adm) || '],'
        || '"subject":"رد: طلب تحديث بيانات الإقرار الضريبي للربع الثالث",'
        || '"body":"تمت مراجعة كشف المشتريات للربع الثالث ومطابقته مع دفتر الأستاذ؛ الفروقات محصورة في فاتورتين '
        || 'سُجلتا بعد إقفال الفترة وتمت تسويتهما.\nلا مانع من الرد على الهيئة وإرفاق الكشف المحدث."}');
  ago(l_rep, 30);
  login(c_admin);
  l_out1 := NOONA_COR_PKG.send('{"kind":"OUTGOING","parent":' || l_in1 || ',"rel":"REPLY","subject":"الرد على خطابكم رقم DEMO/1447/001",'
        || '"party":"هيئة الزكاة والضريبة والجمارك","cc":[' || u(l_fin) || '],'
        || '"body":"السادة / هيئة الزكاة والضريبة والجمارك المحترمين\nالسلام عليكم ورحمة الله وبركاته،\n\nإشارة إلى خطابكم رقم DEMO/1447/001، '
        || 'نفيدكم بأنه تم تحديث بيانات الإقرار الضريبي للربع الثالث، ومرفق لكم كشف المشتريات الخاضعة للضريبة.\n\nوتقبلوا خالص التحية."}');
  ago(l_out1, 26);
  say('خطاب وارد من الهيئة بمرفق، أحيل للدراسة ثم لإبداء الرأي، والرد الصادر');

  -- ====================================================== 2) تعميم الموارد البشرية (للعلم)
  login('DEMO_HR');
  l_circ := NOONA_COR_PKG.send('{"kind":"INTERNAL","type":"CIRCULAR","to":[' || u(l_adm) || ',' || u(l_sal) || ',' || u(l_fin) || ','
        || u(l_sec) || '],"instr":"FYI","subject":"تعميم: مواعيد الدوام الرسمي الجديدة",'
        || '"body":"الزملاء الكرام،\n\nنحيطكم علماً بأن مواعيد الدوام الرسمي اعتباراً من بداية الشهر القادم ستكون '
        || 'من الساعة 8:00 صباحاً حتى 4:00 عصراً، من الأحد إلى الخميس.\n\nمع التحية،\nإدارة الموارد البشرية"}');
  ago(l_circ, 50);

  -- ====================================================== 3) مذكرة عاجلة من المبيعات (مطلوب منك، غير مقروءة)
  login('DEMO_SALES');
  l_disc := NOONA_COR_PKG.send('{"kind":"INTERNAL","to":[' || u(l_adm) || '],"cc":[' || u(l_fin) || '],"priority":"URGENT","instr":"ACTION",'
        || '"due":"' || d(1) || '","subject":"طلب اعتماد خصم استثنائي 12% لعميل مؤسسة الأفق",'
        || '"body":"سعادة المدير العام،\n\nتقدمت مؤسسة الأفق التجارية بطلب شراء كمية كبيرة بقيمة 185,000 ريال مقابل خصم 12%، '
        || 'بينما صلاحيتي حتى 7%.\nنرجو التكرم بالاعتماد قبل نهاية الغد حتى لا تذهب الصفقة لمنافس.\n\nريم - المبيعات"}');
  ago(l_disc, 3);

  -- ====================================================== 4) مذكرة من المسؤول للمبيعات (للإفادة) اطلع عليها المستلم
  login(c_admin);
  NOONA_COR_PKG.set_star(l_disc, 'Y');
  l_plan := NOONA_COR_PKG.send('{"kind":"INTERNAL","to":[' || u(l_sal) || '],"cc":[' || u(l_fin) || '],"instr":"REPORT","due":"' || d(7) || '",'
        || '"subject":"خطة مبيعات الربع القادم","body":"الأستاذة ريم،\n\nنرجو إعداد خطة مبيعات الربع القادم متضمنة المستهدف لكل فرع '
        || 'والحملات الترويجية المقترحة، وإفادتنا بها قبل اجتماع الإدارة.\n\nمع الشكر"}');
  ago(l_plan, 20);
  login('DEMO_SALES');
  NOONA_COR_PKG.acknowledge(l_plan);
  l_n := DBMS_LOB.GETLENGTH(NOONA_COR_PKG.thread_json(l_plan));

  -- ====================================================== 5) خطاب وارد من البنك (للعلم) وصادر لمورد ومسودة
  login('DEMO_SECRETARY');
  l_in2 := NOONA_COR_PKG.send('{"kind":"INCOMING","to":[' || u(l_adm) || ',' || u(l_fin) || '],"instr":"FYI",'
        || '"subject":"إشعار بتجديد التسهيلات الائتمانية","party":"البنك الأهلي السعودي","ext_no":"DEMO/BNK/2290","letter_date":"' || d(-2) || '",'
        || '"body":"نفيدكم بتجديد التسهيلات الائتمانية لشركتكم لمدة عام بالشروط السابقة نفسها."}');
  ago(l_in2, 8);
  login(c_admin);
  l_n := NOONA_COR_PKG.send('{"kind":"OUTGOING","subject":"طلب عرض سعر لتوريد عبوات بلاستيكية","party":"مصنع الخليج للبلاستيك",'
        || '"to":[' || u(l_sal) || '],"body":"السادة / مصنع الخليج للبلاستيك المحترمين\n\nنرجو تزويدنا بعرض سعر لتوريد 50,000 عبوة سعة 1 لتر '
        || 'شاملاً مدة التوريد وشروط الدفع.\n\nوتقبلوا تحياتنا."}');
  ago(l_n, 5);
  l_n := NOONA_COR_PKG.save_draft('{"kind":"INTERNAL","to":[' || u(l_hr) || '],"subject":"ترتيبات الاجتماع السنوي للموظفين",'
        || '"body":"نقترح عقد الاجتماع السنوي في قاعة الفرع الرئيسي..."}');

  COMMIT;
  say('');
  say('تم تحميل بيانات المراسلات التجريبية. افتح «المستندات والمراسلات» ← المراسلات.');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
