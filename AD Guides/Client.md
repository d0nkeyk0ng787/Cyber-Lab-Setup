### Join client to domain

Change client DNS server to the DC server address:

```powershell
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.2
```

Add the client computer to the domain:

```powershell
Add-Computer -DomainName xyz.local -Credential xyz\Administrator -Force -Restart
```

This will prompt us for a password for the domain admin and then the system will restart.
