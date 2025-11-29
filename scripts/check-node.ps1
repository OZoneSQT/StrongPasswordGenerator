<#
Check Node.js installation and provide installation instructions for Windows.

Usage: From repository root in PowerShell:
  .\scripts\check-node.ps1
#>
Write-Host "Checking for Node.js and npm..." -ForegroundColor Cyan

function Cmd-Exists($name) {
    return (Get-Command $name -ErrorAction SilentlyContinue) -ne $null
}

$node = $null
try {
    $node = & node -v 2>$null
} catch { }

if ($node) {
    Write-Host "Node version:" $node -ForegroundColor Green
    try { $npm = & npm -v 2>$null } catch { $npm = $null }
    if ($npm) { Write-Host "npm version:" $npm -ForegroundColor Green }
    Write-Host "You're ready to run the JS tests: .\RunJsTests.cmd" -ForegroundColor Yellow
    exit 0
}

Write-Host "Node.js not found on PATH." -ForegroundColor Yellow

if (Cmd-Exists winget) {
    Write-Host "You can install Node.js LTS using winget:" -ForegroundColor Cyan
    Write-Host "  winget install --id OpenJS.NodeJS.LTS -e" -ForegroundColor White
    Write-Host "Then re-open PowerShell and run: node -v" -ForegroundColor Gray
    exit 2
}

if (Cmd-Exists choco) {
    Write-Host "You can install Node.js LTS using Chocolatey:" -ForegroundColor Cyan
    Write-Host "  choco install nodejs-lts -y" -ForegroundColor White
    Write-Host "Then re-open PowerShell and run: node -v" -ForegroundColor Gray
    exit 2
}

Write-Host "No package manager (winget/choco) detected. Install Node.js manually:" -ForegroundColor Cyan
Write-Host "- Visit: https://nodejs.org/en/download/ and download the Windows LTS (MSI) installer." -ForegroundColor White
Write-Host "- Run the MSI, accept defaults, then re-open PowerShell and run: node -v" -ForegroundColor Gray

Write-Host "If you prefer an automated installer and have administrative rights, install winget or Chocolatey first." -ForegroundColor Magenta
Write-Host "To check your PATH in PowerShell run: echo $env:Path" -ForegroundColor Gray

exit 3
