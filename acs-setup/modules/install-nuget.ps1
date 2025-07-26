# modules/install-nuget.ps1

if ($env:ACS_Install_NuGet) {
    # Set default fallback install path
    if ([string]::IsNullOrWhiteSpace($env:ACS_NuGet_Install_Path)) {
        $env:ACS_NuGet_Install_Path = "$env:ProgramFiles\NuGet"
    }
    # Get install path from user
do {
    $installPath = Read-Host "Enter directory to install %NuGet.exe (e.g., C:\Tools\NuGet)"
    if ([string]::IsNullOrWhiteSpace($installPath)) {
        Write-Host "Install path cannot be empty. Please try again." -ForegroundColor Red
        continue
    }
    
    # Create directory if it doesn't exist
    try {
        if (-not (Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
            Write-Host "Created directory: $installPath" -ForegroundColor Green
        }
        
        # Test write permissions
        $testFile = Join-Path $installPath "test_write.tmp"
        "test" | Out-File -FilePath $testFile -Force
        Remove-Item $testFile -Force
        Write-Host "Write permissions verified" -ForegroundColor Green
        break
        
    } catch {
        Write-Host "Error with path '$installPath': $_" -ForegroundColor Red
        Write-Host "Please try a different path." -ForegroundColor Yellow
        continue
    }
} while ($true)

# Download NuGet
$nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$destination = Join-Path $installPath "nuget.exe"

Write-Host "Downloading NuGet..." -ForegroundColor Yellow
Write-Host "From: $nugetUrl"
Write-Host "To: $destination"

try {
    # Set TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download
    Invoke-WebRequest -Uri $nugetUrl -OutFile $destination -UseBasicParsing
    
    # Verify download
    if (-not (Test-Path $destination)) {
        throw "Download completed but file not found"
    }
    
    $fileInfo = Get-Item $destination
    Write-Host "Downloaded file size: $($fileInfo.Length) bytes" -ForegroundColor Green
    
    if ($fileInfo.Length -lt 1048576) {
        throw "Downloaded file seems too small"
    }
    
    # Add to PATH for current session
    Write-Host "Adding to PATH..." -ForegroundColor Yellow
    $currentPath = $env:PATH
    if ($currentPath -notlike "*$installPath*") {
        $env:PATH = "$installPath;$currentPath"
    }
    
    # Test NuGet
    Write-Host "Testing NuGet..." -ForegroundColor Yellow
    $nugetCommand = Get-Command "nuget.exe" -ErrorAction SilentlyContinue
    if ($nugetCommand) {
        Write-Host "SUCCESS: NuGet installed and accessible!" -ForegroundColor Green
        Write-Host "Location: $($nugetCommand.Source)" -ForegroundColor Cyan
        
        # Show version
        & nuget.exe | Select-Object -First 2
        
    } else {
        Write-Host "NuGet installed but not found in PATH" -ForegroundColor Yellow
        Write-Host "Manual path: $destination" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "ERROR: NuGet installation failed" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
  }
}