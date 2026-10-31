$ErrorActionPreference = 'Stop'

function Get-Tool {
    param([string]$Name)
    Get-Command $Name -ErrorAction SilentlyContinue
}

Write-Host 'Checking local-agent prerequisites...'
$python = Get-Tool 'python'
$git = Get-Tool 'git'
$ollama = Get-Tool 'ollama'
$pythonOk = $false
$gitOk = $null -ne $git
$ollamaOk = $false

if ($python) {
    $versionText = (& $python.Source -c 'import sys; print(".".join(map(str, sys.version_info[:3])))' 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -eq 0 -and $versionText) {
        $version = [version]$versionText
        $pythonOk = $version -ge [version]'3.11'
        Write-Host "Python : $versionText $(if ($pythonOk) { '(OK)' } else { '(3.11+ required)' })"
    }
}
else {
    Write-Host 'Python : MISSING'
}

Write-Host ("Git    : " + $(if ($gitOk) { 'OK' } else { 'MISSING' }))
if ($ollama) {
    & $ollama.Source list 2>$null | Out-Null
    $ollamaOk = $LASTEXITCODE -eq 0
}
Write-Host ("Ollama : " + $(if ($ollamaOk) { 'OK (local service reachable)' } else { 'MISSING or local service unavailable' }))

if (-not ($pythonOk -and $gitOk -and $ollamaOk)) {
    throw 'Install or start the missing prerequisite, then run this check again.'
}

Write-Host 'All prerequisites are available.'
