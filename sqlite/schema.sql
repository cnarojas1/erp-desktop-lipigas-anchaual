-- SQLite Schema for ERP Client (offline-only, no DTE integration)

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
);

-- Companies table (single company per client)
CREATE TABLE IF NOT EXISTS companies (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)))),
    name TEXT NOT NULL,
    ruc TEXT UNIQUE,
    giros TEXT,
    direccion TEXT,
    comuna TEXT,
    ciudad TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Branches/establishments
CREATE TABLE IF NOT EXISTS branches (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)))),
    company_id TEXT REFERENCES companies(id),
    name TEXT NOT NULL,
    sii_code TEXT,
    is_default INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Products/Services
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    code TEXT UNIQUE,
    name TEXT NOT NULL,
    sku TEXT,
    price DECIMAL(12,2) DEFAULT 0,
    stock DECIMAL(12,3) DEFAULT 0,
    is_service INTEGER DEFAULT 0,
    category TEXT,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Customers
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    ruc TEXT UNIQUE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    comuna TEXT,
    city TEXT,
    is_final_consumer INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sales headers
CREATE TABLE IF NOT EXISTS sales (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    branch_id TEXT REFERENCES branches(id),
    customer_id TEXT REFERENCES customers(id),
    sale_type TEXT DEFAULT 'sale', -- sale, purchase, credit_note, debit_note
    subtotal DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) DEFAULT 0,
    tax DECIMAL(12,2) DEFAULT 0,
    currency TEXT DEFAULT 'CLP',
    status TEXT DEFAULT 'draft', -- draft, confirmed, cancelled
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmed_at DATETIME,
    user_id TEXT REFERENCES users(id)
);

-- Sales items
CREATE TABLE IF NOT EXISTS sale_items (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    sale_id TEXT REFERENCES sales(id) ON DELETE CASCADE,
    product_id TEXT REFERENCES products(id),
    description TEXT,
    quantity DECIMAL(12,3) DEFAULT 1,
    unit_price DECIMAL(12,2) DEFAULT 0,
    discount DECIMAL(12,2) DEFAULT 0,
    total DECIMAL(12,2) DEFAULT 0
);

-- Stock movements
CREATE TABLE IF NOT EXISTS stock_movements (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    product_id TEXT REFERENCES products(id),
    type TEXT CHECK(type IN ('in', 'out', 'adjustment')),
    quantity DECIMAL(12,3) DEFAULT 0,
    reference TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_id TEXT REFERENCES users(id)
);

-- Inventory
CREATE TABLE IF NOT EXISTS inventory (
    product_id TEXT PRIMARY KEY REFERENCES products(id),
    stock DECIMAL(12,3) DEFAULT 0,
    reserved DECIMAL(12,3) DEFAULT 0,
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)))),
    name TEXT NOT NULL UNIQUE,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Settings (app configuration)
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    type TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create default company
INSERT OR IGNORE INTO companies (id, name, ruc, giros, direccion, comuna, ciudad) 
VALUES ('default', 'Empresa Default', '86.123.456-7', 'Servicios', 'Comuna Default', 'Ciudad Default', 'Ciudad Default');

-- Create default branch
INSERT OR IGNORE INTO branches (id, company_id, name, is_default) 
VALUES ('default', 'default', 'Sucursal Principal', 1);