# Powershell script to install AD & promote server to DC
# Created by Gnome787  | 24 SEP 22

# Install AD DS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools | Out-Null
Write-Host "AD DS has been installed" -ForegroundColor Cyan
Write-Host "Setting up AD DS Forest" -ForegroundColor Cyan

# Create variables for AD DS
$DomainName = "xyz.local"
$password = (ConvertTo-SecureString "Password1" -AsPlainText -Force)

# Import Active Directory
Import-Module ADDSDeployment | Out-Null

# Install AD DS Forest
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $password -InstallDNS:$true -Force:$true -WarningAction SilentlyContinue | Out-Null
