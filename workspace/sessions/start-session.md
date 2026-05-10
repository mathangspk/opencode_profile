# Start Session

## Goal

Start each work session from the latest operational and repository state across machines.

## Required steps

1. Pull the latest `opencode_profile` changes or run the session start script that performs the sync.
2. Run `install/start-session.ps1` on Windows or `install/start-session.sh` on macOS.
3. Read `projects/registry/now-working.md`.
4. Review the active project's latest handoff and decision notes.
5. Pull the active code repo before making changes.

## Stop conditions

Do not start implementation until these are resolved:

1. `team workspace` is behind remote.
2. Active project repo is behind remote.
3. Active project repo has unexpected dirty state.
4. Project home is missing for an active registry entry.
5. The current machine has no registered path for an active project.
6. The project path exists but is not a Git repo yet.
