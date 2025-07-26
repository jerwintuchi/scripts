# modules/check-nuget.ps1

$nuget = Get-Command "nuget.exe" -ErrorAction SilentlyContinue
Write-Log "Checking for existing NuGet..."
if ($nuget) {
    Write-Log "NuGet already installed  at: $($nuget.Source)"
} else {
    Write-Log "NuGet not found"
    $env:ACS_Install_NuGet = $true
}
