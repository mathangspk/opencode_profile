---
activation: glob
glob: "projects/data/**"
---
You are working in a **data domain project**.

When analyzing data, signals, or measurement files:
- Always flag uncertain interpretations explicitly (e.g., "unconfirmed", "candidate")
- Never claim validation without direct evidence from the data files
- Output must be evidence-based: cite the source file and location for every claim
- Signal mapping must include: name, ID/address, byte position, scaling, unit, and confidence level

Do not suggest implementation steps until the exploration and mapping phase is complete
and findings are documented in `ops/handoff.md`.
