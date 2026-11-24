@echo off
REM ERP Desktop - Lipigas Ancahual Auto-Installer
REM Ejecutar directamente desde la carpeta descomprimida

echo.
echo ==================================================
echo   🚀 ERP Desktop Lipigas Ancahual
echo   Instalación Automática 100%
echo ==================================================

setlocal enabledelayedexpansion

REM Verificar si Node.js está instalado
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ Node.js no encontrado
    echo.
    echo 📌 Instalando Node.js...
    
    REM Verificar si winget está disponible
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo    Usando winget...
        winget install OpenJS.NodeJS -h
    ) else (
        REM Verificar si chocolatey está disponible
        choco --version >nul 2>&1
        if %errorlevel% equ 0 (
            echo    Usando chocolatey...
            choco install nodejs -y
        ) else (
            REM Descargar instalador de Node.js
            echo    Descargando instalador de Node.js...
            set "TEMP_DIR=%TEMP%\nodejs-install-%RANDOM%"
            mkdir "%TEMP_DIR%"
            curl -L "https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.exe" -o "%TEMP_DIR%\node-setup.exe"
            "%TEMP_DIR%\node-setup.exe" /silent /dir="%ProgramFiles%\nodejs"
            set "PATH=%ProgramFiles%\nodejs;%PATH%"
            del /q "%TEMP_DIR%\node-setup.exe"
            rd /s /q "%TEMP_DIR%"
        )
    )
)

REM Verificar que Node.js ahora está disponible
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ No se pudo instalar Node.js automáticamente
    echo.
    echo 📌 Instala Node.js manualmente desde: https://nodejs.org
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo.
echo ✅ Node.js encontrado: !NODE_VERSION!

REM Verificar npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm no encontrado
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo ✅ npm encontrado: !NPM_VERSION!

echo.
echo 📥 Instalando dependencias...
npm install
if %errorlevel% neq 0 (
    echo.
    echo ❌ Error al instalar dependencias
    pause
    exit /b 1
)

echo.
echo 📂 Inicializando base de datos...
npm run db:init
if %errorlevel% neq 0 (
    echo.
    echo ❌ Error al inicializar base de datos
    pause
    exit /b 1
)

echo.
echo ==================================================
echo   ✅ ¡Instalación COMPLETA!
echo ==================================================
echo.
echo   👤 Credenciales por defecto:
echo      Usuario: admin
echo      Contraseña: admin123
echo.
echo   💻 Para iniciar:
echo      npm run dev
echo.
echo   📦 Para producción:
echo      npm run build
echo.
echo   🌐 La app se abrirá en: http://localhost:1420
echo ==================================================
echo.

pause