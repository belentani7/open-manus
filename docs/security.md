# Security

## Local-first baseline

- Use Ollama locally for local-agent workflows.
- Never store real API secrets in tracked files, browser assets, logs, or generated projects.
- Keep .env, config/config.toml, local configs, caches, logs, virtual environments, and the cloned OpenManus checkout untracked.
- Review the upstream source and requirements before installing them.
- New project scaffolding does not download code, install packages, expose ports, launch processes, or call external services.

## Safer operations

- Project writes are behind PowerShell ShouldProcess and support WhatIf.
- The generator refuses non-empty destinations and checks that the project path remains under Workspace.
- Setup only accepts a checkout whose origin is mannaandpoem/OpenManus.
- Existing OpenManus config is preserved. Dependency installation and pip upgrades are explicit when the virtual environment already exists.
- Updates refuse a dirty checkout and use git merge --ff-only rather than reset or forced checkout.

## Risk areas

- Initial setup downloads and installs upstream code and dependencies; inspect the upstream repository and requirements first.
- MCP mode can expose local tools to another client. Review its configuration and tool permissions before connecting it.
- Local-only does not mean risk-free: imported prompts, project files and model outputs can be untrusted.
