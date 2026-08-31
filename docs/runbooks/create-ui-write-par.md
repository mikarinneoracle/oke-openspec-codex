# Create the Todo UI write PAR

Use this one-time manual OCI CLI operation to create the GitHub Actions upload
credential for the public Todo UI bucket. Do not use the OCI Console and do not
commit the generated URL.

## Preconditions

- OCI CLI is authenticated to the `mika.rinne` compartment.
- GitHub CLI is authenticated to the Todo repository.
- A protected GitHub Environment already exists for UI publication. Substitute
  its name for `<github-environment>` below.
- The current demo uses an Nginx UI bridge behind the same HTTP Envoy Gateway
  origin as `/api`, so the workflow requires no API URL variable. When the
  bridge is replaced by direct HTTPS bucket/CDN delivery, add a non-secret
  `TODO_API_BASE_URL` GitHub Environment variable before publishing that build.

## Create and store the PAR

Choose a recorded, finite RFC 3339 expiration timestamp. The value below is an
example only; use an approved future date before running the command.

```sh
PAR_EXPIRY='REPLACE_WITH_APPROVED_RFC3339_EXPIRY'
PAR_ACCESS_URI="$(oci os preauth-request create \
  --region eu-frankfurt-1 \
  --namespace-name frsxwtjslf35 \
  --bucket-name oke-openspec-codex-todo-ui \
  --name todo-ui-actions-write-releases \
  --access-type AnyObjectWrite \
  --object-name 'releases/' \
  --time-expires "$PAR_EXPIRY" \
  --query 'data."access-uri"' \
  --raw-output)"

printf '%s' "https://objectstorage.eu-frankfurt-1.oraclecloud.com${PAR_ACCESS_URI}" \
  | gh secret set OCI_TODO_UI_WRITE_PAR_URL --env <github-environment>

unset PAR_ACCESS_URI PAR_EXPIRY
```

The PAR is limited to creating or overwriting objects whose names start with
`releases/`. It cannot read objects, list the bucket, or change bucket
configuration. The command deliberately pipes the full bearer URL directly to
GitHub CLI rather than printing it.

The Actions workflow appends the selected immutable release path, for example
`releases/<git-sha>/index.html`, to the stored base PAR URL. OCI returns the
PAR access URI only when the request is created; if it is lost, create a new
PAR and replace the GitHub Environment secret.

## Rotation and revocation

- Record the PAR's name and expiry in the team's operational record, but never
  record the URL itself.
- Before expiry, create a replacement PAR with a distinct name, overwrite the
  GitHub Environment secret using the same command, verify a release upload,
  then delete the previous PAR with OCI CLI.
- If exposure is suspected, create and store the replacement first, then delete
  the exposed PAR immediately. Do not wait for its expiry.

Crossplane owns the bucket. This runbook creates only the CI upload capability;
it must not be used to create, update, or delete bucket infrastructure.
