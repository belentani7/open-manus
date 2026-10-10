param([string]$TargetDir = ".\OpenManus")

$ErrorActionPreference = "Stop"

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\main.py"
Pop-Location
