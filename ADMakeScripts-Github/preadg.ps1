# Powershell script to prepare server for AD install/setup
# Created by Gnome787  | 24 SEP 22

# Create variables for static IP
$IntName = "Ethernet"
$Gateway = "192.168.100.1"
$SVRIP = "192.168.100.2"
$PrefixLen = "24"
$SVRName = "DC1"

# Set the IP address of the interface to a static address
New-NetIPAddress -InterfaceAlias $IntName -IPAddress $SVRIP -Prefix $PrefixLen -DefaultGateway $Gateway

# Change DNS server to our server
Set-DnsClientServerAddress -InterfaceAlias $IntName -ServerAddress $SVRIP

# Rename computer
Rename-Computer -NewName $SVRName -Restart