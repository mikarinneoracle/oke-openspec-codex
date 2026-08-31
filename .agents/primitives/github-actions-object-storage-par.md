# GitHub Actions Object Storage PAR primitive

## Purpose

Publish versioned Todo UI artefacts from GitHub Actions without granting the
workflow an OCI user, API key, Workload Identity, or Kubernetes credentials.

## Approved flow

- An OCI administrator creates a time-bound pre-authenticated request (PAR)
  with `AnyObjectWrite` access scoped to the Todo UI bucket's `releases/`
  object prefix.
- Store the resulting complete PAR URL only as the protected GitHub Environment
  secret `OCI_TODO_UI_WRITE_PAR_URL`.
- The release workflow uploads the immutable, versioned UI artefact using that
  URL. It must not list, read, or overwrite unrelated bucket objects.
- Flux remains the only Kubernetes reconciler. GitHub Actions may commit a
  reviewed release reference but must never receive Kubernetes credentials or
  run `kubectl apply`.

## Safety boundary

- A PAR URL is a bearer secret. Never commit it, render it in logs, put it in a
  manifest, or store it in Terraform state.
- Do not use a read/write PAR. The CI publisher needs write access only; the UI
  runtime retrieves releases through its separate, least-privilege OKE
  Workload Identity.
- Set and record an expiry date. Replace the GitHub Environment secret before
  expiry or whenever its exposure is suspected; a PAR cannot be edited.
- Do not use the PAR to create, delete, or change Object Storage infrastructure.
  Crossplane remains the owner of the bucket itself.
