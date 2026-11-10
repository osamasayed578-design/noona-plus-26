#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | ربط بريد النظام (SMTP) - رموز التحقق، استعادة كلمة المرور، تنبيهات الاشتراك، الفواتير، المراسلات
#   التشغيل بحساب root من داخل نسخة المستودع، بعد update_noona26.sh (يتطلب الترقية 52):
#     cd /root/noona-plus-26 && git pull && bash tools/vm/mail_setup.sh
#   يسأل عن خادم البريد وكلمة مرور البريد (لا تحفظ في أي ملف ولا تظهر في قائمة العمليات)، ثم يرسل رسالة تجربة؛
#   لا يفعل البريد في النظام إلا بعد وصولها.
#   Gmail: الخادم smtp.gmail.com والمنفذ 587 (STARTTLS)، وكلمة المرور «كلمة مرور التطبيقات» (App Password) لا كلمة الحساب
#   Zoho : smtp.zoho.com 587 ، Outlook/Microsoft 365: smtp.office365.com 587
#   السجل: /var/log/noona26_mail.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG=/var/log/noona26_mail.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) ----" >> "$LOG"
sq() { su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd /tmp && sqlplus -S -L /nolog"; }
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل: شغّل خدمة القاعدة ثم أعد المحاولة"
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}
PORT_WEB=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT_WEB=${PORT_WEB:-8080}
IP=$(hostname -I | awk '{print $1}')

step "بيانات البريد"
read -rp "  خادم SMTP [smtp.gmail.com]: " HOST; HOST=${HOST:-smtp.gmail.com}
read -rp "  المنفذ [587]: " PORT; PORT=${PORT:-587}
[[ "$PORT" =~ ^[0-9]+$ ]] || die "المنفذ رقم"
case "$PORT" in 465) TLS=Y;; 25) TLS=N;; *) TLS=STARTTLS;; esac
read -rp "  التشفير STARTTLS / Y (SSL) / N [${TLS}]: " T; TLS=${T:-$TLS}
read -rp "  البريد المرسل (اسم المستخدم): " MAILUSER
[[ "$MAILUSER" == *@* ]] || die "اكتب البريد كاملاً"
read -rsp "  كلمة مرور البريد (لـ Gmail: كلمة مرور التطبيقات المكونة من 16 حرفاً): " MAILPWD; echo
[ -n "$MAILPWD" ] || die "كلمة المرور فارغة"
[[ "$MAILPWD" == *"'"* || "$MAILPWD" == *"~"* ]] && die "كلمة المرور فيها ' أو ~ (غير مدعومة في هذا السكربت)"
MAILPWD=${MAILPWD// /}     # كلمة مرور تطبيقات Gmail تعرض بمسافات
read -rp "  اسم المرسل الظاهر [نونا بلس]: " FROMNAME; FROMNAME=${FROMNAME:-نونا بلس}
read -rp "  رابط النظام حتى /ords [http://$IP:$PORT_WEB/ords]: " BASEURL; BASEURL=${BASEURL:-http://$IP:$PORT_WEB/ords}
read -rp "  بريد يصله تنبيه طلبات الاشتراك الجديدة [$MAILUSER]: " NOTIFY; NOTIFY=${NOTIFY:-$MAILUSER}
read -rp "  أرسل رسالة التجربة إلى [$NOTIFY]: " TESTTO; TESTTO=${TESTTO:-$NOTIFY}
read -rsp "  كلمة مرور NOONA_APP (التي أدخلتها عند التثبيت): " APP_PWD; echo
CONN_A="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
printf 'WHENEVER SQLERROR EXIT 1\n%s\nSELECT 1 FROM dual;\nEXIT\n' "$CONN_A" | sq >> "$LOG" 2>&1 || die "كلمة مرور NOONA_APP غير صحيحة"

step "إعداد APEX (الخادم والتشفير وصلاحية الاتصال)"
OUT=$( { cat <<SQL
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=$PDB;
SET SERVEROUTPUT ON FEEDBACK OFF
WHENEVER SQLERROR EXIT 1
DECLARE
  l_apx  VARCHAR2(30);
  l_host VARCHAR2(200) := q'~$HOST~';
  l_port NUMBER := $PORT;
  l_tls  VARCHAR2(10) := q'~$TLS~';
BEGIN
  SELECT schema INTO l_apx FROM dba_registry WHERE comp_id = 'APEX';
  FOR u IN (SELECT l_apx n FROM dual UNION ALL SELECT 'NOONA_OWNER' FROM dual) LOOP
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(host => l_host, lower_port => l_port, upper_port => l_port,
      ace => xs\$ace_type(privilege_list => xs\$name_list('connect'), principal_name => u.n, principal_type => xs_acl.ptype_db));
    DBMS_NETWORK_ACL_ADMIN.append_host_ace(host => l_host,
      ace => xs\$ace_type(privilege_list => xs\$name_list('resolve'), principal_name => u.n, principal_type => xs_acl.ptype_db));
  END LOOP;
  APEX_INSTANCE_ADMIN.set_parameter('SMTP_HOST_ADDRESS', l_host);
  APEX_INSTANCE_ADMIN.set_parameter('SMTP_HOST_PORT', TO_CHAR(l_port));
  APEX_INSTANCE_ADMIN.set_parameter('SMTP_USERNAME', q'~$MAILUSER~');
  APEX_INSTANCE_ADMIN.set_parameter('SMTP_PASSWORD', q'~$MAILPWD~');
  APEX_INSTANCE_ADMIN.set_parameter('SMTP_TLS_MODE', l_tls);
  -- شهادات الجذر من نظام التشغيل (قاعدة 23ai/26ai) للاتصال المشفر
  IF l_tls <> 'N' THEN APEX_INSTANCE_ADMIN.set_parameter('WALLET_PATH', 'system:'); END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('SMTP_OK');
END;
/
EXIT
SQL
} | sq 2>&1 )
echo "$OUT" | grep -v -i "password" >> "$LOG"
unset MAILPWD
echo "$OUT" | grep -q SMTP_OK || { echo "$OUT" | grep -E "ORA-|PLS-" | head -3; die "تعذر إعداد APEX"; }
ok "خادم البريد $HOST:$PORT ($TLS)"

step "رسالة التجربة إلى $TESTTO"
R=$( { cat <<SQL
$CONN_A
SET SERVEROUTPUT ON FEEDBACK OFF
WHENEVER SQLERROR EXIT 1
UPDATE plt_setting_def SET default_value = q'~$MAILUSER~' WHERE setting_key = 'MAIL.FROM';
UPDATE plt_setting_def SET default_value = q'~$FROMNAME~' WHERE setting_key = 'MAIL.FROM_NAME';
UPDATE plt_setting_def SET default_value = q'~$BASEURL~' WHERE setting_key = 'PLATFORM.BASE_URL';
UPDATE plt_setting_def SET default_value = q'~$NOTIFY~' WHERE setting_key = 'PLATFORM.NOTIFY_EMAIL';
UPDATE plt_setting_def SET default_value = 'Y' WHERE setting_key = 'MAIL.ENABLED';
COMMIT;
DECLARE n NUMBER;
BEGIN
  n := NOONA_MAIL_PKG.send(q'~$TESTTO~', 'رسالة تجربة من نونا بلس',
         NOONA_MAIL_PKG.wrap('بريد النظام يعمل', '<p>هذه رسالة تجربة؛ وصولها يعني أن رموز التحقق واستعادة كلمة المرور وتنبيهات الاشتراك ستصل لعملائك.</p>',
                             q'~$BASEURL~' || '/r/noonaplus/noona_master/home', 'فتح النظام'));
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('QUEUED ' || n);
END;
/
EXIT
SQL
} | sq 2>&1 )
echo "$R" >> "$LOG"
echo "$R" | grep -q QUEUED || { echo "$R" | grep -E "ORA-|PLS-" | head -3; die "تعذر وضع الرسالة في قائمة الإرسال"; }
echo "  APEX يرسل قائمة البريد كل بضع دقائق؛ ننتظر حتى 6 دقائق..."
RES=""
for i in $(seq 1 36); do
  sleep 10
  RES=$(printf '%s\nSET HEADING OFF FEEDBACK OFF PAGES 0 LINES 400\nSELECT (SELECT COUNT(*) FROM apex_mail_log WHERE mail_to = q%s AND last_updated_on > SYSDATE - 1/24) || %s || (SELECT MAX(SUBSTR(mail_send_error, 1, 300)) FROM apex_mail_queue) FROM dual;\nEXIT\n' \
        "$CONN_A" "'~$TESTTO~'" "'|'" | sq 2>/dev/null | tr -d '\n')
  [ "${RES%%|*}" -gt 0 ] 2>/dev/null && break
  [ -n "${RES#*|}" ] && break
done
unset APP_PWD
if [ "${RES%%|*}" -gt 0 ] 2>/dev/null; then
  ok "أرسلت رسالة التجربة؛ افتح بريد $TESTTO (وتحقق من البريد المزعج)"
  ok "البريد مفعل: رموز التحقق بالبريد، «نسيت كلمة المرور»، تنبيهات الاشتراك، فواتير الاشتراك"
  echo "  لتفعيل رمز التحقق بالبريد في التسجيل الذاتي: لوحة المنصة ← الأسعار والتسجيل ← SIGNUP.OTP_MODE = EMAIL"
else
  printf '%s\nUPDATE plt_setting_def SET default_value = %s WHERE setting_key = %s;\nCOMMIT;\nEXIT\n' "$CONN_A" "'N'" "'MAIL.ENABLED'" | sq >> "$LOG" 2>&1
  echo "  خطأ الإرسال: ${RES#*|}"
  echo "  أسباب شائعة: كلمة مرور التطبيقات غير صحيحة، أو المنفذ 587 مغلق في الجدار الناري لمزود الخادم، أو اسم الخادم خطأ"
  die "لم تصل رسالة التجربة؛ البريد غير مفعل في النظام"
fi
