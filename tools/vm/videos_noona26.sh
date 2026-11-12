#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | نشر فيديوهات الشرح لكل مؤسسة وربطها بقسم المساعدة
#   الفيديوهات لا تحفظ في المستودع (حجمها كبير). انقل مجلدها إلى الخادم ثم:
#     bash tools/vm/videos_noona26.sh /root/noona_videos
#   المجلد: مجلد لكل مؤسسة باسم رمزها (NFC، RED، ...) وفيه ملفات <الرمز>_<الكتالوج>_<النظام>.mp4 مثل NFC_m01_fin.mp4
#   ينسخها إلى /opt/noona/videos ويخدمها nginx على /noona-videos/ (يتطلب https_noona26.sh)،
#   ثم يربط لكل مؤسسة فيديو كل نظام: زر «فيديو الشرح» في مساعدة أي شاشة من النظام يفتح فيديو مؤسسة المستخدم.
#   يسأل عن كلمة مرور NOONA_OWNER فقط. السجل: /var/log/noona26_videos.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin"
set -o pipefail
SRC="${1:-/root/noona_videos}"
DST=/opt/noona/videos
LOG=/var/log/noona26_videos.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_0='\033[0m'
ok()  { echo -e "${C_OK}  ✓ $*${C_0}"; }
die() { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; exit 1; }
[ "$(id -u)" = 0 ] || die "شغّله بحساب root"
[ -d "$SRC" ] || die "المجلد $SRC غير موجود (انقل مجلد الفيديوهات إلى الخادم أولاً)"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) ----" >> "$LOG"

mkdir -p "$DST"; cp -r "$SRC"/. "$DST"/; find "$DST" -type d -exec chmod 755 {} \; ; find "$DST" -type f -exec chmod 644 {} \;
command -v restorecon >/dev/null && restorecon -R "$DST" >/dev/null 2>&1
command -v chcon >/dev/null && chcon -R -t httpd_sys_content_t "$DST" >/dev/null 2>&1
N=$(find "$DST" -name '*.mp4' | wc -l); [ "$N" -gt 0 ] || die "لا توجد ملفات mp4 في $SRC"
ok "نسخت $N فيديو إلى $DST"

if [ -f /etc/nginx/noona/proxy.conf ]; then
  grep -q "noona-videos" /etc/nginx/noona/proxy.conf || sed -i '/^location = \/ /a location /noona-videos/ { alias /opt/noona/videos/; types { video/mp4 mp4; } add_header Cache-Control "public, max-age=86400"; }' /etc/nginx/noona/proxy.conf
  nginx -t >> "$LOG" 2>&1 && systemctl reload nginx && ok "nginx يخدم الفيديوهات على /noona-videos/"
else
  echo "  تنبيه: nginx غير مضبوط؛ شغّل bash tools/vm/https_noona26.sh ليعمل رابط الفيديو"
fi

PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
PORT_DB=$(su - oracle -c ". ~/.noona_env; lsnrctl status" 2>/dev/null | grep -o 'PORT=[0-9]*' | head -1 | cut -d= -f2); PORT_DB=${PORT_DB:-1521}
read -rsp "  كلمة مرور NOONA_OWNER: " OWNER_PWD; echo
SQLF=$(mktemp /tmp/noona_vid_XXXX.sql); chmod 644 "$SQLF"
{
  echo "SET DEFINE OFF"; echo "SET SERVEROUTPUT ON"; echo "WHENEVER SQLERROR EXIT FAILURE ROLLBACK"
  echo "DECLARE n NUMBER := 0;"
  echo "  PROCEDURE v(p_org VARCHAR2, p_app VARCHAR2, p_url VARCHAR2) IS l_t NUMBER; BEGIN"
  echo "    SELECT MAX(id) INTO l_t FROM plt_tenant WHERE tenant_code = p_org; IF l_t IS NULL THEN RETURN; END IF;"
  echo "    DELETE FROM eng_help WHERE tenant_id = l_t AND app_alias = p_app AND page_id = 0;"
  echo "    INSERT INTO eng_help (tenant_id, app_alias, page_id, title, video_url) VALUES (l_t, p_app, 0, 'فيديو النظام', p_url); n := n + 1;"
  echo "  END v;"
  echo "BEGIN NOONA_CORE_PKG.begin_system;"
  # فيديو واحد لكل نظام في كل مؤسسة: الأقدم رقماً في الكتالوج أولاً (الرئيسي)
  find "$DST" -name '*.mp4' | sort -r | while read -r f; do
    b=$(basename "$f" .mp4); org=${b%%_*}; app=NOONA_$(echo "${b##*_}" | tr a-z A-Z)
    echo "  v('$org', '$app', '/noona-videos/${f#$DST/}');"
  done
  echo "  COMMIT; NOONA_CORE_PKG.end_system; DBMS_OUTPUT.PUT_LINE('VIDEOS_OK ' || n);"
  echo "EXCEPTION WHEN OTHERS THEN ROLLBACK; NOONA_CORE_PKG.end_system; RAISE; END;"; echo "/"; echo "EXIT"
} > "$SQLF"
OUT=$( { echo "CONNECT NOONA_OWNER/\"$OWNER_PWD\"@//localhost:$PORT_DB/$PDB"; echo "@$SQLF"; } \
  | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd /tmp && sqlplus -S -L /nolog" 2>&1 )
unset OWNER_PWD; rm -f "$SQLF"; echo "$OUT" >> "$LOG"
echo "$OUT" | grep -q VIDEOS_OK || { echo "$OUT" | grep -m2 "ORA-"; die "تعذر ربط الفيديوهات بالمساعدة"; }
ok "ربطت $(echo "$OUT" | grep -o 'VIDEOS_OK [0-9]*' | cut -d' ' -f2) فيديو بمساعدة الشاشات (زر «؟» ← فيديو الشرح)"
