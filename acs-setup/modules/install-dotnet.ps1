# modules/install-dotnet.ps1

if ($env:ACS_Install_DotNet) {
    $dotnetInstaller = "https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-8.0.0-windows-x64-installer"
    $tempPath = "$env:TEMP\dotnet-runtime-8.0.0.exe"
    Write-Log "Downloading .NET Runtime 8 installer..."
    Invoke-WebRequest -Uri $dotnetInstaller -OutFile $tempPath -MaximumRedirection 5
    $hashBefore = Get-FileHashString $tempPath
    Write-Log "Installer SHA256: $hashBefore"

    if (-not (Is-ValidExe $tempPath)) {
        Write-Log "ERROR: Downloaded file is not a valid executable. Aborting installation."
        return
    }

    Write-Log "Installing .NET Runtime 8..."
    Start-Process -FilePath $tempPath -ArgumentList "/passive" -Wait
    Remove-Item $tempPath

    $dotnetPath = Get-Command dotnet | Select-Object -ExpandProperty Source
    if ($dotnetPath) {
        Write-Log ".NET Runtime 8 installed at $dotnetPath"
    } else {
        Write-Log ".NET Runtime 8 installed, but location could not be confirmed."
    }
}
