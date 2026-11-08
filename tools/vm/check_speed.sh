#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | فحص بطء فتح الصفحات على الخادم وعلاجه
#   الفحص فقط:        bash tools/vm/check_speed.sh
#   الفحص مع العلاج:  bash tools/vm/check_speed.sh --fix
#   يعرض: الذاكرة والتبديل (swap) والمعالج، استهلاك Oracle وORDS وOllama، زمن الصفحة من المتصفح ومن APEX،
#   وأبطأ الصفحات خلال آخر 24 ساعة، ومهلة خدمة الذكاء الاصطناعي. والعلاج: تحرير النموذج من الذاكرة عند عدم الاستخدام،
#   ورفع مهلة رد الخدمة المحلية إلى 600 ثانية،
#   وإعادة تشغيل ORDS إن كان لا يتصل بالقاعدة.
# =============================================================================
FIX=0; [ "$1" = "--fix" ] && FIX=1
C_OK='\033[1;32m'; C_W='\033[1;33m'; C_ERR='\033[1;31m'; C_H='\033[1;36m'; C_0='\033[0m'
h()    { echo -e "\n${C_H}== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
warn() { echo -e "${C_W}  ! $*${C_0}"; }
bad()  { echo -e "${C_ERR}  ✗ $*${C_0}"; }
[ "$(id -u)" = 0 ] || { bad "شغّل السكربت بحساب root"; exit 1; }
[ -f /home/oracle/.noona_env ] || { bad "لم أجد بيئة نونا (/home/oracle/.noona_env)"; exit 1; }
PORT=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT=${PORT:-8080}
ISSUES=0

# ----------------------------------------------------------------------------- الذاكرة والمعالج
h "الذاكرة والمعالج"
read -r MT MA ST SF < <(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}/SwapTotal/{st=$2}/SwapFree/{sf=$2}END{print int(t/1024),int(a/1024),int(st/1024),int(sf/1024)}' /proc/meminfo)
SU=$((ST-SF)); CPU=$(nproc); LOAD=$(cut -d' ' -f1 /proc/loadavg)
echo "  الذاكرة ${MT}MB · المتاح ${MA}MB · التبديل المستخدم ${SU}MB من ${ST}MB · الأنوية ${CPU} · الحمل ${LOAD}"
[ "$MT" -lt 7500 ] && { warn "الذاكرة أقل من 8 جيجابايت: القاعدة وORDS يحتاجان 6 جيجابايت تقريباً، والذكاء الاصطناعي المحلي يحتاج 3-6 إضافية"; ISSUES=$((ISSUES+1)); }
[ "$MA" -lt 800 ] && { bad "الذاكرة المتاحة منخفضة جداً (${MA}MB): هذا سبب مباشر للبطء"; ISSUES=$((ISSUES+1)); }
[ "$SU" -gt 500 ] && { bad "النظام يستخدم التبديل على القرص (${SU}MB): الصفحات تبطئ كثيراً عند ذلك"; ISSUES=$((ISSUES+1)); }
awk -v l="$LOAD" -v c="$CPU" 'BEGIN{exit !(l>c*1.5)}' && { warn "المعالج مشغول (الحمل ${LOAD} على ${CPU} أنوية)"; ISSUES=$((ISSUES+1)); }
echo "  أكثر العمليات استهلاكاً للذاكرة:"
ps -eo rss,pcpu,comm --sort=-rss | awk 'NR>1&&NR<=7{printf "    %6d MB  %5s%% CPU  %s\n",$1/1024,$2,$3}'
SG=$(ps -eo comm,rss | awk '/^(ora_|oracle)/{s+=$2}END{print int(s/1024)}')

# ----------------------------------------------------------------------------- Ollama
if command -v ollama >/dev/null 2>&1 && systemctl is-active -q ollama; then
  h "الذكاء الاصطناعي المحلي (Ollama)"
  KA=$(systemctl show ollama -p Environment | grep -o 'OLLAMA_KEEP_ALIVE=[^ ]*' | cut -d= -f2)
  LOADED=$(ollama ps 2>/dev/null | awk 'NR>1{print $1" ("$3" "$4")"}' | paste -sd' ')
  echo "  مدة بقاء النموذج في الذاكرة: ${KA:-5m} · المحمل الآن: ${LOADED:-لا شيء}"
  if [ "$KA" = 24h ] || [ "$KA" = -1 ]; then
    bad "النموذج يبقى في الذاكرة طوال اليوم ويزاحم Oracle؛ العلاج: إبقاؤه 10 دقائق بعد آخر سؤال فقط"; ISSUES=$((ISSUES+1))
    if [ $FIX = 1 ]; then
      sed -i 's/OLLAMA_KEEP_ALIVE=.*/OLLAMA_KEEP_ALIVE=10m/' /etc/systemd/system/ollama.service.d/noona.conf
      systemctl daemon-reload; systemctl restart ollama; ok "تم: النموذج يتحرر من الذاكرة بعد 10 دقائق من آخر سؤال (أول سؤال بعدها يأخذ ثواني إضافية للتحميل)"
    fi
  fi
fi

# ----------------------------------------------------------------------------- خدمة الذكاء الاصطناعي في APEX
AI_PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
if [ -n "$AI_PDB" ]; then
  AIQ() { printf 'CONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\nSET HEADING OFF FEEDBACK OFF PAGES 0 LINES 300\n%s\nEXIT\n' "$AI_PDB" "$1" \
    | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>&1 | grep -v '^$\|^Session altered\|^Connected'; }
  APX=$(AIQ "SELECT schema FROM dba_registry WHERE comp_id = 'APEX';" | tr -d ' ')
  SRV=$(AIQ "SELECT static_id||' '||NVL(TO_CHAR(server_timeout),'-')||' '||base_url FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_LOCAL';")
  if [ -n "$SRV" ] && [[ "$SRV" != *ORA-* ]]; then
    h "خدمة الذكاء الاصطناعي المحلية في APEX"
    read -r _ TMO URL <<<"$SRV"
    echo "  العنوان: $URL · مهلة الرد: ${TMO/-/الافتراضي 180} ثانية"
    if [ "$TMO" = "-" ] || [ "$TMO" -lt 600 ] 2>/dev/null; then
      bad "مهلة الرد قصيرة على نموذج محلي يعمل على المعالج؛ هذا يسبب «NOONA-AI-015: فشل طلب HTTP»"; ISSUES=$((ISSUES+1))
      if [ $FIX = 1 ]; then
        AIQ "UPDATE $APX.wwv_remote_servers SET server_timeout = 600 WHERE static_id = 'NOONA_AI_LOCAL';"$'\n'"COMMIT;" >/dev/null
        ok "تم: مهلة الرد 600 ثانية"
      fi
    fi
    if command -v ollama >/dev/null 2>&1; then
      MDL=$(AIQ "SELECT ai_model_name FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_LOCAL';" | tr -d ' ')
      R=$(curl -s --noproxy '*' -m 600 -o /dev/null -w "%{http_code} %{time_total}" "$URL" -H 'Content-Type: application/json' \
          -d "{\"model\":\"$MDL\",\"messages\":[{\"role\":\"user\",\"content\":\"قل مرحبا\"}],\"max_tokens\":20}")
      echo "  تجربة سؤال قصير للنموذج $MDL: الحالة ${R% *} · الزمن ${R#* } ثانية"
      case "${R% *}" in
        200) awk -v t="${R#* }" 'BEGIN{exit !(t>60)}' && warn "النموذج بطيء جداً على هذا الخادم؛ جرّب qwen2.5:3b أو زد الذاكرة والأنوية" ;;
        000) bad "Ollama لا يرد: systemctl restart ollama ثم journalctl -u ollama -n 30"; ISSUES=$((ISSUES+1)) ;;
        *)   bad "Ollama رد بخطأ ${R% *} (هل النموذج $MDL منزّل؟ ollama list)"; ISSUES=$((ISSUES+1)) ;;
      esac
    fi
  fi
fi

# ----------------------------------------------------------------------------- ORDS
h "خادم الويب ORDS (المنفذ $PORT)"
systemctl is-active -q ords && ok "ORDS يعمل" || { bad "ORDS متوقف"; ISSUES=$((ISSUES+1)); }
T=$(curl -s --noproxy '*' -o /dev/null -w "%{http_code} %{time_total}" -m 60 "http://localhost:$PORT/ords/r/noonaplus/noona_master/home" -L)
echo "  فتح صفحة الدخول: الحالة ${T% *} · الزمن ${T#* } ثانية"
case "${T% *}" in
  200) awk -v t="${T#* }" 'BEGIN{exit !(t>2)}' && { warn "صفحة الدخول تأخذ أكثر من ثانيتين"; ISSUES=$((ISSUES+1)); } ;;
  571|503|000) bad "ORDS لا يتصل بالقاعدة (يحدث إذا بدأ قبلها)"; ISSUES=$((ISSUES+1))
     if [ $FIX = 1 ]; then systemctl restart ords; sleep 25; ok "أعيد تشغيل ORDS: $(curl -s --noproxy '*' -o /dev/null -w '%{http_code} %{time_total}s' -m 60 -L http://localhost:$PORT/ords/r/noonaplus/noona_master/home)"; fi ;;
esac
J=$(journalctl -u ords --since "-1 day" 2>/dev/null | grep -ci "OutOfMemory\|pool.*exhaust\|UCP-\|DatabaseConnectionError")
[ "${J:-0}" -gt 0 ] && { warn "في سجل ORDS ${J} رسالة خطأ اتصال أو ذاكرة خلال آخر يوم (journalctl -u ords)"; ISSUES=$((ISSUES+1)); }

# ----------------------------------------------------------------------------- القاعدة وAPEX
h "زمن الصفحات داخل القاعدة (APEX) خلال آخر 24 ساعة"
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
if [ -z "$PDB" ]; then bad "القاعدة لا تعمل"; ISSUES=$((ISSUES+1)); else
cat <<EOF | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; sqlplus -S -L /nolog" 2>&1 | grep -v "^$"
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=$PDB;
SET LINES 150 PAGES 100 FEEDBACK OFF
COL app FOR A14
COL page FOR A40
SELECT a.alias app, COUNT(*) views, ROUND(AVG(l.elapsed_time),2) avg_sec, ROUND(MAX(l.elapsed_time),1) max_sec
FROM apex_workspace_activity_log l JOIN apex_applications a ON a.application_id = l.application_id
WHERE l.view_date > SYSDATE-1 AND l.workspace = 'NOONAPLUS' GROUP BY a.alias ORDER BY 3 DESC;
PROMPT
PROMPT   أبطأ 10 صفحات:
SELECT * FROM (SELECT a.alias app, l.page_id||' '||SUBSTR(l.page_name,1,34) page, COUNT(*) views, ROUND(AVG(l.elapsed_time),2) avg_sec
FROM apex_workspace_activity_log l JOIN apex_applications a ON a.application_id = l.application_id
WHERE l.view_date > SYSDATE-1 AND l.workspace = 'NOONAPLUS' AND l.elapsed_time IS NOT NULL
GROUP BY a.alias, l.page_id, l.page_name ORDER BY 4 DESC) WHERE ROWNUM <= 10;
PROMPT
PROMPT   ذاكرة القاعدة (SGA و PGA بالميجابايت):
SELECT ROUND(SUM(value)/1048576) sga_mb FROM v\$sga;
SELECT ROUND(value/1048576) pga_mb FROM v\$pgastat WHERE name = 'total PGA allocated';
EXIT
EOF
echo "  إن كان متوسط الصفحة أقل من 0.3 ثانية هنا والبطء ظاهر في المتصفح، فالسبب في الذاكرة أو الشبكة وليس في الشاشات."
fi

# ----------------------------------------------------------------------------- الخلاصة
h "الخلاصة"
if [ $ISSUES = 0 ]; then ok "لا مشكلة ظاهرة على الخادم؛ إن كان البطء من جهاز آخر فافحص الشبكة بين الجهازين (ping لعنوان الخادم)"
else echo "  عدد الملاحظات: $ISSUES"; [ $FIX = 0 ] && echo "  للعلاج التلقائي لما يمكن علاجه: bash tools/vm/check_speed.sh --fix"; fi
echo "  أرسل لي ناتج هذا الفحص كما هو (لا يحتوي كلمات مرور)."
