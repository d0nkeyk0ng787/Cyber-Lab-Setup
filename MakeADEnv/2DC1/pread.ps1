# Powershell script to prepare server for AD install/setup
# Created by Gnome787  | 24 SEP 22

# Disable IPv6
Disable-NetAdapterBinding -Name 'Ethernet' -ComponentID 'ms_tcpip6' | Out-Null

Write-Host "IPv6 Disabled" -ForegroundColor Cyan

# Create variables for static IP
$IntName = "Ethernet"
$Gateway = "192.168.100.1"
$SVRIP = "192.168.100.2"
$PrefixLen = "24"
$SVRName = "DC1"

# Set the IP address of the interface to a static address
New-NetIPAddress -InterfaceAlias $IntName -IPAddress $SVRIP -Prefix $PrefixLen -DefaultGateway $Gateway | Out-Null

# Print output
Write-Host "Server has been assigned an IP of $SVRIP" -ForegroundColor Cyan
Write-Host "Server has been assigned a Default Gateway of $Gateway" -ForegroundColor Cyan

# Change DNS server to our server
Set-DnsClientServerAddress -InterfaceAlias $IntName -ServerAddress $SVRIP | Out-Null

# Print output
Write-Host "Server has been assigned a DNS address of $SVRIP" -ForegroundColor Cyan
Write-Host "Server has been renamed DC1" -ForegroundColor Cyan

# Rename computer
Rename-Computer -NewName $SVRName -Restart | Out-Null
