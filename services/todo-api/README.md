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

The Kubernetes probes use `/health/*` directly on the Pod. Envoy Gateway also
publishes `/health/*` to the API for this demo, while browser application calls
remain under `/api`.

## Configuration

The Kubernetes deployment will supply these values through a Secret reference.
Do not commit their values:

- `TODO_DB_USER`
- `TODO_DB_PASSWORD`
- `TODO_DB_CONNECT_STRING`
- `CORS_ALLOWED_ORIGIN` (optional; needed only after the HTTP demo bridge is
  replaced by a separate HTTPS UI origin)

Run [`database/schema.sql`](database/schema.sql) in the application schema
before serving task requests. The Flux-managed API Deployment runs the same
schema through an idempotent initContainer: the first replica creates the
table, and later replicas accept Oracle's already-exists result. Crossplane and
ESO own database provisioning and runtime secret delivery.

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
