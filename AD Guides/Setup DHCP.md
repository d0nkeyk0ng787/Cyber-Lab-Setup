# DHCPSVR - Setup

### Pre DHCP Setup

```powershell
# Assign a static IP
$ipparams = @{
    InterfaceIndex = (Get-NetAdapter).InterfaceIndex
	IPAddress = "192.168.1.3"
	PrefixLength = 24
	DefaultGateway = "192.168.1.1"
}

New-NetIPAddress @ipparams

# Change the DNS server to DC1 
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter).name -ServerAddresses 192.168.1.2

```

### Join server to domain

```powershell
# Join computer to the domain
$domainparams = @{
	DomainName = "xyz.local"
	NewName = "DHCP"
	OUPath = "OU=Servers,OU=Devices,OU=XYZ,DC=xyz,DC=local"
	Credential = "xyz\Administrator"
	Force = $true
	Restart = $true
}

Add-Computer @domainparams
```

### Install & setup DHCP

```powershell
# Install DHCP
Install-WindowsFeature DHCP -IncludeManagementTools

# Add DHCP security groups
netsh dhcp add securitygroups

# Restart DHCP server
Restart-Service dhcpserver
# You can verfy the security groups were installed.
Get-ADGroup -Filter * | Select-String "dhcp"

# Add the DHCP server to the list of authorised DHCP servers in AD
Add-DhcpServerInDC -Dnsname dhcp.xyz.local

# Notify the server that post install is complete
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
```

### Configure DHCP Scopes

```powershell
# Create internal scope
Add-DhcpServerv4Scope -Name "Internal" -StartRange 192.168.1.50 -EndRange 192.168.1.254 -SubnetMask 255.255.255.0 -Description "Internal Network"

# Globally define the DNSServer IP, Domain and the default router.
Set-DhcpServerv4OptionValue -DNSServer 192.168.1.2 -DNSDomain xyz.local -Router 192.168.1.2

# Create an Exclusion range on the scope
Add-Dhcpserverv4ExclusionRange -ScopeId 192.168.1.0 -StartRange 192.168.1.1 -EndRange 192.168.1.49
```

### Additional DHCP Configurations - NOT REQUIRED

```powershell
# Change the default gateway for a specific scope. The -ScopeId is the network address or it can be the start address.
Set-DhcpServerv4OptionValue -ScopeId <SCOPEIDADDRESS> -Router <DEFAULTROUTER>

# Add a lease time to a scope. This will add a lease time of 1 day.
Set-DhcpServerv4Scope -Name "Internal" -StartRange <FIRSTIPADDRESS> -EndRange <LASTIPADDRESS> -SubnetMask <SUBNETMASK> -Description "Internal Network" -LeaseDuration 01.00:00:00

# Create a superscope. Say we have 2 scopes for wired connections with scope ids of 172.16.50.0 & 172.16.51.0. Our command would look like.
Add-DhcpServerv4SuperScope -SuperScopeName "Wired Connections" -ScopeId 172.16.50.0, 172.16.51.0

# Configure DHCP failover. Ensure the DHCP role has been installed on the partner server. This will create a failover server with a lead time of 1 minute, and will be set to hot standby.
Add-DhcpServerv4Failover -Name "DHCP-Failover" -PartnerServer FAILOVERSVRIP -MaxClientLeadTime 00:01:00 -SharedSecret SECRET -ServerRole Standby -ScopeID SCOPEID, SCOPEID, SCOPEID
```

**DHCPv6**
```powershell
Add-DhcpServerv6Scope -Name "NAME" -Prefix fd00:0000:0000:0000::

# Add an exclusion range to this scope. This will exclude addresses from fd00:: to fd00::ff.
Add-DhcpServerv6Scope -Prefix fd00:0000:0000:0000:: -StartRange 0000:0000:0000:0000 -EndRange 0000:0000:0000:00ff
```
