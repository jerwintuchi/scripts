# modules/install-dotnet.ps1

Import-Module utils -ErrorAction Stop

if ($env:ACS_Install_DotNet) {

    # prompt user input for specific dotnet version
    $specificVersion = Read-Host "Enter specific version of .NET to install (e.g., 8.0.0)"
    if ([string]::IsNullOrWhiteSpace($specificVersion)) {
        Write-Host "Specific version cannot be empty. Please try again." -ForegroundColor Red
        continue
    }
    # error handling if invalid version
    if ($specificVersion -notmatch "^\d+\.\d+\.\d+$") {
        Write-Host "Invalid version format. Please try again." -ForegroundColor Red
        continue
    }
    
    if ($specificVersion -lt "8.0.0") {
        Write-Host "Specified version is < 8.0.0. The Azure Trusted Signing Client requires atleast .NET 8 or later." -ForegroundColor Red
        continue
    }

    # Set default fallback install path
    if ([string]::IsNullOrWhiteSpace($env:ACS_DotNet_Install_Path)) {
        $env:ACS_DotNet_Install_Path = "$env:ProgramFiles\dotnet"
    }

    $defaultInstallPath = "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.0/dotnet-runtime-8.0.0-win-x64.exe"
    $specificVersionPath = "https://builds.dotnet.microsoft.com/dotnet/Runtime/$specificVersion/dotnet-runtime-$specificVersion-win-x64.exe"

    $dotnetInstaller = if ($specificVersion) { $specificVersionPath } else { $defaultInstallPath }
    $defaultPath = "$env:TEMP\dotnet-runtime-8.0.0.exe"
    $specificPath = "$env:TEMP\dotnet-runtime-$specificVersion.exe"


    $installPath = if ($specificVersion) { $specificPath } else { $defaultPath }

    Write-Log "Downloading .NET Runtime 8 installer..."
    Invoke-WebRequest -Uri $dotnetInstaller -OutFile $installPath -MaximumRedirection 5
    $hashBefore = Get-FileHashString $installPath
    Write-Log "Installer SHA512: $hashBefore"

    if (-not (Is-ValidExe $installPath)) {
        Write-Log "ERROR: Downloaded file is not a valid executable. Aborting installation."
        return
    }

    Write-Log "Installing .NET Runtime 8..."
    $process = Start-Process -FilePath $installPath -ArgumentList "/passive" -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Log ".NET Runtime $version installed at $(& 'dotnet' --info | Select-String 'Base Path').Line"
        # Graceful installer cleanup
        try {
            Start-Sleep -Seconds 2
            Remove-Item -Path $installPath -Force -ErrorAction Stop
            Write-Log "Installer removed: $installPath"
        }
        catch {
            Write-Log "WARNING: Could not remove installer $installPath - $_"
            Write-Log "Try to remove it manually at $installPath" -ForegroundColor Yellow
        }

    }
    elseif ($process.ExitCode -eq 1602) {
        Write-Log "WARNING: User cancelled .NET Runtime installation. Exit Code 1602"
    }
    elseif ($process.ExitCode -eq 3010) {
        Write-Log "INFO: Installation successful but system restart is required. Exit Code 3010"
    }
    else {
        Write-Log "ERROR: .NET installer exited with code $($process.ExitCode)"
        throw ".NET Runtime installation failed or was cancelled"
    }
}
