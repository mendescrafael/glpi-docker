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

# -----------------------------------------------------------------------------
# Configuração.
# -----------------------------------------------------------------------------
.DEFAULT_GOAL := help

# Shell utilizado pelo Make.
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
SERVICE_WEB ?= web
SERVICE_DB ?= db

# Executáveis de banco de dados.
EXECUTABLE_DB ?= mysql
EXECUTABLE_DB_DUMP ?= mysqldump

# Usuário (UID) e grupo (GID) proprietários dos arquivos e diretórios do projeto:
#
# - Para usuário considera-se o usuário atual (`id -un`);
# - Para grupo considera-se o grupo `DOCKER_GROUP` (grupo gerenciado pelo Docker);
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

# Executa um comando da aplicação no container com o usuário de runtime
# configurado. Use esta função nos alvos específicos adicionados ao template.
define run_app_command
$(1) exec -it $(SERVICE_APP) su -s $(SHELL) -c "$(2)" $(APP_RUNTIME_USER)
endef

# Valores das variáveis de ambiente extraídos e atribuídos às suas respectivas variáveis.
APP_BASE_IMG := $(call getenv,APP_BASE_IMG)
APP_VERSION := $(call getenv,APP_VERSION)
APP_BUILD_ENV := $(call getenv,APP_BUILD_ENV)
CLIENT_ID := $(call getenv,CLIENT_ID)
DB_BASE_IMG := $(call getenv,DB_BASE_IMG)
DOCKER_GROUP := $(call getenv,DOCKER_GROUP)
LICENSE := $(call getenv,LICENSE)
PROJECT_LABEL := $(call getenv,PROJECT_LABEL)
PROJECT_NAME := $(call getenv,PROJECT_NAME)
PROJECT_DESCRIPTION := $(call getenv,PROJECT_DESCRIPTION)
PROJECT_AUTHORS := $(call getenv,PROJECT_AUTHORS)
APP_RUNTIME_USER := $(call getenv,APP_RUNTIME_USER)
APP_RUNTIME_GROUP := $(call getenv,APP_RUNTIME_GROUP)
WEBSERVER_BASE_IMG := $(call getenv,WEBSERVER_BASE_IMG)

# Captura o Git hash ID do último commit (veja `git log`).
# Adiciona também '-dirty' se houver arquivos modificados não
# commitados ou mantém `REVISION` vazio se não houver um repositório Git.
REVISION := $(shell \
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
		printf "%s" "$$(git rev-parse --short HEAD)"; \
		git diff --quiet || printf "%s" "-dirty"; \
	fi)

# Exporta as variáveis usadas pelo Docker Compose nos metadados do Dockerfile.
export TAG_IMAGE := $(APP_VERSION)$(if $(strip $(REVISION)),-$(REVISION))
export BUILD_DATE := $(shell date '+%Y-%m-%d %H:%M')
export REVISION

# -----------------------------------------------------------------------------
# Declaração dos alvos.
# -----------------------------------------------------------------------------
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
	web-shell \
	web-shell-dev \
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
	glpi-console-list \
	glpi-console-list-dev \
	glpi-cache-clear \
	glpi-cache-clear-dev \
	glpi-build-compile-scss \
	glpi-build-compile-scss-dev \
	glpi-system-check-requirements \
	glpi-system-check-requirements-dev \
	glpi-system-list-services \
	glpi-system-list-services-dev \
	glpi-system-status \
	glpi-system-status-dev \
	glpi-database-check-schema-integrity \
	glpi-database-check-schema-integrity-dev \
	glpi-diagnostic-check-documents-integrity \
	glpi-diagnostic-check-documents-integrity-dev \
	glpi-diagnostic-check-source-code-integrity \
	glpi-diagnostic-check-source-code-integrity-dev \
	glpi-plugin-list \
	glpi-plugin-list-dev \
	glpi-maintenance-enable \
	glpi-maintenance-enable-dev \
	glpi-maintenance-disable \
	glpi-maintenance-disable-dev \
	glpi-task-unlock \
	glpi-task-unlock-dev \
	help

# -----------------------------------------------------------------------------
# Verificações.
# -----------------------------------------------------------------------------
# Verifica se os comandos e arquivos necessários estão disponíveis.
check:
	@for cmd in docker git awk chown getent grep id usermod; do \
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
			printf "[ ERROR ] Arquivo '%s' não encontrado. Consulte o arquivo 'README.md' para obter ajuda.\n\n" "$$file"; \
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

# -----------------------------------------------------------------------------
# Permissionamento.
# -----------------------------------------------------------------------------
apply-permissions: check
	@printf "\nAplicando permissões de arquivos e diretórios em: '$(CURDIR)'\n\n"

	@printf "Alterando proprietário para '%s:%s'...\n" "$(CURRENT_USER)" "$(DOCKER_GROUP)"
	@sudo chown -R "$(CURRENT_USER):$(DOCKER_GROUP)" .

	@printf "Aplicando permissões aos diretórios (2775, preservando bits especiais)...\n"
	@sudo find . -type d -exec chmod ug+rwx,o+rx,o-w,g+s {} +

	@printf "Aplicando permissões aos arquivos (664/775, preservando executáveis)...\n"
	@sudo find . -type f -exec chmod u=rwX,g=rwX,o=rX {} +

	@printf "\nPermissões aplicadas com sucesso.\n\n"

add-user-groups: check
	@USER="$(CURRENT_USER)"; \
	for GROUP in $(DOCKER_GROUP) $(APP_RUNTIME_GROUP); do \
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

# -----------------------------------------------------------------------------
# Informações do projeto.
# -----------------------------------------------------------------------------
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
	row "Projeto" "$(PROJECT_LABEL)"; \
	row "Descrição" "$(PROJECT_DESCRIPTION)"; \
	row "Autor" "$(PROJECT_AUTHORS)"; \
	row "Licença" "$(LICENSE)"; \
	border; \
	row "Nome da imagem (Docker)" "$(PROJECT_NAME)-$(CLIENT_ID)"; \
	row "Tag da imagem (Docker)" "$(TAG_IMAGE)"; \
	row "Versão da aplicação" "$(APP_VERSION)"; \
	row "Ambiente de build" "$(APP_BUILD_ENV)"; \
	row "Revisão (Git hash ID)" "$(REVISION)"; \
	border; \
	row "Imagem base (App) (Dockerfile)" "$(APP_BASE_IMG)"; \
	row "Imagem base (Web) (Dockerfile)" "$(WEBSERVER_BASE_IMG)"; \
	row "Imagem base (DB) (Ambiente dev)" "$(DB_BASE_IMG)"; \
	border; \
	printf "\nPara mais informações, consulte o arquivo 'README.md'.\n"; \
	printf "Para ajuda, execute: make help\n\n"

# -----------------------------------------------------------------------------
# Gerenciamento dos containers.
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Acesso ao container da aplicação.
# -----------------------------------------------------------------------------
app-shell: check
	@$(COMPOSE) exec -it $(SERVICE_APP) $(SHELL)

app-shell-dev: check
	@$(COMPOSE_DEV) exec -it $(SERVICE_APP) $(SHELL)

web-shell: check
	@$(COMPOSE) exec -it $(SERVICE_WEB) /bin/sh

web-shell-dev: check
	@$(COMPOSE_DEV) exec -it $(SERVICE_WEB) /bin/sh

# -----------------------------------------------------------------------------
# Banco de dados.
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Limpeza do ambiente Docker.
# -----------------------------------------------------------------------------
prune-cache: check
	@docker builder prune -af

prune-volumes: check
	@docker volume prune -af

prune-networks: check
	@docker network prune -f

clean: prune-cache prune-volumes prune-networks

# -----------------------------------------------------------------------------
# Listagem dos recursos Docker.
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Versão.
# -----------------------------------------------------------------------------
version: check
	@printf "%s\n" "$(TAG_IMAGE)"

# -----------------------------------------------------------------------------
# Comandos específicos da aplicação.
# -----------------------------------------------------------------------------
glpi-console-list: check
	@$(call run_glpi_console,$(COMPOSE),list)

glpi-console-list-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),list)

glpi-cache-clear: check
	@$(call run_glpi_console,$(COMPOSE),cache:clear)

glpi-cache-clear-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),cache:clear)

glpi-build-compile-scss: check
	@$(call run_glpi_console,$(COMPOSE),build:compile_scss)

glpi-build-compile-scss-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),build:compile_scss)

glpi-system-check-requirements: check
	@$(call run_glpi_console,$(COMPOSE),system:check_requirements)

glpi-system-check-requirements-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),system:check_requirements)

glpi-system-list-services: check
	@$(call run_glpi_console,$(COMPOSE),system:list_services)

glpi-system-list-services-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),system:list_services)

glpi-system-status: check
	@$(call run_glpi_console,$(COMPOSE),system:status)

glpi-system-status-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),system:status)

glpi-database-check-schema-integrity: check
	@$(call run_glpi_console,$(COMPOSE),database:check_schema_integrity)

glpi-database-check-schema-integrity-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),database:check_schema_integrity)

glpi-diagnostic-check-documents-integrity: check
	@$(call run_glpi_console,$(COMPOSE),diagnostic:check_documents_integrity)

glpi-diagnostic-check-documents-integrity-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),diagnostic:check_documents_integrity)

glpi-diagnostic-check-source-code-integrity: check
	@$(call run_glpi_console,$(COMPOSE),diagnostic:check_source_code_integrity)

glpi-diagnostic-check-source-code-integrity-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),diagnostic:check_source_code_integrity)

glpi-plugin-list: check
	@$(call run_glpi_console,$(COMPOSE),plugin:list)

glpi-plugin-list-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),plugin:list)

glpi-maintenance-enable: check
	@$(call run_glpi_console,$(COMPOSE),maintenance:enable)

glpi-maintenance-enable-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),maintenance:enable)

glpi-maintenance-disable: check
	@$(call run_glpi_console,$(COMPOSE),maintenance:disable)

glpi-maintenance-disable-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),maintenance:disable)

glpi-task-unlock: check
	@$(call run_glpi_console,$(COMPOSE),task:unlock --all)

glpi-task-unlock-dev: check
	@$(call run_glpi_console,$(COMPOSE_DEV),task:unlock --all)

# -----------------------------------------------------------------------------
# Ajuda.
# -----------------------------------------------------------------------------
help:
	@printf "Uso: make [COMANDO] [VARIAVEL=valor]\n\n"

	@printf "%-12s %s\n" "IMPORTANTE:" "Os comandos com o sufixo '-dev' executam operações no ambiente de DESENVOLVIMENTO."
	@printf "%12s %s\n\n" "" "Para o ambiente de PRODUÇÃO, utilize os comandos equivalentes SEM o sufixo '-dev'."

	@printf "Gerenciamento e execução:\n"
	@printf "  %-30s %s\n" "build," "Constrói as imagens Docker dos serviços."
	@printf "    build-dev\n\n"

	@printf "  %-30s %s\n" "up," "Cria e inicia os containers em segundo plano."
	@printf "    up-dev\n\n"

	@printf "  %-30s %s\n" "down," "Para e remove os containers, redes e recursos associados."
	@printf "    down-dev\n\n"

	@printf "  %-30s %s\n" "stop," "Interrompe a execução dos containers sem removê-los."
	@printf "    stop-dev\n\n"

	@printf "  %-30s %s\n" "deploy," "Implanta a aplicação construindo as imagens Docker dos serviços,"
	@printf "    %-23s %s\n\n" "deploy-dev" "criando e iniciando os containers, executando o 'build' e 'up' respectivamente."

	@printf "  %-30s %s\n" "rebuild," "Reconstrói as imagens e recria os containers."
	@printf "    rebuild-dev\n\n"

	@printf "  %-30s %s\n" "restart," "Para e inicia novamente os containers."
	@printf "    restart-dev\n\n"

	@printf "  %-30s %s\n" "status," "Lista os containers em execução gerenciados pelo Docker Compose."
	@printf "    status-dev\n\n"

	@printf "  %-30s %s\n" "status-all," "Lista todos os containers (incluindo containers parados) gerenciados pelo Docker Compose."
	@printf "    status-all-dev\n\n"

	@printf "  %-30s %s\n" "config," "Exibe informações do arquivo Compose no formato canônico."
	@printf "    config-dev\n\n"

	@printf "  %-30s %s\n" "validate," "Valida o arquivo Compose no modo silencioso. Útil para scripts e pipelines."
	@printf "    validate-dev\n\n"

	@printf "  %-30s %s\n" "logs," "Exibe os logs dos serviços em tempo real."
	@printf "    logs-dev\n\n"

	@printf "Aplicação:\n"
	@printf "  %-30s %s\n" "app-shell," "Abre um terminal no container de aplicação PHP-FPM."
	@printf "    app-shell-dev\n\n"

	@printf "  %-30s %s\n" "web-shell," "Abre um terminal no container do Nginx."
	@printf "    web-shell-dev\n\n"

	@printf "Banco de dados:\n"
	@printf "  %-30s %s\n" "db-cli-dev" "Abre um cliente Shell no container de banco de dados."
	@printf "    DATABASE_USER=<USER>\n\n"

	@printf "  %-30s %s\n" "db-dump-dev" "Gera um backup (dump SQL) do banco de dados."
	@printf "    DATABASE_USER=<USER>\n"
	@printf "    DATABASE_NAME=<NAME>\n\n"

	@printf "  %-30s %s\n" "db-restore-dev" "Restaura um banco de dados a partir de um arquivo de dump SQL."
	@printf "    DATABASE_USER=<USER>\n"
	@printf "    DATABASE_NAME=<NAME>\n"
	@printf "    DATABASE_DUMP_SQL=<DUMP_SQL>\n\n"

	@printf "Limpeza de ambiente:\n"
	@printf "  %-30s %s\n\n" "prune-cache" "Remove o cache de construção (build cache) não utilizado pelo Docker."
	@printf "  %-30s %s\n\n" "" "CUIDADO! Os comandos abaixo podem apagar os recursos criados."
	@printf "  %-30s %s\n" "prune-volumes" "Remove todos os volumes Docker que não estão em uso."
	@printf "  %-30s %s\n" "prune-networks" "Remove todas as redes Docker que não estão sendo utilizadas."
	@printf "  %-30s %s\n\n" "clean" "Limpeza total do ambiente. Remove o build cache, volumes e redes não utilizadas."

	@printf "Listar:\n"
	@printf "  %-30s %s\n" "list-images" "Lista as imagens Docker disponíveis no hospedeiro."
	@printf "  %-30s %s\n" "list-volumes" "Lista os volumes Docker existentes no hospedeiro."
	@printf "  %-30s %s\n" "list-networks" "Lista as redes Docker existentes no hospedeiro."
	@printf "  %-30s %s\n\n" "list-all" "Lista todos os componentes anteriores existentes no hospedeiro."

	@printf "Permissionamento:\n"
	@printf "  %-30s %s\n" "" "NOTA: Os comandos abaixo podem ser usados para corrigir possíveis erros relacionados"
	@printf "  %-30s %s\n\n" "" "a permissões nos arquivos e diretórios do projeto."

	@printf "  %-30s %s\n" "apply-permissions" "Aplica as permissões de usuário e grupo dono nos arquivos e diretórios do projeto."
	@printf "  %-30s %s\n" "" "Para usuário considera-se o usuário atual '`id -un`' e para grupo considera-se"
	@printf "  %-30s %s\n\n" "" "o grupo '$(DOCKER_GROUP)' (grupo gerenciado pelo Docker)."

	@printf "  %-30s %s\n" "add-user-groups" "Verifica e adiciona o usuário atual '`id -un`' aos grupos '$(DOCKER_GROUP)' (grupo gerenciado pelo Docker)"
	@printf "  %-30s %s\n\n" "" "e '$(APP_RUNTIME_GROUP)' (grupo usado pelo runtime da aplicação)."

	@printf "Comandos comuns:\n"
	@printf "  %-30s %s\n" "info" "Informações sobre o projeto."
	@printf "  %-30s %s\n" "version" "Versão do projeto."
	@printf "  %-30s %s\n\n" "help" "Este menu de ajuda."

	@printf "Comandos específicos de gerenciamento e manutenção da aplicação:\n"
	@printf "  %-48s %s\n" "glpi-console-list," "Lista os comandos disponibilizados pelo console do GLPI."
	@printf "    glpi-console-list-dev\n\n"

	@printf "  %-48s %s\n" "glpi-cache-clear," "Limpa o cache do GLPI."
	@printf "    glpi-cache-clear-dev\n\n"

	@printf "  %-48s %s\n" "glpi-build-compile-scss," "Compila os arquivos SCSS do GLPI."
	@printf "    glpi-build-compile-scss-dev\n\n"

	@printf "  %-48s %s\n" "glpi-system-check-requirements," "Verifica os requisitos de sistema do GLPI."
	@printf "    glpi-system-check-requirements-dev\n\n"

	@printf "  %-48s %s\n" "glpi-system-list-services," "Lista os serviços internos verificados pelo GLPI."
	@printf "    glpi-system-list-services-dev\n\n"

	@printf "  %-48s %s\n" "glpi-system-status," "Verifica o estado dos serviços internos do GLPI."
	@printf "    glpi-system-status-dev\n\n"

	@printf "  %-48s %s\n" "glpi-database-check-schema-integrity," "Verifica a integridade do esquema do banco de dados."
	@printf "    glpi-database-check-schema-integrity-dev\n\n"

	@printf "  %-48s %s\n" "glpi-diagnostic-check-documents-integrity," "Verifica a integridade dos documentos do GLPI."
	@printf "    glpi-diagnostic-check-documents-integrity-dev\n\n"

	@printf "  %-48s %s\n" "glpi-diagnostic-check-source-code-integrity," "Verifica a integridade do código-fonte do GLPI."
	@printf "    glpi-diagnostic-check-source-code-integrity-dev\n\n"

	@printf "  %-48s %s\n" "glpi-plugin-list," "Lista os plugins reconhecidos pelo GLPI."
	@printf "    glpi-plugin-list-dev\n\n"

	@printf "  %-48s %s\n" "glpi-maintenance-enable," "Ativa o modo de manutenção do GLPI."
	@printf "    glpi-maintenance-enable-dev\n\n"

	@printf "  %-48s %s\n" "glpi-maintenance-disable," "Desativa o modo de manutenção do GLPI."
	@printf "    glpi-maintenance-disable-dev\n\n"

	@printf "  %-48s %s\n" "glpi-task-unlock," "Desbloqueia todas as tarefas automáticas consideradas travadas."
	@printf "    glpi-task-unlock-dev\n\n"
