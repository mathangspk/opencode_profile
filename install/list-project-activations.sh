#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ACTIVATION_DIR="$ROOT/projects/registry/activations"

python3 - <<'PY' "$ACTIVATION_DIR"
import json, sys
from pathlib import Path

activation_dir = Path(sys.argv[1])
rows = []
for file in sorted(activation_dir.glob('*.json')):
    data = json.loads(file.read_text(encoding='utf-8'))
    for project in data.get('projects', []):
        rows.append((project.get('project_id', ''), data.get('machine_id', ''), data.get('machine_name', ''), project.get('status', ''), project.get('last_seen_at', '')))

if not rows:
    print('No active project-manager registrations found.')
    raise SystemExit(0)

for row in sorted(rows):
    print(' | '.join(row))

counts = {}
for project_id, machine_id, *_ in rows:
    counts.setdefault(project_id, set()).add(machine_id)
multi = {project_id: machines for project_id, machines in counts.items() if len(machines) > 1}
if multi:
    print('\nProjects active on multiple machines')
    for project_id in sorted(multi):
        print(f'- {project_id}: {len(multi[project_id])} machines')
PY
