#!/usr/bin/env sh
# Store a Kubernetes dockerconfigjson for the private Todo API image in the
# existing OCI Vault. The token is read only from the terminal and is never
# written to Git, shell history, or command output.
set -eu

compartment_id='ocid1.compartment.oc1..aaaaaaaawccfklp2wj4c5ymigrkjfdhcbcm3u5ripl2whnznhmvgiqdatqgq'
vault_id='ocid1.vault.oc1.eu-frankfurt-1.cbrcv4plaahh4.abtheljrz3llvhibeprbk3pp5si7vznjxvmplux3xly5rgipubkvhgvav34a'
key_id='ocid1.key.oc1.eu-frankfurt-1.cbrcv4plaahh4.abtheljrkwzqpqwltve34cn33yz7226wrcsbh2v65tzojmygi7uej6wqnmbq'
registry='fra.ocir.io'
secret_name='oke-openspec-codex-todo-ocir-pull'

command -v oci >/dev/null 2>&1 || { echo 'OCI CLI (oci) is required.' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo 'jq is required.' >&2; exit 1; }

printf 'OCIR username: '
IFS= read -r username
test -n "$username" || { echo 'Username cannot be empty.' >&2; exit 1; }

printf 'OCIR auth token (input hidden): '
stty -echo
IFS= read -r token
stty echo
printf '\n'
test -n "$token" || { echo 'Token cannot be empty.' >&2; exit 1; }

docker_config="$(jq -cn --arg registry "$registry" --arg username "$username" --arg password "$token" '{auths: {($registry): {username: $username, password: $password, auth: (($username + ":" + $password) | @base64)}}}')"
secret_content="$(printf '%s' "$docker_config" | base64 | tr -d '\n')"
secret_id="$(oci vault secret list --compartment-id "$compartment_id" --vault-id "$vault_id" --all --query "data[?\"secret-name\"=='${secret_name}' && \"lifecycle-state\"=='ACTIVE'] | [0].id" --raw-output)"

if test "$secret_id" = 'null' || test -z "$secret_id"; then
  oci vault secret create-base64 \
    --compartment-id "$compartment_id" \
    --vault-id "$vault_id" \
    --key-id "$key_id" \
    --secret-name "$secret_name" \
    --description 'OCI Docker configuration for Todo API image pulls' \
    --secret-content-content "$secret_content" \
    --wait-for-state ACTIVE \
    --wait-interval-seconds 5 \
    --max-wait-seconds 120 >/dev/null
  echo 'Created the OCIR pull secret in OCI Vault.'
else
  oci vault secret update-base64 \
    --secret-id "$secret_id" \
    --secret-content-content "$secret_content" \
    --force >/dev/null
  echo 'Updated the OCIR pull secret in OCI Vault.'
fi

unset username token docker_config secret_content secret_id
