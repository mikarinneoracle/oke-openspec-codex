# Todo DB App UI

React/Vite user interface for the OKE OpenSpec reference project.

The UI reads and updates tasks through same-origin REST API calls (`GET`,
`POST`, `PATCH`, and `DELETE /api/tasks`). Envoy Gateway routes `/` requests
to the UI and `/api` requests to the Node.js service, which uses Oracle
Autonomous Database. The browser never receives database credentials.

## Local development

```sh
npm ci
npm run dev
```

## Validation

```sh
npm run build
npm run lint
```

`dist/` is a build artifact. GitHub Actions publishes versioned releases to
OCI Object Storage through a write-only PAR URL held only as the protected
GitHub Environment Secret (`OCI_TODO_UI_WRITE_PAR_URL`). The URL is a bearer
secret: it is never committed or printed in logs. In the current no-DNS,
no-certificate demo, the Nginx UI pod retrieves the versioned release from a
public-read/no-list Object Storage bucket, while Envoy Gateway serves the UI
and `/api` route from the same HTTP origin. Replace this bridge with direct
HTTPS Object Storage/CDN delivery once DNS and TLS are available.
