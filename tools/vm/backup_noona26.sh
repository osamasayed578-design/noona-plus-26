#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | النسخ الاحتياطي لبيانات النظام (Data Pump) واستعادتها
#   bash tools/vm/backup_noona26.sh              نسخة الآن
#   bash tools/vm/backup_noona26.sh --install    نسخة يومية تلقائية 02:30 (systemd timer) مع الاحتفاظ 14 يوماً
#   bash tools/vm/backup_noona26.sh --list       النسخ الموجودة
#   bash tools/vm/backup_noona26.sh --restore <ملف.dmp>   استعادة (تستبدل البيانات الحالية؛ تطلب تأكيداً)
# المحتوى: كل بيانات نونا (مخطط NOONA_OWNER: المؤسسات والشركات والقيود والمستندات المخزنة في القاعدة والإعدادات).
#   التطبيقات تعاد من المستودع (update_noona26.sh)، والملفات المخزنة خارج القاعدة (تخزين خارجي للأرشيف) تنسخ مع مجلدها.
# لا يحتاج كلمات مرور: يعمل بحساب oracle على الخادم نفسه.
# نسخة خارج الخادم (موصى بها): انسخ المجلد دورياً، أو عيّن OCI_BUCKET مع أداة oci المضبوطة لرفع كل نسخة إلى Object Storage:
#   OCI_BUCKET=noona-backup bash tools/vm/backup_noona26.sh --install
# السجل: /var/log/noona26_backup.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
DIR=${BACKUP_DIR:-/opt/noona/backup}
KEEP=${KEEP_DAYS:-14}
LOG=/var/log/noona26_backup.log
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_0='\033[0m'
ok()  { echo -e "${C_OK}  ✓ $*${C_0}"; echo "$(date '+%F %T') OK $*" >> "$LOG"; }
die() { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "$(date '+%F %T') ERR $*" >> "$LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّله بحساب root"
[ -f /home/oracle/.noona_env ] || die "النظام غير مثبت على هذا الخادم"
touch "$LOG"; chmod 600 "$LOG"
mkdir -p "$DIR"; chown oracle:oinstall "$DIR"; chmod 750 "$DIR"

PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل"
ora() { su - oracle -c ". ~/.noona_env; export ORACLE_PDB_SID=$PDB NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd '$DIR' && $1"; }
printf "CREATE OR REPLACE DIRECTORY NOONA_BACKUP AS '%s';\nEXIT\n" "$DIR" | ora "sqlplus -S / as sysdba" >> "$LOG" 2>&1

case "$1" in
  --install)
    cat > /etc/systemd/system/noona-backup.service <<EOF
[Unit]
Description=NOONA PLUS daily backup
[Service]
Type=oneshot
Environment=BACKUP_DIR=$DIR KEEP_DAYS=$KEEP OCI_BUCKET=${OCI_BUCKET:-}
ExecStart=/bin/bash $ROOT/tools/vm/backup_noona26.sh
EOF
    cat > /etc/systemd/system/noona-backup.timer <<EOF
[Unit]
Description=NOONA PLUS daily backup 02:30
[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true
[Install]
WantedBy=timers.target
EOF
    systemctl daemon-reload && systemctl enable --now noona-backup.timer >/dev/null 2>&1 || die "تعذر تفعيل المؤقت"
    ok "النسخ اليومي مفعل 02:30 في $DIR (الاحتفاظ $KEEP يوماً)"
    systemctl list-timers noona-backup.timer --no-pager | head -3
    exit 0 ;;
  --list)
    ls -lh "$DIR"/noona_*.dmp 2>/dev/null || echo "  لا توجد نسخ في $DIR"
    exit 0 ;;
  --restore)
    F="$2"; [ -f "$F" ] || F="$DIR/$2"; [ -f "$F" ] || die "الملف غير موجود: $2"
    echo "  ستستبدل الاستعادة كل بيانات نونا الحالية بمحتوى $(basename "$F")."
    echo "  خذ نسخة الآن أولاً إن لم تكن متأكداً (bash $0)."
    read -rp "  اكتب RESTORE للمتابعة: " A; [ "$A" = RESTORE ] || die "ألغيت الاستعادة"
    [ "$(dirname "$(readlink -f "$F")")" = "$(readlink -f "$DIR")" ] || { cp "$F" "$DIR/"; chown oracle:oinstall "$DIR/$(basename "$F")"; }
    systemctl stop ords 2>/dev/null
    ora "impdp \\\"'/ as sysdba'\\\" directory=NOONA_BACKUP dumpfile=$(basename "$F") logfile=restore_$(date +%Y%m%d_%H%M).log schemas=NOONA_OWNER table_exists_action=REPLACE" >> "$LOG" 2>&1
    RC=$?
    printf "EXEC DBMS_UTILITY.COMPILE_SCHEMA('NOONA_OWNER', FALSE);\nEXIT\n" | ora "sqlplus -S / as sysdba" >> "$LOG" 2>&1
    systemctl start ords 2>/dev/null
    [ $RC -le 5 ] && ok "تمت الاستعادة من $(basename "$F") (التفاصيل في $DIR/restore_*.log)" || die "فشلت الاستعادة؛ راجع $DIR/restore_*.log"
    exit 0 ;;
esac

# ----------------------------------------------------------------------------- نسخة الآن
T=$(date +%Y%m%d_%H%M)
FREE=$(df -Pm "$DIR" | awk 'NR==2{print $4}')
[ "${FREE:-0}" -gt 1024 ] || die "المساحة الحرة في $DIR أقل من 1 جيجا"
ora "expdp \\\"'/ as sysdba'\\\" schemas=NOONA_OWNER directory=NOONA_BACKUP dumpfile=noona_$T.dmp logfile=noona_$T.log flashback_time=systimestamp" >> "$LOG" 2>&1
RC=$?
[ -s "$DIR/noona_$T.dmp" ] && grep -q "successfully completed\|completed with" "$DIR/noona_$T.log" || die "فشل النسخ (رمز $RC)؛ راجع $DIR/noona_$T.log"
gzip -f "$DIR/noona_$T.log"
ok "نسخة $DIR/noona_$T.dmp ($(du -h "$DIR/noona_$T.dmp" | cut -f1))"
# الاحتفاظ
find "$DIR" -maxdepth 1 -name 'noona_*.dmp' -mtime +"$KEEP" -delete
find "$DIR" -maxdepth 1 -name 'noona_*.log.gz' -mtime +"$KEEP" -delete
# نسخة خارج الخادم (اختياري)
if [ -n "$OCI_BUCKET" ]; then
  if command -v oci >/dev/null 2>&1; then
    oci os object put --bucket-name "$OCI_BUCKET" --file "$DIR/noona_$T.dmp" --name "noona_$T.dmp" --force >> "$LOG" 2>&1 \
      && ok "رفعت إلى Object Storage: $OCI_BUCKET" || echo "  تنبيه: تعذر الرفع إلى $OCI_BUCKET (راجع إعداد oci)"
  else
    echo "  تنبيه: OCI_BUCKET محدد لكن أداة oci غير مثبتة"
  fi
fi
