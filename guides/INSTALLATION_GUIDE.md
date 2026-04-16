# Guia de Instalação e Uso - Lotus PDV

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

### 1. **Flutter SDK**
   - **Link**: https://flutter.dev/docs/get-started/install/windows
   - **Versão Mínima**: 3.0.0
   - **Requisitos adicionais para Windows**:
     - Windows 10 ou superior
     - Visual Studio (Community ou Professional)
     - C++ build tools

### 2. **Visual Studio (para Windows)**
   - **Link**: https://visualstudio.microsoft.com/
   - **Instalação**:
     1. Baixe a versão Community (grátis)
     2. Na instalação, selecione "Desktop development with C++"
     3. Conclua a instalação

### 3. **Git** (opcional, mas recomendado)
   - **Link**: https://git-scm.com/

## 🚀 Instalação do Flutter

### Windows

1. **Baixar Flutter SDK**:
   ```
   1. Acesse https://flutter.dev/docs/get-started/install/windows
   2. Clique em "Download Flutter SDK"
   3. Extraia o arquivo em um local permanente (ex: C:\flutter)
   ```

2. **Adicionar Flutter ao PATH**:
   ```
   1. Pressione [Windows + X] e selecione "System"
   2. Clique em "Advanced system settings"
   3. Clique em "Environment Variables"
   4. Em "User variables", clique em "New"
   5. Nome da variável: PATH
   6. Valor: C:\flutter\bin (ou seu caminho do Flutter)
   7. Clique em "OK" e abra um novo Terminal
   ```

3. **Verificar Instalação**:
   ```bash
   flutter --version
   flutter doctor
   ```

## 📦 Instalação do Lotus PDV

### Passo 1: Clonando/Extraindo o Projeto

```bash
# Se tiver git
git clone [seu-repositorio] pdv-system
cd pdv-system

# Ou extraia o arquivo ZIP fornecido
cd pdv-system
```

### Passo 2: Executar Setup Automático

**No Windows**:
```bash
double-click setup.bat
```

**No Linux/macOS**:
```bash
chmod +x setup.sh
./setup.sh
```

### Passo 3: Setup Manual (se o automático falhar)

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar arquivos de build do Windows
flutter create --platforms=windows .

# 3. Limpar build anterior
flutter clean

# 4. Instalar novamente
flutter pub get
```

## ▶️ Executando o Projeto

### Desenvolvimento (Debug)

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar no Windows
flutter run -d windows

# Ou simplesmente (se Windows for o único dispositivo disponível)
flutter run
```

### Build para Produção (Release)

```bash
# Build Windows Release
flutter build windows --release

# O executável estará em:
# build/windows/x64/runner/Release/pdv_system.exe
```

## 🔑 Credenciais de Teste

Após o primeiro launch, você pode usar as seguintes credenciais padrão:

| Usuário | Senha | Função |
|---------|-------|--------|
| admin | admin123 | Administrador |
| vendedor | 1234567 | Vendedor |
| gerente | gerente123 | Gerente |

**⚠️ Importante**: Em produção, altere essas credenciais!

## 📁 Estrutura de Dados

Os dados são salvos automaticamente em:

**Windows**: `C:\Users\[seu-usuario]\Documents\PDV_System\`

Estrutura:
```
PDV_System/
├── data/
│   ├── users/
│   │   └── users.csv
│   ├── products/
│   │   └── products.csv
│   └── sales/
│       ├── sales.csv
│       └── sales_items.csv
└── images/
    └── products/
        └── [imagens de produtos]
```

## 🐛 Troubleshooting

### Erro: "Flutter command not found"
- **Solução**: Adicione Flutter ao PATH (veja seção acima) e reinicie o terminal

### Erro: "Visual Studio Build Tools not found"
- **Solução**: Instale Visual Studio Community com C++ build tools

### Erro: "Device not found"
- **Solução**: 
  - Execute `flutter devices` para verificar dispositivos
  - Certifique-se de estar usando Windows 10 ou superior
  - Reinstale os drivers do Windows SDK

### Erro ao salvar imagens
- **Solução**:
  - Verifique permissões de escrita em `Documents/PDV_System/`
  - Crie a pasta manualmente se necessário

### Build falha com erro C++
- **Solução**:
  - Reinstale Visual Studio Build Tools
  - Abra o projeto em Windows Run (botão direito → Open as Administrator)

## 📚 Recursos Adicionais

### Documentação Oficial
- Flutter: https://flutter.dev/docs
- Dart: https://dart.dev/guides

### Comunidades
- Stack Overflow: Tag `flutter`
- Flutter Community: https://flutter.dev/community

### Tutoriais
- Flutter Codelabs: https://codelabs.developers.google.com/
- YouTube: Flutter Official Channel

## 💡 Dicas de Uso

1. **Adicionar Produtos**: Vá para aba "Produtos" e clique em "Novo Produto"
2. **Fazer Vendas**: Use a aba "Vendas" (PDV) para vender produtos
3. **Cancelar Vendas**: Você pode cancelar vendas no "Histórico"
4. **Ver Relatórios**: A aba "Relatórios" mostra estatísticas detalhadas

## 🔄 Atualizações

Para atualizar as dependências do Flutter:

```bash
flutter upgrade
flutter pub upgrade
```

## 📞 Suporte

Se encontrar problemas:
1. Verifique o terminal para mensagens de erro
2. Execute `flutter doctor` para diagnosticar problemas
3. Consulte o README.md para mais informações

---

**Versão**: 1.0.0  
**Última atualização**: 2024
