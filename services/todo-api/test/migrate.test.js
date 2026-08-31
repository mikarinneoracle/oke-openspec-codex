import assert from 'node:assert/strict';
import test from 'node:test';
import { executableSql } from '../src/migration-sql.js';

test('removes the SQL*Plus delimiter before node-oracledb executes SQL', () => {
  assert.equal(executableSql('SELECT 1 FROM dual;\n'), 'SELECT 1 FROM dual');
});
