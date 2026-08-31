# Todo DB App UI

React/Vite-käyttöliittymä OKE OpenSpec -esimerkkiprojektille.

Tässä tuontivaiheessa tehtävät ovat vielä selaimen paikallisessa tilassa. Seuraava
vaihe korvaa tietolähteen saman originin REST API -kutsuilla (`/api`), jolloin
Node.js-palvelu käyttää Oracle-tietokantaa.

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
