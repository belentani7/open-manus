$ErrorActionPreference = "Stop"

param([string]$TargetDir = ".\OpenManus")

Push-Location $TargetDir
& ".\.venv\Scripts\python.exe" ".\main.py"
Pop-Location
