# Todo platform Vault secret inventory

This is the single inventory for OCI Vault secrets used by the Todo platform.
It records secret identities and flows only. It must never contain secret
values, OCI auth tokens, wallet files, or full secret-bundle output.

The existing OCI Vault is an external platform prerequisite in the
`mika.rinne` compartment. Flux installs External Secrets Operator (ESO), and
ESO uses the scoped OKE Workload Identity
`crossplane-system/todo-vault-reader` to move only the required values between
OCI Vault and Kubernetes.

## Active secrets

| OCI Vault secret name | Created by | OCI Vault purpose | Kubernetes consumer | Rotation |
| --- | --- | --- | --- | --- |
| `oke-openspec-codex-todo-adb-admin-eso` | ESO `PushSecret` from a generated password | Autonomous Database administrator password | `crossplane-system/todo-adb-admin`, consumed by Crossplane's `AutonomousDatabase` | ESO is the owner. Update the GitOps generator only when a deliberate database credential rotation is planned. |
| `oke-openspec-codex-todo-ocir-pull` | Local `scripts/configure-ocir-pull-secret.sh`, with interactive token input | Docker `config.json` for pulling the private Todo API OCIR image | A Flux-managed `kubernetes.io/dockerconfigjson` Secret in `todo-app`, referenced only through the API Deployment's `imagePullSecrets` | Create a replacement OCIR auth token, then re-run `scripts/configure-ocir-pull-secret.sh`. ESO refreshes the in-cluster Secret. |

## Access boundaries

- The ESO identity can read the database bundle and the OCIR pull-secret bundle
  by exact secret name. It is constrained to this OKE cluster, the
  `crossplane-system` namespace, and `todo-vault-reader` ServiceAccount.
- Crossplane receives only the database-admin Kubernetes Secret reference. It
  does not receive literal Vault values and does not own the existing Vault.
- GitHub Actions has a separate protected OCIR publishing credential. It does
  not read OCI Vault and it does not have Kubernetes access.
- Browser-delivered UI assets are public Object Storage objects, not secrets.
  The UI publishing PAR is a protected GitHub Environment secret, but is not
  stored in OCI Vault and is intentionally excluded from this inventory.

## Operational rules

- Do not use `kubectl create secret` for either secret. Flux and ESO are the
  only supported delivery path to Kubernetes.
- Verify lifecycle metadata only when troubleshooting. Do not retrieve or log
  a secret bundle value.
- Retire a Vault secret only after its Flux resource and all OCI/Kubernetes
  consumers have been removed in the documented teardown order.

The OCIR-specific setup and rotation instructions are in
[`configure-ocir-pull-secret.md`](configure-ocir-pull-secret.md).
