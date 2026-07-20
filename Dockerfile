# -----------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Copyright (c) 2026 Rafael Mendes
#
# This file is part of {Nome do projeto}.
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
# Este Dockerfile utiliza a estratégia de Multi-stage builds para organizar a
# construção da imagem em estágios independentes e reutilizáveis.
#
# A divisão em estágios reduz duplicação de instruções, melhora a manutenção do
# arquivo e permite compartilhar uma base comum entre diferentes ambientes.
#
# Estrutura dos estágios:
#
#   - base: Configuração e instalação de pacotes comuns, definição do processo
#           de inicialização (`ENTRYPOINT`) e demais componentes compartilhados
#           por todos os ambientes.
#
#   - app: Código-fonte da aplicação, arquivos auxiliares, configurações da
#          aplicação.
#
#   - dev: Especialização da imagem para desenvolvimento, adicionando ferramentas
#          de diagnóstico, depuração e configurações apropriadas para esse
#          ambiente.
#
#   - prd: Especialização da imagem para produção, aplicando configurações focadas
#          em desempenho, segurança e estabilidade.
#
# O ambiente final é definido pelo parâmetro de build `target`, permitindo gerar
# imagens específicas para desenvolvimento ou produção a partir de um único
# Dockerfile. Consulte o parâmetro `target` nos arquivos `docker-compose.yml` e
# `docker-compose.dev.yml`.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [BEGIN] Multi-stage: BASE
#
# Estágio responsável por preparar a imagem base da aplicação, contendo componentes
# comuns a todos os ambientes. Configuração do processo de inicialização (`ENTRYPOINT`),
# arquivos de inicialização, metadados da imagem e demais dependências
# compartilhadas entre os demais estágios.
# -----------------------------------------------------------------------------

# Imagem base para aplicação.
ARG APP_BASE_IMG=php:8.5-apache
FROM ${APP_BASE_IMG} AS base

# Variáveis de build, usadas durante a construção da imagem.
#
# Para mais informações, consulte os arquivos `docker-compose.yml`
# e `docker-compose.dev.yml`. Veja também os arquivos `.env` e `.env.dev`.
ARG APP_DIR
ARG APP_CONFIG_DIR
ARG BUILD_DATE
ARG ENV_TYPE
ARG LICENSE
ARG PROJECT_NAME
ARG PROJECT_DESCRIPTION
ARG PROJECT_AUTHORS
ARG REVISION
ARG SSL_DIR
ARG TAG_IMAGE
ARG TEMPLATES_DIR
ARG TZ
ARG VENDOR_LABEL
ARG WEBSERVER_PORT
ARG WEBSERVER_PORT_SSL

# Variáveis de ambiente, usadas durante a inicialização e execução dos containers.
#
# Demais variáveis de ambiente usadas são passadas via propriedade `environment`.
# Para mais informações, consulte os arquivos `docker-compose.yml` e `docker-compose.dev.yml`.
ENV DEBIAN_FRONTEND=noninteractive

# Metadados da imagem.
LABEL org.opencontainers.image.title="${PROJECT_NAME}"
LABEL org.opencontainers.image.description="${PROJECT_DESCRIPTION}"
LABEL org.opencontainers.image.authors="${PROJECT_AUTHORS}"
LABEL org.opencontainers.image.licenses="${LICENSE}"
LABEL org.opencontainers.image.vendor="${VENDOR_LABEL}"
LABEL org.opencontainers.image.version="${TAG_IMAGE}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${REVISION}"

# Diretório padrão de trabalho.
WORKDIR ${APP_DIR}

# Conteúdo da aplicação.
COPY app/ .

# Diretório de certificados SSL.
COPY data/utils/ssl/ ${SSL_DIR}/

# Diretório de templates.
COPY data/utils/templates/ ${TEMPLATES_DIR}/

# Web server.
RUN a2enmod rewrite ssl headers

# ENTRYPOINT.
COPY data/utils/app-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/app-entrypoint

# Updates e instalação de pacotes comuns.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    logrotate \
    cron \
    gettext-base

# Definindo a timezone.
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

# Definindo o rotacionamento de logs.
RUN test -f /etc/logrotate.conf \
    && sed -i 's/weekly/daily/g' /etc/logrotate.conf \
    || echo "'/etc/logrotate.conf' não encontrado, ignorando..."

# Inicializa configurações gerais para aplicação.
ENTRYPOINT ["app-entrypoint"]
# -----------------------------------------------------------------------------
# [END] Multi-stage: BASE
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [BEGIN] Multi-stage: APP
#
# Estágio responsável por montar a aplicação. Inclui o código-fonte, arquivos
# auxiliares, configurações e instalação de pacotes específicos da aplicação.
# Este estágio serve como base para as imagens finais produção e desenvolvimento.
# -----------------------------------------------------------------------------
FROM base AS app

# TODO: Adicione aqui as instruções para o build da imagem da aplicação comuns
# aos dois ambientes (produção e desenvolvimento). Então, especialize as instruções
# apropriadas nos estágios abaixo.

# -----------------------------------------------------------------------------
# [END] Multi-stage: APP
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [BEGIN] Multi-stage: DESENVOLVIMENTO
#
# Estágio destinado ao ambiente de desenvolvimento. Estende o estágio 'app'
# adicionando ferramentas de diagnóstico, edição e depuração, além de configurações
# voltadas para facilitar o desenvolvimento, depuração e testes locais da aplicação.
# -----------------------------------------------------------------------------
FROM app AS dev

# Updates e instalação de pacotes restritos ao ambiente de desenvolvimento.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    libarchive-tools \
    unzip \
    gnupg \
    vim \
    iproute2 \
    iputils-ping \
    dnsutils

# TODO: Adicione aqui as instruções para o build da imagem da aplicação voltada
# ao ambiente de desenvolvimento.

# Portas de serviço para a aplicação.
EXPOSE ${WEBSERVER_PORT} ${WEBSERVER_PORT_SSL}
# -----------------------------------------------------------------------------
# [END] Multi-stage: DESENVOLVIMENTO
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# [BEGIN] Multi-stage: PRODUÇÃO
#
# Estágio destinado ao ambiente de produção. Estende o estágio 'app' aplicando
# configurações voltadas para desempenho, segurança e estabilidade, resultando
# na imagem final otimizada para execução da aplicação em ambientes produtivos.
# -----------------------------------------------------------------------------
FROM app AS prd

# TODO: Adicione aqui as instruções para o build da imagem da aplicação voltada
# ao ambiente de produção.

# Limpeza de cache do apt-get.
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Portas de serviço para a aplicação.
EXPOSE ${WEBSERVER_PORT_SSL}
# -----------------------------------------------------------------------------
# [END] Multi-stage: PRODUÇÃO
# -----------------------------------------------------------------------------
