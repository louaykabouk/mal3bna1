# Fix Flutter/Dart Pub 403 Authentication Error

## Diagnosis Summary

The "Authentication error (403)" when running `flutter pub get` typically occurs due to:

1. **Proxy/VPN interference**: Corporate proxies or VPNs may block or interfere with pub.dev access
2. **Incorrect environment variables**: Custom PUB_HOSTED_URL or FLUTTER_STORAGE_BASE_URL pointing to wrong endpoints
3. **Corrupted pub cache credentials**: Stale or invalid authentication tokens in the pub cache
4. **Network/DNS issues**: DNS resolution problems or firewall blocking connections
5. **Antivirus/Firewall**: Security software blocking Flutter/Dart network requests

---

## Step-by-Step Fix

### Step 1: Check Environment Variables

**PowerShell:**
```powershell
# Check current values
echo $env:PUB_HOSTED_URL
echo $env:FLUTTER_STORAGE_BASE_URL
echo $env:HTTP_PROXY
echo $env:HTTPS_PROXY

# Reset if needed (restart terminal after setx)
setx PUB_HOSTED_URL ""
setx FLUTTER_STORAGE_BASE_URL ""
setx HTTP_PROXY ""
setx HTTPS_PROXY ""
```

**CMD:**
```cmd
REM Check current values
echo %PUB_HOSTED_URL%
echo %FLUTTER_STORAGE_BASE_URL%
echo %HTTP_PROXY%
echo %HTTPS_PROXY%

REM Reset if needed (restart terminal after setx)
setx PUB_HOSTED_URL ""
setx FLUTTER_STORAGE_BASE_URL ""
setx HTTP_PROXY ""
setx HTTPS_PROXY ""
```

**Important:** After using `setx`, close and reopen your terminal/PowerShell window.

---

### Step 2: Run Pub Doctor Script

```powershell
# Navigate to project directory
cd "C:\Users\hyuug\Desktop\flutter project\mal3bna1"

# Run the diagnostic script
.\pub_doctor.ps1
```

Review the output to identify specific issues.

---

### Step 3: Repair Pub Cache

**PowerShell:**
```powershell
# Try repair first
dart pub cache repair

# If repair fails, delete credentials only
Remove-Item "$env:LOCALAPPDATA\Pub\Cache\credentials.json" -ErrorAction SilentlyContinue

# If still failing, delete entire cache (WARNING: Will re-download all packages)
Remove-Item "$env:LOCALAPPDATA\Pub\Cache" -Recurse -Force -ErrorAction SilentlyContinue
```

**CMD:**
```cmd
REM Try repair first
dart pub cache repair

REM If repair fails, delete credentials only
del "%LOCALAPPDATA%\Pub\Cache\credentials.json" 2>nul

REM If still failing, delete entire cache (WARNING: Will re-download all packages)
rmdir /s /q "%LOCALAPPDATA%\Pub\Cache" 2>nul
```

---

### Step 4: Clean and Rebuild

**PowerShell/CMD:**
```powershell
# Navigate to project
cd "C:\Users\hyuug\Desktop\flutter project\mal3bna1"

# Clean Flutter project
flutter clean

# Get packages
flutter pub get
```

---

### Step 5: Network Fallback (If Still Failing)

#### A. Try Mobile Hotspot
1. Disconnect from current network
2. Connect to mobile hotspot
3. Run `flutter pub get` again

#### B. Reset DNS

**PowerShell (as Administrator):**
```powershell
# Flush DNS cache
ipconfig /flushdns

# Optional: Set DNS to Google/Cloudflare
netsh interface ip set dns "Wi-Fi" static 8.8.8.8
netsh interface ip add dns "Wi-Fi" 8.8.4.4 index=2
```

**CMD (as Administrator):**
```cmd
REM Flush DNS cache
ipconfig /flushdns

REM Optional: Set DNS to Google/Cloudflare
netsh interface ip set dns "Wi-Fi" static 8.8.8.8
netsh interface ip add dns "Wi-Fi" 8.8.4.4 index=2
```

**Alternative DNS (Cloudflare):**
- Primary: `1.1.1.1`
- Secondary: `1.0.0.1`

---

### Step 6: Disable Proxy Temporarily (If Using)

**PowerShell:**
```powershell
# Check proxy settings
netsh winhttp show proxy

# Disable proxy temporarily
netsh winhttp reset proxy
```

**Note:** Re-enable proxy after testing if needed for your network.

---

## Verification Checklist

After applying fixes, verify:

- [ ] Environment variables are cleared or set correctly
- [ ] `pub_doctor.ps1` shows all connectivity tests PASSED
- [ ] `flutter clean` completes without errors
- [ ] `flutter pub get` completes successfully
- [ ] No 403 errors in output
- [ ] Packages are downloaded to `%LOCALAPPDATA%\Pub\Cache`

---

## Quick Command Reference

```powershell
# Full fix sequence (PowerShell)
cd "C:\Users\hyuug\Desktop\flutter project\mal3bna1"
.\pub_doctor.ps1
dart pub cache repair
flutter clean
flutter pub get
```

---

## If Problem Persists

1. **Check Windows Firewall**: Temporarily disable to test
2. **Check Antivirus**: Add Flutter/Dart to exclusions
3. **Check Corporate Proxy**: Contact IT to whitelist pub.dev and storage.googleapis.com
4. **Try Different Network**: Use mobile hotspot to isolate network issues
5. **Check Flutter Version**: Update Flutter: `flutter upgrade`

---

## Expected Output After Fix

```
Running "flutter pub get" in mal3bna1...
Resolving dependencies...
Got dependencies!
```

No 403 errors should appear.

