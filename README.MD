# Sistema de Gestão Xtudo - Treinamento Progress TOTVS

## 📋 Descrição do Projeto

O **Sistema de Gestão Xtudo** é um projeto desenvolvido durante o **treinamento Progress da empresa TOTVS**. Esta aplicação demonstra o uso da linguagem **Progress OpenEdge** para criar um sistema completo de gestão empresarial para uma hamburgueria, incluindo cadastros, pedidos e relatórios.

### Objetivos do Treinamento

- **Aprendizado Progress OpenEdge**: Desenvolvimento de aplicações desktop
- **Gestão de Banco de Dados**: Uso do Progress Database
- **Interface Gráfica**: Criação de formulários e navegação
- **Relatórios**: Geração de relatórios integrados
- **Boas Práticas**: Estruturação de código e organização de projetos

### Funcionalidades Implementadas

- **Gestão de Cidades**: Cadastro e manutenção de cidades
- **Gestão de Produtos**: Controle de produtos e preços
- **Gestão de Clientes**: Cadastro completo de clientes com endereço
- **Gestão de Pedidos**: Criação e controle de pedidos com itens
- **Relatórios**: Geração de relatórios de clientes e pedidos
- **Exportação**: Funcionalidade de exportação de dados

## 🚀 Como Executar o Projeto

### Pré-requisitos

1. **Progress OpenEdge** instalado no sistema
2. **OpenEdge Developer Studio** (recomendado) ou ambiente de desenvolvimento Progress
3. **Banco de dados Progress** configurado

### Configuração do Banco de Dados

1. **Localização dos arquivos do banco**:
   ```
   db/
   ├── Xtudo.db    # Arquivo principal do banco
   ├── Xtudo.d1    # Arquivo de dados
   ├── Xtudo.b1    # Arquivo de backup
   ├── Xtudo.lg    # Arquivo de log
   ├── Xtudo.pf    # Arquivo de configuração
   └── Xtudo.st    # Arquivo de estrutura
   ```

2. **Conectar ao banco de dados**:
   - Abra o OpenEdge Developer Studio
   - Configure a conexão com o banco `db/Xtudo.db`
   - Certifique-se de que o banco está acessível

### Executando o Sistema

1. **Abra o arquivo principal**:
   ```
   menu.p
   ```

2. **Compile o projeto**:
   - No OpenEdge Developer Studio, compile todos os arquivos `.p`
   - Verifique se não há erros de compilação

3. **Execute o sistema**:
   - Execute o arquivo `menu.p`
   - O menu principal será exibido com todas as opções

### Estrutura de Arquivos

```
Xtudo/
├── menu.p              # Menu principal do sistema
├── cidades.p           # Gestão de cidades
├── produtos.p          # Gestão de produtos
├── clientes.p          # Gestão de clientes
├── pedidos.p           # Gestão de pedidos
├── itens.p             # Gestão de itens dos pedidos
├── rel_clientes.p      # Relatório de clientes
├── rel_pedidos.p       # Relatório de pedidos
├── prowin.lnk          # Atalho do Progress
├── db/                 # Arquivos do banco de dados
│   ├── Xtudo.db       # Arquivo principal do banco
│   ├── Xtudo.d1       # Arquivo de dados
│   ├── Xtudo.b1       # Arquivo de backup
│   ├── Xtudo.lg       # Arquivo de log
│   ├── Xtudo.pf       # Arquivo de configuração
│   └── Xtudo.st       # Arquivo de estrutura
├── .project            # Configuração do projeto
├── .propath            # Configuração do PROPATH
├── build.config        # Configuração de build
└── .settings/          # Configurações do projeto
```

## 🔧 Configurações para Outras Máquinas

### Alterações Necessárias no Código

Para executar o projeto em outras máquinas, você precisará alterar os caminhos absolutos nos seguintes arquivos:

1. **menu.p** (linhas 25, 30, 35, 40, 45, 50):
   ```progress
   // Alterar de:
   RUN c:\Xtudo\cidades.p.
   
   // Para o caminho correto da sua máquina:
   RUN /caminho/para/seu/projeto/cidades.p.
   ```

2. **pedidos.p** (se houver referências a caminhos absolutos):
   ```progress
   // Alterar caminhos absolutos para caminhos relativos ou configuração dinâmica
   ```

### Configuração do PROPATH

O arquivo `.propath` já está configurado para usar variáveis de ambiente:
- `@{ROOT}`: Diretório raiz do projeto
- `@{WORK}`: Diretório de trabalho

### Configuração do Banco de Dados

1. **Copie a pasta "db"** para a nova máquina
2. **Configure a conexão** no OpenEdge Developer Studio
3. **Verifique as permissões** dos arquivos do banco

## 📊 Funcionalidades do Sistema

### Menu Principal
- **Cidades**: Cadastro e manutenção de cidades
- **Produtos**: Gestão de produtos e preços
- **Clientes**: Cadastro completo de clientes
- **Pedidos**: Criação e controle de pedidos
- **Relatório de Clientes**: Geração de relatórios de clientes
- **Relatório de Pedidos**: Geração de relatórios de pedidos
- **Sair**: Encerra o sistema

### Gestão de Pedidos
- Criação de novos pedidos
- Adição de itens aos pedidos
- Modificação e exclusão de pedidos
- Visualização de pedidos existentes
- Exportação de dados

### Relatórios
- **Relatório de Clientes**: Lista todos os clientes cadastrados
- **Relatório de Pedidos**: Lista todos os pedidos realizados

## 🛠️ Tecnologias Utilizadas

- **Progress OpenEdge**: Linguagem de programação
- **OpenEdge Developer Studio**: Ambiente de desenvolvimento
- **Progress Database**: Banco de dados

## 📚 Conteúdo do Treinamento

### Conceitos Aplicados

1. **Estrutura de Programas Progress**:
   - Definição de variáveis
   - Estruturas de controle
   - Manipulação de dados

2. **Interface Gráfica**:
   - Criação de formulários
   - Botões e navegação
   - Browse (tabelas de dados)

3. **Banco de Dados**:
   - Conexão com banco Progress
   - Consultas e navegação
   - Transações e integridade

4. **Relatórios**:
   - Geração de relatórios
   - Exportação de dados
   - Formatação de saída

### Boas Práticas Implementadas

- **Organização de código**: Estrutura modular
- **Navegação**: Botões de navegação (<< < > >>)
- **Validação**: Verificação de dados
- **Tratamento de erros**: Mensagens informativas
- **Interface intuitiva**: Design responsivo

## 📝 Notas Importantes

1. **Backup**: Sempre faça backup do banco de dados antes de modificações
2. **Caminhos**: Verifique se todos os caminhos estão corretos para sua máquina
3. **Permissões**: Certifique-se de que o usuário tem permissões para acessar os arquivos
4. **Compilação**: Compile todos os arquivos antes de executar

## 🆘 Suporte

Em caso de problemas:
1. Verifique se o Progress OpenEdge está instalado corretamente
2. Confirme se o banco de dados está acessível
3. Verifique se todos os caminhos estão configurados corretamente
4. Compile todos os arquivos novamente

## 🎯 Objetivos Alcançados

- ✅ Sistema completo e funcional
- ✅ Interface gráfica intuitiva
- ✅ Banco de dados integrado
- ✅ Relatórios e exportação
- ✅ Código bem estruturado
- ✅ Documentação completa

---

**Desenvolvido para o treinamento Progress da empresa TOTVS** 🏢
