# modules/install-nuget.ps1

if ($env:ACS_Install_NuGet) {
    $targetPath = $env:ACS_NuGet_Install_Path
    if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath | Out-Null }
    $nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    $destination = Join-Path $targetPath "nuget.exe"
    Write-Log "Downloading NuGet CLI to $destination"
    Invoke-WebRequest $nugetUrl -OutFile $destination -UseBasicParsing
    if (Test-Path $destination) {
        Write-Log "NuGet CLI installed at $destination"
        $env:PATH += ";$targetPath"
    } else {
        Write-Log "Failed to install NuGet CLI."
    }
}