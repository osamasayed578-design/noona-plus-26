"""NOONA PLUS 26: «مساعد نونا» في كل التطبيقات (يستدعى من apex_brand.apply عند وجود هذا الملف، نسخة 26 فقط).
يضيف ai.js لملفات التطبيق ويحمله في كل الصفحات، وعملية تطبيق عند الطلب NOONA_AI تخدم الواجهة:
  STATE (الإتاحة) · CHAT (السؤال في p_clob_01) · CONVS · MSGS x02 · DEL x02 · FB x02 x03 · SUMMARY x02=الفرع
"""
import os
import shutil

_DIR = os.path.dirname(os.path.abspath(__file__))

PROCESS = [
    'declare',
    '    l clob;',
    '    l_pos pls_integer := 1;',
    'begin',
    '    case apex_application.g_x01',
    "        when 'STATE' then l := '{\"available\":\"' || noona_ai_pkg.is_enabled || '\"}';",
    "        when 'CHAT' then l := noona_ai_pkg.chat(apex_application.g_clob_01);",
    "        when 'CONVS' then l := noona_ai_pkg.conversations_json(30);",
    "        when 'MSGS' then l := noona_ai_pkg.messages_json(to_number(apex_application.g_x02));",
    "        when 'DEL' then noona_ai_pkg.delete_conversation(to_number(apex_application.g_x02)); l := '{\"ok\":true}';",
    "        when 'FB' then noona_ai_pkg.feedback(to_number(apex_application.g_x02), to_number(apex_application.g_x03)); l := '{\"ok\":true}';",
    "        when 'SUMMARY' then l := noona_ai_pkg.executive_summary(null, to_number(nullif(apex_application.g_x02, '')));",
    "        else l := '{\"ok\":false,\"msg\":\"طلب غير معروف\"}';",
    '    end case;',
    "    owa_util.mime_header('application/json', false); owa_util.http_header_close;",
    '    while l_pos <= dbms_lob.getlength(l) loop',
    '        htp.prn(dbms_lob.substr(l, 8000, l_pos)); l_pos := l_pos + 8000;',
    '    end loop;',
    'exception when others then',
    "    apex_json.open_object; apex_json.write('ok', false);",
    "    apex_json.write('msg', regexp_replace(nvl(trim(regexp_substr(sqlerrm, 'NOONA-[A-Z]+-[0-9]+: [^' || chr(10) || ']+')), sqlerrm),",
    "                                          '\\s*\\[cid=[^]]+\\]', ''));",
    '    apex_json.close_object;',
    'end;']


def files(static_dir, file_list):
    shutil.copyfile(os.path.join(_DIR, 'ai.js'), os.path.join(static_dir, 'ai.js'))
    if ('ai.js', 'application/javascript') not in file_list:
        file_list.append(('ai.js', 'application/javascript'))
