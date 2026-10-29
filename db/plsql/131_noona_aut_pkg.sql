-- =============================================================================
-- NOONA PLUS ERP | NOONA_AUT_PKG - مراكز خدمة السيارات
--   * المركبات (اللوحة، الهيكل، الطراز، المالك والسائق، التأمين، الخدمة التالية) وسجل زياراتها
--   * كتالوج الخدمات ككروت حسب الفئة، ولكل خدمة سعر ووقت قياسي وضمان وقطع افتراضية تضاف معها
--   * الحجوزات على الرافعات بلا تعارض، والاستلام من الحجز أو مباشرة بفحص الاستلام (العداد، الوقود، الأضرار، المتعلقات)
--   * أمر الإصلاح: خدمات وقطع وأعمال خارجية، لكل بند فني منفذ ووقت بدء وانتهاء، وجهة سداد (العميل، التأمين، الضمان)
--   * بحث القطع بجزء من الاسم أو الباركود أو رقم الصنف أو رقم القطعة لدى المصنع أو العلامة أو توافقها مع المركبة، وبدائلها
--   * الفوترة: فاتورة مبيعات واحدة للعميل بالخدمات (إيراد الخدمات 4160) والقطع (تصرف من المستودع وتحمل تكلفتها)،
--     ومع التأمين: فاتورة لشركة التأمين بالمعتمد ناقص التحمل، وفاتورة للعميل بالتحمل وفرق الاعتماد
--   * التقارير: إجمالي العمليات، الخدمات، القطع، الأكثر طلباً ومبيعاً، الفنيون، مدة البقاء، التأمين، الحجوزات، الخدمة المستحقة
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_AUT_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  -- حساب إيراد الخدمات 4160 وتسلسلات الأوامر والحجوزات ورافعتان افتراضيتان؛ يعيد 1
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;
  FUNCTION default_warehouse RETURN NUMBER;

  FUNCTION ts(p TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2;
  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION payer_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION line_type_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION plate_key(p_plate IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
  -- عرض اللوحة: الحروف مفصولة ثم الأرقام (أ ب ج 1234)
  FUNCTION plate_label(p_plate IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

  -- ---------------------------------------------------------- الإعداد
  -- {"id","code","name","icon","color","sort","active"}
  FUNCTION save_category(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","code","name","nameEn","cat","price","inc","minutes","warrantyDays","warrantyKm","nextDays","nextKm","icon","sort","active","desc",
  --  "parts":[{"item","qty","optional":"Y|N"}]}
  FUNCTION save_service(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","code","name","type","sort","active"}
  FUNCTION save_bay(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","code","name","employee","specialty","phone","hourly","commission","active"}
  FUNCTION save_technician(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","code","name","customer"(حساب ذمة؛ ينشأ إن لم يحدد),"laborDisc","partsDisc","deductible","claimDays","contact","phone","email","status"}
  FUNCTION save_insurer(p_doc IN CLOB) RETURN NUMBER;

  -- ---------------------------------------------------------- المركبات
  -- {"id","plate","plateType","vin","make","model","year","color","engine","fuel","trans","odometer","cust" | "ownerName","ownerPhone",
  --  "driverName","driverPhone","insurer","policy","policyExpiry","regExpiry","notes"}
  FUNCTION save_vehicle(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION vehicle_by_plate(p_plate IN VARCHAR2) RETURN NUMBER;
  FUNCTION vehicle_label(p_vehicle_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION vehicle_json(p_vehicle_id IN NUMBER) RETURN CLOB;
  -- بحث بجزء من اللوحة أو الهيكل أو اسم المالك أو جواله
  FUNCTION find_vehicles_json(p_q IN VARCHAR2) RETURN CLOB;
  FUNCTION vehicle_html(p_vehicle_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- الحجوزات
  -- {"vehicle" | "plate","name","phone","start":"YYYY-MM-DD HH24:MI","minutes","bay","tech","services":[ids],"complaint","source"}
  FUNCTION book(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE set_appointment_status(p_appointment_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2 DEFAULT NULL);
  -- الحجوزات التي فات موعدها بأكثر من ساعتين دون حضور؛ يعيد العدد
  FUNCTION mark_no_shows RETURN NUMBER;
  -- استلام السيارة من الحجز: ينشئ أمر الإصلاح بالخدمات المطلوبة
  FUNCTION check_in(p_appointment_id IN NUMBER, p_doc IN CLOB DEFAULT NULL) RETURN NUMBER;
  FUNCTION appointments_html(p_date IN DATE) RETURN CLOB;

  -- ---------------------------------------------------------- أمر الإصلاح
  -- {"vehicle" | "plate","make","model","year","ownerName","ownerPhone", "cust","appointment","odometer","fuel","complaint",
  --  "promised":"YYYY-MM-DD HH24:MI","bay","advisor","payer","insurer","claim","policy","accident","deductible","wh",
  --  "inspection":{...},"services":[ids]}
  FUNCTION open_job(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","diagnosis","recommendations","promised","bay","notes","payer","insurer","claim","policy","accident","claimStatus","approved","deductible",
  --  "cust","phone"}
  PROCEDURE update_job(p_doc IN CLOB);
  -- يضيف الخدمة وقطعها الافتراضية غير الاختيارية؛ يعيد رقم بند الخدمة
  FUNCTION add_service(p_job_id IN NUMBER, p_service_id IN NUMBER, p_payer IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION add_part(p_job_id IN NUMBER, p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT 1, p_price IN NUMBER DEFAULT NULL,
                    p_payer IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- عمل خارجي أو خدمة غير مسجلة: {"job","type":"SUBLET|SERVICE","desc","qty","price","inc","payer","tech"}
  FUNCTION add_line(p_doc IN CLOB) RETURN NUMBER;
  -- {"id","qty","price","disc","payer","tech","minutes","notes"}
  PROCEDURE update_line(p_doc IN CLOB);
  PROCEDURE remove_line(p_line_id IN NUMBER);
  -- START | DONE | RESET
  PROCEDURE line_action(p_line_id IN NUMBER, p_action IN VARCHAR2);
  -- IN_PROGRESS | WAITING_PARTS | COMPLETED | CANCELLED
  PROCEDURE set_job_status(p_job_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2 DEFAULT NULL);
  -- {"place":"BOX:1"(نقدي يحصل الآن) | فارغ = آجل على حساب العميل,"method":"CASH|MADA|..."} ؛ يعيد فاتورة العميل (أو التأمين إن لم يبق على العميل شيء)
  FUNCTION invoice_job(p_job_id IN NUMBER, p_doc IN CLOB DEFAULT NULL) RETURN NUMBER;
  PROCEDURE deliver_job(p_job_id IN NUMBER, p_odometer_out IN NUMBER DEFAULT NULL);
  FUNCTION job_status(p_job_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- واجهة أمر الإصلاح (JSON)
  -- الكروت والفنيون والرافعات وشركات التأمين
  FUNCTION boot_json RETURN CLOB;
  FUNCTION job_json(p_job_id IN NUMBER) RETURN CLOB;
  -- بحث القطع: الاسم (كل الكلمات)، الباركود، رقم الصنف، الكود، رقم القطعة لدى المصنع، العلامة، توافق المركبة؛ والبدائل
  FUNCTION search_parts_json(p_q IN VARCHAR2, p_job_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION job_print(p_job_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- اللوحات والتقارير
  FUNCTION summary_html RETURN CLOB;
  -- السيارات في الورشة حسب الحالة
  FUNCTION board_html RETURN CLOB;
  -- p_kind: SUMMARY | SERVICES | PARTS | TOP_SERVICES | TOP_PARTS | TECHNICIANS | STAY | INSURANCE | APPOINTMENTS | DUE | MAKES | VEHICLES
  FUNCTION report_html(p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_param IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION report_label(p_kind IN VARCHAR2) RETURN VARCHAR2;
  -- مطالبات التأمين: {"job","claim","claimStatus","approved"}
  PROCEDURE set_claim(p_doc IN CLOB);
  FUNCTION claims_html(p_insurer_id IN NUMBER DEFAULT NULL, p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
END NOONA_AUT_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_AUT_PKG AS

  c_job   CONSTANT VARCHAR2(30) := 'AUT_JOB_CARD';
  c_appt  CONSTANT VARCHAR2(30) := 'AUT_APPOINTMENT';
  c_rev   CONSTANT VARCHAR2(10) := '4160';
  g_no   NUMBER;
  g_pay  VARCHAR2(30);
  g_doc  VARCHAR2(50);

  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END jt;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION num(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL THEN 'null' ELSE TRIM(TO_CHAR(p, 'FM9999999999990.999999', 'NLS_NUMERIC_CHARACTERS=''.,''')) END;
  END num;
  FUNCTION ts(p TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD HH24:MI'); END ts;

  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    IF p_permission NOT LIKE '%.VIEW' THEN
      NOONA_CORE_PKG.assert_tenant_writable;
    END IF;
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;

  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION jn(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN p_o.get_number(p_k) END;
  EXCEPTION WHEN OTHERS THEN
    RETURN TO_NUMBER(REPLACE(p_o.get_string(p_k), ',', ''));
  END jn;
  FUNCTION jd(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN DATE IS
  BEGIN
    RETURN TO_DATE(SUBSTR(js(p_o, p_k), 1, 10), 'YYYY-MM-DD');
  END jd;
  -- وقت بالصيغة YYYY-MM-DD HH24:MI أو YYYY-MM-DDTHH24:MI
  FUNCTION jts(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN TIMESTAMP IS
    l VARCHAR2(40) := REPLACE(js(p_o, p_k), 'T', ' ');
  BEGIN
    IF l IS NULL THEN RETURN NULL; END IF;
    RETURN TO_TIMESTAMP(SUBSTR(l, 1, 16), 'YYYY-MM-DD HH24:MI');
  END jts;

  FUNCTION plate_key(p_plate IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    -- توحيد اللوحة: بلا مسافات وشرطات، حروف كبيرة، أرقام لاتينية
    RETURN UPPER(TRANSLATE(REGEXP_REPLACE(p_plate, '[[:space:]-]', ''), '٠١٢٣٤٥٦٧٨٩', '0123456789'));
  END plate_key;

  FUNCTION plate_label(p_plate IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
    l_l VARCHAR2(100);
    l_d VARCHAR2(100);
    ch  VARCHAR2(4);
  BEGIN
    IF p_plate IS NULL THEN RETURN NULL; END IF;
    FOR i IN 1 .. LENGTH(p_plate) LOOP
      ch := SUBSTR(p_plate, i, 1);
      IF ch BETWEEN '0' AND '9' THEN l_d := l_d || ch;
      ELSIF ch <> ' ' THEN l_l := l_l || (CASE WHEN l_l IS NOT NULL THEN ' ' END || ch);
      END IF;
    END LOOP;
    RETURN TRIM(l_l || ' ' || l_d);
  END plate_label;

  FUNCTION status_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'OPEN' THEN 'مستلمة' WHEN 'IN_PROGRESS' THEN 'قيد العمل' WHEN 'WAITING_PARTS' THEN 'بانتظار قطع'
      WHEN 'COMPLETED' THEN 'جاهزة للتسليم' WHEN 'INVOICED' THEN 'مفوترة' WHEN 'DELIVERED' THEN 'سلمت' WHEN 'CANCELLED' THEN 'ملغاة'
      WHEN 'BOOKED' THEN 'محجوز' WHEN 'CONFIRMED' THEN 'مؤكد' WHEN 'ARRIVED' THEN 'وصل' WHEN 'NO_SHOW' THEN 'لم يحضر'
      WHEN 'PENDING' THEN 'لم يبدأ' WHEN 'DONE' THEN 'منجز' WHEN 'ACTIVE' THEN 'نشط' WHEN 'INACTIVE' THEN 'غير نشط' WHEN 'SUSPENDED' THEN 'موقوف'
      WHEN 'NOT_SUBMITTED' THEN 'لم ترفع' WHEN 'SUBMITTED' THEN 'مرفوعة' WHEN 'APPROVED' THEN 'معتمدة' WHEN 'PARTIALLY_APPROVED' THEN 'معتمدة جزئياً'
      WHEN 'REJECTED' THEN 'مرفوضة' WHEN 'PAID' THEN 'مسددة' ELSE p_code END;
  END status_label;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE WHEN p_code IN ('COMPLETED', 'DONE', 'ACTIVE', 'APPROVED', 'PAID', 'CONFIRMED', 'ARRIVED') THEN 'is-success'
                                            WHEN p_code IN ('IN_PROGRESS', 'SUBMITTED', 'BOOKED', 'OPEN') THEN 'is-info'
                                            WHEN p_code IN ('WAITING_PARTS', 'PARTIALLY_APPROVED', 'PENDING') THEN 'is-warning'
                                            WHEN p_code IN ('CANCELLED', 'NO_SHOW', 'REJECTED', 'SUSPENDED') THEN 'is-danger' ELSE 'is-muted' END
        || '">' || esc(status_label(p_code)) || '</span>';
  END badge;

  FUNCTION payer_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'CUSTOMER' THEN 'العميل' WHEN 'INSURANCE' THEN 'التأمين' WHEN 'WARRANTY' THEN 'الضمان' WHEN 'INTERNAL' THEN 'داخلي'
      ELSE p_code END;
  END payer_label;

  FUNCTION line_type_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code WHEN 'SERVICE' THEN 'خدمة' WHEN 'PART' THEN 'قطعة غيار' WHEN 'SUBLET' THEN 'عمل خارجي' ELSE p_code END;
  END line_type_label;

  -- ================================================================ التجهيز
  FUNCTION next_no(p_type VARCHAR2, p_prefix VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, p_type, NULL, p_prefix, 1, 6, 'N', 'NEVER', 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = p_type);
    RETURN NOONA_REFERENCE_PKG.next_doc_no(p_type, company, NULL, TRUNC(SYSDATE), p_type, NULL);
  END next_no;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM aut_bay WHERE company_id = company AND ROWNUM = 1;
    RETURN CASE WHEN l > 0 AND NOONA_INV_PKG.acc_id(c_rev) IS NOT NULL THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION default_warehouse RETURN NUMBER IS
  BEGIN
    RETURN NOONA_INV_PKG.default_warehouse;
  END default_warehouse;

  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2) RETURN NUMBER IS
    l NUMBER := NOONA_INV_PKG.acc_id(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', NULL);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION quick_setup RETURN NUMBER IS
    l_x NUMBER;
    l_n NUMBER;
  BEGIN
    guard('AUT_BAY.CREATE');
    l_x := ensure_account(c_rev, 'إيرادات خدمات صيانة السيارات', '4', 'REVENUE');
    SELECT COUNT(*) INTO l_n FROM aut_bay WHERE company_id = company;
    IF l_n = 0 THEN
      INSERT INTO aut_bay (company_id, code, name_ar, bay_type, sort_order) VALUES (company, 'L1', 'رافعة 1', 'LIFT', 1);
      INSERT INTO aut_bay (company_id, code, name_ar, bay_type, sort_order) VALUES (company, 'L2', 'رافعة 2', 'LIFT', 2);
    END IF;
    -- فئات وخدمات افتراضية لمركز جديد (تعدل أسعارها وتضاف قطعها من «الخدمات وقطعها»)
    SELECT COUNT(*) INTO l_n FROM aut_service_category WHERE company_id = company;
    IF l_n = 0 THEN
      DECLARE
        TYPE t_ids IS TABLE OF NUMBER INDEX BY VARCHAR2(10);
        c t_ids;
        PROCEDURE cat(k VARCHAR2, n VARCHAR2, i VARCHAR2, col VARCHAR2, srt NUMBER) IS
        BEGIN
          c(k) := save_category('{"code":"' || k || '","name":"' || n || '","icon":"' || i || '","color":"' || col || '","sort":' || srt || '}');
        END cat;
        PROCEDURE svc(k VARCHAR2, ck VARCHAR2, n VARCHAR2, pr NUMBER, mins NUMBER, i VARCHAR2, nd NUMBER DEFAULT NULL, nk NUMBER DEFAULT NULL,
                      w NUMBER DEFAULT 30) IS
        BEGIN
          l_x := save_service('{"code":"' || k || '","name":"' || n || '","cat":' || c(ck) || ',"price":' || pr || ',"minutes":' || mins
                 || ',"icon":"' || i || '","warrantyDays":' || w || CASE WHEN nd IS NOT NULL THEN ',"nextDays":' || nd END
                 || CASE WHEN nk IS NOT NULL THEN ',"nextKm":' || nk END || '}');
        END svc;
      BEGIN
        cat('OIL', 'زيوت وفلاتر', 'fa-tint', '#e65100', 1);
        cat('MECH', 'ميكانيكا وفرامل', 'fa-cogs', '#1565c0', 2);
        cat('ELEC', 'كهرباء وبطاريات', 'fa-bolt', '#f9a825', 3);
        cat('DIAG', 'فحص وكمبيوتر', 'fa-laptop', '#6a1b9a', 4);
        cat('TIRE', 'إطارات وميزان', 'fa-circle-o-notch', '#37474f', 5);
        cat('AC', 'تكييف', 'fa-snowflake-o', '#0288d1', 6);
        cat('BODY', 'سمكرة ودهان', 'fa-paint-brush', '#c62828', 7);
        cat('WASH', 'غسيل وتلميع', 'fa-shower', '#2e7d32', 8);
        svc('OIL-CHG', 'OIL', 'تغيير زيت مع الفلتر', 50, 30, 'fa-tint', 90, 5000);
        svc('ATF', 'OIL', 'تغيير زيت القير', 120, 45, 'fa-exchange', 365, 40000);
        svc('BRK-F', 'MECH', 'تغيير فحمات أمامية', 150, 60, 'fa-stop-circle');
        svc('SPARK', 'MECH', 'تغيير البواجي', 120, 45, 'fa-fire', 730, 60000);
        svc('BATT', 'ELEC', 'تركيب بطارية وفحص الشحن', 30, 15, 'fa-battery-full');
        svc('DIAG', 'DIAG', 'فحص كمبيوتر شامل', 150, 30, 'fa-laptop');
        svc('ALIGN', 'TIRE', 'ميزان أذرعة', 120, 40, 'fa-arrows-h', 180, 10000);
        svc('BAL', 'TIRE', 'ترصيص الإطارات (4)', 60, 30, 'fa-circle-o-notch');
        svc('AC-GAS', 'AC', 'تعبئة غاز المكيف وفحص التسريب', 180, 60, 'fa-snowflake-o', 365);
        svc('BODY-P', 'BODY', 'سمكرة ودهان قطعة', 650, 480, 'fa-paint-brush', NULL, NULL, 180);
        svc('WASH', 'WASH', 'غسيل داخلي وخارجي', 70, 45, 'fa-shower', NULL, NULL, 0);
      END;
    END IF;
    RETURN 1;
  END quick_setup;

  -- ================================================================ الإعداد
  FUNCTION save_category(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_name VARCHAR2(400) := js(l_o, 'name');
    l_icon VARCHAR2(50) := NVL(js(l_o, 'icon'), 'fa-wrench');
    l_color VARCHAR2(20) := js(l_o, 'color');
    l_sort NUMBER := jn(l_o, 'sort');
    l_act VARCHAR2(1) := NVL(js(l_o, 'active'), 'Y');
  BEGIN
    guard('AUT_SERVICE_CATEGORY.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-AUT-001', 'رمز الفئة واسمها مطلوبان', 'Code and name are required');
    IF l_id IS NULL THEN
      INSERT INTO aut_service_category (company_id, code, name_ar, icon, color, sort_order, is_active)
      VALUES (company, l_code, l_name, l_icon, l_color, l_sort, l_act) RETURNING id INTO l_id;
    ELSE
      UPDATE aut_service_category SET code = l_code, name_ar = l_name, icon = l_icon, color = l_color, sort_order = l_sort, is_active = l_act
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-002', 'رمز الفئة مستخدم: ' || l_code, 'Category code already exists');
  END save_category;

  FUNCTION save_service(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id   NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code'));
    l_name VARCHAR2(400) := js(l_o, 'name');
    l_cat  NUMBER := jn(l_o, 'cat');
    l_price NUMBER := NVL(jn(l_o, 'price'), 0);
    l_parts JSON_ARRAY_T;
    l_p    JSON_OBJECT_T;
    l_n    NUMBER;
    l_name_en VARCHAR2(400) := js(l_o, 'nameEn'); l_inc VARCHAR2(1) := NVL(js(l_o, 'inc'), 'N'); l_min NUMBER := jn(l_o, 'minutes');
    l_wd NUMBER := jn(l_o, 'warrantyDays'); l_wk NUMBER := jn(l_o, 'warrantyKm'); l_nd NUMBER := jn(l_o, 'nextDays'); l_nk NUMBER := jn(l_o, 'nextKm');
    l_icon VARCHAR2(50) := js(l_o, 'icon'); l_sort NUMBER := jn(l_o, 'sort'); l_act VARCHAR2(1) := NVL(js(l_o, 'active'), 'Y');
    l_desc VARCHAR2(4000) := js(l_o, 'desc');
    l_item NUMBER; l_qty NUMBER; l_opt VARCHAR2(1);
  BEGIN
    guard('AUT_SERVICE.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL AND l_cat IS NOT NULL, 'NOONA-AUT-003', 'رمز الخدمة واسمها وفئتها مطلوبة',
                          'Code, name and category are required');
    NOONA_CORE_PKG.assert(l_price >= 0, 'NOONA-AUT-004', 'السعر لا يكون سالباً', 'Price cannot be negative');
    SELECT COUNT(*) INTO l_n FROM aut_service_category WHERE id = l_cat AND company_id = company;
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-AUT-005', 'الفئة غير موجودة', 'Category not found');
    IF l_id IS NULL THEN
      INSERT INTO aut_service (company_id, code, name_ar, name_en, description, category_id, price, price_includes_tax, standard_minutes, warranty_days,
                               warranty_km, next_service_days, next_service_km, icon, sort_order, is_active)
      VALUES (company, l_code, l_name, l_name_en, l_desc, l_cat, l_price, l_inc, l_min, l_wd, l_wk, l_nd, l_nk, l_icon, l_sort, l_act)
      RETURNING id INTO l_id;
    ELSE
      UPDATE aut_service SET code = l_code, name_ar = l_name, name_en = l_name_en, description = l_desc, category_id = l_cat, price = l_price,
                             price_includes_tax = l_inc, standard_minutes = l_min, warranty_days = l_wd, warranty_km = l_wk, next_service_days = l_nd,
                             next_service_km = l_nk, icon = l_icon, sort_order = l_sort, is_active = l_act
       WHERE id = l_id AND company_id = company;
    END IF;
    IF l_o.has('parts') THEN
      DELETE FROM aut_service_part WHERE service_id = l_id;
      l_parts := l_o.get_array('parts');
      FOR k IN 0 .. l_parts.get_size - 1 LOOP
        l_p := TREAT(l_parts.get(k) AS JSON_OBJECT_T);
        l_item := jn(l_p, 'item'); l_qty := NVL(jn(l_p, 'qty'), 1); l_opt := NVL(js(l_p, 'optional'), 'N');
        NOONA_CORE_PKG.assert(l_qty > 0, 'NOONA-AUT-006', 'كمية القطعة يجب أن تكون موجبة', 'Quantity must be positive');
        INSERT INTO aut_service_part (company_id, service_id, item_id, quantity, is_optional) VALUES (company, l_id, l_item, l_qty, l_opt);
      END LOOP;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-007', 'رمز الخدمة أو قطعتها مكررة', 'Duplicate service code or part');
  END save_service;

  FUNCTION save_bay(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code')); l_name VARCHAR2(400) := js(l_o, 'name');
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'LIFT'); l_sort NUMBER := jn(l_o, 'sort'); l_act VARCHAR2(1) := NVL(js(l_o, 'active'), 'Y');
  BEGIN
    guard('AUT_BAY.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-AUT-001', 'الرمز والاسم مطلوبان', 'Code and name are required');
    IF l_id IS NULL THEN
      INSERT INTO aut_bay (company_id, code, name_ar, bay_type, sort_order, is_active) VALUES (company, l_code, l_name, l_type, l_sort, l_act)
      RETURNING id INTO l_id;
    ELSE
      UPDATE aut_bay SET code = l_code, name_ar = l_name, bay_type = l_type, sort_order = l_sort, is_active = l_act WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-008', 'رمز الرافعة مستخدم', 'Bay code already exists');
  END save_bay;

  FUNCTION save_technician(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code')); l_name VARCHAR2(400) := js(l_o, 'name');
    l_emp NUMBER := jn(l_o, 'employee'); l_spec VARCHAR2(200) := js(l_o, 'specialty'); l_phone VARCHAR2(30) := js(l_o, 'phone');
    l_cost NUMBER := jn(l_o, 'hourly'); l_comm NUMBER := jn(l_o, 'commission'); l_act VARCHAR2(1) := NVL(js(l_o, 'active'), 'Y');
  BEGIN
    guard('AUT_TECHNICIAN.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-AUT-001', 'الرمز والاسم مطلوبان', 'Code and name are required');
    NOONA_CORE_PKG.assert(NVL(l_comm, 0) BETWEEN 0 AND 100, 'NOONA-AUT-009', 'نسبة العمولة بين 0 و100', 'Commission must be 0-100');
    IF l_id IS NULL THEN
      INSERT INTO aut_technician (company_id, code, name_ar, employee_id, specialty, phone, hourly_cost, commission_pct, is_active)
      VALUES (company, l_code, l_name, l_emp, l_spec, l_phone, l_cost, l_comm, l_act) RETURNING id INTO l_id;
    ELSE
      UPDATE aut_technician SET code = l_code, name_ar = l_name, employee_id = l_emp, specialty = l_spec, phone = l_phone, hourly_cost = l_cost,
                                commission_pct = l_comm, is_active = l_act
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-010', 'رمز الفني مستخدم', 'Technician code already exists');
  END save_technician;

  FUNCTION save_insurer(p_doc IN CLOB) RETURN NUMBER IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id NUMBER := jn(l_o, 'id');
    l_code VARCHAR2(50) := UPPER(js(l_o, 'code')); l_name VARCHAR2(400) := js(l_o, 'name');
    l_cust NUMBER := jn(l_o, 'customer');
    l_ld NUMBER := jn(l_o, 'laborDisc'); l_pd NUMBER := jn(l_o, 'partsDisc'); l_ded NUMBER := jn(l_o, 'deductible');
    l_days NUMBER := jn(l_o, 'claimDays'); l_contact VARCHAR2(200) := js(l_o, 'contact'); l_phone VARCHAR2(30) := js(l_o, 'phone');
    l_email VARCHAR2(320) := js(l_o, 'email'); l_st VARCHAR2(30) := NVL(js(l_o, 'status'), 'ACTIVE');
    l_doc CLOB;
  BEGIN
    guard('AUT_INSURER.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-AUT-001', 'الرمز والاسم مطلوبان', 'Code and name are required');
    IF l_cust IS NULL AND l_id IS NULL THEN
      -- حساب ذمة للمطالبات باسم شركة التأمين
      SELECT JSON_OBJECT('name' VALUE l_name, 'phone' VALUE l_phone, 'email' VALUE l_email, 'person' VALUE 'N', 'term' VALUE 'NET30'
                         ABSENT ON NULL RETURNING CLOB) INTO l_doc FROM dual;
      l_cust := NOONA_SAL_PKG.save_customer(l_doc);
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO aut_insurer (company_id, code, name_ar, customer_account_id, labor_discount_pct, parts_discount_pct, default_deductible, claim_days,
                               contact_name, phone, email, status_code)
      VALUES (company, l_code, l_name, l_cust, l_ld, l_pd, l_ded, l_days, l_contact, l_phone, l_email, l_st) RETURNING id INTO l_id;
    ELSE
      UPDATE aut_insurer SET code = l_code, name_ar = l_name, customer_account_id = NVL(l_cust, customer_account_id), labor_discount_pct = l_ld,
                             parts_discount_pct = l_pd, default_deductible = l_ded, claim_days = l_days, contact_name = l_contact, phone = l_phone,
                             email = l_email, status_code = l_st
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-011', 'رمز شركة التأمين مستخدم', 'Insurer code already exists');
  END save_insurer;

  -- ================================================================ المركبات
  FUNCTION vehicle_by_plate(p_plate IN VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM aut_vehicle WHERE company_id = company AND plate_no = plate_key(p_plate);
    RETURN l;
  END vehicle_by_plate;

  FUNCTION vehicle_label(p_vehicle_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT plate_label(plate_no) || ' - ' || make || NVL2(model, ' ' || model, '') || NVL2(model_year, ' ' || model_year, '') INTO l
      FROM aut_vehicle WHERE id = p_vehicle_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END vehicle_label;

  FUNCTION owner_account(p_name VARCHAR2, p_phone VARCHAR2) RETURN NUMBER IS
    l    NUMBER;
    l_doc CLOB;
  BEGIN
    IF p_phone IS NOT NULL THEN
      SELECT MIN(a.id) INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id JOIN ref_contact x ON x.party_id = c.party_id
       WHERE a.company_id = company AND x.mobile = p_phone AND a.status_code = 'ACTIVE';
    END IF;
    IF l IS NULL AND p_name IS NOT NULL THEN
      SELECT JSON_OBJECT('name' VALUE p_name, 'phone' VALUE p_phone, 'term' VALUE 'NET0' ABSENT ON NULL RETURNING CLOB) INTO l_doc FROM dual;
      l := NOONA_SAL_PKG.save_customer(l_doc);
    END IF;
    RETURN l;
  END owner_account;

  FUNCTION save_vehicle(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER := jn(l_o, 'id');
    l_plate VARCHAR2(30) := plate_key(js(l_o, 'plate'));
    l_make  VARCHAR2(100) := js(l_o, 'make');
    l_cust  NUMBER := jn(l_o, 'cust');
    l_oname VARCHAR2(400) := js(l_o, 'ownerName');
    l_ophone VARCHAR2(30) := js(l_o, 'ownerPhone');
    l_n     NUMBER;
    l_ptype VARCHAR2(30) := NVL(js(l_o, 'plateType'), 'PRIVATE'); l_vin VARCHAR2(30) := UPPER(js(l_o, 'vin')); l_model VARCHAR2(100) := js(l_o, 'model');
    l_year NUMBER := jn(l_o, 'year'); l_color VARCHAR2(50) := js(l_o, 'color'); l_engine VARCHAR2(100) := js(l_o, 'engine');
    l_fuel VARCHAR2(30) := js(l_o, 'fuel'); l_trans VARCHAR2(30) := js(l_o, 'trans'); l_odo NUMBER := jn(l_o, 'odometer');
    l_dname VARCHAR2(200) := js(l_o, 'driverName'); l_dphone VARCHAR2(30) := js(l_o, 'driverPhone'); l_ins NUMBER := jn(l_o, 'insurer');
    l_pol VARCHAR2(50) := js(l_o, 'policy'); l_pexp DATE := jd(l_o, 'policyExpiry'); l_rexp DATE := jd(l_o, 'regExpiry');
    l_notes VARCHAR2(4000) := js(l_o, 'notes');
  BEGIN
    guard('AUT_VEHICLE.' || CASE WHEN l_id IS NULL THEN 'CREATE' ELSE 'UPDATE' END);
    NOONA_CORE_PKG.assert(l_plate IS NOT NULL AND l_make IS NOT NULL, 'NOONA-AUT-020', 'رقم اللوحة والشركة المصنعة مطلوبان',
                          'Plate and make are required');
    NOONA_CORE_PKG.assert(l_year IS NULL OR l_year BETWEEN 1950 AND EXTRACT(YEAR FROM SYSDATE) + 1, 'NOONA-AUT-021', 'سنة الصنع غير صحيحة',
                          'Invalid model year');
    NOONA_CORE_PKG.assert(l_vin IS NULL OR REGEXP_LIKE(l_vin, '^[A-HJ-NPR-Z0-9]{11,17}$'), 'NOONA-AUT-022',
                          'رقم الهيكل (VIN) من 11 إلى 17 حرفاً ورقماً (بدون I وO وQ)', 'Invalid VIN');
    SELECT COUNT(*) INTO l_n FROM aut_vehicle WHERE company_id = company AND plate_no = l_plate AND id <> NVL(l_id, -1);
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-AUT-023', 'اللوحة مسجلة لمركبة أخرى: ' || l_plate, 'Plate already registered');
    IF l_cust IS NULL AND (l_oname IS NOT NULL OR l_ophone IS NOT NULL) THEN
      l_cust := owner_account(l_oname, l_ophone);
    END IF;
    IF l_oname IS NULL AND l_cust IS NOT NULL THEN
      l_oname := NOONA_SAL_PKG.customer_label(l_cust);
    END IF;
    IF l_id IS NULL THEN
      INSERT INTO aut_vehicle (company_id, plate_no, plate_type, vin, make, model, model_year, color, engine, fuel_type, transmission, odometer,
                               customer_account_id, owner_name, owner_phone, driver_name, driver_phone, insurer_id, policy_no, policy_expiry,
                               registration_expiry, notes, status_code)
      VALUES (company, l_plate, l_ptype, l_vin, l_make, l_model, l_year, l_color, l_engine, l_fuel, l_trans, l_odo, l_cust, l_oname, l_ophone,
              l_dname, l_dphone, l_ins, l_pol, l_pexp, l_rexp, l_notes, 'ACTIVE')
      RETURNING id INTO l_id;
    ELSE
      UPDATE aut_vehicle SET plate_no = l_plate, plate_type = l_ptype, vin = l_vin, make = l_make, model = l_model, model_year = l_year, color = l_color,
                             engine = l_engine, fuel_type = l_fuel, transmission = l_trans, odometer = GREATEST(NVL(l_odo, 0), NVL(odometer, 0)),
                             customer_account_id = NVL(l_cust, customer_account_id), owner_name = NVL(l_oname, owner_name),
                             owner_phone = NVL(l_ophone, owner_phone), driver_name = l_dname, driver_phone = l_dphone, insurer_id = l_ins,
                             policy_no = l_pol, policy_expiry = l_pexp, registration_expiry = l_rexp, notes = l_notes
       WHERE id = l_id AND company_id = company;
    END IF;
    RETURN l_id;
  END save_vehicle;

  FUNCTION vehicle_json(p_vehicle_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    guard('AUT_VEHICLE.VIEW');
    SELECT JSON_OBJECT('id' VALUE v.id, 'plate' VALUE plate_label(v.plate_no), 'plateType' VALUE v.plate_type, 'vin' VALUE v.vin, 'make' VALUE v.make,
                       'model' VALUE v.model, 'year' VALUE v.model_year, 'color' VALUE v.color, 'engine' VALUE v.engine, 'fuel' VALUE v.fuel_type,
                       'trans' VALUE v.transmission, 'odometer' VALUE v.odometer, 'cust' VALUE v.customer_account_id, 'ownerName' VALUE v.owner_name,
                       'ownerPhone' VALUE v.owner_phone, 'driverName' VALUE v.driver_name, 'driverPhone' VALUE v.driver_phone, 'insurer' VALUE v.insurer_id,
                       'policy' VALUE v.policy_no, 'policyExpiry' VALUE TO_CHAR(v.policy_expiry, 'YYYY-MM-DD'),
                       'regExpiry' VALUE TO_CHAR(v.registration_expiry, 'YYYY-MM-DD'), 'nextDate' VALUE TO_CHAR(v.next_service_date, 'YYYY-MM-DD'),
                       'nextKm' VALUE v.next_service_km, 'notes' VALUE v.notes,
                       'openJob' VALUE (SELECT MAX(j.id) FROM aut_job_card j WHERE j.vehicle_id = v.id
                                          AND j.status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED', 'INVOICED'))
                       RETURNING CLOB)
      INTO l FROM aut_vehicle v WHERE v.id = p_vehicle_id AND v.company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-024', 'المركبة غير موجودة', 'Vehicle not found');
  END vehicle_json;

  FUNCTION find_vehicles_json(p_q IN VARCHAR2) RETURN CLOB IS
    l   CLOB;
    l_q VARCHAR2(200) := LOWER(TRIM(p_q));
    l_k VARCHAR2(200) := plate_key(p_q);
  BEGIN
    guard('AUT_VEHICLE.VIEW');
    IF l_q IS NULL THEN RETURN '[]'; END IF;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'plate' VALUE plate_label(plate_no), 'label' VALUE lbl, 'owner' VALUE owner_name, 'phone' VALUE owner_phone)
                         ORDER BY rk, plate_no RETURNING CLOB)
      INTO l
      FROM (SELECT v.id, v.plate_no, v.make || NVL2(v.model, ' ' || v.model, '') || NVL2(v.model_year, ' ' || v.model_year, '') lbl,
                   v.owner_name, v.owner_phone, CASE WHEN v.plate_no = l_k THEN 0 WHEN v.plate_no LIKE l_k || '%' THEN 1 ELSE 2 END rk
              FROM aut_vehicle v
             WHERE v.company_id = company
               AND (v.plate_no LIKE '%' || l_k || '%' OR LOWER(v.vin) LIKE '%' || l_q || '%' OR LOWER(v.owner_name) LIKE '%' || l_q || '%'
                    OR v.owner_phone LIKE '%' || l_q || '%' OR v.driver_phone LIKE '%' || l_q || '%')
             ORDER BY rk FETCH FIRST 15 ROWS ONLY);
    RETURN NVL(l, '[]');
  END find_vehicles_json;

  -- ================================================================ أمر الإصلاح
  FUNCTION get_job(p_job_id NUMBER, p_lock BOOLEAN DEFAULT FALSE) RETURN aut_job_card%ROWTYPE IS
    j aut_job_card%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO j FROM aut_job_card WHERE id = p_job_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO j FROM aut_job_card WHERE id = p_job_id AND company_id = company;
    END IF;
    RETURN j;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-AUT-030', 'أمر الإصلاح غير موجود', 'Job card not found');
  END get_job;

  FUNCTION job_status(p_job_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(status_code) INTO l FROM aut_job_card WHERE id = p_job_id AND company_id = company;
    RETURN l;
  END job_status;

  PROCEDURE assert_editable(j aut_job_card%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(j.status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED'), 'NOONA-AUT-031',
                          'لا يعدل أمر الإصلاح بعد الفوترة أو الإلغاء (' || status_label(j.status_code) || ')', 'Job card is closed');
  END assert_editable;

  -- تسعير البنود بنفس قواعد فاتورة المبيعات (الضريبة، السعر الشامل، الحد الأدنى) ثم إجماليات الأمر
  PROCEDURE recalc(p_job_id NUMBER) IS
    l_price NUMBER; l_inc VARCHAR2(1); l_tc NUMBER; l_net NUMBER; l_tax NUMBER; l_item NUMBER;
  BEGIN
    FOR l IN (SELECT * FROM aut_job_line WHERE job_card_id = p_job_id AND line_status <> 'CANCELLED') LOOP
      l_price := CASE WHEN l.payer = 'WARRANTY' THEN 0 ELSE l.unit_price END;
      l_inc := l.price_includes_tax; l_tc := NULL;
      l_item := CASE WHEN l.line_type = 'PART' THEN l.item_id END;
      NOONA_SAL_PKG.price_line(l_item, l.quantity, l_price, CASE WHEN l.payer = 'WARRANTY' THEN 0 ELSE l.discount_amount END, l_inc, l_tc,
                               TRUNC(SYSDATE), l_net, l_tax);
      UPDATE aut_job_line SET net_amount = l_net, tax_amount = l_tax WHERE id = l.id;
    END LOOP;
    UPDATE aut_job_card j SET
      (services_amount, parts_amount, discount_amount, tax_amount, total_amount) =
      (SELECT NVL(SUM(CASE WHEN line_type IN ('SERVICE', 'SUBLET') THEN net_amount END), 0), NVL(SUM(CASE WHEN line_type = 'PART' THEN net_amount END), 0),
              NVL(SUM(CASE WHEN payer <> 'WARRANTY' THEN discount_amount END), 0), NVL(SUM(tax_amount), 0), NVL(SUM(net_amount + tax_amount), 0)
         FROM aut_job_line WHERE job_card_id = j.id AND line_status <> 'CANCELLED')
     WHERE id = p_job_id;
  END recalc;

  FUNCTION next_line_no(p_job_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(MAX(line_no), 0) + 1 INTO l FROM aut_job_line WHERE job_card_id = p_job_id;
    RETURN l;
  END next_line_no;

  FUNCTION default_payer(j aut_job_card%ROWTYPE, p_payer VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN NVL(p_payer, CASE j.payer_type WHEN 'INSURANCE' THEN 'INSURANCE' WHEN 'WARRANTY' THEN 'WARRANTY' ELSE 'CUSTOMER' END);
  END default_payer;

  FUNCTION insert_part(j aut_job_card%ROWTYPE, p_item NUMBER, p_qty NUMBER, p_price NUMBER, p_payer VARCHAR2, p_parent NUMBER) RETURN NUMBER IS
    l_id    NUMBER;
    l_type  VARCHAR2(30);
    l_have  NUMBER;
    l_used  NUMBER;
    l_price NUMBER := p_price;
    l_inc   VARCHAR2(1);
    l_desc  VARCHAR2(1000);
    l_disc  NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(p_item IS NOT NULL AND NVL(p_qty, 0) > 0, 'NOONA-AUT-032', 'اختر القطعة وكمية موجبة', 'Item and positive quantity required');
    SELECT item_type, item_no || ' - ' || name_ar INTO l_type, l_desc FROM inv_item WHERE id = p_item;
    IF l_type NOT IN ('SERVICE', 'NON_STOCK') THEN
      -- المتاح في مستودع الأمر بعد ما حجزته بنود الأمر نفسه
      l_have := NOONA_INV_PKG.on_hand(p_item, j.warehouse_id);
      SELECT NVL(SUM(quantity), 0) INTO l_used FROM aut_job_line
       WHERE job_card_id = j.id AND item_id = p_item AND line_type = 'PART' AND line_status <> 'CANCELLED';
      NOONA_CORE_PKG.assert(l_have - l_used >= p_qty, 'NOONA-AUT-033',
        'الكمية المتاحة من ' || l_desc || ' في المستودع ' || TO_CHAR(GREATEST(l_have - l_used, 0)) || ' فقط', 'Insufficient stock');
    END IF;
    IF l_price IS NULL THEN
      SELECT MAX(sale_price), MAX(prices_include_tax) INTO l_price, l_inc FROM inv_item_company WHERE item_id = p_item AND company_id = company;
    END IF;
    -- خصم القطع المتفق عليه مع شركة التأمين
    IF default_payer(j, p_payer) = 'INSURANCE' AND j.insurer_id IS NOT NULL THEN
      SELECT ROUND(NVL(MAX(parts_discount_pct), 0) / 100 * p_qty * NVL(l_price, 0), 2) INTO l_disc FROM aut_insurer WHERE id = j.insurer_id;
    END IF;
    g_no := next_line_no(j.id);
    g_pay := default_payer(j, p_payer);
    INSERT INTO aut_job_line (company_id, job_card_id, line_no, line_type, item_id, parent_line_id, description, quantity, unit_price,
                              price_includes_tax, discount_amount, payer, line_status)
    VALUES (company, j.id, g_no, 'PART', p_item, p_parent, l_desc, p_qty, NVL(l_price, 0), NVL(l_inc, 'N'), NULLIF(l_disc, 0),
            g_pay, 'PENDING')
    RETURNING id INTO l_id;
    RETURN l_id;
  END insert_part;

  FUNCTION add_service(p_job_id IN NUMBER, p_service_id IN NUMBER, p_payer IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    j    aut_job_card%ROWTYPE;
    s    aut_service%ROWTYPE;
    l_id NUMBER;
    l_x  NUMBER;
    l_disc NUMBER;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(p_job_id, TRUE);
    assert_editable(j);
    BEGIN
      SELECT * INTO s FROM aut_service WHERE id = p_service_id AND company_id = company AND is_active = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-AUT-034', 'الخدمة غير موجودة أو غير نشطة', 'Service not found');
    END;
    IF default_payer(j, p_payer) = 'INSURANCE' AND j.insurer_id IS NOT NULL THEN
      SELECT ROUND(NVL(MAX(labor_discount_pct), 0) / 100 * s.price, 2) INTO l_disc FROM aut_insurer WHERE id = j.insurer_id;
    END IF;
    g_no := next_line_no(j.id);
    g_pay := default_payer(j, p_payer);
    INSERT INTO aut_job_line (company_id, job_card_id, line_no, line_type, service_id, description, quantity, unit_price, price_includes_tax,
                              discount_amount, payer, work_minutes, line_status)
    VALUES (company, j.id, g_no, 'SERVICE', s.id, s.name_ar, 1, s.price, s.price_includes_tax, NULLIF(l_disc, 0),
            g_pay, s.standard_minutes, 'PENDING')
    RETURNING id INTO l_id;
    FOR p IN (SELECT item_id, quantity FROM aut_service_part WHERE service_id = s.id AND is_optional = 'N' ORDER BY id) LOOP
      l_x := insert_part(j, p.item_id, p.quantity, NULL, p_payer, l_id);
    END LOOP;
    recalc(j.id);
    RETURN l_id;
  END add_service;

  FUNCTION add_part(p_job_id IN NUMBER, p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT 1, p_price IN NUMBER DEFAULT NULL,
                    p_payer IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    j    aut_job_card%ROWTYPE;
    l_id NUMBER;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(p_job_id, TRUE);
    assert_editable(j);
    l_id := insert_part(j, p_item_id, NVL(p_qty, 1), p_price, p_payer, NULL);
    recalc(j.id);
    RETURN l_id;
  END add_part;

  FUNCTION add_line(p_doc IN CLOB) RETURN NUMBER IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    j     aut_job_card%ROWTYPE;
    l_id  NUMBER;
    l_type VARCHAR2(30) := NVL(js(l_o, 'type'), 'SUBLET');
    l_desc VARCHAR2(1000) := js(l_o, 'desc');
    l_qty NUMBER := NVL(jn(l_o, 'qty'), 1);
    l_price NUMBER := jn(l_o, 'price');
    l_inc VARCHAR2(1) := NVL(js(l_o, 'inc'), 'N');
    l_payer VARCHAR2(30) := js(l_o, 'payer');
    l_tech NUMBER := jn(l_o, 'tech');
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(jn(l_o, 'job'), TRUE);
    assert_editable(j);
    NOONA_CORE_PKG.assert(l_type IN ('SERVICE', 'SUBLET'), 'NOONA-AUT-035', 'نوع البند خدمة أو عمل خارجي', 'Type must be SERVICE or SUBLET');
    NOONA_CORE_PKG.assert(l_desc IS NOT NULL AND NVL(l_price, -1) >= 0 AND l_qty > 0, 'NOONA-AUT-036', 'البيان والسعر والكمية مطلوبة',
                          'Description, price and quantity are required');
    g_no := next_line_no(j.id);
    g_pay := default_payer(j, l_payer);
    INSERT INTO aut_job_line (company_id, job_card_id, line_no, line_type, description, quantity, unit_price, price_includes_tax, payer,
                              technician_id, line_status)
    VALUES (company, j.id, g_no, l_type, l_desc, l_qty, l_price, l_inc, g_pay, l_tech, 'PENDING')
    RETURNING id INTO l_id;
    recalc(j.id);
    RETURN l_id;
  END add_line;

  PROCEDURE update_line(p_doc IN CLOB) IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l    aut_job_line%ROWTYPE;
    j    aut_job_card%ROWTYPE;
    l_qty NUMBER; l_have NUMBER; l_used NUMBER;
    l_price NUMBER; l_disc NUMBER; l_payer VARCHAR2(30); l_tech NUMBER; l_min NUMBER; l_notes VARCHAR2(500);
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    BEGIN
      g_no := jn(l_o, 'id');
      SELECT * INTO l FROM aut_job_line WHERE id = g_no AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-AUT-037', 'البند غير موجود', 'Line not found');
    END;
    j := get_job(l.job_card_id, TRUE);
    assert_editable(j);
    l_qty := NVL(jn(l_o, 'qty'), l.quantity);
    l_price := CASE WHEN l_o.has('price') THEN jn(l_o, 'price') ELSE l.unit_price END;
    l_disc := CASE WHEN l_o.has('disc') THEN jn(l_o, 'disc') ELSE l.discount_amount END;
    l_payer := NVL(js(l_o, 'payer'), l.payer);
    l_tech := CASE WHEN l_o.has('tech') THEN jn(l_o, 'tech') ELSE l.technician_id END;
    l_min := CASE WHEN l_o.has('minutes') THEN jn(l_o, 'minutes') ELSE l.work_minutes END;
    l_notes := CASE WHEN l_o.has('notes') THEN js(l_o, 'notes') ELSE l.notes END;
    NOONA_CORE_PKG.assert(l_qty > 0 AND NVL(l_price, 0) >= 0 AND NVL(l_disc, 0) >= 0, 'NOONA-AUT-038', 'الكمية موجبة والسعر والخصم غير سالبين',
                          'Invalid quantity, price or discount');
    IF l.line_type = 'PART' AND l_qty > l.quantity THEN
      l_have := NOONA_INV_PKG.on_hand(l.item_id, j.warehouse_id);
      SELECT NVL(SUM(quantity), 0) INTO l_used FROM aut_job_line
       WHERE job_card_id = j.id AND item_id = l.item_id AND line_type = 'PART' AND line_status <> 'CANCELLED' AND id <> l.id;
      NOONA_CORE_PKG.assert(l_have - l_used >= l_qty, 'NOONA-AUT-033', 'الكمية المتاحة في المستودع ' || TO_CHAR(GREATEST(l_have - l_used, 0)) || ' فقط',
                            'Insufficient stock');
    END IF;
    UPDATE aut_job_line SET quantity = l_qty, unit_price = l_price, discount_amount = l_disc, payer = l_payer, technician_id = l_tech,
                            work_minutes = l_min, notes = l_notes
     WHERE id = l.id;
    recalc(j.id);
  END update_line;

  PROCEDURE remove_line(p_line_id IN NUMBER) IS
    l_job NUMBER;
    j     aut_job_card%ROWTYPE;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    SELECT MAX(job_card_id) INTO l_job FROM aut_job_line WHERE id = p_line_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_job IS NOT NULL, 'NOONA-AUT-037', 'البند غير موجود', 'Line not found');
    j := get_job(l_job, TRUE);
    assert_editable(j);
    -- حذف الخدمة يحذف قطعها الافتراضية معها
    DELETE FROM aut_job_line WHERE parent_line_id = p_line_id;
    DELETE FROM aut_job_line WHERE id = p_line_id;
    recalc(l_job);
  END remove_line;

  PROCEDURE line_action(p_line_id IN NUMBER, p_action IN VARCHAR2) IS
    l aut_job_line%ROWTYPE;
    j aut_job_card%ROWTYPE;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    BEGIN
      SELECT * INTO l FROM aut_job_line WHERE id = p_line_id AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-AUT-037', 'البند غير موجود', 'Line not found');
    END;
    j := get_job(l.job_card_id, TRUE);
    assert_editable(j);
    IF p_action = 'START' THEN
      NOONA_CORE_PKG.assert(l.technician_id IS NOT NULL OR l.line_type = 'PART', 'NOONA-AUT-039', 'حدد الفني المنفذ قبل بدء البند',
                            'Assign a technician first');
      UPDATE aut_job_line SET line_status = 'IN_PROGRESS', started_at = NVL(started_at, SYSTIMESTAMP), done_at = NULL WHERE id = l.id;
      UPDATE aut_job_card SET status_code = CASE WHEN status_code IN ('OPEN', 'COMPLETED') THEN 'IN_PROGRESS' ELSE status_code END,
                              started_at = NVL(started_at, SYSTIMESTAMP)
       WHERE id = j.id;
    ELSIF p_action = 'DONE' THEN
      NOONA_CORE_PKG.assert(l.technician_id IS NOT NULL OR l.line_type = 'PART', 'NOONA-AUT-039', 'حدد الفني المنفذ قبل إنهاء البند',
                            'Assign a technician first');
      UPDATE aut_job_line SET line_status = 'DONE', done_at = SYSTIMESTAMP, started_at = NVL(started_at, SYSTIMESTAMP),
                              work_minutes = CASE WHEN started_at IS NOT NULL
                                                  THEN GREATEST(ROUND((CAST(SYSTIMESTAMP AS DATE) - CAST(started_at AS DATE)) * 1440), 1)
                                                  ELSE work_minutes END
       WHERE id = l.id;
      UPDATE aut_job_card SET status_code = CASE WHEN status_code = 'OPEN' THEN 'IN_PROGRESS' ELSE status_code END,
                              started_at = NVL(started_at, SYSTIMESTAMP)
       WHERE id = j.id;
    ELSIF p_action = 'RESET' THEN
      UPDATE aut_job_line SET line_status = 'PENDING', started_at = NULL, done_at = NULL WHERE id = l.id;
    ELSE
      NOONA_CORE_PKG.raise_error('NOONA-AUT-040', 'إجراء غير معروف: ' || p_action, 'Unknown action');
    END IF;
  END line_action;

  FUNCTION open_job(p_doc IN CLOB) RETURN NUMBER IS
    l_o    JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_veh  NUMBER := jn(l_o, 'vehicle');
    l_id   NUMBER;
    l_cust NUMBER := jn(l_o, 'cust');
    v      aut_vehicle%ROWTYPE;
    l_n    NUMBER;
    l_svc  JSON_ARRAY_T;
    l_x    NUMBER;
    l_doc  CLOB;
    l_insp CLOB;
    l_payer VARCHAR2(30) := NVL(js(l_o, 'payer'), 'CUSTOMER');
    l_ins  NUMBER := jn(l_o, 'insurer');
    l_ded  NUMBER := jn(l_o, 'deductible');
    l_odo  NUMBER := jn(l_o, 'odometer');
    l_wh   NUMBER := NVL(jn(l_o, 'wh'), default_warehouse);
    l_appt NUMBER := jn(l_o, 'appointment');
    l_bay NUMBER := jn(l_o, 'bay'); l_fuel VARCHAR2(30) := js(l_o, 'fuel'); l_comp VARCHAR2(4000) := js(l_o, 'complaint');
    l_prom TIMESTAMP := jts(l_o, 'promised'); l_adv VARCHAR2(200) := NVL(js(l_o, 'advisor'), SYS_CONTEXT('NOONA_CTX', 'USERNAME'));
    l_claim VARCHAR2(50) := js(l_o, 'claim'); l_pol VARCHAR2(50) := js(l_o, 'policy'); l_acc VARCHAR2(50) := js(l_o, 'accident');
    l_phone VARCHAR2(30);
  BEGIN
    guard('AUT_JOB_CARD.CREATE');
    IF l_veh IS NULL AND js(l_o, 'plate') IS NOT NULL THEN
      l_veh := vehicle_by_plate(js(l_o, 'plate'));
      IF l_veh IS NULL THEN
        NOONA_CORE_PKG.assert(l_payer <> 'INSURANCE' OR l_ins IS NOT NULL, 'NOONA-AUT-044', 'حدد شركة التأمين', 'Insurer is required');
        SELECT JSON_OBJECT('plate' VALUE JSON_VALUE(p_doc, '$.plate'), 'make' VALUE JSON_VALUE(p_doc, '$.make'), 'model' VALUE JSON_VALUE(p_doc, '$.model'),
                           'year' VALUE JSON_VALUE(p_doc, '$.year' RETURNING NUMBER), 'color' VALUE JSON_VALUE(p_doc, '$.color'),
                           'vin' VALUE JSON_VALUE(p_doc, '$.vin'), 'cust' VALUE JSON_VALUE(p_doc, '$.cust' RETURNING NUMBER),
                           'ownerName' VALUE JSON_VALUE(p_doc, '$.ownerName'), 'ownerPhone' VALUE JSON_VALUE(p_doc, '$.ownerPhone'),
                           'odometer' VALUE JSON_VALUE(p_doc, '$.odometer' RETURNING NUMBER), 'insurer' VALUE JSON_VALUE(p_doc, '$.insurer' RETURNING NUMBER)
                           ABSENT ON NULL RETURNING CLOB)
          INTO l_doc FROM dual;
        l_veh := save_vehicle(l_doc);
      END IF;
    END IF;
    NOONA_CORE_PKG.assert(l_veh IS NOT NULL, 'NOONA-AUT-041', 'حدد المركبة أو رقم اللوحة', 'Vehicle is required');
    SELECT * INTO v FROM aut_vehicle WHERE id = l_veh AND company_id = company;
    -- لا يفتح أمران للمركبة نفسها
    SELECT COUNT(*) INTO l_n FROM aut_job_card WHERE vehicle_id = l_veh AND status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED');
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-AUT-042', 'للمركبة ' || plate_label(v.plate_no) || ' أمر إصلاح مفتوح', 'Vehicle already has an open job card');
    NOONA_CORE_PKG.assert(l_odo IS NULL OR v.odometer IS NULL OR l_odo >= v.odometer, 'NOONA-AUT-043',
                          'قراءة العداد أقل من آخر قراءة مسجلة (' || v.odometer || ')', 'Odometer is lower than the last reading');
    NOONA_CORE_PKG.assert(l_payer <> 'INSURANCE' OR NVL(l_ins, v.insurer_id) IS NOT NULL, 'NOONA-AUT-044', 'حدد شركة التأمين', 'Insurer is required');
    -- مركبة مسجلة بلا مالك: يربط المالك المذكور عند الاستلام
    IF l_cust IS NULL AND v.customer_account_id IS NULL AND (js(l_o, 'ownerName') IS NOT NULL OR js(l_o, 'ownerPhone') IS NOT NULL) THEN
      l_cust := owner_account(js(l_o, 'ownerName'), js(l_o, 'ownerPhone'));
      v.owner_name := NVL(v.owner_name, js(l_o, 'ownerName')); v.owner_phone := NVL(v.owner_phone, js(l_o, 'ownerPhone'));
      UPDATE aut_vehicle SET customer_account_id = l_cust, owner_name = v.owner_name, owner_phone = v.owner_phone WHERE id = v.id;
    END IF;
    l_cust := NVL(l_cust, v.customer_account_id);
    l_phone := NVL(js(l_o, 'phone'), NVL(v.owner_phone, v.driver_phone));
    IF l_o.has('inspection') THEN l_insp := l_o.get_object('inspection').to_clob; END IF;
    IF l_payer = 'INSURANCE' THEN
      l_ins := NVL(l_ins, v.insurer_id);
      SELECT NVL(l_ded, MAX(default_deductible)) INTO l_ded FROM aut_insurer WHERE id = l_ins;
    END IF;
    g_doc := next_no(c_job, 'JC-');
    INSERT INTO aut_job_card (company_id, doc_no, doc_date, vehicle_id, customer_account_id, customer_name, customer_phone, appointment_id, bay_id,
                              advisor_name, checkin_at, promised_at, odometer_in, fuel_level, complaint, inspection, payer_type, insurer_id, claim_no,
                              policy_no, accident_report_no, claim_status, deductible_amount, warehouse_id, services_amount, parts_amount, discount_amount,
                              tax_amount, total_amount, status_code)
    VALUES (company, g_doc, TRUNC(SYSDATE), l_veh, l_cust, NVL(v.owner_name, NOONA_SAL_PKG.customer_label(l_cust)), l_phone, l_appt,
            l_bay, l_adv, SYSTIMESTAMP, l_prom, l_odo, l_fuel, l_comp, l_insp, l_payer, CASE WHEN l_payer = 'INSURANCE' THEN l_ins END,
            l_claim, NVL(l_pol, v.policy_no), l_acc, CASE WHEN l_payer = 'INSURANCE' THEN 'NOT_SUBMITTED' END, l_ded, l_wh, 0, 0, 0, 0, 0, 'OPEN')
    RETURNING id INTO l_id;
    UPDATE aut_vehicle SET odometer = GREATEST(NVL(odometer, 0), NVL(l_odo, 0)), last_visit_at = SYSTIMESTAMP WHERE id = l_veh;
    IF l_appt IS NOT NULL THEN
      UPDATE aut_appointment SET status_code = 'ARRIVED', job_card_id = l_id, vehicle_id = l_veh WHERE id = l_appt AND company_id = company;
    END IF;
    IF l_o.has('services') THEN
      l_svc := l_o.get_array('services');
      FOR k IN 0 .. l_svc.get_size - 1 LOOP
        l_x := add_service(l_id, l_svc.get_number(k));
      END LOOP;
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_job, l_id, 'CHECK_IN', 'SUCCESS');
    RETURN l_id;
  END open_job;

  PROCEDURE update_job(p_doc IN CLOB) IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    j    aut_job_card%ROWTYPE;
    l_payer VARCHAR2(30);
    l_ins NUMBER;
    l_cst VARCHAR2(30);
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(jn(l_o, 'id'), TRUE);
    assert_editable(j);
    l_payer := NVL(js(l_o, 'payer'), j.payer_type);
    l_ins := CASE WHEN l_o.has('insurer') THEN jn(l_o, 'insurer') ELSE j.insurer_id END;
    NOONA_CORE_PKG.assert(l_payer <> 'INSURANCE' OR l_ins IS NOT NULL, 'NOONA-AUT-044', 'حدد شركة التأمين', 'Insurer is required');
    IF l_o.has('diagnosis') THEN j.diagnosis := js(l_o, 'diagnosis'); END IF;
    IF l_o.has('recommendations') THEN j.recommendations := js(l_o, 'recommendations'); END IF;
    IF l_o.has('complaint') THEN j.complaint := js(l_o, 'complaint'); END IF;
    IF l_o.has('notes') THEN j.notes := js(l_o, 'notes'); END IF;
    IF l_o.has('promised') THEN j.promised_at := jts(l_o, 'promised'); END IF;
    IF l_o.has('bay') THEN j.bay_id := jn(l_o, 'bay'); END IF;
    IF l_o.has('cust') THEN j.customer_account_id := jn(l_o, 'cust'); END IF;
    IF l_o.has('phone') THEN j.customer_phone := js(l_o, 'phone'); END IF;
    IF l_o.has('claim') THEN j.claim_no := js(l_o, 'claim'); END IF;
    IF l_o.has('policy') THEN j.policy_no := js(l_o, 'policy'); END IF;
    IF l_o.has('accident') THEN j.accident_report_no := js(l_o, 'accident'); END IF;
    IF l_o.has('approved') THEN j.approved_amount := jn(l_o, 'approved'); END IF;
    IF l_o.has('deductible') THEN j.deductible_amount := jn(l_o, 'deductible'); END IF;
    l_cst := js(l_o, 'claimStatus');
    UPDATE aut_job_card SET
      diagnosis = j.diagnosis,
      recommendations = j.recommendations,
      complaint = j.complaint,
      notes = j.notes,
      promised_at = j.promised_at,
      bay_id = j.bay_id,
      customer_account_id = j.customer_account_id,
      customer_phone = j.customer_phone,
      claim_no = j.claim_no,
      policy_no = j.policy_no,
      accident_report_no = j.accident_report_no,
      approved_amount = j.approved_amount,
      deductible_amount = j.deductible_amount,
      payer_type = l_payer,
      insurer_id = CASE WHEN l_payer = 'INSURANCE' THEN l_ins END,
      claim_status = CASE WHEN l_payer = 'INSURANCE' THEN NVL(l_cst, NVL(claim_status, 'NOT_SUBMITTED')) END
     WHERE id = j.id;
    IF l_payer <> j.payer_type THEN
      -- تغيير جهة السداد ينقل البنود التي كانت على الجهة السابقة
      UPDATE aut_job_line SET payer = CASE l_payer WHEN 'INSURANCE' THEN 'INSURANCE' WHEN 'WARRANTY' THEN 'WARRANTY' ELSE 'CUSTOMER' END
       WHERE job_card_id = j.id AND payer = CASE j.payer_type WHEN 'INSURANCE' THEN 'INSURANCE' WHEN 'WARRANTY' THEN 'WARRANTY' ELSE 'CUSTOMER' END;
      recalc(j.id);
    END IF;
  END update_job;

  PROCEDURE set_job_status(p_job_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2 DEFAULT NULL) IS
    j     aut_job_card%ROWTYPE;
    l_n   NUMBER;
    l_days NUMBER;
    l_km  NUMBER;
  BEGIN
    guard(CASE WHEN p_status = 'CANCELLED' THEN 'AUT_JOB_CARD.CANCEL' ELSE 'AUT_JOB_CARD.UPDATE' END);
    j := get_job(p_job_id, TRUE);
    assert_editable(j);
    IF p_status IN ('IN_PROGRESS', 'WAITING_PARTS') THEN
      UPDATE aut_job_card SET status_code = p_status, started_at = NVL(started_at, SYSTIMESTAMP), completed_at = NULL WHERE id = j.id;
    ELSIF p_status = 'COMPLETED' THEN
      SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE job_card_id = j.id AND line_status <> 'CANCELLED';
      NOONA_CORE_PKG.assert(l_n > 0, 'NOONA-AUT-045', 'أمر الإصلاح بلا بنود', 'Job card has no lines');
      SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE job_card_id = j.id AND line_type IN ('SERVICE', 'SUBLET') AND line_status NOT IN ('DONE', 'CANCELLED');
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-AUT-046', l_n || ' خدمة لم تنجز بعد؛ أنهها أو احذفها', 'Some services are not done');
      SELECT COUNT(*) INTO l_n FROM aut_job_line WHERE job_card_id = j.id AND line_type IN ('SERVICE', 'SUBLET') AND line_status = 'DONE'
         AND technician_id IS NULL;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-AUT-039', 'حدد الفني المنفذ لكل خدمة', 'Assign a technician to every service');
      -- الخدمة التالية: أقرب موعد وأقرب عداد من خدمات الأمر
      SELECT MIN(s.next_service_days), MIN(s.next_service_km) INTO l_days, l_km
        FROM aut_job_line l JOIN aut_service s ON s.id = l.service_id WHERE l.job_card_id = j.id AND l.line_status = 'DONE';
      UPDATE aut_job_card SET status_code = 'COMPLETED', completed_at = SYSTIMESTAMP, started_at = NVL(started_at, SYSTIMESTAMP),
                              next_service_date = CASE WHEN l_days IS NOT NULL THEN TRUNC(SYSDATE) + l_days END,
                              next_service_km = CASE WHEN l_km IS NOT NULL THEN NVL(odometer_in, 0) + l_km END
       WHERE id = j.id;
      NOONA_API_PKG.publish('AUT_JOB_CARD.READY', c_job, j.id);
    ELSIF p_status = 'CANCELLED' THEN
      NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-AUT-047', 'سبب الإلغاء مطلوب', 'Reason is required');
      UPDATE aut_job_line SET line_status = 'CANCELLED' WHERE job_card_id = j.id;
      UPDATE aut_job_card SET status_code = 'CANCELLED', cancel_reason = p_reason WHERE id = j.id;
      UPDATE aut_appointment SET status_code = 'CANCELLED', cancel_reason = p_reason WHERE job_card_id = j.id;
    ELSE
      NOONA_CORE_PKG.raise_error('NOONA-AUT-048', 'حالة غير صحيحة: ' || p_status, 'Invalid status');
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_job, j.id, 'STATUS_' || p_status, 'SUCCESS', p_reason => p_reason);
  END set_job_status;

  -- ================================================================ الفوترة والتسليم
  FUNCTION sal_line(l aut_job_line%ROWTYPE, p_disc NUMBER, p_zero BOOLEAN) RETURN JSON_OBJECT_T IS
    o JSON_OBJECT_T := JSON_OBJECT_T();
  BEGIN
    IF l.line_type = 'PART' THEN
      o.put('i', l.item_id);
    ELSE
      o.put('d', l.description);
      o.put('acc', c_rev);
    END IF;
    o.put('q', l.quantity);
    o.put('p', CASE WHEN p_zero THEN 0 ELSE l.unit_price END);
    o.put('inc', l.price_includes_tax);
    IF NOT p_zero AND NVL(p_disc, 0) > 0 THEN o.put('disc', p_disc); END IF;
    RETURN o;
  END sal_line;

  FUNCTION invoice_job(p_job_id IN NUMBER, p_doc IN CLOB DEFAULT NULL) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(NVL(p_doc, '{}'));
    j        aut_job_card%ROWTYPE;
    l_place  VARCHAR2(30) := js(l_o, 'place');
    l_cust   NUMBER;
    l_insacc NUMBER;
    l_cl     JSON_ARRAY_T := JSON_ARRAY_T();
    l_il     JSON_ARRAY_T := JSON_ARRAY_T();
    l_x      JSON_OBJECT_T;
    l_d      JSON_OBJECT_T;
    l_r      NUMBER := 0;
    l_insnet NUMBER := 0;
    l_factor NUMBER := 1;
    l_gross  NUMBER;
    l_cinv   NUMBER;
    l_iinv   NUMBER;
    l_sub    NUMBER;
    l_extra  NUMBER;
    l_plate  VARCHAR2(30);
    l_split  BOOLEAN := FALSE;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(p_job_id, TRUE);
    NOONA_CORE_PKG.assert(j.status_code = 'COMPLETED', 'NOONA-AUT-050', 'أنه العمل أولاً (جاهزة للتسليم) ثم افتر', 'Complete the job before invoicing');
    recalc(j.id);
    j := get_job(j.id);
    SELECT plate_label(plate_no) INTO l_plate FROM aut_vehicle WHERE id = j.vehicle_id;
    -- تكلفة القطع وقت البيع (لتقارير الربحية)
    UPDATE aut_job_line SET unit_cost = NOONA_INV_PKG.avg_cost(item_id)
     WHERE job_card_id = j.id AND line_type = 'PART' AND line_status <> 'CANCELLED';
    SELECT NVL(SUM(net_amount), 0) INTO l_r FROM aut_job_line WHERE job_card_id = j.id AND payer = 'INSURANCE' AND line_status <> 'CANCELLED';
    IF j.payer_type = 'INSURANCE' AND l_r > 0 THEN
      SELECT MAX(customer_account_id) INTO l_insacc FROM aut_insurer WHERE id = j.insurer_id;
      NOONA_CORE_PKG.assert(l_insacc IS NOT NULL, 'NOONA-AUT-051', 'شركة التأمين بلا حساب ذمة؛ عدلها من الإعداد', 'Insurer has no AR account');
      NOONA_CORE_PKG.assert(NVL(j.claim_status, 'NOT_SUBMITTED') <> 'REJECTED', 'NOONA-AUT-052',
                            'المطالبة مرفوضة؛ حول جهة السداد إلى العميل', 'Claim rejected: change payer to customer');
      -- حصة التأمين = المعتمد (أو كامل المبلغ) ناقص تحمل العميل
      l_insnet := GREATEST(LEAST(NVL(j.approved_amount, l_r), l_r) - NVL(j.deductible_amount, 0), 0);
      l_factor := l_insnet / l_r;
      l_split := l_insnet > 0;
    END IF;
    FOR l IN (SELECT * FROM aut_job_line WHERE job_card_id = j.id AND line_status <> 'CANCELLED' ORDER BY line_no) LOOP
      IF l.payer = 'INSURANCE' AND l_split THEN
        l_gross := ROUND(l.quantity * l.unit_price, 2);
        l_il.append(sal_line(l, NVL(l.discount_amount, 0) + ROUND((l_gross - NVL(l.discount_amount, 0)) * (1 - l_factor), 2), FALSE));
      ELSE
        l_cl.append(sal_line(l, l.discount_amount, l.payer = 'WARRANTY'));
      END IF;
    END LOOP;
    IF l_split THEN
      l_d := JSON_OBJECT_T();
      l_d.put('cust', l_insacc); l_d.put('wh', j.warehouse_id); l_d.put('mode', 'CREDIT'); l_d.put('action', 'POST');
      l_d.put('notes', 'مطالبة تأمين ' || NVL(j.claim_no, '-') || ' - أمر ' || j.doc_no || ' - لوحة ' || l_plate);
      l_d.put('lines', l_il);
      l_iinv := NOONA_SAL_PKG.save_invoice(l_d.to_clob);
      -- ما لم يغطه التأمين (التحمل وفرق الاعتماد) على العميل بالفرق الفعلي بعد التقريب
      SELECT subtotal INTO l_sub FROM sal_invoice WHERE id = l_iinv;
      l_extra := ROUND(l_r - l_sub, 2);
      IF l_extra > 0 THEN
        l_x := JSON_OBJECT_T();
        l_x.put('d', 'حصة العميل من الإصلاح المؤمن (التحمل وفرق الاعتماد) - مطالبة ' || NVL(j.claim_no, '-'));
        l_x.put('acc', c_rev); l_x.put('q', 1); l_x.put('p', l_extra); l_x.put('inc', 'N');
        l_cl.append(l_x);
      END IF;
    END IF;
    IF l_cl.get_size > 0 THEN
      l_cust := NVL(j.customer_account_id, NOONA_SAL_PKG.walk_in_customer);
      l_d := JSON_OBJECT_T();
      l_d.put('cust', l_cust); l_d.put('wh', j.warehouse_id); l_d.put('action', 'POST');
      l_d.put('mode', CASE WHEN l_place IS NOT NULL THEN 'CASH' ELSE 'CREDIT' END);
      IF l_place IS NOT NULL THEN
        l_d.put('place', l_place); l_d.put('method', NVL(js(l_o, 'method'), 'CASH'));
      END IF;
      IF j.customer_account_id IS NULL THEN l_d.put('name', j.customer_name); END IF;
      l_d.put('notes', 'أمر إصلاح ' || j.doc_no || ' - لوحة ' || l_plate);
      l_d.put('lines', l_cl);
      l_cinv := NOONA_SAL_PKG.save_invoice(l_d.to_clob);
    END IF;
    UPDATE aut_job_card SET status_code = 'INVOICED', sales_invoice_id = l_cinv, insurer_invoice_id = l_iinv,
                            claim_status = CASE WHEN l_iinv IS NOT NULL AND NVL(claim_status, 'NOT_SUBMITTED') = 'NOT_SUBMITTED' THEN 'SUBMITTED'
                                                ELSE claim_status END
     WHERE id = j.id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_job, j.id, 'INVOICE', 'SUCCESS',
                              p_new_values => JSON_OBJECT('customerInvoice' VALUE l_cinv, 'insurerInvoice' VALUE l_iinv));
    RETURN NVL(l_cinv, l_iinv);
  END invoice_job;

  PROCEDURE deliver_job(p_job_id IN NUMBER, p_odometer_out IN NUMBER DEFAULT NULL) IS
    j aut_job_card%ROWTYPE;
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(p_job_id, TRUE);
    NOONA_CORE_PKG.assert(j.status_code = 'INVOICED', 'NOONA-AUT-053', 'تسلم السيارة بعد الفوترة', 'Invoice before delivery');
    NOONA_CORE_PKG.assert(p_odometer_out IS NULL OR j.odometer_in IS NULL OR p_odometer_out >= j.odometer_in, 'NOONA-AUT-043',
                          'عداد التسليم أقل من عداد الاستلام', 'Odometer out is lower than odometer in');
    UPDATE aut_job_card SET status_code = 'DELIVERED', delivered_at = SYSTIMESTAMP, odometer_out = NVL(p_odometer_out, odometer_in) WHERE id = j.id;
    UPDATE aut_vehicle SET odometer = GREATEST(NVL(odometer, 0), NVL(p_odometer_out, NVL(j.odometer_in, 0))), last_visit_at = SYSTIMESTAMP,
                           next_service_date = NVL(j.next_service_date, next_service_date), next_service_km = NVL(j.next_service_km, next_service_km)
     WHERE id = j.vehicle_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_job, j.id, 'DELIVER', 'SUCCESS');
  END deliver_job;

  PROCEDURE set_claim(p_doc IN CLOB) IS
    l_o JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    j   aut_job_card%ROWTYPE;
    l_st VARCHAR2(30) := js(l_o, 'claimStatus');
  BEGIN
    guard('AUT_JOB_CARD.UPDATE');
    j := get_job(jn(l_o, 'job'), TRUE);
    NOONA_CORE_PKG.assert(j.payer_type = 'INSURANCE', 'NOONA-AUT-054', 'الأمر ليس على شركة تأمين', 'Not an insurance job');
    NOONA_CORE_PKG.assert(l_st IS NULL OR l_st IN ('NOT_SUBMITTED', 'SUBMITTED', 'APPROVED', 'PARTIALLY_APPROVED', 'REJECTED', 'PAID'),
                          'NOONA-AUT-055', 'حالة مطالبة غير صحيحة', 'Invalid claim status');
    NOONA_CORE_PKG.assert(NOT (l_o.has('approved') AND j.status_code IN ('INVOICED', 'DELIVERED')), 'NOONA-AUT-056',
                          'لا يعدل المبلغ المعتمد بعد الفوترة', 'Approved amount cannot change after invoicing');
    IF l_o.has('approved') THEN j.approved_amount := jn(l_o, 'approved'); END IF;
    g_doc := js(l_o, 'claim');
    UPDATE aut_job_card SET claim_no = NVL(g_doc, claim_no), claim_status = NVL(l_st, claim_status), approved_amount = j.approved_amount
     WHERE id = j.id;
  END set_claim;

  -- ================================================================ الحجوزات
  FUNCTION book(p_doc IN CLOB) RETURN NUMBER IS
    l_o     JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id    NUMBER;
    l_start TIMESTAMP := jts(l_o, 'start');
    l_min   NUMBER := jn(l_o, 'minutes');
    l_end   TIMESTAMP;
    l_bay   NUMBER := jn(l_o, 'bay');
    l_veh   NUMBER := jn(l_o, 'vehicle');
    l_ids   VARCHAR2(1000);
    l_svc   JSON_ARRAY_T;
    l_n     NUMBER;
    l_name  VARCHAR2(400) := js(l_o, 'name');
    l_phone VARCHAR2(30) := js(l_o, 'phone');
    l_plate VARCHAR2(30) := plate_key(js(l_o, 'plate'));
    l_tech NUMBER := jn(l_o, 'tech'); l_comp VARCHAR2(2000) := js(l_o, 'complaint'); l_src VARCHAR2(30) := NVL(js(l_o, 'source'), 'PHONE');
  BEGIN
    guard('AUT_APPOINTMENT.CREATE');
    NOONA_CORE_PKG.assert(l_start IS NOT NULL, 'NOONA-AUT-060', 'حدد موعد الوصول', 'Start time is required');
    NOONA_CORE_PKG.assert(l_start >= SYSTIMESTAMP - INTERVAL '1' HOUR, 'NOONA-AUT-061', 'الموعد في الماضي', 'Appointment is in the past');
    IF l_veh IS NULL AND l_plate IS NOT NULL THEN
      l_veh := vehicle_by_plate(l_plate);
    END IF;
    NOONA_CORE_PKG.assert(l_veh IS NOT NULL OR (l_plate IS NOT NULL AND (l_name IS NOT NULL OR l_phone IS NOT NULL)), 'NOONA-AUT-062',
                          'حدد المركبة، أو اللوحة مع اسم العميل أو جواله', 'Vehicle or plate with customer is required');
    IF l_veh IS NOT NULL THEN
      SELECT NVL(l_name, owner_name), NVL(l_phone, NVL(owner_phone, driver_phone)), plate_no INTO l_name, l_phone, l_plate
        FROM aut_vehicle WHERE id = l_veh AND company_id = company;
    END IF;
    IF l_o.has('services') THEN
      l_svc := l_o.get_array('services');
      FOR k IN 0 .. l_svc.get_size - 1 LOOP
        l_ids := l_ids || CASE WHEN l_ids IS NOT NULL THEN ',' END || l_svc.get_number(k);
      END LOOP;
      IF l_min IS NULL THEN
        SELECT SUM(standard_minutes) INTO l_min FROM aut_service
         WHERE id IN (SELECT TO_NUMBER(column_value) FROM TABLE(apex_string.split(l_ids, ','))) AND company_id = company;
      END IF;
    END IF;
    l_end := l_start + NUMTODSINTERVAL(NVL(l_min, 60), 'MINUTE');
    IF l_bay IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM aut_appointment
       WHERE bay_id = l_bay AND company_id = company AND status_code IN ('BOOKED', 'CONFIRMED', 'ARRIVED') AND start_at < l_end AND end_at > l_start;
      NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-AUT-063', 'الرافعة محجوزة في هذا الوقت', 'Bay is already booked at this time');
    END IF;
    g_doc := next_no(c_appt, 'BK-');
    INSERT INTO aut_appointment (company_id, doc_no, doc_date, vehicle_id, plate_no, customer_name, phone, start_at, end_at, bay_id, technician_id,
                                 service_ids, complaint, source_code, status_code)
    VALUES (company, g_doc, TRUNC(CAST(l_start AS DATE)), l_veh, l_plate, l_name, l_phone, l_start, l_end, l_bay, l_tech,
            l_ids, l_comp, l_src, 'BOOKED')
    RETURNING id INTO l_id;
    RETURN l_id;
  END book;

  PROCEDURE set_appointment_status(p_appointment_id IN NUMBER, p_status IN VARCHAR2, p_reason IN VARCHAR2 DEFAULT NULL) IS
    l_st VARCHAR2(30);
  BEGIN
    guard(CASE WHEN p_status = 'CANCELLED' THEN 'AUT_APPOINTMENT.CANCEL' ELSE 'AUT_APPOINTMENT.UPDATE' END);
    SELECT MAX(status_code) INTO l_st FROM aut_appointment WHERE id = p_appointment_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_st IN ('BOOKED', 'CONFIRMED'), 'NOONA-AUT-064', 'الحجز ليس قائماً', 'Appointment is not open');
    NOONA_CORE_PKG.assert(p_status IN ('CONFIRMED', 'CANCELLED', 'NO_SHOW'), 'NOONA-AUT-065', 'حالة غير صحيحة', 'Invalid status');
    NOONA_CORE_PKG.assert(p_status <> 'CANCELLED' OR TRIM(p_reason) IS NOT NULL, 'NOONA-AUT-047', 'سبب الإلغاء مطلوب', 'Reason is required');
    UPDATE aut_appointment SET status_code = p_status, cancel_reason = CASE WHEN p_status = 'CANCELLED' THEN p_reason END WHERE id = p_appointment_id;
  END set_appointment_status;

  FUNCTION mark_no_shows RETURN NUMBER IS
  BEGIN
    guard('AUT_APPOINTMENT.UPDATE');
    UPDATE aut_appointment SET status_code = 'NO_SHOW'
     WHERE company_id = company AND status_code IN ('BOOKED', 'CONFIRMED') AND start_at < SYSTIMESTAMP - INTERVAL '2' HOUR;
    RETURN SQL%ROWCOUNT;
  END mark_no_shows;

  FUNCTION check_in(p_appointment_id IN NUMBER, p_doc IN CLOB DEFAULT NULL) RETURN NUMBER IS
    a    aut_appointment%ROWTYPE;
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(NVL(p_doc, '{}'));
    l_s  JSON_ARRAY_T := JSON_ARRAY_T();
  BEGIN
    guard('AUT_JOB_CARD.CREATE');
    BEGIN
      SELECT * INTO a FROM aut_appointment WHERE id = p_appointment_id AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-AUT-066', 'الحجز غير موجود', 'Appointment not found');
    END;
    NOONA_CORE_PKG.assert(a.status_code IN ('BOOKED', 'CONFIRMED'), 'NOONA-AUT-064', 'الحجز ليس قائماً', 'Appointment is not open');
    l_o.put('appointment', a.id);
    IF a.vehicle_id IS NOT NULL THEN l_o.put('vehicle', a.vehicle_id);
    ELSIF NOT l_o.has('plate') THEN l_o.put('plate', a.plate_no);
    END IF;
    -- مركبة جديدة من الحجز: الشركة المصنعة إلزامية للتسجيل؛ تستكمل لاحقاً من بطاقة المركبة
    IF a.vehicle_id IS NULL AND js(l_o, 'make') IS NULL THEN l_o.put('make', 'غير محدد'); END IF;
    IF NOT l_o.has('ownerName') AND a.customer_name IS NOT NULL THEN l_o.put('ownerName', a.customer_name); END IF;
    IF NOT l_o.has('ownerPhone') AND a.phone IS NOT NULL THEN l_o.put('ownerPhone', a.phone); END IF;
    IF NOT l_o.has('bay') AND a.bay_id IS NOT NULL THEN l_o.put('bay', a.bay_id); END IF;
    IF NOT l_o.has('complaint') AND a.complaint IS NOT NULL THEN l_o.put('complaint', a.complaint); END IF;
    IF NOT l_o.has('services') AND a.service_ids IS NOT NULL THEN
      FOR s IN (SELECT TO_NUMBER(column_value) v FROM TABLE(apex_string.split(a.service_ids, ','))) LOOP
        l_s.append(s.v);
      END LOOP;
      l_o.put('services', l_s);
    END IF;
    RETURN open_job(l_o.to_clob);
  END check_in;

  -- ================================================================ واجهة أمر الإصلاح
  FUNCTION boot_json RETURN CLOB IS
    l_cat  CLOB;
    l_tech CLOB;
    l_bay  CLOB;
    l_ins  CLOB;
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE c.id, 'name' VALUE c.name_ar, 'icon' VALUE NVL(c.icon, 'fa-wrench'), 'color' VALUE c.color,
             'services' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE s.id, 'name' VALUE s.name_ar, 'price' VALUE s.price,
                                                               'inc' VALUE s.price_includes_tax, 'minutes' VALUE s.standard_minutes,
                                                               'icon' VALUE NVL(s.icon, c.icon),
                                                               'parts' VALUE (SELECT COUNT(*) FROM aut_service_part p WHERE p.service_id = s.id))
                                                   ORDER BY s.sort_order NULLS LAST, s.name_ar RETURNING CLOB)
                                 FROM aut_service s WHERE s.category_id = c.id AND s.is_active = 'Y') FORMAT JSON)
                         ORDER BY c.sort_order NULLS LAST, c.name_ar RETURNING CLOB)
      INTO l_cat FROM aut_service_category c WHERE c.company_id = company AND c.is_active = 'Y';
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'name' VALUE name_ar, 'specialty' VALUE specialty) ORDER BY name_ar RETURNING CLOB)
      INTO l_tech FROM aut_technician WHERE company_id = company AND is_active = 'Y';
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'name' VALUE name_ar) ORDER BY sort_order NULLS LAST, code RETURNING CLOB)
      INTO l_bay FROM aut_bay WHERE company_id = company AND is_active = 'Y';
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'name' VALUE name_ar) ORDER BY name_ar RETURNING CLOB)
      INTO l_ins FROM aut_insurer WHERE company_id = company AND status_code = 'ACTIVE';
    RETURN '{"cats":' || NVL(l_cat, '[]') || ',"techs":' || NVL(l_tech, '[]') || ',"bays":' || NVL(l_bay, '[]') || ',"insurers":' || NVL(l_ins, '[]')
        || ',"places":' || NOONA_CSH_PKG.places_json || ',"methods":' || NOONA_PUR_PKG.payment_methods_json || '}';
  END boot_json;

  FUNCTION job_json(p_job_id IN NUMBER) RETURN CLOB IS
    j     aut_job_card%ROWTYPE;
    l_h   CLOB;
    l_l   CLOB;
    l_veh CLOB;
    l_r   NUMBER;
    l_ins NUMBER;
    l_cinv VARCHAR2(50); l_iinv VARCHAR2(50); l_insname VARCHAR2(400);
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    j := get_job(p_job_id);
    SELECT MAX(doc_no) INTO l_cinv FROM sal_invoice WHERE id = j.sales_invoice_id;
    SELECT MAX(doc_no) INTO l_iinv FROM sal_invoice WHERE id = j.insurer_invoice_id;
    SELECT MAX(name_ar) INTO l_insname FROM aut_insurer WHERE id = j.insurer_id;
    SELECT NVL(SUM(net_amount), 0) INTO l_r FROM aut_job_line WHERE job_card_id = j.id AND payer = 'INSURANCE' AND line_status <> 'CANCELLED';
    l_ins := CASE WHEN j.payer_type = 'INSURANCE' THEN GREATEST(LEAST(NVL(j.approved_amount, l_r), l_r) - NVL(j.deductible_amount, 0), 0) END;
    l_veh := vehicle_json(j.vehicle_id);
    SELECT JSON_OBJECT('id' VALUE j.id, 'no' VALUE j.doc_no, 'status' VALUE j.status_code, 'statusLabel' VALUE status_label(j.status_code),
                       'checkin' VALUE ts(j.checkin_at), 'promised' VALUE ts(j.promised_at), 'started' VALUE ts(j.started_at),
                       'completed' VALUE ts(j.completed_at), 'delivered' VALUE ts(j.delivered_at),
                       'hours' VALUE ROUND((CAST(NVL(j.delivered_at, SYSTIMESTAMP) AS DATE) - CAST(j.checkin_at AS DATE)) * 24, 1),
                       'late' VALUE CASE WHEN j.promised_at < NVL(j.delivered_at, SYSTIMESTAMP) AND j.status_code NOT IN ('CANCELLED') THEN 'Y' ELSE 'N' END,
                       'cust' VALUE j.customer_account_id, 'custName' VALUE j.customer_name, 'phone' VALUE j.customer_phone,
                       'bay' VALUE j.bay_id, 'advisor' VALUE j.advisor_name, 'odoIn' VALUE j.odometer_in, 'odoOut' VALUE j.odometer_out,
                       'fuel' VALUE j.fuel_level, 'complaint' VALUE j.complaint, 'diagnosis' VALUE j.diagnosis, 'recommendations' VALUE j.recommendations,
                       'notes' VALUE j.notes, 'payer' VALUE j.payer_type, 'insurer' VALUE j.insurer_id, 'insurerName' VALUE l_insname,
                       'claim' VALUE j.claim_no, 'policy' VALUE j.policy_no, 'accident' VALUE j.accident_report_no, 'claimStatus' VALUE j.claim_status,
                       'approved' VALUE j.approved_amount, 'deductible' VALUE j.deductible_amount, 'insuredNet' VALUE l_r, 'insurerShare' VALUE l_ins,
                       'services' VALUE j.services_amount, 'parts' VALUE j.parts_amount, 'discount' VALUE j.discount_amount, 'tax' VALUE j.tax_amount,
                       'total' VALUE j.total_amount, 'invoice' VALUE j.sales_invoice_id, 'invoiceNo' VALUE l_cinv, 'insInvoice' VALUE j.insurer_invoice_id,
                       'insInvoiceNo' VALUE l_iinv, 'nextDate' VALUE TO_CHAR(j.next_service_date, 'YYYY-MM-DD'), 'nextKm' VALUE j.next_service_km,
                       'editable' VALUE CASE WHEN j.status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED') THEN 'Y' ELSE 'N' END,
                       'inspection' VALUE j.inspection FORMAT JSON RETURNING CLOB)
      INTO l_h FROM dual;
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE l.id, 'no' VALUE l.line_no, 'type' VALUE l.line_type, 'typeLabel' VALUE line_type_label(l.line_type),
                                     'service' VALUE l.service_id, 'item' VALUE l.item_id, 'parent' VALUE l.parent_line_id, 'desc' VALUE l.description,
                                     'qty' VALUE l.quantity, 'price' VALUE l.unit_price, 'inc' VALUE l.price_includes_tax, 'disc' VALUE l.discount_amount,
                                     'net' VALUE l.net_amount, 'tax' VALUE l.tax_amount, 'payer' VALUE l.payer, 'payerLabel' VALUE payer_label(l.payer),
                                     'tech' VALUE l.technician_id, 'techName' VALUE t.name_ar, 'minutes' VALUE l.work_minutes,
                                     'started' VALUE ts(l.started_at), 'done' VALUE ts(l.done_at), 'status' VALUE l.line_status,
                                     'statusLabel' VALUE status_label(l.line_status), 'notes' VALUE l.notes,
                                     'onHand' VALUE CASE WHEN l.line_type = 'PART' THEN NOONA_INV_PKG.on_hand(l.item_id, j.warehouse_id) END)
                         ORDER BY NVL(l.parent_line_id, l.id), l.line_no RETURNING CLOB)
      INTO l_l FROM aut_job_line l LEFT JOIN aut_technician t ON t.id = l.technician_id
     WHERE l.job_card_id = j.id AND l.line_status <> 'CANCELLED';
    RETURN '{"job":' || l_h || ',"vehicle":' || l_veh || ',"lines":' || NVL(l_l, '[]') || '}';
  END job_json;

  FUNCTION search_parts_json(p_q IN VARCHAR2, p_job_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_raw  VARCHAR2(200) := TRIM(p_q);
    l_key  VARCHAR2(200) := plate_key(p_q);
    l_t1 VARCHAR2(100); l_t2 VARCHAR2(100); l_t3 VARCHAR2(100); l_t4 VARCHAR2(100);
    l_wh   NUMBER;
    l_make VARCHAR2(100); l_model VARCHAR2(100); l_year NUMBER;
    l_c    CLOB;
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    IF LENGTH(l_raw) < 2 THEN RETURN '[]'; END IF;
    l_t1 := LOWER(REGEXP_SUBSTR(l_raw, '[^ ]+', 1, 1)); l_t2 := LOWER(REGEXP_SUBSTR(l_raw, '[^ ]+', 1, 2));
    l_t3 := LOWER(REGEXP_SUBSTR(l_raw, '[^ ]+', 1, 3)); l_t4 := LOWER(REGEXP_SUBSTR(l_raw, '[^ ]+', 1, 4));
    IF p_job_id IS NOT NULL THEN
      SELECT MAX(j.warehouse_id), MAX(UPPER(v.make)), MAX(UPPER(v.model)), MAX(v.model_year) INTO l_wh, l_make, l_model, l_year
        FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id WHERE j.id = p_job_id AND j.company_id = company;
    END IF;
    l_wh := NVL(l_wh, default_warehouse);
    WITH m AS (
      SELECT id, MIN(rk) rk FROM (
        SELECT b.item_id id, 0 rk FROM inv_item_barcode b WHERE b.barcode = l_raw AND b.is_active = 'Y'
        UNION ALL
        SELECT i.id, 1 FROM inv_item i
         WHERE plate_key(i.item_no) = l_key OR plate_key(i.item_code) = l_key OR plate_key(i.manufacturer_part_no) = l_key
        UNION ALL
        SELECT i.id, 2 FROM inv_item i
         WHERE LENGTH(l_key) >= 3 AND (plate_key(i.item_no) LIKE l_key || '%' OR plate_key(i.item_code) LIKE l_key || '%'
                                       OR plate_key(i.manufacturer_part_no) LIKE '%' || l_key || '%')
        UNION ALL
        SELECT i.id, 3 FROM (
          SELECT i.id, LOWER(i.name_ar || ' ' || i.name_en || ' ' || i.brand || ' ' || i.manufacturer || ' ' || i.manufacturer_part_no || ' '
                             || i.item_no || ' ' || i.item_code || ' '
                             || (SELECT LISTAGG(f.vehicle_make || ' ' || f.vehicle_model || ' ' || f.engine, ' ') WITHIN GROUP (ORDER BY f.id)
                                   FROM inv_item_fitment f WHERE f.item_id = i.id)) hay
            FROM inv_item i) i
         WHERE INSTR(i.hay, l_t1) > 0 AND (l_t2 IS NULL OR INSTR(i.hay, l_t2) > 0) AND (l_t3 IS NULL OR INSTR(i.hay, l_t3) > 0)
           AND (l_t4 IS NULL OR INSTR(i.hay, l_t4) > 0))
      GROUP BY id),
    a AS (
      SELECT x.alt_item_id id, 5 rk FROM inv_item_alternate x JOIN m ON m.id = x.item_id
      UNION
      SELECT x.item_id, 5 FROM inv_item_alternate x JOIN m ON m.id = x.alt_item_id),
    r AS (
      SELECT id, MIN(rk) rk FROM (SELECT id, rk FROM m UNION ALL SELECT id, rk FROM a) GROUP BY id)
    SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE id, 'no' VALUE item_no, 'name' VALUE name_ar, 'brand' VALUE brand, 'mpn' VALUE mpn,
                                     'price' VALUE price, 'inc' VALUE inc, 'onHand' VALUE onhand, 'fits' VALUE fits,
                                     'alt' VALUE CASE WHEN rk = 5 THEN 'Y' ELSE 'N' END, 'barcode' VALUE bc)
                         ORDER BY CASE WHEN rk = 5 THEN 1 ELSE 0 END, CASE fits WHEN 'Y' THEN 0 WHEN 'N' THEN 2 ELSE 1 END, rk, name_ar RETURNING CLOB)
      INTO l_c
      FROM (SELECT r.rk, i.id, i.item_no, i.name_ar, i.brand, i.manufacturer_part_no mpn, c.sale_price price, NVL(c.prices_include_tax, 'N') inc,
                   NOONA_INV_PKG.on_hand(i.id, l_wh) onhand,
                   (SELECT MIN(b.barcode) FROM inv_item_barcode b WHERE b.item_id = i.id) bc,
                   CASE WHEN l_make IS NULL THEN NULL
                        WHEN NOT EXISTS (SELECT 1 FROM inv_item_fitment f WHERE f.item_id = i.id) THEN NULL
                        WHEN EXISTS (SELECT 1 FROM inv_item_fitment f WHERE f.item_id = i.id AND UPPER(f.vehicle_make) = l_make
                                        AND (f.vehicle_model IS NULL OR UPPER(f.vehicle_model) = l_model)
                                        AND (l_year IS NULL OR l_year BETWEEN NVL(f.year_from, 1900) AND NVL(f.year_to, 2999))) THEN 'Y'
                        ELSE 'N' END fits
              FROM r JOIN inv_item i ON i.id = r.id
              LEFT JOIN inv_item_company c ON c.item_id = i.id AND c.company_id = company
             WHERE i.status_code = 'ACTIVE' AND i.is_sellable = 'Y' AND i.item_type NOT IN ('SERVICE', 'ASSET', 'REAL_ESTATE_UNIT')
             ORDER BY r.rk FETCH FIRST 40 ROWS ONLY);
    RETURN NVL(l_c, '[]');
  END search_parts_json;

  FUNCTION job_print(p_job_id IN NUMBER) RETURN CLOB IS
    j   aut_job_card%ROWTYPE;
    v   aut_vehicle%ROWTYPE;
    l_h CLOB;
    l_ins VARCHAR2(400);
  BEGIN
    guard('AUT_JOB_CARD.PRINT');
    j := get_job(p_job_id);
    SELECT * INTO v FROM aut_vehicle WHERE id = j.vehicle_id;
    SELECT MAX(name_ar) INTO l_ins FROM aut_insurer WHERE id = j.insurer_id;
    l_h := '<div class="nn-aut-print"><div class="nn-aut-ph"><div><h2>' || esc(NOONA_APEX_PKG.company_name) || '</h2><div>أمر إصلاح <b>'
        || esc(j.doc_no) || '</b></div></div><div class="nn-aut-plate">' || esc(plate_label(v.plate_no)) || '</div></div>'
        || '<table class="nn-aut-kv"><tr><th>المركبة</th><td>' || esc(v.make || ' ' || v.model || ' ' || v.model_year || ' ' || v.color) || '</td>'
        || '<th>رقم الهيكل</th><td dir="ltr">' || esc(v.vin) || '</td></tr><tr><th>العميل</th><td>' || esc(j.customer_name) || '</td><th>الجوال</th><td dir="ltr">'
        || esc(j.customer_phone) || '</td></tr><tr><th>الاستلام</th><td>' || ts(j.checkin_at) || '</td><th>التسليم المتوقع</th><td>' || ts(j.promised_at)
        || '</td></tr><tr><th>العداد</th><td>' || j.odometer_in || CASE WHEN j.odometer_out IS NOT NULL THEN ' ← ' || j.odometer_out END
        || ' كم</td><th>جهة السداد</th><td>' || esc(payer_label(j.payer_type)) || CASE WHEN l_ins IS NOT NULL THEN ' - ' || esc(l_ins) || ' (مطالبة '
        || esc(j.claim_no) || ')' END || '</td></tr></table>'
        || CASE WHEN j.complaint IS NOT NULL THEN '<p><b>شكوى العميل:</b> ' || esc(j.complaint) || '</p>' END
        || CASE WHEN j.diagnosis IS NOT NULL THEN '<p><b>التشخيص:</b> ' || esc(j.diagnosis) || '</p>' END
        || '<table class="nn-prj-t"><thead><tr><th>#</th><th>النوع</th><th>البيان</th><th>الفني</th><th class="n">الكمية</th><th class="n">السعر</th>'
        || '<th class="n">الصافي</th><th>على</th></tr></thead><tbody>';
    FOR l IN (SELECT l.*, t.name_ar tech FROM aut_job_line l LEFT JOIN aut_technician t ON t.id = l.technician_id
               WHERE l.job_card_id = j.id AND l.line_status <> 'CANCELLED' ORDER BY NVL(l.parent_line_id, l.id), l.line_no) LOOP
      l_h := l_h || ('<tr><td>' || l.line_no || '</td><td>' || esc(line_type_label(l.line_type)) || '</td><td>' || esc(l.description) || '</td><td>'
          || esc(l.tech) || '</td><td class="n">' || l.quantity || '</td><td class="n">' || fmt(l.unit_price) || '</td><td class="n">' || fmt(l.net_amount)
          || '</td><td>' || esc(payer_label(l.payer)) || '</td></tr>');
    END LOOP;
    l_h := l_h || ('</tbody><tfoot><tr><th colspan="6">الخدمات</th><th class="n">' || fmt(j.services_amount) || '</th><th></th></tr>'
        || '<tr><th colspan="6">القطع</th><th class="n">' || fmt(j.parts_amount) || '</th><th></th></tr>'
        || '<tr><th colspan="6">الضريبة</th><th class="n">' || fmt(j.tax_amount) || '</th><th></th></tr>'
        || '<tr><th colspan="6">الإجمالي</th><th class="n">' || fmt(j.total_amount) || '</th><th></th></tr></tfoot></table>'
        || CASE WHEN j.recommendations IS NOT NULL THEN '<p><b>توصيات:</b> ' || esc(j.recommendations) || '</p>' END
        || CASE WHEN j.next_service_date IS NOT NULL OR j.next_service_km IS NOT NULL THEN '<p><b>الخدمة التالية:</b> '
             || TO_CHAR(j.next_service_date, 'YYYY-MM-DD') || CASE WHEN j.next_service_km IS NOT NULL THEN ' أو عند ' || j.next_service_km || ' كم' END
             || '</p>' END
        || '<div class="nn-aut-sign"><div>توقيع العميل</div><div>مستشار الخدمة: ' || esc(j.advisor_name) || '</div></div></div>');
    RETURN l_h;
  END job_print;

  -- ================================================================ الحجوزات والمركبات (شاشات)
  FUNCTION appointments_html(p_date IN DATE) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('AUT_APPOINTMENT.VIEW');
    l_h := '<table class="nn-prj-t nn-aut-appts"><thead><tr><th>الوقت</th><th>الرافعة</th><th>اللوحة</th><th>العميل</th><th>الجوال</th><th>الخدمات</th>'
        || '<th>الحالة</th><th></th></tr></thead><tbody>';
    FOR a IN (SELECT a.*, b.name_ar bay, (SELECT LISTAGG(s.name_ar, '، ') WITHIN GROUP (ORDER BY s.name_ar) FROM aut_service s
                                           WHERE s.id IN (SELECT TO_NUMBER(column_value) FROM TABLE(apex_string.split(a.service_ids, ','))))
                     svcs, j.doc_no job_no
                FROM aut_appointment a LEFT JOIN aut_bay b ON b.id = a.bay_id LEFT JOIN aut_job_card j ON j.id = a.job_card_id
               WHERE a.company_id = company AND a.start_at >= CAST(p_date AS TIMESTAMP) AND a.start_at < CAST(p_date + 1 AS TIMESTAMP)
               ORDER BY a.start_at, b.sort_order) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-appt="' || a.id || '"><td>' || TO_CHAR(a.start_at, 'HH24:MI') || ' - ' || TO_CHAR(a.end_at, 'HH24:MI') || '</td><td>'
          || esc(a.bay) || '</td><td><b>' || esc(plate_label(a.plate_no)) || '</b></td><td>' || esc(a.customer_name) || '</td><td dir="ltr">' || esc(a.phone)
          || '</td><td><small>' || esc(a.svcs) || CASE WHEN a.complaint IS NOT NULL THEN '<br>' || esc(a.complaint) END || '</small></td><td>'
          || badge(a.status_code) || CASE WHEN a.job_no IS NOT NULL THEN ' <small>' || esc(a.job_no) || '</small>' END || '</td><td class="nn-aut-act">'
          || CASE WHEN a.status_code IN ('BOOKED', 'CONFIRMED') THEN
               '<button type="button" class="t-Button t-Button--small t-Button--success" data-act="CHECKIN" data-id="' || a.id || '">استلام</button> '
               || CASE WHEN a.status_code = 'BOOKED' THEN '<button type="button" class="t-Button t-Button--small" data-act="CONFIRM" data-id="' || a.id
                       || '">تأكيد</button> ' END
               || '<button type="button" class="t-Button t-Button--small" data-act="NOSHOW" data-id="' || a.id || '">لم يحضر</button> '
               || '<button type="button" class="t-Button t-Button--small t-Button--danger" data-act="CANCEL" data-id="' || a.id || '">إلغاء</button>' END
          || '</td></tr>');
    END LOOP;
    IF l_n = 0 THEN RETURN TO_CLOB('<div class="nn-empty">لا توجد حجوزات في ') || TO_CHAR(p_date, 'YYYY-MM-DD') || '</div>'; END IF;
    RETURN l_h || ('</tbody></table>');
  END appointments_html;

  FUNCTION vehicle_html(p_vehicle_id IN NUMBER) RETURN CLOB IS
    v   aut_vehicle%ROWTYPE;
    l_h CLOB;
    l_n PLS_INTEGER := 0;
    l_spent NUMBER;
  BEGIN
    guard('AUT_VEHICLE.VIEW');
    SELECT * INTO v FROM aut_vehicle WHERE id = p_vehicle_id AND company_id = company;
    SELECT NVL(SUM(total_amount), 0) INTO l_spent FROM aut_job_card WHERE vehicle_id = v.id AND status_code IN ('INVOICED', 'DELIVERED');
    l_h := '<div class="nn-prj-chips"><span class="nn-aut-plate">' || esc(plate_label(v.plate_no)) || '</span><span>' || esc(v.make || ' ' || v.model || ' ' || v.model_year)
        || '</span>' || CASE WHEN v.color IS NOT NULL THEN '<span>' || esc(v.color) || '</span>' END || '<span>' || esc(v.owner_name) || ' ' || esc(v.owner_phone) || '</span><span>العداد ' || NVL(TO_CHAR(v.odometer), '-')
        || '</span><span>إجمالي الإنفاق ' || fmt(l_spent) || '</span>'
        || CASE WHEN v.next_service_date IS NOT NULL OR v.next_service_km IS NOT NULL THEN '<span class="' || CASE WHEN v.next_service_date <= TRUNC(SYSDATE)
             THEN 'is-danger' ELSE 'is-info' END || '">الخدمة التالية ' || TO_CHAR(v.next_service_date, 'YYYY-MM-DD')
             || CASE WHEN v.next_service_km IS NOT NULL THEN ' / ' || v.next_service_km || ' كم' END || '</span>' END
        || CASE WHEN v.policy_expiry IS NOT NULL THEN '<span>التأمين حتى ' || TO_CHAR(v.policy_expiry, 'YYYY-MM-DD') || '</span>' END || '</div>'
        || '<table class="nn-prj-t"><thead><tr><th>الأمر</th><th>الاستلام</th><th>العداد</th><th>الخدمات والقطع</th><th>الفنيون</th><th class="n">الإجمالي</th>'
        || '<th>الحالة</th></tr></thead><tbody>';
    FOR j IN (SELECT j.*, (SELECT LISTAGG(l.description, '، ') WITHIN GROUP (ORDER BY l.line_no) FROM aut_job_line l
                            WHERE l.job_card_id = j.id AND l.line_status <> 'CANCELLED') work,
                     (SELECT LISTAGG(DISTINCT t.name_ar, '، ') WITHIN GROUP (ORDER BY t.name_ar) FROM aut_job_line l JOIN aut_technician t ON t.id = l.technician_id
                       WHERE l.job_card_id = j.id) techs
                FROM aut_job_card j WHERE j.vehicle_id = v.id ORDER BY j.checkin_at DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-job="' || j.id || '"><td><b>' || esc(j.doc_no) || '</b></td><td>' || ts(j.checkin_at) || '</td><td>' || j.odometer_in
          || '</td><td><small>' || esc(SUBSTR(j.work, 1, 300)) || '</small></td><td>' || esc(j.techs) || '</td><td class="n">' || fmt(j.total_amount)
          || '</td><td>' || badge(j.status_code) || '</td></tr>');
    END LOOP;
    RETURN l_h || (CASE WHEN l_n = 0 THEN '<tr><td colspan="7" class="nn-empty">لا زيارات بعد</td></tr>' END || '</tbody></table>');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<div class="nn-empty">اختر مركبة</div>';
  END vehicle_html;

  -- ================================================================ لوحة التحكم
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_cls VARCHAR2 DEFAULT 'is-info') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_cls || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div><div class="nn-kpi-value">'
        || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION summary_html RETURN CLOB IS
    l_co NUMBER := company;
    l_open NUMBER; l_ready NUMBER; l_late NUMBER; l_today NUMBER; l_appt NUMBER; l_rev NUMBER; l_month NUMBER; l_claims NUMBER; l_due NUMBER;
    l_d0 TIMESTAMP := CAST(TRUNC(SYSDATE) AS TIMESTAMP);
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    SELECT COUNT(CASE WHEN status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('COMPLETED', 'INVOICED') THEN 1 END),
           COUNT(CASE WHEN status_code IN ('OPEN', 'IN_PROGRESS', 'WAITING_PARTS', 'COMPLETED') AND promised_at < SYSTIMESTAMP THEN 1 END),
           COUNT(CASE WHEN checkin_at >= l_d0 THEN 1 END),
           NVL(SUM(CASE WHEN status_code IN ('INVOICED', 'DELIVERED') AND completed_at >= l_d0 THEN total_amount END), 0),
           NVL(SUM(CASE WHEN status_code IN ('INVOICED', 'DELIVERED') AND completed_at >= CAST(TRUNC(SYSDATE, 'MM') AS TIMESTAMP) THEN total_amount END), 0),
           COUNT(CASE WHEN claim_status IN ('SUBMITTED', 'APPROVED', 'PARTIALLY_APPROVED') THEN 1 END)
      INTO l_open, l_ready, l_late, l_today, l_rev, l_month, l_claims
      FROM aut_job_card WHERE company_id = l_co;
    SELECT COUNT(*) INTO l_appt FROM aut_appointment
     WHERE company_id = l_co AND status_code IN ('BOOKED', 'CONFIRMED') AND start_at >= l_d0 AND start_at < l_d0 + 1;
    SELECT COUNT(*) INTO l_due FROM aut_vehicle WHERE company_id = l_co AND status_code = 'ACTIVE' AND next_service_date <= TRUNC(SYSDATE) + 7;
    RETURN '<div class="nn-kpis">' || kpi('مركبات في الورشة', l_open, 'fa-car', 'is-info')
        || kpi('جاهزة / بانتظار التسليم', l_ready, 'fa-check-circle', 'is-success')
        || kpi('متأخرة عن الموعد', l_late, 'fa-clock-o', CASE WHEN l_late > 0 THEN 'is-danger' ELSE 'is-info' END)
        || kpi('استلام اليوم', l_today, 'fa-sign-in', 'is-info') || kpi('حجوزات اليوم المتبقية', l_appt, 'fa-calendar', 'is-warning')
        || kpi('مبيعات اليوم', fmt(l_rev), 'fa-money', 'is-success') || kpi('مبيعات الشهر', fmt(l_month), 'fa-line-chart', 'is-success')
        || kpi('مطالبات تأمين مفتوحة', l_claims, 'fa-shield', 'is-warning') || kpi('خدمات مستحقة خلال أسبوع', l_due, 'fa-bell', 'is-warning')
        || '</div>';
  END summary_html;

  FUNCTION board_html RETURN CLOB IS
    l_h CLOB := '<div class="nn-aut-board">';
    l_n PLS_INTEGER;
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    FOR c IN (SELECT 'OPEN' st, 'بانتظار البدء' t FROM dual UNION ALL SELECT 'IN_PROGRESS', 'قيد العمل' FROM dual
              UNION ALL SELECT 'WAITING_PARTS', 'بانتظار قطع' FROM dual UNION ALL SELECT 'COMPLETED', 'جاهزة للفوترة' FROM dual
              UNION ALL SELECT 'INVOICED', 'بانتظار التسليم' FROM dual) LOOP
      l_h := l_h || ('<div class="nn-aut-col" data-status="' || c.st || '"><div class="nn-aut-colh">' || esc(c.t) || '</div>');
      l_n := 0;
      FOR j IN (SELECT j.*, v.plate_no, v.make, v.model, b.name_ar bay,
                       (SELECT LISTAGG(DISTINCT t.name_ar, '، ') WITHIN GROUP (ORDER BY t.name_ar) FROM aut_job_line l
                          JOIN aut_technician t ON t.id = l.technician_id WHERE l.job_card_id = j.id AND l.line_status <> 'CANCELLED') techs,
                       (SELECT COUNT(*) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.line_type = 'SERVICE' AND l.line_status = 'DONE') done,
                       (SELECT COUNT(*) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.line_type = 'SERVICE' AND l.line_status <> 'CANCELLED') svc
                  FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id LEFT JOIN aut_bay b ON b.id = j.bay_id
                 WHERE j.company_id = company AND j.status_code = c.st ORDER BY j.promised_at NULLS LAST, j.checkin_at) LOOP
        l_n := l_n + 1;
        l_h := l_h || ('<a class="nn-aut-job' || CASE WHEN j.promised_at < SYSTIMESTAMP THEN ' is-late' END || '" data-job="' || j.id
            || '" href="javascript:void(0)"><div class="nn-aut-plate">' || esc(plate_label(j.plate_no)) || '</div><div><b>' || esc(j.doc_no) || '</b> '
            || esc(j.make || ' ' || j.model) || '</div><div><small>' || esc(j.customer_name) || '</small></div>'
            || '<div class="nn-aut-meta"><span class="fa fa-clock-o"></span> ' || TO_CHAR(j.promised_at, 'MM-DD HH24:MI')
            || CASE WHEN j.bay IS NOT NULL THEN ' · ' || esc(j.bay) END || CASE WHEN j.svc > 0 THEN ' · ' || j.done || '/' || j.svc END || '</div>'
            || CASE WHEN j.techs IS NOT NULL THEN '<div class="nn-aut-meta"><span class="fa fa-user"></span> ' || esc(j.techs) || '</div>' END
            || CASE WHEN j.payer_type = 'INSURANCE' THEN '<span class="nn-badge is-warning">تأمين</span>' END || '</a>');
      END LOOP;
      IF l_n = 0 THEN l_h := l_h || ('<div class="nn-empty">—</div>'); END IF;
      l_h := l_h || ('</div>');
    END LOOP;
    RETURN l_h || ('</div>');
  END board_html;

  -- ================================================================ التقارير
  FUNCTION report_label(p_kind IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_kind
      WHEN 'SUMMARY' THEN 'إجمالي العمليات (خدمات وقطع) يومياً'
      WHEN 'SERVICES' THEN 'تقرير الخدمات المنفذة'
      WHEN 'PARTS' THEN 'تقرير مبيعات قطع الغيار'
      WHEN 'TOP_SERVICES' THEN 'أكثر الخدمات طلباً'
      WHEN 'TOP_PARTS' THEN 'أكثر قطع الغيار مبيعاً'
      WHEN 'TECHNICIANS' THEN 'إنتاجية الفنيين وعمولاتهم'
      WHEN 'STAY' THEN 'مدة بقاء المركبات والالتزام بالموعد'
      WHEN 'INSURANCE' THEN 'مطالبات شركات التأمين'
      WHEN 'APPOINTMENTS' THEN 'الحجوزات حسب الحالة والمصدر'
      WHEN 'DUE' THEN 'خدمات وتأمين واستمارات مستحقة'
      WHEN 'MAKES' THEN 'العمليات حسب الشركة المصنعة والطراز'
      WHEN 'VEHICLES' THEN 'أعلى المركبات والعملاء إنفاقاً'
      ELSE p_kind END;
  END report_label;

  FUNCTION report_html(p_kind IN VARCHAR2, p_from IN DATE, p_to IN DATE, p_param IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_co   NUMBER := company;
    l_f    TIMESTAMP := CAST(TRUNC(NVL(p_from, TRUNC(SYSDATE, 'MM'))) AS TIMESTAMP);
    l_t    TIMESTAMP := CAST(TRUNC(NVL(p_to, SYSDATE)) + 1 AS TIMESTAMP);
    l_h    CLOB;
    l_n    PLS_INTEGER := 0;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0; s4 NUMBER := 0; s5 NUMBER := 0; s6 NUMBER := 0;
    PROCEDURE head(p_cols VARCHAR2) IS
    BEGIN
      l_h := '<div class="nn-rpt-h"><h3>' || esc(report_label(p_kind)) || '</h3><small>من ' || TO_CHAR(l_f, 'YYYY-MM-DD') || ' إلى '
          || TO_CHAR(l_t - 1, 'YYYY-MM-DD') || '</small></div><table class="nn-prj-t nn-aut-rpt"><thead><tr>';
      FOR c IN (SELECT column_value v FROM TABLE(apex_string.split(p_cols, '|'))) LOOP
        l_h := l_h || (CASE WHEN c.v LIKE '#%' THEN '<th class="n">' || esc(SUBSTR(c.v, 2)) ELSE '<th>' || esc(c.v) END || '</th>');
      END LOOP;
      l_h := l_h || ('</tr></thead><tbody>');
    END head;
    PROCEDURE r(p VARCHAR2) IS BEGIN l_n := l_n + 1; l_h := l_h || ('<tr>' || p || '</tr>'); END r;
    FUNCTION c(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN '<td>' || esc(p) || '</td>'; END c;
    FUNCTION n(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN '<td class="n">' || fmt(p) || '</td>'; END n;
    FUNCTION q(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN '<td class="n">' || RTRIM(RTRIM(TO_CHAR(p, 'FM999G999G990D99'), '0'), '.') || '</td>'; END q;
    FUNCTION foot(p VARCHAR2) RETURN CLOB IS
    BEGIN
      RETURN l_h || (CASE WHEN l_n = 0 THEN '<tr><td colspan="20" class="nn-empty">لا توجد بيانات في الفترة</td></tr>' END || '</tbody>'
          || CASE WHEN l_n > 0 AND p IS NOT NULL THEN '<tfoot><tr>' || p || '</tr></tfoot>' END || '</table>');
    END foot;
  BEGIN
    guard('AUT_JOB_CARD.EXPORT');
    IF p_kind = 'SUMMARY' THEN
      head('اليوم|#أوامر|#خدمات|#قطع|#الخصم|#الضريبة|#الإجمالي|#تكلفة القطع|#مجمل الربح');
      FOR x IN (SELECT TRUNC(CAST(j.completed_at AS DATE)) d, COUNT(*) jobs, SUM(j.services_amount) svc, SUM(j.parts_amount) prt,
                       SUM(j.discount_amount) disc, SUM(j.tax_amount) tax, SUM(j.total_amount) tot,
                       SUM((SELECT NVL(SUM(l.quantity * l.unit_cost), 0) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.line_type = 'PART'
                               AND l.line_status <> 'CANCELLED')) cost
                  FROM aut_job_card j WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                 GROUP BY TRUNC(CAST(j.completed_at AS DATE)) ORDER BY 1) LOOP
        r(c(TO_CHAR(x.d, 'YYYY-MM-DD')) || q(x.jobs) || n(x.svc) || n(x.prt) || n(x.disc) || n(x.tax) || n(x.tot) || n(x.cost) || n(x.svc + x.prt - x.cost));
        s1 := s1 + x.jobs; s2 := s2 + x.svc; s3 := s3 + x.prt; s4 := s4 + x.tax; s5 := s5 + x.tot; s6 := s6 + x.cost;
      END LOOP;
      RETURN foot('<th>الإجمالي</th>' || q(s1) || n(s2) || n(s3) || '<td></td>' || n(s4) || n(s5) || n(s6) || n(s2 + s3 - s6));
    ELSIF p_kind = 'SERVICES' THEN
      head('التاريخ|الأمر|اللوحة|الخدمة|الفني|#الدقائق|على|#الصافي');
      FOR x IN (SELECT j.completed_at, j.doc_no, v.plate_no, l.description, t.name_ar tech, l.work_minutes, l.payer, l.net_amount
                  FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN aut_vehicle v ON v.id = j.vehicle_id
                  LEFT JOIN aut_technician t ON t.id = l.technician_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                   AND l.line_type IN ('SERVICE', 'SUBLET') AND l.line_status <> 'CANCELLED'
                   AND (p_param IS NULL OR l.service_id = TO_NUMBER(p_param))
                 ORDER BY j.completed_at, l.line_no) LOOP
        r(c(ts(x.completed_at)) || c(x.doc_no) || c(plate_label(x.plate_no)) || c(x.description) || c(x.tech) || q(x.work_minutes) || c(payer_label(x.payer)) || n(x.net_amount));
        s1 := s1 + NVL(x.work_minutes, 0); s2 := s2 + NVL(x.net_amount, 0);
      END LOOP;
      RETURN foot('<th colspan="5">الإجمالي</th>' || q(s1) || '<td></td>' || n(s2));
    ELSIF p_kind = 'PARTS' THEN
      head('التاريخ|الأمر|اللوحة|القطعة|رقم القطعة|#الكمية|#السعر|#الصافي|#التكلفة|#الربح');
      FOR x IN (SELECT j.completed_at, j.doc_no, v.plate_no, l.description, i.item_no, l.quantity, l.unit_price, l.net_amount,
                       l.quantity * NVL(l.unit_cost, 0) cost
                  FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN aut_vehicle v ON v.id = j.vehicle_id
                  LEFT JOIN inv_item i ON i.id = l.item_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                   AND l.line_type = 'PART' AND l.line_status <> 'CANCELLED' AND (p_param IS NULL OR l.item_id = TO_NUMBER(p_param))
                 ORDER BY j.completed_at, l.line_no) LOOP
        r(c(ts(x.completed_at)) || c(x.doc_no) || c(plate_label(x.plate_no)) || c(x.description) || c(x.item_no) || q(x.quantity) || n(x.unit_price) || n(x.net_amount)
          || n(x.cost) || n(x.net_amount - x.cost));
        s1 := s1 + x.quantity; s2 := s2 + NVL(x.net_amount, 0); s3 := s3 + x.cost;
      END LOOP;
      RETURN foot('<th colspan="5">الإجمالي</th>' || q(s1) || '<td></td>' || n(s2) || n(s3) || n(s2 - s3));
    ELSIF p_kind = 'TOP_SERVICES' THEN
      head('#|الخدمة|الفئة|#مرات الطلب|#مركبات|#متوسط الدقائق|#الإيراد|#النسبة %');
      SELECT NVL(SUM(l.net_amount), 0) INTO s6 FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id
       WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
         AND l.line_type = 'SERVICE' AND l.line_status <> 'CANCELLED';
      FOR x IN (SELECT s.name_ar, g.name_ar cat, COUNT(*) cnt, COUNT(DISTINCT j.vehicle_id) veh, ROUND(AVG(l.work_minutes)) mins, SUM(l.net_amount) rev
                  FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN aut_service s ON s.id = l.service_id
                  JOIN aut_service_category g ON g.id = s.category_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                   AND l.line_type = 'SERVICE' AND l.line_status <> 'CANCELLED'
                 GROUP BY s.name_ar, g.name_ar ORDER BY cnt DESC, rev DESC FETCH FIRST NVL(TO_NUMBER(p_param), 20) ROWS ONLY) LOOP
        r('<td>' || (l_n + 1) || '</td>' || c(x.name_ar) || c(x.cat) || q(x.cnt) || q(x.veh) || q(x.mins) || n(x.rev)
          || q(CASE WHEN s6 > 0 THEN ROUND(x.rev * 100 / s6, 1) END));
        s1 := s1 + x.cnt; s2 := s2 + NVL(x.rev, 0);
      END LOOP;
      RETURN foot('<th colspan="3">الإجمالي</th>' || q(s1) || '<td></td><td></td>' || n(s2) || '<td></td>');
    ELSIF p_kind = 'TOP_PARTS' THEN
      head('#|القطعة|رقم القطعة|الماركة|#الكمية|#مرات البيع|#الإيراد|#التكلفة|#الربح|#الهامش %');
      FOR x IN (SELECT i.name_ar, i.item_no, i.brand, SUM(l.quantity) qty, COUNT(*) cnt, SUM(l.net_amount) rev, SUM(l.quantity * NVL(l.unit_cost, 0)) cost
                  FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN inv_item i ON i.id = l.item_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                   AND l.line_type = 'PART' AND l.line_status <> 'CANCELLED'
                 GROUP BY i.name_ar, i.item_no, i.brand
                 ORDER BY CASE WHEN p_param = 'VALUE' THEN SUM(l.net_amount) ELSE SUM(l.quantity) END DESC FETCH FIRST 30 ROWS ONLY) LOOP
        r('<td>' || (l_n + 1) || '</td>' || c(x.name_ar) || c(x.item_no) || c(x.brand) || q(x.qty) || q(x.cnt) || n(x.rev) || n(x.cost)
          || n(x.rev - x.cost) || q(CASE WHEN x.rev > 0 THEN ROUND((x.rev - x.cost) * 100 / x.rev, 1) END));
        s1 := s1 + x.qty; s2 := s2 + NVL(x.rev, 0); s3 := s3 + x.cost;
      END LOOP;
      RETURN foot('<th colspan="4">الإجمالي</th>' || q(s1) || '<td></td>' || n(s2) || n(s3) || n(s2 - s3) || '<td></td>');
    ELSIF p_kind = 'TECHNICIANS' THEN
      head('الفني|التخصص|#أوامر|#خدمات|#ساعات العمل|#إيراد الخدمات|#نسبة العمولة|#العمولة|#تكلفة الساعات');
      FOR x IN (SELECT t.name_ar, t.specialty, t.commission_pct, t.hourly_cost, COUNT(DISTINCT l.job_card_id) jobs, COUNT(*) cnt,
                       ROUND(NVL(SUM(l.work_minutes), 0) / 60, 1) hrs, NVL(SUM(l.net_amount), 0) rev
                  FROM aut_job_line l JOIN aut_job_card j ON j.id = l.job_card_id JOIN aut_technician t ON t.id = l.technician_id
                 WHERE j.company_id = l_co AND j.status_code IN ('COMPLETED', 'INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                   AND l.line_type = 'SERVICE' AND l.line_status = 'DONE'
                 GROUP BY t.name_ar, t.specialty, t.commission_pct, t.hourly_cost ORDER BY rev DESC) LOOP
        r(c(x.name_ar) || c(x.specialty) || q(x.jobs) || q(x.cnt) || q(x.hrs) || n(x.rev) || q(x.commission_pct)
          || n(ROUND(x.rev * NVL(x.commission_pct, 0) / 100, 2)) || n(ROUND(x.hrs * NVL(x.hourly_cost, 0), 2)));
        s1 := s1 + x.cnt; s2 := s2 + x.hrs; s3 := s3 + x.rev; s4 := s4 + ROUND(x.rev * NVL(x.commission_pct, 0) / 100, 2);
        s5 := s5 + ROUND(x.hrs * NVL(x.hourly_cost, 0), 2);
      END LOOP;
      RETURN foot('<th colspan="3">الإجمالي</th>' || q(s1) || q(s2) || n(s3) || '<td></td>' || n(s4) || n(s5));
    ELSIF p_kind = 'STAY' THEN
      head('الأمر|اللوحة|المركبة|الاستلام|الموعد المتوقع|التسليم|#ساعات البقاء|#ساعات العمل|التأخير|الحالة');
      FOR x IN (SELECT j.*, v.plate_no, v.make || ' ' || v.model veh,
                       ROUND((CAST(NVL(j.delivered_at, SYSTIMESTAMP) AS DATE) - CAST(j.checkin_at AS DATE)) * 24, 1) hrs,
                       (SELECT ROUND(NVL(SUM(l.work_minutes), 0) / 60, 1) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.line_status = 'DONE') whrs,
                       ROUND((CAST(NVL(j.delivered_at, SYSTIMESTAMP) AS DATE) - CAST(j.promised_at AS DATE)) * 24, 1) late
                  FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id
                 WHERE j.company_id = l_co AND j.checkin_at >= l_f AND j.checkin_at < l_t AND j.status_code <> 'CANCELLED'
                 ORDER BY hrs DESC) LOOP
        r(c(x.doc_no) || c(plate_label(x.plate_no)) || c(x.veh) || c(ts(x.checkin_at)) || c(ts(x.promised_at)) || c(ts(x.delivered_at)) || q(x.hrs) || q(x.whrs)
          || '<td>' || CASE WHEN x.late > 0 THEN '<span class="nn-badge is-danger">' || x.late || ' س</span>' ELSE '<span class="nn-badge is-success">في الموعد</span>' END
          || '</td><td>' || badge(x.status_code) || '</td>');
        s1 := s1 + x.hrs; s2 := s2 + CASE WHEN x.late > 0 THEN 1 ELSE 0 END;
      END LOOP;
      RETURN foot('<th colspan="6">متوسط البقاء ' || CASE WHEN l_n > 0 THEN ROUND(s1 / l_n, 1) END || ' ساعة · المتأخرة ' || s2 || ' من ' || l_n
                  || '</th><td colspan="4"></td>');
    ELSIF p_kind = 'INSURANCE' THEN
      head('شركة التأمين|#أوامر|#المطالب به|#المعتمد|#تحمل العملاء|#فاتورة التأمين|#مدفوعة|#معلقة|#مرفوضة');
      FOR x IN (SELECT i.name_ar, COUNT(*) jobs,
                       SUM((SELECT NVL(SUM(l.net_amount), 0) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.payer = 'INSURANCE' AND l.line_status <> 'CANCELLED')) claimed,
                       SUM(j.approved_amount) appr, SUM(j.deductible_amount) ded,
                       SUM((SELECT s.total_amount FROM sal_invoice s WHERE s.id = j.insurer_invoice_id)) inv,
                       COUNT(CASE WHEN j.claim_status = 'PAID' THEN 1 END) paid,
                       COUNT(CASE WHEN j.claim_status IN ('NOT_SUBMITTED', 'SUBMITTED', 'APPROVED', 'PARTIALLY_APPROVED') THEN 1 END) pend,
                       COUNT(CASE WHEN j.claim_status = 'REJECTED' THEN 1 END) rej
                  FROM aut_job_card j JOIN aut_insurer i ON i.id = j.insurer_id
                 WHERE j.company_id = l_co AND j.payer_type = 'INSURANCE' AND j.checkin_at >= l_f AND j.checkin_at < l_t AND j.status_code <> 'CANCELLED'
                 GROUP BY i.name_ar ORDER BY claimed DESC) LOOP
        r(c(x.name_ar) || q(x.jobs) || n(x.claimed) || n(x.appr) || n(x.ded) || n(x.inv) || q(x.paid) || q(x.pend) || q(x.rej));
        s1 := s1 + x.jobs; s2 := s2 + NVL(x.claimed, 0); s3 := s3 + NVL(x.appr, 0); s4 := s4 + NVL(x.ded, 0); s5 := s5 + NVL(x.inv, 0);
      END LOOP;
      RETURN foot('<th>الإجمالي</th>' || q(s1) || n(s2) || n(s3) || n(s4) || n(s5) || '<td colspan="3"></td>');
    ELSIF p_kind = 'APPOINTMENTS' THEN
      head('المصدر|#الحجوزات|#مؤكدة|#حضرت|#لم تحضر|#ملغاة|#نسبة الحضور %');
      FOR x IN (SELECT source_code, COUNT(*) tot, COUNT(CASE WHEN status_code = 'CONFIRMED' THEN 1 END) conf,
                       COUNT(CASE WHEN status_code = 'ARRIVED' THEN 1 END) arr, COUNT(CASE WHEN status_code = 'NO_SHOW' THEN 1 END) ns,
                       COUNT(CASE WHEN status_code = 'CANCELLED' THEN 1 END) can
                  FROM aut_appointment WHERE company_id = l_co AND start_at >= l_f AND start_at < l_t GROUP BY source_code ORDER BY tot DESC) LOOP
        r(c(CASE x.source_code WHEN 'PHONE' THEN 'هاتف' WHEN 'WALK_IN' THEN 'حضور مباشر' WHEN 'WHATSAPP' THEN 'واتساب' WHEN 'WEB' THEN 'الموقع' WHEN 'APP' THEN 'التطبيق' ELSE x.source_code END) || q(x.tot) || q(x.conf) || q(x.arr) || q(x.ns) || q(x.can)
          || q(CASE WHEN x.arr + x.ns > 0 THEN ROUND(x.arr * 100 / (x.arr + x.ns), 1) END));
        s1 := s1 + x.tot; s2 := s2 + x.arr; s3 := s3 + x.ns; s4 := s4 + x.can; s5 := s5 + x.conf;
      END LOOP;
      RETURN foot('<th>الإجمالي</th>' || q(s1) || q(s5) || q(s2) || q(s3) || q(s4) || q(CASE WHEN s2 + s3 > 0 THEN ROUND(s2 * 100 / (s2 + s3), 1) END));
    ELSIF p_kind = 'DUE' THEN
      head('اللوحة|المركبة|المالك|الجوال|البند|التاريخ|العداد');
      FOR x IN (SELECT * FROM (
                  SELECT v.plate_no, v.make || ' ' || v.model veh, v.owner_name, v.owner_phone, 'خدمة دورية' what, v.next_service_date d, v.next_service_km km
                    FROM aut_vehicle v WHERE v.company_id = l_co AND v.status_code = 'ACTIVE' AND v.next_service_date < l_t
                  UNION ALL
                  SELECT v.plate_no, v.make || ' ' || v.model, v.owner_name, v.owner_phone, 'انتهاء التأمين', v.policy_expiry, NULL
                    FROM aut_vehicle v WHERE v.company_id = l_co AND v.status_code = 'ACTIVE' AND v.policy_expiry < l_t
                  UNION ALL
                  SELECT v.plate_no, v.make || ' ' || v.model, v.owner_name, v.owner_phone, 'انتهاء الاستمارة', v.registration_expiry, NULL
                    FROM aut_vehicle v WHERE v.company_id = l_co AND v.status_code = 'ACTIVE' AND v.registration_expiry < l_t)
                ORDER BY d) LOOP
        r(c(plate_label(x.plate_no)) || c(x.veh) || c(x.owner_name) || '<td dir="ltr">' || esc(x.owner_phone) || '</td>' || c(x.what)
          || '<td>' || CASE WHEN x.d < TRUNC(SYSDATE) THEN '<span class="nn-badge is-danger">' ELSE '<span class="nn-badge is-warning">' END
          || TO_CHAR(x.d, 'YYYY-MM-DD') || '</span></td>' || q(x.km));
      END LOOP;
      RETURN foot(NULL);
    ELSIF p_kind = 'MAKES' THEN
      head('الشركة المصنعة|الطراز|#مركبات|#أوامر|#خدمات|#قطع|#الإجمالي|#متوسط الأمر');
      FOR x IN (SELECT v.make, v.model, COUNT(DISTINCT v.id) veh, COUNT(*) jobs, SUM(j.services_amount) svc, SUM(j.parts_amount) prt, SUM(j.total_amount) tot
                  FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                 GROUP BY v.make, v.model ORDER BY tot DESC) LOOP
        r(c(x.make) || c(x.model) || q(x.veh) || q(x.jobs) || n(x.svc) || n(x.prt) || n(x.tot) || n(ROUND(x.tot / x.jobs, 2)));
        s1 := s1 + x.jobs; s2 := s2 + x.svc; s3 := s3 + x.prt; s4 := s4 + x.tot;
      END LOOP;
      RETURN foot('<th colspan="3">الإجمالي</th>' || q(s1) || n(s2) || n(s3) || n(s4) || '<td></td>');
    ELSIF p_kind = 'VEHICLES' THEN
      head('#|اللوحة|المركبة|العميل|#زيارات|#خدمات|#قطع|#الإجمالي|آخر زيارة');
      FOR x IN (SELECT v.plate_no, v.make || ' ' || v.model veh, NVL(j.customer_name, v.owner_name) cust, COUNT(*) visits,
                       SUM(j.services_amount) svc, SUM(j.parts_amount) prt, SUM(j.total_amount) tot, MAX(j.checkin_at) last_at
                  FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id
                 WHERE j.company_id = l_co AND j.status_code IN ('INVOICED', 'DELIVERED') AND j.completed_at >= l_f AND j.completed_at < l_t
                 GROUP BY v.plate_no, v.make || ' ' || v.model, NVL(j.customer_name, v.owner_name) ORDER BY tot DESC FETCH FIRST 30 ROWS ONLY) LOOP
        r('<td>' || (l_n + 1) || '</td>' || c(plate_label(x.plate_no)) || c(x.veh) || c(x.cust) || q(x.visits) || n(x.svc) || n(x.prt) || n(x.tot) || c(ts(x.last_at)));
      END LOOP;
      RETURN foot(NULL);
    END IF;
    RAISE_APPLICATION_ERROR(-20000, 'AUT-090: نوع تقرير غير معروف');
  END report_html;

  FUNCTION claims_html(p_insurer_id IN NUMBER DEFAULT NULL, p_status IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    guard('AUT_JOB_CARD.VIEW');
    l_h := '<table class="nn-prj-t nn-aut-claims"><thead><tr><th>الأمر</th><th>اللوحة</th><th>شركة التأمين</th><th>المطالبة</th><th>الحادث</th>'
        || '<th class="n">المطالب به</th><th class="n">المعتمد</th><th class="n">تحمل العميل</th><th>فاتورة التأمين</th><th>الحالة</th><th></th></tr></thead><tbody>';
    FOR x IN (SELECT j.*, v.plate_no, i.name_ar ins, s.doc_no inv_no, s.due_date,
                     (SELECT NVL(SUM(l.net_amount), 0) FROM aut_job_line l WHERE l.job_card_id = j.id AND l.payer = 'INSURANCE' AND l.line_status <> 'CANCELLED') claimed
                FROM aut_job_card j JOIN aut_vehicle v ON v.id = j.vehicle_id JOIN aut_insurer i ON i.id = j.insurer_id
                LEFT JOIN sal_invoice s ON s.id = j.insurer_invoice_id
               WHERE j.company_id = company AND j.payer_type = 'INSURANCE' AND j.status_code <> 'CANCELLED'
                 AND (p_insurer_id IS NULL OR j.insurer_id = p_insurer_id)
                 AND (p_status IS NULL OR j.claim_status = p_status OR (p_status = 'OPEN' AND NVL(j.claim_status, 'NOT_SUBMITTED') NOT IN ('PAID', 'REJECTED')))
               ORDER BY j.checkin_at DESC) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr data-job="' || x.id || '"><td><b>' || esc(x.doc_no) || '</b></td><td>' || esc(plate_label(x.plate_no)) || '</td><td>' || esc(x.ins) || '</td><td dir="ltr">'
          || esc(x.claim_no) || '</td><td dir="ltr">' || esc(x.accident_report_no) || '</td><td class="n">' || fmt(x.claimed) || '</td><td class="n">'
          || fmt(x.approved_amount) || '</td><td class="n">' || fmt(x.deductible_amount) || '</td><td>' || esc(x.inv_no)
          || CASE WHEN x.due_date IS NOT NULL THEN ' <small>' || TO_CHAR(x.due_date, 'YYYY-MM-DD') || '</small>' END || '</td><td>'
          || badge(NVL(x.claim_status, 'NOT_SUBMITTED')) || '</td><td><button type="button" class="t-Button t-Button--small" data-act="CLAIM" data-id="'
          || x.id || '">تحديث</button></td></tr>');
    END LOOP;
    RETURN l_h || (CASE WHEN l_n = 0 THEN '<tr><td colspan="11" class="nn-empty">لا مطالبات</td></tr>' END || '</tbody></table>');
  END claims_html;

END NOONA_AUT_PKG;
/
SHOW ERRORS PACKAGE BODY NOONA_AUT_PKG
