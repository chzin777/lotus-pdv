# Documentação Técnica - PDV System

## 🏗️ Arquitetura

O projeto segue a arquitetura **MVC (Model-View-Controller)** com **Provider** para gerenciamento de estado.

```
┌─────────────────────────────────────────┐
│            User Interface               │
│          (Screens & Widgets)            │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│        State Management                 │
│     (Provider - Auth, Product, Sale)    │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          Business Logic                 │
│    (Services - User, Product, Sale)     │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│            Data Layer                   │
│   (Storage Service - CSV Files)         │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│        File System Storage              │
│     (Local CSV & Image Files)           │
└─────────────────────────────────────────┘
```

## 📦 Componentes Principais

### 1. **Models** (`lib/models/`)
Define a estrutura de dados do aplicativo:

- **user.dart**: Modelo de usuário com roles (admin, manager, seller)
- **product.dart**: Modelo de produto com cálculos de lucro
- **sale.dart**: Modelo de venda e itens de venda

### 2. **Services** (`lib/services/`)
Lógica de negócio e acesso a dados:

- **storage_service.dart**: Gerencia o sistema de arquivos local
- **user_service.dart**: CRUD de usuários em CSV
- **product_service.dart**: CRUD de produtos em CSV
- **sale_service.dart**: CRUD de vendas com relatórios

### 3. **Providers** (`lib/providers/`)
Gerenciamento de estado com Provider:

- **auth_provider.dart**: Autenticação e usuário atual
- **product_provider.dart**: Estado dos produtos
- **sale_provider.dart**: Estado do carrinho e vendas

### 4. **Screens** (`lib/screens/`)
Telas da aplicação:

- **login_screen.dart**: Tela de login e registro
- **home_screen.dart**: Dashboard principal com navegação
- **pos_screen.dart**: Sistema de PDV com carrinho
- **products_screen.dart**: Gerenciamento de produtos
- **sales_history_screen.dart**: Histórico e cancelamento de vendas
- **reports_screen.dart**: Relatórios e estatísticas

### 5. **Widgets** (`lib/widgets/`)
Componentes reutilizáveis:

- **custom_widgets.dart**: Cards, botões e componentes comuns

### 6. **Utils** (`lib/utils/`)
Funções utilitárias e constantes:

- **constants.dart**: Constantes como cores, formatos de data

## 🔄 Fluxo de Dados

### Fluxo de Venda Típico

```
1. Usuário seleciona produto no POS
   ↓
2. Clica para adicionar ao carrinho
   ↓
3. SaleProvider.addToCart() atualiza state
   ↓
4. UI é reconstruída mostrando item no carrinho
   ↓
5. Usuário confirma venda
   ↓
6. SaleProvider.completeSale() chama:
   - SaleService.addSale() salva em CSV
   - ProductService.updateProductQuantity() reduz estoque
   - UI mostra confirmação
```

### Fluxo de Autenticação

```
1. Usuário insere credenciais na Login Screen
   ↓
2. AuthProvider.login() chama UserService.getUserByUsername()
   ↓
3. Se credenciais corretas:
   - AuthProvider._currentUser é atualizado
   - notifyListeners() notifica a UI
   - Consumer constrói HomeScreen
   ↓
4. Se credenciais incorretas:
   - Mensagem de erro é exibida
```

## 📊 Banco de Dados (CSV)

O sistema usa arquivos CSV para persistência de dados:

### users.csv
```csv
id,username,password,fullName,role,isActive,createdAt,profileImage
1,admin,admin123,Administrador,admin,true,2024-01-01T00:00:00.000Z,
```

### products.csv
```csv
id,name,description,costPrice,sellingPrice,quantity,category,imagePath,sku,isActive,createdAt,updatedAt
1,Café Premium,Café 500g,15.00,25.00,50,Bebidas,/path/to/image.jpg,SKU001,true,2024-01-01T00:00:00.000Z,
```

### sales.csv e sales_items.csv
```csv
id,totalAmount,discountAmount,finalAmount,paymentMethod,status,userId,createdAt,cancelledAt,cancellationReason,itemCount
1,100.00,10.00,90.00,Dinheiro,completed,1,2024-01-01T00:00:00.000Z,,0,1
```

## 🎨 Design System

### Cores
- **Primária**: #667eea (Azul)
- **Secundária**: #764ba2 (Roxo)
- **Sucesso**: #34C759 (Verde)
- **Erro**: #FF3B30 (Vermelho)
- **Aviso**: #FF9500 (Laranja)

### Tipografia
- **Heading**: Poppins Bold (24px)
- **Body**: Poppins Regular (14px)
- **Caption**: Poppins Regular (12px)

## 🔒 Segurança

⚠️ **Notas Importantes**:

1. **Senhas**: Atualmente armazenadas em plain text (não recomendado para produção)
   - **Solução**: Implementar hashing (bcrypt)

2. **Validação**: Implementar validação robusta de entradas

3. **Permissões**: Adicionar controle de acesso baseado em roles

4. **Criptografia**: Considerar criptografar dados sensíveis em CSV

## 🚀 Como Estender o Projeto

### Adicionar Nova Tela

1. **Criar arquivo em `lib/screens/`**:
```dart
import 'package:flutter/material.dart';

class MyNewScreen extends StatefulWidget {
  const MyNewScreen({Key? key}) : super(key: key);

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(/* sua UI */);
  }
}
```

2. **Adicionar ao Home Screen**:
```dart
// Em home_screen.dart
int _selectedIndex = 0;
// ... adicionar novo case no IndexedStack
// Adicionar novo BottomNavigationBarItem
```

### Adicionar Novo Provider

1. **Criar arquivo em `lib/providers/`**:
```dart
import 'package:flutter/material.dart';

class MyProvider extends ChangeNotifier {
  // Estado
  // Métodos

  void updateState() {
    notifyListeners(); // Notifica widgets que escutam
  }
}
```

2. **Registrar em `main.dart`**:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
)
```

### Adicionar Novo Modelo

1. **Criar arquivo em `lib/models/`**:
```dart
class MyModel {
  final String id;
  final String name;
  // ... propriedades

  MyModel({required this.id, required this.name});

  Map<String, dynamic> toJson() { /* ... */ }
  factory MyModel.fromJson(Map<String, dynamic> json) { /* ... */ }
}
```

2. **Criar Service em `lib/services/`**:
```dart
import 'my_model.dart';

class MyService {
  static Future<List<MyModel>> getItems() async {
    // Lógica de acesso a dados
  }
}
```

### Melhorar Segurança

```dart
// Implementar hashing de senha
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

bool verifyPassword(String password, String hash) {
  return hashPassword(password) == hash;
}
```

## 📱 Recursos Potenciais para o Futuro

- [ ] Sincronização com servidor backend
- [ ] Backup automático na nuvem
- [ ] Leitura de código de barras
- [ ] Nota fiscal eletrônica (NFe)
- [ ] Integração com sistemas de pagamento
- [ ] App para gerenciamento remoto
- [ ] Suporte a múltiplas filiais
- [ ] Sistema de estoque mais avançado
- [ ] Análise de vendas com gráficos
- [ ] Integração com contabilidade

## 🔧 Troubleshooting para Desenvolvedores

### Hot Reload não funciona
```bash
flutter clean
flutter pub get
flutter run
```

### Import circular
- Reorganize imports e crie arquivos separados
- Use `barrel exports` em `index.dart`

### Performance lenta
- Use `const` Constructor quando possível
- Minimize rebuilds com Consumer seletivo
- Profile com `flutter run --profile`

## 📚 Referências

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Language](https://dart.dev/guides)
- [Material Design](https://material.io/design)

---

**Versão**: 1.0.0  
**Última atualização**: 2024
