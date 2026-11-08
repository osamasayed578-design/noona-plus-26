#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تحديث خادم مثبت مسبقاً بأحدث نسخة من المستودع (القاعدة + التطبيقات + الذكاء الاصطناعي)
#   التشغيل بحساب root من داخل نسخة المستودع بعد git pull:
#     cd /root/noona-plus-26 && git pull && bash tools/vm/update_noona26.sh
#   يسأل فقط عن كلمتي مرور NOONA_OWNER و NOONA_APP (لا تحفظان في أي ملف)، ولا يمس البيانات ولا كلمات مرور المستخدمين.
#   الخطوات: نسخ الملفات ← كل ترقيات القاعدة بالترتيب (يعاد تشغيلها بأمان) ← ترقيات الذكاء الاصطناعي ← إعادة الترجمة
#            ← استيراد التطبيقات الخمسة عشر ← حزمة APEX العربية إن لم تثبت ← فحص المساعد المحلي وتشغيله (Ollama) إن كان مثبتاً
#   السجل: /var/log/noona26_update.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=/opt/noona
LOG=/var/log/noona26_update.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}" | tee -a "$LOG"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}" | tee -a "$LOG"; }
info() { echo "  $*" | tee -a "$LOG"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}" | tee -a "$LOG"; echo "  السجل: $LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم: شغّل setup_noona26_ol.sh أولاً"
[ -f "$ROOT/db/upgrade_ai26_01.sql" ] && [ -d "$ROOT/apex/NOONA_MASTER" ] || die "شغّله من نسخة مستودع noona-plus-26 كاملة"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) $(cd "$ROOT" && git log --oneline -1 2>/dev/null) ----" >> "$LOG"

sqlrun() {   # $1 مجلد العمل؛ النص من stdin حتى لا تظهر كلمات المرور في قائمة العمليات
  su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd '$1' && sqlplus -S -L /nolog" >> "$LOG" 2>&1
}
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل: systemctl start oracle-free-26ai (أو خدمة قاعدتك) ثم أعد المحاولة"
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}
PORT_WEB=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT_WEB=${PORT_WEB:-8080}

# ----------------------------------------------------------------------------- كلمات المرور
step "كلمات المرور (التي أدخلتها عند التثبيت)"
read -rsp "  كلمة مرور NOONA_OWNER: " OWNER_PWD; echo
read -rsp "  كلمة مرور NOONA_APP: " APP_PWD; echo
CONN_O="CONNECT NOONA_OWNER/\"$OWNER_PWD\"@//localhost:$PORT_DB/$PDB"
CONN_A="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
printf 'WHENEVER SQLERROR EXIT 1\n%s\nSELECT 1 FROM dual;\nEXIT\n' "$CONN_O" | sqlrun /tmp || die "كلمة مرور NOONA_OWNER غير صحيحة"
printf 'WHENEVER SQLERROR EXIT 1\n%s\nSELECT 1 FROM dual;\nEXIT\n' "$CONN_A" | sqlrun /tmp || die "كلمة مرور NOONA_APP غير صحيحة"
ok "القاعدة $PDB على المنفذ $PORT_DB"

# ----------------------------------------------------------------------------- 1) الملفات
step "1/6 نسخ ملفات النسخة الجديدة"
rm -rf "$WORK/db" "$WORK/apex"; mkdir -p "$WORK"; cp -r "$ROOT/db" "$ROOT/apex" "$WORK/"
chown -R oracle:oinstall "$WORK"; chmod -R u+rwX,go+rX "$WORK"
ok "نسخت إلى $WORK ($(cd "$ROOT" && git log --oneline -1 2>/dev/null | cut -c1-60))"

# ----------------------------------------------------------------------------- 2) ترقيات القاعدة
step "2/6 ترقيات القاعدة (10-30 دقيقة)"
for u in $(ls "$WORK/db"/upgrade_[0-9]*.sql | xargs -n1 basename | sort -V) $(ls "$WORK/db"/upgrade_ai26_*.sql | xargs -n1 basename | sort -V); do
  printf '%s\n@%s\nEXIT\n' "$CONN_O" "$u" | sqlrun "$WORK/db" || die "فشلت $u (التفاصيل في آخر $LOG)"
  info "$u ✓"
done
printf '%s\n@security/41_synonyms_noona_app.sql\nCREATE OR REPLACE SYNONYM NOONA_AI_PKG FOR NOONA_OWNER.NOONA_AI_PKG;\n@ords/api_v1.sql\n@ords/agent_v1.sql\nEXIT\n' \
  "$CONN_A" | sqlrun "$WORK/db"
printf '%s\nEXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE)\nEXIT\n' "$CONN_O" | sqlrun "$WORK/db"
INV=$(printf '%s\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT object_type||%s||object_name FROM user_objects WHERE status <> %s;\nEXIT\n' "$CONN_O" "' '" "'VALID'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -v '^$')
[ -z "$INV" ] || { echo "$INV" | tee -a "$LOG"; die "توجد كائنات غير صالحة في NOONA_OWNER (أعلاه)"; }
ok "القاعدة محدثة، ولا كائنات غير صالحة"

# ----------------------------------------------------------------------------- 3) التطبيقات
step "3/6 استيراد التطبيقات (15 تطبيقاً)"
FAILED=""
for d in $(ls -d "$WORK"/apex/NOONA_*/f[0-9][0-9][0-9]); do
  id=${d##*/f}
  printf '%s\n@../../import_app.sql NOONAPLUS %s\n' "$CONN_A" "$id" | su - oracle -c ". ~/.noona_env; cd '$d' && sqlplus -S -L /nolog" > "$WORK/import_$id.log" 2>&1
  if grep -q "ORA-\|PLS-\|SP2-" "$WORK/import_$id.log"; then FAILED="$FAILED $id"; info "f$id: خطأ (انظر $WORK/import_$id.log)"; else info "f$id ✓"; fi
done
[ -z "$FAILED" ] || die "تعذر استيراد:$FAILED"
ok "كل التطبيقات مستوردة بالتصميم الجديد"

# ----------------------------------------------------------------------------- 4) العربية في APEX
step "4/6 قوائم APEX بالعربية"
APXS=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nALTER SESSION SET CONTAINER=%s;\nSELECT schema FROM dba_registry WHERE comp_id = %s;\nEXIT\n' "$PDB" "'APEX'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -v '^$\|Session' | tr -d ' ')
AR=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nALTER SESSION SET CONTAINER=%s;\nSELECT COUNT(*) FROM %s.wwv_flow_messages$ WHERE message_language = %s AND security_group_id = 10;\nEXIT\n' "$PDB" "$APXS" "'ar'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -v 'Session' | tr -dc 0-9)
if [ "${AR:-0}" -ge 1 ] 2>/dev/null; then ok "اللغة العربية مثبتة في APEX"
elif [ -f "$ROOT/tools/vm/setup_apex_arabic.sh" ]; then bash "$ROOT/tools/vm/setup_apex_arabic.sh" || info "تنبيه: لم تثبت العربية؛ شغّل لاحقاً: bash tools/vm/setup_apex_arabic.sh"
fi

# ----------------------------------------------------------------------------- 5) الذكاء الاصطناعي
step "5/6 الذكاء الاصطناعي"
if command -v ollama >/dev/null 2>&1 || systemctl list-unit-files ollama.service >/dev/null 2>&1; then
  systemctl enable -q ollama 2>/dev/null; systemctl is-active -q ollama || systemctl start ollama
  bash "$ROOT/tools/vm/fix_ai.sh" 2>&1 | tee -a "$LOG"
else
  info "المساعد المحلي (Ollama) غير مثبت. للتجربة المجانية على نفس الخادم:  bash tools/vm/setup_ai_ollama.sh"
  info "أو اضبط خدمة Claude ومفتاحك في APEX حسب docs/ai_setup_26.md"
fi

# ----------------------------------------------------------------------------- 6) التحقق
step "6/6 التحقق"
systemctl restart ords; for i in $(seq 1 40); do curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT_WEB/ords/r/noonaplus/noona_master/home" | grep -q "200\|302" && break; sleep 3; done
CODE=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT_WEB/ords/r/noonaplus/noona_master/home")
[[ "$CODE" =~ ^(200|302)$ ]] || die "ORDS لا يستجيب (HTTP $CODE) - journalctl -u ords -n 50"
IP=$(hostname -I | awk '{print $1}')
ok "التحديث اكتمل: http://$IP:$PORT_WEB/ords/r/noonaplus/noona_master/home"
echo "  حدّث صفحة المتصفح (Ctrl+F5) لتظهر الواجهة الجديدة."
