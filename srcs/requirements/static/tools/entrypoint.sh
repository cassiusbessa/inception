#!/bin/sh
set -e
echo "[static] Starting static site nginx..."
exec nginx -g 'daemon off;'
