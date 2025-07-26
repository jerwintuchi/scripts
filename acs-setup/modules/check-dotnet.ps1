# modules/check-dotnet.ps1

$dotnet = Get-Command "dotnet" -ErrorAction SilentlyContinue
if ($dotnet) {
    $version = (& $dotnet --version)
    if ($version -like "8.*") {
        Write-Log ".NET 8 is installed: version $version"
    } else {
        Write-Log ".NET found, but not version 8+: $version"
        $env:ACS_Install_DotNet = $true
    }
} else {
    Write-Log ".NET not found."
    $env:ACS_Install_DotNet = $true
}