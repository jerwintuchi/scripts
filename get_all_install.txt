# Set output directory
$outputDirectory = "C:\Audit\InstalledApps"
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

# Get current timestamp in yyyy-MM-dd-HHmm format
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"

# Set output filename with timestamp
$outputFile = "installed_apps_$timestamp.txt"
$fullPath = Join-Path $outputDirectory $outputFile

# Collect installed apps from 32-bit and 64-bit registry
$apps32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

$apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

# Combine and clean
$allApps = $apps32 + $apps64 | Where-Object { $_.DisplayName -ne $null }

# Save to file
$allApps | Sort-Object DisplayName | Out-File -FilePath $fullPath -Encoding UTF8

Write-Host "[SUCCESS] Installed applications list saved to:"
Write-Host "  $fullPath"
