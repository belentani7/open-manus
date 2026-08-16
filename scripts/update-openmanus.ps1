param(
    [string]$RepoDir = ".\OpenManus"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $RepoDir)) {
    Write-Error "OpenManus folder not found: $RepoDir"
}

Push-Location $RepoDir
try {
    git pull

    if (Test-Path -LiteralPath ".\.venv\Scripts\python.exe") {
        .\.venv\Scripts\python.exe -m pip install -U pip
        if (Test-Path -LiteralPath ".\requirements.txt") {
            .\.venv\Scripts\python.exe -m pip install -r .\requirements.txt
        }
    }
    else {
        Write-Warning "Virtual environment not found. Run setup-openmanus.ps1 first."
    }
}
finally {
    Pop-Location
}
