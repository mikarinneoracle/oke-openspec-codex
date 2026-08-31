# Promote a Todo UI release

GitHub Actions publishes each successful UI build as a new immutable Object
Storage release at `releases/<git-sha>/`. Publishing does **not** change the
version served by the demo Nginx UI bridge. Promotion is a separate, reviewed
GitOps operation.

This separation is intentional: GitHub Actions has no Kubernetes credentials,
and Flux remains the only continuous Kubernetes writer.

## Preconditions

- The `Publish Todo UI` GitHub Actions run for the intended commit has
  completed successfully.
- The intended release SHA is known. It is the commit SHA shown in the Actions
  run summary and is used as the Object Storage release prefix.
- The repository is on `main` with the desired review and approval process.

## Promote the release

1. In
   `platform/tenants/todo/application/todo-ui-bridge.yaml`, change only the
   Git SHA in `UI_RELEASE_BUNDLE_URL` so that it refers to:

   ```text
   .../releases/<git-sha>/bundle.tar.gz
   ```

   Keep the configured Object Storage region, namespace, bucket, and public
   object URL structure unchanged.

2. Review the diff, commit the manifest change, and push it to `main`.

3. Flux detects the Deployment pod-template change and performs a rolling
   replacement of the Nginx UI bridge. The replacement init container downloads
   the pinned public archive and the Gateway API route continues serving `/`
   from the new release.

## Verify

Use only read-only cluster inspection after Flux has reconciled:

```sh
flux get kustomizations -n flux-system
kubectl get pods -n todo-app -l app.kubernetes.io/name=todo-ui-bridge
kubectl get deployment -n todo-app todo-ui-bridge
```

Confirm that the new bridge pod is Ready, then load the existing demo endpoint
in a browser. Do not use `kubectl apply`, `kubectl rollout`, or any direct
cluster mutation.

## Roll back

To roll back, change only `UI_RELEASE_BUNDLE_URL` back to a previously
published `releases/<git-sha>/bundle.tar.gz`, commit, and push. Because releases
are immutable, the earlier archive remains an exact rollback target.

## Direct Object Storage delivery later

When public DNS and TLS are available, the temporary Nginx bridge can be
removed. A browser can then load a versioned Object Storage URL directly, but
an explicit public entry point (for example a CDN route, a custom domain, or a
documented versioned URL) must select the active release. The API must use HTTPS
and allow scoped CORS from that UI origin.

## Optional future automation

An automation may open a pull request that changes the pinned release SHA after
a successful build. It must not update the cluster directly, run `kubectl`, or
bypass review; merging the PR remains the promotion event and Flux performs the
deployment.
