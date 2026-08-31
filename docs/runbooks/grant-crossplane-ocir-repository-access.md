# Grant Crossplane access to the Todo API OCIR repository

The OCI Artifacts Crossplane provider creates and reconciles the private Todo
API OCIR repository. Before Flux applies that repository resource, grant the
existing Crossplane OKE Workload Identity this narrowly scoped permission:

```text
Allow any-user to manage repos in compartment id <mika.rinne-compartment-ocid>
where all {
  request.principal.type = 'workload',
  request.principal.namespace = 'crossplane-system',
  request.principal.service_account = 'crossplane-provider-oci',
  request.principal.cluster_id = '<this-OKE-cluster-ocid>'
}
```

This grants neither Kubernetes access nor general OCI user credentials. Only
the Crossplane provider ServiceAccount from this OKE cluster can manage OCIR
repositories in the Todo compartment.

## Apply the approved policy change

Run the reviewed interactive-safe script from the repository root:

```sh
sh scripts/grant-crossplane-ocir-repository-access.sh
```

The script reads the current policy, appends the statement only if it is absent,
and uses the policy ETag to prevent overwriting a concurrent change. It does
not print or store credentials.

This is an explicit bootstrap-access exception performed with OCI CLI. Do not
add it to Terraform: Terraform is limited to the initial OKE bootstrap, while
Crossplane owns post-bootstrap Todo infrastructure through Flux.

## Verify

```sh
oci iam policy get \
  --policy-id <crossplane-policy-ocid> \
  --query 'data.statements[?contains(@, `manage repos`)]' \
  --output json
```

After the policy is effective, commit the OCI Artifacts provider and
`ContainerRepository` manifests. Flux installs the provider, then Crossplane
creates the private `oke-openspec-codex/todo-api` repository. Releases are
immutable by convention through unique Git SHA tags: OCI Artifacts does not
currently support enforcing `isImmutable` when creating this repository.
