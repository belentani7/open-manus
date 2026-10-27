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
    if ([IO.Path]::GetFullPath($root).TrimEnd([char[]]@('\', '/')) -ne [IO.Path]::GetFullPath($repoPath).TrimEnd([char[]]@('\', '/'))) {
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

    # A clean Git status excludes ignored files. A normal fast-forward can still
    # overwrite an ignored local .env or .venv file if upstream starts tracking it.
    # Fetch first, then reject newly tracked paths that local rules ignore.
    $upstream = (& git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')
    Assert-GitSuccess "upstream"
    if ([string]::IsNullOrWhiteSpace($upstream)) {
        throw "Refusing to update a branch without an upstream."
    }

    $remote = (& git config --get "branch.$branch.remote")
    Assert-GitSuccess "branch remote"
    if ([string]::IsNullOrWhiteSpace($remote)) {
        throw "Refusing to update a branch without a configured remote."
    }

    & git fetch --no-tags $remote
    Assert-GitSuccess "fetch"
    & git merge-base --is-ancestor HEAD $upstream
    if ($LASTEXITCODE -ne 0) {
        throw "Refusing to update: upstream is not a fast-forward of the local branch."
    }

    # Disable Git path quoting for Unicode names. Quoted paths (control
    # characters, embedded newlines, etc.) are rejected rather than misread.
    $incomingPaths = @(& git -c core.quotePath=false diff --name-only --no-renames --diff-filter=A HEAD $upstream)
    Assert-GitSuccess "incoming path diff"
    foreach ($relativePath in $incomingPaths) {
        if ($relativePath.StartsWith('"')) {
            throw "Refusing to update: unsupported quoted Git path in upstream."
        }
        & git check-ignore -q -- $relativePath
        if ($LASTEXITCODE -eq 0) {
            throw "Refusing to overwrite ignored local path: $relativePath"
        }
        if ($LASTEXITCODE -ne 1) {
            throw "Refusing to update: could not check ignore status for $relativePath."
        }
    }

    Write-Host "Updating $repoPath on branch $branch (fast-forward only)..."
    & git merge --ff-only $upstream
    Assert-GitSuccess "merge --ff-only"

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
