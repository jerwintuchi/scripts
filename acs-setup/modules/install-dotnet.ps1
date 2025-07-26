# modules/install-dotnet.ps1

if ($env:ACS_Install_DotNet) {
    $dotnetInstaller = "https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-8.0.0-windows-x64-installer"
    $tempPath = "$env:TEMP\dotnet-runtime-8.0.0.exe"
    Write-Log "Downloading .NET Runtime 8 installer..."
    Invoke-WebRequest -Uri $dotnetInstaller -OutFile $tempPath -UseBasicParsing
    Write-Log "Installing .NET Runtime 8..."
    Start-Process -FilePath $tempPath -ArgumentList "/passive" -Wait
    Remove-Item $tempPath
    Write-Log ".NET Runtime 8 installed."
}