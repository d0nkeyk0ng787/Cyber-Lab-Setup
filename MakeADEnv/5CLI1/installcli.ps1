# Install CLI1 

# Disable IPv6
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6' | Out-Null

# Set the DNS
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.100.2

Write-Host "Clients DNS server was changed to 192.168.100.2" -ForegroundColor Cyan

# Create a domain credential object
$Password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential ("xyz\Administrator", $Password) 

# Join to domain
Add-Computer -DomainName xyz.local -Credential $DomainCred -Force -Restart