# Uso

Este documento descreve como operar e manter o GLPI Docker depois da preparação e da primeira implantação do ambiente.

Para preparar o projeto e realizar a primeira implantação, consulte o [guia de instalação](INSTALL.md).

## Antes de começar

Antes de continuar, conclua os procedimentos descritos no [INSTALL.md](INSTALL.md), incluindo a criação dos arquivos de ambiente, a configuração dos certificados SSL, a validação do Docker Compose e a implantação inicial.

## Conceitos e configuração

### Ambientes

O projeto disponibiliza comandos distintos para desenvolvimento e produção:

| Ambiente | Convenção dos comandos | Serviços |
| -------- | ---------------------- | -------- |
| Desenvolvimento | Sufixo `-dev` | Aplicação GLPI e banco de dados MySQL em containers. |
| Produção | Sem o sufixo `-dev` | Aplicação GLPI em container e banco de dados externo. |

Execute os comandos na raiz do projeto. Os exemplos deste documento apresentam primeiro o ambiente de desenvolvimento e depois o equivalente de produção, quando ambos estiverem disponíveis.

### Informações do projeto

Liste os comandos disponíveis:

```bash
make help
```

Exiba as informações técnicas do projeto, das imagens base e da aplicação:

```bash
make info
```

Consulte a tag calculada para a imagem:

```bash
make version
```

A tag combina a versão do GLPI e a revisão atual do Git. O sufixo `-dirty` indica que arquivos rastreados pelo Git contêm alterações não commitadas.

## Operações

### Inicialização dos ambientes

#### Iniciar containers existentes

Use estes comandos quando as imagens já estiverem construídas:

```bash
make up-dev
make up
```

Os containers são iniciados em segundo plano.

#### Construir e iniciar

Use `deploy-dev` ou `deploy` na primeira implantação ou quando for necessário construir as imagens antes de iniciar os containers:

```bash
make deploy-dev
make deploy
```

Esses alvos executam, respectivamente, `build-dev` e `up-dev`, ou `build` e `up`.

#### Reconstruir o ambiente

Quando houver alterações no Dockerfile, nos arquivos Docker Compose ou nos artefatos incorporados à imagem, reconstrua o ambiente:

```bash
make rebuild-dev
make rebuild
```

O processo interrompe e remove os containers atuais, reconstrói as imagens e cria os containers novamente. Confirme previamente que os diretórios persistentes e o banco de dados estão protegidos por uma política de backup adequada.

### Estado, configuração e logs

Liste os containers em execução:

```bash
make status-dev
make status
```

Inclua também os containers interrompidos:

```bash
make status-all-dev
make status-all
```

Acompanhe os logs dos serviços em tempo real:

```bash
make logs-dev
make logs
```

Interrompa o acompanhamento com `Ctrl+C`. Isso encerra somente a exibição dos logs e não interrompe os containers.

O Docker Compose limita os logs de cada serviço a cinco arquivos de 10 MB pelo driver `json-file`. Encaminhe os logs para uma solução externa quando o histórico exigido exceder essa retenção local.

Ao investigar uma falha, consulte primeiro o estado de todos os containers e depois os logs do ambiente afetado.

O healthcheck da aplicação consulta `http://localhost` a cada 60 segundos, após um período inicial de 90 segundos. No desenvolvimento, o MySQL é verificado a cada 30 segundos, após um período inicial de 20 segundos. Ambos usam timeout de 10 segundos e três tentativas.

#### Validação da configuração

Exiba a configuração final resolvida pelo Docker Compose:

```bash
make config-dev
make config
```

Essa saída pode conter valores derivados dos arquivos de ambiente. Revise e sanitize o conteúdo antes de armazená-lo ou compartilhá-lo.

Valide a configuração silenciosamente:

```bash
make validate-dev
make validate
```

Execute a validação depois de alterar arquivos de ambiente, Docker Compose ou valores utilizados na construção das imagens.

### Interrupção e reinicialização

Interrompa os containers sem removê-los:

```bash
make stop-dev
make stop
```

Inicie-os novamente com `make up-dev` ou `make up`.

Reinicie os serviços:

```bash
make restart-dev
make restart
```

Pare e remova os containers e as redes criadas pelo Docker Compose:

```bash
make down-dev
make down
```

Os alvos `down-dev` e `down` não utilizam a opção `--volumes`. Mesmo assim, confirme os mapeamentos e os backups antes de alterar volumes ou executar operações de limpeza.

### Acesso à aplicação

Acesse o endereço definido em `WEBSERVER_DOMAIN_NAME` no arquivo de ambiente correspondente.

Depois da implantação, confirme:

- Disponibilidade da interface web;
- Estado saudável dos containers;
- Persistência das configurações e dos arquivos;
- Execução das tarefas automáticas;
- Envio de e-mails;
- Autenticação dos usuários;
- Funcionamento dos plugins instalados;

Consulte a documentação oficial do GLPI para os fluxos funcionais da aplicação, como gerenciamento de ativos, chamados, usuários, entidades e regras de negócio.

### Acesso ao container da aplicação

Abra um terminal no container da aplicação:

```bash
make app-shell-dev
make app-shell
```

Como o Dockerfile não define `USER`, esse terminal utiliza atualmente `root`. Use-o para diagnósticos pontuais e para tarefas de sistema que realmente exijam esse privilégio. Não altere manualmente arquivos do core nem grave configurações que serão perdidas quando o container for recriado.

### Operações específicas da aplicação

Os alvos desta seção executam `php bin/console` dentro do container com o usuário definido em `WEBSERVER_USER`, por meio de `su`. A execução parte do `WORKDIR` definido como `APP_DIR` no Dockerfile, de modo que o caminho relativo `bin/console` seja resolvido corretamente. Use o sufixo `-dev` no desenvolvimento e o alvo sem sufixo na produção.

Para uma execução manual, acesse primeiro `APP_DIR` ou use o caminho absoluto do console. Por exemplo:

```bash
cd "${APP_DIR}"
su -s /bin/bash -c "php bin/console cache:clear" "${WEBSERVER_USER}"
```

Prefira os alvos do Makefile, pois eles selecionam o Compose e o ambiente corretos e evitam depender do diretório atual do shell.

#### Consulta, validação e diagnóstico

| Alvo de produção | Comando do GLPI | Finalidade |
| ---------------- | --------------- | ---------- |
| `glpi-console-list` | `list` | Lista os comandos disponibilizados pelo console. |
| `glpi-system-check-requirements` | `system:check_requirements` | Verifica os requisitos de sistema. |
| `glpi-system-list-services` | `system:list_services` | Lista os serviços internos que podem ser consultados. |
| `glpi-system-status` | `system:status` | Verifica o estado dos serviços internos. |
| `glpi-database-check-schema-integrity` | `database:check_schema_integrity` | Compara o esquema atual com o esquema esperado. |
| `glpi-diagnostic-check-documents-integrity` | `diagnostic:check_documents_integrity` | Verifica a integridade dos documentos. |
| `glpi-diagnostic-check-source-code-integrity` | `diagnostic:check_source_code_integrity` | Verifica a integridade do código-fonte. |
| `glpi-plugin-list` | `plugin:list` | Lista os plugins reconhecidos pelo GLPI. |

Por exemplo, verifique o ambiente de desenvolvimento com:

```bash
make glpi-system-check-requirements-dev
make glpi-system-list-services-dev
make glpi-system-status-dev
make glpi-database-check-schema-integrity-dev
```

Os comandos de diagnóstico são somente de leitura, mas podem percorrer muitos arquivos ou retornar código diferente de zero quando encontrarem inconsistências.

#### Compilação de SCSS

Compile os arquivos SCSS depois de alterar temas ou fontes relacionadas:

```bash
make glpi-build-compile-scss-dev
make glpi-build-compile-scss
```

O alvo executa `build:compile_scss` com o usuário do servidor web e grava os artefatos em `public/css_compiled`. Durante a inicialização, o `ENTRYPOINT` atribui esse diretório a `WEBSERVER_USER:WEBSERVER_GROUP`, usa modo `2770` nos diretórios e `660` nos arquivos existentes.

#### Cache do GLPI

Limpe o cache depois de alterações em configurações ou plugins que não tenham sido reconhecidas pela aplicação:

```bash
make glpi-cache-clear-dev
make glpi-cache-clear
```

Os comandos executam o console do GLPI no container da aplicação com o usuário do servidor web.

#### Manutenção e tarefas automáticas

Ative ou desative o modo de manutenção:

```bash
make glpi-maintenance-enable-dev
make glpi-maintenance-disable-dev

make glpi-maintenance-enable
make glpi-maintenance-disable
```

Desbloqueie todas as tarefas automáticas consideradas travadas pelo GLPI:

```bash
make glpi-task-unlock-dev
make glpi-task-unlock
```

Esses comandos alteram o estado da aplicação. Confirme o ambiente e comunique a indisponibilidade antes de ativar o modo de manutenção. O desbloqueio usa `task:unlock --all`: considera o atraso padrão de 1.800 segundos do GLPI e atua em todas as tarefas que atendam a esse critério.

#### Comandos não encapsulados

O console também oferece operações de atualização e instalação do banco, migrações, gerenciamento de usuários, alteração de chaves de segurança, geração do manifesto de integridade, sincronização LDAP, regras, Marketplace e instalação ou remoção de plugins. Esses comandos não possuem atalhos no Makefile porque podem exigir parâmetros sensíveis, acesso externo, backup, confirmação do destino ou análise específica do impacto. A geração do manifesto também pode substituir a referência usada para verificar o código-fonte e deve ocorrer somente em um fluxo de build validado.

Quando uma dessas operações for necessária, abra o container com `make app-shell-dev` ou `make app-shell`, consulte primeiro `php bin/console help <COMANDO>` e siga o procedimento oficial aplicável. Não execute migrações, atualizações de esquema ou alterações de chaves sem um backup validado.

### Banco de dados no ambiente de desenvolvimento

Os comandos desta seção destinam-se somente ao banco MySQL conteinerizado do ambiente de desenvolvimento. Em produção, use os procedimentos e as ferramentas de backup da infraestrutura externa responsável pelo banco de dados.

#### Acessar o cliente

```bash
make db-cli-dev
```

Informe o usuário interativamente ou forneça-o no comando:

```bash
make db-cli-dev DATABASE_USER=<USUARIO>
```

A senha é solicitada pelo cliente MySQL e não deve ser adicionada à linha de comando, aos logs ou à documentação.

#### Gerar um dump

Os alvos de dump e restauração utilizam os clientes `mysqldump` e `mysql` instalados no hospedeiro.

Gere um dump informando o usuário e o banco de dados:

```bash
make db-dump-dev DATABASE_USER=<USUARIO> DATABASE_NAME=<BANCO>
```

Quando os valores não forem fornecidos, o comando os solicita interativamente. O arquivo é criado no diretório atual com o formato:

```text
dump_<AAAAMMDDHHMM>_<BANCO>.sql
```

Mova o dump para um local protegido e abrangido pela política de backup. Não versione arquivos SQL nem os publique sem sanitização.

#### Restaurar um dump

Antes da restauração, confirme o ambiente, o nome do banco, a compatibilidade do dump e a existência de um backup atualizado.

```bash
make db-restore-dev \
  DATABASE_USER=<USUARIO> \
  DATABASE_NAME=<BANCO> \
  DATABASE_DUMP_SQL=<ARQUIVO_SQL>
```

A restauração altera os dados do banco de destino. Não a execute em produção nem reutilize credenciais de produção no ambiente de desenvolvimento.

## Manutenção e cuidados

### Persistência e backup

Inclua estes diretórios na política de backup da aplicação:

```text
data/app/config/
data/app/files/
data/app/marketplace/
data/app/plugins/
```

As responsabilidades são:

- `data/app/config/`: Configurações persistentes do GLPI;
- `data/app/files/`: Arquivos, documentos, sessões e demais dados persistentes da aplicação;
- `data/app/marketplace/`: Plugins instalados pelo Marketplace do GLPI;
- `data/app/plugins/`: Plugins instalados manualmente no modo legacy;

O backup da aplicação não substitui o backup do banco de dados. Mantenha cópias consistentes de ambos e teste periodicamente o procedimento de restauração em um ambiente isolado.

### Atualização

Antes de atualizar:

- Gere backups do banco de dados e dos diretórios persistentes;
- Consulte o [CHANGELOG.md](CHANGELOG.md);
- Compare os arquivos `.env.example` e `.env.dev.example` com as configurações locais;
- Revise mudanças no Dockerfile, nos arquivos Docker Compose, no `ENTRYPOINT` e nos templates;
- Valide a atualização primeiro em desenvolvimento ou homologação;
- Confirme os requisitos da versão de destino do GLPI;

No ambiente de desenvolvimento:

```bash
make validate-dev
make rebuild-dev
make status-all-dev
make logs-dev
```

No ambiente de produção:

```bash
make validate
make rebuild
make status-all
make logs
```

Depois da atualização, conclua eventuais migrações apresentadas pelo GLPI e valide a interface, as tarefas automáticas, os e-mails, a autenticação e os plugins.

### Recursos do hospedeiro

Liste os recursos Docker do hospedeiro antes de executar qualquer limpeza:

```bash
make list-images
make list-volumes
make list-networks
make list-all
```

### Limpeza

O projeto disponibiliza estes comandos de limpeza:

```bash
make prune-cache
make prune-volumes
make prune-networks
make clean
```

> **Cuidado:** os comandos de limpeza atuam globalmente sobre recursos Docker não utilizados do hospedeiro e podem afetar outros projetos. `make clean` remove o cache de construção, os volumes não utilizados e as redes não utilizadas. Revise os recursos e mantenha backups antes da execução.

### Boas práticas operacionais

- Use os comandos do Makefile para manter a execução padronizada;
- Valide mudanças primeiro em desenvolvimento ou homologação;
- Mantenha o banco de produção em infraestrutura externa e protegida;
- Monitore disponibilidade, logs, espaço em disco, memória e CPU;
- Mantenha backups do banco e dos diretórios persistentes;
- Teste regularmente a restauração dos backups;
- Não versione arquivos de ambiente, certificados reais, dumps ou logs sensíveis;
- Não exponha o banco de dados diretamente à internet;
- Não modifique o core do GLPI;

## Diagnóstico

### Container parado ou não saudável

Consulte o estado completo e os logs:

```bash
make status-all-dev
make logs-dev
```

Ou, em produção:

```bash
make status-all
make logs
```

Valide também a configuração com `make validate-dev` ou `make validate` antes de reconstruir o ambiente.

### Erro de permissão

Confirme os valores de `DOCKER_GROUP` e `WEBSERVER_GROUP` e a associação do usuário aos grupos configurados.

Quando necessário, execute:

```bash
make add-user-groups
make apply-permissions
```

Depois de `make add-user-groups`, encerre e inicie novamente a sessão. O alvo `apply-permissions` altera recursivamente o proprietário, o grupo e as permissões da raiz do projeto; revise o diretório antes de executá-lo.

Em seguida, use `make restart-dev` no desenvolvimento ou `make restart` na produção. O `ENTRYPOINT` não altera o código completo da aplicação: ele inicializa somente `APP_CONFIG_DIR`, `APP_FILES_DIR`, `${APP_DIR}/marketplace`, `${APP_DIR}/plugins` e `${APP_DIR}/public/css_compiled` quando o diretório raiz ainda não possui o padrão esperado.

No desenvolvimento, o bind mount `./app:${APP_DIR}:rw` substitui o código e as permissões gravados na imagem. Se um comando do GLPI falhar, confirme que `WEBSERVER_USER` consegue atravessar `APP_DIR` e `APP_DIR/bin`, ler `bin/console` e gravar no diretório exigido pela operação. Para a compilação de SCSS, verifique especificamente `public/css_compiled`.

Os diretórios graváveis usam proprietário e grupo do servidor web, diretórios `2770`, arquivos `660` e o bit `setgid`. O código incorporado à imagem usa diretórios `750` e arquivos `640`, mas esse padrão de build não é reaplicado a todo o bind mount de desenvolvimento.

### Alteração não aplicada

Limpe o cache com `make glpi-cache-clear-dev` ou `make glpi-cache-clear`. Se a alteração depender de conteúdo incorporado à imagem, reconstrua o ambiente correspondente.

### Certificados não encontrados

Confirme a presença dos arquivos ativos com os nomes esperados em `data/utils/ssl/`:

```text
cert-file.crt
cert-file.key
```

Os arquivos com o sufixo `.example` são apenas referências e não são carregados como certificados ativos.

### Logs da inicialização

O `ENTRYPOINT` atual registra o nome e o valor das variáveis obrigatórias durante a validação, inclusive variáveis de conexão com o banco de dados. Trate os logs do container como conteúdo sensível, restrinja seu acesso e sanitize qualquer trecho antes de armazená-lo ou compartilhá-lo.

## Ajuda e segurança

Para preparar o projeto, consulte o [INSTALL.md](INSTALL.md). Para conhecer a visão geral e os recursos do projeto, consulte o [README.md](README.md).

Problemas de uso devem seguir as orientações do [SUPPORT.md](SUPPORT.md). Vulnerabilidades ou suspeitas de falha de segurança devem ser relatadas pelo processo privado descrito no [SECURITY.md](SECURITY.md).
