# Handoff — Workspace Standardization

## Session handoff — 2026-05-20
Machine: WIN-HYPERV-1

### Completed
- Switched canonical OpenCode model routing to `opencode/qwen3.6-plus-free` for orchestrator and all specialist agents.
- Removed remaining `hy3-preview` references from active workspace configs, templates, project profiles, scaffold config, and workflow docs.
- Updated `orchestrator.md` to treat `.xml` and CODESYS/PLC project files as source code that must be delegated to subagents.
- Simplified `orchestrator.md` frontmatter so permissions/models are sourced from `opencode.json` only.
- Added and scaffolded the new managed project `codesys-apollo` under `projects/iot/codesys-apollo`.

### Current state
- Branch: `main`
- Last verified: canonical `opencode.json`, scaffold `opencode.json`, and `codesys/opencode.json` all point every configured agent to `opencode/qwen3.6-plus-free`; `hy3-preview` remains only in this handoff history.
- Known issues: Desktop App / sidecar may still need a full restart before new model/delegation settings are reflected live.

### Exact next step
Fully restart OpenCode Desktop App (and any `opencode-cli.exe` sidecar), then start a fresh session in `codesys` and verify that XML/CODESYS file review is delegated to a subagent.

### Context for next session
The canonical config is `C:\local\opencode\opencode.json`. Most project `opencode.json` files are symlinked to it; `C:\local\opencode\codesys\opencode.json` is a scaffold copy that was updated separately. `docs/handoff.md` keeps historical references to old models on purpose; active configs/docs now use `opencode/qwen3.6-plus-free`.

## What was done

### Workspace layout restructuring
- Established workspace convention: `{workspace_root}/opencode_profile/` + `{workspace_root}/<domain>/<project>/`
- Created domain directories: `data/`, `iot/`, `web/` under workspace root
- Moved `opencode_profile/` out of `analysis/` to workspace root
- Moved `esp32_loss_power/` → `iot/esp32_loss_power/`
- Moved `analysic-data/` → `data/analysic-data/`
- Moved `explore-CAN-message-motor-voltage/` → `data/explore-CAN-message-motor-voltage/`
- Updated `.opencode-machine.json` with `workspace_root`
- Updated `projects.json` machine paths for WIN-HYPERV-1

### Configuration centralization
- Created canonical `opencode.json` at `C:\local\opencode\opencode.json`
- All project `opencode.json` replaced with symlinks to canonical file
- Model set to `openrouter/tencent/hy3-preview` (gpt-5.4 not working)

- Removed plugin `@razroo/opencode-model-fallback` from all configs
- Removed `fallback_models` from YAML frontmatter in all agent .md files (25 files)
- Removed `model` from YAML frontmatter in all agent .md files (25 files) — model now comes from canonical JSON only
- Fixed malformed YAML indentation in esp32 orchestrator.md

### Workflow extraction
- Extracted team workflow from orchestrator.md into `opencode_profile/.opencode/workflow.md`
- All orchestrators (opencode_profile + 4 projects) are now thin coordinators referencing workflow.md
- Removed duplicate workflow code from opencode_profile orchestrator.md (reduced from 152 lines to ~50)
- Updated scaffold template to follow same pattern

### Analysis project setup
- Created `.opencode/agents/orchestrator.md` for `analysis/` project
- Symlinked `opencode.json` to canonical
- Registered in `projects.json` as domain `ops`
- Team workflow reference: `../opencode_profile/.opencode/workflow.md`

## Architecture

```
C:\local\opencode\
├── opencode.json                          ← CANONICAL config (symlinked)
├── opencode_profile/                      ← team workspace (git repo)
│   ├── .opencode/workflow.md              ← CANONICAL workflow (single source of truth)
│   └── .opencode/agents/orchestrator.md   ← thin coordinator → ref workflow.md
├── analysis/                              ← ops project (symlink + coordinator)
├── data/
│   ├── analysic-data/                     ← symlink + coordinator → ref workflow.md
│   └── explore-CAN-message-motor-voltage/ ← symlink + coordinator → ref workflow.md
└── iot/
    └── esp32_loss_power/                  ← symlink + coordinator → ref workflow.md
```

## Design decisions

1. **Symlinks for opencode.json** — single source of truth for model/agent config. One change propagates everywhere.
2. **No plugin for fallback** — `fallback_models` is supported natively in opencode v1.4.1, no plugin needed.
3. **YAML frontmatter stripped of model** — model control centralized in JSON. YAML only has permission overrides.
4. **Workflow extracted to separate file** — workflow.md is referenced by all orchestrators, not inlined.
5. **All orchestrators are coordinator-only** — no agent implements or executes directly.

## Next steps / known issues

- gpt-5.4 not working → switched to openrouter/tencent/hy3-preview
- Symlinks require admin on Windows (Developer Mode off)
- Remaining model routing docs in workflow.md reference gpt models not configured in this workspace
- Consider registering `analysis/` project properly with a profile.md

## Commands to run after handoff

Start new session from any project:
```
cd C:\local\opencode\analysis
opencode
```
