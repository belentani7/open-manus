[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$')]
    [string]$ProjectName,

    [string]$Workspace = (Join-Path $HOME 'Projects'),

    [ValidateSet('general', 'web', 'python', 'node')]
    [string]$Template = 'general',

    [switch]$InitializeGit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workspacePath = [System.IO.Path]::GetFullPath($Workspace)
if (Test-Path -LiteralPath $workspacePath -PathType Leaf) {
    throw "Workspace must be a directory: $workspacePath"
}

$projectPath = [System.IO.Path]::GetFullPath((Join-Path $workspacePath $ProjectName))
$separator = [string][System.IO.Path]::DirectorySeparatorChar
$workspacePrefix = $workspacePath
if (-not $workspacePrefix.EndsWith($separator)) {
    $workspacePrefix += $separator
}
if (-not $projectPath.StartsWith($workspacePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Project path must remain inside the selected workspace.'
}

if (Test-Path -LiteralPath $projectPath -PathType Leaf) {
    throw "Project path is a file: $projectPath"
}
if (Test-Path -LiteralPath $projectPath) {
    $projectItem = Get-Item -LiteralPath $projectPath -Force
    if (($projectItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Project path cannot be a symbolic link or junction: $projectPath"
    }
}
if (Test-Path -LiteralPath $projectPath -PathType Container) {
    $existingItems = @(Get-ChildItem -LiteralPath $projectPath -Force)
    if ($existingItems.Count -gt 0) {
        throw "Refusing to overwrite a non-empty directory: $projectPath"
    }
}
if ($InitializeGit -and -not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git is required when -InitializeGit is selected.'
}

if (-not $PSCmdlet.ShouldProcess($projectPath, "Create the $Template project scaffold")) {
    return
}

$slug = $ProjectName.ToLowerInvariant() -replace '[^a-z0-9-]+', '-'
$slug = $slug -replace '^-+|-+$', ''

$files = [ordered]@{}
$files['README.md'] = @'
# __PROJECT_NAME__

A new project scaffold. Define the user outcome and scope in docs/project-brief.md before adding dependencies or production claims.

## Start here

1. Complete docs/project-brief.md.
2. Read AGENTS.md and .cursor/rules/project.mdc.
3. Select only the stack and capabilities this project needs.
4. Add a focused test for each behavior that matters.

## Generated with

The local-agent project factory. It creates files locally; it does not install packages, contact services, open ports, or start applications.
'@
$files['AGENTS.md'] = @'
# Project operating contract

- Treat this repository as the source of truth. Inspect the existing code before changing it.
- Keep user data and existing project files. Do not overwrite a non-empty destination.
- Describe only behavior that exists and has been verified. Label mock data and unfinished routes.
- Keep secrets out of source, logs, examples, browser bundles, and generated files.
- Avoid network calls, package installation, external services, and privilege expansion unless the task requires them.
- Make the smallest complete change, then run the relevant tests and build.
- When output is generated, edit its source and document the regeneration command.
- Use semantic HTML, keyboard-visible focus, readable contrast, and reduced-motion support for web interfaces.
'@
$files['.cursor/rules/project.mdc'] = @'
---
description: Project-wide rules for safe, testable and truthful changes.
globs: "**/*"
alwaysApply: true
---

Use this repository and its current files as the source of truth. Preserve user data and established design. Make generated output from a documented source. Do not invent features, results, metrics, releases or deployment status. Keep secrets out of code and logs. Prefer local, reversible changes; avoid installs, network calls, production writes and services unless they are required. Run the smallest relevant verification and report the exact result. For web work, preserve semantic structure, keyboard focus, sufficient contrast and reduced-motion behavior.
'@
$files['.editorconfig'] = @'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2

[*.ps1]
indent_size = 4

[*.py]
indent_size = 4
'@
$files['.gitignore'] = @'
.env
.env.*
!.env.example
node_modules/
.venv/
venv/
__pycache__/
.pytest_cache/
coverage/
dist/
build/
.next/
*.log
.DS_Store
Thumbs.db
'@
$files['project.json'] = @'
{
  "name": "__PROJECT_NAME__",
  "slug": "__PROJECT_SLUG__",
  "template": "__TEMPLATE__",
  "generator": "local-agent/scripts/New-Project.ps1"
}
'@
$files['docs/project-brief.md'] = @'
# Project brief

## User and need

- Primary user:
- Need or problem:
- Current alternative:

## Outcome

- The user can:
- Evidence that it works:

## Scope

### Included

- 

### Excluded

- 

## Constraints

- Data and privacy:
- Supported devices or environment:
- Dependencies allowed:
- Accessibility:

## First delivery

- Smallest useful workflow:
- Verification command:
- Definition of done:
'@

switch ($Template) {
    'web' {
        $files['index.html'] = @'
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="__PROJECT_NAME__: define aquí el propósito real del proyecto.">
  <meta name="theme-color" content="#f5f7f3">
  <title>__PROJECT_NAME__</title>
  <link rel="stylesheet" href="assets/css/styles.css">
  <script src="assets/js/main.js" defer></script>
</head>
<body>
  <a class="skip-link" href="#main">Saltar al contenido</a>
  <header class="site-header">
    <a class="brand" href="./">__PROJECT_NAME__</a>
    <nav aria-label="Navegación principal">
      <a href="#about">Acerca del proyecto</a>
    </nav>
  </header>
  <main id="main" tabindex="-1">
    <section class="hero" aria-labelledby="page-title">
      <p class="eyebrow">Proyecto en definición</p>
      <h1 id="page-title">Un propósito claro. Un primer paso útil.</h1>
      <p class="lead">Sustituye este texto por una descripción comprobable del servicio y de la persona a quien ayuda.</p>
      <a class="button" href="#about">Conocer el alcance</a>
    </section>
    <section id="about" class="content" aria-labelledby="about-title">
      <h2 id="about-title">Qué resolverá</h2>
      <p>Define aquí el problema, los límites y cómo comprobarás que la primera versión funciona.</p>
    </section>
  </main>
  <footer class="site-footer">
    <p>__PROJECT_NAME__ · <span data-year>2026</span></p>
  </footer>
</body>
</html>
'@
        $files['assets/css/styles.css'] = @'
:root {
  color-scheme: light;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  color: #15231c;
  background: #f5f7f3;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  --surface: #fff;
  --line: #d4ded6;
  --accent: #14624d;
  --focus: #a44400;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body { margin: 0; line-height: 1.65; }
a { color: var(--accent); text-underline-offset: .18em; }
a:focus-visible { outline: 3px solid var(--focus); outline-offset: 4px; }
.skip-link { position: absolute; left: 1rem; top: -5rem; z-index: 5; padding: .6rem 1rem; background: #fff; color: #15231c; }
.skip-link:focus { top: 1rem; }
.site-header, .site-footer { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1rem clamp(1rem, 5vw, 4rem); border-bottom: 1px solid var(--line); }
.brand { color: inherit; font-weight: 750; text-decoration: none; }
.site-header nav { display: flex; flex-wrap: wrap; gap: 1rem; }
main { width: min(100% - 2rem, 68rem); margin: 0 auto; }
.hero { min-height: 65vh; display: grid; align-content: center; justify-items: start; padding: clamp(2rem, 8vw, 7rem) 0; }
.eyebrow { color: #425c4d; font-size: .8rem; font-weight: 750; letter-spacing: .1em; text-transform: uppercase; }
h1 { max-width: 16ch; margin: .3rem 0 1rem; font-size: clamp(2.5rem, 8vw, 5.5rem); line-height: 1.04; letter-spacing: -.05em; }
.lead { max-width: 58ch; font-size: clamp(1.1rem, 2vw, 1.35rem); }
.button { display: inline-block; margin-top: 1rem; padding: .7rem 1rem; border-radius: .7rem; background: #164f3f; color: #fff; font-weight: 700; text-decoration: none; }
.content { max-width: 65ch; padding: 2rem 0 5rem; }
.site-footer { justify-content: center; border-top: 1px solid var(--line); border-bottom: 0; }
@media (max-width: 38rem) {
  .site-header { align-items: flex-start; flex-direction: column; }
  .hero { min-height: 55vh; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { scroll-behavior: auto !important; animation-duration: .01ms !important; animation-iteration-count: 1 !important; transition-duration: .01ms !important; }
}
'@
        $files['assets/js/main.js'] = @'
const year = document.querySelector('[data-year]');
if (year) year.textContent = String(new Date().getFullYear());
'@
    }
    'python' {
        $files['main.py'] = @'
def project_status() -> dict[str, str]:
    """Return a truthful, local-only status for the new project scaffold."""
    return {"name": "__PROJECT_NAME__", "status": "scaffolded"}


if __name__ == "__main__":
    print(project_status())
'@
        $files['tests/test_main.py'] = @'
import unittest

from main import project_status


class ProjectStatusTests(unittest.TestCase):
    def test_status_is_local_and_explicit(self):
        self.assertEqual(project_status(), {"name": "__PROJECT_NAME__", "status": "scaffolded"})


if __name__ == "__main__":
    unittest.main()
'@
        $files['pyproject.toml'] = @'
[project]
name = "__PROJECT_SLUG__"
version = "0.1.0"
description = "A new project scaffold; replace with a truthful description."
requires-python = ">=3.11"
dependencies = []

[tool.unittest]
start-directory = "tests"
'@
    }
    'node' {
        $files['package.json'] = @'
{
  "name": "__PROJECT_SLUG__",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "start": "node src/index.js",
    "test": "node --test"
  }
}
'@
        $files['src/index.js'] = @'
import { pathToFileURL } from "node:url";

export function projectStatus() {
  return { name: "__PROJECT_NAME__", status: "scaffolded" };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.stdout.write(JSON.stringify(projectStatus()) + "\n");
}
'@
        $files['tests/project-status.test.js'] = @'
import test from "node:test";
import assert from "node:assert/strict";
import { projectStatus } from "../src/index.js";

test("reports the local scaffold status without claiming deployment", () => {
  assert.deepEqual(projectStatus(), { name: "__PROJECT_NAME__", status: "scaffolded" });
});
'@
    }
}

if (-not (Test-Path -LiteralPath $workspacePath -PathType Container)) {
    New-Item -ItemType Directory -Path $workspacePath -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
    New-Item -ItemType Directory -Path $projectPath | Out-Null
}

$directories = @()
foreach ($relativePath in $files.Keys) {
    $parentDirectory = [System.IO.Path]::GetDirectoryName($relativePath)
    if ($parentDirectory) {
        $directories += $parentDirectory
    }
}
foreach ($directory in ($directories | Sort-Object -Unique)) {
    New-Item -ItemType Directory -Path (Join-Path $projectPath $directory) -Force | Out-Null
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
foreach ($relativePath in $files.Keys) {
    $destination = Join-Path $projectPath $relativePath
    $content = $files[$relativePath].Replace('__PROJECT_NAME__', $ProjectName)
    $content = $content.Replace('__PROJECT_SLUG__', $slug).Replace('__TEMPLATE__', $Template)
    [System.IO.File]::WriteAllText($destination, $content, $utf8NoBom)
}

if ($InitializeGit) {
    & git -C $projectPath init
    if ($LASTEXITCODE -ne 0) {
        throw "Git initialization failed with exit code $LASTEXITCODE."
    }
    & git -C $projectPath symbolic-ref HEAD refs/heads/main
    if ($LASTEXITCODE -ne 0) {
        throw "Could not set the initial branch to main (exit code $LASTEXITCODE)."
    }
}

Write-Output $projectPath
