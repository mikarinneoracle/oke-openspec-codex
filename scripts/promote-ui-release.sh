#!/usr/bin/env bash

# Promote an immutable Todo UI release through GitOps.
#
# The script changes only the Git-managed Nginx bridge release pin. It never
# contacts OCI Object Storage or Kubernetes; after review, commit and push the
# resulting manifest change so Flux performs the rolling update.

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repository_root/platform/tenants/todo/application/todo-ui-bridge.yaml"
reset_manifest="$repository_root/platform/tenants/todo/demo-reset/todo-demo-reset.yaml"

if [[ ! -f "$manifest" ]]; then
  echo "Todo UI bridge manifest not found: $manifest" >&2
  exit 1
fi

if [[ ! -f "$reset_manifest" ]]; then
  echo "Todo demo reset manifest not found: $reset_manifest" >&2
  exit 1
fi

release_sha="${1:-}"
if [[ -z "$release_sha" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) is required when no release SHA is supplied." >&2
    echo "Usage: sh scripts/promote-ui-release.sh <successful-ui-build-git-sha>" >&2
    exit 1
  fi

  release_sha="$(
    cd "$repository_root"
    gh run list --workflow publish-todo-ui.yaml --status success --limit 1 \
      --json headSha --jq '.[0].headSha'
  )"

  if [[ -z "$release_sha" || "$release_sha" == "null" ]]; then
    echo "No successful Publish Todo UI workflow run was found." >&2
    exit 1
  fi

  echo "Latest successful UI release SHA: $release_sha"
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

release_reference_count="$(grep -Eo 'releases/[0-9a-f]{40}/bundle\.tar\.gz' "$manifest" | wc -l | tr -d ' ')"
if [[ "$release_reference_count" != "1" ]]; then
  echo "Expected exactly one pinned UI release in $manifest; found $release_reference_count." >&2
  exit 1
fi

current_release="$(grep -Eo 'releases/[0-9a-f]{40}/bundle\.tar\.gz' "$manifest")"
target_release="releases/$release_sha/bundle.tar.gz"
release_short_sha="${release_sha:0:8}"
reset_job_name_count="$(grep -Eo 'todo-demo-reset-[0-9a-f]{8}(-[0-9]+)?' "$reset_manifest" | wc -l | tr -d ' ')"
reset_version_count="$(grep -Eo 'app.kubernetes.io/version: "[0-9a-f]{40}"' "$reset_manifest" | wc -l | tr -d ' ')"

if [[ "$reset_job_name_count" != "1" || "$reset_version_count" != "1" ]]; then
  echo "Expected one release-specific demo reset Job name and version label." >&2
  exit 1
fi

if [[ "$current_release" == "$target_release" ]]; then
  echo "The bridge already uses $target_release."
  exit 0
fi

perl -0pi -e "s{\Q$current_release\E}{$target_release}" "$manifest"
perl -0pi -e "s{todo-demo-reset-[0-9a-f]{8}(?:-[0-9]+)?}{todo-demo-reset-$release_short_sha}" "$reset_manifest"
perl -0pi -e "s{app\.kubernetes\.io/version: \"[0-9a-f]{40}\"}{app.kubernetes.io/version: \"$release_sha\"}" "$reset_manifest"

echo "Promoted UI release reference:"
echo "  $current_release"
echo "  -> $target_release"
echo "Demo reset Job: todo-demo-reset-$release_short_sha"
echo
echo "Review the Git diff, then commit and push. Flux will roll out the bridge"
echo "and run the release-specific demo reset Job after the application is Ready."
