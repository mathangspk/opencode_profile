#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
REGISTRY_DIR="$ROOT/projects/registry"
REGISTRY_PATH="$REGISTRY_DIR/projects.json"

python3 - <<'PY' "$REGISTRY_PATH" "$REGISTRY_DIR"
import json, sys
from pathlib import Path

registry_path = Path(sys.argv[1])
registry_dir = Path(sys.argv[2])
registry = json.loads(registry_path.read_text(encoding='utf-8'))
projects = sorted(registry.get('projects', []), key=lambda x: (x.get('domain', ''), x.get('name', '')))

def fmt(value, default='TBD'):
    return value if value else default

index_lines = [
    '# Projects Index',
    '',
    'Generated from `projects/registry/projects.json`.',
    '',
    '| Project | Domain | Lifecycle | Execution | Phase | Report Day | Jira Epic | Approval | Project Home | Repo | Local Path | Last Handoff |',
    '|---|---|---|---|---|---|---|---|---|---|---|---|',
]
for project in projects:
    index_lines.append(
        f"| {project.get('name','')} | {project.get('domain','')} | {project.get('lifecycle_status','')} | {fmt(project.get('execution_status',''), '')} | {fmt(project.get('phase',''), '')} | {fmt(project.get('report_day',''), '')} | {fmt(project.get('jira_epic_key',''))} | {fmt(project.get('approval_sensitivity',''), '')} | `{project.get('project_home','')}` | {fmt(project.get('repo_url',''), '')} | `{project.get('local_path','')}` | {fmt(project.get('last_handoff',''), '')} |"
    )
(registry_dir / 'projects-index.md').write_text('\n'.join(index_lines) + '\n', encoding='utf-8')

active = [p for p in projects if p.get('lifecycle_status') in ('active', 'paused')]
active_lines = ['# Active Projects', '', 'Generated from `projects/registry/projects.json`.', '', '## Active and paused workset', '']
if not active:
    active_lines.append('No active or paused projects.')
else:
    for idx, project in enumerate(active, start=1):
        active_lines.extend([
            f'{idx}. {project.get("name","")}',
            f'   - Lifecycle: `{project.get("lifecycle_status","")}`',
            f'   - Jira Epic: `{fmt(project.get("jira_epic_key",""))}`',
            f'   - Notion page: `{fmt(project.get("notion_page_link",""))}`',
            f'   - Phase: `{fmt(project.get("phase",""), "")}`',
            f'   - Approval sensitivity: `{fmt(project.get("approval_sensitivity",""), "")}`',
            f'   - QA mode: `{fmt(project.get("qa_mode",""), "")}`',
            f'   - Current focus: {fmt(project.get("current_focus",""), "")}',
        ])
(registry_dir / 'active.md').write_text('\n'.join(active_lines) + '\n', encoding='utf-8')

archived = [p for p in projects if p.get('lifecycle_status') == 'archived']
archived_lines = ['# Archived Projects', '', 'Generated from `projects/registry/projects.json`.', '']
if not archived:
    archived_lines.append('No archived projects.')
else:
    for project in archived:
        archived_lines.extend([
            f'- {project.get("name","")}',
            f'  - Project home: `{project.get("project_home","")}`',
            f'  - Last published: `{fmt(project.get("last_report_published",""), "")}`',
        ])
(registry_dir / 'archived.md').write_text('\n'.join(archived_lines) + '\n', encoding='utf-8')

report_lines = ['# Report Due', '', 'Generated from `projects/registry/projects.json`.', '', '## Weekly cadence', '']
report_projects = [p for p in projects if p.get('lifecycle_status') == 'active']
if not report_projects:
    report_lines.append('No active projects.')
else:
    for project in sorted(report_projects, key=lambda x: (x.get('report_day', ''), x.get('name', ''))):
        report_lines.append(f"- {fmt(project.get('report_day','Friday'), 'Friday')}: {project.get('name','')}")
(registry_dir / 'report-due.md').write_text('\n'.join(report_lines) + '\n', encoding='utf-8')
PY
