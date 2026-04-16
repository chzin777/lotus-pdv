@echo off
REM PDV System Setup Script for Windows

echo.
echo ===================================
echo PDV System - Setup Script
echo ===================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter não encontrado no PATH!
    echo.
    echo Por favor, instale Flutter:
    echo https://flutter.dev/docs/get-started/install/windows
    echo.
    echo Depois, adicione o Flutter ao PATH e execute este script novamente.
    pause
    exit /b 1
)

echo [✓] Flutter encontrado
flutter --version
echo.

REM Get dependencies
echo [1/4] Instalando dependências...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Falha ao instalar dependências!
    pause
    exit /b 1
)
echo [✓] Dependências instaladas
echo.

REM Create Windows build files
echo [2/4] Gerando arquivos do Windows...
flutter create --platforms=windows .
if %errorlevel% neq 0 (
    echo [WARNING] Arquivo windows pode já existir
)
echo [✓] Arquivos Windows verificados
echo.

REM Clean build
echo [3/4] Limpando build anterior...
flutter clean
echo [✓] Build anterior limpo
echo.

REM Get dependencies again after clean
echo [4/4] Instalando dependências novamente...
flutter pub get
echo [✓] Configuração concluída!
echo.

echo ===================================
echo Setup Completo!
echo ===================================
echo.
echo Para executar o projeto:
echo   flutter run -d windows
echo.
echo Para fazer build para release:
echo   flutter build windows --release
echo.
pause
