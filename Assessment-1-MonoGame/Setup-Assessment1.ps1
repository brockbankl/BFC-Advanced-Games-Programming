[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Write-Status {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('CHECK', 'PASS', 'INFO', 'WARN', 'FAIL')][string]$Kind,
        [Parameter(Mandatory = $true)][string]$Message
    )

    Write-Host "[$Kind] $Message"
}

function Test-DotNet10Sdk {
    param([Parameter(Mandatory = $true)][string]$Command)

    try {
        $sdks = & $Command --list-sdks 2>$null
        return $LASTEXITCODE -eq 0 -and ($sdks -match '(?m)^\s*10\.\d+\.\d+\s+\[')
    }
    catch {
        return $false
    }
}

function Add-UserDotNetPath {
    param([Parameter(Mandatory = $true)][string]$InstallDirectory)

    $separator = [System.IO.Path]::PathSeparator
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $pathEntries = @($currentPath -split [regex]::Escape([string]$separator) | Where-Object { $_ })

    if ($pathEntries -notcontains $InstallDirectory) {
        $newPath = (@($pathEntries) + $InstallDirectory) -join $separator
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    }

    [Environment]::SetEnvironmentVariable('DOTNET_ROOT', $InstallDirectory, 'User')
    $env:DOTNET_ROOT = $InstallDirectory
    $env:Path = "$InstallDirectory$separator$env:Path"
}

function Install-UserDotNet10Sdk {
    param([Parameter(Mandatory = $true)][string]$InstallDirectory)

    Write-Status CHECK 'A .NET 10 SDK was not found. Attempting an official user-level installation.'
    New-Item -ItemType Directory -Path $InstallDirectory -Force | Out-Null

    $installerPath = Join-Path $env:TEMP 'bfc-agp-dotnet-install.ps1'
    try {
        Invoke-WebRequest -Uri 'https://dot.net/v1/dotnet-install.ps1' -OutFile $installerPath -UseBasicParsing
        & $installerPath -Channel '10.0' -Quality 'GA' -InstallDir $InstallDirectory -NoPath
        if ($LASTEXITCODE -ne 0) {
            throw "The official .NET installer exited with code $LASTEXITCODE."
        }
    }
    finally {
        if (Test-Path -LiteralPath $installerPath) {
            Remove-Item -LiteralPath $installerPath -Force
        }
    }

    Add-UserDotNetPath -InstallDirectory $InstallDirectory
    $candidate = Join-Path $InstallDirectory 'dotnet.exe'
    if (-not (Test-Path -LiteralPath $candidate) -or -not (Test-DotNet10Sdk -Command $candidate)) {
        throw 'A compatible .NET 10 SDK was not available after installation. Ask college IT to install the .NET 10 SDK, then run this setup again.'
    }

    return $candidate
}

function Invoke-DotNetStep {
    param(
        [Parameter(Mandatory = $true)][string]$DotNetCommand,
        [Parameter(Mandatory = $true)][string]$Stage,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    Write-Status INFO "${Stage}: dotnet $($Arguments -join ' ')"
    & $DotNetCommand @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Stage failed (exit code $LASTEXITCODE)."
    }
}

try {
    $projectRoot = Split-Path -Parent $PSCommandPath
    Set-Location -LiteralPath $projectRoot
    Write-Status INFO "Preparing Assessment 1 at: $projectRoot"

    $isWindows = $env:OS -eq 'Windows_NT'
    $platformProject = if ($isWindows) { 'WindowsDX/Platformer3D.csproj' } else { 'DesktopGL/Platformer3D.csproj' }
    $platformName = if ($isWindows) { 'WindowsDX' } else { 'DesktopGL' }
    Write-Status PASS "Operating-system target: $platformName"

    Write-Status CHECK 'Looking for a compatible .NET 10 SDK.'
    $dotnetCommand = $null
    $systemDotNet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($null -ne $systemDotNet -and (Test-DotNet10Sdk -Command $systemDotNet.Source)) {
        $dotnetCommand = $systemDotNet.Source
        Write-Status PASS "Using installed .NET SDK: $((& $dotnetCommand --version).Trim())"
    }
    elseif ($isWindows) {
        $userDotNetDirectory = Join-Path $env:LOCALAPPDATA 'BFC-AGP\dotnet'
        $userDotNet = Join-Path $userDotNetDirectory 'dotnet.exe'
        if (Test-Path -LiteralPath $userDotNet -and (Test-DotNet10Sdk -Command $userDotNet)) {
            Add-UserDotNetPath -InstallDirectory $userDotNetDirectory
            $dotnetCommand = $userDotNet
            Write-Status PASS "Using existing user-level .NET SDK: $((& $dotnetCommand --version).Trim())"
        }
        else {
            $dotnetCommand = Install-UserDotNet10Sdk -InstallDirectory $userDotNetDirectory
            Write-Status PASS "Installed user-level .NET SDK: $((& $dotnetCommand --version).Trim())"
        }
    }
    else {
        throw 'A .NET 10 SDK is required. Install it from https://dotnet.microsoft.com/download/dotnet/10.0 and run this setup again.'
    }

    $codeCommand = Get-Command code -ErrorAction SilentlyContinue
    if ($null -eq $codeCommand) {
        Write-Status WARN 'The VS Code command-line tool was not found. Install these extensions manually: ms-dotnettools.csdevkit, timgjones.hlsltools.'
    }
    else {
        foreach ($extension in @('ms-dotnettools.csdevkit', 'timgjones.hlsltools')) {
            Write-Status INFO "Checking VS Code extension: $extension"
            & $codeCommand.Source --install-extension $extension | Write-Output
            if ($LASTEXITCODE -eq 0) {
                Write-Status PASS "VS Code extension ready: $extension"
            }
            else {
                Write-Status WARN "Could not install $extension automatically. Install it from VS Code Extensions and continue."
            }
        }
    }

    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage 'Restore Content' -Arguments @('restore', './Content/Content.csproj')
    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage "Restore $platformName" -Arguments @('restore', "./$platformProject")
    Invoke-DotNetStep -DotNetCommand $dotnetCommand -Stage "Build $platformName" -Arguments @('build', "./$platformProject", '--no-restore')

    Write-Host ''
    Write-Status PASS 'ASSESSMENT 1 SETUP COMPLETE'
    Write-Status INFO "Run the game with: dotnet run --project ./$platformProject"
}
catch {
    Write-Status FAIL $_.Exception.Message
    exit 1
}
