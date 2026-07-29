*This project has been created as part of the 42 curriculum by caqueiro.*

# Inception

## Description

Inception is a system administration project that builds a small, production-like web infrastructure with Docker Compose. Three dedicated containers form a LEMP-style stack:

- **NGINX** — sole public entrypoint on port **443** with **TLSv1.2 / TLSv1.3**
- **WordPress + php-fpm** — application container (no nginx inside)
- **MariaDB** — database container (no nginx inside)

Persistent data lives in two **named volumes** whose host storage is under `/home/caqueiro/data`. Containers communicate on a custom Docker bridge network named `inception`. Secrets (DB passwords and WordPress credentials) are mounted via **Docker secrets**; non-sensitive configuration uses a `.env` file.

### Project description — design choices

Custom Dockerfiles build every service from **Alpine 3.20** (penultimate stable at project time). No ready-made service images are pulled from Docker Hub. A root `Makefile` drives `docker compose` so `make` builds and starts the whole application.

#### Virtual Machines vs Docker

A VM virtualizes hardware and runs a full guest OS. Docker containers share the host kernel and isolate processes with namespaces and cgroups. Containers start faster, use less disk/RAM, and match the “one process per container” model used here. The subject still requires the project to run inside a VM so the Docker host itself stays isolated from the evaluator’s machine.

#### Secrets vs Environment Variables

Environment variables (and `.env`) are convenient for non-sensitive values such as domain name and database name. They are easy to leak via process listings, image history, or accidental commits. **Docker secrets** inject confidential values as files under `/run/secrets` at runtime and keep them out of Dockerfiles and the Git history. This project stores passwords only under `secrets/` (gitignored) and mounts them as Compose secrets.

#### Docker Network vs Host Network

`network: host` removes network isolation and is forbidden by the subject. A user-defined bridge (`inception`) lets containers resolve each other by service name (`mariadb`, `wordpress`, `nginx`) while only NGINX publishes host port 443.

#### Docker Volumes vs Bind Mounts

Bind mounts map an arbitrary host path into a container and are easy to misuse. The subject requires **named volumes** for WordPress files and the database. Compose declares named volumes whose `driver_opts` point their storage at `/home/caqueiro/data/{wordpress,mariadb}`, satisfying both persistence rules and the host path requirement without using compose-style bind mounts on the services themselves.

## Instructions

### Prerequisites

- Docker Engine with Compose plugin
- `make`
- Host directories `/home/caqueiro/data/wordpress` and `/home/caqueiro/data/mariadb`
- DNS or `/etc/hosts` entry: `127.0.0.1 caqueiro.42.fr`

### Secrets

Create (already provided locally, never commit):

```
secrets/db_password.txt
secrets/db_root_password.txt
secrets/credentials.txt
```

`credentials.txt` uses `KEY=value` lines for WordPress admin and secondary user accounts. The administrator username must not contain `admin` / `administrator`.

### Run

```bash
make          # build images and start containers
make logs     # follow logs
make down     # stop and remove containers
make fclean   # full cleanup including volumes/images and data dirs
make re       # fclean + all
```

Open **https://caqueiro.42.fr** (accept the self-signed certificate). WordPress admin: **https://caqueiro.42.fr/wp-admin**.

## Resources

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [NGINX SSL/TLS](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Alpine Linux packages](https://pkgs.alpinelinux.org/)

### How AI was used

AI assisted with scaffolding the Compose layout, drafting entrypoint scripts, aligning the tree with the subject’s example structure, and writing README / USER_DOC / DEV_DOC. All Dockerfiles, configs, and scripts were reviewed, adapted to Alpine 3.20 packages, and tested locally before submission. Peer review remains required before evaluation.
