#!/bin/sh
set -e
echo "[adminer] Starting Adminer on :8080"
exec php -S 0.0.0.0:8080 -t /var/www
