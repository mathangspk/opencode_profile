# Machine Activation Policy

## Goal

Track which machine is actively managing which project so cross-machine work is visible before conflicts appear.

## Rules

1. Each machine writes to its own activation file under `projects/registry/activations/`.
2. A project may be active on more than one machine, but this must be visible in the dashboard.
3. Deactivate a project when you no longer need active management on that machine.
4. Delete stale activation files only when the machine is no longer relevant.
