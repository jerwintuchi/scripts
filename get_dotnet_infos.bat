@echo off
setlocal enabledelayedexpansion

:: Set the audit directory path
set "AUDIT_DIR=C:\Audit\DotnetInfo"

:: Create the directory if it doesn't exist
if not exist "%AUDIT_DIR%" (
    mkdir "%AUDIT_DIR%"
)

:: Get current date and time components
for /f "tokens=1-3 delims=/" %%a in ("%date%") do (
    set "mm=%%a"
    set "dd=%%b"
    set "yyyy=%%c"
)

for /f "tokens=1-2 delims=: " %%a in ("%time%") do (
    set "hh=%%a"
    set "min=%%b"
)

:: Format hour if needed (e.g., 8 becomes 08)
if 1%!hh! LSS 110 set "hh=0!hh!"

:: Build timestamp string in format: yyyy-mm-dd-hhmm
set "timestamp=%yyyy%-%mm%-%dd%-%hh%%min%"

:: File output paths
set "INFO_FILE=%AUDIT_DIR%\dotnet_info_%timestamp%.txt"
set "RUNTIME_FILE=%AUDIT_DIR%\dotnet_runtimes_%timestamp%.txt"

:: Check if dotnet CLI is available
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] dotnet CLI is not installed or not in PATH.
    exit /b 1
)

:: Save outputs
echo [INFO] Saving dotnet --info to: %INFO_FILE%
dotnet --info > "%INFO_FILE%"

echo [INFO] Saving dotnet --list-runtimes to: %RUNTIME_FILE%
dotnet --list-runtimes > "%RUNTIME_FILE%"

echo.
echo [SUCCESS] .NET audit completed.
echo Files saved:
echo  - %INFO_FILE%
echo  - %RUNTIME_FILE%

endlocal
pause
