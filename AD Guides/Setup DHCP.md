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
