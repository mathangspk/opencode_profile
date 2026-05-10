#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s <project-id>\n' "$0" >&2
  exit 1
fi

PROJECT_ID=$1
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
MACHINE_FILE="$ROOT/.opencode-machine.json"
ACTIVATION_DIR="$ROOT/projects/registry/activations"

[ -f "$MACHINE_FILE" ] || { printf 'Run ./install/init-machine.sh first.\n' >&2; exit 1; }

python3 - <<'PY' "$MACHINE_FILE" "$ACTIVATION_DIR" "$PROJECT_ID"
import json, sys
from pathlib import Path

machine_file, activation_dir, project_id = sys.argv[1:4]
machine = json.loads(Path(machine_file).read_text(encoding='utf-8'))
activation_path = Path(activation_dir) / f"{machine['machine_id']}.json"
if not activation_path.exists():
    raise SystemExit(0)

activation = json.loads(activation_path.read_text(encoding='utf-8'))
activation['projects'] = [project for project in activation.get('projects', []) if project.get('project_id') != project_id]
if not activation['projects']:
    activation_path.unlink()
else:
    activation_path.write_text(json.dumps(activation, indent=2) + '\n', encoding='utf-8')
PY

"$SCRIPT_DIR/refresh-activations-dashboard.sh"
printf 'Deactivated project manager for %s\n' "$PROJECT_ID"
