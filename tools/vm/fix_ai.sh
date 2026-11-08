#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | فحص وإصلاح المساعد الذكي المحلي (Ollama) عند ظهور «NOONA-AI-015: فشل طلب HTTP»
#   التشغيل بحساب root من مجلد المستودع:   bash tools/vm/fix_ai.sh
#   يفحص: خدمة Ollama والنموذج، رد النموذج وزمنه، صلاحية الشبكة (ACL) لـ APEX، مهلة الخدمة في APEX، ربط المؤسسة بالخدمة
#   ويصلح: يشغل Ollama، يضيف الصلاحية الناقصة، يرفع المهلة إلى 600 ثانية، ويحدث برنامج المساعد ليذكر سبب أي فشل بوضوح
#   لا يطلب كلمات مرور. أرسل ناتجه كاملاً إن بقيت المشكلة.
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
C_OK='\033[1;32m'; C_W='\033[1;33m'; C_ERR='\033[1;31m'; C_H='\033[1;36m'; C_0='\033[0m'
h()    { echo -e "\n${C_H}== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
warn() { echo -e "${C_W}  ! $*${C_0}"; }
bad()  { echo -e "${C_ERR}  ✗ $*${C_0}"; }
[ "$(id -u)" = 0 ] || { bad "شغّل السكربت بحساب root"; exit 1; }
[ -f /home/oracle/.noona_env ] || { bad "لم أجد بيئة نونا (/home/oracle/.noona_env)"; exit 1; }
[ -f "$ROOT/db/plsql26/140_noona_ai_pkg.sql" ] || { bad "شغّله من مجلد المستودع الكامل (لم أجد db/plsql26/140_noona_ai_pkg.sql)"; exit 1; }

PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || { bad "القاعدة لا تعمل"; exit 1; }
Q() { printf 'CONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\nSET HEADING OFF FEEDBACK OFF PAGES 0 LINES 300 SERVEROUTPUT ON\n%s\nEXIT\n' "$PDB" "$1" \
  | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; sqlplus -S -L /nolog" 2>&1 | grep -v '^$\|^Session altered\|^Connected'; }
APX=$(Q "SELECT schema FROM dba_registry WHERE comp_id = 'APEX';" | tr -d ' ')

# ----------------------------------------------------------------------------- 0) لماذا يختفي «اسأل نونا» والملخص
# يظهران فقط إذا: برنامج المساعد صالح، وموديول AI مفعل في اشتراك المؤسسة وساري اليوم، وإعداد المؤسسة مفعل بنموذج وخدمة
h "0) شروط ظهور «اسأل نونا» والملخص التنفيذي"
Q "SELECT '  برنامج المساعد '||object_type||': '||DECODE(status,'VALID','صالح','غير صالح') FROM dba_objects
    WHERE owner = 'NOONA_OWNER' AND object_name = 'NOONA_AI_PKG' ORDER BY object_type;"
Q "SELECT '  خطأ في '||name||' سطر '||line||': '||SUBSTR(text,1,160) FROM dba_errors WHERE owner = 'NOONA_OWNER' AND name LIKE 'NOONA_AI%' AND ROWNUM <= 8;"
Q "SELECT '  مؤسسة '||t.id||' ('||t.name_ar||'): موديول AI '||
          NVL((SELECT MAX(CASE WHEN e.is_enabled = 'Y' AND TRUNC(SYSDATE) BETWEEN e.effective_from AND NVL(e.effective_to, DATE '9999-12-31')
                               THEN 'مفعل' ELSE 'غير مفعل أو منتهي ('||TO_CHAR(e.effective_to,'YYYY-MM-DD')||')' END)
                 FROM noona_owner.plt_entitlement e JOIN noona_owner.plt_module m ON m.id = e.module_id
                WHERE e.tenant_id = t.id AND m.module_code = 'AI' AND e.feature_id IS NULL), 'مفعل (لا قيود في الاشتراك)')
          ||' · المساعد '||NVL((SELECT DECODE(s.is_enabled,'Y','مفعل','معطل')||' · النموذج '||NVL(m.model_identifier,'-')||' · الخدمة '||NVL(p.endpoint_ref,'-')
                 FROM noona_owner.ai_tenant_setting s LEFT JOIN noona_owner.ai_model m ON m.id = s.chat_model_id
                 LEFT JOIN noona_owner.ai_provider p ON p.id = m.provider_id WHERE s.tenant_id = t.id AND ROWNUM = 1), 'غير معد')
     FROM noona_owner.plt_tenant t ORDER BY t.id;"

# ----------------------------------------------------------------------------- 1) الخدمة في APEX
h "1) خدمة الذكاء الاصطناعي في APEX"
ROW=$(Q "SELECT NVL(TO_CHAR(server_timeout),'-')||' '||NVL(ai_model_name,'-')||' '||base_url FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_LOCAL';")
if [ -z "$ROW" ] || [[ "$ROW" == *ORA-* ]]; then bad "الخدمة NOONA_AI_LOCAL غير موجودة: شغّل  bash tools/vm/setup_ai_ollama.sh"; echo "$ROW"; exit 1; fi
read -r TMO MODEL URL <<<"$ROW"
HOSTP=$(echo "$URL" | sed -E 's#^https?://([^/]+).*#\1#'); OH=${HOSTP%%:*}
echo "  العنوان: $URL · النموذج: $MODEL · المهلة: ${TMO/-/الافتراضي 180} ثانية"
[[ "$URL" == */v1/chat/completions ]] || bad "العنوان يجب أن ينتهي بـ /v1/chat/completions"
if [ "$TMO" = "-" ] || [ "$TMO" -lt 600 ] 2>/dev/null; then
  Q "UPDATE $APX.wwv_remote_servers SET server_timeout = 600 WHERE static_id = 'NOONA_AI_LOCAL';"$'\n'"COMMIT;" >/dev/null
  ok "رفعت مهلة الرد إلى 600 ثانية (كانت ${TMO/-/180})"
else ok "مهلة الرد $TMO ثانية"; fi

# ----------------------------------------------------------------------------- 2) Ollama
h "2) خدمة Ollama والنموذج"
if ! command -v ollama >/dev/null 2>&1; then bad "Ollama غير مثبت: شغّل  bash tools/vm/setup_ai_ollama.sh"; exit 1; fi
systemctl is-active -q ollama || { warn "Ollama متوقف؛ أشغله"; systemctl start ollama; sleep 5; }
systemctl is-active -q ollama && ok "Ollama يعمل" || { bad "تعذر تشغيل Ollama:"; journalctl -u ollama -n 15 --no-pager; exit 1; }
if ollama list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$MODEL"; then ok "النموذج $MODEL منزّل"
else bad "النموذج $MODEL غير منزّل؛ الموجود: $(ollama list | awk 'NR>1{print $1}' | paste -sd' ')"; echo "  نزّله:  ollama pull $MODEL"; fi
echo "  الذاكرة المتاحة: $(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo) ميجابايت · المحمل الآن: $(ollama ps 2>/dev/null | awk 'NR>1{print $1" "$3$4}' | paste -sd' ')"
echo "  أسأل النموذج سؤالاً قصيراً (قد يأخذ دقيقة أو أكثر في أول مرة لتحميله)..."
R=$(curl -s --noproxy '*' -m 600 -w '\n%{http_code} %{time_total}' "$URL" -H 'Content-Type: application/json' \
    -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"قل مرحبا في كلمة واحدة\"}],\"max_tokens\":20}")
CODE=$(echo "$R" | tail -1 | cut -d' ' -f1); SEC=$(echo "$R" | tail -1 | cut -d' ' -f2)
case "$CODE" in
  200) ok "رد النموذج خلال $SEC ثانية: $(echo "$R" | head -n -1 | grep -o '"content":"[^"]*"' | head -1)"
       awk -v t="$SEC" 'BEGIN{exit !(t>60)}' && warn "النموذج بطيء؛ الأسئلة التي تستخدم بيانات النظام تأخذ أضعاف ذلك" ;;
  000) bad "لا رد من $URL خلال 600 ثانية أو الاتصال مرفوض"; journalctl -u ollama -n 15 --no-pager ;;
  *)   bad "رد Ollama بالخطأ $CODE: $(echo "$R" | head -n -1 | head -c 300)" ;;
esac

# ----------------------------------------------------------------------------- 3) صلاحية الشبكة
h "3) صلاحية الشبكة (ACL) لـ $APX على $OH"
N=$(Q "SELECT COUNT(*) FROM dba_host_aces WHERE principal = '$APX' AND privilege IN ('HTTP','CONNECT') AND host IN ('$OH','*');" | tr -dc '0-9')
if [ "${N:-0}" -ge 1 ] 2>/dev/null; then ok "الصلاحية موجودة"
else
  Q "BEGIN FOR h IN (SELECT '$OH' host FROM dual UNION SELECT '127.0.0.1' FROM dual) LOOP
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(host => h.host, ace => xs\$ace_type(privilege_list => xs\$name_list('http','connect','resolve'),
    principal_name => '$APX', principal_type => xs_acl.ptype_db)); END LOOP; END;
/" | grep -i "ORA-" && bad "تعذر إضافة الصلاحية" || ok "أضفت صلاحية الاتصال بـ $OH"
fi

# ----------------------------------------------------------------------------- 4) ربط المؤسسة
h "4) ربط المساعد بالخدمة"
Q "SELECT '  '||p.code||' -> '||p.endpoint_ref||' · '||p.status_code||' · مؤسسة '||NVL(TO_CHAR(p.tenant_id),'(عام)') FROM noona_owner.ai_provider p WHERE p.endpoint_ref = 'NOONA_AI_LOCAL';"
Q "SELECT '  مفعل لمؤسسة '||s.tenant_id||': '||s.is_enabled||' · النموذج '||m.model_identifier FROM noona_owner.ai_tenant_setting s LEFT JOIN noona_owner.ai_model m ON m.id = s.chat_model_id;"

# ----------------------------------------------------------------------------- 5) تحديث برنامج المساعد
h "5) تحديث برنامج المساعد (رسائل أوضح لسبب الفشل)"
T=/tmp/noona_ai_pkg_$$.sql; cp "$ROOT/db/plsql26/140_noona_ai_pkg.sql" "$T"; chmod 644 "$T"
OUT=$(Q "ALTER SESSION SET CURRENT_SCHEMA = NOONA_OWNER;
@$T
SELECT 'STATUS '||status FROM dba_objects WHERE owner = 'NOONA_OWNER' AND object_name = 'NOONA_AI_PKG' AND object_type = 'PACKAGE BODY';"); rm -f "$T"
echo "$OUT" | grep -q "STATUS VALID" && ok "تم تحديث برنامج المساعد" || { bad "تعذر التحديث:"; echo "$OUT" | grep -i "ORA-\|PLS-\|STATUS" | head -5; }
# إعادة ترجمة ما أبطله التحديث، ثم عرض أي كائن غير صالح بسبب خطئه
Q "EXEC DBMS_UTILITY.COMPILE_SCHEMA('NOONA_OWNER', FALSE)" >/dev/null
INVL=$(Q "SELECT '  '||o.object_name||' '||o.object_type||': '||NVL((SELECT SUBSTR(MIN(e.text),1,140) FROM dba_errors e
              WHERE e.owner = o.owner AND e.name = o.object_name AND e.type = o.object_type), '')
            FROM dba_objects o WHERE o.owner IN ('NOONA_OWNER','NOONA_APP') AND o.status <> 'VALID';")
if [ -z "$INVL" ]; then ok "كل كائنات نونا صالحة"
else bad "كائنات غير صالحة (قاعدة أقدم من الملفات؟ شغّل: RUN_UPGRADES=1 bash tools/vm/setup_noona26_ol.sh):"; echo "$INVL" | head -15; fi

h "التالي"
echo "  جرّب «اسأل نونا» الآن. إن ظهر خطأ فستذكر الرسالة سببه بالتحديد؛ أرسلها لي مع ناتج هذا السكربت."
