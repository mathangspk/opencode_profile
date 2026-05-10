#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ACTIVATION_DIR="$ROOT/projects/registry/activations"
DASHBOARD_PATH="$ROOT/projects/registry/activations.md"

mkdir -p "$ACTIVATION_DIR"

python3 - <<'PY' "$ACTIVATION_DIR" "$DASHBOARD_PATH"
import json, sys
from pathlib import Path

activation_dir = Path(sys.argv[1])
dashboard_path = Path(sys.argv[2])
records = []
for file in sorted(activation_dir.glob('*.json')):
    data = json.loads(file.read_text(encoding='utf-8'))
    for project in data.get('projects', []):
      records.append({
          'machine_id': data.get('machine_id', ''),
          'machine_name': data.get('machine_name', ''),
          'project_id': project.get('project_id', ''),
      })

lines = [
    '# Project Activations',
    '',
    'Generated from `projects/registry/activations/*.json`.',
    '',
]
if not records:
    lines.append('No active machine registrations yet.')
else:
    lines.extend(['## By project', ''])
    by_project = {}
    for record in records:
        by_project.setdefault(record['project_id'], []).append(record)
    for project_id in sorted(by_project):
        lines.append(f'- {project_id}')
        lines.append(f'  - active on {len(by_project[project_id])} machine(s)')
        for record in sorted(by_project[project_id], key=lambda item: item['machine_id']):
            lines.append(f'  - {record["machine_id"]}')
    lines.extend(['', '## By machine', ''])
    by_machine = {}
    for record in records:
        by_machine.setdefault(record['machine_id'], []).append(record)
    for machine_id in sorted(by_machine):
        lines.append(f'- {machine_id}')
        lines.append(f'  - machine name: {by_machine[machine_id][0]["machine_name"]}')
        for record in sorted(by_machine[machine_id], key=lambda item: item['project_id']):
            lines.append(f'  - {record["project_id"]}')

dashboard_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
PY
