# User documentation

## What this stack provides

| Service    | Role                                      | Access                         |
|------------|-------------------------------------------|--------------------------------|
| NGINX      | HTTPS reverse proxy                       | https://caqueiro.42.fr (port 443) |
| WordPress  | CMS (php-fpm)                             | Via NGINX only                 |
| MariaDB    | WordPress database                        | Internal network only          |
| Redis      | WordPress object cache (bonus)            | Internal network only          |
| Adminer    | DB web UI (bonus)                         | https://caqueiro.42.fr/adminer/ |
| Static     | Showcase HTML site (bonus)                | https://caqueiro.42.fr/static/ |
| FTP        | Access to WordPress files (bonus)         | `localhost:21` (passive 21100–21110) |

## Start and stop

From the repository root:

```bash
make up       # or: make
make down
make stop
make start
```

## Access the website and admin panel

1. Ensure hosts maps the domain on **both** WSL and Windows:
   - WSL: `/etc/hosts` → `127.0.0.1 caqueiro.42.fr`
   - Windows: `C:\Windows\System32\drivers\etc\hosts` → same line (needed to open the site from a Windows browser)
2. Open **https://caqueiro.42.fr** in a browser
3. Accept the self-signed TLS certificate warning
4. Admin panel: **https://caqueiro.42.fr/wp-admin**

Default admin username is defined in `secrets/credentials.txt` as `WP_ADMIN_USER` (must not contain “admin”). A second non-admin WordPress user is created from the same file.

FTP (bonus): user `FTP_USER` from `srcs/.env`, password in `secrets/ftp_password.txt`, root directory = WordPress volume.

## Credentials

| Secret file                    | Contents                                      |
|--------------------------------|-----------------------------------------------|
| `secrets/db_password.txt`      | MariaDB password for `MYSQL_USER`             |
| `secrets/db_root_password.txt` | MariaDB root password                         |
| `secrets/credentials.txt`      | WordPress admin + secondary user credentials  |
| `secrets/ftp_password.txt`     | FTP user password                             |

Non-secret settings (domain, DB name, DB user name) live in `srcs/.env`.

Never commit secrets or `.env` if it ever contains passwords. Rotate values by editing the secret files, then recreate containers (`make re` if the database must be re-initialized).

## Check that services are running

```bash
make ps
docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs
curl -kI https://caqueiro.42.fr
```

Healthy state: containers are `Up` (`mariadb`/`wordpress`/`redis` healthy), HTTPS returns 200, and FTP accepts login to the WordPress files.
