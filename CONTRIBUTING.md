# Contribuindo

Este documento descreve como preparar o ambiente de desenvolvimento do GLPI Docker, as diretrizes para alterar seus principais componentes e os comandos usados para validar uma contribuição.

Antes de começar, leia o [README.md](README.md) para conhecer o projeto e o [INSTALL.md](INSTALL.md) para preparar e executar.

## Formas de contribuir

Você pode contribuir, por exemplo, com:

- Correções no Dockerfile, nos arquivos Docker Compose, no `ENTRYPOINT` e no Makefile;
- Melhorias nos ambientes de desenvolvimento e produção;
- Melhorias na integração, configuração e execução do GLPI em containers;
- Novos templates ou melhorias nos templates existentes;
- Correções e complementos na documentação;
- Melhorias de segurança, portabilidade, desempenho e compatibilidade;
- Relatos de erros com instruções que permitam reproduzir o problema.

Ao propor uma mudança, preserve o objetivo do projeto: oferecer uma infraestrutura Docker padronizada e reproduzível para o GLPI, com separação clara entre desenvolvimento e produção e configurações parametrizadas por arquivos de ambiente.

## Preparação do ambiente

O desenvolvimento deve ser feito preferencialmente em GNU/Linux. No Windows, utilize o WSL e mantenha o repositório em um sistema de arquivos Linux.

Instale os pré-requisitos descritos no `INSTALL.md`, incluindo Docker Engine, Docker Compose Plugin, Git, GNU Make e os utilitários de sistema exigidos pelo Makefile. Os comandos `mysql` e `mysqldump` também são necessários para os alvos de backup e restauração. O usuário atual deve possuir permissão para executar o Docker.

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

Se precisar ajustar grupos ou permissões, siga as orientações do `INSTALL.md`. Antes de executar `make apply-permissions`, considere que o alvo altera recursivamente proprietário, grupo e permissões de toda a raiz do repositório.

## Diretrizes para as alterações

### Ambientes e Docker

- Preserve, sempre que possível, os estágios `BASE`, `APP`, `DEV` e `PRD` do Dockerfile e a separação de responsabilidades entre eles.
- Mantenha no estágio `BASE` somente os recursos compartilhados, no `APP` o código-fonte e as configurações da aplicação, no `DEV` as ferramentas de desenvolvimento e no `PRD` as configurações de desempenho e segurança.
- Mantenha a versão presente em `app/` compatível com `APP_VERSION` e com as definições do Dockerfile.
- Considere que a aplicação e o banco de dados são executados em containers no desenvolvimento, enquanto o banco de produção é externo ao Docker Compose.
- Preserve os metadados OCI, o gerenciamento adequado de sinais e as práticas de segurança das imagens.
- Ao alterar caminhos ou volumes, verifique a persistência de configurações, arquivos e plugins do GLPI.

### Variáveis de ambiente e templates

- Defina valores configuráveis em `.env` e `.env.dev`; não grave valores específicos do ambiente diretamente nos arquivos `.template`.
- Ao criar, remover ou alterar uma variável, atualize os arquivos `.env.example` e `.env.dev.example` aplicáveis e a documentação.
- Use valores fictícios e seguros nos arquivos de exemplo.
- Mantenha os templates em `data/utils/templates/` restritos à estrutura das configurações do servidor web e do agendador.
- Faça alterações estruturais nos templates somente quando elas não puderem ser expressas por variáveis.

### Docker Compose

- Mantenha as definições comuns e de produção em `docker-compose.yml` e as especializações de desenvolvimento em `docker-compose.dev.yml`.
- Mantenha o banco de dados de produção externo ao Docker Compose. O serviço de banco conteinerizado pertence ao ambiente de desenvolvimento.
- Preserve os nomes padrão dos serviços `app` e `db`. Se a alteração exigir outros nomes, atualize `SERVICE_APP` e `SERVICE_DB` no Makefile e documente a mudança.
- Siga os padrões de nomenclatura de imagens, containers, hosts, volumes, redes e bancos de dados descritos no `README.md`.
- Declare explicitamente os volumes persistentes e confirme que configurações, arquivos, plugins e dados do banco não serão perdidos durante a recriação dos containers.
- Não exponha o banco de dados diretamente à internet.

### `ENTRYPOINT`

- Mantenha `data/utils/app-entrypoint` compatível com as variáveis, os templates, os caminhos persistentes e o servidor web utilizados pelo projeto.
- Prefira rotinas idempotentes, que possam ser executadas mais de uma vez com segurança.
- Evite migrações irreversíveis ou operações destrutivas durante a inicialização.
- Preserve o permissionamento necessário para que o GLPI acesse suas configurações e arquivos persistentes.
- Inicie o processo principal de forma que ele receba corretamente os sinais enviados pelo Docker.

### Makefile

- Reutilize os alvos existentes sempre que possível.
- Adicione alvos específicos da aplicação na área reservada imediatamente antes do alvo `help`.
- Nomeie esses alvos no formato `glpi-comando`, por exemplo, `glpi-cache-clear`.
- Inclua novos alvos em `.PHONY`, quando aplicável, e documente-os na saída de `make help`.
- Mantenha pares de comandos com e sem o sufixo `-dev` quando a operação existir nos dois ambientes.
- Preserve a convenção de que os comandos com `-dev` operam em desenvolvimento e os equivalentes sem o sufixo operam em produção.
- Avalie cuidadosamente qualquer alvo que altere permissões, restaure bancos ou remova recursos Docker do hospedeiro.

### Código, persistência e plugins do GLPI

- Mantenha o código-fonte base do GLPI em `app/` compatível com a versão declarada pelo projeto.
- Preserve `data/app/config/`, `data/app/files/`, `data/app/marketplace/` e `data/app/plugins/` nas alterações de montagem, atualização ou reconstrução.
- Considere que `data/app/marketplace/` contém plugins instalados pelo Marketplace e `data/app/plugins/` contém plugins instalados manualmente.
- Ao modificar configurações ou plugins, verifique se o cache precisa ser limpo com `make glpi-cache-clear-dev` no ambiente de desenvolvimento.
- Não inclua no repositório dados gerados por uma instância local do GLPI.

### Documentação

- Atualize `README.md`, `INSTALL.md` e os arquivos de exemplo sempre que uma alteração modificar requisitos, variáveis, comandos, estrutura de diretórios ou comportamento.
- Use exemplos reproduzíveis e sem informações sensíveis.
- Mantenha a documentação em português claro e os nomes técnicos consistentes com os arquivos do projeto.
- Diferencie explicitamente instruções de desenvolvimento e produção quando o procedimento não for o mesmo nos dois ambientes.

## Segurança e dados locais

Nunca inclua na contribuição:

- Arquivos `.env` ou `.env.dev`;
- Senhas, tokens, chaves de API ou outras credenciais;
- Certificados ou chaves privadas reais;
- Dumps de banco de dados;
- Logs ou conteúdo gerado em `data/misc/`;
- Configurações e arquivos persistentes gerados pela instância local em `data/app/`;
- Arquivos de sessão, cache, upload ou outros dados operacionais do GLPI;
- Logs que exponham informações confidenciais.

Antes de criar um commit, revise as alterações com `git diff` e `git status` e confirme que apenas os arquivos pretendidos serão enviados. Caso um relato de erro precise de logs ou configurações, remova ou substitua todos os dados sensíveis.

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

Quando a mudança afetar o GLPI, confirme também que a aplicação inicia corretamente, que os diretórios persistentes continuam acessíveis e que os recursos alterados, como autenticação, tarefas automáticas, envio de e-mails ou plugins, funcionam conforme esperado.

Não é necessário implantar em produção para validar uma contribuição. Não execute `make clean`, `make prune-volumes`, `make prune-networks` ou outros comandos de limpeza sem antes listar e revisar os recursos Docker do hospedeiro, pois esses alvos podem afetar outros projetos. Operações de restauração de banco também exigem confirmação do destino e um backup atualizado.

Se alguma verificação não puder ser executada, explique o motivo e informe no pull request quais validações foram realizadas. Mudanças no código do GLPI ou em plugins também devem executar os respectivos testes, linters ou verificações adicionais aplicáveis.

## Commits e pull requests

Mantenha cada contribuição focada em um único objetivo e escreva mensagens de commit curtas, claras e no modo imperativo. Evite incluir reformatações ou alterações não relacionadas no mesmo pull request.

Ao abrir o pull request:

1. Descreva o problema ou a necessidade;
2. Explique a solução adotada e as principais decisões;
3. Liste os arquivos ou componentes afetados;
4. Informe os comandos usados para validar a alteração e seus resultados;
5. Destaque impactos, incompatibilidades, migrações ou mudanças em variáveis;
6. Associe a issue correspondente, quando houver;
7. Inclua logs ou capturas de tela somente quando forem úteis e estiverem sem dados sensíveis.

Antes do envio, confirme que:

- Os ambientes de desenvolvimento e produção continuam corretamente separados;
- O banco de dados permanece conteinerizado somente no ambiente de desenvolvimento;
- Os arquivos Compose foram validados;
- As imagens afetadas foram construídas com sucesso;
- A persistência de configurações, arquivos, plugins e dados foi preservada;
- Nenhuma credencial, chave privada, dump, log confidencial ou arquivo local foi incluído;
- Os arquivos `.example` e a documentação foram atualizados quando necessário;
- Os novos alvos do Makefile aparecem em `make help`;
- A versão em `app/`, `APP_VERSION` e o Dockerfile permanecem compatíveis.

Durante a revisão, responda aos comentários e mantenha a branch atualizada. Alterações adicionais devem permanecer relacionadas ao objetivo original do pull request.

## Relatos de erros

Um bom relato deve conter:

- Descrição objetiva do comportamento observado e do comportamento esperado;
- Sistema operacional e versões do Docker, Docker Compose, Git e GNU Make;
- Versão do GLPI e tag da imagem informadas por `make info` e `make version`;
- Ambiente afetado: desenvolvimento ou produção;
- Passos mínimos para reproduzir o problema;
- Saída dos comandos de validação relevantes;
- Estado dos containers e logs necessários, devidamente anonimizados.

Antes de relatar o problema, consulte a seção de diagnóstico do `INSTALL.md`, verifique a configuração com os alvos apropriados e procure por uma issue equivalente.

## Licença

Ao enviar uma contribuição, você concorda que ela seja distribuída sob os termos da licença GNU General Public License v3.0 ou posterior (GPLv3+), adotada pelo projeto.
