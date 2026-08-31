# Todo DB App UI

React/Vite-käyttöliittymä OKE OpenSpec -esimerkkiprojektille.

Käyttöliittymä hakee ja muuttaa tehtäviä saman originin REST API -kutsuilla
(`GET`, `POST`, `PATCH` ja `DELETE /api/tasks`). Envoy Gateway reitittää
`/`-pyynnöt UI:lle ja `/api`-pyynnöt Node.js-palvelulle, joka käyttää Oracle
Autonomous Databasea. Selain ei koskaan saa tietokantayhteystietoja.

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

`dist/` on rakennusartefakti. Se julkaistaan myöhemmässä vaiheessa versionoituna
OCI Object Storageen eikä sitä commitata.
