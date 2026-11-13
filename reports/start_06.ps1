# Setup helper only: does not modify the course harness or start measured runs.
# From the repository root: & .\reports\start_06.ps1
# To load the variables without calling the API: add -LoadOnly.
[CmdletBinding()]
param([switch]$LoadOnly)

& {
    param([string]$ScriptDirectory, [bool]$OnlyLoad)
    $ErrorActionPreference = 'Stop'
    $projectRoot = Split-Path -Parent $ScriptDirectory
    $envPath = Join-Path $projectRoot '.env'
    $pythonPath = Join-Path $projectRoot '.venv\Scripts\python.exe'

    if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) {
        throw 'The project .env file is missing.'
    }
    $allowed = @('OPENAI_API_KEY', 'REVIEWER', 'PYTHONUTF8')
    $values = @{}
    $lineNumber = 0
    foreach ($line in (Get-Content -LiteralPath $envPath -Encoding UTF8)) {
        $lineNumber++
        $entry = $line.Trim()
        if (-not $entry -or $entry.StartsWith('#')) { continue }
        if ($entry -notmatch '^([A-Z_][A-Z0-9_]*)\s*=(.*)$') {
            throw "Invalid .env format at line $lineNumber. Use NAME=value."
        }
        $name = $Matches[1]
        $value = $Matches[2].Trim()
        if ($name -notin $allowed -or $values.ContainsKey($name)) {
            throw "Unexpected or duplicate setting at .env line $lineNumber."
        }
        if ($value.Length -ge 2) {
            $first = $value.Substring(0, 1)
            $last = $value.Substring($value.Length - 1, 1)
            if (($first -eq '"' -and $last -eq '"') -or
                ($first -eq "'" -and $last -eq "'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }
        $values[$name] = $value
    }
    $key = $values['OPENAI_API_KEY']
    if ([string]::IsNullOrWhiteSpace($key) -or
        $key -eq 'PASTE_YOUR_OPENAI_API_KEY_HERE' -or $key -match '\s') {
        throw 'Fill OPENAI_API_KEY in the project .env file with your key, then save it. The key is not displayed.'
    }
    if ($values['REVIEWER'] -ne 'scripted:approve-all') {
        throw 'Assignment 6 requires REVIEWER=scripted:approve-all in .env.'
    }
    if ($values['PYTHONUTF8'] -ne '1') {
        throw 'Keep PYTHONUTF8=1 in .env for the Windows setup.'
    }
    foreach ($name in $allowed) {
        [Environment]::SetEnvironmentVariable($name, $values[$name], 'Process')
    }
    Write-Host 'Environment loaded for this PowerShell session. API key is hidden.'
    if ($OnlyLoad) { return }
    if (-not (Test-Path -LiteralPath $pythonPath -PathType Leaf)) {
        throw 'The project virtual environment is missing. Create .venv and install requirements first.'
    }
    Push-Location -LiteralPath $projectRoot
    try {
        & $pythonPath -m harness.ping
        if ($LASTEXITCODE -ne 0) {
            throw 'API preflight did not pass. No experiment or Git operation was started.'
        }
        Write-Host 'API preflight passed. No measured experiments or Git operations were started.'
    }
    finally {
        Pop-Location
    }
} $PSScriptRoot ([bool]$LoadOnly)
