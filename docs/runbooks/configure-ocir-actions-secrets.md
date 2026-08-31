# Configure OCIR publish secrets for GitHub Actions

Use this manual terminal operation before enabling Todo API image publication
from GitHub Actions. It creates a protected GitHub Environment and stores the
OCIR publishing configuration without printing protected values or placing them
in shell history.

## Preconditions

- GitHub CLI is authenticated to `mikarinneoracle/oke-openspec-codex`.
- An OCI auth token has been generated for the OCI identity that may push to the
  Crossplane-managed Todo API OCIR repository.
- Crossplane has been granted its separate, scoped `manage repos` policy using
  [`grant-crossplane-ocir-repository-access.md`](grant-crossplane-ocir-repository-access.md),
  so Flux can create the private Todo API repository before this workflow runs.

## Store the secrets

```sh
sh scripts/configure-ocir-actions-secrets.sh
```

The script prompts for the public OCIR registry endpoint (default:
`fra.ocir.io`) and for three hidden values: tenancy namespace, the **full
OCIR Docker username including that namespace**, and auth token. Do not paste a
multi-line command block into the interactive prompts.

For a federated OCI identity-domain user, the username is normally
`<tenancy-namespace>/<identity-domain>/<username>`. For a non-federated user
it is `<tenancy-namespace>/<username>`. The auth token is the Docker password,
not the OCI console password.

## Stored GitHub Environment configuration

The script uses the `ocir-publish` GitHub Environment and creates or updates:

| Name | GitHub storage | Purpose |
| --- | --- | --- |
| `OCI_REGISTRY` | Environment Variable | Public registry endpoint, such as `fra.ocir.io`. |
| `OCI_TENANCY_NAMESPACE` | Environment Secret | Tenancy-scoped OCIR repository path component. |
| `OCI_REGISTRY_USERNAME` | Environment Secret | OCIR Docker login username. |
| `OCI_REGISTRY_AUTH_TOKEN` | Environment Secret | OCIR Docker login password/token. |

The Todo API workflow reads these names only from the `ocir-publish`
Environment. The namespace is intentionally a Secret even though it is not a
credential, following this platform's tenancy-information handling policy.

## Safety boundary

- Never echo, commit, paste into a workflow, or record the namespace, username,
  or token outside the GitHub Environment secret store.
- The token must be scoped by OCI IAM to pushing the Todo API OCIR repository;
  it grants no Kubernetes access.
- Rotate by creating a replacement OCI auth token, updating the Environment
  secret with the same command, verifying one image push, then revoking the old
  token.
