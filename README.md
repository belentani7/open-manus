# Local Agent Workbench

Entorno de trabajo local para OpenManus con Ollama en Windows 11, más un generador reutilizable de proyectos independientes.

## Qué incluye

- scripts de preparación y lanzamiento de OpenManus en CLI, web y MCP
- comprobación de Python, Git y disponibilidad real del servicio Ollama
- generador local de proyectos generales, web, Python o Node
- reglas de Cursor y AGENTS.md incluidos en cada proyecto nuevo
- pruebas automatizadas de PowerShell y de no sobrescritura

## Crear cualquier proyecto

La fábrica no está acoplada a Bellacore ni a ningún producto. Previsualiza primero:

~~~powershell
.\scripts\New-Project.ps1 -ProjectName "TetrisAI" -Template web -Workspace "$HOME\Projects" -WhatIf
~~~

Crea el proyecto:

~~~powershell
.\scripts\New-Project.ps1 -ProjectName "TetrisAI" -Template web -Workspace "$HOME\Projects"
~~~

Plantillas disponibles: general, web, python y node. El destino debe estar ausente o vacío. La fábrica no instala dependencias, no hace llamadas de red, no abre puertos y no inicia la aplicación. Añade -InitializeGit para crear el repositorio local. Las escrituras admiten -WhatIf.

La definición, los límites, las pruebas y las reglas generadas se describen en docs/universal-project-factory.md.

## Preparar OpenManus

Requisitos para el agente local: Windows 11, Python 3.11+, Git y Ollama instalado con el servicio local iniciado. La fábrica de proyectos solo requiere PowerShell.

~~~powershell
.\scripts\check-system.ps1
.\scripts\setup-openmanus.ps1
ollama pull qwen2.5:7b
.\scripts\start-cli.ps1
~~~

La primera preparación crea el entorno virtual e instala el archivo requirements del upstream. Repetir el comando conserva el entorno y la configuración existentes; usa -InstallDependencies para reinstalar dependencias y -UpgradePip para actualizar pip. El script no sobrescribe config/config.toml si ya existe.

Usa los lanzadores cuando necesites otra interfaz:

~~~powershell
.\scripts\start-web.ps1
.\scripts\start-mcp.ps1
~~~

Para actualizar el checkout local, primero confirma que no tenga cambios sin guardar. update-openmanus.ps1 solo acepta avance rápido; no usa reset ni reescribe historial. Reinstalar dependencias y actualizar pip requieren opciones explícitas.

## Verificación

En Windows con Python 3.12 y PowerShell:

~~~powershell
python -m unittest discover -s tests -v
~~~

La CI de GitHub ejecuta estas pruebas en cada push a main y cada Pull Request.

## Seguridad y límites

- La fábrica crea archivos únicamente en el Workspace elegido y rechaza destinos no vacíos.
- OpenManus y Ollama se ejecutan localmente; los modelos y dependencias se descargan solo durante una instalación solicitada.
- Los archivos de configuración local, claves y entornos virtuales no se versionan.
- Este repositorio no afirma que una instalación, despliegue o servicio esté activo hasta comprobarlo.

Consulta docs/security.md, docs/architecture.md, docs/workflows.md, docs/official-tooling-guidance-2026-10-31.md y docs/qwen-export-review.md.
