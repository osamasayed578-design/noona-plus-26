#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تجهيز بيئة المختبرين: حذف كل المؤسسات وإنشاء تسع مؤسسات تجريبية ببيانات كاملة
#   cd /root/noona-plus-26 && git pull && bash tools/vm/update_noona26.sh && bash tools/vm/reset_nine_orgs.sh
#
#   1) نسخة احتياطية كاملة أولاً (backup_noona26.sh)؛ إن فشلت يتوقف ولا يحذف شيئاً
#   2) حذف كل المؤسسات والشركات ومستخدميها وبياناتها (تبقى المنصة ومستخدموها والإعدادات والبيانات المرجعية)
#   3) إنشاء المؤسسات التسع (db/demo/nine/orgs.txt) + مجموعة الريادة القابضة بثلاث شركات، لكل مؤسسة مسؤول
#      وكلمة مرور عشوائية تولد هنا ولا تحفظ في المستودع
#   4) تحميل بيانات كل نشاط بحيث تمتلئ شاشات أنظمته، ثم الأرشيف والمراسلات ومركز الإدارة وشروح الشاشات
#   5) طباعة جدول المسؤولين وكلمات المرور، وحفظه في /root/noona_testers_accounts.txt (للمستخدم root فقط)
#
#   يسأل عن كلمتي مرور NOONA_OWNER و NOONA_APP (لا تحفظان)، ويطلب كتابة «احذف» للتأكيد.
#   السجل: /var/log/noona26_reset_nine.log
#   الاستعادة عند الحاجة: bash tools/vm/backup_noona26.sh --restore <ملف النسخة المطبوع في الخطوة 1>
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=/tmp/noona_nine_$$
LOG=/var/log/noona26_reset_nine.log
OUTF=/root/noona_testers_accounts.txt
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_WARN='\033[1;33m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}"; echo "== $*" >> "$LOG"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
WARN_N=0
warn() { echo -e "${C_WARN}  ! $*${C_0}"; echo "WARN $*" >> "$LOG"; WARN_N=$((WARN_N + 1)); }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; rm -rf "$WORK"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم"
[ -f "$ROOT/db/demo/nine/orgs.txt" ] && [ -f "$ROOT/db/demo/nine/00_purge_all_tenants.sql" ] || die "ملفات التجهيز غير موجودة: نفّذ git pull أولاً"
command -v openssl >/dev/null || die "الأداة openssl غير مثبتة (dnf install -y openssl)"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) $(cd "$ROOT" && git log --oneline -1 2>/dev/null) ----" >> "$LOG"

sql() {   # $1 = سطر الاتصال؛ نص SQL من stdin (كلمات المرور لا تظهر في قائمة العمليات)؛ المخرجات إلى stdout
  { echo "$1"; cat; } | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd '$WORK/db' && sqlplus -S -L /nolog" 2>&1
}
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل: شغّل خدمة القاعدة ثم أعد المحاولة"
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}
PORT_WEB=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT_WEB=${PORT_WEB:-8080}

# ----------------------------------------------------------------------------- التأكيد
echo
echo -e "${C_ERR}  تحذير: سيحذف هذا السكربت كل المؤسسات والشركات المسجلة على الخادم وكل بياناتها ومستخدميها.${C_0}"
echo "  تؤخذ نسخة احتياطية كاملة أولاً، ثم تنشأ المؤسسات التجريبية التسع للمختبرين."
read -rp "  اكتب «احذف» للمتابعة: " CONFIRM
[ "$CONFIRM" = "احذف" ] || [ "$CONFIRM" = "DELETE" ] || die "ألغي: لم يحذف شيء"

step "كلمات المرور (التي أدخلتها عند التثبيت)"
read -rsp "  كلمة مرور NOONA_OWNER: " OWNER_PWD; echo
read -rsp "  كلمة مرور NOONA_APP: " APP_PWD; echo
CONN_O="CONNECT NOONA_OWNER/\"$OWNER_PWD\"@//localhost:$PORT_DB/$PDB"
CONN_A="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
unset OWNER_PWD APP_PWD
mkdir -p "$WORK"; cp -r "$ROOT/db" "$WORK/"; chown -R oracle:oinstall "$WORK"; chmod -R u+rwX,go+rX "$WORK"; chmod 711 "$WORK"
printf 'WHENEVER SQLERROR EXIT 1\nSELECT 1 FROM dual;\nEXIT\n' | sql "$CONN_O" > /dev/null || die "كلمة مرور NOONA_OWNER غير صحيحة"
printf 'WHENEVER SQLERROR EXIT 1\nSELECT 1 FROM dual;\nEXIT\n' | sql "$CONN_A" > /dev/null || die "كلمة مرور NOONA_APP غير صحيحة"
PLT_USER=$(printf "SET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT username FROM sec_user WHERE user_type = 'PLATFORM_ADMIN' AND status_code = 'ACTIVE' ORDER BY id FETCH FIRST 1 ROWS ONLY;\nEXIT\n" \
  | sql "$CONN_O" | tr -d ' \n')
[ -n "$PLT_USER" ] || die "لا يوجد مستخدم مسؤول منصة نشط"
ok "القاعدة $PDB، مسؤول المنصة $PLT_USER"

# ----------------------------------------------------------------------------- 1) النسخة الاحتياطية
step "1/5 نسخة احتياطية كاملة قبل الحذف"
BK_OUT=$(bash "$ROOT/tools/vm/backup_noona26.sh" 2>&1); RC=$?
echo "$BK_OUT" >> "$LOG"
[ $RC = 0 ] || { echo "$BK_OUT" | tail -3; die "فشلت النسخة الاحتياطية؛ لم يحذف شيء"; }
BK_FILE=$(echo "$BK_OUT" | grep -o '/[^ ]*noona_[0-9_]*\.dmp' | tail -1)
ok "النسخة: ${BK_FILE:-$(ls -t /opt/noona/backup/noona_*.dmp 2>/dev/null | head -1)}"

# ----------------------------------------------------------------------------- 2) الحذف
step "2/5 حذف كل المؤسسات وبياناتها (دقيقة إلى خمس دقائق)"
OUT=$(echo "@demo/nine/00_purge_all_tenants.sql" | sql "$CONN_O"); echo "$OUT" >> "$LOG"
echo "$OUT" | grep -q "PURGE_OK" || { echo "$OUT" | grep -E "PURGE_FAILED|ORA-" | head -3; die "تعذر الحذف (أعيدت القيود والمشغلات كما كانت)"; }
ok "$(echo "$OUT" | grep -o 'PURGE_OK.*')"

# ----------------------------------------------------------------------------- كلمات المرور العشوائية
gen_pwd() { echo "Nn$(openssl rand -hex 4)#$(( RANDOM % 90 + 10 ))"; }
declare -A PWD_OF NAME_OF
prep_demo() {   # $1 البيانات التجريبية، $2 بادئة المستخدمين -> demo/nine_<demo>_<pfx>.sql (أسماء مستخدمين فريدة لكل مؤسسة)
  sed -e "s/'DEMO_\([A-Z0-9_]*\)'/'$2_\1'/g" -e "s/demo\.\([a-z0-9]*\)@noona\.local/$(echo "$2" | tr A-Z a-z).\1@noona.local/g" \
      "$ROOT/db/demo/$1.sql" > "$WORK/db/demo/nine_$1_$2.sql"
  chown oracle:oinstall "$WORK/db/demo/nine_$1_$2.sql"; chmod 644 "$WORK/db/demo/nine_$1_$2.sql"
}
run_demo() {    # $1 الرمز، $2 البيانات، $3 البادئة، $4 المسؤول
  [ -f "$ROOT/db/demo/$2.sql" ] || { warn "$1: الملف $2 غير موجود"; return; }
  prep_demo "$2" "$3"
  local R; R=$(printf '@demo/nine_%s_%s.sql %s\nEXIT\n' "$2" "$3" "$4" | sql "$CONN_A")
  echo "[$1 $2] $R" >> "$LOG"
  if echo "$R" | grep -qE "ORA-|PLS-|SP2-"; then warn "$1 $2: $(echo "$R" | grep -m1 -oE '(ORA|PLS|SP2)-[0-9]+[^[]{0,140}')"
  else echo "    · $2"; fi
}

# ----------------------------------------------------------------------------- 3) المؤسسات
step "3/5 إنشاء المؤسسات وبياناتها (20-40 دقيقة)"
ORDER=()
while IFS='|' read -r code adm nar nen cco cnm mods brc brn demos pfx; do
  [ -n "$code" ] && [ "${code:0:1}" != "#" ] || continue
  P=$(gen_pwd); PWD_OF[$adm]=$P; NAME_OF[$adm]="$nar"; ORDER+=("$adm")
  echo -e "  ${C_STEP}$code${C_0} $nar"
  R=$(printf 'DEFINE ORG_PWD = "%s"\nDEFINE PLT_USER = "%s"\n@demo/nine/10_provision_org.sql "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"\n' \
        "$P" "$PLT_USER" "$code" "$adm" "$nar" "$nen" "$cco" "$cnm" "$mods" "$brc" "$brn" | sql "$CONN_A")
  echo "$R" | grep -v "ORG_PWD" >> "$LOG"
  if ! echo "$R" | grep -q "ORG_OK"; then warn "$code: تعذر الإنشاء $(echo "$R" | grep -m1 -oE '(ORA|PLS)-[0-9]+[^[]{0,140}')"; unset "PWD_OF[$adm]"; continue; fi
  echo "$R" | grep -q "WARN activation" && warn "$code: $(echo "$R" | grep -m1 'WARN activation')"
  for d in $demos; do run_demo "$code" "$d" "$pfx" "$adm"; done
done < "$ROOT/db/demo/nine/orgs.txt"

# مجموعة الريادة القابضة: ثلاث شركات متعددة النشاط بفروعها + التجميع
echo -e "  ${C_STEP}RYD${C_0} مجموعة الريادة القابضة"
P=$(gen_pwd)
R=$( { printf 'DEFINE DEMO_PWD = "%s"\n' "$P"; cat "$ROOT/db/demo/demo_holding.sql"; printf '\nEXIT\n'; } | sql "$CONN_A")
echo "$R" | grep -v "DEMO_PWD" >> "$LOG"
if echo "$R" | grep -qE "^(DONE|EXISTS):"; then
  PWD_OF[RYD_ADMIN]=$P; PWD_OF[RYD_FIN]=$P
  NAME_OF[RYD_ADMIN]="مجموعة الريادة القابضة (مسؤول المؤسسة)"; NAME_OF[RYD_FIN]="مجموعة الريادة القابضة (المحاسب)"
  ORDER+=(RYD_ADMIN RYD_FIN)
  for d in demo_hr demo_common; do run_demo RYD "$d" RYD RYD_ADMIN; done
else
  warn "RYD: $(echo "$R" | grep -m1 -E 'ABORT|ORA-|PLS-')"
fi

# ----------------------------------------------------------------------------- 4) سجل التغييرات وشروح الشاشات
step "4/5 سجل التغييرات وشروح الشاشات في قسم المساعدة"
OUT=$(printf 'SET SERVEROUTPUT ON\nDECLARE n NUMBER; BEGIN NOONA_CORE_PKG.begin_system; n := NOONA_ENG_PKG.track_defaults; NOONA_CORE_PKG.end_system; DBMS_OUTPUT.PUT_LINE(%s || n); EXCEPTION WHEN OTHERS THEN NOONA_CORE_PKG.end_system; DBMS_OUTPUT.PUT_LINE(%s || SQLERRM); END;\n/\nEXIT\n' "'TRACK '" "'TRACK_WARN '" | sql "$CONN_O")
echo "$OUT" >> "$LOG"; ok "$(echo "$OUT" | grep -o 'TRACK.*' | head -1)"
if [ -f "$WORK/db/demo/nine/20_help_seed.sql" ]; then
  OUT=$(echo "@demo/nine/20_help_seed.sql" | sql "$CONN_O"); echo "$OUT" >> "$LOG"
  echo "$OUT" | grep -q "HELP_OK" && ok "$(echo "$OUT" | grep -o 'HELP_OK.*')" || warn "شروح الشاشات: $(echo "$OUT" | grep -m1 -oE 'ORA-[0-9]+[^[]{0,120}')"
fi
unset CONN_O CONN_A

# ----------------------------------------------------------------------------- 5) المسؤولون وكلمات المرور
step "5/5 حسابات المختبرين"
HOST=$(hostname -I 2>/dev/null | awk '{print $1}')
{
  echo "NOONA PLUS 26 - حسابات المختبرين ($(date '+%F %H:%M'))"
  echo "صفحة الدخول: http://${HOST:-<عنوان الخادم>}:$PORT_WEB/ords/r/noonaplus/noona_master/home (أو رابط HTTPS الخاص بك)"
  echo "غيّر كلمة المرور بعد أول دخول من «تغيير كلمة المرور» في قائمة المستخدم."
  echo "------------------------------------------------------------------------------"
  printf '%-12s %-20s %s\n' "المستخدم" "كلمة المرور" "المؤسسة"
  for u in "${ORDER[@]}"; do
    [ -n "${PWD_OF[$u]}" ] && printf '%-12s %-20s %s\n' "$u" "${PWD_OF[$u]}" "${NAME_OF[$u]}"
  done
  echo "------------------------------------------------------------------------------"
  echo "مستخدمون إضافيون في كل مؤسسة (المعتمد، الموارد البشرية، المندوبون...) بلا كلمة مرور؛ يعينها مسؤول المؤسسة من شاشة المستخدمين."
} > "$OUTF"
chmod 600 "$OUTF"
cat "$OUTF"
unset PWD_OF
rm -rf "$WORK"
echo
ok "اكتمل التجهيز. نسخة من الجدول في $OUTF (لـ root فقط)؛ احذفها بعد تسليم الحسابات: rm $OUTF"
[ -n "$BK_FILE" ] && echo "  للرجوع لما قبل الحذف: bash tools/vm/backup_noona26.sh --restore $BK_FILE"
[ "$WARN_N" -gt 0 ] && echo "  توجد $WARN_N تنبيهات أعلاه (التفاصيل في $LOG)"
exit 0
