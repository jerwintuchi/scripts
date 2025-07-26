# modules/check-vcredist.ps1

$vcChecks = @("2015", "2017", "2019", "2022")
$found = $false
foreach ($version in $vcChecks) {
    $product = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Visual C++%Redistributable%$version%'" -ErrorAction SilentlyContinue
    if ($product) {
        Write-Log "Microsoft Visual C++ Redistributable $version is installed."
        $found = $true
        break
    }
}
if (-not $found) {
    Write-Log "No suitable Microsoft Visual C++ Redistributable (2015-2022) found."
    $env:ACS_Install_VCRedist = $true
}