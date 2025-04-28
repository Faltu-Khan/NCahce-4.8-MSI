# Download the MSI installer
$msiUrl = "https://github.com/Faltu-Khan/NCahce-4.8-MSI/releases/download/NCache/ncache.oss.x64.msi"
$downloadPath = "C:\Windows\Temp\ncache.oss.x64.msi"
$logPath = "C:\Windows\Temp\ncache_install.log"

# Create temp directory if not exists
if (-not (Test-Path "C:\Windows\Temp")) {
    New-Item -ItemType Directory -Path "C:\Windows\Temp" -Force
}

# Download with retries
$retryCount = 3
$retryDelay = 10

for ($i = 0; $i -lt $retryCount; $i++) {
    try {
        Write-Output "Download attempt $($i+1) of $retryCount"
        Invoke-WebRequest -Uri $msiUrl -OutFile $downloadPath -UseBasicParsing
        break
    }
    catch {
        Write-Output "Download failed: $_"
        if ($i -eq $retryCount - 1) {
            throw "Failed to download after $retryCount attempts"
        }
        Start-Sleep -Seconds $retryDelay
    }
}

# Verify download
if (-not (Test-Path $downloadPath)) {
    throw "MSI file not found at $downloadPath"
}

# Install with detailed logging
$installArgs = @(
    "/i",
    "`"$downloadPath`"",
    "/quiet",
    "/norestart",
    "/l*v",
    $logPath
)

Write-Output "Starting installation..."
$process = Start-Process msiexec.exe -ArgumentList $installArgs -Wait -PassThru

# Check exit code
if ($process.ExitCode -ne 0) {
    $logContent = Get-Content $logPath -Tail 20 -ErrorAction SilentlyContinue
    throw "Installation failed with exit code $($process.ExitCode). Last log lines: `n$logContent"
}

# Final verification
if (Test-Path "C:\Program Files\NCache") {
    Write-Output "NCache installed successfully"
    exit 0
} else {
    $logContent = Get-Content $logPath -Tail 20 -ErrorAction SilentlyContinue
    throw "Installation verification failed. Last log lines: `n$logContent"
}