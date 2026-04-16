# 📑 Índice de Arquivos - PDV System

## 🎯 Comece Por Aqui

1. **Leia Primeiro**: [README_PT.md](#readme_ptmd) (Português completo)
2. **Setup Rápido**: [QUICK_START.md](#quick_startmd) (5 minutos)
3. **Instalar**: [INSTALLATION_GUIDE.md](#installation_guidemd) (Passo a passo)

---

## 📂 Estrutura de Arquivos

### 📄 Documentação (Leia estes!)

- **[README.md](README.md)** - Documentação principal em inglês
- **[README_PT.md](README_PT.md)** ⭐ - Documentação completa em português **RECOMENDADO**
- **[QUICK_START.md](QUICK_START.md)** - Começar em 5 minutos
- **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - Guia detalhado de instalação
- **[TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)** - Arquitetura e desenvolvimento
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Sumário do projeto
- **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Guia visual da interface
- **[SETUP_COMPLETE.txt](SETUP_COMPLETE.txt)** - Sumário de conclusão
- **[FINAL_CHECKLIST.txt](FINAL_CHECKLIST.txt)** - Checklist final de verificação

### 🔧 Configuração

- **[pubspec.yaml](pubspec.yaml)** - Dependências do Flutter
- **[analysis_options.yaml](analysis_options.yaml)** - Análise de código
- **[.gitignore](.gitignore)** - Git ignore
- **[.metadata](.metadata)** - Metadados do projeto
- **[.flutterconfig](.flutterconfig)** - Configuração Flutter

### 🚀 Scripts de Setup

- **[setup.bat](setup.bat)** - Setup automático para Windows
- **[setup.sh](setup.sh)** - Setup automático para Linux/macOS

### 💻 Código Fonte (lib/)

#### **[lib/main.dart](lib/main.dart)** - Ponto de Entrada
```
├─ Configuração MultiProvider
├─ Tema Material Design 3
├─ Rotas de navegação
└─ Consumer para autenticação
```

#### **[lib/models/](lib/models/)** - Modelos de Dados

1. **[user.dart](lib/models/user.dart)**
   - Modelo `User` com roles (admin, manager, seller)
   - Serialização JSON
   - Métodos utilitários

2. **[product.dart](lib/models/product.dart)**
   - Modelo `Product` com preços e estoque
   - Cálculo de lucro e margem
   - Serialização JSON

3. **[sale.dart](lib/models/sale.dart)**
   - Modelo `Sale` e `SaleItem`
   - Rastreamento de vendas
   - Suporte a cancelamento

#### **[lib/services/](lib/services/)** - Camada de Dados

1. **[storage_service.dart](lib/services/storage_service.dart)**
   - Gerenciamento de arquivo local
   - Caminhos de dados e imagens
   - Operações de arquivo

2. **[user_service.dart](lib/services/user_service.dart)**
   - CRUD de usuários em CSV
   - Busca por username
   - Validação

3. **[product_service.dart](lib/services/product_service.dart)**
   - CRUD de produtos em CSV
   - Busca e filtros
   - Gerenciamento de estoque

4. **[sale_service.dart](lib/services/sale_service.dart)**
   - CRUD de vendas em CSV
   - Cancelamento
   - Relatórios

#### **[lib/providers/](lib/providers/)** - State Management

1. **[auth_provider.dart](lib/providers/auth_provider.dart)**
   - Autenticação de usuários
   - Registro
   - Logout

2. **[product_provider.dart](lib/providers/product_provider.dart)**
   - Gerenciamento de produtos
   - Filtro por categoria
   - Carregamento de dados

3. **[sale_provider.dart](lib/providers/sale_provider.dart)**
   - Gerenciamento de carrinho
   - Processamento de vendas
   - Relatórios

#### **[lib/screens/](lib/screens/)** - Telas da Aplicação

1. **[login_screen.dart](lib/screens/login_screen.dart)** 🔓
   - Tela de login
   - Modo de registro
   - Validação de credenciais

2. **[home_screen.dart](lib/screens/home_screen.dart)** 🏠
   - Dashboard principal
   - Navegação com 5 abas
   - Cards de estatísticas

3. **[pos_screen.dart](lib/screens/pos_screen.dart)** 🛒
   - Sistema de vendas (PDV)
   - Grid de produtos
   - Carrinho de compras

4. **[products_screen.dart](lib/products_screen.dart)** 📦
   - Gerenciamento de produtos
   - CRUD completo
   - Upload de imagens

5. **[sales_history_screen.dart](lib/screens/sales_history_screen.dart)** 📋
   - Histórico de vendas
   - Cancelamento
   - Detalhes de transações

6. **[reports_screen.dart](lib/screens/reports_screen.dart)** 📊
   - Relatórios e estatísticas
   - Filtros por período
   - KPIs principais

#### **[lib/widgets/](lib/widgets/)** - Componentes Reutilizáveis

1. **[custom_widgets.dart](lib/widgets/custom_widgets.dart)**
   - `CustomCard` - Card customizado
   - `CustomButton` - Botão customizado
   - `SectionHeader` - Header de seção
   - `LoadingOverlay` - Overlay de carregamento

#### **[lib/utils/](lib/utils/)** - Utilidades

1. **[constants.dart](lib/utils/constants.dart)**
   - Cores do app
   - Métodos de pagamento
   - Formatação de data/moeda

### 📊 Dados de Exemplo

- **[assets/data/users.csv](assets/data/users.csv)** - 3 usuários pré-carregados
- **[assets/data/products.csv](assets/data/products.csv)** - 6 produtos de exemplo

### 🌐 Web

- **[web/index.html](web/index.html)** - Página HTML
- **[web/manifest.json](web/manifest.json)** - PWA manifest

### 💻 Windows Build

- **[windows/](windows/)** - Configuração para Windows 10+

---

## 🎯 Navegação Rápida por Funcionalidade

### 🔐 Autenticação
- **Login**: [login_screen.dart](lib/screens/login_screen.dart)
- **Lógica**: [auth_provider.dart](lib/providers/auth_provider.dart)
- **Dados**: [user_service.dart](lib/services/user_service.dart)
- **Modelo**: [user.dart](lib/models/user.dart)

### 📦 Produtos
- **Interface**: [products_screen.dart](lib/screens/products_screen.dart)
- **Gerenciamento**: [product_provider.dart](lib/providers/product_provider.dart)
- **Dados**: [product_service.dart](lib/services/product_service.dart)
- **Modelo**: [product.dart](lib/models/product.dart)

### 🛒 Vendas (PDV)
- **Interface**: [pos_screen.dart](lib/screens/pos_screen.dart)
- **Gerenciamento**: [sale_provider.dart](lib/providers/sale_provider.dart)
- **Dados**: [sale_service.dart](lib/services/sale_service.dart)
- **Modelo**: [sale.dart](lib/models/sale.dart)

### 📋 Histórico
- **Interface**: [sales_history_screen.dart](lib/screens/sales_history_screen.dart)
- **Cancelamento**: Em [sale_provider.dart](lib/providers/sale_provider.dart)

### 📊 Relatórios
- **Interface**: [reports_screen.dart](lib/screens/reports_screen.dart)
- **Cálculos**: Em [sale_service.dart](lib/services/sale_service.dart)

### 💾 Armazenamento
- **Gerenciamento**: [storage_service.dart](lib/services/storage_service.dart)

---

## 📚 Guias por Necessidade

### 🆕 Sou novo aqui
1. Leia [README_PT.md](README_PT.md)
2. Siga [QUICK_START.md](QUICK_START.md)
3. Execute [setup.bat](setup.bat)
4. Rode o projeto com `flutter run`

### 🛠️ Quer instalar/configurar
1. Consulte [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
2. Execute [setup.bat](setup.bat) ou [setup.sh](setup.sh)

### 👨‍💻 Quer desenvolver/estender
1. Leia [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)
2. Estude a arquitetura em `lib/`
3. Siga os padrões existentes

### 🎨 Quer entender a interface
1. Consulte [VISUAL_GUIDE.md](VISUAL_GUIDE.md)
2. Use as credenciais padrão
3. Explore cada funcionalidade

### 📊 Quer entender tudo
1. Leia [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
2. Verifique [FINAL_CHECKLIST.txt](FINAL_CHECKLIST.txt)

---

## 🔍 Busca Rápida de Tópicos

### Login e Autenticação
- [auth_provider.dart](lib/providers/auth_provider.dart)
- [user_service.dart](lib/services/user_service.dart)
- [login_screen.dart](lib/screens/login_screen.dart)

### Adicionar Produto
- [products_screen.dart](lib/screens/products_screen.dart)
- [product_provider.dart](lib/providers/product_provider.dart)
- [product_service.dart](lib/services/product_service.dart)

### Fazer Venda
- [pos_screen.dart](lib/screens/pos_screen.dart)
- [sale_provider.dart](lib/providers/sale_provider.dart)
- [sale_service.dart](lib/services/sale_service.dart)

### Ver Histórico
- [sales_history_screen.dart](lib/screens/sales_history_screen.dart)
- [sale_service.dart](lib/services/sale_service.dart)

### Cancelar Venda
- [sales_history_screen.dart](lib/screens/sales_history_screen.dart)
- [sale_provider.dart](lib/providers/sale_provider.dart)

### Ver Relatórios
- [reports_screen.dart](lib/screens/reports_screen.dart)
- [sale_service.dart](lib/services/sale_service.dart)

### Salvar Imagens
- [storage_service.dart](lib/services/storage_service.dart)
- [products_screen.dart](lib/screens/products_screen.dart)

---

## 📈 Arquivos por Tamanho de Importância

### 🔴 CRÍTICO (Comece por aqui)
1. main.dart
2. auth_provider.dart
3. sale_provider.dart
4. login_screen.dart

### 🟠 IMPORTANTE (Funcionalidades chave)
1. product_provider.dart
2. pos_screen.dart
3. products_screen.dart
4. sales_history_screen.dart

### 🟡 ÚTIL (Suporte)
1. storage_service.dart
2. user_service.dart
3. product_service.dart
4. sale_service.dart

### 🟢 COMPLEMENTAR (Extras)
1. custom_widgets.dart
2. constants.dart
3. Modelos (user.dart, product.dart, sale.dart)

---

## ✅ Checklist de Instalação

- [ ] Instalou Flutter
- [ ] Executou setup.bat (ou setup.sh)
- [ ] Rodou `flutter pub get`
- [ ] Executou `flutter run -d windows`
- [ ] Fez login com admin/admin123
- [ ] Explorou cada aba
- [ ] Adicionou um produto
- [ ] Fez uma venda
- [ ] Cancelou uma venda
- [ ] Viu relatórios

---

## 🚀 Próximas Ações

1. Execute o projeto
2. Teste as funcionalidades
3. Personalize as cores em [constants.dart](lib/utils/constants.dart)
4. Adicione seus produtos reais
5. Implante nos seus computadores
6. Faça backups regularmente

---

## 📞 Referência Rápida

| Quero | Arquivo |
|-------|---------|
| Começar | [QUICK_START.md](QUICK_START.md) |
| Instalar | [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) |
| Entender | [README_PT.md](README_PT.md) |
| Desenvolver | [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md) |
| Usar | [VISUAL_GUIDE.md](VISUAL_GUIDE.md) |
| Loginscreen | [login_screen.dart](lib/screens/login_screen.dart) |
| PDV | [pos_screen.dart](lib/screens/pos_screen.dart) |
| Produtos | [products_screen.dart](lib/screens/products_screen.dart) |
| Histórico | [sales_history_screen.dart](lib/screens/sales_history_screen.dart) |
| Relatórios | [reports_screen.dart](lib/screens/reports_screen.dart) |
| Estado | [sale_provider.dart](lib/providers/sale_provider.dart) |
| Dados | [sale_service.dart](lib/services/sale_service.dart) |

---

## 🎉 Pronto!

Todos os arquivos estão criados e prontos para uso.

**Próxima ação**: Leia [README_PT.md](README_PT.md)

---

*Índice completo de todos os 35+ arquivos criados para o PDV System v1.0.0*
