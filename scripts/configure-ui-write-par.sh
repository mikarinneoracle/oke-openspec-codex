#!/usr/bin/env sh
# Create a write-only, prefix-scoped UI publication PAR and store its bearer URL
# directly as a GitHub Environment secret.
set -eu

repository='mikarinneoracle/oke-openspec-codex'
environment='ui-publish'
region='eu-frankfurt-1'
namespace='frsxwtjslf35'
bucket='oke-openspec-codex-todo-ui'
par_name='todo-ui-actions-write-releases'

command -v gh >/dev/null 2>&1 || { echo 'GitHub CLI (gh) is required.' >&2; exit 1; }
command -v oci >/dev/null 2>&1 || { echo 'OCI CLI (oci) is required.' >&2; exit 1; }

printf 'PAR expiry (RFC 3339, for example 2027-02-01T00:00:00Z): '
IFS= read -r par_expiry
test -n "$par_expiry" || { echo 'Expiry cannot be empty.' >&2; exit 1; }

gh api --method PUT "repos/${repository}/environments/${environment}" >/dev/null

par_access_uri="$(oci os preauth-request create \
  --region "$region" \
  --namespace-name "$namespace" \
  --bucket-name "$bucket" \
  --name "$par_name" \
  --access-type AnyObjectWrite \
  --object-name 'releases/' \
  --time-expires "$par_expiry" \
  --query 'data."access-uri"' \
  --raw-output)"

printf '%s' "https://objectstorage.${region}.oraclecloud.com${par_access_uri}" \
  | gh secret set OCI_TODO_UI_WRITE_PAR_URL --env "$environment"

unset par_access_uri par_expiry
echo "UI write PAR stored in GitHub Environment: ${environment}"
