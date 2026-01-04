# Pub Doctor Script - Diagnose Flutter/Dart pub authentication issues
# Run this script in PowerShell: .\pub_doctor.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Pub Doctor - Network & Environment Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter/Dart versions
Write-Host "1. Flutter/Dart Versions:" -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "   Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "   Flutter: Not found or error" -ForegroundColor Red
}

try {
    $dartVersion = dart --version 2>&1
    Write-Host "   Dart: $dartVersion" -ForegroundColor Green
} catch {
    Write-Host "   Dart: Not found or error" -ForegroundColor Red
}
Write-Host ""

# Check environment variables
Write-Host "2. Environment Variables:" -ForegroundColor Yellow
$envVars = @(
    "PUB_HOSTED_URL",
    "FLUTTER_STORAGE_BASE_URL",
    "HTTP_PROXY",
    "HTTPS_PROXY",
    "http_proxy",
    "https_proxy"
)

foreach ($var in $envVars) {
    $value = [Environment]::GetEnvironmentVariable($var, "User")
    if ($null -eq $value) {
        $value = [Environment]::GetEnvironmentVariable($var, "Machine")
    }
    if ($null -eq $value) {
        $value = [Environment]::GetEnvironmentVariable($var, "Process")
    }
    
    if ($null -eq $value -or $value -eq "") {
        Write-Host "   $var : (not set)" -ForegroundColor Gray
    } else {
        Write-Host "   $var : $value" -ForegroundColor $(if ($var -like "*PROXY*") { "Yellow" } else { "Green" })
    }
}
Write-Host ""

# Check Pub cache location
Write-Host "3. Pub Cache Location:" -ForegroundColor Yellow
$pubCachePath = "$env:LOCALAPPDATA\Pub\Cache"
if (Test-Path $pubCachePath) {
    $cacheSize = (Get-ChildItem $pubCachePath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "   Path: $pubCachePath" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($cacheSize, 2)) MB" -ForegroundColor Green
    
    $credentialsPath = "$pubCachePath\credentials.json"
    if (Test-Path $credentialsPath) {
        Write-Host "   Credentials file: EXISTS" -ForegroundColor Yellow
    } else {
        Write-Host "   Credentials file: NOT FOUND" -ForegroundColor Gray
    }
} else {
    Write-Host "   Path: $pubCachePath (NOT FOUND)" -ForegroundColor Red
}
Write-Host ""

# Test network connectivity
Write-Host "4. Network Connectivity Tests:" -ForegroundColor Yellow

# Test pub.dev
Write-Host "   Testing pub.dev..." -NoNewline
try {
    $pubDevTest = Test-NetConnection -ComputerName "pub.dev" -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($pubDevTest) {
        Write-Host " PASSED" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host " FAILED (Error: $_)" -ForegroundColor Red
}

# Test storage.googleapis.com
Write-Host "   Testing storage.googleapis.com..." -NoNewline
try {
    $storageTest = Test-NetConnection -ComputerName "storage.googleapis.com" -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($storageTest) {
        Write-Host " PASSED" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host " FAILED (Error: $_)" -ForegroundColor Red
}

# Test HTTP requests
Write-Host "   Testing HTTP to pub.dev..." -NoNewline
try {
    $httpTest = Invoke-WebRequest -Uri "https://pub.dev" -Method Head -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host " PASSED (Status: $($httpTest.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host " FAILED (Error: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host "   Testing HTTP to storage.googleapis.com..." -NoNewline
try {
    $storageHttpTest = Invoke-WebRequest -Uri "https://storage.googleapis.com" -Method Head -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host " PASSED (Status: $($storageHttpTest.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host " FAILED (Error: $($_.Exception.Message))" -ForegroundColor Red
}
Write-Host ""

# Check DNS
Write-Host "5. DNS Resolution:" -ForegroundColor Yellow
try {
    $pubDevDns = Resolve-DnsName -Name "pub.dev" -ErrorAction Stop
    Write-Host "   pub.dev resolves to: $($pubDevDns[0].IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "   pub.dev DNS resolution: FAILED" -ForegroundColor Red
}

try {
    $storageDns = Resolve-DnsName -Name "storage.googleapis.com" -ErrorAction Stop
    Write-Host "   storage.googleapis.com resolves to: $($storageDns[0].IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "   storage.googleapis.com DNS resolution: FAILED" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnosis Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

