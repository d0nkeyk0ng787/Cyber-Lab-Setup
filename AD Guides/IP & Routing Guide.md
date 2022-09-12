# IP & Routing Guide 

### Configure a new IP on an interface

```powershell
New-NetIPAddress -InterfaceIndex 6 -IPAddress <IPADDRESS> -PrefixLength 24 -DefaultGateway <DEFAULTGATEWAY>
```

### Configure a DHCP Relay Agent

