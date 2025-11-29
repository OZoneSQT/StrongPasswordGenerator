<#
Setup script for StrongPasswordGenerator
- Ensures Node.js is installed (attempts winget if available)
- Runs `npm install`
- Ensures Pester PowerShell module is installed for tests
- Shows next steps
#>

param(
    [switch]$NonInteractive
)

function Write-Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Warning $msg }
function Write-Ok($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Info "Checking for Node.js..."
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Warn "Node.js not found in PATH. Attempting automated install via winget (if available)."
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Info "Attempting elevated winget install: OpenJS.NodeJS.LTS"
        $args = 'install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements'
        try {
            Start-Process -FilePath $winget.Path -ArgumentList $args -Verb RunAs -Wait -NoNewWindow
            Start-Sleep -Seconds 2
            $node = Get-Command node -ErrorAction SilentlyContinue
            if ($node) { Write-Ok "Node installed." } else { Write-Warn "Node installation attempted but 'node' not found on PATH. You may need to restart your shell." }
        } catch {
            Write-Warn "Elevated winget install failed or was cancelled: $($_.Exception.Message)"
            Write-Host "winget install failed. Attempting fallback: download and run Node LTS MSI installer." -ForegroundColor Yellow
            try {
                Write-Info "Fetching Node index to determine latest LTS version..."
                $index = Invoke-RestMethod -Uri 'https://nodejs.org/dist/index.json' -UseBasicParsing -ErrorAction Stop
                $ltsEntry = $index | Where-Object { $_.lts -ne $null -and $_.lts -ne $false } | Select-Object -First 1
                if (-not $ltsEntry) { throw "No LTS entry found in Node index.json" }
                $version = $ltsEntry.version

                # Determine architecture (x64 or arm64) for the MSI filename
                $arch = 'x64'
                try {
                    $procArch = $env:PROCESSOR_ARCHITECTURE
                    if ($procArch -match 'ARM' -or $procArch -match 'ARM64') { $arch = 'arm64' }
                } catch { $arch = 'x64' }

                $msiFileName = "node-$version-$arch.msi"
                $msiUrl = "https://nodejs.org/dist/$version/$msiFileName"
                $outPath = Join-Path $env:TEMP $msiFileName
                Write-Info "Downloading $msiUrl to $outPath"
                Invoke-WebRequest -Uri $msiUrl -OutFile $outPath -UseBasicParsing -ErrorAction Stop

                # Verify checksum using SHASUMS256.txt from the same dist directory
                try {
                    $shasumsUrl = "https://nodejs.org/dist/$version/SHASUMS256.txt"
                    Write-Info "Fetching SHASUMS256.txt for verification..."
                    $shasums = Invoke-RestMethod -Uri $shasumsUrl -UseBasicParsing -ErrorAction Stop
                    $expectedLine = ($shasums -split "`n") | Where-Object { $_ -match [regex]::Escape($msiFileName) } | Select-Object -First 1
                    if (-not $expectedLine) { Write-Warn "Checksum entry for $msiFileName not found in SHASUMS256.txt; skipping verification." }
                    else {
                        $expectedHash = ($expectedLine -split ' ')[0].Trim()
                        $actualHash = (Get-FileHash -Path $outPath -Algorithm SHA256).Hash.ToLower()
                        if ($actualHash -ne $expectedHash.ToLower()) {
                            throw "Checksum mismatch for downloaded MSI. Expected $expectedHash but got $actualHash"
                        } else { Write-Ok "MSI checksum verified." }
                    }
                } catch {
                    Write-Warn "Checksum verification failed or skipped: $($_.Exception.Message)"
                    if (-not $NonInteractive) {
                        Write-Host "Proceed with installation despite checksum warning? (Y/N)" -ForegroundColor Yellow
                        $resp = Read-Host
                        if ($resp -notin @('Y','y')) { throw 'User aborted due to checksum verification failure.' }
                    } else {
                        Write-Warn "Non-interactive mode: proceeding despite checksum warning."
                    }
                }

                Write-Info "Running MSI installer elevated (silent)..."
                Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$outPath`" /qn /norestart" -Verb RunAs -Wait
                Start-Sleep -Seconds 2
                $node = Get-Command node -ErrorAction SilentlyContinue
                if ($node) { Write-Ok "Node installed via MSI." } else { Write-Warn "MSI ran but 'node' not found on PATH. You may need to restart your shell." }
            } catch {
                Write-Warn "Fallback MSI install failed: $($_.Exception.Message)"
                Write-Host "If automated install failed, please install Node.js LTS manually from https://nodejs.org/ or install nvm-windows and re-run this script." -ForegroundColor Yellow
                Write-Host "Press ENTER after installing Node to continue, or Ctrl+C to abort."; Read-Host > $null
                $node = Get-Command node -ErrorAction SilentlyContinue
            }
        }
    } else {
        Write-Warn "winget not available. Please install Node.js LTS manually from https://nodejs.org/ or install nvm-windows and re-run this script."
        Write-Host "Press ENTER after installing Node to continue, or Ctrl+C to abort."; Read-Host > $null
        $node = Get-Command node -ErrorAction SilentlyContinue
    }
} else {
    Write-Ok "Node.js found: $($node.Path)"
}

if (-not $node) {
    Write-Warn "Node.js is required to run JS tests and `npm install`. Exiting setup.";
    exit 1
}

# Run npm install
Write-Info "Running npm install..."
try {
    npm install
    Write-Ok "npm install completed."
} catch {
    Write-Warn "npm install failed: $($_.Exception.Message)"
}

# Ensure Pester is installed
Write-Info "Checking for Pester PowerShell module..."
$pester = Get-Module -ListAvailable -Name Pester
if (-not $pester) {
    Write-Info "Pester not found. Installing from PSGallery (CurrentUser scope)."
    try {
        Install-Module -Name Pester -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Ok "Pester installed."
    } catch {
        Write-Warn "Failed to install Pester: $($_.Exception.Message)"
        Write-Host "You can install Pester manually by running: Install-Module -Name Pester -Scope CurrentUser -Force"
    }
} else {
    Write-Ok "Pester installed (version $($pester.Version))."
}

Write-Host "\nSetup complete. Next steps:"
Write-Host " - Run JS tests: npm test" -ForegroundColor Yellow
Write-Host " - Run PowerShell tests: .\ps\RunTests.cmd" -ForegroundColor Yellow
Write-Host " - To run both: .\RunJsTests.cmd && .\ps\RunTests.cmd" -ForegroundColor Yellow

exit 0
