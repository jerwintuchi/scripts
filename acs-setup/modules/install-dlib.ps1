# modules/install-dlib.ps1

if ($env:ACS_Install_Dlib) {
    $installPath = if ($env:ACS_Dlib_Install_Path) { $env:ACS_Dlib_Install_Path } else { "$env:ProgramFiles\TrustedSigningClient" }
    $version = if ($env:ACS_Dlib_Version) { $env:ACS_Dlib_Version } else { "latest" }
    if (-not (Test-Path $installPath)) { New-Item -ItemType Directory -Path $installPath | Out-Null }
    $pkgId = if ($version -eq "latest") { "Microsoft.TrustedSigning.Client" } else { "Microsoft.TrustedSigning.Client.$version" }
    $nugetArgs = "install $pkgId -OutputDirectory `"$installPath`" -Verbosity detailed"
    Write-Log "Installing Trusted Signing Client ($version) to $installPath using NuGet..."
    & nuget.exe $nugetArgs
    Write-Log "Trusted Signing Client installation completed."
}