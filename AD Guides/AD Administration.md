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

### Groups

```powershell
# Create a new group for staff
$groupparams = @{
    Name = "Staff"
    SamAccountName = "Staff"
    GroupCategory = "Security"
    GroupScope = "Global"
    DisplayName = "Staff"
    Path = "OU=SecurityGroups,OU=Groups,OU=XYZ,DC=xyz,DC=local"
    Description = "Members of this group are staff at XYZ"
}
New-ADGroup @groupparams

# From there we add our user to this group by doing.
Add-AdGroupMember -Identity "Staff" -Members "john.smith"
```

### Create & setup a Wallpaper GPO

```posh
# Create GPO
New-GPO -name "Wallpaper"
# Note down the Guid and past it into the following command

# Link GPO to OU
New-GPlink -Guid "92d4cf93-8f73-4019-9deb-98507d6568fd" -target "OU=Employees,OU=Users,OU=XYZ,DC=xyz,DC=local"

# Set desktop wallpaper
Set-GPRegistryValue -Name "Wallpaper" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName 'WallpaperStyle' -Value 0 -Type Dword
Set-GPregistryValue -Name "Wallpaper" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName 'Wallpaper' -Value '\\dc1.xyz.local\SYSVOL\BG\bg.jpg' -Type ExpandString

# Prevent users changing the desktop background
Set-GPRegistryValue -Name "Wallpaper" -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop'   -ValueName 'NoChangingWallPaper' -Value 1   -Type Dword

# Set the permissions for the staff group
Set-GPPermission -Name "Wallpaper" -TargetName "Staff" -TargetType Group -PermissionLevel GpoRead
```
