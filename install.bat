@echo off
REM Auto-installer ERP Desktop - Lipigas Ancahual

echo.
echo ==========================================
echo 🚀 ERP Desktop - Instalación Automática
echo ==========================================
echo.

REM Verificar Node.js (requerido)
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js no encontrado
    echo.
    echo 📌 Instala Node.js desde: https://nodejs.org
    echo    O usa: winget install OpenJS.NodeJS
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo ✅ Node.js encontrado: %NODE_VERSION%

REM Verificar npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm no encontrado
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo ✅ npm encontrado: %NPM_VERSION%
echo.

REM Instalar dependencias
echo 📥 Instalando dependencias...
npm install
if %errorlevel% neq 0 (
    echo ❌ Error al instalar dependencias
    pause
    exit /b 1
)
echo ✅ Dependencias instaladas

REM Inicializar base de datos
echo 📂 Inicializando base de datos...
npm run db:init
if %errorlevel% neq 0 (
    echo ❌ Error al inicializar base de datos
    pause
    exit /b 1
)
echo ✅ Base de datos inicializada
echo.

echo ==========================================
echo ✅ ¡Instalación completada!
echo ==========================================
echo.
echo 👤 Credenciales por defecto:
echo    Usuario: admin
echo    Contraseña: admin123
echo.
echo 💻 Para iniciar la app:
echo    npm run dev
echo.
echo 📦 Para producción:
echo    npm run build
echo.
pause