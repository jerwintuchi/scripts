# modules/check-sdk.ps1

$sdkPath = Get-Command "signtool.exe" -ErrorAction SilentlyContinue
if ($sdkPath) {
    Write-Log "Windows SDK SignTool is available: $($sdkPath.Source)"
} else {
    Write-Log "Windows SDK SignTool not found."
    $env:ACS_Install_SDK = $true
}