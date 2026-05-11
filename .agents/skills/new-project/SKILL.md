---
name: new-project
description: Create a new project home in the workspace. Triggered by "new project", "create project", "thêm dự án mới", or "add project".
---

# New Project Skill

## Purpose
Guide the user through creating a new project home correctly without skipping steps.

## Steps

### 1. Gather required information
Ask the user for:
- Project ID (lowercase, hyphenated, e.g., `my-new-project`)
- Domain: `data`, `web`, `iot`, or `ops`
- Local path on this machine
- Brief description of the project goal

### 2. Check for conflicts
Read `projects/registry/projects.json` — confirm the project ID does not already exist.

### 3. Instruct the user to run the install script

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\install\new-project-home.ps1 `
  -ProjectId "<id>" `
  -Domain <domain> `
  -LocalPath "<local-path>"
```

**macOS/Linux:**
```bash
./install/new-project-home.sh <id> <domain> <local-path>
```

### 4. After script runs, complete setup
Tell the user to:
1. Fill in `projects/<domain>/<project>/profile.md` with project details
2. Add Jira Epic key and Notion page link when available
3. Copy OpenCode scaffold if this is a code project:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install\install-project-scaffold.ps1 -ProjectPath "<local-path>"
   ```
4. Add machine path for other machines when they are set up

### 5. Confirm
After setup is complete, run `project-status` skill to confirm the project appears in the registry.
