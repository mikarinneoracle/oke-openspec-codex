import { createApp } from './app.js';
import { closePool } from './database.js';

const server = createApp().listen(Number(process.env.PORT ?? 8080), '0.0.0.0', () => console.log(`Todo API listening on port ${process.env.PORT ?? 8080}`));

async function shutdown(signal) {
  console.log(`${signal} received; shutting down`);
  server.close(async () => {
    await closePool();
    process.exit(0);
  });
}

process.once('SIGTERM', () => { void shutdown('SIGTERM'); });
process.once('SIGINT', () => { void shutdown('SIGINT'); });
