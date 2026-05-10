# Lifecycle Policy

## States

1. `planned`
   - Project exists in the workspace but execution has not started.
2. `active`
   - Project is currently being worked.
3. `paused`
   - Work is intentionally stopped but may resume.
4. `done`
   - Delivery work is complete and ready to leave the active set.
5. `archived`
   - Project is no longer active, but all operating history is preserved.
6. `deleted`
   - Project was invalid, duplicate, or sandbox-only and has been intentionally removed.

## Policy

1. Use `archive` for completed projects.
2. Use `delete` only for invalid, duplicate, or sandbox projects.
3. Never delete an active project.
4. Archive keeps the project home and history.
5. Delete removes the project home and registry entry after explicit confirmation.
