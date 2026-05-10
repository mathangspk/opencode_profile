# First Run

## Goal

Prepare a new machine so the team workspace can safely manage project freshness and activation state.

## Steps

1. Run `install/init-machine.ps1` on Windows or `install/init-machine.sh` on macOS.
2. Run `install/start-session.ps1 -Mode full` on Windows or `install/start-session.sh --mode full` on macOS.
3. Review warnings for projects that are missing a local path, missing a repo, or missing remote tracking.
4. Add the correct machine path or clone the missing repo before starting work.
