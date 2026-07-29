#!/bin/sh
set -e

DB_ROOT_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_root_password)"
DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[mariadb] Initializing data directory..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal >/dev/null

	mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
	echo "[mariadb] Bootstrap complete."
fi

echo "[mariadb] Starting MariaDB..."
exec mysqld --user=mysql --console
