[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$teacherRoot = Join-Path $repositoryRoot '_teacher'
$upstreamRoot = Join-Path $teacherRoot 'upstream-clean'
$teachingBase = Join-Path $teacherRoot 'teaching-base'
$lessonsRoot = Join-Path $teacherRoot 'lessons'
$manifest = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'upstream.json') | ConvertFrom-Json
$upstreamUrl = $manifest.repository
$pinnedCommit = $manifest.commit

New-Item -ItemType Directory -Force -Path $teacherRoot, $lessonsRoot | Out-Null

if (-not (Test-Path -LiteralPath $upstreamRoot)) {
    & git clone --origin upstream $upstreamUrl $upstreamRoot
    if ($LASTEXITCODE -ne 0) {
        throw 'The upstream clone failed.'
    }

    & git -C $upstreamRoot checkout --detach $pinnedCommit
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to check out pinned upstream commit $pinnedCommit"
    }
}
elseif (-not (Test-Path -LiteralPath (Join-Path $upstreamRoot '.git'))) {
    throw "The existing upstream-clean folder is not a Git checkout: $upstreamRoot"
}

$currentCommit = (& git -C $upstreamRoot rev-parse HEAD).Trim()
if ($currentCommit -ne $pinnedCommit) {
    throw "upstream-clean is at $currentCommit but upstream.json pins $pinnedCommit. Review the upstream change instead of replacing the baseline automatically."
}

if (Test-Path -LiteralPath $teachingBase) {
    Write-Host "Teaching base already exists; leaving it unchanged: $teachingBase"
    Write-Host 'Rename or archive it before intentionally creating a new baseline.'
    exit 0
}

New-Item -ItemType Directory -Path $teachingBase | Out-Null

$null = & robocopy $upstreamRoot $teachingBase /E /XD .git bin obj .artifacts Output /XF '*.xnb' '*.blend1'
if ($LASTEXITCODE -ge 8) {
    throw "robocopy failed with exit code $LASTEXITCODE"
}
$LASTEXITCODE = 0

$targetsPath = Join-Path $teachingBase 'Content\BuildContent.targets'
$targets = Get-Content -Raw -LiteralPath $targetsPath
$originalArgs = '<ContentArgs>build -p $(MonoGamePlatform) -s Content/Assets -o $(ContentOutput) -i $(ContentTemp)</ContentArgs>'
$quotedArgs = '<ContentArgs>build -p &quot;$(MonoGamePlatform)&quot; -s &quot;Content/Assets&quot; -o &quot;$(ContentOutput).&quot; -i &quot;$(ContentTemp).&quot;</ContentArgs>'
$originalCommand = '<Exec Command="$(ContentCommand) $(ContentArgs)"'
$quotedCommand = '<Exec Command="&quot;$(ContentCommand)&quot; $(ContentArgs)"'

if (-not $targets.Contains($originalArgs) -or -not $targets.Contains($originalCommand)) {
    throw 'The upstream BuildContent.targets layout changed; review it before applying the local path fix.'
}

$targets = $targets.Replace($originalArgs, $quotedArgs).Replace($originalCommand, $quotedCommand)
Set-Content -LiteralPath $targetsPath -Value $targets -Encoding utf8

$provenance = @"
# Local teaching baseline

Upstream: $upstreamUrl
Commit: $pinnedCommit

Local change: quoted the Content Builder executable and path arguments so the
project builds when the containing workspace path includes spaces. A trailing
dot prevents Windows from treating the final path separator as an escaped quote.
"@
Set-Content -LiteralPath (Join-Path $teachingBase 'TEACHING_BASE.md') -Value $provenance -Encoding utf8

Write-Host "Created teaching baseline: $teachingBase"
Write-Host "Upstream commit: $pinnedCommit"
