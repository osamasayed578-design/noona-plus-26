"""صفحات المراسلات في تطبيق المستندات والمراسلات (129): صندوق البريد (50) وملف المرفق (51).
الواجهة في tools/mail.js (ملف ثابت للتطبيق) والمنطق كله في NOONA_COR_PKG عبر عملية AJAX واحدة MAIL (العملية في x01).
"""

MAIL_AJAX = [
    'declare',
    '    l_c  clob;',
    '    l_id number;',
    '    l_op varchar2(30) := apex_application.g_x01;',
    '    function n(p varchar2) return number is begin return to_number(p); end;',
    '    procedure out(p clob) is',
    '        l_off pls_integer := 1;',
    '    begin',
    '        while l_off <= dbms_lob.getlength(p) loop',
    '            htp.prn(dbms_lob.substr(p, 8000, l_off));',
    '            l_off := l_off + 8000;',
    '        end loop;',
    '    end;',
    'begin',
    '    case l_op',
    "        when 'META' then l_c := noona_cor_pkg.meta_json;",
    "        when 'FOLDERS' then l_c := noona_cor_pkg.folders_json;",
    "        when 'LIST' then l_c := noona_cor_pkg.list_json(apex_application.g_x02, apex_application.g_x03, n(apex_application.g_x04));",
    "        when 'THREAD' then l_c := noona_cor_pkg.thread_json(n(apex_application.g_x02));",
    "        when 'DIR' then l_c := noona_cor_pkg.directory_json(apex_application.g_x02);",
    "        when 'PARTY' then l_c := noona_cor_pkg.parties_json(apex_application.g_x02);",
    "        when 'DRAFT' then l_c := noona_cor_pkg.draft_json(n(apex_application.g_x02));",
    "        when 'DRAFTSEED' then l_c := noona_cor_pkg.reply_seed_json(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'SAVE' then l_id := noona_cor_pkg.save_draft(apex_application.g_clob_01); l_c := '{\"id\":' || l_id || '}';",
    "        when 'SEND' then l_id := noona_cor_pkg.send(apex_application.g_clob_01); l_c := '{\"id\":' || l_id || '}';",
    "        when 'DELDRAFT' then noona_cor_pkg.delete_draft(n(apex_application.g_x02));",
    "        when 'ATTACH' then",
    "            l_id := noona_cor_pkg.attach(n(apex_application.g_x02), apex_application.g_x03, apex_application.g_x04,",
    '                                         apex_web_service.clobbase642blob(apex_application.g_clob_01));',
    "            l_c := '{\"doc\":' || l_id || '}';",
    "        when 'UNATTACH' then noona_cor_pkg.remove_attachment(n(apex_application.g_x02), n(apex_application.g_x03));",
    "        when 'STAR' then noona_cor_pkg.set_star(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'ARCHIVE' then noona_cor_pkg.archive_thread(n(apex_application.g_x02));",
    "        when 'RESTORE' then noona_cor_pkg.restore_thread(n(apex_application.g_x02));",
    "        when 'UNREAD' then noona_cor_pkg.mark_unread(n(apex_application.g_x02));",
    "        when 'ACK' then noona_cor_pkg.acknowledge(n(apex_application.g_x02));",
    "        when 'DONE' then noona_cor_pkg.complete(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'REFER' then noona_cor_pkg.refer(n(apex_application.g_x02), n(apex_application.g_x03), apex_application.g_x04,",
    "                                               to_date(apex_application.g_x05, 'YYYY-MM-DD'), apex_application.g_x06);",
    "        when 'LETTER' then l_c := noona_cor_pkg.letter_html(n(apex_application.g_x02));",
    "        when 'RESEND' then noona_cor_pkg.resend_email(n(apex_application.g_x02), apex_application.g_x03);",
    "        when 'HANDOVER' then noona_cor_pkg.record_handover(n(apex_application.g_x02), apex_application.g_x03);",
    "        else raise_application_error(-20500, 'NOONA-COR-099: عملية غير معروفة ' || l_op);",
    '    end case;',
    "    out(nvl(l_c, to_clob('{\"ok\":true}')));",
    'exception when others then',
    '    rollback;',
    '    apex_json.open_object;',
    "    apex_json.write('error', nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm));",
    '    apex_json.close_object;',
    'end;']

LOADER = ["(function () { var s = document.createElement('script'); s.src = apex.env.APP_FILES + 'mail.js'; "
          "document.head.appendChild(s); })();"]


def mail_pages(app, scheme):
    # 50) صندوق المراسلات؛ P50_OPEN يفتح مراسلة مباشرة (رابط الإشعار)
    p = app.page(50, 'Correspondence', 'MAIL', 'المراسلات', scheme=scheme, protection='N')
    p.dynamic('المراسلات', 10, [
        'begin',
        "    return '<div id=\"nnMail\" class=\"nn-mail\" data-open=\"' || apex_escape.html_attribute(:P50_OPEN)",
        "        || '\" data-file=\"' || apex_escape.html_attribute(apex_page.get_url(p_page => 51, p_items => 'P51_MSG,P51_DOC,P51_MODE',",
        "                                                                    p_values => '990000000001,990000000002,V')) || '\"></div>';",
        'end;'], hide_header=True)
    f = p.static('فتح', 20, hide_header=True)
    p.hidden('P50_OPEN', f, 10, protected=False)
    p.process(1, 'ON_DEMAND', 'MAIL', MAIL_AJAX)
    p.onload(LOADER)

    # 51) عرض / تنزيل مرفق مراسلة لأطرافها فقط
    p = app.page(51, 'Correspondence File', 'MAIL-FILE', 'مرفق مراسلة', scheme=scheme, protection='N')
    f = p.static('الملف', 10, hide_header=True)
    p.hidden('P51_MSG', f, 1, protected=False)
    p.hidden('P51_DOC', f, 2, protected=False)
    p.hidden('P51_MODE', f, 3, protected=False)
    p.process(10, 'BEFORE_HEADER', 'Download', [
        'begin',
        "    noona_cor_pkg.download(:P51_MSG, :P51_DOC, case :P51_MODE when 'D' then 'DOWNLOAD' else 'VIEW' end);",
        '    apex_application.stop_apex_engine;',
        'exception',
        '    when apex_application.e_stop_apex_engine then',
        '        null;',
        'end;'])
