# External Secrets and OCI Vault primitive

## Purpose

Keep secret values outside Git while making the minimum required Kubernetes
Secrets available to Flux-managed workloads and Crossplane.

## Ownership and flow

- OCI Vault is the external system of record for secret values.
- External Secrets Operator (ESO) is installed and configured by Flux.
- ESO uses OKE Workload Identity; OCI API keys and secret values are never
  committed to Git or stored in Terraform state.
- ESO generates a database-admin password, writes it to the approved existing
  OCI Vault, and materializes it only as the scoped Kubernetes Secret consumed
  by Crossplane or the Todo API.
- Crossplane consumes Kubernetes Secret references. It does not own the Vault
  or receive literal secret values through Git manifests.

## Safety boundary

- Do not put a password, wallet, token, private key, or OCI credential in a
  Kubernetes manifest, Helm values file, ConfigMap, Crossplane resource, or
  Terraform variable/state.
- Scope each ExternalSecret, SecretStore, and ServiceAccount to the least
  privilege namespace and secret path required by its workload.
- Treat the existing OCI Vault as an external platform prerequisite. Do not
  register it as a Crossplane managed resource merely to read or synchronize
  secrets.
