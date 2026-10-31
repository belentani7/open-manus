# Revisión de exportaciones Qwen

Fecha: 2026-10-31.

## Exportaciones recuperadas

Se leyeron cuatro conversaciones completas desde Library:

- chat-Bellacore Automatización Integral.txt
- chat-Desarrollo Web El Racó.txt
- chat-Motor de Extracción Leads con Visor Web (2).txt
- chat-Universal Project Integration.txt

Los transcripts conservan fragmentos y referencias a adjuntos; la búsqueda de archivos no encontró los ZIP citados dentro de Library. No se afirma haber recuperado binarios que no están presentes.

## Ideas aplicadas en este repositorio

El chat Universal Project Integration aclara que la herramienta debe servir a proyectos futuros, sin anclarse en Bellacore. Se aplica mediante scripts/New-Project.ps1 y cuatro plantillas independientes. La fábrica no instala automáticamente lo que ya está instalado, no lanza servicios y permite revisar la escritura con WhatIf.

Se conserva la idea de un flujo repetible y de pruebas concretas; las pruebas verifican creación, alcance de ruta, ejecución de la plantilla Python, estructura de la plantilla Node, accesibilidad básica, WhatIf y preservación de datos existentes.

## Ideas excluidas o pendientes de un repositorio propio

- Los fragmentos de Bellacore mezclan simulación de resultados con la intención de consultar datos reales. No se copian al agente local.
- Se excluyen rotación de proxies, resolución de CAPTCHA y evasión de controles. La recolección de lugares requiere APIs autorizadas y respetar sus términos.
- No se exponen API keys en el navegador, no se inventan resultados ni se afirma coste cero sin medición.
- El chat de El Racó trata una tienda y un panel autenticado. No se copian identidad, credenciales, datos de clientes, pedidos ni archivos locales a OpenManus.

Esas conversaciones podrán originar repositorios propios solo cuando exista una fuente de código/adjuntos y alcance que coincidan; no se mezclan con este wrapper local.
