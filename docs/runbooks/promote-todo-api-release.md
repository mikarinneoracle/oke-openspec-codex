# Promote a Todo API release

GitHub Actions builds and publishes every successful API source commit as an
immutable OCIR image tagged with its full Git SHA. Publishing the image does
not change the running API: promotion is a separate, reviewed GitOps change.

This separation keeps GitHub Actions free of Kubernetes credentials. Flux is
the only cluster writer and deploys the reviewed image pin from `main`.

## Promote

From the repository root, run:

```sh
sh scripts/promote-todo-api-release.sh
```

The script finds the latest successful `Publish Todo API` workflow, requests
confirmation, and changes only these Git-managed values:

- the pinned API image in the migration init container and API container;
- the image of the demo reset Job;
- the reset Job's release-specific name and version label.

To promote a particular known-good build, pass its full SHA:

```sh
sh scripts/promote-todo-api-release.sh <git-sha>
```

Review the resulting diff, commit it, and push it to `main`. Flux detects the
new pod template, replaces the API pods with the pinned OCIR image, waits for
the application Kustomization to be Ready, and then runs the one-shot
`todo-demo-reset-<short-sha>` Job. That demo-only Job deliberately deletes all
Todo rows and inserts the deterministic 1,000-row dataset.

If a reset Job itself needs a corrected rerun, its name receives a numeric
suffix (for example `todo-demo-reset-<short-sha>-2`). This is a new,
reviewable Job while keeping the same promoted image pin; completed and failed
Jobs are never restarted in place.

The script does not commit, push, contact OCI, or use Kubernetes credentials.

## Verify

After Flux has reconciled, use read-only inspection:

```sh
flux get kustomizations -n flux-system
kubectl get deployment,pods -n todo-app -l app.kubernetes.io/name=todo-api
kubectl get jobs -n todo-app -l app.kubernetes.io/component=demo-data-reset
```

Confirm that `todo-application` and `todo-demo-reset` are Ready, the new API
pods are Ready, and the release-specific reset Job is `Completed`. Then refresh
the browser UI and confirm that all 1,000 demo tasks are present again.

Do not use direct `kubectl` mutation; Flux reconciles the reviewed Git change.
