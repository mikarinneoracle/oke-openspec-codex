#!/usr/bin/env bash

# Promote an immutable Todo API image through GitOps.
#
# The script changes only Git-managed image pins and the release-specific demo
# reset Job. It never contacts OCI, Kubernetes, or Flux. Review, commit, and
# push the resulting manifest change so Flux performs the rollout.

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_manifest="$repository_root/platform/tenants/todo/application/todo-api.yaml"
reset_manifest="$repository_root/platform/tenants/todo/demo-reset/todo-demo-reset.yaml"
image_repository='fra.ocir.io/frsxwtjslf35/oke-openspec-codex/todo-api'

for manifest in "$api_manifest" "$reset_manifest"; do
  if [[ ! -f "$manifest" ]]; then
    echo "Required manifest not found: $manifest" >&2
    exit 1
  fi
done

release_sha="${1:-}"
if [[ -z "$release_sha" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) is required when no release SHA is supplied." >&2
    echo "Usage: sh scripts/promote-todo-api-release.sh <successful-api-build-git-sha>" >&2
    exit 1
  fi

  release_sha="$(
    cd "$repository_root"
    gh run list --workflow publish-todo-api.yaml --status success --limit 1 \
      --json headSha --jq '.[0].headSha'
  )"

  if [[ -z "$release_sha" || "$release_sha" == "null" ]]; then
    echo "No successful Publish Todo API workflow run was found." >&2
    exit 1
  fi

  echo "Latest successful API release SHA: $release_sha"
  read -r -p "Promote this release? [y/N] " confirmation
  if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
    echo "Promotion cancelled."
    exit 0
  fi
fi

if [[ ! "$release_sha" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Release SHA must be a 40-character lowercase Git SHA." >&2
  exit 1
fi

image_reference_count="$(grep -Eo "${image_repository}:[0-9a-f]{40}" "$api_manifest" | wc -l | tr -d ' ')"
reset_image_count="$(grep -Eo "${image_repository}:[0-9a-f]{40}" "$reset_manifest" | wc -l | tr -d ' ')"
reset_job_name_count="$(grep -Eo 'todo-demo-reset-[0-9a-f]{8}' "$reset_manifest" | wc -l | tr -d ' ')"
reset_version_count="$(grep -Eo 'app.kubernetes.io/version: "[0-9a-f]{40}"' "$reset_manifest" | wc -l | tr -d ' ')"

if [[ "$image_reference_count" != "2" || "$reset_image_count" != "1" || "$reset_job_name_count" != "1" || "$reset_version_count" != "1" ]]; then
  echo "Expected two API deployment image pins and one reset image, Job name, and version label." >&2
  exit 1
fi

target_image="$image_repository:$release_sha"
release_short_sha="${release_sha:0:8}"

perl -0pi -e "s{\Q$image_repository\E:[0-9a-f]{40}}{$target_image}g" "$api_manifest" "$reset_manifest"
perl -0pi -e "s{todo-demo-reset-[0-9a-f]{8}}{todo-demo-reset-$release_short_sha}" "$reset_manifest"
perl -0pi -e "s{app\.kubernetes\.io/version: \"[0-9a-f]{40}\"}{app.kubernetes.io/version: \"$release_sha\"}" "$reset_manifest"

echo "Promoted Todo API image: $target_image"
echo "Demo reset Job: todo-demo-reset-$release_short_sha"
echo
echo "Review the Git diff, then commit and push. Flux will roll out the API"
echo "and run the release-specific demo reset Job after the application is Ready."
