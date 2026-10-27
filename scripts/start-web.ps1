param([string]$TargetDir = ".\OpenManus")

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TargetDir -PathType Container)) {
    throw "OpenManus directory not found: $TargetDir"
}

$targetPath = (Resolve-Path -LiteralPath $TargetDir).Path
$python = Join-Path $targetPath ".venv\Scripts\python.exe"
$entry = Join-Path $targetPath "web_run.py"

if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
    throw "OpenManus virtual environment Python not found: $python. Run setup-openmanus.ps1 first."
}
if (-not (Test-Path -LiteralPath $entry -PathType Leaf)) {
    throw "OpenManus entry point not found: $entry. Check the installed upstream revision."
}

Push-Location -LiteralPath $targetPath
try {
    & $python $entry
    if ($LASTEXITCODE -ne 0) {
        throw "OpenManus start-web.ps1 failed: Python exited with code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}
