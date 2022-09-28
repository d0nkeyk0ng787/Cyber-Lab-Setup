# Setup DNS 

### Install DNS

```posh
Install-WindowsFeatures DNS -IncludeManagementTools
```

### Create a primary zone

Create a primary zone, added to the forest partition.

```posh
Add-DnsServerPrimaryZone -Name "NAME" -ReplicationScope "Forest" -PassThru
```

Create a file-backed primary zone.

```posh
Add-DnsServerPrimaryZone -Name "NAME" -ZoneFile "NAME.dns"
```

### Add a forwarder

This will allow you to forward DNS queries through a different server. 

```posh
Add-DnsServerForwarder -IPAddress <IPADDRESS> -PassThru
```

### Add a secondary DNS zone

There must first be a primary zone configured on a different server, say 172.16.0.1. On our server 172.16.1.1, we create a secondary zone.

```posh
ADd-DnsServerSecondaryZone -Name "TreyResearch.net" -MasterServer 172.16.0.1 -ZoneFile "TreyResearch.net.dns" -PassThru
```

From there we must notify our secondary server so that it can get the zone information. This is done like so:
Go into primary server > DNS Manager > Right-click DNS zone under Forward Lookup Zones > Properties > Zone Transfers > Allow zone transfer, select Only to the following servers > Click Edit > Type the secondary server IP (in our case 172.16.1.1) > Click Notify > Under Automatically Notify select The Following Servers > Type the IP of the secondary server > Click OK

Going back to the secondary server, you should see the SOA and NS records.


