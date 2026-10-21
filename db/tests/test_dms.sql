-- =============================================================================
-- NOONA PLUS ERP | اختبار محرك المستندات والأرشفة (NOONA_DMS_PKG) والمرجع الورقي قبل الاعتماد بحساب NOONA_APP
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_dms.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'HH24MISSFF3');
  l_box  NUMBER;
  l_v    NUMBER;
  l_v2   NUMBER;
  l_j    NUMBER;
  l_doc  NUMBER;
  l_doc2 NUMBER;
  l_mem  NUMBER;
  l_role NUMBER;
  l_n    NUMBER;
  l_n2   NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_pdf  BLOB;
  l_exe  BLOB;
  l_big  BLOB;
  l_user VARCHAR2(100);
  l_pty  NUMBER;
  l_blob BLOB;
  l_cid  NUMBER;
  l_date DATE := TRUNC(SYSDATE);

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  PROCEDURE login(p_user VARCHAR2) IS
  BEGIN
    NOONA_APEX_PKG.cleanup_request;
    NOONA_APEX_PKG.post_auth(p_user, TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  END login;
BEGIN
  login('ADMIN');
  l_n := NOONA_GL_PKG.quick_setup;
  l_box := NOONA_CSH_PKG.quick_setup;
  DELETE FROM dms_archive_rule;                                   -- حالة نظيفة داخل المعاملة
  DELETE FROM dms_storage_profile;                                -- الحفظ داخل قاعدة البيانات في بداية الاختبار
  l_user := 'DMA' || l_sfx;
  l_mem := NOONA_SEC_ADMIN_PKG.create_user(l_user, 'معتمد مالي', LOWER(l_user) || '@x.local', TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')));
  l_role := NOONA_SEC_ADMIN_PKG.create_role('DMR' || l_sfx, 'معتمد');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'CSH', 'VIEW,APPROVE,POST');
  l_n := NOONA_SEC_ADMIN_PKG.add_module_permissions(l_role, 'GL', 'VIEW,APPROVE,POST');
  l_n := NOONA_SEC_ADMIN_PKG.grant_role(l_mem, l_role, NULL, 'اختبار');
  -- تمويل الصندوق قبل اختبارات الصرف (قاعدة بيانات جديدة رصيد صندوقها صفر)
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'RECEIPT', l_date, l_box, NULL, NULL, 'الشريك', 'تمويل الصندوق', NULL, '[{"a":"3101","m":1000}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_v);
  login('ADMIN');
  l_n := NOONA_DMS_PKG.quick_setup;
  ok('archive setup adds default rules', l_n >= 2, l_n);
  ok('archive setup idempotent', NOONA_DMS_PKG.quick_setup = 0 AND NOONA_DMS_PKG.is_ready = 'Y');
  SELECT COUNT(*) INTO l_n FROM dms_document_type WHERE tenant_id IS NULL AND code IN ('RECEIPT_VOUCHER', 'PAYMENT_VOUCHER', 'JOURNAL_SUPPORT', 'GENERAL');
  ok('platform document types seeded', l_n = 4, l_n);


  -- سند بلا مرجع ورقي لا يعتمد
  l_v := NOONA_CSH_PKG.save_voucher(NULL, 'PAYMENT', l_date, l_box, NULL, NULL, 'مؤسسة الصيانة', 'صيانة المكيفات', 'INV-55',
                                    '[{"a":"5205","m":10}]');
  NOONA_CSH_PKG.submit_voucher(l_v);
  ok('voucher without reference flagged', NOONA_DMS_PKG.has_reference('CSH_TRANSACTION', l_v) = 'N');
  login(l_user);
  BEGIN NOONA_CSH_PKG.approve_voucher(l_v); ok('approval needs paper reference', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('approval needs paper reference', 'NOONA-DMS-200', SQLERRM); END;
  login('ADMIN');
  BEGIN l_doc := NOONA_DMS_PKG.archive_document('CSH_TRANSACTION', l_v, NULL, NULL); ok('reference or file required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reference or file required', 'NOONA-DMS-114', SQLERRM); END;
  l_doc := NOONA_DMS_PKG.archive_document('CSH_TRANSACTION', l_v, NULL, NULL, 'INV-55', 'ملف الصيانة 2026 - رف 3');
  SELECT d.reference_no || '|' || t.code || '|' || d.external_ref INTO l_s
    FROM dms_document d JOIN dms_document_type t ON t.id = d.document_type_id WHERE d.id = l_doc;
  ok('paper reference archived with archive number and auto type', l_s LIKE 'ARC-%|PAYMENT_VOUCHER|INV-55', l_s);
  ok('voucher reference satisfied', NOONA_DMS_PKG.has_reference('CSH_TRANSACTION', l_v) = 'Y');
  login(l_user);
  NOONA_CSH_PKG.approve_voucher(l_v);
  SELECT status_code INTO l_s FROM csh_transaction WHERE id = l_v;
  ok('voucher approved after archiving', l_s = 'SETTLED', l_s);
  login('ADMIN');
  l_c := NOONA_CSH_PKG.voucher_print(l_v);
  ok('voucher print shows archive reference', INSTR(l_c, 'ARC-') > 0 AND INSTR(l_c, 'INV-55') > 0);
  BEGIN NOONA_DMS_PKG.detach(l_doc, 'CSH_TRANSACTION', l_v, 'خطأ'); ok('no detach from posted document', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no detach from posted document', 'NOONA-DMS-131', SQLERRM); END;
  l_c := NOONA_DMS_PKG.attachments_html('CSH_TRANSACTION', l_v, 'f?p=128:49:1::NO::P49_DOC:#ID#');
  ok('attachments panel', INSTR(l_c, 'INV-55') > 0 AND INSTR(l_c, 'أصل ورقي فقط') > 0 AND INSTR(l_c, 'المرجع الورقي مسجل') > 0);

  -- قاعدة تتطلب صورة الأصل
  NOONA_DMS_PKG.set_rule('CSH_TRANSACTION', 'PAYMENT_VOUCHER', 'Y', 'Y');
  l_v2 := NOONA_CSH_PKG.save_voucher(NULL, 'EXPENSE', l_date, l_box, NULL, NULL, 'مكتبة', 'أحبار', NULL, '[{"a":"5207","m":5}]');
  NOONA_CSH_PKG.submit_voucher(l_v2);
  l_doc2 := NOONA_DMS_PKG.archive_document('CSH_TRANSACTION', l_v2, NULL, 'إيصال المكتبة', 'R-9001', 'درج المصروفات');
  ok('paper-only not enough when file required', NOONA_DMS_PKG.has_reference('CSH_TRANSACTION', l_v2) = 'N');
  l_exe := UTL_RAW.CAST_TO_RAW('MZ' || RPAD('x', 100, 'x'));
  BEGIN l_n := NOONA_DMS_PKG.add_version(l_doc2, 'invoice.pdf', 'application/pdf', l_exe, 'صورة'); ok('disguised executable rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('disguised executable rejected', 'NOONA-DMS-112', SQLERRM); END;
  l_pdf := UTL_RAW.CAST_TO_RAW('%PDF-1.4' || CHR(10) || '% NOONA test document' || CHR(10) || '%%EOF');
  l_n := NOONA_DMS_PKG.add_version(l_doc2, 'receipt.pdf', 'application/pdf', l_pdf, 'صورة الإيصال');
  ok('scan added as version', NOONA_DMS_PKG.has_reference('CSH_TRANSACTION', l_v2) = 'Y');
  SELECT COUNT(*) INTO l_n FROM dms_document_version v JOIN dms_file_content c ON c.id = v.content_id
   WHERE v.document_id = l_doc2 AND v.status_code = 'CURRENT' AND c.detected_mime = 'application/pdf' AND LENGTH(c.hash_value) = 64;
  ok('file stored with detected type and SHA-256', l_n = 1, l_n);
  l_n := NOONA_DMS_PKG.add_version(l_doc2, 'receipt-v2.pdf', 'application/pdf', l_pdf, 'صورة أوضح');
  SELECT COUNT(*) INTO l_n FROM dms_document_version WHERE document_id = l_doc2 AND status_code = 'SUPERSEDED';
  ok('previous version kept as superseded', l_n = 1, l_n);
  l_n := NOONA_DMS_PKG.create_type('SMALL' || l_sfx, 'نوع صغير', 'ADM', 'application/pdf', 1);
  DBMS_LOB.CREATETEMPORARY(l_big, TRUE);
  DBMS_LOB.APPEND(l_big, l_pdf);
  FOR i IN 1 .. 40 LOOP DBMS_LOB.APPEND(l_big, UTL_RAW.COPIES(UTL_RAW.CAST_TO_RAW('0123456789ABCDEF'), 2000)); END LOOP;
  BEGIN l_n := NOONA_DMS_PKG.archive_document(NULL, NULL, 'SMALL' || l_sfx, 'كبير', NULL, NULL, NULL, NULL, 'big.pdf', 'application/pdf', l_big);
        ok('size limit per document type', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('size limit per document type', 'NOONA-DMS-111', SQLERRM); END;
  l_c := NOONA_DMS_PKG.document_html(l_doc2, 'f?p=128:49:1::NO::P49_DOC,P49_VER:#ID#,#VER#');
  ok('document page lists versions and links', INSTR(l_c, 'receipt-v2.pdf') > 0 AND INSTR(l_c, 'صورة أوضح') > 0 AND INSTR(l_c, 'سند مصروفات') > 0);

  -- القيود
  l_j := NOONA_GL_PKG.create_journal(l_date, 'تسوية بمستند');
  NOONA_GL_PKG.save_lines(l_j, '[{"a":"5299","d":15},{"a":"1102","c":15}]');
  NOONA_GL_PKG.submit_journal(l_j);
  login(l_user);
  BEGIN NOONA_GL_PKG.approve_journal(l_j); ok('journal approval needs paper reference', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('journal approval needs paper reference', 'NOONA-DMS-200', SQLERRM); END;
  login('ADMIN');
  l_doc := NOONA_DMS_PKG.archive_document('GL_JOURNAL', l_j, NULL, NULL, 'MEMO-7', 'ملف القيود');
  login(l_user);
  NOONA_GL_PKG.approve_journal(l_j);
  SELECT status_code INTO l_s FROM gl_journal WHERE id = l_j;
  ok('journal approved after archiving', l_s = 'POSTED', l_s);
  login('ADMIN');
  ok('refs text', INSTR(NOONA_DMS_PKG.refs_text('GL_JOURNAL', l_j), 'MEMO-7') > 0);
  l_c := NOONA_FIN_RPT_PKG.journal_view(l_j);
  ok('journal view lists archived documents', INSTR(l_c, 'المستندات المؤرشفة') > 0 AND INSTR(l_c, 'MEMO-7') > 0);
  NOONA_DMS_PKG.set_rule('GL_JOURNAL', 'JOURNAL_SUPPORT', 'N', 'N');
  ok('rule can be relaxed', NOONA_DMS_PKG.has_reference('GL_JOURNAL', -1) = 'Y');
  l_c := NOONA_DMS_PKG.summary('1');
  ok('archive dashboard renders', INSTR(l_c, 'nn-kpi') > 0);


  -- عارض المستندات
  l_c := NOONA_DMS_PKG.attachments_html('CSH_TRANSACTION', l_v2, 'f?p=129:49:1::NO::P49_DOC:#ID#', 'Y');
  ok('viewer cards with preview kind', INSTR(l_c, 'nn-dv-card') > 0 AND INSTR(l_c, 'data-kind="pdf"') > 0 AND INSTR(l_c, 'data-auto="Y"') > 0
     AND INSTR(l_c, 'p49_mode=D') > 0);

  -- مكان الحفظ: مجلد على الخادم
  BEGIN NOONA_DMS_PKG.set_storage('SERVER_FOLDER', 'NOONA_DMS_T999'); ok('foreign directory rejected', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('foreign directory rejected', 'NOONA-DMS-144', SQLERRM); END;
  BEGIN NOONA_DMS_PKG.set_storage('OBJECT_STORAGE'); ok('object storage deferred', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('object storage deferred', 'NOONA-DMS-141', SQLERRM); END;
  SELECT COUNT(*) INTO l_n FROM TABLE(NOONA_DMS_PKG.storage_directories);
  IF l_n > 0 THEN
    SELECT MIN(column_value) INTO l_s FROM TABLE(NOONA_DMS_PKG.storage_directories);
    NOONA_DMS_PKG.set_storage('SERVER_FOLDER', l_s, '/opt/noona/files', 'TEST_');
    ok('server folder test passes', NOONA_DMS_PKG.test_storage = 'OK', NOONA_DMS_PKG.test_storage);
    l_doc := NOONA_DMS_PKG.archive_document(NULL, NULL, 'GENERAL', 'ملف في المجلد', 'EXT-1', NULL, NULL, NULL,
                                            'folder.pdf', 'application/pdf', l_pdf);
    SELECT c.id, c.storage_medium || '|' || NVL2(c.content_blob, 'BLOB', 'NOBLOB') || '|' || c.storage_bucket_ref INTO l_cid, l_s
      FROM dms_document d JOIN dms_document_version v ON v.id = d.current_version_id JOIN dms_file_content c ON c.id = v.content_id
     WHERE d.id = l_doc;
    ok('new file saved outside the database', l_s LIKE 'NAS|NOBLOB|NOONA_DMS_T%', l_s);
    l_blob := NOONA_DMS_PKG.read_content(l_cid);
    ok('file read back from folder intact', DBMS_LOB.COMPARE(l_blob, l_pdf) = 0);
    l_n := NOONA_DMS_PKG.move_files(50);
    SELECT COUNT(*) INTO l_n2 FROM dms_file_content c JOIN dms_document_version v ON v.content_id = c.id JOIN dms_document d ON d.id = v.document_id
     WHERE d.id = l_doc2 AND c.storage_medium = 'NAS' AND c.content_blob IS NULL;
    ok('existing database files moved to the folder', l_n > 0 AND l_n2 >= 1, l_n || '/' || l_n2);
    SELECT c.id INTO l_cid FROM dms_document d JOIN dms_document_version v ON v.id = d.current_version_id JOIN dms_file_content c ON c.id = v.content_id
     WHERE d.id = l_doc2;
    ok('moved file still readable', DBMS_LOB.COMPARE(NOONA_DMS_PKG.read_content(l_cid), l_pdf) = 0);
    l_c := NOONA_DMS_PKG.storage_html;
    ok('storage settings summary', INSTR(l_c, 'مجلد على الخادم') > 0);
    NOONA_DMS_PKG.set_storage('DATABASE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('SKIP  server folder tests (no NOONA_DMS_T<tenant> directory)');
  END IF;

  -- الأطراف ومستنداتهم
  BEGIN l_pty := NOONA_PTY_PKG.create_party('ORGANIZATION', 'مورد خطأ', 'SUPPLIER', NULL, '123'); ok('Saudi VAT format checked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('Saudi VAT format checked', 'NOONA-PTY-002', SQLERRM); END;
  l_pty := NOONA_PTY_PKG.create_party('ORGANIZATION', 'مؤسسة التوريدات المتحدة ' || l_sfx, 'SUPPLIER', NULL,
                                      '3' || LPAD(MOD(TO_NUMBER(l_sfx), 1e13), 13, '0') || '3', 'CR' || l_sfx);
  SELECT party_no INTO l_s FROM pty_party WHERE id = l_pty;
  ok('party created with number and role', l_s LIKE 'P-%' AND NOONA_PTY_PKG.party_roles(l_pty) = 'مورد', l_s);
  DELETE FROM dms_required_document;
  ok('default party requirements', NOONA_DMS_PKG.seed_requirements >= 9);
  ok('missing supplier documents counted', NOONA_DMS_PKG.missing_documents(l_pty, 'SUPPLIER') = 3, NOONA_DMS_PKG.missing_documents(l_pty, 'SUPPLIER'));
  l_doc := NOONA_DMS_PKG.archive_document('PTY_PARTY', l_pty, 'COMMERCIAL_REGISTER', NULL, '1010' || l_sfx, 'ملف الموردين',
                                          p_valid_from => ADD_MONTHS(l_date, -12), p_valid_to => l_date - 1);
  ok('expired certificate does not count', NOONA_DMS_PKG.missing_documents(l_pty, 'SUPPLIER') = 3);
  l_doc := NOONA_DMS_PKG.archive_document('PTY_PARTY', l_pty, 'COMMERCIAL_REGISTER', NULL, '1010' || l_sfx, 'ملف الموردين',
                                          p_valid_from => l_date, p_valid_to => l_date + 20);
  l_doc2 := NOONA_DMS_PKG.archive_document('PTY_PARTY', l_pty, 'VAT_CERTIFICATE', NULL, 'VAT-' || l_sfx, NULL, NULL, NULL,
                                           'vat.pdf', 'application/pdf', l_pdf);
  l_n := NOONA_DMS_PKG.archive_document('PTY_PARTY', l_pty, 'BANK_LETTER', NULL, 'IBAN-LETTER', 'ملف الموردين');
  ok('supplier documents complete', NOONA_DMS_PKG.missing_documents(l_pty, 'SUPPLIER') = 0, NOONA_DMS_PKG.missing_documents(l_pty, 'SUPPLIER'));
  BEGIN l_n := NOONA_DMS_PKG.archive_document('PTY_PARTY', l_pty, 'ZAKAT_CERTIFICATE', NULL, 'Z-1', NULL, p_valid_from => l_date, p_valid_to => l_date - 5);
        ok('validity dates checked', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('validity dates checked', 'NOONA-DMS-115', SQLERRM); END;
  l_c := NOONA_DMS_PKG.compliance_html(l_pty, 'SUPPLIER', 'f?p=129:49:1::NO::P49_DOC:#ID#');
  ok('compliance page (status + viewer)', INSTR(l_c, 'مكتملة وسارية') > 0 AND INSTR(l_c, 'ينتهي') > 0 AND INSTR(l_c, 'nn-dv-card') > 0);
  l_c := NOONA_DMS_PKG.expiring_html(30);
  ok('expiring report lists the certificate', INSTR(l_c, '1010' || l_sfx) > 0 AND INSTR(l_c, 'الطرف') > 0);
  NOONA_DMS_PKG.set_validity(l_doc, l_date, ADD_MONTHS(l_date, 12));
  ok('validity updated', NOONA_DMS_PKG.validity_status(ADD_MONTHS(l_date, 12), 30) = 'VALID');
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
