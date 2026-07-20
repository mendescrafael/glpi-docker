# 1. GLPI Docker

## 1.1 Sobre a aplicação

O GLPI (Gestionnaire Libre de Parc Informatique) é uma plataforma **Open Source** de Gerenciamento de Serviços de TI (ITSM) e Gerenciamento de Ativos de TI (ITAM). Desenvolvido para atender às melhores práticas de gestão de serviços, o GLPI oferece recursos para centralizar operações de Service Desk, Inventário de Ativos, Gestão de Contratos, controle de Licenças, Base de Conhecimento, Gestão de Mudanças, Projetos e muito mais.

A plataforma permite automatizar processos, acompanhar indicadores operacionais e garantir maior governança sobre a infraestrutura de TI, sendo amplamente utilizada por organizações de todos os portes.

Entre seus principais recursos estão:

- Gerenciamento de Chamados (Help Desk e Service Desk);
- Catálogo de Serviços;
- Inventário de Ativos de hardware e software;
- CMDB (Configuration Management Database);
- Gestão de Contratos, Fornecedores e Licenças;
- Base de Conhecimento (Knowledge Base);
- Gestão de Mudanças, Problemas e Projetos;
- Controle de SLAs e escalonamentos;
- Dashboards e relatórios gerenciais;
- Integração com LDAP, Active Directory, Microsoft Entra ID, APIs e diversas ferramentas de monitoramento.

Saiba mais sobre o GLPI em: https://www.glpi-project.org/.

## 1.2 Projeto de conteinerização Docker

### 1.2.1 Visão geral

Este projeto disponibiliza uma infraestrutura baseada em Docker para facilitar a implantação, atualização e manutenção da aplicação, proporcionando um ambiente padronizado, reproduzível e adequado tanto para produção quanto para desenvolvimento.

A arquitetura de conteinerização deste projeto foi desenhada para dar suporte a estes ambientes distintos: **produção** e **desenvolvimento**.

- **Ambiente de produção:** A aplicação é totalmente conteinerizada para garantir escalabilidade e portabilidade. Em contrapartida, o serviço de banco de dados é provisionado em uma infraestrutura tradicional (servidor dedicado ou gerenciado), visando maior segurança, resiliência, performance e a conformidade com as boas práticas.

- **Ambiente de desenvolvimento:** Nesse ambiente, tanto a aplicação quanto o banco de dados são executados em containers. Essa configuração proporciona maior agilidade na preparação do ambiente local, garante a padronização entre os desenvolvedores, reduz dependências de infraestrutura externa e facilita a recriação completa do ambiente sempre que necessário.

A estrutura de arquivos e diretórios do projeto foi organizada para refletir essa segregação entre os ambientes de produção e desenvolvimento, mantendo os artefatos específicos de cada cenário devidamente isolados. Essa organização simplifica a manutenção do projeto, reduz a possibilidade de erros de configuração e facilita sua evolução ao longo do tempo.

Consulte a seção [1.4 Estrutura de arquivos e diretórios do projeto](#14-estrutura-de-arquivos-e-diretórios-do-projeto) para obter mais detalhes sobre a estrutura de arquivos e diretórios adotada pelo projeto.

### 1.2.2 Docker e Linux

Este projeto foi desenhado para trabalhar nativamente em sistemas Linux. Sendo assim, recomenda-se utilizar uma distribuição **GNU/Linux** para o **ambiente de produção**, alinhando-se às boas práticas de mercado para garantir máxima resiliência, segurança e performance.

Além disso, para o **ambiente de desenvolvimento**, recomenda-se utilizar o **WSL (Windows Subsystem for Linux)**. Isso garante o correto permissionamento de arquivos e diretórios. Essa abordagem assegura a paridade entre ambientes e o correto permissionamento de arquivos e diretórios, visto que a execução ocorrerá em um sistema de arquivos nativo do Linux, semelhante ao de produção.

Para mais informações sobre a instalação do WSL, consulte a [documentação oficial da Microsoft](https://learn.microsoft.com/pt-br/windows/wsl/install).

#### 1.2.2.1 WSL vs VS Code

No VS Code, é possível acessar um diretório dentro do WSL de forma nativa, semelhante à conexão com um servidor remoto via SSH.

Consulte o guia oficial de [desenvolvimento remoto no WSL](https://code.visualstudio.com/docs/remote/wsl-tutorial).

## 1.3 Dockerfile

Este projeto utiliza um Dockerfile baseado em **Multi-stage builds**, projetado para ser altamente reutilizável, modular e de fácil manutenção.

Diferentemente de Dockerfiles convencionais, que costumam ser fortemente acoplados a uma única aplicação, esta implementação separa a construção da imagem em estágios independentes, permitindo reutilizar praticamente toda a infraestrutura em outros projetos com poucas adaptações. A arquitetura do Dockerfile está organizada em camadas de responsabilidade bem definidas, nas quais cada estágio possui um objetivo específico, evitando duplicação de código e facilitando futuras evoluções.

### 1.3.1 Principais características

- Arquitetura baseada em Multi-stage builds, reduzindo duplicação de instruções.
- Separação entre infraestrutura comum, aplicação e ambientes de execução.
- Suporte nativo a ambientes de desenvolvimento e produção utilizando o parâmetro `target` do Docker Build.
- Configuração orientada por variáveis de ambiente, minimizando alterações no Dockerfile entre projetos.
- Permite trocar facilmente a imagem base conforme a necessidade do projeto.
- Estrutura preparada para personalização de:
  - Domínio da aplicação;
  - Certificados SSL;
  - Portas de serviços;
  - Diretórios internos;
  - Web server;
  - Metadados da imagem OCI;
  - Serviços utilizados (web server, banco de dados, etc.).
- Processo de inicialização centralizado por meio de um `ENTRYPOINT`, responsável por executar tarefas de configuração antes da inicialização da aplicação.
- Configurações do web server geradas a partir de templates e variáveis de ambiente, reduzindo a necessidade de manter múltiplos arquivos de configuração.

### 1.3.2 Organização dos estágios

| Estágio  | Responsabilidade |
| -------- | ---------------- |
| **base** | Configuração e instalação de pacotes comuns, definição do processo de inicialização (`ENTRYPOINT`) e demais componentes compartilhados por todos os ambientes. |
| **app**  | Código-fonte da aplicação, arquivos auxiliares, configurações da aplicação. |
| **dev**  | Especialização da imagem para desenvolvimento, adicionando ferramentas de diagnóstico, depuração e configurações apropriadas para esse ambiente. |
| **prd**  | Especialização da imagem para produção, aplicando configurações focadas em desempenho, segurança e estabilidade. |

### 1.3.3 Reutilização em outros projetos

Grande parte da lógica presente neste Dockerfile foi desenvolvida para ser independente da aplicação hospedada.

Para adaptá-lo a outro projeto normalmente basta:

- Alterar a imagem base (`APP_BASE_IMG`);
- Ajustar as variáveis dos arquivos `.env` e `.env.dev`;
- Substituir os templates do web server;
- Adaptar o `ENTRYPOINT`, caso necessário;

Na maioria dos casos, a estrutura dos estágios, a organização do _build_ e a configuração dos ambientes permanecem inalteradas.

### 1.3.4 Proposta deste Dockerfile

A proposta deste Dockerfile é fornecer uma base que seja:

- Reutilizável;
- Modular;
- Parametrizável;
- Simples de manter;
- Facilmente extensível;
- Adequada tanto para desenvolvimento quanto para produção.

Essa abordagem reduz a necessidade de manter Dockerfiles distintos para cada projeto, concentrando toda a infraestrutura em uma única implementação configurável por meio de variáveis e arquivos de ambiente.

## 1.4 Estrutura de arquivos e diretórios do projeto

> **Nota:** A estrutura a seguir não apresenta a árvore completa de diretórios e arquivos do projeto. Em vez disso, destaca os diretórios e arquivos mais relevantes para um melhor entendimento.

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
└── Makefile
```

### 1.4.1 Diretórios e arquivos comuns

> **Nota:** Consulte os valores de variáveis nos arquivos `.env` e `.env.dev`.

- `app/`: Diretório base para o código-fonte da aplicação.
- `data/`: Diretório de dados para concentrar arquivos essenciais.
  - `app/`: Arquivos e diretórios auxiliares para a aplicação.
    - `config/`: Diretório de configuração (arquivos de conexão com banco de dados), montado em `APP_CONFIG_DIR` no container de aplicação.
    - `files/`: Diretório de arquivos, montado em `APP_FILES_DIR` no container de aplicação.
    - `marketplace/`: Plugins instalados a partir do Marketplace do GLPI, montado em `${APP_DIR}/marketplace/` no container de aplicação.
    - `plugins/`: Plugins instalados manualmente no GLPI (modo legacy), montado em `${APP_DIR}/plugins/` no container de aplicação.
  - `db/`:
    - `dumps/` (conteúdo **NÃO** rastreado pelo Git): Dumps (backups) do banco de dados, montado em `DB_DUMPS_DIR` no container de banco de dados (**ambiente de desenvolvimento**). Para mais informações, consulte a propriedade `volumes` do arquivo `docker-compose.dev.yml`.
  - `misc/` (conteúdo **NÃO** rastreado pelo Git): Diretório de armazenamento de arquivos diversos. Use para armazenar arquivos úteis provenientes do ambiente de desenvolvimento.
  - `utils/`: Arquivos para conteinerização da aplicação.
    - `ssl/`: Diretório de certificados SSL, copiado para `SSL_DIR` no container de aplicação. Adicione aqui os certificados SSL.
      
      > **Nota:** Os arquivos de exemplo servem como referência de nomenclatura. Ao adicionar os seus próprios certificados, mantenha os nomes padrão `cert-file.crt` e `cert-file.key`, respectivamente.

      - `cert-file.crt.example`: Arquivo `.crt` (Certificate) de exemplo.
      - `cert-file.key.example`: Arquivo `.key` (Private Key) de exemplo.
    - `templates/`: Diretório de templates. Para mais informações, consulte a seção [1.4.5 Arquivos `.template`](#145-arquivos-template).
      - `app-site-cfg.conf.template`: Template de configuração do site para o web server.
      - `app-site-vhost.conf.template`: Template do site para o web server.
      - `app-cron.template`: Template para o _Cron_.

### 1.4.2 `ENTRYPOINT`

> **Nota:** Deve ser modificado conforme a necessidade do ambiente.

O script `app-entrypoint`, definido como o `ENTRYPOINT` no `Dockerfile`, é responsável por preparar o ambiente de execução. Suas principais atribuições incluem:

- Iniciar o processo principal dentro do container de aplicação;
- Substituir as variáveis de ambiente nos [arquivos `.template`](#145-arquivos-template);
- Configurar o web server;
- Garantir o correto permissionamento de arquivos e diretórios para a aplicação;
- Outras tarefas pertinentes.

### 1.4.3 Arquivos `.env`

Os arquivos `.env` e `.env.dev` agrupam todas as variáveis de ambiente utilizadas no projeto. Elas são consumidas pelos componentes `Dockerfile`, `Makefile`, `app-entrypoint`, e pelas configurações dos arquivos `docker-compose.yml` e `docker-compose.dev.yml`. **Devendo as variáveis serem modificadas conforme a necessidade do ambiente**.

- `.env` e `.env.dev`:
  > **Nota:** **NÃO** rastreado pelo Git.
  - `.env`: Credenciais, tokens, chaves de API e identificadores utilizados no projeto.
  - `.env.dev` (**ambiente de desenvolvimento**): Credenciais, tokens, chaves de API e identificadores utilizados no projeto.
- `.env.example` e `.env.dev.example`:
  > **Nota:** Rastreado pelo Git.
  - `.env.example`: Arquivo `.env` de exemplo. Faça uma cópia renomeando para `.env`.
  - `.env.dev.example` (**ambiente de desenvolvimento**): Arquivo `.env.dev` de exemplo. Faça uma cópia renomeando para `.env.dev`.

### 1.4.4 Docker Compose

> **Nota:** Os arquivos `docker-compose.yml` e `docker-compose.dev.yml` devem ser modificados conforme a necessidade do ambiente.

O projeto utiliza o **Docker Compose** para gerenciar de forma automatizada e padronizada toda a infraestrutura necessária para a execução do projeto. A stack é dividida em dois arquivos principais para isolar os ambientes de **produção** e **desenvolvimento**:

- `docker-compose.yml`: Contém as especificações da arquitetura do **ambiente de produção**, por exemplo, definindo o nome da stack no Docker, a rede para a aplicação (isolada), o serviço de aplicação, volumes para persistência de dados e políticas de reinicialização automática, além de outras definições de boas práticas.
- `docker-compose.dev.yml`: Arquivo de _override_ que adapta a stack para o **ambiente de desenvolvimento** e execução _localhost_. Cria também o serviço de banco de dados e volume para persistência de dados do DB, além de desativar o reinício automático dos containers para poupar recursos de hardware e ajuste dos mapeamentos de volumes para depuração em tempo real.

### 1.4.5 Arquivos `.template`

> **Nota:** Todas as definições de valores devem ser realizadas exclusivamente nos arquivos `.env` e `.env.dev`, e **NUNCA** diretamente nos arquivos de template.

Os arquivos `.template` foram criados para otimizar a configuração do projeto. Ao ajustar os valores das variáveis nos arquivos `.env` e `.env.dev`, o `ENTRYPOINT` no arquivo `Dockerfile` (através do script `app-entrypoint`) se encarregará de realizar as substituições e as configurações necessárias de forma automática durante a inicialização.

### 1.4.6 Makefile

O arquivo **Makefile** foi criado para simplificar o gerenciamento do projeto. Ele reúne diversos comandos úteis que automatizam desde o _build_ da imagem Docker até a limpeza de componentes não utilizados no ambiente.

Para listar todos os comandos disponíveis, execute `make help`. Para visualizar os detalhes técnicos do projeto, utilize `make info`.

Exemplo de saída do comando `make info`:

```text
$ make info

Abaixo estão disponíveis as especificações dos artefatos usados no projeto.

+----------------------------------+--------------------------------------------------------------+
| Propriedade                      | Valor                                                        |
+----------------------------------+--------------------------------------------------------------+
| Projeto                          | GLPI Docker                                                  |
| Descrição                        | Projeto de conteinerização Docker para a aplicação GLPI.     |
| Autor                            | Rafael Mendes <mendescrafael@outlook.com>                    |
| Licença                          | GPLv3                                                        |
+----------------------------------+--------------------------------------------------------------+
| Nome da imagem (Docker)          | glpi-contoso                                                 |
| Tag da imagem (Docker)           | 11.0.8-8284fa2                                               |
| Versão da aplicação              | 11.0.8                                                       |
| Revisão (Git hash ID)            | 8284fa2                                                      |
+----------------------------------+--------------------------------------------------------------+
| Imagem base (App) (Dockerfile)   | php:8.5-apache                                               |
| Imagem base (DB) (Ambiente dev)  | mysql:9.7                                                    |
+----------------------------------+--------------------------------------------------------------+

Para mais informações, consulte o arquivo 'README.md'.
Para ajuda, execute: make help
```

### 1.4.7 Permissionamento de arquivos e diretórios

Para garantir o correto permissionamento dos arquivos e diretórios do projeto use os comandos abaixo:

> **Nota:** Os comandos abaixo podem ser usados para corrigir possíveis erros relacionados a permissões nos arquivos e diretórios do projeto.

- `make apply-files-permissions`: Este comando aplica as permissões de usuário e grupo dono nos arquivos e diretórios do projeto. Para usuário considera-se o usuário atual (`id -un`) e para grupo considera-se o grupo `docker` (grupo gerenciado pelo Docker).

  > Permissões usadas:
  > 
  > - **Arquivos**:
  > 
  > ```text
  > 664
  > │││
  > ││└── Outros = r--
  > │└─── Grupo = rw-
  > └──── Dono = rw-
  > ```
  > 
  > - **Diretórios**:
  > 
  > ```text
  > 775
  > │││
  > ││└── Outros = r-x
  > │└─── Grupo = rwx
  > └──── Dono = rwx
  > ```

- `add-user-groups`: Verifica e adiciona o usuário atual (`id -un`) aos grupos `docker` (grupo gerenciado pelo Docker) e `www-data` (grupo gerenciado pelo web server).

## 1.5 Padrões de nomenclatura

Os padrões de nomenclatura documentados a seguir foram estabelecidos para garantir a clareza dos artefatos e recursos criados. Essa padronização facilita a rápida identificação dos componentes e assegura que a estrutura seja facilmente reutilizável em futuros projetos de conteinerização e também em infraestruturas multi-tenant.

### 1.5.1 Componentes Docker Compose (`docker-compose.yml` e `docker-compose.dev.yml`)

- Nome da imagem (`image`): `<vendor>`/`<aplicacao>`-`<cliente>`:`<versao-aplicacao>`-`<git-hash>`
  > Exemplo: `contoso/glpi-contoso:1.0.0-9bd1a79`.

  - `contoso`: Namespace (ou nome da organização)
  - `glpi`: Aplicação
  - `contoso`: Cliente
  - `1.0.0`: Versão aplicação
  - `9bd1a79`: Git hash ID do commit (HEAD) que representa o estado atual do código-fonte

- Serviço (`service`): `<servico>`
  > Exemplo: `app`

  - `app`: Serviço (para aplicação)
  
  > Exemplo: `db`

  - `db`: Serviço (para banco de dados)

- Nome do container (`container_name`): `<nome-aplicacao>`-`<cliente>`-`<servico>`-`<aplicacao-servico>`-`<ambiente>`
  > Exemplo: `glpi-contoso-db-mysql-prd`

  - `glpi`: Nome aplicação
  - `contoso`: Cliente
  - `db`: Serviço
  - `mysql`: Aplicação de serviço
  - `prd`: Ambiente

- Nome do host (`hostname`): `<servico>`-`<aplicacao-servico>`-`<ambiente>`
  > Exemplo: `db-mysql-prd`

  - `db`: Serviço
  - `mysql`: Aplicação de serviço
  - `prd`: Ambiente

- Volume persistente (`volumes`): `<nome-aplicacao>`-`<cliente>`-`<recurso-consumidor>`-`<ambiente>`
  > Exemplo: `glpi-contoso-mysql-prd`

  - `glpi`: Nome aplicação
  - `contoso`: Cliente
  - `mysql`: Recurso consumidor do volume
  - `prd`: Ambiente

- Rede (`networks`): `<nome-aplicacao>`-`<cliente>`
  > Exemplo: `glpi-contoso`

  - `glpi`: Nome aplicação
  - `contoso`: Cliente

### 1.5.2 Banco de dados

- Nome do banco de dados (`db_name`): `<nome-aplicacao>`-`<cliente>`-`<ambiente>`
  > Exemplo: `glpi-contoso-prd`

  - `glpi`: Nome aplicação
  - `contoso`: Cliente
  - `prd`: Ambiente

## 1.6 Especificações de versões dos artefatos

Para obter todas as informações de versões e especificações técnicas dos artefatos utilizados no projeto, execute o comando `make info` na raiz do projeto.

Veja mais detalhes na seção [1.4.6 Makefile](#146-makefile).
