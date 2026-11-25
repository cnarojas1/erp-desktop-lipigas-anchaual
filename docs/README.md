# ERP Desktop - Lipigas Ancahual

ERP 100% offline sin integración de proveedores de DTE ni envío de documentos al SII.

## ✨ Características

- ✅ 100% offline - **ninguna conexión requerida**
- ✅ Base de datos SQLite local
- ✅ JWT con claims embebidos
- ✅ Sin proveedores de DTE
- ✅ Sin envío de documentos
- ✅ Sin configuración de API

---

## 🚀 INSTALACIÓN 100% AUTOMÁTICA

### macOS (Apple Silicon - M1/M2/M3)

```bash
# 1. Descomprimir el ZIP
# 2. Ejecutar instalador
chmod +x install-auto.sh
./install-auto.sh
```

### Windows

```bash
# 1. Descomprimir el ZIP
# 2. Hacer doble clic en install-auto.bat
```

### Linux

```bash
# 1. Descomprimir el ZIP
# 2. Ejecutar instalador
chmod +x install-auto.sh
./install-auto.sh
```

---

## 📌 ¿Qué hace el instalador automático?

1. **Verifica Node.js** - Si no está instalado, lo instala automáticamente
2. **Instala dependencias** - `npm install`
3. **Crea base de datos** - `npm run db:init`
4. **Listo para usar** - Te da las credenciales

---

## 📦 Instalación Manual (Alternativa)

```bash
cd erp-client-folder
npm install
npm run dev      # Desarrollo
npm run build    # Producción
```

## 🚀 Primer Uso

```bash
# 1. Inicializar base de datos
npm run db:init

# 2. Arrancar en desarrollo
npm run dev

# 3. Abrir http://localhost:1420
```

---

## 📁 Estructura del Proyecto

```
erp-client/
├── src/              # Frontend (JS + HTML)
├── src-tauri/        # Backend Rust
├── sqlite/           # Schema SQLite
├── scripts/          # Scripts (init-db.js)
├── package.json      # Config + scripts
├── Cargo.toml        # Dependencias Rust
├── tauri.conf.json   # Config Tauri
├── install-auto.sh   # Instalador automático macOS/Linux
├── install-auto.bat  # Instalador automático Windows
└── README.md         # Esta documentación
```

---

## 👤 Credenciales por Defecto

Al iniciar, el sistema crea:

- **Empresa**: "Lipigas Ancahual" (única empresa por cliente)
- **Sucursal**: "Sucursal Principal"
- **Usuario de prueba**: admin/admin

---

## ⚠️ NOTA IMPORTANTE - SIN INTEGRACIÓN DTE

Este ERP **NO incluye**:

- Integración con Luminous
- Envío de DTE al SII
- Conexión a proveedores externos
- Tokens de API para facturación

Es **ideal para**:

- Empresas que facturan internamente
- Clientes que usan otro sistema de facturación
- Pruebas y desarrollo local
- Entornos sin acceso a internet

---

## 📊 Uso del Sistema

### 1. Usuarios

- Registro y login local
- Roles: `admin`, `user`

### 2. Productos

- Agregar productos/servicios
- Control de stock
- Precios personalizados

### 3. Ventas

- Ventas directas
- Notas de crédito/debito
- Estado: borrador, confirmado, cancelado

### 4. Clientes

- Registro de clientes
- RUT opcional
- Información de contacto

---

## 🛠️ Personalización

### Cambiar el nombre de la empresa

Edita en `sqlite/schema.sql` o desde el script de inicialización.

### Cambiar credenciales por defecto

Modifica el script `scripts/init-db.js`.

### Añadir funcionalidades

El proyecto usa una arquitectura modular:

- `src/main.js`: Funciones de base de datos y JWT
- `src-tauri/src/main.rs`: Comandos Tauri
- `index.html`: UI del usuario

---

## 📞 Soporte

- **Desarrollo**: nicolabs@digitalizaplus.cl
- **Documentación**: Ver `INSTALACION.md`
- **GitHub**: Ver releases para descargas