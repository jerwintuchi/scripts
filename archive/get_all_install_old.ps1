# Set the output directory (change this as needed)
$outputDirectory = "C:\Audit\InstalledApps"
$outputFile = "installed_apps_list.txt"
$fullPath = Join-Path $outputDirectory $outputFile

# Create the directory if it doesn't exist
if (!(Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force
}

# Get 32-bit installed apps from registry
$apps32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

# Get 64-bit installed apps from registry
$apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

# Optional: Get installed apps via WMI (may be slow and can trigger repair checks)
#$appsWMI = Get-WmiObject -Class Win32_Product | Select-Object Name, Version

# Combine and filter out empty entries
$allApps = $apps32 + $apps64 | Where-Object { $_.DisplayName -ne $null }

# Save to file
$allApps | Sort-Object DisplayName | Out-File -FilePath $fullPath -Encoding UTF8

Write-Output "Installed applications list saved to: $fullPath"
