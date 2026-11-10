-- =============================================================================
-- NOONA PLUS ERP | NOONA_MAIL_PKG - بريد النظام (رموز التحقق، استعادة كلمة المرور، تنبيهات الاشتراك، الفواتير)
--   * يرسل عبر APEX_MAIL بإعداد SMTP على مستوى APEX (يضبطه tools/vm/mail_setup.sh) ومن داخل الوظائف الخلفية أيضاً
--   * مفعل فقط بعد نجاح رسالة التجربة (الإعداد MAIL.ENABLED = Y)؛ وإلا تعيد الدوال NULL ولا ترسل
--   * القالب: رأس بشعار نونا ونص عربي من اليمين لليسار
-- =============================================================================
SET DEFINE OFF

CREATE OR REPLACE PACKAGE NOONA_MAIL_PKG AUTHID DEFINER AS
  FUNCTION enabled RETURN VARCHAR2;
  FUNCTION setting(p_key IN VARCHAR2) RETURN VARCHAR2;
  -- يعيد رقم الرسالة في قائمة APEX أو NULL إن كان البريد غير مفعل؛ p_now يدفع القائمة فوراً
  FUNCTION send(p_to IN VARCHAR2, p_subject IN VARCHAR2, p_body_html IN CLOB, p_attach_name IN VARCHAR2 DEFAULT NULL,
                p_attach IN CLOB DEFAULT NULL, p_now IN BOOLEAN DEFAULT TRUE) RETURN NUMBER;
  -- قالب الرسالة: عنوان وفقرات وزر اختياري
  FUNCTION wrap(p_title IN VARCHAR2, p_body IN VARCHAR2, p_link IN VARCHAR2 DEFAULT NULL, p_link_text IN VARCHAR2 DEFAULT NULL) RETURN CLOB;
  -- رابط صفحة في النظام: PLATFORM.BASE_URL + /r/noonaplus/<alias>/<page>
  FUNCTION url(p_app_alias IN VARCHAR2, p_page_alias IN VARCHAR2) RETURN VARCHAR2;
  -- حالة البريد لمسؤول المنصة: الإعداد وآخر الرسائل وأخطاؤها
  FUNCTION status_html RETURN CLOB;
END NOONA_MAIL_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_MAIL_PKG AS

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;

  FUNCTION setting(p_key IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(4000);
  BEGIN
    SELECT MAX(default_value) INTO l FROM plt_setting_def WHERE setting_key = p_key;
    RETURN l;
  END setting;

  FUNCTION enabled RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE WHEN setting('MAIL.ENABLED') = 'Y' THEN 'Y' ELSE 'N' END;
  END enabled;

  FUNCTION url(p_app_alias IN VARCHAR2, p_page_alias IN VARCHAR2) RETURN VARCHAR2 IS
    l VARCHAR2(400) := RTRIM(setting('PLATFORM.BASE_URL'), '/');
  BEGIN
    RETURN CASE WHEN l IS NULL THEN NULL ELSE l || '/r/noonaplus/' || LOWER(p_app_alias) || '/' || LOWER(p_page_alias) END;
  END url;

  FUNCTION wrap(p_title IN VARCHAR2, p_body IN VARCHAR2, p_link IN VARCHAR2 DEFAULT NULL, p_link_text IN VARCHAR2 DEFAULT NULL) RETURN CLOB IS
  BEGIN
    RETURN '<div dir="rtl" style="font-family:Tahoma,Arial,sans-serif;max-width:600px;margin:auto;border:1px solid #e3e8f0;border-radius:12px;overflow:hidden">'
        || '<div style="background:linear-gradient(90deg,#0b3a8a,#1d6fe0);color:#fff;padding:14px 18px;font-size:18px;font-weight:bold">نونا بلس NOONA PLUS</div>'
        || '<div style="padding:18px;color:#1f2937;line-height:1.9"><h2 style="margin:0 0 10px;font-size:18px">' || esc(p_title) || '</h2>'
        || p_body
        || CASE WHEN p_link IS NOT NULL THEN '<p style="margin-top:18px"><a href="' || esc(p_link) || '" style="background:#1d4ed8;color:#fff;'
                || 'padding:10px 18px;border-radius:8px;text-decoration:none">' || esc(NVL(p_link_text, 'فتح النظام')) || '</a></p>' END
        || '</div><div style="background:#f6f8fb;color:#6b7280;font-size:12px;padding:10px 18px">رسالة آلية من نونا بلس؛ لا ترد عليها.</div></div>';
  END wrap;

  PROCEDURE ensure_workspace IS
    l_sg NUMBER;
  BEGIN
    IF NVL(apex_application.g_flow_id, 0) = 0 OR SYS_CONTEXT('APEX$SESSION', 'WORKSPACE_ID') IS NULL THEN
      l_sg := apex_util.find_security_group_id(p_workspace => NVL(setting('MAIL.WORKSPACE'), 'NOONAPLUS'));
      apex_util.set_security_group_id(p_security_group_id => l_sg);
    END IF;
  EXCEPTION WHEN OTHERS THEN NULL;
  END ensure_workspace;

  FUNCTION send(p_to IN VARCHAR2, p_subject IN VARCHAR2, p_body_html IN CLOB, p_attach_name IN VARCHAR2 DEFAULT NULL,
                p_attach IN CLOB DEFAULT NULL, p_now IN BOOLEAN DEFAULT TRUE) RETURN NUMBER IS
    l_id   NUMBER;
    l_from VARCHAR2(400) := NVL(setting('MAIL.FROM'), 'no-reply@noona.local');
    l_name VARCHAR2(200) := setting('MAIL.FROM_NAME');
    l_text CLOB;
  BEGIN
    IF enabled = 'N' OR TRIM(p_to) IS NULL THEN RETURN NULL; END IF;
    ensure_workspace;
    l_text := TO_CLOB(REGEXP_REPLACE(DBMS_LOB.substr(p_body_html, 30000, 1), '<[^>]+>', ' '));
    l_id := apex_mail.send(p_to => p_to, p_from => CASE WHEN l_name IS NOT NULL THEN l_name || ' <' || l_from || '>' ELSE l_from END,
                           p_body => l_text, p_body_html => p_body_html, p_subj => p_subject);
    IF p_attach IS NOT NULL THEN
      apex_mail.add_attachment(p_mail_id => l_id, p_attachment => apex_util.clob_to_blob(p_clob => p_attach, p_charset => 'AL32UTF8'),
                               p_filename => NVL(p_attach_name, 'noona.html'), p_mime_type => 'text/html');
    END IF;
    IF p_now THEN
      BEGIN apex_mail.push_queue; EXCEPTION WHEN OTHERS THEN NULL; END;   -- وإلا ترسل مع مهمة APEX الدورية
    END IF;
    RETURN l_id;
  END send;

  FUNCTION status_html RETURN CLOB IS
    l_h CLOB;
    l_n PLS_INTEGER := 0;
  BEGIN
    NOONA_CORE_PKG.require_platform_admin;
    ensure_workspace;
    l_h := '<div class="nn-prj-chips"><span>البريد: ' || CASE WHEN enabled = 'Y' THEN 'مفعل' ELSE 'غير مفعل (شغل tools/vm/mail_setup.sh)' END
        || '</span><span dir="ltr">' || esc(setting('MAIL.FROM')) || '</span><span dir="ltr">' || esc(setting('PLATFORM.BASE_URL')) || '</span></div>'
        || '<table class="nn-prj-t"><thead><tr><th>الوقت</th><th>إلى</th><th>الموضوع</th><th>الحالة</th></tr></thead><tbody>';
    FOR r IN (SELECT * FROM (
                SELECT last_updated_on t, mail_to t2, mail_subj s, CASE WHEN mail_send_error IS NULL THEN 'أرسلت' ELSE 'خطأ: ' || SUBSTR(mail_send_error, 1, 200) END st FROM apex_mail_log
                UNION ALL SELECT last_updated_on, mail_to, mail_subj, 'بانتظار الإرسال' || NVL2(mail_send_error, ': ' || SUBSTR(mail_send_error, 1, 200), '')
                  FROM apex_mail_queue)
               ORDER BY 1 DESC FETCH FIRST 20 ROWS ONLY) LOOP
      l_n := l_n + 1;
      l_h := l_h || ('<tr><td>' || TO_CHAR(r.t, 'YYYY-MM-DD HH24:MI') || '</td><td dir="ltr">' || esc(r.t2) || '</td><td>' || esc(r.s)
          || '</td><td>' || esc(r.st) || '</td></tr>');
    END LOOP;
    RETURN l_h || CASE WHEN l_n = 0 THEN '<tr><td colspan="4">لا توجد رسائل</td></tr>' END || ('</tbody></table>');
  END status_html;

END NOONA_MAIL_PKG;
/
