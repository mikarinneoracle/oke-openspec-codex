import oracledb from 'oracledb';

let pool;

function databaseConfig() {
  const { TODO_DB_USER: user, TODO_DB_PASSWORD: password, TODO_DB_CONNECT_STRING: connectString } = process.env;
  if (!user || !password || !connectString) throw new Error('Database configuration is incomplete');
  return { user, password, connectString, poolMin: 0, poolMax: 4, poolIncrement: 1 };
}

export async function getPool() {
  if (!pool) pool = await oracledb.createPool(databaseConfig());
  return pool;
}

export async function withConnection(work) {
  const connection = await (await getPool()).getConnection();
  try {
    return await work(connection);
  } finally {
    await connection.close();
  }
}

export async function closePool() {
  if (pool) {
    await pool.close(10);
    pool = undefined;
  }
}

export async function isReady() {
  await withConnection((connection) => connection.execute('SELECT 1 FROM dual'));
}
