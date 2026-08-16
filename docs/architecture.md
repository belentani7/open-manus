# Architecture

`local-agent` is a Windows-first operational wrapper around OpenManus running with local Ollama models.

## Layers

1. `Repo layer`
   - onboarding docs
   - repeatable PowerShell scripts
   - local config template
2. `Runtime layer`
   - Python virtual environment
   - upstream `OpenManus` source in `.\OpenManus`
   - optional MCP server mode
3. `Model layer`
   - Ollama local API on `http://localhost:11434/v1`
   - recommended default: `qwen2.5:7b`
   - fallback for lighter machines: `qwen2.5:3b`

## Folder map

- `docs/`: install, quickstart, troubleshooting, architecture, models, workflows, security
- `scripts/`: setup, health check, launchers, updater
- `config/`: ready-to-copy config templates
- `prompts/`: reusable system prompt baselines

## Operational flow

1. Run `scripts/check-system.ps1`
2. Run `scripts/setup-openmanus.ps1`
3. Pull model with `ollama pull qwen2.5:7b`
4. Start CLI, web UI, or MCP mode

## Design goals

- local-first
- Windows-friendly
- low-friction setup
- minimal manual editing
- easy handoff for non-technical operators
