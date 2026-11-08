#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | مراقبة صحة الخادم مع علاج تلقائي
#   bash tools/vm/health_noona26.sh            فحص الآن وعرض النتيجة
#   bash tools/vm/health_noona26.sh --install  فحص تلقائي كل 10 دقائق (systemd timer)
# يفحص: القاعدة مفتوحة، المستمع، ORDS يرد، المساحة الحرة، الذاكرة، آخر نسخة احتياطية.
# يعالج تلقائياً: يشغل القاعدة إن توقفت، ويعيد تشغيل ORDS إن لم يرد.
# السجل: /var/log/noona26_health.log (المشاكل فقط، مع سطر حالة كل ساعة)
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin:/usr/sbin"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG=/var/log/noona26_health.log
QUIET=0; [ -n "$INVOCATION_ID" ] && QUIET=1          # تحت systemd: بلا ألوان
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_W='\033[1;33m'; C_0='\033[0m'
[ $QUIET = 1 ] && { C_OK=; C_ERR=; C_W=; C_0=; }
BAD=0; MSG=""
ok()   { [ $QUIET = 0 ] && echo -e "${C_OK}  ✓ $*${C_0}"; }
warn() { echo -e "${C_W}  ! $*${C_0}"; MSG="$MSG | $*"; }
bad()  { echo -e "${C_ERR}  ✗ $*${C_0}"; MSG="$MSG | $*"; BAD=$((BAD+1)); }

[ "$(id -u)" = 0 ] || { echo "شغّله بحساب root"; exit 1; }
[ -f /home/oracle/.noona_env ] || { echo "النظام غير مثبت على هذا الخادم"; exit 1; }
touch "$LOG"; chmod 600 "$LOG"

if [ "$1" = "--install" ]; then
  cat > /etc/systemd/system/noona-health.service <<EOF
[Unit]
Description=NOONA PLUS health check
[Service]
Type=oneshot
ExecStart=/bin/bash $ROOT/tools/vm/health_noona26.sh
EOF
  cat > /etc/systemd/system/noona-health.timer <<EOF
[Unit]
Description=NOONA PLUS health check every 10 minutes
[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
[Install]
WantedBy=timers.target
EOF
  systemctl daemon-reload && systemctl enable --now noona-health.timer >/dev/null 2>&1 && echo "  ✓ المراقبة مفعلة كل 10 دقائق؛ السجل $LOG"
  exit 0
fi

sq() { printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\n%s\nEXIT\n' "$1" | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>&1 | grep -v '^$' | head -3; }

# 1) القاعدة
PDB=$(sq "SELECT name||':'||open_mode FROM v\$pdbs WHERE name <> 'PDB\$SEED' ORDER BY con_id FETCH FIRST 1 ROWS ONLY;" | tr -d ' ')
if [[ "$PDB" == *":READWRITE"* ]]; then ok "القاعدة ${PDB%%:*} مفتوحة"
else
  bad "القاعدة لا تعمل (${PDB:-لا رد})"
  SVC=$(ls /etc/init.d/ 2>/dev/null | grep -E '^oracle.*(free|ee|26ai|23ai)' | grep -v preinstall | head -1)
  if [ -n "$SVC" ]; then
    /etc/init.d/"$SVC" start >> "$LOG" 2>&1
    sq "ALTER PLUGGABLE DATABASE ALL OPEN;" >/dev/null
    PDB=$(sq "SELECT name||':'||open_mode FROM v\$pdbs WHERE name <> 'PDB\$SEED' ORDER BY con_id FETCH FIRST 1 ROWS ONLY;" | tr -d ' ')
    [[ "$PDB" == *":READWRITE"* ]] && warn "علاج: شغلت القاعدة ${PDB%%:*}" || bad "تعذر تشغيل القاعدة تلقائياً"
  fi
fi

# 2) المستمع
if su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -q "Services Summary"; then ok "المستمع يعمل"
else
  su - oracle -c ". ~/.noona_env; lsnrctl start" >> "$LOG" 2>&1
  warn "علاج: شغلت المستمع"
fi

# 3) ORDS
PORT_WEB=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT_WEB=${PORT_WEB:-8080}
code() { curl -s -o /dev/null -m 20 -w '%{http_code}' "http://localhost:$PORT_WEB/ords/"; }
C=$(code)
if [[ "$C" =~ ^(200|301|302|303)$ ]]; then ok "ORDS يرد على المنفذ $PORT_WEB ($C)"
else
  systemctl restart ords 2>>"$LOG"; sleep 40; C=$(code)
  [[ "$C" =~ ^(200|301|302|303)$ ]] && warn "علاج: أعدت تشغيل ORDS (كان لا يرد)" || bad "ORDS لا يرد ($C) حتى بعد إعادة التشغيل"
fi

# 4) المساحة
for m in / /opt; do
  U=$(df -P "$m" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}')
  [ -z "$U" ] && continue
  if [ "$U" -ge 95 ]; then bad "المساحة في $m ممتلئة ${U}%"
  elif [ "$U" -ge 85 ]; then warn "المساحة في $m ${U}%"
  else ok "المساحة في $m ${U}%"; fi
done

# 5) الذاكرة
AV=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
[ "${AV:-0}" -lt 300 ] && warn "الذاكرة المتاحة ${AV} ميجا فقط" || ok "الذاكرة المتاحة ${AV} ميجا"

# 6) آخر نسخة احتياطية
B=$(ls -t /opt/noona/backup/noona_*.dmp 2>/dev/null | head -1)
if [ -z "$B" ]; then warn "لا توجد نسخة احتياطية (فعّلها: bash tools/vm/backup_noona26.sh --install)"
elif [ -n "$(find "$B" -mtime +2)" ]; then warn "آخر نسخة احتياطية أقدم من يومين: $(basename "$B")"
else ok "آخر نسخة احتياطية $(basename "$B")"; fi

# السجل: المشاكل دائماً، وسطر حالة مرة كل ساعة
if [ -n "$MSG" ]; then echo "$(date '+%F %T') ${BAD} مشكلة${MSG}" >> "$LOG"
elif [ "$(date +%M)" -lt 10 ]; then echo "$(date '+%F %T') سليم" >> "$LOG"; fi
[ $QUIET = 0 ] && { [ $BAD = 0 ] && echo -e "${C_OK}  النظام سليم${C_0}" || echo -e "${C_ERR}  مشاكل: $BAD (السجل $LOG)${C_0}"; }
exit $BAD
