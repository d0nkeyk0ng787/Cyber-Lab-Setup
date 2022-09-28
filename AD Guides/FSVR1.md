# File Server 1 Setup

### Join FSVR1 to the domain

```powershell
# Assign a static IP
$ipparams = @{
  InterfaceIndex = (Get-NetAdapter).InterfaceIndex
	IPAddress = "192.168.1.5"
	PrefixLength = 24
	DefaultGateway = "192.168.1.1"
}

New-NetIPAddress @ipparams

# Change the DNS server to DC1 
Set-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter).name -ServerAddresses 192.168.1.2

# Join computer to the domain
$domainparams = @{
	DomainName = "xyz.local"
	NewName = "FSVR1"
	OUPath = "OU=Servers,OU=Devices,OU=XYZ,DC=xyz,DC=local"
	Credential = "xyz\Administrator"
	Force = $true
	Restart = $true
}

Add-Computer @domainparams
```

### File Server Setup

**Create a disk**
```powershell
# Initialise a new disk using GPT partition style
Initialize-Disk -Number 1 -PartitionStyle GPT
# Create a new partition
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
# Format the partition
Format-Volume -DriveLetter S -FileSystem "NTFS" -NewFileSystemLabel "Network Share"

# Verify the volume was created
Get-Volume
```

**Create an SMB-Share**
```posh
# Install File Services role
Install-WindowsFeature File-Services

# Create an SMB share
$smbparams = @{
	Name = "EmployeeData"
	Path = "S:\Shares\EmployeeData\"
	FullAccess = "Domain Admins"
	ReadAccess = "Domain Users"
	FolderEnumerationMode = "AccessBased"
}

New-SmbShare @smbparams
```

### Setup DFS

**Install DFS**
```posh
# Install windows feature
Install-WindowsFeature FS-DFS-Namespace -IncludeManagementTools
```

**Create DFS**
```posh
# Create DFS namespace
New-DfsnRoot -Path "\\xyz.local\EmployeeData" -Type DomainV2 -TargetPath "\\fsvr1.xyz.local\EmployeeData"

# Confirm it was created
Get-DfsnRoot -Path "\\xyz.local\EmployeeData" | Format-List 
```

### Drive Mapping GPO

**Note** - Credits for this part to [REDACTED-DEV](https://github.com/REDACTD-DEV/CyberLab/blob/main/File%20Server.md)

This part is done on the domain controller!

```posh
#Create GPO
$gpoOuObj=new-gpo -name "NetShare"

#Link GPO to domain
new-gplink -Guid $gpoOuObj.Id.Guid -target "DC=xyz,DC=local"

#Get GUID and make it upper case
$guid = $gpoOuObj.Id.Guid.ToUpper()

#Create a folder that the GP MMC snap-in normally would
$path="\\xyz.local\SYSVOL\xyz.local\Policies\{$guid}\User\Preferences\Drives"
New-Item -Path $path -type Directory | Out-Null

#Variables that would normally be set in the Drive Mapping dialog box
$Letter = "M"
$Label = "EmployeeData"
$SharePath = "\\xyz.local\EmployeeData"
$ILT = "XYZ\Staff"
$SID = (Get-ADGroup "Staff").SID.Value

#Date needs to be inserted into the XML
$Date = Get-Date -Format "yyyy-MM-dd hh:mm:ss"

#A Guid needs to be inserted into the XML - This can be completely random 
$RandomGuid = (New-Guid).Guid.ToUpper()

#The XML
$data = @"
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
	<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" bypassErrors="1" uid="{$RandomGuid}" changed="$Date" image="2" status="${Letter}:" name="${Letter}:">
		<Properties letter="$Letter" useLetter="1" persistent="1" label="$Label" path="$SharePath" userName="" allDrives="SHOW" thisDrive="SHOW" action="U"/>
		<Filters>
      <FilterGroup bool="AND" not="0" name="$ILT" sid="$SID" userContext="1" primaryGroup="0" localGroup="0"/>
    </Filters>
	</Drive>
</Drives>
"@
#Write XML
$data | out-file $path\drives.xml -Encoding "utf8"

#Edit AD Attribute "gPCUserExtensionNames" since the GP MMC snap-in normally would 
$ExtensionNames = "[{00000000-0000-0000-0000-000000000000}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}][{5794DAFD-BE60-433F-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}]"
Set-ADObject -Identity "CN={$guid},CN=Policies,CN=System,DC=xyz,DC=local" -Add @{gPCUserExtensionNames=$ExtensionNames}

#A versionNumber of 0 means that clients won't get the policy since it hasn't changed
#Edit something random (and easy) so it increments the versionNumber properly
#This one removes the computer icon from the desktop.
$Params = @{
    Name = "NetShare"
    Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum"
    Type = "DWORD"
    ValueName = "{645FF040-5081-101B-9F08-00AA002F954E}"
    Value = 0
}
set-GPRegistryValue @Params
```

### Create user home directory

**On the FSVR1**
```posh
# Create the SMB share
$smbparams = @{
	Name = "EmployeeHomes"
	Path = "S:\Shares\"
	FullAccess = "Domain Admins", "Domain Users"
	FolderEnumerationMode = "AccessBased"
}

New-SmbShare @smbparams
```

### Map the Drive 

**On DC1**
```posh
#Create GPO
$gpoOuObj=new-gpo -name "UserHomeDriveMap"

#Link GPO to domain
new-gplink -Guid $gpoOuObj.Id.Guid -target "DC=xyz,DC=local"

#Get GUID and make it upper case
$guid = $gpoOuObj.Id.Guid.ToUpper()

#Create a folder that the GP MMC snap-in normally would
$path="\\xyz.local\SYSVOL\xyz.local\Policies\{$guid}\User\Preferences\Drives"
New-Item -Path $path -type Directory | Out-Null

#Variables that would normally be set in the Drive Mapping dialog box
$Letter = "L"
$Label = "%username% Home"
$SharePath = "\\xyz.local\EmployeeHomes"
$ILT = "XYZ\Staff"
$SID = (Get-ADGroup "Staff").SID.Value

#Date needs to be inserted into the XML
$Date = Get-Date -Format "yyyy-MM-dd hh:mm:ss"

#A Guid needs to be inserted into the XML - This can be completely random 
$RandomGuid = (New-Guid).Guid.ToUpper()

#The XML
$data = @"
<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}">
	<Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" bypassErrors="1" uid="{$RandomGuid}" changed="$Date" image="2" status="${Letter}:" name="${Letter}:">
		<Properties letter="$Letter" useLetter="1" persistent="1" label="$Label" path="$SharePath" userName="" allDrives="SHOW" thisDrive="SHOW" action="U"/>
		<Filters>
      <FilterGroup bool="AND" not="0" name="$ILT" sid="$SID" userContext="1" primaryGroup="0" localGroup="0"/>
    </Filters>
	</Drive>
</Drives>
"@
#Write XML
$data | out-file $path\drives.xml -Encoding "utf8"

#Edit AD Attribute "gPCUserExtensionNames" since the GP MMC snap-in normally would 
$ExtensionNames = "[{00000000-0000-0000-0000-000000000000}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}][{5794DAFD-BE60-433F-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}]"
Set-ADObject -Identity "CN={$guid},CN=Policies,CN=System,DC=xyz,DC=local" -Add @{gPCUserExtensionNames=$ExtensionNames}

#A versionNumber of 0 means that clients won't get the policy since it hasn't changed
#Edit something random (and easy) so it increments the versionNumber properly
#This one removes the computer icon from the desktop.
$Params = @{
    Name = "UserHomeDriveMap"
    Key = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum"
    Type = "DWORD"
    ValueName = "{645FF040-5081-101B-9F08-00AA002F954E}"
    Value = 0
}
Set-GPRegistryValue @Params
```
