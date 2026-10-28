-- =============================================================================
-- NOONA PLUS ERP | بيانات تجريبية للضرائب والتوطين (بعد التحديث 31) - بحساب NOONA_APP، ولا تكرر (تكتشف المورد التجريبي):
--   sqlplus NOONA_APP@//host:1521/PDB @demo/demo_localization.sql ADMIN
-- المحتوى: تطبيق حزمة الدولة وحسابات الضرائب، الرقم الضريبي والسجل التجاري للشركة (إن لم يسجلا)، الفوترة الإلكترونية بالمحاكي
--          وإرسال فواتير الشهر المرحلة، مورد غير مقيم بفاتورة خدمات وشهادة استقطاع، ومسودة إقرار ضريبة القيمة المضافة للشهر السابق
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
  c_sup   CONSTANT VARCHAR2(200) := 'شركة الحلول البرمجية الخليجية (دبي)';
  l_n     NUMBER;
  l_x     NUMBER;
  l_cc    VARCHAR2(2);
  l_type  NUMBER;
  l_sup   NUMBER;
  l_item  NUMBER;
  l_msg   VARCHAR2(400);
  l_from  DATE := ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1);
  l_to    DATE := TRUNC(SYSDATE, 'MM') - 1;
  PROCEDURE say(p VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(p); END;
BEGIN
  NOONA_APEX_PKG.post_auth(c_admin, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  SELECT COUNT(*) INTO l_n FROM pty_party p JOIN ap_supplier s ON s.party_id = p.id
    JOIN ap_supplier_account a ON a.supplier_id = s.id AND a.company_id = NOONA_LOC_PKG.company WHERE p.display_name_ar = c_sup;
  IF l_n > 0 THEN
    say('بيانات الضرائب محملة سابقاً لهذه الشركة؛ لم يضف شيء.');
    NOONA_APEX_PKG.cleanup_request;
    RETURN;
  END IF;
  l_cc := NOONA_LOC_PKG.company_country;

  -- حزمة الدولة وحسابات الضرائب
  l_n := NOONA_LOC_PKG.setup_company;
  say('حزمة الدولة ' || l_cc || ': ربط ' || l_n || ' كود ضريبة بحساباته');

  -- التسجيلات (سعودية): الرقم الضريبي والسجل التجاري إن لم يسجلا
  IF l_cc = 'SA' THEN
    IF NOONA_LOC_PKG.company_tax_number IS NULL THEN
      SELECT MIN(t.id) INTO l_type FROM loc_registration_type t WHERE t.country_pack_id = NOONA_LOC_PKG.company_pack AND t.code = 'SA_VAT';
      l_x := NOONA_LOC_PKG.save_registration('{"type":' || l_type || ',"number":"399999999900003","authority":"هيئة الزكاة والضريبة والجمارك","issue":"'
                                             || TO_CHAR(ADD_MONTHS(SYSDATE, -36), 'YYYY-MM-DD') || '"}');
      say('الرقم الضريبي التجريبي 399999999900003');
    END IF;
    SELECT COUNT(*) INTO l_n FROM org_legal_registration g JOIN loc_registration_type t ON t.id = g.reg_type_id
     WHERE g.company_id = NOONA_LOC_PKG.company AND t.code = 'SA_CR' AND g.status_code <> 'CANCELLED';
    IF l_n = 0 THEN
      SELECT MIN(t.id) INTO l_type FROM loc_registration_type t WHERE t.country_pack_id = NOONA_LOC_PKG.company_pack AND t.code = 'SA_CR';
      l_x := NOONA_LOC_PKG.save_registration('{"type":' || l_type || ',"number":"1010123456","authority":"وزارة التجارة","issue":"'
                                             || TO_CHAR(ADD_MONTHS(SYSDATE, -36), 'YYYY-MM-DD') || '","expiry":"' || TO_CHAR(ADD_MONTHS(SYSDATE, 1), 'YYYY-MM-DD') || '"}');
      say('السجل التجاري 1010123456 (ينتهي خلال شهر: يظهر تنبيه قرب الانتهاء)');
    END IF;

    -- الفوترة الإلكترونية بالمحاكي، وإرسال فواتير الشهر المرحلة
    IF NOONA_EINV_PKG.active_profile IS NULL THEN
      l_x := NOONA_EINV_PKG.save_profile('{"adapter":"SIMULATOR","mode":"CLEARANCE","device":"EGS-DEMO-1","sandbox":"Y","status":"ACTIVE"}');
      l_n := 0;
      FOR i IN (SELECT id FROM sal_invoice WHERE company_id = NOONA_LOC_PKG.company AND status_code IN ('POSTED', 'PARTIALLY_PAID', 'PAID', 'CREDITED')
                   AND einvoice_submission_id IS NULL AND doc_date >= TRUNC(SYSDATE, 'MM') ORDER BY posted_at, id FETCH FIRST 15 ROWS ONLY) LOOP
        l_x := NOONA_EINV_PKG.queue_invoice(i.id);
        l_n := l_n + 1;
      END LOOP;
      l_x := NOONA_EINV_PKG.process_queue;
      say('الفوترة الإلكترونية (المحاكي): ' || l_n || ' فاتورة في السلسلة، أرسل ' || l_x);
    END IF;
  END IF;

  -- مورد غير مقيم: فاتورة خدمات واستقطاع
  l_sup := NOONA_PUR_PKG.save_supplier('{"name":"' || c_sup || '","nameEn":"Gulf Software Solutions (Dubai)","person":"N","type":"SERVICES","term":"NET30"}');
  UPDATE pty_party SET country_code = 'AE'
   WHERE id = (SELECT s.party_id FROM ap_supplier_account a JOIN ap_supplier s ON s.id = a.supplier_id WHERE a.id = l_sup);
  SELECT MIN(id) INTO l_item FROM inv_item WHERE name_ar = 'خدمات استشارية تقنية';
  IF l_item IS NULL THEN
    l_item := NOONA_INV_PKG.save_item('{"name":"خدمات استشارية تقنية","type":"SERVICE","price":0,"incl":"N"}');
  END IF;
  l_x := NOONA_PUR_PKG.save_invoice('{"sup":' || l_sup || ',"date":"' || TO_CHAR(TRUNC(SYSDATE) - 5, 'YYYY-MM-DD') || '","supInv":"GSS-2026-118",'
         || '"action":"POST","lines":[{"i":' || l_item || ',"q":1,"p":40000}]}');
  FOR w IN (SELECT c.code FROM loc_tax_code c JOIN loc_tax_type t ON t.id = c.tax_type_id
             WHERE t.country_pack_id = NOONA_LOC_PKG.company_pack AND t.tax_category = 'WITHHOLDING' AND c.status_code = 'ACTIVE'
             ORDER BY c.code DESC FETCH FIRST 1 ROWS ONLY) LOOP
    l_x := NOONA_LOC_PKG.withhold('{"supplier":' || l_sup || ',"code":"' || w.code || '","base":40000,"date":"' || TO_CHAR(TRUNC(SYSDATE) - 5, 'YYYY-MM-DD')
                                  || '","service":"خدمات فنية واستشارية (تطوير نظام)"}');
    SELECT certificate_no || ' (' || w.code || ') بمبلغ ' || withheld_amount INTO l_msg FROM loc_withholding_cert WHERE id = l_x;
    say('شهادة استقطاع ' || l_msg);
  END LOOP;

  -- مسودة إقرار ضريبة القيمة المضافة للشهر السابق
  SELECT COUNT(*) INTO l_n FROM loc_tax_return WHERE company_id = NOONA_LOC_PKG.company AND period_start <= l_to AND period_end >= l_from;
  IF l_n = 0 AND NOONA_LOC_PKG.company_pack IS NOT NULL THEN
    BEGIN
      l_x := NOONA_LOC_PKG.new_return('VAT', l_from, l_to);
      SELECT net_payable INTO l_n FROM loc_tax_return WHERE id = l_x;
      say('مسودة إقرار ضريبة القيمة المضافة ' || TO_CHAR(l_from, 'YYYY-MM') || ': الصافي ' || l_n);
    EXCEPTION WHEN OTHERS THEN
      say('لم ينشأ الإقرار: ' || SQLERRM);
    END;
  END IF;

  COMMIT;
  say('');
  say('تم تحميل بيانات الضرائب. افتح «المالية > الضرائب».');
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('FAILED: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  RAISE;
END;
/
EXIT
