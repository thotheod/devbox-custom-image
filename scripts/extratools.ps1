##########################
## Install Chocolatey 
##########################
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


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
    wsl --update
    Write-Host "WSL updated to the latest version."
} catch {
    Write-Host "An error occurred while updating WSL."
    Write-Host "Error details: $_"
}

## Set Ubuntu 22.02
Write-Host "installing Ubuntu 22.02"
try {
    wsl.exe --install -d Ubuntu-22.02
    Write-Host "Installed Ubuntu 22.02."
} catch {
    Write-Host "An error occurred while installing Ubuntu 22.02."
    Write-Host "Error details: $_"
}

######################################
## Install extra Tools with Chocolatey
######################################

# google chrome latest version may fail with checksum mismatch -
## Tooling List
# $tools = @(
#             "7zip", "adobereader",  "azure-cli", "nodejs.install", "postman",  "git.install", "sql-server-management-studio",  "gh", "googlechrome", "notepadplusplus"
#         )
# git, gh, azure-cli are included in the base image
$tools = @(
    "7zip", "adobereader", "nodejs.install", "postman", "sql-server-management-studio",  "googlechrome", "notepadplusplus", "podman-desktop"
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