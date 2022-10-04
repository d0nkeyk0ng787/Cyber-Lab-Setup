# Setup DHCP environment

# Install DHCP
Install-WindowsFeature DHCP -IncludeManagementTools

# Add DHCP security groups
netsh dhcp add securitygroups

# Restart DHCP server
Restart-Service dhcpserver

Write-Host "DHCP service is restarting..." -ForegroundColor Magenta

# Sleep for a few seconds
Start-Sleep -Seconds 5

# Add the DHCP server to the list of authorised DHCP servers in AD
Add-DhcpServerInDC -Dnsname dhcp.xyz.local

# Notify the server that post install is complete
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2

# Create internal scope
Add-DhcpServerv4Scope -Name "Internal" -StartRange 192.168.100.50 -EndRange 192.168.100.254 -SubnetMask 255.255.255.0 -Description "Internal Network"

# Globally define the DNSServer IP, Domain and the default router.
Set-DhcpServerv4OptionValue -DNSServer 192.168.100.2 -DNSDomain xyz.local -Router 192.168.100.1

# Create an Exclusion range on the scope
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.100.0 -StartRange 192.168.100.1 -EndRange 192.168.100.49

# Complete message
Write-Host "DHCP server setup is complete...continuing" -ForegroundColor Cyan