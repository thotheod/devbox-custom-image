
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
}

# update WSL to latest version
Write-Host "Updating WSL to latest version..."
try {
    wsl --update --no-prompt 
    Write-Host "WSL updated to the latest version."
} catch {
    Write-Host "An error occurred while updating WSL."
}

## Set WSL default version to 2 (possibly not necessary step - it should default to ver 2)
Write-Host "Setting WSL default version to 2..."
try {
    wsl --set-default-version 2 --no-prompt 
    Write-Host "WSL default version set to 2."
} catch {
    Write-Host "An error occurred while setting WSL default version to 2."
}

##########################
## Install Chocolatey 
##########################
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# # Note: It gets an error : winget 0x80073CF9
# ##########################
# ## Install winget
# ##########################
# Write-Host "Installing winget..."
# try {
#     # Download the latest App Installer package which includes winget
#     $wingetInstallerUrl = "https://aka.ms/getwinget"
#     $wingetInstallerPath = "C:\Windows\Temp\winget.msixbundle"
    
#     Invoke-WebRequest -Uri $wingetInstallerUrl -OutFile $wingetInstallerPath
#     Write-Host "winget has been downloaded."

#     # Install the App Installer package
#     Add-AppxPackage -Path $wingetInstallerPath    
#     Write-Host "winget has been installed successfully!"
# } catch {
#     Write-Host "An error occurred during the installation of winget!"
#     Write-Host "Error details: $_"
# }

# # ...existing code...

# ##########################
# ## Install winget packages
# ##########################

# Write-Host "Installing Ubuntu..."
# try {
#     winget install -e -h --id Canonical.Ubuntu.2204 --accept-package-agreements --accept-source-agreements --force --disable-interactivity --nowarn
#     Write-Host "Ubuntu installation completed successfully."
# } catch {
#     Write-Host "An error occurred during the installation of Ubuntu."
#     Write-Host "Error details: $_"
# }

# Write-Host "Installing Google Chrome..."
# try {
#     winget install -e -h --id Google.Chrome --accept-package-agreements --accept-source-agreements --force --disable-interactivity --nowarn

#     Write-Host "Google Chrome installation completed successfully."
# } catch {
#     Write-Host "An error occurred during the installation of Google Chrome."
#     Write-Host "Error details: $_"
# }

# Write-Host "Installing Notepad++..."
# try {
#     winget install -e -h --id Notepad++.Notepad++ --accept-package-agreements --accept-source-agreements --force --disable-interactivity --nowarn
#     Write-Host "Notepad++ installation completed successfully."
# } catch {
#     Write-Host "An error occurred during the installation of Notepad++."
# }


######################################
## Install extra Tools with Chocolatey
######################################

## Tooling List
$tools = @(
            "7zip", "adobereader",  "azure-cli", "nodejs.install", "postman",  "git.install", "sql-server-management-studio",  "gh"
        )

## Install extra Tools with Chocolatey
foreach ($t in $tools) {
    try {
        Write-Host "Installing package: $t ...."
        choco install -y $t
        Write-Host "Installed: $t"
    } catch {
        Write-Host "An error occurred during the installation of $t."
    }
}