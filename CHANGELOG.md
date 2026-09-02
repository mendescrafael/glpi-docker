# Alterações no projeto

Todas as alterações relevantes neste projeto serão documentadas neste arquivo.

O formato baseia-se em [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e este projeto segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Adicionado

- Adicionadas as variáveis genéricas `APP_NAME`, `APP_ENV`, `APP_DEBUG`, `APP_URL` e `APP_KEY` aos arquivos de ambiente de exemplo e seu encaminhamento ao container `app`;
- Adicionada separação entre `DB_PORT` (porta interna) e `DB_PUBLISHED_PORT` (porta publicada no desenvolvimento);
- Adicionada `PROJECT_LABEL` para definir o nome legível do projeto nos metadados OCI das imagens;
- Adicionados targets `WEB-BASE`, `WEB-DEV` e `WEB-PRD` para construir o Nginx separadamente do runtime PHP;
- Adicionado serviço `web` ao Docker Compose, com healthcheck próprio e encaminhamento FastCGI para PHP-FPM;
- Adicionados `web-shell` e `web-shell-dev` ao Makefile;

### Alterado

- Renomeado o seletor de ambiente da infraestrutura de `APP_ENV` para `APP_BUILD_ENV`;
- Adotados `PROJECT_LABEL` como nome legível do projeto e `PROJECT_NAME` como identificador técnico dos recursos Docker, deixando `APP_NAME` disponível para a aplicação consumidora;
- Alterado o `.gitignore` para permitir que o código em `app/` seja versionado pelo repositório do projeto derivado;
- Atualizado o mapeamento do banco para usar `DB_PORT` dentro da rede Docker;
- Centralizadas as regras de ignore no `.gitignore` da raiz;
- Substituída a imagem `php:8.5-apache` por PHP-FPM e Nginx em containers independentes;
- Separado o tráfego HTTP/HTTPS do runtime PHP, mantendo a porta FastCGI apenas na rede interna do Compose;
- Renomeadas as variáveis de usuário e grupo da aplicação para `APP_RUNTIME_USER` e `APP_RUNTIME_GROUP`;
- Transferido o processamento das configurações web para o `ENTRYPOINT` oficial do Nginx;
- Alterado o tratamento dos certificados para bind mount somente leitura no serviço `web`, evitando incorporá-los às camadas das imagens;
- Atualizada a documentação para a arquitetura Nginx + PHP-FPM;

### Descontinuado

### Removido

### Corrigido

- Corrigida a validação das variáveis obrigatórias no `ENTRYPOINT`, que ignorava indevidamente a primeira variável recebida;

### Segurança

- Removida a exposição dos valores das variáveis obrigatórias nos logs do `ENTRYPOINT`;
- Mantidos certificados e chaves privadas fora das imagens Docker;

## [1.1.0] - 2026-08-21

### Adicionado

- Adicionados alvos do Makefile para compilação de SCSS, consultas, diagnósticos, verificação de esquema, listagem de plugins, modo de manutenção e desbloqueio de tarefas do GLPI;
- Adicionada função reutilizável para executar o console do GLPI com o usuário configurado para o web server;

### Alterado

- Adotado padrão de funções POSIX no script `ENTRYPOINT`;
- Transferida para o build da imagem a normalização da propriedade e das permissões do código incorporado;
- Restrita a inicialização de permissões em runtime aos diretórios graváveis de configuração, arquivos, Marketplace, plugins e CSS compilado;
- Atualizados os guias de contribuição, instalação e uso conforme o estado atual do Docker Compose, Dockerfile, Makefile e `ENTRYPOINT`;

### Removido

- Removidos `${APP_DIR}/public/css_compiled` e `${APP_DIR}/version` da validação de diretórios obrigatórios, pois esses caminhos são fornecidos pelo core do GLPI;

### Corrigido

- Corrigida a gravação do CSS compilado pela rotina `build:compile_scss` executada com o usuário do web server;
- Corrigido o uso de `WEBSERVER_USER` nas tarefas do Cron e nos comandos administrativos do GLPI;

### Segurança

- Removido o acesso de outros usuários do sistema ao código incorporado e aos diretórios graváveis da aplicação;
- Aplicados modos `2770` aos diretórios graváveis e `660` aos seus arquivos, com `setgid` para preservar o grupo do web server;

## [1.0.0] - 2026-08-12

### Adicionado

- Infraestrutura baseada em Docker para o GLPI 11.0.8, com ambientes dedicados de produção e desenvolvimento;
- Imagem da aplicação em múltiplos estágios, baseada em PHP 8.5 e Apache, além de um serviço MySQL 9.7 para desenvolvimento;
- Definições do Docker Compose, diretórios de dados persistentes, templates de configuração, exemplos de certificados SSL e um ponto de entrada para a aplicação;
- Comandos no Makefile para construir, iniciar, interromper, manter e inspecionar os ambientes conteinerizados;
- Documentação de instalação, contribuição, segurança, suporte, licenciamento e uso do projeto;
- Guia de uso com procedimentos de operação, manutenção, atualização, backup e diagnóstico dos ambientes;
- Atributos do Git e regras de arquivos ignorados para manter um comportamento consistente no repositório;

### Alterado

- Padronização das nomenclaturas do projeto, dos containers, serviços, redes, volumes, variáveis de ambiente e arquivos;
- Refinamento da estrutura dos arquivos de ambiente, da configuração dos containers, do comportamento do ponto de entrada e da documentação do projeto;
- Diretrizes de contribuição padronizadas, preservando requisitos, exemplos e verificações específicos do projeto;

### Corrigido

- Correção do comportamento do Makefile e da organização das variáveis de ambiente;
- Correção da precedência dos arquivos INI do PHP e da configuração dos estágios base, desenvolvimento e produção da imagem;
