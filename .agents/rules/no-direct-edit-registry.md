---
activation: always
---
Never directly edit `projects/registry/projects.json` in the chat interface.
If the user needs to add or update a project, instruct them to use the appropriate install script:

- New project: `install/new-project-home.ps1` or `install/new-project-home.sh`
- Archive: `install/archive-project.ps1`
- Delete: `install/delete-project.ps1`

This file is the source of truth for all scripts. Manual edits risk JSON syntax errors
that break all registry-dependent tooling.
