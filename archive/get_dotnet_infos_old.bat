@echo off
setlocal

:: Set the audit directory path
set "AUDIT_DIR=C:\Audit\DotnetInfo"

:: Create the directory if it doesn't exist
if not exist "%AUDIT_DIR%" (
    mkdir "%AUDIT_DIR%"
)

:: Log file paths
set "INFO_FILE=%AUDIT_DIR%\dotnet_info.txt"
set "RUNTIME_FILE=%AUDIT_DIR%\dotnet_runtimes.txt"

:: Check if dotnet is available
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] dotnet CLI is not installed or not in PATH.
    echo Please install .NET before running this script.
    exit /b 1
)

:: Dump .NET SDK and environment info
echo [INFO] Saving output of dotnet --info to %INFO_FILE%
dotnet --info > "%INFO_FILE%"

:: Dump installed runtimes
echo [INFO] Saving output of dotnet --list-runtimes to %RUNTIME_FILE%
dotnet --list-runtimes > "%RUNTIME_FILE%"

echo.
echo [SUCCESS] .NET audit complete. Files saved in:
echo   %INFO_FILE%
echo   %RUNTIME_FILE%

endlocal
pause
