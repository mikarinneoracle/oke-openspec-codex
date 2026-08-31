## Summary

Describe the user-visible or platform change and why it is needed.

## Validation

- [ ] Relevant GitHub Actions checks passed.
- [ ] I described the tests performed and their outcome below.

<!-- List commands, browser checks, API checks, or other evidence. -->

## Todo UI checklist (complete when this PR changes the UI)

- [ ] I tested the PR branch locally with `npm ci`, `npm run lint`, and
  `npm run build` in `apps/todo-db-app`.
- [ ] I ran `npm run preview` and completed a browser smoke test.
- [ ] I described the visible UI change in the Summary.

## UI release promotion checklist (complete only for a promotion PR)

- [ ] This PR changes only the intended Git-SHA-pinned
  `UI_RELEASE_BUNDLE_URL` release reference.
- [ ] The referenced `Publish Todo UI` workflow completed successfully.
- [ ] I recorded the promoted release SHA and rollback SHA below.
- [ ] I understand that merging this PR lets Flux roll out the Nginx UI bridge.

Promoted SHA:

Rollback SHA:
