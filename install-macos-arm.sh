#!/bin/bash
# ERP Desktop - Lipigas Ancahual Auto-Installer for macOS Apple Silicon (M1/M2)

set -e

echo "=================================================="
echo "  🚀 ERP Desktop Lipigas Ancahual (M1/M2)"
echo "  Instalación Automática 100%"
echo "=================================================="

# Detectar arquitectura
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo "⚠️  Este instalador es para Apple Silicon (M1/M2)"
    echo "    Ejecutando versión genérica..."
    exec ./install-auto.sh
fi

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado"
    echo "📌 Instalando Node.js para Apple Silicon..."
    
    # Intentar Homebrew primero
    if command -v brew &> /dev/null; then
        echo "  Usando Homebrew..."
        brew install node
    else
        # Descargar Node.js para macOS ARM64
        echo "  Descargando Node.js de nodejs.org..."
        TEMP_DIR="/tmp/nodejs-install-$$"
        mkdir -p "$TEMP_DIR"
        curl -L "https://nodejs.org/dist/v20.11.0/node-v20.11.0-darwin-arm64.tar.xz" -o "$TEMP_DIR/node.tar.xz"
        tar -xJf "$TEMP_DIR/node.tar.xz" -C "$TEMP_DIR"
        # Instalar en /usr/local
        sudo mkdir -p /usr/local/bin
        sudo cp -r "$TEMP_DIR/node-v20.11.0-darwin-arm64/bin"/* /usr/local/bin/
        sudo cp -r "$TEMP_DIR/node-v20.11.0-darwin-arm64/lib"/* /usr/local/lib/
        sudo cp -r "$TEMP_DIR/node-v20.11.0-darwin-arm64/include"/* /usr/local/include/
        rm -rf "$TEMP_DIR"
        echo "✅ Node.js instalado para M1/M2"
    fi
else
    echo "✅ Node.js encontrado: $(node --version)"
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm no encontrado"
    exit 1
fi

echo "✅ npm encontrado: $(npm --version)"

# Instalar dependencias
echo "📥 Instalando dependencias..."
npm install

# Inicializar base de datos
echo "📂 Inicializando base de datos..."
npm run db:init

# Mensaje final
echo ""
echo "=================================================="
echo "  ✅ ¡Instalación COMPLETA!"
echo "=================================================="
echo ""
echo "  👤 Credenciales por defecto:"
echo "     Usuario: admin"
echo "     Contraseña: admin123"
echo ""
echo "  💻 Para iniciar:"
echo "     npm run dev"
echo ""
echo "  📦 Para producción:"
echo "     npm run build"
echo ""
echo "  🌐 La app se abrirá en: http://localhost:1420"
echo "=================================================="