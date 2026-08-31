import { withConnection } from './database.js';

function toTask(row) {
  return { id: row.ID, title: row.TITLE, completed: row.COMPLETED === 1 };
}

export async function listTasks() {
  return withConnection(async (connection) => {
    const result = await connection.execute('SELECT id, title, completed FROM todo_items ORDER BY created_at DESC', [], { outFormat: 4002 });
    return result.rows.map(toTask);
  });
}

export async function createTask({ id, title }) {
  await withConnection((connection) => connection.execute('INSERT INTO todo_items (id, title, completed) VALUES (:id, :title, 0)', { id, title }, { autoCommit: true }));
  return { id, title, completed: false };
}

export async function updateTask(id, { completed }) {
  return withConnection(async (connection) => {
    const result = await connection.execute('UPDATE todo_items SET completed = :completed WHERE id = :id', { id, completed: completed ? 1 : 0 }, { autoCommit: true });
    if (result.rowsAffected === 0) return undefined;
    const selected = await connection.execute('SELECT id, title, completed FROM todo_items WHERE id = :id', { id }, { outFormat: 4002 });
    return toTask(selected.rows[0]);
  });
}

export async function deleteTask(id) {
  return withConnection(async (connection) => {
    const result = await connection.execute('DELETE FROM todo_items WHERE id = :id', { id }, { autoCommit: true });
    return result.rowsAffected > 0;
  });
}
