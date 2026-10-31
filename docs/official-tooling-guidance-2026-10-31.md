# Guía oficial aplicada a local-agent

Revisión por repositorio: local-agent/open-manus. Fecha: 2026-10-31.

## Cursor

Cursor documenta reglas de proyecto versionadas en .cursor/rules y el formato MDC con descripción, globs y alwaysApply. Se añadió .cursor/rules/local-agent.mdc para distinguir el runtime OpenManus del generador universal. Cada scaffold emite su propia regla de proyecto. No se convierte un chat exportado en instrucciones implícitas fuera de esos límites.

Referencia: https://docs.cursor.com/context/rules-for-ai

## GitHub Actions

GitHub recomienda permisos mínimos de GITHUB_TOKEN y SHA completo para fijar Actions. El workflow CI ahora ejecuta pruebas PowerShell reales en Windows; CodeQL tiene un único job válido de análisis con permisos actions:read, contents:read y security-events:write.

SHA verificados contra las etiquetas oficiales de sus repositorios:
- actions/checkout v7: 3d3c42e5aac5ba805825da76410c181273ba90b1
- actions/setup-python v5: a26af69be951a213d495a4c3e4e4022e16d87065
- github/codeql-action v4: 9b3254085494b55a0f7c4c2b3d2d52cc712ce370

Referencia: https://docs.github.com/en/actions/reference/security/secure-use

## Microsoft Learn

PowerShell ShouldProcess habilita WhatIf y Confirm; cada escritura del generador se agrupa tras ShouldProcess. Los scripts de instalación y actualización verifican explícitamente el exit code de programas nativos. La plantilla web incorpora landmarks, enlaces de salto, foco de teclado visible y prefers-reduced-motion.

Referencias:
- https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.4
- https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/running-commands
- https://learn.microsoft.com/en-us/microsoft-edge/accessibility/design
- https://learn.microsoft.com/en-us/microsoft-edge/devtools/accessibility/reduced-motion-simulation
