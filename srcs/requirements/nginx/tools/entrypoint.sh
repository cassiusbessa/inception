#!/bin/sh
set -e

DOMAIN_NAME="${DOMAIN_NAME:-caqueiro.42.fr}"

sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

echo "[nginx] Starting nginx for https://${DOMAIN_NAME}"
exec nginx -g 'daemon off;'
