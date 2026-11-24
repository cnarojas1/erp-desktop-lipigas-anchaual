#!/bin/bash
# ERP Desktop - Lipigas Ancahual Auto-Installer
# Ejecutarlo directamente desde la carpeta descomprimida

set -e

echo "=================================================="
echo "  🚀 ERP Desktop Lipigas Ancahual"
echo "  Instalación Automática 100%"
echo "=================================================="

# Detectar sistema operativo
OS="$(uname -s)"
case "$OS" in
    Linux*)     INSTALLER="install-linux.sh";;
    Darwin*)    INSTALLER="install-mac.sh";;
    *)          INSTALLER="install-generic.sh";;
esac

# Función para instalar Node.js en macOS
install_nodejs_mac() {
    echo "📌 Instalando Node.js..."
    
    if command -v brew &> /dev/null; then
        echo "  Usando Homebrew..."
        brew install node
    elif command -v port &> /dev/null; then
        echo "  Usando MacPorts..."
        sudo port install nodejs
    else
        echo "  Descargando Node.js de nodejs.org..."
        # Descargar Node.js LTS para macOS
        NODE_URL="https://nodejs.org/dist/v20.11.0/node-v20.11.0-darwin-x64.tar.xz"
        TEMP_DIR="/tmp/nodejs-install-$$"
        mkdir -p "$TEMP_DIR"
        curl -L "$NODE_URL" -o "$TEMP_DIR/node.tar.xz"
        tar -xJf "$TEMP_DIR/node.tar.xz" -C "$TEMP_DIR"
        # Instalar en /usr/local
        sudo cp -r "$TEMP_DIR/node-v20.11.0-darwin-x64"/* /usr/local/
        rm -rf "$TEMP_DIR"
        echo "✅ Node.js instalado"
        return 0
    fi
    
    echo "✅ Node.js instalado vía $(node --version)"
}

# Función para instalar Node.js en Linux
install_nodejs_linux() {
    echo "📌 Instalando Node.js..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y nodejs npm
    elif command -v yum &> /dev/null; then
        sudo yum install -y nodejs npm
    elif command -v pacman &> /dev/null; then
        sudo pacman -S nodejs npm
    else
        echo "  Descargando Node.js binario..."
        TEMP_DIR="/tmp/nodejs-install-$$"
        mkdir -p "$TEMP_DIR"
        curl -L "https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz" -o "$TEMP_DIR/node.tar.xz"
        tar -xJf "$TEMP_DIR/node.tar.xz" -C "$TEMP_DIR"
        # Instalar en /usr/local
        sudo cp -r "$TEMP_DIR/node-v20.11.0-linux-x64"/* /usr/local/
        rm -rf "$TEMP_DIR"
    fi
    
    echo "✅ Node.js instalado vía $(node --version)"
}

# Función principal de instalación
main() {
    # Verificar si Node.js está instalado
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js no encontrado"
        
        case "$OS" in
            Darwin*)
                install_nodejs_mac
                ;;
            Linux*)
                install_nodejs_linux
                ;;
            *)
                echo "⚠️  Sistema operativo no soportado para instalación automática"
                echo "📌 Instala Node.js manualmente desde: https://nodejs.org"
                exit 1
                ;;
        esac
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
}

# Ejecutar
main