# Setup FSVR1

# Create a disk

# Initialise a new disk using GPT partition style
Initialize-Disk -Number 1 -PartitionStyle GPT | Out-Null
# Create a new partition
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S | Out-Null
# Format the partition
Format-Volume -DriveLetter S -FileSystem "NTFS" -NewFileSystemLabel "Network Share" | Out-Null

Write-Host "Network Share created, Drive letter S, using NTFS." -ForegroundColor Cyan

# Creare user home directories

New-Item -Path 'S:\Shares' -ItemType Directory | Out-Null

# Install File Services role
Install-WindowsFeature File-Services | Out-Null

# Create the SMB share
$smbparams = @{
	Name = "EmployeeHomes"
	Path = "S:\Shares\"
	FullAccess = "Domain Admins", "Domain Users"
	FolderEnumerationMode = "AccessBased"
}

New-SmbShare @smbparams | Out-Null

Write-Host "SMB share EmployeeHomes created on the S drive." -ForegroundColor Cyan

# Setup DFS

# Install windows feature
Install-WindowsFeature FS-DFS-Namespace -IncludeManagementTools | Out-Null

# Create DFS namespace
New-DfsnRoot -Path "\\xyz.local\EmployeeHomes" -Type DomainV2 -TargetPath "\\fsvr1.xyz.local\EmployeeHomes" | Out-Null

Write-Host "DFS configured and setup for EmployeeHomes. Implementing drive mapping." -ForegroundColor Cyan
