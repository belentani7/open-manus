# Workflows

## 1. First local setup

```powershell
.\scripts\check-system.ps1
.\scripts\setup-openmanus.ps1
ollama pull qwen2.5:7b
.\scripts\start-cli.ps1
```

## 2. Web mode

```powershell
.\scripts\start-web.ps1
```

Use this when the operator prefers browser interaction instead of terminal chat.

## 3. MCP mode

```powershell
.\scripts\start-mcp.ps1
```

Use this when integrating OpenManus capabilities with tool-driven environments.

## 4. Upstream refresh

```powershell
.\scripts\update-openmanus.ps1
```

Use this after the initial install to refresh the embedded upstream clone.

## 5. Safe handoff

- keep `.venv` local
- keep personal secrets out of repo files
- copy `config/config.template.toml` into upstream config when needed
- document chosen model before handoff
