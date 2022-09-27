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

```powershell
# Initialise a new disk using GPT partition style
Initialize-Disk -Number 1 -PartitionStyle GPT
# Create a new partition
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
# Format the partition
Format-Volume -DriveLetter S -FileSystem "NTFS" -NewFileSystemLabel "Network Share"

# Verify the volume was created
Get-Volume
