# -----------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
#
# @copyright Copyright (c) 2026 Rafael Mendes
# @license   GPLv3+ <https://www.gnu.org/licenses/gpl-3.0.html>
# @link      GitHub <https://github.com/mendescrafael>
#
# This file is part of GLPI Docker.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------

.DEFAULT_GOAL := info

# Definindo o shell usado.
SHELL := /bin/bash

# Arquivos de variáveis de ambiente.
ENV_FILE ?= .env
ENV_FILE_DEV ?= .env.dev

# Arquivos Docker Compose.
DOCKER_COMPOSE_FILE ?= docker-compose.yml
DOCKER_COMPOSE_FILE_DEV ?= docker-compose.dev.yml

COMPOSE := docker compose \
	--env-file $(ENV_FILE) \
	-f $(DOCKER_COMPOSE_FILE)

COMPOSE_DEV := docker compose \
	--env-file $(ENV_FILE) \
	--env-file $(ENV_FILE_DEV) \
	-f $(DOCKER_COMPOSE_FILE) \
	-f $(DOCKER_COMPOSE_FILE_DEV)

# Nome dos serviços Docker Compose (veja `docker-compose.yml` e `docker-compose.dev.yml`).
SERVICE_APP ?= app
SERVICE_DB ?= db

# Executáveis de banco de dados.
EXECUTABLE_DB ?= mysql
EXECUTABLE_DB_DUMP ?= mysqldump

# Usuário (UID) e grupo (GID) dono dos arquivos e diretórios do projeto.
# Para usuário considera-se o usuário atual (`id -un`). Para grupo
# considera-se o grupo `DOCKER_GROUP` (grupo gerenciado pelo Docker).
CURRENT_USER ?= $(shell id -un)

# Largura de tabela para saída de dados na CLI.
PROP_WIDTH  := 35
VALUE_WIDTH := 80

# Função para ler os valores de variáveis do arquivo '.env'.
define getenv
$(shell \
	if [ -f $(ENV_FILE) ]; then \
		awk -F= '/^[[:space:]]*$(1)[[:space:]]*=/ { \
			value=$$2; \
			sub(/^[[:space:]]*/, "", value); \
			sub(/[[:space:]]*$$/, "", value); \
			gsub(/^["'\''"]|["'\''"]$$/, "", value); \
			print value; \
		}' $(ENV_FILE); \
	fi)
endef

# Valores das variáveis de ambiente extraídos e atribuídos as suas respectivas variáveis.
APP_BASE_IMG := $(call getenv,APP_BASE_IMG)
APP_NAME := $(call getenv,APP_NAME)
APP_VERSION := $(call getenv,APP_VERSION)
CLIENT_ID := $(call getenv,CLIENT_ID)
DB_BASE_IMG := $(call getenv,DB_BASE_IMG)
DOCKER_GROUP := $(call getenv,DOCKER_GROUP)
LICENSE := $(call getenv,LICENSE)
PROJECT_NAME := $(call getenv,PROJECT_NAME)
PROJECT_DESCRIPTION := $(call getenv,PROJECT_DESCRIPTION)
PROJECT_AUTHORS := $(call getenv,PROJECT_AUTHORS)
WEBSERVER_GROUP := $(call getenv,WEBSERVER_GROUP)

# Captura o Git hash ID do último commit (veja `git log`).
# Adiciona também '-dirty' se houver arquivos modificados não 
# commitados ou mantém `REVISION` vazio se não houver um repositório Git.
REVISION := $(shell \
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
		printf "%s" "$$(git rev-parse --short HEAD)"; \
		git diff --quiet || printf "%s" "-dirty"; \
	fi)

# Exporta a variável para o Docker Compose capturar (usadas nos metadados do Dockerfile).
export TAG_IMAGE := $(APP_VERSION)$(if $(strip $(REVISION)),-$(REVISION))
export BUILD_DATE := $(shell date '+%Y-%m-%d %H:%M')
export REVISION

.PHONY: \
	check \
	check-db-commands \
	apply-permissions \
	add-user-groups \
	info \
	build \
	build-dev \
	up \
	up-dev \
	down \
	down-dev \
	stop \
	stop-dev \
	deploy \
	deploy-dev \
	rebuild \
	rebuild-dev \
	restart \
	restart-dev \
	status \
	status-dev \
	status-all \
	status-all-dev \
	config \
	config-dev \
	validate \
	validate-dev \
	logs \
	logs-dev \
	app-shell \
	app-shell-dev \
	db-cli-dev \
	db-dump-dev \
	db-restore-dev \
	prune-cache \
	prune-volumes \
	prune-networks \
	clean \
	list-images \
	list-volumes \
	list-networks \
	list-all \
	version \
	help

# Verifica se os comandos e arquivos necessários estão disponíveis.
check:
	@for cmd in docker git awk getent grep id usermod; do \
		command -v $$cmd >/dev/null 2>&1 || { \
			printf "[ ERROR ] Comando '%s' não encontrado. Instale o(s) software(s) e tente novamente.\n\n" "$$cmd"; \
			exit 1; \
		}; \
	done
	@for file in \
		$(ENV_FILE) \
		$(ENV_FILE_DEV) \
		$(DOCKER_COMPOSE_FILE) \
		$(DOCKER_COMPOSE_FILE_DEV) \
		Dockerfile; do \
		[ -f "$$file" ] || { \
			printf "[ ERROR ] Arquivo '%s' não encontrado. Consulte o arquivo 'README.md' para obter ajudar.\n\n" "$$file"; \
			exit 1; \
		}; \
	done

# Verifica se os comandos necessários para ações em banco de dados estão disponíveis.
check-db-commands:
	@for cmd in $(EXECUTABLE_DB) $(EXECUTABLE_DB_DUMP); do \
		command -v $$cmd >/dev/null 2>&1 || { \
			printf "[ ERROR ] Comando '%s' não encontrado. Instale o(s) software(s) e tente novamente.\n\n" "$$cmd"; \
			exit 1; \
		}; \
	done

apply-permissions: check
	@printf "\nAplicando permissões de arquivos e diretórios em: '$(CURDIR)'\n\n"

	@printf "Alterando proprietário para '%s:%s'...\n" "$(CURRENT_USER)" "$(DOCKER_GROUP)"
	@sudo chown -R $(CURRENT_USER):$(DOCKER_GROUP) .
	
	@printf "Aplicando permissões aos diretórios (775 -> 'rwxrwxr-x')...\n"
	@sudo find . -type d -exec chmod 775 {} \;
	
	@printf "Aplicando permissões aos arquivos (664 -> 'rw-rw-r--')...\n"
	@sudo find . -type f -exec chmod 664 {} \;

	@printf "\nPermissões aplicadas com sucesso.\n\n"

add-user-groups: check
	@USER="$(CURRENT_USER)"; \
	for GROUP in $(DOCKER_GROUP) $(WEBSERVER_GROUP); do \
		printf "Verificando grupo '%s'...\n" "$$GROUP"; \
		if ! getent group "$$GROUP" >/dev/null; then \
			printf "[ ERROR ] Grupo '%s' não encontrado.\n\n" "$$GROUP"; \
			continue; \
		fi; \
		if id -nG "$$USER" | tr ' ' '\n' | grep -Fxq "$$GROUP"; then \
			printf "[ INFO ] Usuário '%s' já pertence ao grupo '%s'.\n\n" "$$USER" "$$GROUP"; \
		else \
			printf "Adicionando usuário '%s' ao grupo '%s'...\n" "$$USER" "$$GROUP"; \
			sudo usermod -aG "$$GROUP" "$$USER" && \
			printf "[ OK ] Usuário adicionado com sucesso.\n\n"; \
		fi; \
	done; \
	printf "IMPORTANTE: Faça logout/login (ou reinicie a sessão) para que a alteração tenha efeito.\n\n"

info: check
	@PROP_WIDTH=$(PROP_WIDTH); \
	VALUE_WIDTH=$(VALUE_WIDTH); \
	border() { \
		printf '+'; \
		printf '%*s' $$((PROP_WIDTH + 2)) '' | tr ' ' '-'; \
		printf '+'; \
		printf '%*s' $$((VALUE_WIDTH + 2)) '' | tr ' ' '-'; \
		printf '+\n'; \
	}; \
	row() { \
		prop="$$1"; \
		value="$$2"; \
		prop_padding=$$((PROP_WIDTH - $${#prop})); \
		value_padding=$$((VALUE_WIDTH - $${#value})); \
		(( prop_padding < 0 )) && prop_padding=0; \
		(( value_padding < 0 )) && value_padding=0; \
		printf '| %s%*s | %s%*s |\n' \
			"$$prop" "$$prop_padding" '' \
			"$$value" "$$value_padding" ''; \
	}; \
	printf "\nAbaixo estão disponíveis as especificações dos artefatos usados no projeto.\n\n"; \
	border; \
	row "Propriedade" "Valor"; \
	border; \
	row "Projeto" "$(PROJECT_NAME)"; \
	row "Descrição" "$(PROJECT_DESCRIPTION)"; \
	row "Autor" "$(PROJECT_AUTHORS)"; \
	row "Licença" "$(LICENSE)"; \
	border; \
	row "Nome da imagem (Docker)" "$(APP_NAME)-$(CLIENT_ID)"; \
	row "Tag da imagem (Docker)" "$(TAG_IMAGE)"; \
	row "Versão da aplicação" "$(APP_VERSION)"; \
	row "Revisão (Git hash ID)" "$(REVISION)"; \
	border; \
	row "Imagem base (App) (Dockerfile)" "$(APP_BASE_IMG)"; \
	row "Imagem base (DB) (Ambiente dev)" "$(DB_BASE_IMG)"; \
	border; \
	printf "\nPara mais informações, consulte o arquivo 'README.md'.\n"; \
	printf "Para ajuda, execute: make help\n\n"

build: check
	@$(COMPOSE) build

build-dev: check
	@$(COMPOSE_DEV) build

up: check
	@$(COMPOSE) up -d

up-dev: check
	@$(COMPOSE_DEV) up -d

down: check
	@$(COMPOSE) down

down-dev: check
	@$(COMPOSE_DEV) down

stop: check
	@$(COMPOSE) stop

stop-dev: check
	@$(COMPOSE_DEV) stop

deploy: build up
deploy-dev: build-dev up-dev

rebuild: down build up
rebuild-dev: down-dev build-dev up-dev

restart: stop up
restart-dev: stop-dev up-dev

status: check
	@$(COMPOSE) ps

status-dev: check
	@$(COMPOSE_DEV) ps

status-all: check
	@$(COMPOSE) ps -a

status-all-dev: check
	@$(COMPOSE_DEV) ps -a

config: check
	@$(COMPOSE) config

config-dev: check
	@$(COMPOSE_DEV) config

validate: check
	@$(COMPOSE) config --quiet

validate-dev: check
	@$(COMPOSE_DEV) config --quiet

logs: check
	@$(COMPOSE) logs -f

logs-dev: check
	@$(COMPOSE_DEV) logs -f

app-shell: check
	@$(COMPOSE) exec -it $(SERVICE_APP) $(SHELL)

app-shell-dev: check
	@$(COMPOSE_DEV) exec -it $(SERVICE_APP) $(SHELL)

db-cli-dev: check
	@USER="$(DATABASE_USER)"; \
	[ -n "$$USER" ] || read -p "Usuário: " USER; \
	$(COMPOSE_DEV) \
	exec -it $(SERVICE_DB) $(SHELL) -c "$(EXECUTABLE_DB) -u $$USER -p"

db-dump-dev: check-db-commands
	@USER="$(DATABASE_USER)"; DB="$(DATABASE_NAME)"; \
	[ -n "$$USER" ] || read -p "Usuário: " USER; \
	[ -n "$$DB" ] || read -p "Banco de dados: " DB; \
	$(EXECUTABLE_DB_DUMP) -v -u "$$USER" -p "$$DB" > dump_$$(date +%Y%m%d%H%M)_$$DB.sql

db-restore-dev: check-db-commands
	@USER="$(DATABASE_USER)"; DB="$(DATABASE_NAME)"; DUMP_SQL="$(DATABASE_DUMP_SQL)"; \
	[ -n "$$USER" ] || read -p "Usuário: " USER; \
	[ -n "$$DB" ] || read -p "Banco de dados: " DB; \
	[ -n "$$DUMP_SQL" ] || read -p "Arquivo de dump SQL: " DUMP_SQL; \
	$(EXECUTABLE_DB) -v -u "$$USER" -p "$$DB" < "$$DUMP_SQL"

prune-cache: check
	@docker builder prune -af

prune-volumes: check
	@docker volume prune -af

prune-networks: check
	@docker network prune -f

clean: prune-cache prune-volumes prune-networks

list-images: check
	@docker image ls
	@printf "\n"

list-volumes: check
	@docker volume ls
	@printf "\n"

list-networks: check
	@docker network ls
	@printf "\n"

list-all: list-images list-volumes list-networks

version: check
	@printf "%s\n" "$(TAG_IMAGE)"

# TODO: Adicione aqui alvos para comandos específicos da aplicação.
glpi-cache-clear: check
	@$(COMPOSE) exec -it $(SERVICE_APP) su -s $(SHELL) -c "php bin/console cache:clear" $(WEBSERVER_GROUP)

glpi-cache-clear-dev: check
	@$(COMPOSE_DEV) exec -it $(SERVICE_APP) su -s $(SHELL) -c "php bin/console cache:clear" $(WEBSERVER_GROUP)

help:
	@printf "Uso: make [COMANDO] [ARG...]\n\n"

	@printf "%-12s %s\n" "IMPORTANTE:" "Os comandos com o sufixo '-dev' executam operações no ambiente de DESENVOLVIMENTO."
	@printf "%12s %s\n\n" "" "Para o ambiente de PRODUÇÃO, utilize os comandos equivalentes SEM o sufixo '-dev'."

	@printf "Gerenciamento e execução:\n"
	@printf "  %-25s %s\n" "build," "Constrói as imagens Docker dos serviços."
	@printf "    build-dev\n\n"

	@printf "  %-25s %s\n" "up," "Cria e inicia os containers em segundo plano."
	@printf "    up-dev\n\n"

	@printf "  %-25s %s\n" "down," "Para e remove os containers, redes e recursos associados."
	@printf "    down-dev\n\n"

	@printf "  %-25s %s\n" "stop," "Interrompe a execução dos containers sem removê-los."
	@printf "    stop-dev\n\n"

	@printf "  %-25s %s\n" "deploy," "Implanta a aplicação construindo as imagens Docker dos serviços,"
	@printf "    %-23s %s\n\n" "deploy-dev" "criando e iniciando os containers, executando o 'build' e 'up' respectivamente."

	@printf "  %-25s %s\n" "rebuild," "Reconstrói as imagens e recria os containers."
	@printf "    rebuild-dev\n\n"
	
	@printf "  %-25s %s\n" "restart," "Para e inicia novamente os containers."
	@printf "    restart-dev\n\n"

	@printf "  %-25s %s\n" "status," "Lista os containers em execução gerenciados pelo Docker Compose."
	@printf "    status-dev\n\n"

	@printf "  %-25s %s\n" "status-all," "Lista todos os containers (incluindo containers parados) gerenciados pelo Docker Compose."
	@printf "    status-all-dev\n\n"

	@printf "  %-25s %s\n" "config," "Exibe informações do arquivo Compose no formato canônico."
	@printf "    config-dev\n\n"

	@printf "  %-25s %s\n" "validate," "Valida o arquivo Compose no modo silencioso. Útil para scripts e pipelines."
	@printf "    validate-dev\n\n"

	@printf "  %-25s %s\n" "logs," "Exibe os logs dos serviços em tempo real."
	@printf "    logs-dev\n\n"
	
	@printf "Aplicação:\n"
	@printf "  %-25s %s\n" "app-shell," "Abre um terminal no container de aplicação."
	@printf "    app-shell-dev\n\n"

	@printf "Banco de dados:\n"
	@printf "  %-25s %s\n" "db-cli-dev" "Abre um cliente Shell no container de banco de dados."
	@printf "    DATABASE_USER=<USER>\n\n"

	@printf "  %-25s %s\n" "db-dump-dev" "Gera um backup (dump SQL) do banco de dados."
	@printf "    DATABASE_USER=<USER>\n"
	@printf "    DATABASE_NAME=<NAME>\n\n"

	@printf "  %-25s %s\n" "db-restore-dev" "Restaura um banco de dados a partir de um arquivo de dump SQL."
	@printf "    DATABASE_USER=<USER>\n"
	@printf "    DATABASE_NAME=<NAME>\n"
	@printf "    DATABASE_DUMP_SQL=<DUMP_SQL>\n\n"

	@printf "Limpeza de ambiente:\n"
	@printf "  %-25s %s\n\n" "prune-cache" "Remove o cache de construção (build cache) não utilizado pelo Docker."
	@printf "  %-25s %s\n\n" "" "CUIDADO! Os comandos abaixo podem apagar os recursos criados."
	@printf "  %-25s %s\n" "prune-volumes" "Remove todos os volumes Docker que não estão em uso."
	@printf "  %-25s %s\n" "prune-networks" "Remove todas as redes Docker que não estão sendo utilizadas."
	@printf "  %-25s %s\n\n" "clean" "Limpeza total do ambiente. Remove o build cache, volumes e redes não utilizadas."

	@printf "Listar:\n"
	@printf "  %-25s %s\n" "list-images" "Lista as imagens Docker disponíveis no hospedeiro."
	@printf "  %-25s %s\n" "list-volumes" "Lista os volumes Docker existentes no hospedeiro."
	@printf "  %-25s %s\n" "list-networks" "Lista as redes Docker existentes no hospedeiro."
	@printf "  %-25s %s\n\n" "list-all" "Lista todos os componentes anteriores existentes no hospedeiro."

	@printf "Permissionamento:\n"
	@printf "  %-25s %s\n" "" "NOTA: Os comandos abaixo podem ser usados para corrigir possíveis erros relacionados"
	@printf "  %-25s %s\n\n" "" "a permissões nos arquivos e diretórios do projeto."

	@printf "  %-25s %s\n" "apply-permissions" "Aplica as permissões de usuário e grupo dono nos arquivos e diretórios do projeto."
	@printf "  %-25s %s\n" "" "Para usuário considera-se o usuário atual (`id -un`) e para grupo considera-se"
	@printf "  %-25s %s\n\n" "" "o grupo '$(DOCKER_GROUP)' (grupo gerenciado pelo Docker)."

	@printf "  %-25s %s\n" "add-user-groups" "Verifica e adiciona o usuário atual (`id -un`) aos grupos '$(DOCKER_GROUP)' (grupo gerenciado pelo Docker)"
	@printf "  %-25s %s\n\n" "" "e '$(WEBSERVER_GROUP)' (grupo gerenciado pelo web server)."

	@printf "Comandos comuns:\n"
	@printf "  %-25s %s\n" "info" "Informações sobre o projeto."
	@printf "  %-25s %s\n" "version" "Versão do projeto."
	@printf "  %-25s %s\n\n" "help" "Este menu de ajuda."

	@printf "Comandos específicos de gerenciamente e manutenção da aplicação:\n"
	@printf "  %-25s %s\n" "glpi-cache-clear," "Limpa o cache do GLPI."
	@printf "    glpi-cache-clear-dev\n\n"
