[CmdletBinding()]
param(
    # Optional isolated locations are for support testing; students need none.
    [string]$NodeInstallRoot,
    [string]$NodeCacheRoot,
    [switch]$SkipUserPathUpdate,
    [switch]$SkipSmokeTest
)

$ErrorActionPreference = 'Stop'
$NodeVersion = 'v22.23.2'
$NodeArchives = @{
    x64 = @{ File = "node-$NodeVersion-win-x64.zip"; Sha256 = '1177b4137ba5adaa56354ae40f1080c7450e8ae09cecb47da459d1c52ac99f97' }
    arm64 = @{ File = "node-$NodeVersion-win-arm64.zip"; Sha256 = 'fec025a6da31757e3b6af84c5a1628e9d38442ca99a2161091d78f2fcfa35ef3' }
}

function Write-Status {
    param([Parameter(Mandatory = $true)][ValidateSet('CHECK', 'PASS', 'INFO', 'WARN', 'FAIL')][string]$Kind, [Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[$Kind] $Message"
}

function Get-NodeMajorVersion {
    param([Parameter(Mandatory = $true)][string]$NodeCommand)
    try {
        # node --version prints one line. Avoid a Select-Object pipeline here:
        # Windows PowerShell can report a misleading -1 exit code on repeats.
        $version = (& $NodeCommand --version 2>$null).Trim()
        if ($LASTEXITCODE -eq 0 -and $version -match '^v(?<major>\d+)\.\d+\.\d+$') { return [pscustomobject]@{ Version = $version; Major = [int]$Matches.major } }
    }
    catch { }
    return $null
}

function Test-Node22 {
    param([Parameter(Mandatory = $true)][string]$NodeCommand)
    $version = Get-NodeMajorVersion -NodeCommand $NodeCommand
    if ($null -eq $version) { return $false }
    return [bool]($version.Major -eq 22)
}

function Add-UserPathEntry {
    param([Parameter(Mandatory = $true)][string]$Directory, [switch]$DoNotPersist)
    # PATH is the list of folders Windows searches for commands. Update this
    # process immediately, then save one non-duplicated user-level entry.
    $separator = [System.IO.Path]::PathSeparator; $normalised = $Directory.TrimEnd('\')
    $processEntries = @($env:Path -split [regex]::Escape([string]$separator) | Where-Object { $_ })
    if (-not ($processEntries | Where-Object { $_.TrimEnd('\') -ieq $normalised })) {
        $env:Path = "$Directory$separator$env:Path"; Write-Status PASS 'Node.js is available to this setup process immediately.'
    }
    if ($DoNotPersist) { Write-Status INFO 'Test mode: did not save a user PATH entry.'; return }
    $stored = [Environment]::GetEnvironmentVariable('Path', 'User')
    $userEntries = @($stored -split [regex]::Escape([string]$separator) | Where-Object { $_ })
    if ($userEntries | Where-Object { $_.TrimEnd('\') -ieq $normalised }) { Write-Status PASS 'The Node.js folder is already present in your user PATH.'; return }
    try {
        [Environment]::SetEnvironmentVariable('Path', ((@($userEntries) + $Directory) -join $separator), 'User')
        Write-Status PASS 'Added the Node.js folder to your user PATH for future VS Code terminals.'
    }
    catch {
        Write-Status WARN "Node.js works for this setup, but Windows could not save your user PATH: $($_.Exception.Message)"
        Write-Status WARN 'After setup, use a newly opened terminal only if Node.js is available there; otherwise ask your lecturer or IT.'
    }
}

function Get-WindowsArchitecture {
    if (-not [Environment]::Is64BitOperatingSystem) { throw 'This is 32-bit Windows. Tank Arena setup supports 64-bit Windows x64 or ARM64 only.' }
    $architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()
    if ($architecture -notin @('x64', 'arm64')) { throw "Windows architecture '$architecture' is not supported by this setup. Ask your lecturer or IT for Node.js 22.23.2." }
    return $architecture
}

function Test-ArchiveChecksum {
    param([Parameter(Mandatory = $true)][string]$Archive, [Parameter(Mandatory = $true)][string]$ExpectedSha256)
    if (-not (Test-Path -LiteralPath $Archive)) { return $false }
    try { return (Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash -ieq $ExpectedSha256 } catch { return $false }
}

function Get-NodeArchive {
    param([Parameter(Mandatory = $true)][string]$CacheDirectory, [Parameter(Mandatory = $true)][hashtable]$ArchiveInfo)
    New-Item -ItemType Directory -Path $CacheDirectory -Force | Out-Null
    $archive = Join-Path $CacheDirectory $ArchiveInfo.File
    if (Test-ArchiveChecksum -Archive $archive -ExpectedSha256 $ArchiveInfo.Sha256) { Write-Status PASS "Reusing verified Node.js archive: $archive"; return $archive }
    if (Test-Path -LiteralPath $archive) { Write-Status WARN 'The cached Node.js archive is incomplete or has the wrong checksum; downloading a clean copy.'; Remove-Item -LiteralPath $archive -Force }
    $partial = "$archive.download"; if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force }
    $url = "https://nodejs.org/dist/$NodeVersion/$($ArchiveInfo.File)"
    try { Write-Status INFO "Downloading official Node.js $NodeVersion from nodejs.org. This may take a few minutes on a college connection."; Invoke-WebRequest -Uri $url -OutFile $partial -UseBasicParsing }
    catch { if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial -Force }; throw "Node.js could not be downloaded from the official Node.js site. Check the internet connection or college filtering, then run setup again. Original error: $($_.Exception.Message)" }
    if (-not (Test-ArchiveChecksum -Archive $partial -ExpectedSha256 $ArchiveInfo.Sha256)) { Remove-Item -LiteralPath $partial -Force; throw 'The downloaded Node.js archive did not match the published SHA-256 checksum. It was not installed. Retry on a trusted connection and tell your lecturer or IT if this continues.' }
    Move-Item -LiteralPath $partial -Destination $archive -Force; Write-Status PASS 'Downloaded and verified the official Node.js archive.'; return $archive
}

function Install-UserNode22 {
    param([Parameter(Mandatory = $true)][string]$Architecture, [Parameter(Mandatory = $true)][string]$InstallBase, [Parameter(Mandatory = $true)][string]$CacheDirectory)
    $archiveInfo = $NodeArchives[$Architecture]; $installDirectory = Join-Path $InstallBase "$NodeVersion\$Architecture"; $archive = Get-NodeArchive -CacheDirectory $CacheDirectory -ArchiveInfo $archiveInfo
    $parent = Split-Path -Parent $installDirectory; New-Item -ItemType Directory -Path $parent -Force | Out-Null; $staging = Join-Path $parent ".node-extract-$([guid]::NewGuid().ToString('N'))"
    try {
        Write-Status INFO "Extracting Node.js into your user account: $installDirectory"; Expand-Archive -LiteralPath $archive -DestinationPath $staging -Force
        $extractedDirectory = Join-Path $staging ([System.IO.Path]::GetFileNameWithoutExtension($archiveInfo.File)); $nodeExecutable = Join-Path $extractedDirectory 'node.exe'
        if (-not (Test-Path -LiteralPath $nodeExecutable) -or -not (Test-Node22 -NodeCommand $nodeExecutable)) { throw 'The extracted Node.js archive did not contain a working Node 22 executable.' }
        if (Test-Path -LiteralPath $installDirectory) { Remove-Item -LiteralPath $installDirectory -Recurse -Force }
        Move-Item -LiteralPath $extractedDirectory -Destination $installDirectory
    }
    finally { if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force } }
    $installedNode = Join-Path $installDirectory 'node.exe'; if (-not (Test-Node22 -NodeCommand $installedNode)) { throw 'Node.js 22 was not available after extraction. Ask your lecturer or IT to inspect the setup output.' }; return $installedNode
}

function Get-NpmCommand {
    param([Parameter(Mandatory = $true)][string]$NodeCommand)
    $adjacentNpm = Join-Path (Split-Path -Parent $NodeCommand) 'npm.cmd'; if (Test-Path -LiteralPath $adjacentNpm) { return $adjacentNpm }
    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue; if ($null -ne $npm) { return $npm.Source }; throw 'npm.cmd could not be found beside Node.js. The Node.js installation is incomplete; run setup again.'
}

function Invoke-NpmStep {
    param([Parameter(Mandatory = $true)][string]$NpmCommand, [Parameter(Mandatory = $true)][string]$Stage, [Parameter(Mandatory = $true)][string[]]$Arguments)
    Write-Status INFO "${Stage}: npm $($Arguments -join ' ')"; & $NpmCommand @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Stage failed (exit code $LASTEXITCODE). Read the npm output above before trying again." }; Write-Status PASS "$Stage passed."
}

function Test-TankArenaHealth {
    param([Parameter(Mandatory = $true)][string]$NodeCommand, [Parameter(Mandatory = $true)][string]$ProjectRoot)
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0); $listener.Start(); $port = ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port; $listener.Stop(); $server = $null; $previousPort = $env:PORT
    try {
        Write-Status INFO "Starting a short local health check on port $port. The server will stop automatically."
        # Windows PowerShell 5.1 is common in the Dev Lab and does not support
        # Start-Process -Environment. Set this process's PORT only long enough
        # for the child to inherit it, then restore the caller's value.
        $env:PORT = "$port"
        $server = Start-Process -FilePath $NodeCommand -ArgumentList @('server/server.js') -WorkingDirectory $ProjectRoot -PassThru -WindowStyle Hidden
        if ($null -eq $previousPort) { Remove-Item Env:PORT -ErrorAction SilentlyContinue } else { $env:PORT = $previousPort }
        $deadline = (Get-Date).AddSeconds(12)
        do { try { $health = Invoke-RestMethod -Uri "http://127.0.0.1:$port/health" -TimeoutSec 2 -UseBasicParsing; if ($health.status -eq 'ok') { Write-Status PASS 'Application health check passed.'; return } } catch { Start-Sleep -Milliseconds 250 } } while ((Get-Date) -lt $deadline -and -not $server.HasExited)
        throw 'The Tank Arena server did not answer its local /health check within 12 seconds.'
    }
    finally { if ($null -eq $previousPort) { Remove-Item Env:PORT -ErrorAction SilentlyContinue } else { $env:PORT = $previousPort }; if ($null -ne $server -and -not $server.HasExited) { Stop-Process -Id $server.Id -ErrorAction SilentlyContinue; $server.WaitForExit(3000) | Out-Null; Write-Status INFO 'Stopped the temporary health-check server.' } }
}

try {
    $projectRoot = Split-Path -Parent $PSCommandPath; Set-Location -LiteralPath $projectRoot
    Write-Status INFO "Preparing Assessment 2 Tank Arena at: $projectRoot"; Write-Status INFO 'This setup is safe to run again. It reuses a verified Node archive, a working user installation and npm packages where possible.'
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'package.json'))) { throw 'package.json was not found. Open the Assessment-2-Tank-Arena folder and run setup again.' }
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'package-lock.json'))) { throw 'package-lock.json was not found. Copy or clone the complete course folder, then run setup again.' }
    $isWindows = $env:OS -eq 'Windows_NT'; $nodeCommand = $null; Write-Status CHECK "Looking for Node.js 22 (the course-pinned major version; this setup installs $NodeVersion on Windows when needed)."
    $pathNode = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($null -ne $pathNode) { $pathNodeVersion = Get-NodeMajorVersion -NodeCommand $pathNode.Source; if ($null -ne $pathNodeVersion -and $pathNodeVersion.Major -eq 22) { $nodeCommand = $pathNode.Source; Write-Status PASS "Using Node.js $($pathNodeVersion.Version) already available on PATH." } elseif ($null -ne $pathNodeVersion) { Write-Status WARN "Found Node.js $($pathNodeVersion.Version) on PATH, but Assessment 2 is pinned to Node 22 for reproducible teaching." } }
    if ($null -eq $nodeCommand -and $isWindows) {
        $architecture = Get-WindowsArchitecture
        if ([string]::IsNullOrWhiteSpace($NodeInstallRoot)) { $NodeInstallRoot = Join-Path $env:LOCALAPPDATA 'BFC-AGP\node' }
        if ([string]::IsNullOrWhiteSpace($NodeCacheRoot)) { $NodeCacheRoot = Join-Path $env:LOCALAPPDATA 'BFC-AGP\node-cache' }
        $userNode = Join-Path $NodeInstallRoot "$NodeVersion\$architecture\node.exe"
        if (Test-Node22 -NodeCommand $userNode) { $nodeCommand = $userNode; Write-Status PASS "Using existing user-level Node.js $((& $nodeCommand --version).Trim()): $userNode" }
        else { Write-Status CHECK 'A suitable Node 22 installation was not found. Preparing the official current-user installation.'; $nodeCommand = Install-UserNode22 -Architecture $architecture -InstallBase $NodeInstallRoot -CacheDirectory $NodeCacheRoot; Write-Status PASS "Installed Node.js $((& $nodeCommand --version).Trim()) for this user: $(Split-Path -Parent $nodeCommand)" }
        Add-UserPathEntry -Directory (Split-Path -Parent $nodeCommand) -DoNotPersist:$SkipUserPathUpdate
    }
    elseif ($null -eq $nodeCommand) { throw 'Node.js 22 is required. On macOS or Linux, install Node 22 from https://nodejs.org/en/download, reopen your terminal and run setup again.' }
    if (-not (Test-Node22 -NodeCommand $nodeCommand)) { throw 'Node.js 22 could not be verified after setup.' }
    $npmCommand = Get-NpmCommand -NodeCommand $nodeCommand; $npmVersion = (& $npmCommand --version 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($npmVersion)) { throw 'npm did not run correctly after Node.js setup.' }; Write-Status PASS "npm $npmVersion is ready."
    Invoke-NpmStep -NpmCommand $npmCommand -Stage 'Restore locked project packages' -Arguments @('ci'); Invoke-NpmStep -NpmCommand $npmCommand -Stage 'Run automated tests' -Arguments @('test'); Invoke-NpmStep -NpmCommand $npmCommand -Stage 'Run JavaScript syntax checks' -Arguments @('run', 'check')
    if (-not $SkipSmokeTest) { Test-TankArenaHealth -NodeCommand $nodeCommand -ProjectRoot $projectRoot } else { Write-Status WARN 'Skipped the application health check because -SkipSmokeTest was supplied.' }
    Write-Host ''; Write-Status PASS 'ASSESSMENT 2 SETUP COMPLETE'; Write-Status INFO "Node.js: $((& $nodeCommand --version).Trim())"; Write-Status INFO "npm: $npmVersion"; Write-Status INFO 'Dependencies: restored from package-lock.json'; Write-Status INFO 'Tests and syntax checks: passed'; Write-Status INFO 'Run the game with: npm start'; Write-Status INFO 'Then open: http://localhost:3000'; Write-Status INFO 'If VS Code was already open when Node was installed, open a new terminal (or restart VS Code) so it reads the updated user PATH.'
}
catch { Write-Status FAIL $_.Exception.Message; exit 1 }
