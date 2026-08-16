# Local Agent

OpenManus + Ollama en Windows 11, sin Docker y sin claves API.

Repositorio orientado a ejecucion local:

- CLI
- Web UI
- MCP
- Ollama local
- flujo Windows 11

## Que incluye

- guia rapida de arranque
- scripts PowerShell para preparar y lanzar OpenManus
- troubleshooting base
- material fuente en PDF y notas de chat

## Requisitos

- Windows 11
- Python 3.11 recomendado
- Git
- Ollama
- 8 GB RAM minimo
- 16 GB RAM recomendado para `qwen2.5:7b`

## Modelos recomendados

- `qwen2.5:3b` para equipos modestos
- `qwen2.5:7b` para mejor calidad general

## Estructura

```text
.
|-- README.md
|-- .gitignore
|-- docs/
|   |-- install-windows.md
|   |-- quickstart.md
|   `-- troubleshooting.md
|-- scripts/
|   |-- check-system.ps1
|   |-- setup-openmanus.ps1
|   |-- start-cli.ps1
|   |-- start-web.ps1
|   `-- start-mcp.ps1
|-- Guia_OpenManus_Windows11.pdf
|-- Guia_OpenManus_Windows11_SinDocker.pdf
|-- Guia_OpenManus_Windows11_SinDocker_final.pdf
`-- chat-OpenManus Ollama Windows Setup.txt
```

## Arranque rapido

1. Instala Python 3.11, Git y Ollama.
2. En Ollama descarga un modelo:

```powershell
ollama pull qwen2.5:7b
```

3. Clona OpenManus:

```powershell
git clone https://github.com/mannaandpoem/OpenManus.git
```

4. Ejecuta la preparacion:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-openmanus.ps1
```

5. Lanza el modo que necesites:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-cli.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\start-web.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\start-mcp.ps1
```

## Configuracion esperada

OpenManus debe apuntar a Ollama local:

```toml
base_url = "http://localhost:11434/v1"
model = "qwen2.5:7b"
api_key = "ollama"
```

## Documentacion

- [Instalacion Windows](docs/install-windows.md)
- [Quickstart](docs/quickstart.md)
- [Troubleshooting](docs/troubleshooting.md)

## Material fuente

Este repo conserva los PDFs y el transcript usados para construir la version publicada.

## Estado

Documentacion-first repo listo para publicar y extender.
