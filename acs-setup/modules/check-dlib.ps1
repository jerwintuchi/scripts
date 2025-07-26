# modules/check-dlib.ps1

$dlibCheck = Get-Command "azts" -ErrorAction SilentlyContinue
if ($dlibCheck) {
    Write-Log "Trusted Signing Client (azts) is available at $($dlibCheck.Source)"
} else {
    Write-Log "Trusted Signing Client (azts) not found."
    $env:ACS_Install_Dlib = $true
}