#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تجهيز خادم Oracle Linux 8/9 بأمر واحد:
#   Oracle AI Database 26ai (Free أو Enterprise Edition) + APEX 26.x + ORDS + Java 21 + نونا 26 (القاعدة، التطبيقات، البيانات التجريبية)
#
# التشغيل (بحساب root أو sudo) من داخل نسخة المستودع على الخادم:
#   sudo bash tools/vm/setup_noona26_ol.sh
#
# الملفات: يبحث في /opt/noona/downloads ثم مجلد هذا السكربت عن:
#   - حزمة القاعدة  oracle-*database-free-26ai-*.elN.rpm أو oracle-*database-ee-26ai-*.elN.rpm (N = إصدار النظام 8 أو 9)
#   - Java (اختياري) jdk-21*.rpm من Oracle، وإلا يثبت OpenJDK 21
#   - APEX          apex_26*.zip أو apex-latest.zip                    (وإلا ينزل apex-latest.zip تلقائياً)
#   - ORDS          ords-*.zip أو ords-latest.zip                      (وإلا ينزل ords-latest.zip تلقائياً)
# كلمات المرور تطلب أثناء التشغيل ولا تكتب في أي ملف. يعاد تشغيله بأمان: الخطوات المكتملة تتخطى.
# السجل الكامل: /var/log/noona26_setup.log
# =============================================================================
set -o pipefail
umask 077

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DL=/opt/noona/downloads
WORK=/opt/noona
LOG=/var/log/noona26_setup.log
PDB=""          # يكتشف بعد التهيئة: FREEPDB1 للنسخة المجانية، ORCLPDB1 للنسخة المؤسسية
PORT_DB=1521
PORT_WEB=8080
APEX_DIR=/opt/oracle/apex
ORDS_DIR=/opt/oracle/ords
ORDS_CFG=/opt/oracle/ords-config

C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}" | tee -a "$LOG"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}" | tee -a "$LOG"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}" | tee -a "$LOG"; echo "  السجل الكامل: $LOG"; exit 1; }
info() { echo "  $*" | tee -a "$LOG"; }

[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root: sudo bash $0"
[ -f "$ROOT/db/install.sql" ] && [ -d "$ROOT/apex" ] || die "شغّل السكربت من داخل نسخة مستودع noona-plus-26 (لم أجد db/install.sql)"
mkdir -p "$DL" "$WORK"; touch "$LOG"; chmod 600 "$LOG"
echo "---- $(date) ----" >> "$LOG"

# ----------------------------------------------------------------------------- 0) فحص الجهاز
step "0/10 فحص الجهاز"
. /etc/os-release
OLV="${VERSION_ID%%.*}"
[ "$ID" = "ol" ] || info "تنبيه: النظام ليس Oracle Linux ($ID) - قد تختلف أسماء الحزم"
[ "$OLV" = 8 ] || [ "$OLV" = 9 ] || die "الإصدار المدعوم Oracle Linux 8 أو 9 (الحالي $VERSION_ID)"
MEM=$(awk '/MemTotal/{print int($2/1024/1024+0.5)}' /proc/meminfo)
OPTFREE=$(df -BG --output=avail /opt | tail -1 | tr -dc 0-9)
info "Oracle Linux $VERSION_ID · الذاكرة ${MEM}G · المتاح في /opt ${OPTFREE}G"
[ "$MEM" -ge 4 ] || die "الذاكرة أقل من 4 جيجابايت"
[ "$OPTFREE" -ge 20 ] || die "المساحة المتاحة في /opt أقل من 20 جيجابايت"
curl -s -o /dev/null -m 15 https://yum.oracle.com || info "تنبيه: لا اتصال بالإنترنت؛ يجب أن تكون كل الملفات في $DL"
ok "الجهاز مناسب"

# ----------------------------------------------------------------------------- كلمات المرور
ask_pwd() {   # $1 المتغير  $2 الوصف  $3 أقل طول
  local a b
  while true; do
    read -rsp "  $2: " a; echo
    read -rsp "  أعد كتابتها: " b; echo
    [ "$a" = "$b" ] || { echo "  غير متطابقتين، أعد المحاولة"; continue; }
    [ ${#a} -ge "$3" ] || { echo "  الطول $3 أحرف على الأقل"; continue; }
    [[ "$a" =~ [A-Z] && "$a" =~ [a-z] && "$a" =~ [0-9] ]] || { echo "  يلزم حرف كبير وصغير ورقم"; continue; }
    case "$a" in *[[:space:]]*|*\"*|*\'*|*\\*|*\$*|*\`*) echo "  لا تستخدم المسافة أو علامات التنصيص أو \\ أو \$ أو \`"; continue;; esac
    printf -v "$1" '%s' "$a"; break
  done
}
step "كلمات المرور (لا تحفظ في أي ملف)"
ask_pwd SYS_PWD   "كلمة مرور SYS/SYSTEM لقاعدة البيانات" 8
ask_pwd OWNER_PWD "كلمة مرور المخطط NOONA_OWNER" 10
ask_pwd APP_PWD   "كلمة مرور المخطط NOONA_APP" 10
ask_pwd APEXA_PWD "كلمة مرور مسؤول APEX ومطوّر مساحة العمل NOONA (يلزم فيها رمز مثل # أو !)" 10
[[ "$APEXA_PWD" =~ [^A-Za-z0-9] ]] || die "كلمة مرور APEX يلزم فيها رمز مثل # أو !"
ask_pwd NADM_PWD  "كلمة مرور الدخول لنونا للمستخدم ADMIN" 10
ask_pwd NPLT_PWD  "كلمة مرور الدخول لنونا للمستخدم PLATFORM" 10
read -rp "  تحميل البيانات التجريبية (شركة تجريبية بكل الأنظمة وسنتين سابقتين)? [Y/n]: " DEMO; DEMO=${DEMO:-Y}
ORDS_PUB_PWD="Ords#$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')"
APEX_PUB_PWD="Apex#$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')"

# ----------------------------------------------------------------------------- 1) الحزم وJava
step "1/10 الحزم الأساسية وJava 21"
dnf -y install unzip zip curl tar >>"$LOG" 2>&1 || die "تعذر تثبيت الحزم الأساسية (dnf)"
JDK=$(ls "$DL"/jdk-21*_linux-x64_bin.rpm 2>/dev/null | sort -V | tail -1)
if [ -n "$JDK" ]; then
  dnf -y localinstall "$JDK" >>"$LOG" 2>&1 || die "تعذر تثبيت $(basename "$JDK")"
  JAVA_HOME=$(ls -d /usr/lib/jvm/jdk-21* 2>/dev/null | sort -V | tail -1)
else
  dnf -y install java-21-openjdk-headless >>"$LOG" 2>&1 || die "تعذر تثبيت Java 21؛ ضع jdk-21*_linux-x64_bin.rpm في $DL"
  JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
fi
[ -x "$JAVA_HOME/bin/java" ] || die "لم أجد Java 21"
"$JAVA_HOME/bin/java" -version 2>&1 | grep -q '"21\.' || die "إصدار Java ليس 21"
"$JAVA_HOME/bin/java" -version 2>&1 | head -1 | tee -a "$LOG"
PRE=""
for p in oracle-ai-database-preinstall-26ai oracle-database-preinstall-26ai oracle-database-preinstall-23ai; do
  if rpm -q "$p" >/dev/null 2>&1 || dnf -y install "$p" >>"$LOG" 2>&1; then PRE=$p; break; fi
done
if [ -z "$PRE" ]; then
  f=$(ls "$DL"/oracle-*preinstall*.el"$OLV"*.rpm 2>/dev/null | head -1)
  [ -n "$f" ] && dnf -y localinstall "$f" >>"$LOG" 2>&1 && PRE=$(basename "$f")
fi
[ -n "$PRE" ] || die "تعذر تثبيت حزمة التهيئة preinstall. فعّل المستودع: dnf config-manager --enable ol${OLV}_appstream ol${OLV}_baseos_latest ثم أعد التشغيل"
ok "Java 21 وحزمة التهيئة ($PRE)"

# ----------------------------------------------------------------------------- 2) قاعدة البيانات
step "2/10 Oracle AI Database 26ai Free"
find_init() { ls /etc/init.d/ 2>/dev/null | grep -E '^oracle.*(free|ee|26ai|23ai)' | grep -v preinstall | head -1; }
if [ -z "$(find_init)" ]; then
  RPM=$(ls "$DL"/oracle-*database-free*.el"$OLV"*.rpm "$DL"/oracle-*database-ee*.el"$OLV"*.rpm 2>/dev/null | grep -v preinstall | head -1)
  if [ -z "$RPM" ]; then
    WRONG=$(ls "$DL"/oracle-*database-*.rpm 2>/dev/null | grep -v preinstall | head -1)
    [ -n "$WRONG" ] && die "الحزمة $(basename "$WRONG") ليست لنظامك (Oracle Linux $OLV يحتاج حزمة .el${OLV}.)"
    die "ضع حزمة القاعدة 26ai (Free أو EE) لنظام el${OLV} في $DL ثم أعد التشغيل"
  fi
  info "تثبيت $(basename "$RPM") (5-15 دقيقة)"
  dnf -y localinstall "$RPM" >>"$LOG" 2>&1 || die "فشل تثبيت حزمة القاعدة"
fi
SVC=$(find_init); INIT=/etc/init.d/$SVC
[ -n "$SVC" ] || die "لم أجد سكربت تهيئة القاعدة في /etc/init.d"
case "$SVC" in *free*) EDITION=FREE ;; *) EDITION=EE ;; esac
# اسم الجهاز يجب أن يحل لعنوانه قبل التهيئة
grep -qw "$(hostname -s)" /etc/hosts || echo "$(hostname -I | awk '{print $1}') $(hostname) $(hostname -s)" >> /etc/hosts
if ! grep -qE '^[A-Za-z0-9_]+:/opt/oracle' /etc/oratab 2>/dev/null; then
  info "تهيئة القاعدة ($EDITION): 15-60 دقيقة حسب الإصدار والجهاز"
  (export DB_PASSWORD="$SYS_PWD"; printf '%s\n%s\n' "$SYS_PWD" "$SYS_PWD" | "$INIT" configure) >>"$LOG" 2>&1 || die "فشلت تهيئة القاعدة"
fi
SID=$(grep -E '^[A-Za-z0-9_]+:/opt/oracle' /etc/oratab | head -1 | cut -d: -f1)
OH=$(grep -E '^[A-Za-z0-9_]+:/opt/oracle' /etc/oratab | head -1 | cut -d: -f2)
[ -n "$SID" ] && [ -x "$OH/bin/sqlplus" ] || die "لم أجد القاعدة في /etc/oratab بعد التهيئة"
systemctl daemon-reload; systemctl enable "$SVC" >>"$LOG" 2>&1; systemctl start "$SVC" >>"$LOG" 2>&1
cat > /home/oracle/.noona_env <<EOF
export ORACLE_HOME=$OH
export ORACLE_SID=$SID
export PATH=\$ORACLE_HOME/bin:\$PATH
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
EOF
chown oracle:oinstall /home/oracle/.noona_env; chmod 644 /home/oracle/.noona_env
grep -q noona_env /home/oracle/.bash_profile 2>/dev/null || echo '. ~/.noona_env' >> /home/oracle/.bash_profile

# تشغيل SQL*Plus بحساب oracle؛ النص من stdin (كلمات المرور لا تظهر في قائمة العمليات)
sqlrun() {   # $1 مجلد العمل
  su - oracle -c ". ~/.noona_env; cd '$1' && sqlplus -S -L /nolog" 2>&1 | tee -a "$LOG"
  return "${PIPESTATUS[0]}"
}
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "لم أجد قاعدة PDB"
sys_pdb() { printf 'WHENEVER SQLERROR EXIT SQL.SQLCODE\nCONNECT / AS SYSDBA\nSET FEEDBACK OFF\nALTER SESSION SET CONTAINER=%s;\nSET FEEDBACK ON\n' "$PDB"; }
echo "$(sys_pdb)
ALTER PLUGGABLE DATABASE $PDB SAVE STATE;
SELECT 'PDB_OK' FROM dual;
EXIT" | sqlrun /tmp | grep -q PDB_OK || die "القاعدة لا تعمل أو $PDB غير مفتوحة"
ok "القاعدة تعمل ($EDITION · $SID · $PDB · $OH)"

# ----------------------------------------------------------------------------- 3) APEX
step "3/10 APEX"
APEX_VER=$(echo "$(sys_pdb)
SET HEADING OFF FEEDBACK OFF
SELECT version FROM dba_registry WHERE comp_id = 'APEX' AND status = 'VALID';
EXIT" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -oE '^ *[0-9]+\.[0-9]+\.[0-9.]+' | tr -d ' ' | head -1)
if [[ "$APEX_VER" != 2[6-9].* ]]; then
  Z=$(ls "$DL"/apex_2[6-9]*.zip "$DL"/apex-latest.zip 2>/dev/null | head -1)
  if [ -z "$Z" ]; then
    info "تنزيل APEX (apex-latest.zip)"
    curl -fL -o "$DL/apex-latest.zip" https://download.oracle.com/otn_software/apex/apex-latest.zip >>"$LOG" 2>&1 || die "تعذر تنزيل APEX؛ ضع apex_26.x.zip في $DL"
    Z=$DL/apex-latest.zip
  fi
  rm -rf "$APEX_DIR"; mkdir -p /opt/oracle; unzip -q -o "$Z" -d /opt/oracle || die "ملف APEX تالف"
  chown -R oracle:oinstall "$APEX_DIR"
  info "تثبيت APEX في $PDB (15-30 دقيقة)"
  echo "$(sys_pdb)
@apexins.sql SYSAUX SYSAUX TEMP /i/
EXIT" | sqlrun "$APEX_DIR" >/dev/null || die "فشل تثبيت APEX"
fi
APEX_SCHEMA=$(echo "$(sys_pdb)
SET HEADING OFF FEEDBACK OFF
SELECT schema FROM dba_registry WHERE comp_id = 'APEX';
EXIT" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -oE 'APEX_[0-9]+' | head -1)
[ -n "$APEX_SCHEMA" ] || die "لم أجد مخطط APEX في القاعدة"
# مسؤول APEX (INTERNAL) وحساب البوابة وصلاحية الاتصال الخارجي (مزود الذكاء الاصطناعي)
echo "$(sys_pdb)
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY \"$APEX_PUB_PWD\" ACCOUNT UNLOCK;
BEGIN
  APEX_UTIL.SET_SECURITY_GROUP_ID(10);
  BEGIN
    APEX_UTIL.CREATE_USER(p_user_name => 'ADMIN', p_email_address => 'admin@noona.local', p_web_password => '$APEXA_PWD',
                          p_developer_privs => 'ADMIN', p_change_password_on_first_use => 'N');
  EXCEPTION WHEN OTHERS THEN
    APEX_UTIL.EDIT_USER(p_user_id => APEX_UTIL.GET_USER_ID('ADMIN'), p_user_name => 'ADMIN', p_web_password => '$APEXA_PWD',
                        p_new_password => '$APEXA_PWD', p_change_password_on_first_use => 'N');
  END;
  COMMIT;
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(host => 'api.anthropic.com',
    ace => xs\$ace_type(privilege_list => xs\$name_list('http', 'connect', 'resolve'), principal_name => '$APEX_SCHEMA',
                        principal_type => xs_acl.ptype_db));
END;
/
EXIT" | sqlrun /tmp >/dev/null || die "تعذر ضبط مسؤول APEX"
ok "APEX ${APEX_VER:-installed} (المخطط $APEX_SCHEMA)"

# ----------------------------------------------------------------------------- 4) ORDS
step "4/10 ORDS"
if [ ! -x "$ORDS_DIR/bin/ords" ]; then
  Z=$(ls "$DL"/ords-*.zip 2>/dev/null | head -1)
  if [ -z "$Z" ]; then
    info "تنزيل ORDS (ords-latest.zip)"
    curl -fL -o "$DL/ords-latest.zip" https://download.oracle.com/otn_software/java/ords/ords-latest.zip >>"$LOG" 2>&1 || die "تعذر تنزيل ORDS؛ ضع ords-xx.zip في $DL"
    Z=$DL/ords-latest.zip
  fi
  rm -rf "$ORDS_DIR"; mkdir -p "$ORDS_DIR"; unzip -q -o "$Z" -d "$ORDS_DIR" || die "ملف ORDS تالف"
fi
mkdir -p "$ORDS_CFG" /var/log/ords; chown -R oracle:oinstall "$ORDS_DIR" "$ORDS_CFG" /var/log/ords
if [ ! -f "$ORDS_CFG/databases/default/pool.xml" ]; then
  printf '%s\n%s\n' "$SYS_PWD" "$ORDS_PUB_PWD" | su oracle -s /bin/bash -c "export JAVA_HOME=$JAVA_HOME; cd /var/log/ords && \
    $ORDS_DIR/bin/ords --config $ORDS_CFG install --admin-user SYS --db-hostname localhost --db-port $PORT_DB --db-servicename $PDB \
    --feature-db-api false --feature-rest-enabled-sql false --feature-sdw false --gateway-mode proxied \
    --gateway-user APEX_PUBLIC_USER --proxy-user --log-folder /var/log/ords --password-stdin" >>"$LOG" 2>&1 || die "فشل تثبيت ORDS"
fi
cat > /etc/systemd/system/ords.service <<EOF
[Unit]
Description=Oracle REST Data Services (NOONA PLUS)
After=network.target $SVC.service
Wants=$SVC.service

[Service]
User=oracle
Group=oinstall
Environment=JAVA_HOME=$JAVA_HOME
Environment=_JAVA_OPTIONS=-Xms512m -Xmx1024m
ExecStart=$ORDS_DIR/bin/ords --config $ORDS_CFG serve --port $PORT_WEB --apex-images $APEX_DIR/images
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
chmod 644 /etc/systemd/system/ords.service
systemctl daemon-reload; systemctl enable ords >>"$LOG" 2>&1; systemctl restart ords
ok "ORDS خدمة systemd على المنفذ $PORT_WEB"

# ----------------------------------------------------------------------------- 5) ملفات نونا
step "5/10 ملفات نونا"
rm -rf "$WORK/db" "$WORK/apex"; cp -r "$ROOT/db" "$ROOT/apex" "$WORK/"
chown -R oracle:oinstall "$WORK"; chmod -R u+rwX,go+rX "$WORK"
ok "نسخت إلى $WORK"

# ----------------------------------------------------------------------------- 6) المخططات وقاعدة نونا
step "6/10 مخططات نونا والجداول والحزم"
sed -e "s/^DEFINE owner_pwd = .*/DEFINE owner_pwd = '$OWNER_PWD'/" -e "s/^DEFINE app_pwd .*/DEFINE app_pwd   = '$APP_PWD'/" \
    "$WORK/db/admin/00_create_schemas.sql" > "$WORK/db/admin/_schemas_run.sql"; chown oracle "$WORK/db/admin/_schemas_run.sql"
echo "$(sys_pdb)
@admin/_schemas_run.sql
@admin/01_sys_grants.sql
EXIT" | sqlrun "$WORK/db" >/dev/null; RC=$?; rm -f "$WORK/db/admin/_schemas_run.sql"; [ $RC = 0 ] || die "تعذر إنشاء المخططات"
INSTALLED=$(printf 'CONNECT NOONA_OWNER/"%s"@//localhost:%s/%s\nSET HEADING OFF FEEDBACK OFF\nSELECT COUNT(*) FROM user_tables WHERE table_name = %s;\nEXIT\n' \
  "$OWNER_PWD" "$PORT_DB" "$PDB" "'GL_JOURNAL'" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -dc 0-9)
CONN_O="CONNECT NOONA_OWNER/\"$OWNER_PWD\"@//localhost:$PORT_DB/$PDB"
CONN_A="CONNECT NOONA_APP/\"$APP_PWD\"@//localhost:$PORT_DB/$PDB"
if [ "$INSTALLED" != 1 ]; then
  info "install.sql (5-15 دقيقة)"
  printf '%s\n@install.sql\nEXIT\n' "$CONN_O" | sqlrun "$WORK/db" > "$WORK/install_out.log" || die "فشل install.sql - راجع $WORK/install_out.log"
elif [ "${RUN_UPGRADES:-0}" = 1 ]; then
  info "القاعدة مثبتة سابقاً: تشغيل الترقيات (RUN_UPGRADES=1)"
  for u in $(ls "$WORK/db"/upgrade_[0-9]*.sql | sort -V); do
    printf '%s\n@%s\nEXIT\n' "$CONN_O" "$(basename "$u")" | sqlrun "$WORK/db" >/dev/null || die "فشلت $(basename "$u")"
  done
else
  info "جداول نونا مثبتة سابقاً (لتحديث قاعدة قديمة شغّل السكربت مع RUN_UPGRADES=1)"
fi
# بذرة المؤسسة التجريبية عند غيابها (تتراجع كاملة إن فشلت، فتعاد بأمان)
TEN=$(echo "$(sys_pdb)
SET HEADING OFF FEEDBACK OFF
SELECT 'TEN=' || COUNT(*) FROM noona_owner.plt_tenant;
EXIT" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | grep -oE 'TEN=[0-9]+' | cut -d= -f2)
if [ "${TEN:-0}" = 0 ]; then
  printf '%s\n@seed/90_demo_tenant_DEV_ONLY.sql\nEXIT\n' "$CONN_O" | sqlrun "$WORK/db" >/dev/null || die "فشلت بذرة المؤسسة"
fi
for u in $(ls "$WORK/db"/upgrade_ai26_*.sql | sort -V); do
  printf '%s\n@%s\nEXIT\n' "$CONN_O" "$(basename "$u")" | sqlrun "$WORK/db" >/dev/null || die "فشلت $(basename "$u")"
done
printf '%s\n@security/41_synonyms_noona_app.sql\nCREATE OR REPLACE SYNONYM NOONA_AI_PKG FOR NOONA_OWNER.NOONA_AI_PKG;\n@ords/api_v1.sql\n@ords/agent_v1.sql\nEXIT\n' \
  "$CONN_A" | sqlrun "$WORK/db" >/dev/null
INV=$(printf '%s\nSET HEADING OFF FEEDBACK OFF\nSELECT COUNT(*) FROM user_objects WHERE status <> %s;\nEXIT\n' "$CONN_O" "'VALID'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -dc 0-9)
[ "${INV:-1}" = 0 ] || die "توجد $INV كائنات غير صالحة في NOONA_OWNER"
ok "قاعدة نونا جاهزة، ولا كائنات غير صالحة"

# ----------------------------------------------------------------------------- 7) مساحة العمل
step "7/10 مساحة عمل APEX (NOONAPLUS)"
echo "$(sys_pdb)
DECLARE l NUMBER;
BEGIN
  SELECT COUNT(*) INTO l FROM apex_workspaces WHERE workspace = 'NOONAPLUS';
  IF l = 0 THEN APEX_INSTANCE_ADMIN.ADD_WORKSPACE(p_workspace => 'NOONAPLUS', p_primary_schema => 'NOONA_APP'); END IF;
  APEX_UTIL.SET_WORKSPACE('NOONAPLUS');
  BEGIN
    APEX_UTIL.CREATE_USER(p_user_name => 'NOONA', p_web_password => '$APEXA_PWD', p_email_address => 'noona@noona.local',
                          p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL', p_change_password_on_first_use => 'N');
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  COMMIT;
END;
/
EXIT" | sqlrun /tmp >/dev/null || die "تعذر إنشاء مساحة العمل"
ok "مساحة العمل NOONAPLUS ومطورها NOONA"

# ----------------------------------------------------------------------------- 8) التطبيقات
step "8/10 استيراد التطبيقات (15 تطبيقاً)"
FAILED=""
for d in $(ls -d "$WORK"/apex/NOONA_*/f[0-9][0-9][0-9] | awk -F/ '{print $NF" "$0}' | sort | cut -d' ' -f2); do
  id=${d##*/f}
  printf '%s\n@../../import_app.sql NOONAPLUS %s\n' "$CONN_A" "$id" | sqlrun "$d" > "$WORK/import_$id.log" 2>&1
  if grep -q "ORA-\|PLS-\|SP2-" "$WORK/import_$id.log"; then FAILED="$FAILED $id"; info "f$id: خطأ (انظر $WORK/import_$id.log)"; else info "f$id ✓"; fi
done
[ -z "$FAILED" ] || die "تعذر استيراد:$FAILED"
ok "كل التطبيقات مستوردة"

# ----------------------------------------------------------------------------- 9) مستخدمو نونا والبيانات التجريبية
step "9/10 مستخدمو نونا$( [[ $DEMO =~ ^[Yy] ]] && echo ' والبيانات التجريبية')"
for u in ADMIN:$NADM_PWD PLATFORM:$NPLT_PWD; do
  printf '%s\n@reset_password.sql %s "%s"\nEXIT\n' "$CONN_O" "${u%%:*}" "${u#*:}" | sqlrun "$WORK/db" >/dev/null \
    || die "تعذر ضبط كلمة مرور ${u%%:*} (10 أحرف، كبير وصغير ورقم، ولا تحتوي اسم المستخدم)"
done
if [[ $DEMO =~ ^[Yy] ]]; then
  for f in $(grep -o '@demo/[a-z_0-9]*\.sql' "$WORK/db/demo_windows.bat" | tr -d @); do
    info "$f"
    printf '%s\n@%s ADMIN\nEXIT\n' "$CONN_A" "$f" | sqlrun "$WORK/db" > "$WORK/demo_$(basename "$f" .sql).log" 2>&1
    grep -q "^ERROR\|ORA-" "$WORK/demo_$(basename "$f" .sql).log" && info "   تنبيه: راجع $WORK/demo_$(basename "$f" .sql).log"
  done
fi
ok "تم"

# ----------------------------------------------------------------------------- 10) الشبكة والتحقق
step "10/10 جدار الحماية والتحقق"
if systemctl is-active -q firewalld; then
  firewall-cmd -q --permanent --add-port=$PORT_DB/tcp; firewall-cmd -q --permanent --add-port=$PORT_WEB/tcp; firewall-cmd -q --reload
fi
for i in $(seq 1 30); do curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT_WEB/ords/r/noonaplus/noona_master/home" | grep -q "200\|302" && break; sleep 5; done
CODE=$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$PORT_WEB/ords/r/noonaplus/noona_master/home")
IP=$(hostname -I | awk '{print $1}')
[[ "$CODE" =~ ^(200|302)$ ]] || die "ORDS لا يستجيب (HTTP $CODE) - journalctl -u ords -n 50"
ok "النظام يعمل"
cat <<EOF | tee -a "$LOG"

====================================================================
 نونا 26 جاهز
   الدخول للنظام : http://$IP:$PORT_WEB/ords/r/noonaplus/noona_master/home   (ADMIN أو PLATFORM)
   تطوير APEX     : http://$IP:$PORT_WEB/ords/r/apex/workspace-sign-in   (مساحة NOONAPLUS، المستخدم NOONA)
   إدارة APEX     : http://$IP:$PORT_WEB/ords/apex_admin                 (ADMIN)
   SQL*Plus       : NOONA_APP@//$IP:$PORT_DB/$PDB
   الخدمات        : systemctl status $SVC ords
   الذكاء الاصطناعي: اضبط خدمة Claude ومفتاحك في APEX حسب docs/ai_setup_26.md
====================================================================
EOF
