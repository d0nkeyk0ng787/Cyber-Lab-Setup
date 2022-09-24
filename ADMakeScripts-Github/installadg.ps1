# Powershell script to install AD & promote server to DC
# Created by Gnome787  | 24 SEP 22

# Install AD DS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Get AD DS install state
$ADState = (Get-WindowsFeature -Name "AD-Domain-Services").installstate

# Create variables for AD DS
$DomainName = "xyz.local"
$password = (ConvertTo-SecureString "Password1" -AsPlainText -Force)

# Import Active Directory
Import-Module ADDSDeployment

# Install AD DS Forest
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $password -InstallDNS:$true -Force:$true
