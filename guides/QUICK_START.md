# 🚀 COMEÇAR RÁPIDO - PDV System

## ⚡ Setup em 3 passos

### 1️⃣ Instalar Flutter (primeira vez apenas)

**Windows**:
- Visite: https://flutter.dev/docs/get-started/install/windows
- Baixe e extraia o Flutter SDK em `C:\flutter`
- Adicione ao PATH do Windows

**Verificar instalação**:
```bash
flutter --version
flutter doctor
```

### 2️⃣ Executar Setup do Projeto

**Windows (recomendado)**:
```bash
# Navegue até a pasta do projeto e execute:
setup.bat
```

**Manual (se precisar)**:
```bash
flutter pub get
flutter create --platforms=windows .
flutter clean
flutter pub get
```

### 3️⃣ Rodar a Aplicação

```bash
flutter run -d windows
```

## 📱 Interface Rápida

### Tela de Login
- Use: `admin` / `admin123` (ou qualquer credencial registrada)
- Ou clique "Não tem conta? Registrar" para criar nova

### Dashboard (Menu Principal)
- 🏠 **Dashboard**: Estatísticas gerais
- 🛒 **Vendas (PDV)**: Fazer vendas
- 📦 **Produtos**: Adicionar/editar produtos
- 📋 **Histórico**: Ver vendas antigas e cancelar
- 📊 **Relatórios**: Gráficos e estatísticas

## 🛒 Fazendo sua Primeira Venda

1. ✅ Faça login como **admin/admin123**
2. ✅ Clique na aba **"Vendas"**
3. ✅ Clique em um produto para adicionar ao carrinho (ex: Café Premium)
4. ✅ Escolha quantidade (padrão: 1)
5. ✅ Modifique desconto se precisar (opcional)
6. ✅ Selecione método de pagamento (Dinheiro, Crédito, etc)
7. ✅ Clique em **"Confirmar Venda"** ✓

## 📦 Adicionando Novos Produtos

1. ✅ Clique na aba **"Produtos"**
2. ✅ Clique em **"Novo Produto"**
3. ✅ Preencha os dados:
   - Nome
   - Descrição
   - Preço de custo
   - Preço de venda
   - Quantidade em estoque
   - Categoria
   - SKU
   - Imagem (opcional)
4. ✅ Clique **"Adicionar"**

## 📊 Visualizando Vendas e Relatórios

### Histórico
- aba **"Histórico"**
- Veja cada venda em detalhe
- Cancele vendas se necessário (com motivo)

### Relatórios
- Aba **"Relatórios"**
- Escolha período (data início/fim)
- Veja estatísticas:
  - Receita total
  - Desconto total
  - Total de itens
  - Ticket médio
  - Vendas completas vs canceladas

## 📁 Onde Meus Dados são Salvos?

**Windows**: `C:\Users\[seu-usuario]\Documents\PDV_System\`

- `data/users/` - Dados de usuários
- `data/products/` - Dados de produtos
- `data/sales/` - Histórico de vendas
- `images/products/` - Imagens de produtos

## 🔒 Credenciais Padrão (Mude em Produção!)

```
👤 admin        🔒 admin123     👑 Administrador
👤 vendedor     🔒 1234567      🏪 Vendedor
👤 gerente      🔒 gerente123   👨‍💼 Gerente
```

## ⚙️ Configurações e Personalizações

### Mudar Tema
No `main.dart`, você pode editar:
```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF667eea), // Mude a cor aqui
)
```

### Adicionar Novo Método de Pagamento
No `utils/constants.dart`:
```dart
static const paymentMethods = [
  'Dinheiro', 
  'Débito', 
  'Crédito', 
  'Pix',
  'Seu Novo Método' // Adicione aqui
];
```

## 🐛 Erros Comuns

### ❌ "Flutter command not found"
```bash
# Solução: Adicione Flutter ao PATH
# Windows: Pesquise "Environment Variables"
# Adicione o caminho: C:\flutter\bin
```

### ❌ Erro ao salvar imagens
```bash
# Solução: Verifique permissões em Documents/PDV_System/
# Ou crie a pasta manualmente
```

### ❌ Build falha no Windows
```bash
# Solução: Reinstale Visual Studio Build Tools
# https://visualstudio.microsoft.com/downloads/
```

## 🔧 Build para Produção

```bash
flutter build windows --release

# Resultado:
# build/windows/x64/runner/Release/pdv_system.exe
```

Este executável pode ser distribuído e instalado em qualquer Windows 10+.

## 📚 Documentos Completos

- **README.md** - Documentação completa
- **INSTALLATION_GUIDE.md** - Guia de instalação detalhado
- **TECHNICAL_DOCUMENTATION.md** - Arquitetura e desenvolvimento
- **PROJECT_SUMMARY.md** - Sumário do projeto

## ✍️ Desenvolvendo Suas Próprias Features

### Adicionar Novo Provider
```dart
// Criar em lib/providers/new_provider.dart
class MyProvider extends ChangeNotifier {
  void myMethod() {
    notifyListeners(); // Atualiza a UI
  }
}

// Registrar em main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
)
```

### Adicionar Nova Tela
```dart
// Criar em lib/screens/my_screen.dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(/* sua UI */);
  }
}

// Adicionar em home_screen.dart
```

## 🎯 Checklist de Implementação

- [x] Autenticação de usuários
- [x] Gerenciamento de produtos
- [x] Sistema de PDV
- [x] Histórico de vendas
- [x] Cancelamento de vendas
- [x] Relatórios
- [x] Upload de imagens
- [x] Build para Windows
- [x] UI/UX profissional

## 🚀 Próximos Passos Sugeridos

1. **Criar usuários específicos** para seus vendedores
2. **Adicionar seus produtos reais** à base
3. **Personnalizar as cores** da marca
4. **Testar em produção** com seus dados
5. **Fazer backup regular** dos dados em Documents/PDV_System/
6. **Expandir** com novas funcionalidades conforme necessário

## 💡 Dicas Profissionais

- 💾 Faça backups regulares da pasta `PDV_System/`
- 📊 Verifique relatórios semanalmente
- 🔍 Audite vendas canceladas regularmente
- 👥 Crie usuários com roles específicas
- 🎨 Customize a UI para sua marca
- 🔐 Altere as senhas padrão em produção

## 📞 Precisa de Ajuda?

1. Verifique os documentos em Markdown
2. Execute `flutter doctor` para diagnosticar
3. Procure a solução em **INSTALLATION_GUIDE.md**
4. Consulte **TECHNICAL_DOCUMENTATION.md** para dev

## 🎉 Pronto!

Seu **PDV System** está completo e pronto para usar!

```
╔════════════════════════════════════╗
║                                    ║
║   ✅ PDV System v1.0.0            ║
║   Ready to use!                    ║
║                                    ║
║   flutter run -d windows           ║
║                                    ║
╚════════════════════════════════════╝
```

---

**Happy Selling! 🎊**

*Desenvolvido com ❤️ para seu negócio*
