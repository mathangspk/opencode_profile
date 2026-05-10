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
REGISTRY_PATH="$ROOT/projects/registry/projects.json"
ACTIVATION_DIR="$ROOT/projects/registry/activations"

[ -f "$MACHINE_FILE" ] || { printf 'Run ./install/init-machine.sh first.\n' >&2; exit 1; }
mkdir -p "$ACTIVATION_DIR"

python3 - <<'PY' "$MACHINE_FILE" "$REGISTRY_PATH" "$ACTIVATION_DIR" "$PROJECT_ID"
import json, sys, datetime
from pathlib import Path

machine_file, registry_path, activation_dir, project_id = sys.argv[1:5]
machine = json.loads(Path(machine_file).read_text(encoding='utf-8'))
registry = json.loads(Path(registry_path).read_text(encoding='utf-8'))
if not any(project.get('id') == project_id for project in registry.get('projects', [])):
    raise SystemExit(f'Project not found: {project_id}')

activation_path = Path(activation_dir) / f"{machine['machine_id']}.json"
now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'
if activation_path.exists():
    activation = json.loads(activation_path.read_text(encoding='utf-8'))
else:
    activation = {
        'machine_id': machine['machine_id'],
        'machine_name': machine['machine_name'],
        'platform': machine['platform'],
        'updated_at': now,
        'projects': [],
    }

for project in activation['projects']:
    if project.get('project_id') == project_id:
        project['last_seen_at'] = now
        project['status'] = 'active'
        break
else:
    activation['projects'].append({
        'project_id': project_id,
        'activated_at': now,
        'last_seen_at': now,
        'status': 'active',
    })

activation['updated_at'] = now
activation_path.write_text(json.dumps(activation, indent=2) + '\n', encoding='utf-8')
PY

"$SCRIPT_DIR/refresh-activations-dashboard.sh"
printf 'Activated project manager for %s\n' "$PROJECT_ID"
