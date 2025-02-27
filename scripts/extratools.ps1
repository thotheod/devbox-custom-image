##########################
## Install Chocolatey 
##########################
Write-Host "Install Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force 2>$null; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 2>$null; 
try {
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 2>$null
    Write-Host "Chocolatey installation completed successfully."
} catch {
    Write-Host "An error occurred during the installation of Chocolatey."
}

##########################
## Install winget
##########################
Write-Host "Install winget..."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    try {
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" 2>$null
        Add-AppxPackage -Path "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" 2>$null
        Write-Host "winget has been installed."
    } catch {
        Write-Host "An error occurred during the installation of winget."
    }
} else {
    Write-Host "winget is already installed."
}

##########################
## Install choco packages
##########################

## Tooling List
$tools = @(
            "sql-server-management-studio", 
            "adobereader",  
            "azure-cli", 
            "notepadplusplus",
            "postman",
            "nodejs.install",
            "git.install",
            "gh"
        )

## Install extra Tools with Chocolatey
foreach ($t in $tools) {
    try {
        choco install -y $t 2>$null
        Write-Host "Installed: $t"
    } catch {
        Write-Host "An error occurred during the installation of $t."
    }
}

##########################
## Enable WSL
##########################

# Enable WSL / install Ubuntu
Write-Host "Enabling Windows Subsystem for Linux..."
try {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>$null
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>$null
    Write-Host "WSL enabled successfully."
} catch {
    Write-Host "An error occurred while enabling WSL."
}

# update WSL to latest version
Write-Host "Updating WSL to latest version..."
try {
    wsl --update --no-prompt 2>$null
    Write-Host "WSL updated to the latest version."
} catch {
    Write-Host "An error occurred while updating WSL."
}

## Set WSL default version to 2 (possibly not necessary step - it should default to ver 2)
Write-Host "Setting WSL default version to 2..."
try {
    wsl --set-default-version 2 --no-prompt 2>$null
    Write-Host "WSL default version set to 2."
} catch {
    Write-Host "An error occurred while setting WSL default version to 2."
}

##########################
## winget installations
##########################

## Install Ubuntu
Write-Host "Installing Ubuntu..."
try {
    winget install -e --id Canonical.Ubuntu.2204 --accept-package-agreements --accept-source-agreements 2>$null
    Write-Host "Ubuntu installation completed successfully."
} catch {
    Write-Host "An error occurred during the installation of Ubuntu."
}

# choco googlechrome currently fails, so use winget
Write-Host "Installing Google Chrome..."
try {
    winget install -e --id Google.Chrome --accept-package-agreements --accept-source-agreements 2>$null
    Write-Host "Google Chrome installation completed successfully."
} catch {
    Write-Host "An error occurred during the installation of Google Chrome."
}