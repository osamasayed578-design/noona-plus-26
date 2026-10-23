-- =============================================================================
-- NOONA PLUS ERP | NOONA_MNT_PKG - الصيانة وإدارة المرافق
--   * التجهيز: فئات الخدمة (سباكة، كهرباء، تكييف، نجارة، دهانات، أجهزة، مصاعد، نظافة ومكافحة حشرات، شبكات، أقفال)
--     بأولوية وزمن إنجاز مستهدف، وفريق صيانة عام، والترقيم
--   * الفرق والفنيون (موظفون أو فنيو مقاول) وتكلفة الساعة
--   * البلاغ: من الاستقبال (غرفة نزيل) أو الهاتف أو البريد أو البوابة أو التطبيق أو المعاينة أو الصيانة الوقائية؛
--     الأولوية وموعد الإنجاز (SLA)، المبلغ واسمه وجواله، العقار/الوحدة/الغرفة/الأصل، وإيقاف الغرفة الفندقية حتى الإصلاح
--   * دورة العمل: جديد ← مسند (ينشئ أمر عمل ويشعر المشرف والفني) ← قيد التنفيذ ← معلق ← منجز (ساعات الفنيين
--     والمواد والتكلفة، وإعادة الغرفة للخدمة للتنظيف) ← مغلق بتقييم الرضا؛ أو مرفوض/ملغى
--   * لوحة البلاغات حسب الحالة، والمؤشرات (المفتوحة، المتأخرة، الطارئة، متوسط زمن الإنجاز، الرضا)
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_MNT_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION save_category(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_priority IN VARCHAR2, p_sla_hours IN NUMBER,
                         p_icon IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION save_team(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_specialty IN VARCHAR2, p_phone IN VARCHAR2,
                     p_supervisor_employee_id IN NUMBER) RETURN NUMBER;
  FUNCTION add_technician(p_team_id IN NUMBER, p_employee_id IN NUMBER, p_external_name IN VARCHAR2, p_skills IN VARCHAR2,
                          p_hourly_cost IN NUMBER) RETURN NUMBER;

  -- JSON: category, priority, title, description, channel, property, unit, room, asset, reporter_name, reporter_phone,
  --   requester_party, chargeable_to, room_ooo (Y يوقف الغرفة الشاغرة حتى الإصلاح), team, technician ؛ يعيد رقم البلاغ
  FUNCTION create_request(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE assign(p_request_id IN NUMBER, p_team_id IN NUMBER, p_technician_id IN NUMBER DEFAULT NULL);
  PROCEDURE start_work(p_request_id IN NUMBER);
  PROCEDURE hold(p_request_id IN NUMBER, p_reason IN VARCHAR2);
  -- يسجل ساعات الفني (اختياري) ويغلق أمر العمل ويعيد الغرفة للخدمة
  PROCEDURE complete(p_request_id IN NUMBER, p_notes IN VARCHAR2, p_hours IN NUMBER DEFAULT NULL, p_material_cost IN NUMBER DEFAULT NULL);
  PROCEDURE close_request(p_request_id IN NUMBER, p_satisfaction IN NUMBER DEFAULT NULL);
  PROCEDURE reopen(p_request_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE cancel_request(p_request_id IN NUMBER, p_reason IN VARCHAR2, p_reject IN VARCHAR2 DEFAULT 'N');
  FUNCTION add_labor(p_work_order_id IN NUMBER, p_technician_id IN NUMBER, p_date IN DATE, p_hours IN NUMBER) RETURN NUMBER;
  FUNCTION work_order_of(p_request_id IN NUMBER) RETURN NUMBER;

  FUNCTION priority_hours(p_priority IN VARCHAR2) RETURN NUMBER;
  FUNCTION priority_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION channel_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION technician_name(p_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION request_status(p_request_id IN NUMBER) RETURN VARCHAR2;
  -- ON_TIME / AT_RISK / OVERDUE / MET / MISSED
  FUNCTION sla_state(p_due IN TIMESTAMP WITH LOCAL TIME ZONE, p_resolved IN TIMESTAMP WITH LOCAL TIME ZONE, p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION sla_badge(p_due IN TIMESTAMP WITH LOCAL TIME ZONE, p_resolved IN TIMESTAMP WITH LOCAL TIME ZONE, p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION location_label(p_request_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION summary_html RETURN CLOB;
  -- لوحة البلاغات المفتوحة بالأعمدة؛ p_link يحتوي #ID#
  FUNCTION board_html(p_property_id IN NUMBER DEFAULT NULL, p_team_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION request_html(p_request_id IN NUMBER) RETURN CLOB;
  FUNCTION performance_html(p_from IN DATE, p_to IN DATE) RETURN CLOB;
END NOONA_MNT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_MNT_PKG AS

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION me RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')); END me;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN '' ELSE TO_CHAR(ROUND(p, 2), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fnum;
  FUNCTION fts(p TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD HH24:MI'); END fts;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  PROCEDURE ensure_sequence(p_type VARCHAR2, p_prefix VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
  END ensure_sequence;

  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    ensure_sequence(p_type, p_prefix);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;

  -- ================================================================ المسميات
  FUNCTION priority_hours(p_priority IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE p_priority WHEN 'EMERGENCY' THEN 2 WHEN 'URGENT' THEN 4 WHEN 'HIGH' THEN 24 WHEN 'LOW' THEN 168 ELSE 72 END;
  END priority_hours;

  FUNCTION priority_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'EMERGENCY' THEN 'طارئ' WHEN 'URGENT' THEN 'عاجل' WHEN 'HIGH' THEN 'مرتفع' WHEN 'NORMAL' THEN 'عادي'
      WHEN 'LOW' THEN 'منخفض' ELSE p_code END;
  END priority_label;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'NEW' THEN 'جديد' WHEN 'TRIAGED' THEN 'مصنف' WHEN 'ASSIGNED' THEN 'مسند' WHEN 'IN_PROGRESS' THEN 'قيد التنفيذ'
      WHEN 'ON_HOLD' THEN 'معلق' WHEN 'COMPLETED' THEN 'منجز' WHEN 'VERIFIED' THEN 'تم التحقق' WHEN 'CLOSED' THEN 'مغلق'
      WHEN 'CANCELLED' THEN 'ملغى' WHEN 'REJECTED' THEN 'مرفوض' WHEN 'SCHEDULED' THEN 'مجدول' WHEN 'PLANNED' THEN 'مخطط'
      ELSE p_code END;
  END status_label;

  FUNCTION channel_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'PORTAL' THEN 'بوابة الخدمة' WHEN 'PHONE' THEN 'هاتف' WHEN 'EMAIL' THEN 'بريد إلكتروني'
      WHEN 'FRONT_DESK' THEN 'الاستقبال' WHEN 'INSPECTION' THEN 'جولة معاينة' WHEN 'PREVENTIVE' THEN 'صيانة وقائية' WHEN 'APP' THEN 'تطبيق الجوال'
      ELSE p_code END;
  END channel_label;

  FUNCTION technician_name(p_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(NVL(p.display_name_ar, t.external_name)) INTO l FROM mnt_technician t LEFT JOIN hr_employee e ON e.id = t.employee_id
      LEFT JOIN pty_party p ON p.id = e.person_party_id WHERE t.id = p_id;
    RETURN l;
  END technician_name;

  FUNCTION request_status(p_request_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM mnt_request WHERE id = p_request_id AND company_id = company;
    RETURN l;
  END request_status;

  FUNCTION sla_state(p_due IN TIMESTAMP WITH LOCAL TIME ZONE, p_resolved IN TIMESTAMP WITH LOCAL TIME ZONE, p_status IN VARCHAR2) RETURN VARCHAR2 IS
    l_left NUMBER;
  BEGIN
    IF p_due IS NULL OR p_status IN ('CANCELLED', 'REJECTED') THEN RETURN NULL; END IF;
    IF p_resolved IS NOT NULL THEN
      RETURN CASE WHEN p_resolved <= p_due THEN 'MET' ELSE 'MISSED' END;
    END IF;
    l_left := (CAST(p_due AS DATE) - CAST(SYSTIMESTAMP AS DATE)) * 24;
    RETURN CASE WHEN l_left < 0 THEN 'OVERDUE' WHEN l_left < 2 THEN 'AT_RISK' ELSE 'ON_TIME' END;
  END sla_state;

  FUNCTION sla_badge(p_due IN TIMESTAMP WITH LOCAL TIME ZONE, p_resolved IN TIMESTAMP WITH LOCAL TIME ZONE, p_status IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(20) := sla_state(p_due, p_resolved, p_status);
  BEGIN
    RETURN CASE l WHEN 'OVERDUE' THEN '<span class="nn-badge is-danger">متأخر</span>' WHEN 'AT_RISK' THEN '<span class="nn-badge is-warning">قارب الموعد</span>'
      WHEN 'ON_TIME' THEN '<span class="nn-badge is-info">في الوقت</span>' WHEN 'MET' THEN '<span class="nn-badge is-success">أنجز في الموعد</span>'
      WHEN 'MISSED' THEN '<span class="nn-badge is-danger">أنجز متأخراً</span>' END;
  END sla_badge;

  FUNCTION location_label(p_request_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(600);
  BEGIN
    SELECT MAX(TRIM(BOTH ' ' FROM p.name_ar || CASE WHEN hr.room_no IS NOT NULL THEN ' · غرفة ' || hr.room_no
                         WHEN u.code IS NOT NULL THEN ' · وحدة ' || u.code END
                   || CASE WHEN a.asset_no IS NOT NULL THEN ' · ' || a.asset_no || ' ' || a.name_ar END)) INTO l
      FROM mnt_request r LEFT JOIN re_property p ON p.id = r.property_id LEFT JOIN re_unit u ON u.id = r.unit_id
      LEFT JOIN hsp_room hr ON hr.id = r.room_id LEFT JOIN fa_asset a ON a.id = r.asset_id
     WHERE r.id = p_request_id;
    RETURN l;
  END location_label;

  -- ================================================================ التجهيز
  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    guard('MNT_TEAM.CREATE');
    FOR c IN (SELECT 'PLUMBING' code, 'سباكة وتسربات مياه' nm, 'HIGH' pr, 24 h, 'fa-tint' ic FROM dual
              UNION ALL SELECT 'ELECTRICAL', 'كهرباء وإنارة', 'HIGH', 24, 'fa-bolt' FROM dual
              UNION ALL SELECT 'HVAC', 'تكييف وتبريد', 'URGENT', 8, 'fa-snowflake-o' FROM dual
              UNION ALL SELECT 'CARPENTRY', 'نجارة وأبواب وأقفال', 'NORMAL', 48, 'fa-key' FROM dual
              UNION ALL SELECT 'PAINTING', 'دهانات وتشطيبات', 'LOW', 120, 'fa-paint-brush' FROM dual
              UNION ALL SELECT 'APPLIANCES', 'أجهزة منزلية وتلفزيون', 'NORMAL', 48, 'fa-television' FROM dual
              UNION ALL SELECT 'ELEVATOR', 'مصاعد', 'URGENT', 4, 'fa-arrows-v' FROM dual
              UNION ALL SELECT 'CLEANING', 'نظافة ومكافحة حشرات', 'NORMAL', 24, 'fa-bug' FROM dual
              UNION ALL SELECT 'NETWORK', 'إنترنت وشبكات واتصالات', 'NORMAL', 24, 'fa-wifi' FROM dual
              UNION ALL SELECT 'SAFETY', 'سلامة وإنذار حريق', 'EMERGENCY', 2, 'fa-fire-extinguisher' FROM dual
              UNION ALL SELECT 'GENERAL', 'أعمال عامة أخرى', 'NORMAL', 72, 'fa-wrench' FROM dual) LOOP
      INSERT INTO mnt_service_category (code, name_ar, default_priority, sla_hours, icon, is_active)
      SELECT c.code, c.nm, c.pr, c.h, c.ic, 'Y' FROM dual WHERE NOT EXISTS (SELECT 1 FROM mnt_service_category WHERE code = c.code);
      l_n := l_n + SQL%ROWCOUNT;
    END LOOP;
    INSERT INTO mnt_team (company_id, code, name_ar, specialty, is_active)
    SELECT company, 'GEN', 'فريق الصيانة العامة', 'سباكة، كهرباء، تكييف، نجارة', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM mnt_team WHERE company_id = company);
    l_n := l_n + SQL%ROWCOUNT;
    ensure_sequence('MNT_REQUEST', 'MR-');
    ensure_sequence('MNT_WORK_ORDER', 'WO-');
    NOONA_AUDIT_PKG.log_event('CONFIG', 'MNT_TEAM', NULL, 'QUICK_SETUP', 'SUCCESS');
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l_c NUMBER;
    l_t NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_c FROM mnt_service_category WHERE is_active = 'Y';
    SELECT COUNT(*) INTO l_t FROM mnt_team WHERE company_id = company AND is_active = 'Y';
    RETURN CASE WHEN l_c > 0 AND l_t > 0 THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION save_category(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_priority IN VARCHAR2, p_sla_hours IN NUMBER,
                         p_icon IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_id NUMBER := p_id;
  BEGIN
    guard(CASE WHEN p_id IS NULL THEN 'MNT_SERVICE_CATEGORY.CREATE' ELSE 'MNT_SERVICE_CATEGORY.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-MNT-001', 'الرمز والاسم مطلوبان', 'Code and name required');
    IF l_id IS NULL THEN
      INSERT INTO mnt_service_category (code, name_ar, default_priority, sla_hours, icon, is_active)
      VALUES (UPPER(TRIM(p_code)), TRIM(p_name_ar), NVL(p_priority, 'NORMAL'), p_sla_hours, p_icon, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE mnt_service_category SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), default_priority = NVL(p_priority, 'NORMAL'),
             sla_hours = p_sla_hours, icon = NVL(p_icon, icon)
       WHERE id = l_id;
    END IF;
    RETURN l_id;
  END save_category;

  FUNCTION save_team(p_id IN NUMBER, p_code IN VARCHAR2, p_name_ar IN VARCHAR2, p_specialty IN VARCHAR2, p_phone IN VARCHAR2,
                     p_supervisor_employee_id IN NUMBER) RETURN NUMBER IS
    l_id NUMBER := p_id;
  BEGIN
    guard(CASE WHEN p_id IS NULL THEN 'MNT_TEAM.CREATE' ELSE 'MNT_TEAM.UPDATE' END);
    NOONA_CORE_PKG.assert(TRIM(p_code) IS NOT NULL AND TRIM(p_name_ar) IS NOT NULL, 'NOONA-MNT-001', 'الرمز والاسم مطلوبان', 'Code and name required');
    IF l_id IS NULL THEN
      INSERT INTO mnt_team (company_id, code, name_ar, specialty, phone, supervisor_employee_id, is_active)
      VALUES (company, UPPER(TRIM(p_code)), TRIM(p_name_ar), p_specialty, p_phone, p_supervisor_employee_id, 'Y')
      RETURNING id INTO l_id;
    ELSE
      UPDATE mnt_team SET code = UPPER(TRIM(p_code)), name_ar = TRIM(p_name_ar), specialty = p_specialty, phone = p_phone,
             supervisor_employee_id = p_supervisor_employee_id
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_team;

  FUNCTION add_technician(p_team_id IN NUMBER, p_employee_id IN NUMBER, p_external_name IN VARCHAR2, p_skills IN VARCHAR2,
                          p_hourly_cost IN NUMBER) RETURN NUMBER IS
    l_id NUMBER;
  BEGIN
    guard('MNT_TECHNICIAN.CREATE');
    NOONA_CORE_PKG.assert(p_employee_id IS NOT NULL OR TRIM(p_external_name) IS NOT NULL, 'NOONA-MNT-002',
      'اختر الموظف أو أدخل اسم فني المقاول', 'Employee or external name required');
    INSERT INTO mnt_technician (company_id, team_id, employee_id, external_name, skills, hourly_cost, is_active)
    VALUES (company, p_team_id, p_employee_id, TRIM(p_external_name), p_skills, p_hourly_cost, 'Y')
    RETURNING id INTO l_id;
    RETURN l_id;
  END add_technician;

  -- ================================================================ الإشعارات
  PROCEDURE notify_employee(p_employee NUMBER, p_request NUMBER, p_title VARCHAR2, p_due TIMESTAMP WITH LOCAL TIME ZONE) IS
    l_evt NUMBER;
  BEGIN
    IF p_employee IS NULL THEN RETURN; END IF;
    SELECT MIN(id) INTO l_evt FROM ntf_event_type WHERE code = 'MNT_ASSIGNED';
    IF l_evt IS NULL THEN RETURN; END IF;
    FOR m IN (SELECT id FROM sec_user_membership WHERE employee_id = p_employee AND status_code = 'ACTIVE') LOOP
      BEGIN
        INSERT INTO ntf_notification (event_type_id, membership_id, source_entity_type, source_entity_id, title, link_url,
                                      idempotency_key, due_at, correlation_id)
        VALUES (l_evt, m.id, 'MNT_REQUEST', p_request, SUBSTR(p_title, 1, 500), 'f?p=NOONA_PRJ:MAINT-REQUEST:::NO::P71_ID:' || p_request,
                'MNT:' || p_request || ':' || m.id || ':' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3'), p_due, NOONA_CTX_PKG.correlation_id);
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
      END;
    END LOOP;
  END notify_employee;

  -- ================================================================ البلاغات
  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jnum(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
    l VARCHAR2(100) := js(p_o, p_k);
  BEGIN
    RETURN CASE WHEN l IS NOT NULL THEN TO_NUMBER(REPLACE(l, ',', ''), '999999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END jnum;

  FUNCTION req_row(p_id NUMBER) RETURN mnt_request%ROWTYPE IS
    l mnt_request%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM mnt_request WHERE id = p_id AND company_id = company FOR UPDATE;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-MNT-010', 'البلاغ غير موجود', 'Request not found');
  END req_row;

  FUNCTION work_order_of(p_request_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) INTO l FROM mnt_work_order WHERE request_id = p_request_id AND company_id = company AND status_code <> 'CANCELLED';
    RETURN l;
  END work_order_of;

  FUNCTION create_request(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_cat   NUMBER := jnum(l_o, 'category');
    l_pr    VARCHAR2(30) := js(l_o, 'priority');
    l_title VARCHAR2(200) := js(l_o, 'title');
    l_desc  VARCHAR2(4000) := js(l_o, 'description');
    l_chan  VARCHAR2(30) := NVL(js(l_o, 'channel'), 'PHONE');
    l_prop  NUMBER := jnum(l_o, 'property');
    l_unit  NUMBER := jnum(l_o, 'unit');
    l_room  NUMBER := jnum(l_o, 'room');
    l_asset NUMBER := jnum(l_o, 'asset');
    l_rname VARCHAR2(200) := js(l_o, 'reporter_name');
    l_rph   VARCHAR2(30) := js(l_o, 'reporter_phone');
    l_party NUMBER := jnum(l_o, 'requester_party');
    l_chg   VARCHAR2(30) := NVL(js(l_o, 'chargeable_to'), 'OWNER');
    l_ooo   VARCHAR2(1) := NVL(js(l_o, 'room_ooo'), 'N');
    l_team  NUMBER := jnum(l_o, 'team');
    l_tech  NUMBER := jnum(l_o, 'technician');
    l_hours NUMBER;
    l_catn  VARCHAR2(200);
    l_id    NUMBER;
    l_no    VARCHAR2(50);
    l_n     NUMBER;
    l_me    NUMBER := me;
    l_due   TIMESTAMP WITH LOCAL TIME ZONE;
  BEGIN
    guard('MNT_REQUEST.CREATE');
    NOONA_CORE_PKG.assert(l_cat IS NOT NULL, 'NOONA-MNT-011', 'حدد نوع العطل (الفئة)', 'Category required');
    NOONA_CORE_PKG.assert(l_desc IS NOT NULL OR l_title IS NOT NULL, 'NOONA-MNT-012', 'صف المشكلة', 'Description required');
    NOONA_CORE_PKG.assert(COALESCE(l_prop, l_unit, l_room, l_asset) IS NOT NULL, 'NOONA-MNT-013',
      'حدد موقع العطل: العقار أو الوحدة أو الغرفة أو الأصل', 'Location required');
    SELECT name_ar, NVL(l_pr, default_priority), sla_hours INTO l_catn, l_pr, l_hours FROM mnt_service_category WHERE id = l_cat;
    l_pr := NVL(l_pr, 'NORMAL');
    -- الأولوية الأعلى من افتراض الفئة تقصر الموعد
    l_hours := LEAST(NVL(l_hours, priority_hours(l_pr)), priority_hours(l_pr));
    IF l_room IS NOT NULL THEN
      SELECT property_id, NVL(l_unit, unit_id) INTO l_prop, l_unit FROM hsp_room WHERE id = l_room AND company_id = company;
    ELSIF l_unit IS NOT NULL AND l_prop IS NULL THEN
      SELECT property_id INTO l_prop FROM re_unit WHERE id = l_unit AND company_id = company;
    END IF;
    l_due := SYSTIMESTAMP + NUMTODSINTERVAL(l_hours, 'HOUR');
    l_no := next_no('MNT_REQUEST', 'MR-');
    INSERT INTO mnt_request (company_id, doc_no, doc_date, category_id, priority_code, requester_party_id, requester_member_id, channel_code,
                             property_id, unit_id, room_id, asset_id, description, due_at, chargeable_to, title, reporter_name, reporter_phone,
                             room_out_of_order, status_code)
    VALUES (company, l_no, TRUNC(SYSDATE), l_cat, l_pr, l_party, l_me, l_chan, l_prop, l_unit, l_room, l_asset,
            NVL(l_desc, l_title), l_due, l_chg, NVL(l_title, SUBSTR(l_catn || ': ' || l_desc, 1, 200)), l_rname, l_rph, 'N', 'NEW')
    RETURNING id INTO l_id;
    -- إيقاف الغرفة الفندقية الشاغرة حتى الإصلاح
    IF l_ooo = 'Y' AND l_room IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM hsp_stay WHERE room_id = l_room AND status_code = 'IN_HOUSE';
      IF l_n = 0 THEN
        NOONA_HSP_PKG.set_out_of_order(l_room, NULL, NULL, l_no || ' ' || NVL(l_title, l_catn), NULL);
        UPDATE mnt_request SET room_out_of_order = 'Y' WHERE id = l_id;
      END IF;
    END IF;
    IF l_unit IS NOT NULL AND l_pr IN ('EMERGENCY', 'URGENT') THEN
      NULL;  -- حالة الوحدة لا تتغير تلقائياً إلا بقرار الإيقاف
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MNT_REQUEST', l_id, 'CREATE', 'SUCCESS');
    IF l_team IS NOT NULL THEN
      assign(l_id, l_team, l_tech);
    END IF;
    RETURN l_id;
  END create_request;

  PROCEDURE assign(p_request_id IN NUMBER, p_team_id IN NUMBER, p_technician_id IN NUMBER DEFAULT NULL) IS
    l_r    mnt_request%ROWTYPE := req_row(p_request_id);
    l_t    mnt_team%ROWTYPE;
    l_wo   NUMBER;
    l_emp  NUMBER;
    l_no   VARCHAR2(50);
    l_unit NUMBER;
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('NEW', 'TRIAGED', 'ASSIGNED', 'ON_HOLD', 'IN_PROGRESS'), 'NOONA-MNT-014',
      'لا يسند بلاغ ' || status_label(l_r.status_code), 'Request cannot be assigned');
    SELECT * INTO l_t FROM mnt_team WHERE id = p_team_id AND company_id = company AND is_active = 'Y';
    IF p_technician_id IS NOT NULL THEN
      SELECT employee_id INTO l_emp FROM mnt_technician WHERE id = p_technician_id AND company_id = company;
    END IF;
    UPDATE mnt_request SET team_id = p_team_id, technician_id = p_technician_id,
           status_code = CASE WHEN status_code = 'IN_PROGRESS' THEN 'IN_PROGRESS' ELSE 'ASSIGNED' END,
           responded_at = NVL(responded_at, SYSTIMESTAMP)
     WHERE id = p_request_id;
    l_wo := work_order_of(p_request_id);
    IF l_wo IS NULL THEN
      l_no := next_no('MNT_WORK_ORDER', 'WO-');
      l_unit := l_r.unit_id;
      INSERT INTO mnt_work_order (company_id, doc_no, doc_date, request_id, wo_type, team_id, asset_id, unit_id, planned_start, planned_end,
                                  capitalize, status_code)
      VALUES (company, l_no, TRUNC(SYSDATE), p_request_id, CASE WHEN l_r.priority_code = 'EMERGENCY' THEN 'EMERGENCY' ELSE 'CORRECTIVE' END,
              p_team_id, l_r.asset_id, l_unit, SYSTIMESTAMP, l_r.due_at, 'N', 'SCHEDULED');
    ELSE
      UPDATE mnt_work_order SET team_id = p_team_id WHERE id = l_wo;
    END IF;
    notify_employee(l_t.supervisor_employee_id, p_request_id, 'بلاغ صيانة لفريقك: ' || l_r.doc_no || ' - ' || l_r.title, l_r.due_at);
    IF NVL(l_emp, -1) <> NVL(l_t.supervisor_employee_id, -1) THEN
      notify_employee(l_emp, p_request_id, 'بلاغ صيانة مسند إليك: ' || l_r.doc_no || ' - ' || l_r.title, l_r.due_at);
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MNT_REQUEST', p_request_id, 'ASSIGN', 'SUCCESS',
      p_new_values => '{"team":' || p_team_id || ',"technician":' || NVL(TO_CHAR(p_technician_id), 'null') || '}');
  END assign;

  PROCEDURE start_work(p_request_id IN NUMBER) IS
    l_r mnt_request%ROWTYPE := req_row(p_request_id);
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('ASSIGNED', 'ON_HOLD'), 'NOONA-MNT-015', 'أسند البلاغ لفريق أولاً', 'Assign the request first');
    UPDATE mnt_request SET status_code = 'IN_PROGRESS' WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'IN_PROGRESS', actual_start = NVL(actual_start, SYSTIMESTAMP)
     WHERE request_id = p_request_id AND status_code IN ('SCHEDULED', 'ON_HOLD', 'APPROVED', 'PLANNED');
  END start_work;

  PROCEDURE hold(p_request_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r mnt_request%ROWTYPE := req_row(p_request_id);
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('ASSIGNED', 'IN_PROGRESS'), 'NOONA-MNT-016', 'يعلق البلاغ المسند أو الجاري فقط', 'Cannot hold');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-MNT-017', 'سبب التعليق مطلوب (انتظار قطع غيار، موافقة...)', 'Reason required');
    UPDATE mnt_request SET status_code = 'ON_HOLD',
           resolution_notes = SUBSTR(resolution_notes || CASE WHEN resolution_notes IS NOT NULL THEN CHR(10) END || 'تعليق: ' || p_reason, 1, 2000)
     WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'ON_HOLD' WHERE request_id = p_request_id AND status_code IN ('SCHEDULED', 'IN_PROGRESS');
  END hold;

  FUNCTION add_labor(p_work_order_id IN NUMBER, p_technician_id IN NUMBER, p_date IN DATE, p_hours IN NUMBER) RETURN NUMBER IS
    l_id   NUMBER;
    l_cost NUMBER;
  BEGIN
    guard('MNT_WO_LABOR.CREATE');
    NOONA_CORE_PKG.assert(p_hours > 0 AND p_hours <= 24, 'NOONA-MNT-018', 'الساعات من 0 إلى 24', 'Hours 0-24');
    SELECT hourly_cost INTO l_cost FROM mnt_technician WHERE id = p_technician_id AND company_id = company;
    INSERT INTO mnt_wo_labor (company_id, work_order_id, technician_id, work_date, hours, cost_amount)
    VALUES (company, p_work_order_id, p_technician_id, NVL(p_date, TRUNC(SYSDATE)), p_hours, ROUND(NVL(l_cost, 0) * p_hours, 2))
    RETURNING id INTO l_id;
    UPDATE mnt_work_order SET actual_cost = NVL(actual_cost, 0) + ROUND(NVL(l_cost, 0) * p_hours, 2) WHERE id = p_work_order_id;
    RETURN l_id;
  END add_labor;

  PROCEDURE complete(p_request_id IN NUMBER, p_notes IN VARCHAR2, p_hours IN NUMBER DEFAULT NULL, p_material_cost IN NUMBER DEFAULT NULL) IS
    l_r  mnt_request%ROWTYPE := req_row(p_request_id);
    l_wo NUMBER;
    l_id NUMBER;
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('ASSIGNED', 'IN_PROGRESS', 'ON_HOLD'), 'NOONA-MNT-019',
      'لا ينجز بلاغ ' || status_label(l_r.status_code), 'Request cannot be completed');
    NOONA_CORE_PKG.assert(TRIM(p_notes) IS NOT NULL, 'NOONA-MNT-020', 'اكتب ما تم عمله', 'Resolution notes required');
    l_wo := work_order_of(p_request_id);
    IF NVL(p_hours, 0) > 0 THEN
      NOONA_CORE_PKG.assert(l_r.technician_id IS NOT NULL, 'NOONA-MNT-021', 'حدد الفني لتسجيل الساعات', 'Technician required for hours');
      l_id := add_labor(l_wo, l_r.technician_id, TRUNC(SYSDATE), p_hours);
    END IF;
    UPDATE mnt_request SET status_code = 'COMPLETED', resolved_at = SYSTIMESTAMP,
           resolution_notes = SUBSTR(resolution_notes || CASE WHEN resolution_notes IS NOT NULL THEN CHR(10) END || p_notes, 1, 2000)
     WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'COMPLETED', actual_start = NVL(actual_start, SYSTIMESTAMP), actual_end = SYSTIMESTAMP,
           actual_cost = NVL(actual_cost, 0) + NVL(p_material_cost, 0), completion_notes = SUBSTR(p_notes, 1, 4000)
     WHERE id = l_wo;
    IF l_r.room_out_of_order = 'Y' AND l_r.room_id IS NOT NULL THEN
      NOONA_HSP_PKG.return_to_service(l_r.room_id);
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MNT_REQUEST', p_request_id, 'COMPLETE', 'SUCCESS');
  END complete;

  PROCEDURE close_request(p_request_id IN NUMBER, p_satisfaction IN NUMBER DEFAULT NULL) IS
    l_r mnt_request%ROWTYPE := req_row(p_request_id);
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('COMPLETED', 'VERIFIED'), 'NOONA-MNT-022', 'يغلق البلاغ بعد إنجازه', 'Complete the request first');
    NOONA_CORE_PKG.assert(p_satisfaction IS NULL OR p_satisfaction BETWEEN 1 AND 5, 'NOONA-MNT-023', 'التقييم من 1 إلى 5', 'Rating 1-5');
    UPDATE mnt_request SET status_code = 'CLOSED', satisfaction_score = p_satisfaction WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'CLOSED' WHERE request_id = p_request_id AND status_code IN ('COMPLETED', 'VERIFIED');
  END close_request;

  PROCEDURE reopen(p_request_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_r mnt_request%ROWTYPE := req_row(p_request_id);
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code IN ('COMPLETED', 'VERIFIED', 'CLOSED'), 'NOONA-MNT-024', 'يعاد فتح البلاغ المنجز فقط', 'Only completed requests');
    UPDATE mnt_request SET status_code = CASE WHEN team_id IS NOT NULL THEN 'ASSIGNED' ELSE 'NEW' END, resolved_at = NULL,
           resolution_notes = SUBSTR(resolution_notes || CHR(10) || 'إعادة فتح: ' || p_reason, 1, 2000)
     WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'SCHEDULED', actual_end = NULL WHERE request_id = p_request_id AND status_code <> 'CANCELLED';
  END reopen;

  PROCEDURE cancel_request(p_request_id IN NUMBER, p_reason IN VARCHAR2, p_reject IN VARCHAR2 DEFAULT 'N') IS
    l_r mnt_request%ROWTYPE := req_row(p_request_id);
  BEGIN
    guard('MNT_REQUEST.UPDATE');
    NOONA_CORE_PKG.assert(l_r.status_code NOT IN ('COMPLETED', 'VERIFIED', 'CLOSED', 'CANCELLED', 'REJECTED'), 'NOONA-MNT-025',
      'لا يلغى بلاغ ' || status_label(l_r.status_code), 'Request cannot be cancelled');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-MNT-026', 'السبب مطلوب', 'Reason required');
    UPDATE mnt_request SET status_code = CASE WHEN p_reject = 'Y' THEN 'REJECTED' ELSE 'CANCELLED' END,
           resolution_notes = SUBSTR(resolution_notes || CASE WHEN resolution_notes IS NOT NULL THEN CHR(10) END
                                     || CASE WHEN p_reject = 'Y' THEN 'رفض: ' ELSE 'إلغاء: ' END || p_reason, 1, 2000)
     WHERE id = p_request_id;
    UPDATE mnt_work_order SET status_code = 'CANCELLED' WHERE request_id = p_request_id AND status_code NOT IN ('COMPLETED', 'CLOSED');
    IF l_r.room_out_of_order = 'Y' AND l_r.room_id IS NOT NULL THEN
      NOONA_HSP_PKG.return_to_service(l_r.room_id);
    END IF;
  END cancel_request;

  -- ================================================================ العرض
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_open NUMBER; l_late NUMBER; l_emg NUMBER; l_new NUMBER; l_done NUMBER; l_avg NUMBER; l_sat NUMBER;
  BEGIN
    SELECT COUNT(CASE WHEN status_code IN ('NEW', 'TRIAGED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('NEW', 'TRIAGED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD') AND due_at < SYSTIMESTAMP THEN 1 END),
           COUNT(CASE WHEN status_code IN ('NEW', 'TRIAGED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD') AND priority_code IN ('EMERGENCY', 'URGENT') THEN 1 END),
           COUNT(CASE WHEN status_code = 'NEW' THEN 1 END),
           COUNT(CASE WHEN resolved_at >= TRUNC(SYSDATE) THEN 1 END),
           ROUND(AVG(CASE WHEN resolved_at >= SYSTIMESTAMP - 30 THEN (CAST(resolved_at AS DATE) - CAST(created_at AS DATE)) * 24 END), 1),
           ROUND(AVG(CASE WHEN created_at >= SYSTIMESTAMP - 90 THEN satisfaction_score END), 1)
      INTO l_open, l_late, l_emg, l_new, l_done, l_avg, l_sat
      FROM mnt_request WHERE company_id = company;
    RETURN '<div class="nn-kpis">'
        || kpi('بلاغات مفتوحة', l_open, 'fa-wrench')
        || kpi('جديدة بانتظار الإسناد', l_new, 'fa-inbox', CASE WHEN l_new > 0 THEN 'is-warning' ELSE 'is-info' END)
        || kpi('متأخرة عن الموعد', l_late, 'fa-clock-o', CASE WHEN l_late > 0 THEN 'is-danger' ELSE 'is-success' END)
        || kpi('طارئة وعاجلة', l_emg, 'fa-exclamation-triangle', CASE WHEN l_emg > 0 THEN 'is-danger' ELSE 'is-info' END)
        || kpi('أنجزت اليوم', l_done, 'fa-check', 'is-success')
        || kpi('متوسط زمن الإنجاز (ساعة، 30 يوماً)', NVL(TO_CHAR(l_avg), '-'), 'fa-hourglass-half')
        || kpi('رضا المبلغين (من 5)', NVL(TO_CHAR(l_sat), '-'), 'fa-star', 'is-info') || '</div>';
  END summary_html;

  FUNCTION board_html(p_property_id IN NUMBER DEFAULT NULL, p_team_id IN NUMBER DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_out CLOB := '<div class="nn-mnt-board">';
    l_n   PLS_INTEGER;
  BEGIN
    FOR c IN (SELECT 'NEW' st, 'جديد' nm, 1 o FROM dual UNION ALL SELECT 'ASSIGNED', 'مسند', 2 FROM dual
              UNION ALL SELECT 'IN_PROGRESS', 'قيد التنفيذ', 3 FROM dual UNION ALL SELECT 'ON_HOLD', 'معلق', 4 FROM dual
              UNION ALL SELECT 'COMPLETED', 'منجز بانتظار الإغلاق', 5 FROM dual ORDER BY 3) LOOP
      l_n := 0;
      l_out := l_out || '<div class="nn-mnt-col nn-mnt-' || LOWER(c.st) || '"><div class="nn-mnt-colh">' || c.nm || '</div>';
      FOR r IN (SELECT r.id, r.doc_no, r.title, r.priority_code, r.due_at, r.resolved_at, r.status_code, r.channel_code, c2.icon,
                       t.name_ar team, r.technician_id, r.room_out_of_order
                  FROM mnt_request r JOIN mnt_service_category c2 ON c2.id = r.category_id LEFT JOIN mnt_team t ON t.id = r.team_id
                 WHERE r.company_id = company AND (r.status_code = c.st OR (c.st = 'NEW' AND r.status_code = 'TRIAGED'))
                   AND (p_property_id IS NULL OR r.property_id = p_property_id) AND (p_team_id IS NULL OR r.team_id = p_team_id)
                 ORDER BY CASE r.priority_code WHEN 'EMERGENCY' THEN 1 WHEN 'URGENT' THEN 2 WHEN 'HIGH' THEN 3 WHEN 'NORMAL' THEN 4 ELSE 5 END,
                          r.due_at FETCH FIRST 60 ROWS ONLY) LOOP
        l_out := l_out || CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', r.id) || '"' ELSE '<div' END
              || ' class="nn-mnt-card is-' || LOWER(r.priority_code) || '"><div class="nn-mnt-top"><span class="fa ' || NVL(r.icon, 'fa-wrench')
              || '"></span><b>' || esc(r.doc_no) || '</b><span class="nn-mnt-pr">' || priority_label(r.priority_code) || '</span></div><div class="nn-mnt-t">'
              || esc(r.title) || '</div><div class="nn-mnt-loc"><span class="fa fa-map-marker"></span> ' || esc(location_label(r.id))
              || CASE WHEN r.room_out_of_order = 'Y' THEN ' · <span class="nn-badge is-danger">الغرفة موقوفة</span>' END
              || '</div><div class="nn-mnt-meta">' || channel_label(r.channel_code)
              || CASE WHEN r.team IS NOT NULL THEN ' · ' || esc(r.team) END
              || CASE WHEN r.technician_id IS NOT NULL THEN ' · ' || esc(technician_name(r.technician_id)) END
              || ' ' || sla_badge(r.due_at, r.resolved_at, r.status_code) || '</div>'
              || CASE WHEN p_link IS NOT NULL THEN '</a>' ELSE '</div>' END;
        l_n := l_n + 1;
      END LOOP;
      IF l_n = 0 THEN l_out := l_out || '<div class="nn-mnt-empty">لا يوجد</div>'; END IF;
      l_out := l_out || '</div>';
    END LOOP;
    RETURN l_out || '</div>';
  END board_html;

  FUNCTION request_html(p_request_id IN NUMBER) RETURN CLOB IS
    l_r   mnt_request%ROWTYPE;
    l_cat VARCHAR2(200);
    l_tm  VARCHAR2(200);
    l_wo  mnt_work_order%ROWTYPE;
    l_out CLOB;
    l_by  VARCHAR2(200);
  BEGIN
    SELECT * INTO l_r FROM mnt_request WHERE id = p_request_id AND company_id = company;
    SELECT name_ar INTO l_cat FROM mnt_service_category WHERE id = l_r.category_id;
    SELECT MAX(name_ar) INTO l_tm FROM mnt_team WHERE id = l_r.team_id;
    SELECT MAX(u.display_name) INTO l_by FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE m.id = l_r.requester_member_id;
    BEGIN
      SELECT * INTO l_wo FROM mnt_work_order WHERE id = work_order_of(p_request_id);
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    l_out := '<div class="nn-mnt-head is-' || LOWER(l_r.priority_code) || '"><div><b>' || esc(l_r.doc_no) || ' · ' || esc(l_r.title)
          || '</b><small>' || esc(l_cat) || ' · ' || priority_label(l_r.priority_code) || ' · ' || channel_label(l_r.channel_code) || '</small></div>'
          || '<div><span class="nn-badge is-info">' || status_label(l_r.status_code) || '</span> ' || sla_badge(l_r.due_at, l_r.resolved_at, l_r.status_code)
          || '</div></div><div class="nn-fa-card"><table class="nn-rpt"><tbody>'
          || '<tr><td class="nn-rpt-text">الموقع</td><td class="nn-rpt-text">' || esc(location_label(p_request_id))
          || CASE WHEN l_r.room_out_of_order = 'Y' THEN ' <span class="nn-badge is-danger">الغرفة موقوفة حتى الإصلاح</span>' END || '</td></tr>'
          || '<tr><td class="nn-rpt-text">المبلغ</td><td class="nn-rpt-text">' || esc(NVL(l_r.reporter_name, NVL(NOONA_HSP_PKG.guest_name(l_r.requester_party_id), l_by)))
          || CASE WHEN l_r.reporter_phone IS NOT NULL THEN ' · ' || esc(l_r.reporter_phone) END || '</td></tr>'
          || '<tr><td class="nn-rpt-text">الوصف</td><td class="nn-rpt-text">' || REPLACE(esc(l_r.description), CHR(10), '<br>') || '</td></tr>'
          || '<tr><td class="nn-rpt-text">يحمل على</td><td class="nn-rpt-text">' || CASE l_r.chargeable_to WHEN 'OWNER' THEN 'المالك/المنشأة'
             WHEN 'LESSEE' THEN 'المستأجر/النزيل' WHEN 'WARRANTY' THEN 'الضمان' WHEN 'CONTRACTOR' THEN 'المقاول' WHEN 'INSURANCE' THEN 'التأمين' END || '</td></tr>'
          || '</tbody></table><table class="nn-rpt"><tbody>'
          || '<tr><td class="nn-rpt-text">وقت البلاغ</td><td>' || fts(l_r.created_at) || '</td></tr>'
          || '<tr><td class="nn-rpt-text">الموعد المستهدف</td><td>' || fts(l_r.due_at) || '</td></tr>'
          || '<tr><td class="nn-rpt-text">الإسناد</td><td class="nn-rpt-text">' || esc(l_tm) || CASE WHEN l_r.technician_id IS NOT NULL
             THEN ' · ' || esc(technician_name(l_r.technician_id)) END || CASE WHEN l_r.responded_at IS NOT NULL THEN ' (' || fts(l_r.responded_at) || ')' END || '</td></tr>'
          || '<tr><td class="nn-rpt-text">أمر العمل</td><td class="nn-rpt-text">' || esc(l_wo.doc_no) || CASE WHEN l_wo.id IS NOT NULL THEN ' · '
             || status_label(l_wo.status_code) || ' · التكلفة ' || fnum(NVL(l_wo.actual_cost, 0)) END || '</td></tr>'
          || '<tr><td class="nn-rpt-text">الإنجاز</td><td>' || fts(l_r.resolved_at) || CASE WHEN l_r.resolved_at IS NOT NULL THEN ' (' ||
             ROUND((CAST(l_r.resolved_at AS DATE) - CAST(l_r.created_at AS DATE)) * 24, 1) || ' ساعة)' END || '</td></tr>'
          || CASE WHEN l_r.satisfaction_score IS NOT NULL THEN '<tr><td class="nn-rpt-text">التقييم</td><td>' || RPAD('★', l_r.satisfaction_score, '★') || '</td></tr>' END
          || '</tbody></table></div>'
          || CASE WHEN l_r.resolution_notes IS NOT NULL THEN '<div class="nn-mnt-notes"><b>ما تم عمله والملاحظات</b><p>'
             || REPLACE(esc(l_r.resolution_notes), CHR(10), '<br>') || '</p></div>' END;
    IF l_wo.id IS NOT NULL THEN
      l_out := l_out || '<table class="nn-rpt"><thead><tr><th>الفني</th><th>التاريخ</th><th>الساعات</th><th>التكلفة</th></tr></thead><tbody>';
      FOR l IN (SELECT technician_id, work_date, hours, cost_amount FROM mnt_wo_labor WHERE work_order_id = l_wo.id ORDER BY work_date, id) LOOP
        l_out := l_out || '<tr><td class="nn-rpt-text">' || esc(technician_name(l.technician_id)) || '</td><td>' || TO_CHAR(l.work_date, 'YYYY-MM-DD')
              || '</td><td>' || l.hours || '</td><td>' || fnum(l.cost_amount) || '</td></tr>';
      END LOOP;
      l_out := l_out || '</tbody></table>';
    END IF;
    RETURN l_out;
  END request_html;

  FUNCTION performance_html(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_out CLOB := '<div class="nn-rpt-wrap"><table class="nn-rpt"><thead><tr><th>الفئة</th><th>البلاغات</th><th>المنجزة</th><th>في الموعد</th>'
               || '<th>نسبة الالتزام</th><th>متوسط الإنجاز (ساعة)</th><th>المفتوحة</th><th>التكلفة</th><th>الرضا</th></tr></thead><tbody>';
    l_n PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT c.name_ar, COUNT(*) cnt, COUNT(r.resolved_at) done, COUNT(CASE WHEN r.resolved_at <= r.due_at THEN 1 END) met,
                     ROUND(AVG((CAST(r.resolved_at AS DATE) - CAST(r.created_at AS DATE)) * 24), 1) avg_h,
                     COUNT(CASE WHEN r.status_code IN ('NEW', 'TRIAGED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD') THEN 1 END) open_n,
                     SUM(w.actual_cost) cost, ROUND(AVG(r.satisfaction_score), 1) sat
                FROM mnt_request r JOIN mnt_service_category c ON c.id = r.category_id
                LEFT JOIN mnt_work_order w ON w.request_id = r.id AND w.status_code <> 'CANCELLED'
               WHERE r.company_id = company AND r.doc_date BETWEEN p_from AND p_to AND r.status_code NOT IN ('CANCELLED', 'REJECTED')
               GROUP BY c.name_ar ORDER BY COUNT(*) DESC) LOOP
      l_out := l_out || '<tr><td class="nn-rpt-text">' || esc(r.name_ar) || '</td><td>' || r.cnt || '</td><td>' || r.done || '</td><td>' || r.met
            || '</td><td>' || CASE WHEN r.done > 0 THEN ROUND(r.met * 100 / r.done) || '%' END || '</td><td>' || r.avg_h || '</td><td>' || r.open_n
            || '</td><td>' || fnum(r.cost) || '</td><td>' || r.sat || '</td></tr>';
      l_n := l_n + 1;
    END LOOP;
    IF l_n = 0 THEN RETURN '<div class="nn-empty">لا توجد بلاغات في الفترة</div>'; END IF;
    RETURN l_out || '</tbody></table></div>';
  END performance_html;

END NOONA_MNT_PKG;
/
