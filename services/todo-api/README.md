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

Run [`database/schema.sql`](database/schema.sql) in the application schema
before the readiness endpoint can succeed. The later Crossplane/database task
owns database provisioning and runtime secret delivery.

## Local validation

```sh
npm ci
npm test
npm run lint
```
