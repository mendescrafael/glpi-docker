# Alterações no projeto

Todas as alterações relevantes neste projeto serão documentadas neste arquivo.

O formato baseia-se em [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) e este projeto segue [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Adicionado

### Alterado

### Descontinuado

### Removido

### Corrigido

### Segurança

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
