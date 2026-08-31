# Configure OCIR publish secrets for GitHub Actions

Use this manual terminal operation before enabling Todo API image publication
from GitHub Actions. It creates a protected GitHub Environment and stores the
OCIR Docker login values without printing them or placing them in shell history.

## Preconditions

- GitHub CLI is authenticated to `mikarinneoracle/oke-openspec-codex`.
- An OCI auth token has been generated for the OCI identity that may push to the
  Crossplane-managed Todo API OCIR repository.
- The OCIR registry is `fra.ocir.io` and the tenancy Object Storage namespace
  is `frsxwtjslf35`.
- Crossplane has been granted its separate, scoped `manage repos` policy using
  [`grant-crossplane-ocir-repository-access.md`](grant-crossplane-ocir-repository-access.md),
  so Flux can create the private Todo API repository before this workflow runs.

## Store the secrets

```sh
sh scripts/configure-ocir-actions-secrets.sh
```

The script prompts separately for the username and hidden auth token. Do not
paste a multi-line command block into the interactive prompts.

For a federated OCI identity-domain user, the username is normally
`frsxwtjslf35/<identity-domain>/<username>`. For a non-federated user it is
`frsxwtjslf35/<username>`. The auth token is the Docker password, not the OCI
console password.

## Safety boundary

- Never echo, commit, paste into a workflow, or record either value outside the
  GitHub Environment secret store.
- The token must be scoped by OCI IAM to pushing the Todo API OCIR repository;
  it grants no Kubernetes access.
- Rotate by creating a replacement OCI auth token, updating the Environment
  secret with the same command, verifying one image push, then revoking the old
  token.
