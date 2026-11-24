#!/bin/bash
# ERP Desktop - Lipigas Ancahual Quick Start
# Ejecutarlo directamente desde la carpeta descomprimida

echo "🚀 Iniciando ERP Desktop Lipigas Ancahual..."

# Verificar si Node.js está disponible
if ! command -v node &> /dev/null; then
    echo ""
    echo "⚠️  Node.js no está instalado en el sistema"
    echo ""
    echo "Opciones:"
    echo "  1. Ejecutar install-auto.sh para instalación automática"
    echo "  2. Instalar Node.js manualmente desde https://nodejs.org"
    echo ""
    read -p "¿Abrir enlace de instalación? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "https://nodejs.org" 2>/dev/null || xdg-open "https://nodejs.org" 2>/dev/null
    fi
    exit 1
fi

# Verificar si ya existe node_modules
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependencias..."
    npm install
fi

# Inicializar base de datos si no existe
if [ ! -f "$HOME/Documents/erp-client/erp.db" ] && [ ! -f "erp.db" ]; then
    echo "📂 Inicializando base de datos..."
    npm run db:init
fi

echo ""
echo "✅ Iniciando aplicación..."
echo "🌐 Abriendo http://localhost:1420"
echo ""

# Iniciar en desarrollo
npm run dev