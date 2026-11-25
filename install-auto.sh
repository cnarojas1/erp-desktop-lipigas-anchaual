#!/bin/bash
# ERP Desktop - Lipigas Ancahual Auto-Installer
# ✅ Instala todo automáticamente: Node.js, dependencias y base de datos

set -e

echo "=================================================="
echo "  🚀 ERP Desktop Lipigas Ancahual"
echo "  Instalación Automática 100%"
echo "=================================================="

# Detectar sistema operativo
OS="$(uname -s)"
case "$OS" in
    Linux*)     OS_TYPE="linux";;
    Darwin*)    OS_TYPE="mac";;
    *)          OS_TYPE="unknown";;
esac

echo "🔧 Sistema detectado: $OS_TYPE"

# Función para instalar Homebrew (macOS) si no existe
install_homebrew_if_needed() {
    if ! command -v brew &> /dev/null; then
        echo "📌 Instalando Homebrew (gestor de paquetes)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# Función para instalar Node.js en macOS
install_nodejs_mac() {
    echo "📌 Instalando Node.js..."
    
    if ! command -v brew &> /dev/null; then
        install_homebrew_if_needed
    fi
    
    # Instalar Node.js v20 LTS
    brew install node@20
    brew link --force node@20 2>/dev/null || brew link --overwrite node
    
    echo "✅ Node.js instalado: $(node --version)"
}

# Función para instalar Node.js en Linux
install_nodejs_linux() {
    echo "📌 Instalando Node.js..."
    
    if command -v apt-get &> /dev/null; then
        echo "  Usando apt (Ubuntu/Debian)..."
        sudo apt-get update
        sudo apt-get install -y curl git
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command -v yum &> /dev/null; then
        echo "  Usando yum (RHEL/CentOS)..."
        sudo yum install -y curl git
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
        sudo yum install -y nodejs
    elif command -v pacman &> /dev/null; then
        echo "  Usando pacman (Arch Linux)..."
        sudo pacman -S --noconfirm nodejs npm
    else
        # Descargar binario directamente (último recurso)
        echo "  Descargando Node.js binario oficial..."
        TEMP_DIR="/tmp/nodejs-install-$$"
        mkdir -p "$TEMP_DIR"
        curl -L "https://nodejs.org/dist/v20.11.0/node-v20.11.0-linux-x64.tar.xz" -o "$TEMP_DIR/node.tar.xz"
        tar -xJf "$TEMP_DIR/node.tar.xz" -C "$TEMP_DIR"
        
        sudo mkdir -p /usr/local/bin
        sudo cp "$TEMP_DIR/node-v20.11.0-linux-x64/bin/node" /usr/local/bin/
        sudo cp "$TEMP_DIR/node-v20.11.0-linux-x64/bin/npm" /usr/local/bin/
        sudo cp "$TEMP_DIR/node-v20.11.0-linux-x64/bin/npx" /usr/local/bin/
        sudo chmod +x /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx
        
        rm -rf "$TEMP_DIR"
        echo "✅ Node.js instalado manualmente"
    fi
}

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo ""
    echo "⚠️  Node.js no está instalado en el sistema"
    echo "    Se instalará automáticamente..."
    echo ""
    
    case "$OS_TYPE" in
        mac)
            install_nodejs_mac
            ;;
        linux)
            install_nodejs_linux
            ;;
        *)
            echo "❌ Sistema operativo no soportado para instalación automática"
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
echo ""
echo "📥 Instalando dependencias..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Error al instalar dependencias"
    exit 1
fi

echo "✅ Dependencias instaladas"

# Inicializar base de datos
echo ""
echo "📂 Inicializando base de datos..."
npm run db:init

if [ $? -ne 0 ]; then
    echo "❌ Error al inicializar base de datos"
    exit 1
fi

echo "✅ Base de datos inicializada"

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
echo ""

# Crear script de acceso rápido
cat > run.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando ERP Desktop..."
npm run dev
EOF
chmod +x run.sh
echo "📄 Script 'run.sh' creado para iniciar rápidamente"

# Preguntar si quiere iniciar ahora
echo ""
read -p "¿Abrir la aplicación ahora? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Iniciando aplicación..."
    npm run dev
fi