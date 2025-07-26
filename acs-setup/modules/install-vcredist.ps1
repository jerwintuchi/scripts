# modules/install-vcredist.ps1

if ($env:ACS_Install_VCRedist) {
    $vcUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
    $tempPath = "$env:TEMP\vc_redist.x64.exe"
    Write-Log "Downloading Visual C++ Redistributable..."
    Invoke-WebRequest -Uri $vcUrl -OutFile $tempPath -UseBasicParsing
    Start-Process -FilePath $tempPath -ArgumentList "/passive /norestart" -Wait
    Remove-Item $tempPath
    Write-Log "Visual C++ Redistributable installed."
}