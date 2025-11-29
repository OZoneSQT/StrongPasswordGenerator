@echo off
REM Run JS tests with Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Node.js not found. Please install Node to run JS tests.
  exit /b 1
)
node "%~dp0root\tests\pw.test.js"
