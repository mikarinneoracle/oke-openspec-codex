# Todo API

Node.js REST API for the OKE Todo reference platform. Browser code communicates
only with `/api`; Oracle credentials remain in the API workload.

## API

- `GET /health/live`
- `GET /health/ready`
- `GET /api/tasks`
- `POST /api/tasks` with `{ "title": "..." }`
- `PATCH /api/tasks/:id` with `{ "completed": true }`
- `DELETE /api/tasks/:id`

## Configuration

The Kubernetes deployment will supply these values through a Secret reference.
Do not commit their values:

- `TODO_DB_USER`
- `TODO_DB_PASSWORD`
- `TODO_DB_CONNECT_STRING`
- `CORS_ALLOWED_ORIGIN` (the exact HTTPS Object Storage UI origin; no wildcard)

Run [`database/schema.sql`](database/schema.sql) in the application schema
before the readiness endpoint can succeed. The later Crossplane/database task
owns database provisioning and runtime secret delivery.

Each API pod uses a lazy `node-oracledb` pool with `poolMin: 0` and
`poolMax: 1`. A pool avoids opening a new database connection for every HTTP
request while keeping database concurrency proportional to the number of API
replicas.

## Local validation

```sh
npm ci
npm test
npm run lint
```
