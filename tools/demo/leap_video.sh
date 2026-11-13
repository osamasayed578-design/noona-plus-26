#!/bin/bash
# NOONA PLUS | تسجيل الفيديو القصير للمعرض وتركيبه: leap_video.sh <مجلد الإخراج>
#   يتطلب: node + playwright + ffmpeg، وتشغيل db/demo/demo_leap_prep.sql قبله، والمتغيرات:
#   NOONA_PORT DST_USER DST_PWD RYD_USER RYD_PWD (كلمات المرور من البيئة لا من الملف)
set -e
OUT=${1:-leap_video}; D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; mkdir -p "$OUT"
export PW_PATH=${PW_PATH:-playwright}
node "$D/leap_video.js" "$OUT" mobile
node "$D/leap_video.js" "$OUT" desktop
# الجوال في وسط خلفية بلون الهوية، ثم مشاهد الشاشة الكبيرة
ffmpeg -nostdin -loglevel error -y -i "$OUT/leap_mobile.webm" -i "$OUT/leap_desktop.webm" -filter_complex \
 "color=c=0x0b3b6e:s=1280x720:r=25[bg];[0:v]fps=25,scale=-2:700[m];[bg][m]overlay=(W-w)/2:(H-h)/2:shortest=1,setsar=1[a];[1:v]fps=25,scale=1280:720,setsar=1[b];[a][b]concat=n=2:v=1:a=0[v]" \
 -map "[v]" -c:v libx264 -preset medium -crf 26 -pix_fmt yuv420p -movflags +faststart "$OUT/NOONA_LEAP_demo.mp4"
echo "saved $OUT/NOONA_LEAP_demo.mp4 ($(du -h "$OUT/NOONA_LEAP_demo.mp4" | cut -f1))"
