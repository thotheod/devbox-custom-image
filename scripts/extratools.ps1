
##########################
## Enable WSL
##########################
Write-Host "Enabling Windows Subsystem for Linux..."
try {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    Write-Host "WSL enabled successfully."
} catch {
    Write-Host "An error occurred while enabling WSL."
    Write-Host "Error details: $_"
}

# update WSL to latest version
Write-Host "Updating WSL to latest version..."
try {
    wsl --update --no-prompt 
    Write-Host "WSL updated to the latest version."
} catch {
    Write-Host "An error occurred while updating WSL."
    Write-Host "Error details: $_"
}

## Set WSL default version to 2 (possibly not necessary step - it should default to ver 2)
Write-Host "Setting WSL default version to 2..."
try {
    wsl --set-default-version 2 --no-prompt 
    Write-Host "WSL default version set to 2."
} catch {
    Write-Host "An error occurred while setting WSL default version to 2."
    Write-Host "Error details: $_"
}

##########################
## Install Chocolatey 
##########################
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

######################################
## Install extra Tools with Chocolatey
######################################

# google chrome latest version may fail with checksum mismatch -
## Tooling List
$tools = @(
            "7zip", "adobereader",  "azure-cli", "nodejs.install", "postman",  "git.install", "sql-server-management-studio",  "gh", "googlechrome", "notepadplusplus"
        )

## Install extra Tools with Chocolatey
foreach ($t in $tools) {
    try {
        Write-Host "Installing package: $t ...."
        choco install -y $t --no-progress --force --limit-output
        Write-Host "Installed: $t"
    } catch {
        Write-Host "An error occurred during the installation of $t."
        Write-Host "Error details: $_"
    }
}