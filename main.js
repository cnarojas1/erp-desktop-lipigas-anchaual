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

// Local database operations
export async function initDatabase() {
    const response = await window.__TAURI_INVOKE__('init_database', {});
    return response.success;
}

export async function localQuery(sql, params = []) {
    const response = await window.__TAURI_INVOKE__('db_query', { sql, params });
    return response.data;
}

export async function localExec(sql, params = []) {
    const response = await window.__TAURI_INVOKE__('db_run', { sql, params });
    return response;
}