-- =============================================================================
-- NOONA PLUS ERP | اختبار الأصول الثابتة بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_fixed_assets.sql
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
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_per  NUMBER;
  l_ps   DATE;
  l_pe   DATE;
  l_pty  NUMBER;
  l_cc   NUMBER;
  l_a    NUMBER;   -- حاسب: قسط ثابت 48 شهراً
  l_b    NUMBER;   -- أثاث: يبدأ قبل 3 أشهر (لحاق)
  l_c    NUMBER;   -- آلة برصيد افتتاحي ومجمع منقول
  l_d    NUMBER;   -- أرض: لا تهلك
  l_f    NUMBER;   -- أثاث يستبعد قبل أي إهلاك
  l_v    NUMBER;   -- سيارة: متناقص
  l_run  NUMBER;
  l_dis  NUMBER;
  l_dis2 NUMBER;
  l_j    NUMBER;
  l_dr   NUMBER;
  l_cr   NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION cat(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT id INTO l FROM fa_category WHERE code = p_code AND company_id = NOONA_FA_PKG.company;
    RETURN l;
  END cat;
  FUNCTION bk(p_asset NUMBER, p_col VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT ' || p_col || ' FROM fa_asset_book WHERE asset_id = :1' INTO l USING p_asset;
    RETURN l;
  END bk;
  FUNCTION ast(p_asset NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT status_code INTO l FROM fa_asset WHERE id = p_asset;
    RETURN l;
  END ast;
  -- مجموع المدين/الدائن لحساب في قيد
  FUNCTION jl(p_j NUMBER, p_code VARCHAR2, p_side VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE p_side WHEN 'D' THEN l.debit_amount ELSE l.credit_amount END), 0) INTO l
      FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j AND a.account_code = p_code;
    RETURN l;
  END jl;
  FUNCTION ev_journal(p_type VARCHAR2, p_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(journal_id) INTO l FROM ace_accounting_event
     WHERE source_entity_type = p_type AND source_entity_id = p_id AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    RETURN l;
  END ev_journal;
  FUNCTION cap_txn(p_asset NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM fa_transaction WHERE asset_id = p_asset AND txn_type = 'CAPITALIZATION';
    RETURN l;
  END cap_txn;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- التجهيز
  l_n := NOONA_FA_PKG.quick_setup;
  ok('fixed assets ready after setup', NOONA_FA_PKG.is_ready = 'Y');
  l_n := NOONA_FA_PKG.quick_setup;
  ok('setup is idempotent', l_n = 0, l_n);
  SELECT COUNT(*) INTO l_n FROM fa_category WHERE company_id = NOONA_FA_PKG.company AND code IN ('LAND', 'BUILDINGS', 'MACHINERY', 'FURNITURE', 'VEHICLES', 'COMPUTERS');
  ok('default categories created', l_n = 6, l_n);
  l_per := NOONA_FA_PKG.next_period;
  SELECT start_date, end_date INTO l_ps, l_pe FROM gl_period WHERE id = l_per;
  ok('next depreciation period found', l_per IS NOT NULL AND l_ps = TRUNC(l_ps, 'MM'), d(l_ps));
  SELECT MIN(id) INTO l_pty FROM pty_party;
  SELECT MIN(id) INTO l_cc FROM gl_cost_center WHERE company_id = NOONA_FA_PKG.company AND status_code = 'ACTIVE';

  -- التحقق
  BEGIN l_n := NOONA_FA_PKG.create_asset('{"name_ar":"x","category":' || cat('COMPUTERS') || ',"cost":0}'); ok('cost must be positive', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cost must be positive', 'NOONA-FA-018', SQLERRM); END;
  BEGIN l_n := NOONA_FA_PKG.create_asset('{"name_ar":"x","category":' || cat('COMPUTERS') || ',"cost":1000,"funding":"PAYABLE","capitalize":"Y","acquisition_date":"'
                 || d(l_ps) || '"}'); ok('credit purchase needs supplier', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('credit purchase needs supplier', 'NOONA-FA-012', SQLERRM); END;
  BEGIN l_n := NOONA_FA_PKG.create_asset('{"name_ar":"x","category":' || cat('COMPUTERS') || ',"cost":1000,"funding":"BANK","opening_accum":200}');
        ok('opening accumulated only with opening funding', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('opening accumulated only with opening funding', 'NOONA-FA-021', SQLERRM); END;

  -- الاقتناء من البنك مع ضريبة المدخلات والرسملة الفورية
  l_a := NOONA_FA_PKG.create_asset('{"name_ar":"خادم بيانات","category":' || cat('COMPUTERS') || ',"cost":48000,"vat":7200,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_ps) || '","in_service_date":"' || d(l_ps) || '","cost_center":' || NVL(TO_CHAR(l_cc), 'null')
         || ',"serial":"SRV-1","capitalize":"Y"}');
  ok('asset capitalized and in service', ast(l_a) = 'IN_SERVICE', ast(l_a));
  l_j := ev_journal('FA_TRANSACTION', cap_txn(l_a));
  ok('acquisition entry: Dr asset 48000, Dr input VAT 7200', jl(l_j, '1206', 'D') = 48000 AND jl(l_j, '1107', 'D') = 7200);
  SELECT SUM(debit_amount), SUM(credit_amount) INTO l_dr, l_cr FROM gl_journal_line WHERE journal_id = l_j;
  ok('acquisition entry balanced, bank credited 55200', l_dr = l_cr AND l_cr = 55200, l_dr || '/' || l_cr);
  SELECT asset_no INTO l_s FROM fa_asset WHERE id = l_a;
  ok('asset numbered', l_s LIKE 'FA-%', l_s);
  BEGIN l_n := NOONA_FA_PKG.capitalize(l_a); ok('no double capitalization', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no double capitalization', 'NOONA-FA-022', SQLERRM); END;

  -- شراء آجل من مورد، بدأ تشغيله قبل 3 أشهر
  l_b := NOONA_FA_PKG.create_asset('{"name_ar":"مكاتب الإدارة","category":' || cat('FURNITURE') || ',"cost":6000,"funding":"PAYABLE","party":' || l_pty
         || ',"acquisition_date":"' || d(l_ps) || '","in_service_date":"' || d(ADD_MONTHS(l_ps, -3)) || '"}');
  ok('draft asset before capitalization', ast(l_b) = 'DRAFT');
  l_j := NOONA_FA_PKG.capitalize(l_b);
  ok('credit purchase: Cr asset payables with supplier', jl(l_j, '2110', 'C') = 6000 AND jl(l_j, '1204', 'D') = 6000);
  SELECT COUNT(*) INTO l_n FROM gl_journal_line WHERE journal_id = l_j AND party_id = l_pty;
  ok('payable line carries the supplier', l_n = 1);

  -- رصيد افتتاحي: آلة عمرها 10 سنوات، مضى عليها سنتان، متبقية 5%
  l_c := NOONA_FA_PKG.create_asset('{"name_ar":"خط تعبئة","category":' || cat('MACHINERY') || ',"cost":120000,"funding":"OPENING","opening_accum":22800,'
         || '"acquisition_date":"' || d(l_ps) || '","in_service_date":"' || d(ADD_MONTHS(l_ps, -24)) || '","capitalize":"Y"}');
  ok('opening asset: residual from category %', bk(l_c, 'residual_value') = 6000, bk(l_c, 'residual_value'));
  l_j := ev_journal('FA_TRANSACTION', cap_txn(l_c));
  ok('opening entry: Cr accumulated 22800 and opening balances 97200', jl(l_j, '1209', 'C') = 22800 AND jl(l_j, '3105', 'C') = 97200);
  ok('opening asset depreciated to day before capitalization', bk(l_c, 'accumulated_depr') = 22800);

  -- أرض لا تهلك، وسيارة بالمتناقص
  l_d := NOONA_FA_PKG.create_asset('{"name_ar":"أرض المستودع","category":' || cat('LAND') || ',"cost":500000,"funding":"BANK","acquisition_date":"'
         || d(l_ps) || '","capitalize":"Y"}');
  l_v := NOONA_FA_PKG.create_asset('{"name_ar":"سيارة توزيع","category":' || cat('VEHICLES') || ',"cost":90000,"residual":9000,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_ps) || '","in_service_date":"' || d(l_ps) || '","capitalize":"Y"}');
  -- مسودة تحذف
  l_n := NOONA_FA_PKG.create_asset('{"name_ar":"مسودة","category":' || cat('FURNITURE') || ',"cost":100}');
  NOONA_FA_PKG.delete_asset(l_n);
  SELECT COUNT(*) INTO l_n FROM fa_asset WHERE id = l_n;
  ok('draft asset deleted', l_n = 0);
  BEGIN NOONA_FA_PKG.delete_asset(l_a); ok('capitalized asset cannot be deleted', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('capitalized asset cannot be deleted', 'NOONA-FA-023', SQLERRM); END;

  -- معاينة وتشغيل الإهلاك
  ok('depreciation preview: computer 1000 for the month',
     NOONA_FA_PKG.depreciation_for(NOONA_FA_PKG.book_id_of(l_a), l_pe) = 1000, NOONA_FA_PKG.depreciation_for(NOONA_FA_PKG.book_id_of(l_a), l_pe));
  ok('preview renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.preview_html(l_per)) > 100);
  l_run := NOONA_FA_PKG.run_depreciation(l_per);
  SELECT status_code INTO l_s FROM fa_depreciation_run WHERE id = l_run;
  ok('depreciation run posted', l_s = 'POSTED', l_s);
  ok('straight line monthly: 48000 / 48 = 1000', bk(l_a, 'accumulated_depr') = 1000, bk(l_a, 'accumulated_depr'));
  ok('catch-up of missed months: 6000 / 60 x 4 = 400', bk(l_b, 'accumulated_depr') = 400, bk(l_b, 'accumulated_depr'));
  ok('opening asset over remaining life: 91200 / 96 = 950', bk(l_c, 'accumulated_depr') = 22800 + 950, bk(l_c, 'accumulated_depr'));
  ok('land not depreciated', bk(l_d, 'accumulated_depr') = 0);
  ok('declining balance: 90000 x 1.5 / 60 = 2250', bk(l_v, 'accumulated_depr') = 2250, bk(l_v, 'accumulated_depr'));
  SELECT journal_id INTO l_j FROM fa_depreciation_run WHERE id = l_run;
  SELECT SUM(debit_amount), SUM(credit_amount) INTO l_dr, l_cr FROM gl_journal_line WHERE journal_id = l_j;
  ok('depreciation entry balanced: Dr expense = Cr accumulated', l_dr = l_cr AND jl(l_j, '5206', 'D') = l_dr AND jl(l_j, '1209', 'C') = l_cr);
  SELECT COUNT(*) INTO l_n FROM gl_journal_line WHERE journal_id = l_j AND cost_center_id = l_cc;
  ok('depreciation expense charged to asset cost center', l_cc IS NULL OR l_n >= 1);
  BEGIN l_n := NOONA_FA_PKG.run_depreciation(l_per); ok('period cannot be depreciated twice', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('period cannot be depreciated twice', 'NOONA-FA-031', SQLERRM); END;
  ok('run report renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.run_html(l_run)) > 200);

  -- إضافة رأسمالية، انخفاض، تغيير العمر، نقل
  l_n := NOONA_FA_PKG.add_cost(l_a, 2400, l_pe, 'BANK', NULL, NULL, NULL, NULL, 360, 'ترقية الذاكرة');
  ok('capital addition increases cost', bk(l_a, 'cost') = 50400);
  l_j := ev_journal('FA_TRANSACTION', l_n);
  ok('addition entry posted', jl(l_j, '1206', 'D') = 2400 AND jl(l_j, '1107', 'D') = 360);
  BEGIN l_n := NOONA_FA_PKG.impair(l_c, 999999, l_pe, 'تلف'); ok('impairment limited to NBV', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('impairment limited to NBV', 'NOONA-FA-042', SQLERRM); END;
  l_n := NOONA_FA_PKG.impair(l_c, 5000, l_pe, 'تقادم تقني');
  ok('impairment increases accumulated', bk(l_c, 'accumulated_depr') = 22800 + 950 + 5000);
  l_j := ev_journal('FA_TRANSACTION', l_n);
  ok('impairment entry: Dr impairment loss', jl(l_j, '5218', 'D') = 5000 AND jl(l_j, '1209', 'C') = 5000);
  l_n := NOONA_FA_PKG.change_life(l_b, 36, 0, l_pe, 'إعادة تقدير العمر');
  ok('useful life changed', bk(l_b, 'useful_life_months') = 36);
  ok('remaining life applied prospectively: 5600 / 32 = 175',
     NOONA_FA_PKG.depreciation_for(NOONA_FA_PKG.book_id_of(l_b), LAST_DAY(l_pe + 1)) = 175,
     NOONA_FA_PKG.depreciation_for(NOONA_FA_PKG.book_id_of(l_b), LAST_DAY(l_pe + 1)));
  l_n := NOONA_FA_PKG.transfer(l_a, l_pe, NULL, NULL, NULL, 'غرفة الخوادم - الدور الثاني', 'نقل');
  SELECT location_text INTO l_s FROM fa_asset WHERE id = l_a;
  ok('transfer updates location', l_s = 'غرفة الخوادم - الدور الثاني', l_s);
  SELECT COUNT(*) INTO l_n FROM fa_transfer WHERE asset_id = l_a AND status_code = 'COMPLETED';
  ok('transfer document recorded', l_n = 1);

  -- البيع الآجل مع ضريبة المخرجات وخسارة
  BEGIN l_n := NOONA_FA_PKG.dispose(l_a, 'SALE', l_pe, 0, 0, 'BANK', NULL, NULL, NULL, 'x'); ok('sale needs a price', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('sale needs a price', 'NOONA-FA-053', SQLERRM); END;
  BEGIN l_n := NOONA_FA_PKG.dispose(l_a, 'DONATION', l_pe, 100, 0, 'BANK', NULL, NULL, NULL, 'x'); ok('donation has no proceeds', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('donation has no proceeds', 'NOONA-FA-052', SQLERRM); END;
  BEGIN l_n := NOONA_FA_PKG.dispose(l_a, 'SALE', l_ps, 1000, 0, 'BANK', NULL, NULL, NULL, 'x'); ok('disposal date after posted depreciation', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('disposal date after posted depreciation', 'NOONA-FA-054', SQLERRM); END;
  l_dis := NOONA_FA_PKG.dispose(l_a, 'SALE', l_pe, 40000, 6000, 'RECEIVABLE', NULL, NULL, l_pty, 'بيع لجهة خارجية');
  ok('asset disposed', ast(l_a) = 'DISPOSED');
  SELECT gain_loss, nbv_at_disposal INTO l_dr, l_cr FROM fa_disposal WHERE id = l_dis;
  ok('loss on sale: 40000 - (50400 - 1000) = -9400', l_dr = -9400 AND l_cr = 49400, l_dr || ' / ' || l_cr);
  l_j := ev_journal('FA_DISPOSAL', l_dis);
  ok('sale entry: Dr receivable 46000, Cr VAT 6000, Cr cost 50400',
     jl(l_j, '1109', 'D') = 46000 AND jl(l_j, '2104', 'C') = 6000 AND jl(l_j, '1206', 'C') = 50400);
  ok('sale entry: Dr accumulated 1000 and loss 9400', jl(l_j, '1209', 'D') = 1000 AND jl(l_j, '5217', 'D') = 9400);
  SELECT SUM(debit_amount), SUM(credit_amount) INTO l_dr, l_cr FROM gl_journal_line WHERE journal_id = l_j;
  ok('sale entry balanced', l_dr = l_cr, l_dr || '/' || l_cr);
  BEGIN l_n := NOONA_FA_PKG.dispose(l_a, 'SCRAP', l_pe, 0, 0, 'BANK', NULL, NULL, NULL, 'x'); ok('disposed asset cannot be disposed again', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('disposed asset cannot be disposed again', 'NOONA-FA-040', SQLERRM); END;

  -- تخريد أصل لم يهلك بعد: يلحق إهلاكه حتى تاريخ الاستبعاد
  l_f := NOONA_FA_PKG.create_asset('{"name_ar":"طابعة قديمة","category":' || cat('FURNITURE') || ',"cost":12000,"funding":"BANK",'
         || '"acquisition_date":"' || d(l_ps) || '","in_service_date":"' || d(l_ps) || '","capitalize":"Y"}');
  l_dis2 := NOONA_FA_PKG.dispose(l_f, 'SCRAP', l_pe, 500, 0, 'BANK', NULL, NULL, NULL, 'تخريد');
  l_j := ev_journal('FA_DISPOSAL', l_dis2);
  ok('scrap catches up depreciation to disposal date (200)', jl(l_j, '5206', 'D') = 200, jl(l_j, '5206', 'D'));
  SELECT gain_loss INTO l_n FROM fa_disposal WHERE id = l_dis2;
  ok('scrap loss: 500 - 11800 = -11300', l_n = -11300, l_n);
  ok('scrap entry: loss and cost closed', jl(l_j, '5217', 'D') = 11300 AND jl(l_j, '1204', 'C') = 12000 AND jl(l_j, '1209', 'D') = 200);

  -- ربح بيع: الأرض بأعلى من تكلفتها
  l_n := NOONA_FA_PKG.dispose(l_d, 'SALE', l_pe, 550000, 0, 'BANK', NULL, NULL, l_pty, 'بيع الأرض');
  SELECT gain_loss INTO l_dr FROM fa_disposal WHERE id = l_n;
  l_j := ev_journal('FA_DISPOSAL', l_n);
  ok('gain on sale credited to disposal gains', l_dr = 50000 AND jl(l_j, '4204', 'C') = 50000, l_dr);

  -- عكس الإهلاك يتطلب عكس الاستبعاد أولاً
  BEGIN l_n := NOONA_FA_PKG.reverse_run(l_run, 'x'); ok('reverse run blocked by disposal', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('reverse run blocked by disposal', 'NOONA-FA-036', SQLERRM); END;
  l_n := NOONA_FA_PKG.reverse_disposal(l_dis, 'بيع ملغى');
  ok('disposal reversed: asset back in service', ast(l_a) = 'IN_SERVICE' AND bk(l_a, 'accumulated_depr') = 1000, ast(l_a));
  SELECT status_code INTO l_s FROM fa_disposal WHERE id = l_dis;
  ok('disposal cancelled', l_s = 'CANCELLED', l_s);
  l_n := NOONA_FA_PKG.reverse_run(l_run, 'إعادة احتساب');
  ok('run reversed: accumulated restored', bk(l_b, 'accumulated_depr') = 0 AND bk(l_c, 'accumulated_depr') = 22800 + 5000,
     bk(l_b, 'accumulated_depr') || ' / ' || bk(l_c, 'accumulated_depr'));
  SELECT depreciated_to INTO l_ps FROM fa_asset_book WHERE asset_id = l_c;
  ok('opening asset back to its opening date', l_ps = TRUNC(l_ps) AND l_ps < l_pe);
  l_run := NOONA_FA_PKG.run_depreciation(l_per);
  ok('period re-run after reversal', bk(l_a, 'accumulated_depr') = 1050 AND bk(l_b, 'accumulated_depr') > 0, bk(l_a, 'accumulated_depr'));

  -- التقارير
  ok('summary renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.fa_summary) > 200);
  ok('register renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.register_html(NULL, NULL, 'ALL', 'f?p=1:61::#ID#')) > 300);
  ok('asset card renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.asset_card_html(l_a)) > 500);
  ok('schedule renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.schedule_html(l_b)) > 500);
  ok('roll-forward renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.rollforward_html(TRUNC(l_pe, 'YYYY'), l_pe)) > 500);
  ok('disposals report renders', DBMS_LOB.GETLENGTH(NOONA_FA_PKG.disposals_html(TRUNC(l_pe, 'YYYY'), l_pe)) > 300);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
