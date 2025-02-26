## Install Script for common organisation tooling

## Install Chocolatey 
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

## Install winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Add-AppxPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    Write-Host "winget has been installed."
} else {
    Write-Host "winget is already installed."
}

## Tooling List
$tools = @(
            "sql-server-management-studio", 
            "adobereader",  
            "azure-cli", 
            "notepadplusplus",
            "postman",
            "googlechrome",
            "nodejs.install",
            "git.install",
            "gh"
        )

## Install extra Tools with Chocolatey
foreach ($t in $tools) {
    choco install -y $t
    Write-Host "Installed: $t"
}

# choco googlechrome currenlty fails, so use winget
winget install -e --id Google.Chrome  --accept-package-agreements --accept-source-agreements

## Enable WSL
# Write-Host "Enabling Windows Subsystem for Linux..."
# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# ## Set WSL default version to 2
# Write-Host "Setting WSL default version to 2..."
# wsl --set-default-version 2

# ## Install Ubuntu
# Write-Host "Installing Ubuntu..."
# choco install wsl-ubuntu-2004 -y

# VsCode Extensions
# https://community.chocolatey.org/packages?q=vscode