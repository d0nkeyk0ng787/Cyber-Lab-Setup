# Install DHCP server

# Disable IPv6
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6' | Out-Null

# Assign a static IP
$ipparams = @{
    InterfaceIndex = (Get-NetAdapter).InterfaceIndex
	IPAddress = "192.168.100.3"
	PrefixLength = 24
	DefaultGateway = "192.168.100.1"
}

New-NetIPAddress @ipparams | Out-Null

# Completed message
Write-Host "Server has been assigned an IP of 192.168.100.3" -ForegroundColor Cyan
Write-Host "Server has been assigned a Default Gateway of 192.168.100.1" -ForegroundColor Cyan

# Change the DNS server to DC1 
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter).name -ServerAddresses 192.168.100.2  | Out-Null

# Completed message
Write-Host "Servers DNS server has been changed to 192.168.100.2" -ForegroundColor Cyan

# Create a domain credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential ("xyz\Administrator", $Password) 

# Join computer to the domain
$domainparams = @{
	DomainName = "xyz.local"
	NewName = "DHCP"
	OUPath = "OU=Servers,OU=Devices,OU=XYZ,DC=xyz,DC=local"
	Credential = $DomainCred
	Force = $true
	Restart = $true
}

Add-Computer @domainparams