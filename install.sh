#!/bin/bash
# Auto-installer ERP Desktop - Lipigas Ancahual

echo "🚀 Iniciando instalación automática..."

# Detectar sistema operativo
OS="$(uname -s)"
case "$OS" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Windows;;
    MINGW*)     MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:$OS"
esac

echo "🔧 Sistema detectado: $MACHINE"

# Verificar Node.js (requerido)
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado"
    echo "📌 Instala Node.js desde: https://nodejs.org"
    echo "   O usa: brew install node"
    exit 1
fi

echo "✅ Node.js encontrado: $(node --version)"

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm no encontrado"
    exit 1
fi

echo "✅ npm encontrado: $(npm --version)"

# Instalar dependencias
echo "📥 Instalando dependencias..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Error al instalar dependencias"
    exit 1
fi

echo "✅ Dependencias instaladas"

# Inicializar base de datos
echo "📂 Inicializando base de datos..."
npm run db:init

if [ $? -ne 0 ]; then
    echo "❌ Error al inicializar base de datos"
    exit 1
fi

echo "✅ Base de datos inicializada"

# Mensaje final
echo "
═══════════════════════════════════════════════
✅ ¡Instalación completada!

👤 Credenciales por defecto:
   Usuario: admin
   Contraseña: admin123

💻 Para iniciar la app:
   npm run dev

📦 Para producción:
   npm run build
═══════════════════════════════════════════════
"