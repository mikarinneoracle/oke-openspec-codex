#!/usr/bin/env sh
# Allow ESO's existing workload identity to read exactly the Vault secret that
# contains the private Todo API OCIR image-pull configuration.
set -eu

policy_id='ocid1.policy.oc1..aaaaaaaak76aemkxfqbbfzfgweebgxywk6br2rw6zw7swgyomckiegioqxmq'
compartment_id='ocid1.compartment.oc1..aaaaaaaawccfklp2wj4c5ymigrkjfdhcbcm3u5ripl2whnznhmvgiqdatqgq'
cluster_id='ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaau3sb3gs5lcosf7u4a5u3xz5kvrzwkzbkc7fog7s3xcpenwekptda'
secret_name='oke-openspec-codex-todo-ocir-pull'
statement="Allow any-user to read secret-bundles in compartment id ${compartment_id} where all {request.principal.type = 'workload', request.principal.namespace = 'crossplane-system', request.principal.service_account = 'todo-vault-reader', request.principal.cluster_id = '${cluster_id}', target.secret.name = '${secret_name}'}"

command -v oci >/dev/null 2>&1 || { echo 'OCI CLI (oci) is required.' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo 'jq is required.' >&2; exit 1; }

policy_json="$(mktemp)"
statements_json="$(mktemp)"
trap 'rm -f "$policy_json" "$statements_json"' EXIT

oci iam policy get --policy-id "$policy_id" --output json > "$policy_json"

if jq -e --arg statement "$statement" '.data.statements | index($statement)' "$policy_json" >/dev/null; then
  echo 'ESO already has the required OCIR pull-secret read permission.'
  exit 0
fi

jq --arg statement "$statement" '.data.statements + [$statement]' "$policy_json" > "$statements_json"

oci iam policy update \
  --policy-id "$policy_id" \
  --description 'Scoped OCI Vault access for Todo database and OCIR pull secrets.' \
  --statements "file://${statements_json}" \
  --version-date '' \
  --if-match "$(jq -r '.etag' "$policy_json")" \
  --force

echo 'Granted ESO read access to the scoped OCIR pull secret.'
