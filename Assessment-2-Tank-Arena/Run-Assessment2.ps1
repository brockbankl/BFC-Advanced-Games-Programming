[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('start', 'test', 'check')]
    [string]$Action = 'start'
)

$ErrorActionPreference = 'Stop'
$NodeVersion = 'v22.23.2'

function Write-Status {
    param([Parameter(Mandatory = $true)][ValidateSet('INFO', 'PASS', 'FAIL')][string]$Kind, [Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[$Kind] $Message"
}

try {
    $projectRoot = Split-Path -Parent $PSCommandPath
    $architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
    if ($architecture -notin @('x64', 'arm64')) { throw "Windows architecture '$architecture' is not supported by the supplied Node runner." }
    $nodeDirectory = Join-Path $env:LOCALAPPDATA "BFC-AGP\node\$NodeVersion\$architecture"
    $node = Join-Path $nodeDirectory 'node.exe'
    $npm = Join-Path $nodeDirectory 'npm.cmd'
    if (-not (Test-Path -LiteralPath $node) -or -not (Test-Path -LiteralPath $npm)) {
        throw "The course Node.js $NodeVersion installation was not found. Run Setup-Assessment2.cmd first. Expected: $nodeDirectory"
    }
    $nodeVersion = (& $node --version 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or $nodeVersion -notmatch '^v22\.') { throw "The course Node.js installation is not a working Node 22 copy. Run Setup-Assessment2.cmd again." }
    Set-Location -LiteralPath $projectRoot
    # npm.cmd launches node by name internally. Make the pinned Node folder
    # available only to this runner process; do not rely on or write user PATH.
    $separator = [System.IO.Path]::PathSeparator
    if (-not (@($env:Path -split [regex]::Escape([string]$separator)) | Where-Object { $_.TrimEnd('\') -ieq $nodeDirectory.TrimEnd('\') })) {
        $env:Path = "$nodeDirectory$separator$env:Path"
    }
    [string[]]$npmArguments = switch ($Action) {
        'start' { @('start') }
        'test' { @('test') }
        'check' { @('run', 'check') }
    }
    Write-Status INFO "Using the course Node.js $nodeVersion directly: $nodeDirectory"
    & $npm @npmArguments
    if ($LASTEXITCODE -ne 0) { throw "npm $Action failed (exit code $LASTEXITCODE). Read the output above before trying again." }
    Write-Status PASS "Tank Arena $Action completed."
}
catch {
    Write-Status FAIL $_.Exception.Message
    exit 1
}
