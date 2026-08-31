#!/usr/bin/env sh
# Store OCIR Docker credentials as GitHub Environment secrets without exposing
# either value in the command line, source tree, or shell history.
set -eu

repository='mikarinneoracle/oke-openspec-codex'
environment='ocir-publish'

command -v gh >/dev/null 2>&1 || {
  echo 'GitHub CLI (gh) is required.' >&2
  exit 1
}

gh api --method PUT "repos/${repository}/environments/${environment}" >/dev/null

printf 'OCIR Docker username: '
IFS= read -r ocir_username
test -n "$ocir_username" || {
  echo 'Username cannot be empty.' >&2
  exit 1
}
printf '%s' "$ocir_username" | gh secret set OCI_REGISTRY_USERNAME --env "$environment"
unset ocir_username

cleanup() {
  stty echo 2>/dev/null || true
}
trap cleanup EXIT HUP INT TERM

printf 'OCI auth token: '
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
trap - EXIT HUP INT TERM

echo "OCIR secrets stored in GitHub Environment: ${environment}"
