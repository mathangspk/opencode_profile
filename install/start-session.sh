#!/usr/bin/env sh
set -eu

MODE=quick
if [ "${1:-}" = "--mode" ]; then
  MODE=${2:-quick}
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
MACHINE_FILE="$ROOT/.opencode-machine.json"
REGISTRY_PATH="$ROOT/projects/registry/projects.json"
SYNC_PATH="$ROOT/projects/registry/machine-sync.md"
ROW_FILE=$(mktemp)

cleanup() {
  rm -f "$ROW_FILE"
}
trap cleanup EXIT INT TERM

if [ ! -f "$MACHINE_FILE" ]; then
  printf 'Missing machine identity file: %s\n' "$MACHINE_FILE" >&2
  printf 'Run ./install/init-machine.sh first.\n' >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  printf 'Required command is missing: git\n' >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf 'Required command is missing: python3\n' >&2
  exit 1
fi

git -C "$ROOT" fetch --all --prune >/dev/null 2>&1 || true
if [ -z "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ]; then
  git -C "$ROOT" pull --ff-only >/dev/null 2>&1 || true
fi

MACHINE_ID=$(python3 - <<'PY' "$MACHINE_FILE"
import json, sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
print(data['machine_id'])
PY
)

PLATFORM=$(python3 - <<'PY' "$MACHINE_FILE"
import json, sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
print(data['platform'])
PY
)

WORKSPACE_BRANCH=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'unknown')
WORKSPACE_DIRTY=clean
if [ -n "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ]; then
  WORKSPACE_DIRTY=dirty
fi

WORKSPACE_SYNC=unknown
if git -C "$ROOT" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  COUNTS=$(git -C "$ROOT" rev-list --left-right --count HEAD...@{u} 2>/dev/null || printf '0 0')
  BEHIND=$(printf '%s' "$COUNTS" | awk '{print $1}')
  AHEAD=$(printf '%s' "$COUNTS" | awk '{print $2}')
  if [ "$AHEAD" = "0" ] && [ "$BEHIND" = "0" ]; then
    WORKSPACE_SYNC=up-to-date
  elif [ "$AHEAD" != "0" ] && [ "$BEHIND" = "0" ]; then
    WORKSPACE_SYNC="ahead $AHEAD"
  elif [ "$AHEAD" = "0" ] && [ "$BEHIND" != "0" ]; then
    WORKSPACE_SYNC="behind $BEHIND"
  else
    WORKSPACE_SYNC="diverged +$AHEAD/-$BEHIND"
  fi
else
  WORKSPACE_SYNC=no-remote-tracking
fi

python3 - <<'PY' "$REGISTRY_PATH" "$MACHINE_ID" "$MODE" "$ROW_FILE"
import json, sys
from pathlib import Path

registry_path, machine_id, mode, row_file = sys.argv[1:5]
registry = json.loads(Path(registry_path).read_text(encoding='utf-8'))
projects = registry.get('projects', [])
if mode != 'full':
    projects = [p for p in projects if p.get('lifecycle_status') in ('active', 'paused')]

lines = []
for project in sorted(projects, key=lambda x: (x.get('domain', ''), x.get('name', ''))):
    machine_paths = project.get('machine_paths') or {}
    path = machine_paths.get(machine_id) or project.get('local_path', '')
    source = 'machine_paths' if machine_id in machine_paths else ('local_path' if project.get('local_path') else 'missing')
    fields = [project.get('name', ''), project.get('lifecycle_status', ''), path, source]
    lines.append('\t'.join(fields))

Path(row_file).write_text('\n'.join(lines) + ('\n' if lines else ''), encoding='utf-8')
PY

TMP_ROWS=""
ATTENTION=""
printf 'Team workspace session start\n'
printf -- '- Machine id: %s\n' "$MACHINE_ID"
printf -- '- Platform: %s\n' "$PLATFORM"
printf -- '- Scan mode: %s\n' "$MODE"
printf -- '- Workspace branch: %s\n' "$WORKSPACE_BRANCH"
printf -- '- Workspace dirty: %s\n' "$WORKSPACE_DIRTY"
printf -- '- Workspace sync: %s\n\n' "$WORKSPACE_SYNC"
printf 'Project freshness\n'
printf '%s\n' 'Project|Lifecycle|Status|Branch|Dirty|Sync|PathSource'

TAB=$(printf '\t')
while IFS="$TAB" read -r PROJECT LIFECYCLE PATH_VALUE PATH_SOURCE; do
  [ -z "$PROJECT" ] && continue
  BRANCH=
  DIRTY=missing
  SYNC=missing-machine-path
  STATUS=missing-machine-path
  ACTION='Add this machine path to projects.json before managing the repo on this machine.'

  if [ -n "$PATH_VALUE" ]; then
    if [ ! -e "$PATH_VALUE" ]; then
      STATUS=path-not-found
      SYNC=path-not-found
      ACTION='Create or fix the local path before working on this project.'
    elif [ ! -d "$PATH_VALUE/.git" ]; then
      STATUS=not-a-repo
      DIRTY=not-a-repo
      SYNC=not-a-repo
      ACTION='Clone or initialize the project repo before treating it as managed.'
    else
      git -C "$PATH_VALUE" fetch --all --prune >/dev/null 2>&1 || true
      BRANCH=$(git -C "$PATH_VALUE" rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'unknown')
      if [ -n "$(git -C "$PATH_VALUE" status --porcelain 2>/dev/null)" ]; then
        DIRTY=dirty
      else
        DIRTY=clean
      fi

      if git -C "$PATH_VALUE" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
        COUNTS=$(git -C "$PATH_VALUE" rev-list --left-right --count HEAD...@{u} 2>/dev/null || printf '0 0')
        BEHIND=$(printf '%s' "$COUNTS" | awk '{print $1}')
        AHEAD=$(printf '%s' "$COUNTS" | awk '{print $2}')
        if [ "$AHEAD" = "0" ] && [ "$BEHIND" = "0" ]; then
          SYNC=up-to-date
          STATUS=ready
          ACTION='No action required.'
          if [ "$DIRTY" = "dirty" ]; then
            STATUS=dirty
            ACTION='Review local changes before starting new work.'
          fi
        elif [ "$AHEAD" != "0" ] && [ "$BEHIND" = "0" ]; then
          SYNC="ahead $AHEAD"
          STATUS=ahead
          ACTION='Push or reconcile local commits when appropriate.'
        elif [ "$AHEAD" = "0" ] && [ "$BEHIND" != "0" ]; then
          SYNC="behind $BEHIND"
          STATUS=behind
          ACTION='Pull the latest changes before starting work.'
        else
          SYNC="diverged +$AHEAD/-$BEHIND"
          STATUS=diverged
          ACTION='Resolve branch divergence before starting work.'
        fi
      else
        SYNC=no-remote-tracking
        STATUS=no-remote-tracking
        ACTION='Add a tracked remote branch so freshness can be verified.'
      fi

      if [ "$DIRTY" = "dirty" ] && [ "$STATUS" = "behind" ]; then
        STATUS=dirty-and-behind
        ACTION='Review local changes, then pull the latest remote changes.'
      fi
    fi
  fi

  printf '%s|%s|%s|%s|%s|%s|%s\n' "$PROJECT" "$LIFECYCLE" "$STATUS" "$BRANCH" "$DIRTY" "$SYNC" "$PATH_SOURCE"
  TMP_ROWS="$TMP_ROWS$PROJECT	$LIFECYCLE	$STATUS	$BRANCH	$DIRTY	$SYNC	$PATH_SOURCE	$PATH_VALUE	$ACTION\n"

  case "$STATUS" in
    missing-machine-path|path-not-found|not-a-repo|no-remote-tracking|behind|dirty-and-behind|diverged)
      ATTENTION="$ATTENTION- $PROJECT: $ACTION\n"
      ;;
  esac
done < "$ROW_FILE"

if [ -n "$ATTENTION" ]; then
  printf '\nAttention required\n%b' "$ATTENTION"
fi

python3 - <<'PY' "$SYNC_PATH" "$MACHINE_ID" "$PLATFORM" "$MODE" "$WORKSPACE_BRANCH" "$WORKSPACE_DIRTY" "$WORKSPACE_SYNC" "$TMP_ROWS"
import sys
path, machine_id, platform, mode, branch, dirty, sync, rows_blob = sys.argv[1:9]
lines = [
    '# Machine Sync',
    '',
    'Generated by `install/start-session.sh`.',
    '',
    f'- Machine id: `{machine_id}`',
    f'- Platform: `{platform}`',
    f'- Scan mode: `{mode}`',
    f'- Team workspace branch: `{branch}`',
    f'- Team workspace dirty: `{dirty}`',
    f'- Team workspace sync: `{sync}`',
    '',
    '| Project | Lifecycle | Status | Branch | Dirty | Sync | Path Source | Path | Action |',
    '|---|---|---|---|---|---|---|---|---|',
]
for raw in rows_blob.splitlines():
    if not raw.strip():
        continue
    project, lifecycle, status, row_branch, row_dirty, row_sync, path_source, row_path, action = raw.split('\t')
    lines.append(f'| {project} | {lifecycle} | {status} | {row_branch} | {row_dirty} | {row_sync} | {path_source} | `{row_path}` | {action} |')
with open(path, 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(lines) + '\n')
PY
