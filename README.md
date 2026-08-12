# GLPI Docker

## Sobre o projeto

O GLPI Docker fornece uma infraestrutura conteinerizada para executar o GLPI de forma padronizada em ambientes de desenvolvimento e produção.

O GLPI é uma plataforma Open Source de Gerenciamento de Serviços de TI (ITSM) e Gerenciamento de Ativos de TI (ITAM), com recursos para Service Desk, inventário, contratos, licenças, base de conhecimento, mudanças, problemas e projetos. Para conhecer a aplicação, consulte o [site oficial do GLPI](https://www.glpi-project.org/).

## Motivação e objetivo

A preparação manual de ambientes do GLPI pode produzir diferenças de configuração, dependências e permissões entre desenvolvimento e produção. Este projeto concentra a infraestrutura em imagens, serviços, arquivos de ambiente e templates versionados para tornar a implantação reproduzível e facilitar sua manutenção.

O objetivo é preservar a separação entre os ambientes, manter os dados persistentes fora da imagem e permitir que configurações específicas sejam fornecidas sem acoplar a infraestrutura a um único servidor.

## Principais recursos

### Conteinerização e ambientes

- Imagens construídas com Docker Multi-stage builds;
- Estágios separados para recursos comuns, aplicação, desenvolvimento e produção;
- Aplicação e banco de dados conteinerizados no desenvolvimento;
- Aplicação conteinerizada e banco de dados externo em produção;
- Configurações distintas para desenvolvimento e produção;

### Configuração e automação

- Configuração orientada por arquivos de ambiente;
- Docker Compose para definição dos serviços, volumes e redes;
- Templates processados durante a inicialização;
- `ENTRYPOINT` centralizado para preparar o ambiente da aplicação;
- Makefile para validação, construção e operação dos ambientes;

### Persistência e integração com o GLPI

- Persistência das configurações e dos arquivos do GLPI;
- Diretórios separados para plugins do Marketplace e plugins instalados manualmente;
- Diretório dedicado a dumps do banco de desenvolvimento;
- Suporte a certificados SSL;
- Rotinas específicas para acesso ao GLPI, compilação de SCSS, limpeza de cache, diagnóstico, manutenção e gerenciamento do banco de desenvolvimento;

## Arquitetura e organização

### Visão geral

A infraestrutura separa a construção da imagem, a configuração da aplicação e a execução dos serviços. O Dockerfile produz imagens específicas para cada ambiente, enquanto o Docker Compose combina os serviços e os recursos necessários à execução.

Os procedimentos de preparação e primeira implantação estão no [INSTALL.md](INSTALL.md). Os comandos cotidianos e as operações de manutenção estão no [USAGE.md](USAGE.md).

### Ambientes suportados

- Desenvolvimento: Executa a aplicação GLPI e o banco de dados em containers;
- Produção: Executa a aplicação em container e utiliza um banco de dados provisionado externamente;

### Componentes principais

#### Dockerfile e estágios

O Dockerfile utiliza os estágios `BASE`, `APP`, `DEV` e `PRD`. O estágio base reúne recursos compartilhados, o estágio da aplicação incorpora o GLPI e os estágios finais aplicam as configurações específicas de desenvolvimento ou produção.

#### Docker Compose

O arquivo `docker-compose.yml` define a base do ambiente de produção. O arquivo `docker-compose.dev.yml` complementa essa configuração com o banco de dados e os recursos necessários ao desenvolvimento local.

#### Arquivos de ambiente

Os arquivos `.env` e `.env.dev` armazenam configurações locais e não devem ser versionados. Os arquivos `.env.example` e `.env.dev.example` documentam as variáveis aceitas usando valores genéricos.

#### `ENTRYPOINT` e templates

O `ENTRYPOINT` valida a configuração, processa os templates e prepara os diretórios antes de iniciar o processo principal. Os templates mantêm a estrutura das configurações do web server e do agendador sem incorporar valores específicos do ambiente.

### Padrões e convenções

#### Recursos Docker Compose

Imagens, containers, hosts, volumes e redes seguem uma nomenclatura que identifica aplicação, cliente, serviço e ambiente. As regras completas estão em [Padrões de nomenclatura](CONTRIBUTING.md#padrões-de-nomenclatura).

#### Banco de dados

O nome do banco identifica a aplicação, o cliente e o ambiente. A convenção detalhada também está em [Padrões de nomenclatura](CONTRIBUTING.md#padrões-de-nomenclatura).

## Estrutura de arquivos e diretórios

A árvore e a finalidade dos arquivos e diretórios relevantes estão documentadas em [Estrutura de arquivos e diretórios](CONTRIBUTING.md#estrutura-de-arquivos-e-diretórios).

## Compatibilidade

O projeto requer:

- Docker Engine 29.7 ou superior;
- Docker Compose;
- GLPI 11;
- PHP 8.5;
- MySQL 9.7 LTS no ambiente de desenvolvimento ou banco externo compatível em produção;

## Documentação

- [INSTALL.md](INSTALL.md): Preparação, configuração e primeira implantação do projeto;
- [USAGE.md](USAGE.md): Operação, manutenção, atualização e diagnóstico dos ambientes;
- [CONTRIBUTING.md](CONTRIBUTING.md): Preparação e diretrizes para contribuições;
- [SUPPORT.md](SUPPORT.md): Orientações para solicitar suporte;
- [SECURITY.md](SECURITY.md): Política e processo de relato de vulnerabilidades;
- [CHANGELOG.md](CHANGELOG.md): Histórico das alterações relevantes do projeto;

## Licença

Distribuído sob a licença [LICENSE](LICENSE).
