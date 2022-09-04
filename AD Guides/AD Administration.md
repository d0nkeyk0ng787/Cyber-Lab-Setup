# AD Administration

### Join client to domain

If the server isn't part of a domain and is still in a workgroup we must open up our **SConfig** and select option **1**. We then want to input **d** for domain and type in the domain we gave the server. Otherwise continue with next steps.

First we must change the DNS settings for our **Win10** client to the ip of the server so that it can resolve the hostname of said server.

This can be done with the powershell command:

```powershell
Set-DNSClientServerAddrss -InterfaceAlias Ethernet0 -ServerAddresses <SERVERIP>
```

Once we have changed the DNS server, we can add the client to the domain by doing the following.

```powershell
Add-Computer -DomainName lab.local -Credential lab\Administrator -Force -Restart
```

This will prompt us for a password for the domain admin and then the system will restart.

### Create a new AD user

In the server run the following command

```powershell
New-ADUser -Name "john" -AccountPassword (Read-Host -AsSecureString "Account Password") -Enabled $true
```

This will then prompt for a password and then the user will be created. This can be verified by typing.

```powershell
Get-ADUser -Filter *
```

### Join a user to a group

Let's say we want to add a user to the domain admins group. First we want to return the name of that group so we do.

```powershell
Get-AdGroupMember "Administrators"
```

This will return all the administrator groups. We see **Domain Admins** is what we want.

From there we add our user to this group by doing.

```powershell
Add-AdGroupMember -Identity "Domain Admins" -Members john
```

Then we can verify our user has join the group by doing.

```powershell
Get-AdGroupMember "Domain Admins"
```
