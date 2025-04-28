# Download the MSI installer
$msiUrl = "https://github.com/Faltu-Khan/NCahce-4.8-MSI/releases/download/NCache/ncache.oss.x64.msi"
$downloadPath = "C:\Windows\Temp\ncache.oss.x64.msi"

# Retry logic for download
$retryCount = 3
$retryDelay = 5

for ($i = 0; $i -lt $retryCount; $i++) {
    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $downloadPath -UseBasicParsing
        Write-Output "Download successful"
        break
    }
    catch {
        Write-Output "Attempt $($i+1) failed: $_"
        if ($i -eq $retryCount - 1) {
            throw "Failed to download after $retryCount attempts"
        }
        Start-Sleep -Seconds $retryDelay
    }
}

# Install the MSI silently
Start-Process msiexec.exe -Wait -ArgumentList @(
    "/i",
    "`"$downloadPath`"",
    "/quiet",
    "/norestart",
    "/l*v",
    "C:\Windows\Temp\ncache_install.log"
)

# Verify installation
if (Test-Path "C:\Program Files\NCache") {
    Write-Output "NCache installed successfully"
} else {
    throw "Installation may have failed - check C:\Windows\Temp\ncache_install.log"
}
