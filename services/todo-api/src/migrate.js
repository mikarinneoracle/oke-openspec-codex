import { readFile } from 'node:fs/promises';
import { closePool, withConnection } from './database.js';

async function migrate() {
  const statement = (await readFile(new URL('../database/schema.sql', import.meta.url), 'utf8')).trim();
  await withConnection(async (connection) => {
    try {
      await connection.execute(statement);
    } catch (error) {
      // The initContainer can run on every replica. Oracle error ORA-00955
      // means the initial replica has already created the table.
      if (error.errorNum !== 955) throw error;
    }
  });
}

try {
  await migrate();
  console.log('Todo database schema is ready.');
} finally {
  await closePool();
}
