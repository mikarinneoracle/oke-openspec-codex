# Increase Todo header size

## Why

The primary `To-do list` heading should have slightly stronger visual hierarchy
in the Todo UI.

## What changes

- Render the existing semantic page heading with Material UI's `h4` typography
  variant instead of `h5`.

## Impact

Only the visible heading size changes. Task behaviour, routes, API calls, and
deployment configuration remain unchanged.
