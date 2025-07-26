# modules/install-sdk.ps1

if ($env:ACS_Install_SDK) {
    $installPath = if ($env:ACS_SDK_Install_Path) { $env:ACS_SDK_Install_Path } else { "$env:ProgramFiles\Windows Kits\10" }
    $version = if ($env:ACS_SDK_Version) { $env:ACS_SDK_Version } else { "10.0.22621.755" }
    if (-not (Test-Path $installPath)) { New-Item -ItemType Directory -Path $installPath | Out-Null }
    $pkgId = "Microsoft.Windows.SDK.SigningTools.$version"
    $nugetArgs = "install $pkgId -OutputDirectory `"$installPath`" -Verbosity detailed"
    Write-Log "Installing Windows SDK $version to $installPath using NuGet..."
    & nuget.exe $nugetArgs
    Write-Log "Windows SDK installation completed."
}