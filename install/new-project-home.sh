#!/usr/bin/env sh
set -eu

if [ "$#" -lt 2 ]; then
  printf 'Usage: %s <project-id> <domain> [local-path]\n' "$0" >&2
  exit 1
fi

PROJECT_ID=$1
DOMAIN=$2
LOCAL_PATH=${3:-}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TEMPLATE_ROOT="$ROOT/projects/_templates/project-home"
PROJECT_ROOT="$ROOT/projects/$DOMAIN/$PROJECT_ID"
REGISTRY_PATH="$ROOT/projects/registry/projects.json"
MACHINE_FILE="$ROOT/.opencode-machine.json"

[ -d "$PROJECT_ROOT" ] && { printf 'Project home already exists: %s\n' "$PROJECT_ROOT" >&2; exit 1; }
cp -R "$TEMPLATE_ROOT" "$PROJECT_ROOT"

python3 - <<'PY' "$PROJECT_ROOT/profile.md" "$PROJECT_ID" "$DOMAIN" "$LOCAL_PATH"
from pathlib import Path
import sys

profile_path, project_id, domain, local_path = sys.argv[1:5]
text = Path(profile_path).read_text(encoding='utf-8')
text = text.replace('- Project name:', f'- Project name: {project_id}')
text = text.replace('- Domain: `data` | `web` | `iot`', f'- Domain: `{domain}`')
text = text.replace('- Local path:', f'- Local path: `{local_path}`')
text = text.replace('- Team project ref:', f'- Team project ref: `projects/{domain}/{project_id}`')
text = text.replace('- QA mode: `data` | `web` | `iot`', f'- QA mode: `{domain}`')
Path(profile_path).write_text(text, encoding='utf-8')
PY

python3 - <<'PY' "$PROJECT_ROOT/reporting/config.json" "$PROJECT_ID" "$DOMAIN" "$LOCAL_PATH"
import json, sys
from pathlib import Path

config_path, project_id, domain, local_path = sys.argv[1:5]
data = json.loads(Path(config_path).read_text(encoding='utf-8'))
data['project']['name'] = project_id
data['project']['domain'] = domain
data['sources']['local_path'] = local_path
Path(config_path).write_text(json.dumps(data, indent=2) + '\n', encoding='utf-8')
PY

python3 - <<'PY' "$REGISTRY_PATH" "$MACHINE_FILE" "$PROJECT_ID" "$DOMAIN" "$LOCAL_PATH"
import json, sys
from pathlib import Path

registry_path, machine_file, project_id, domain, local_path = sys.argv[1:6]
registry = json.loads(Path(registry_path).read_text(encoding='utf-8'))
machine_paths = {}
if Path(machine_file).exists():
    machine = json.loads(Path(machine_file).read_text(encoding='utf-8'))
    if local_path:
        machine_paths[machine['machine_id']] = local_path

registry['projects'].append({
    'id': project_id,
    'name': project_id,
    'domain': domain,
    'lifecycle_status': 'planned',
    'execution_status': 'not-started',
    'priority': 'medium',
    'phase': 'discovery',
    'report_day': 'Friday',
    'approval_sensitivity': 'medium',
    'qa_mode': domain,
    'project_home': f'projects/{domain}/{project_id}',
    'repo_url': '',
    'repo_required': True,
    'machine_paths': machine_paths,
    'local_path': local_path,
    'default_branch': 'main',
    'jira_epic_key': '',
    'jira_epic_url': '',
    'notion_page_link': '',
    'notion_page_id': '',
    'current_focus': '',
    'last_team_sync': '',
    'last_repo_sync': '',
    'last_handoff': '',
    'last_report_draft': '',
    'last_report_published': '',
    'delete_reason': '',
})
Path(registry_path).write_text(json.dumps(registry, indent=2) + '\n', encoding='utf-8')
PY

"$SCRIPT_DIR/refresh-registry-dashboard.sh"
printf 'Created project home: %s\n' "$PROJECT_ROOT"
