-- =============================================================================
-- NOONA PLUS ERP | التصنيع: NOONA_MFG_PKG
--   مراكز العمل بمعدلات العمالة والآلات والتحميل، قوائم المواد ومسارات التصنيع بإصدارات (لا يعدل الإصدار المستخدم)،
--   متعددة المستويات مع البدائل والمنتجات المشتركة والقوائم الوهمية (Phantom)، وحساب التكلفة المعيارية المجمعة.
--   أوامر الإنتاج: تخطيط ← اعتماد ← إطلاق (تثبيت الإصدار والتكلفة المعيارية) ← صرف خامات ← تقارير العمليات
--   ← استلام الإنتاج (مع فحص الجودة) ← إكمال ← إقفال بتسوية الانحرافات. التخطيط MRP، وأحمال مراكز العمل.
--   المحاسبة بالعمل تحت التشغيل (1110): الخامات والعمالة والتحميل مدين، والإنتاج المستلم بالتكلفة المعيارية دائن،
--   والرصيد المتبقي عند الإقفال انحراف (5105). كل حركة مخزون عبر NOONA_INV_PKG وكل قيد عبر NOONA_ACE_PKG.
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_MFG_PKG AUTHID DEFINER AS

  FUNCTION company RETURN NUMBER;
  -- تجهيز التصنيع: حسابات الإنتاج تحت التشغيل والتحميل والانحرافات، الترقيم، مركز عمل افتراضي
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- ---------------------------------------------------------- مراكز العمل
  -- {"id","code","name","site","cap":8,"labor":40,"machine":25,"overhead":15,"cc","active":"Y"}
  FUNCTION save_work_center(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION work_center_json(p_id IN NUMBER) RETURN CLOB;

  -- ---------------------------------------------------------- قوائم المواد
  -- {"id","item","name","type":"PRODUCTION|PHANTOM|KIT|ENGINEERING","base":1,"action":"SAVE|PUBLISH",
  --  "lines":[{"i","q","s":scrapPct,"op":opSeq,"co":"Y" (منتج مشترك),"subs":[{"i","f":factor}]}]}
  FUNCTION save_bom(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION bom_doc_json(p_bom_id IN NUMBER, p_item_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  PROCEDURE publish_bom(p_bom_id IN NUMBER);
  PROCEDURE obsolete_bom(p_bom_id IN NUMBER);
  -- نسخة جديدة مسودة من إصدار قائم (لتعديل قائمة مستخدمة)
  FUNCTION new_bom_version(p_bom_id IN NUMBER) RETURN NUMBER;
  FUNCTION bom_in_use(p_bom_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION default_bom(p_item_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- مسارات التصنيع
  -- {"id","item","name","action":"SAVE|PUBLISH","ops":[{"seq":10,"wc","d":"قص","setup":30,"run":2.5,"qc":"Y"}]}
  FUNCTION save_routing(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION routing_doc_json(p_routing_id IN NUMBER, p_item_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  PROCEDURE publish_routing(p_routing_id IN NUMBER);
  PROCEDURE obsolete_routing(p_routing_id IN NUMBER);
  FUNCTION new_routing_version(p_routing_id IN NUMBER) RETURN NUMBER;
  FUNCTION routing_in_use(p_routing_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION default_routing(p_item_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- التكلفة المعيارية
  -- تكلفة الوحدة لكل عنصر لإنتاج p_qty: {"mat","lab","mac","ovh","total"} (الخامات المصنعة بتكلفتها المجمعة)
  FUNCTION std_cost_json(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT NULL, p_bom_id IN NUMBER DEFAULT NULL,
                         p_routing_id IN NUMBER DEFAULT NULL) RETURN CLOB;
  FUNCTION std_unit_cost(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT NULL) RETURN NUMBER;
  -- تكلفة الوحدة الحالية لمكون: المتوسط المرجح، أو التكلفة المجمعة للمصنع بلا رصيد
  FUNCTION comp_cost(p_item_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- أوامر الإنتاج
  -- {"id","item","qty","bom","routing","wh":مستودع الاستلام,"swh":مستودع الصرف,"date","start","end","priority",
  --  "lot","exp","cc","notes","parent","action":"SAVE|APPROVE|RELEASE"}
  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB;
  PROCEDURE approve_order(p_order_id IN NUMBER);
  PROCEDURE release_order(p_order_id IN NUMBER);
  PROCEDURE hold_order(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  PROCEDURE resume_order(p_order_id IN NUMBER);
  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2);
  -- صرف الخامات: {"order","date","wh","lines":[{"m":materialId,"q"} | {"i":itemId,"q"} (مادة إضافية)]}؛ بلا أسطر = كل المتبقي
  FUNCTION issue_materials(p_doc IN CLOB) RETURN NUMBER;
  -- إرجاع خامات زائدة: {"order","date","lines":[{"m","q"}]}
  FUNCTION return_materials(p_doc IN CLOB) RETURN NUMBER;
  -- استبدال المتبقي من مكون ببديله المعتمد في قائمة المواد
  PROCEDURE substitute_material(p_material_id IN NUMBER, p_item_id IN NUMBER);
  -- تقرير عملية: {"order","op":operationId,"date","setup","run","good","scrap","rework","down","done":"Y"}
  FUNCTION report_operation(p_doc IN CLOB) RETURN NUMBER;
  -- استلام إنتاج: {"order","qty","scrap","date","lot","exp","key"}؛ يدخل المخزون أو ينتظر فحص الجودة
  FUNCTION report_output(p_doc IN CLOB) RETURN NUMBER;
  -- فحص الجودة: {"output","passed","failed","date","notes","results":{...}}
  FUNCTION inspect_output(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE complete_order(p_order_id IN NUMBER);
  -- الإقفال: تسوية رصيد العمل تحت التشغيل كانحرافات ويعيد رقم القيد (أو NULL إن لم يوجد انحراف)
  FUNCTION close_order(p_order_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER;
  -- رصيد العمل تحت التشغيل للأمر (لكل العناصر أو عنصر واحد)
  FUNCTION wip_balance(p_order_id IN NUMBER, p_element IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  -- إعدادات التكلفة للشركة: معالجة الانحراف عند الإقفال (EXPENSE مصروف 5105 | INVENTORY على المنتج المتبقي في المخزون والباقي
  -- تكلفة المبيعات) وتحديث التكلفة المعيارية في بطاقة الصنف عند إطلاق الأمر (Y/N)
  FUNCTION variance_treatment RETURN VARCHAR2;
  FUNCTION update_item_std_cost RETURN VARCHAR2;
  PROCEDURE save_settings(p_treatment IN VARCHAR2, p_update_std IN VARCHAR2);

  -- ---------------------------------------------------------- التخطيط
  -- احتياجات المواد: [{"i","n","t":"MAKE|BUY","oh","sup","gross","net","lvl","uom","bom"}]
  FUNCTION mrp_json(p_include_reorder IN VARCHAR2 DEFAULT 'Y') RETURN CLOB;
  -- تنفيذ المقترحات: {"date","lines":[{"i","q","t"}]} ← أوامر إنتاج مخططة وطلب شراء مسودة؛ يعيد {"orders":n,"req":id}
  FUNCTION mrp_execute(p_doc IN CLOB) RETURN CLOB;

  -- ---------------------------------------------------------- القوائم والتسميات (تستخدم داخل SQL)
  -- {"wcs","products" (لها قائمة منشورة),"items" (قابلة للتصنيع),"whs","ccs"}
  FUNCTION lists_json(p_names IN VARCHAR2) RETURN CLOB;
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION priority_label(p_priority IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION element_label(p_element IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION wc_label(p_wc_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION order_progress(p_order_id IN NUMBER) RETURN NUMBER;

  -- ---------------------------------------------------------- التقارير (HTML)
  FUNCTION mfg_summary RETURN CLOB;
  FUNCTION order_cost_sheet(p_order_id IN NUMBER) RETURN CLOB;
  FUNCTION order_print(p_order_id IN NUMBER) RETURN CLOB;
  FUNCTION orders_register(p_from IN DATE, p_to IN DATE, p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION wip_report(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION variance_report(p_from IN DATE, p_to IN DATE, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION material_usage(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION production_summary(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION wc_utilization(p_from IN DATE, p_to IN DATE) RETURN CLOB;
  FUNCTION capacity_load(p_from IN DATE DEFAULT NULL, p_days IN NUMBER DEFAULT 14) RETURN CLOB;
  FUNCTION bom_tree(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT 1) RETURN CLOB;
  FUNCTION where_used(p_item_id IN NUMBER) RETURN CLOB;
  FUNCTION mrp_report(p_include_reorder IN VARCHAR2 DEFAULT 'Y') RETURN CLOB;
  FUNCTION quality_report(p_from IN DATE, p_to IN DATE) RETURN CLOB;
END NOONA_MFG_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_MFG_PKG AS

  c_order CONSTANT VARCHAR2(30) := 'MFG_PRODUCTION_ORDER';
  TYPE t_num IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END;
  FUNCTION company RETURN NUMBER IS BEGIN RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID')); END;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p IS NULL OR p = 0 THEN '' ELSE TO_CHAR(p, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''') END;
  END fmt;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(p, 0), 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');
  END fmt0;
  FUNCTION fqty(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN RTRIM(TO_CHAR(NVL(p, 0), 'FM999G999G999G990D999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '.');
  END fqty;
  -- رقم JSON صالح (صفر قبل الفاصلة العشرية، بلا أصفار زائدة)
  FUNCTION fnum(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN 'null'; END IF;
    RETURN RTRIM(RTRIM(TO_CHAR(ROUND(p, 12), 'FM999999999999999999990D999999999999', 'NLS_NUMERIC_CHARACTERS=''.,'''), '0'), '.');
  END fnum;
  FUNCTION d(p VARCHAR2) RETURN DATE IS BEGIN RETURN TO_DATE(SUBSTR(p, 1, 10), 'YYYY-MM-DD'); END;
  FUNCTION ds(p DATE) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(p, 'YYYY-MM-DD'); END;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION item_label(p NUMBER) RETURN VARCHAR2 IS BEGIN RETURN NOONA_INV_PKG.item_label(p); END;
  -- التكلفة المعيارية للوحدة لعنصر من تفصيل الأمر {"MATERIAL":..,"LABOR":..}
  FUNCTION std_el(p_det CLOB, p_el VARCHAR2) RETURN NUMBER IS
    l_o JSON_OBJECT_T;
  BEGIN
    IF p_det IS NULL THEN RETURN 0; END IF;
    l_o := JSON_OBJECT_T.parse(p_det);
    RETURN NVL(l_o.get_number(p_el), 0);
  END std_el;
  FUNCTION acc(p VARCHAR2) RETURN NUMBER IS BEGIN RETURN NOONA_INV_PKG.acc_id(p); END;

  -- ================================================================ التسميات
  FUNCTION status_label(p_status IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_status
      WHEN 'PLANNED' THEN 'مخطط' WHEN 'APPROVED' THEN 'معتمد' WHEN 'RELEASED' THEN 'مطلق للتنفيذ'
      WHEN 'IN_PROGRESS' THEN 'قيد التنفيذ' WHEN 'PARTIALLY_COMPLETED' THEN 'منجز جزئياً' WHEN 'COMPLETED' THEN 'مكتمل'
      WHEN 'CLOSED' THEN 'مقفل' WHEN 'ON_HOLD' THEN 'موقوف' WHEN 'CANCELLED' THEN 'ملغى'
      WHEN 'DRAFT' THEN 'مسودة' WHEN 'PUBLISHED' THEN 'منشور' WHEN 'OBSOLETE' THEN 'ملغى الاستخدام'
      WHEN 'PENDING' THEN 'لم تبدأ' WHEN 'SKIPPED' THEN 'متجاوزة'
      WHEN 'PENDING_QUALITY' THEN 'بانتظار الجودة' WHEN 'ACCEPTED' THEN 'مقبول' WHEN 'REJECTED' THEN 'مرفوض' WHEN 'POSTED' THEN 'مرحل'
      WHEN 'PASSED' THEN 'ناجح' WHEN 'FAILED' THEN 'مرفوض' WHEN 'CONDITIONAL' THEN 'قبول جزئي'
      ELSE p_status END;
  END status_label;

  FUNCTION priority_label(p_priority IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_priority WHEN 'LOW' THEN 'منخفضة' WHEN 'NORMAL' THEN 'عادية' WHEN 'HIGH' THEN 'عالية' WHEN 'URGENT' THEN 'عاجلة'
                ELSE p_priority END;
  END priority_label;

  FUNCTION element_label(p_element IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_element WHEN 'MATERIAL' THEN 'الخامات' WHEN 'LABOR' THEN 'العمالة' WHEN 'MACHINE' THEN 'الآلات'
                WHEN 'OVERHEAD' THEN 'التحميل الصناعي' WHEN 'SUBCONTRACT' THEN 'التشغيل لدى الغير' WHEN 'SCRAP' THEN 'الهالك'
                WHEN 'MATERIAL_USAGE' THEN 'انحراف كمية الخامات' WHEN 'MATERIAL_PRICE' THEN 'انحراف سعر الخامات'
                WHEN 'LABOR_EFFICIENCY' THEN 'انحراف كفاءة العمالة' WHEN 'LABOR_RATE' THEN 'انحراف معدل العمالة'
                WHEN 'YIELD' THEN 'انحراف الإنتاجية' WHEN 'SCRAP_ABNORMAL' THEN 'هالك غير طبيعي'
                ELSE p_element END;
  END element_label;

  FUNCTION wc_label(p_wc_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(300);
  BEGIN
    SELECT MAX(code || ' - ' || name_ar) INTO l FROM mfg_work_center WHERE id = p_wc_id;
    RETURN l;
  END wc_label;

  FUNCTION badge(p_status VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN '<span class="nn-badge ' || CASE
             WHEN p_status IN ('CLOSED', 'COMPLETED', 'PUBLISHED', 'PASSED', 'ACCEPTED', 'POSTED') THEN 'is-success'
             WHEN p_status IN ('CANCELLED', 'OBSOLETE', 'FAILED', 'REJECTED') THEN 'is-danger'
             WHEN p_status IN ('ON_HOLD', 'PENDING_QUALITY', 'CONDITIONAL') THEN 'is-warning'
             WHEN p_status IN ('IN_PROGRESS', 'PARTIALLY_COMPLETED', 'RELEASED') THEN 'is-info'
             ELSE '' END || '">' || esc(status_label(p_status)) || '</span>';
  END badge;

  -- ================================================================ التجهيز
  FUNCTION ensure_account(p_code VARCHAR2, p_name VARCHAR2, p_parent VARCHAR2, p_type VARCHAR2, p_sub VARCHAR2 DEFAULT NULL)
    RETURN NUMBER IS
    l NUMBER := acc(p_code);
  BEGIN
    IF l IS NULL THEN
      l := NOONA_GL_PKG.add_account(NOONA_GL_PKG.primary_coa, p_code, p_name, p_parent, p_type, 'Y', p_sub);
    END IF;
    RETURN l;
  END ensure_account;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n  NUMBER := 0;
    l_id NUMBER;
    l_cc NUMBER;
  BEGIN
    guard('MFG_WORK_CENTER.CREATE');
    IF NOONA_INV_PKG.is_ready = 'N' THEN
      l_n := NOONA_INV_PKG.quick_setup;
    END IF;
    l_id := ensure_account('1110', 'الإنتاج تحت التشغيل', '11', 'ASSET', 'INV');
    l_id := ensure_account('5103', 'العمالة الصناعية المحملة على الإنتاج', '51', 'EXPENSE');
    l_id := ensure_account('5104', 'الأعباء الصناعية المحملة على الإنتاج', '51', 'EXPENSE');
    l_id := ensure_account('5105', 'انحرافات تكاليف الإنتاج', '51', 'EXPENSE');
    NOONA_INV_PKG.ensure_sequence(c_order, 'MO-');
    NOONA_INV_PKG.ensure_sequence('PUR_REQUISITION', 'PR-');
    SELECT COUNT(*) INTO l_id FROM mfg_work_center WHERE company_id = company;
    IF l_id = 0 THEN
      SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(code, 'CC-600', 0, 'CC-500', 1, 2), id) INTO l_cc
        FROM gl_cost_center WHERE company_id = company;
      INSERT INTO mfg_work_center (company_id, branch_id, code, name_ar, capacity_hours_day, labor_rate, overhead_rate, machine_rate,
                                   cost_center_id, is_active)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'WC-ASM', 'خط التجميع', 8, 40, 15, 0, l_cc, 'Y');
      l_n := l_n + 1;
    END IF;
    RETURN l_n;
  END quick_setup;

  FUNCTION is_ready RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN acc('1110') IS NOT NULL AND acc('5105') IS NOT NULL AND NOONA_INV_PKG.is_ready = 'Y' THEN 'Y' ELSE 'N' END;
  END is_ready;

  -- ================================================================ مراكز العمل
  FUNCTION save_work_center(p_doc IN CLOB) RETURN NUMBER IS
    l_id   NUMBER := JSON_VALUE(p_doc, '$.id' RETURNING NUMBER);
    l_code VARCHAR2(50) := UPPER(TRIM(JSON_VALUE(p_doc, '$.code')));
    l_name VARCHAR2(200) := TRIM(JSON_VALUE(p_doc, '$.name'));
    l_cap  NUMBER := NVL(JSON_VALUE(p_doc, '$.cap' RETURNING NUMBER), 8);
    l_lab  NUMBER := NVL(JSON_VALUE(p_doc, '$.labor' RETURNING NUMBER), 0);
    l_mac  NUMBER := NVL(JSON_VALUE(p_doc, '$.machine' RETURNING NUMBER), 0);
    l_ovh  NUMBER := NVL(JSON_VALUE(p_doc, '$.overhead' RETURNING NUMBER), 0);
    l_cc   NUMBER := JSON_VALUE(p_doc, '$.cc' RETURNING NUMBER);
    l_site NUMBER := JSON_VALUE(p_doc, '$.site' RETURNING NUMBER);
    l_act  VARCHAR2(1) := NVL(JSON_VALUE(p_doc, '$.active'), 'Y');
  BEGIN
    NOONA_CORE_PKG.assert(l_code IS NOT NULL AND l_name IS NOT NULL, 'NOONA-MFG-001', 'رمز مركز العمل واسمه إلزاميان',
                          'Work center code and name are required');
    NOONA_CORE_PKG.assert(l_cap > 0 AND l_cap <= 24, 'NOONA-MFG-002', 'الطاقة اليومية بين 1 و 24 ساعة', 'Capacity must be 1-24 hours');
    NOONA_CORE_PKG.assert(l_lab >= 0 AND l_mac >= 0 AND l_ovh >= 0, 'NOONA-MFG-003', 'المعدلات لا تكون سالبة', 'Rates cannot be negative');
    IF l_id IS NULL THEN
      guard('MFG_WORK_CENTER.CREATE');
      INSERT INTO mfg_work_center (company_id, branch_id, code, name_ar, site_id, capacity_hours_day, labor_rate, overhead_rate,
                                   machine_rate, cost_center_id, is_active)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_code, l_name, l_site, l_cap, l_lab, l_ovh, l_mac, l_cc,
              CASE WHEN l_act = 'N' THEN 'N' ELSE 'Y' END)
      RETURNING id INTO l_id;
    ELSE
      guard('MFG_WORK_CENTER.UPDATE');
      UPDATE mfg_work_center
         SET code = l_code, name_ar = l_name, site_id = l_site, capacity_hours_day = l_cap, labor_rate = l_lab,
             overhead_rate = l_ovh, machine_rate = l_mac, cost_center_id = l_cc, is_active = CASE WHEN l_act = 'N' THEN 'N' ELSE 'Y' END
       WHERE id = l_id AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-MFG-004', 'مركز العمل غير موجود', 'Work center not found');
    END IF;
    NOONA_AUDIT_PKG.log_event('CONFIG', 'MFG_WORK_CENTER', l_id, 'SAVE', 'SUCCESS');
    RETURN l_id;
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    NOONA_CORE_PKG.raise_error('NOONA-MFG-005', 'رمز مركز العمل مستخدم', 'Work center code already exists');
  END save_work_center;

  FUNCTION work_center_json(p_id IN NUMBER) RETURN CLOB IS
    l CLOB;
  BEGIN
    SELECT JSON_OBJECT('id' VALUE id, 'code' VALUE code, 'name' VALUE name_ar, 'site' VALUE site_id, 'cap' VALUE capacity_hours_day,
                       'labor' VALUE labor_rate, 'machine' VALUE machine_rate, 'overhead' VALUE overhead_rate, 'cc' VALUE cost_center_id,
                       'active' VALUE is_active RETURNING CLOB)
      INTO l FROM mfg_work_center WHERE id = p_id AND company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '{"id":null,"cap":8,"labor":0,"machine":0,"overhead":0,"active":"Y"}';
  END work_center_json;

  -- ================================================================ قوائم المواد
  FUNCTION default_bom(p_item_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) KEEP (DENSE_RANK FIRST ORDER BY DECODE(is_default, 'Y', 0, 1), version_no DESC) INTO l
      FROM mfg_bom WHERE company_id = company AND item_id = p_item_id AND status_code = 'PUBLISHED';
    RETURN l;
  END default_bom;

  FUNCTION bom_in_use(p_bom_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM dual
     WHERE EXISTS (SELECT 1 FROM mfg_production_order WHERE bom_id = p_bom_id AND status_code NOT IN ('PLANNED', 'APPROVED', 'CANCELLED'))
        OR EXISTS (SELECT 1 FROM inv_transaction WHERE source_entity_type = 'MFG_BOM' AND source_entity_id = p_bom_id);
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END bom_in_use;

  -- يمنع الدورات: هل يظهر p_target ضمن مكونات p_item على أي مستوى (القوائم المنشورة والمسودة الحالية)
  FUNCTION contains_item(p_item NUMBER, p_target NUMBER, p_depth PLS_INTEGER DEFAULT 0) RETURN BOOLEAN IS
    l_bom NUMBER := default_bom(p_item);
  BEGIN
    IF p_depth > 25 OR l_bom IS NULL THEN RETURN FALSE; END IF;
    FOR r IN (SELECT component_item_id c FROM mfg_bom_line WHERE bom_id = l_bom AND is_co_product = 'N') LOOP
      IF r.c = p_target OR contains_item(r.c, p_target, p_depth + 1) THEN RETURN TRUE; END IF;
    END LOOP;
    RETURN FALSE;
  END contains_item;

  FUNCTION save_bom(p_doc IN CLOB) RETURN NUMBER IS
    l_id     NUMBER := JSON_VALUE(p_doc, '$.id' RETURNING NUMBER);
    l_itemid NUMBER := JSON_VALUE(p_doc, '$.item' RETURNING NUMBER);
    l_item   inv_item%ROWTYPE;
    l_bom    mfg_bom%ROWTYPE;
    l_base   NUMBER := NVL(JSON_VALUE(p_doc, '$.base' RETURNING NUMBER), 1);
    l_type   VARCHAR2(30) := NVL(JSON_VALUE(p_doc, '$.type'), 'PRODUCTION');
    l_name   VARCHAR2(200) := JSON_VALUE(p_doc, '$.name');
    l_action VARCHAR2(30) := NVL(JSON_VALUE(p_doc, '$.action'), 'SAVE');
    l_no     PLS_INTEGER := 0;
    l_line   NUMBER;
    l_uom    NUMBER;
    l_ver    NUMBER;
    l_out    PLS_INTEGER := 0;
  BEGIN
    SAVEPOINT mfg_bom;
    guard('MFG_BOM.CREATE');
    IF l_id IS NOT NULL THEN
      SELECT * INTO l_bom FROM mfg_bom WHERE id = l_id AND company_id = company FOR UPDATE;
      l_itemid := l_bom.item_id;
      NOONA_CORE_PKG.assert(l_bom.status_code <> 'OBSOLETE', 'NOONA-MFG-010', 'الإصدار ملغى الاستخدام؛ أنشئ إصداراً جديداً',
                            'Obsolete version');
      NOONA_CORE_PKG.assert(bom_in_use(l_id) = 'N', 'NOONA-MFG-011',
        'هذا الإصدار مستخدم في أوامر إنتاج فلا يعدل؛ أنشئ إصداراً جديداً منه', 'Version in use; create a new version');
    END IF;
    NOONA_CORE_PKG.assert(l_itemid IS NOT NULL, 'NOONA-MFG-012', 'اختر المنتج', 'Choose the product');
    SELECT * INTO l_item FROM inv_item WHERE id = l_itemid;
    NOONA_CORE_PKG.assert(l_base > 0, 'NOONA-MFG-013', 'الكمية المرجعية يجب أن تكون موجبة', 'Base quantity must be positive');
    NOONA_CORE_PKG.assert(l_type IN ('PRODUCTION', 'ENGINEERING', 'KIT', 'PHANTOM'), 'NOONA-MFG-014', 'نوع قائمة غير صالح', 'Invalid BOM type');
    -- التحقق من الأسطر قبل أي تعديل
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', co VARCHAR2(1) PATH '$.co'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      NOONA_CORE_PKG.assert(r.i <> l_itemid, 'NOONA-MFG-015', 'المنتج لا يكون مكوناً لنفسه', 'An item cannot be its own component');
      NOONA_CORE_PKG.assert(NVL(r.q, 0) > 0, 'NOONA-MFG-016', 'كمية المكون يجب أن تكون موجبة: ' || item_label(r.i),
                            'Component quantity must be positive');
      IF NVL(r.co, 'N') = 'N' THEN
        NOONA_CORE_PKG.assert(NOT contains_item(r.i, l_itemid), 'NOONA-MFG-017',
          'دورة في قائمة المواد: المكون ' || item_label(r.i) || ' يحتوي المنتج نفسه في أحد مستوياته', 'Circular bill of materials');
        l_no := l_no + 1;
      ELSE
        l_out := l_out + 1;
      END IF;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-MFG-018', 'أضف مكوناً واحداً على الأقل', 'Add at least one component');
    IF l_id IS NULL THEN
      SELECT NVL(MAX(version_no), 0) + 1 INTO l_ver FROM mfg_bom WHERE company_id = company AND code = l_item.item_no;
      INSERT INTO mfg_bom (company_id, code, name_ar, item_id, version_no, bom_type, base_quantity, uom_id, is_default, status_code)
      VALUES (company, l_item.item_no, NVL(l_name, 'قائمة مواد ' || l_item.name_ar), l_itemid, l_ver, l_type, l_base, l_item.base_uom_id,
              'N', 'DRAFT')
      RETURNING id INTO l_id;
    ELSE
      UPDATE mfg_bom SET name_ar = NVL(l_name, name_ar), bom_type = l_type, base_quantity = l_base WHERE id = l_id;
      DELETE FROM mfg_bom_substitute WHERE bom_line_id IN (SELECT id FROM mfg_bom_line WHERE bom_id = l_id);
      DELETE FROM mfg_bom_line WHERE bom_id = l_id;
    END IF;
    l_no := 0;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (
                ln FOR ORDINALITY, i NUMBER PATH '$.i', q NUMBER PATH '$.q', s NUMBER PATH '$.s', op NUMBER PATH '$.op',
                co VARCHAR2(1) PATH '$.co', sg VARCHAR2(30) PATH '$.sg', subs CLOB FORMAT JSON PATH '$.subs'))) LOOP
      CONTINUE WHEN r.i IS NULL;
      l_no := l_no + 1;
      SELECT base_uom_id INTO l_uom FROM inv_item WHERE id = r.i;
      INSERT INTO mfg_bom_line (company_id, bom_id, line_no, component_item_id, quantity, uom_id, scrap_pct, operation_seq,
                                is_co_product, substitute_group, sort_order)
      VALUES (company, l_id, l_no, r.i, r.q, l_uom, LEAST(GREATEST(NVL(r.s, 0), 0), 99), r.op,
              CASE WHEN r.co = 'Y' THEN 'Y' ELSE 'N' END, r.sg, l_no)
      RETURNING id INTO l_line;
      IF r.subs IS NOT NULL THEN
        FOR s IN (SELECT * FROM JSON_TABLE(r.subs, '$[*]' COLUMNS (sn FOR ORDINALITY, i NUMBER PATH '$.i', f NUMBER PATH '$.f'))) LOOP
          CONTINUE WHEN s.i IS NULL OR s.i = r.i;
          INSERT INTO mfg_bom_substitute (company_id, bom_line_id, substitute_item_id, conversion_factor, priority_no, requires_approval)
          VALUES (company, l_line, s.i, NVL(NULLIF(s.f, 0), 1), s.sn, 'N');
        END LOOP;
      END IF;
    END LOOP;
    UPDATE inv_item SET is_manufactured = 'Y' WHERE id = l_itemid AND NVL(is_manufactured, 'N') <> 'Y';
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_BOM', l_id, 'SAVE', 'SUCCESS');
    IF l_action = 'PUBLISH' THEN
      publish_bom(l_id);
    END IF;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ROLLBACK TO mfg_bom;
    NOONA_CORE_PKG.raise_error('NOONA-MFG-019', 'قائمة المواد أو المنتج غير موجود', 'BOM or item not found');
  WHEN OTHERS THEN
    ROLLBACK TO mfg_bom;
    RAISE;
  END save_bom;

  PROCEDURE publish_bom(p_bom_id IN NUMBER) IS
    l mfg_bom%ROWTYPE;
  BEGIN
    guard('MFG_BOM.APPROVE');
    SELECT * INTO l FROM mfg_bom WHERE id = p_bom_id AND company_id = company FOR UPDATE;
    NOONA_CORE_PKG.assert(l.status_code IN ('DRAFT', 'APPROVED', 'PUBLISHED'), 'NOONA-MFG-020', 'لا ينشر إصدار ملغى الاستخدام',
                          'Obsolete version cannot be published');
    UPDATE mfg_bom SET is_default = 'N' WHERE company_id = company AND item_id = l.item_id AND id <> p_bom_id AND is_default = 'Y';
    UPDATE mfg_bom SET status_code = 'PUBLISHED', is_default = 'Y', effective_from = LEAST(effective_from, TRUNC(SYSDATE)),
                       effective_to = NULL
     WHERE id = p_bom_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_BOM', p_bom_id, 'PUBLISH', 'SUCCESS');
  END publish_bom;

  PROCEDURE obsolete_bom(p_bom_id IN NUMBER) IS
  BEGIN
    guard('MFG_BOM.UPDATE');
    UPDATE mfg_bom SET status_code = 'OBSOLETE', is_default = 'N', effective_to = GREATEST(effective_from, TRUNC(SYSDATE))
     WHERE id = p_bom_id AND company_id = company AND status_code <> 'OBSOLETE';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-MFG-021', 'الإصدار غير موجود أو ملغى سابقاً', 'Version not found');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_BOM', p_bom_id, 'OBSOLETE', 'SUCCESS');
  END obsolete_bom;

  FUNCTION new_bom_version(p_bom_id IN NUMBER) RETURN NUMBER IS
    l     mfg_bom%ROWTYPE;
    l_new NUMBER;
    l_ln  NUMBER;
    l_ver NUMBER;
  BEGIN
    guard('MFG_BOM.CREATE');
    SELECT * INTO l FROM mfg_bom WHERE id = p_bom_id AND company_id = company;
    SELECT MAX(version_no) + 1 INTO l_ver FROM mfg_bom WHERE company_id = company AND code = l.code;
    INSERT INTO mfg_bom (company_id, code, name_ar, item_id, version_no, bom_type, base_quantity, uom_id, is_default, status_code)
    VALUES (company, l.code, l.name_ar, l.item_id, l_ver, l.bom_type, l.base_quantity, l.uom_id, 'N', 'DRAFT')
    RETURNING id INTO l_new;
    FOR r IN (SELECT * FROM mfg_bom_line WHERE bom_id = p_bom_id ORDER BY line_no) LOOP
      INSERT INTO mfg_bom_line (company_id, bom_id, line_no, component_item_id, quantity, uom_id, scrap_pct, operation_seq,
                                is_co_product, substitute_group, sort_order)
      VALUES (company, l_new, r.line_no, r.component_item_id, r.quantity, r.uom_id, r.scrap_pct, r.operation_seq, r.is_co_product,
              r.substitute_group, r.sort_order)
      RETURNING id INTO l_ln;
      INSERT INTO mfg_bom_substitute (company_id, bom_line_id, substitute_item_id, conversion_factor, priority_no, requires_approval)
      SELECT company, l_ln, substitute_item_id, conversion_factor, priority_no, requires_approval
        FROM mfg_bom_substitute WHERE bom_line_id = r.id;
    END LOOP;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_BOM', l_new, 'NEW_VERSION', 'SUCCESS');
    RETURN l_new;
  END new_bom_version;

  FUNCTION bom_doc_json(p_bom_id IN NUMBER, p_item_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_id  NUMBER := NVL(p_bom_id, default_bom(p_item_id));
    l_out CLOB;
    l_use VARCHAR2(1);
  BEGIN
    IF l_id IS NULL THEN
      SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY version_no) INTO l_id FROM mfg_bom WHERE company_id = company AND item_id = p_item_id;
    END IF;
    IF l_id IS NULL THEN
      RETURN '{"id":null,"item":' || fnum(p_item_id) || ',"itemName":' || jt(item_label(p_item_id))
          || ',"type":"PRODUCTION","base":1,"status":"DRAFT","version":1,"lines":[],"versions":[]}';
    END IF;
    l_use := bom_in_use(l_id);
    SELECT JSON_OBJECT('id' VALUE b.id, 'item' VALUE b.item_id, 'itemName' VALUE NOONA_INV_PKG.item_label(b.item_id), 'code' VALUE b.code,
             'name' VALUE b.name_ar, 'type' VALUE b.bom_type, 'base' VALUE b.base_quantity, 'version' VALUE b.version_no,
             'status' VALUE b.status_code, 'statusName' VALUE NOONA_MFG_PKG.status_label(b.status_code), 'default' VALUE b.is_default,
             'inUse' VALUE l_use,
             'lines' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE l.component_item_id, 'n' VALUE i.item_no || ' - ' || i.name_ar,
                                    'q' VALUE l.quantity, 's' VALUE l.scrap_pct, 'op' VALUE l.operation_seq, 'co' VALUE l.is_co_product,
                                    'sg' VALUE l.substitute_group, 'c' VALUE NOONA_INV_PKG.avg_cost(l.component_item_id),
                                    'oh' VALUE NOONA_INV_PKG.on_hand(l.component_item_id),
                                    'mk' VALUE CASE WHEN NOONA_MFG_PKG.default_bom(l.component_item_id) IS NOT NULL THEN 'Y' ELSE 'N' END,
                                    'subs' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE s.substitute_item_id,
                                                    'n' VALUE NOONA_INV_PKG.item_label(s.substitute_item_id), 'f' VALUE s.conversion_factor)
                                                    ORDER BY s.priority_no RETURNING CLOB)
                                                    FROM mfg_bom_substitute s WHERE s.bom_line_id = l.id) FORMAT JSON
                                    RETURNING CLOB) ORDER BY l.line_no RETURNING CLOB)
                              FROM mfg_bom_line l JOIN inv_item i ON i.id = l.component_item_id WHERE l.bom_id = b.id) FORMAT JSON,
             'versions' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE v.id, 'v' VALUE v.version_no, 'st' VALUE v.status_code,
                                     'sn' VALUE NOONA_MFG_PKG.status_label(v.status_code), 'def' VALUE v.is_default) ORDER BY v.version_no DESC RETURNING CLOB)
                                 FROM mfg_bom v WHERE v.company_id = b.company_id AND v.item_id = b.item_id) FORMAT JSON
             RETURNING CLOB)
      INTO l_out FROM mfg_bom b WHERE b.id = l_id AND b.company_id = company;
    RETURN l_out;
  END bom_doc_json;

  -- ================================================================ مسارات التصنيع
  FUNCTION default_routing(p_item_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY version_no) INTO l
      FROM mfg_routing WHERE company_id = company AND item_id = p_item_id AND status_code = 'PUBLISHED';
    RETURN l;
  END default_routing;

  FUNCTION routing_in_use(p_routing_id IN NUMBER) RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM mfg_production_order
     WHERE routing_id = p_routing_id AND status_code NOT IN ('PLANNED', 'APPROVED', 'CANCELLED') AND ROWNUM = 1;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END routing_in_use;

  FUNCTION save_routing(p_doc IN CLOB) RETURN NUMBER IS
    l_id     NUMBER := JSON_VALUE(p_doc, '$.id' RETURNING NUMBER);
    l_itemid NUMBER := JSON_VALUE(p_doc, '$.item' RETURNING NUMBER);
    l_item   inv_item%ROWTYPE;
    l_r      mfg_routing%ROWTYPE;
    l_name   VARCHAR2(200) := JSON_VALUE(p_doc, '$.name');
    l_action VARCHAR2(30) := NVL(JSON_VALUE(p_doc, '$.action'), 'SAVE');
    l_no     PLS_INTEGER := 0;
    l_ver    NUMBER;
    l_seen   t_num;
  BEGIN
    SAVEPOINT mfg_rt;
    guard('MFG_ROUTING.CREATE');
    IF l_id IS NOT NULL THEN
      SELECT * INTO l_r FROM mfg_routing WHERE id = l_id AND company_id = company FOR UPDATE;
      l_itemid := l_r.item_id;
      NOONA_CORE_PKG.assert(l_r.status_code <> 'OBSOLETE', 'NOONA-MFG-030', 'الإصدار ملغى الاستخدام', 'Obsolete version');
      NOONA_CORE_PKG.assert(routing_in_use(l_id) = 'N', 'NOONA-MFG-031',
        'هذا المسار مستخدم في أوامر إنتاج فلا يعدل؛ أنشئ إصداراً جديداً منه', 'Routing in use; create a new version');
    END IF;
    NOONA_CORE_PKG.assert(l_itemid IS NOT NULL, 'NOONA-MFG-012', 'اختر المنتج', 'Choose the product');
    SELECT * INTO l_item FROM inv_item WHERE id = l_itemid;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.ops[*]' COLUMNS (seq NUMBER PATH '$.seq', wc NUMBER PATH '$.wc', dsc VARCHAR2(500) PATH '$.d',
                                                                  st NUMBER PATH '$.setup', rn NUMBER PATH '$.run'))) LOOP
      CONTINUE WHEN r.wc IS NULL;
      NOONA_CORE_PKG.assert(r.seq IS NOT NULL AND r.seq > 0, 'NOONA-MFG-032', 'تسلسل العملية مطلوب', 'Operation sequence is required');
      NOONA_CORE_PKG.assert(NOT l_seen.EXISTS(r.seq), 'NOONA-MFG-033', 'تسلسل العملية مكرر: ' || r.seq, 'Duplicate operation sequence');
      l_seen(r.seq) := 1;
      NOONA_CORE_PKG.assert(TRIM(r.dsc) IS NOT NULL, 'NOONA-MFG-034', 'وصف العملية ' || r.seq || ' مطلوب', 'Operation description is required');
      NOONA_CORE_PKG.assert(NVL(r.st, 0) >= 0 AND NVL(r.rn, 0) >= 0, 'NOONA-MFG-035', 'الأزمنة لا تكون سالبة', 'Times cannot be negative');
      l_no := l_no + 1;
    END LOOP;
    NOONA_CORE_PKG.assert(l_no > 0, 'NOONA-MFG-036', 'أضف عملية واحدة على الأقل', 'Add at least one operation');
    IF l_id IS NULL THEN
      SELECT NVL(MAX(version_no), 0) + 1 INTO l_ver FROM mfg_routing WHERE company_id = company AND code = l_item.item_no;
      INSERT INTO mfg_routing (company_id, code, name_ar, item_id, version_no, status_code)
      VALUES (company, l_item.item_no, NVL(l_name, 'مسار تصنيع ' || l_item.name_ar), l_itemid, l_ver, 'DRAFT')
      RETURNING id INTO l_id;
    ELSE
      UPDATE mfg_routing SET name_ar = NVL(l_name, name_ar) WHERE id = l_id;
      DELETE FROM mfg_routing_operation WHERE routing_id = l_id;
    END IF;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.ops[*]' COLUMNS (seq NUMBER PATH '$.seq', wc NUMBER PATH '$.wc', dsc VARCHAR2(500) PATH '$.d',
                                                                  st NUMBER PATH '$.setup', rn NUMBER PATH '$.run', qc VARCHAR2(1) PATH '$.qc'))) LOOP
      CONTINUE WHEN r.wc IS NULL;
      INSERT INTO mfg_routing_operation (company_id, routing_id, operation_seq, work_center_id, description, setup_minutes,
                                         run_minutes_per_unit, quality_check)
      SELECT company, l_id, r.seq, id, TRIM(r.dsc), NVL(r.st, 0), NVL(r.rn, 0), CASE WHEN r.qc = 'Y' THEN 'Y' ELSE 'N' END
        FROM mfg_work_center WHERE id = r.wc AND company_id = company;
      NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-MFG-037', 'مركز العمل غير موجود في العملية ' || r.seq, 'Work center not found');
    END LOOP;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_ROUTING', l_id, 'SAVE', 'SUCCESS');
    IF l_action = 'PUBLISH' THEN
      publish_routing(l_id);
    END IF;
    RETURN l_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ROLLBACK TO mfg_rt;
    NOONA_CORE_PKG.raise_error('NOONA-MFG-038', 'المسار أو المنتج غير موجود', 'Routing or item not found');
  WHEN OTHERS THEN
    ROLLBACK TO mfg_rt;
    RAISE;
  END save_routing;

  PROCEDURE publish_routing(p_routing_id IN NUMBER) IS
  BEGIN
    guard('MFG_ROUTING.APPROVE');
    UPDATE mfg_routing SET status_code = 'PUBLISHED', effective_from = LEAST(effective_from, TRUNC(SYSDATE)), effective_to = NULL
     WHERE id = p_routing_id AND company_id = company AND status_code IN ('DRAFT', 'APPROVED', 'PUBLISHED');
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-MFG-039', 'المسار غير موجود أو ملغى الاستخدام', 'Routing not found or obsolete');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_ROUTING', p_routing_id, 'PUBLISH', 'SUCCESS');
  END publish_routing;

  PROCEDURE obsolete_routing(p_routing_id IN NUMBER) IS
  BEGIN
    guard('MFG_ROUTING.UPDATE');
    UPDATE mfg_routing SET status_code = 'OBSOLETE', effective_to = GREATEST(effective_from, TRUNC(SYSDATE))
     WHERE id = p_routing_id AND company_id = company AND status_code <> 'OBSOLETE';
    NOONA_CORE_PKG.assert(SQL%ROWCOUNT = 1, 'NOONA-MFG-039', 'المسار غير موجود أو ملغى سابقاً', 'Routing not found');
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_ROUTING', p_routing_id, 'OBSOLETE', 'SUCCESS');
  END obsolete_routing;

  FUNCTION new_routing_version(p_routing_id IN NUMBER) RETURN NUMBER IS
    l     mfg_routing%ROWTYPE;
    l_new NUMBER;
    l_ver NUMBER;
  BEGIN
    guard('MFG_ROUTING.CREATE');
    SELECT * INTO l FROM mfg_routing WHERE id = p_routing_id AND company_id = company;
    SELECT MAX(version_no) + 1 INTO l_ver FROM mfg_routing WHERE company_id = company AND code = l.code;
    INSERT INTO mfg_routing (company_id, code, name_ar, item_id, version_no, status_code)
    VALUES (company, l.code, l.name_ar, l.item_id, l_ver, 'DRAFT')
    RETURNING id INTO l_new;
    INSERT INTO mfg_routing_operation (company_id, routing_id, operation_seq, work_center_id, description, setup_minutes,
                                       run_minutes_per_unit, quality_check)
    SELECT company, l_new, operation_seq, work_center_id, description, setup_minutes, run_minutes_per_unit, quality_check
      FROM mfg_routing_operation WHERE routing_id = p_routing_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'MFG_ROUTING', l_new, 'NEW_VERSION', 'SUCCESS');
    RETURN l_new;
  END new_routing_version;

  FUNCTION routing_doc_json(p_routing_id IN NUMBER, p_item_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    l_id  NUMBER := NVL(p_routing_id, default_routing(p_item_id));
    l_out CLOB;
    l_use VARCHAR2(1);
  BEGIN
    IF l_id IS NULL THEN
      SELECT MAX(id) KEEP (DENSE_RANK LAST ORDER BY version_no) INTO l_id FROM mfg_routing WHERE company_id = company AND item_id = p_item_id;
    END IF;
    IF l_id IS NULL THEN
      RETURN '{"id":null,"item":' || fnum(p_item_id) || ',"itemName":' || jt(item_label(p_item_id))
          || ',"status":"DRAFT","version":1,"ops":[],"versions":[]}';
    END IF;
    l_use := routing_in_use(l_id);
    SELECT JSON_OBJECT('id' VALUE r.id, 'item' VALUE r.item_id, 'itemName' VALUE NOONA_INV_PKG.item_label(r.item_id), 'code' VALUE r.code,
             'name' VALUE r.name_ar, 'version' VALUE r.version_no, 'status' VALUE r.status_code,
             'statusName' VALUE NOONA_MFG_PKG.status_label(r.status_code), 'inUse' VALUE l_use,
             'ops' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('seq' VALUE o.operation_seq, 'wc' VALUE o.work_center_id,
                                  'wcn' VALUE NOONA_MFG_PKG.wc_label(o.work_center_id), 'd' VALUE o.description, 'setup' VALUE o.setup_minutes,
                                  'run' VALUE o.run_minutes_per_unit, 'qc' VALUE o.quality_check,
                                  'rate' VALUE (w.labor_rate + w.machine_rate + w.overhead_rate)) ORDER BY o.operation_seq RETURNING CLOB)
                            FROM mfg_routing_operation o JOIN mfg_work_center w ON w.id = o.work_center_id WHERE o.routing_id = r.id) FORMAT JSON,
             'versions' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE v.id, 'v' VALUE v.version_no, 'st' VALUE v.status_code,
                                     'sn' VALUE NOONA_MFG_PKG.status_label(v.status_code)) ORDER BY v.version_no DESC RETURNING CLOB)
                                 FROM mfg_routing v WHERE v.company_id = r.company_id AND v.item_id = r.item_id) FORMAT JSON
             RETURNING CLOB)
      INTO l_out FROM mfg_routing r WHERE r.id = l_id AND r.company_id = company;
    RETURN l_out;
  END routing_doc_json;

  -- ================================================================ التكلفة المعيارية
  -- تكلفة الوحدة لكل عنصر؛ الخامة المصنعة بلا رصيد تكلفة تأخذ تكلفتها المجمعة من قائمتها ومسارها
  PROCEDURE std_cost(p_item NUMBER, p_qty NUMBER, p_bom NUMBER, p_routing NUMBER,
                     o_mat OUT NUMBER, o_lab OUT NUMBER, o_mac OUT NUMBER, o_ovh OUT NUMBER, p_depth PLS_INTEGER DEFAULT 0) IS
    l_bom  NUMBER := NVL(p_bom, default_bom(p_item));
    l_rt   NUMBER := NVL(p_routing, default_routing(p_item));
    l_base NUMBER;
    l_qty  NUMBER;
    l_uc   NUMBER;
    m NUMBER; a NUMBER; b NUMBER; c NUMBER;
  BEGIN
    o_mat := 0; o_lab := 0; o_mac := 0; o_ovh := 0;
    IF p_depth > 25 THEN RETURN; END IF;
    IF l_bom IS NOT NULL THEN
      SELECT base_quantity INTO l_base FROM mfg_bom WHERE id = l_bom;
      l_qty := NVL(NULLIF(p_qty, 0), l_base);
      FOR r IN (SELECT component_item_id ci, quantity q, scrap_pct s, is_co_product co FROM mfg_bom_line WHERE bom_id = l_bom) LOOP
        l_uc := NOONA_INV_PKG.avg_cost(r.ci);
        IF NVL(l_uc, 0) = 0 AND default_bom(r.ci) IS NOT NULL THEN
          std_cost(r.ci, NULL, NULL, NULL, m, a, b, c, p_depth + 1);
          l_uc := m + a + b + c;
        END IF;
        -- المنتج المشترك يخفض تكلفة المنتج الرئيسي بقيمته
        o_mat := o_mat + CASE WHEN r.co = 'Y' THEN -1 ELSE 1 + NVL(r.s, 0) / 100 END * r.q / l_base * NVL(l_uc, 0);
      END LOOP;
    ELSE
      l_qty := NVL(NULLIF(p_qty, 0), 1);
    END IF;
    IF l_rt IS NOT NULL THEN
      FOR r IN (SELECT o.setup_minutes st, o.run_minutes_per_unit rn, w.labor_rate lr, w.machine_rate mr, w.overhead_rate orr
                  FROM mfg_routing_operation o JOIN mfg_work_center w ON w.id = o.work_center_id WHERE o.routing_id = l_rt) LOOP
        -- زمن الإعداد يوزع على كمية الأمر
        o_lab := o_lab + (r.st / l_qty + r.rn) / 60 * r.lr;
        o_mac := o_mac + (r.st / l_qty + r.rn) / 60 * r.mr;
        o_ovh := o_ovh + (r.st / l_qty + r.rn) / 60 * r.orr;
      END LOOP;
    END IF;
    o_mat := ROUND(GREATEST(o_mat, 0), 6); o_lab := ROUND(o_lab, 6); o_mac := ROUND(o_mac, 6); o_ovh := ROUND(o_ovh, 6);
  END std_cost;

  FUNCTION std_cost_json(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT NULL, p_bom_id IN NUMBER DEFAULT NULL,
                         p_routing_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
    m NUMBER; a NUMBER; b NUMBER; c NUMBER;
  BEGIN
    std_cost(p_item_id, p_qty, p_bom_id, p_routing_id, m, a, b, c);
    RETURN '{"mat":' || fnum(m) || ',"lab":' || fnum(a) || ',"mac":' || fnum(b) || ',"ovh":' || fnum(c)
        || ',"total":' || fnum(ROUND(m + a + b + c, 6)) || '}';
  END std_cost_json;

  FUNCTION std_unit_cost(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    m NUMBER; a NUMBER; b NUMBER; c NUMBER;
  BEGIN
    std_cost(p_item_id, p_qty, NULL, NULL, m, a, b, c);
    RETURN ROUND(m + a + b + c, 6);
  END std_unit_cost;

  -- ================================================================ الترحيل
  PROCEDURE add_line(p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines, p_acc NUMBER, p_dr NUMBER, p_cr NUMBER, p_cc NUMBER,
                     p_desc VARCHAR2, p_item NUMBER DEFAULT NULL) IS
    l_dr NUMBER := ROUND(NVL(p_dr, 0), 2);
    l_cr NUMBER := ROUND(NVL(p_cr, 0), 2);
  BEGIN
    IF l_dr = 0 AND l_cr = 0 THEN RETURN; END IF;
    NOONA_CORE_PKG.assert(p_acc IS NOT NULL, 'NOONA-MFG-090', 'حسابات التصنيع غير مجهزة؛ نفذ تجهيز التصنيع', 'Manufacturing accounts are not set up');
    FOR i IN 1 .. p_lines.COUNT LOOP
      IF p_lines(i).account_id = p_acc AND NVL(p_lines(i).cost_center_id, 0) = NVL(p_cc, 0)
         AND ((l_dr > 0 AND p_lines(i).debit > 0) OR (l_cr > 0 AND p_lines(i).credit > 0)) THEN
        p_lines(i).debit := p_lines(i).debit + l_dr;
        p_lines(i).credit := p_lines(i).credit + l_cr;
        RETURN;
      END IF;
    END LOOP;
    p_lines.EXTEND;
    p_lines(p_lines.COUNT).account_id := p_acc;
    p_lines(p_lines.COUNT).debit := l_dr;
    p_lines(p_lines.COUNT).credit := l_cr;
    p_lines(p_lines.COUNT).cost_center_id := p_cc;
    p_lines(p_lines.COUNT).description := SUBSTR(p_desc, 1, 1000);
    p_lines(p_lines.COUNT).item_id := p_item;
  END add_line;

  -- يوازن فروق التقريب (هللات) على حساب العمل تحت التشغيل ثم يرحل عبر المحرك المحاسبي
  FUNCTION post(p_entity VARCHAR2, p_id NUMBER, p_class VARCHAR2, p_date DATE, p_desc VARCHAR2, p_lines IN OUT NOCOPY NOONA_GL_PKG.t_lines,
                p_ref VARCHAR2, p_cc NUMBER) RETURN NUMBER IS
    l_dr NUMBER := 0;
    l_cr NUMBER := 0;
    l_j  NUMBER;
    l_ev NUMBER;
  BEGIN
    FOR i IN 1 .. p_lines.COUNT LOOP
      l_dr := l_dr + p_lines(i).debit; l_cr := l_cr + p_lines(i).credit;
    END LOOP;
    IF l_dr <> l_cr THEN
      add_line(p_lines, acc('1110'), GREATEST(l_cr - l_dr, 0), GREATEST(l_dr - l_cr, 0), p_cc, 'فرق تقريب');
      l_dr := GREATEST(l_dr, l_cr);
    END IF;
    IF l_dr = 0 THEN RETURN NULL; END IF;
    l_j := NOONA_ACE_PKG.post_source(p_class, 'MANUFACTURING', p_entity, p_id, p_date, SUBSTR(p_desc, 1, 1000),
                                     NOONA_GL_PKG.ledger_currency, 1, p_lines, p_ref, NULL, 'MANUFACTURING');
    SELECT MAX(id) INTO l_ev FROM ace_accounting_event
     WHERE source_entity_type = p_entity AND source_entity_id = p_id AND status_code = 'POSTED' AND reversal_of_event_id IS NULL;
    UPDATE mfg_wip_cost SET accounting_event_id = l_ev
     WHERE source_entity_type = p_entity AND source_entity_id = p_id AND accounting_event_id IS NULL;
    RETURN l_j;
  END post;

  FUNCTION wip(p_order NUMBER, p_seq NUMBER, p_element VARCHAR2, p_amount NUMBER, p_date DATE, p_entry VARCHAR2, p_item NUMBER,
               p_qty NUMBER, p_minutes NUMBER, p_desc VARCHAR2, p_src_type VARCHAR2, p_src_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF ROUND(NVL(p_amount, 0), 2) = 0 AND p_entry <> 'CHARGE' THEN RETURN NULL; END IF;
    INSERT INTO mfg_wip_cost (company_id, order_id, operation_seq, cost_element, amount, cost_date, entry_type, item_id, quantity, minutes,
                              description, source_entity_type, source_entity_id)
    VALUES (company, p_order, p_seq, p_element, ROUND(NVL(p_amount, 0), 2), TRUNC(p_date), p_entry, p_item, p_qty, p_minutes,
            SUBSTR(p_desc, 1, 500), p_src_type, p_src_id)
    RETURNING id INTO l;
    RETURN l;
  END wip;

  FUNCTION wip_balance(p_order_id IN NUMBER, p_element IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(SUM(CASE entry_type WHEN 'CHARGE' THEN amount ELSE -amount END), 0) INTO l
      FROM mfg_wip_cost WHERE order_id = p_order_id AND (p_element IS NULL OR cost_element = p_element);
    RETURN l;
  END wip_balance;

  -- ================================================================ أوامر الإنتاج
  FUNCTION get_order(p_id NUMBER, p_lock BOOLEAN DEFAULT TRUE) RETURN mfg_production_order%ROWTYPE IS
    l mfg_production_order%ROWTYPE;
  BEGIN
    IF p_lock THEN
      SELECT * INTO l FROM mfg_production_order WHERE id = p_id AND company_id = company FOR UPDATE;
    ELSE
      SELECT * INTO l FROM mfg_production_order WHERE id = p_id AND company_id = company;
    END IF;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-MFG-040', 'أمر الإنتاج غير موجود', 'Production order not found');
  END get_order;

  PROCEDURE assert_active(p_o mfg_production_order%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(p_o.status_code IN ('RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED'), 'NOONA-MFG-041',
      'الأمر ' || p_o.doc_no || ' ' || status_label(p_o.status_code) || '؛ التنفيذ متاح للأوامر المطلقة وقيد التنفيذ فقط',
      'Order is not in execution');
  END assert_active;

  FUNCTION order_cc(p_o mfg_production_order%ROWTYPE) RETURN NUMBER IS
    l NUMBER := p_o.cost_center_id;
  BEGIN
    IF l IS NULL THEN
      SELECT MAX(w.cost_center_id) KEEP (DENSE_RANK FIRST ORDER BY o.operation_seq) INTO l
        FROM mfg_order_operation o JOIN mfg_work_center w ON w.id = o.work_center_id WHERE o.order_id = p_o.id;
    END IF;
    IF l IS NULL THEN
      SELECT MAX(cost_center_id) INTO l FROM inv_warehouse WHERE id = p_o.warehouse_id;
    END IF;
    RETURN l;
  END order_cc;

  -- تكلفة الوحدة الحالية للمكون (المصنع بلا رصيد بتكلفته المجمعة)
  FUNCTION comp_cost(p_item_id IN NUMBER) RETURN NUMBER IS
    l NUMBER := NOONA_INV_PKG.avg_cost(p_item_id);
  BEGIN
    IF NVL(l, 0) = 0 AND default_bom(p_item_id) IS NOT NULL THEN
      l := std_unit_cost(p_item_id);
    END IF;
    RETURN NVL(l, 0);
  END comp_cost;

  -- الاحتياجات من قائمة المواد (تفك القوائم الوهمية) والعمليات من المسار، والتكلفة المعيارية للوحدة
  PROCEDURE build_requirements(p_id NUMBER) IS
    l_o    mfg_production_order%ROWTYPE := get_order(p_id);
    l_base NUMBER;
    l_min  NUMBER := 0;
    l_qc   VARCHAR2(1) := 'N';
    l_det  VARCHAR2(400);
    m NUMBER; a NUMBER; b NUMBER; c NUMBER;
    PROCEDURE add_mat(p_item NUMBER, p_qty NUMBER, p_seq NUMBER, p_line NUMBER, p_depth PLS_INTEGER) IS
      l_ph  NUMBER;
      l_pb  NUMBER;
    BEGIN
      SELECT MIN(id) INTO l_ph FROM mfg_bom WHERE id = default_bom(p_item) AND bom_type = 'PHANTOM';
      IF l_ph IS NOT NULL AND p_depth < 20 THEN
        SELECT base_quantity INTO l_pb FROM mfg_bom WHERE id = l_ph;
        FOR r IN (SELECT component_item_id ci, quantity q, scrap_pct s, operation_seq op FROM mfg_bom_line
                   WHERE bom_id = l_ph AND is_co_product = 'N' ORDER BY line_no) LOOP
          add_mat(r.ci, p_qty * r.q / l_pb * (1 + NVL(r.s, 0) / 100), NVL(p_seq, r.op), NULL, p_depth + 1);
        END LOOP;
        RETURN;
      END IF;
      MERGE INTO mfg_order_material x
      USING (SELECT p_item item_id, NVL(p_seq, -1) seq FROM dual) s
         ON (x.order_id = p_id AND x.item_id = s.item_id AND NVL(x.operation_seq, -1) = s.seq)
       WHEN MATCHED THEN UPDATE SET x.required_qty = x.required_qty + ROUND(p_qty, 6)
       WHEN NOT MATCHED THEN INSERT (company_id, order_id, bom_line_id, item_id, required_qty, uom_id, warehouse_id, is_substitute,
                                     std_unit_cost, operation_seq)
            VALUES (company, p_id, p_line, p_item, ROUND(p_qty, 6), (SELECT base_uom_id FROM inv_item WHERE id = p_item),
                    NVL(l_o.source_warehouse_id, l_o.warehouse_id), 'N', comp_cost(p_item), p_seq);
    END add_mat;
  BEGIN
    DELETE FROM mfg_order_material WHERE order_id = p_id;
    DELETE FROM mfg_order_operation WHERE order_id = p_id;
    SELECT base_quantity INTO l_base FROM mfg_bom WHERE id = l_o.bom_id;
    FOR r IN (SELECT id, component_item_id ci, quantity q, scrap_pct s, operation_seq op FROM mfg_bom_line
               WHERE bom_id = l_o.bom_id AND is_co_product = 'N' ORDER BY line_no) LOOP
      add_mat(r.ci, l_o.planned_qty * r.q / l_base * (1 + NVL(r.s, 0) / 100), r.op, r.id, 0);
    END LOOP;
    IF l_o.routing_id IS NOT NULL THEN
      FOR r IN (SELECT * FROM mfg_routing_operation WHERE routing_id = l_o.routing_id ORDER BY operation_seq) LOOP
        INSERT INTO mfg_order_operation (company_id, order_id, operation_seq, work_center_id, planned_minutes, description, setup_minutes,
                                         run_minutes_per_unit, quality_check, status_code)
        VALUES (company, p_id, r.operation_seq, r.work_center_id, ROUND(r.setup_minutes + r.run_minutes_per_unit * l_o.planned_qty, 2),
                r.description, r.setup_minutes, r.run_minutes_per_unit, r.quality_check, 'PENDING');
        l_min := l_min + r.setup_minutes + r.run_minutes_per_unit * l_o.planned_qty;
        IF r.quality_check = 'Y' THEN l_qc := 'Y'; END IF;
      END LOOP;
    END IF;
    std_cost(l_o.item_id, l_o.planned_qty, l_o.bom_id, l_o.routing_id, m, a, b, c);
    l_det := '{"MATERIAL":' || fnum(m) || ',"LABOR":' || fnum(a) || ',"MACHINE":' || fnum(b) || ',"OVERHEAD":' || fnum(c) || '}';
    UPDATE mfg_production_order
       SET std_unit_cost = ROUND(m + a + b + c, 6),
           std_cost_detail = l_det,
           estimated_cost = ROUND((m + a + b + c) * planned_qty, 2),
           requires_qc = CASE WHEN l_qc = 'Y' OR requires_qc = 'Y' THEN 'Y' ELSE 'N' END,
           planned_start = NVL(planned_start, CAST(doc_date AS TIMESTAMP)),
           planned_end = NVL(planned_end, CAST(doc_date + GREATEST(CEIL(l_min / 480), 1) - 1 AS TIMESTAMP))
     WHERE id = p_id;
  END build_requirements;

  FUNCTION save_order(p_doc IN CLOB) RETURN NUMBER IS
    l_id     NUMBER := JSON_VALUE(p_doc, '$.id' RETURNING NUMBER);
    l_item   NUMBER := JSON_VALUE(p_doc, '$.item' RETURNING NUMBER);
    l_qty    NUMBER := JSON_VALUE(p_doc, '$.qty' RETURNING NUMBER);
    l_bom    NUMBER := JSON_VALUE(p_doc, '$.bom' RETURNING NUMBER);
    l_rt     NUMBER := JSON_VALUE(p_doc, '$.routing' RETURNING NUMBER);
    l_wh     NUMBER := JSON_VALUE(p_doc, '$.wh' RETURNING NUMBER);
    l_swh    NUMBER := JSON_VALUE(p_doc, '$.swh' RETURNING NUMBER);
    l_date   DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_start  DATE := d(JSON_VALUE(p_doc, '$.start'));
    l_end    DATE := d(JSON_VALUE(p_doc, '$.end'));
    l_prio   VARCHAR2(30) := NVL(JSON_VALUE(p_doc, '$.priority'), 'NORMAL');
    l_lot    VARCHAR2(100) := TRIM(JSON_VALUE(p_doc, '$.lot'));
    l_exp    DATE := d(JSON_VALUE(p_doc, '$.exp'));
    l_cc     NUMBER := JSON_VALUE(p_doc, '$.cc' RETURNING NUMBER);
    l_notes  VARCHAR2(1000) := SUBSTR(JSON_VALUE(p_doc, '$.notes'), 1, 1000);
    l_parent NUMBER := JSON_VALUE(p_doc, '$.parent' RETURNING NUMBER);
    l_qc     VARCHAR2(1) := NVL(JSON_VALUE(p_doc, '$.qc'), 'N');
    l_action VARCHAR2(30) := NVL(JSON_VALUE(p_doc, '$.action'), 'SAVE');
    l_o      mfg_production_order%ROWTYPE;
    l_n      NUMBER;
  BEGIN
    SAVEPOINT mfg_save;
    IF l_id IS NOT NULL THEN
      l_o := get_order(l_id);
      NOONA_CORE_PKG.assert(l_o.status_code IN ('PLANNED', 'APPROVED'), 'NOONA-MFG-042',
        'لا يعدل الأمر بعد إطلاقه؛ استخدم الإيقاف أو الإلغاء', 'Order cannot be changed after release');
      guard('MFG_PRODUCTION_ORDER.UPDATE');
      l_item := l_o.item_id;
    ELSE
      guard('MFG_PRODUCTION_ORDER.CREATE');
    END IF;
    NOONA_CORE_PKG.assert(l_item IS NOT NULL, 'NOONA-MFG-012', 'اختر المنتج', 'Choose the product');
    NOONA_CORE_PKG.assert(NVL(l_qty, 0) > 0, 'NOONA-MFG-043', 'كمية الإنتاج يجب أن تكون موجبة', 'Quantity must be positive');
    l_bom := NVL(l_bom, default_bom(l_item));
    NOONA_CORE_PKG.assert(l_bom IS NOT NULL, 'NOONA-MFG-044', 'لا توجد قائمة مواد منشورة للمنتج ' || item_label(l_item),
                          'No published bill of materials');
    SELECT COUNT(*) INTO l_n FROM mfg_bom WHERE id = l_bom AND item_id = l_item AND company_id = company AND status_code = 'PUBLISHED';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-MFG-045', 'قائمة المواد المختارة غير منشورة أو لا تخص المنتج', 'BOM is not published for the item');
    l_rt := NVL(l_rt, default_routing(l_item));
    IF l_rt IS NOT NULL THEN
      SELECT COUNT(*) INTO l_n FROM mfg_routing WHERE id = l_rt AND item_id = l_item AND company_id = company AND status_code = 'PUBLISHED';
      NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-MFG-046', 'المسار المختار غير منشور أو لا يخص المنتج', 'Routing is not published for the item');
    END IF;
    l_wh := NVL(l_wh, NOONA_INV_PKG.default_warehouse);
    NOONA_CORE_PKG.assert(l_wh IS NOT NULL, 'NOONA-MFG-047', 'حدد مستودع استلام الإنتاج', 'Receiving warehouse is required');
    NOONA_CORE_PKG.assert(l_prio IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'), 'NOONA-MFG-048', 'أولوية غير صالحة', 'Invalid priority');
    NOONA_CORE_PKG.assert(l_end IS NULL OR l_start IS NULL OR l_end >= l_start, 'NOONA-MFG-049', 'تاريخ النهاية قبل البداية',
                          'End date is before start date');
    IF l_id IS NULL THEN
      SELECT base_uom_id INTO l_n FROM inv_item WHERE id = l_item;
      INSERT INTO mfg_production_order (company_id, branch_id, doc_no, doc_date, item_id, bom_id, routing_id, planned_qty, uom_id, warehouse_id,
                                        source_warehouse_id, planned_start, planned_end, priority, lot_no, expiry_date, cost_center_id, notes,
                                        parent_order_id, requires_qc, status_code)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), l_date, l_item, l_bom, l_rt, l_qty,
              l_n, l_wh, NVL(l_swh, l_wh), CAST(l_start AS TIMESTAMP), CAST(l_end AS TIMESTAMP), l_prio, l_lot, l_exp, l_cc, l_notes,
              l_parent, CASE WHEN l_qc = 'Y' THEN 'Y' ELSE 'N' END, 'PLANNED')
      RETURNING id INTO l_id;
      UPDATE mfg_production_order
         SET doc_no = NOONA_REFERENCE_PKG.next_doc_no(c_order, company, branch_id, l_date, c_order, l_id)
       WHERE id = l_id;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, l_id, 'CREATE', 'SUCCESS');
    ELSE
      UPDATE mfg_production_order
         SET doc_date = l_date, bom_id = l_bom, routing_id = l_rt, planned_qty = l_qty, warehouse_id = l_wh,
             source_warehouse_id = NVL(l_swh, l_wh), planned_start = CAST(l_start AS TIMESTAMP), planned_end = CAST(l_end AS TIMESTAMP),
             priority = l_prio, lot_no = l_lot, expiry_date = l_exp, cost_center_id = l_cc, notes = l_notes,
             requires_qc = CASE WHEN l_qc = 'Y' THEN 'Y' ELSE 'N' END, status_code = 'PLANNED'
       WHERE id = l_id;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, l_id, 'UPDATE', 'SUCCESS');
    END IF;
    build_requirements(l_id);
    IF l_action IN ('APPROVE', 'RELEASE') THEN
      approve_order(l_id);
    END IF;
    IF l_action = 'RELEASE' THEN
      release_order(l_id);
    END IF;
    RETURN l_id;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_save;
    RAISE;
  END save_order;

  PROCEDURE approve_order(p_order_id IN NUMBER) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
  BEGIN
    guard('MFG_PRODUCTION_ORDER.APPROVE');
    NOONA_CORE_PKG.assert(l_o.status_code = 'PLANNED', 'NOONA-MFG-050', 'يعتمد الأمر المخطط فقط', 'Only planned orders can be approved');
    UPDATE mfg_production_order SET status_code = 'APPROVED' WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', c_order, p_order_id, 'APPROVE', 'SUCCESS');
  END approve_order;

  FUNCTION variance_treatment RETURN VARCHAR2 IS
    l VARCHAR2(30);
  BEGIN
    SELECT MAX(variance_treatment) INTO l FROM mfg_setting WHERE company_id = company;
    RETURN NVL(l, 'EXPENSE');
  END variance_treatment;

  FUNCTION update_item_std_cost RETURN VARCHAR2 IS
    l VARCHAR2(1);
  BEGIN
    SELECT MAX(update_item_std_cost) INTO l FROM mfg_setting WHERE company_id = company;
    RETURN NVL(l, 'Y');
  END update_item_std_cost;

  PROCEDURE save_settings(p_treatment IN VARCHAR2, p_update_std IN VARCHAR2) IS
  BEGIN
    guard('MFG_SETTING.UPDATE');
    NOONA_CORE_PKG.assert(p_treatment IN ('EXPENSE', 'INVENTORY') AND NVL(p_update_std, 'Y') IN ('Y', 'N'), 'NOONA-MFG-090',
      'اختر معالجة الانحراف وتحديث التكلفة المعيارية', 'Choose the variance treatment');
    MERGE INTO mfg_setting s USING (SELECT company c FROM dual) x ON (s.company_id = x.c)
     WHEN MATCHED THEN UPDATE SET variance_treatment = p_treatment, update_item_std_cost = NVL(p_update_std, 'Y')
     WHEN NOT MATCHED THEN INSERT (company_id, variance_treatment, update_item_std_cost) VALUES (x.c, p_treatment, NVL(p_update_std, 'Y'));
    NOONA_AUDIT_PKG.log_event('CONFIG', 'MFG_SETTING', NULL, 'UPDATE', 'SUCCESS', p_new_values => '{"variance":"' || p_treatment || '"}');
  END save_settings;

  PROCEDURE release_order(p_order_id IN NUMBER) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.POST');
    NOONA_CORE_PKG.assert(l_o.status_code = 'APPROVED', 'NOONA-MFG-051', 'يطلق الأمر المعتمد فقط', 'Only approved orders can be released');
    SELECT COUNT(*) INTO l_n FROM mfg_bom WHERE id = l_o.bom_id AND status_code = 'PUBLISHED';
    NOONA_CORE_PKG.assert(l_n = 1, 'NOONA-MFG-052', 'قائمة المواد المثبتة على الأمر لم تعد منشورة؛ عدل الأمر', 'BOM is no longer published');
    -- تثبيت الاحتياجات والتكلفة المعيارية بأسعار وقت الإطلاق
    build_requirements(p_order_id);
    UPDATE mfg_production_order SET status_code = 'RELEASED' WHERE id = p_order_id;
    -- التكلفة المعيارية للمنتج في بطاقة الصنف من آخر أمر مطلق (يقرؤها محرك التسعير وتقارير الهوامش)
    IF update_item_std_cost = 'Y' THEN
      UPDATE inv_item_company SET standard_cost = (SELECT ROUND(std_unit_cost, 4) FROM mfg_production_order WHERE id = p_order_id)
       WHERE item_id = l_o.item_id AND company_id = company
         AND (SELECT std_unit_cost FROM mfg_production_order WHERE id = p_order_id) > 0;
    END IF;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, p_order_id, 'RELEASE', 'SUCCESS');
  END release_order;

  PROCEDURE hold_order(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
  BEGIN
    guard('MFG_PRODUCTION_ORDER.UPDATE');
    assert_active(l_o);
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-MFG-053', 'اكتب سبب الإيقاف', 'Reason is required');
    UPDATE mfg_production_order SET status_code = 'ON_HOLD', hold_reason = SUBSTR(p_reason, 1, 1000) WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, p_order_id, 'HOLD', 'SUCCESS', p_reason => p_reason);
  END hold_order;

  PROCEDURE resume_order(p_order_id IN NUMBER) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.UPDATE');
    NOONA_CORE_PKG.assert(l_o.status_code = 'ON_HOLD', 'NOONA-MFG-054', 'الأمر غير موقوف', 'Order is not on hold');
    SELECT COUNT(*) INTO l_n FROM mfg_wip_cost WHERE order_id = p_order_id AND ROWNUM = 1;
    UPDATE mfg_production_order
       SET status_code = CASE WHEN completed_qty > 0 THEN 'PARTIALLY_COMPLETED' WHEN l_n > 0 THEN 'IN_PROGRESS' ELSE 'RELEASED' END,
           hold_reason = NULL
     WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, p_order_id, 'RESUME', 'SUCCESS');
  END resume_order;

  PROCEDURE cancel_order(p_order_id IN NUMBER, p_reason IN VARCHAR2) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.CANCEL');
    NOONA_CORE_PKG.assert(l_o.status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'ON_HOLD'), 'NOONA-MFG-055',
      'لا يلغى أمر بدأ تنفيذه؛ أعد الخامات ثم أكمله وأقفله', 'Order in execution cannot be cancelled');
    NOONA_CORE_PKG.assert(TRIM(p_reason) IS NOT NULL, 'NOONA-MFG-053', 'اكتب سبب الإلغاء', 'Reason is required');
    SELECT COUNT(*) INTO l_n FROM mfg_wip_cost WHERE order_id = p_order_id AND ROWNUM = 1;
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-MFG-056',
      'على الأمر تكاليف مسجلة (خامات أو عمليات)؛ أعد الخامات وأقفل الأمر بدلاً من إلغائه', 'Order has costs; close it instead');
    UPDATE mfg_production_order SET status_code = 'CANCELLED', hold_reason = SUBSTR(p_reason, 1, 1000) WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, p_order_id, 'CANCEL', 'SUCCESS', p_reason => p_reason);
  END cancel_order;

  PROCEDURE started(p_o mfg_production_order%ROWTYPE, p_date DATE) IS
  BEGIN
    UPDATE mfg_production_order
       SET status_code = CASE WHEN status_code = 'RELEASED' THEN 'IN_PROGRESS' ELSE status_code END,
           actual_start = NVL(actual_start, CAST(p_date AS TIMESTAMP))
     WHERE id = p_o.id;
  END started;

  -- ---------------------------------------------------------------- صرف الخامات وإرجاعها
  FUNCTION move_materials(p_doc CLOB, p_return BOOLEAN) RETURN NUMBER IS
    l_o     mfg_production_order%ROWTYPE := get_order(JSON_VALUE(p_doc, '$.order' RETURNING NUMBER));
    l_date  DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_wh    NUMBER := JSON_VALUE(p_doc, '$.wh' RETURNING NUMBER);
    l_cnt   NUMBER := CASE WHEN JSON_QUERY(p_doc, '$.lines[0]') IS NOT NULL THEN 1 ELSE 0 END;
    TYPE t_req IS RECORD (mat NUMBER, item NUMBER, qty NUMBER, wh NUMBER, uc NUMBER);
    TYPE t_reqs IS TABLE OF t_req;
    l_reqs  t_reqs := t_reqs();
    l_moves NOONA_INV_PKG.t_moves;
    l_lines NOONA_GL_PKG.t_lines;
    l_txn   NUMBER;
    l_first NUMBER;
    l_j     NUMBER;
    l_m     mfg_order_material%ROWTYPE;
    l_mat   NUMBER;
    l_cc    NUMBER;
    l_dn    VARCHAR2(100);
    l_tot   NUMBER;
    l_x     NUMBER;
  BEGIN
    SAVEPOINT mfg_mv;
    guard('MFG_PRODUCTION_ORDER.POST');
    assert_active(l_o);
    l_cc := order_cc(l_o);
    -- الأسطر المطلوبة
    IF l_cnt = 0 AND NOT p_return THEN
      FOR r IN (SELECT id, item_id, required_qty - issued_qty + returned_qty q, warehouse_id FROM mfg_order_material
                 WHERE order_id = l_o.id AND required_qty - issued_qty + returned_qty > 0 ORDER BY id) LOOP
        l_reqs.EXTEND; l_reqs(l_reqs.COUNT).mat := r.id; l_reqs(l_reqs.COUNT).item := r.item_id; l_reqs(l_reqs.COUNT).qty := r.q;
        l_reqs(l_reqs.COUNT).wh := NVL(l_wh, r.warehouse_id);
      END LOOP;
    ELSE
      FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (m NUMBER PATH '$.m', i NUMBER PATH '$.i', q NUMBER PATH '$.q'))) LOOP
        CONTINUE WHEN NVL(r.q, 0) = 0 OR (r.m IS NULL AND r.i IS NULL);
        NOONA_CORE_PKG.assert(r.q > 0, 'NOONA-MFG-060', 'الكمية يجب أن تكون موجبة', 'Quantity must be positive');
        IF r.m IS NULL THEN
          -- مادة إضافية خارج قائمة المواد (صرف فقط)
          NOONA_CORE_PKG.assert(NOT p_return, 'NOONA-MFG-061', 'حدد سطر المادة المرتجعة', 'Choose the material line');
          SELECT MIN(id) INTO l_mat FROM mfg_order_material WHERE order_id = l_o.id AND item_id = r.i;
          IF l_mat IS NULL THEN
            SELECT base_uom_id INTO l_x FROM inv_item WHERE id = r.i;
            INSERT INTO mfg_order_material (company_id, order_id, item_id, required_qty, uom_id, warehouse_id, is_substitute, std_unit_cost)
            VALUES (company, l_o.id, r.i, 0, l_x, NVL(l_o.source_warehouse_id, l_o.warehouse_id), 'N', comp_cost(r.i))
            RETURNING id INTO l_mat;
          END IF;
        ELSE
          l_mat := r.m;
        END IF;
        SELECT * INTO l_m FROM mfg_order_material WHERE id = l_mat AND order_id = l_o.id;
        IF p_return THEN
          NOONA_CORE_PKG.assert(r.q <= l_m.issued_qty - l_m.returned_qty, 'NOONA-MFG-062',
            'المرتجع من ' || item_label(l_m.item_id) || ' أكبر من المصروف الصافي (' || fqty(l_m.issued_qty - l_m.returned_qty) || ')',
            'Return exceeds the net issued quantity');
        END IF;
        l_reqs.EXTEND; l_reqs(l_reqs.COUNT).mat := l_mat; l_reqs(l_reqs.COUNT).item := l_m.item_id; l_reqs(l_reqs.COUNT).qty := r.q;
        l_reqs(l_reqs.COUNT).wh := NVL(l_wh, l_m.warehouse_id);
        IF p_return THEN
          l_reqs(l_reqs.COUNT).uc := ROUND(l_m.issued_cost / NULLIF(l_m.issued_qty - l_m.returned_qty, 0), 6);
        END IF;
      END LOOP;
    END IF;
    NOONA_CORE_PKG.assert(l_reqs.COUNT > 0, 'NOONA-MFG-063',
      CASE WHEN p_return THEN 'حدد الكميات المرتجعة' ELSE 'لا توجد كميات متبقية للصرف' END, 'Nothing to move');
    -- حركة مخزون وقيد لكل مستودع
    DECLARE
      l_whs t_num;
      l_k   PLS_INTEGER;
    BEGIN
      FOR i IN 1 .. l_reqs.COUNT LOOP
        l_whs(NVL(l_reqs(i).wh, NOONA_INV_PKG.default_warehouse)) := 1;
      END LOOP;
      l_k := l_whs.FIRST;
      WHILE l_k IS NOT NULL LOOP
        l_moves := NOONA_INV_PKG.t_moves();
        l_lines := NOONA_GL_PKG.t_lines();
        FOR i IN 1 .. l_reqs.COUNT LOOP
          IF NVL(l_reqs(i).wh, NOONA_INV_PKG.default_warehouse) = l_k THEN
            l_moves.EXTEND;
            l_moves(l_moves.COUNT).item_id := l_reqs(i).item;
            l_moves(l_moves.COUNT).qty := l_reqs(i).qty;
            l_moves(l_moves.COUNT).unit_cost := l_reqs(i).uc;
            l_moves(l_moves.COUNT).line_ref := TO_CHAR(l_reqs(i).mat);
          END IF;
        END LOOP;
        l_txn := NOONA_INV_PKG.move(CASE WHEN p_return THEN 'MFG_RETURN' ELSE 'MFG_ISSUE' END, l_k, l_date, c_order, l_o.id, l_moves,
                                    SUBSTR(l_o.doc_no, 1, 30));
        l_first := NVL(l_first, l_txn);
        l_tot := 0;
        FOR i IN 1 .. l_moves.COUNT LOOP
          l_mat := TO_NUMBER(l_moves(i).line_ref);
          l_x := NVL(l_moves(i).total_cost, 0);
          IF p_return THEN
            UPDATE mfg_order_material SET returned_qty = returned_qty + l_moves(i).qty, issued_cost = issued_cost - l_x WHERE id = l_mat;
          ELSE
            UPDATE mfg_order_material SET issued_qty = issued_qty + l_moves(i).qty, issued_cost = issued_cost + l_x WHERE id = l_mat;
          END IF;
          SELECT * INTO l_m FROM mfg_order_material WHERE id = l_mat;
          IF l_txn IS NOT NULL THEN
            l_x := wip(l_o.id, l_m.operation_seq, 'MATERIAL', CASE WHEN p_return THEN -l_x ELSE l_x END, l_date, 'CHARGE', l_m.item_id,
                       CASE WHEN p_return THEN -1 ELSE 1 END * l_moves(i).qty, NULL,
                       CASE WHEN p_return THEN 'إرجاع ' ELSE 'صرف ' END || item_label(l_m.item_id), 'INV_TRANSACTION', l_txn);
            l_tot := l_tot + NVL(l_moves(i).total_cost, 0);
            IF p_return THEN
              add_line(l_lines, NOONA_INV_PKG.account_for(l_m.item_id, 'INVENTORY'), l_moves(i).total_cost, 0, NULL,
                       'إرجاع ' || item_label(l_m.item_id), l_m.item_id);
            ELSE
              add_line(l_lines, NOONA_INV_PKG.account_for(l_m.item_id, 'INVENTORY'), 0, l_moves(i).total_cost, NULL,
                       'صرف ' || item_label(l_m.item_id), l_m.item_id);
            END IF;
          END IF;
        END LOOP;
        IF l_txn IS NOT NULL AND l_tot > 0 THEN
          IF p_return THEN
            add_line(l_lines, acc('1110'), 0, l_tot, l_cc, 'تخفيض الإنتاج تحت التشغيل ' || l_o.doc_no);
          ELSE
            add_line(l_lines, acc('1110'), l_tot, 0, l_cc, 'الإنتاج تحت التشغيل ' || l_o.doc_no);
          END IF;
          SELECT doc_no INTO l_dn FROM inv_transaction WHERE id = l_txn;
          l_j := post('INV_TRANSACTION', l_txn, CASE WHEN p_return THEN 'MFG_MATERIAL_RETURNED' ELSE 'MFG_MATERIAL_ISSUED' END, l_date,
                      CASE WHEN p_return THEN 'إرجاع خامات من أمر الإنتاج ' ELSE 'صرف خامات لأمر الإنتاج ' END || l_o.doc_no || ' - '
                      || item_label(l_o.item_id) || ' (' || l_dn || ')', l_lines, l_dn, l_cc);
        END IF;
        l_k := l_whs.NEXT(l_k);
      END LOOP;
    END;
    started(l_o, l_date);
    NOONA_AUDIT_PKG.log_event('POSTING', c_order, l_o.id, CASE WHEN p_return THEN 'RETURN_MATERIAL' ELSE 'ISSUE_MATERIAL' END, 'SUCCESS');
    RETURN l_first;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ROLLBACK TO mfg_mv;
    NOONA_CORE_PKG.raise_error('NOONA-MFG-064', 'سطر المادة غير موجود في الأمر', 'Material line not found');
  WHEN OTHERS THEN
    ROLLBACK TO mfg_mv;
    RAISE;
  END move_materials;

  FUNCTION issue_materials(p_doc IN CLOB) RETURN NUMBER IS
  BEGIN
    RETURN move_materials(p_doc, FALSE);
  END issue_materials;

  FUNCTION return_materials(p_doc IN CLOB) RETURN NUMBER IS
  BEGIN
    RETURN move_materials(p_doc, TRUE);
  END return_materials;

  PROCEDURE substitute_material(p_material_id IN NUMBER, p_item_id IN NUMBER) IS
    l_m   mfg_order_material%ROWTYPE;
    l_o   mfg_production_order%ROWTYPE;
    l_f   NUMBER;
    l_rem NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.UPDATE');
    SELECT * INTO l_m FROM mfg_order_material WHERE id = p_material_id AND company_id = company;
    l_o := get_order(l_m.order_id);
    NOONA_CORE_PKG.assert(l_o.status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED'), 'NOONA-MFG-065',
                          'الأمر لا يقبل الاستبدال في حالته', 'Order status does not allow substitution');
    SELECT MAX(conversion_factor) INTO l_f FROM mfg_bom_substitute WHERE bom_line_id = l_m.bom_line_id AND substitute_item_id = p_item_id;
    NOONA_CORE_PKG.assert(l_f IS NOT NULL, 'NOONA-MFG-066', 'الصنف ليس بديلاً معتمداً لهذا المكون في قائمة المواد',
                          'Not an approved substitute');
    l_rem := l_m.required_qty - (l_m.issued_qty - l_m.returned_qty);
    NOONA_CORE_PKG.assert(l_rem > 0, 'NOONA-MFG-067', 'لا توجد كمية متبقية من المكون لاستبدالها', 'Nothing left to substitute');
    UPDATE mfg_order_material SET required_qty = issued_qty - returned_qty WHERE id = p_material_id;
    MERGE INTO mfg_order_material x
    USING (SELECT p_item_id item_id FROM dual) s ON (x.order_id = l_m.order_id AND x.item_id = s.item_id AND x.bom_line_id = l_m.bom_line_id)
     WHEN MATCHED THEN UPDATE SET x.required_qty = x.required_qty + ROUND(l_rem * l_f, 6)
     WHEN NOT MATCHED THEN INSERT (company_id, order_id, bom_line_id, item_id, required_qty, uom_id, warehouse_id, is_substitute, std_unit_cost,
                                   operation_seq)
          VALUES (company, l_m.order_id, l_m.bom_line_id, p_item_id, ROUND(l_rem * l_f, 6), (SELECT base_uom_id FROM inv_item WHERE id = p_item_id),
                  l_m.warehouse_id, 'Y', l_m.std_unit_cost / l_f, l_m.operation_seq);
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, l_m.order_id, 'SUBSTITUTE', 'SUCCESS',
      p_new_values => '{"from":' || l_m.item_id || ',"to":' || p_item_id || ',"qty":' || fnum(l_rem * l_f) || '}');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-MFG-064', 'سطر المادة غير موجود', 'Material line not found');
  END substitute_material;

  -- ---------------------------------------------------------------- تقارير العمليات
  FUNCTION report_operation(p_doc IN CLOB) RETURN NUMBER IS
    l_op    mfg_order_operation%ROWTYPE;
    l_o     mfg_production_order%ROWTYPE;
    l_w     mfg_work_center%ROWTYPE;
    l_date  DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_setup NUMBER := NVL(JSON_VALUE(p_doc, '$.setup' RETURNING NUMBER), 0);
    l_run   NUMBER := NVL(JSON_VALUE(p_doc, '$.run' RETURNING NUMBER), 0);
    l_good  NUMBER := NVL(JSON_VALUE(p_doc, '$.good' RETURNING NUMBER), 0);
    l_scrap NUMBER := NVL(JSON_VALUE(p_doc, '$.scrap' RETURNING NUMBER), 0);
    l_rew   NUMBER := NVL(JSON_VALUE(p_doc, '$.rework' RETURNING NUMBER), 0);
    l_down  NUMBER := NVL(JSON_VALUE(p_doc, '$.down' RETURNING NUMBER), 0);
    l_done  VARCHAR2(1) := NVL(JSON_VALUE(p_doc, '$.done'), 'N');
    l_opid  NUMBER := JSON_VALUE(p_doc, '$.op' RETURNING NUMBER);
    l_min   NUMBER;
    l_prev  NUMBER;
    l_first NUMBER;
    l_x     NUMBER;
    l_lab   NUMBER; l_mac NUMBER; l_ovh NUMBER;
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_j     NUMBER;
    l_cc    NUMBER;
  BEGIN
    SAVEPOINT mfg_op;
    guard('MFG_PRODUCTION_ORDER.POST');
    BEGIN
      SELECT * INTO l_op FROM mfg_order_operation WHERE id = l_opid AND company_id = company;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-MFG-070', 'العملية غير موجودة', 'Operation not found');
    END;
    l_o := get_order(l_op.order_id);
    assert_active(l_o);
    NOONA_CORE_PKG.assert(l_op.status_code NOT IN ('COMPLETED', 'SKIPPED'), 'NOONA-MFG-071', 'العملية ' || l_op.operation_seq || ' منتهية',
                          'Operation is already completed');
    NOONA_CORE_PKG.assert(LEAST(l_setup, l_run, l_good, l_scrap, l_rew, l_down) >= 0, 'NOONA-MFG-072', 'القيم لا تكون سالبة',
                          'Values cannot be negative');
    l_min := l_setup + l_run;
    NOONA_CORE_PKG.assert(l_min > 0 OR l_good > 0 OR l_scrap > 0 OR l_done = 'Y', 'NOONA-MFG-073', 'سجل الزمن أو الكميات المنجزة',
                          'Enter time or quantities');
    -- لا تنجز عملية أكثر مما أنجزته العملية السابقة
    SELECT MAX(good_qty) KEEP (DENSE_RANK LAST ORDER BY operation_seq) INTO l_prev FROM mfg_order_operation
     WHERE order_id = l_o.id AND operation_seq < l_op.operation_seq AND status_code <> 'SKIPPED';
    NOONA_CORE_PKG.assert(l_prev IS NULL OR l_op.good_qty + l_good <= l_prev, 'NOONA-MFG-074',
      'الكمية المقبولة في العملية ' || l_op.operation_seq || ' (' || fqty(l_op.good_qty + l_good) || ') تتجاوز ما أنجزته العملية السابقة ('
      || fqty(l_prev) || ')', 'Good quantity exceeds the previous operation');
    SELECT * INTO l_w FROM mfg_work_center WHERE id = l_op.work_center_id;
    l_lab := ROUND(l_min / 60 * l_w.labor_rate, 2);
    l_mac := ROUND(l_min / 60 * l_w.machine_rate, 2);
    l_ovh := ROUND(l_min / 60 * l_w.overhead_rate, 2);
    UPDATE mfg_order_operation
       SET actual_minutes = actual_minutes + l_min, good_qty = good_qty + l_good, scrap_qty = scrap_qty + l_scrap,
           rework_qty = rework_qty + l_rew, downtime_minutes = downtime_minutes + l_down,
           status_code = CASE WHEN l_done = 'Y' THEN 'COMPLETED' ELSE 'IN_PROGRESS' END
     WHERE id = l_op.id;
    -- قيد التحميل: مدين الإنتاج تحت التشغيل، دائن العمالة والأعباء المحملة
    l_first := wip(l_o.id, l_op.operation_seq, 'LABOR', l_lab, l_date, 'CHARGE', NULL, l_good, l_min,
                   'عملية ' || l_op.operation_seq || ' - ' || l_op.description, NULL, NULL);
    l_x := wip(l_o.id, l_op.operation_seq, 'MACHINE', l_mac, l_date, 'CHARGE', NULL, NULL, l_min, 'آلات ' || l_w.name_ar, NULL, NULL);
    l_x := wip(l_o.id, l_op.operation_seq, 'OVERHEAD', l_ovh, l_date, 'CHARGE', NULL, NULL, l_min, 'تحميل ' || l_w.name_ar, NULL, NULL);
    UPDATE mfg_wip_cost SET source_entity_type = 'MFG_WIP_COST', source_entity_id = l_first
     WHERE order_id = l_o.id AND source_entity_id IS NULL;
    IF l_lab + l_mac + l_ovh > 0 THEN
      l_cc := order_cc(l_o);
      add_line(l_lines, acc('1110'), l_lab + l_mac + l_ovh, 0, l_cc, 'الإنتاج تحت التشغيل ' || l_o.doc_no);
      add_line(l_lines, acc('5103'), 0, l_lab, l_w.cost_center_id, 'عمالة محملة - ' || l_w.name_ar);
      add_line(l_lines, acc('5104'), 0, l_mac + l_ovh, l_w.cost_center_id, 'أعباء محملة - ' || l_w.name_ar);
      l_j := post('MFG_WIP_COST', l_first, 'MFG_OPERATION_REPORTED', l_date,
                  'تحميل العملية ' || l_op.operation_seq || ' (' || l_op.description || ') على أمر الإنتاج ' || l_o.doc_no
                  || ': ' || fqty(l_min) || ' دقيقة', l_lines, l_o.doc_no, l_cc);
    ELSE
      DELETE FROM mfg_wip_cost WHERE source_entity_type = 'MFG_WIP_COST' AND source_entity_id = l_first AND amount = 0 AND id <> l_first;
    END IF;
    started(l_o, l_date);
    NOONA_AUDIT_PKG.log_event('POSTING', c_order, l_o.id, 'REPORT_OPERATION', 'SUCCESS',
      p_new_values => '{"op":' || l_op.operation_seq || ',"minutes":' || fnum(l_min) || ',"good":' || fnum(l_good) || '}');
    RETURN l_first;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_op;
    RAISE;
  END report_operation;

  -- ---------------------------------------------------------------- استلام الإنتاج
  -- يخفض العمل تحت التشغيل بالتكلفة المعيارية لكل عنصر؛ المقبول يدخل المخزون والمرفوض يحمل على الهالك
  PROCEDURE receive(p_o mfg_production_order%ROWTYPE, p_good NUMBER, p_bad NUMBER, p_date DATE, p_lot VARCHAR2, p_exp DATE,
                    p_entity VARCHAR2, p_id NUMBER, p_class VARCHAR2, o_txn OUT NUMBER, o_cost OUT NUMBER) IS
    l_det   CLOB := NVL(p_o.std_cost_detail, '{}');
    l_moves NOONA_INV_PKG.t_moves := NOONA_INV_PKG.t_moves();
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_cc    NUMBER := order_cc(p_o);
    l_base  NUMBER;
    l_tot   NUMBER := 0;
    l_x     NUMBER;
    l_j     NUMBER;
    l_co    NUMBER := 0;
    l_dn    VARCHAR2(100);
    l_qty   NUMBER := NVL(p_good, 0) + NVL(p_bad, 0);
  BEGIN
    o_txn := NULL; o_cost := 0;
    IF l_qty <= 0 THEN RETURN; END IF;
    -- تخفيض العمل تحت التشغيل لكل عنصر
    FOR e IN (SELECT 'MATERIAL' el FROM dual UNION ALL SELECT 'LABOR' FROM dual UNION ALL SELECT 'MACHINE' FROM dual
              UNION ALL SELECT 'OVERHEAD' FROM dual) LOOP
      l_x := ROUND(std_el(l_det, e.el) * l_qty, 2);
      IF l_x <> 0 THEN
        l_x := wip(p_o.id, NULL, e.el, l_x, p_date, 'RELIEF', p_o.item_id, l_qty, NULL,
                   'إنتاج ' || fqty(l_qty) || ' ' || item_label(p_o.item_id), p_entity, p_id);
      END IF;
    END LOOP;
    SELECT NVL(SUM(amount), 0) INTO l_tot FROM mfg_wip_cost WHERE source_entity_type = p_entity AND source_entity_id = p_id AND entry_type = 'RELIEF';
    o_cost := l_tot;
    IF NVL(p_good, 0) > 0 THEN
      l_moves.EXTEND;
      l_moves(1).item_id := p_o.item_id;
      l_moves(1).qty := p_good;
      l_moves(1).unit_cost := ROUND(NVL(p_o.std_unit_cost, 0), 6);
      l_moves(1).lot_no := NVL(p_lot, NVL(p_o.lot_no, p_o.doc_no));
      l_moves(1).expiry := NVL(p_exp, p_o.expiry_date);
      -- المنتجات المشتركة بنسبة المقبول وبتكلفتها الحالية
      SELECT base_quantity INTO l_base FROM mfg_bom WHERE id = p_o.bom_id;
      FOR r IN (SELECT component_item_id ci, quantity q FROM mfg_bom_line WHERE bom_id = p_o.bom_id AND is_co_product = 'Y') LOOP
        l_moves.EXTEND;
        l_moves(l_moves.COUNT).item_id := r.ci;
        l_moves(l_moves.COUNT).qty := ROUND(r.q * p_good / l_base, 6);
        l_moves(l_moves.COUNT).unit_cost := comp_cost(r.ci);
        l_moves(l_moves.COUNT).lot_no := NVL(p_lot, NVL(p_o.lot_no, p_o.doc_no));
        l_moves(l_moves.COUNT).expiry := NVL(p_exp, p_o.expiry_date);
      END LOOP;
      o_txn := NOONA_INV_PKG.move('MFG_RECEIPT', p_o.warehouse_id, p_date, c_order, p_o.id, l_moves, SUBSTR(p_o.doc_no, 1, 30));
      FOR i IN 1 .. l_moves.COUNT LOOP
        add_line(l_lines, NOONA_INV_PKG.account_for(l_moves(i).item_id, 'INVENTORY'), l_moves(i).total_cost, 0, NULL,
                 'استلام ' || fqty(l_moves(i).qty) || ' ' || item_label(l_moves(i).item_id), l_moves(i).item_id);
        IF i > 1 THEN
          l_co := l_co + NVL(l_moves(i).total_cost, 0);
          l_x := wip(p_o.id, NULL, 'MATERIAL', l_moves(i).total_cost, p_date, 'RELIEF', l_moves(i).item_id, l_moves(i).qty, NULL,
                     'منتج مشترك ' || item_label(l_moves(i).item_id), p_entity, p_id);
        END IF;
      END LOOP;
      -- فرق تقريب تكلفة الوحدة بين الاستلام والتخفيض
      l_x := NVL(l_moves(1).total_cost, 0) - ROUND(l_tot * p_good / l_qty, 2);
      IF l_x <> 0 THEN
        l_x := wip(p_o.id, NULL, 'MATERIAL', l_x, p_date, 'RELIEF', p_o.item_id, 0, NULL, 'فرق تقريب', p_entity, p_id);
      END IF;
    END IF;
    IF NVL(p_bad, 0) > 0 THEN
      add_line(l_lines, acc('5213'), ROUND(l_tot * p_bad / l_qty, 2), 0, l_cc,
               'هالك مرفوض بالجودة ' || fqty(p_bad) || ' ' || item_label(p_o.item_id), p_o.item_id);
    END IF;
    SELECT NVL(SUM(amount), 0) INTO l_tot FROM mfg_wip_cost WHERE source_entity_type = p_entity AND source_entity_id = p_id AND entry_type = 'RELIEF';
    o_cost := l_tot;
    add_line(l_lines, acc('1110'), 0, l_tot, l_cc, 'تخفيض الإنتاج تحت التشغيل ' || p_o.doc_no);
    IF o_txn IS NOT NULL THEN
      SELECT doc_no INTO l_dn FROM inv_transaction WHERE id = o_txn;
    END IF;
    l_j := post(p_entity, p_id, p_class, p_date, 'استلام إنتاج أمر ' || p_o.doc_no || ': ' || fqty(p_good) || ' مقبول'
                || CASE WHEN p_bad > 0 THEN ' و' || fqty(p_bad) || ' مرفوض' END || ' - ' || item_label(p_o.item_id)
                || CASE WHEN l_dn IS NOT NULL THEN ' (' || l_dn || ')' END, l_lines, NVL(l_dn, p_o.doc_no), l_cc);
    UPDATE mfg_production_order
       SET completed_qty = completed_qty + NVL(p_good, 0), scrapped_qty = scrapped_qty + NVL(p_bad, 0),
           status_code = CASE WHEN completed_qty + NVL(p_good, 0) >= planned_qty THEN 'COMPLETED' ELSE 'PARTIALLY_COMPLETED' END,
           actual_end = CASE WHEN completed_qty + NVL(p_good, 0) >= planned_qty THEN CAST(p_date AS TIMESTAMP) ELSE actual_end END
     WHERE id = p_o.id;
  END receive;

  FUNCTION report_output(p_doc IN CLOB) RETURN NUMBER IS
    l_o     mfg_production_order%ROWTYPE := get_order(JSON_VALUE(p_doc, '$.order' RETURNING NUMBER));
    l_qty   NUMBER := NVL(JSON_VALUE(p_doc, '$.qty' RETURNING NUMBER), 0);
    l_scrap NUMBER := NVL(JSON_VALUE(p_doc, '$.scrap' RETURNING NUMBER), 0);
    l_date  DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_lot   VARCHAR2(100) := TRIM(JSON_VALUE(p_doc, '$.lot'));
    l_exp   DATE := d(JSON_VALUE(p_doc, '$.exp'));
    l_key   VARCHAR2(100) := NVL(TRIM(JSON_VALUE(p_doc, '$.key')), RAWTOHEX(SYS_GUID()));
    l_id    NUMBER;
    l_last  NUMBER;
    l_ops   NUMBER;
    l_done  NUMBER;
    l_txn   NUMBER;
    l_cost  NUMBER;
    l_trk   VARCHAR2(30);
  BEGIN
    SAVEPOINT mfg_out;
    guard('MFG_PRODUCTION_ORDER.POST');
    -- إعادة الإرسال بنفس المفتاح لا تكرر الاستلام
    SELECT MIN(id) INTO l_id FROM mfg_order_output WHERE idempotency_key = 'MO' || l_o.id || ':' || l_key;
    IF l_id IS NOT NULL THEN RETURN l_id; END IF;
    assert_active(l_o);
    NOONA_CORE_PKG.assert(l_qty > 0 AND l_scrap >= 0, 'NOONA-MFG-080', 'الكمية المنتجة يجب أن تكون موجبة', 'Quantity must be positive');
    SELECT COUNT(*), MAX(good_qty) KEEP (DENSE_RANK LAST ORDER BY operation_seq) INTO l_ops, l_last
      FROM mfg_order_operation WHERE order_id = l_o.id AND status_code <> 'SKIPPED';
    IF l_ops > 0 THEN
      SELECT NVL(SUM(quantity), 0) INTO l_done FROM mfg_order_output
       WHERE order_id = l_o.id AND output_type = 'MAIN' AND status_code <> 'REJECTED';
      NOONA_CORE_PKG.assert(l_done + l_qty <= l_last, 'NOONA-MFG-081',
        'الكمية المستلمة (' || fqty(l_done + l_qty) || ') تتجاوز المقبول في آخر عملية (' || fqty(l_last) || ')؛ سجل تنفيذ العمليات أولاً',
        'Output exceeds the last operation good quantity');
    END IF;
    SELECT tracking_mode INTO l_trk FROM inv_item WHERE id = l_o.item_id;
    IF l_trk IN ('LOT', 'LOT_AND_SERIAL') THEN
      l_lot := NVL(l_lot, NVL(l_o.lot_no, l_o.doc_no));
    END IF;
    INSERT INTO mfg_order_output (company_id, order_id, item_id, output_type, quantity, idempotency_key, output_date, lot_no, expiry_date,
                                  unit_cost, status_code)
    VALUES (company, l_o.id, l_o.item_id, 'MAIN', l_qty, 'MO' || l_o.id || ':' || l_key, l_date, l_lot, NVL(l_exp, l_o.expiry_date),
            l_o.std_unit_cost, CASE WHEN l_o.requires_qc = 'Y' THEN 'PENDING_QUALITY' ELSE 'POSTED' END)
    RETURNING id INTO l_id;
    IF l_scrap > 0 THEN
      UPDATE mfg_production_order SET scrapped_qty = scrapped_qty + l_scrap WHERE id = l_o.id;
    END IF;
    IF l_o.requires_qc = 'Y' THEN
      INSERT INTO mfg_quality_inspection (company_id, order_id, output_id, inspected_qty, passed_qty, failed_qty, status_code)
      VALUES (company, l_o.id, l_id, l_qty, 0, 0, 'PENDING');
    ELSE
      receive(l_o, l_qty, 0, l_date, l_lot, NVL(l_exp, l_o.expiry_date), 'MFG_ORDER_OUTPUT', l_id, 'MFG_OUTPUT_RECEIVED', l_txn, l_cost);
      UPDATE mfg_order_output SET inv_transaction_id = l_txn, total_cost = l_cost,
             lot_id = (SELECT MAX(lot_id) FROM inv_transaction_line WHERE transaction_id = l_txn AND item_id = l_o.item_id)
       WHERE id = l_id;
    END IF;
    started(l_o, l_date);
    NOONA_AUDIT_PKG.log_event('POSTING', c_order, l_o.id, 'REPORT_OUTPUT', 'SUCCESS',
      p_new_values => '{"qty":' || fnum(l_qty) || ',"scrap":' || fnum(l_scrap) || ',"output":' || l_id || '}');
    RETURN l_id;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_out;
    RAISE;
  END report_output;

  FUNCTION inspect_output(p_doc IN CLOB) RETURN NUMBER IS
    l_out   mfg_order_output%ROWTYPE;
    l_o     mfg_production_order%ROWTYPE;
    l_ins   mfg_quality_inspection%ROWTYPE;
    l_pass  NUMBER := NVL(JSON_VALUE(p_doc, '$.passed' RETURNING NUMBER), 0);
    l_fail  NUMBER := NVL(JSON_VALUE(p_doc, '$.failed' RETURNING NUMBER), 0);
    l_date  DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_notes VARCHAR2(1000) := SUBSTR(JSON_VALUE(p_doc, '$.notes'), 1, 1000);
    l_res   CLOB := JSON_QUERY(p_doc, '$.results' RETURNING CLOB);
    l_txn   NUMBER;
    l_cost  NUMBER;
  BEGIN
    SAVEPOINT mfg_qc;
    guard('MFG_QUALITY_INSPECTION.CREATE');
    BEGIN
      SELECT * INTO l_out FROM mfg_order_output WHERE id = JSON_VALUE(p_doc, '$.output' RETURNING NUMBER) AND company_id = company FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-MFG-082', 'الإنتاج المفحوص غير موجود', 'Output not found');
    END;
    NOONA_CORE_PKG.assert(l_out.status_code = 'PENDING_QUALITY', 'NOONA-MFG-083', 'تم فحص هذا الإنتاج سابقاً', 'Output already inspected');
    NOONA_CORE_PKG.assert(l_pass >= 0 AND l_fail >= 0 AND l_pass + l_fail = l_out.quantity, 'NOONA-MFG-084',
      'المقبول + المرفوض يجب أن يساوي الكمية المفحوصة (' || fqty(l_out.quantity) || ')', 'Passed + failed must equal the inspected quantity');
    l_o := get_order(l_out.order_id);
    SELECT * INTO l_ins FROM mfg_quality_inspection WHERE output_id = l_out.id AND status_code = 'PENDING' AND ROWNUM = 1 FOR UPDATE;
    UPDATE mfg_quality_inspection
       SET passed_qty = l_pass, failed_qty = l_fail, results = l_res, notes = l_notes, inspection_date = l_date,
           status_code = CASE WHEN l_fail = 0 THEN 'PASSED' WHEN l_pass = 0 THEN 'FAILED' ELSE 'CONDITIONAL' END
     WHERE id = l_ins.id;
    receive(l_o, l_pass, l_fail, l_date, l_out.lot_no, l_out.expiry_date, 'MFG_QUALITY_INSPECTION', l_ins.id, 'MFG_QUALITY_INSPECTED',
            l_txn, l_cost);
    UPDATE mfg_order_output
       SET status_code = CASE WHEN l_pass = 0 THEN 'REJECTED' ELSE 'ACCEPTED' END, inv_transaction_id = l_txn, total_cost = l_cost,
           lot_id = (SELECT MAX(lot_id) FROM inv_transaction_line WHERE transaction_id = l_txn AND item_id = l_o.item_id)
     WHERE id = l_out.id;
    NOONA_AUDIT_PKG.log_event('APPROVAL', 'MFG_QUALITY_INSPECTION', l_ins.id, 'INSPECT', 'SUCCESS',
      p_new_values => '{"passed":' || fnum(l_pass) || ',"failed":' || fnum(l_fail) || '}');
    RETURN l_ins.id;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_qc;
    RAISE;
  END inspect_output;

  PROCEDURE complete_order(p_order_id IN NUMBER) IS
    l_o mfg_production_order%ROWTYPE := get_order(p_order_id);
    l_n NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.POST');
    IF l_o.status_code = 'COMPLETED' THEN RETURN; END IF;
    assert_active(l_o);
    SELECT COUNT(*) INTO l_n FROM mfg_order_output WHERE order_id = p_order_id AND status_code = 'PENDING_QUALITY';
    NOONA_CORE_PKG.assert(l_n = 0, 'NOONA-MFG-085', 'يوجد إنتاج بانتظار فحص الجودة', 'Output is waiting for quality inspection');
    UPDATE mfg_production_order SET status_code = 'COMPLETED', actual_end = NVL(actual_end, SYSTIMESTAMP) WHERE id = p_order_id;
    UPDATE mfg_order_operation SET status_code = 'COMPLETED' WHERE order_id = p_order_id AND status_code = 'IN_PROGRESS';
    UPDATE mfg_order_operation SET status_code = 'SKIPPED' WHERE order_id = p_order_id AND status_code = 'PENDING';
    NOONA_AUDIT_PKG.log_event('DATA_CHANGE', c_order, p_order_id, 'COMPLETE', 'SUCCESS');
  END complete_order;

  FUNCTION close_order(p_order_id IN NUMBER, p_date IN DATE DEFAULT NULL) RETURN NUMBER IS
    l_o     mfg_production_order%ROWTYPE := get_order(p_order_id);
    l_date  DATE := NVL(p_date, TRUNC(SYSDATE));
    l_lines NOONA_GL_PKG.t_lines := NOONA_GL_PKG.t_lines();
    l_cc    NUMBER;
    l_b     NUMBER;
    l_tot   NUMBER := 0;
    l_price NUMBER;
    l_x     NUMBER;
    l_j     NUMBER;
    l_n     NUMBER;
    l_mode  VARCHAR2(30) := variance_treatment;
    l_made  NUMBER;
    l_have  NUMBER;
    l_inv   NUMBER := 0;
    PROCEDURE var(p_type VARCHAR2, p_std NUMBER, p_act NUMBER) IS
    BEGIN
      IF ROUND(NVL(p_act, 0) - NVL(p_std, 0), 2) <> 0 THEN
        INSERT INTO mfg_variance (company_id, order_id, variance_type, standard_amount, actual_amount, variance_amount, posted_at, posted_by)
        VALUES (company, p_order_id, p_type, ROUND(p_std, 2), ROUND(p_act, 2), ROUND(p_act - p_std, 2), SYSTIMESTAMP,
                NOONA_CTX_PKG.current_user_name);
      END IF;
    END var;
    FUNCTION charged(p_el VARCHAR2) RETURN NUMBER IS
      l NUMBER;
    BEGIN
      SELECT NVL(SUM(amount), 0) INTO l FROM mfg_wip_cost WHERE order_id = p_order_id AND entry_type = 'CHARGE' AND cost_element = p_el;
      RETURN l;
    END charged;
  BEGIN
    SAVEPOINT mfg_close;
    guard('MFG_PRODUCTION_ORDER.POST');
    IF l_o.status_code IN ('RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED') THEN
      complete_order(p_order_id);
      l_o := get_order(p_order_id);
    END IF;
    NOONA_CORE_PKG.assert(l_o.status_code = 'COMPLETED', 'NOONA-MFG-086', 'يقفل الأمر المكتمل فقط', 'Only completed orders can be closed');
    l_cc := order_cc(l_o);
    -- انحرافات تحليلية: سعر الخامات = (التكلفة الفعلية - الكمية الصافية × السعر المعياري)، والباقي كمية
    SELECT NVL(SUM(issued_cost - (issued_qty - returned_qty) * NVL(std_unit_cost, 0)), 0) INTO l_price
      FROM mfg_order_material WHERE order_id = p_order_id;
    FOR e IN (SELECT 'MATERIAL' el FROM dual UNION ALL SELECT 'LABOR' FROM dual UNION ALL SELECT 'MACHINE' FROM dual
              UNION ALL SELECT 'OVERHEAD' FROM dual UNION ALL SELECT 'SUBCONTRACT' FROM dual UNION ALL SELECT 'SCRAP' FROM dual) LOOP
      l_b := wip_balance(p_order_id, e.el);
      IF l_b <> 0 THEN
        l_x := wip(p_order_id, NULL, e.el, l_b, l_date, 'VARIANCE', NULL, NULL, NULL, 'انحراف ' || element_label(e.el) || ' عند الإقفال',
                   c_order, p_order_id);
        l_tot := l_tot + l_b;
        IF l_mode = 'INVENTORY' THEN
          NULL;      -- يحمل الإجمالي بعد الحلقة على المخزون وتكلفة المبيعات
        ELSIF l_b > 0 THEN
          add_line(l_lines, acc('5105'), l_b, 0, l_cc, 'انحراف ' || element_label(e.el) || ' - ' || l_o.doc_no);
        ELSE
          add_line(l_lines, acc('5105'), 0, -l_b, l_cc, 'انحراف ' || element_label(e.el) || ' - ' || l_o.doc_no);
        END IF;
      END IF;
      IF e.el = 'MATERIAL' THEN
        var('MATERIAL_PRICE', charged('MATERIAL') - l_price, charged('MATERIAL'));
        var('MATERIAL_USAGE', charged('MATERIAL') - l_b, charged('MATERIAL') - l_price);
      ELSIF e.el = 'LABOR' THEN
        var('LABOR_EFFICIENCY', charged('LABOR') - l_b, charged('LABOR'));
      ELSIF e.el IN ('MACHINE', 'OVERHEAD') THEN
        var('OVERHEAD', charged(e.el) - l_b, charged(e.el));
      END IF;
    END LOOP;
    -- التكلفة الفعلية: الانحراف على قيمة المنتج الذي ما زال في المخزون (يعدل متوسط تكلفته)، وما بيع منه على تكلفة المبيعات
    IF l_mode = 'INVENTORY' AND l_tot <> 0 THEN
      -- الكمية الجيدة المستلمة للمخزون (المرفوض في الفحص لا يدخل المخزون)
      SELECT NVL(completed_qty, 0) INTO l_made FROM mfg_production_order WHERE id = p_order_id;
      l_have := GREATEST(NOONA_INV_PKG.on_hand(l_o.item_id, NULL), 0);
      l_inv := CASE WHEN l_made > 0 THEN ROUND(l_tot * LEAST(l_have, l_made) / l_made, 2) ELSE 0 END;
      IF l_inv <> 0 THEN
        add_line(l_lines, NOONA_INV_PKG.account_for(l_o.item_id, 'INVENTORY'), GREATEST(l_inv, 0), GREATEST(-l_inv, 0), l_cc,
                 'تحميل انحراف التكلفة على المخزون - ' || l_o.doc_no);
        UPDATE inv_item_cost SET total_value = total_value + ROUND(l_inv * on_hand_qty / NULLIF(l_have, 0), 2),
               average_cost = CASE WHEN on_hand_qty > 0 THEN ROUND((total_value + l_inv * on_hand_qty / l_have) / on_hand_qty, 6) ELSE average_cost END
         WHERE company_id = company AND item_id = l_o.item_id AND on_hand_qty > 0 AND l_have > 0;
      END IF;
      IF l_tot - l_inv <> 0 THEN
        add_line(l_lines, NOONA_INV_PKG.account_for(l_o.item_id, 'COGS'), GREATEST(l_tot - l_inv, 0), GREATEST(l_inv - l_tot, 0), l_cc,
                 'انحراف التكلفة للكمية المباعة - ' || l_o.doc_no);
      END IF;
    END IF;
    IF l_tot > 0 THEN
      add_line(l_lines, acc('1110'), 0, l_tot, l_cc, 'تسوية الإنتاج تحت التشغيل ' || l_o.doc_no);
    ELSIF l_tot < 0 THEN
      add_line(l_lines, acc('1110'), -l_tot, 0, l_cc, 'تسوية الإنتاج تحت التشغيل ' || l_o.doc_no);
    END IF;
    SELECT COUNT(*) INTO l_n FROM mfg_wip_cost WHERE source_entity_type = c_order AND source_entity_id = p_order_id;
    IF l_n > 0 THEN
      l_j := post(c_order, p_order_id, 'MFG_ORDER_CLOSED', l_date, 'إقفال أمر الإنتاج ' || l_o.doc_no || ' - ' || item_label(l_o.item_id)
                  || ': تسوية الانحرافات', l_lines, l_o.doc_no, l_cc);
    END IF;
    UPDATE mfg_production_order
       SET status_code = 'CLOSED', posted_at = SYSTIMESTAMP, posted_by = NOONA_CTX_PKG.current_user_name,
           actual_cost = (SELECT NVL(SUM(amount), 0) FROM mfg_wip_cost WHERE order_id = p_order_id AND entry_type = 'CHARGE'),
           accounting_event_id = (SELECT MAX(id) FROM ace_accounting_event WHERE source_entity_type = c_order AND source_entity_id = p_order_id
                                     AND status_code = 'POSTED')
     WHERE id = p_order_id;
    NOONA_AUDIT_PKG.log_event('POSTING', c_order, p_order_id, 'CLOSE', 'SUCCESS', p_new_values => '{"variance":' || fnum(l_tot) || ',"mode":"' || l_mode || '","toInventory":' || fnum(l_inv) || '}');
    RETURN l_j;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_close;
    RAISE;
  END close_order;

  FUNCTION order_progress(p_order_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT LEAST(ROUND(completed_qty / NULLIF(planned_qty, 0) * 100), 100) INTO l FROM mfg_production_order WHERE id = p_order_id;
    RETURN NVL(l, 0);
  END order_progress;

  FUNCTION order_json(p_order_id IN NUMBER) RETURN CLOB IS
    l_o   mfg_production_order%ROWTYPE;
    l_out CLOB;
    l_act VARCHAR2(400);
    l_pq  NUMBER;
  BEGIN
    IF p_order_id IS NULL THEN
      RETURN '{"id":null,"status":"PLANNED","date":"' || ds(TRUNC(SYSDATE)) || '","priority":"NORMAL","wh":'
          || fnum(NOONA_INV_PKG.default_warehouse) || ',"materials":[],"operations":[],"outputs":[],"wip":[],"journals":[]}';
    END IF;
    l_o := get_order(p_order_id, FALSE);
    SELECT COUNT(*) INTO l_pq FROM mfg_order_output WHERE order_id = p_order_id AND status_code = 'PENDING_QUALITY';
    l_act := CASE l_o.status_code
               WHEN 'PLANNED' THEN 'SAVE,APPROVE,RELEASE,CANCEL'
               WHEN 'APPROVED' THEN 'SAVE,RELEASE,CANCEL'
               WHEN 'RELEASED' THEN 'ISSUE,OPERATION,OUTPUT,HOLD,CANCEL'
               WHEN 'IN_PROGRESS' THEN 'ISSUE,RETURN,OPERATION,OUTPUT,HOLD,COMPLETE,CLOSE'
               WHEN 'PARTIALLY_COMPLETED' THEN 'ISSUE,RETURN,OPERATION,OUTPUT,HOLD,COMPLETE,CLOSE'
               WHEN 'ON_HOLD' THEN 'RESUME,CANCEL'
               WHEN 'COMPLETED' THEN 'CLOSE' END
             || CASE WHEN l_pq > 0 THEN ',INSPECT' END;
    SELECT JSON_OBJECT(
             'id' VALUE o.id, 'no' VALUE o.doc_no, 'date' VALUE TO_CHAR(o.doc_date, 'YYYY-MM-DD'), 'item' VALUE o.item_id,
             'itemName' VALUE NOONA_INV_PKG.item_label(o.item_id), 'qty' VALUE o.planned_qty, 'done' VALUE o.completed_qty,
             'scrap' VALUE o.scrapped_qty, 'bom' VALUE o.bom_id,
             'bomName' VALUE (SELECT 'v' || version_no || ' - ' || name_ar FROM mfg_bom WHERE id = o.bom_id),
             'routing' VALUE o.routing_id,
             'routingName' VALUE (SELECT 'v' || version_no || ' - ' || name_ar FROM mfg_routing WHERE id = o.routing_id),
             'wh' VALUE o.warehouse_id, 'swh' VALUE o.source_warehouse_id,
             'start' VALUE TO_CHAR(o.planned_start, 'YYYY-MM-DD'), 'end' VALUE TO_CHAR(o.planned_end, 'YYYY-MM-DD'),
             'astart' VALUE TO_CHAR(o.actual_start, 'YYYY-MM-DD'), 'aend' VALUE TO_CHAR(o.actual_end, 'YYYY-MM-DD'),
             'priority' VALUE o.priority, 'lot' VALUE o.lot_no, 'exp' VALUE TO_CHAR(o.expiry_date, 'YYYY-MM-DD'), 'cc' VALUE o.cost_center_id,
             'notes' VALUE o.notes, 'qc' VALUE o.requires_qc, 'hold' VALUE o.hold_reason, 'parent' VALUE o.parent_order_id,
             'status' VALUE o.status_code, 'statusName' VALUE NOONA_MFG_PKG.status_label(o.status_code), 'actions' VALUE l_act,
             'stdUnit' VALUE o.std_unit_cost, 'estimated' VALUE o.estimated_cost, 'actual' VALUE o.actual_cost,
             'std' VALUE o.std_cost_detail FORMAT JSON,
             'progress' VALUE NOONA_MFG_PKG.order_progress(o.id),
             'materials' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE m.id, 'i' VALUE m.item_id,
                                  'n' VALUE NOONA_INV_PKG.item_label(m.item_id), 'req' VALUE m.required_qty, 'iss' VALUE m.issued_qty,
                                  'ret' VALUE m.returned_qty, 'rem' VALUE GREATEST(m.required_qty - m.issued_qty + m.returned_qty, 0),
                                  'oh' VALUE NOONA_INV_PKG.on_hand(m.item_id, m.warehouse_id), 'wh' VALUE m.warehouse_id,
                                  'std' VALUE m.std_unit_cost, 'cost' VALUE m.issued_cost, 'op' VALUE m.operation_seq, 'sub' VALUE m.is_substitute,
                                  'subs' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('i' VALUE s.substitute_item_id,
                                                  'n' VALUE NOONA_INV_PKG.item_label(s.substitute_item_id), 'f' VALUE s.conversion_factor,
                                                  'oh' VALUE NOONA_INV_PKG.on_hand(s.substitute_item_id, m.warehouse_id)) RETURNING CLOB)
                                                  FROM mfg_bom_substitute s WHERE s.bom_line_id = m.bom_line_id AND m.is_substitute = 'N') FORMAT JSON
                                  RETURNING CLOB) ORDER BY m.operation_seq NULLS FIRST, m.id RETURNING CLOB)
                                  FROM mfg_order_material m WHERE m.order_id = o.id) FORMAT JSON,
             'operations' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE p.id, 'seq' VALUE p.operation_seq, 'd' VALUE p.description,
                                   'wc' VALUE p.work_center_id, 'wcn' VALUE NOONA_MFG_PKG.wc_label(p.work_center_id),
                                   'plan' VALUE p.planned_minutes, 'act' VALUE p.actual_minutes, 'good' VALUE p.good_qty,
                                   'scrap' VALUE p.scrap_qty, 'rework' VALUE p.rework_qty, 'down' VALUE p.downtime_minutes, 'qc' VALUE p.quality_check,
                                   'st' VALUE p.status_code, 'sn' VALUE NOONA_MFG_PKG.status_label(p.status_code)
                                   RETURNING CLOB) ORDER BY p.operation_seq RETURNING CLOB)
                                   FROM mfg_order_operation p WHERE p.order_id = o.id) FORMAT JSON,
             'outputs' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE t.id, 'date' VALUE TO_CHAR(t.output_date, 'YYYY-MM-DD'),
                                'q' VALUE t.quantity, 'lot' VALUE t.lot_no, 'cost' VALUE t.total_cost, 'st' VALUE t.status_code,
                                'sn' VALUE NOONA_MFG_PKG.status_label(t.status_code),
                                'txn' VALUE (SELECT doc_no FROM inv_transaction WHERE id = t.inv_transaction_id),
                                'pass' VALUE (SELECT MAX(passed_qty) FROM mfg_quality_inspection q WHERE q.output_id = t.id),
                                'fail' VALUE (SELECT MAX(failed_qty) FROM mfg_quality_inspection q WHERE q.output_id = t.id)
                                RETURNING CLOB) ORDER BY t.id RETURNING CLOB)
                                FROM mfg_order_output t WHERE t.order_id = o.id) FORMAT JSON,
             'wip' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('el' VALUE w.cost_element, 'n' VALUE NOONA_MFG_PKG.element_label(w.cost_element),
                            'charge' VALUE w.ch, 'relief' VALUE w.rl, 'var' VALUE w.vr, 'bal' VALUE w.ch - w.rl - w.vr) RETURNING CLOB)
                            FROM (SELECT cost_element, SUM(CASE WHEN entry_type = 'CHARGE' THEN amount ELSE 0 END) ch,
                                         SUM(CASE WHEN entry_type = 'RELIEF' THEN amount ELSE 0 END) rl,
                                         SUM(CASE WHEN entry_type = 'VARIANCE' THEN amount ELSE 0 END) vr
                                    FROM mfg_wip_cost WHERE order_id = o.id GROUP BY cost_element) w) FORMAT JSON,
             'journals' VALUE (SELECT JSON_ARRAYAGG(JSON_OBJECT('id' VALUE j.id, 'no' VALUE j.doc_no, 'date' VALUE TO_CHAR(j.doc_date, 'YYYY-MM-DD'),
                                 'd' VALUE j.description, 'amt' VALUE e.total_amount) ORDER BY j.id RETURNING CLOB)
                                 FROM ace_accounting_event e JOIN gl_journal j ON j.id = e.journal_id
                                WHERE (e.source_entity_type, e.source_entity_id) IN (
                                        SELECT DISTINCT source_entity_type, source_entity_id FROM mfg_wip_cost
                                         WHERE order_id = o.id AND source_entity_id IS NOT NULL)) FORMAT JSON
             RETURNING CLOB)
      INTO l_out FROM mfg_production_order o WHERE o.id = p_order_id;
    RETURN l_out;
  END order_json;

  -- ================================================================ تخطيط احتياجات المواد (MRP)
  -- مستويات منخفضة لكل صنف، ثم صافي الاحتياج مستوى بمستوى: الطلب (أوامر البيع + حد الطلب + احتياجات أوامر الإنتاج)
  -- مقابل المتاح (الرصيد + أوامر الإنتاج المفتوحة + أوامر وطلبات الشراء المفتوحة)؛ الصنف المصنع ينفجر على مكوناته
  FUNCTION mrp_json(p_include_reorder IN VARCHAR2 DEFAULT 'Y') RETURN CLOB IS
    l_in    t_num;     -- الأصناف المشمولة
    l_lvl   t_num;
    l_gross t_num;
    l_sup   t_num;
    l_oh    t_num;
    l_min   t_num;
    l_max   t_num;
    l_bom   t_num;
    l_base  t_num;
    l_maxl  PLS_INTEGER := 0;
    l_k     PLS_INTEGER;
    l_net   NUMBER;
    l_proj  NUMBER;
    l_out   CLOB := '[';
    l_first BOOLEAN := TRUE;
    l_chg   BOOLEAN;
    PROCEDURE inc(p_arr IN OUT NOCOPY t_num, p_k NUMBER, p_v NUMBER) IS
    BEGIN
      IF p_k IS NULL THEN RETURN; END IF;
      l_in(p_k) := 1;
      p_arr(p_k) := CASE WHEN p_arr.EXISTS(p_k) THEN p_arr(p_k) ELSE 0 END + NVL(p_v, 0);
    END inc;
    FUNCTION g(p_arr t_num, p_k NUMBER) RETURN NUMBER IS
    BEGIN
      RETURN CASE WHEN p_arr.EXISTS(p_k) THEN p_arr(p_k) ELSE 0 END;
    END g;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    -- قوائم المواد الافتراضية والمستويات
    FOR b IN (SELECT b.item_id, b.id, b.base_quantity FROM mfg_bom b
               WHERE b.company_id = company AND b.status_code = 'PUBLISHED' AND b.id = NOONA_MFG_PKG.default_bom(b.item_id)) LOOP
      l_bom(b.item_id) := b.id; l_base(b.item_id) := b.base_quantity; inc(l_lvl, b.item_id, 0);
    END LOOP;
    FOR pass IN 1 .. 25 LOOP
      l_chg := FALSE;
      l_k := l_bom.FIRST;
      WHILE l_k IS NOT NULL LOOP
        FOR c IN (SELECT component_item_id ci FROM mfg_bom_line WHERE bom_id = l_bom(l_k) AND is_co_product = 'N') LOOP
          IF g(l_lvl, c.ci) < g(l_lvl, l_k) + 1 OR NOT l_lvl.EXISTS(c.ci) THEN
            l_in(c.ci) := 1;
            l_lvl(c.ci) := GREATEST(g(l_lvl, c.ci), g(l_lvl, l_k) + 1);
            l_chg := TRUE;
          END IF;
        END LOOP;
        l_k := l_bom.NEXT(l_k);
      END LOOP;
      EXIT WHEN NOT l_chg;
    END LOOP;
    -- الطلب المستقل: أوامر البيع المفتوحة
    FOR r IN (SELECT l.item_id, SUM(l.quantity - NVL(l.delivered_qty, 0)) q FROM sal_order_line l JOIN sal_order o ON o.id = l.order_id
               WHERE o.company_id = company AND o.status_code NOT IN ('DRAFT', 'CANCELLED', 'CLOSED', 'COMPLETED', 'REJECTED')
                 AND l.item_id IS NOT NULL AND l.quantity > NVL(l.delivered_qty, 0) GROUP BY l.item_id) LOOP
      inc(l_gross, r.item_id, r.q);
    END LOOP;
    -- الطلب التابع لأوامر الإنتاج المفتوحة (المتبقي غير المصروف)
    FOR r IN (SELECT m.item_id, SUM(GREATEST(m.required_qty - m.issued_qty + m.returned_qty, 0)) q
                FROM mfg_order_material m JOIN mfg_production_order o ON o.id = m.order_id
               WHERE o.company_id = company AND o.status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED', 'ON_HOLD')
               GROUP BY m.item_id) LOOP
      inc(l_gross, r.item_id, r.q);
    END LOOP;
    -- المتاح: أوامر إنتاج مفتوحة، أوامر شراء معتمدة، طلبات شراء قائمة
    FOR r IN (SELECT item_id, SUM(GREATEST(planned_qty - completed_qty, 0)) q FROM mfg_production_order
               WHERE company_id = company AND status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED', 'ON_HOLD')
               GROUP BY item_id) LOOP
      inc(l_sup, r.item_id, r.q);
    END LOOP;
    FOR r IN (SELECT l.item_id, SUM(GREATEST(l.quantity - NVL(l.received_qty, 0), 0)) q FROM pur_order_line l JOIN pur_order o ON o.id = l.order_id
               WHERE o.company_id = company AND o.status_code IN ('APPROVED', 'PARTIALLY_RECEIVED') AND l.item_id IS NOT NULL GROUP BY l.item_id) LOOP
      inc(l_sup, r.item_id, r.q);
    END LOOP;
    FOR r IN (SELECT l.item_id, SUM(GREATEST(l.quantity - l.ordered_qty, 0)) q FROM pur_requisition_line l JOIN pur_requisition h ON h.id = l.requisition_id
               WHERE h.company_id = company AND h.status_code IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'PARTIALLY_ORDERED')
                 AND l.status_code IN ('OPEN', 'PARTIALLY_ORDERED') AND l.item_id IS NOT NULL GROUP BY l.item_id) LOOP
      inc(l_sup, r.item_id, r.q);
    END LOOP;
    IF p_include_reorder = 'Y' THEN
      FOR r IN (SELECT c.item_id, c.min_qty, c.max_qty FROM inv_item_company c JOIN inv_item i ON i.id = c.item_id
                 WHERE c.company_id = company AND c.min_qty > 0 AND i.status_code = 'ACTIVE') LOOP
        l_in(r.item_id) := 1; l_min(r.item_id) := r.min_qty; l_max(r.item_id) := NVL(r.max_qty, r.min_qty);
      END LOOP;
    END IF;
    l_k := l_in.FIRST;
    WHILE l_k IS NOT NULL LOOP
      l_oh(l_k) := NOONA_INV_PKG.on_hand(l_k);
      IF NOT l_lvl.EXISTS(l_k) THEN l_lvl(l_k) := 0; END IF;
      l_maxl := GREATEST(l_maxl, l_lvl(l_k));
      l_k := l_in.NEXT(l_k);
    END LOOP;
    -- صافي الاحتياج مستوى بمستوى
    FOR lv IN 0 .. l_maxl LOOP
      l_k := l_in.FIRST;
      WHILE l_k IS NOT NULL LOOP
        IF l_lvl(l_k) = lv THEN
          l_proj := g(l_oh, l_k) + g(l_sup, l_k) - g(l_gross, l_k);
          IF l_min.EXISTS(l_k) AND l_proj < l_min(l_k) THEN
            l_net := l_max(l_k) - l_proj;
          ELSE
            l_net := -l_proj;
          END IF;
          IF l_net > 0 THEN
            l_net := CEIL(ROUND(l_net, 6) * 1000) / 1000;
            IF l_bom.EXISTS(l_k) THEN
              FOR c IN (SELECT component_item_id ci, quantity q, scrap_pct s FROM mfg_bom_line WHERE bom_id = l_bom(l_k) AND is_co_product = 'N') LOOP
                inc(l_gross, c.ci, c.q * l_net / l_base(l_k) * (1 + NVL(c.s, 0) / 100));
              END LOOP;
            END IF;
            l_out := l_out || ((CASE WHEN l_first THEN '' ELSE ',' END
                  || '{"i":' || l_k || ',"n":' || jt(item_label(l_k)) || ',"t":"' || CASE WHEN l_bom.EXISTS(l_k) THEN 'MAKE' ELSE 'BUY' END
                  || '","lvl":' || lv || ',"oh":' || fnum(g(l_oh, l_k)) || ',"sup":' || fnum(g(l_sup, l_k)) || ',"gross":' || fnum(ROUND(g(l_gross, l_k), 3))
                  || ',"min":' || fnum(CASE WHEN l_min.EXISTS(l_k) THEN l_min(l_k) END) || ',"net":' || fnum(l_net)
                  || ',"bom":' || fnum(CASE WHEN l_bom.EXISTS(l_k) THEN l_bom(l_k) END) || ',"c":' || fnum(comp_cost(l_k)) || '}'));
            l_first := FALSE;
          END IF;
        END IF;
        l_k := l_in.NEXT(l_k);
      END LOOP;
    END LOOP;
    RETURN l_out || (']');
  END mrp_json;

  FUNCTION mrp_execute(p_doc IN CLOB) RETURN CLOB IS
    l_date  DATE := NVL(d(JSON_VALUE(p_doc, '$.date')), TRUNC(SYSDATE));
    l_n     PLS_INTEGER := 0;
    l_req   NUMBER;
    l_no    PLS_INTEGER := 0;
    l_id    NUMBER;
    l_total NUMBER := 0;
    l_wh    NUMBER := NOONA_INV_PKG.default_warehouse;
    l_dn    VARCHAR2(50);
  BEGIN
    SAVEPOINT mfg_mrp;
    FOR r IN (SELECT * FROM JSON_TABLE(p_doc, '$.lines[*]' COLUMNS (i NUMBER PATH '$.i', q NUMBER PATH '$.q', t VARCHAR2(10) PATH '$.t'))) LOOP
      CONTINUE WHEN r.i IS NULL OR NVL(r.q, 0) <= 0;
      IF r.t = 'MAKE' THEN
        l_id := save_order('{"item":' || r.i || ',"qty":' || fnum(r.q) || ',"date":"' || ds(l_date) || '","notes":"من تخطيط احتياجات المواد"}');
        l_n := l_n + 1;
      ELSE
        IF l_req IS NULL THEN
          guard('PUR_REQUISITION.CREATE');
          NOONA_CORE_PKG.assert(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID') IS NOT NULL, 'NOONA-MFG-095', 'لا توجد عضوية للمستخدم الحالي',
                                'No membership in context');
          INSERT INTO pur_requisition (company_id, branch_id, doc_no, doc_date, requester_member_id, purchase_type, required_date, justification,
                                       currency_code, estimated_total, status_code)
          VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), 'DRAFT-' || RAWTOHEX(SYS_GUID()), l_date,
                  TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID')), 'GOODS', l_date + 7, 'مقترحات تخطيط احتياجات المواد (MRP)',
                  NOONA_GL_PKG.ledger_currency, 0, 'DRAFT')
          RETURNING id INTO l_req;
          UPDATE pur_requisition SET doc_no = NOONA_REFERENCE_PKG.next_doc_no('PUR_REQUISITION', company, branch_id, l_date, 'PUR_REQUISITION', l_req)
           WHERE id = l_req;
        END IF;
        l_no := l_no + 1;
        INSERT INTO pur_requisition_line (company_id, requisition_id, line_no, item_id, description, quantity, uom_id, estimated_price, warehouse_id,
                                          ordered_qty, status_code)
        SELECT company, l_req, l_no, id, item_no || ' - ' || name_ar, r.q, base_uom_id, comp_cost(id), l_wh, 0, 'OPEN'
          FROM inv_item WHERE id = r.i;
        l_total := l_total + r.q * comp_cost(r.i);
      END IF;
    END LOOP;
    IF l_req IS NOT NULL THEN
      UPDATE pur_requisition SET estimated_total = ROUND(l_total, 2) WHERE id = l_req;
      NOONA_AUDIT_PKG.log_event('DATA_CHANGE', 'PUR_REQUISITION', l_req, 'CREATE', 'SUCCESS');
    END IF;
    IF l_req IS NOT NULL THEN
      SELECT doc_no INTO l_dn FROM pur_requisition WHERE id = l_req;
    END IF;
    RETURN '{"orders":' || l_n || ',"req":' || fnum(l_req) || ',"reqNo":' || CASE WHEN l_req IS NULL THEN 'null' ELSE jt(l_dn) END || '}';
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO mfg_mrp;
    RAISE;
  END mrp_execute;

  -- ================================================================ القوائم
  FUNCTION lists_json(p_names IN VARCHAR2) RETURN CLOB IS
    l_out   CLOB := '{';
    l_c     CLOB;
    l_co    NUMBER := company;
    l_first BOOLEAN := TRUE;
    FUNCTION want(p VARCHAR2) RETURN BOOLEAN IS BEGIN RETURN INSTR(',' || REPLACE(p_names, ' ') || ',', ',' || p || ',') > 0; END;
    PROCEDURE put(p_name VARCHAR2, p_json CLOB) IS
    BEGIN
      l_out := l_out || ((CASE WHEN l_first THEN '' ELSE ',' END || '"' || p_name || '":' || NVL(p_json, TO_CLOB('[]'))));
      l_first := FALSE;
    END put;
  BEGIN
    IF want('wcs') THEN
      SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE id, 'n' VALUE code || ' - ' || name_ar, 'r' VALUE labor_rate + machine_rate + overhead_rate,
                                       'cap' VALUE capacity_hours_day) ORDER BY code RETURNING CLOB)
        INTO l_c FROM mfg_work_center WHERE company_id = l_co AND is_active = 'Y';
      put('wcs', l_c);
    END IF;
    IF want('products') THEN
      SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE i.id, 'n' VALUE i.item_no || ' - ' || i.name_ar, 'b' VALUE NOONA_MFG_PKG.default_bom(i.id),
                                       'r' VALUE NOONA_MFG_PKG.default_routing(i.id), 'lot' VALUE i.tracking_mode, 'exp' VALUE i.track_expiry)
                           ORDER BY i.item_no RETURNING CLOB)
        INTO l_c FROM inv_item i
       WHERE i.status_code = 'ACTIVE' AND EXISTS (SELECT 1 FROM mfg_bom b WHERE b.item_id = i.id AND b.company_id = l_co AND b.status_code = 'PUBLISHED');
      put('products', l_c);
    END IF;
    IF want('items') THEN
      -- الأصناف القابلة للتصنيع (منتج تام أو نصف مصنع أو له قائمة مواد)
      SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE i.id, 'n' VALUE i.item_no || ' - ' || i.name_ar) ORDER BY i.item_no RETURNING CLOB)
        INTO l_c FROM inv_item i
       WHERE i.status_code = 'ACTIVE' AND (i.item_type IN ('FINISHED_GOOD', 'SEMI_FINISHED') OR i.is_manufactured = 'Y');
      put('items', l_c);
    END IF;
    IF want('whs') THEN
      SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE id, 'n' VALUE code || ' - ' || name_ar) ORDER BY DECODE(warehouse_type, 'MAIN', 0, 1), code RETURNING CLOB)
        INTO l_c FROM inv_warehouse WHERE company_id = l_co AND status_code = 'ACTIVE';
      put('whs', l_c);
    END IF;
    IF want('ccs') THEN
      SELECT JSON_ARRAYAGG(JSON_OBJECT('v' VALUE id, 'n' VALUE code || ' - ' || name_ar) ORDER BY code RETURNING CLOB)
        INTO l_c FROM gl_cost_center WHERE company_id = l_co;
      put('ccs', l_c);
    END IF;
    RETURN l_out || ('}');
  END lists_json;

  -- ================================================================ التقارير
  FUNCTION kpi(p_label VARCHAR2, p_value VARCHAR2, p_icon VARCHAR2, p_class VARCHAR2 DEFAULT '') RETURN VARCHAR2 IS
  BEGIN
    RETURN '<div class="nn-kpi ' || p_class || '"><span class="nn-kpi-icon fa ' || p_icon || '" aria-hidden="true"></span><div>'
        || '<div class="nn-kpi-value">' || p_value || '</div><div class="nn-kpi-label">' || esc(p_label) || '</div></div></div>';
  END kpi;

  FUNCTION head(p_title VARCHAR2) RETURN CLOB IS
  BEGIN
    RETURN NOONA_BRAND_PKG.report_header(p_title);
  END head;

  FUNCTION period(p_from DATE, p_to DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN ' من ' || ds(p_from) || ' إلى ' || ds(p_to);
  END period;

  FUNCTION link(p_link VARCHAR2, p_id NUMBER, p_text VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_link IS NOT NULL THEN '<a href="' || REPLACE(p_link, '#ID#', p_id) || '">' || esc(p_text) || '</a>' ELSE esc(p_text) END;
  END link;

  FUNCTION mfg_summary RETURN CLOB IS
    l_open NUMBER; l_wip NUMBER; l_late NUMBER; l_qc NUMBER; l_done NUMBER; l_var NUMBER;
  BEGIN
    SELECT COUNT(*), COUNT(CASE WHEN planned_end < TRUNC(SYSDATE) THEN 1 END) INTO l_open, l_late
      FROM mfg_production_order
     WHERE company_id = company AND status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED', 'ON_HOLD');
    SELECT NVL(SUM(CASE w.entry_type WHEN 'CHARGE' THEN w.amount ELSE -w.amount END), 0) INTO l_wip
      FROM mfg_wip_cost w JOIN mfg_production_order o ON o.id = w.order_id WHERE o.company_id = company AND o.status_code <> 'CLOSED';
    SELECT COUNT(*) INTO l_qc FROM mfg_order_output WHERE company_id = company AND status_code = 'PENDING_QUALITY';
    SELECT NVL(SUM(quantity), 0) INTO l_done FROM mfg_order_output
     WHERE company_id = company AND status_code IN ('POSTED', 'ACCEPTED') AND output_date >= TRUNC(SYSDATE, 'MM');
    SELECT NVL(SUM(v.variance_amount), 0) INTO l_var FROM mfg_variance v WHERE v.company_id = company AND v.posted_at >= TRUNC(SYSDATE, 'MM');
    RETURN '<div class="nn-kpis">' || kpi('أوامر مفتوحة', l_open, 'fa-industry')
        || kpi('الإنتاج تحت التشغيل', fmt0(l_wip), 'fa-cogs')
        || kpi('أوامر متأخرة', l_late, 'fa-clock-o', CASE WHEN l_late > 0 THEN 'is-danger' END)
        || kpi('بانتظار الجودة', l_qc, 'fa-check-square-o', CASE WHEN l_qc > 0 THEN 'is-warning' END)
        || kpi('المنتج هذا الشهر', fqty(l_done), 'fa-cubes')
        || kpi('انحرافات الشهر', fmt0(l_var), 'fa-balance-scale', CASE WHEN l_var > 0 THEN 'is-warning' END) || '</div>';
  END mfg_summary;

  FUNCTION order_head(p_o mfg_production_order%ROWTYPE) RETURN VARCHAR2 IS
    FUNCTION f(p_l VARCHAR2, p_v VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<div class="nn-field"><div class="nn-field-label">' || p_l || '</div><div class="nn-field-value">' || p_v || '</div></div>';
    END f;
  BEGIN
    RETURN '<div class="nn-fields">' || f('رقم الأمر', esc(p_o.doc_no)) || f('التاريخ', ds(p_o.doc_date))
        || f('المنتج', esc(item_label(p_o.item_id))) || f('الكمية المخططة', fqty(p_o.planned_qty))
        || f('المنتج المقبول', fqty(p_o.completed_qty)) || f('الهالك', fqty(p_o.scrapped_qty))
        || f('الحالة', badge(p_o.status_code)) || f('الأولوية', priority_label(p_o.priority))
        || f('البداية / النهاية المخططة', TO_CHAR(p_o.planned_start, 'YYYY-MM-DD') || ' ← ' || TO_CHAR(p_o.planned_end, 'YYYY-MM-DD'))
        || f('التكلفة المعيارية للوحدة', fmt0(p_o.std_unit_cost)) || '</div>';
  END order_head;

  FUNCTION order_cost_sheet(p_order_id IN NUMBER) RETURN CLOB IS
    l_o    mfg_production_order%ROWTYPE := get_order(p_order_id, FALSE);
    l_html CLOB;
    l_out  NUMBER := l_o.completed_qty + l_o.scrapped_qty;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0; s4 NUMBER := 0; s5 NUMBER := 0;
    l_x    NUMBER;
    l_sm   NUMBER := std_el(l_o.std_cost_detail, 'MATERIAL');
    l_sl   NUMBER := std_el(l_o.std_cost_detail, 'LABOR');
    l_sc   NUMBER := std_el(l_o.std_cost_detail, 'MACHINE');
    l_so   NUMBER := std_el(l_o.std_cost_detail, 'OVERHEAD');
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('بطاقة تكلفة أمر الإنتاج ' || l_o.doc_no) || order_head(l_o)
           || '<h3 class="nn-rpt-title">ملخص التكلفة حسب العنصر</h3><table class="nn-rpt"><thead><tr><th>العنصر</th>'
           || '<th>المعياري للوحدة</th><th>المحمل فعلياً</th><th>المخفض بالإنتاج</th><th>الانحراف المقفل</th><th>الرصيد تحت التشغيل</th></tr></thead><tbody>';
    FOR r IN (SELECT e.el, DECODE(e.el, 'MATERIAL', l_sm, 'LABOR', l_sl, 'MACHINE', l_sc, l_so) su,
                     NVL(SUM(CASE WHEN w.entry_type = 'CHARGE' THEN w.amount END), 0) ch,
                     NVL(SUM(CASE WHEN w.entry_type = 'RELIEF' THEN w.amount END), 0) rl,
                     NVL(SUM(CASE WHEN w.entry_type = 'VARIANCE' THEN w.amount END), 0) vr
                FROM (SELECT 'MATERIAL' el, 1 o FROM dual UNION ALL SELECT 'LABOR', 2 FROM dual UNION ALL SELECT 'MACHINE', 3 FROM dual
                      UNION ALL SELECT 'OVERHEAD', 4 FROM dual) e
                LEFT JOIN mfg_wip_cost w ON w.order_id = p_order_id AND w.cost_element = e.el
               GROUP BY e.el, e.o ORDER BY e.o) LOOP
      s1 := s1 + r.su; s2 := s2 + r.ch; s3 := s3 + r.rl; s4 := s4 + r.vr;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || element_label(r.el) || '</td><td>' || fmt(r.su) || '</td><td>' || fmt(r.ch)
             || '</td><td>' || fmt(r.rl) || '</td><td>' || fmt(r.vr) || '</td><td>' || fmt(r.ch - r.rl - r.vr) || '</td></tr>'));
    END LOOP;
    l_html := l_html || (('</tbody><tfoot><tr><td>الإجمالي</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>' || fmt0(s3)
           || '</td><td>' || fmt0(s4) || '</td><td>' || fmt0(s2 - s3 - s4) || '</td></tr></tfoot></table>'
           || '<div class="nn-fields"><div class="nn-field"><div class="nn-field-label">تكلفة الوحدة الفعلية</div><div class="nn-field-value">'
           || CASE WHEN l_o.completed_qty > 0 THEN fmt0(s2 / l_o.completed_qty) ELSE '-' END || '</div></div>'
           || '<div class="nn-field"><div class="nn-field-label">التكلفة المعيارية للمنتج المقبول</div><div class="nn-field-value">'
           || fmt0(l_o.std_unit_cost * l_o.completed_qty) || '</div></div></div>'
           || '<h3 class="nn-rpt-title">الخامات: المعياري مقابل الفعلي</h3><table class="nn-rpt"><thead><tr><th>المادة</th><th>المطلوب للأمر</th>'
           || '<th>المعياري للمنتج</th><th>الصافي المصروف</th><th>فرق الكمية</th><th>السعر المعياري</th><th>التكلفة الفعلية</th>'
           || '<th>انحراف السعر</th><th>انحراف الكمية</th></tr></thead><tbody>'));
    s1 := 0; s2 := 0;
    FOR m IN (SELECT * FROM mfg_order_material WHERE order_id = p_order_id ORDER BY operation_seq NULLS FIRST, id) LOOP
      l_x := m.required_qty * CASE WHEN l_o.planned_qty > 0 THEN l_out / l_o.planned_qty ELSE 0 END;
      s1 := s1 + (m.issued_cost - (m.issued_qty - m.returned_qty) * NVL(m.std_unit_cost, 0));
      s2 := s2 + ((m.issued_qty - m.returned_qty) - l_x) * NVL(m.std_unit_cost, 0);
      l_html := l_html || (('<tr' || CASE WHEN ABS((m.issued_qty - m.returned_qty) - l_x) > 0.0005 THEN ' class="nn-rpt-warn"' END || '><td class="nn-rpt-text">'
             || esc(item_label(m.item_id)) || CASE WHEN m.is_substitute = 'Y' THEN ' <span class="nn-badge is-info">بديل</span>' END || '</td><td>'
             || fqty(m.required_qty) || '</td><td>' || fqty(ROUND(l_x, 3)) || '</td><td>' || fqty(m.issued_qty - m.returned_qty) || '</td><td>'
             || fqty(ROUND((m.issued_qty - m.returned_qty) - l_x, 3)) || '</td><td>' || fmt(m.std_unit_cost) || '</td><td>' || fmt(m.issued_cost)
             || '</td><td>' || fmt(m.issued_cost - (m.issued_qty - m.returned_qty) * NVL(m.std_unit_cost, 0)) || '</td><td>'
             || fmt(((m.issued_qty - m.returned_qty) - l_x) * NVL(m.std_unit_cost, 0)) || '</td></tr>'));
    END LOOP;
    l_html := l_html || (('</tbody><tfoot><tr><td colspan="7">الإجمالي</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td></tr></tfoot></table>'
           || '<h3 class="nn-rpt-title">العمليات: الزمن المعياري مقابل الفعلي</h3><table class="nn-rpt"><thead><tr><th>العملية</th><th>مركز العمل</th>'
           || '<th>المخطط (دقيقة)</th><th>المعياري للمنجز</th><th>الفعلي</th><th>الكفاءة</th><th>المقبول</th><th>الهالك</th><th>التكلفة المحملة</th>'
           || '<th>الحالة</th></tr></thead><tbody>'));
    FOR p IN (SELECT p.*, (SELECT NVL(SUM(amount), 0) FROM mfg_wip_cost w WHERE w.order_id = p.order_id AND w.operation_seq = p.operation_seq
                              AND w.entry_type = 'CHARGE' AND w.cost_element IN ('LABOR', 'MACHINE', 'OVERHEAD')) cost
                FROM mfg_order_operation p WHERE p.order_id = p_order_id ORDER BY p.operation_seq) LOOP
      l_x := p.setup_minutes + p.run_minutes_per_unit * (p.good_qty + p.scrap_qty);
      s5 := s5 + p.cost;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || p.operation_seq || ' - ' || esc(p.description) || '</td><td class="nn-rpt-text">'
             || esc(wc_label(p.work_center_id)) || '</td><td>' || fqty(p.planned_minutes) || '</td><td>' || fqty(l_x) || '</td><td>'
             || fqty(p.actual_minutes) || '</td><td>' || CASE WHEN p.actual_minutes > 0 THEN ROUND(l_x / p.actual_minutes * 100) || '%' END
             || '</td><td>' || fqty(p.good_qty) || '</td><td>' || fqty(p.scrap_qty) || '</td><td>' || fmt(p.cost) || '</td><td>' || badge(p.status_code)
             || '</td></tr>'));
    END LOOP;
    l_html := l_html || (('</tbody><tfoot><tr><td colspan="8">الإجمالي</td><td>' || fmt0(s5) || '</td><td></td></tr></tfoot></table>'));
    -- الانحرافات المقفلة
    SELECT COUNT(*) INTO l_x FROM mfg_variance WHERE order_id = p_order_id;
    IF l_x > 0 THEN
      l_html := l_html || ('<h3 class="nn-rpt-title">تحليل الانحرافات</h3><table class="nn-rpt"><thead><tr><th>النوع</th><th>المعياري</th>'
             || '<th>الفعلي</th><th>الانحراف</th></tr></thead><tbody>');
      FOR v IN (SELECT * FROM mfg_variance WHERE order_id = p_order_id ORDER BY id) LOOP
        l_html := l_html || (('<tr' || CASE WHEN v.variance_amount > 0 THEN ' class="nn-rpt-warn"' END || '><td class="nn-rpt-text">'
               || element_label(v.variance_type) || '</td><td>' || fmt(v.standard_amount) || '</td><td>' || fmt(v.actual_amount) || '</td><td>'
               || fmt(v.variance_amount) || '</td></tr>'));
      END LOOP;
      l_html := l_html || ('</tbody></table>');
    END IF;
    RETURN l_html || ((NOONA_GL_PKG.report_footer('الانحراف الموجب = تكلفة فعلية أعلى من المعيارية (غير مرغوب)')));
  END order_cost_sheet;

  FUNCTION order_print(p_order_id IN NUMBER) RETURN CLOB IS
    l_o    mfg_production_order%ROWTYPE := get_order(p_order_id, FALSE);
    l_html CLOB;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('أمر إنتاج / بطاقة تشغيل ' || l_o.doc_no) || order_head(l_o)
           || CASE WHEN l_o.notes IS NOT NULL THEN '<p class="nn-rpt-note">' || esc(l_o.notes) || '</p>' END
           || '<h3 class="nn-rpt-title">الخامات المطلوبة</h3><table class="nn-rpt"><thead><tr><th>#</th><th>المادة</th><th>العملية</th>'
           || '<th>الكمية المطلوبة</th><th>المصروف</th><th>توقيع أمين المستودع</th></tr></thead><tbody>';
    FOR m IN (SELECT m.*, ROWNUM rn FROM (SELECT * FROM mfg_order_material WHERE order_id = p_order_id ORDER BY operation_seq NULLS FIRST, id) m) LOOP
      l_html := l_html || (('<tr><td>' || m.rn || '</td><td class="nn-rpt-text">' || esc(item_label(m.item_id)) || '</td><td>' || m.operation_seq
             || '</td><td>' || fqty(m.required_qty) || '</td><td>' || fqty(m.issued_qty - m.returned_qty) || '</td><td></td></tr>'));
    END LOOP;
    l_html := l_html || (('</tbody></table><h3 class="nn-rpt-title">مراحل التشغيل</h3><table class="nn-rpt"><thead><tr><th>التسلسل</th>'
           || '<th>العملية</th><th>مركز العمل</th><th>الزمن المخطط (دقيقة)</th><th>فحص جودة</th><th>المقبول</th><th>الهالك</th><th>المنفذ / التوقيع</th>'
           || '</tr></thead><tbody>'));
    FOR p IN (SELECT * FROM mfg_order_operation WHERE order_id = p_order_id ORDER BY operation_seq) LOOP
      l_html := l_html || (('<tr><td>' || p.operation_seq || '</td><td class="nn-rpt-text">' || esc(p.description) || '</td><td class="nn-rpt-text">'
             || esc(wc_label(p.work_center_id)) || '</td><td>' || fqty(p.planned_minutes) || '</td><td>'
             || CASE WHEN p.quality_check = 'Y' THEN '✔' END || '</td><td>' || CASE WHEN p.good_qty > 0 THEN fqty(p.good_qty) END
             || '</td><td>' || CASE WHEN p.scrap_qty > 0 THEN fqty(p.scrap_qty) END || '</td><td></td></tr>'));
    END LOOP;
    RETURN l_html || ('</tbody></table><div class="nn-sign"><div>مدير الإنتاج</div><div>مراقب الجودة</div><div>أمين المستودع</div></div>');
  END order_print;

  FUNCTION orders_register(p_from IN DATE, p_to IN DATE, p_status IN VARCHAR2 DEFAULT NULL, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0; l_n PLS_INTEGER := 0;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('سجل أوامر الإنتاج' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>رقم الأمر</th><th>التاريخ</th><th>المنتج</th><th>المخطط</th><th>المقبول</th><th>الهالك</th>'
           || '<th>الإنجاز</th><th>التكلفة التقديرية</th><th>التكلفة الفعلية</th><th>الأولوية</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM mfg_production_order WHERE company_id = company AND doc_date BETWEEN p_from AND p_to
                 AND (p_status IS NULL OR status_code = p_status) ORDER BY doc_date, id) LOOP
      l_n := l_n + 1;
      s1 := s1 + NVL(r.estimated_cost, 0); s2 := s2 + NVL(r.actual_cost, 0); s3 := s3 + r.completed_qty;
      l_html := l_html || (('<tr' || CASE WHEN r.planned_end < TRUNC(SYSDATE) AND r.status_code NOT IN ('COMPLETED', 'CLOSED', 'CANCELLED')
                                       THEN ' class="nn-rpt-warn"' END || '><td>' || link(p_link, r.id, r.doc_no) || '</td><td>' || ds(r.doc_date)
             || '</td><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>' || fqty(r.planned_qty) || '</td><td>' || fqty(r.completed_qty)
             || '</td><td>' || fqty(r.scrapped_qty) || '</td><td>' || order_progress(r.id) || '%</td><td>' || fmt(r.estimated_cost) || '</td><td>'
             || fmt(r.actual_cost) || '</td><td>' || priority_label(r.priority) || '</td><td>' || badge(r.status_code) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="4">' || l_n || ' أمر</td><td>' || fqty(s3) || '</td><td colspan="2"></td><td>' || fmt0(s1)
        || '</td><td>' || fmt0(s2) || '</td><td colspan="2"></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('التكلفة الفعلية تظهر بعد إقفال الأمر؛ الأسطر الملونة أوامر تجاوزت تاريخ النهاية المخطط')));
  END orders_register;

  FUNCTION wip_report(p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    s NUMBER := 0; s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0; s4 NUMBER := 0;
    l_gl NUMBER;
    l_wa NUMBER := acc('1110');
    l_ld NUMBER := NOONA_GL_PKG.primary_ledger;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('الإنتاج تحت التشغيل حتى ' || ds(TRUNC(SYSDATE)))
           || '<table class="nn-rpt"><thead><tr><th>رقم الأمر</th><th>المنتج</th><th>الحالة</th><th>الإنجاز</th><th>الخامات</th><th>العمالة</th>'
           || '<th>الآلات والتحميل</th><th>المخفض بالإنتاج</th><th>الرصيد</th></tr></thead><tbody>';
    FOR r IN (SELECT o.id, o.doc_no, o.item_id, o.status_code,
                     NVL(SUM(CASE WHEN w.entry_type = 'CHARGE' AND w.cost_element = 'MATERIAL' THEN w.amount END), 0) mat,
                     NVL(SUM(CASE WHEN w.entry_type = 'CHARGE' AND w.cost_element = 'LABOR' THEN w.amount END), 0) lab,
                     NVL(SUM(CASE WHEN w.entry_type = 'CHARGE' AND w.cost_element NOT IN ('MATERIAL', 'LABOR') THEN w.amount END), 0) ovh,
                     NVL(SUM(CASE WHEN w.entry_type <> 'CHARGE' THEN w.amount END), 0) rel
                FROM mfg_production_order o JOIN mfg_wip_cost w ON w.order_id = o.id
               WHERE o.company_id = company GROUP BY o.id, o.doc_no, o.item_id, o.status_code
              HAVING ROUND(SUM(CASE WHEN w.entry_type = 'CHARGE' THEN w.amount ELSE -w.amount END), 2) <> 0
               ORDER BY o.id) LOOP
      s := s + r.mat + r.lab + r.ovh - r.rel; s1 := s1 + r.mat; s2 := s2 + r.lab; s3 := s3 + r.ovh; s4 := s4 + r.rel;
      l_html := l_html || (('<tr><td>' || link(p_link, r.id, r.doc_no) || '</td><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>'
             || badge(r.status_code) || '</td><td>' || order_progress(r.id) || '%</td><td>' || fmt(r.mat) || '</td><td>' || fmt(r.lab) || '</td><td>'
             || fmt(r.ovh) || '</td><td>' || fmt(r.rel) || '</td><td>' || fmt(r.mat + r.lab + r.ovh - r.rel) || '</td></tr>'));
    END LOOP;
    SELECT NVL(SUM(l.debit_func - l.credit_func), 0) INTO l_gl FROM gl_journal_line l JOIN gl_journal j ON j.id = l.journal_id
     WHERE l.account_id = l_wa AND j.ledger_id = l_ld AND j.status_code IN ('POSTED', 'REVERSED');
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td>' || fmt0(s1) || '</td><td>' || fmt0(s2) || '</td><td>' || fmt0(s3)
        || '</td><td>' || fmt0(s4) || '</td><td>' || fmt0(s) || '</td></tr></tfoot></table>'
        || '<div class="nn-check ' || CASE WHEN ROUND(l_gl - s, 2) = 0 THEN 'is-ok' ELSE 'is-bad' END || '">رصيد حساب الإنتاج تحت التشغيل 1110 في الأستاذ: '
        || fmt0(l_gl) || CASE WHEN ROUND(l_gl - s, 2) = 0 THEN ' — مطابق للأوامر' ELSE ' — الفرق ' || fmt0(l_gl - s) END || '</div>'
        || NOONA_GL_PKG.report_footer('الأوامر التي عليها رصيد تحت التشغيل؛ يصفر الرصيد عند إقفال الأمر')));
  END wip_report;

  FUNCTION variance_report(p_from IN DATE, p_to IN DATE, p_link IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_html CLOB;
    TYPE t_tot IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
    l_t t_tot;
    l_all NUMBER := 0;
    l_k VARCHAR2(30);
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('انحرافات تكاليف الإنتاج' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>رقم الأمر</th><th>المنتج</th><th>الكمية</th><th>التكلفة المعيارية</th><th>التكلفة الفعلية</th>'
           || '<th>سعر الخامات</th><th>كمية الخامات</th><th>كفاءة العمالة</th><th>التحميل</th><th>إجمالي الانحراف</th><th>%</th></tr></thead><tbody>';
    FOR r IN (SELECT o.id, o.doc_no, o.item_id, o.completed_qty, o.std_unit_cost, o.actual_cost,
                     NVL(SUM(CASE WHEN v.variance_type = 'MATERIAL_PRICE' THEN v.variance_amount END), 0) mp,
                     NVL(SUM(CASE WHEN v.variance_type = 'MATERIAL_USAGE' THEN v.variance_amount END), 0) mu,
                     NVL(SUM(CASE WHEN v.variance_type = 'LABOR_EFFICIENCY' THEN v.variance_amount END), 0) le,
                     NVL(SUM(CASE WHEN v.variance_type = 'OVERHEAD' THEN v.variance_amount END), 0) ov,
                     (SELECT NVL(SUM(amount), 0) FROM mfg_wip_cost w WHERE w.order_id = o.id AND w.entry_type = 'VARIANCE') tot
                FROM mfg_production_order o LEFT JOIN mfg_variance v ON v.order_id = o.id
               WHERE o.company_id = company AND o.status_code = 'CLOSED' AND CAST(o.posted_at AS DATE) BETWEEN p_from AND p_to + 1 - 1 / 86400
               GROUP BY o.id, o.doc_no, o.item_id, o.completed_qty, o.std_unit_cost, o.actual_cost ORDER BY o.id) LOOP
      l_t('mp') := CASE WHEN l_t.EXISTS('mp') THEN l_t('mp') ELSE 0 END + r.mp;
      l_t('mu') := CASE WHEN l_t.EXISTS('mu') THEN l_t('mu') ELSE 0 END + r.mu;
      l_t('le') := CASE WHEN l_t.EXISTS('le') THEN l_t('le') ELSE 0 END + r.le;
      l_t('ov') := CASE WHEN l_t.EXISTS('ov') THEN l_t('ov') ELSE 0 END + r.ov;
      l_all := l_all + r.tot;
      l_html := l_html || (('<tr' || CASE WHEN r.tot > 0 THEN ' class="nn-rpt-warn"' END || '><td>' || link(p_link, r.id, r.doc_no)
             || '</td><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>' || fqty(r.completed_qty) || '</td><td>'
             || fmt(r.std_unit_cost * r.completed_qty) || '</td><td>' || fmt(r.actual_cost) || '</td><td>' || fmt(r.mp) || '</td><td>' || fmt(r.mu)
             || '</td><td>' || fmt(r.le) || '</td><td>' || fmt(r.ov) || '</td><td>' || fmt(r.tot) || '</td><td>'
             || CASE WHEN r.std_unit_cost * r.completed_qty > 0 THEN ROUND(r.tot / (r.std_unit_cost * r.completed_qty) * 100, 1) || '%' END
             || '</td></tr>'));
    END LOOP;
    l_k := 'x';
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="5">الإجمالي</td><td>'
        || fmt0(CASE WHEN l_t.EXISTS('mp') THEN l_t('mp') END) || '</td><td>' || fmt0(CASE WHEN l_t.EXISTS('mu') THEN l_t('mu') END) || '</td><td>'
        || fmt0(CASE WHEN l_t.EXISTS('le') THEN l_t('le') END) || '</td><td>' || fmt0(CASE WHEN l_t.EXISTS('ov') THEN l_t('ov') END) || '</td><td>'
        || fmt0(l_all) || '</td><td></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الأوامر المقفلة في الفترة؛ الانحراف الموجب تكلفة فعلية أعلى من المعيارية ويرحل لحساب 5105')));
  END variance_report;

  FUNCTION material_usage(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('استهلاك الخامات في الإنتاج' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>المادة</th><th>عدد الأوامر</th><th>الكمية المصروفة</th><th>المرتجعة</th><th>الصافي</th>'
           || '<th>متوسط التكلفة</th><th>التكلفة</th></tr></thead><tbody>';
    FOR r IN (SELECT w.item_id, COUNT(DISTINCT w.order_id) n,
                     SUM(CASE WHEN w.quantity > 0 THEN w.quantity ELSE 0 END) iss, SUM(CASE WHEN w.quantity < 0 THEN -w.quantity ELSE 0 END) ret,
                     SUM(w.amount) amt
                FROM mfg_wip_cost w
               WHERE w.company_id = company AND w.entry_type = 'CHARGE' AND w.cost_element = 'MATERIAL' AND w.item_id IS NOT NULL
                 AND w.cost_date BETWEEN p_from AND p_to
               GROUP BY w.item_id ORDER BY SUM(w.amount) DESC) LOOP
      s1 := s1 + r.amt;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>' || r.n || '</td><td>' || fqty(r.iss)
             || '</td><td>' || fqty(r.ret) || '</td><td>' || fqty(r.iss - r.ret) || '</td><td>' || fmt(r.amt / NULLIF(r.iss - r.ret, 0))
             || '</td><td>' || fmt(r.amt) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="6">الإجمالي</td><td>' || fmt0(s1) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('صرف وإرجاع الخامات على أوامر الإنتاج بالتكلفة الفعلية (المتوسط المرجح)')));
  END material_usage;

  FUNCTION production_summary(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('ملخص الإنتاج حسب المنتج' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>المنتج</th><th>الأوامر</th><th>المنتج المقبول</th><th>المرفوض بالجودة</th>'
           || '<th>نسبة القبول</th><th>تكلفة الاستلام المعيارية</th><th>متوسط تكلفة الوحدة</th></tr></thead><tbody>';
    FOR r IN (SELECT o.item_id, COUNT(DISTINCT o.id) n,
                     NVL(SUM(CASE WHEN t.status_code IN ('POSTED', 'ACCEPTED') THEN t.quantity - NVL(q.failed_qty, 0) END), 0) good,
                     NVL(SUM(q.failed_qty), 0) bad, NVL(SUM(t.total_cost), 0) cost
                FROM mfg_order_output t JOIN mfg_production_order o ON o.id = t.order_id
                LEFT JOIN mfg_quality_inspection q ON q.output_id = t.id
               WHERE t.company_id = company AND t.output_date BETWEEN p_from AND p_to AND t.status_code <> 'PENDING_QUALITY'
               GROUP BY o.item_id ORDER BY 3 DESC) LOOP
      s1 := s1 + r.good; s2 := s2 + r.cost;
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>' || r.n || '</td><td>' || fqty(r.good)
             || '</td><td>' || fqty(r.bad) || '</td><td>' || CASE WHEN r.good + r.bad > 0 THEN ROUND(r.good / (r.good + r.bad) * 100, 1) || '%' END
             || '</td><td>' || fmt(r.cost) || '</td><td>' || fmt(r.cost / NULLIF(r.good + r.bad, 0)) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="2">الإجمالي</td><td>' || fqty(s1) || '</td><td colspan="2"></td><td>' || fmt0(s2)
        || '</td><td></td></tr></tfoot></table>' || NOONA_GL_PKG.report_footer('الإنتاج المستلم بعد فحص الجودة بالتكلفة المعيارية')));
  END production_summary;

  FUNCTION wc_utilization(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    l_days NUMBER := GREATEST(p_to - p_from + 1, 1);
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    -- أيام العمل: يستثنى الجمعة
    SELECT COUNT(*) INTO l_days FROM (SELECT p_from + LEVEL - 1 dd FROM dual CONNECT BY LEVEL <= l_days)
     WHERE TO_CHAR(dd, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') <> 'FRI';
    l_html := head('استغلال مراكز العمل' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>مركز العمل</th><th>الطاقة المتاحة (ساعة)</th><th>الزمن الفعلي (ساعة)</th><th>نسبة الاستغلال</th>'
           || '<th>الزمن المعياري للمنجز (ساعة)</th><th>الكفاءة</th><th>التوقف (ساعة)</th><th>التكلفة المحملة</th></tr></thead><tbody>';
    FOR r IN (SELECT c.id, c.capacity_hours_day cap,
                     NVL((SELECT SUM(w.minutes) FROM mfg_wip_cost w JOIN mfg_order_operation p ON p.order_id = w.order_id AND p.operation_seq = w.operation_seq
                           WHERE p.work_center_id = c.id AND w.cost_element = 'LABOR' AND w.entry_type = 'CHARGE'
                             AND w.cost_date BETWEEN p_from AND p_to), 0) act,
                     NVL((SELECT SUM(w.amount) FROM mfg_wip_cost w JOIN mfg_order_operation p ON p.order_id = w.order_id AND p.operation_seq = w.operation_seq
                           WHERE p.work_center_id = c.id AND w.cost_element IN ('LABOR', 'MACHINE', 'OVERHEAD') AND w.entry_type = 'CHARGE'
                             AND w.cost_date BETWEEN p_from AND p_to), 0) cost,
                     NVL((SELECT SUM(p.setup_minutes + p.run_minutes_per_unit * (p.good_qty + p.scrap_qty)) FROM mfg_order_operation p
                           WHERE p.work_center_id = c.id AND p.actual_minutes > 0
                             AND EXISTS (SELECT 1 FROM mfg_wip_cost w WHERE w.order_id = p.order_id AND w.operation_seq = p.operation_seq
                                            AND w.cost_date BETWEEN p_from AND p_to)), 0) std,
                     NVL((SELECT SUM(p.downtime_minutes) FROM mfg_order_operation p WHERE p.work_center_id = c.id
                             AND EXISTS (SELECT 1 FROM mfg_wip_cost w WHERE w.order_id = p.order_id AND w.operation_seq = p.operation_seq
                                            AND w.cost_date BETWEEN p_from AND p_to)), 0) down
                FROM mfg_work_center c WHERE c.company_id = company AND c.is_active = 'Y' ORDER BY c.code) LOOP
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(wc_label(r.id)) || '</td><td>' || fqty(r.cap * l_days) || '</td><td>'
             || fqty(ROUND(r.act / 60, 2)) || '</td><td>' || ROUND(r.act / 60 / NULLIF(r.cap * l_days, 0) * 100, 1) || '%</td><td>'
             || fqty(ROUND(r.std / 60, 2)) || '</td><td>' || CASE WHEN r.act > 0 THEN ROUND(r.std / r.act * 100) || '%' END || '</td><td>'
             || fqty(ROUND(r.down / 60, 2)) || '</td><td>' || fmt(r.cost) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody></table>' || NOONA_GL_PKG.report_footer('الطاقة = ساعات اليوم × أيام العمل (عدا الجمعة)؛ الكفاءة = الزمن المعياري للمنجز ÷ الفعلي')));
  END wc_utilization;

  FUNCTION capacity_load(p_from IN DATE DEFAULT NULL, p_days IN NUMBER DEFAULT 14) RETURN CLOB IS
    l_from DATE := NVL(p_from, TRUNC(SYSDATE));
    l_days PLS_INTEGER := LEAST(GREATEST(NVL(p_days, 14), 1), 31);
    l_html CLOB;
    l_load NUMBER;
    l_pct  NUMBER;
  BEGIN
    guard('MFG_PRODUCTION_ORDER.VIEW');
    l_html := head('أحمال مراكز العمل' || period(l_from, l_from + l_days - 1))
           || '<div class="nn-rpt-scroll"><table class="nn-rpt nn-rpt-grid"><thead><tr><th>مركز العمل</th>';
    FOR i IN 0 .. l_days - 1 LOOP
      l_html := l_html || (('<th>' || TO_CHAR(l_from + i, 'MM-DD') || '<br>' || TO_CHAR(l_from + i, 'DY', 'NLS_DATE_LANGUAGE=ARABIC') || '</th>'));
    END LOOP;
    l_html := l_html || ('</tr></thead><tbody>');
    FOR c IN (SELECT id, capacity_hours_day cap FROM mfg_work_center WHERE company_id = company AND is_active = 'Y' ORDER BY code) LOOP
      l_html := l_html || (('<tr><td class="nn-rpt-text">' || esc(wc_label(c.id)) || '</td>'));
      FOR i IN 0 .. l_days - 1 LOOP
        -- المتبقي من زمن كل عملية مفتوحة يوزع بالتساوي على أيام الأمر المخططة (المتأخر يحمل على اليوم)
        SELECT NVL(SUM(GREATEST(p.planned_minutes - p.actual_minutes, 0)
                       / (GREATEST(TRUNC(CAST(o.planned_end AS DATE)), TRUNC(SYSDATE)) - GREATEST(TRUNC(CAST(o.planned_start AS DATE)), TRUNC(SYSDATE)) + 1)), 0)
          INTO l_load
          FROM mfg_order_operation p JOIN mfg_production_order o ON o.id = p.order_id
         WHERE p.work_center_id = c.id AND p.status_code IN ('PENDING', 'IN_PROGRESS')
           AND o.status_code IN ('PLANNED', 'APPROVED', 'RELEASED', 'IN_PROGRESS', 'PARTIALLY_COMPLETED')
           AND l_from + i BETWEEN GREATEST(TRUNC(CAST(o.planned_start AS DATE)), TRUNC(SYSDATE))
                              AND GREATEST(TRUNC(CAST(o.planned_end AS DATE)), TRUNC(SYSDATE));
        l_pct := ROUND(l_load / NULLIF(c.cap * 60, 0) * 100);
        l_html := l_html || (('<td class="' || CASE WHEN l_pct > 100 THEN 'nn-rpt-bad' WHEN l_pct >= 80 THEN 'nn-load-high' WHEN l_pct > 0 THEN 'nn-load' END
               || '" title="' || fqty(ROUND(l_load / 60, 1)) || ' ساعة">' || CASE WHEN l_pct > 0 THEN l_pct || '%' END || '</td>'));
      END LOOP;
      l_html := l_html || ('</tr>');
    END LOOP;
    RETURN l_html || (('</tbody></table></div>' || NOONA_GL_PKG.report_footer('الحمل = المتبقي من زمن العمليات المفتوحة ÷ الطاقة اليومية؛ الأحمر تجاوز الطاقة')));
  END capacity_load;

  FUNCTION bom_tree(p_item_id IN NUMBER, p_qty IN NUMBER DEFAULT 1) RETURN CLOB IS
    l_html  CLOB;
    l_total NUMBER := 0;
    l_qty   NUMBER := NVL(NULLIF(p_qty, 0), 1);
    m NUMBER; a NUMBER; b NUMBER; c NUMBER;
    PROCEDURE walk(p_item NUMBER, p_q NUMBER, p_lvl PLS_INTEGER) IS
      l_bom  NUMBER := default_bom(p_item);
      l_base NUMBER;
      l_type VARCHAR2(30);
      l_q    NUMBER;
      l_uc   NUMBER;
    BEGIN
      IF l_bom IS NULL OR p_lvl > 20 THEN RETURN; END IF;
      SELECT base_quantity, bom_type INTO l_base, l_type FROM mfg_bom WHERE id = l_bom;
      FOR r IN (SELECT component_item_id ci, quantity q, scrap_pct s, is_co_product co, operation_seq op FROM mfg_bom_line WHERE bom_id = l_bom ORDER BY line_no) LOOP
        l_q := p_q * r.q / l_base * CASE WHEN r.co = 'Y' THEN 1 ELSE 1 + NVL(r.s, 0) / 100 END;
        l_uc := comp_cost(r.ci);
        IF p_lvl = 1 THEN
          l_total := l_total + CASE WHEN r.co = 'Y' THEN -1 ELSE 1 END * l_q * l_uc;
        END IF;
        l_html := l_html || (('<tr' || CASE WHEN r.co = 'Y' THEN ' class="nn-rpt-warn"' WHEN p_lvl = 1 THEN ' class="nn-rpt-sub"' END || '><td>' || p_lvl
               || '</td><td class="nn-rpt-text" style="padding-inline-start:' || (p_lvl * 18) || 'px">' || esc(item_label(r.ci))
               || CASE WHEN r.co = 'Y' THEN ' <span class="nn-badge is-warning">منتج مشترك</span>' END
               || CASE WHEN default_bom(r.ci) IS NOT NULL THEN ' <span class="nn-badge is-info">مصنع</span>' END || '</td><td>' || r.op || '</td><td>'
               || fqty(ROUND(l_q, 4)) || '</td><td>' || fqty(r.s) || '%</td><td>' || fmt(l_uc) || '</td><td>' || fmt(l_q * l_uc) || '</td><td>'
               || fqty(NOONA_INV_PKG.on_hand(r.ci)) || '</td></tr>'));
        IF r.co = 'N' THEN
          walk(r.ci, l_q, p_lvl + 1);
        END IF;
      END LOOP;
    END walk;
  BEGIN
    guard('MFG_BOM.VIEW');
    l_html := head('شجرة قائمة المواد: ' || item_label(p_item_id) || ' لكمية ' || fqty(l_qty))
           || '<table class="nn-rpt"><thead><tr><th>المستوى</th><th>المكون</th><th>العملية</th><th>الكمية</th><th>الهالك</th><th>تكلفة الوحدة</th>'
           || '<th>التكلفة</th><th>الرصيد</th></tr></thead><tbody>';
    walk(p_item_id, l_qty, 1);
    std_cost(p_item_id, l_qty, NULL, NULL, m, a, b, c);
    RETURN l_html || (('</tbody></table><table class="nn-rpt"><thead><tr><th>عناصر التكلفة المعيارية للوحدة</th><th>الخامات</th><th>العمالة</th>'
        || '<th>الآلات</th><th>التحميل</th><th>الإجمالي للوحدة</th><th>إجمالي الكمية</th></tr></thead><tbody><tr><td class="nn-rpt-text">'
        || esc(item_label(p_item_id)) || '</td><td>' || fmt0(m) || '</td><td>' || fmt0(a) || '</td><td>' || fmt0(b) || '</td><td>' || fmt0(c)
        || '</td><td><b>' || fmt0(m + a + b + c) || '</b></td><td>' || fmt0((m + a + b + c) * l_qty) || '</td></tr></tbody></table>'
        || NOONA_GL_PKG.report_footer('المستوى 1 المكونات المباشرة؛ المكون المصنع يتفرع إلى مكوناته. تكلفة المكون = المتوسط المرجح أو التكلفة المجمعة')));
  END bom_tree;

  FUNCTION where_used(p_item_id IN NUMBER) RETURN CLOB IS
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
    PROCEDURE up(p_item NUMBER, p_lvl PLS_INTEGER) IS
    BEGIN
      IF p_lvl > 20 THEN RETURN; END IF;
      FOR r IN (SELECT b.item_id, b.id, b.version_no, b.status_code, b.is_default, l.quantity, b.base_quantity
                  FROM mfg_bom_line l JOIN mfg_bom b ON b.id = l.bom_id
                 WHERE l.component_item_id = p_item AND b.company_id = company AND b.status_code <> 'OBSOLETE' ORDER BY b.item_id, b.version_no) LOOP
        l_n := l_n + 1;
        l_html := l_html || (('<tr><td>' || p_lvl || '</td><td class="nn-rpt-text" style="padding-inline-start:' || (p_lvl * 18) || 'px">'
               || esc(item_label(r.item_id)) || '</td><td>v' || r.version_no || CASE WHEN r.is_default = 'Y' THEN ' (الافتراضي)' END || '</td><td>'
               || badge(r.status_code) || '</td><td>' || fqty(r.quantity) || ' لكل ' || fqty(r.base_quantity) || '</td></tr>'));
        IF r.is_default = 'Y' THEN up(r.item_id, p_lvl + 1); END IF;
      END LOOP;
    END up;
  BEGIN
    guard('MFG_BOM.VIEW');
    l_html := head('أين يستخدم: ' || item_label(p_item_id))
           || '<table class="nn-rpt"><thead><tr><th>المستوى</th><th>المنتج</th><th>الإصدار</th><th>الحالة</th><th>الكمية</th></tr></thead><tbody>';
    up(p_item_id, 1);
    IF l_n = 0 THEN
      l_html := l_html || ('<tr><td colspan="5">لا يدخل الصنف في أي قائمة مواد</td></tr>');
    END IF;
    RETURN l_html || ('</tbody></table>');
  END where_used;

  FUNCTION mrp_report(p_include_reorder IN VARCHAR2 DEFAULT 'Y') RETURN CLOB IS
    l_j    CLOB := mrp_json(p_include_reorder);
    l_html CLOB;
    l_n    PLS_INTEGER := 0;
    l_v    NUMBER := 0;
  BEGIN
    l_html := head('تخطيط احتياجات المواد حتى ' || ds(TRUNC(SYSDATE)))
           || '<table class="nn-rpt"><thead><tr><th>المستوى</th><th>الصنف</th><th>الإجراء</th><th>الرصيد</th><th>الوارد المفتوح</th>'
           || '<th>إجمالي الطلب</th><th>حد الطلب</th><th>صافي الاحتياج</th><th>التكلفة التقديرية</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM JSON_TABLE(l_j, '$[*]' COLUMNS (i NUMBER PATH '$.i', n VARCHAR2(400) PATH '$.n', t VARCHAR2(10) PATH '$.t',
                                                            lvl NUMBER PATH '$.lvl', oh NUMBER PATH '$.oh', sup NUMBER PATH '$.sup',
                                                            gross NUMBER PATH '$.gross', mn NUMBER PATH '$.min', net NUMBER PATH '$.net',
                                                            c NUMBER PATH '$.c'))) LOOP
      l_n := l_n + 1; l_v := l_v + r.net * NVL(r.c, 0);
      l_html := l_html || (('<tr><td>' || r.lvl || '</td><td class="nn-rpt-text">' || esc(r.n) || '</td><td>'
             || CASE WHEN r.t = 'MAKE' THEN '<span class="nn-badge is-info">تصنيع</span>' ELSE '<span class="nn-badge is-warning">شراء</span>' END
             || '</td><td>' || fqty(r.oh) || '</td><td>' || fqty(r.sup) || '</td><td>' || fqty(r.gross) || '</td><td>' || fqty(r.mn) || '</td><td><b>'
             || fqty(r.net) || '</b></td><td>' || fmt(r.net * NVL(r.c, 0)) || '</td></tr>'));
    END LOOP;
    IF l_n = 0 THEN
      l_html := l_html || ('<tr><td colspan="9">لا توجد احتياجات: الأرصدة والوارد يغطيان الطلب</td></tr>');
    END IF;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="8">' || l_n || ' مقترح</td><td>' || fmt0(l_v) || '</td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('الطلب = أوامر البيع المفتوحة + احتياجات أوامر الإنتاج + الوصول لحد الطلب الأعلى؛ الوارد = أوامر الإنتاج والشراء وطلبات الشراء المفتوحة')));
  END mrp_report;

  FUNCTION quality_report(p_from IN DATE, p_to IN DATE) RETURN CLOB IS
    l_html CLOB;
    s1 NUMBER := 0; s2 NUMBER := 0; s3 NUMBER := 0;
  BEGIN
    guard('MFG_QUALITY_INSPECTION.VIEW');
    l_html := head('فحوصات الجودة' || period(p_from, p_to))
           || '<table class="nn-rpt"><thead><tr><th>التاريخ</th><th>أمر الإنتاج</th><th>المنتج</th><th>الدفعة</th><th>المفحوص</th><th>المقبول</th>'
           || '<th>المرفوض</th><th>نسبة القبول</th><th>النتيجة</th><th>ملاحظات</th></tr></thead><tbody>';
    FOR r IN (SELECT q.*, o.doc_no, o.item_id, t.lot_no FROM mfg_quality_inspection q JOIN mfg_production_order o ON o.id = q.order_id
                LEFT JOIN mfg_order_output t ON t.id = q.output_id
               WHERE q.company_id = company AND NVL(q.inspection_date, TRUNC(SYSDATE)) BETWEEN p_from AND p_to ORDER BY q.id) LOOP
      s1 := s1 + r.inspected_qty; s2 := s2 + r.passed_qty; s3 := s3 + r.failed_qty;
      l_html := l_html || (('<tr' || CASE WHEN r.failed_qty > 0 THEN ' class="nn-rpt-warn"' END || '><td>' || ds(r.inspection_date) || '</td><td>'
             || esc(r.doc_no) || '</td><td class="nn-rpt-text">' || esc(item_label(r.item_id)) || '</td><td>' || esc(r.lot_no) || '</td><td>'
             || fqty(r.inspected_qty) || '</td><td>' || fqty(r.passed_qty) || '</td><td>' || fqty(r.failed_qty) || '</td><td>'
             || CASE WHEN r.status_code <> 'PENDING' AND r.inspected_qty > 0 THEN ROUND(r.passed_qty / r.inspected_qty * 100, 1) || '%' END
             || '</td><td>' || badge(r.status_code) || '</td><td class="nn-rpt-text">' || esc(r.notes) || '</td></tr>'));
    END LOOP;
    RETURN l_html || (('</tbody><tfoot><tr><td colspan="4">الإجمالي</td><td>' || fqty(s1) || '</td><td>' || fqty(s2) || '</td><td>' || fqty(s3)
        || '</td><td>' || CASE WHEN s2 + s3 > 0 THEN ROUND(s2 / (s2 + s3) * 100, 1) || '%' END || '</td><td colspan="2"></td></tr></tfoot></table>'
        || NOONA_GL_PKG.report_footer('المرفوض يحمل على حساب العجز والتلف 5213 بالتكلفة المعيارية')));
  END quality_report;
END NOONA_MFG_PKG;
/
