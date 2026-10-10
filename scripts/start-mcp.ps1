param([string]$TargetDir = ".\OpenManus")

$ErrorActionPreference = "Stop"

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\run_mcp.py"
Pop-Location
