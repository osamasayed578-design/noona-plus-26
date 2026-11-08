#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تثبيت اللغة العربية لرسائل APEX على خادم مثبت مسبقاً
#   بدونها تظهر قوائم التقارير التفاعلية بالإنجليزية (Actions، Columns، Filter، Search...)
#   التشغيل بحساب root:   bash tools/vm/setup_apex_arabic.sh
#   يحتاج ملف apex_26.x.zip (أو apex-latest.zip) في /opt/noona/downloads، وإن لم يوجد ينزّله
# =============================================================================
set -o pipefail
LOG=/var/log/noona26_setup.log
DL=/opt/noona/downloads
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_0='\033[0m'
die() { echo -e "${C_ERR}  ✗ $*${C_0}" | tee -a "$LOG"; exit 1; }
[ "$(id -u)" = 0 ] || die "شغّل السكربت بحساب root"
[ -f /home/oracle/.noona_env ] || die "شغّل setup_noona26_ol.sh أولاً"
echo "---- $(date) apex arabic ----" >> "$LOG"
PDB=$(printf 'CONNECT / AS SYSDBA\nSET HEADING OFF FEEDBACK OFF PAGES 0\nSELECT name FROM v$pdbs WHERE name <> %s ORDER BY con_id FETCH FIRST 1 ROWS ONLY;\nEXIT\n' "'PDB\$SEED'" \
  | su - oracle -c ". ~/.noona_env; sqlplus -S -L /nolog" 2>/dev/null | tr -d ' \n')
[ -n "$PDB" ] || die "القاعدة لا تعمل"
Z=$(ls "$DL"/apex_2[6-9]*.zip "$DL"/apex-latest.zip 2>/dev/null | head -1)
if [ -z "$Z" ]; then
  echo "  تنزيل APEX (حوالي 330 ميجابايت)"
  mkdir -p "$DL"; curl -fL -o "$DL/apex-latest.zip" https://download.oracle.com/otn_software/apex/apex-latest.zip >>"$LOG" 2>&1 || die "تعذر التنزيل؛ ضع apex_26.x.zip في $DL"
  Z=$DL/apex-latest.zip
fi
T=/opt/noona/apex_ar; rm -rf "$T"; mkdir -p "$T"
unzip -q -o "$Z" 'apex/builder/ar/*' -d "$T" || die "لم أجد الحزمة العربية داخل $Z"
chown -R oracle:oinstall "$T"
echo "  تثبيت اللغة العربية في $PDB (دقيقتان تقريباً)"
OUT=$(printf 'WHENEVER SQLERROR EXIT SQL.SQLCODE\nCONNECT / AS SYSDBA\nALTER SESSION SET CONTAINER=%s;\n@load_ar.sql\nEXIT\n' "$PDB" \
  | su - oracle -c ". ~/.noona_env; export NLS_LANG=AMERICAN_AMERICA.AL32UTF8; cd $T/apex/builder/ar && sqlplus -S -L /nolog" 2>&1); echo "$OUT" >> "$LOG"
echo "$OUT" | grep -q "ORA-" && die "فشل التثبيت: $(echo "$OUT" | grep -m2 'ORA-')"
rm -rf "$T"
echo -e "${C_OK}  ✓ تم: حدّث صفحة نونا في المتصفح لتظهر قوائم التقارير بالعربية${C_0}" | tee -a "$LOG"
