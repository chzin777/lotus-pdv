#!/bin/bash

# PDV System Setup Script for Linux/macOS

echo ""
echo "==================================="
echo "PDV System - Setup Script"
echo "==================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter não encontrado no PATH!"
    echo ""
    echo "Por favor, instale Flutter:"
    echo "https://flutter.dev/docs/get-started/install"
    echo ""
    echo "Depois, adicione o Flutter ao PATH e execute este script novamente."
    exit 1
fi

echo "[✓] Flutter encontrado"
flutter --version
echo ""

# Get dependencies
echo "[1/4] Instalando dependências..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "[ERROR] Falha ao instalar dependências!"
    exit 1
fi
echo "[✓] Dependências instaladas"
echo ""

# Create platform build files
echo "[2/4] Gerando arquivos de build..."
flutter create --platforms=windows,linux,macos .
if [ $? -ne 0 ]; then
    echo "[WARNING] Arquivos pode já existir"
fi
echo "[✓] Arquivos verificados"
echo ""

# Clean build
echo "[3/4] Limpando build anterior..."
flutter clean
echo "[✓] Build anterior limpo"
echo ""

# Get dependencies again after clean
echo "[4/4] Instalando dependências novamente..."
flutter pub get
echo "[✓] Configuração concluída!"
echo ""

echo "==================================="
echo "Setup Completo!"
echo "==================================="
echo ""
echo "Para executar o projeto:"
echo "  flutter run"
echo ""
echo "Para fazer build para release:"
echo "  flutter build windows --release"
echo ""
