param(
    [string]$RepoDir = ".\OpenManus"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $RepoDir -PathType Container)) {
    throw "OpenManus folder not found: $RepoDir"
}

Push-Location -LiteralPath $RepoDir
try {
    & git rev-parse --is-inside-work-tree | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Target is not a Git checkout" }

    $dirty = & git status --porcelain
    if ($LASTEXITCODE -ne 0) { throw "Cannot inspect Git working tree" }
    if ($dirty) {
        throw "Working tree contains local changes; commit or stash them before updating"
    }

    & git pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "Fast-forward update failed; nothing was reset or overwritten" }

    $python = ".\.venv\Scripts\python.exe"
    if (Test-Path -LiteralPath $python -PathType Leaf) {
        if (Test-Path -LiteralPath ".\requirements.txt" -PathType Leaf) {
            & $python -m pip install -r ".\requirements.txt"
            if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed" }
        }
    } else {
        Write-Warning "Virtual environment not found. Run setup-openmanus.ps1 first."
    }
}
finally {
    Pop-Location
}
