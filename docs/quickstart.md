# Quickstart

## Flujo corto

1. Instala Python 3.11, Git y Ollama.
2. Descarga `qwen2.5:7b` o `qwen2.5:3b`.
3. Clona OpenManus.
4. Ejecuta `scripts/check-system.ps1`.
5. Ejecuta `scripts/setup-openmanus.ps1`.
6. Inicia CLI, Web o MCP.

## Comandos

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-system.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\setup-openmanus.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\start-cli.ps1
```

## Modos

### CLI

Uso simple y directo:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-cli.ps1
```

### Web UI

Interfaz web local:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-web.ps1
```

### MCP

Integracion para flujos agenticos:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-mcp.ps1
```
