// JWT Local helper - sin integración de DTE
export class LocalAuth {
    static SECRET_KEY = 'erp-local-secret-key';
    
    static generateToken(userId, companyId, role = 'user') {
        const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
        const payload = btoa(JSON.stringify({
            sub: userId,
            company_id: companyId,
            role: role,
            iat: Math.floor(Date.now() / 1000),
            exp: Math.floor(Date.now() / 1000) + (8 * 3600)
        }));
        const signature = btoa(`${header}.${payload}`);
        return `${header}.${payload}.${signature}`;
    }
    
    static verifyToken(token) {
        try {
            const [header, payload] = token.split('.');
            if (!header || !payload) return null;
            const payloadJson = JSON.parse(atob(payload));
            if (payloadJson.exp < Math.floor(Date.now() / 1000)) return null;
            return payloadJson;
        } catch (e) {
            return null;
        }
    }
}

// IndexedDB helper for web/PWA fallback
let db = null;
const DB_NAME = 'ERP_Lipigas_Ancahual';
const DB_VERSION = 2;
let opening;

async function openIDB() {
    if (db) return db;
    if (opening) return opening;
    opening = new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        request.onerror = () => reject(request.error);
        request.onblocked = () => reject(new Error('Cierra las otras pestañas de la aplicación y recarga.'));
        request.onsuccess = () => {
            db = request.result;
            db.onversionchange = () => { db.close(); db = null; opening = null; };
            resolve(db);
        };
        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            // Add missing schema without replacing existing stores or records.
            for (const name of ['users', 'products', 'sales', 'customers', 'settings']) {
                if (!db.objectStoreNames.contains(name)) {
                    db.createObjectStore(name, { keyPath: name === 'settings' ? 'key' : 'id' });
                }
            }
            const users = request.transaction.objectStore('users');
            if (!users.indexNames.contains('username')) {
                users.createIndex('username', 'username', { unique: false });
            }
        };
    }).catch(error => { opening = null; throw error; });
    return opening;
}

// Resolve only after the transaction commits, not when the request is created.
function completed(request) {
    return new Promise((resolve, reject) => {
        const tx = request.transaction;
        tx.oncomplete = () => resolve(request.result);
        tx.onabort = () => reject(tx.error || request.error || new Error('Transacción cancelada'));
        tx.onerror = () => reject(tx.error || request.error);
    });
}

// Check if running in Tauri context
function isTauri() {
    return typeof window !== 'undefined' && 
           window.__TAURI_INVOKE__ && 
           typeof window.__TAURI_INVOKE__ === 'function';
}

// Local database operations - works in both Tauri and Web
export async function initDatabase() {
    if (isTauri()) {
        // Tauri context - use Rust backend
        const response = await window.__TAURI_INVOKE__('init_database', {});
        return response.success;
    } else {
        // Web context - use IndexedDB
        try {
            await openIDB();
            return { success: true };
        } catch (e) {
            console.error('Database init error:', e);
            throw e;
        }
    }
}

export async function localQuery(sql, params = []) {
    if (isTauri()) {
        const response = await window.__TAURI_INVOKE__('db_query', { sql, params });
        return response.data;
    } else {
        // Web context - parse SQL and query IndexedDB
        return queryIDB(sql, params);
    }
}

export async function localExec(sql, params = []) {
    if (isTauri()) {
        const response = await window.__TAURI_INVOKE__('db_run', { sql, params });
        return response;
    } else {
        // Web context - parse SQL and execute IndexedDB
        return execIDB(sql, params);
    }
}

// IndexedDB SQL-like operations
async function queryIDB(sql, params = []) {
    const db = await openIDB();
    const normalizedSql = sql.toLowerCase().trim();
    
    // SELECT users
    if (normalizedSql.startsWith('select') && normalizedSql.includes('from users')) {
        const store = db.transaction('users').objectStore('users');
        if (params.length > 0) {
            // WHERE username = ?
            const index = store.index('username');
            const users = await completed(index.getAll(params[0]));
            return normalizedSql.includes('password_hash')
                ? users.filter(user => user.password_hash === params[1]) : users;
        }
        return completed(store.getAll());
    }
    
    // SELECT products
    if (normalizedSql.startsWith('select') && normalizedSql.includes('from products')) {
        const store = db.transaction('products').objectStore('products');
        return completed(store.getAll());
    }
    
    // SELECT sales
    if (normalizedSql.startsWith('select') && normalizedSql.includes('from sales')) {
        const store = db.transaction('sales').objectStore('sales');
        return completed(store.getAll());
    }
    
    // SELECT customers
    if (normalizedSql.startsWith('select') && normalizedSql.includes('from customers')) {
        const store = db.transaction('customers').objectStore('customers');
        return completed(store.getAll());
    }
    
    return [];
}

async function execIDB(sql, params = []) {
    const db = await openIDB();
    const normalizedSql = sql.toLowerCase().trim();
    
    // INSERT users
    if (normalizedSql.startsWith('insert') && normalizedSql.includes('users')) {
        const store = db.transaction('users', 'readwrite').objectStore('users');
        const user = {
            id: params[0],
            username: params[1],
            email: params[2],
            password_hash: params[3],
            full_name: params[4],
            role: params[5],
            created_at: new Date().toISOString()
        };
        await completed(store.keyPath === null ? store.add(user, user.id) : store.add(user));
        return { success: true };
    }
    
    // INSERT products
    if (normalizedSql.startsWith('insert') && normalizedSql.includes('products')) {
        const store = db.transaction('products', 'readwrite').objectStore('products');
        const product = {
            id: crypto.randomUUID(),
            name: params[0],
            price: params[1] || 0,
            created_at: new Date().toISOString()
        };
        await completed(store.keyPath === null ? store.add(product, product.id) : store.add(product));
        return { success: true };
    }
    
    // INSERT sales
    if (normalizedSql.startsWith('insert') && normalizedSql.includes('sales')) {
        const store = db.transaction('sales', 'readwrite').objectStore('sales');
        const sale = {
            id: crypto.randomUUID(),
            total: params[0] || 0,
            status: params[1] || 'draft',
            created_at: new Date().toISOString()
        };
        await completed(store.keyPath === null ? store.add(sale, sale.id) : store.add(sale));
        return { success: true };
    }
    
    // INSERT customers
    if (normalizedSql.startsWith('insert') && normalizedSql.includes('customers')) {
        const store = db.transaction('customers', 'readwrite').objectStore('customers');
        const customer = {
            id: crypto.randomUUID(),
            name: params[0],
            created_at: new Date().toISOString()
        };
        await completed(store.keyPath === null ? store.add(customer, customer.id) : store.add(customer));
        return { success: true };
    }
    
    // INSERT OR IGNORE users (for init)
    if (normalizedSql.includes('insert or ignore') && normalizedSql.includes('users')) {
        const store = db.transaction('users', 'readwrite').objectStore('users');
        const user = {
            id: params[0],
            username: params[1],
            email: params[2],
            password_hash: params[3],
            full_name: params[4],
            role: params[5],
            created_at: new Date().toISOString()
        };
        try {
            await completed(store.keyPath === null ? store.add(user, user.id) : store.add(user));
        } catch (e) {
            // Already exists - ignore
        }
        return { success: true };
    }
    
    return { success: true };
}

// Tauri Updater functions
export async function checkForUpdates() {
    if (!isTauri()) {
        // Web context - return no update
        return { available: false };
    }
    try {
        const { autoUpdater } = await import('@tauri-apps/api/updater');
        return await autoUpdater.checkForUpdates();
    } catch (e) {
        return { available: false };
    }
}

export async function downloadUpdate() {
    if (!isTauri()) {
        // Web context - open GitHub releases
        window.open('https://github.com/nicolasrojas/erp-desktop-lipigas-anchaual/releases/latest', '_blank');
        return { downloaded: false };
    }
    try {
        const { autoUpdater } = await import('@tauri-apps/api/updater');
        return await autoUpdater.downloadUpdate();
    } catch (e) {
        window.open('https://github.com/nicolasrojas/erp-desktop-lipigas-anchaual/releases/latest', '_blank');
        return { downloaded: false };
    }
}

export async function relaunch() {
    if (!isTauri()) {
        window.location.reload();
        return;
    }
    try {
        const { autoUpdater } = await import('@tauri-apps/api/updater');
        return await autoUpdater.relaunch();
    } catch (e) {
        window.location.reload();
    }
}