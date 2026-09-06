$ErrorActionPreference = "Stop"

function Status([string]$label, [string]$message) { Write-Host "[$label] $message" }

Status "CHECK" "Checking that this is the Tank Arena folder..."
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot "package.json"))) {
    Status "FAIL" "package.json was not found. Open the Assessment-2-Tank-Arena folder and run setup again."
    exit 1
}

Status "CHECK" "Checking Node.js 22..."
try { $nodeVersion = (& node --version 2>$null).Trim() } catch { $nodeVersion = $null }
if (-not $nodeVersion) {
    Status "FAIL" "Node.js was not found. Install Node 22 LTS from https://nodejs.org/, reopen Visual Studio Code, then run this script again."
    exit 1
}
if ($nodeVersion -notmatch '^v22\.') {
    Status "FAIL" "Found Node.js $nodeVersion. This teaching baseline requires Node 22. Ask your lecturer or IT for the approved Node 22 installation route."
    exit 1
}
Status "PASS" "Found Node.js $nodeVersion."

Status "CHECK" "Checking npm..."
try { $npmVersion = (& npm --version 2>$null).Trim() } catch { $npmVersion = $null }
if (-not $npmVersion) { Status "FAIL" "npm was not found even though Node is installed. Reinstall Node 22 through the approved route."; exit 1 }
Status "PASS" "Found npm $npmVersion."

Set-Location -LiteralPath $PSScriptRoot
Status "INFO" "Installing the locked project dependencies. This can take a few minutes on a college network..."
& npm ci
if ($LASTEXITCODE -ne 0) { Status "FAIL" "npm ci failed. Keep the full error visible and see README.md > Troubleshooting."; exit $LASTEXITCODE }
Status "PASS" "Dependencies installed."

Status "CHECK" "Running the automated checks..."
& npm test
if ($LASTEXITCODE -ne 0) { Status "FAIL" "Tests failed. Do not continue until the error is understood."; exit $LASTEXITCODE }
& npm run check
if ($LASTEXITCODE -ne 0) { Status "FAIL" "Syntax check failed. Do not continue until the error is understood."; exit $LASTEXITCODE }
Status "PASS" "Tank Arena is ready. Run npm start, then open http://localhost:3000."
