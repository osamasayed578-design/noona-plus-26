-- =============================================================================
-- NOONA PLUS ERP | بيانات مشتركة لكل شركة تجريبية (تشغل آخر بيانات الشركة)
--   الأرشيف: وثائق الشركة النظامية بصلاحياتها (منها قريب الانتهاء)
--   العاملون الميدانيون: ربط السائقين والفنيين بموظفي الموارد البشرية ومكافآتهم، وجمع مستحقات الشهر
--   مركز الإدارة: القوالب وقواعد التنبيه، روابط بوابة العملاء، رسائل واتساب (فواتير وكشوف وتذكيرات)، وتشغيل التنبيهات
--   كل قسم مستقل: إن تعذر قسم يطبع تنبيهاً ويكمل البقية
--   sqlplus NOONA_APP@... @demo/demo_common.sql <مسؤول المؤسسة>
-- =============================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
COLUMN 1 NEW_VALUE 1 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
DEFINE ADMIN_USER = '&1'
DECLARE
  c_admin CONSTANT VARCHAR2(100) := NVL(UPPER(TRIM('&ADMIN_USER')), 'ADMIN');
  l_co NUMBER; l_n NUMBER; l_x NUMBER; l_k PLS_INTEGER;
  TYPE t_num IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  l_emp t_num;
  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
BEGIN
  login(c_admin);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));

  -- ================================================= الأرشيف
  BEGIN
    SELECT COUNT(*) INTO l_n FROM dms_document WHERE company_id = l_co AND external_ref LIKE 'DEMO-DOC-%';
    IF l_n = 0 THEN
      l_n := NOONA_DMS_PKG.quick_setup;
      l_x := NOONA_DMS_PKG.archive_document(NULL, NULL, 'COMMERCIAL_REGISTER', 'السجل التجاري للشركة', 'DEMO-DOC-CR', 'خزنة الإدارة - ملف 1',
               ADD_MONTHS(TRUNC(SYSDATE), -20), 'الأصل الورقي للسجل التجاري', p_valid_from => ADD_MONTHS(TRUNC(SYSDATE), -20),
               p_valid_to => ADD_MONTHS(TRUNC(SYSDATE), 16));
      l_x := NOONA_DMS_PKG.archive_document(NULL, NULL, 'VAT_CERTIFICATE', 'شهادة التسجيل في ضريبة القيمة المضافة', 'DEMO-DOC-VAT',
               'خزنة الإدارة - ملف 1', ADD_MONTHS(TRUNC(SYSDATE), -18), 'شهادة هيئة الزكاة والضريبة والجمارك');
      l_x := NOONA_DMS_PKG.archive_document(NULL, NULL, 'MUNICIPAL_LICENSE', 'رخصة البلدية للمقر الرئيسي', 'DEMO-DOC-MUN', 'خزنة الإدارة - ملف 2',
               ADD_MONTHS(TRUNC(SYSDATE), -11), 'تجدد سنوياً', p_valid_from => ADD_MONTHS(TRUNC(SYSDATE), -11),
               p_valid_to => TRUNC(SYSDATE) + 25);
      l_x := NOONA_DMS_PKG.archive_document(NULL, NULL, 'GOSI_CERTIFICATE', 'شهادة التأمينات الاجتماعية', 'DEMO-DOC-GOSI', 'الموارد البشرية - ملف 4',
               ADD_MONTHS(TRUNC(SYSDATE), -2), 'شهادة سارية', p_valid_from => ADD_MONTHS(TRUNC(SYSDATE), -2),
               p_valid_to => ADD_MONTHS(TRUNC(SYSDATE), 1));
      l_x := NOONA_DMS_PKG.archive_document(NULL, NULL, 'NATIONAL_ADDRESS', 'إثبات العنوان الوطني', 'DEMO-DOC-ADDR', 'خزنة الإدارة - ملف 1',
               ADD_MONTHS(TRUNC(SYSDATE), -6));
      COMMIT;
      say('الأرشيف: 5 وثائق نظامية (رخصة البلدية تنتهي خلال 25 يوماً)');
    END IF;
  EXCEPTION WHEN OTHERS THEN ROLLBACK; say('تنبيه الأرشيف: ' || SQLERRM);
  END;

  -- ================================================= السائقون والفنيون من الموارد البشرية
  BEGIN
    l_k := 0;
    FOR r IN (SELECT e.id FROM hr_employee e
               WHERE e.status_code = 'ACTIVE' AND NOONA_WRK_PKG.employment_of(e.id) IS NOT NULL
                 AND NOT EXISTS (SELECT 1 FROM dst_rep d WHERE d.employee_id = e.id)
               ORDER BY e.id) LOOP
      l_k := l_k + 1; l_emp(l_k) := r.id;
    END LOOP;
    l_n := 0;
    FOR d IN (SELECT id, ROWNUM rn FROM (SELECT id FROM trn_driver WHERE company_id = l_co AND employee_id IS NULL ORDER BY id)) LOOP
      EXIT WHEN d.rn > l_k;
      NOONA_WRK_PKG.set_worker('DRIVER', d.id, l_emp(d.rn), CASE MOD(d.rn, 3) WHEN 0 THEN 'CASH' ELSE 'PAYROLL' END);
      NOONA_WRK_PKG.set_bonus('DRIVER', d.id, CASE MOD(d.rn, 3) WHEN 1 THEN 'PER_TRIP' WHEN 2 THEN 'PER_KM' ELSE 'PCT_FREIGHT' END,
                              CASE MOD(d.rn, 3) WHEN 1 THEN 75 WHEN 2 THEN 0.12 ELSE 3 END);
      l_n := l_n + 1;
    END LOOP;
    FOR t IN (SELECT id, ROWNUM rn FROM (SELECT id FROM aut_technician WHERE company_id = l_co AND employee_id IS NULL ORDER BY id)) LOOP
      EXIT WHEN l_n + t.rn > l_k;
      NOONA_WRK_PKG.set_worker('TECH', t.id, l_emp(l_n + t.rn), 'PAYROLL');
      NOONA_WRK_PKG.set_bonus('TECH', t.id, 'JOB', 15);
    END LOOP;
    -- شاشات الجوال («رحلاتي» للسائق و«مهامي» للفني) تعرض بيانات لمسؤول المؤسسة: يربط بأول سائق وأول فني (يغير من شاشة السائق/الفني)
    UPDATE trn_driver SET user_name = c_admin
     WHERE id = (SELECT MIN(id) FROM trn_driver WHERE company_id = l_co)
       AND NOT EXISTS (SELECT 1 FROM trn_driver WHERE company_id = l_co AND user_name IS NOT NULL);
    UPDATE aut_technician SET user_name = c_admin
     WHERE id = (SELECT MIN(id) FROM aut_technician WHERE company_id = l_co)
       AND NOT EXISTS (SELECT 1 FROM aut_technician WHERE company_id = l_co AND user_name IS NOT NULL);
    SELECT COUNT(*) INTO l_n FROM pay_field_earning WHERE company_id = l_co;
    IF l_n = 0 THEN
      l_n := NOONA_WRK_PKG.collect(TRUNC(SYSDATE, 'MM'));
      -- مكافآت يدوية للسائقين (الرحلات التي صرف لها بدل في مصروفاتها لا يتكرر لها بونص)
      FOR d IN (SELECT employee_id, ROWNUM rn FROM trn_driver WHERE company_id = l_co AND employee_id IS NOT NULL) LOOP
        l_x := NOONA_WRK_PKG.add_manual('{"employee":' || d.employee_id || ',"type":"' || CASE MOD(d.rn, 2) WHEN 1 THEN 'BONUS' ELSE 'OTHER' END
             || '","amount":' || (150 * d.rn) || ',"month":"' || TO_CHAR(SYSDATE, 'YYYY-MM') || '-01","method":"'
             || CASE MOD(d.rn, 2) WHEN 1 THEN 'PAYROLL' ELSE 'CASH' END || '","notes":"مكافأة التزام بمواعيد التسليم"}');
        l_n := l_n + 1;
      END LOOP;
      IF l_n > 0 THEN say('مستحقات العاملين الميدانيين للشهر: ' || l_n); END IF;
    END IF;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN ROLLBACK; say('تنبيه العاملين الميدانيين: ' || SQLERRM);
  END;

  -- ================================================= تجهيز المبيعات (الترقيم والعميل النقدي) إن لم تجهز
  BEGIN
    IF NOONA_SAL_PKG.is_ready = 'N' THEN l_n := NOONA_SAL_PKG.quick_setup; COMMIT; say('تجهيز المبيعات والترقيم'); END IF;
  EXCEPTION WHEN OTHERS THEN ROLLBACK; say('تنبيه تجهيز المبيعات: ' || SQLERRM);
  END;

  -- ================================================= مركز الإدارة: التنبيهات والبوابة وواتساب
  BEGIN
    IF NOONA_ENG_PKG.is_ready = 'N' THEN l_n := NOONA_ENG_PKG.quick_setup; END IF;
    SELECT COUNT(*) INTO l_n FROM eng_portal_link WHERE company_id = l_co;
    IF l_n = 0 THEN
      l_k := 0;
      FOR a IN (SELECT a.id FROM ar_customer_account a WHERE a.company_id = l_co AND a.status_code = 'ACTIVE' ORDER BY a.id) LOOP
        l_k := l_k + 1; EXIT WHEN l_k > 4;
        l_x := NOONA_ENG_PKG.create_link(a.id, 365);
        BEGIN
          l_x := NOONA_ENG_PKG.send_event(CASE MOD(l_k, 2) WHEN 1 THEN 'STATEMENT' ELSE 'PORTAL' END, a.id, NULL, NULL,
                                          NVL(NOONA_ENG_PKG.customer_phone(a.id), '05000000' || (10 + l_k)));
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END LOOP;
      FOR i IN (SELECT id, customer_account_id FROM (SELECT id, customer_account_id FROM sal_invoice
                  WHERE company_id = l_co AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID') ORDER BY id DESC) WHERE ROWNUM <= 2) LOOP
        BEGIN
          l_x := NOONA_ENG_PKG.send_event('INVOICE', i.customer_account_id, 'SAL_INVOICE', i.id,
                                          NVL(NOONA_ENG_PKG.customer_phone(i.customer_account_id), '0500000099'));
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END LOOP;
      BEGIN l_x := NOONA_ENG_PKG.send_reminders(1); EXCEPTION WHEN OTHERS THEN NULL; END;
      say('مركز الإدارة: روابط بوابة العملاء ورسائل واتساب');
    END IF;
    COMMIT;
    l_n := NOONA_ENG_PKG.run_alerts(l_co);
    COMMIT;
    say('تنبيهات الإدارة الحالية: ' || l_n);
  EXCEPTION WHEN OTHERS THEN ROLLBACK; say('تنبيه مركز الإدارة: ' || SQLERRM);
  END;
  NOONA_APEX_PKG.cleanup_request;
END;
/
EXIT
