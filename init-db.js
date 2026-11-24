#!/usr/bin/env node
/**
 * Initialize local database for ERP Desktop client
 * Run: node scripts/init-db.js
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

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
const db = new sqlite3.Database(dbPath, (err) => {
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
        db.close();
        process.exit(0);
    });
});