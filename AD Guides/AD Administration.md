# AD Administration

### Create Organisational Units

```powershell
# Create your main OU
New-ADOrganizationalUnit -Name "XYZ" -Path "DC=xyz,DC=local" 
# Devices
New-ADOrganizationalUnit -Name "Devices" -Path "OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Devices,OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Devices,OU=XYZ,DC=xyz,DC=local"
# Users
New-ADOrganizationalUnit -Name "Users" -Path "OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "Admins" -Path "OU=Users,OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "Employees" -Path "OU=Users,OU=XYZ,DC=xyz,DC=local"
# Groups
New-ADOrganizationalUnit -Name "Groups" -Path "OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "SecurityGroups" -Path "OU=Groups,OU=XYZ,DC=xyz,DC=local"
New-ADOrganizationalUnit -Name "DistributionLists" -Path "OU=Groups,OU=XYZ,DC=xyz,DC=local"
```

### Create a new AD user

To create a new user we can do the following:
```powershell
# Standard User
$userparams = @{
    Name = "jsmith"
    AccountPassword = (ConvertTo-SecureString "Password1" -AsPlainText -Force)
    ChangePasswordAtLogon = $true
    Enabled = $true
    DisplayName = "John Smith"
}
New-ADUser @userparams
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
