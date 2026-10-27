param(
    [string]$TargetDir = ".\OpenManus",
    [string]$Model = "qwen2.5:7b",
    [switch]$SkipDependencies
)

$ErrorActionPreference = "Stop"

# Validate before any network, filesystem or dependency change.
if ($Model -notmatch '^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$') {
    throw "Invalid Ollama model name. Use letters, numbers, dots, slashes, colons or hyphens."
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required and must be available in PATH."
}
if (Test-Path -LiteralPath $TargetDir) {
    if (-not (Test-Path -LiteralPath (Join-Path $TargetDir ".git"))) {
        throw "Refusing to configure an existing folder that is not a Git checkout: $TargetDir"
    }
}
elseif ($SkipDependencies) {
    throw "Refusing to clone OpenManus in configuration-only mode. Supply an existing Git checkout."
}
else {
    & git clone -- https://github.com/mannaandpoem/OpenManus.git $TargetDir
    if ($LASTEXITCODE -ne 0) { throw "OpenManus clone failed (exit code $LASTEXITCODE)." }
}

Push-Location -LiteralPath $TargetDir

if ($SkipDependencies) {
    Write-Host "Python environment and dependency installation skipped by request."
}
else {
    if (-not (Test-Path -LiteralPath ".\.venv")) {
        python -m venv .venv
        if ($LASTEXITCODE -ne 0) { throw "Python virtual environment creation failed." }
    }

    & ".\.venv\Scripts\python.exe" -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) { throw "pip upgrade failed." }
    & ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw "OpenManus dependency installation failed." }
}

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    throw "Ollama is not installed or not in PATH."
}
& ollama list | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Ollama is not responding. Start Ollama and retry."
}

$configExample = ".\config\config.example.toml"
$configTarget = ".\config\config.toml"

# Never rewrite a user's existing provider credentials, model choice or private config.
if (Test-Path -LiteralPath $configTarget -PathType Leaf) {
    Write-Warning "Existing config.toml preserved unchanged. Review it manually to select Ollama."
}
elseif (Test-Path -LiteralPath $configExample -PathType Leaf) {
    Copy-Item -LiteralPath $configExample -Destination $configTarget -ErrorAction Stop
    $content = Get-Content -LiteralPath $configTarget -Raw
    $content = $content -replace 'base_url\s*=\s*".*?"', 'base_url = "http://localhost:11434/v1"'
    $content = $content -replace 'model\s*=\s*".*?"', ('model = "' + $Model + '"')
    if ($content -match 'api_key\s*=') {
        $content = $content -replace 'api_key\s*=\s*".*?"', 'api_key = "ollama"'
    }
    else {
        $content += [Environment]::NewLine + 'api_key = "ollama"' + [Environment]::NewLine
    }
    Set-Content -LiteralPath $configTarget -Value $content -Encoding UTF8
    Write-Host "Created local Ollama config.toml from upstream example."
}
else {
    throw "No upstream config/config.example.toml found. Existing config was not modified; check the upstream version."
}

Pop-Location

Write-Host "OpenManus prepared in $TargetDir"
