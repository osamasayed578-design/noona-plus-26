#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تشغيل مساعد نونا بـ Claude بدل النموذج المحلي
#   bash tools/vm/use_claude.sh
# قبل التشغيل (مرة واحدة، أنت بنفسك، والمفتاح لا يكتب في أي سكربت أو محادثة):
#   APEX ← Workspace Utilities ← Generative AI Services ← Create
#     AI Provider: Anthropic (Claude)   Static ID: NOONA_AI_CLAUDE   ثم أدخل مفتاح Anthropic في Credential
# السكربت: يتحقق من الخدمة، يفعّل Claude للمؤسسات التي تختارها (بمسؤول كل مؤسسة) مع حصة شهرية من الرموز،
#   يجرب سؤالاً حقيقياً، ويعرض إيقاف Ollama لتحرير الذاكرة للقاعدة.
# السجل: /var/log/noona26_claude.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG=/var/log/noona26_claude.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
info() { echo "  $*"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّله بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم"
[ -f "$ROOT/db/dev/ai_claude_tenant.sql" ] || die "نفّذ git pull أولاً"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) ----" >> "$LOG"
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل"
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}
SYSQ() { printf 'CONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\nSET HEADING OFF FEEDBACK OFF PAGES 0 LINES 300\n%s\nEXIT\n' "$PDB" "$1" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>&1 | grep -v '^$\|^Session altered\|^Connected'; }

step "1/4 خدمة Claude في APEX"
APX=$(SYSQ "SELECT schema FROM dba_registry WHERE comp_id = 'APEX';" | tr -d ' ')
SRV=$(SYSQ "SELECT COUNT(*) FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_CLAUDE';" | tr -dc 0-9)
if [ "${SRV:-0}" = 0 ]; then
  echo
  echo "  لم أجد خدمة NOONA_AI_CLAUDE. أنشئها أولاً (المفتاح تدخله أنت في APEX ولا ترسله لأحد):"
  echo "    1) ادخل APEX بمسؤول مساحة العمل NOONAPLUS"
  echo "    2) Workspace Utilities ← Generative AI Services ← Create"
  echo "    3) AI Provider: Anthropic   Name: NOONA Claude   Static ID: NOONA_AI_CLAUDE"
  echo "    4) Credential: أنشئ جديداً وألصق مفتاح Anthropic (من console.anthropic.com)"
  echo "    5) احفظ ثم أعد تشغيل هذا السكربت"
  exit 1
fi
SYSQ "UPDATE $APX.wwv_remote_servers SET server_timeout = GREATEST(NVL(server_timeout, 0), 120) WHERE static_id = 'NOONA_AI_CLAUDE';
COMMIT;" >> "$LOG"
ok "الخدمة NOONA_AI_CLAUDE موجودة"

step "2/4 الاختيارات"
read -rsp "  كلمة مرور NOONA_APP: " APP_PWD; echo
CONN="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
printf 'WHENEVER SQLERROR EXIT 1\n%s\nSELECT 1 FROM dual;\nEXIT\n' "$CONN" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" >> "$LOG" 2>&1 \
  || die "كلمة مرور NOONA_APP غير صحيحة"
echo "  النموذج: 1) Claude Haiku سريع واقتصادي (موصى به للعروض)  2) Claude Sonnet متوازن  3) Claude Opus الأقوى"
read -rp "  اختر [1]: " c
case "$c" in 2) MODEL=CLAUDE_SONNET ;; 3) MODEL=CLAUDE_OPUS ;; *) MODEL=CLAUDE_HAIKU ;; esac
read -rp "  الحصة الشهرية لكل مؤسسة بالرموز [2000000]: " QUOTA; QUOTA=${QUOTA:-2000000}
[[ "$QUOTA" =~ ^[0-9]+$ ]] && [ "$QUOTA" -ge 1000 ] || die "الحصة رقم 1000 فأكثر"
read -rp "  مسؤولو المؤسسات (أسماء دخول مفصولة بمسافات) [ADMIN]: " USERS; USERS=${USERS:-ADMIN}

step "3/4 تفعيل Claude للمؤسسات"
T=/tmp/noona_claude_$$.sql; cp "$ROOT/db/dev/ai_claude_tenant.sql" "$T"; chmod 644 "$T"
FIRST=""
for U in $USERS; do
  [[ "$U" =~ ^[A-Za-z0-9_.@-]+$ ]] || { info "تخطيت اسماً غير صالح: $U"; continue; }
  OUT=$(printf '%s\n@%s %s %s %s\n' "$CONN" "$T" "$U" "$MODEL" "$QUOTA" | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; sqlplus -S -L /nolog" 2>&1)
  echo "$OUT" >> "$LOG"
  if echo "$OUT" | grep -q "TENANT_OK.*available=Y"; then ok "$U: $MODEL بحصة $QUOTA رمز شهرياً"; FIRST=${FIRST:-$U}
  else info "✗ $U: $(echo "$OUT" | grep -m1 -o 'NOONA-[A-Z]*-[0-9]*: [^[]*\|ORA-[0-9]*: .*' )"; fi
done
rm -f "$T"
[ -n "$FIRST" ] || die "لم يفعل لأي مؤسسة"

step "4/4 سؤال تجريبي"
OUT=$(su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; sqlplus -S -L /nolog" 2>&1 <<EOF
$CONN
SET SERVEROUTPUT ON
DECLARE l CLOB;
BEGIN
  apex_session.create_session(p_app_id => 127, p_page_id => 1, p_username => '$FIRST');
  NOONA_APEX_PKG.post_auth('$FIRST', TRUNC(DBMS_RANDOM.VALUE(1e12, 9e12)));
  l := NOONA_AI_PKG.chat('{"question":"قل: مرحباً من نونا، في جملة واحدة","module":"FIN","pageTitle":"اختبار"}');
  DBMS_OUTPUT.PUT_LINE('CHAT_OK ' || DBMS_LOB.SUBSTR(l, 200, 1));
  ROLLBACK;
  NOONA_APEX_PKG.cleanup_request;
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('CHAT_ERR ' || SQLERRM); ROLLBACK;
END;
/
EXIT
EOF
)
echo "$OUT" >> "$LOG"
if echo "$OUT" | grep -q CHAT_OK; then ok "Claude يرد"
else die "Claude لا يرد: $(echo "$OUT" | grep -m1 CHAT_ERR | cut -c10-300) — راجع المفتاح في خدمة NOONA_AI_CLAUDE"; fi
unset APP_PWD CONN

if command -v ollama >/dev/null 2>&1 && systemctl is-active --quiet ollama; then
  read -rp "  إيقاف Ollama وتحرير ذاكرته للقاعدة؟ (يمكن إعادته لاحقاً) [y/N]: " s
  [[ "$s" =~ ^[yYن]$ ]] && systemctl disable --now ollama >> "$LOG" 2>&1 && ok "أوقف Ollama"
fi
echo
echo "  تم. «اسأل نونا» والملخص التنفيذي يعملان الآن بـ Claude."
echo "  الاستهلاك لكل مؤسسة: المالية ← إعدادات الذكاء الاصطناعي (أو جدول AI_USAGE)."
