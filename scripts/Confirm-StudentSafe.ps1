[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot '.git'))) {
    throw 'Run this check after initialising the outer course repository with Git.'
}

$trackedTeacherFiles = @(& git -C $repositoryRoot ls-files -- '_teacher')
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to inspect tracked files.'
}

if ($trackedTeacherFiles.Count -gt 0) {
    $trackedTeacherFiles | ForEach-Object { Write-Error "Lecturer-only file is tracked: $_" }
    throw 'Student-safety check failed.'
}

$trackedPaths = @(& git -C $repositoryRoot ls-files)
$sensitivePaths = @(
    $trackedPaths | Where-Object {
        $_ -match '(^|/)Teacher-Additions(/|$)' -or
        $_ -match '(^|/)users\.json$' -or
        $_ -match '(^|/)Login-Version(/|$)'
    }
)

if ($sensitivePaths.Count -gt 0) {
    $sensitivePaths | ForEach-Object { Write-Error "Private Assessment 2 material is tracked publicly: $_" }
    throw 'Student-safety check failed.'
}

$teacherRoot = Join-Path $repositoryRoot '_teacher'
if (Test-Path -LiteralPath $teacherRoot) {
    & git -C $repositoryRoot check-ignore -q -- '_teacher'
    if ($LASTEXITCODE -ne 0) {
        throw 'The _teacher directory is not ignored.'
    }
}

$readme = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'README.md')
if (-not $readme.Contains('https://github.com/MonoGame/Starter-Kit-3D-Platformer')) {
    throw 'README.md no longer links to the official upstream repository.'
}

Write-Host 'Student-safety check passed: no lecturer-only or login-addition files are tracked.'
