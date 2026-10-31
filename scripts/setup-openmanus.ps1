[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [string]$TargetDir = '.\OpenManus',

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._:/-]{0,99}$')]
    [string]$Model = 'qwen2.5:7b',

    [switch]$InstallDependencies,

    [switch]$UpgradePip
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repository = 'https://github.com/mannaandpoem/OpenManus.git'
$targetPath = [System.IO.Path]::GetFullPath($TargetDir)
$exists = Test-Path -LiteralPath $targetPath -PathType Container
$cloneRequired = -not (Test-Path -LiteralPath $targetPath)
$gitCommand = Get-Command git -ErrorAction SilentlyContinue

if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
    throw "Target path is a file: $targetPath"
}
if ($exists) {
    if (-not $gitCommand) { throw 'Git was not found on PATH.' }
    $origin = (& $gitCommand.Source -C $targetPath remote get-url origin 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $origin -notmatch '(^|[:/])mannaandpoem/OpenManus(?:\.git)?$') {
        throw "Target exists but is not a clone of mannaandpoem/OpenManus: $targetPath"
    }
}
if (-not $PSCmdlet.ShouldProcess($targetPath, 'Clone or prepare OpenManus for local Ollama')) {
    return
}

$pythonCommand = Get-Command python -ErrorAction SilentlyContinue
$ollamaCommand = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $gitCommand) { throw 'Git was not found on PATH.' }
if (-not $pythonCommand) { throw 'Python was not found on PATH. Install Python 3.11 or newer.' }
if (-not $ollamaCommand) { throw 'Ollama was not found on PATH. Install Ollama and start its local service.' }

& $ollamaCommand.Source list 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Ollama is installed but its local service did not answer. Start Ollama and retry.'
}

if ($cloneRequired) {
    $targetParent = [System.IO.Path]::GetDirectoryName($targetPath)
    if ($targetParent -and -not (Test-Path -LiteralPath $targetParent -PathType Container)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    & $gitCommand.Source clone --depth 1 $repository $targetPath
    if ($LASTEXITCODE -ne 0) {
        throw "OpenManus clone failed with exit code $LASTEXITCODE."
    }
}

Push-Location -LiteralPath $targetPath
try {
    $createdEnvironment = $false
    $venvPython = Join-Path $targetPath '.venv\Scripts\python.exe'
    if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        & $pythonCommand.Source -m venv (Join-Path $targetPath '.venv')
        if ($LASTEXITCODE -ne 0) {
            throw "Virtual environment creation failed with exit code $LASTEXITCODE."
        }
        $createdEnvironment = $true
    }
    if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        throw "Virtual environment Python is missing: $venvPython"
    }

    $requirements = Join-Path $targetPath 'requirements.txt'
    if ($UpgradePip -or $InstallDependencies) {
        if ($UpgradePip) {
            & $venvPython -m pip install --upgrade pip
            if ($LASTEXITCODE -ne 0) { throw "pip upgrade failed with exit code $LASTEXITCODE." }
        }
        if (-not (Test-Path -LiteralPath $requirements -PathType Leaf)) {
            throw "OpenManus dependency manifest is missing: $requirements"
        }
        & $venvPython -m pip install -r $requirements
        if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed with exit code $LASTEXITCODE." }
    }
    elseif ($createdEnvironment) {
        if (-not (Test-Path -LiteralPath $requirements -PathType Leaf)) {
            throw "OpenManus dependency manifest is missing: $requirements"
        }
        & $venvPython -m pip install -r $requirements
        if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed with exit code $LASTEXITCODE." }
    }
    else {
        Write-Host 'Existing virtual environment preserved; dependency installation skipped.'
    }

    $configDirectory = Join-Path $targetPath 'config'
    $configExample = Join-Path $configDirectory 'config.example.toml'
    $configTarget = Join-Path $configDirectory 'config.toml'
    $configCreated = $false
    if (-not (Test-Path -LiteralPath $configTarget -PathType Leaf)) {
        if (Test-Path -LiteralPath $configExample -PathType Leaf) {
            Copy-Item -LiteralPath $configExample -Destination $configTarget
            $configCreated = $true
        }
        else {
            $localTemplate = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\config\config.template.toml'))
            if (Test-Path -LiteralPath $localTemplate -PathType Leaf) {
                New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
                Copy-Item -LiteralPath $localTemplate -Destination $configTarget
                $configCreated = $true
            }
            else {
                Write-Warning 'No upstream config example found; leaving configuration unchanged.'
            }
        }
    }

    if ($configCreated) {
        $content = [System.IO.File]::ReadAllText($configTarget)
        if ($content -notmatch '(?m)^\s*base_url\s*=') {
            throw 'The new config has no base_url entry; refusing to write a partial local configuration.'
        }
        if ($content -notmatch '(?m)^\s*model\s*=') {
            throw 'The new config has no model entry; refusing to write a partial local configuration.'
        }
        $content = [System.Text.RegularExpressions.Regex]::Replace(
            $content,
            '(?m)^\s*base_url\s*=.*$',
            'base_url = "http://localhost:11434/v1"'
        )
        $content = [System.Text.RegularExpressions.Regex]::Replace(
            $content,
            '(?m)^\s*model\s*=.*$',
            ('model = "' + $Model + '"')
        )
        if ($content -match '(?m)^\s*api_key\s*=') {
            $content = [System.Text.RegularExpressions.Regex]::Replace(
                $content,
                '(?m)^\s*api_key\s*=.*$',
                'api_key = "ollama"'
            )
        }
        [System.IO.File]::WriteAllText($configTarget, $content, [System.Text.UTF8Encoding]::new($false))
    }
    else {
        Write-Host 'Existing OpenManus config preserved; no secrets or provider settings were rewritten.'
    }

    $revision = (& $gitCommand.Source -C $targetPath rev-parse --short HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the installed OpenManus revision.' }
    Write-Host "OpenManus prepared at $targetPath (revision $revision)."
}
finally {
    Pop-Location
}
