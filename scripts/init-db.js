#!/usr/bin/env node
/**
 * Initialize local database for ERP Desktop client
 * Run: node scripts/init-db.js
 */

import sqlite3Pkg from 'sqlite3';
const { Database, verbose } = sqlite3Pkg;
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Get database path
const dbDir = path.join(process.env.HOME || '.', 'Documents', 'erp-client');
const dbPath = path.join(dbDir, 'erp.db');

// Ensure directory exists
if (!fs.existsSync(dbDir)) {
    fs.mkdirSync(dbDir, { recursive: true });
}

// Read schema
const schemaPath = path.join(__dirname, '..', 'sqlite', 'schema.sql');
const schema = fs.readFileSync(schemaPath, 'utf8');

// Create database and initialize
const db = new Database(dbPath, (err) => {
    if (err) {
        console.error('Error creating database:', err.message);
        process.exit(1);
    }
    console.log('Database created at:', dbPath);
    
    db.exec(schema, (err) => {
        if (err) {
            console.error('Error initializing schema:', err.message);
            process.exit(1);
        }
        console.log('✅ Database initialized successfully');
        console.log('📁 Location:', dbPath);
        console.log('📝 No DTE provider configuration needed');
        
        // Create default admin user
        const defaultPassword = 'admin123'; // Cambiar en producción
        db.run(`INSERT OR IGNORE INTO users (id, username, email, password_hash, full_name, role) 
                VALUES ('default-admin', 'admin', 'admin@localhost', ?, 'Administrador', 'admin')`,
            [defaultPassword],
            function(err) {
                if (err) {
                    console.error('Error creating admin user:', err.message);
                } else {
                    console.log('\n👤 Usuario admin creado:');
                    console.log('   Usuario: admin');
                    console.log('   Contraseña: admin123');
                    console.log('   Rol: admin');
                }
                
                db.close();
                console.log('\n✅ Listo para usar');
                process.exit(0);
            });
    });
});