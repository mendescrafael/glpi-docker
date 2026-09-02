# Diretrizes para agentes

## Como reutilizar este arquivo

Este arquivo separa as orientações em dois grupos:

- **Diretrizes reutilizáveis:** regras gerais de atuação, preservação, qualidade, segurança, validação e entrega que devem permanecer iguais entre projetos;
- **Especificidades deste projeto:** identidade, escopo, arquitetura, domínio, compatibilidade, documentação e comandos que pertencem somente ao projeto atual.

Ao copiar este arquivo para outro projeto, mantenha as **Diretrizes reutilizáveis** e altere somente o bloco **Especificidades deste projeto**. Revise também, de forma independente, as permissões declaradas no arquivo `.codex/config.toml` do workspace.

Quando uma especificidade do projeto complementar ou restringir uma diretriz reutilizável, prevalece a regra mais específica.

## Diretrizes reutilizáveis

### Objetivo

- Realizar análises;
- Sugerir e implementar melhorias de boas práticas;
- Realizar correções;
- Atender a outros tópicos solicitados pelo usuário;

### Contexto

- Ler a documentação indicada em **Especificidades deste projeto** antes de atuar;
- Inspecionar somente os arquivos necessários à solicitação;
- Não presumir versões, caminhos, dependências ou comportamentos que possam ser verificados no projeto;

### Política de autonomia

Para solicitações de análise, explicação, revisão, diagnóstico ou planejamento:

- Inspecionar os arquivos relevantes;
- Apresentar as conclusões;
- Não modificar arquivos, salvo quando a solicitação também pedir implementação;

Para solicitações de alteração, correção, refatoração ou implementação:

- Realizar as mudanças locais solicitadas dentro do escopo autorizado;
- Executar validações locais não destrutivas;
- Não pedir confirmação para leituras, edições ou validações seguras;
- Pedir confirmação antes de operações externas, destrutivas, persistentes ou que ampliem materialmente o escopo;

Para políticas de escrita, leitura e de acesso negado a arquivos e diretórios, consultar também o arquivo `.codex/config.toml` aplicável ao workspace.

### Escopo e preservação do trabalho

- Manter todas as alterações no escopo definido para o projeto;
- Não modificar componentes externos, projetos vizinhos ou arquivos não relacionados à tarefa;
- Não sobrescrever alterações não commitadas;
- Quando uma limitação depender de mudança fora do escopo, explicar o impedimento e propor uma alternativa restrita ao projeto;
- Não adicionar integrações, compatibilidade genérica ou dependências obrigatórias sem solicitação explícita;
- Preferir APIs públicas e mecanismos nativos da plataforma a detalhes internos frágeis;

### Compatibilidade e dependências

- Ler as versões atuais nos arquivos do projeto antes de alterá-las;
- Preservar a faixa de versões suportadas, salvo solicitação explícita;
- Usar APIs, componentes, classes, funções e convenções nativas sempre que disponíveis;
- Não adicionar dependências externas desnecessárias;
- Avaliar o impacto em todos os fluxos que compartilhem uma mesma classe-base ou regra de domínio;

### Git

- Não executar comandos Git, salvo quando solicitado pelo usuário;
- Não remover o diretório `.git/`;
- Não executar `commit`, `add`, `reset`, `clean`, `checkout`, `merge`, `rebase` ou `push`, salvo se solicitado;
- Quando um commit for solicitado, seguir o padrão Conventional Commits;
- Inspecionar `git status` e `git diff` antes de editar quando o uso de Git estiver autorizado;

### Arquitetura e organização do código

- Respeitar a estrutura de diretórios, as responsabilidades e as convenções descritas nas especificidades do projeto;
- Evitar duplicação de regras entre interfaces ou fluxos equivalentes;
- Concentrar regras de domínio, persistência e apresentação nas camadas apropriadas;
- Manter arquivos públicos nos diretórios adotados pelo projeto;
- Não inserir grandes blocos de marcação ou scripts em componentes cuja responsabilidade seja apenas coordenar requisições;

### Interface e acessibilidade

- Usar componentes e padrões visuais nativos da plataforma;
- Garantir contraste e legibilidade nos temas suportados;
- Usar variáveis de tema, evitando cores fixas quando houver equivalente nativo;
- Manter acessibilidade por teclado e atributos ARIA;
- Escapar conteúdo fornecido pelo usuário e não tratá-lo como HTML confiável;
- Carregar dados sob demanda e evitar processamento desnecessário;
- Evitar requisições concorrentes em rotinas de monitoramento;
- Pausar monitoramentos quando a interface não estiver visível, quando aplicável;

### Internacionalização

- Seguir idioma, fuso e formato regional escolhidos pelo usuário;
- Usar os mecanismos nativos da plataforma para datas e traduções;
- Não inserir textos traduzíveis em código cliente sem internacionalização ou sem dados já traduzidos pelo backend;
- Ao alterar textos traduzíveis, atualizar, compilar e validar os catálogos definidos nas especificidades do projeto;

### Banco de dados

- Não apagar tabelas ou dados durante a implementação de uma funcionalidade;
- Manter a criação e a atualização do esquema idempotentes;
- Alterar o esquema somente quando necessário;
- Documentar novas colunas e índices;
- Não criar compatibilidade retroativa desnecessária;
- Não alterar silenciosamente o significado de colunas existentes;
- Usar as APIs de banco da plataforma e consultas seguras;

### Segurança e resiliência

- Validar o usuário autenticado nos endpoints;
- Respeitar o modelo de autorização, os escopos e as permissões da plataforma;
- Confirmar a permissão de visualização antes de gerar links para recursos protegidos;
- Não permitir que um registro, evento ou ação conceda acesso ao objeto de origem;
- Usar os mecanismos nativos de proteção contra CSRF;
- Sanitizar entradas, saídas e parâmetros de filtros;
- Não registrar ou expor senhas, tokens, chaves, credenciais, stack traces, consultas, caminhos internos ou outros dados sensíveis;
- Manter fallback seguro quando um valor não puder ser resolvido;
- Impedir que falhas de recursos acessórios interrompam a operação principal da plataforma;

### Cabeçalhos e documentação de código

- Usar o cabeçalho definido nas especificidades do projeto nos arquivos em que ele já for adotado e nos novos arquivos de código;
- Escrever comentários e documentação no idioma definido pelo projeto;
- Preservar PHPDoc, JSDoc, comentários e mecanismos equivalentes de documentação nas demais linguagens;
- Adicionar documentação em novas classes, funções e métodos;
- Documentar parâmetros, retorno, exceções e efeitos colaterais relevantes;
- Não remover documentação apenas para reduzir o tamanho do arquivo;
- Fazer com que comentários expliquem intenção e decisões, sem repetir o código;
- Texto de listas em arquivos Markdown (e outros arquivos equivalentes) devem iniciar com palavras em maiúsculo e finalizar com `;`, conforme o padrão:

```markdown
- Primeiro item de lista;
- Segundo item de lista;
- Terceiro item de lista:
  - Subitem;
  - Outro subitem;
```

### Padronização de arquivos de configuração

- Manter a mesma ordem das seções comuns em arquivos equivalentes entre projetos;
- Preservar seções, variáveis, alvos e padrões específicos de cada projeto;
- Usar como referência o arquivo equivalente mais completo, incorporando somente elementos aplicáveis ao projeto atual;
- Organizar variáveis, padrões e alvos relacionados dentro da mesma seção;
- Manter nomes e descrições idênticos para seções que tratem do mesmo assunto;
- Omitir seções vazias ou recursos que não sejam aplicáveis ao projeto;
- Manter os blocos comuns de arquivos binários do `.gitattributes` sincronizados;
- Preservar no `.gitignore` e em `app/.gitattributes` regras genéricas herdadas ou compartilhadas com o projeto-base quando elas forem úteis para manter consistência estrutural, mesmo que alguns padrões façam referência a componentes que ainda não estejam em uso ou que possam não ser utilizados pelo projeto;
- Não interpretar a presença de uma regra no `.gitignore` ou em `app/.gitattributes` como indicação de que o respectivo componente, linguagem, ferramenta ou artefato já esteja em uso, nem como proibição de introduzi-lo, substituí-lo ou removê-lo quando uma necessidade real do projeto exigir;
- Não sanitizar preventivamente o `.gitignore` ou `app/.gitattributes` apenas por existirem padrões atualmente sem uso; realizar essa limpeza somente quando houver solicitação explícita ou em etapa destinada à sanitização final;
- Manter as exceções do `.gitignore` coerentes com os arquivos de exemplo realmente existentes;
- Usar `.env*` no `.dockerignore` para impedir o envio de arquivos locais de ambiente ao contexto de construção;
- Comparar nomes e organização das variáveis entre `.env.example` e `.env`, sem copiar valores sensíveis para os exemplos;
- Comparar `.env.dev.example` e `.env.dev` seguindo a mesma regra;
- Preservar nos arquivos `.env*.example` uma organização lógica e legível por seções, dependências e finalidade; não reordenar variáveis exclusivamente para obter ordem alfabética quando a ordem atual melhorar a leitura, refletir dependências de interpolação ou mantiver variáveis relacionadas próximas;
- Ao adicionar ou alterar variáveis em `.env*.example`, posicioná-las na seção funcional apropriada e preservar a ordem deliberadamente estabelecida, salvo quando houver motivo técnico ou solicitação explícita para reorganizá-las;
- Não criar arquivos locais `.env` ou `.env.dev` quando eles não existirem;
- Validar a sintaxe dos `Makefile`, arquivos de ambiente e demais formatos alterados;
- Não alterar documentação Markdown durante padronizações quando sua atualização tiver sido explicitamente adiada;

### Padronização da documentação Markdown

- Manter a mesma ordem dos tópicos comuns em documentos equivalentes entre projetos;
- Usar o documento equivalente mais completo como referência, incorporando somente conteúdo aplicável ao projeto atual;
- Preservar requisitos, comandos, caminhos, versões, procedimentos e seções específicas de cada projeto;
- Omitir tópicos vazios ou que não sejam aplicáveis ao projeto;
- Manter o `README.md` concentrado na visão geral, nos principais recursos, na compatibilidade e no índice da documentação;
- Manter procedimentos de preparação e primeira implantação no `INSTALL.md`;
- Manter procedimentos operacionais, comandos cotidianos, manutenção e diagnóstico no `USAGE.md`;
- Manter preparação do ambiente de desenvolvimento, diretrizes, validações, commits e pull requests no `CONTRIBUTING.md`;
- Manter orientações para solicitar ajuda no `SUPPORT.md`;
- Manter versões suportadas e relato privado de vulnerabilidades no `SECURITY.md`;
- Usar, quando aplicável, a ordem `Verificação`, `Atualização`, `Próximos passos`, `Diagnóstico` e `Segurança` no final do `INSTALL.md`;
- Usar, quando aplicável, os tópicos `Antes de começar`, `Diagnóstico` e `Ajuda e segurança` no `USAGE.md`;
- Usar a ordem `Formas de contribuir`, `Pré-requisitos e preparação do ambiente`, diretrizes específicas, `Segurança e dados locais`, `Validação das mudanças`, `Commits e pull requests`, `Relatos de erros` e `Licença` no `CONTRIBUTING.md`;
- Manter uma seção `Documentação` no `README.md` com links para `INSTALL.md`, `USAGE.md`, `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md` e `CHANGELOG.md`;
- Transformar menções a outros arquivos Markdown em links relativos;
- Nas árvores que representam a estrutura do projeto, exibir todos os arquivos e diretórios da raiz;
- Para `app/`, exibir somente seus arquivos e diretórios diretamente contidos, sem expandir níveis internos;
- Não expandir nenhum diretório da raiz além de `app/` e `data/`;
- Para `data/`, exibir somente diretórios internos, omitindo arquivos, com profundidade máxima de 6 níveis de diretórios a partir de `data/`;
- Não exibir arquivos internos de `data/`;
- Ordenar cada nível da árvore como na IDE: diretórios iniciados por `.` primeiro, diretórios comuns em seguida, arquivos iniciados por `.` depois e arquivos comuns por último;
- Manter ordem alfabética, sem distinção entre maiúsculas e minúsculas, dentro de cada um desses quatro grupos;
- Manter as árvores sincronizadas com a estrutura real, salvo árvores explicitamente identificadas como estrutura planejada;
- Iniciar itens de listas com palavras em maiúscula e terminá-los com ponto e vírgula, exceto itens introdutórios que terminem com dois-pontos;
- Preservar exemplos de comandos e saídas em blocos literais;
- Validar espaçamento de títulos, pontuação de listas, espaços residuais, links relativos e referências a títulos renomeados;
- Não duplicar instruções detalhadas entre `README.md`, `INSTALL.md` e `USAGE.md`; manter uma descrição resumida e um link para o documento responsável;

#### Estruturas modelos para arquivos de documentação Markdown

##### Modelo para arquivo `CONTRIBUTING.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `CONTRIBUTING.md`.

> **Importante:** Quando forem aplicáveis, subtópicos adicionais podem ser criados dentro dos tópicos e subtópicos existentes, mas preservando a estrutura macro e ordem dos tópicos conforme abaixo.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado, salvo quando se tratarem de texto genérico que deve ser substituído.

```markdown
# Contribuindo

Este documento descreve o ambiente de desenvolvimento, a finalidade dos arquivos auxiliares presentes na raiz do projeto e os comandos usados para validar uma contribuição.

Antes de começar, leia o [README.md](README.md) para conhecer o projeto, o [INSTALL.md](INSTALL.md) para preparar o ambiente, o [USAGE.md](USAGE.md) para conhecer os procedimentos operacionais e o [SECURITY.md](SECURITY.md) para comunicar vulnerabilidades de forma responsável.

## Formas de contribuir

<!-- Listagem das formas de contribuições possíveis -->

## Pré-requisitos e preparação do ambiente

<!-- Instruções sobre pré-requisitos e preparação do ambiente -->

## Estrutura de arquivos e diretórios

> **Nota:** a árvore deve listar os arquivos e diretórios da raiz; em `app/`, listar somente os itens diretos, incluindo arquivos; em `data/`, mostrar somente a hierarquia de diretórios até 6 níveis, sem arquivos internos; qualquer outro diretório da raiz deve aparecer somente pelo nome. Em cada nível, ordenar diretórios ocultos, diretórios comuns, arquivos ocultos e arquivos comuns quando aplicável, sempre alfabeticamente dentro de cada grupo.

<!-- A estrutura hierárquica dos arquivos e diretórios do projeto -->

## Ambiente de desenvolvimento

<!-- Descrição sobre a estruturação do ambiente de desenvolvimento -->

### Artefatos de desenvolvimento na raiz do projeto

<!-- Descrição dos artefatos de desenvolvimentos -->

### Controle do repositório e colaboração

<!-- Listagem de arquivos e diretórios de controle de versão -->

### Dependências e artefatos específicos

<!-- Listagem de artefatos de dependência -->

### Diretrizes para as alterações

<!-- Breve descrição das diretrizes de desenvolvimento que devem ser seguidas -->

#### Diretrizes específicas do projeto

<!-- Descrição detalhada das diretrizes de desenvolvimento  -->

## Uso do Makefile

<!-- Descrição do uso do Makefile -->

### Variáveis configuráveis

<!-- Descrição da finalidade das variáveis -->

### Verificações de pré-requisitos

<!-- Instruções sobre comandos de checagem de pré-requisitos -->

### Permissionamento do ambiente de desenvolvimento

<!-- Instruções sobre comandos de permissionamento -->

### Validações de qualidade

<!-- Instruções sobre comandos de qualidade do projeto e/ou código -->

### Operações específicas do projeto

<!-- Listagem de operações específicas do projeto -->

### Convenções para novos alvos

<!-- Instruções sobre nomenclatura para novos alvos no Makefile -->

## Padrões de código e documentação

### Linguagens e formatos utilizados

<!-- Descrição sobre liguagens e padrões de formato usados -->

### Cabeçalho e documentação do código

<!-- Instruções e exemplo de cabeçalho header para arquivos -->

### Documentação do projeto

<!-- Instruções para regras de documentação do projeto -->

## Segurança e dados locais

<!-- Instruções relacionadas a segurança -->

## Validação das mudanças

<!-- Instruções sobre uso de comandos ou procedimentos para validar as mudanças -->

## Commits e pull requests

<!-- Instruções sobre padrões adotados para commits -->

### PRs

<!-- Instruções sobre PRs -->

## Relatos de erros

Um bom relato deve conter:

- Descrição aqui;
- Outra descrição aqui;

Antes de relatar o problema, consulte a seção de diagnóstico do [USAGE.md](USAGE.md) e as orientações do [SUPPORT.md](SUPPORT.md) e procure por uma issue equivalente.

## Licença

Ao enviar uma contribuição, você concorda que ela seja distribuída sob os termos da licença [LICENSE](LICENSE), adotada pelo projeto.
```

##### Modelo para arquivo `INSTALL.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `INSTALL.md`.

> **Importante:** Quando forem aplicáveis, subtópicos adicionais podem ser criados dentro dos tópicos e subtópicos existentes, mas preservando a estrutura macro e ordem dos tópicos conforme abaixo.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado, salvo quando se tratarem de texto genérico que deve ser substituído.

```markdown
# Instalação

## Pré-requisitos

<!-- Listagem dos pré-requisitos do projeto -->

## Obtendo o projeto

<!-- Instruções de como obter o projeto -->

## Preparação

<!-- Instruções de prepação do projeto -->

## Permissões

<!-- Instruções sobre permissionamento de arquivos e diretórios do projeto -->

## Verificação

<!-- Instruções sobre verificações dos artefatos usados pelo projeto -->

## Atualização

<!-- Instruções de atualização do projeto  -->

## Próximos passos

<!-- Instruções para próximos passos após implantação do projeto -->

## Diagnóstico

<!-- Instruções sobre diagnósticos aplicáveis -->

## Segurança

<!-- Instruções relacionadas a segurança no projeto -->
```

##### Modelo para arquivo `README.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `README.md`.

> **Importante:** Quando forem aplicáveis, subtópicos adicionais podem ser criados dentro dos tópicos e subtópicos existentes, mas preservando a estrutura macro e ordem dos tópicos conforme abaixo.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado, salvo quando se tratarem de texto genérico que deve ser substituído.

```markdown
# {Nome do projeto}

## Sobre o projeto

<!-- Descrição do projeto -->

## Motivação e objetivo

<!-- Descrição sobre motivo e objetivo do projeto -->

## Principais recursos

<!-- Listagem dos principais recursos do projeto -->

## Arquitetura e organização

### Visão geral

<!-- Uma visão geral da arquitetura e organização do projeto  -->

### Componentes principais

<!-- Listagem dos componentes principais do projeto -->

## Estrutura de arquivos e diretórios

A árvore e a finalidade dos arquivos e diretórios relevantes estão documentadas em [Estrutura de arquivos e diretórios](CONTRIBUTING.md#estrutura-de-arquivos-e-diretórios).

## Compatibilidade

O projeto requer:

- Descreva artefato e versão;
- Outro artefato e versão;

## Documentação

- [INSTALL.md](INSTALL.md): Preparação, configuração e primeira implantação do projeto;
- [USAGE.md](USAGE.md): Operação, manutenção, atualização e diagnóstico do projeto;
- [CONTRIBUTING.md](CONTRIBUTING.md): Preparação e diretrizes para contribuições;
- [SUPPORT.md](SUPPORT.md): Orientações para solicitar suporte;
- [SECURITY.md](SECURITY.md): Política e processo de relato de vulnerabilidades;
- [CHANGELOG.md](CHANGELOG.md): Histórico das alterações relevantes do projeto;

## Licença

Distribuído sob a licença [LICENSE](LICENSE).
```

##### Modelo para arquivo `SECURITY.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `SECURITY.md`.

> **Importante:** Nenhum tópico ou subtópico adicional deve ser criado, mas caso necessário pode ser incluído novo conteúdo em algum tópico existente.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado.

```markdown
# Política de segurança

## Versões suportadas

Correções de segurança são fornecidas para a versão estável mais recente do projeto. Antes de relatar um problema, confirme se ele também ocorre na versão atual e em uma versão suportada conforme [Compatibilidade](README.md#compatibilidade).

## Relato de vulnerabilidades

Não publique vulnerabilidades, provas de conceito ou dados sensíveis em issues abertas.

Envie o relato de forma privada pelo recurso **Report a vulnerability** da aba **Security** do repositório [{usuário GitHub}/{repositório}](https://github.com/{usuário GitHub}/{repositório}/security). Inclua, quando possível:

- Versões do projeto e outros artefados;
- Pré-condições e passos mínimos para reproduzir;
- Impacto observado e comportamento esperado;
- Logs sanitizados, sem credenciais, tokens ou dados pessoais;
- Uma sugestão de correção, caso exista;

O recebimento será confirmado assim que possível. A análise, a correção e a divulgação serão coordenadas de acordo com a gravidade e a possibilidade de reprodução. Não há programa de recompensa financeira.

## Escopo

São relevantes falhas introduzidas pelo código do projeto, incluindo bypass de autorização, exposição de ações ou dados e operações indevidas. Problemas pertencentes ao core dos artefatos usados devem ser comunicados ao respectivo mantenedor.
```

##### Modelo para arquivo `SUPPORT.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `SUPPORT.md`.

> **Importante:** Nenhum tópico ou subtópico adicional deve ser criado, mas caso necessário pode ser incluído novo conteúdo em algum tópico existente.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado.

```markdown
# Suporte

## Antes de solicitar ajuda

Consulte [README.md](README.md), [INSTALL.md](INSTALL.md) e [USAGE.md](USAGE.md), confirme a compatibilidade das versões conforme [Compatibilidade](README.md#compatibilidade). Reproduza o problema com a versão estável mais recente do projeto e verifique os logs dos artefatos.

## Abrindo uma issue

Use as [issues do projeto](https://github.com/{usuário GitHub}/{repositório}/issues) para relatar defeitos reproduzíveis ou propor melhorias. Informe:

- Versões do projeto e outros artefados;
- Forma de instalação e ambiente utilizado;
- Passos para reproduzir, resultado atual e resultado esperado;
- Capturas de tela ou logs sanitizados, quando úteis;
- Configurações adicionais necessárias para reproduzir, se houver;

**Não publique** senhas, tokens, endereços internos, dados pessoais ou dumps de banco. Vulnerabilidades devem seguir exclusivamente o processo privado descrito em [SECURITY.md](SECURITY.md).

## Limites do suporte

O projeto não oferece SLA ou suporte comercial. Dúvidas gerais de administração dos artefatos, infraestrutura, ferramentas de terceiros e problemas não introduzidos pelo projeto estão fora de escopo.
```

##### Modelo para arquivo `USAGE.md`:

Abaixo está um modelo-base que reúne a estrutura comum para o arquivo `USAGE.md`.

> **Importante:** Quando forem aplicáveis, subtópicos adicionais podem ser criados dentro dos tópicos e subtópicos existentes, mas preservando a estrutura macro e ordem dos tópicos conforme abaixo.

> **Importante:** O conteúdo dos tópicos e subtópicos inserido no modelo abaixo deve ser preservado, salvo quando se tratarem de texto genérico que deve ser substituído.

```markdown
# Uso

<!-- Descrição gerais de uso -->

Para preparar o projeto e realizar a primeira implantação, consulte o [guia de instalação](INSTALL.md).

## Antes de começar

<!-- Instruções iniciais -->

## Conceitos e configuração

<!-- Instruções sobre conceitos e configuração do projeto -->

## Operações

<!-- Instruções sobre operações realizdas pelo projeto -->

## Manutenção e cuidados

<!-- Instruções sobre manutenção e cuidados do projeto -->

## Diagnóstico

<!-- Instruções sobre diagnósticos aplicáveis -->

## Ajuda e segurança

Para preparar o projeto, consulte o [INSTALL.md](INSTALL.md). Para conhecer a visão geral e os recursos do projeto, consulte o [README.md](README.md).

Problemas de uso devem seguir as orientações do [SUPPORT.md](SUPPORT.md). Vulnerabilidades ou suspeitas de falha de segurança devem ser relatadas pelo processo privado descrito no [SECURITY.md](SECURITY.md).
```

### Versão e documentação

- Atualizar a versão somente quando solicitado;
- Não presumir a versão: ler os arquivos atuais;
- Atualizar o changelog e os documentos afetados quando requisitos ou procedimentos mudarem;
- Manter sincronizadas as árvores de arquivos presentes na documentação com a regra de profundidade e ordenação definida neste `AGENTS.md`;
- Usar como referência base para árvores do projeto o tópico [Estrutura de arquivos e diretórios](#estrutura-de-arquivos-e-diretórios), salvo árvores explicitamente conceituais ou identificadas como estrutura planejada;
- Em árvores do projeto, detalhar a raiz, os itens diretos de `app/` e a hierarquia de diretórios de `data/` até 6 níveis; qualquer outro diretório da raiz deve aparecer somente pelo nome;
- Menções a outros arquivos Markdown devem ser links para o arquivo;
- Exemplos de saídas de comandos devem ser preservados em texto literal;
- Não criar commit ou tag, salvo quando solicitado;

### Validação

- Executar o conjunto aplicável de comandos definido nas especificidades do projeto;
- Executar testes automatizados relevantes, quando houver;
- Adaptar comandos a arquivos opcionais que realmente existam;
- Não iniciar serviços, modificar bancos de dados ou instalar ferramentas sem autorização;
- Executar validações Git somente quando o usuário tiver autorizado o uso de Git;
- Informar claramente qualquer validação não executada;

### Entrega

Ao finalizar:

- Resumir as mudanças;
- Listar os arquivos modificados;
- Informar as validações executadas;
- Informar limitações e testes não executados;
- Destacar decisões que dependam de validação funcional na plataforma;

## Especificidades deste projeto

> **Bloco de personalização:** ao reutilizar este arquivo, substituir ou remover somente os tópicos desta seção conforme a identidade, a arquitetura, o domínio e as ferramentas do novo projeto.

### Identificação e contexto

- Nome: GLPI Docker;
- Diretório e identificador: `glpi-docker`;
- Plataforma: GLPI, Docker;
- Diretório de atuação: raiz deste arquivo e seus descendentes;
- Documentação principal: `README.md` na raiz deste diretório;
- Arquivo de permissões do workspace: `.codex/config.toml` na raiz do projeto de conteinerização;

### Escopo do projeto

- Não modificar o core do GLPI;
- Não aplicar patches em classes, templates, JavaScript, CSS ou arquivos públicos do GLPI;
- Não copiar arquivos do core para dentro do projeto com o objetivo de sobrescrever comportamentos internos;
- Não criar dependência obrigatória do GLPI;
- Considerar somente objetos, campos, relações, APIs e opções de pesquisa pertencentes ao core do GLPI;
- Não implementar suporte genérico a dados de terceiros sem solicitação explícita;

### Compatibilidade

- Manter compatibilidade com GLPI 11, PHP 8.5 e MySQL 9.7 LTS;
- Não alterar essa faixa de versões sem solicitação;

### Estrutura de arquivos e diretórios

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
│       ├── templates/
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

- `app/`: Diretório base para o código-fonte da aplicação.
- `data/`: Diretório de dados para concentrar arquivos essenciais.
  - `app/`: Arquivos e diretórios auxiliares para a aplicação.
    - `config/`: Diretório de configuração, montado em `APP_CONFIG_DIR` no container de aplicação.
    - `files/`: Diretório de arquivos, montado em `APP_FILES_DIR` no container de aplicação.
    - `marketplace/`: Plugins instalados a partir do Marketplace do GLPI, montado em `${APP_DIR}/marketplace/` no container de aplicação.
    - `plugins/`: Plugins instalados manualmente no GLPI (modo legacy), montado em `${APP_DIR}/plugins/` no container de aplicação.
  - `db/`:
    - `dumps/` (conteúdo **NÃO** rastreado pelo Git): Dumps (backups) do banco de dados, montado em `DB_DUMPS_DIR` no container de banco de dados (**ambiente de desenvolvimento**). Para mais informações, consulte a propriedade `volumes` do arquivo `docker-compose.dev.yml`.
  - `misc/` (conteúdo **NÃO** rastreado pelo Git): Diretório de armazenamento de arquivos diversos. Use para armazenar arquivos úteis provenientes do ambiente de desenvolvimento.
  - `utils/`: Arquivos para conteinerização da aplicação.
    - `ssl/`: Diretório de certificados SSL, copiado para `SSL_DIR` no container de aplicação. Adicione aqui os certificados SSL.
    - `templates/`: Diretório de templates. Para mais informações, consulte a seção [Arquivos `.template`](#arquivos-template).
- `README.md`: Documentação do projeto.

### Organização e identidade técnica

- Preservar os caminhos sob a raiz desse arquivo;

### Cabeçalho e idioma da documentação de código

Preservar este cabeçalho nos arquivos em que ele já for adotado e adicioná-lo aos novos arquivos de código, respeitando o tipo de comentário da linguagem:

```text
/**
 * -----------------------------------------------------------------------------
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * @copyright Copyright (c) 2026 Rafael Mendes
 * @license   GPLv3+ <https://www.gnu.org/licenses/gpl-3.0.html>
 * @link      GitHub <https://github.com/mendescrafael>
 *
 * This file is part of GLPI Docker.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 * -----------------------------------------------------------------------------
 */
```

- Escrever comentários e documentação de código em Português do Brasil;

### Versão, changelog e documentos

Quando houver mudança de versão, revisar:

- `CONTRIBUTING.md`;
- `CHANGELOG.md`;
- A estrutura de árvore presente na documentação, desconsiderando `AGENTS.md` e `.codex/`;

Além disso:

- Adicionar as últimas alterações no `CHANGELOG.md` sempre abaixo do bloco `[Unreleased]`, criando uma nova seção;
- Manter `README.md`, `INSTALL.md`, `SUPPORT.md` e `SECURITY.md` genéricos quanto à versão corrente do projeto;
- Alterar esses documentos somente quando requisitos ou procedimentos efetivamente mudarem;

### Comandos de validação

Executar o conjunto aplicável após mudanças:

```bash
# Estado e integridade do diff, somente quando o uso de Git estiver autorizado
git status --short
git diff --check

# PHP
find . -path './.git' -prune -o -name '*.php' -print0 \
  | xargs -0 -n1 php -l
```

- Destacar decisões que dependam de validação funcional no projeto;

### Outros `AGENTS.md` aninhados

Este projeto pode conter outros `AGENTS.md` aninhados, consulte-os:

- `app/AGENTS.md`, se houver;
- `data/app/plugins/feed/AGENTS.md`, se houver;
