# Setup DHCP

### Install DHCPv4 on AD server

First we need to install DHCP on the server. 

```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

Next we need to create the DHCP security groups.

```posh
netsh dhcp add securitygroups
```

Then we restart the service.
```posh
Restart-Service dhcpserver
```
You can verfy the security groups were installed.
```posh
Get-ADGroup -Filter * | Select-String "dhcp"
```

Next we want to add the DHCP server to the list of authorised DHCP servers in AD.
```posh
Add-DhcpServerInDC -Dnsname dc1.xyz.local -IPAddress <IPADDRESS>
```
We can verify we have authorised the server by doing the following.
```posh
Get-DhcpServerInDC
```


Notify the server that post install is complete.
```posh
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
```

### Configure a DHCP scope

From there we want to create a DHCP scope for our internal network. 

```powershell
Add-DhcpServerv4Scope -Name "Internal" -StartRange <FIRSTIPADDRESS> -EndRange <LASTIPADDRESS> -SubnetMask <SUBNETMASK> -Description "Internal Network"
```

I also then globally defined the DNSServer IP, Domain and the default router.

```powershell
Set-DhcpServerv4OptionValue -DNSServer <DNSSVRIP> -DNSDomain <DNSDOMAINNAME> -Router <DEFAULTGATEWAY>
```

Changing the default gateway for a specific scope. The -ScopeId is the network address or it can be the start address.

```powershell
Set-DhcpServerv4OptionValue -ScopeId <SCOPEIDADDRESS> -Router <DEFAULTROUTER>
```

Add a lease time to a scope. This will add a lease time of 1 day.

```powershell
Set-DhcpServerv4Scope -Name "Internal" -StartRange <FIRSTIPADDRESS> -EndRange <LASTIPADDRESS> -SubnetMask <SUBNETMASK> -Description "Internal Network" -LeaseDuration 01.00:00:00
```

Create a superscope. Say we have 2 scopes for wired connections with scope ids of 172.16.50.0 & 172.16.51.0. Our command would look like.

```powershell
Add-DhcpServerv4SuperScope -SuperScopeName "Wired Connections" -ScopeId 172.16.50.0, 172.16.51.0
```

Configure DHCP failover. Ensure the DHCP role has been installed on the partner server. This will create a failover server with a lead time of 1 minute, and will be set to hot standby.

```powershell
Add-DhcpServerv4Failover -Name "DHCP-Failover" -PartnerServer FAILOVERSVRIP -MaxClientLeadTime 00:01:00 -SharedSecret SECRET -ServerRole Standby -ScopeID SCOPEID, SCOPEID, SCOPEID
```

### Configure DHCPv6 scope on AD server

Add a DHCPv6 scope.

```powershell
Add-DhcpServerv6Scope -Name "NAME" -Prefix fd00:0000:0000:0000::
```

Add an exclusion range to this scope. This will exclude addresses from fd00:: to fd00::ff.

```powershell
Add-DhcpServerv6Scope -Prefix fd00:0000:0000:0000:: -StartRange 0000:0000:0000:0000 -EndRange 0000:0000:0000:00ff
```

