import assert from 'node:assert/strict';
import test from 'node:test';
import { createApp } from '../src/app.js';

async function withApi(repository, callback) {
  const server = createApp({ taskRepository: repository, readinessCheck: async () => {} }).listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  const address = server.address();
  try {
    await callback(`http://127.0.0.1:${address.port}`);
  } finally {
    await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  }
}

test('creates and lists tasks through the REST API', async () => {
  const stored = [];
  const repository = {
    listTasks: async () => stored,
    createTask: async (task) => { const created = { ...task, completed: false }; stored.push(created); return created; },
    updateTask: async () => undefined,
    deleteTask: async () => false,
  };
  await withApi(repository, async (baseUrl) => {
    const created = await fetch(`${baseUrl}/api/tasks`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ title: '  Ship API  ' }) });
    assert.equal(created.status, 201);
    assert.deepEqual(await created.json(), { id: stored[0].id, title: 'Ship API', completed: false });
    const listed = await fetch(`${baseUrl}/api/tasks`);
    assert.equal(listed.status, 200);
    assert.deepEqual(await listed.json(), stored);
  });
});

test('rejects invalid task payloads', async () => {
  const repository = { listTasks: async () => [], createTask: async () => {}, updateTask: async () => undefined, deleteTask: async () => false };
  await withApi(repository, async (baseUrl) => {
    const response = await fetch(`${baseUrl}/api/tasks`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ title: '   ' }) });
    assert.equal(response.status, 400);
    assert.deepEqual(await response.json(), { error: 'title must contain 1 to 500 characters' });
  });
});
