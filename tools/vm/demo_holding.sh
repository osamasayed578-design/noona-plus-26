#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | إنشاء المؤسسة التجريبية «مجموعة الريادة القابضة» (نفس سيناريو فيديو الشركة القابضة)
#   التشغيل بحساب root من داخل نسخة المستودع، بعد update_noona26.sh (يتطلب التحديث 48):
#     cd /root/noona-plus-26 && git pull && bash tools/vm/demo_holding.sh
#   يسأل عن كلمة مرور NOONA_APP، وعن كلمة مرور تختارها لمستخدمي المجموعة (لا تحفظ في أي ملف).
#   ينشئ: المؤسسة RYD وثلاث شركات وفروعها، ودليلاً خاصاً للقابضة ودليل مجموعة للتابعتين، وقيوداً معتمدة،
#         ومجموعة تجميع معتمدة. المستخدمان: RYD_ADMIN (مسؤول المؤسسة) و RYD_FIN (المحاسب).
#   إعادة التشغيل لا تكرر البيانات: تعيد تعيين كلمة المرور للمستخدمين فقط.
#   السجل: /var/log/noona26_demo_holding.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SQL="$ROOT/db/demo/demo_holding.sql"
LOG=/var/log/noona26_demo_holding.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم"
[ -f "$SQL" ] || die "الملف $SQL غير موجود: نفّذ git pull أولاً"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) ----" >> "$LOG"

sqlrun() {   # النص من stdin حتى لا تظهر كلمات المرور في قائمة العمليات
  su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd /tmp && sqlplus -S -L /nolog"
}
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل: شغّل خدمة القاعدة ثم أعد المحاولة"
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}

step "كلمات المرور"
read -rsp "  كلمة مرور NOONA_APP (التي أدخلتها عند التثبيت): " APP_PWD; echo
CONN_A="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
printf 'WHENEVER SQLERROR EXIT 1\n%s\nSELECT 1 FROM dual;\nEXIT\n' "$CONN_A" | sqlrun >> "$LOG" 2>&1 || die "كلمة مرور NOONA_APP غير صحيحة"
echo "  اختر كلمة مرور لمستخدمي المجموعة RYD_ADMIN و RYD_FIN"
echo "  (10 أحرف على الأقل، فيها حرف كبير وحرف صغير ورقم، وبلا علامات ' \" &)"
while true; do
  read -rsp "  كلمة المرور: " DEMO_PWD; echo
  read -rsp "  أعد كتابتها: " DEMO_PWD2; echo
  if [ "$DEMO_PWD" != "$DEMO_PWD2" ]; then echo "  غير متطابقتين، أعد المحاولة"; continue; fi
  if [ ${#DEMO_PWD} -lt 10 ] || ! [[ "$DEMO_PWD" =~ [A-Z] ]] || ! [[ "$DEMO_PWD" =~ [a-z] ]] || ! [[ "$DEMO_PWD" =~ [0-9] ]]; then
    echo "  لا تحقق الشروط (10 أحرف، كبير وصغير ورقم)"; continue; fi
  if [[ "$DEMO_PWD" == *[\'\"\&~]* ]]; then echo "  لا تستخدم ' \" & ~"; continue; fi
  break
done

step "إنشاء مجموعة الريادة القابضة (دقيقة تقريباً)"
OUT=$( { printf '%s\nDEFINE DEMO_PWD = "%s"\n' "$CONN_A" "$DEMO_PWD"; cat "$SQL"; printf '\nEXIT\n'; } | sqlrun 2>&1 )
echo "$OUT" | grep -v "DEMO_PWD" >> "$LOG"
unset DEMO_PWD DEMO_PWD2
if echo "$OUT" | grep -q "^DONE:"; then
  ok "تم إنشاء المجموعة: ثلاث شركات وفروعها، القيود معتمدة، والتجميع معتمد"
elif echo "$OUT" | grep -q "^EXISTS:"; then
  ok "المجموعة موجودة مسبقاً؛ أعيد تعيين كلمة المرور فقط"
else
  echo "$OUT" | grep -E "ABORT|ORA-|PLS-|SP2-" | head -5
  die "لم يكتمل الإنشاء (لم يحفظ شيء من الخطوة المتعثرة)"
fi

# ----------------------------------------------------------------------------- مساعد نونا للمجموعة
# المساعد يفعل لكل مؤسسة على حدة: نفعله لمجموعة الريادة بالخدمة المتاحة على الخادم (Claude إن أنشئت، وإلا النموذج المحلي)
step "تفعيل «اسأل نونا» والملخص لمجموعة الريادة"
SYSQ() { printf 'CONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\nSET HEADING OFF FEEDBACK OFF PAGES 0\n%s\nEXIT\n' "$PDB" "$1" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -v '^$\|^Session altered'; }
APX=$(SYSQ "SELECT schema FROM dba_registry WHERE comp_id = 'APEX';" | tr -d ' ')
HAS_CLAUDE=$(SYSQ "SELECT COUNT(*) FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_CLAUDE';" | tr -dc 0-9)
HAS_LOCAL=$(SYSQ "SELECT COUNT(*) FROM $APX.wwv_remote_servers WHERE static_id = 'NOONA_AI_LOCAL';" | tr -dc 0-9)
T=/tmp/noona_ai_demo_$$.sql
AI_OK=0
for U in RYD_ADMIN RYD_FIN; do
  if [ "${HAS_CLAUDE:-0}" != 0 ]; then
    cp "$ROOT/db/dev/ai_claude_tenant.sql" "$T"; chmod 644 "$T"; ARGS="$U CLAUDE_HAIKU 2000000"; KIND="Claude"
  elif [ "${HAS_LOCAL:-0}" != 0 ]; then
    MODEL=$(command -v ollama >/dev/null && ollama list 2>/dev/null | awk 'NR==2{print $1}')
    cp "$ROOT/db/dev/ai_local_tenant.sql" "$T"; chmod 644 "$T"; ARGS="$U ${MODEL:-qwen2.5:3b}"; KIND="النموذج المحلي ${MODEL:-qwen2.5:3b}"
  else
    break
  fi
  R=$(printf '%s\n@%s %s\n' "$CONN_A" "$T" "$ARGS" | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; sqlplus -S -L /nolog" 2>&1)
  echo "$R" >> "$LOG"
  echo "$R" | grep -q "TENANT_OK.*available=Y" && AI_OK=1
  break   # إعداد المؤسسة واحد لكل مستخدميها
done
rm -f "$T"
unset APP_PWD CONN_A
if [ $AI_OK = 1 ]; then ok "«اسأل نونا» مفعل للمجموعة ($KIND)"
elif [ "${HAS_CLAUDE:-0}" = 0 ] && [ "${HAS_LOCAL:-0}" = 0 ]; then
  echo "  لا توجد خدمة ذكاء اصطناعي على الخادم بعد: bash tools/vm/use_claude.sh (Claude) أو bash tools/vm/setup_ai_ollama.sh (محلي)، ثم أعد هذا السكربت"
else
  echo "  تعذر تفعيل المساعد للمجموعة؛ التفاصيل في $LOG أو شغّل: bash tools/vm/fix_ai.sh"
fi

echo
echo "  ادخل من صفحة الدخول المعتادة:"
echo "    RYD_ADMIN  مسؤول المؤسسة (إدارة المؤسسة والمالية وكل الأنظمة)"
echo "    RYD_FIN    سامي المحاسب (المالية في الشركات الثلاث)"
echo "  القوائم الموحدة: المالية ← الشركة القابضة (التجميع) ← القوائم المالية الموحدة ← المجموعة CONS-RYD"
