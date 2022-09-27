# AD Install

### Create a NAT Switch on Host

```powershell
New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNAT -Name "NATNetwork" -InternalIPInterfaceAddressPrefix 192.168.1.0/24
```

### Configure Static Address, DNS & Change Computer Name

Before we install AD, we need to ensure we have set a static IP address, DNS server and rename the server. 

Change IP Address. Can add a default gateway with ```-DefaultGateway <DG>``` if needed.
```powershell
New-NetIPAddress -InterfaceIndex <INTERFACE-INDEX> -IPAddress <SERVER-IP> -PrefixLength <SUBNETMASK>
# Confirm with
Get-NetIPAddress -InterfaceIndex <INTERFACE-INDEX>
``` 
Change the DNS server to the servers IP:
```powershell
Set-DNSClientServerAddress -InterfaceIndex 3 -ServerAddresses <SERVERIP>
# Confirm with
Get-DNSClientServerAddress -InterfaceIndex 3
``` 

Rename Server:
```powershell
Rename-Computer -NewName "<NAME>" -Restart
# Confirm with
Get-ComputerInfo -Property "*Name"
```


### Install AD On Server Core

To install AD DS with management tookls, we simply enter the following.

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
# Confirm with
Get-WindowsFeature
```
This will then start the install process which will take a little while.

### Configure AD DS

Now we want to install our AD DS forest and configure our server as a domain controller.

```powershell
# Create admin password
$password = (ConvertTo-SecureString "Password1" -AsPlainText -Force)
# Install AD forest with our specified options
Install-ADDSForest -DomainName "xyz.local" -SafeModeAdministratorPassword $password -InstallDns:$true -Force:$true
```


### Configure a DC on an exisitng Domain

We want to add our new server as a DC on an exisiting domain, this can be done by doing the following on the new server.

```powershell
# Create admin password
$password = (ConvertTo-SecureString "Password1" -AsPlainText -Force)
# Add current server as a DC
Install-ADDSDomainController -DomaiName "xyz.local" -InstallDns:$true -NoRebootOnCompletion:$false -Force:$true 
```
