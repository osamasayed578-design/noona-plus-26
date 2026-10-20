-- =============================================================================
-- NOONA PLUS ERP | اختبار شعار المشترك (NOONA_BRAND_PKG) بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_brand.sql
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
  l_sess NUMBER := TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12));
  l_co   NUMBER;
  l_doc  NUMBER;
  l_blob BLOB;
  l_mime VARCHAR2(100);
  l_hash VARCHAR2(128);
  l_c    CLOB;
  l_s    VARCHAR2(4000);
  -- صورة PNG بحجم 1×1
  c_png  CONSTANT RAW(100) := HEXTORAW('89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C489'
                                    || '0000000D4944415478DA63F8CFC0F01F0005000201FFA2E8B10000000049454E44AE426082');

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', l_sess);
  l_co := TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  NOONA_BRAND_PKG.remove_company_logo(l_co);
  ok('no logo initially', NOONA_BRAND_PKG.has_logo(l_co) = 'N');
  l_s := NOONA_BRAND_PKG.header_badge(123, '1');
  ok('header badge without logo shows company icon', INSTR(l_s, 'nn-co-icon') > 0 AND INSTR(l_s, '<img') = 0, l_s);

  BEGIN l_doc := NOONA_BRAND_PKG.set_company_logo(l_co, 'x.svg', TO_BLOB(UTL_RAW.CAST_TO_RAW('<svg onload="alert(1)"/>')));
        ok('SVG / non-image rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('SVG / non-image rejected', 'NOONA-BRD-002', SQLERRM); END;
  DBMS_LOB.CREATETEMPORARY(l_blob, TRUE);
  DBMS_LOB.APPEND(l_blob, TO_BLOB(c_png));
  FOR i IN 1 .. 9000 LOOP DBMS_LOB.WRITEAPPEND(l_blob, 64, UTL_RAW.COPIES('00', 64)); END LOOP;
  BEGIN l_doc := NOONA_BRAND_PKG.set_company_logo(l_co, 'big.png', l_blob); ok('logo over 512KB rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('logo over 512KB rejected', 'NOONA-BRD-001', SQLERRM); END;

  l_doc := NOONA_BRAND_PKG.set_company_logo(l_co, 'logo.png', TO_BLOB(c_png));
  ok('logo stored as DMS document', l_doc IS NOT NULL AND NOONA_BRAND_PKG.has_logo(l_co) = 'Y');
  NOONA_BRAND_PKG.get_company_logo(NULL, l_blob, l_mime, l_hash);
  ok('current company logo served with detected type', l_mime = 'image/png' AND DBMS_LOB.GETLENGTH(l_blob) = 70, l_mime);
  l_c := NOONA_BRAND_PKG.logo_data_uri(l_co);
  ok('data URI for reports', l_c LIKE 'data:image/png;base64,iVBORw0KGgo%', SUBSTR(l_c, 1, 40));
  l_s := NOONA_BRAND_PKG.header_badge(123, '1');
  ok('header badge links to logo process', INSTR(l_s, 'APPLICATION_PROCESS=NOONA_COMPANY_LOGO') > 0, l_s);
  l_c := NOONA_BRAND_PKG.report_header('ميزان المراجعة', l_co);
  ok('report header has logo, title and system mark',
     INSTR(l_c, 'nn-rpt-logo') > 0 AND INSTR(l_c, 'ميزان المراجعة') > 0 AND INSTR(l_c, 'NOONA PLUS') > 0);
  NOONA_BRAND_PKG.remove_company_logo(l_co);
  ok('logo removed', NOONA_BRAND_PKG.has_logo(l_co) = 'N');
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
  IF g_fail > 0 THEN RAISE_APPLICATION_ERROR(-20999, g_fail || ' test(s) failed'); END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT: ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
