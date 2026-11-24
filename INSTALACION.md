# Instrucciones de Instalación - ERP Desktop Offline

## 📦 Archivo Entregado

El proyecto ERP Desktop sin integración DTE.

## 🚀 Pasos para instalar

```bash
# 1. Descomprimir el archivo
unzip erp-desktop-offline.zip

# 2. Acceder a la carpeta
cd erp-desktop-offline

# 3. Instalar dependencias
npm install

# 4. Inicializar base de datos
npm run db:init

# 5. Ejecutar en modo desarrollo
npm run dev
```

## 📋 Requisitos del Sistema

| Sistema | Recomendado |
|---------|-------------|
| **macOS** | Ventura 13.0+ |
| **Procesador** | Apple Silicon (M1/M2) o Intel (2018+) |
| **Memoria RAM** | 4 GB mínimo (8 GB recomendado) |

## ❓ Preguntas Frecuentes

**P: ¿Funciona sin internet?**
R: Sí, 100% offline.

**P: ¿Necesito configurar algo?**
R: No, se inicializa todo automáticamente.

**P: ¿Dónde están mis datos?**
R: En `Documents/erp-client/erp.db`

## 🔧 Solución de Problemas

```bash
# Error de permisos
chmod +x src-tauri/target/release/bundle/dmg/ERP\ Desktop.app

# Reiniciar la BD
rm ~/Documents/erp-client/erp.db && npm run db:init
```