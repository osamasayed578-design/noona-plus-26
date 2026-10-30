-- =============================================================================
-- NOONA PLUS ERP | اختبار استيراد شجرة الحسابات من ملف CSV بحساب NOONA_APP - يتراجع في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_coa_import.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT ========== Client character set check (NLS_LANG must end with .AL32UTF8)
BEGIN
  IF LENGTH('نونا') <> 4 THEN
    RAISE_APPLICATION_ERROR(-20000, 'NOONA-INS-001: Client character set is not UTF-8; Arabic text would be corrupted. '
      || 'Windows CMD: set NLS_LANG=AMERICAN_AMERICA.AL32UTF8  then run sqlplus again.');
  END IF;
END;
/

DECLARE
  g_pass PLS_INTEGER := 0;
  g_fail PLS_INTEGER := 0;
  l_sfx  VARCHAR2(4) := TO_CHAR(MOD(TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'SSFF3')), 9000) + 1000);
  l_job  NUMBER;
  l_ok   NUMBER;
  l_bad  NUMBER;
  l_e    CLOB;
  l_s    VARCHAR2(4000);
  l_csv  CLOB;
  l_root VARCHAR2(10);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  FUNCTION acc(p_code VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(a.name_ar || '|' || a.account_type || '|' || a.is_postable || '|' || p.account_code || '|' || a.account_level)
      INTO l FROM gl_account a LEFT JOIN gl_account p ON p.id = a.parent_account_id
     WHERE a.coa_id = NOONA_GL_PKG.primary_coa AND a.account_code = p_code;
    RETURN l;
  END acc;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  -- حساب رئيسي أعلى للأصول (تجميعي) من الدليل القائم
  SELECT MIN(account_code) INTO l_root FROM gl_account WHERE coa_id = NOONA_GL_PKG.primary_coa AND account_type = 'ASSET' AND is_postable = 'N' AND account_level = 1;
  ok('standard chart has an asset root', l_root IS NOT NULL);
  -- عناوين عربية، الفرع قبل أبيه في الملف، أخطاء صفوف
  l_csv := 'رمز الحساب,اسم الحساب,الحساب الأب,النوع,حساب حركة' || CHR(10)
        || '9' || l_sfx || '01,عهدة مدير المشتريات,9' || l_sfx || ',,نعم' || CHR(10)
        || '9' || l_sfx || ',العهد المؤقتة,' || l_root || ',,لا' || CHR(10)
        || '9' || l_sfx || '02,"عهدة أمين الصندوق، الفرع الرئيسي",9' || l_sfx || ',,نعم' || CHR(10)
        || '9' || l_sfx || '03,حساب بنوع خاطئ,9' || l_sfx || ',طائرات,نعم' || CHR(10)
        || '9' || l_sfx || '04,بلا أب,7777777,,نعم' || CHR(10)
        || '9' || l_sfx || '01,مكرر,9' || l_sfx || ',,نعم' || CHR(10)
        || '8' || l_sfx || ',مصروفات تجريبية رئيسية,,مصروفات,لا' || CHR(10);
  l_job := NOONA_CONN_PKG.import_csv('ACCOUNTS', 'coa.csv', l_csv);
  SELECT ok_rows, failed_rows, errors INTO l_ok, l_bad, l_e FROM api_import_job WHERE id = l_job;
  ok('4 accounts imported, 3 rejected', l_ok = 4 AND l_bad = 3, l_ok || '/' || l_bad || ' ' || DBMS_LOB.SUBSTR(l_e, 500, 1));
  l_s := acc('9' || l_sfx);
  ok('summary parent created under root, type inherited', l_s LIKE 'العهد المؤقتة|ASSET|N|' || l_root || '|2', l_s);
  ok('child listed before its parent is imported (first occurrence kept)', acc('9' || l_sfx || '01') LIKE 'عهدة مدير المشتريات|ASSET|Y|9' || l_sfx || '|3', acc('9' || l_sfx || '01'));
  ok('quoted name with comma', acc('9' || l_sfx || '02') LIKE 'عهدة أمين الصندوق، الفرع الرئيسي|%');
  ok('top-level account with type', acc('8' || l_sfx) LIKE 'مصروفات تجريبية رئيسية|EXPENSE|N||1', acc('8' || l_sfx));
  ok('unknown type reported', DBMS_LOB.INSTR(l_e, 'نوع غير معروف') > 0);
  ok('missing parent reported', DBMS_LOB.INSTR(l_e, 'الحساب الأب غير موجود: 7777777') > 0);
  ok('duplicate code in the file reported', DBMS_LOB.INSTR(l_e, 'مكرر في الملف') > 0);
  l_job := NOONA_CONN_PKG.import_csv('ACCOUNTS', 'again.csv', 'code,name,parent' || CHR(10) || '9' || l_sfx || ',مرة ثانية,' || l_root);
  SELECT errors INTO l_e FROM api_import_job WHERE id = l_job;
  ok('code existing in the chart reported', DBMS_LOB.INSTR(l_e, 'رمز الحساب مستخدم') > 0, DBMS_LOB.SUBSTR(l_e, 300, 1));
  -- عناوين إنجليزية
  l_job := NOONA_CONN_PKG.import_csv('ACCOUNTS', 'coa_en.csv', 'code,name,parent,postable' || CHR(10) || '9' || l_sfx || '05,Petty cash 2,9' || l_sfx || ',Y');
  SELECT ok_rows INTO l_ok FROM api_import_job WHERE id = l_job;
  ok('english headers accepted', l_ok = 1);
  BEGIN l_job := NOONA_CONN_PKG.import_csv('ACCOUNTS', 'x.csv', 'parent,type' || CHR(10) || '1,ASSET'); ok('code and name columns required', FALSE);
  EXCEPTION WHEN OTHERS THEN ok('code and name columns required', INSTR(SQLERRM, 'NOONA-CON-021') > 0, SQLERRM); END;
  ok('template available', NOONA_CONN_PKG.template_csv('ACCOUNTS') LIKE 'code,name,parent,type,postable%', SUBSTR(NOONA_CONN_PKG.template_csv('ACCOUNTS'), 1, 60));

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
