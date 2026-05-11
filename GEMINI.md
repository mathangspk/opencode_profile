# opencode_profile — Antigravity Agent Context

This is the **central team workspace** for AI-assisted development. It is a Git repository
that manages all active projects across data, web, and IoT domains.

## Workspace layout

```
C:\local\opencode\
├── opencode.json                     ← Canonical OpenCode config (symlinked from all projects)
├── opencode_profile/                 ← THIS repo — team workspace (git)
│   ├── GEMINI.md                     ← Antigravity context (this file)
│   ├── .agents/                      ← Antigravity rules and skills
│   ├── .opencode/workflow.md         ← Canonical workflow (OpenCode + Antigravity share this)
│   └── projects/<domain>/<project>/  ← Per-project operating homes
├── data/
│   ├── analysic-data/
│   └── explore-CAN-message-motor-voltage/
└── iot/
    └── esp32_loss_power/
```

## Key files — always read before acting

| Purpose | Path |
|---|---|
| Project registry (source of truth) | `projects/registry/projects.json` |
| Active workset | `projects/registry/active.md` |
| Current session focus | `projects/registry/now-working.md` |
| Canonical workflow | `.opencode/workflow.md` |
| Machine identity | `.opencode-machine.json` |

## Active projects

| ID | Domain | Local path |
|---|---|---|
| `analysic-data` | data | `C:\local\opencode\data\analysic-data` |
| `explore-CAN-message-motor-voltage` | data | `C:\local\opencode\data\explore-CAN-message-motor-voltage` |
| `esp_loss_power` | iot | `C:\local\opencode\iot\esp32_loss_power` |
| `analysis` | ops | `C:\local\opencode\analysis` |

## Rules — always follow

1. Read `projects/<domain>/<project>/profile.md` before working on any specific project.
2. Never edit `projects/registry/projects.json` directly — always use `install/` scripts.
3. Weekly report day is **Friday**.
4. At the end of any session that changes project state, update `ops/handoff.md` for the relevant project.
5. Output language: **Vietnamese** for summaries and user-facing content, **English** for code, configs, and technical docs.

## OpenCode agent architecture (do not replicate in Antigravity)

OpenCode uses a multi-agent system (orchestrator → subagents). Antigravity is a single agent.
Do NOT try to simulate subagent delegation — instead, use Skills to load the right expertise for each task.

## Antigravity configuration

- Skills: `.agents/skills/` — loaded automatically when task matches description
- Rules: `.agents/rules/` — always-on behavioral constraints
- This file (`GEMINI.md`) — always loaded at conversation start
