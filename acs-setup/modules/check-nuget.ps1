# modules/check-nuget.ps1

$nuget = Get-Command "nuget.exe" -ErrorAction SilentlyContinue
if ($nuget) {
    Write-Log "NuGet CLI is already installed at: $($nuget.Source)"
} else {
    Write-Log "NuGet CLI not found."
    $env:ACS_Install_NuGet = $true
}