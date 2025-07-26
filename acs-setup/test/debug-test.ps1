# debug-test.ps1 - Simple debug test

Write-Host "=== ACS Setup Debug Test ===" -ForegroundColor Green

# Test 1: Check files
Write-Host "`n1. Checking file structure..." -ForegroundColor Yellow
$currentDir = Get-Location
Write-Host "Current directory: $currentDir"

$files = @("main.ps1", "modules/check-nuget.ps1", "modules/install-nuget.ps1")
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Found: $file" -ForegroundColor Green
    } else {
        Write-Host "Missing: $file" -ForegroundColor Red
    }
}

# Test 2: Check NuGet
Write-Host "`n2. Checking NuGet..." -ForegroundColor Yellow
$nuget = Get-Command "nuget.exe" -ErrorAction SilentlyContinue
if ($nuget) {
    Write-Host "NuGet found at: $($nuget.Source)" -ForegroundColor Green
} else {
    Write-Host "NuGet not found" -ForegroundColor Red
}

# Test 3: Internet test
Write-Host "`n3. Testing internet..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5 | Out-Null
    Write-Host "Internet connection works" -ForegroundColor Green
} catch {
    Write-Host "Internet connection failed: $_" -ForegroundColor Red
}

# Test 4: Execution policy
Write-Host "`n4. Execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy
Write-Host "Current policy: $policy"

# Test 5: Run checks
Write-Host "`n5. Running checks..." -ForegroundColor Yellow
$env:ACS_Install_NuGet = $null

if (Test-Path "modules/check-nuget.ps1") {
    try {
        . "modules/check-nuget.ps1"
        Write-Host "NuGet check completed. Install needed: $env:ACS_Install_NuGet" -ForegroundColor Green
    } catch {
        Write-Host "NuGet check failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "check-nuget.ps1 not found" -ForegroundColor Red
}

Write-Host "`nDebug test complete!" -ForegroundColor Green