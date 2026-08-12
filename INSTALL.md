# Instalação

Este documento descreve como preparar, configurar e executar o projeto GLPI Docker em ambientes de desenvolvimento e produção.

O projeto fornece uma infraestrutura baseada em Docker Multi-stage builds, Docker Compose, arquivos de ambiente, templates, `ENTRYPOINT` e Makefile para padronizar a implantação do GLPI.

Depois de concluir a implantação, consulte o [USAGE.md](USAGE.md) para operar, manter, atualizar e diagnosticar os ambientes.

## Pré-requisitos

### Sistema operacional

O projeto foi desenvolvido para sistemas GNU/Linux.

Para desenvolvimento em Windows, utilize preferencialmente o WSL e mantenha o repositório em um sistema de arquivos Linux.

Para instalar o WSL, consulte a [documentação oficial da Microsoft](https://learn.microsoft.com/pt-br/windows/wsl/install). No VS Code, o diretório mantido no WSL pode ser acessado com o fluxo descrito no guia de [desenvolvimento remoto no WSL](https://code.visualstudio.com/docs/remote/wsl-tutorial).

### Ferramentas necessárias

Instale e configure:

- Docker Engine 29.7 ou superior;
- Docker Compose;
- Git;
- GNU Make;
- `awk`;
- `getent`;
- `grep`;
- `id`;
- `usermod`;
- `sudo` e os utilitários de gerenciamento de usuários, grupos e permissões do sistema, para usar os alvos de permissionamento;
- `mysql` e `mysqldump`, quando forem utilizados os alvos de backup e restauração;

Confirme as ferramentas principais:

```bash
docker --version
docker compose version
git --version
make --version
```

O usuário atual deve possuir permissão para executar o Docker.

## Obtendo o projeto

Clone o repositório e acesse sua raiz:

```bash
git clone https://github.com/mendescrafael/glpi-docker.git && cd glpi-docker
```

## Preparação

### Visão geral dos ambientes

A arquitetura contempla dois ambientes:

- **Desenvolvimento:** a aplicação GLPI e o banco de dados são executados em containers;
- **Produção:** a aplicação GLPI é executada em container e o banco de dados é provisionado externamente, em infraestrutura dedicada ou gerenciada;

Os comandos do Makefile com o sufixo `-dev` operam no ambiente de desenvolvimento. Os comandos equivalentes sem esse sufixo operam no ambiente de produção.

```text
make deploy-dev    # Desenvolvimento
make deploy        # Produção
```

### Personalização do projeto

Antes da primeira execução, revise os valores específicos do ambiente, da organização e do cliente.

#### Identidade do projeto

Revise:

- Nome e descrição do projeto;
- Autores e licença;
- Nome e versão do GLPI;
- Identificação da organização, do cliente e do ambiente;
- Imagens base da aplicação e do banco de dados;
- Nomes de imagens, containers, volumes e redes;
- Domínio, portas e certificados;
- Metadados OCI da imagem;

Não mantenha valores de exemplo em ambientes reais.

#### Código da aplicação

O código-fonte do GLPI fica em:

```text
app/
```

Confirme que a versão presente nesse diretório corresponde à versão declarada em `APP_VERSION` e à configuração do Dockerfile.

#### Imagens base e estágios

Revise o Dockerfile para garantir que ele:

- Utilize a imagem PHP adequada;
- Instale as extensões necessárias ao GLPI;
- Copie o GLPI para `APP_DIR` no estágio `BASE`, com proprietário e grupo do servidor web;
- Preserve o estágio `BASE` para o código, o `ENTRYPOINT`, os templates, os certificados e os pacotes comuns;
- Preserve o estágio `APP` para as extensões e configurações PHP exigidas pelo GLPI;
- Preserve o estágio `DEV` para as ferramentas de diagnóstico e as configurações PHP de desenvolvimento;
- Preserve o estágio `PRD` para as configurações PHP de desempenho e segurança e para a limpeza da imagem;
- Defina corretamente `WORKDIR` e `ENTRYPOINT`;
- Utilize em `APP_ENV` somente um target final existente, atualmente `dev` ou `prd`;

### Arquivos de ambiente

Crie os arquivos locais a partir dos modelos:

```bash
cp .env.example .env
cp .env.dev.example .env.dev
```

> **Importante:** o alvo `check` verifica a existência de `.env`, `.env.dev`, `docker-compose.yml`, `docker-compose.dev.yml` e `Dockerfile`. Portanto, os dois arquivos de ambiente devem existir mesmo quando a operação pretendida utilizar apenas a configuração de produção.

#### `.env`

O arquivo `.env` reúne as definições gerais e de produção.

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
WEBSERVER_USER
WEBSERVER_GROUP
```

Preencha também todas as demais variáveis utilizadas pelo Dockerfile, pelo Docker Compose, pelos templates e pelo `ENTRYPOINT`.

#### `.env.dev`

O arquivo `.env.dev` complementa as definições para o ambiente de desenvolvimento, incluindo as configurações do banco de dados executado em container.

Preencha todas as variáveis documentadas em `.env.dev.example`.

#### Segurança dos arquivos de ambiente

Os arquivos `.env` e `.env.dev` podem conter credenciais, tokens, chaves, senhas e identificadores internos.

- Não versione esses arquivos;
- Não utilize valores reais nos arquivos `.example`;
- Não compartilhe seus conteúdos em logs ou documentação pública;
- Restrinja o acesso conforme as políticas do ambiente;

### Identificação e versionamento da imagem

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

### Docker Compose

Revise os arquivos Docker Compose para refletir o ambiente no qual o GLPI será executado.

#### Produção

O arquivo `docker-compose.yml` define o serviço da aplicação GLPI, a rede, os bind mounts persistentes de configuração, arquivos e plugins, as portas HTTP e HTTPS e os demais recursos necessários à execução em produção. O banco de dados deve permanecer externo ao Compose.

O serviço utiliza `restart: always`, verifica a aplicação por HTTP em `http://localhost` a cada 60 segundos, com timeout de 10 segundos, três tentativas e período inicial de 90 segundos. Os logs usam o driver `json-file`, limitado a cinco arquivos de 10 MB. O target de build é obtido de `APP_ENV`.

O VirtualHost HTTP redireciona as requisições para HTTPS. O estágio `DEV` declara as duas portas com `EXPOSE`, enquanto o estágio `PRD` declara somente a porta HTTPS; o Compose ainda publica os dois mapeamentos porque `EXPOSE` funciona apenas como metadado da imagem.

#### Desenvolvimento

O arquivo `docker-compose.dev.yml` complementa o Compose principal com:

- Serviço de banco de dados MySQL;
- Volume persistente do banco de dados;
- Diretório de dumps;
- Bind mount `./app:${APP_DIR}:rw`, que substitui no container o código incorporado à imagem;
- Portas locais;
- Política `restart: no` para os serviços locais;
- Verificação do MySQL a cada 30 segundos, com timeout de 10 segundos, três tentativas e período inicial de 20 segundos;
- Rotação dos logs do MySQL em cinco arquivos de 10 MB;

#### Serviços

Mantenha os nomes dos serviços compatíveis com as variáveis do Makefile:

```make
SERVICE_APP ?= app
SERVICE_DB ?= db
```

Caso os serviços recebam outros nomes, altere essas variáveis no Makefile ou forneça os valores na execução.

### Templates

Os arquivos em:

```text
data/utils/templates/
```

contêm a estrutura das configurações do Apache e do agendador:

```text
app-site-cfg.conf.template
app-site-vhost.conf.template
app-cron.template
```

Defina os valores nos arquivos `.env` e `.env.dev`, e não diretamente nos templates.

Adapte os templates somente quando o GLPI exigir mudanças estruturais, como domínio, proxy reverso, certificados, cabeçalhos, regras de reescrita, agendamento de tarefas ou caminhos internos.

### ENTRYPOINT

O arquivo:

```text
data/utils/app-entrypoint
```

prepara o ambiente antes de iniciar o GLPI.

A rotina valida variáveis e caminhos obrigatórios, processa os templates, prepara os diretórios persistentes, configura o Cron e o Apache e, por fim, substitui o processo do script por `apache2-foreground`.

O Dockerfile não define `USER`, portanto o `ENTRYPOINT` inicia como `root`. Esse privilégio é necessário para ajustar propriedades e modos, escrever configurações em `/etc`, iniciar o Cron e preparar o Apache. As tarefas do Cron e os alvos `glpi-*` do Makefile executam o GLPI com o usuário definido em `WEBSERVER_USER`; a imagem base do Apache deve manter seus processos de atendimento compatíveis com esse mesmo usuário e grupo.

As permissões do código incorporado à imagem são normalizadas durante o build: proprietário e grupo definidos por `WEBSERVER_USER` e `WEBSERVER_GROUP`, diretórios `750` e arquivos `640`. Dessa forma, o processo web pode executar as rotinas administrativas do GLPI sem conceder acesso aos demais usuários do sistema.

Depois da montagem dos volumes, o `ENTRYPOINT` inicializa os diretórios graváveis `APP_CONFIG_DIR`, `APP_FILES_DIR`, `${APP_DIR}/marketplace`, `${APP_DIR}/plugins` e `${APP_DIR}/public/css_compiled` com o mesmo proprietário e grupo, diretórios `2770` e arquivos `660`. O caminho `public/css_compiled` permite que `build:compile_scss` grave os artefatos compilados.

Os quatro primeiros caminhos integram a validação de diretórios obrigatórios e são criados quando não existem. `${APP_DIR}/public/css_compiled` faz parte do core do GLPI e, por isso, não integra essa validação; o caminho deve existir no código fornecido em `app/`, mas ainda recebe o permissionamento gravável durante a inicialização.

O ajuste é recursivo somente quando o proprietário, o grupo ou o modo do diretório raiz não corresponde ao padrão. Nas inicializações seguintes, o processamento é ignorado. O bit `setgid` mantém o grupo definido por `WEBSERVER_GROUP` nos novos arquivos e diretórios criados nesses caminhos.

No desenvolvimento, o bind mount de `./app` substitui o conteúdo e as permissões incorporados à imagem. O `ENTRYPOINT` não normaliza todo o core montado; ele ajusta somente os cinco diretórios graváveis listados anteriormente. Preserve no hospedeiro a leitura e a travessia necessárias ao usuário do servidor web.

Os diretórios de certificados recebem modo `710` e seus arquivos, modo `640`. O arquivo gerado para o Cron recebe modo `644` antes da inicialização do serviço.

> **Atenção:** a validação atual registra nos logs o nome e o valor das variáveis obrigatórias, inclusive as variáveis de conexão com o banco de dados. Restrinja o acesso aos logs do container e não os compartilhe sem sanitização.

Revise o script quando houver mudança de caminhos, servidor web, certificados ou rotina de inicialização. Evite operações destrutivas, migrações irreversíveis ou rotinas que não possam ser executadas novamente com segurança.

### Certificados SSL

Antes da implantação, copie os certificados para:

```text
data/utils/ssl/
```

Mantenha os nomes exigidos pelo `ENTRYPOINT`:

```text
cert-file.crt
cert-file.key
```

Os arquivos com sufixo `.example` servem somente como referência de nomenclatura. A inicialização falhará se os dois arquivos esperados não estiverem presentes.

Nunca versione chaves privadas reais.

### Grupos do usuário

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

- Diretórios: `2775`, com o bit `setgid`;
- Arquivos regulares: `664`;
- Arquivos executáveis: `775`;
- Proprietário: usuário atual;
- Grupo: valor de `DOCKER_GROUP`;

> **Atenção:** o alvo utiliza `sudo chown` e `sudo chmod` em toda a raiz do projeto. Revise o conteúdo do diretório antes de executá-lo.

Esse alvo corrige as permissões do workspace no hospedeiro. Ao iniciar ou reiniciar o container, o `ENTRYPOINT` aplica o padrão específico da aplicação somente aos diretórios graváveis; ele não reaplica `750` e `640` a todo o bind mount de código do ambiente de desenvolvimento.

## Verificação

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

### Validação da configuração

Antes de construir as imagens, valide o Docker Compose.

#### Desenvolvimento

```bash
make config-dev
make validate-dev
```

#### Produção

```bash
make config
make validate
```

`config` exibe a configuração resultante. `validate` executa a validação silenciosa.

Corrija todos os erros antes de prosseguir.

### Implantação em desenvolvimento

O ambiente de desenvolvimento combina `docker-compose.yml`, `docker-compose.dev.yml`, `.env` e `.env.dev`.

#### Construção e inicialização

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

#### Verificação

```bash
make status-dev
make status-all-dev
make logs-dev
```

#### Acesso ao container

```bash
make app-shell-dev
```

Depois que os containers estiverem ativos, conclua a instalação inicial do GLPI quando necessário.

### Implantação em produção

O ambiente de produção utiliza `docker-compose.yml` e `.env`.

#### Preparação

Antes da implantação:

- Provisione o banco de dados externo;
- Crie o banco e o usuário;
- Conceda somente as permissões necessárias;
- Configure a conectividade entre a aplicação e o banco;
- Configure os valores de conexão em `.env`;
- Valide DNS, domínio, portas, certificados e firewall;
- Confirme os volumes persistentes;
- Revise limites de recursos e políticas de reinicialização;
- Realize backup dos dados existentes;

#### Construção e inicialização

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

#### Verificação

```bash
make status
make status-all
make logs
```

#### Acesso ao container

```bash
make app-shell
```

Depois, conclua a instalação ou atualização do GLPI.

### Detalhes específicos do GLPI Docker

#### Conclusão da instalação do GLPI

Depois que os serviços estiverem ativos, acesse o endereço configurado em `WEBSERVER_DOMAIN_NAME`.

Quando a instância ainda não estiver instalada, conclua o assistente de instalação do GLPI utilizando os dados de banco configurados para o ambiente.

Após concluir:

- Acesse o GLPI com uma conta administrativa;
- Altere ou remova as contas padrão conforme as recomendações de segurança do GLPI;
- Confirme a gravação dos arquivos persistentes em `data/app/`;
- Confirme que os containers permanecem saudáveis;
- Consulte os logs;
- Valide envio de e-mails, tarefas automáticas, autenticação e plugins;

#### Persistência e plugins

Preserve os diretórios:

```text
data/app/config/
data/app/files/
data/app/marketplace/
data/app/plugins/
```

`data/app/marketplace/` armazena plugins instalados pelo Marketplace. `data/app/plugins/` armazena plugins instalados manualmente no modo legacy.

Antes de atualizar ou reconstruir o ambiente, confirme que esses diretórios estão corretamente montados e incluídos na política de backup.

### Verificação final

Antes de considerar a implantação concluída, confirme:

- A versão do código em `app/` corresponde a `APP_VERSION`;
- `.env` e `.env.dev` foram criados e revisados;
- Os valores de exemplo foram substituídos;
- O banco externo de produção foi provisionado, quando aplicável;
- Os certificados SSL ativos foram adicionados com os nomes esperados;
- Os diretórios persistentes foram definidos e incluídos na política de backup;
- `make validate-dev` foi executado para o ambiente de desenvolvimento;
- `make validate` foi executado para o ambiente de produção;
- A implantação foi testada antes do uso em produção;
- O assistente de instalação ou o procedimento de atualização do GLPI foi concluído;
- As contas padrão foram alteradas ou removidas;
- Tarefas automáticas, e-mail, autenticação e plugins foram validados;
- Backups e procedimentos de recuperação foram definidos;

## Atualização

Antes de atualizar o GLPI Docker:

- Gere backup do banco de dados;
- Preserve os diretórios persistentes;
- Revise alterações em `.env.example` e `.env.dev.example`;
- Compare o Dockerfile, os arquivos Compose, o `ENTRYPOINT` e os templates;
- Verifique se personalizações locais serão sobrescritas;
- Valide primeiro em desenvolvimento ou homologação;

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

## Próximos passos

Depois de concluir a implantação e a verificação do GLPI, consulte o [USAGE.md](USAGE.md) para operar, manter, atualizar e diagnosticar os ambientes.

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

Revise também `DOCKER_GROUP`, `WEBSERVER_USER` e `WEBSERVER_GROUP`. Depois do ajuste no hospedeiro, reinicie o ambiente com `make restart-dev` no desenvolvimento ou `make restart` na produção para que o `ENTRYPOINT` inicialize os diretórios graváveis.

Se a falha ocorrer somente no desenvolvimento, lembre-se de que `./app:${APP_DIR}:rw` substitui as permissões definidas no build. Confirme que o usuário do servidor web consegue atravessar `APP_DIR/bin`, ler `bin/console` e gravar em `public/css_compiled`.

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

### Certificados não encontrados

Confirme que `data/utils/ssl/` contém os arquivos `cert-file.crt` e `cert-file.key`. Os arquivos `.example` não são utilizados pelo `ENTRYPOINT` como certificados ativos.

## Segurança

Proteja os arquivos de ambiente, certificados, dumps e diretórios persistentes. Para comunicar vulnerabilidades de forma responsável, siga o processo privado descrito no [SECURITY.md](SECURITY.md).
