# Script to control the execution of the AD environment creation scripts
# Created 03 OCT 22 | Gnome787

# Variables

# Create a credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("Administrator", $Password) 

# Create a domain credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential ("xyz\Administrator", $Password) 

# Create a client credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$CliCred = New-Object System.Management.Automation.PSCredential ("Admin", $Password) 

# Functions

# Press any key function
function Press-Any {

    param (
        [string[]]$CustomMessage
    )

    Write-Host -NoNewLine $CustomMessage 'Press any key to continue...' -ForegroundColor Magenta -BackgroundColor Black
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Wait for PS Remoting
function Wait-ForPS {

    param (
        [Parameter(Mandatory = $true)] [string[]]$VMName,
        [Parameter(Mandatory = $true)] $Creds
    )

    Write-Host "Waiting for" $VMName "to respond to PS remoting" -ForegroundColor Cyan
    while ((icm -VMName $VMName -Credential $Creds {“Test”} -ea SilentlyContinue) -ne “Test”) {Sleep -Seconds 1}
    Write-Host $VMName "is responding to PS direct...Continuing" -ForegroundColor Cyan 
}

# Run the script that makes the VMs
H:\MakeADEnv\1VMs\makevms.ps1

# Sleep until the VMs are created
Start-Sleep -Seconds 10

# Start the DC
Start-VM -Name "DC1"
Write-Host "DC1 is running" -ForegroundColor Green

# Continue when Windows install has completed
Press-Any -CustomMessage "Complete Windows setup before continuing."

Write-Host "`r`nPre AD setup is beginning" -ForegroundColor Cyan

# Perform pre AD config
#Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\pread.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Install AD
#Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\installad.ps1 -Credential $Cred

Write-Host "Finished installing AD DS Forest" -ForegroundColor Yellow

# Sleep until the DC responds to PS remoting
Wait-ForPS -VMName DC1 -Creds $DomainCred

# Wait for ADWS to come online
Invoke-Command -VMName DC1 -Credential $DomainCred -ScriptBlock {
    Write-Verbose "Waiting for AD Web Services to be in a running state" -Verbose
    $ADWebSvc = Get-Service ADWS | Select-Object *
    while($ADWebSvc.Status -ne 'Running')
            {
            Start-Sleep -Seconds 1
            $ADWebSvc = Get-Service ADWS | Select-Object *
            }
	Write-Host "ADWS is running" -ForegroundColor Green
	}

# Setup the AD environment
# Make OUs, security groups, and add users
#Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\adenv.ps1 -Credential $DomainCred

Write-Host "Moving on to DHCP setup" -ForegroundColor Cyan

# Setup the DHCP server
Start-VM -Name "DHCP"
Write-Host "DHCP server is running" -ForegroundColor Green

# Continue when Windows install has completed
Press-Any -CustomMessage "Complete Windows setup before continuing."

Write-Host "`r`nDHCP setup is beginning" -ForegroundColor Cyan

# Perform DHCP server setup
#Invoke-Command -VMName "DHCP" -FilePath H:\MakeADEnv\3DHCP\installdhcp.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Setup the DHCP server, add security groups, add server as an authorised DHCP server, create and setup scopes
#Invoke-Command -VMName "DHCP" -FilePath H:\MakeADEnv\3DHCP\setupdhcp.ps1 -Credential $DomainCred

Write-Host "Finished setting up DHCP" -ForegroundColor Yellow
Write-Host "Moving on to FSVR setup" -ForegroundColor Cyan

# Setup the File Server
Start-VM -Name "FSVR1"
Write-Host "FSVR1 is running" -ForegroundColor Green

# Continue when Windows install has completed
Press-Any -CustomMessage "Complete Windows setup before continuing."

Write-Host "`r`nFSVR1 setup is beginning" -ForegroundColor Cyan

# Perform FSVR1 setup
#Invoke-Command -VMName "FSVR1" -FilePath H:\MakeADEnv\4FSVR1\installfsvr1.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Setup the FSVR1, create disk, create smb share, setup dfs, drive mapping
#Invoke-Command -VMName "FSVR1" -FilePath H:\MakeADEnv\4FSVR1\setupfsvr1.ps1 -Credential $DomainCred

Write-Host "Finished setting up FSVR1" -ForegroundColor Yellow

# Create drive mapping GPO on DC1
Write-Host "Implement GPO on DC1 to map the users home drive" -ForegroundColor Cyan

# Implement GPO
#Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\4FSVR1\drivegpo.ps1 -Credential $DomainCred

Write-Host "GPO implemented" -ForegroundColor Yellow
Write-Host "Moving on to CLI1" -ForegroundColor Cyan

# Setup the Client
Start-VM -Name "CLI1"
Write-Host "CLI1 is running" -ForegroundColor Green

# Continue when Windows install has completed
Press-Any -CustomMessage "Complete Windows setup before continuing."

Write-Host "`r`nCLI1 setup is beginning" -ForegroundColor Cyan

# Sleep
Start-Sleep -Seconds 10

# Perform CLI1 setup. Create a PSSession and store it in a variable to get past Access is denied error with Invoke-Command
$Session = New-PSSession -VMName "CLI1" -Credential $CliCred
Invoke-Command -Session $Session -FilePath H:\MakeADEnv\5CLI1\installcli.ps1
#Invoke-Command -VMName "CLI1" -FilePath H:\MakeADEnv\5CLI1\installcli.ps1 -Credential $CliCred

Start-Sleep -Seconds 20

# Rename the client
$Session = New-PSSession -VMName "CLI1" -Credential $DomainCred
Invoke-Command -Session $Session -ScriptBlock {Rename-Computer -NewName "CLI1" -Restart}
#Invoke-Command -VMName "CLI1" -Credential $DomainCred -ScriptBlock {Rename-Computer -NewName "CLI1" -Restart} 

Write-Host "CLI1 setup complete" -ForegroundColor Cyan