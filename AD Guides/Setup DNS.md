# Setup DNS 

**Note** - A number of these commands have ```-PassThru``` added to the end of them. This command simply print the output to the console so you can see the changes.

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

