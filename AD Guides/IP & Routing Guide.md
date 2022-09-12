# IP & Routing Guide 

### Configure a new IP on an interface

```powershell
New-NetIPAddress -InterfaceIndex 6 -IPAddress <IPADDRESS> -PrefixLength 24 -DefaultGateway <DEFAULTGATEWAY>
```

### Configure a DHCP Relay Agent

Routing & Remote Access > Expand the PC name > IPv4 > Right-click general > DHCP Relay Agent > Right-click DHCP Relay Agent then click Properties > Add the IP addresses you want your relay agent to relay DHCP addresses to > Right-click DHCP Relay Agent > New Interface > Select your interface > Adjust the properties if you need and then click OK > Repeat for any other interface you wish to add.
