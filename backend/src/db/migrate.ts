import { Pool } from 'pg';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Run SQL migration files that haven't been applied yet.
 * Tracks applied migrations in a simple `_migrations` table.
 */
export async function runMigrations(): Promise<void> {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });

  try {
    // Create migrations tracking table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS _migrations (
        id SERIAL PRIMARY KEY,
        filename TEXT UNIQUE NOT NULL,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const migrationsDir = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      const { rows } = await pool.query(
        'SELECT 1 FROM _migrations WHERE filename = $1', [file]
      );
      if (rows.length > 0) continue; // already applied

      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      console.log(`[migrate] Applying ${file}...`);
      await pool.query(sql);
      await pool.query('INSERT INTO _migrations (filename) VALUES ($1)', [file]);
      console.log(`[migrate] ✅ ${file} done`);
    }
  } catch (err) {
    console.error('[migrate] Error:', err);
    throw err;
  } finally {
    await pool.end();
  }
}
