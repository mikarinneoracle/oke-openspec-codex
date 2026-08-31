export function executableSql(sql) {
  // node-oracledb executes one SQL statement and must not receive the
  // SQL*Plus-style trailing delimiter stored in schema.sql.
  return sql.trim().replace(/;\s*$/, '');
}
