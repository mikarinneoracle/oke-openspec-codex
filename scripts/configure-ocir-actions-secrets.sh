#!/usr/bin/env sh
# Configure the OCIR publishing environment without exposing tenancy-scoped
# values, credentials, or the auth token in Git, command lines, or shell history.
set -eu

repository='mikarinneoracle/oke-openspec-codex'
environment='ocir-publish'

command -v gh >/dev/null 2>&1 || {
  echo 'GitHub CLI (gh) is required.' >&2
  exit 1
}

gh api --method PUT "repos/${repository}/environments/${environment}" >/dev/null

cleanup() {
  stty echo 2>/dev/null || true
}
trap cleanup EXIT HUP INT TERM

printf 'OCIR registry endpoint [fra.ocir.io]: '
IFS= read -r ocir_registry
ocir_registry="${ocir_registry:-fra.ocir.io}"
printf '%s' "$ocir_registry" | gh variable set OCI_REGISTRY --env "$environment"
unset ocir_registry

printf 'OCI tenancy namespace (input hidden): '
stty -echo
IFS= read -r ocir_namespace
stty echo
printf '\n'
test -n "$ocir_namespace" || {
  echo 'Tenancy namespace cannot be empty.' >&2
  exit 1
}
printf '%s' "$ocir_namespace" | gh secret set OCI_TENANCY_NAMESPACE --env "$environment"
unset ocir_namespace

printf 'OCIR Docker username (input hidden): '
stty -echo
IFS= read -r ocir_username
stty echo
printf '\n'
test -n "$ocir_username" || {
  echo 'Username cannot be empty.' >&2
  exit 1
}
printf '%s' "$ocir_username" | gh secret set OCI_REGISTRY_USERNAME --env "$environment"
unset ocir_username

printf 'OCI auth token (input hidden): '
stty -echo
IFS= read -r ocir_auth_token
stty echo
printf '\n'
test -n "$ocir_auth_token" || {
  echo 'Auth token cannot be empty.' >&2
  exit 1
}
printf '%s' "$ocir_auth_token" | gh secret set OCI_REGISTRY_AUTH_TOKEN --env "$environment"
unset ocir_auth_token

echo "OCIR configuration stored in GitHub Environment: ${environment}"
