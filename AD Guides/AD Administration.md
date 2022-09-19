# AD Administration

### Join client to domain

First we must change the DNS settings for our **Win10** client to the ip of the server so that it can resolve the hostname of said server.

This can be done with the powershell command:

```powershell
Set-DNSClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses <SERVERIP>
```

Once we have changed the DNS server, we can add the client to the domain by doing the following.

```powershell
Add-Computer -DomainName lab.local -Credential lab\Administrator -Force -Restart
```

This will prompt us for a password for the domain admin and then the system will restart.

### Create Organisational Units

```powershell
# Create your main OU
New-ADOrganizationalUnit -Name "XYZ" -Path "DC=xyz,DC=local" 
```

### Create a new AD user

To create a new user we can do the following:
```powershell
$args = @{
    Name = "jsmith"
    AccountPassword = (ConvertTo-SecureString "Password1" -AsPlainText -Force)
    ChangePasswordAtLogon = $true
    Enabled = $true
    DisplayName = "John Smith"
}
New-ADUser @args
# Verify creation
Get-ADUser -Identity 'USERNAME'
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
