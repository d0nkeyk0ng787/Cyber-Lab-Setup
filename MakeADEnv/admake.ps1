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
    Write-Host $VMName "is responding to PS remoting...Continuing" -ForegroundColor Cyan 
}

# Run the script that makes the VMs
H:\MakeADEnv\1VMs\makevms.ps1

# Sleep until the VMs are created
Start-Sleep -Seconds 10

# Start the DC
Start-VM -Name "DC1"
Write-Host "DC1 is running" -ForegroundColor Black -BackgroundColor Green

# Continue when Windows install has completed
#Press-Any -CustomMessage "Complete Windows setup before continuing."
Write-Host "Complete Windows install" -ForegroundColor Black -BackgroundColor Magenta
Wait-ForPS -VMName "DC1" -Creds $Cred

Write-Host "`r`nPre AD setup is beginning" -ForegroundColor Cyan

# Perform pre AD config
Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\pread.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Install AD
Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\installad.ps1 -Credential $Cred

Write-Host "Finished installing AD DS Forest" -ForegroundColor Black -BackgroundColor Yellow

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
	Write-Host "ADWS is running" -ForegroundColor Black -BackgroundColor Green
	}

# Setup the AD environment
# Make OUs, security groups, and add users
Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\2DC1\adenv.ps1 -Credential $DomainCred

Write-Host "Moving on to DHCP setup" -ForegroundColor Cyan

# Setup the DHCP server
Start-VM -Name "DHCP"
Write-Host "DHCP server is running" -ForegroundColor Black -BackgroundColor Green

# Continue when Windows install has completed
#Press-Any -CustomMessage "Complete Windows setup before continuing."
Write-Host "Complete Windows install" -ForegroundColor Black -BackgroundColor Magenta
Wait-ForPS -VMName "DHCP" -Creds $Cred

Write-Host "`r`nDHCP setup is beginning" -ForegroundColor Cyan

# Perform DHCP server setup
Invoke-Command -VMName "DHCP" -FilePath H:\MakeADEnv\3DHCP\installdhcp.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Setup the DHCP server, add security groups, add server as an authorised DHCP server, create and setup scopes
Invoke-Command -VMName "DHCP" -FilePath H:\MakeADEnv\3DHCP\setupdhcp.ps1 -Credential $DomainCred

Write-Host "Finished setting up DHCP" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Moving on to FSVR setup" -ForegroundColor Cyan

# Setup the File Server
Start-VM -Name "FSVR1"
Write-Host "FSVR1 is running" -ForegroundColor Black -BackgroundColor Green

# Continue when Windows install has completed
#Press-Any -CustomMessage "Complete Windows setup before continuing."
Write-Host "Complete Windows install" -ForegroundColor Black -BackgroundColor Magenta
Wait-ForPS -VMName "FSVR1" -Creds $Cred

Write-Host "`r`nFSVR1 setup is beginning" -ForegroundColor Cyan

# Perform FSVR1 setup
Invoke-Command -VMName "FSVR1" -FilePath H:\MakeADEnv\4FSVR1\installfsvr1.ps1 -Credential $Cred

# Sleep until server restarts
Start-Sleep -Seconds 10

# Setup the FSVR1, create disk, create smb share, setup dfs, drive mapping
Invoke-Command -VMName "FSVR1" -FilePath H:\MakeADEnv\4FSVR1\setupfsvr1.ps1 -Credential $DomainCred

Write-Host "Finished setting up FSVR1" -ForegroundColor Black -BackgroundColor Yellow

# Create drive mapping GPO on DC1
Write-Host "Implement GPO on DC1 to map the users home drive" -ForegroundColor Cyan

# Implement GPO
Invoke-Command -VMName "DC1" -FilePath H:\MakeADEnv\4FSVR1\drivegpo.ps1 -Credential $DomainCred

Write-Host "GPO implemented" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Moving on to CLI1" -ForegroundColor Cyan

# Setup the Client
Start-VM -Name "CLI1"
Write-Host "CLI1 is running" -ForegroundColor Black -BackgroundColor Green

# Continue when Windows install has completed
#Press-Any -CustomMessage "Complete Windows setup before continuing."
Write-Host "Complete Windows install" -ForegroundColor Black -BackgroundColor Magenta
Wait-ForPS -VMName "CLI1" -Creds $CliCred

Write-Host "`r`nCLI1 setup is beginning" -ForegroundColor Cyan

# Sleep
Start-Sleep -Seconds 10

# Perform CLI1 setup. Create a PSSession and store it in a variable to get past Access is denied error with Invoke-Command
$Session = New-PSSession -VMName "CLI1" -Credential $CliCred
Invoke-Command -Session $Session -FilePath H:\MakeADEnv\5CLI1\installcli.ps1
#Invoke-Command -VMName "CLI1" -FilePath H:\MakeADEnv\5CLI1\installcli.ps1 -Credential $CliCred

Start-Sleep -Seconds 20

# Rename the client
#$Session = New-PSSession -VMName "CLI1" -Credential $DomainCred
#Invoke-Command -Session $Session -ScriptBlock {Rename-Computer -NewName "CLI1" -Restart}
#Invoke-Command -VMName "CLI1" -Credential $DomainCred -ScriptBlock {Rename-Computer -NewName "CLI1" -Restart} 

Write-Host "CLI1 setup complete" -ForegroundColor Cyan

$Contin = Read-Host -Prompt "Would you like to continue with installing additional features of AD? (Y/N)"
$Contin = $Contin.ToLower()

# Create extra variable
$Extra = 0

# Functions for extra features
function Add-Users {
    # Ensure the VM is running
    Start-VM -VMName "DC1"
    Write-Host "DC1 is running" -ForegroundColor Black -BackgroundColor Green
    Wait-ForPS -VMName "DC1" -Creds $DomainCred

    # Run the add users script on the DC
    Invoke-Command -VMName "DC1" -Credential $DomainCred -FilePath H:\MakeADEnv\6Extras\userconfig.csv
}

function Add-Machine {

    param (
        [Parameter(Mandatory = $true)] [string[]]$VMName
    )
    # Let the script operator know they need to add the config for the machine to the vmconfig.csv
    Write-Host "Ensure you have added the config for the machine to vmconfig.csv" -ForegroundColor Black -BackgroundColor Magenta
    Press-Any -CustomMessage "Proceed when you have filled out the vmconfig.csv"

    # Create the VM
    Write-Host "`r`n"
    H:\MakeADEnv\1VMs\makevms.ps1

    # Sleep until the VMs are created
    Start-Sleep -Seconds 10

    # Start the Machine
    Start-VM -Name $VMName
    Write-Host $VMName "is running" -ForegroundColor Black -BackgroundColor Green

    # Setup Windows
    Write-Host "Complete Windows install" -ForegroundColor Black -BackgroundColor Magenta
    Wait-ForPS -VMName $VMName -Creds $Cred

    # Setup the server and add it to the domain
    Invoke-Command -VMName $VMName -Credential $Cred -FilePath H:\MakeADEnv\6Extras\addmachine.ps1

    # Completed
    Write-Host "Additional machine created" -ForegroundColor Cyan
}

function Get-Continue {
    # See if user wants to continue
    if ($Contin -eq "n"){
        Write-Host "AD environment setup complete. Exiting..." -ForegroundColor Black -BackgroundColor Green
        $ExitState = 1
    }
    else{
        Write-Host "Extras include: add additional users, add an additional machine, setup wallpaper GPO." -ForegroundColor Black -BackgroundColor Cyan
        $Extra = Read-Host -Prompt "Select 1, 2 or 3 respectively to make a choice, alternatively press 4 to exit"
    }

    # Continue with extra installs
    if ($Extra -eq "1"){
        Add-Users
    }
    ElseIf ($Extra -eq "2"){
        Add-Machine -VMName "SVR1"
    }
    ElseIF ($Extra -eq "3"){
        Write-Host "To be configured" -ForegroundColor Red
    }
    Elseif ($Extra -eq "4"){
        Write-Host "AD environment setup complete. Exiting..." -ForegroundColor Black -BackgroundColor Green
        break
    }
}

$ExitState = 0

While ($ExitState -eq 0){
    Get-Continue
}
