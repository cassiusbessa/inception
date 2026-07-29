NAME		= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_DIR	= /home/caqueiro/data

.PHONY: all build up down start stop restart logs ps clean fclean re prune

all: build up

build:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb $(DATA_DIR)/redis
	$(COMPOSE) build

up:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb $(DATA_DIR)/redis
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: stop start

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean: down
	docker image prune -f

fclean: down
	docker compose -f srcs/docker-compose.yml --env-file srcs/.env down -v --rmi all --remove-orphans
	@sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/* $(DATA_DIR)/redis/* 2>/dev/null || rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/* $(DATA_DIR)/redis/*
	docker system prune -af

re: fclean all

prune:
	docker system prune -af
