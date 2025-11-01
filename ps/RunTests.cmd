@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Set-Location 'src\'; $result = Invoke-Pester -Path 'tests' -PassThru; if ($result.FailedCount -gt 0) { exit 1 } else { exit 0 }"
endlocal
pause