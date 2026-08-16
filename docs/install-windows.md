# Instalacion de OpenManus en Windows 11

## Objetivo

Ejecutar OpenManus de forma local con Ollama, sin Docker y sin depender de claves API externas.

## Requisitos base

- Windows 11
- Python 3.11
- Git
- Ollama instalado y funcionando

## Paso 1. Instalar Python

Descarga Python 3.11 y asegurate de marcar la opcion para agregarlo al `PATH`.

Verificacion:

```powershell
python --version
```

## Paso 2. Instalar Git

Instala Git para poder clonar OpenManus y gestionar actualizaciones.

Verificacion:

```powershell
git --version
```

## Paso 3. Instalar Ollama

Instala Ollama para servir el modelo localmente.

Verificacion:

```powershell
ollama --version
```

## Paso 4. Descargar modelo

Modelo recomendado general:

```powershell
ollama pull qwen2.5:7b
```

Alternativa ligera:

```powershell
ollama pull qwen2.5:3b
```

## Paso 5. Clonar OpenManus

```powershell
git clone https://github.com/mannaandpoem/OpenManus.git
cd OpenManus
```

## Paso 6. Crear entorno virtual

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

## Paso 7. Instalar dependencias

```powershell
pip install -r requirements.txt
```

## Paso 8. Configurar conexion local con Ollama

En `config/config.toml` o archivo equivalente, usar:

```toml
base_url = "http://localhost:11434/v1"
model = "qwen2.5:7b"
api_key = "ollama"
```

## Paso 9. Ejecutar

CLI:

```powershell
python main.py
```

Web:

```powershell
python web_run.py
```

MCP:

```powershell
python run_mcp.py
```

## Notas

- `qwen2.5-coder` no es la opcion principal recomendada para este flujo general.
- Si tu equipo es justo de memoria, prioriza `qwen2.5:3b`.
