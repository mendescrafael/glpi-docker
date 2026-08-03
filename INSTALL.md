# Instalação

Este documento descreve como preparar, configurar e executar o projeto GLPI Docker em ambientes de desenvolvimento e produção.

O projeto utiliza Docker Multi-stage builds, Docker Compose, arquivos de ambiente, templates, `ENTRYPOINT` e Makefile para padronizar a implantação do GLPI.

## Pré-requisitos

### Sistema operacional

O projeto foi desenvolvido para sistemas GNU/Linux.

Para desenvolvimento em Windows, utilize preferencialmente o WSL e mantenha o repositório em um sistema de arquivos Linux.

### Ferramentas necessárias

Instale e configure:

- Docker Engine;
- Docker Compose Plugin;
- Git;
- GNU Make;
- `awk`;
- `getent`;
- `grep`;
- `id`;
- `usermod`;
- `sudo`, quando necessário para grupos e permissões;
- `mysql` e `mysqldump`, quando forem utilizados os alvos de backup e restauração.

Confirme as ferramentas principais:

```bash
docker --version
docker compose version
git --version
make --version
```

O usuário atual deve possuir permissão para executar o Docker.

## Visão geral dos ambientes

A arquitetura contempla dois ambientes:

- **Desenvolvimento:** a aplicação GLPI e o banco de dados são executados em containers.
- **Produção:** a aplicação GLPI é executada em container e o banco de dados é provisionado externamente, em infraestrutura dedicada ou gerenciada.

Os comandos do Makefile com o sufixo `-dev` operam no ambiente de desenvolvimento. Os comandos equivalentes sem esse sufixo operam no ambiente de produção.

```text
make deploy-dev    # Desenvolvimento
make deploy        # Produção
```

## Obtendo o projeto

Clone o repositório e acesse sua raiz:

```bash
git clone https://github.com/mendescrafael/glpi-docker.git && cd glpi-docker
```

A raiz deve conter, no mínimo:

```text
app/
data/
.env.example
.env.dev.example
docker-compose.yml
docker-compose.dev.yml
Dockerfile
Makefile
README.md
```

## Estrutura principal

A estrutura base do projeto é:

```text
./
├── app/
├── data/
│   ├── app/
│   │   ├── config/
│   │   ├── files/
│   │   ├── marketplace/
│   │   └── plugins/
│   ├── db/
│   │   └── dumps/
│   ├── misc/
│   └── utils/
│       ├── ssl/
│       │   ├── cert-file.crt.example
│       │   └── cert-file.key.example
│       ├── templates/
│       │   ├── app-site-cfg.conf.template
│       │   ├── app-site-vhost.conf.template
│       │   └── app-cron.template
│       └── app-entrypoint
├── .env
├── .env.dev
├── .env.dev.example
├── .env.example
├── docker-compose.dev.yml
├── docker-compose.yml
├── Dockerfile
├── Makefile
└── README.md
```

Os diretórios possuem as seguintes responsabilidades:

- `app/`: código-fonte base do GLPI;
- `data/app/config/`: configurações persistentes do GLPI;
- `data/app/files/`: arquivos persistentes do GLPI;
- `data/app/marketplace/`: plugins instalados pelo Marketplace;
- `data/app/plugins/`: plugins instalados manualmente;
- `data/db/dumps/`: dumps do banco de dados no ambiente de desenvolvimento;
- `data/misc/`: arquivos auxiliares;
- `data/utils/ssl/`: certificados SSL;
- `data/utils/templates/`: templates processados pelo `ENTRYPOINT`;
- `data/utils/app-entrypoint`: script de inicialização da aplicação.

## Personalização do projeto

Antes da primeira execução, revise os valores específicos do ambiente e do cliente.

### Identidade do projeto

Revise:

- nome e descrição do projeto;
- autores e licença;
- identificação do cliente;
- versão do GLPI;
- imagens base da aplicação e do banco;
- nomes de imagens, containers, volumes e redes;
- domínio, portas e certificados;
- metadados OCI da imagem.

Não mantenha valores de exemplo em ambientes reais.

### Código da aplicação

O código-fonte base do GLPI fica em:

```text
app/
```

Confirme que a versão presente nesse diretório corresponde à versão declarada em `APP_VERSION` e à configuração do Dockerfile.

### Imagens base e estágios

Revise o Dockerfile para garantir que ele:

- utilize a imagem PHP adequada;
- instale as extensões necessárias ao GLPI;
- copie o GLPI para o caminho correto;
- preserve os estágios `BASE`, `APP`, `DEV` e `PRD`;
- defina corretamente `WORKDIR`, `ENTRYPOINT` e `CMD`;
- mantenha as ferramentas de diagnóstico apenas no estágio `DEV`;
- mantenha as configurações de desempenho e segurança no estágio `PRD`.

## Arquivos de ambiente

Crie os arquivos locais a partir dos modelos:

```bash
cp .env.example .env
cp .env.dev.example .env.dev
```

> **Importante:** o alvo `check` verifica a existência de `.env`, `.env.dev`, `docker-compose.yml`, `docker-compose.dev.yml` e `Dockerfile`. Portanto, os dois arquivos de ambiente devem existir mesmo quando a operação pretendida utilizar apenas a configuração de produção.

### `.env`

O arquivo `.env` reúne as definições gerais e de produção, incluindo metadados, versões, nomes dos recursos, caminhos, grupos e dados de conexão.

O Makefile lê diretamente estas variáveis:

```text
APP_BASE_IMG
APP_NAME
APP_VERSION
CLIENT_ID
DB_BASE_IMG
DOCKER_GROUP
LICENSE
PROJECT_NAME
PROJECT_DESCRIPTION
PROJECT_AUTHORS
WEBSERVER_GROUP
```

Preencha também todas as demais variáveis documentadas em `.env.example`.

### `.env.dev`

O arquivo `.env.dev` complementa as definições para o ambiente de desenvolvimento, no qual o banco de dados também é executado pelo Docker Compose.

Preencha todas as variáveis documentadas em `.env.dev.example`.

### Segurança dos arquivos de ambiente

Os arquivos `.env` e `.env.dev` podem conter credenciais, tokens, chaves, senhas e identificadores internos.

- Não versione esses arquivos.
- Não utilize valores reais nos arquivos `.example`.
- Não compartilhe seus conteúdos em logs ou documentação pública.
- Restrinja o acesso conforme as políticas do ambiente.

## Identificação e versionamento da imagem

O Makefile forma a tag da imagem a partir de `APP_VERSION` e da revisão atual do Git.

Quando o diretório pertence a um repositório Git:

```text
<versao-do-glpi>-<git-hash>
```

Quando existem alterações não commitadas:

```text
<versao-do-glpi>-<git-hash>-dirty
```

Quando o diretório não pertence a um repositório Git, a tag contém apenas a versão do GLPI.

Consulte a tag calculada:

```bash
make version
```

Exiba as informações técnicas detectadas:

```bash
make info
```

## Docker Compose

Revise os arquivos Docker Compose para refletir o ambiente no qual o GLPI será executado.

### Produção

O arquivo `docker-compose.yml` define o serviço da aplicação GLPI e os recursos necessários à execução em produção. O banco de dados deve permanecer externo ao Compose.

### Desenvolvimento

O arquivo `docker-compose.dev.yml` complementa o Compose principal com o serviço de banco de dados, volumes, portas e configurações destinadas ao ambiente local.

### Serviços

Mantenha os nomes dos serviços compatíveis com as variáveis do Makefile:

```make
SERVICE_APP ?= app
SERVICE_DB ?= db
```

Caso os serviços recebam outros nomes, altere essas variáveis no Makefile ou forneça os valores na execução.

## Templates

Os arquivos em:

```text
data/utils/templates/
```

contêm a estrutura das configurações do servidor web e do agendador.

Defina os valores nos arquivos `.env` e `.env.dev`, e não diretamente nos templates.

Edite os templates somente quando a estrutura da configuração do GLPI precisar ser alterada.

## ENTRYPOINT

O arquivo:

```text
data/utils/app-entrypoint
```

prepara o ambiente antes de iniciar o GLPI.

A rotina pode processar variáveis nos templates, configurar o servidor web, preparar diretórios, ajustar permissões, gerar arquivos de configuração e iniciar o processo principal do container.

Revise o script quando houver mudança de caminhos, servidor web, certificados ou rotina de inicialização.

## Certificados SSL

Quando forem utilizados certificados próprios, copie-os para:

```text
data/utils/ssl/
```

Mantenha os nomes esperados:

```text
cert-file.crt
cert-file.key
```

Os arquivos com sufixo `.example` servem somente como referência.

Nunca versione chaves privadas reais.

## Grupos do usuário

Depois de preencher `.env`, confira os valores de `DOCKER_GROUP` e `WEBSERVER_GROUP`.

Adicione o usuário atual aos grupos configurados:

```bash
make add-user-groups
```

Depois, encerre e inicie novamente a sessão, ou reinicie o WSL.

Confirme:

```bash
id
docker ps
```

## Permissões

Quando necessário, aplique o padrão de permissões:

```bash
make apply-permissions
```

O comando aplica recursivamente:

- diretórios: `775`;
- arquivos: `664`;
- proprietário: usuário atual;
- grupo: valor de `DOCKER_GROUP`.

> **Atenção:** o alvo utiliza `sudo chown` e `sudo chmod` em toda a raiz do projeto. Revise o conteúdo do diretório antes de executá-lo.

## Verificação inicial

Liste os comandos disponíveis:

```bash
make help
```

Exiba os dados do projeto:

```bash
make info
```

Consulte a versão calculada da imagem:

```bash
make version
```

## Validação da configuração

Antes de construir as imagens, valide o Docker Compose.

### Desenvolvimento

```bash
make config-dev
make validate-dev
```

### Produção

```bash
make config
make validate
```

`config` exibe a configuração resultante. `validate` executa a validação silenciosa.

Corrija todos os erros antes de prosseguir.

## Implantação em desenvolvimento

O ambiente de desenvolvimento combina `docker-compose.yml`, `docker-compose.dev.yml`, `.env` e `.env.dev`.

### Construção e inicialização

Execute:

```bash
make deploy-dev
```

Esse alvo executa `build-dev` e `up-dev`.

As etapas também podem ser executadas separadamente:

```bash
make build-dev
make up-dev
```

### Verificação

```bash
make status-dev
make status-all-dev
make logs-dev
```

### Acesso ao container

```bash
make app-shell-dev
```

Depois que os containers estiverem ativos, conclua a instalação inicial do GLPI quando necessário.

## Implantação em produção

O ambiente de produção utiliza `docker-compose.yml` e `.env`.

### Preparação

Antes da implantação:

- provisione o banco de dados externo;
- crie o banco e o usuário;
- conceda somente as permissões necessárias;
- configure a conectividade entre o container e o banco;
- configure os valores de conexão em `.env`;
- valide DNS, domínio, portas, certificados e firewall;
- confirme os volumes persistentes;
- revise limites de recursos e políticas de reinicialização;
- realize backup dos dados existentes.

### Construção e inicialização

Execute:

```bash
make deploy
```

Esse alvo executa `build` e `up`.

As etapas também podem ser executadas separadamente:

```bash
make build
make up
```

### Verificação

```bash
make status
make status-all
make logs
```

### Acesso ao container

```bash
make app-shell
```

Depois, conclua a instalação ou atualização do GLPI.

## Comandos operacionais

### Parar os containers

```bash
make stop-dev
make stop
```

### Parar e remover os containers

```bash
make down-dev
make down
```

### Reiniciar os serviços

```bash
make restart-dev
make restart
```

### Reconstruir o ambiente

```bash
make rebuild-dev
make rebuild
```

### Acompanhar os logs

```bash
make logs-dev
make logs
```

## Banco de dados no ambiente de desenvolvimento

O Makefile disponibiliza operações para o banco de dados do ambiente de desenvolvimento.

### Acesso ao cliente

```bash
make db-cli-dev
```

Quando necessário:

```bash
make db-cli-dev DATABASE_USER=<USUARIO>
```

### Gerar dump

Os comandos `mysql` e `mysqldump` devem estar disponíveis no host.

Execute:

```bash
make db-dump-dev DATABASE_USER=<USUARIO> DATABASE_NAME=<BANCO>
```

Quando os valores não forem fornecidos, o Makefile os solicita interativamente.

### Restaurar dump

```bash
make db-restore-dev DATABASE_USER=<USUARIO> DATABASE_NAME=<BANCO> DATABASE_DUMP_SQL=<ARQUIVO_SQL>
```

Antes de restaurar, confirme o banco de destino, mantenha um backup atual e verifique a compatibilidade do dump.

## Diagnóstico

### Arquivos obrigatórios

O alvo `check` exige:

```text
.env
.env.dev
docker-compose.yml
docker-compose.dev.yml
Dockerfile
```

### Docker sem `sudo`

Execute:

```bash
make add-user-groups
```

Depois, reabra a sessão e confirme:

```bash
docker ps
```

### Erros de permissão

Execute:

```bash
make apply-permissions
```

Revise também `DOCKER_GROUP` e `WEBSERVER_GROUP`.

### Erros do Docker Compose

Desenvolvimento:

```bash
make config-dev
make validate-dev
```

Produção:

```bash
make config
make validate
```

### Container não inicia

Desenvolvimento:

```bash
make status-all-dev
make logs-dev
```

Produção:

```bash
make status-all
make logs
```

Analise os logs antes de reconstruir ou remover recursos.

## Listagem de recursos Docker

```bash
make list-images
make list-volumes
make list-networks
make list-all
```

## Limpeza

O projeto disponibiliza:

```bash
make prune-cache
make prune-volumes
make prune-networks
make clean
```

`clean` executa a limpeza de cache de build, volumes não utilizados e redes não utilizadas.

> **Cuidado:** esses comandos atuam sobre recursos não utilizados do hospedeiro e podem afetar outros projetos Docker. Liste os recursos e realize backups antes da execução.

## Atualização

Antes de atualizar o GLPI Docker:

- gere backup do banco de dados;
- preserve `data/app/config/`, `data/app/files/`, `data/app/marketplace/` e `data/app/plugins/`;
- revise alterações em `.env.example` e `.env.dev.example`;
- compare o Dockerfile, os arquivos Compose, o `ENTRYPOINT` e os templates;
- valide primeiro em desenvolvimento ou homologação.

### Desenvolvimento

```bash
make validate-dev
make rebuild-dev
make status-dev
make logs-dev
```

### Produção

```bash
make validate
make rebuild
make status
make logs
```

## Recomendações

- Utilize Linux em produção.
- Utilize WSL para desenvolvimento em Windows.
- Mantenha o banco de dados de produção em infraestrutura externa, resiliente e protegida.
- Não armazene credenciais no repositório.
- Não versione chaves privadas.
- Use os arquivos `.env` para valores e os templates para estrutura.
- Valide primeiro em desenvolvimento ou homologação.
- Mantenha backups do banco e dos diretórios persistentes.
- Monitore logs, espaço em disco, memória, CPU e disponibilidade.
- Não exponha o banco de dados diretamente à internet.
- Use o Makefile para padronizar as operações.

## Detalhes específicos do GLPI Docker

### Conclusão da instalação do GLPI

Depois que os serviços estiverem ativos, acesse o endereço configurado para a aplicação.

Quando a instância ainda não estiver instalada, conclua o assistente de instalação do GLPI utilizando os dados de banco configurados para o ambiente.

Após concluir:

- acesse o GLPI com uma conta administrativa;
- confirme a gravação dos arquivos persistentes em `data/app/`;
- confirme que os containers permanecem saudáveis;
- consulte os logs;
- valide envio de e-mails, tarefas automáticas, autenticação e plugins.

### Limpeza do cache do GLPI

Desenvolvimento:

```bash
make glpi-cache-clear-dev
```

Produção:

```bash
make glpi-cache-clear
```

Utilize esses comandos quando alterações do GLPI, configurações ou plugins não forem reconhecidas imediatamente.

### Persistência e plugins

Preserve os diretórios:

```text
data/app/config/
data/app/files/
data/app/marketplace/
data/app/plugins/
```

`data/app/marketplace/` armazena plugins instalados pelo Marketplace. `data/app/plugins/` armazena plugins instalados manualmente.

Antes de atualizar ou reconstruir o ambiente, confirme que esses diretórios estão corretamente montados e incluídos na política de backup.
