# Sync Policy

## Goal

Avoid drift between machines by making freshness checks part of every work session.

## Required checks

1. `opencode_profile` must not be behind remote before editing operational state.
2. Active code repos must not be behind remote before implementation starts.
3. Dirty worktrees must be reviewed before new work begins.
4. Diverged branches must be resolved before reporting the project as current.

## Source of truth

1. `projects/registry/projects.json` is the machine-readable control plane.
2. `projects/<domain>/<project>/` is the human-readable operating home.
3. Code repositories remain the source of truth for implementation.
