param([string]$TargetDir = ".\OpenManus")

$ErrorActionPreference = "Stop"

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\web_run.py"
Pop-Location
