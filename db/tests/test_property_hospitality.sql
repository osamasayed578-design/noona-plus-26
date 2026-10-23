-- =============================================================================
-- NOONA PLUS ERP | اختبار العقارات والضيافة والصيانة بحساب NOONA_APP - يتراجع عن كل التغييرات في النهاية
-- التشغيل: sqlplus NOONA_APP@//host:1521/PDB @tests/test_property_hospitality.sql
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
  l_sfx  VARCHAR2(20) := TO_CHAR(SYSTIMESTAMP, 'MISSFF3');
  l_n    NUMBER;
  l_s    VARCHAR2(4000);
  l_c    CLOB;
  l_prop NUMBER;
  l_rt   NUMBER;
  l_plan NUMBER;
  l_bd   DATE;
  l_bd0  DATE;
  l_r1   NUMBER;
  l_r3   NUMBER;
  l_r4   NUMBER;
  l_st   NUMBER;
  l_st2  NUMBER;
  l_st1  NUMBER;
  l_fol  NUMBER;
  l_room NUMBER;
  l_rB   NUMBER;
  l_rD   NUMBER;
  l_aud  NUMBER;
  l_j    NUMBER;
  l_dr   NUMBER;
  l_cr   NUMBER;
  l_cmp  NUMBER;
  l_cat  NUMBER;
  l_team NUMBER;
  l_tech NUMBER;
  l_req  NUMBER;
  l_unit NUMBER;

  PROCEDURE ok(p_name VARCHAR2, p_cond BOOLEAN, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF p_cond THEN g_pass := g_pass + 1; DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name);
    ELSE g_fail := g_fail + 1; DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || CASE WHEN p_info IS NOT NULL THEN '  -> ' || p_info END);
    END IF;
  END ok;
  PROCEDURE expect(p_name VARCHAR2, p_code VARCHAR2, p_err VARCHAR2) IS
  BEGIN ok(p_name, INSTR(p_err, p_code) > 0, NVL(p_err, 'no error')); END;
  FUNCTION d(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  FUNCTION jl(p_j NUMBER, p_code VARCHAR2, p_side VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE p_side WHEN 'D' THEN l.debit_amount ELSE l.credit_amount END), 0) INTO l
      FROM gl_journal_line l JOIN gl_account a ON a.id = l.account_id WHERE l.journal_id = p_j AND a.account_code = p_code;
    RETURN l;
  END jl;
  FUNCTION ev(p_type VARCHAR2, p_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(journal_id) INTO l FROM ace_accounting_event WHERE source_entity_type = p_type AND source_entity_id = p_id
       AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    RETURN l;
  END ev;
  FUNCTION room_of(p_stay NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT room_id INTO l FROM hsp_stay WHERE id = p_stay; RETURN l;
  END room_of;
  FUNCTION hk(p_room NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(100);
  BEGIN
    SELECT housekeeping_status || '/' || front_desk_status || '/' || status_code INTO l FROM hsp_room WHERE id = p_room; RETURN l;
  END hk;
  FUNCTION balanced(p_j NUMBER) RETURN BOOLEAN IS
    l_d NUMBER; l_k NUMBER;
  BEGIN
    SELECT SUM(debit_amount), SUM(credit_amount) INTO l_d, l_k FROM gl_journal_line WHERE journal_id = p_j;
    RETURN l_d = l_k AND l_d > 0;
  END balanced;
BEGIN
  NOONA_APEX_PKG.post_auth('ADMIN', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));

  -- التجهيز
  l_n := NOONA_HSP_PKG.quick_setup;
  ok('hospitality ready after setup', NOONA_HSP_PKG.is_ready = 'Y');
  l_n := NOONA_MNT_PKG.quick_setup;
  ok('maintenance ready after setup', NOONA_MNT_PKG.is_ready = 'Y');
  SELECT COUNT(*) INTO l_n FROM mnt_service_category WHERE code IN ('PLUMBING', 'HVAC', 'ELECTRICAL', 'ELEVATOR');
  ok('service categories seeded', l_n = 4, l_n);

  -- معالج العقار: فندق بمبنى من 3 أدوار و4 غرف في كل دور
  BEGIN l_n := NOONA_RE_PKG.save_property('{"name_ar":""}'); ok('property name required', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('property name required', 'NOONA-RE-001', SQLERRM); END;
  l_prop := NOONA_RE_PKG.setup_wizard('{"name_ar":"فندق اختبار ' || l_sfx || '","type":"HOTEL","star_rating":4,"address":"الرياض - العليا",'
            || '"buildings":[{"code":"A","name":"البرج الرئيسي","floors":3}],'
            || '"units":{"per_floor":4,"unit_type":"ROOM","usage_type":"HOSPITALITY","bedrooms":1,"area":32,"furnishing":"FURNISHED"},'
            || '"hospitality":{"room_type_name":"غرفة ديلوكس","base_rate":400,"max_adults":2}}');
  SELECT COUNT(*) INTO l_n FROM re_unit WHERE property_id = l_prop;
  ok('wizard generated 12 units', l_n = 12, l_n);
  SELECT COUNT(*) INTO l_n FROM hsp_room WHERE property_id = l_prop;
  ok('wizard created 12 hotel rooms', l_n = 12, l_n);
  SELECT COUNT(*) INTO l_n FROM re_unit WHERE property_id = l_prop AND code IN ('101', '104', '301', '304');
  ok('unit numbering floor + sequence', l_n = 4, l_n);
  SELECT MIN(id) INTO l_rt FROM hsp_room_type WHERE property_id = l_prop;
  ok('stacking plan renders', DBMS_LOB.GETLENGTH(NOONA_RE_PKG.stacking_html(l_prop, '#ID#')) > 1000);
  SELECT MIN(id) INTO l_unit FROM re_unit WHERE property_id = l_prop AND code = '101';
  NOONA_RE_PKG.save_unit('{"id":' || l_unit || ',"bedrooms":2,"amenities":"شاشة، ثلاجة، مطبخ صغير","price":null}');
  SELECT bedrooms INTO l_n FROM re_unit WHERE id = l_unit;
  ok('unit details saved', l_n = 2);

  -- الأسعار
  l_plan := NOONA_HSP_PKG.save_rate_plan(NULL, l_prop, 'BAR', 'السعر اليومي', 'DAILY', 'BREAKFAST', 'N', 'إلغاء مجاني قبل 24 ساعة');
  l_bd := NOONA_HSP_PKG.business_date(l_prop);
  l_bd0 := l_bd;
  l_n := NOONA_HSP_PKG.set_rate(l_plan, l_rt, l_bd - 30, l_bd + 365, 450);
  ok('nightly rate from plan', NOONA_HSP_PKG.nightly_rate(l_plan, l_rt, l_bd) = 450, NOONA_HSP_PKG.nightly_rate(l_plan, l_rt, l_bd));
  ok('fallback to base rate', NOONA_HSP_PKG.nightly_rate(NULL, l_rt, l_bd) = 400);
  ok('all rooms available', NOONA_HSP_PKG.available_count(l_prop, l_rt, l_bd, l_bd + 1) = 12);

  -- حجز مستقبلي
  BEGIN l_n := NOONA_HSP_PKG.create_reservation('{"property":' || l_prop || ',"guest_name":"x","room_type":' || l_rt || ',"arrival":"'
                 || d(l_bd + 3) || '","departure":"' || d(l_bd + 1) || '"}'); ok('departure after arrival', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('departure after arrival', 'NOONA-HSP-015', SQLERRM); END;
  l_r1 := NOONA_HSP_PKG.create_reservation('{"property":' || l_prop || ',"guest_name":"سعد الحربي ' || l_sfx || '","phone":"0551234567",'
          || '"id_type":"NATIONAL_ID","id_no":"10' || LPAD(l_sfx, 8, '3') || '","room_type":' || l_rt || ',"rate_plan":' || l_plan || ','
          || '"arrival":"' || d(l_bd + 1) || '","departure":"' || d(l_bd + 3) || '","adults":2,"channel":"PHONE","deposit":300,"deposit_method":"CASH"}');
  SELECT status_code INTO l_s FROM hsp_reservation WHERE id = l_r1;
  ok('reservation with deposit is guaranteed', l_s = 'GUARANTEED', l_s);
  SELECT room_id INTO l_room FROM hsp_reservation_room WHERE reservation_id = l_r1;
  SELECT COUNT(*) INTO l_n FROM hsp_room_block WHERE room_id = l_room;
  ok('two nights blocked for the room', l_n = 2, l_n);
  l_fol := NOONA_HSP_PKG.folio_of_reservation(l_r1);
  ok('deposit credited to folio', NOONA_HSP_PKG.folio_balance(l_fol) = -300, NOONA_HSP_PKG.folio_balance(l_fol));
  SELECT MAX(id) INTO l_n FROM hsp_folio_line WHERE folio_id = l_fol;
  l_j := ev('HSP_FOLIO_LINE', l_n);
  ok('deposit entry: Cr guest ledger 1112', jl(l_j, '1112', 'C') = 300 AND balanced(l_j));
  BEGIN l_n := NOONA_HSP_PKG.create_reservation('{"property":' || l_prop || ',"guest_name":"مكرر","room":' || l_room || ','
                 || '"arrival":"' || d(l_bd + 2) || '","departure":"' || d(l_bd + 4) || '"}'); ok('double booking prevented', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('double booking prevented', 'NOONA-HSP-010', SQLERRM); END;
  ok('availability reduced on reserved night', NOONA_HSP_PKG.available_count(l_prop, l_rt, l_bd + 1, l_bd + 2) = 11);
  BEGIN l_n := NOONA_HSP_PKG.check_in(l_r1); ok('no early check-in', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('no early check-in', 'NOONA-HSP-024', SQLERRM); END;

  -- دخول سريع مع دفعة
  l_st := NOONA_HSP_PKG.walk_in('{"property":' || l_prop || ',"guest_name":"ضيف مباشر ' || l_sfx || '","phone":"0559998887","room_type":'
          || l_rt || ',"rate_plan":' || l_plan || ',"nights":2,"pay":500,"pay_method":"CASH"}');
  l_rB := room_of(l_st);
  ok('walk-in checked in', l_st IS NOT NULL AND hk(l_rB) LIKE '%OCCUPIED%', hk(l_rB));
  ok('walk-in got another room', l_rB <> l_room);
  l_fol := NOONA_HSP_PKG.folio_of_stay(l_st);
  ok('walk-in payment on folio', NOONA_HSP_PKG.folio_balance(l_fol) = -500);
  l_n := NOONA_HSP_PKG.post_charge(l_fol, 'LAUNDRY', 'غسيل وكي', 100);
  ok('service charge with VAT', NOONA_HSP_PKG.folio_balance(l_fol) = -385, NOONA_HSP_PKG.folio_balance(l_fol));
  l_j := ev('HSP_FOLIO_LINE', l_n);
  ok('service entry: Cr services 4111 + VAT 2104', jl(l_j, '4111', 'C') = 100 AND jl(l_j, '2104', 'C') = 15 AND balanced(l_j));
  l_c := NOONA_HSP_PKG.rack_json(l_prop);
  l_n := JSON_ARRAY_T.parse(JSON_QUERY(l_c, '$.rooms')).get_size;
  ok('room rack JSON lists 12 rooms', l_n = 12, l_n);
  ok('rack shows occupied room', INSTR(l_c, '"fd":"OCCUPIED"') > 0);
  l_c := NOONA_HSP_PKG.chart_json(l_prop, l_bd, 14);
  ok('reservation chart JSON valid', JSON_OBJECT_T.parse(l_c).get_array('blocks').get_size >= 4);
  l_c := NOONA_HSP_PKG.stay_json(l_st);
  ok('stay JSON with folio lines', JSON_OBJECT_T.parse(l_c).get_array('lines').get_size = 3);

  -- التدقيق الليلي
  l_aud := NOONA_HSP_PKG.night_audit(l_prop);
  ok('night audit posts room night', NOONA_HSP_PKG.folio_balance(l_fol) = -385 + 517.5, NOONA_HSP_PKG.folio_balance(l_fol));
  l_j := ev('HSP_NIGHT_AUDIT', l_aud);
  ok('audit entry: Cr room revenue 4110 = 450', jl(l_j, '4110', 'C') = 450 AND jl(l_j, '2104', 'C') = 67.5 AND balanced(l_j));
  SELECT occupancy_pct INTO l_n FROM hsp_night_audit WHERE id = l_aud;
  ok('occupancy recorded (1/12)', l_n = 8.33, l_n);
  l_bd := NOONA_HSP_PKG.business_date(l_prop);
  ok('business date advanced', l_bd = l_bd0 + 1, d(l_bd));
  ok('occupied room needs stayover cleaning', hk(l_rB) LIKE 'DIRTY%', hk(l_rB));
  BEGIN l_n := NOONA_HSP_PKG.night_audit(l_prop); ok('cannot audit a day not yet ended', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('cannot audit a day not yet ended', 'NOONA-HSP-070', SQLERRM); END;

  -- التمديد والتعارض
  NOONA_HSP_PKG.change_departure(l_st, l_bd0 + 3);
  SELECT COUNT(*) INTO l_n FROM hsp_room_block WHERE stay_id = l_st;
  ok('stay extended one night', l_n = 3, l_n);
  l_r3 := NOONA_HSP_PKG.create_reservation('{"property":' || l_prop || ',"guest_name":"حجز لاحق","room":' || l_rB || ','
          || '"arrival":"' || d(l_bd0 + 3) || '","departure":"' || d(l_bd0 + 5) || '"}');
  BEGIN NOONA_HSP_PKG.change_departure(l_st, l_bd0 + 4); ok('extension blocked by next reservation', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('extension blocked by next reservation', 'NOONA-HSP-010', SQLERRM); END;

  -- نقل الغرفة
  SELECT MIN(r.id) INTO l_n FROM hsp_room r WHERE r.property_id = l_prop AND r.id NOT IN (l_room, l_rB)
     AND NOONA_HSP_PKG.is_free(r.id, l_bd, l_bd0 + 3) = 'Y';
  l_st2 := NOONA_HSP_PKG.move_room(l_st, l_n, 'تعطل التكييف');
  ok('room move creates new stay', l_st2 <> l_st AND room_of(l_st2) = l_n);
  ok('old room vacant and dirty', hk(l_rB) = 'DIRTY/VACANT/ACTIVE', hk(l_rB));
  ok('folio follows the guest', NOONA_HSP_PKG.folio_of_stay(l_st2) = l_fol);
  SELECT COUNT(*) INTO l_n FROM hsp_housekeeping_task WHERE room_id = l_rB AND status_code = 'PENDING';
  ok('cleaning task for old room', l_n >= 1, l_n);
  NOONA_HSP_PKG.set_hk_status(l_rB, 'CLEAN');
  ok('housekeeping marks room clean', hk(l_rB) LIKE 'CLEAN%');

  -- دخول الحجز المؤكد ثم المغادرة بحساب الشركة (استخدام نهاري)
  l_st1 := NOONA_HSP_PKG.check_in(l_r1);
  ok('reserved guest checked in', l_st1 IS NOT NULL);
  l_cmp := NOONA_PTY_PKG.create_party('ORGANIZATION', 'شركة السفر الأولى ' || l_sfx, 'CUSTOMER');
  BEGIN l_n := NOONA_HSP_PKG.check_out(l_st2); ok('balance must be settled before check-out', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('balance must be settled before check-out', 'NOONA-HSP-050', SQLERRM); END;
  l_n := NOONA_HSP_PKG.post_payment(l_fol, NOONA_HSP_PKG.folio_balance(l_fol), 'CARD', NULL, NULL, 'POS-8812');
  l_n := NOONA_HSP_PKG.check_out(l_st2);
  SELECT status_code INTO l_s FROM hsp_folio WHERE id = l_fol;
  ok('walk-in checked out, folio settled', l_s = 'SETTLED', l_s);
  ok('departed room dirty', hk(room_of(l_st2)) LIKE 'DIRTY/VACANT%', hk(room_of(l_st2)));
  l_fol := NOONA_HSP_PKG.folio_of_stay(l_st1);
  l_n := NOONA_HSP_PKG.check_out(l_st1, l_cmp);
  SELECT status_code, balance INTO l_s, l_dr FROM hsp_folio WHERE id = l_fol;
  ok('day use charged one night and transferred to company', l_s = 'TRANSFERRED' AND l_dr = 0, l_s);
  SELECT COUNT(*) INTO l_n FROM hsp_folio_line WHERE folio_id = l_fol AND line_type = 'ROOM_CHARGE';
  ok('one room night charged at check-out', l_n = 1, l_n);
  l_j := ev('HSP_FOLIO', l_fol);
  ok('city ledger entry: Dr 1113 with company', jl(l_j, '1113', 'D') = 217.5 AND balanced(l_j), jl(l_j, '1113', 'D'));
  ok('folio prints', DBMS_LOB.GETLENGTH(NOONA_HSP_PKG.folio_html(l_fol)) > 500);

  -- إلغاء وعدم حضور
  NOONA_HSP_PKG.cancel_reservation(l_r3, 'تغيرت خطة السفر');
  SELECT COUNT(*) INTO l_n FROM hsp_room_block b JOIN hsp_reservation_room rr ON rr.id = b.reservation_room_id WHERE rr.reservation_id = l_r3;
  ok('cancellation releases nights', l_n = 0, l_n);
  l_r4 := NOONA_HSP_PKG.create_reservation('{"property":' || l_prop || ',"guest_name":"لن يحضر","room_type":' || l_rt || ','
          || '"arrival":"' || d(l_bd) || '","departure":"' || d(l_bd + 1) || '"}');
  NOONA_HSP_PKG.mark_no_show(l_r4);
  SELECT status_code INTO l_s FROM hsp_reservation WHERE id = l_r4;
  ok('no-show recorded', l_s = 'NO_SHOW', l_s);

  -- الصيانة: بلاغ من الاستقبال يوقف الغرفة
  SELECT MIN(r.id) INTO l_rD FROM hsp_room r WHERE r.property_id = l_prop AND r.status_code = 'ACTIVE'
     AND NOT EXISTS (SELECT 1 FROM hsp_stay s WHERE s.room_id = r.id AND s.status_code = 'IN_HOUSE')
     AND NOONA_HSP_PKG.is_free(r.id, l_bd, l_bd + 1) = 'Y';
  SELECT id INTO l_cat FROM mnt_service_category WHERE code = 'HVAC';
  BEGIN l_n := NOONA_MNT_PKG.create_request('{"category":' || l_cat || ',"description":"x"}'); ok('request needs a location', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('request needs a location', 'NOONA-MNT-013', SQLERRM); END;
  l_req := NOONA_MNT_PKG.create_request('{"category":' || l_cat || ',"title":"المكيف لا يبرد","description":"صوت عال وتسريب ماء",'
           || '"channel":"FRONT_DESK","room":' || l_rD || ',"room_ooo":"Y","priority":"URGENT"}');
  SELECT status_code, property_id INTO l_s, l_n FROM mnt_request WHERE id = l_req;
  ok('request created and linked to the property', l_s = 'NEW' AND l_n = l_prop);
  ok('room out of order until repaired', hk(l_rD) LIKE '%OUT_OF_ORDER', hk(l_rD));
  ok('out-of-order room not offered', NOONA_HSP_PKG.free_room(l_prop, l_rt, l_bd, l_bd + 1) <> l_rD);
  SELECT CAST(due_at AS DATE) - CAST(created_at AS DATE) INTO l_dr FROM mnt_request WHERE id = l_req;
  ok('urgent SLA is 4 hours', ROUND(l_dr * 24) = 4, l_dr * 24);
  SELECT MIN(id) INTO l_team FROM mnt_team WHERE company_id = NOONA_MNT_PKG.company;
  l_tech := NOONA_MNT_PKG.add_technician(l_team, NULL, 'فني تكييف ' || l_sfx, 'تكييف مركزي وسبليت', 60);
  NOONA_MNT_PKG.assign(l_req, l_team, l_tech);
  ok('assignment creates work order', NOONA_MNT_PKG.work_order_of(l_req) IS NOT NULL AND NOONA_MNT_PKG.request_status(l_req) = 'ASSIGNED');
  NOONA_MNT_PKG.start_work(l_req);
  BEGIN NOONA_MNT_PKG.complete(l_req, NULL); ok('completion needs notes', FALSE);
  EXCEPTION WHEN OTHERS THEN expect('completion needs notes', 'NOONA-MNT-020', SQLERRM); END;
  NOONA_MNT_PKG.complete(l_req, 'تنظيف الفلاتر وتعبئة الغاز', 1.5, 120);
  SELECT actual_cost INTO l_dr FROM mnt_work_order WHERE id = NOONA_MNT_PKG.work_order_of(l_req);
  ok('work order cost = labor 90 + materials 120', l_dr = 210, l_dr);
  ok('room back in service for cleaning', hk(l_rD) = 'DIRTY/VACANT/ACTIVE', hk(l_rD));
  ok('SLA met', NOONA_MNT_PKG.sla_state(SYSTIMESTAMP + 1, SYSTIMESTAMP, 'COMPLETED') = 'MET');
  NOONA_MNT_PKG.close_request(l_req, 5);
  ok('request closed with rating', NOONA_MNT_PKG.request_status(l_req) = 'CLOSED');
  l_req := NOONA_MNT_PKG.create_request('{"category":' || l_cat || ',"description":"اختبار إلغاء","unit":' || l_unit || ',"channel":"PHONE",'
           || '"reporter_name":"مستأجر","reporter_phone":"0500000000"}');
  NOONA_MNT_PKG.cancel_request(l_req, 'بلاغ مكرر');
  ok('request cancelled', NOONA_MNT_PKG.request_status(l_req) = 'CANCELLED');

  -- التقارير
  ok('front desk summary renders', DBMS_LOB.GETLENGTH(NOONA_HSP_PKG.front_summary(l_prop)) > 500);
  ok('occupancy report renders', DBMS_LOB.GETLENGTH(NOONA_HSP_PKG.occupancy_html(l_prop, l_bd0 - 1, l_bd)) > 300);
  ok('maintenance board renders', DBMS_LOB.GETLENGTH(NOONA_MNT_PKG.board_html(l_prop, NULL, '#ID#')) > 300);
  ok('maintenance summary/performance render', DBMS_LOB.GETLENGTH(NOONA_MNT_PKG.summary_html) > 300
     AND DBMS_LOB.GETLENGTH(NOONA_MNT_PKG.performance_html(l_bd0 - 30, l_bd + 1)) > 200);
  ok('request card renders', DBMS_LOB.GETLENGTH(NOONA_MNT_PKG.request_html(l_req)) > 500);
  ok('registry summary and property card render', DBMS_LOB.GETLENGTH(NOONA_RE_PKG.registry_summary) > 300
     AND DBMS_LOB.GETLENGTH(NOONA_RE_PKG.property_card_html(l_prop)) > 300);

  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
  DBMS_OUTPUT.PUT_LINE('=== RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ABORT ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  ROLLBACK; NOONA_APEX_PKG.cleanup_request; RAISE;
END;
/
EXIT
