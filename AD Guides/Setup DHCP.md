# Setup DHCP

### Configure DHCP scope on AD server

First we need to install DHCP on the server. 

```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

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
