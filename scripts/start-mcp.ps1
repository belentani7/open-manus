$ErrorActionPreference = "Stop"

param([string]$TargetDir = ".\OpenManus")

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\run_mcp.py"
Pop-Location
