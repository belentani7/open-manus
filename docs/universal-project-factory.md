# Fábrica local y agnóstica de proyectos

## Propósito

scripts/New-Project.ps1 produce un esqueleto independiente para una idea nueva, sin asumir que todo proyecto sea Bellacore, OpenManus, una aplicación web o un producto de extracción de datos.

## Uso

~~~powershell
.\scripts\New-Project.ps1 -ProjectName "IdeaNueva" -Template general -Workspace "$HOME\Projects" -WhatIf
.\scripts\New-Project.ps1 -ProjectName "IdeaNueva" -Template web -Workspace "$HOME\Projects"
.\scripts\New-Project.ps1 -ProjectName "IdeaNueva" -Template python -Workspace "$HOME\Projects" -InitializeGit
~~~

Plantillas: general, web, python y node. El nombre queda limitado a letras ASCII, números, punto, guion y guion bajo; el path final debe mantenerse dentro de Workspace.

## Garantías de la herramienta

- Se niega a escribir sobre una carpeta no vacía.
- WhatIf muestra la acción prevista y no crea Workspace ni proyecto.
- InitializeGit es opcional y solo ejecuta Git local después de crear archivos.
- No descarga fuentes, instala dependencias, genera claves, inicia servicios, lanza procesos ni abre el navegador.
- Cada scaffold contiene brief de proyecto, AGENTS.md, .cursor/rules/project.mdc, .editorconfig, .gitignore y project.json.
- La plantilla web incluye estructura semántica, navegación por teclado, foco visible, diseño adaptable y movimiento reducido. No enlaza CDNs.

## Límites

El scaffold no determina si la idea tiene demanda, no implementa un producto de producción, no infiere cumplimiento legal y no crea infraestructura remota. Esas decisiones se documentan en el brief antes de implementar.

## Verificación

La suite tests/test_new_project.py crea proyectos temporales en el runner Windows, comprueba las rutas y valida el comportamiento de no sobrescritura y WhatIf.
