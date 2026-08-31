# Configure the Todo API OCIR pull secret

The Todo API image repository is private. OKE receives the registry credentials
through External Secrets Operator (ESO), not through a GitHub Actions secret,
a committed Kubernetes Secret, or a local `kubectl create secret` command.

## One-time setup

First grant ESO's existing OKE Workload Identity permission to read only the
new Vault secret:

```sh
sh scripts/grant-eso-ocir-pull-secret-access.sh
```

Then, from the repository root, create the Docker configuration in the existing
OCI Vault:

```sh
sh scripts/configure-ocir-pull-secret.sh
```

The script prompts for the same OCIR username and auth token stored in the
protected `ocir-publish` GitHub Environment. The token input is hidden. Neither
the username nor token is printed, committed, placed in shell history, or read
back from GitHub.

The stored secret is named `oke-openspec-codex-todo-ocir-pull`. A later Flux
manifest creates a `kubernetes.io/dockerconfigjson` Secret only in the
`todo-app` namespace. The Todo API Deployment references that secret via
`imagePullSecrets`.

## Rotation

Run `sh scripts/configure-ocir-pull-secret.sh` again after creating a
replacement OCI auth token. The script detects the active Vault secret and
creates a new secret version. ESO refreshes the Kubernetes pull secret; restart
or redeploy the workload through GitOps only when a new image pull is needed.
