# Install CLI1 

# Disable IPv6
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6' | Out-Null

Write-Host "IPv6 Disabled" -ForegroundColor Cyan

# Resuable Variables
$DC = "192.168.100.2"

# Set the DNS
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $DC

Write-Host "Clients DNS server was changed to $DC" -ForegroundColor Cyan

# Create a domain credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential ("xyz\Administrator", $Password) 

Write-Host "Joining client to the domain" -ForegroundColor Cyan

# Join computer to the domain
$domainparams = @{
	DomainName = "xyz.local"
	NewName = "CLI1"
	OUPath = "OU=Workstations,OU=Devices,OU=XYZ,DC=xyz,DC=local"
	Credential = $DomainCred
	Force = $true
	Restart = $true
}

Add-Computer @domainparams | Out-Null
