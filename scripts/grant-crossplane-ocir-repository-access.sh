#!/usr/bin/env sh
# Add the least-privilege OCIR repository permission required by the
# Crossplane OCI Artifacts provider. This is a post-bootstrap IAM exception;
# Terraform must not manage it after the OKE bootstrap handoff.
set -eu

policy_id='ocid1.policy.oc1..aaaaaaaagfhte2s3jpjjav4q6heaqcbohkyng2siktia2rd5ofwbdvxiv2pq'
compartment_id='ocid1.compartment.oc1..aaaaaaaawccfklp2wj4c5ymigrkjfdhcbcm3u5ripl2whnznhmvgiqdatqgq'
cluster_id='ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaau3sb3gs5lcosf7u4a5u3xz5kvrzwkzbkc7fog7s3xcpenwekptda'
statement="Allow any-user to manage repos in compartment id ${compartment_id} where all {request.principal.type = 'workload', request.principal.namespace = 'crossplane-system', request.principal.service_account = 'crossplane-provider-oci', request.principal.cluster_id = '${cluster_id}'}"

command -v oci >/dev/null 2>&1 || { echo 'OCI CLI (oci) is required.' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo 'jq is required.' >&2; exit 1; }

policy_json="$(mktemp)"
statements_json="$(mktemp)"
trap 'rm -f "$policy_json" "$statements_json"' EXIT

oci iam policy get --policy-id "$policy_id" --output json > "$policy_json"

if jq -e --arg statement "$statement" '.data.statements | index($statement)' "$policy_json" >/dev/null; then
  echo 'Crossplane already has the required OCIR repository permission.'
  exit 0
fi

jq --arg statement "$statement" '.data.statements + [$statement]' "$policy_json" > "$statements_json"

oci iam policy update \
  --policy-id "$policy_id" \
  --description 'Least-privilege OCI access for the Crossplane OCI provider workload.' \
  --statements "file://${statements_json}" \
  --version-date '' \
  --if-match "$(jq -r '.etag' "$policy_json")" \
  --force

echo 'Granted Crossplane the scoped OCIR repository permission.'
