#!/bin/sh
set -e

WP_PATH="${WP_PATH:-/var/www/html}"
DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"
export WP_CLI_PHP_ARGS="-d memory_limit=512M"

# shellcheck disable=SC1091
. /run/secrets/credentials

wait_for_db() {
	echo "[wordpress] Waiting for MariaDB at ${MYSQL_HOSTNAME}..."
	i=0
	while [ "$i" -lt 60 ]; do
		if mariadb-admin ping -h"${MYSQL_HOSTNAME}" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; then
			echo "[wordpress] MariaDB is ready."
			return 0
		fi
		i=$((i + 1))
		sleep 2
	done
	echo "[wordpress] ERROR: MariaDB did not become ready in time." >&2
	exit 1
}

wait_for_db

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
	echo "[wordpress] Downloading WordPress..."
	wp core download --path="${WP_PATH}" --allow-root

	echo "[wordpress] Creating wp-config.php..."
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="${MYSQL_HOSTNAME}" \
		--allow-root

	echo "[wordpress] Installing WordPress..."
	wp core install \
		--path="${WP_PATH}" \
		--url="https://${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

	echo "[wordpress] Creating secondary user..."
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--path="${WP_PATH}" \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}" \
		--allow-root

	echo "[wordpress] WordPress setup complete."
else
	echo "[wordpress] Existing installation detected; skipping install."
fi

# Redis object cache (bonus) — safe if redis is unavailable
if [ -n "${REDIS_HOST:-}" ]; then
	echo "[wordpress] Configuring Redis cache (${REDIS_HOST})..."
	wp config set WP_REDIS_HOST "${REDIS_HOST}" --allow-root --path="${WP_PATH}" 2>/dev/null || true
	wp config set WP_REDIS_PORT "${REDIS_PORT:-6379}" --raw --allow-root --path="${WP_PATH}" 2>/dev/null || true
	if ! wp plugin is-installed redis-cache --allow-root --path="${WP_PATH}" 2>/dev/null; then
		wp plugin install redis-cache --activate --allow-root --path="${WP_PATH}" || true
	else
		wp plugin activate redis-cache --allow-root --path="${WP_PATH}" 2>/dev/null || true
	fi
	wp redis enable --allow-root --path="${WP_PATH}" 2>/dev/null || true
fi

chown -R nobody:nobody "${WP_PATH}" 2>/dev/null || true

echo "[wordpress] Starting php-fpm..."
exec php-fpm83 -F
