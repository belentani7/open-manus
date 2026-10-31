[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [string]$RepoDir = '.\OpenManus',
    [switch]$InstallDependencies,
    [switch]$UpgradePip
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$targetPath = [System.IO.Path]::GetFullPath($RepoDir)
if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
    throw "OpenManus folder not found: $targetPath"
}
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCommand) { throw 'Git was not found on PATH.' }

$origin = (& $gitCommand.Source -C $targetPath remote get-url origin 2>$null | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $origin -notmatch '(^|[:/])mannaandpoem/OpenManus(?:\.git)? (& $gitCommand.Source -C $targetPath status --porcelain | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the OpenManus working tree.' }
if ($dirty) { throw 'OpenManus has local changes. Commit or back them up before updating.' }

$upstream = (& $gitCommand.Source -C $targetPath rev-parse --abbrev-ref '@{u}' 2>$null | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or -not $upstream) {
    throw 'The current branch has no upstream. Set and verify an upstream before updating.'
}
if ($upstream.Split('/')[0] -ne 'origin') {
    throw "The branch upstream is not origin: $upstream"
}

if (-not $PSCmdlet.ShouldProcess($targetPath, "Fast-forward to $upstream")) {
    return
}

& $gitCommand.Source -C $targetPath fetch --prune origin
if ($LASTEXITCODE -ne 0) { throw 'Fetch failed; the local checkout was not changed.' }
& $gitCommand.Source -C $targetPath merge --ff-only $upstream
if ($LASTEXITCODE -ne 0) { throw 'Fast-forward failed; inspect the local and upstream histories.' }

if ($UpgradePip -or $InstallDependencies) {
    $venvPython = Join-Path $targetPath '.venv\Scripts\python.exe'
    $requirements = Join-Path $targetPath 'requirements.txt'
    if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        throw "Virtual environment is missing: $venvPython"
    }
    if ($UpgradePip) {
        & $venvPython -m pip install --upgrade pip
        if ($LASTEXITCODE -ne 0) { throw "pip upgrade failed with exit code $LASTEXITCODE." }
    }
    if ($InstallDependencies) {
        if (-not (Test-Path -LiteralPath $requirements -PathType Leaf)) {
            throw "Dependency manifest is missing: $requirements"
        }
        & $venvPython -m pip install -r $requirements
        if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed with exit code $LASTEXITCODE." }
    }
}

$revision = (& $gitCommand.Source -C $targetPath rev-parse --short HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not read the updated OpenManus revision.' }
Write-Host "OpenManus updated safely to $revision."
) {
    throw "Target is not a clone of mannaandpoem/OpenManus: $targetPath"
}

$dirty = (& $gitCommand.Source -C $targetPath status --porcelain | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the OpenManus working tree.' }
if ($dirty) { throw 'OpenManus has local changes. Commit or back them up before updating.' }

$upstream = (& $gitCommand.Source -C $targetPath rev-parse --abbrev-ref '@{u}' 2>$null | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or -not $upstream) {
    throw 'The current branch has no upstream. Set and verify an upstream before updating.'
}

if (-not $PSCmdlet.ShouldProcess($targetPath, "Fast-forward to $upstream")) {
    return
}

& $gitCommand.Source -C $targetPath fetch --prune origin
if ($LASTEXITCODE -ne 0) { throw 'Fetch failed; the local checkout was not changed.' }
& $gitCommand.Source -C $targetPath merge --ff-only $upstream
if ($LASTEXITCODE -ne 0) { throw 'Fast-forward failed; inspect the local and upstream histories.' }

if ($UpgradePip -or $InstallDependencies) {
    $venvPython = Join-Path $targetPath '.venv\Scripts\python.exe'
    $requirements = Join-Path $targetPath 'requirements.txt'
    if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        throw "Virtual environment is missing: $venvPython"
    }
    if ($UpgradePip) {
        & $venvPython -m pip install --upgrade pip
        if ($LASTEXITCODE -ne 0) { throw "pip upgrade failed with exit code $LASTEXITCODE." }
    }
    if ($InstallDependencies) {
        if (-not (Test-Path -LiteralPath $requirements -PathType Leaf)) {
            throw "Dependency manifest is missing: $requirements"
        }
        & $venvPython -m pip install -r $requirements
        if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed with exit code $LASTEXITCODE." }
    }
}

$revision = (& $gitCommand.Source -C $targetPath rev-parse --short HEAD).Trim()
Write-Host "OpenManus updated safely to $revision."
