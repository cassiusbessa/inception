# Developer documentation

## Prerequisites

- Linux VM (or WSL) with Docker Engine + Compose plugin
- `make`, `openssl` (used inside the NGINX image build)
- Write access to create `/home/caqueiro/data/{wordpress,mariadb}`
- Ability to edit `/etc/hosts` for `caqueiro.42.fr`

## Environment from scratch

1. Clone the repository.
2. Create secret files under `secrets/` (see subject example names):
   - `db_password.txt` — single-line DB user password
   - `db_root_password.txt` — single-line root password
   - `credentials.txt` — `WP_ADMIN_*` and `WP_USER_*` variables
3. Review `srcs/.env` for domain and non-secret MySQL/WordPress identifiers.
4. Create data directories:

```bash
mkdir -p /home/caqueiro/data/wordpress /home/caqueiro/data/mariadb
```

5. Map the domain:

```bash
echo '127.0.0.1 caqueiro.42.fr' | sudo tee -a /etc/hosts
```

## Build and launch

```bash
make build
make up
# equivalent: make
```

The Makefile invokes:

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env
```

Images are built from local Dockerfiles:

- `srcs/requirements/mariadb/Dockerfile`
- `srcs/requirements/wordpress/Dockerfile`
- `srcs/requirements/nginx/Dockerfile`

## Useful commands

```bash
make logs          # follow all service logs
make ps            # container status
make restart       # stop then start
make clean         # down + prune dangling images
make fclean        # remove containers, volumes, images, wipe data dirs
make re            # fclean then rebuild/start
```

Compose equivalents:

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec mariadb sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress sh
docker volume ls | grep -E 'mariadb_data|wordpress_data'
```

## Where data lives

| Named volume      | Container path     | Host path                         |
|-------------------|--------------------|-----------------------------------|
| `wordpress_data`  | `/var/www/html`    | `/home/caqueiro/data/wordpress`   |
| `mariadb_data`    | `/var/lib/mysql`   | `/home/caqueiro/data/mariadb`     |

Volumes are declared as named volumes with local driver options so Docker manages them as volumes while storing files under the required host tree. Wiping persistence: `make fclean` (destructive).

## Network and TLS

- Network: `inception` (bridge); no `host` network, no legacy `links`
- Only NGINX publishes `443:443`
- Certificate is generated at NGINX image build time (self-signed for `DOMAIN_NAME`)

## Layout

```
Makefile
secrets/                 # gitignored credentials
srcs/.env                # non-secret env
srcs/docker-compose.yml
srcs/requirements/{mariadb,nginx,wordpress}/
README.md USER_DOC.md DEV_DOC.md
```
