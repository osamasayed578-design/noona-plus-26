-- =============================================================================
-- NOONA PLUS ERP | NOONA_COR_PKG - المراسلات (بريد داخلي بطابع إداري)
--   * مراسلة داخلية (مذكرة/تعميم) بين المستخدمين والوحدات التنظيمية: إلى / نسخة / نسخة مخفية
--   * خطاب وارد (يسجل ويوزع داخلياً) وخطاب صادر (لجهة خارجية) برقم صادر/وارد مستقل لكل شركة وسنة
--   * لكل مستلم حالة مستقلة: مقروء، نجمة، مؤرشف، والإجراء المطلوب منه (التعليمة والمهلة) وهل أنجزه
--   * الرد والرد على الكل والتحويل في سلسلة واحدة، والإحالة الإدارية لشخص آخر بتعليمة ومهلة وملاحظة
--   * المرفقات تحفظ في الأرشيف (DMS) وتربط بالمراسلة؛ لا يطلع عليها إلا أطراف المراسلة
--   * إشعار داخلي للمستلم، وسجل تدقيق لكل إرسال وإحالة وإنجاز
-- الواجهة (تطبيق 129) تستدعي دوال JSON وتعرض صندوق بريد بتصميم مشابه لـ Gmail.
-- =============================================================================
CREATE OR REPLACE PACKAGE NOONA_COR_PKG AUTHID DEFINER AS

  -- العضوية والشركة الحاليتان، وسجل تسليمي في رسالة (عامة لاستخدامها داخل SQL)
  FUNCTION me RETURN NUMBER;
  FUNCTION company RETURN NUMBER;
  FUNCTION my_rid(p_id IN NUMBER) RETURN NUMBER;
  -- بيانات الواجهة: المستخدم، التعليمات، الأنواع، صلاحية تسجيل الوارد والصادر
  FUNCTION meta_json RETURN CLOB;
  -- أعداد المجلدات: غير المقروء في الوارد، المطلوب مني، المسودات
  FUNCTION folders_json RETURN CLOB;
  -- قائمة مجلد: INBOX / TASKS / STARRED / SENT / DRAFTS / ARCHIVE / INCOMING / OUTGOING
  FUNCTION list_json(p_folder IN VARCHAR2, p_q IN VARCHAR2 DEFAULT NULL, p_offset IN NUMBER DEFAULT 0) RETURN CLOB;
  -- السلسلة كاملة (أي رسالة فيها)؛ تعلّم رسائل المستلم مقروءة
  FUNCTION thread_json(p_id IN NUMBER) RETURN CLOB;
  -- دليل المستلمين: المستخدمون والوحدات التنظيمية
  FUNCTION directory_json(p_q IN VARCHAR2) RETURN CLOB;
  -- الجهات الخارجية (الأطراف) للوارد والصادر
  FUNCTION parties_json(p_q IN VARCHAR2) RETURN CLOB;
  -- مسودة لإعادة فتحها في نافذة الإنشاء
  FUNCTION draft_json(p_id IN NUMBER) RETURN CLOB;
  -- مستلمو الرد: كاتب الرسالة (أو مستلموها إن كنت كاتبها)، وعلى الكل: بقية المستلمين نسخة
  FUNCTION reply_seed_json(p_id IN NUMBER, p_all IN VARCHAR2 DEFAULT 'N') RETURN CLOB;

  -- حفظ مسودة / إرسال (JSON: id,kind,type,to[],cc[],bcc[],subject,body,priority,instr,due,parent,rel,ext_no,letter_date,party,party_id,conf)
  FUNCTION save_draft(p_doc IN CLOB) RETURN NUMBER;
  FUNCTION send(p_doc IN CLOB) RETURN NUMBER;
  PROCEDURE delete_draft(p_id IN NUMBER);

  -- المرفقات (للمسودة فقط)
  FUNCTION attach(p_id IN NUMBER, p_file_name IN VARCHAR2, p_mime IN VARCHAR2, p_content IN BLOB) RETURN NUMBER;
  PROCEDURE remove_attachment(p_id IN NUMBER, p_document_id IN NUMBER);
  PROCEDURE download(p_id IN NUMBER, p_document_id IN NUMBER, p_mode IN VARCHAR2 DEFAULT 'VIEW');

  -- إجراءات المستخدم على السلسلة (p_id أي رسالة فيها)
  PROCEDURE set_star(p_id IN NUMBER, p_on IN VARCHAR2);
  PROCEDURE archive_thread(p_id IN NUMBER);
  PROCEDURE restore_thread(p_id IN NUMBER);
  PROCEDURE mark_unread(p_id IN NUMBER);
  -- على الرسالة: تم الاطلاع (إقرار) / تم الإنجاز / إحالة
  PROCEDURE acknowledge(p_id IN NUMBER);
  PROCEDURE complete(p_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL);
  PROCEDURE refer(p_id IN NUMBER, p_member_id IN NUMBER, p_instruction IN VARCHAR2, p_due IN DATE DEFAULT NULL,
                  p_note IN VARCHAR2 DEFAULT NULL);

  FUNCTION unread_count RETURN NUMBER;
  -- نسخة الطباعة الرسمية (خطاب / مذكرة)
  FUNCTION letter_html(p_id IN NUMBER) RETURN CLOB;
END NOONA_COR_PKG;
/

CREATE OR REPLACE PACKAGE BODY NOONA_COR_PKG AS

  TYPE t_ids IS TABLE OF NUMBER;

  FUNCTION esc(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_UI_PKG.esc(p); END;
  FUNCTION jt(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN NOONA_CORE_PKG.json_text(p); END;

  FUNCTION me RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'MEMBERSHIP_ID'));
  END me;

  FUNCTION company RETURN NUMBER IS
  BEGIN
    RETURN TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'COMPANY_ID'));
  END company;

  FUNCTION can(p_perm VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN NOONA_SECURITY_PKG.has_permission(p_perm, company) = 'Y';
  END can;

  FUNCTION name_of(p_member NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(u.display_name) INTO l FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id WHERE m.id = p_member;
    RETURN NVL(l, '-');
  END name_of;

  FUNCTION initials(p_name VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN UPPER(SUBSTR(TRIM(p_name), 1, 1));
  END initials;

  FUNCTION date_label(p_ts TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS
    l_d DATE := CAST(p_ts AS DATE);
  BEGIN
    IF l_d IS NULL THEN RETURN NULL; END IF;
    IF TRUNC(l_d) = TRUNC(SYSDATE) THEN RETURN TO_CHAR(l_d, 'HH24:MI'); END IF;
    IF TRUNC(l_d) = TRUNC(SYSDATE) - 1 THEN RETURN 'أمس'; END IF;
    IF EXTRACT(YEAR FROM l_d) = EXTRACT(YEAR FROM SYSDATE) THEN
      RETURN TO_CHAR(l_d, 'FMDD') || ' ' || CASE TO_CHAR(l_d, 'MM')
        WHEN '01' THEN 'يناير' WHEN '02' THEN 'فبراير' WHEN '03' THEN 'مارس' WHEN '04' THEN 'أبريل'
        WHEN '05' THEN 'مايو' WHEN '06' THEN 'يونيو' WHEN '07' THEN 'يوليو' WHEN '08' THEN 'أغسطس'
        WHEN '09' THEN 'سبتمبر' WHEN '10' THEN 'أكتوبر' WHEN '11' THEN 'نوفمبر' ELSE 'ديسمبر' END;
    END IF;
    RETURN TO_CHAR(l_d, 'YYYY/MM/DD');
  END date_label;

  FUNCTION full_date(p_ts TIMESTAMP WITH LOCAL TIME ZONE) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_ts, 'YYYY-MM-DD HH24:MI');
  END full_date;

  FUNCTION kind_label(p_dir VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_dir WHEN 'INCOMING' THEN 'وارد' WHEN 'OUTGOING' THEN 'صادر' ELSE 'داخلي' END;
  END kind_label;

  FUNCTION priority_label(p VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p WHEN 'LOW' THEN 'منخفضة' WHEN 'HIGH' THEN 'مهمة' WHEN 'URGENT' THEN 'عاجلة' WHEN 'VERY_URGENT' THEN 'عاجلة جداً'
                  ELSE 'عادية' END;
  END priority_label;

  FUNCTION cor_row(p_id NUMBER) RETURN cor_correspondence%ROWTYPE IS
    l cor_correspondence%ROWTYPE;
  BEGIN
    SELECT * INTO l FROM cor_correspondence WHERE id = p_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-COR-001', 'المراسلة غير موجودة', 'Correspondence not found');
  END cor_row;

  FUNCTION thread_of(p_id NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT NVL(thread_id, id) INTO l FROM cor_correspondence WHERE id = p_id;
    RETURN l;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NOONA_CORE_PKG.raise_error('NOONA-COR-001', 'المراسلة غير موجودة', 'Correspondence not found');
  END thread_of;

  FUNCTION my_rid(p_id IN NUMBER) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MIN(id) INTO l FROM cor_recipient WHERE correspondence_id = p_id AND membership_id = me;
    RETURN l;
  END my_rid;

  -- يطلع على الرسالة: كاتبها أو أحد مستلميها، أو صاحب صلاحية سجل الوارد والصادر لخطابات شركته
  FUNCTION can_see(p_c cor_correspondence%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    IF p_c.author_member_id = me THEN RETURN TRUE; END IF;
    IF p_c.status_code = 'DRAFT' THEN RETURN FALSE; END IF;
    IF my_rid(p_c.id) IS NOT NULL THEN RETURN TRUE; END IF;
    RETURN p_c.direction <> 'INTERNAL' AND p_c.company_id = company AND can('COR_CORRESPONDENCE.VIEW');
  END can_see;

  PROCEDURE assert_see(p_c cor_correspondence%ROWTYPE) IS
  BEGIN
    NOONA_CORE_PKG.assert(can_see(p_c), 'NOONA-COR-002', 'لا تملك صلاحية الاطلاع على هذه المراسلة',
      'You are not a party to this correspondence');
  END assert_see;

  PROCEDURE event(p_rid NUMBER, p_code VARCHAR2, p_info VARCHAR2 DEFAULT NULL) IS
  BEGIN
    INSERT INTO cor_recipient_event (recipient_id, event_code, actor_member_id, event_info)
    VALUES (p_rid, p_code, me, p_info);
  END event;

  PROCEDURE notify(p_member NUMBER, p_id NUMBER, p_title VARCHAR2, p_due TIMESTAMP WITH LOCAL TIME ZONE, p_key VARCHAR2) IS
    l_evt NUMBER;
  BEGIN
    SELECT MIN(id) INTO l_evt FROM ntf_event_type WHERE code = 'COR_RECEIVED';
    IF l_evt IS NULL OR p_member = me THEN RETURN; END IF;
    INSERT INTO ntf_notification (event_type_id, membership_id, source_entity_type, source_entity_id, title, link_url,
                                  idempotency_key, due_at, correlation_id)
    VALUES (l_evt, p_member, 'COR_CORRESPONDENCE', p_id, SUBSTR(p_title, 1, 500),
            'f?p=NOONA_DOC:MAIL:::NO::P50_OPEN:' || p_id, SUBSTR(p_key, 1, 200), p_due, NOONA_CTX_PKG.correlation_id);
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
  END notify;

  FUNCTION instruction_id(p_code VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    IF p_code IS NULL THEN RETURN NULL; END IF;
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END, version_no DESC)
      INTO l FROM cor_instruction WHERE code = p_code AND is_active = 'Y';
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-COR-003', 'التعليمة غير معرفة: ' || p_code, 'Unknown instruction');
    RETURN l;
  END instruction_id;

  FUNCTION instruction_name(p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(name_ar) INTO l FROM cor_instruction WHERE id = p_id;
    RETURN l;
  END instruction_name;

  -- التعليمة تتطلب إجراء (غير «للعلم» و«للحفظ»)
  FUNCTION is_task(p_instruction_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(50);
  BEGIN
    IF p_instruction_id IS NULL THEN RETURN 'N'; END IF;
    SELECT MAX(code) INTO l FROM cor_instruction WHERE id = p_instruction_id;
    RETURN CASE WHEN l IN ('FYI', 'FILE') OR l IS NULL THEN 'N' ELSE 'Y' END;
  END is_task;

  FUNCTION type_id(p_code VARCHAR2, p_kind VARCHAR2) RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT MAX(id) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END)
      INTO l FROM cor_type
     WHERE is_active = 'Y' AND direction = p_kind
       AND code = NVL(p_code, CASE p_kind WHEN 'INCOMING' THEN 'INCOMING_LETTER' WHEN 'OUTGOING' THEN 'OUTGOING_LETTER'
                                         ELSE 'INTERNAL_MEMO' END);
    NOONA_CORE_PKG.assert(l IS NOT NULL, 'NOONA-COR-004', 'نوع المراسلة غير معرف', 'Unknown correspondence type');
    RETURN l;
  END type_id;

  FUNCTION attachments(p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(32767) := '[';
  BEGIN
    FOR a IN (SELECT d.id, c.file_name, c.file_size_bytes, c.detected_mime
                FROM dms_document_link k JOIN dms_document d ON d.id = k.document_id
                JOIN dms_document_version v ON v.id = d.current_version_id JOIN dms_file_content c ON c.id = v.content_id
               WHERE k.entity_type = 'COR_CORRESPONDENCE' AND k.entity_id = p_id AND k.status_code = 'ACTIVE'
               ORDER BY k.id) LOOP
      l := l || CASE WHEN l <> '[' THEN ',' END || '{"d":' || a.id || ',"n":' || jt(a.file_name) || ',"s":'
             || jt(CASE WHEN a.file_size_bytes < 1048576 THEN CEIL(a.file_size_bytes / 1024) || ' KB'
                        ELSE ROUND(a.file_size_bytes / 1048576, 1) || ' MB' END) || ',"m":' || jt(a.detected_mime) || '}';
    END LOOP;
    RETURN l || ']';
  END attachments;

  FUNCTION addressees(p_id NUMBER, p_role VARCHAR2, p_with_ids BOOLEAN DEFAULT FALSE) RETURN VARCHAR2 IS
    l VARCHAR2(32767) := '[';
  BEGIN
    FOR a IN (SELECT target_type, target_id, target_name_snapshot FROM cor_addressee
               WHERE correspondence_id = p_id AND addressee_role = p_role ORDER BY sort_order, id) LOOP
      l := l || CASE WHEN l <> '[' THEN ',' END
             || CASE WHEN p_with_ids THEN '{"k":' || jt(CASE a.target_type WHEN 'ORG_UNIT' THEN 'O' ELSE 'U' END)
                                         || ',"id":' || a.target_id || ',"n":' || jt(a.target_name_snapshot) || '}'
                     ELSE jt(a.target_name_snapshot) END;
    END LOOP;
    RETURN l || ']';
  END addressees;

  FUNCTION party_name(p_id NUMBER) RETURN VARCHAR2 IS
    l VARCHAR2(400);
  BEGIN
    SELECT MAX(name_snapshot) INTO l FROM cor_party WHERE correspondence_id = p_id AND party_role IN ('SENDER', 'RECIPIENT');
    RETURN l;
  END party_name;

  FUNCTION snippet(p_body CLOB) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(REGEXP_REPLACE(DBMS_LOB.SUBSTR(p_body, 300, 1), '\s+', ' '), 1, 160);
  END snippet;

  -- ================================================================ بيانات الواجهة
  FUNCTION meta_json RETURN CLOB IS
    l_out CLOB;
    l_n   VARCHAR2(400) := name_of(me);
    l_s   VARCHAR2(32767) := '[';
  BEGIN
    l_out := '{"me":{"id":' || NVL(TO_CHAR(me), 'null') || ',"n":' || jt(l_n) || ',"i":' || jt(initials(l_n)) || '}'
          || ',"canReg":' || jt(CASE WHEN can('COR_CORRESPONDENCE.CREATE') THEN 'Y' ELSE 'N' END)
          || ',"canView":' || jt(CASE WHEN can('COR_CORRESPONDENCE.VIEW') THEN 'Y' ELSE 'N' END);
    FOR i IN (SELECT code, MAX(name_ar) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) n,
                     MIN(sort_order) o
                FROM cor_instruction WHERE is_active = 'Y' GROUP BY code ORDER BY 3, 1) LOOP
      l_s := l_s || CASE WHEN l_s <> '[' THEN ',' END || '{"c":' || jt(i.code) || ',"n":' || jt(i.n) || '}';
    END LOOP;
    l_out := l_out || ',"instr":' || l_s || ']';
    l_s := '[';
    FOR t IN (SELECT code, MAX(name_ar) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN tenant_id IS NULL THEN 1 ELSE 0 END) n,
                     MAX(direction) k
                FROM cor_type WHERE is_active = 'Y' GROUP BY code
               ORDER BY CASE WHEN code IN ('INTERNAL_MEMO', 'INCOMING_LETTER', 'OUTGOING_LETTER') THEN 0 ELSE 1 END, 1) LOOP
      l_s := l_s || CASE WHEN l_s <> '[' THEN ',' END || '{"c":' || jt(t.code) || ',"n":' || jt(t.n) || ',"k":' || jt(t.k) || '}';
    END LOOP;
    RETURN l_out || ',"types":' || l_s || ']}';
  END meta_json;

  FUNCTION unread_count RETURN NUMBER IS
    l NUMBER;
  BEGIN
    SELECT COUNT(DISTINCT NVL(c.thread_id, c.id)) INTO l
      FROM cor_recipient r JOIN cor_correspondence c ON c.id = r.correspondence_id
     WHERE r.membership_id = me AND r.read_status = 'UNREAD' AND r.view_status <> 'ARCHIVED'
       AND c.status_code NOT IN ('DRAFT', 'CANCELLED');
    RETURN l;
  END unread_count;

  FUNCTION folders_json RETURN CLOB IS
    l_tasks NUMBER;
    l_dr    NUMBER;
  BEGIN
    SELECT COUNT(*) INTO l_tasks
      FROM cor_recipient r JOIN cor_correspondence c ON c.id = r.correspondence_id
      JOIN cor_instruction i ON i.id = r.instruction_id
     WHERE r.membership_id = me AND r.action_status IN ('NONE', 'ACKNOWLEDGED') AND i.code NOT IN ('FYI', 'FILE')
       AND c.status_code NOT IN ('DRAFT', 'CANCELLED');
    SELECT COUNT(*) INTO l_dr FROM cor_correspondence WHERE author_member_id = me AND status_code = 'DRAFT';
    RETURN '{"INBOX":' || unread_count || ',"TASKS":' || l_tasks || ',"DRAFTS":' || l_dr || '}';
  END folders_json;

  -- ================================================================ القوائم
  FUNCTION list_json(p_folder IN VARCHAR2, p_q IN VARCHAR2 DEFAULT NULL, p_offset IN NUMBER DEFAULT 0) RETURN CLOB IS
    l_out   CLOB := '{"rows":[';
    l_me    NUMBER := me;
    l_f     VARCHAR2(30) := UPPER(NVL(p_folder, 'INBOX'));
    l_q     VARCHAR2(400) := UPPER(TRIM(p_q));
    l_off   NUMBER := NVL(p_offset, 0);
    l_first BOOLEAN := TRUE;
    l_more  VARCHAR2(1) := 'N';
    l_c     cor_correspondence%ROWTYPE;
    l_who   VARCHAR2(4000);
    l_att   NUMBER;
    l_row   VARCHAR2(32767);
    l_subj  VARCHAR2(1000);
  BEGIN
    IF l_f = 'DRAFTS' THEN
      FOR d IN (SELECT * FROM (
                  SELECT c.id, c.subject, c.body_text, c.direction, NVL(c.updated_at, c.created_at) ts_at,
                         ROW_NUMBER() OVER (ORDER BY NVL(c.updated_at, c.created_at) DESC) rn
                    FROM cor_correspondence c
                   WHERE c.author_member_id = l_me AND c.status_code = 'DRAFT'
                     AND (l_q IS NULL OR UPPER(c.subject) LIKE '%' || l_q || '%'))
                 WHERE rn > l_off AND rn <= l_off + 51) LOOP
        IF d.rn = l_off + 51 THEN l_more := 'Y'; EXIT; END IF;
        SELECT LISTAGG(target_name_snapshot, '، ') WITHIN GROUP (ORDER BY sort_order, id) INTO l_who
          FROM (SELECT target_name_snapshot, sort_order, id FROM cor_addressee
                 WHERE correspondence_id = d.id AND addressee_role = 'TO' AND ROWNUM <= 3);
        l_out := l_out || (CASE WHEN NOT l_first THEN ',' END || '{"id":' || d.id || ',"t":' || d.id || ',"draft":"Y"'
              || ',"who":' || jt(NVL(l_who, '(بدون مستلم)')) || ',"s":' || jt(d.subject) || ',"sn":' || jt(snippet(d.body_text))
              || ',"d":' || jt(date_label(d.ts_at)) || ',"k":' || jt(d.direction) || ',"u":"N","st":"N","n":1}');
        l_first := FALSE;
      END LOOP;
      RETURN l_out || '],"more":' || jt(l_more) || '}';
    END IF;

    IF l_f IN ('INCOMING', 'OUTGOING') THEN
      NOONA_CORE_PKG.assert(can('COR_CORRESPONDENCE.VIEW'), 'NOONA-COR-005', 'سجل الوارد والصادر يتطلب صلاحية عرض المراسلات',
        'Viewing the registers requires COR_CORRESPONDENCE.VIEW');
      FOR d IN (SELECT * FROM (
                  SELECT c.id, NVL(c.thread_id, c.id) tid, c.subject, c.body_text, c.correspondence_no, c.external_no,
                         c.letter_date, c.priority_code, NVL(c.sent_at, NVL(c.received_at, c.created_at)) ts_at,
                         ROW_NUMBER() OVER (ORDER BY NVL(c.sent_at, NVL(c.received_at, c.created_at)) DESC, c.id DESC) rn
                    FROM cor_correspondence c
                   WHERE c.company_id = company AND c.direction = l_f AND c.status_code NOT IN ('DRAFT', 'CANCELLED')
                     AND (l_q IS NULL OR UPPER(c.subject) LIKE '%' || l_q || '%' OR UPPER(c.correspondence_no) LIKE '%' || l_q || '%'
                          OR UPPER(c.external_no) LIKE '%' || l_q || '%'
                          OR EXISTS (SELECT 1 FROM cor_party p WHERE p.correspondence_id = c.id
                                        AND UPPER(p.name_snapshot) LIKE '%' || l_q || '%')))
                 WHERE rn > l_off AND rn <= l_off + 51) LOOP
        IF d.rn = l_off + 51 THEN l_more := 'Y'; EXIT; END IF;
        SELECT COUNT(*) INTO l_att FROM dms_document_link
         WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = d.id AND status_code = 'ACTIVE';
        l_out := l_out || (CASE WHEN NOT l_first THEN ',' END || '{"id":' || d.id || ',"t":' || d.tid
              || ',"who":' || jt(party_name(d.id)) || ',"s":' || jt(d.subject) || ',"sn":' || jt(snippet(d.body_text))
              || ',"d":' || jt(date_label(d.ts_at)) || ',"no":' || jt(d.correspondence_no) || ',"ext":' || jt(d.external_no)
              || ',"k":' || jt(l_f) || ',"p":' || jt(d.priority_code) || ',"a":' || jt(CASE WHEN l_att > 0 THEN 'Y' ELSE 'N' END)
              || ',"u":"N","st":"N","n":1}');
        l_first := FALSE;
      END LOOP;
      RETURN l_out || '],"more":' || jt(l_more) || '}';
    END IF;

    FOR t IN (SELECT * FROM (
                SELECT g.*, ROW_NUMBER() OVER (ORDER BY g.last_at DESC, g.tid DESC) rn FROM (
                  SELECT v.tid, MAX(v.ts_at) last_at, COUNT(*) n,
                         MAX(CASE WHEN v.rid IS NOT NULL AND v.read_status = 'UNREAD' THEN 1 ELSE 0 END) unread,
                         MAX(CASE WHEN v.is_starred = 'Y' OR (v.author_member_id = l_me AND v.author_starred = 'Y') THEN 1 ELSE 0 END) star,
                         MAX(CASE WHEN v.rid IS NOT NULL AND v.view_status <> 'ARCHIVED' THEN 1 ELSE 0 END) active_in,
                         MAX(CASE WHEN v.rid IS NOT NULL THEN 1 ELSE 0 END) has_in,
                         MAX(CASE WHEN v.author_member_id = l_me THEN 1 ELSE 0 END) mine,
                         MAX(CASE WHEN v.task = 'Y' AND v.action_status IN ('NONE', 'ACKNOWLEDGED') THEN 1 ELSE 0 END) open_task,
                         MIN(CASE WHEN v.task = 'Y' AND v.action_status IN ('NONE', 'ACKNOWLEDGED') THEN v.due_at END) due_at,
                         MAX(CASE WHEN l_q IS NULL OR v.hit = 1 THEN 1 ELSE 0 END) hit
                    FROM (SELECT c.id, NVL(c.thread_id, c.id) tid, c.author_member_id, c.author_starred,
                                 NVL(c.sent_at, NVL(c.received_at, c.created_at)) ts_at,
                                 r.id rid, r.read_status, r.view_status, r.is_starred, r.action_status, r.due_at,
                                 CASE WHEN i.code IS NOT NULL AND i.code NOT IN ('FYI', 'FILE') THEN 'Y' ELSE 'N' END task,
                                 CASE WHEN l_q IS NOT NULL AND (UPPER(c.subject) LIKE '%' || l_q || '%'
                                           OR UPPER(c.correspondence_no) LIKE '%' || l_q || '%'
                                           OR UPPER(DBMS_LOB.SUBSTR(c.body_text, 2000, 1)) LIKE '%' || l_q || '%')
                                      THEN 1 ELSE 0 END hit
                            FROM cor_correspondence c
                            LEFT JOIN cor_recipient r ON r.correspondence_id = c.id AND r.membership_id = l_me
                            LEFT JOIN cor_instruction i ON i.id = r.instruction_id
                           WHERE c.status_code NOT IN ('DRAFT', 'CANCELLED')
                             AND (c.author_member_id = l_me OR r.id IS NOT NULL)) v
                   GROUP BY v.tid) g
                 WHERE g.hit = 1
                   AND ((l_f = 'INBOX' AND g.active_in = 1)
                     OR (l_f = 'TASKS' AND g.open_task = 1)
                     OR (l_f = 'STARRED' AND g.star = 1)
                     OR (l_f = 'SENT' AND g.mine = 1)
                     OR (l_f = 'ARCHIVE' AND g.has_in = 1 AND g.active_in = 0)
                     OR l_f = 'ALL'))
               WHERE rn > l_off AND rn <= l_off + 51) LOOP
      IF t.rn = l_off + 51 THEN l_more := 'Y'; EXIT; END IF;
      -- آخر رسالة ظاهرة لي في السلسلة
      SELECT * INTO l_c FROM (
        SELECT c.* FROM cor_correspondence c
         WHERE NVL(c.thread_id, c.id) = t.tid AND c.status_code NOT IN ('DRAFT', 'CANCELLED')
           AND (c.author_member_id = l_me OR EXISTS (SELECT 1 FROM cor_recipient r WHERE r.correspondence_id = c.id
                                                        AND r.membership_id = l_me))
         ORDER BY NVL(c.sent_at, NVL(c.received_at, c.created_at)) DESC, c.id DESC)
       WHERE ROWNUM = 1;
      IF l_f = 'SENT' OR (l_c.author_member_id = l_me AND t.has_in = 0) THEN
        SELECT 'إلى: ' || LISTAGG(target_name_snapshot, '، ') WITHIN GROUP (ORDER BY sort_order, id) INTO l_who
          FROM (SELECT target_name_snapshot, sort_order, id FROM cor_addressee
                 WHERE correspondence_id = l_c.id AND addressee_role IN ('TO', 'CC') AND ROWNUM <= 3);
        IF l_c.direction = 'OUTGOING' THEN l_who := 'إلى: ' || party_name(l_c.id); END IF;
      ELSE
        -- أطراف السلسلة (الكتّاب) كما في Gmail
        SELECT LISTAGG(nm, '، ') WITHIN GROUP (ORDER BY first_at) INTO l_who
          FROM (SELECT nm, MIN(ts_at) first_at FROM (
                  SELECT NVL(c.sent_at, NVL(c.received_at, c.created_at)) ts_at,
                         CASE WHEN c.direction = 'INCOMING' THEN NVL(
                           (SELECT MAX(p.name_snapshot) FROM cor_party p WHERE p.correspondence_id = c.id AND p.party_role = 'SENDER'), '-')
                              WHEN c.author_member_id = l_me THEN 'أنا'
                              ELSE (SELECT u.display_name FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
                                     WHERE m.id = c.author_member_id) END nm
                    FROM cor_correspondence c
                   WHERE NVL(c.thread_id, c.id) = t.tid AND c.status_code NOT IN ('DRAFT', 'CANCELLED'))
                 GROUP BY nm
                 ORDER BY 2)
         WHERE ROWNUM <= 3;
      END IF;
      SELECT COUNT(*) INTO l_att FROM dms_document_link k JOIN cor_correspondence c ON c.id = k.entity_id
       WHERE k.entity_type = 'COR_CORRESPONDENCE' AND k.status_code = 'ACTIVE' AND NVL(c.thread_id, c.id) = t.tid;
      -- عنوان المحادثة موضوع أول رسالة فيها (كما في Gmail)
      SELECT MAX(subject) INTO l_subj FROM cor_correspondence WHERE id = t.tid;
      l_row := '{"id":' || l_c.id || ',"t":' || t.tid || ',"who":' || jt(l_who) || ',"s":' || jt(NVL(l_subj, l_c.subject))
            || ',"sn":' || jt(snippet(l_c.body_text)) || ',"d":' || jt(date_label(t.last_at)) || ',"n":' || t.n
            || ',"u":' || jt(CASE WHEN t.unread = 1 THEN 'Y' ELSE 'N' END) || ',"st":' || jt(CASE WHEN t.star = 1 THEN 'Y' ELSE 'N' END)
            || ',"a":' || jt(CASE WHEN l_att > 0 THEN 'Y' ELSE 'N' END) || ',"k":' || jt(l_c.direction)
            || ',"p":' || jt(l_c.priority_code) || ',"no":' || jt(l_c.correspondence_no)
            || ',"task":' || jt(CASE WHEN t.open_task = 1 THEN 'Y' ELSE 'N' END)
            || ',"due":' || jt(CASE WHEN t.due_at IS NOT NULL THEN TO_CHAR(t.due_at, 'YYYY-MM-DD') END)
            || ',"late":' || jt(CASE WHEN t.due_at < SYSTIMESTAMP THEN 'Y' ELSE 'N' END) || '}';
      l_out := l_out || (CASE WHEN NOT l_first THEN ',' END || l_row);
      l_first := FALSE;
    END LOOP;
    RETURN l_out || '],"more":' || jt(l_more) || '}';
  END list_json;

  -- ================================================================ السلسلة
  FUNCTION thread_json(p_id IN NUMBER) RETURN CLOB IS
    l_tid   NUMBER := thread_of(p_id);
    l_root  cor_correspondence%ROWTYPE := cor_row(l_tid);
    l_me    NUMBER := me;
    l_out   CLOB;
    l_first BOOLEAN := TRUE;
    l_star  VARCHAR2(1) := 'N';
    l_act   VARCHAR2(1) := 'N';
    l_r     cor_recipient%ROWTYPE;
    l_from  VARCHAR2(400);
    l_refs  VARCHAR2(32767);
    l_any   BOOLEAN := FALSE;
    l_reg   BOOLEAN := can('COR_CORRESPONDENCE.VIEW');
    l_typ   VARCHAR2(200);
    l_none  cor_recipient%ROWTYPE;
  BEGIN
    l_out := '{"tid":' || l_tid || ',"msgs":[';
    FOR c IN (SELECT * FROM cor_correspondence c
               WHERE NVL(c.thread_id, c.id) = l_tid AND c.status_code NOT IN ('DRAFT', 'CANCELLED')
               ORDER BY NVL(c.sent_at, NVL(c.received_at, c.created_at)), c.id) LOOP
      CONTINUE WHEN NOT (c.author_member_id = l_me OR my_rid(c.id) IS NOT NULL
                         OR (l_reg AND c.direction <> 'INTERNAL' AND c.company_id = company));
      l_any := TRUE;
      l_r := l_none;
      IF my_rid(c.id) IS NOT NULL THEN
        SELECT * INTO l_r FROM cor_recipient WHERE id = my_rid(c.id);
        IF l_r.is_starred = 'Y' THEN l_star := 'Y'; END IF;
        IF l_r.view_status <> 'ARCHIVED' THEN l_act := 'Y'; END IF;
      END IF;
      IF c.author_member_id = l_me AND c.author_starred = 'Y' THEN l_star := 'Y'; END IF;
      SELECT MAX(name_ar) INTO l_typ FROM cor_type WHERE id = c.cor_type_id;
      l_from := CASE WHEN c.direction = 'INCOMING' THEN NVL(party_name(c.id), '-') ELSE name_of(c.author_member_id) END;
      l_refs := '[';
      FOR f IN (SELECT ci.from_member_id, ci.to_member_id, ci.instruction_id, ci.due_at, ci.entered_at, ci.status_code,
                       (SELECT MAX(n.note_text) FROM cor_circulation_note n WHERE n.circulation_id = ci.id) note
                  FROM cor_circulation ci WHERE ci.correspondence_id = c.id ORDER BY ci.id) LOOP
        l_refs := l_refs || CASE WHEN l_refs <> '[' THEN ',' END || '{"f":' || jt(name_of(f.from_member_id))
               || ',"to":' || jt(name_of(f.to_member_id)) || ',"ins":' || jt(instruction_name(f.instruction_id))
               || ',"due":' || jt(TO_CHAR(f.due_at, 'YYYY-MM-DD')) || ',"at":' || jt(full_date(f.entered_at))
               || ',"note":' || jt(f.note) || ',"done":' || jt(CASE WHEN f.status_code = 'COMPLETED' THEN 'Y' ELSE 'N' END) || '}';
      END LOOP;
      l_out := l_out || (CASE WHEN NOT l_first THEN ',' END
            || '{"id":' || c.id || ',"from":' || jt(l_from) || ',"fi":' || jt(initials(l_from))
            || ',"mine":' || jt(CASE WHEN c.author_member_id = l_me THEN 'Y' ELSE 'N' END)
            || ',"by":' || jt(CASE WHEN c.direction = 'INCOMING' THEN 'سجله ' || name_of(c.author_member_id) END)
            || ',"to":' || addressees(c.id, 'TO') || ',"cc":' || addressees(c.id, 'CC')
            || ',"bcc":' || CASE WHEN c.author_member_id = l_me THEN addressees(c.id, 'BCC') ELSE '[]' END
            || ',"meBcc":' || jt(CASE WHEN l_r.recipient_role = 'BCC' THEN 'Y' ELSE 'N' END)
            || ',"at":' || jt(full_date(NVL(c.sent_at, NVL(c.received_at, c.created_at))))
            || ',"al":' || jt(date_label(NVL(c.sent_at, NVL(c.received_at, c.created_at))))
            || ',"no":' || jt(c.correspondence_no) || ',"k":' || jt(c.direction) || ',"kl":' || jt(kind_label(c.direction))
            || ',"typ":' || jt(l_typ)
            || ',"p":' || jt(c.priority_code) || ',"pl":' || jt(priority_label(c.priority_code))
            || ',"ext":' || jt(c.external_no) || ',"ld":' || jt(TO_CHAR(c.letter_date, 'YYYY-MM-DD'))
            || ',"party":' || jt(party_name(c.id))
            || ',"body":' || jt(DBMS_LOB.SUBSTR(c.body_text, 30000, 1))
            || ',"att":' || attachments(c.id) || ',"refs":' || l_refs || ']'
            || ',"my":' || CASE WHEN l_r.id IS NULL THEN 'null' ELSE
                 '{"ins":' || jt(instruction_name(l_r.instruction_id)) || ',"task":' || jt(is_task(l_r.instruction_id))
                 || ',"due":' || jt(TO_CHAR(l_r.due_at, 'YYYY-MM-DD'))
                 || ',"late":' || jt(CASE WHEN l_r.due_at < SYSTIMESTAMP AND l_r.action_status IN ('NONE', 'ACKNOWLEDGED') THEN 'Y' ELSE 'N' END)
                 || ',"act":' || jt(l_r.action_status) || ',"unread":' || jt(CASE WHEN l_r.read_status = 'UNREAD' THEN 'Y' ELSE 'N' END)
                 || '}' END
            || '}');
      l_first := FALSE;
    END LOOP;
    NOONA_CORE_PKG.assert(l_any, 'NOONA-COR-002', 'لا تملك صلاحية الاطلاع على هذه المراسلة', 'You are not a party to this correspondence');
    -- القراءة الفعلية
    FOR r IN (SELECT r.id FROM cor_recipient r JOIN cor_correspondence c ON c.id = r.correspondence_id
               WHERE r.membership_id = l_me AND r.read_status = 'UNREAD' AND NVL(c.thread_id, c.id) = l_tid) LOOP
      UPDATE cor_recipient SET read_status = 'READ', first_read_at = NVL(first_read_at, SYSTIMESTAMP), last_read_at = SYSTIMESTAMP
       WHERE id = r.id;
      event(r.id, 'OPENED');
    END LOOP;
    UPDATE ntf_notification SET read_at = NVL(read_at, SYSTIMESTAMP)
     WHERE membership_id = l_me AND source_entity_type = 'COR_CORRESPONDENCE' AND read_at IS NULL
       AND source_entity_id IN (SELECT id FROM cor_correspondence WHERE NVL(thread_id, id) = l_tid);
    RETURN l_out || '],"subject":' || jt(l_root.subject) || ',"star":' || jt(l_star) || ',"inbox":' || jt(l_act) || '}';
  END thread_json;

  -- ================================================================ الدليل
  FUNCTION directory_json(p_q IN VARCHAR2) RETURN CLOB IS
    l_out CLOB := '[';
    l_q   VARCHAR2(200) := UPPER(TRIM(p_q));
    l_n   PLS_INTEGER := 0;
  BEGIN
    FOR u IN (SELECT * FROM (
                SELECT m.id, u.display_name, NVL(u.email, u.username) e
                  FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
                 WHERE m.status_code = 'ACTIVE' AND m.tenant_id = TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'TENANT_ID'))
                   AND (l_q IS NULL OR UPPER(u.display_name) LIKE '%' || l_q || '%' OR UPPER(u.username) LIKE '%' || l_q || '%'
                        OR UPPER(u.email) LIKE '%' || l_q || '%')
                 ORDER BY u.display_name) WHERE ROWNUM <= 12) LOOP
      l_out := l_out || (CASE WHEN l_n > 0 THEN ',' END || '{"k":"U","id":' || u.id || ',"n":' || jt(u.display_name)
            || ',"e":' || jt(u.e) || ',"i":' || jt(initials(u.display_name)) || '}');
      l_n := l_n + 1;
    END LOOP;
    FOR o IN (SELECT * FROM (
                SELECT id, name_ar FROM org_unit
                 WHERE company_id = company AND status_code = 'ACTIVE' AND receives_correspondence = 'Y'
                   AND (l_q IS NULL OR UPPER(name_ar) LIKE '%' || l_q || '%' OR UPPER(code) LIKE '%' || l_q || '%')
                 ORDER BY name_ar) WHERE ROWNUM <= 8) LOOP
      l_out := l_out || (CASE WHEN l_n > 0 THEN ',' END || '{"k":"O","id":' || o.id || ',"n":' || jt(o.name_ar)
            || ',"e":"وحدة تنظيمية","i":"#"}');
      l_n := l_n + 1;
    END LOOP;
    RETURN l_out || ']';
  END directory_json;

  FUNCTION parties_json(p_q IN VARCHAR2) RETURN CLOB IS
    l_out CLOB := '[';
    l_q   VARCHAR2(200) := UPPER(TRIM(p_q));
    l_n   PLS_INTEGER := 0;
  BEGIN
    FOR p IN (SELECT * FROM (
                SELECT id, display_name_ar FROM pty_party
                 WHERE l_q IS NOT NULL AND (UPPER(display_name_ar) LIKE '%' || l_q || '%' OR UPPER(party_no) LIKE '%' || l_q || '%')
                 ORDER BY display_name_ar) WHERE ROWNUM <= 10) LOOP
      l_out := l_out || (CASE WHEN l_n > 0 THEN ',' END || '{"id":' || p.id || ',"n":' || jt(p.display_name_ar) || '}');
      l_n := l_n + 1;
    END LOOP;
    RETURN l_out || ']';
  END parties_json;

  FUNCTION draft_json(p_id IN NUMBER) RETURN CLOB IS
    l_c cor_correspondence%ROWTYPE := cor_row(p_id);
    l_t VARCHAR2(50);
    l_i VARCHAR2(50);
    l_p cor_party%ROWTYPE;
  BEGIN
    NOONA_CORE_PKG.assert(l_c.author_member_id = me AND l_c.status_code = 'DRAFT', 'NOONA-COR-006',
      'المسودة غير موجودة أو ليست لك', 'Draft not found');
    SELECT MAX(code) INTO l_t FROM cor_type WHERE id = l_c.cor_type_id;
    SELECT MAX(i.code) INTO l_i FROM cor_addressee a JOIN cor_instruction i ON i.id = a.instruction_id
     WHERE a.correspondence_id = p_id AND a.addressee_role = 'TO';
    BEGIN
      SELECT * INTO l_p FROM cor_party WHERE correspondence_id = p_id AND party_role IN ('SENDER', 'RECIPIENT') AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    RETURN '{"id":' || p_id || ',"kind":' || jt(l_c.direction) || ',"type":' || jt(l_t)
        || ',"to":' || addressees(p_id, 'TO', TRUE) || ',"cc":' || addressees(p_id, 'CC', TRUE) || ',"bcc":' || addressees(p_id, 'BCC', TRUE)
        || ',"subject":' || jt(CASE WHEN l_c.subject = '(بدون موضوع)' THEN NULL ELSE l_c.subject END)
        || ',"body":' || jt(DBMS_LOB.SUBSTR(l_c.body_text, 30000, 1))
        || ',"priority":' || jt(l_c.priority_code) || ',"instr":' || jt(l_i) || ',"due":' || jt(TO_CHAR(l_c.due_at, 'YYYY-MM-DD'))
        || ',"parent":' || NVL(TO_CHAR(l_c.parent_id), 'null') || ',"rel":' || jt(l_c.relation_type)
        || ',"ext_no":' || jt(l_c.external_no) || ',"letter_date":' || jt(TO_CHAR(l_c.letter_date, 'YYYY-MM-DD'))
        || ',"party":' || jt(l_p.name_snapshot) || ',"party_id":' || NVL(TO_CHAR(l_p.party_id), 'null')
        || ',"conf":' || jt(l_c.confidentiality_level) || ',"att":' || attachments(p_id) || '}';
  END draft_json;

  FUNCTION reply_seed_json(p_id IN NUMBER, p_all IN VARCHAR2 DEFAULT 'N') RETURN CLOB IS
    l_c   cor_correspondence%ROWTYPE := cor_row(p_id);
    l_to  VARCHAR2(32767) := '[';
    l_cc  VARCHAR2(32767) := '[';
    l_me  NUMBER := me;
    PROCEDURE add(p_list IN OUT VARCHAR2, p_k VARCHAR2, p_id NUMBER, p_n VARCHAR2) IS
      l_item VARCHAR2(600) := '{"k":' || jt(p_k) || ',"id":' || p_id || ',"n":' || jt(p_n) || '}';
    BEGIN
      IF INSTR(l_to || l_cc, '"k":' || jt(p_k) || ',"id":' || p_id || ',') = 0 THEN
        p_list := p_list || CASE WHEN p_list <> '[' THEN ',' END || l_item;
      END IF;
    END add;
  BEGIN
    assert_see(l_c);
    IF l_c.author_member_id = l_me THEN
      FOR a IN (SELECT target_type, target_id, target_name_snapshot FROM cor_addressee
                 WHERE correspondence_id = p_id AND addressee_role = 'TO' ORDER BY sort_order) LOOP
        add(l_to, CASE a.target_type WHEN 'ORG_UNIT' THEN 'O' ELSE 'U' END, a.target_id, a.target_name_snapshot);
      END LOOP;
    ELSIF l_c.direction <> 'INCOMING' THEN
      add(l_to, 'U', l_c.author_member_id, name_of(l_c.author_member_id));
    END IF;
    IF p_all = 'Y' THEN
      FOR a IN (SELECT target_type, target_id, target_name_snapshot FROM cor_addressee
                 WHERE correspondence_id = p_id AND addressee_role IN ('TO', 'CC')
                   AND NOT (target_type = 'USER' AND target_id = l_me) ORDER BY sort_order) LOOP
        add(l_cc, CASE a.target_type WHEN 'ORG_UNIT' THEN 'O' ELSE 'U' END, a.target_id, a.target_name_snapshot);
      END LOOP;
    END IF;
    RETURN '{"to":' || l_to || '],"cc":' || l_cc || ']}';
  END reply_seed_json;

  -- ================================================================ الإنشاء والإرسال
  FUNCTION save_draft(p_doc IN CLOB) RETURN NUMBER IS
    l_o      JSON_OBJECT_T := JSON_OBJECT_T.parse(p_doc);
    l_id     NUMBER := l_o.get_number('id');
    l_kind   VARCHAR2(30) := NVL(UPPER(l_o.get_string('kind')), 'INTERNAL');
    l_type   NUMBER;
    l_parent cor_correspondence%ROWTYPE;
    l_pid    NUMBER := l_o.get_number('parent');
    l_rel    VARCHAR2(30) := UPPER(l_o.get_string('rel'));
    l_subj   VARCHAR2(1000) := SUBSTR(TRIM(l_o.get_string('subject')), 1, 1000);
    l_body   CLOB := l_o.get_clob('body');
    l_prio   VARCHAR2(30) := NVL(UPPER(l_o.get_string('priority')), 'NORMAL');
    l_ins    NUMBER := instruction_id(l_o.get_string('instr'));
    l_due    DATE := TO_DATE(l_o.get_string('due'), 'YYYY-MM-DD');
    l_ld     DATE := TO_DATE(l_o.get_string('letter_date'), 'YYYY-MM-DD');
    l_party  VARCHAR2(400) := SUBSTR(TRIM(l_o.get_string('party')), 1, 400);
    l_pty    NUMBER := l_o.get_number('party_id');
    l_conf   VARCHAR2(30) := NVL(UPPER(l_o.get_string('conf')), 'INTERNAL');
    l_new    BOOLEAN := l_id IS NULL;
    l_arr    JSON_ARRAY_T;
    l_e      JSON_OBJECT_T;
    l_seq    PLS_INTEGER := 0;
    l_tid    NUMBER;
    l_tt     VARCHAR2(30);
    l_name   VARCHAR2(400);
    l_ext    VARCHAR2(100) := SUBSTR(TRIM(l_o.get_string('ext_no')), 1, 100);
    l_k      VARCHAR2(5);
    l_tg     NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    NOONA_CORE_PKG.assert(me IS NOT NULL AND company IS NOT NULL, 'NOONA-COR-007', 'سجل الدخول في شركة أولاً',
      'A company session is required');
    NOONA_CORE_PKG.assert(l_kind IN ('INTERNAL', 'INCOMING', 'OUTGOING'), 'NOONA-COR-008', 'نوع المراسلة غير صحيح', 'Invalid kind');
    NOONA_CORE_PKG.assert(l_kind = 'INTERNAL' OR can('COR_CORRESPONDENCE.CREATE'), 'NOONA-COR-009',
      'تسجيل الوارد والصادر يتطلب صلاحية إنشاء المراسلات', 'Registering incoming/outgoing letters requires COR_CORRESPONDENCE.CREATE');
    NOONA_CORE_PKG.assert(l_prio IN ('LOW', 'NORMAL', 'HIGH', 'URGENT', 'VERY_URGENT'), 'NOONA-COR-010', 'الأولوية غير صحيحة', 'Invalid priority');
    l_type := type_id(l_o.get_string('type'), l_kind);
    IF l_pid IS NOT NULL THEN
      l_parent := cor_row(l_pid);
      assert_see(l_parent);
      l_tid := NVL(l_parent.thread_id, l_parent.id);
    END IF;
    IF l_new THEN
      INSERT INTO cor_correspondence (company_id, branch_id, cor_type_id, direction, subject, body_text, language_code,
                                      author_member_id, letter_date, priority_code, due_at, inbound_channel, external_no,
                                      external_party_id, thread_id, parent_id, original_id, relation_type, confidentiality_level,
                                      status_code, correlation_id)
      VALUES (company, TO_NUMBER(SYS_CONTEXT('NOONA_CTX', 'BRANCH_ID')), l_type, l_kind, NVL(l_subj, '(بدون موضوع)'), l_body, 'ar',
              me, l_ld, l_prio, CAST(l_due + 1 - 1/86400 AS TIMESTAMP), CASE WHEN l_kind = 'INCOMING' THEN 'MANUAL' END,
              l_ext, l_pty, l_tid, l_pid,
              CASE WHEN l_rel = 'FORWARD' THEN l_pid END, CASE WHEN l_pid IS NOT NULL THEN NVL(l_rel, 'REPLY') END, l_conf,
              'DRAFT', NOONA_CTX_PKG.correlation_id)
      RETURNING id INTO l_id;
      -- التحويل يحمل مرفقات الرسالة الأصلية
      IF l_rel = 'FORWARD' AND l_pid IS NOT NULL THEN
        FOR a IN (SELECT document_id FROM dms_document_link
                   WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = l_pid AND status_code = 'ACTIVE') LOOP
          NOONA_DMS_PKG.system_link(a.document_id, 'COR_CORRESPONDENCE', l_id);
        END LOOP;
      END IF;
    ELSE
      DECLARE
        l_c cor_correspondence%ROWTYPE;
      BEGIN
        SELECT * INTO l_c FROM cor_correspondence WHERE id = l_id FOR UPDATE;
        NOONA_CORE_PKG.assert(l_c.author_member_id = me AND l_c.status_code = 'DRAFT', 'NOONA-COR-006',
          'المسودة غير موجودة أو ليست لك', 'Draft not found');
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NOONA_CORE_PKG.raise_error('NOONA-COR-006', 'المسودة غير موجودة أو ليست لك', 'Draft not found');
      END;
      UPDATE cor_correspondence
         SET cor_type_id = l_type, direction = l_kind, subject = NVL(l_subj, '(بدون موضوع)'), body_text = l_body,
             letter_date = l_ld, priority_code = l_prio, due_at = CAST(l_due + 1 - 1/86400 AS TIMESTAMP),
             inbound_channel = CASE WHEN l_kind = 'INCOMING' THEN 'MANUAL' END,
             external_no = l_ext, external_party_id = l_pty,
             confidentiality_level = l_conf
       WHERE id = l_id;
    END IF;
    IF l_tid IS NULL THEN
      UPDATE cor_correspondence SET thread_id = l_id WHERE id = l_id AND thread_id IS NULL;
    END IF;
    -- الجهات المخاطبة كما اختارها المرسل
    DELETE FROM cor_addressee WHERE correspondence_id = l_id;
    FOR k IN 1 .. 3 LOOP
      l_tt := CASE k WHEN 1 THEN 'TO' WHEN 2 THEN 'CC' ELSE 'BCC' END;
      l_arr := l_o.get_array(LOWER(l_tt));
      IF l_arr IS NOT NULL THEN
        FOR i IN 0 .. l_arr.get_size - 1 LOOP
          l_e := TREAT(l_arr.get(i) AS JSON_OBJECT_T);
          l_seq := l_seq + 1;
          l_k := NVL(l_e.get_string('k'), 'U');
          l_tg := l_e.get_number('id');
          IF l_k = 'O' THEN
            SELECT MAX(name_ar) INTO l_name FROM org_unit WHERE id = l_tg AND company_id = company;
            NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-COR-011', 'الوحدة التنظيمية غير موجودة في الشركة الحالية',
              'Organisation unit not found');
          ELSE
            SELECT MAX(u.display_name) INTO l_name FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
             WHERE m.id = l_tg AND m.status_code = 'ACTIVE';
            NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-COR-012', 'المستخدم غير موجود أو غير فعال', 'User not found or inactive');
          END IF;
          INSERT INTO cor_addressee (correspondence_id, target_type, target_id, target_name_snapshot, addressee_role,
                                     resolution_policy, instruction_id, priority_code, due_at, is_mandatory, sort_order)
          VALUES (l_id, CASE WHEN l_k = 'O' THEN 'ORG_UNIT' ELSE 'USER' END, l_tg, l_name, l_tt,
                  CASE WHEN l_k = 'O' THEN 'HEAD' END,
                  CASE WHEN l_tt = 'TO' THEN l_ins END, l_prio,
                  CASE WHEN l_tt = 'TO' THEN CAST(l_due + 1 - 1/86400 AS TIMESTAMP) END, 'N', l_seq);
        END LOOP;
      END IF;
    END LOOP;
    -- الجهة الخارجية
    DELETE FROM cor_party WHERE correspondence_id = l_id;
    IF l_kind <> 'INTERNAL' AND l_party IS NOT NULL THEN
      INSERT INTO cor_party (correspondence_id, party_role, party_id, name_snapshot)
      VALUES (l_id, CASE l_kind WHEN 'INCOMING' THEN 'SENDER' ELSE 'RECIPIENT' END, l_pty, l_party);
    END IF;
    RETURN l_id;
  END save_draft;

  -- مستلمو وحدة تنظيمية: رئيسها، وإلا شاغلو مناصبها
  FUNCTION unit_members(p_unit NUMBER) RETURN t_ids IS
    l_ids  t_ids := t_ids();
    l_head NUMBER := NOONA_ORG_PKG.unit_head(p_unit);
  BEGIN
    IF l_head IS NOT NULL THEN
      l_ids.EXTEND; l_ids(1) := l_head;
      RETURN l_ids;
    END IF;
    SELECT DISTINCT m.id BULK COLLECT INTO l_ids
      FROM org_position p
      JOIN org_position_assignment a ON a.position_id = p.id AND a.status_code IN ('EFFECTIVE', 'SCHEDULED')
           AND TRUNC(SYSDATE) BETWEEN a.effective_from AND NVL(a.effective_to, DATE '9999-12-31')
      JOIN hr_employment e ON e.id = a.employment_id AND e.status_code = 'ACTIVE'
      JOIN sec_user_membership m ON m.employee_id = e.employee_id AND m.status_code = 'ACTIVE'
     WHERE p.org_unit_id = p_unit;
    RETURN l_ids;
  END unit_members;

  PROCEDURE ensure_sequence(p_kind VARCHAR2) IS
  BEGIN
    INSERT INTO ref_doc_sequence (company_id, doc_type_code, fiscal_year, prefix, next_number, padding, is_gapless, reset_policy, is_active)
    SELECT company, 'COR_' || p_kind, EXTRACT(YEAR FROM SYSDATE),
           CASE p_kind WHEN 'INCOMING' THEN 'IN-' WHEN 'OUTGOING' THEN 'OUT-' ELSE 'INT-' END, 1, 6, 'N', 'YEARLY', 'Y'
      FROM dual
     WHERE NOT EXISTS (SELECT 1 FROM ref_doc_sequence WHERE company_id = company AND doc_type_code = 'COR_' || p_kind
                          AND (fiscal_year = EXTRACT(YEAR FROM SYSDATE) OR fiscal_year IS NULL));
  END ensure_sequence;

  -- يضيف مستلماً (أو يحدث سجله إن كان مستلماً) ويعيد رقم سجل التسليم
  FUNCTION add_recipient(p_id NUMBER, p_addressee NUMBER, p_member NUMBER, p_role VARCHAR2, p_ins NUMBER,
                         p_due TIMESTAMP WITH LOCAL TIME ZONE) RETURN NUMBER IS
    l_rid  NUMBER;
    l_snap VARCHAR2(1000) := CASE WHEN p_ins IS NOT NULL THEN '{"instruction":' || jt(instruction_name(p_ins)) || '}' END;
    l_pos  NUMBER := NOONA_ORG_PKG.primary_position(p_member);
    l_read VARCHAR2(10) := CASE WHEN p_member = me THEN 'READ' ELSE 'UNREAD' END;
  BEGIN
    SELECT MIN(id) INTO l_rid FROM cor_recipient WHERE correspondence_id = p_id AND membership_id = p_member;
    IF l_rid IS NULL THEN
      INSERT INTO cor_recipient (correspondence_id, addressee_id, membership_id, recipient_role, position_id, delivery_status,
                                 read_status, action_status, view_status, delivered_at, instruction_id, instruction_snapshot,
                                 due_at, idempotency_key)
      VALUES (p_id, p_addressee, p_member, p_role, l_pos, 'DELIVERED', l_read, 'NONE', 'ACTIVE', SYSTIMESTAMP, p_ins, l_snap,
              p_due, 'COR:' || p_id || ':' || p_member)
      RETURNING id INTO l_rid;
      event(l_rid, 'DELIVERED');
    ELSE
      UPDATE cor_recipient SET read_status = 'UNREAD', view_status = 'ACTIVE', action_status = 'NONE',
                               instruction_id = NVL(p_ins, instruction_id), due_at = NVL(p_due, due_at)
       WHERE id = l_rid;
    END IF;
    RETURN l_rid;
  END add_recipient;

  PROCEDURE send_draft(p_id NUMBER) IS
    l_c     cor_correspondence%ROWTYPE;
    l_ids   t_ids;
    l_rid   NUMBER;
    l_n     PLS_INTEGER;
    l_total PLS_INTEGER := 0;
    l_to    NUMBER;
    l_party NUMBER;
    l_from  VARCHAR2(400) := name_of(me);
  BEGIN
    SELECT * INTO l_c FROM cor_correspondence WHERE id = p_id FOR UPDATE;
    NOONA_CORE_PKG.assert(l_c.subject <> '(بدون موضوع)' OR l_c.direction = 'INTERNAL', 'NOONA-COR-013',
      'الموضوع إلزامي للخطابات الواردة والصادرة', 'Subject is required for letters');
    SELECT COUNT(*) INTO l_to FROM cor_addressee WHERE correspondence_id = p_id AND addressee_role = 'TO';
    SELECT COUNT(*) INTO l_party FROM cor_party WHERE correspondence_id = p_id;
    NOONA_CORE_PKG.assert(l_c.direction = 'OUTGOING' OR l_to > 0, 'NOONA-COR-014',
      CASE l_c.direction WHEN 'INCOMING' THEN 'حدد من يحال إليه الخطاب الوارد (إلى)' ELSE 'أضف مستلماً واحداً على الأقل (إلى)' END,
      'At least one recipient is required');
    NOONA_CORE_PKG.assert(l_c.direction = 'INTERNAL' OR l_party > 0, 'NOONA-COR-015',
      CASE l_c.direction WHEN 'INCOMING' THEN 'أدخل الجهة المرسلة للخطاب الوارد' ELSE 'أدخل الجهة المرسل إليها الخطاب الصادر' END,
      'External party is required');
    ensure_sequence(l_c.direction);
    UPDATE cor_correspondence
       SET correspondence_no = NOONA_REFERENCE_PKG.next_doc_no('COR_' || l_c.direction, company, NULL, TRUNC(SYSDATE),
                                                                'COR_CORRESPONDENCE', p_id),
           numbering_year = EXTRACT(YEAR FROM SYSDATE),
           sent_at = CASE WHEN l_c.direction <> 'INCOMING' THEN SYSTIMESTAMP END,
           received_at = CASE WHEN l_c.direction = 'INCOMING' THEN SYSTIMESTAMP END,
           status_code = CASE l_c.direction WHEN 'INCOMING' THEN 'DISTRIBUTED' ELSE 'SENT' END
     WHERE id = p_id;
    -- حل الجهات إلى مستلمين فعليين (إلى ثم نسخة ثم مخفية؛ لا يتكرر المستلم)
    FOR a IN (SELECT * FROM cor_addressee WHERE correspondence_id = p_id
               ORDER BY CASE addressee_role WHEN 'TO' THEN 1 WHEN 'CC' THEN 2 ELSE 3 END, sort_order) LOOP
      IF a.target_type = 'ORG_UNIT' THEN
        l_ids := unit_members(a.target_id);
        NOONA_CORE_PKG.assert(l_ids.COUNT > 0, 'NOONA-COR-016', 'لا يوجد من يستلم مراسلات الوحدة: ' || a.target_name_snapshot
          || ' (عيّن رئيساً للوحدة أو شاغلاً لمناصبها)', 'Organisation unit has no members to receive correspondence');
      ELSE
        l_ids := t_ids(a.target_id);
      END IF;
      l_n := 0;
      FOR i IN 1 .. l_ids.COUNT LOOP
        SELECT COUNT(*) INTO l_rid FROM cor_recipient WHERE correspondence_id = p_id AND membership_id = l_ids(i);
        IF l_rid = 0 THEN
          l_rid := add_recipient(p_id, a.id, l_ids(i), a.addressee_role, a.instruction_id, a.due_at);
          notify(l_ids(i), p_id, CASE l_c.direction WHEN 'INCOMING' THEN 'خطاب وارد: ' ELSE 'مراسلة من ' || l_from || ': ' END
                 || l_c.subject, a.due_at, 'COR_RECEIVED:' || p_id || ':' || l_ids(i));
          l_n := l_n + 1;
        END IF;
      END LOOP;
      UPDATE cor_addressee SET resolved_count = l_n WHERE id = a.id;
      l_total := l_total + l_n;
    END LOOP;
    -- الرد ينجز المطلوب مني في الرسالة الأصلية
    IF l_c.parent_id IS NOT NULL AND NVL(l_c.relation_type, 'REPLY') IN ('REPLY', 'REPLY_ALL') THEN
      FOR r IN (SELECT id FROM cor_recipient WHERE correspondence_id = l_c.parent_id AND membership_id = me
                   AND action_status IN ('NONE', 'ACKNOWLEDGED')) LOOP
        UPDATE cor_recipient SET action_status = 'ACTIONED' WHERE id = r.id;
        event(r.id, 'ACTIONED', '{"reply":' || p_id || '}');
      END LOOP;
      UPDATE cor_circulation SET status_code = 'COMPLETED', left_at = SYSTIMESTAMP
       WHERE correspondence_id = l_c.parent_id AND to_member_id = me AND status_code NOT IN ('COMPLETED', 'CANCELLED');
    END IF;
    NOONA_AUDIT_PKG.log_event('CORRESPONDENCE', 'COR_CORRESPONDENCE', p_id, 'SEND', 'SUCCESS',
      p_new_values => '{"direction":' || jt(l_c.direction) || ',"recipients":' || l_total || '}');
  END send_draft;

  FUNCTION send(p_doc IN CLOB) RETURN NUMBER IS
    l_id NUMBER := save_draft(p_doc);
  BEGIN
    send_draft(l_id);
    RETURN l_id;
  END send;

  PROCEDURE delete_draft(p_id IN NUMBER) IS
    l_c cor_correspondence%ROWTYPE := cor_row(p_id);
  BEGIN
    NOONA_CORE_PKG.assert(l_c.author_member_id = me AND l_c.status_code = 'DRAFT', 'NOONA-COR-006',
      'المسودة غير موجودة أو ليست لك', 'Draft not found');
    UPDATE dms_document_link SET status_code = 'DETACHED', detach_reason = 'حذف مسودة المراسلة'
     WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = p_id AND status_code = 'ACTIVE';
    DELETE FROM cor_addressee WHERE correspondence_id = p_id;
    DELETE FROM cor_party WHERE correspondence_id = p_id;
    UPDATE cor_correspondence SET status_code = 'CANCELLED', close_reason = 'حذف المسودة' WHERE id = p_id;
  END delete_draft;

  -- ================================================================ المرفقات
  FUNCTION attach(p_id IN NUMBER, p_file_name IN VARCHAR2, p_mime IN VARCHAR2, p_content IN BLOB) RETURN NUMBER IS
    l_c cor_correspondence%ROWTYPE := cor_row(p_id);
    l_n NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert(l_c.author_member_id = me AND l_c.status_code = 'DRAFT', 'NOONA-COR-017',
      'المرفقات تضاف للمسودة قبل الإرسال', 'Attachments can be added to drafts only');
    SELECT COUNT(*) INTO l_n FROM dms_document_link WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = p_id AND status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_n < 20, 'NOONA-COR-018', 'الحد الأقصى 20 مرفقاً للمراسلة', 'Too many attachments');
    RETURN NOONA_DMS_PKG.system_archive('COR_CORRESPONDENCE', p_id,
      CASE l_c.direction WHEN 'INCOMING' THEN 'INCOMING_LETTER' WHEN 'OUTGOING' THEN 'OUTGOING_LETTER' ELSE 'MAIL_ATTACHMENT' END,
      SUBSTR(p_file_name || ' - ' || l_c.subject, 1, 500), p_file_name, p_mime, p_content);
  END attach;

  PROCEDURE remove_attachment(p_id IN NUMBER, p_document_id IN NUMBER) IS
    l_c cor_correspondence%ROWTYPE := cor_row(p_id);
  BEGIN
    NOONA_CORE_PKG.assert(l_c.author_member_id = me AND l_c.status_code = 'DRAFT', 'NOONA-COR-017',
      'المرفقات تعدل في المسودة قبل الإرسال', 'Attachments can be changed in drafts only');
    UPDATE dms_document_link SET status_code = 'DETACHED', detach_reason = 'إزالة من مسودة المراسلة'
     WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = p_id AND document_id = p_document_id AND status_code = 'ACTIVE';
  END remove_attachment;

  PROCEDURE download(p_id IN NUMBER, p_document_id IN NUMBER, p_mode IN VARCHAR2 DEFAULT 'VIEW') IS
    l_c cor_correspondence%ROWTYPE;
    l_n NUMBER;
  BEGIN
    BEGIN
      SELECT * INTO l_c FROM cor_correspondence WHERE id = p_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      owa_util.status_line(404, 'Not Found');
      RETURN;
    END;
    SELECT COUNT(*) INTO l_n FROM dms_document_link
     WHERE entity_type = 'COR_CORRESPONDENCE' AND entity_id = p_id AND document_id = p_document_id AND status_code = 'ACTIVE';
    IF l_n = 0 OR NOT can_see(l_c) THEN
      owa_util.status_line(403, 'Forbidden');
      RETURN;
    END IF;
    NOONA_DMS_PKG.system_download(p_document_id, p_mode);
  END download;

  -- ================================================================ إجراءات المستلم
  PROCEDURE set_star(p_id IN NUMBER, p_on IN VARCHAR2) IS
    l_tid NUMBER := thread_of(p_id);
    l_on  VARCHAR2(1) := CASE WHEN p_on = 'Y' THEN 'Y' ELSE 'N' END;
  BEGIN
    UPDATE cor_recipient SET is_starred = l_on
     WHERE membership_id = me AND correspondence_id IN (SELECT id FROM cor_correspondence WHERE NVL(thread_id, id) = l_tid);
    UPDATE cor_correspondence SET author_starred = l_on
     WHERE author_member_id = me AND NVL(thread_id, id) = l_tid AND status_code <> 'DRAFT';
  END set_star;

  PROCEDURE set_view(p_id NUMBER, p_view VARCHAR2, p_event VARCHAR2) IS
    l_tid NUMBER := thread_of(p_id);
  BEGIN
    FOR r IN (SELECT r.id FROM cor_recipient r JOIN cor_correspondence c ON c.id = r.correspondence_id
               WHERE r.membership_id = me AND NVL(c.thread_id, c.id) = l_tid AND r.view_status <> p_view) LOOP
      UPDATE cor_recipient SET view_status = p_view WHERE id = r.id;
      event(r.id, p_event);
    END LOOP;
  END set_view;

  PROCEDURE archive_thread(p_id IN NUMBER) IS
  BEGIN
    set_view(p_id, 'ARCHIVED', 'ARCHIVED');
  END archive_thread;

  PROCEDURE restore_thread(p_id IN NUMBER) IS
  BEGIN
    set_view(p_id, 'RESTORED', 'RESTORED');
  END restore_thread;

  PROCEDURE mark_unread(p_id IN NUMBER) IS
    l_tid NUMBER := thread_of(p_id);
  BEGIN
    UPDATE cor_recipient SET read_status = 'UNREAD'
     WHERE membership_id = me AND correspondence_id IN (SELECT id FROM cor_correspondence WHERE NVL(thread_id, id) = l_tid);
  END mark_unread;

  FUNCTION assert_recipient(p_id NUMBER) RETURN cor_recipient%ROWTYPE IS
    l_r cor_recipient%ROWTYPE;
    l_rid NUMBER := my_rid(p_id);
  BEGIN
    NOONA_CORE_PKG.assert(l_rid IS NOT NULL, 'NOONA-COR-019', 'لست من مستلمي هذه المراسلة', 'You are not a recipient');
    SELECT * INTO l_r FROM cor_recipient WHERE id = l_rid FOR UPDATE;
    RETURN l_r;
  END assert_recipient;

  PROCEDURE acknowledge(p_id IN NUMBER) IS
    l_r cor_recipient%ROWTYPE := assert_recipient(p_id);
  BEGIN
    IF l_r.action_status = 'NONE' THEN
      UPDATE cor_recipient SET action_status = 'ACKNOWLEDGED', acknowledged_at = SYSTIMESTAMP WHERE id = l_r.id;
      event(l_r.id, 'ACKNOWLEDGED');
    END IF;
  END acknowledge;

  PROCEDURE complete(p_id IN NUMBER, p_note IN VARCHAR2 DEFAULT NULL) IS
    l_r cor_recipient%ROWTYPE := assert_recipient(p_id);
  BEGIN
    NOONA_CORE_PKG.assert(l_r.action_status IN ('NONE', 'ACKNOWLEDGED'), 'NOONA-COR-020', 'المطلوب منك منجز مسبقاً',
      'Already actioned');
    UPDATE cor_recipient SET action_status = 'ACTIONED', acknowledged_at = NVL(acknowledged_at, SYSTIMESTAMP) WHERE id = l_r.id;
    event(l_r.id, 'ACTIONED', CASE WHEN TRIM(p_note) IS NOT NULL THEN '{"note":' || jt(SUBSTR(p_note, 1, 1000)) || '}' END);
    FOR ci IN (SELECT id FROM cor_circulation WHERE correspondence_id = p_id AND to_member_id = me
                  AND status_code NOT IN ('COMPLETED', 'CANCELLED')) LOOP
      UPDATE cor_circulation SET status_code = 'COMPLETED', left_at = SYSTIMESTAMP WHERE id = ci.id;
      IF TRIM(p_note) IS NOT NULL THEN
        INSERT INTO cor_circulation_note (circulation_id, author_member_id, note_type, note_text)
        VALUES (ci.id, me, 'DECISION', SUBSTR(p_note, 1, 4000));
      END IF;
    END LOOP;
    NOONA_AUDIT_PKG.log_event('CORRESPONDENCE', 'COR_CORRESPONDENCE', p_id, 'COMPLETE', 'SUCCESS');
  END complete;

  PROCEDURE refer(p_id IN NUMBER, p_member_id IN NUMBER, p_instruction IN VARCHAR2, p_due IN DATE DEFAULT NULL,
                  p_note IN VARCHAR2 DEFAULT NULL) IS
    l_c    cor_correspondence%ROWTYPE := cor_row(p_id);
    l_ins  NUMBER := instruction_id(NVL(p_instruction, 'ACTION'));
    l_due  TIMESTAMP WITH LOCAL TIME ZONE := CAST(p_due + 1 - 1/86400 AS TIMESTAMP);
    l_rid  NUMBER := my_rid(p_id);
    l_name VARCHAR2(400);
    l_addr NUMBER;
    l_circ NUMBER;
    l_new  NUMBER;
    l_from NUMBER;
  BEGIN
    NOONA_CORE_PKG.assert_tenant_writable;
    assert_see(l_c);
    NOONA_CORE_PKG.assert(l_c.status_code NOT IN ('DRAFT', 'CANCELLED'), 'NOONA-COR-021', 'لا تحال مسودة', 'Drafts cannot be referred');
    NOONA_CORE_PKG.assert(p_member_id IS NOT NULL AND p_member_id <> me, 'NOONA-COR-022', 'اختر الشخص المحال إليه',
      'Choose who to refer to');
    SELECT MAX(u.display_name) INTO l_name FROM sec_user_membership m JOIN sec_user u ON u.id = m.user_id
     WHERE m.id = p_member_id AND m.status_code = 'ACTIVE';
    NOONA_CORE_PKG.assert(l_name IS NOT NULL, 'NOONA-COR-012', 'المستخدم غير موجود أو غير فعال', 'User not found or inactive');
    SELECT MAX(id) INTO l_from FROM cor_circulation WHERE correspondence_id = p_id AND to_member_id = me;
    INSERT INTO cor_circulation (correspondence_id, parent_circulation_id, from_member_id, to_target_type, to_target_id,
                                 to_member_id, instruction_id, required_action, due_at, entered_at, status_code)
    VALUES (p_id, l_from, me, 'USER', p_member_id, p_member_id, l_ins, SUBSTR(p_note, 1, 1000), l_due, SYSTIMESTAMP, 'ASSIGNED')
    RETURNING id INTO l_circ;
    IF TRIM(p_note) IS NOT NULL THEN
      INSERT INTO cor_circulation_note (circulation_id, author_member_id, note_type, note_text)
      VALUES (l_circ, me, 'INSTRUCTION', SUBSTR(p_note, 1, 4000));
    END IF;
    IF l_from IS NOT NULL THEN
      UPDATE cor_circulation SET status_code = 'REFERRED', left_at = SYSTIMESTAMP WHERE id = l_from AND status_code <> 'COMPLETED';
    END IF;
    INSERT INTO cor_addressee (correspondence_id, target_type, target_id, target_name_snapshot, addressee_role, instruction_id,
                               priority_code, due_at, is_mandatory, sort_order, resolved_count)
    VALUES (p_id, 'USER', p_member_id, l_name, 'FYI', l_ins, l_c.priority_code, l_due, 'N', 900, 1)
    RETURNING id INTO l_addr;
    l_new := add_recipient(p_id, l_addr, p_member_id, 'FYI', l_ins, l_due);
    event(l_new, 'DELIVERED', '{"referred_by":' || jt(name_of(me)) || '}');
    IF l_rid IS NOT NULL THEN
      UPDATE cor_recipient SET action_status = 'FORWARDED' WHERE id = l_rid AND action_status IN ('NONE', 'ACKNOWLEDGED');
      event(l_rid, 'FORWARDED', '{"to":' || jt(l_name) || '}');
    END IF;
    notify(p_member_id, p_id, 'إحالة من ' || name_of(me) || ' (' || instruction_name(l_ins) || '): ' || l_c.subject, l_due,
           'COR_REFER:' || l_circ);
    NOONA_AUDIT_PKG.log_event('CORRESPONDENCE', 'COR_CORRESPONDENCE', p_id, 'REFER', 'SUCCESS',
      p_new_values => '{"to":' || jt(l_name) || ',"instruction":' || jt(instruction_name(l_ins)) || '}');
  END refer;

  -- ================================================================ الطباعة
  FUNCTION letter_html(p_id IN NUMBER) RETURN CLOB IS
    l_c    cor_correspondence%ROWTYPE := cor_row(p_id);
    l_co   VARCHAR2(400);
    l_to   VARCHAR2(4000);
    l_cc   VARCHAR2(4000);
    l_type VARCHAR2(200);
  BEGIN
    assert_see(l_c);
    SELECT MAX(legal_name_ar) INTO l_co FROM org_company WHERE id = l_c.company_id;
    SELECT MAX(name_ar) INTO l_type FROM cor_type WHERE id = l_c.cor_type_id;
    SELECT LISTAGG(target_name_snapshot, '، ') WITHIN GROUP (ORDER BY sort_order) INTO l_to
      FROM cor_addressee WHERE correspondence_id = p_id AND addressee_role = 'TO';
    SELECT LISTAGG(target_name_snapshot, '، ') WITHIN GROUP (ORDER BY sort_order) INTO l_cc
      FROM cor_addressee WHERE correspondence_id = p_id AND addressee_role = 'CC';
    IF l_c.direction <> 'INTERNAL' THEN
      l_to := NVL(party_name(p_id), l_to);
    END IF;
    RETURN '<!doctype html><html lang="ar" dir="rtl"><head><meta charset="utf-8"><title>' || esc(l_c.correspondence_no) || '</title>'
        || '<style>body{font-family:Tahoma,Arial,sans-serif;margin:0;color:#1f2937}.pg{max-width:780px;margin:24px auto;padding:40px 48px;'
        || 'border:1px solid #e5e7eb}.hd{display:flex;justify-content:space-between;border-bottom:3px solid #0f766e;padding-bottom:12px}'
        || '.co{font-size:20px;font-weight:bold;color:#0f766e}.meta{font-size:13px;line-height:1.9}.ttl{text-align:center;font-size:18px;'
        || 'font-weight:bold;margin:24px 0 8px}.row{margin:6px 0}.lbl{color:#6b7280;display:inline-block;min-width:90px}'
        || '.body{white-space:pre-wrap;line-height:2;margin-top:20px;font-size:15px}.sg{margin-top:48px;text-align:left}'
        || '@media print{.pg{border:0;margin:0}}</style></head><body><div class="pg"><div class="hd"><div class="co">' || esc(l_co)
        || '</div><div class="meta">الرقم: <b>' || esc(NVL(l_c.correspondence_no, 'مسودة')) || '</b><br>التاريخ: '
        || TO_CHAR(NVL(CAST(l_c.sent_at AS DATE), NVL(CAST(l_c.received_at AS DATE), SYSDATE)), 'YYYY/MM/DD')
        || CASE WHEN l_c.external_no IS NOT NULL THEN '<br>الرقم الخارجي: ' || esc(l_c.external_no) END
        || '</div></div><div class="ttl">' || esc(l_type) || '</div>'
        || '<div class="row"><span class="lbl">' || CASE l_c.direction WHEN 'INCOMING' THEN 'من:' ELSE 'إلى:' END || '</span> '
        || esc(CASE l_c.direction WHEN 'INCOMING' THEN party_name(p_id) ELSE l_to END) || '</div>'
        || CASE WHEN l_cc IS NOT NULL THEN '<div class="row"><span class="lbl">نسخة إلى:</span> ' || esc(l_cc) || '</div>' END
        || '<div class="row"><span class="lbl">الموضوع:</span> <b>' || esc(l_c.subject) || '</b></div>'
        || '<div class="body">' || esc(DBMS_LOB.SUBSTR(l_c.body_text, 30000, 1)) || '</div>'
        || '<div class="sg">' || esc(name_of(l_c.author_member_id)) || '</div></div>'
        || '<script>window.onload=function(){window.print();}</script></body></html>';
  END letter_html;

END NOONA_COR_PKG;
/
