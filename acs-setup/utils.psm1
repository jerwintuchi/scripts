# utils.psm1
function Get-InstalledComponents {
    # Query the registry for installed programs
    $installedPrograms = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    # Create an array to store the list of installed components
    $installedComponents = @()
    foreach ($program in $installedPrograms) {
        $installedComponents += $program.GetValue("DisplayName")
    }
    return $installedComponents
}

function Get-ComponentName {
    param ($componentName)
    $installedComponents = Get-InstalledComponents
    if ($installedComponents -contains $componentName) {
        return $true
    }
    else {
        return $false
    }
}

function Test-ComponentInstalled {
    param (
        [Parameter(Mandatory)]
        [string]$Name, # Name of the component

        [string[]]$ExpectedPaths = @(), # Optional custom paths for portable tools

        [switch]$CheckCommand, # Check if executable is in PATH

        [switch]$CheckRegistry, # Check registry for installed apps

        [switch]$SearchCommonDirs, # NEW: look in common install folders like BuildTools, etc

        [switch]$VerboseOutput = $false
    )
    if ($VerboseOutput) {
        Write-Host " Checking component: $Name" -ForegroundColor Cyan
    }

    $found = $false

    if ($VerboseOutput) {
        Write-Host "Checking: $Name"
    }

    if ($CheckCommand) {
        try {
            $command = Get-Command $Name -ErrorAction Stop
            if ($command) {
                if ($VerboseOutput) { Write-Host "Found command: $($command.Source)" }
                $found = $true
            }
        }
        catch {
            if ($VerboseOutput) { Write-Host "Command not found in PATH." }
        }
    }

    if (-not $found -and $CheckRegistry) {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        )
        foreach ($regPath in $regPaths) {
            if (Test-Path $regPath) {
                $entries = Get-ChildItem -Path $regPath | ForEach-Object {
                    $_.GetValue("DisplayName")
                } | Where-Object { $_ -and $_ -match $Name }

                if ($entries.Count -gt 0) {
                    if ($VerboseOutput) { Write-Host "Found in registry: $($entries -join ', ')" -ForegroundColor Green }
                    $found = $true
                    break
                }
                else {
                    if ($VerboseOutput) { Write-Host "Not found in registry." }
                }
            }
        }
    }

    if (-not $found -and $ExpectedPaths.Count -gt 0) {
        foreach ($path in $ExpectedPaths) {
            if (Test-Path $path) {
                if ($VerboseOutput) { Write-Host "Found at expected path: $path" -ForegroundColor Green }
                $found = $true
                break
            }
        }

        if (-not $found -and $VerboseOutput) {
            Write-Host "Not found at any expected paths." -ForegroundColor Red
        }
    }

    if (-not $found -and $SearchCommonDirs) {
        $commonDirs = @(
            "C:\BuildTools\NuGet-*", 
            "C:\ProgramData\chocolatey\bin",
            "C:\Tools", 
            "C:\NuGet", 
            "C:\DevTools"
        )

        foreach ($dir in $commonDirs) {
            Write-Host "Scanning $dir"
            if (Test-Path $dir) {
                try {
                    $match = Get-ChildItem -Path $dir -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "$Name.exe" } |
                    Where-Object { $_.Length -lt 10MB }

                    if ($match.Count -gt 0) {
                        if ($VerboseOutput) { Write-Host "Found in common dir: $($match[0].FullName)" -ForegroundColor Green }
                        $found = $true
                        break
                    }
                }
                catch {
                    if ($VerboseOutput) { Write-Host "Error scanning $dir : $_" -ForegroundColor Red }
                }
            }
        }

        if (-not $found -and $VerboseOutput) {
            Write-Host "Not found in any common install directories." -ForegroundColor Red
        }
    }

    return $found
}


function Get-FileHashString {
    param([string]$Path)
    if (Test-Path $Path) {
        return (Get-FileHash -Path $Path -Algorithm SHA512).Hash
    }
    return ""
}

function Read-ValidExe {
    param([string]$Path)
    try {
        $output = & $Path /?
        return $true
    }
    catch {
        return $false
    }
}
