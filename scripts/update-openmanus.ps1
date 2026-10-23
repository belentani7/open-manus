param(
    [string]$RepoDir = ".\OpenManus",
    [switch]$SkipDependencies
)

$ErrorActionPreference = "Stop"

function Assert-GitSuccess {
    param([string]$Operation)
    if ($LASTEXITCODE -ne 0) {
        throw "OpenManus update aborted: git $Operation failed (exit code $LASTEXITCODE)."
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is not installed or not available in PATH."
}
if (-not (Test-Path -LiteralPath $RepoDir -PathType Container)) {
    throw "OpenManus folder not found: $RepoDir"
}

$repoPath = (Resolve-Path -LiteralPath $RepoDir).Path
# A nested folder in an unrelated checkout must never update its parent.
if (-not (Test-Path -LiteralPath (Join-Path $repoPath ".git"))) {
    throw "Refusing to update: $repoPath is not a Git working-tree root."
}

Push-Location -LiteralPath $repoPath
try {
    $root = (& git rev-parse --show-toplevel)
    Assert-GitSuccess "rev-parse"
    if ([IO.Path]::GetFullPath($root).TrimEnd('\', '/') -ne [IO.Path]::GetFullPath($repoPath).TrimEnd('\', '/')) {
        throw "Refusing to update a different Git repository."
    }

    $changes = @(& git status --porcelain --untracked-files=normal)
    Assert-GitSuccess "status"
    if ($changes.Count -gt 0) {
        throw "Refusing to update: working tree has local modifications or untracked files. Commit/stash them before retrying."
    }

    $branch = (& git symbolic-ref --quiet --short HEAD)
    Assert-GitSuccess "symbolic-ref"
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Refusing to update from detached HEAD."
    }

    Write-Host "Updating $repoPath on branch $branch (fast-forward only)..."
    & git pull --ff-only
    Assert-GitSuccess "pull --ff-only"

    if ($SkipDependencies) {
        Write-Host "Repository updated. Dependency installation skipped by request."
        return
    }

    $python = Join-Path $repoPath ".venv\Scripts\python.exe"
    if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
        Write-Warning "Virtual environment not found. Run setup-openmanus.ps1 before installing dependencies."
        return
    }

    & $python -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) { throw "Python pip update failed (exit code $LASTEXITCODE)." }

    $requirements = Join-Path $repoPath "requirements.txt"
    if (Test-Path -LiteralPath $requirements -PathType Leaf) {
        & $python -m pip install -r $requirements
        if ($LASTEXITCODE -ne 0) { throw "OpenManus dependency installation failed (exit code $LASTEXITCODE)." }
    }
    Write-Host "OpenManus updated successfully."
}
finally {
    Pop-Location
}
