#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf 'Usage: %s <project-path> [--force]\n' "$0" >&2
  exit 1
fi

PROJECT_PATH=$1
FORCE=${2:-}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROFILE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SOURCE_ROOT="$PROFILE_ROOT/scaffolds/opencode-project"

if [ ! -d "$PROJECT_PATH" ]; then
  printf 'Project path does not exist: %s\n' "$PROJECT_PATH" >&2
  exit 1
fi

PROJECT_ROOT=$(CDPATH= cd -- "$PROJECT_PATH" && pwd)

for target in "$PROJECT_ROOT/opencode.json" "$PROJECT_ROOT/.opencode"; do
  if [ -e "$target" ] && [ "$FORCE" != "--force" ]; then
    printf 'Target already exists: %s. Re-run with --force to overwrite.\n' "$target" >&2
    exit 1
  fi
done

rm -rf "$PROJECT_ROOT/opencode.json" "$PROJECT_ROOT/.opencode"
cp "$SOURCE_ROOT/opencode.json" "$PROJECT_ROOT/opencode.json"
cp -R "$SOURCE_ROOT/.opencode" "$PROJECT_ROOT/.opencode"

printf 'Installed OpenCode project scaffold into %s\n' "$PROJECT_ROOT"
printf 'Next steps:\n'
printf '1. Run opencode and verify "orchestrator" is the default agent.\n'
printf '2. Add the team project ref and domain into .opencode/agents/orchestrator.md.\n'
printf '3. Fill your project home in opencode_profile/projects/.\n'
printf '4. Run the new-project checklist.\n'
