$ErrorActionPreference = "Stop"

param([string]$TargetDir = ".\OpenManus")

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\web_run.py"
Pop-Location
