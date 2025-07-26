$packages = @(
    "Microsoft.Windows.SDK.BuildTools",
    "Microsoft.Trusted.Signing.Client"
)

$searchRoot = "D:\"  # Change to correct base path

foreach ($pkg in $packages) {
    $found = Get-ChildItem -Path $searchRoot -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "$pkg*" }

    if ($found) {
        Write-Host "[FOUND] $pkg at:"
        $found.FullName
    } else {
        Write-Host "[MISSING] $pkg not found in $searchRoot"
    }
}
