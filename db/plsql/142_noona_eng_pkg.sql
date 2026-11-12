SET DEFINE OFF
-- =============================================================================
-- NOONA_ENG_PKG: مركز الإدارة والتواصل
--   بوابة العملاء برابط آمن، محرك واتساب، توقع النقد 90 يوماً، الإنذار المبكر، لوحة المدير،
--   مساعدة الشاشات، تصدير البيانات، سجل التغييرات المقروء
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_ENG_PKG AUTHID DEFINER AS
  FUNCTION company RETURN NUMBER;
  FUNCTION quick_setup RETURN NUMBER;
  FUNCTION is_ready RETURN VARCHAR2;

  -- ---------------------------------------------------------- بوابة العملاء
  FUNCTION create_link(p_account_id IN NUMBER, p_days IN NUMBER DEFAULT 365, p_phone IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  PROCEDURE revoke_link(p_link_id IN NUMBER);
  FUNCTION link_url(p_link_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION account_link_url(p_account_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION portal_html(p_token IN VARCHAR2, p_tab IN VARCHAR2 DEFAULT 'HOME') RETURN CLOB;

  -- ---------------------------------------------------------- واتساب
  PROCEDURE save_wa_setting(p_doc IN CLOB);
  FUNCTION wa_has_token RETURN VARCHAR2;
  FUNCTION intl_phone(p_phone IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION wa_link(p_phone IN VARCHAR2, p_text IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION render(p_body IN VARCHAR2, p_vars IN CLOB) RETURN VARCHAR2;
  FUNCTION send_text(p_phone IN VARCHAR2, p_text IN VARCHAR2, p_entity_type IN VARCHAR2 DEFAULT NULL, p_entity_id IN NUMBER DEFAULT NULL,
                     p_account_id IN NUMBER DEFAULT NULL, p_template_id IN NUMBER DEFAULT NULL, p_vars IN CLOB DEFAULT NULL) RETURN NUMBER;
  FUNCTION send_event(p_event IN VARCHAR2, p_account_id IN NUMBER, p_entity_type IN VARCHAR2 DEFAULT NULL, p_entity_id IN NUMBER DEFAULT NULL,
                      p_phone IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
  FUNCTION send_reminders(p_min_overdue_days IN NUMBER DEFAULT 1) RETURN NUMBER;
  FUNCTION message_link(p_message_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION customer_phone(p_account_id IN NUMBER) RETURN VARCHAR2;

  -- ---------------------------------------------------------- النقد والإنذار
  FUNCTION cash_now RETURN NUMBER;
  FUNCTION forecast_json(p_days IN NUMBER DEFAULT 90) RETURN CLOB;
  FUNCTION forecast_html(p_days IN NUMBER DEFAULT 90) RETURN CLOB;
  FUNCTION forecast_min(p_days IN NUMBER DEFAULT 90, p_date OUT DATE) RETURN NUMBER;
  FUNCTION run_alerts(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER;
  PROCEDURE ack_alert(p_id IN NUMBER);
  PROCEDURE close_alert(p_id IN NUMBER);
  FUNCTION dashboard_html RETURN CLOB;
  FUNCTION alerts_html(p_limit IN NUMBER DEFAULT 10) RETURN CLOB;
  FUNCTION metric_label(p_code IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2;

  -- ---------------------------------------------------------- المساعدة والتصدير والسجل
  FUNCTION help_html(p_app_id IN NUMBER, p_page_id IN NUMBER) RETURN CLOB;
  PROCEDURE save_help(p_doc IN CLOB);
  FUNCTION export_sql(p_table IN VARCHAR2) RETURN CLOB;
  FUNCTION export_name(p_table IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE track_table(p_table IN VARCHAR2);
  PROCEDURE untrack_table(p_table IN VARCHAR2);
  FUNCTION track_defaults RETURN NUMBER;
  FUNCTION history_html(p_table IN VARCHAR2 DEFAULT NULL, p_row_id IN NUMBER DEFAULT NULL, p_from IN DATE DEFAULT NULL,
                        p_to IN DATE DEFAULT NULL, p_user IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  FUNCTION table_label(p_table IN VARCHAR2) RETURN VARCHAR2;
END NOONA_ENG_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_ENG_PKG AS

  -- ================================================================ أدوات
  FUNCTION company RETURN NUMBER IS BEGIN RETURN NOONA_CTX_PKG.company_id; END company;
  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END esc;
  FUNCTION fmt(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990.00', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt;
  FUNCTION fmt0(p NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(TO_CHAR(NVL(p, 0), 'FM999,999,999,990', 'NLS_NUMERIC_CHARACTERS=''.,'''));
  END fmt0;
  PROCEDURE guard(p_permission VARCHAR2) IS
  BEGIN
    NOONA_SECURITY_PKG.assert_permission(p_permission, company);
  END guard;
  FUNCTION js(p_o JSON_OBJECT_T, p_k VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN p_o.has(p_k) AND NOT p_o.get(p_k).is_null THEN TRIM(p_o.get_string(p_k)) END;
  END js;
  FUNCTION enc_key RETURN RAW IS
    l RAW(64);
  BEGIN
    SELECT MAX(key_value) INTO l FROM noona_keystore WHERE key_name = 'ENG';
    IF l IS NULL THEN
      l := DBMS_CRYPTO.RANDOMBYTES(32);
      INSERT INTO noona_keystore (key_name, key_value) VALUES ('ENG', l);
    END IF;
    RETURN l;
  END enc_key;
  FUNCTION encrypt(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    RETURN RAWTOHEX(DBMS_CRYPTO.ENCRYPT(UTL_I18N.STRING_TO_RAW(p, 'AL32UTF8'),
                                        DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5, enc_key));
  END encrypt;
  FUNCTION decrypt(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF p IS NULL THEN RETURN NULL; END IF;
    RETURN UTL_I18N.RAW_TO_CHAR(DBMS_CRYPTO.DECRYPT(HEXTORAW(p), DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
                                                    enc_key), 'AL32UTF8');
  END decrypt;
  FUNCTION sha(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN LOWER(RAWTOHEX(DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p, 'AL32UTF8'), DBMS_CRYPTO.HASH_SH256)));
  END sha;
  FUNCTION company_name(p_company_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(NVL(trade_name_ar, legal_name_ar)) INTO l FROM org_company WHERE id = p_company_id;
    RETURN l;
  END company_name;
  -- رابط صفحة في تطبيق المركز: مطلق داخل جلسة APEX، أو من الإعداد PORTAL.BASE_URL (مثل https://erp.example.com/ords/) للمهام والإرسال الآلي
  FUNCTION hub_url(p_page VARCHAR2, p_items VARCHAR2, p_values VARCHAR2, p_session NUMBER DEFAULT 0) RETURN VARCHAR2 IS
    l VARCHAR2(1000);
  BEGIN
    BEGIN
      l := NOONA_SIGNUP_PKG.setting('PORTAL.BASE_URL');
    EXCEPTION WHEN OTHERS THEN l := NULL;
    END;
    IF l IS NOT NULL THEN
      RETURN RTRIM(l, '/') || '/f?p=NOONA_HUB:' || p_page || ':' || p_session || '::NO::' || p_items || ':' || p_values;
    END IF;
    IF V('APP_ID') IS NOT NULL THEN
      BEGIN
        l := APEX_UTIL.host_url('APEX_PATH');
      EXCEPTION WHEN OTHERS THEN l := NULL;
      END;
      IF l IS NOT NULL THEN
        RETURN RTRIM(l, '/') || '/f?p=NOONA_HUB:' || p_page || ':' || p_session || '::NO::' || p_items || ':' || p_values;
      END IF;
    END IF;
    RETURN '/ords/f?p=NOONA_HUB:' || p_page || ':' || p_session || '::NO::' || p_items || ':' || p_values;
  END hub_url;

  FUNCTION badge(p_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_c VARCHAR2(20);
  BEGIN
    l_c := CASE WHEN p_code IN ('ACTIVE', 'SENT', 'DELIVERED', 'READ', 'CLOSED', 'LOW') THEN 'is-success'
                WHEN p_code IN ('OPEN', 'MEDIUM', 'LINK', 'QUEUED', 'ACKNOWLEDGED') THEN 'is-warning'
                WHEN p_code IN ('FAILED', 'REVOKED', 'HIGH', 'CRITICAL') THEN 'is-danger' ELSE 'is-info' END;
    RETURN '<span class="nn-badge ' || l_c || '">' || esc(CASE p_code
      WHEN 'ACTIVE' THEN 'نشط' WHEN 'REVOKED' THEN 'ملغى' WHEN 'SENT' THEN 'أرسلت' WHEN 'DELIVERED' THEN 'وصلت' WHEN 'READ' THEN 'قرئت'
      WHEN 'FAILED' THEN 'فشلت' WHEN 'LINK' THEN 'رابط يدوي' WHEN 'QUEUED' THEN 'بالانتظار' WHEN 'OPEN' THEN 'مفتوح'
      WHEN 'ACKNOWLEDGED' THEN 'مستلم' WHEN 'CLOSED' THEN 'مغلق' WHEN 'LOW' THEN 'منخفضة' WHEN 'MEDIUM' THEN 'متوسطة'
      WHEN 'HIGH' THEN 'عالية' WHEN 'CRITICAL' THEN 'حرجة' ELSE p_code END) || '</span>';
  END badge;

  FUNCTION metric_label(p_code IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_code
      WHEN 'CASH_LOW' THEN 'انخفاض النقد عن حد'
      WHEN 'FORECAST_NEGATIVE' THEN 'عجز نقدي متوقع خلال أيام'
      WHEN 'AR_OVERDUE' THEN 'الذمم المتأخرة تتجاوز حداً'
      WHEN 'OVER_CREDIT_LIMIT' THEN 'عملاء تجاوزوا حد الائتمان'
      WHEN 'STOCK_BELOW_MIN' THEN 'أصناف تحت الحد الأدنى'
      WHEN 'SALES_DROP' THEN 'انخفاض المبيعات بنسبة'
      WHEN 'PENDING_COLLECTIONS' THEN 'تحويلات ميدانية لم تؤكد'
      WHEN 'CHEQUES_DUE' THEN 'شيكات تستحق قريباً'
      WHEN 'AP_DUE' THEN 'مستحقات موردين قريبة'
      ELSE p_code END;
  END metric_label;

  FUNCTION is_ready RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM eng_alert_rule WHERE company_id = company;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END is_ready;

  FUNCTION quick_setup RETURN NUMBER IS
    l_n NUMBER := 0;
    PROCEDURE tpl(p_code VARCHAR2, p_ev VARCHAR2, p_name VARCHAR2, p_body VARCHAR2) IS
    BEGIN
      INSERT INTO eng_wa_template (company_id, code, name_ar, name_en, event_code, body_text, is_active)
      SELECT company, p_code, p_name, p_code, p_ev, p_body, 'Y' FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM eng_wa_template WHERE company_id = company AND code = p_code);
      l_n := l_n + SQL%ROWCOUNT;
    END tpl;
    PROCEDURE rule(p_code VARCHAR2, p_metric VARCHAR2, p_name VARCHAR2, p_thr NUMBER, p_days NUMBER, p_sev VARCHAR2) IS
    BEGIN
      INSERT INTO eng_alert_rule (company_id, code, name_ar, name_en, metric, threshold, days, severity, is_active)
      SELECT company, p_code, p_name, p_code, p_metric, p_thr, p_days, p_sev, 'Y' FROM dual
       WHERE NOT EXISTS (SELECT 1 FROM eng_alert_rule WHERE company_id = company AND code = p_code);
      l_n := l_n + SQL%ROWCOUNT;
    END rule;
  BEGIN
    guard('ENG_ALERT_RULE.CREATE');
    INSERT INTO eng_wa_setting (company_id, provider, default_cc, is_enabled)
    SELECT company, 'LINK', NVL((SELECT MAX(REGEXP_REPLACE(r.phone_prefix, '[^0-9]', '')) FROM org_company c JOIN ref_country r ON r.country_code = c.country_code
                                  WHERE c.id = company), '966'), 'Y' FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM eng_wa_setting WHERE company_id = company);
    tpl('INVOICE', 'INVOICE', 'إرسال فاتورة', 'السلام عليكم {customer}، صدرت لكم الفاتورة {invoice} بتاريخ {date} بمبلغ {amount}. رصيدكم الحالي {balance}. التفاصيل: {link}. {company}');
    tpl('STATEMENT', 'STATEMENT', 'كشف حساب', 'السلام عليكم {customer}، رصيد حسابكم لدى {company} هو {balance}. كشف الحساب والفواتير: {link}');
    tpl('PAYMENT', 'PAYMENT', 'تأكيد سداد', 'شكراً {customer}، استلمنا مبلغ {amount} بتاريخ {date}. رصيدكم الآن {balance}. {company}');
    tpl('REMINDER', 'REMINDER', 'تذكير بالسداد', 'السلام عليكم {customer}، نذكركم بمبلغ مستحق {overdue} منذ {days} يوماً. الرصيد الإجمالي {balance}. التفاصيل: {link}. {company}');
    tpl('PORTAL', 'PORTAL', 'رابط البوابة', 'السلام عليكم {customer}، هذا رابط حسابكم لدى {company} لمتابعة الفواتير والرصيد والشحنات: {link}');
    tpl('ALERT', 'ALERT', 'تنبيه للمدير', 'تنبيه {company}: {title}');
    rule('CASH_LOW', 'CASH_LOW', 'النقد المتاح أقل من الحد', 10000, NULL, 'HIGH');
    rule('FORECAST_NEG', 'FORECAST_NEGATIVE', 'عجز نقدي متوقع خلال 30 يوماً', 0, 30, 'CRITICAL');
    rule('AR_OVERDUE', 'AR_OVERDUE', 'الذمم المتأخرة أكثر من 30 يوماً تتجاوز الحد', 50000, 30, 'MEDIUM');
    rule('OVER_LIMIT', 'OVER_CREDIT_LIMIT', 'عملاء تجاوزوا حد الائتمان', 0, NULL, 'MEDIUM');
    rule('STOCK_MIN', 'STOCK_BELOW_MIN', 'أصناف تحت الحد الأدنى', 0, NULL, 'MEDIUM');
    rule('SALES_DROP', 'SALES_DROP', 'انخفاض مبيعات الأسبوع 30% عن متوسط الأسابيع السابقة', 30, 7, 'HIGH');
    rule('PENDING_COLL', 'PENDING_COLLECTIONS', 'تحويلات ميدانية لم تؤكد منذ يومين', 0, 2, 'MEDIUM');
    rule('CHEQUES_DUE', 'CHEQUES_DUE', 'شيكات عملاء تستحق خلال 3 أيام', 0, 3, 'LOW');
    rule('AP_DUE', 'AP_DUE', 'مستحقات موردين خلال 7 أيام', 0, 7, 'LOW');
    RETURN l_n;
  END quick_setup;

  -- ================================================================ بوابة العملاء
  FUNCTION create_link(p_account_id IN NUMBER, p_days IN NUMBER DEFAULT 365, p_phone IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_tok VARCHAR2(64) := LOWER(RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES(24)));
    l_id  NUMBER;
    l_x   NUMBER;
    l_hs  VARCHAR2(64) := sha(l_tok);
    l_en  VARCHAR2(500) := encrypt(l_tok);
    l_ph  VARCHAR2(60) := NVL(p_phone, customer_phone(p_account_id));
  BEGIN
    guard('ENG_PORTAL_LINK.CREATE');
    SELECT COUNT(*) INTO l_x FROM ar_customer_account WHERE id = p_account_id AND company_id = company;
    NOONA_CORE_PKG.assert(l_x = 1, 'NOONA-ENG-001', 'العميل غير موجود', 'Customer not found');
    UPDATE eng_portal_link SET status_code = 'REVOKED' WHERE customer_account_id = p_account_id AND company_id = company AND status_code = 'ACTIVE';
    INSERT INTO eng_portal_link (company_id, customer_account_id, token_hash, token_enc, token_hint, expires_at, phone, status_code)
    VALUES (company, p_account_id, l_hs, l_en, SUBSTR(l_tok, -6),
            CASE WHEN NVL(p_days, 0) > 0 THEN SYSTIMESTAMP + NUMTODSINTERVAL(p_days, 'DAY') END, l_ph, 'ACTIVE')
    RETURNING id INTO l_id;
    RETURN l_id;
  END create_link;

  PROCEDURE revoke_link(p_link_id IN NUMBER) IS
  BEGIN
    guard('ENG_PORTAL_LINK.UPDATE');
    UPDATE eng_portal_link SET status_code = 'REVOKED' WHERE id = p_link_id AND company_id = company;
  END revoke_link;

  FUNCTION link_url(p_link_id IN NUMBER) RETURN VARCHAR2 IS
    l_enc VARCHAR2(500);
  BEGIN
    SELECT MAX(token_enc) INTO l_enc FROM eng_portal_link WHERE id = p_link_id AND company_id = company AND status_code = 'ACTIVE';
    IF l_enc IS NULL THEN RETURN NULL; END IF;
    RETURN hub_url('PORTAL', 'P100_T', decrypt(l_enc));
  END link_url;

  FUNCTION account_link_url(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l_id NUMBER;
  BEGIN
    SELECT MAX(id) INTO l_id FROM eng_portal_link
     WHERE customer_account_id = p_account_id AND company_id = company AND status_code = 'ACTIVE'
       AND (expires_at IS NULL OR expires_at > SYSTIMESTAMP);
    IF l_id IS NULL THEN l_id := create_link(p_account_id); END IF;
    RETURN link_url(l_id);
  END account_link_url;

  FUNCTION portal_html(p_token IN VARCHAR2, p_tab IN VARCHAR2 DEFAULT 'HOME') RETURN CLOB IS
    l_l   eng_portal_link%ROWTYPE;
    l_h   CLOB;
    l_bal NUMBER; l_lim NUMBER; l_ovd NUMBER := 0; l_n PLS_INTEGER := 0;
    l_nm  VARCHAR2(400);
    l_tab VARCHAR2(20) := UPPER(NVL(p_tab, 'HOME'));
    l_hs  VARCHAR2(64);
    l_pco NUMBER := NOONA_CTX_PKG.company_id;
    l_pbr NUMBER := NOONA_CTX_PKG.branch_id;
    FUNCTION tab(p_code VARCHAR2, p_label VARCHAR2, p_icon VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<a class="nn-pt-tab' || CASE WHEN l_tab = p_code THEN ' is-on' END || '" href="'
          || esc(hub_url('PORTAL', 'P100_T,P100_TAB', p_token || ',' || p_code, NVL(TO_NUMBER(V('APP_SESSION')), 0)))
          || '"><span class="fa ' || p_icon || '"></span> ' || p_label || '</a>';
    END tab;
  BEGIN
    IF p_token IS NULL OR LENGTH(p_token) < 20 THEN
      RETURN '<div class="nn-pt-empty"><h2>الرابط غير صحيح</h2><p>اطلب رابطاً جديداً من الشركة.</p></div>';
    END IF;
    l_hs := sha(p_token);
    NOONA_CORE_PKG.begin_system;
    BEGIN
      SELECT * INTO l_l FROM eng_portal_link WHERE token_hash = l_hs;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.end_system;
      RETURN '<div class="nn-pt-empty"><h2>الرابط غير صحيح</h2><p>اطلب رابطاً جديداً من الشركة.</p></div>';
    END;
    IF l_l.status_code <> 'ACTIVE' OR l_l.expires_at < SYSTIMESTAMP THEN
      NOONA_CORE_PKG.end_system;
      RETURN '<div class="nn-pt-empty"><h2>انتهت صلاحية الرابط</h2><p>اطلب رابطاً جديداً من الشركة.</p></div>';
    END IF;
    UPDATE eng_portal_link SET last_access_at = SYSTIMESTAMP, access_count = access_count + 1 WHERE id = l_l.id;
    NOONA_CTX_PKG.set_company(l_l.company_id);
    l_nm := NOONA_SAL_PKG.customer_label(l_l.customer_account_id);
    l_bal := NOONA_SAL_PKG.customer_balance(l_l.customer_account_id);
    l_lim := NOONA_SAL_PKG.credit_limit(l_l.customer_account_id);
    SELECT NVL(SUM(open_amount), 0) INTO l_ovd FROM ar_open_item
     WHERE customer_account_id = l_l.customer_account_id AND company_id = l_l.company_id AND status_code IN ('OPEN', 'PARTIALLY_PAID')
       AND due_date < TRUNC(SYSDATE);
    l_h := '<div class="nn-pt"><div class="nn-pt-head"><div><small>' || esc(company_name(l_l.company_id)) || '</small><h1>' || esc(l_nm)
        || '</h1></div><div class="nn-pt-bal"><small>الرصيد المستحق</small><b>' || fmt(l_bal) || '</b></div></div>'
        || '<div class="nn-kpis"><div class="nn-kpi"><span>متأخر السداد</span><b>' || fmt(l_ovd) || '</b></div>'
        || '<div class="nn-kpi"><span>حد الائتمان</span><b>' || CASE WHEN l_lim IS NULL THEN '—' ELSE fmt(l_lim) END || '</b></div>'
        || '<div class="nn-kpi"><span>المتاح</span><b>' || CASE WHEN l_lim IS NULL THEN '—' ELSE fmt(GREATEST(l_lim - l_bal, 0)) END || '</b></div></div>'
        || '<nav class="nn-pt-tabs">' || tab('HOME', 'الفواتير', 'fa-file-text-o') || tab('STATEMENT', 'كشف الحساب', 'fa-list')
        || tab('SHIP', 'الشحنات والطلبيات', 'fa-truck') || '</nav>';
    IF l_tab = 'STATEMENT' THEN
      -- كشف حساب آخر 6 أشهر: رصيد افتتاحي ثم الفواتير والإشعارات والمقبوضات بالرصيد الجاري
      DECLARE
        l_from DATE := ADD_MONTHS(TRUNC(SYSDATE), -6);
        l_run  NUMBER := NOONA_SAL_PKG.customer_balance(l_l.customer_account_id, l_from - 1);
        l_rows CLOB;
      BEGIN
        FOR m IN (SELECT doc_date d, doc_no n, CASE item_type WHEN 'CREDIT_NOTE' THEN 'إشعار دائن' WHEN 'INVOICE' THEN 'فاتورة' ELSE 'مستند' END t,
                         CASE WHEN item_type = 'CREDIT_NOTE' THEN 0 ELSE original_amount END dr,
                         CASE WHEN item_type = 'CREDIT_NOTE' THEN original_amount ELSE 0 END cr, id k
                    FROM ar_open_item WHERE customer_account_id = l_l.customer_account_id AND company_id = l_l.company_id
                     AND status_code <> 'CANCELLED' AND doc_date >= l_from
                  UNION ALL
                  SELECT doc_date, doc_no, 'سند قبض', 0, amount, id FROM ar_receipt
                   WHERE customer_account_id = l_l.customer_account_id AND company_id = l_l.company_id AND status_code = 'CONFIRMED' AND doc_date >= l_from
                  ORDER BY 1, 6) LOOP
          l_run := l_run + m.dr - m.cr;
          l_rows := l_rows || '<tr><td>' || TO_CHAR(m.d, 'YYYY-MM-DD') || '</td><td>' || esc(m.t) || ' ' || esc(m.n) || '</td><td>'
              || CASE WHEN m.dr <> 0 THEN fmt(m.dr) END || '</td><td>' || CASE WHEN m.cr <> 0 THEN fmt(m.cr) END || '</td><td><b>' || fmt(l_run) || '</b></td></tr>';
        END LOOP;
        l_h := l_h || '<div class="nn-pt-body"><table class="nn-table"><thead><tr><th>التاريخ</th><th>البيان</th><th>مدين</th><th>دائن</th><th>الرصيد</th></tr></thead><tbody>'
            || '<tr><td>' || TO_CHAR(l_from, 'YYYY-MM-DD') || '</td><td>رصيد افتتاحي</td><td></td><td></td><td><b>'
            || fmt(NOONA_SAL_PKG.customer_balance(l_l.customer_account_id, l_from - 1)) || '</b></td></tr>' || l_rows || '</tbody></table></div>';
      END;
    ELSIF l_tab = 'SHIP' THEN
      l_h := l_h || '<div class="nn-pt-body"><h3>الشحنات</h3>';
      l_n := 0;
      FOR o IN (SELECT o.id, o.doc_no, o.doc_date, o.status_code, o.pickup_date, o.required_delivery_date, o.quantity, o.delivered_qty,
                       f.name_ar fr, t.name_ar tl,
                       (SELECT MAX(tr.eta) KEEP (DENSE_RANK LAST ORDER BY tr.id) FROM trn_trip_order x JOIN trn_trip tr ON tr.id = x.trip_id
                         WHERE x.order_id = o.id) eta,
                       (SELECT MAX(tr.status_code) KEEP (DENSE_RANK LAST ORDER BY tr.id) FROM trn_trip_order x JOIN trn_trip tr ON tr.id = x.trip_id
                         WHERE x.order_id = o.id) tst,
                       (SELECT COUNT(*) FROM trn_pod p WHERE p.order_id = o.id) pods
                  FROM trn_order o JOIN trn_location f ON f.id = o.from_location_id JOIN trn_location t ON t.id = o.to_location_id
                 WHERE o.customer_account_id = l_l.customer_account_id AND o.company_id = l_l.company_id AND o.status_code <> 'DRAFT'
                 ORDER BY o.id DESC FETCH FIRST 30 ROWS ONLY) LOOP
        l_n := l_n + 1;
        l_h := l_h || '<div class="nn-pt-card"><div class="nn-pt-card-h"><b>' || esc(o.doc_no) || '</b> ' || NOONA_TRN_PKG.badge(o.status_code) || '</div>'
            || '<div>' || esc(o.fr) || ' ← ' || esc(o.tl) || '</div><small>التحميل ' || TO_CHAR(o.pickup_date, 'YYYY-MM-DD')
            || ' · التسليم المطلوب ' || TO_CHAR(o.required_delivery_date, 'YYYY-MM-DD')
            || CASE WHEN o.eta IS NOT NULL AND o.tst IN ('PLANNED', 'IN_TRANSIT', 'DEPARTED') THEN ' · الوصول المتوقع ' || TO_CHAR(o.eta, 'YYYY-MM-DD HH24:MI') END
            || CASE WHEN o.delivered_qty > 0 THEN ' · سلم ' || o.delivered_qty || ' من ' || o.quantity END
            || CASE WHEN o.pods > 0 THEN ' · <span class="fa fa-check-circle"></span> إثبات تسليم موقع' END || '</small></div>';
      END LOOP;
      IF l_n = 0 THEN l_h := l_h || '<p class="nn-hint">لا شحنات.</p>'; END IF;
      l_h := l_h || '<h3>طلبيات التوريد</h3>';
      l_n := 0;
      FOR o IN (SELECT doc_no, doc_date, delivery_date, total_amount, status_code FROM dst_order
                 WHERE company_id = l_l.company_id AND shop_id IN (SELECT id FROM dst_shop WHERE customer_account_id = l_l.customer_account_id)
                 ORDER BY id DESC FETCH FIRST 20 ROWS ONLY) LOOP
        l_n := l_n + 1;
        l_h := l_h || '<div class="nn-pt-card"><div class="nn-pt-card-h"><b>' || esc(o.doc_no) || '</b> ' || NOONA_DST_PKG.badge(o.status_code)
            || '</div><small>بتاريخ ' || TO_CHAR(o.doc_date, 'YYYY-MM-DD') || ' · التسليم ' || TO_CHAR(o.delivery_date, 'YYYY-MM-DD')
            || ' · ' || fmt(o.total_amount) || '</small></div>';
      END LOOP;
      IF l_n = 0 THEN l_h := l_h || '<p class="nn-hint">لا طلبيات.</p>'; END IF;
      l_h := l_h || '</div>';
    ELSE
      l_h := l_h || '<div class="nn-pt-body">';
      FOR i IN (SELECT i.id, i.doc_no, i.doc_date, i.due_date, i.total_amount, i.doc_type,
                       (SELECT NVL(SUM(o.open_amount), 0) FROM ar_open_item o
                         WHERE o.source_entity_type = 'SAL_INVOICE' AND o.source_entity_id = i.id AND o.status_code IN ('OPEN', 'PARTIALLY_PAID')) open_amt
                  FROM sal_invoice i
                 WHERE i.customer_account_id = l_l.customer_account_id AND i.company_id = l_l.company_id
                   AND i.status_code NOT IN ('DRAFT', 'CANCELLED') AND i.doc_type <> 'PROFORMA'
                 ORDER BY i.doc_date DESC, i.id DESC FETCH FIRST 40 ROWS ONLY) LOOP
        l_n := l_n + 1;
        l_h := l_h || '<details class="nn-pt-card"><summary><div class="nn-pt-card-h"><b>' || esc(i.doc_no) || '</b>'
            || CASE WHEN i.doc_type = 'CREDIT_NOTE' THEN ' <span class="nn-badge is-info">إشعار دائن</span>'
                    WHEN i.open_amt = 0 THEN ' <span class="nn-badge is-success">مسددة</span>'
                    WHEN i.due_date < TRUNC(SYSDATE) THEN ' <span class="nn-badge is-danger">متأخرة</span>'
                    ELSE ' <span class="nn-badge is-warning">مستحقة</span>' END
            || '<b class="nn-pt-amt">' || fmt(i.total_amount) || '</b></div><small>' || TO_CHAR(i.doc_date, 'YYYY-MM-DD')
            || CASE WHEN i.due_date IS NOT NULL THEN ' · الاستحقاق ' || TO_CHAR(i.due_date, 'YYYY-MM-DD') END
            || CASE WHEN i.open_amt > 0 THEN ' · المتبقي <b>' || fmt(i.open_amt) || '</b>' END || '</small></summary><table class="nn-table"><tbody>';
        FOR ln IN (SELECT description, quantity, net_amount + tax_amount amt FROM sal_invoice_line WHERE invoice_id = i.id ORDER BY line_no) LOOP
          l_h := l_h || '<tr><td>' || esc(ln.description) || '</td><td>' || ln.quantity || '</td><td>' || fmt(ln.amt) || '</td></tr>';
        END LOOP;
        l_h := l_h || '</tbody></table></details>';
      END LOOP;
      IF l_n = 0 THEN l_h := l_h || '<p class="nn-hint">لا فواتير.</p>'; END IF;
      l_h := l_h || '</div>';
    END IF;
    l_h := l_h || '<p class="nn-pt-foot">رابط خاص بحسابكم؛ لا تشاركه. تحديث ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') || '</p></div>';
    NOONA_CTX_PKG.set_company(l_pco, l_pbr);
    NOONA_CORE_PKG.end_system;
    RETURN l_h;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CTX_PKG.set_company(l_pco, l_pbr);
    NOONA_CORE_PKG.end_system;
    RETURN '<div class="nn-pt-empty"><h2>تعذر عرض الحساب الآن</h2><p>حاول لاحقاً.</p></div>';
  END portal_html;

  -- ================================================================ واتساب
  FUNCTION setting_row RETURN eng_wa_setting%ROWTYPE IS
    l eng_wa_setting%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM eng_wa_setting WHERE company_id = company;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l.provider := 'LINK'; l.default_cc := '966'; l.is_enabled := 'Y'; l.api_version := 'v21.0';
    RETURN l;
  END setting_row;

  PROCEDURE save_wa_setting(p_doc IN CLOB) IS
    l_o   JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_pr  VARCHAR2(20) := NVL(js(l_o, 'provider'), 'LINK');
    l_tok VARCHAR2(2000) := js(l_o, 'token');
    l_x   NUMBER;
    l_te  VARCHAR2(2000) := encrypt(l_tok);
    l_ph  VARCHAR2(50) := js(l_o, 'phoneId');
    l_bi  VARCHAR2(50) := js(l_o, 'businessId');
    l_ve  VARCHAR2(10) := NVL(js(l_o, 'version'), 'v21.0');
    l_cc  VARCHAR2(5) := NVL(REGEXP_REPLACE(js(l_o, 'cc'), '[^0-9]', ''), '966');
    l_se  VARCHAR2(30) := js(l_o, 'sender');
    l_en  VARCHAR2(1) := NVL(js(l_o, 'enabled'), 'Y');
    l_cl  VARCHAR2(1) := js(l_o, 'clearToken');
  BEGIN
    guard('ENG_WA_SETTING.UPDATE');
    NOONA_CORE_PKG.assert(l_pr IN ('LINK', 'CLOUD_API'), 'NOONA-ENG-010', 'طريقة الإرسال غير صحيحة', 'Invalid provider');
    SELECT COUNT(*) INTO l_x FROM eng_wa_setting WHERE company_id = company;
    IF l_x = 0 THEN
      INSERT INTO eng_wa_setting (company_id, provider, default_cc, is_enabled) VALUES (company, 'LINK', '966', 'Y');
    END IF;
    UPDATE eng_wa_setting
       SET provider = l_pr, phone_number_id = l_ph, business_account_id = l_bi, api_version = l_ve, default_cc = l_cc,
           sender_phone = l_se, is_enabled = l_en,
           token_enc = CASE WHEN l_cl = 'Y' THEN NULL WHEN l_te IS NOT NULL THEN l_te ELSE token_enc END
     WHERE company_id = company;
    SELECT provider, phone_number_id, token_enc INTO l_pr, l_tok, l_x FROM (SELECT provider, phone_number_id, NVL2(token_enc, 1, 0) token_enc
      FROM eng_wa_setting WHERE company_id = company);
    NOONA_CORE_PKG.assert(l_pr = 'LINK' OR (l_tok IS NOT NULL AND l_x = 1), 'NOONA-ENG-011',
      'لـ Cloud API أدخل معرف رقم الإرسال ورمز الوصول', 'Phone number id and access token required');
  END save_wa_setting;

  FUNCTION wa_has_token RETURN VARCHAR2 IS
    l NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l FROM eng_wa_setting WHERE company_id = company AND token_enc IS NOT NULL;
    RETURN CASE WHEN l > 0 THEN 'Y' ELSE 'N' END;
  END wa_has_token;

  FUNCTION intl_phone(p_phone IN VARCHAR2) RETURN VARCHAR2 IS
    l  VARCHAR2(40) := REGEXP_REPLACE(TRANSLATE(p_phone, '٠١٢٣٤٥٦٧٨٩', '0123456789'), '[^0-9+]', '');
    cc VARCHAR2(5) := NVL(setting_row().default_cc, '966');
  BEGIN
    IF l IS NULL THEN RETURN NULL; END IF;
    IF NOT REGEXP_LIKE(cc, '^[0-9]+$') THEN
      SELECT NVL(MAX(REGEXP_REPLACE(phone_prefix, '[^0-9]', '')), '966') INTO cc FROM ref_country WHERE country_code = UPPER(cc);
    END IF;
    IF l LIKE '+%' THEN RETURN SUBSTR(l, 2); END IF;
    IF l LIKE '00%' THEN RETURN SUBSTR(l, 3); END IF;
    IF l LIKE cc || '%' AND LENGTH(l) > 10 THEN RETURN l; END IF;
    RETURN cc || LTRIM(l, '0');
  END intl_phone;

  FUNCTION wa_link(p_phone IN VARCHAR2, p_text IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'https://wa.me/' || intl_phone(p_phone) || '?text=' || UTL_URL.escape(p_text, TRUE, 'AL32UTF8');
  END wa_link;

  FUNCTION render(p_body IN VARCHAR2, p_vars IN CLOB) RETURN VARCHAR2 IS
    l VARCHAR2(4000) := p_body;
    o JSON_OBJECT_T;
    k JSON_KEY_LIST;
  BEGIN
    IF p_vars IS NULL THEN RETURN l; END IF;
    o := JSON_OBJECT_T.parse(p_vars);
    k := o.get_keys;
    FOR i IN 1 .. k.COUNT LOOP
      l := REPLACE(l, '{' || k(i) || '}', o.get_string(k(i)));
    END LOOP;
    RETURN REGEXP_REPLACE(l, '\{[a-z]+\}', '');
  END render;

  FUNCTION customer_phone(p_account_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(60);
  BEGIN
    SELECT MAX(NVL(whatsapp, phone)) INTO l FROM dst_shop WHERE customer_account_id = p_account_id;
    IF l IS NULL THEN
      BEGIN
        SELECT MAX(NVL(p.mobile, p.phone)) INTO l FROM ar_customer_account a JOIN ar_customer c ON c.id = a.customer_id
          JOIN ref_contact p ON p.party_id = c.party_id WHERE a.id = p_account_id AND NVL(p.mobile, p.phone) IS NOT NULL;
      EXCEPTION WHEN OTHERS THEN l := NULL;
      END;
    END IF;
    RETURN l;
  END customer_phone;

  FUNCTION cloud_send(p_s eng_wa_setting%ROWTYPE, p_to VARCHAR2, p_text VARCHAR2, p_tpl eng_wa_template%ROWTYPE, p_vars CLOB,
                      p_err OUT VARCHAR2) RETURN VARCHAR2 IS
    l_b   JSON_OBJECT_T := JSON_OBJECT_T();
    l_t   JSON_OBJECT_T;
    l_c   JSON_ARRAY_T;
    l_p   JSON_ARRAY_T;
    l_x   JSON_OBJECT_T;
    l_o   JSON_OBJECT_T;
    l_r   CLOB;
    l_k   VARCHAR2(50);
    l_i   PLS_INTEGER := 1;
  BEGIN
    l_b.put('messaging_product', 'whatsapp');
    l_b.put('to', p_to);
    IF p_tpl.cloud_template IS NOT NULL THEN
      -- قالب معتمد من Meta: المتغيرات بترتيب ظهورها في نص القالب
      l_b.put('type', 'template');
      l_t := JSON_OBJECT_T();
      l_t.put('name', p_tpl.cloud_template);
      l_x := JSON_OBJECT_T(); l_x.put('code', NVL(p_tpl.language_code, 'ar')); l_t.put('language', l_x);
      IF p_vars IS NOT NULL THEN
        l_o := JSON_OBJECT_T.parse(p_vars);
        l_p := JSON_ARRAY_T();
        LOOP
          l_k := REGEXP_SUBSTR(p_tpl.body_text, '\{([a-z]+)\}', 1, l_i, NULL, 1);
          EXIT WHEN l_k IS NULL;
          l_x := JSON_OBJECT_T(); l_x.put('type', 'text'); l_x.put('text', NVL(l_o.get_string(l_k), '-'));
          l_p.append(l_x);
          l_i := l_i + 1;
        END LOOP;
        IF l_p.get_size > 0 THEN
          l_c := JSON_ARRAY_T(); l_x := JSON_OBJECT_T(); l_x.put('type', 'body'); l_x.put('parameters', l_p); l_c.append(l_x);
          l_t.put('components', l_c);
        END IF;
      END IF;
      l_b.put('template', l_t);
    ELSE
      l_b.put('type', 'text');
      l_x := JSON_OBJECT_T(); l_x.put('body', p_text); l_x.put('preview_url', TRUE);
      l_b.put('text', l_x);
    END IF;
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    APEX_WEB_SERVICE.g_request_headers(1).name := 'Content-Type';
    APEX_WEB_SERVICE.g_request_headers(1).value := 'application/json';
    APEX_WEB_SERVICE.g_request_headers(2).name := 'Authorization';
    APEX_WEB_SERVICE.g_request_headers(2).value := 'Bearer ' || decrypt(p_s.token_enc);
    l_r := APEX_WEB_SERVICE.make_rest_request(
             p_url => 'https://graph.facebook.com/' || NVL(p_s.api_version, 'v21.0') || '/' || p_s.phone_number_id || '/messages',
             p_http_method => 'POST', p_body => l_b.to_clob, p_transfer_timeout => 20, p_wallet_path => 'system:');
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    IF APEX_WEB_SERVICE.g_status_code BETWEEN 200 AND 299 THEN
      RETURN JSON_VALUE(l_r, '$.messages[0].id');
    END IF;
    p_err := SUBSTR('HTTP ' || APEX_WEB_SERVICE.g_status_code || ': ' || NVL(JSON_VALUE(l_r, '$.error.message'), DBMS_LOB.SUBSTR(l_r, 400, 1)), 1, 1000);
    RETURN NULL;
  EXCEPTION WHEN OTHERS THEN
    APEX_WEB_SERVICE.g_request_headers.DELETE;
    p_err := SUBSTR(SQLERRM, 1, 1000);
    RETURN NULL;
  END cloud_send;

  FUNCTION send_text(p_phone IN VARCHAR2, p_text IN VARCHAR2, p_entity_type IN VARCHAR2 DEFAULT NULL, p_entity_id IN NUMBER DEFAULT NULL,
                     p_account_id IN NUMBER DEFAULT NULL, p_template_id IN NUMBER DEFAULT NULL, p_vars IN CLOB DEFAULT NULL) RETURN NUMBER IS
    l_s   eng_wa_setting%ROWTYPE := setting_row;
    l_t   eng_wa_template%ROWTYPE;
    l_to  VARCHAR2(40) := intl_phone(p_phone);
    l_id  NUMBER;
    l_mid VARCHAR2(200);
    l_err VARCHAR2(1000);
    l_st  VARCHAR2(20);
  BEGIN
    NOONA_CORE_PKG.assert(l_to IS NOT NULL AND LENGTH(l_to) >= 9, 'NOONA-ENG-012', 'رقم الجوال غير صحيح', 'Invalid phone');
    NOONA_CORE_PKG.assert(p_text IS NOT NULL, 'NOONA-ENG-013', 'نص الرسالة فارغ', 'Empty message');
    IF p_template_id IS NOT NULL THEN
      SELECT * INTO l_t FROM eng_wa_template WHERE id = p_template_id;
    END IF;
    IF l_s.provider = 'CLOUD_API' AND l_s.is_enabled = 'Y' AND l_s.token_enc IS NOT NULL AND l_s.phone_number_id IS NOT NULL THEN
      l_mid := cloud_send(l_s, l_to, p_text, l_t, p_vars, l_err);
      l_st := CASE WHEN l_mid IS NOT NULL THEN 'SENT' ELSE 'FAILED' END;
    ELSE
      l_st := 'LINK';
    END IF;
    INSERT INTO eng_message (company_id, channel, to_phone, template_id, body_text, entity_type, entity_id, customer_account_id,
                             provider_msg_id, error_text, sent_at, link_url, status_code)
    VALUES (company, 'WHATSAPP', l_to, p_template_id, SUBSTR(p_text, 1, 4000), p_entity_type, p_entity_id, p_account_id,
            l_mid, l_err, CASE WHEN l_st = 'SENT' THEN SYSTIMESTAMP END,
            CASE WHEN l_st <> 'SENT' THEN SUBSTR(wa_link(l_to, p_text), 1, 4000) END, l_st)
    RETURNING id INTO l_id;
    RETURN l_id;
  END send_text;

  FUNCTION vars_for(p_account_id NUMBER, p_entity_type VARCHAR2, p_entity_id NUMBER) RETURN CLOB IS
    l JSON_OBJECT_T := JSON_OBJECT_T();
    l_ovd NUMBER; l_days NUMBER;
  BEGIN
    l.put('customer', NOONA_SAL_PKG.customer_label(p_account_id));
    l.put('balance', fmt(NOONA_SAL_PKG.customer_balance(p_account_id)));
    l.put('company', company_name(company));
    l.put('date', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    SELECT NVL(SUM(open_amount), 0), NVL(MAX(TRUNC(SYSDATE) - due_date), 0) INTO l_ovd, l_days FROM ar_open_item
     WHERE customer_account_id = p_account_id AND company_id = company AND status_code IN ('OPEN', 'PARTIALLY_PAID') AND due_date < TRUNC(SYSDATE);
    l.put('overdue', fmt(l_ovd)); l.put('days', TO_CHAR(l_days));
    BEGIN l.put('link', account_link_url(p_account_id)); EXCEPTION WHEN OTHERS THEN l.put('link', ''); END;
    IF p_entity_type = 'SAL_INVOICE' THEN
      FOR i IN (SELECT doc_no, doc_date, total_amount FROM sal_invoice WHERE id = p_entity_id AND company_id = company) LOOP
        l.put('invoice', i.doc_no); l.put('amount', fmt(i.total_amount)); l.put('date', TO_CHAR(i.doc_date, 'YYYY-MM-DD'));
      END LOOP;
    ELSIF p_entity_type = 'AR_RECEIPT' THEN
      FOR r IN (SELECT doc_no, doc_date, amount FROM ar_receipt WHERE id = p_entity_id AND company_id = company) LOOP
        l.put('invoice', r.doc_no); l.put('amount', fmt(r.amount)); l.put('date', TO_CHAR(r.doc_date, 'YYYY-MM-DD'));
      END LOOP;
    END IF;
    RETURN l.to_clob;
  END vars_for;

  FUNCTION send_event(p_event IN VARCHAR2, p_account_id IN NUMBER, p_entity_type IN VARCHAR2 DEFAULT NULL, p_entity_id IN NUMBER DEFAULT NULL,
                      p_phone IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
    l_t  eng_wa_template%ROWTYPE;
    l_v  CLOB;
    l_ph VARCHAR2(60) := NVL(p_phone, customer_phone(p_account_id));
  BEGIN
    guard('ENG_MESSAGE.CREATE');
    NOONA_CORE_PKG.assert(l_ph IS NOT NULL, 'NOONA-ENG-014', 'لا يوجد رقم جوال أو واتساب للعميل', 'Customer has no phone');
    BEGIN
      SELECT * INTO l_t FROM (SELECT * FROM eng_wa_template WHERE company_id = company AND event_code = p_event AND is_active = 'Y'
                               ORDER BY id) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NOONA_CORE_PKG.raise_error('NOONA-ENG-015', 'لا يوجد قالب نشط لهذه المناسبة: شغّل «تجهيز المركز» أو أضف قالباً', 'No active template');
    END;
    l_v := vars_for(p_account_id, p_entity_type, p_entity_id);
    RETURN send_text(l_ph, render(l_t.body_text, l_v), p_entity_type, p_entity_id, p_account_id, l_t.id, l_v);
  END send_event;

  FUNCTION send_reminders(p_min_overdue_days IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_n NUMBER := 0;
    l_m NUMBER;
  BEGIN
    guard('ENG_MESSAGE.CREATE');
    FOR c IN (SELECT customer_account_id FROM ar_open_item
               WHERE company_id = company AND status_code IN ('OPEN', 'PARTIALLY_PAID') AND due_date <= TRUNC(SYSDATE) - NVL(p_min_overdue_days, 1)
               GROUP BY customer_account_id HAVING SUM(open_amount) > 0) LOOP
      IF customer_phone(c.customer_account_id) IS NOT NULL THEN
        BEGIN
          l_m := send_event('REMINDER', c.customer_account_id, 'AR_CUSTOMER_ACCOUNT', c.customer_account_id);
          l_n := l_n + 1;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END IF;
    END LOOP;
    RETURN l_n;
  END send_reminders;

  FUNCTION message_link(p_message_id IN NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(link_url) INTO l FROM eng_message WHERE id = p_message_id AND company_id = company;
    RETURN l;
  END message_link;

  -- ================================================================ النقد والتوقع
  FUNCTION cash_now RETURN NUMBER IS
    l NUMBER := 0;
  BEGIN
    FOR b IN (SELECT id FROM csh_cash_box WHERE company_id = company AND status_code = 'ACTIVE') LOOP
      l := l + NVL(NOONA_CSH_PKG.balance(b.id, NULL), 0);
    END LOOP;
    FOR b IN (SELECT id FROM csh_bank_account WHERE company_id = company AND status_code = 'ACTIVE') LOOP
      l := l + NVL(NOONA_CSH_PKG.balance(NULL, b.id), 0);
    END LOOP;
    RETURN l;
  END cash_now;

  -- أسابيع التوقع: الوارد (الذمم المدينة بالاستحقاق، المتأخر 60% موزع على 4 أسابيع، الشيكات الميدانية)،
  -- الصادر (الذمم الدائنة بالاستحقاق، المتأخر في الأسبوع الأول، متوسط صافي الرواتب في 27 من كل شهر)
  FUNCTION forecast_json(p_days IN NUMBER DEFAULT 90) RETURN CLOB IS
    TYPE t_n IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    l_in  t_n; l_out t_n; l_pay t_n;
    l_w   PLS_INTEGER := CEIL(NVL(p_days, 90) / 7);
    l_d0  DATE := TRUNC(SYSDATE);
    l_k   PLS_INTEGER;
    l_bal NUMBER := cash_now;
    l_pr  NUMBER;
    l_a   JSON_ARRAY_T := JSON_ARRAY_T();
    l_o   JSON_OBJECT_T;
    l_d   DATE;
    FUNCTION wk(p DATE) RETURN PLS_INTEGER IS BEGIN RETURN LEAST(GREATEST(FLOOR((p - l_d0) / 7) + 1, 1), l_w); END wk;
  BEGIN
    FOR i IN 1 .. l_w LOOP l_in(i) := 0; l_out(i) := 0; l_pay(i) := 0; END LOOP;
    FOR r IN (SELECT due_date, open_amount FROM ar_open_item WHERE company_id = company AND status_code IN ('OPEN', 'PARTIALLY_PAID')
                 AND open_amount > 0 AND due_date < l_d0 + l_w * 7) LOOP
      IF r.due_date < l_d0 THEN
        FOR i IN 1 .. LEAST(4, l_w) LOOP l_in(i) := l_in(i) + r.open_amount * 0.6 / LEAST(4, l_w); END LOOP;
      ELSE
        l_k := wk(r.due_date); l_in(l_k) := l_in(l_k) + r.open_amount * 0.95;
      END IF;
    END LOOP;
    FOR r IN (SELECT cheque_due_date d, amount FROM dst_collection WHERE company_id = company AND status_code = 'PENDING_VERIFY'
                 AND payment_method = 'CHEQUE' AND cheque_due_date < l_d0 + l_w * 7) LOOP
      l_k := wk(r.d); l_in(l_k) := l_in(l_k) + r.amount;
    END LOOP;
    FOR r IN (SELECT due_date, open_amount FROM ap_open_item WHERE company_id = company AND status_code IN ('OPEN', 'SCHEDULED', 'PARTIALLY_PAID')
                 AND open_amount > 0 AND due_date < l_d0 + l_w * 7) LOOP
      l_k := wk(r.due_date); l_out(l_k) := l_out(l_k) + r.open_amount;
    END LOOP;
    BEGIN
      SELECT AVG(total_net) INTO l_pr FROM (SELECT total_net FROM pay_run WHERE company_id = company AND run_type = 'REGULAR'
                                              AND status_code IN ('APPROVED', 'PAYABLE', 'PAID', 'POSTED', 'CLOSED') AND total_net > 0
                                            ORDER BY id DESC FETCH FIRST 3 ROWS ONLY);
    EXCEPTION WHEN OTHERS THEN l_pr := NULL;
    END;
    IF NVL(l_pr, 0) > 0 THEN
      l_d := TRUNC(l_d0, 'MM') + 26;
      WHILE l_d < l_d0 + l_w * 7 LOOP
        IF l_d >= l_d0 THEN l_k := wk(l_d); l_pay(l_k) := l_pay(l_k) + l_pr; END IF;
        l_d := ADD_MONTHS(l_d, 1);
      END LOOP;
    END IF;
    FOR i IN 1 .. l_w LOOP
      l_bal := l_bal + l_in(i) - l_out(i) - l_pay(i);
      l_o := JSON_OBJECT_T();
      l_o.put('w', i); l_o.put('from', TO_CHAR(l_d0 + (i - 1) * 7, 'YYYY-MM-DD')); l_o.put('to', TO_CHAR(l_d0 + i * 7 - 1, 'YYYY-MM-DD'));
      l_o.put('in', ROUND(l_in(i), 2)); l_o.put('out', ROUND(l_out(i), 2)); l_o.put('payroll', ROUND(l_pay(i), 2));
      l_o.put('net', ROUND(l_in(i) - l_out(i) - l_pay(i), 2)); l_o.put('balance', ROUND(l_bal, 2));
      l_a.append(l_o);
    END LOOP;
    RETURN l_a.to_clob;
  END forecast_json;

  FUNCTION forecast_min(p_days IN NUMBER DEFAULT 90, p_date OUT DATE) RETURN NUMBER IS
    l_min NUMBER;
  BEGIN
    FOR r IN (SELECT * FROM JSON_TABLE(forecast_json(p_days), '$[*]' COLUMNS (f VARCHAR2(10) PATH '$.from', b NUMBER PATH '$.balance'))) LOOP
      IF l_min IS NULL OR r.b < l_min THEN l_min := r.b; p_date := TO_DATE(r.f, 'YYYY-MM-DD'); END IF;
    END LOOP;
    RETURN l_min;
  END forecast_min;

  FUNCTION forecast_html(p_days IN NUMBER DEFAULT 90) RETURN CLOB IS
    l_h   CLOB;
    l_bar CLOB;
    l_max NUMBER := 1;
    l_now NUMBER := cash_now;
    l_neg PLS_INTEGER := 0;
    l_x   NUMBER := 0;
    l_tin NUMBER := 0; l_tout NUMBER := 0;
  BEGIN
    FOR r IN (SELECT * FROM JSON_TABLE(forecast_json(p_days), '$[*]' COLUMNS (b NUMBER PATH '$.balance'))) LOOP
      l_max := GREATEST(l_max, ABS(r.b));
    END LOOP;
    l_max := GREATEST(l_max, ABS(l_now));
    FOR r IN (SELECT * FROM JSON_TABLE(forecast_json(p_days), '$[*]' COLUMNS (w NUMBER PATH '$.w', f VARCHAR2(10) PATH '$.from', t VARCHAR2(10) PATH '$.to',
                     i NUMBER PATH '$.in', o NUMBER PATH '$.out', p NUMBER PATH '$.payroll', n NUMBER PATH '$.net', b NUMBER PATH '$.balance'))) LOOP
      l_x := l_x + 1;
      l_tin := l_tin + r.i; l_tout := l_tout + r.o + r.p;
      IF r.b < 0 THEN l_neg := l_neg + 1; END IF;
      l_h := l_h || '<tr' || CASE WHEN r.b < 0 THEN ' class="is-neg"' END || '><td>' || r.w || '</td><td>' || r.f || ' ← ' || r.t || '</td><td>'
          || fmt(r.i) || '</td><td>' || fmt(r.o) || '</td><td>' || fmt(r.p) || '</td><td>' || fmt(r.n) || '</td><td><b>' || fmt(r.b) || '</b></td></tr>';
      l_bar := l_bar || '<div class="nn-fc-bar' || CASE WHEN r.b < 0 THEN ' is-neg' END || '" title="' || r.f || ': ' || fmt(r.b)
          || '"><i style="height:' || ROUND(ABS(r.b) / l_max * 100) || '%"></i><small>' || r.w || '</small></div>';
    END LOOP;
    RETURN '<div class="nn-kpis"><div class="nn-kpi"><span>النقد الآن</span><b>' || fmt(l_now) || '</b></div>'
        || '<div class="nn-kpi"><span>الوارد المتوقع</span><b>' || fmt(l_tin) || '</b></div>'
        || '<div class="nn-kpi"><span>الصادر المتوقع</span><b>' || fmt(l_tout) || '</b></div>'
        || '<div class="nn-kpi' || CASE WHEN l_neg > 0 THEN ' is-danger' END || '"><span>أسابيع بعجز</span><b>' || l_neg || '</b></div></div>'
        || '<div class="nn-fc-chart">' || l_bar || '</div>'
        || '<table class="nn-table nn-fc"><thead><tr><th>الأسبوع</th><th>الفترة</th><th>تحصيل متوقع</th><th>سداد موردين</th><th>رواتب</th><th>الصافي</th>'
        || '<th>الرصيد المتوقع</th></tr></thead><tbody>' || l_h || '</tbody></table>'
        || '<p class="nn-hint">الافتراضات: الذمم المدينة تحصل في استحقاقها بنسبة 95%، والمتأخر منها 60% موزعاً على 4 أسابيع، والشيكات الميدانية في تاريخها؛ '
        || 'الذمم الدائنة تسدد في استحقاقها؛ الرواتب بمتوسط آخر 3 مسيرات في 27 من كل شهر.</p>';
  END forecast_html;

  -- ================================================================ الإنذار المبكر
  PROCEDURE notify(p_tenant NUMBER, p_company NUMBER, p_alert_id NUMBER, p_title VARCHAR2) IS
    l_ev NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_ev FROM ntf_event_type WHERE code = 'ENG_ALERT';
    IF l_ev IS NULL THEN RETURN; END IF;
    FOR m IN (SELECT um.id FROM sec_user_membership um JOIN sec_user u ON u.id = um.user_id
               WHERE um.tenant_id = p_tenant AND um.status_code = 'ACTIVE' AND u.status_code = 'ACTIVE' AND um.is_tenant_admin = 'Y') LOOP
      BEGIN
        INSERT INTO ntf_notification (tenant_id, event_type_id, membership_id, source_entity_type, source_entity_id, title, link_url,
                                      idempotency_key, correlation_id, confidentiality_level)
        VALUES (p_tenant, l_ev, m.id, 'ENG_ALERT', p_alert_id, SUBSTR(p_title, 1, 500), 'f?p=NOONA_HUB:ALERTS',
                'ENG:' || p_alert_id || ':' || m.id, NOONA_CTX_PKG.correlation_id, 'INTERNAL');
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
      END;
    END LOOP;
  END notify;

  FUNCTION run_alerts(p_company_id IN NUMBER DEFAULT NULL) RETURN NUMBER IS
    l_n     NUMBER := 0;
    l_v     NUMBER;
    l_hit   BOOLEAN;
    l_title VARCHAR2(500);
    l_det   VARCHAR2(4000);
    l_id    NUMBER;
    l_dt    DATE;
    l_prev  NUMBER;
    l_m     NUMBER;
    l_tpl   VARCHAR2(2000);
    l_pco   NUMBER := NOONA_CTX_PKG.company_id;
    l_pbr   NUMBER := NOONA_CTX_PKG.branch_id;
  BEGIN
    NOONA_CORE_PKG.begin_system;
    FOR r IN (SELECT * FROM eng_alert_rule WHERE is_active = 'Y' AND (p_company_id IS NULL OR company_id = p_company_id) ORDER BY company_id, id) LOOP
      NOONA_CTX_PKG.set_company(r.company_id);
      l_hit := FALSE; l_det := NULL; l_v := NULL;
      BEGIN
        IF r.metric = 'CASH_LOW' THEN
          l_v := cash_now; l_hit := l_v < NVL(r.threshold, 0);
          l_title := 'النقد المتاح ' || fmt(l_v) || ' أقل من الحد ' || fmt(r.threshold);
        ELSIF r.metric = 'FORECAST_NEGATIVE' THEN
          l_v := forecast_min(NVL(r.days, 30), l_dt); l_hit := l_v < NVL(r.threshold, 0);
          l_title := 'عجز نقدي متوقع ' || fmt(l_v) || ' في أسبوع ' || TO_CHAR(l_dt, 'YYYY-MM-DD');
        ELSIF r.metric = 'AR_OVERDUE' THEN
          SELECT NVL(SUM(open_amount), 0), COUNT(DISTINCT customer_account_id) INTO l_v, l_m FROM ar_open_item
           WHERE company_id = r.company_id AND status_code IN ('OPEN', 'PARTIALLY_PAID') AND due_date < TRUNC(SYSDATE) - NVL(r.days, 0);
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := 'ذمم متأخرة أكثر من ' || NVL(r.days, 0) || ' يوماً: ' || fmt(l_v) || ' على ' || l_m || ' عميل';
        ELSIF r.metric = 'OVER_CREDIT_LIMIT' THEN
          l_v := 0;
          FOR c IN (SELECT a.id FROM ar_customer_account a WHERE a.company_id = r.company_id AND a.status_code = 'ACTIVE'
                       AND NOONA_SAL_PKG.credit_limit(a.id) IS NOT NULL) LOOP
            IF NOONA_SAL_PKG.customer_balance(c.id) > NOONA_SAL_PKG.credit_limit(c.id) THEN
              l_v := l_v + 1;
              IF NVL(LENGTH(l_det), 0) < 3500 THEN l_det := l_det || NOONA_SAL_PKG.customer_label(c.id) || '؛ '; END IF;
            END IF;
          END LOOP;
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := l_v || ' عميل تجاوز حد الائتمان';
        ELSIF r.metric = 'STOCK_BELOW_MIN' THEN
          l_v := 0;
          FOR s IN (SELECT i.name_ar, ic.min_qty, (SELECT NVL(SUM(o.on_hand_qty), 0) FROM inv_onhand o WHERE o.item_id = ic.item_id AND o.company_id = ic.company_id) q
                      FROM inv_item_company ic JOIN inv_item i ON i.id = ic.item_id
                     WHERE ic.company_id = r.company_id AND ic.min_qty > 0) LOOP
            IF s.q < s.min_qty THEN
              l_v := l_v + 1;
              IF NVL(LENGTH(l_det), 0) < 3500 THEN l_det := l_det || s.name_ar || ' (' || s.q || ' / ' || s.min_qty || ')؛ '; END IF;
            END IF;
          END LOOP;
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := l_v || ' صنف تحت الحد الأدنى';
        ELSIF r.metric = 'SALES_DROP' THEN
          SELECT NVL(SUM(CASE WHEN doc_date >= TRUNC(SYSDATE) - NVL(r.days, 7) THEN total_amount END), 0),
                 NVL(SUM(CASE WHEN doc_date < TRUNC(SYSDATE) - NVL(r.days, 7) THEN total_amount END), 0) / 4
            INTO l_v, l_prev FROM sal_invoice
           WHERE company_id = r.company_id AND status_code NOT IN ('DRAFT', 'CANCELLED') AND doc_type IN ('INVOICE', 'SIMPLIFIED_INVOICE')
             AND doc_date >= TRUNC(SYSDATE) - NVL(r.days, 7) * 5;
          l_hit := l_prev > 0 AND l_v < l_prev * (1 - NVL(r.threshold, 30) / 100);
          l_title := 'مبيعات آخر ' || NVL(r.days, 7) || ' أيام ' || fmt(l_v) || ' مقابل متوسط ' || fmt(l_prev)
                     || CASE WHEN l_prev > 0 THEN ' (انخفاض ' || ROUND((1 - l_v / l_prev) * 100) || '%)' END;
        ELSIF r.metric = 'PENDING_COLLECTIONS' THEN
          SELECT COUNT(*), NVL(SUM(amount), 0) INTO l_v, l_m FROM dst_collection
           WHERE company_id = r.company_id AND status_code = 'PENDING_VERIFY' AND doc_date <= TRUNC(SYSDATE) - NVL(r.days, 2);
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := l_v || ' تحصيل ميداني (تحويل أو شيك) بمبلغ ' || fmt(l_m) || ' لم يؤكد منذ ' || NVL(r.days, 2) || ' يوم';
        ELSIF r.metric = 'CHEQUES_DUE' THEN
          SELECT COUNT(*), NVL(SUM(amount), 0) INTO l_v, l_m FROM dst_collection
           WHERE company_id = r.company_id AND payment_method = 'CHEQUE' AND status_code = 'PENDING_VERIFY'
             AND cheque_due_date BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + NVL(r.days, 3);
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := l_v || ' شيك بمبلغ ' || fmt(l_m) || ' يستحق خلال ' || NVL(r.days, 3) || ' أيام';
        ELSIF r.metric = 'AP_DUE' THEN
          SELECT NVL(SUM(open_amount), 0), COUNT(*) INTO l_v, l_m FROM ap_open_item
           WHERE company_id = r.company_id AND status_code IN ('OPEN', 'SCHEDULED', 'PARTIALLY_PAID') AND due_date <= TRUNC(SYSDATE) + NVL(r.days, 7);
          l_hit := l_v > NVL(r.threshold, 0);
          l_title := 'مستحقات موردين خلال ' || NVL(r.days, 7) || ' أيام: ' || fmt(l_v) || ' (' || l_m || ' مستند)';
        END IF;
      EXCEPTION WHEN OTHERS THEN
        l_hit := FALSE;
      END;
      UPDATE eng_alert_rule SET last_run_at = SYSTIMESTAMP, last_value = l_v WHERE id = r.id;
      IF l_hit THEN
        BEGIN
          INSERT INTO eng_alert (tenant_id, company_id, rule_id, alert_date, severity, title, detail, metric_value, status_code)
          VALUES (r.tenant_id, r.company_id, r.id, TRUNC(SYSDATE), r.severity, SUBSTR(l_title, 1, 500), SUBSTR(l_det, 1, 4000), l_v, 'OPEN')
          RETURNING id INTO l_id;
          l_n := l_n + 1;
          notify(r.tenant_id, r.company_id, l_id, l_title);
          IF r.notify_whatsapp IS NOT NULL THEN
            BEGIN
              SELECT MAX(body_text) INTO l_tpl FROM eng_wa_template WHERE company_id = r.company_id AND event_code = 'ALERT' AND is_active = 'Y';
              l_m := send_text(r.notify_whatsapp, REPLACE(REPLACE(NVL(l_tpl, 'تنبيه {company}: {title}'), '{title}', l_title),
                                                     '{company}', company_name(r.company_id)), 'ENG_ALERT', l_id);
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
          END IF;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
          UPDATE eng_alert SET title = SUBSTR(l_title, 1, 500), detail = SUBSTR(l_det, 1, 4000), metric_value = l_v
           WHERE company_id = r.company_id AND rule_id = r.id AND alert_date = TRUNC(SYSDATE) AND status_code = 'OPEN';
        END;
      END IF;
    END LOOP;
    NOONA_CTX_PKG.set_company(l_pco, l_pbr);
    NOONA_CORE_PKG.end_system;
    RETURN l_n;
  EXCEPTION WHEN OTHERS THEN
    NOONA_CTX_PKG.set_company(l_pco, l_pbr);
    NOONA_CORE_PKG.end_system;
    RAISE;
  END run_alerts;

  PROCEDURE ack_alert(p_id IN NUMBER) IS
  BEGIN
    guard('ENG_ALERT.UPDATE');
    UPDATE eng_alert SET status_code = 'ACKNOWLEDGED', ack_by = NOONA_CTX_PKG.current_user_name, ack_at = SYSTIMESTAMP
     WHERE id = p_id AND company_id = company AND status_code = 'OPEN';
  END ack_alert;

  PROCEDURE close_alert(p_id IN NUMBER) IS
  BEGIN
    guard('ENG_ALERT.UPDATE');
    UPDATE eng_alert SET status_code = 'CLOSED', ack_by = NVL(ack_by, NOONA_CTX_PKG.current_user_name), ack_at = NVL(ack_at, SYSTIMESTAMP)
     WHERE id = p_id AND company_id = company;
  END close_alert;

  FUNCTION alerts_html(p_limit IN NUMBER DEFAULT 10) RETURN CLOB IS
    l_h CLOB;
  BEGIN
    FOR a IN (SELECT id, title, severity, alert_date, detail FROM eng_alert WHERE company_id = company AND status_code = 'OPEN'
               ORDER BY DECODE(severity, 'CRITICAL', 0, 'HIGH', 1, 'MEDIUM', 2, 3), id DESC FETCH FIRST NVL(p_limit, 10) ROWS ONLY) LOOP
      l_h := l_h || '<div class="nn-al nn-al-' || LOWER(a.severity) || '">' || badge(a.severity) || ' <b>' || esc(a.title) || '</b><small>'
          || TO_CHAR(a.alert_date, 'YYYY-MM-DD') || CASE WHEN a.detail IS NOT NULL THEN ' · ' || esc(SUBSTR(a.detail, 1, 200)) END || '</small></div>';
    END LOOP;
    RETURN NVL(l_h, '<p class="nn-hint">لا تنبيهات مفتوحة. <span class="fa fa-check-circle"></span></p>');
  END alerts_html;

  FUNCTION dashboard_html RETURN CLOB IS
    l_cash NUMBER := cash_now;
    l_td NUMBER; l_mtd NUMBER; l_lm NUMBER; l_ar NUMBER; l_ovd NUMBER; l_ap NUMBER; l_min NUMBER; l_dt DATE; l_dst NUMBER; l_vis NUMBER;
    l_top CLOB;
    FUNCTION k(p_label VARCHAR2, p_val VARCHAR2, p_sub VARCHAR2 DEFAULT NULL, p_cls VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    BEGIN
      RETURN '<div class="nn-kpi' || CASE WHEN p_cls IS NOT NULL THEN ' ' || p_cls END || '"><span>' || p_label || '</span><b>' || p_val || '</b>'
          || CASE WHEN p_sub IS NOT NULL THEN '<small>' || p_sub || '</small>' END || '</div>';
    END k;
  BEGIN
    SELECT NVL(SUM(CASE WHEN doc_date = TRUNC(SYSDATE) THEN total_amount END), 0),
           NVL(SUM(CASE WHEN doc_date >= TRUNC(SYSDATE, 'MM') THEN total_amount END), 0),
           NVL(SUM(CASE WHEN doc_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1) AND doc_date < ADD_MONTHS(TRUNC(SYSDATE), -1) + 1 THEN total_amount END), 0)
      INTO l_td, l_mtd, l_lm FROM sal_invoice
     WHERE company_id = company AND status_code NOT IN ('DRAFT', 'CANCELLED') AND doc_type IN ('INVOICE', 'SIMPLIFIED_INVOICE')
       AND doc_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1);
    SELECT NVL(SUM(open_amount), 0), NVL(SUM(CASE WHEN due_date < TRUNC(SYSDATE) THEN open_amount END), 0) INTO l_ar, l_ovd
      FROM ar_open_item WHERE company_id = company AND status_code IN ('OPEN', 'PARTIALLY_PAID');
    SELECT NVL(SUM(open_amount), 0) INTO l_ap FROM ap_open_item
     WHERE company_id = company AND status_code IN ('OPEN', 'SCHEDULED', 'PARTIALLY_PAID') AND due_date <= TRUNC(SYSDATE) + 7;
    l_min := forecast_min(90, l_dt);
    SELECT NVL(SUM(sales_amount), 0), COUNT(*) INTO l_dst, l_vis FROM dst_visit WHERE company_id = company AND doc_date = TRUNC(SYSDATE);
    FOR c IN (SELECT customer_account_id a, SUM(open_amount) s FROM ar_open_item
               WHERE company_id = company AND status_code IN ('OPEN', 'PARTIALLY_PAID') AND due_date < TRUNC(SYSDATE)
               GROUP BY customer_account_id ORDER BY 2 DESC FETCH FIRST 5 ROWS ONLY) LOOP
      l_top := l_top || '<tr><td>' || esc(NOONA_SAL_PKG.customer_label(c.a)) || '</td><td class="u-tE"><b>' || fmt(c.s) || '</b></td></tr>';
    END LOOP;
    RETURN '<div class="nn-kpis nn-mgr">'
        || k('النقد والبنوك الآن', fmt0(l_cash), NULL, CASE WHEN l_cash < 0 THEN 'is-danger' END)
        || k('مبيعات اليوم', fmt0(l_td))
        || k('مبيعات الشهر', fmt0(l_mtd), CASE WHEN l_lm > 0 THEN 'مقابل ' || fmt0(l_lm) || ' للفترة نفسها من الشهر الماضي ('
              || CASE WHEN l_mtd >= l_lm THEN '+' END || ROUND((l_mtd - l_lm) / l_lm * 100) || '%)' END,
              CASE WHEN l_lm > 0 AND l_mtd < l_lm * 0.8 THEN 'is-warning' END)
        || k('الذمم المدينة', fmt0(l_ar), 'منها متأخر ' || fmt0(l_ovd), CASE WHEN l_ovd > l_ar * 0.3 THEN 'is-warning' END)
        || k('مستحق للموردين خلال 7 أيام', fmt0(l_ap))
        || k('أدنى رصيد متوقع (90 يوماً)', fmt0(l_min), 'أسبوع ' || TO_CHAR(l_dt, 'YYYY-MM-DD'), CASE WHEN l_min < 0 THEN 'is-danger' END)
        || CASE WHEN l_vis > 0 THEN k('التوزيع اليوم', fmt0(l_dst), l_vis || ' زيارة') END
        || '</div><h3 class="nn-mgr-h">التنبيهات</h3>' || alerts_html(8)
        || CASE WHEN l_top IS NOT NULL THEN '<h3 class="nn-mgr-h">أكبر المتأخرين</h3><table class="nn-table"><tbody>' || l_top || '</tbody></table>' END;
  END dashboard_html;

  -- ================================================================ مساعدة الشاشات
  FUNCTION help_html(p_app_id IN NUMBER, p_page_id IN NUMBER) RETURN CLOB IS
    l_h     CLOB;
    l_alias VARCHAR2(100);
    l_title VARCHAR2(400);
    l_appn  VARCHAR2(400);
    l_items CLOB;
    l_btns  CLOB;
    l_regs  CLOB;
    l_hp    eng_help%ROWTYPE;
    l_video VARCHAR2(500);
    l_found BOOLEAN := FALSE;
  BEGIN
    FOR a IN (SELECT alias, application_name FROM apex_applications WHERE application_id = p_app_id) LOOP
      l_alias := a.alias; l_appn := a.application_name;
    END LOOP;
    FOR p IN (SELECT page_title, page_name FROM apex_application_pages WHERE application_id = p_app_id AND page_id = p_page_id) LOOP
      l_title := NVL(p.page_title, p.page_name);
    END LOOP;
    IF l_title IS NULL THEN RETURN '<p class="nn-hint">لا توجد شاشة بهذا الرقم.</p>'; END IF;
    BEGIN
      SELECT * INTO l_hp FROM (SELECT * FROM eng_help WHERE app_alias = l_alias AND page_id = p_page_id
                                ORDER BY NVL2(tenant_id, 0, 1)) WHERE ROWNUM = 1;
      l_found := TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    FOR r IN (SELECT region_name FROM apex_application_page_regions WHERE application_id = p_app_id AND page_id = p_page_id
                 AND region_name NOT LIKE 'NOONA %' AND NVL(display_position, 'BODY') NOT LIKE '%BREADCRUMB%' ORDER BY display_sequence) LOOP
      l_regs := l_regs || '<li>' || esc(r.region_name) || '</li>';
    END LOOP;
    FOR i IN (SELECT label, display_as, is_required, item_help_text FROM apex_application_page_items
               WHERE application_id = p_app_id AND page_id = p_page_id AND display_as NOT LIKE '%Hidden%' AND label IS NOT NULL
               ORDER BY region, display_sequence) LOOP
      l_items := l_items || '<tr><td><b>' || esc(i.label) || '</b>' || CASE WHEN i.is_required = 'Yes' OR i.is_required = 'Y' THEN ' <span class="nn-badge is-danger">مطلوب</span>' END
          || '</td><td>' || esc(CASE WHEN i.display_as LIKE '%Select%' THEN 'اختيار من قائمة' WHEN i.display_as LIKE '%Date%' THEN 'تاريخ'
                                     WHEN i.display_as LIKE '%Number%' THEN 'رقم' WHEN i.display_as LIKE '%Textarea%' THEN 'نص طويل'
                                     WHEN i.display_as LIKE '%Checkbox%' THEN 'خيارات متعددة' WHEN i.display_as LIKE '%File%' THEN 'ملف'
                                     WHEN i.display_as LIKE '%Display%' THEN 'للعرض' ELSE 'نص' END)
          || '</td><td>' || esc(i.item_help_text) || '</td></tr>';
    END LOOP;
    FOR b IN (SELECT label FROM apex_application_page_buttons WHERE application_id = p_app_id AND page_id = p_page_id ORDER BY button_sequence) LOOP
      l_btns := l_btns || '<span class="nn-badge is-info">' || esc(b.label) || '</span> ';
    END LOOP;
    l_h := '<div class="nn-help"><h2>' || esc(l_title) || '</h2><small>' || esc(l_appn) || ' · الشاشة ' || p_page_id || '</small>';
    IF l_found AND l_hp.purpose IS NOT NULL THEN
      l_h := l_h || '<h3>الغرض</h3><p>' || REPLACE(esc(l_hp.purpose), CHR(10), '<br>') || '</p>';
    END IF;
    IF l_found AND l_hp.steps IS NOT NULL THEN
      l_h := l_h || '<h3>خطوات العمل</h3><ol><li>' || REPLACE(esc(l_hp.steps), CHR(10), '</li><li>') || '</li></ol>';
    END IF;
    IF l_regs IS NOT NULL THEN l_h := l_h || '<h3>أقسام الشاشة</h3><ul>' || l_regs || '</ul>'; END IF;
    IF l_items IS NOT NULL THEN
      l_h := l_h || '<h3>الحقول</h3><table class="nn-table"><thead><tr><th>الحقل</th><th>النوع</th><th>ملاحظة</th></tr></thead><tbody>' || l_items || '</tbody></table>';
    END IF;
    IF l_btns IS NOT NULL THEN l_h := l_h || '<h3>الأزرار</h3><p>' || l_btns || '</p>'; END IF;
    IF l_found AND l_hp.tips IS NOT NULL THEN
      l_h := l_h || '<h3>تنبيهات ونصائح</h3><p>' || REPLACE(esc(l_hp.tips), CHR(10), '<br>') || '</p>';
    END IF;
    -- فيديو الشرح: فيديو الشاشة، وإلا فيديو النظام لمؤسسة المستخدم (الصفحة 0) ثم فيديو النظام العام
    SELECT MAX(video_url) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN page_id = p_page_id THEN 0 ELSE 1 END, NVL2(tenant_id, 0, 1))
      INTO l_video FROM eng_help
     WHERE app_alias = l_alias AND page_id IN (p_page_id, 0) AND video_url IS NOT NULL;
    IF l_video IS NOT NULL THEN
      l_h := l_h || '<p><a class="nn-dst-btn" target="_blank" rel="noopener" href="' || esc(l_video) || '"><span class="fa fa-play-circle"></span> فيديو الشرح</a></p>';
    END IF;
    RETURN l_h || '</div>';
  END help_html;

  PROCEDURE save_help(p_doc IN CLOB) IS
    l_o  JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_al VARCHAR2(50) := UPPER(js(l_o, 'app'));
    l_pg NUMBER := TO_NUMBER(js(l_o, 'page'));
    l_x  NUMBER;
    l_ti VARCHAR2(200) := js(l_o, 'title');
    l_pu VARCHAR2(4000) := js(l_o, 'purpose');
    l_st VARCHAR2(4000) := js(l_o, 'steps');
    l_tp VARCHAR2(4000) := js(l_o, 'tips');
    l_vi VARCHAR2(500) := js(l_o, 'video');
  BEGIN
    guard('ENG_HELP.UPDATE');
    NOONA_CORE_PKG.assert(l_al IS NOT NULL AND l_pg IS NOT NULL, 'NOONA-ENG-020', 'حدد التطبيق والشاشة', 'App and page required');
    SELECT MAX(id) INTO l_x FROM eng_help WHERE tenant_id = NOONA_CTX_PKG.tenant_id AND app_alias = l_al AND page_id = l_pg;
    IF l_x IS NULL THEN
      INSERT INTO eng_help (tenant_id, app_alias, page_id) VALUES (NOONA_CTX_PKG.tenant_id, l_al, l_pg) RETURNING id INTO l_x;
    END IF;
    UPDATE eng_help SET title = l_ti, purpose = l_pu, steps = l_st, tips = l_tp, video_url = l_vi
     WHERE id = l_x;
  END save_help;

  -- ================================================================ تصدير البيانات
  FUNCTION table_label(p_table IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(comments) INTO l FROM user_tab_comments WHERE table_name = UPPER(p_table);
    RETURN NVL(TRIM(REGEXP_SUBSTR(l, '^[^|.(]+')), p_table);
  END table_label;

  FUNCTION export_name(p_table IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE(table_label(p_table), '[\\/:*?"<>|]', '') || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD');
  END export_name;

  -- يتحقق من صلاحية العرض ويبني الاستعلام بعناوين عربية من تعليقات الأعمدة، دون الأعمدة الحساسة والثنائية
  FUNCTION export_sql(p_table IN VARCHAR2) RETURN CLOB IS
    l_t VARCHAR2(128) := UPPER(DBMS_ASSERT.simple_sql_name(p_table));
    l_s CLOB;
    l_x NUMBER;
    l_c NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_x FROM user_tables WHERE table_name = l_t;
    NOONA_CORE_PKG.assert(l_x = 1, 'NOONA-ENG-030', 'مجموعة البيانات غير موجودة', 'Dataset not found');
    NOONA_SECURITY_PKG.assert_permission(l_t || '.VIEW', company);
    SELECT COUNT(*) INTO l_c FROM user_tab_columns WHERE table_name = l_t AND column_name = 'COMPANY_ID';
    FOR c IN (SELECT c.column_name, c.data_type, m.comments FROM user_tab_columns c
                LEFT JOIN user_col_comments m ON m.table_name = c.table_name AND m.column_name = c.column_name
               WHERE c.table_name = l_t AND c.data_type NOT IN ('BLOB', 'RAW', 'LONG RAW', 'BFILE')
                 AND c.column_name NOT IN ('TENANT_ID', 'ROW_VERSION') AND c.column_name NOT LIKE '%\_ENC' ESCAPE '\'
                 AND c.column_name NOT LIKE '%HASH%' AND c.column_name NOT LIKE '%PASSWORD%' AND c.column_name NOT LIKE '%SECRET%'
               ORDER BY c.column_id) LOOP
      l_s := l_s || CASE WHEN l_s IS NOT NULL THEN ', ' END
          || CASE WHEN c.data_type = 'CLOB' THEN 'DBMS_LOB.SUBSTR(' || c.column_name || ', 4000, 1)' ELSE c.column_name END
          || ' AS "' || SUBSTR(REPLACE(NVL(REGEXP_SUBSTR(c.comments, '^[^(|]+'), c.column_name), '"', ''), 1, 120) || '"';
    END LOOP;
    RETURN 'SELECT ' || l_s || ' FROM ' || l_t || CASE WHEN l_c = 1 THEN ' WHERE company_id = noona_eng_pkg.company' END || ' ORDER BY 1';
  END export_sql;

  -- ================================================================ سجل التغييرات
  PROCEDURE track_table(p_table IN VARCHAR2) IS
    l_t   VARCHAR2(128) := UPPER(DBMS_ASSERT.simple_sql_name(p_table));
    l_b   CLOB;
    l_x   NUMBER;
    l_co  NUMBER;
    l_trg VARCHAR2(128);
  BEGIN
    SELECT COUNT(*) INTO l_x FROM user_tab_columns WHERE table_name = l_t AND column_name IN ('ID', 'TENANT_ID');
    IF l_x < 2 THEN RETURN; END IF;
    SELECT COUNT(*) INTO l_co FROM user_tab_columns WHERE table_name = l_t AND column_name = 'COMPANY_ID';
    l_trg := SUBSTR('ENG_TRK_' || l_t, 1, 128);
    FOR c IN (SELECT column_name, data_type FROM user_tab_columns
               WHERE table_name = l_t AND data_type IN ('VARCHAR2', 'NUMBER', 'DATE', 'CHAR', 'NVARCHAR2', 'FLOAT')
                 AND data_type NOT LIKE 'TIMESTAMP%'
                 AND column_name NOT IN ('ID', 'TENANT_ID', 'COMPANY_ID', 'CREATED_AT', 'CREATED_BY', 'UPDATED_AT', 'UPDATED_BY', 'ROW_VERSION')
                 AND column_name NOT LIKE '%\_ENC' ESCAPE '\' AND column_name NOT LIKE '%HASH%' AND column_name NOT LIKE '%PASSWORD%'
               ORDER BY column_id) LOOP
      l_b := l_b || '    IF NOT (:OLD.' || c.column_name || ' = :NEW.' || c.column_name || ' OR (:OLD.' || c.column_name || ' IS NULL AND :NEW.'
          || c.column_name || ' IS NULL)) THEN ch(''' || c.column_name || ''', '
          || CASE WHEN c.data_type = 'DATE' THEN 'TO_CHAR(:OLD.' || c.column_name || ', ''YYYY-MM-DD''), TO_CHAR(:NEW.' || c.column_name || ', ''YYYY-MM-DD'')'
                  ELSE 'SUBSTR(TO_CHAR(:OLD.' || c.column_name || '), 1, 400), SUBSTR(TO_CHAR(:NEW.' || c.column_name || '), 1, 400)' END
          || '); END IF;' || CHR(10);
    END LOOP;
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || l_trg || ' AFTER INSERT OR UPDATE OR DELETE ON ' || l_t || ' FOR EACH ROW' || CHR(10)
      || 'DECLARE' || CHR(10) || '  a JSON_ARRAY_T := JSON_ARRAY_T();' || CHR(10)
      || '  l_act VARCHAR2(10) := CASE WHEN INSERTING THEN ''INSERT'' WHEN UPDATING THEN ''UPDATE'' ELSE ''DELETE'' END;' || CHR(10)
      || '  l_chg CLOB;' || CHR(10)
      || '  PROCEDURE ch(c VARCHAR2, o VARCHAR2, n VARCHAR2) IS x JSON_OBJECT_T := JSON_OBJECT_T(); BEGIN x.put(''c'', c); x.put(''o'', o); x.put(''n'', n); a.append(x); END;' || CHR(10)
      || 'BEGIN' || CHR(10)
      || '  IF UPDATING THEN' || CHR(10) || l_b
      || '    IF a.get_size = 0 THEN RETURN; END IF;' || CHR(10) || '    l_chg := a.to_clob;' || CHR(10) || '  END IF;' || CHR(10)
      || '  INSERT INTO eng_change_log (tenant_id, company_id, table_name, row_id, action, changes, changed_by, changed_at)' || CHR(10)
      || '  VALUES (NVL(:NEW.tenant_id, :OLD.tenant_id), ' || CASE WHEN l_co = 1 THEN 'NVL(:NEW.company_id, :OLD.company_id)' ELSE 'NULL' END
      || ', ''' || l_t || ''', NVL(:NEW.id, :OLD.id), l_act, l_chg, NVL(NOONA_CTX_PKG.current_user_name, USER), SYSTIMESTAMP);' || CHR(10)
      || 'EXCEPTION WHEN OTHERS THEN NULL;' || CHR(10)
      || 'END;';
    -- أمان: مشغل غير صالح يوقف الكتابة على الجدول؛ يحذف فوراً إن لم يترجم
    SELECT COUNT(*) INTO l_x FROM user_objects WHERE object_name = l_trg AND object_type = 'TRIGGER' AND status <> 'VALID';
    IF l_x > 0 THEN
      EXECUTE IMMEDIATE 'DROP TRIGGER ' || l_trg;
      NOONA_CORE_PKG.raise_error('NOONA-ENG-040', 'تعذر تفعيل سجل التغييرات للجدول ' || l_t, 'Change tracking trigger failed for ' || l_t);
    END IF;
  END track_table;

  PROCEDURE untrack_table(p_table IN VARCHAR2) IS
    l_trg VARCHAR2(128) := SUBSTR('ENG_TRK_' || UPPER(DBMS_ASSERT.simple_sql_name(p_table)), 1, 128);
    l_x NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_x FROM user_triggers WHERE trigger_name = l_trg;
    IF l_x = 1 THEN EXECUTE IMMEDIATE 'DROP TRIGGER ' || l_trg; END IF;
  END untrack_table;

  FUNCTION track_defaults RETURN NUMBER IS
    l_n NUMBER := 0;
  BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
                'AR_CUSTOMER', 'AR_CUSTOMER_ACCOUNT', 'AP_SUPPLIER', 'AP_SUPPLIER_ACCOUNT', 'INV_ITEM', 'INV_ITEM_COMPANY', 'INV_WAREHOUSE',
                'SAL_PRICE_LIST_LINE', 'HR_EMPLOYEE', 'GL_ACCOUNT', 'CSH_CASH_BOX', 'CSH_BANK_ACCOUNT', 'ORG_COMPANY', 'ORG_BRANCH',
                'DST_REP', 'DST_SHOP', 'DST_ROUTE', 'TRN_VEHICLE', 'TRN_DRIVER', 'TRN_RATE', 'FA_ASSET', 'AUT_TECHNICIAN', 'ENG_ALERT_RULE')
              UNION
              -- إعادة بناء المشغلات القائمة بعد كل ترقية (أعمدة جديدة أو محذوفة)
              SELECT table_name FROM user_triggers WHERE trigger_name LIKE 'ENG\_TRK\_%' ESCAPE '\') LOOP
      BEGIN track_table(t.table_name); l_n := l_n + 1; EXCEPTION WHEN OTHERS THEN NULL; END;
    END LOOP;
    RETURN l_n;
  END track_defaults;

  FUNCTION col_label(p_table VARCHAR2, p_col VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(comments) INTO l FROM user_col_comments WHERE table_name = p_table AND column_name = p_col;
    RETURN NVL(TRIM(REGEXP_SUBSTR(l, '^[^(|]+')), p_col);
  END col_label;

  FUNCTION row_label(p_table VARCHAR2, p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
    l_c VARCHAR2(128);
  BEGIN
    SELECT MAX(column_name) KEEP (DENSE_RANK FIRST ORDER BY DECODE(column_name, 'NAME_AR', 1, 'FULL_NAME', 2, 'DOC_NO', 3, 'CODE', 4, 'ITEM_NO', 5,
                                                                     'PLATE_NO', 6, 'LEGAL_NAME_AR', 7, 9))
      INTO l_c FROM user_tab_columns
     WHERE table_name = p_table AND column_name IN ('NAME_AR', 'FULL_NAME', 'DOC_NO', 'CODE', 'ITEM_NO', 'PLATE_NO', 'LEGAL_NAME_AR');
    IF l_c IS NULL THEN RETURN '#' || p_id; END IF;
    EXECUTE IMMEDIATE 'SELECT MAX(TO_CHAR(' || l_c || ')) FROM ' || p_table || ' WHERE id = :1' INTO l USING p_id;
    RETURN NVL(l, '#' || p_id);
  EXCEPTION WHEN OTHERS THEN RETURN '#' || p_id;
  END row_label;

  FUNCTION history_html(p_table IN VARCHAR2 DEFAULT NULL, p_row_id IN NUMBER DEFAULT NULL, p_from IN DATE DEFAULT NULL,
                        p_to IN DATE DEFAULT NULL, p_user IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
    l_h  CLOB;
    l_ln CLOB;
    l_n  PLS_INTEGER := 0;
  BEGIN
    FOR r IN (SELECT * FROM eng_change_log
               WHERE (p_table IS NULL OR table_name = UPPER(p_table)) AND (p_row_id IS NULL OR row_id = p_row_id)
                 AND (company_id IS NULL OR company_id = company)
                 AND changed_at >= CAST(NVL(p_from, TRUNC(SYSDATE) - 30) AS TIMESTAMP)
                 AND changed_at < CAST(NVL(p_to, TRUNC(SYSDATE)) + 1 AS TIMESTAMP)
                 AND (p_user IS NULL OR UPPER(changed_by) = UPPER(p_user))
               ORDER BY changed_at DESC, id DESC FETCH FIRST 300 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_ln := NULL;
      IF r.action = 'UPDATE' AND r.changes IS NOT NULL THEN
        FOR c IN (SELECT * FROM JSON_TABLE(r.changes, '$[*]' COLUMNS (c VARCHAR2(128) PATH '$.c', o VARCHAR2(400) PATH '$.o', n VARCHAR2(400) PATH '$.n'))) LOOP
          l_ln := l_ln || '<li>«' || esc(col_label(r.table_name, c.c)) || '» من <del>' || NVL(esc(c.o), '(فارغ)') || '</del> إلى <ins>'
              || NVL(esc(c.n), '(فارغ)') || '</ins></li>';
        END LOOP;
      END IF;
      l_h := l_h || '<div class="nn-hist"><div class="nn-hist-h"><b>' || esc(r.changed_by) || '</b> '
          || CASE r.action WHEN 'INSERT' THEN 'أنشأ' WHEN 'DELETE' THEN 'حذف' ELSE 'عدّل' END || ' ' || esc(table_label(r.table_name))
          || ' «' || esc(row_label(r.table_name, r.row_id)) || '»<small>' || TO_CHAR(r.changed_at, 'YYYY-MM-DD HH24:MI') || '</small></div>'
          || CASE WHEN l_ln IS NOT NULL THEN '<ul>' || l_ln || '</ul>' END || '</div>';
    END LOOP;
    RETURN NVL(l_h, '<p class="nn-hint">لا تغييرات مسجلة في هذه الفترة.</p>');
  END history_html;

END NOONA_ENG_PKG;
/
