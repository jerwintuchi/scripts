# modules/install-dotnet.ps1

Import-Module utils -ErrorAction Stop

if ($env:ACS_Install_DotNet) {
    
    # prompt user input for specific dotnet version
    Write-Host "Azure Trusted Signing Client requires .NET 8 or later."
    $specificVersion = Read-Host "Enter specific version of .NET to install (e.g., 8.0.0)"
    if ([string]::IsNullOrWhiteSpace($specificVersion)) {
        Write-Host "Specific version cannot be empty. Please try again." -ForegroundColor Red
        continue
    }
    # error handling if invalid version
    if ($specificVersion -notmatch "^\d+\.\d+\.\d+(-[a-z]+\.\d+)?$") {
        Write-Host "Invalid version format. Please try again." -ForegroundColor Red
        return
    }

    
    # Compare as version
    $ver = [Version]$specificVersion
    if ($ver -lt [Version]"8.0.0" -or $ver -ge [Version]"11.0.0") {
        # doesn't handle preview versions (UPDATE IF NEEDED)
        Write-Host "Invalid version: Currently supported versions are .NET 8, 9 or 10 only" -ForegroundColor Red
        Write-Host "Visit the .NET download page: https://dotnet.microsoft.com/en-us/download/dotnet for supported versions" -ForegroundColor Yellow
        continue
    }

    # get only major.minor (first two chars)       
    if ($specificVersion -match "^(\d+\.\d+)\.\d+(-[a-z]+\.\d+)?$") {
        $FilteredVersion = $matches[1]
    }
    else {
        Write-Host "Could not extract major.minor from version string." -ForegroundColor Red
        return
    }
    
    
    # Write-Host "Filtered version: $FilteredVersion" For debugging purposes, uncomment to display Filtered Version

    # Set default fallback install path
    if ([string]::IsNullOrWhiteSpace($env:ACS_DotNet_Install_Path)) {
        $env:ACS_DotNet_Install_Path = "$env:ProgramFiles\dotnet"
    }

    # set install path and version for dotnet runtime
    # fallback to default if user input is empty
    $dotnetBaseUrl = "https://dotnetcli.azureedge.net/dotnet/Runtime/8.0.0/dotnet-runtime-8.0.0-win-x64.exe"
    $specificVersionUrl = "https://dotnetcli.azureedge.net/dotnet/Runtime/$specificVersion/dotnet-runtime-$specificVersion-win-x64.exe"
    $blobUrl = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/$FilteredVersion/releases.json"
 
    $dotnetInstaller = if ($specificVersion) { $specificVersionUrl } else { $dotnetBaseUrl }
    $defaultPath = "$env:TEMP\dotnet-runtime-8.0.0.exe"
    $specificPath = "$env:TEMP\dotnet-runtime-$specificVersion.exe"


    $installPath = if ($specificVersion) { $specificPath } else { $defaultPath }

    function Get-InstallerHash {
        param(
            [Parameter(Mandatory)]
            [string]$Url,
            [Parameter(Mandatory)]
            [string]$Version
        )

        $releaseJson = Invoke-RestMethod -Uri $Url -UseBasicParsing

        $matchingRelease = $releaseJson.releases | Where-Object {
            $_.'release-version' -eq $Version
        }

        if (-not $matchingRelease) {
            Write-Log "ERROR: .NET Runtime $Version not found in release metadata." -ForegroundColor Red
            throw "Version $Version not listed in official release metadata."
        }

        $winFile = $matchingRelease.runtime.files | Where-Object {
            $_.rid -eq "win-x64" -and $_.name -like "dotnet-runtime-win-x64.exe"
        }

        if (-not $winFile) {
            Write-Log "ERROR: .NET Runtime win-x64 installer not found in release metadata." -ForegroundColor Red
            throw "win-x64 installer not listed for version $Version."
        }

        return $winFile.hash.ToUpper()
    }




    # download .NET runtime
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $dotnetInstaller -OutFile $installPath -MaximumRedirection 5 -ErrorAction Stop

        # Check Hash of the .NET Runtime installer
        $hashBefore = Get-FileHashString $installPath
        $officialHash = Get-InstallerHash -Url $blobUrl -Version $specificVersion

        
        Write-Log "Validating .NET Runtime installer hash..." -ToConsole
        Write-Log "Installer SHA512: $hashBefore" -ForegroundColor Yellow -ToConsole
        Write-Log "Expected SHA512: $officialHash" -ForegroundColor Yellow -ToConsole

        if ($hashBefore -eq $officialHash) {
            Write-Log ".NET Runtime installer hash is valid" -ForegroundColor Green -ToConsole
            continue
        }
        else {
            Write-Log "ERROR: .NET Runtime installer hash is invalid. Aborting installation." -ForegroundColor Red -ToConsole
            return
        }

        if (-not (Read-ValidExe $installPath)) {
            Write-Log "ERROR: Downloaded file is not a valid executable. Aborting installation." -ForegroundColor Red -ToConsole
            return
        }
    }
    catch {
        if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
            Write-Log "$specificVersion .NET Runtime version does not exist (HTTP 404)." -ForegroundColor Red
            continue
        }
        else {
            Write-Log "ERROR: Failed to download .NET Runtime - $_" -ForegroundColor Red
            throw "Unhandled error during download: $_"
            return
        }
    }

    
    Write-Log "Installing .NET Runtime 8..." -ForegroundColor Yellow
    $process = Start-Process -FilePath $installPath -ArgumentList "/passive" -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Log ".NET Runtime $version installed at $(& 'dotnet' --info | Select-String 'Base Path').Line" -ForegroundColor Green
        # Graceful installer cleanup
        try {
            Start-Sleep -Seconds 2
            Remove-Item -Path $installPath -Force -ErrorAction Stop
            Write-Log "Installer removed: $installPath"
        }
        catch {
            Write-Log "WARNING: Could not remove installer $installPath - $_" -ForegroundColor Yellow
            Write-Log "Try to remove it manually at $installPath" -ForegroundColor Yellow
        }

    }
    elseif ($process.ExitCode -eq 1602) {
        Write-Log "WARNING: User cancelled .NET Runtime installation. Exit Code 1602" -ForegroundColor Yellow
        return
    }
    elseif ($process.ExitCode -eq 3010) {
        Write-Log "INFO: Installation successful but system restart is required. Exit Code 3010" -ForegroundColor Yellow
    }
    else {
        Write-Log "ERROR: .NET installer exited with code $($process.ExitCode)" -ForegroundColor Red
        throw ".NET Runtime installation failed or was cancelled"
    }
}

