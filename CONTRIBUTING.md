# Contribuindo

Este documento descreve o ambiente de desenvolvimento, a finalidade dos arquivos auxiliares presentes na raiz do projeto e os comandos usados para validar uma contribuição.

Antes de começar, leia o [README.md](README.md) para conhecer o projeto, o [INSTALL.md](INSTALL.md) para preparar o ambiente, o [USAGE.md](USAGE.md) para conhecer os procedimentos operacionais e o [SECURITY.md](SECURITY.md) para comunicar vulnerabilidades de forma responsável.

## Formas de contribuir

Você pode contribuir, por exemplo, com:

- Correções no Dockerfile, nos arquivos Docker Compose, no `ENTRYPOINT` e no Makefile;
- Melhorias nos ambientes de desenvolvimento e produção;
- Melhorias na integração, configuração e execução do GLPI em containers;
- Novos templates ou melhorias nos templates existentes;
- Correções e complementos na documentação;
- Melhorias de segurança, portabilidade, desempenho e compatibilidade;
- Relatos de erros com instruções que permitam reproduzir o problema;

Ao propor uma mudança, preserve o objetivo do projeto: oferecer uma infraestrutura Docker padronizada e reproduzível para o GLPI, com separação clara entre desenvolvimento e produção e configurações parametrizadas por arquivos de ambiente.

## Pré-requisitos e preparação do ambiente

O desenvolvimento deve ser feito preferencialmente em GNU/Linux. No Windows, utilize o WSL e mantenha o repositório em um sistema de arquivos Linux.

Instale os pré-requisitos descritos no [INSTALL.md](INSTALL.md), incluindo Docker Engine, Docker Compose Plugin, Git, GNU Make e os utilitários de sistema exigidos pelo Makefile. Os comandos `mysql` e `mysqldump` também são necessários para os alvos de backup e restauração. O usuário atual deve possuir permissão para executar o Docker.

Faça um fork do repositório, clone-o e crie uma branch para a contribuição:

```bash
git clone https://github.com/SEU-USUARIO/glpi-docker.git
cd glpi-docker
git switch -c tipo/descricao-curta
```

Use um nome de branch curto e descritivo, como `fix/entrypoint-permissions` ou `docs/install-requirements`.

Crie os arquivos de ambiente locais a partir dos exemplos:

```bash
cp .env.example .env
cp .env.dev.example .env.dev
```

Preencha-os com valores adequados ao seu ambiente. Os dois arquivos são exigidos pelo alvo `check`, inclusive quando a validação utiliza somente a configuração de produção.

Consulte os comandos disponíveis e as informações detectadas para o projeto:

```bash
make help
make info
make version
```

Se precisar ajustar grupos ou permissões, siga as orientações do [INSTALL.md](INSTALL.md). Antes de executar `make apply-permissions`, considere que o alvo altera recursivamente proprietário, grupo e permissões de toda a raiz do repositório.

## Estrutura de arquivos e diretórios

> **Nota:** esta árvore destaca apenas os arquivos e diretórios mais relevantes.

```text
.
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
├── .git/
├── .dockerignore
├── .env
├── .env.dev
├── .env.dev.example
├── .env.example
├── .gitattributes
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── docker-compose.dev.yml
├── docker-compose.yml
├── Dockerfile
├── INSTALL.md
├── LICENSE
├── Makefile
├── README.md
├── SECURITY.md
├── SUPPORT.md
└── USAGE.md
```

## Ambiente de desenvolvimento

O ambiente de desenvolvimento combina o código do GLPI, os serviços definidos pelo Docker Compose e os arquivos locais `.env` e `.env.dev`. Mantenha as configurações de desenvolvimento separadas das definições de produção e use dados descartáveis nas validações.

### Artefatos de desenvolvimento na raiz do projeto

Os arquivos mantidos na raiz concentram a configuração dos ambientes, a automação, a construção das imagens e a documentação necessária à colaboração.

### Controle do repositório e colaboração

- `.git/`: Armazena os metadados locais do repositório e não integra os artefatos distribuídos;
- `.gitattributes`: Normaliza arquivos de texto, identifica formatos binários e controla exclusões aplicáveis aos pacotes;
- `.gitignore`: Impede o versionamento de arquivos locais, dados persistentes e artefatos gerados;
- [CONTRIBUTING.md](CONTRIBUTING.md): Centraliza a preparação do ambiente e o fluxo de validação para contribuidores;

### Dependências e artefatos específicos

- `.env` e `.env.dev`: Contêm configurações locais e não devem ser versionados;
- `.env.example` e `.env.dev.example`: Documentam as variáveis aceitas com valores genéricos;
- `app/`: Contém o código-fonte do GLPI compatível com a versão declarada pelo projeto;
- `data/app/`: Armazena configurações, arquivos e plugins persistentes da aplicação;
- `data/db/dumps/` e `data/misc/`: Recebem dumps e artefatos locais que não pertencem ao repositório;
- `data/utils/ssl/`: Recebe os certificados ativos, enquanto os arquivos `.example` preservam somente a nomenclatura esperada;

### Diretrizes para as alterações

Preserve a separação entre desenvolvimento e produção e avalie o impacto das mudanças sobre imagens, containers, volumes, redes, templates, persistência e inicialização.

#### Diretrizes específicas do projeto

##### Ambientes e Docker

- Preserve, sempre que possível, os estágios `BASE`, `APP`, `DEV` e `PRD` do Dockerfile e a separação de responsabilidades entre eles;
- Mantenha no estágio `BASE` o código-fonte com suas permissões iniciais, o `ENTRYPOINT`, os templates, os certificados e os pacotes comuns; no `APP`, as extensões e configurações PHP exigidas pelo GLPI; no `DEV`, as ferramentas de desenvolvimento; e no `PRD`, as configurações de desempenho, segurança e limpeza da imagem;
- Mantenha a versão presente em `app/` compatível com `APP_VERSION` e com as definições do Dockerfile;
- Preserve a compatibilidade com GLPI 11, PHP 8.5 e MySQL 9.7 LTS;
- Considere que a aplicação e o banco de dados são executados em containers no desenvolvimento, enquanto o banco de produção é externo ao Docker Compose;
- Prefira configurações, APIs públicas e mecanismos nativos do GLPI a detalhes internos frágeis;
- Preserve os metadados OCI, o gerenciamento adequado de sinais e as práticas de segurança das imagens;
- Ao alterar caminhos ou volumes, verifique a persistência de configurações, arquivos e plugins do GLPI;

##### Variáveis de ambiente e templates

- Defina valores configuráveis em `.env` e `.env.dev`; não grave valores específicos do ambiente diretamente nos arquivos `.template`;
- Ao criar, remover ou alterar uma variável, atualize os arquivos `.env.example` e `.env.dev.example` aplicáveis e a documentação;
- Use valores fictícios e seguros nos arquivos de exemplo;
- Mantenha os templates em `data/utils/templates/` restritos à estrutura das configurações do servidor web e do agendador;
- Faça alterações estruturais nos templates somente quando elas não puderem ser expressas por variáveis;

##### Docker Compose

- Mantenha as definições comuns e de produção em `docker-compose.yml` e as especializações de desenvolvimento em `docker-compose.dev.yml`;
- Mantenha o banco de dados de produção externo ao Docker Compose. O serviço de banco conteinerizado pertence ao ambiente de desenvolvimento;
- Preserve os nomes padrão dos serviços `app` e `db`. Se a alteração exigir outros nomes, atualize `SERVICE_APP` e `SERVICE_DB` no Makefile e documente a mudança;
- Siga os padrões de nomenclatura de imagens, containers, hosts, volumes, redes e bancos de dados descritos no [README.md](README.md);
- Declare explicitamente os volumes persistentes e confirme que configurações, arquivos, plugins e dados do banco não serão perdidos durante a recriação dos containers;
- Preserve no serviço `app` os bind mounts de configuração, arquivos, Marketplace e plugins, a política de reinicialização, a verificação de integridade e a rotação do driver de logs;
- Considere que o override de desenvolvimento substitui o código incorporado à imagem pelo bind mount `./app:${APP_DIR}:rw`, desativa a reinicialização automática e adiciona o serviço MySQL, seu volume nomeado e o diretório de dumps;
- Mantenha `APP_ENV` compatível com os targets finais `dev` e `prd` disponíveis no Dockerfile;
- Não exponha o banco de dados diretamente à internet;

##### Padrões de nomenclatura

Os nomes dos recursos devem permitir identificar rapidamente a aplicação, o cliente, o serviço e o ambiente, inclusive em infraestruturas multi-tenant.

###### Componentes Docker Compose

- Imagem (`image`): Use `<vendor>/<aplicacao>-<cliente>:<versao-aplicacao>-<git-hash>`, como `contoso/glpi-contoso:1.0.0-9bd1a79`;
- Serviço (`service`): Use o nome funcional do serviço, como `app` para a aplicação e `db` para o banco de dados;
- Container (`container_name`): Use `<nome-aplicacao>-<cliente>-<servico>-<aplicacao-servico>-<ambiente>`, como `glpi-contoso-db-mysql-prd`;
- Host (`hostname`): Use `<servico>-<aplicacao-servico>-<ambiente>`, como `db-mysql-prd`;
- Volume persistente (`volumes`): Use `<nome-aplicacao>-<cliente>-<recurso-consumidor>-<ambiente>`, como `glpi-contoso-mysql-prd`;
- Rede (`networks`): Use `<nome-aplicacao>-<cliente>`, como `glpi-contoso`;

###### Banco de dados

- Banco (`db_name`): Use `<nome-aplicacao>-<cliente>-<ambiente>`, como `glpi-contoso-prd`;

##### `ENTRYPOINT`

- Mantenha `data/utils/app-entrypoint` compatível com as variáveis, os templates, os caminhos persistentes e o servidor web utilizados pelo projeto;
- Prefira rotinas idempotentes, que possam ser executadas mais de uma vez com segurança;
- Evite migrações irreversíveis ou operações destrutivas durante a inicialização;
- Preserve o permissionamento necessário para que o GLPI acesse suas configurações e arquivos persistentes;
- Normalize durante o build as permissões e a propriedade do código incorporado à imagem e restrinja os ajustes do `ENTRYPOINT` aos diretórios graváveis;
- Preserve no código incorporado à imagem a propriedade `WEBSERVER_USER:WEBSERVER_GROUP`, o modo `750` para diretórios e `640` para arquivos;
- Inicialize em runtime somente `APP_CONFIG_DIR`, `APP_FILES_DIR`, `${APP_DIR}/marketplace`, `${APP_DIR}/plugins` e `${APP_DIR}/public/css_compiled`, usando diretórios `2770`, arquivos `660` e o bit `setgid` para herdar `WEBSERVER_GROUP`;
- Considere `${APP_DIR}/public/css_compiled` como parte do core do GLPI: o caminho não integra a validação que cria diretórios obrigatórios, mas recebe o permissionamento gravável necessário à compilação de SCSS;
- Preserve a execução inicial como `root`, necessária para preparar configurações do sistema, permissões, certificados, Cron e Apache; execute as operações do console do GLPI como `WEBSERVER_USER` por meio da função `run_glpi_console`;
- Evite ajustes recursivos em todo o diretório da aplicação durante cada inicialização;
- Inicie o processo principal de forma que ele receba corretamente os sinais enviados pelo Docker;

##### Código, persistência e plugins do GLPI

- Não modifique o core do GLPI nem aplique patches em suas classes, templates, JavaScript, CSS ou arquivos públicos;
- Não copie arquivos do core para o projeto com o objetivo de sobrescrever comportamentos internos;
- Mantenha o código-fonte base do GLPI em `app/` compatível com a versão declarada pelo projeto;
- Preserve `data/app/config/`, `data/app/files/`, `data/app/marketplace/` e `data/app/plugins/` nas alterações de montagem, atualização ou reconstrução;
- Considere que `data/app/marketplace/` contém plugins instalados pelo Marketplace e `data/app/plugins/` contém plugins instalados manualmente;
- Ao modificar configurações ou plugins, verifique se o cache precisa ser limpo com `make glpi-cache-clear-dev` no desenvolvimento ou `make glpi-cache-clear` na produção;
- Não inclua no repositório dados gerados por uma instância local do GLPI;

## Uso do Makefile

O `Makefile` é a interface principal para consultar informações, validar configurações e operar os ambientes de desenvolvimento e produção. Execute os alvos a partir da raiz do projeto:

```bash
make help
make <COMANDO>
```

Sem um comando, `make` executa `info`, que é o alvo padrão. Os alvos com o sufixo `-dev` operam em desenvolvimento; os equivalentes sem esse sufixo operam em produção.

### Variáveis configuráveis

As variáveis podem ser sobrescritas na própria chamada. Por exemplo:

```bash
make validate ENV_FILE=.env
make db-dump-dev DATABASE_USER=<USUARIO> DATABASE_NAME=<BANCO>
```

- `ENV_FILE` e `ENV_FILE_DEV`: Arquivos de ambiente usados nas configurações de produção e desenvolvimento;
- `DOCKER_COMPOSE_FILE` e `DOCKER_COMPOSE_FILE_DEV`: Arquivos Docker Compose comuns e de desenvolvimento;
- `SERVICE_APP` e `SERVICE_DB`: Nomes dos serviços de aplicação e banco de dados; os padrões são `app` e `db`;
- `EXECUTABLE_DB` e `EXECUTABLE_DB_DUMP`: Clientes usados para restaurar e gerar dumps; os padrões são `mysql` e `mysqldump`;
- `CURRENT_USER`: Usuário proprietário dos arquivos e diretórios; o padrão é o usuário atual, obtido por `id -un`;
- `DOCKER_GROUP`: Grupo usado pelos alvos de permissionamento e obtido do arquivo de ambiente;
- `WEBSERVER_USER` e `WEBSERVER_GROUP`: Usuário e grupo do processo web usados nas operações da aplicação e obtidos do arquivo de ambiente;
- `DATABASE_USER`, `DATABASE_NAME` e `DATABASE_DUMP_SQL`: Parâmetros exigidos pelos alvos de banco de dados aplicáveis;

### Verificações de pré-requisitos

- `make check`: Verifica os comandos e os arquivos necessários às operações comuns;
- `make check-db-commands`: Verifica os clientes exigidos pelos alvos de dump e restauração;

Esses alvos também são chamados automaticamente como dependências dos comandos que precisam deles.

### Permissionamento do ambiente de desenvolvimento

Para adicionar o usuário atual aos grupos configurados e corrigir recursivamente proprietário, grupo e permissões, execute:

```bash
make add-user-groups
make apply-permissions
```

Após alterar os grupos do usuário, encerre e inicie novamente a sessão para aplicar a nova associação. Confirme `CURRENT_USER`, `DOCKER_GROUP` e `WEBSERVER_GROUP` antes do permissionamento, pois `apply-permissions` modifica toda a raiz do projeto.

### Validações de qualidade

- `make config` e `make config-dev`: Exibem a configuração final resolvida pelo Docker Compose;
- `make validate` e `make validate-dev`: Validam silenciosamente os arquivos Docker Compose;

### Operações específicas do projeto

#### Gerenciamento e execução dos ambientes

- `make build` e `make build-dev`: Constroem as imagens dos serviços;
- `make up` e `make up-dev`: Criam e iniciam os containers em segundo plano;
- `make down` e `make down-dev`: Param e removem os containers e os recursos associados;
- `make stop` e `make stop-dev`: Interrompem os containers sem removê-los;
- `make deploy` e `make deploy-dev`: Constroem as imagens e iniciam os ambientes;
- `make rebuild` e `make rebuild-dev`: Reconstroem as imagens e recriam os containers;
- `make restart` e `make restart-dev`: Interrompem e iniciam novamente os containers;
- `make status` e `make status-dev`: Listam os containers em execução;
- `make status-all` e `make status-all-dev`: Listam também os containers parados;
- `make logs` e `make logs-dev`: Acompanham os logs dos serviços em tempo real;

#### Aplicação e banco de dados

- `make app-shell` e `make app-shell-dev`: Abrem um terminal com o usuário padrão da imagem, atualmente `root`, no container de aplicação;
- `make db-cli-dev`: Abre o cliente no container de banco de dados de desenvolvimento;
- `make db-dump-dev`: Gera um dump SQL do banco de desenvolvimento;
- `make db-restore-dev`: Restaura um dump SQL no banco de desenvolvimento;
- `make glpi-console-list` e `make glpi-console-list-dev`: Listam os comandos disponibilizados pelo console do GLPI;
- `make glpi-cache-clear` e `make glpi-cache-clear-dev`: Limpam o cache do GLPI no ambiente correspondente;
- `make glpi-build-compile-scss` e `make glpi-build-compile-scss-dev`: Compilam os arquivos SCSS do GLPI;
- Alvos `glpi-system-*`, `glpi-database-check-schema-integrity*`, `glpi-diagnostic-*` e `glpi-plugin-list*`: Executam verificações e consultas administrativas;
- Alvos `glpi-maintenance-*` e `glpi-task-unlock*`: Alteram explicitamente o estado operacional da aplicação;

Os comandos, os efeitos e as restrições estão documentados em [Operações específicas da aplicação](USAGE.md#operações-específicas-da-aplicação).

Confirme o ambiente, o banco, o arquivo de dump e a existência de um backup atualizado antes de executar uma restauração.

#### Inspeção e limpeza

- `make info`: Exibe as informações resolvidas do projeto;
- `make version`: Exibe a versão e a tag do projeto;
- `make list-images`, `make list-volumes`, `make list-networks` e `make list-all`: Listam os recursos Docker do hospedeiro;
- `make prune-cache`: Remove o cache de construção não utilizado;
- `make prune-volumes` e `make prune-networks`: Removem volumes e redes Docker que não estão em uso;
- `make clean`: Agrega a limpeza do cache de construção, dos volumes e das redes não utilizados;

Liste e revise os recursos do hospedeiro antes dos alvos de limpeza, pois eles podem afetar outros projetos.

### Convenções para novos alvos

- Reutilize os alvos existentes sempre que possível;
- Adicione alvos específicos da aplicação na área reservada imediatamente antes do alvo `help`;
- Nomeie esses alvos no formato `glpi-comando`, por exemplo, `glpi-cache-clear`;
- Reutilize a função `run_glpi_console` nos alvos que executem `php bin/console`;
- Inclua novos alvos em `.PHONY`, quando aplicável, e documente-os na saída de `make help`;
- Mantenha pares de comandos com e sem o sufixo `-dev` quando a operação existir nos dois ambientes;
- Preserve a convenção de que os comandos com `-dev` operam em desenvolvimento e os equivalentes sem o sufixo operam em produção;
- Avalie cuidadosamente qualquer alvo que altere permissões, restaure bancos ou remova recursos Docker do hospedeiro;

## Padrões de código e documentação

### Linguagens e formatos utilizados

- Preserve a compatibilidade com Docker Engine 29.7 ou superior e com o Docker Compose;
- Mantenha as responsabilidades dos estágios, serviços, volumes, redes, templates e ambientes definidas nas seções anteriores;
- Siga a organização, a indentação e as convenções já adotadas nos arquivos Dockerfile, YAML e Makefile;
- Use recursos nativos do Bash e das ferramentas já adotadas pelo projeto sempre que forem suficientes;
- Valide variáveis de ambiente, argumentos e caminhos antes de executar operações que alterem configurações, permissões, bancos ou recursos Docker;
- Use aspas em expansões de variáveis e argumentos quando a separação de palavras ou a expansão de curingas não for intencional;
- Mantenha as rotinas do `ENTRYPOINT` idempotentes e preserve o encaminhamento de sinais ao processo principal;
- Não registre nem incorpore senhas, tokens, chaves, credenciais ou outros dados sensíveis no código ou nas imagens;

### Cabeçalho e documentação do código

Preserve o cabeçalho existente nos arquivos que já o adotam. Adicione o cabeçalho abaixo aos novos arquivos de código, adaptando apenas o tipo de comentário quando necessário:

```text
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
```

Preserve comentários e blocos de documentação existentes. Documente novas funções Shell, incluindo parâmetros, retorno, variáveis globais utilizadas, saídas e efeitos colaterais relevantes. Faça com que os comentários expliquem intenção e decisões, sem apenas repetir o código.

### Documentação do projeto

- Escreva a documentação em Português do Brasil;
- Inicie os itens de listas com palavras em maiúscula e finalize-os com `;`, exceto itens introdutórios que terminem com `:`;
- Transforme menções a outros arquivos Markdown em links relativos;
- Atualize o [README.md](README.md), o [INSTALL.md](INSTALL.md), o [USAGE.md](USAGE.md), o [CHANGELOG.md](CHANGELOG.md) e os arquivos de exemplo sempre que uma alteração modificar requisitos, variáveis, comandos, estrutura de diretórios ou comportamento;
- Use exemplos reproduzíveis e sem informações sensíveis;
- Diferencie explicitamente instruções de desenvolvimento e produção quando o procedimento não for o mesmo nos dois ambientes;
- Mantenha o [USAGE.md](USAGE.md) sincronizado com os comandos operacionais, as variáveis e o comportamento dos ambientes;
- Registre alterações relevantes na seção `[Unreleased]` do [CHANGELOG.md](CHANGELOG.md), na categoria apropriada;
- Não altere a versão do projeto sem solicitação explícita;

## Segurança e dados locais

Nunca inclua na contribuição:

- Arquivos `.env` ou `.env.dev`;
- Senhas, tokens, chaves de API ou outras credenciais;
- Certificados ou chaves privadas reais;
- Dumps de banco de dados;
- Logs ou conteúdo gerado em `data/misc/`;
- Configurações e arquivos persistentes gerados pela instância local em `data/app/`;
- Arquivos de sessão, cache, upload ou outros dados operacionais do GLPI;
- Logs que exponham informações confidenciais;

Antes de criar um commit, revise as alterações com `git diff` e `git status` e confirme que apenas os arquivos pretendidos serão enviados. Caso um relato de erro precise de logs, configurações ou capturas de tela, remova ou substitua todos os dados sensíveis.

## Validação das mudanças

Execute as verificações compatíveis com o escopo da contribuição. Para mudanças na infraestrutura, a validação mínima é:

```bash
make validate-dev
make validate
```

Quando precisar inspecionar a configuração final resolvida pelo Docker Compose, use `make config-dev` ou `make config`, mas não publique a saída sem antes verificar se há valores sensíveis.

Quando a mudança afetar a construção das imagens, execute também:

```bash
make build-dev
make build
```

Para alterações que afetem a execução em desenvolvimento, inicie a stack e verifique seu estado e seus logs:

```bash
make deploy-dev
make status-all-dev
make logs-dev
```

Interrompa o acompanhamento dos logs com `Ctrl+C` e remova a stack de desenvolvimento, quando não for mais necessária, com `make down-dev`.

Quando a mudança afetar a versão, a configuração ou a integração do GLPI, confirme também que a aplicação inicia corretamente, que os diretórios persistentes continuam acessíveis e que os recursos alterados, como autenticação, tarefas automáticas, envio de e-mails ou plugins, funcionam conforme esperado.

Não é necessário implantar em produção para validar uma contribuição. Não execute `make clean`, `make prune-volumes`, `make prune-networks` ou outros comandos de limpeza sem antes listar e revisar os recursos Docker do hospedeiro, pois esses alvos podem afetar outros projetos. Operações de restauração de banco também exigem confirmação do destino e um backup atualizado.

Se alguma verificação não puder ser executada, explique o motivo e informe no pull request quais validações foram realizadas. Atualizações da versão base do GLPI ou de plugins também devem executar os respectivos testes, linters ou verificações adicionais aplicáveis.

## Commits e pull requests

O projeto adota o padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/). Escreva cada mensagem de commit no seguinte formato:

```text
<tipo>[escopo opcional][!]: <descrição>

[corpo opcional]

[rodapé(s) opcional(is)]
```

Use um destes tipos conforme a natureza da alteração:

- `feat`: Adiciona uma funcionalidade;
- `fix`: Corrige um defeito;
- `docs`: Altera somente a documentação;
- `style`: Altera a formatação sem modificar o comportamento do código;
- `refactor`: Reorganiza o código sem corrigir defeito nem adicionar funcionalidade;
- `perf`: Melhora o desempenho;
- `test`: Adiciona ou ajusta testes;
- `build`: Altera o sistema de construção ou as dependências;
- `ci`: Altera arquivos ou rotinas de integração contínua;
- `chore`: Executa tarefas de manutenção que não se enquadram nos tipos anteriores;
- `revert`: Reverte um commit anterior;

O escopo é opcional e deve identificar de forma breve a área afetada, como `app`, `compose`, `db`, `dockerfile`, `entrypoint` ou `env`. Mantenha a descrição curta, direta e sem ponto final. Cada commit deve representar uma alteração lógica e autocontida.

Exemplos:

```text
feat(compose): adiciona um serviço de cache
fix(entrypoint): preserva a configuração existente da aplicação
docs: detalha a preparação do ambiente
build(dockerfile): atualiza as dependências da imagem
```

Para uma mudança incompatível, acrescente `!` antes de `:` e explique o impacto no corpo ou use um rodapé iniciado por `BREAKING CHANGE:`:

```text
feat(compose)!: altera o nome do serviço da aplicação

BREAKING CHANGE: os comandos e os arquivos de ambiente existentes devem usar o novo nome do serviço.
```

### PRs

Mantenha cada contribuição focada em um único objetivo e escreva mensagens de commit curtas, claras e no modo imperativo. Evite incluir reformatações ou alterações não relacionadas no mesmo pull request.

Ao abrir o pull request:

1. Descreva o problema ou a necessidade;
2. Explique a solução adotada e as principais decisões;
3. Liste os arquivos ou componentes afetados;
4. Informe os comandos usados para validar a alteração e seus resultados;
5. Destaque impactos, incompatibilidades, migrações ou mudanças em variáveis;
6. Associe a issue correspondente, quando houver;
7. Inclua logs ou capturas de tela somente quando forem úteis e estiverem sem dados sensíveis;

Antes do envio, confirme que:

- Os ambientes de desenvolvimento e produção continuam corretamente separados;
- O banco de dados permanece conteinerizado somente no ambiente de desenvolvimento;
- Os arquivos Compose foram validados;
- As imagens afetadas foram construídas com sucesso;
- A persistência de configurações, arquivos, plugins e dados foi preservada;
- Nenhuma credencial, chave privada, dump, log confidencial ou arquivo local foi incluído;
- Os arquivos `.example` e a documentação foram atualizados quando necessário;
- O [CHANGELOG.md](CHANGELOG.md) foi atualizado quando houve uma alteração relevante para usuários;
- Os novos alvos do Makefile aparecem em `make help`;
- A versão em `app/`, `APP_VERSION` e o Dockerfile permanecem compatíveis;
- A compatibilidade com Docker Engine 29.7 ou superior foi preservada;
- A compatibilidade com GLPI 11, PHP 8.5 e MySQL 9.7 LTS foi preservada;
- Nenhuma alteração ou sobrescrita do core do GLPI foi introduzida;

Durante a revisão, responda aos comentários e mantenha a branch atualizada. Alterações adicionais devem permanecer relacionadas ao objetivo original do pull request.

## Relatos de erros

Um bom relato deve conter:

- Descrição objetiva do comportamento observado e do comportamento esperado;
- Sistema operacional e versões do Docker, Docker Compose, Git e GNU Make;
- Versão do GLPI e tag da imagem informadas por `make info` e `make version`;
- Ambiente afetado: desenvolvimento ou produção;
- Passos mínimos para reproduzir o problema;
- Saída dos comandos de validação relevantes;
- Estado dos containers e logs necessários, devidamente anonimizados;

Antes de relatar o problema, consulte a seção de diagnóstico do [USAGE.md](USAGE.md) e as orientações do [SUPPORT.md](SUPPORT.md), verifique a configuração com os alvos apropriados e procure por uma issue equivalente.

## Licença

Ao enviar uma contribuição, você concorda que ela seja distribuída sob os termos da licença [LICENSE](LICENSE), adotada pelo projeto.
