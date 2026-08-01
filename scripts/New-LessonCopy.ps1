[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_-]*$')]
    [string] $Name
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repositoryRoot '_teacher\teaching-base'
$lessonsRoot = Join-Path $repositoryRoot '_teacher\lessons'
$destination = Join-Path $lessonsRoot $Name

if (-not (Test-Path -LiteralPath $source)) {
    throw 'The teaching base does not exist. Run Initialize-TeacherWorkspace.ps1 first.'
}

if (Test-Path -LiteralPath $destination) {
    throw "The lesson already exists and will not be overwritten: $destination"
}

New-Item -ItemType Directory -Force -Path $lessonsRoot | Out-Null
New-Item -ItemType Directory -Path $destination | Out-Null

$null = & robocopy $source $destination /E /XD .git bin obj .artifacts Output /XF '*.xnb' '*.blend1'
if ($LASTEXITCODE -ge 8) {
    throw "robocopy failed with exit code $LASTEXITCODE"
}
$LASTEXITCODE = 0

Write-Host "Created lesson copy: $destination"
Write-Host 'Open that folder directly in a new Visual Studio Code window.'
