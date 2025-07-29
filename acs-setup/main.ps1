# ACS-Setup/main.ps1
Import-Module utils # Import the utils.psm1 module

$LogDir = "$(Split-Path -Path $MyInvocation.MyCommand.Definition)/logs"
$LogFile = "$LogDir/acs-install.log"
$ModulesPath = "$(Split-Path -Path $MyInvocation.MyCommand.Definition)/modules"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -Append -FilePath $LogFile
}

# Initialize summary
$Summary = @{}

Write-Log "Starting ACS setup check"

# Import & Run Checks
. "$ModulesPath/check-nuget.ps1"

# Install NuGet if needed
if ($env:ACS_Install_NuGet) {
    . "$ModulesPath/install-nuget.ps1"
}

. "$ModulesPath/check-dotnet.ps1"

if ($env:ACS_Install_DotNet) {
    . "$ModulesPath/install-dotnet.ps1"
}

. "$ModulesPath/check-vcredist.ps1"
. "$ModulesPath/check-sdk.ps1"
. "$ModulesPath/check-dlib.ps1"

# Prompt for install locations if needed (after NuGet installed)
if ($env:ACS_Install_SDK) {
    $env:ACS_SDK_Install_Path = Read-Host "Enter path to install Windows SDK (leave blank for default)"
    $env:ACS_SDK_Version = Read-Host "Enter SDK version to install (or leave blank for latest)"
}
if ($env:ACS_Install_Dlib) {
    $env:ACS_Dlib_Install_Path = Read-Host "Enter install directory for Trusted Signing Client (azts, leave blank for default)"
    $env:ACS_Dlib_Version = Read-Host "Enter version of azts to install (or leave blank for latest)"
}

# Import & Run Installations if missing
. "$ModulesPath/install-vcredist.ps1"
. "$ModulesPath/install-sdk.ps1"
. "$ModulesPath/install-dlib.ps1"

Write-Log "ACS setup completed"

