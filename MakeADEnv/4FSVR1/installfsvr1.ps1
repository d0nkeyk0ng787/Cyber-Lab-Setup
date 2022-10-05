# Install FSVR1

# Disable IPv6
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6' | Out-Null

Write-Host "IPv6 Disabled" -ForegroundColor Cyan

# Resuable Variables
$IP = "192.168.100.5"
$Gateway = "192.168.100.1"
$DC = "192.168.100.2"

# Assign a static IP
$ipparams = @{
    InterfaceIndex = (Get-NetAdapter).InterfaceIndex
    IPAddress = $IP
	PrefixLength = 24
	DefaultGateway = $Gateway
}

New-NetIPAddress @ipparams | Out-Null

# Completed message
Write-Host "Server has been assigned an IP of $IP" -ForegroundColor Cyan
Write-Host "Server has been assigned a Default Gateway of $Gateway" -ForegroundColor Cyan

# Change the DNS server to DC1 
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter).name -ServerAddresses $DC | Out-Null

# Completed message
Write-Host "Servers DNS server has been changed to $DC" -ForegroundColor Cyan

# Create a domain credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential ("xyz\Administrator", $Password) 

Start-Sleep -Seconds 5

Write-Host "Renaming server to FSVR1 and joining server to the domain" -ForegroundColor Cyan

# Join computer to the domain
$domainparams = @{
	DomainName = "xyz.local"
	NewName = "FSVR1"
	OUPath = "OU=Servers,OU=Devices,OU=XYZ,DC=xyz,DC=local"
	Credential = $DomainCred
	Force = $true
	Restart = $true
}

Add-Computer @domainparams | Out-Null
