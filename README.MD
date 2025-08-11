# Sistema de Gestão XTudo 🍔

## 📋 Sobre o Projeto

O **Sistema de Gestão XTudo** é um sistema completo de gestão empresarial desenvolvido durante o treinamento Progress OpenEdge da empresa TOTVS. Esta aplicação demonstra o uso da linguagem Progress para criar um sistema desktop completo para uma hamburgueria, incluindo cadastros, pedidos e relatórios.

## 🎯 Propósito

Este projeto foi desenvolvido com o objetivo de:
- Aprender a linguagem Progress OpenEdge
- Desenvolver aplicações desktop com interface gráfica
- Trabalhar com banco de dados Progress
- Implementar um sistema completo de gestão empresarial
- Aplicar boas práticas de desenvolvimento Progress

## 🛠️ Stack Tecnológica

- **Linguagem**: Progress OpenEdge (ABL)
- **IDE**: OpenEdge Developer Studio
- **Banco de Dados**: Progress Database
- **Interface**: Formulários Progress com botões e campos
- **Arquitetura**: Aplicação desktop monolítica

## 🚀 Como Executar

### Pré-requisitos

1. **Progress OpenEdge** instalado no sistema
2. **OpenEdge Developer Studio** (recomendado)
3. **Banco de dados Progress** configurado

### Configuração

1. **Clone o repositório**:
   ```bash
   git clone [url-do-repositorio]
   cd Sistema-Gestao-XTudo
   ```

2. **Configure o banco de dados**:
   - Abra o OpenEdge Developer Studio
   - Configure a conexão com o banco `db/Xtudo.db`
   - Certifique-se de que o banco está acessível

3. **Compile o projeto**:
   - No OpenEdge Developer Studio, compile todos os arquivos `.p`
   - Verifique se não há erros de compilação

4. **Execute o sistema**:
   - Execute o arquivo `menu.p`
   - O menu principal será exibido com todas as opções

### Estrutura do Projeto

```
Sistema-Gestao-XTudo/
├── menu.p              # Menu principal do sistema
├── cidades.p           # Gestão de cidades
├── produtos.p          # Gestão de produtos
├── clientes.p          # Gestão de clientes
├── pedidos.p           # Gestão de pedidos
├── itens.p             # Gestão de itens dos pedidos
├── rel_clientes.p      # Relatório de clientes
├── rel_pedidos.p       # Relatório de pedidos
├── build.config        # Configuração de build
└── db/                 # Arquivos do banco de dados
    ├── Xtudo.db       # Arquivo principal do banco
    ├── Xtudo.d1       # Arquivo de dados
    ├── Xtudo.b1       # Arquivo de backup
    ├── Xtudo.lg       # Arquivo de log
    ├── Xtudo.pf       # Arquivo de configuração
    └── Xtudo.st       # Arquivo de estrutura
```

## 🔧 Funcionalidades

### Menu Principal
- **Cidades**: Cadastro e manutenção de cidades
- **Produtos**: Gestão de produtos e preços
- **Clientes**: Cadastro completo de clientes
- **Pedidos**: Criação e controle de pedidos
- **Relatório de Clientes**: Geração de relatórios de clientes
- **Relatório de Pedidos**: Geração de relatórios de pedidos

### Módulos do Sistema

#### Gestão de Cidades (`cidades.p`)
- Cadastro de novas cidades
- Modificação de cidades existentes
- Exclusão de cidades
- Navegação entre registros (<< < > >>)
- Exportação de dados

#### Gestão de Produtos (`produtos.p`)
- Cadastro de produtos
- Definição de preços
- Modificação e exclusão
- Navegação entre registros
- Exportação de dados

#### Gestão de Clientes (`clientes.p`)
- Cadastro completo de clientes
- Informações de endereço
- Modificação e exclusão
- Navegação entre registros

#### Gestão de Pedidos (`pedidos.p`)
- Criação de novos pedidos
- Adição de itens aos pedidos
- Modificação e exclusão de pedidos
- Controle de status

#### Gestão de Itens (`itens.p`)
- Controle dos itens dos pedidos
- Quantidades e valores
- Relacionamento com produtos

#### Relatórios
- **Relatório de Clientes** (`rel_clientes.p`): Lista todos os clientes cadastrados
- **Relatório de Pedidos** (`rel_pedidos.p`): Lista todos os pedidos realizados

## 📚 Aprendizados

### Conceitos Progress OpenEdge Aplicados

1. **Estrutura de Programas Progress**:
   - Definição de variáveis e buffers
   - Estruturas de controle (DO, IF, FOR)
   - Manipulação de dados e consultas

2. **Interface Gráfica**:
   - Criação de formulários com FRAME
   - Botões e eventos (ON 'choose')
   - Campos de entrada e navegação
   - Browse (tabelas de dados)

3. **Banco de Dados**:
   - Conexão com banco Progress
   - Consultas com QUERY e FIND
   - Transações e integridade
   - Navegação entre registros

4. **Funcionalidades Avançadas**:
   - Exportação de dados
   - Geração de relatórios
   - Validação de dados
   - Tratamento de erros

### Boas Práticas Implementadas

- **Organização modular**: Cada funcionalidade em arquivo separado
- **Navegação intuitiva**: Botões de navegação (<< < > >>)
- **Validação de dados**: Confirmações antes de exclusões
- **Interface responsiva**: Design adaptável e intuitivo
- **Estrutura consistente**: Padrão similar entre todos os módulos

## ⚠️ Notas Importantes

1. **Caminhos absolutos**: O projeto usa caminhos absolutos (`c:\Xtudo\`) que precisam ser ajustados para outras máquinas
2. **Banco de dados**: Sempre faça backup antes de modificações
3. **Compilação**: Compile todos os arquivos antes de executar
4. **Permissões**: Verifique se o usuário tem acesso aos arquivos do banco

## 🎯 Objetivos Alcançados

- ✅ Sistema completo e funcional para gestão empresarial
- ✅ Interface gráfica intuitiva com navegação
- ✅ Banco de dados integrado com Progress
- ✅ Módulos de cadastro, pedidos e relatórios
- ✅ Funcionalidade de exportação de dados
- ✅ Código bem estruturado e organizado
- ✅ Aplicação prática dos conceitos Progress OpenEdge

---

**Desenvolvido durante o treinamento Progress OpenEdge da empresa TOTVS** 🏢
