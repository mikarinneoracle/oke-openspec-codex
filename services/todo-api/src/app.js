import crypto from 'node:crypto';
import express from 'express';
import { isReady } from './database.js';
import * as tasks from './tasks.js';
import { validateNewTask, validateTaskPatch } from './validation.js';

export function createApp({
  taskRepository = tasks,
  readinessCheck = isReady,
  corsAllowedOrigin = process.env.CORS_ALLOWED_ORIGIN,
} = {}) {
  const app = express();
  app.use((request, response, next) => {
    if (corsAllowedOrigin && request.get('origin') === corsAllowedOrigin) {
      response.set({
        'access-control-allow-origin': corsAllowedOrigin,
        'access-control-allow-methods': 'GET, POST, PATCH, DELETE, OPTIONS',
        'access-control-allow-headers': 'content-type',
        vary: 'Origin',
      });
      if (request.method === 'OPTIONS') return response.status(204).end();
    }
    return next();
  });
  app.use(express.json({ limit: '16kb' }));
  app.get('/health/live', (_request, response) => response.status(200).json({ service: 'todo-api', status: 'ok' }));
  app.get('/health/ready', async (_request, response) => {
    try {
      await readinessCheck();
      response.status(200).json({ status: 'ok' });
    } catch {
      response.status(503).json({ status: 'not-ready' });
    }
  });
  app.get('/api/tasks', async (_request, response, next) => {
    try { response.json(await taskRepository.listTasks()); } catch (error) { next(error); }
  });
  app.post('/api/tasks', async (request, response, next) => {
    const validated = validateNewTask(request.body);
    if (validated.error) return response.status(400).json({ error: validated.error });
    try { return response.status(201).json(await taskRepository.createTask({ id: crypto.randomUUID(), ...validated.value })); } catch (error) { return next(error); }
  });
  app.patch('/api/tasks/:id', async (request, response, next) => {
    const validated = validateTaskPatch(request.body);
    if (validated.error) return response.status(400).json({ error: validated.error });
    try {
      const task = await taskRepository.updateTask(request.params.id, validated.value);
      return task ? response.json(task) : response.status(404).json({ error: 'task not found' });
    } catch (error) { return next(error); }
  });
  app.delete('/api/tasks/:id', async (request, response, next) => {
    try { return (await taskRepository.deleteTask(request.params.id)) ? response.status(204).end() : response.status(404).json({ error: 'task not found' }); } catch (error) { return next(error); }
  });
  app.use((error, _request, response, _next) => {
    console.error(error);
    response.status(503).json({ error: 'database unavailable' });
  });
  return app;
}
