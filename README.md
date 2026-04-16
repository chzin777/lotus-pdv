# Lotus PDV - Ponto de Venda (Point of Sale)

Um sistema completo de PDV (Ponto de Venda) desenvolvido em Flutter, otimizado para Windows, com gerenciamento de produtos, vendas, autenticação de usuários e relatórios.

## 🎯 Funcionalidades

- ✅ **Sistema de Autenticação**: Login e cadastro de usuários com diferentes níveis de acesso
- ✅ **Gerenciamento de Produtos**: Adicionar, editar, deletar e buscar produtos
- ✅ **Upload de Imagens**: Salve imagens de produtos, logos e banners na pasta local
- ✅ **Sistema de Vendas (POS)**: Interface intuitiva e rápida para realizar vendas
- ✅ **Carrinho de Compras**: Adicione, remova e modifique quantidade de itens
- ✅ **Sistema de Desconto**: Aplique descontos nas vendas
- ✅ **Múltiplos Métodos de Pagamento**: Dinheiro, Débito, Crédito, Pix
- ✅ **Histórico de Vendas**: Visualize todas as vendas realizadas
- ✅ **Cancelamento de Vendas**: Cancele vendas e reestoque automático de produtos
- ✅ **Relatórios**: Dashboard com estatísticas de vendas, receita, ticket médio, etc.
- ✅ **Banco de Dados Local**: Usa planilhas CSV para armazenamento de dados
- ✅ **UI/UX Profissional**: Interface bonita, responsiva e bem organizada
- ✅ **Build para Windows**: Otimizado para executar nativamente no Windows

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── user.dart
│   ├── product.dart
│   └── sale.dart
├── services/                 # Serviços de dados
│   ├── storage_service.dart
│   ├── user_service.dart
│   ├── product_service.dart
│   └── sale_service.dart
├── providers/                # State Management (Provider)
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   └── sale_provider.dart
├── screens/                  # Telas da aplicação
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── pos_screen.dart
│   ├── products_screen.dart
│   ├── sales_history_screen.dart
│   └── reports_screen.dart
├── widgets/                  # Widgets reutilizáveis
└── utils/                    # Funções utilitárias

assets/
├── data/                     # Pasta para arquivos CSV
│   ├── users/
│   ├── products/
│   └── sales/
├── images/                   # Pasta para imagens de produtos
└── images/products/
```

## 🚀 Como Executar

### Requisitos
- Flutter 3.0+ instalado
- Dart 3.0+
- Visual Studio Code ou Android Studio

### Instalação

1. Clone ou extraia o projeto:
```bash
cd pdv_system
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o projeto em Windows:
```bash
flutter run -d windows
```

### Build para Windows

Para gerar um executável pronto para produção:

```bash
flutter build windows --release
```

O executável estará em: `build/windows/x64/runner/Release/`

## 💾 Banco de Dados

O sistema usa **arquivos CSV** para armazenamento de dados, localizados em:

**Windows**: `C:\Users\[USERNAME]\Documents\PDV_System\data\`

Estrutura de pastas:
- `data/users/` - Dados de usuários
- `data/products/` - Dados de produtos
- `data/sales/` - Dados de vendas
- `images/products/` - Imagens de produtos

## 👤 Usuários Padrão

Para começar a testar, você pode registrar novos usuários através da tela de login.

## 🔒 Autenticação

- Suporta diferentes roles: Admin, Manager, Seller
- Login seguro com validação
- Sistema de registro de novos usuários

## 🎨 Design

O projeto usa:
- **Material Design 3** para UI moderna
- **Google Fonts** para tipografia profissional
- **Gradient Colors** para componentes atraentes
- **Responsive Layout** que se adapta ao tamanho da tela

## 📊 Recursos Principais

### Dashboard
- Visualização rápida de estatísticas
- Total de produtos e vendas

### PDV (Ponto de Venda)
- Busca rápida de produtos
- Carrinho de compras intuitivo
- Aplicação de descontos
- Seleção de método de pagamento
- Confirmação de vendas

### Gerenciamento de Produtos
- CRUD completo (Create, Read, Update, Delete)
- Upload de imagens
- Categorização de produtos
- SKU para fácil identificação
- Controle de estoque

### Histórico de Vendas
- Listagem de todas as vendas
- Detalhes de cada transação
- Cancelamento com motivo
- Filtros por data

### Relatórios
- Receita total
- Desconto total
- Total de itens vendidos
- Ticket médio
- Vendas concluídas vs canceladas
- Filtros por período

## 🔧 Desenvolvimento

### Dependências Principais

- **provider**: State management
- **csv**: Leitura/escrita de CSV
- **image_picker**: Seleção de imagens
- **path_provider**: Localização de diretórios
- **intl**: Formatação de datas e números
- **uuid**: Geração de IDs únicos

## 📝 Notas

- O sistema salva tudo em arquivos CSV locais, não requer banco de dados externo
- Ideal para pequenos e médios negócios
- Fácil de expandir e adicionar novas funcionalidades
- Totalmente personalizável

## 🐛 Troubleshooting

### Windows Build Falha
- Certifique-se de ter Visual Studio com C++ build tools instalado
- Execute: `flutter doctor -v` para verificar requisitos

### Erro ao Salvar Dados
- Verifique permissões de escrita na pasta `Documents`
- Crie manualmente a pasta `PDV_System` em Documents se necessário

## 📄 Licença

Este projeto é de código aberto e pode ser usado livremente.

## 👨‍💻 Autor

Desenvolvido com ❤️ para melhorar o gerenciamento de negócios.

---

**Versão**: 1.0.0  
**Atualizado**: 2024
