# modules/check-nuget.ps1
Import-Module utils -ErrorAction Stop

if (-not (Test-ComponentInstalled -Name "nuget" -ExpectedPaths @("C:\BuildTools") -VerboseOutput -CheckRegistry -CheckCommand)) {
    $env:ACS_Install_NuGet = $true
    Write-Log "NuGet not found. Marked for install."
} else {
    Write-Log "NuGet is already installed."
}

