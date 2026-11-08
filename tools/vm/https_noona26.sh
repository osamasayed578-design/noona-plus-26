#!/bin/bash
# =============================================================================
# NOONA PLUS 26 | تشغيل النظام عبر HTTPS (nginx أمام ORDS)
#   bash tools/vm/https_noona26.sh demo.example.com    شهادة مجانية من Let's Encrypt لنطاقك (تتجدد تلقائياً)
#   bash tools/vm/https_noona26.sh                     شهادة ذاتية التوقيع (للشبكة الداخلية؛ المتصفح ينبه)
# قبل الشهادة المجانية: سجل A للنطاق يشير لعنوان الخادم العام، والمنفذان 80 و443 مفتوحان
#   (في OCI: Security List أو NSG للشبكة، إضافة لجدار الخادم الذي يفتحه هذا السكربت).
# بعدها: https://<النطاق>/ يفتح صفحة الدخول مباشرة. منفذ ORDS الداخلي يبقى للخادم نفسه.
# السجل: /var/log/noona26_https.log
# =============================================================================
export PATH="$PATH:/usr/local/bin:/usr/bin:/usr/sbin"
set -o pipefail
DOMAIN="$1"
LOG=/var/log/noona26_https.log
C_OK='\033[1;32m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_0='\033[0m'
step() { echo -e "\n${C_STEP}===== $*${C_0}"; }
ok()   { echo -e "${C_OK}  ✓ $*${C_0}"; }
info() { echo "  $*"; }
die()  { echo -e "${C_ERR}  ✗ $*${C_0}"; echo "  السجل: $LOG"; exit 1; }

[ "$(id -u)" = 0 ] || die "شغّله بحساب root"
touch "$LOG"; chmod 600 "$LOG"; echo "---- $(date) $DOMAIN ----" >> "$LOG"
PORT_WEB=$(systemctl cat ords 2>/dev/null | grep -o -- '--port [0-9]*' | awk '{print $2}'); PORT_WEB=${PORT_WEB:-8080}
curl -s -o /dev/null -m 15 "http://127.0.0.1:$PORT_WEB/ords/" || die "ORDS لا يرد على المنفذ $PORT_WEB؛ شغّل: systemctl start ords"
if [ -n "$DOMAIN" ]; then
  [[ "$DOMAIN" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\.[A-Za-z]{2,}$ ]] || die "اسم النطاق غير صالح: $DOMAIN"
fi
OLV=$(rpm -E %rhel 2>/dev/null)

step "1/4 تثبيت nginx"
dnf -y install nginx openssl >>"$LOG" 2>&1 || die "تعذر تثبيت nginx"
command -v setsebool >/dev/null && setsebool -P httpd_can_network_connect 1 >>"$LOG" 2>&1
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-service=http --add-service=https >>"$LOG" 2>&1 && firewall-cmd --reload >>"$LOG" 2>&1
  ok "جدار الخادم: فتح 80 و443"
fi
mkdir -p /var/www/certbot /etc/nginx/noona
ok "nginx"

# إعداد الوكيل (مشترك بين HTTP المؤقت وHTTPS)
cat > /etc/nginx/noona/proxy.conf <<EOF
client_max_body_size 50m;
location = / { return 302 /ords/r/noonaplus/noona_master/home; }
location / {
    proxy_pass http://127.0.0.1:$PORT_WEB;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_read_timeout 900s;
    proxy_send_timeout 900s;
}
EOF
NAME=${DOMAIN:-_}

step "2/4 الشهادة"
CERT=/etc/nginx/noona/self.crt; KEY=/etc/nginx/noona/self.key
if [ -n "$DOMAIN" ]; then
  # HTTP مؤقت لتحقق Let's Encrypt
  cat > /etc/nginx/conf.d/noona.conf <<EOF
server {
    listen 80;
    server_name $NAME;
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 301 https://\$host\$request_uri; }
}
EOF
  systemctl enable --now nginx >>"$LOG" 2>&1; nginx -t >>"$LOG" 2>&1 && systemctl reload nginx
  if ! command -v certbot >/dev/null; then
    dnf -y install "oracle-epel-release-el${OLV}" >>"$LOG" 2>&1 || dnf -y install epel-release >>"$LOG" 2>&1
    dnf -y install certbot >>"$LOG" 2>&1 || die "تعذر تثبيت certbot (مستودع EPEL)"
  fi
  certbot certonly --webroot -w /var/www/certbot -d "$DOMAIN" --agree-tos --register-unsafely-without-email --non-interactive \
    --deploy-hook "systemctl reload nginx" >>"$LOG" 2>&1 \
    || die "تعذر إصدار الشهادة: تأكد أن $DOMAIN يشير لعنوان هذا الخادم وأن المنفذ 80 مفتوح من الإنترنت"
  CERT=/etc/letsencrypt/live/$DOMAIN/fullchain.pem; KEY=/etc/letsencrypt/live/$DOMAIN/privkey.pem
  systemctl enable --now certbot-renew.timer >>"$LOG" 2>&1 || (crontab -l 2>/dev/null; echo "17 3 * * * certbot renew -q") | crontab -
  ok "شهادة Let's Encrypt لـ $DOMAIN (تتجدد تلقائياً)"
else
  [ -f "$CERT" ] || openssl req -x509 -nodes -newkey rsa:2048 -days 825 -subj "/CN=$(hostname -f)" \
    -addext "subjectAltName=DNS:$(hostname -f),IP:$(hostname -I | awk '{print $1}')" -keyout "$KEY" -out "$CERT" >>"$LOG" 2>&1 \
    || die "تعذر إنشاء الشهادة الذاتية"
  chmod 600 "$KEY"
  ok "شهادة ذاتية التوقيع (صالحة 825 يوماً)"
fi

step "3/4 إعداد HTTPS"
cat > /etc/nginx/conf.d/noona.conf <<EOF
server {
    listen 80;
    server_name $NAME;
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 301 https://\$host\$request_uri; }
}
server {
    listen 443 ssl;
    http2 on;
    server_name $NAME;
    ssl_certificate     $CERT;
    ssl_certificate_key $KEY;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    add_header Strict-Transport-Security "max-age=31536000" always;
    include /etc/nginx/noona/proxy.conf;
}
EOF
# nginx أقدم من 1.25 لا يعرف «http2 on»
nginx -t >>"$LOG" 2>&1 || { sed -i 's/^    http2 on;$//; s/listen 443 ssl;/listen 443 ssl http2;/' /etc/nginx/conf.d/noona.conf; }
nginx -t >>"$LOG" 2>&1 || die "إعداد nginx غير صالح (السجل)"
systemctl enable --now nginx >>"$LOG" 2>&1; systemctl reload nginx
ok "nginx يستقبل 443 ويمرر لـ ORDS على $PORT_WEB"

step "4/4 التحقق"
C=$(curl -sk -o /dev/null -m 20 -w '%{http_code}' "https://127.0.0.1/ords/r/noonaplus/noona_master/home" -H "Host: ${DOMAIN:-localhost}")
[[ "$C" =~ ^(200|302)$ ]] && ok "HTTPS يعمل ($C)" || die "HTTPS لا يرد كما يجب ($C)"
echo
echo "  افتح: https://${DOMAIN:-$(hostname -I | awk '{print $1}')}/"
[ -z "$DOMAIN" ] && echo "  (الشهادة ذاتية التوقيع: وافق على تنبيه المتصفح مرة واحدة)"
echo "  يُستحسن إغلاق منفذ ORDS المباشر من خارج الخادم: firewall-cmd --permanent --remove-port=$PORT_WEB/tcp && firewall-cmd --reload"
