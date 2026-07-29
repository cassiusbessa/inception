#!/bin/sh
set -e
echo "[redis] Starting Redis..."
exec redis-server /etc/redis.conf
