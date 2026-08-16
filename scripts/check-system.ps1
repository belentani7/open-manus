$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

Write-Host "Checking Windows local-agent prerequisites..."

$pythonOk = Test-Command "python"
$gitOk = Test-Command "git"
$ollamaOk = Test-Command "ollama"

Write-Host ("Python : " + $(if ($pythonOk) { "OK" } else { "MISSING" }))
Write-Host ("Git    : " + $(if ($gitOk) { "OK" } else { "MISSING" }))
Write-Host ("Ollama : " + $(if ($ollamaOk) { "OK" } else { "MISSING" }))

if (-not ($pythonOk -and $gitOk -and $ollamaOk)) {
    Write-Error "Missing required tools. Install Python 3.11, Git and Ollama first."
}

Write-Host "All required tools are available."
