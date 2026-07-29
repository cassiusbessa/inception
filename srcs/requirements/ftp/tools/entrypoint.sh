#!/bin/sh
set -e

FTP_USER="${FTP_USER:-ftpuser}"
FTP_PASSWORD="$(tr -d '\r\n' < /run/secrets/ftp_password)"

if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
	adduser -D -h /var/www/html -s /bin/sh "${FTP_USER}"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
echo "${FTP_USER}" > /etc/vsftpd.userlist

# Ensure home is the WordPress volume mount
mkdir -p /var/www/html
# Do not chown the tree (php-fpm runs as nobody); keep content world-readable/writable for FTP edits
chmod -R a+rX /var/www/html 2>/dev/null || true
chmod -R ugo+rwX /var/www/html/wp-content 2>/dev/null || true

echo "[ftp] Starting vsftpd for user ${FTP_USER} -> /var/www/html"
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
