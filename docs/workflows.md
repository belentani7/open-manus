# Workflows

## 1. Create a project-independent workspace

~~~powershell
.\scripts\New-Project.ps1 -ProjectName "NewIdea" -Template general -Workspace "$HOME\Projects" -WhatIf
.\scripts\New-Project.ps1 -ProjectName "NewIdea" -Template general -Workspace "$HOME\Projects"
~~~

Choose web, python or node when the product brief justifies that stack. The factory is separate from the OpenManus clone and does not install or start it.

## 2. First local-agent setup

~~~powershell
.\scripts\check-system.ps1
.\scripts\setup-openmanus.ps1
ollama pull qwen2.5:7b
.\scripts\start-cli.ps1
~~~

The first setup prepares a new virtual environment. Existing config is preserved; dependency reinstalls require InstallDependencies.

## 3. Web and MCP modes

~~~powershell
.\scripts\start-web.ps1
.\scripts\start-mcp.ps1
~~~

Review MCP permissions before connecting it to another agent.

## 4. Upstream refresh

Use scripts/update-openmanus.ps1 -WhatIf to preview. The updater refuses dirty worktrees and only fast-forwards. Install dependencies explicitly after reviewing the upstream manifest.

## 5. Tests and safe handoff

~~~powershell
python -m unittest discover -s tests -v
~~~

Keep .venv and local config out of commits. Record the selected model and upstream commit for handoff.
