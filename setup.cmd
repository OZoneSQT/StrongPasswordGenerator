@echo off
REM Wrapper to run the PowerShell setup script with bypassed execution policy
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if %ERRORLEVEL% NEQ 0 (
  echo Setup encountered errors.
  exit /b %ERRORLEVEL%
)
exit /b 0
