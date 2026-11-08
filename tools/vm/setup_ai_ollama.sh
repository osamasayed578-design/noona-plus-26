#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | مساعد ذكاء اصطناعي مجاني على نفس الخادم (Ollama + نموذج مفتوح المصدر) للتجربة والعرض
#   يثبّت Ollama ونموذجاً يدعم استدعاء الأدوات، وينشئ خدمة APEX (NOONA_AI_LOCAL)، ويفعّل المساعد للمؤسسة، ثم يختبر سؤالاً
#   التشغيل بعد setup_noona26_ol.sh:   sudo bash tools/vm/setup_ai_ollama.sh
#   النموذج: يسأل عنه (qwen2.5:3b أسرع، qwen2.5:7b أدق)، أو حدده مسبقاً: MODEL=qwen2.5:7b bash ...
#   لا مفاتيح ولا تكلفة، ولا يخرج شيء من الخادم. يعاد تشغيله بأمان.
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG=/var/log/noona26_ai.log
WORK=/opt/noona
OHOST=localhost
OPORT=11434
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}" | tee -a "$LOG"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}" | tee -a "$LOG"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}" | tee -a "$LOG"; echo "  السجل: $LOG"; exit 1; }
info() { echo "  $*" | tee -a "$LOG"; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "شغّل setup_noona26_ol.sh أولاً (لم أجد بيئة القاعدة)"
[ -f "$ROOT/db/dev/ai_local_service.sql" ] || die "انسخ آخر نسخة من المستودع (لم أجد db/dev/ai_local_service.sql)"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) ----" >> "$LOG"

# ----------------------------------------------------------------------------- النموذج
step "1/6 اختيار النموذج"
MEM=$(awk '/MemTotal/{print int($2/1024/1024+0.5)}' /proc/meminfo); CPU=$(nproc)
info "الذاكرة ${MEM}G · الأنوية ${CPU}"
if [ -z "$MODEL" ]; then
  echo "  1) qwen2.5:3b  - أسرع (حوالي 2 جيجابايت تنزيل) - مناسب للمعالج بلا كرت شاشة"
  echo "  2) qwen2.5:7b  - أدق في العربية (حوالي 4.7 جيجابايت) - أبطأ، يحتاج 8 جيجابايت ذاكرة فارغة"
  read -rp "  اختر [1]: " c
  case "$c" in 2) MODEL=qwen2.5:7b ;; *) MODEL=qwen2.5:3b ;; esac
fi
[ "$MODEL" = qwen2.5:7b ] && [ "$MEM" -lt 14 ] && info "تنبيه: الذاكرة قد لا تكفي القاعدة ونموذج 7b معاً"
read -rsp "  كلمة مرور NOONA_APP (التي أدخلتها في تثبيت نونا): " APP_PWD; echo
read -rp "  مستخدم نونا الذي يفعّل له المساعد [ADMIN]: " NUSER; NUSER=${NUSER:-ADMIN}
ok "النموذج $MODEL"

# ----------------------------------------------------------------------------- Ollama
step "2/6 تثبيت Ollama"
if ! command -v ollama >/dev/null 2>&1; then
  dnf -y install zstd tar curl >>"$LOG" 2>&1 || true
  curl -fsSL https://ollama.com/install.sh -o /tmp/ollama_install.sh >>"$LOG" 2>&1 || die "تعذر تنزيل مثبّت Ollama (تحقق من الإنترنت وDNS)"
  sh /tmp/ollama_install.sh >>"$LOG" 2>&1 || die "فشل تثبيت Ollama"
fi
# سياق أطول (تعليمات المساعد وأدواته)، والنموذج يبقى محملاً، وطلب واحد في الوقت نفسه
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/noona.conf <<EOF
[Service]
Environment=OLLAMA_HOST=127.0.0.1:$OPORT
Environment=OLLAMA_CONTEXT_LENGTH=8192
Environment=OLLAMA_KEEP_ALIVE=10m
Environment=OLLAMA_NUM_PARALLEL=1
EOF
chmod 644 /etc/systemd/system/ollama.service.d/noona.conf
systemctl daemon-reload; systemctl enable ollama >>"$LOG" 2>&1; systemctl restart ollama
for i in $(seq 1 30); do curl -s -o /dev/null "http://$OHOST:$OPORT/api/tags" && break; sleep 2; done
curl -s -o /dev/null "http://$OHOST:$OPORT/api/tags" || die "خدمة Ollama لا تستجيب (journalctl -u ollama -n 30)"
ok "Ollama يعمل على $OHOST:$OPORT ($(ollama --version 2>/dev/null | tail -1))"

# ----------------------------------------------------------------------------- تنزيل النموذج
step "3/6 تنزيل النموذج $MODEL (يكمل من حيث توقف إن انقطع)"
ollama pull "$MODEL" 2>&1 | tr '\r' '\n' | grep -v '^$' | awk 'NR%40==0 || /success|error/' | tee -a "$LOG"
ollama list | grep -q "^${MODEL%%:*}.*${MODEL##*:}" || die "لم يكتمل تنزيل النموذج؛ أعد تشغيل السكربت"
ok "النموذج جاهز"

# ----------------------------------------------------------------------------- اختبار مباشر
step "4/6 اختبار النموذج (أول مرة أبطأ: تحميله في الذاكرة)"
T0=$(date +%s)
R=$(curl -s -m 600 "http://$OHOST:$OPORT/v1/chat/completions" -H 'Content-Type: application/json' \
  -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"قل: مرحباً من نونا\"}],\"max_tokens\":30}")
echo "$R" | grep -q '"content"' || die "النموذج لم يرد: $(echo "$R" | head -c 200)"
ok "رد خلال $(( $(date +%s) - T0 )) ثانية"

# ----------------------------------------------------------------------------- القاعدة وAPEX
. /home/oracle/.noona_env
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل"
rm -rf "$WORK/ai"; mkdir -p "$WORK/ai"; cp -r "$ROOT/db/dev" "$WORK/ai/"; chown -R oracle:oinstall "$WORK/ai"; chmod -R u+rwX,go+rX "$WORK/ai"

step "5/6 خدمة APEX (NOONA_AI_LOCAL) وصلاحية الاتصال"
OUT=$(printf 'CONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\n@dev/ai_local_service.sql %s %s %s\n' "$PDB" "$OHOST" "$OPORT" "$MODEL" \
  | su - oracle -c ". ~/.noona_env; cd $WORK/ai && sqlplus -S -L /nolog" 2>&1); echo "$OUT" >> "$LOG"
echo "$OUT" | grep -q SERVICE_OK || die "تعذر إنشاء خدمة APEX: $(echo "$OUT" | grep -m2 'ORA-')"
ok "الخدمة NOONA_AI_LOCAL (http://$OHOST:$OPORT/v1/chat/completions)"

step "6/6 تفعيل المساعد للمؤسسة واختبار سؤال حقيقي"
OUT=$(printf 'CONNECT NOONA_APP/"%s"@//localhost:1521/%s\n@dev/ai_local_tenant.sql %s %s\n' "$APP_PWD" "$PDB" "$NUSER" "$MODEL" \
  | su - oracle -c ". ~/.noona_env; cd $WORK/ai && sqlplus -S -L /nolog" 2>&1); echo "$OUT" >> "$LOG"
echo "$OUT" | grep -q "TENANT_OK available=Y" || die "تعذر التفعيل: $(echo "$OUT" | grep -m2 'ORA-\|TENANT_OK')"
ok "المساعد مفعّل للمؤسسة"
info "سؤال تجريبي عبر المساعد (قد يأخذ دقيقة أو أكثر على المعالج)"
T0=$(date +%s)
OUT=$(su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>&1 <<EOF
CONNECT NOONA_APP/"$APP_PWD"@//localhost:1521/$PDB
SET SERVEROUTPUT ON SIZE UNLIMITED FEEDBACK OFF
DECLARE l CLOB;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => '$NUSER');
  NOONA_APEX_PKG.post_auth('$NUSER', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l := NOONA_AI_PKG.chat('{"question":"ما إجمالي الإيرادات هذا الشهر؟","app":"NOONA_BI","pageTitle":"اختبار"}');
  DBMS_OUTPUT.PUT_LINE('CHAT_OK ' || DBMS_LOB.SUBSTR(l, 600, 1));
  COMMIT;
END;
/
EXIT
EOF
); echo "$OUT" >> "$LOG"
if echo "$OUT" | grep -q CHAT_OK; then
  ok "أجاب المساعد خلال $(( $(date +%s) - T0 )) ثانية"
  echo "$OUT" | grep CHAT_OK | cut -c1-400 | tee -a "$LOG"
else
  info "تنبيه: الاختبار عبر المساعد لم يكتمل ($(echo "$OUT" | grep -m1 'ORA-\|NOONA-')). جرّب من الشاشة؛ وإن كان بطيئاً اختر qwen2.5:3b"
fi
IP=$(hostname -I | awk '{print $1}')
cat <<EOF | tee -a "$LOG"

====================================================================
 مساعد نونا يعمل بنموذج محلي مجاني ($MODEL)
   افتح أي صفحة: http://$IP:8080/ords/r/noonaplus/noona_master/home  ثم زر «اسأل نونا»
   تغيير النموذج لاحقاً: MODEL=qwen2.5:7b bash tools/vm/setup_ai_ollama.sh
   الانتقال إلى Claude لاحقاً: خدمة NOONA_AI_CLAUDE بمفتاحك، ثم اختر النموذج من إدارة المؤسسة ← الذكاء الاصطناعي
====================================================================
EOF
