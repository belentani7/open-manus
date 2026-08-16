$ErrorActionPreference = "Stop"

param(
    [string]$TargetDir = ".\OpenManus",
    [string]$Model = "qwen2.5:7b"
)

if (-not (Test-Path -LiteralPath $TargetDir)) {
    git clone https://github.com/mannaandpoem/OpenManus.git $TargetDir
}

Push-Location $TargetDir

if (-not (Test-Path -LiteralPath ".\.venv")) {
    python -m venv .venv
}

& ".\.venv\Scripts\python.exe" -m pip install --upgrade pip
& ".\.venv\Scripts\python.exe" -m pip install -r requirements.txt

try {
    ollama list | Out-Null
} catch {
    throw "Ollama is not available. Start Ollama and retry."
}

$configExample = ".\config\config.example.toml"
$configTarget = ".\config\config.toml"

if (Test-Path -LiteralPath $configExample -and -not (Test-Path -LiteralPath $configTarget)) {
    Copy-Item -LiteralPath $configExample -Destination $configTarget
}

if (Test-Path -LiteralPath $configTarget) {
    $content = Get-Content -LiteralPath $configTarget -Raw
    $content = $content -replace 'base_url\s*=\s*".*?"', 'base_url = "http://localhost:11434/v1"'
    $content = $content -replace 'model\s*=\s*".*?"', ('model = "' + $Model + '"')
    if ($content -match 'api_key\s*=') {
        $content = $content -replace 'api_key\s*=\s*".*?"', 'api_key = "ollama"'
    } else {
        $content += "`r`napi_key = `"ollama`"`r`n"
    }
    Set-Content -LiteralPath $configTarget -Value $content -Encoding UTF8
}

Pop-Location

Write-Host "OpenManus prepared in $TargetDir"
