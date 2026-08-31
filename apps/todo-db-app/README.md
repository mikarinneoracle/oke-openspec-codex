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

`dist/` on rakennusartefakti. GitHub Actions julkaisee sen versionoituna OCI
Object Storageen write-only PAR-URL:lla, joka on ainoastaan suojattuna GitHub
Environment Secretinä (`OCI_TODO_UI_WRITE_PAR_URL`). URL on bearer-salaisuus,
eikä sitä commitata tai tulosteta lokiin. Selain lataa versionoidun UI-releasen
suoraan public-read/no-list Object Storage -bucketista. Julkaisuvaiheessa
`VITE_TODO_API_BASE_URL` asetetaan Envoy Gatewayn HTTPS API-originiksi.
