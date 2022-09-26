# Powershell script to create a virtual machine in Hyper-V
# Created by Gnome787  | 22 SEP 22

# 1 MB in B (Binary)
$1BM = 1048576
# 1 GB in B (Binary)
$1BG = 1073741824

# Store csv file in a variable
$VMs = Import-Csv PATH -Delimiter ","

# Iterate over each row in the csv file and assign the data to variables
foreach($VM in $VMs){
    # Create variables for the parameters of the New-VM command based on values in the csv file
    $VMName = [string]$VM.vmname
    $Memory = [int]$VM.memory * $1BM
    $Path = [string]$VM.path + $VMName
    $NewVHDPath = [string]$VM.newvhdpath + $VMName + "\" + $VMName + ".vhdx"
    $Storagesize = [int]$VM.storagesize * $1BG
    $ISOPath = $VM.isopath

    # Create a vm check variable
    $VMCheck = Get-VM -VMName $VMName -erroraction 'silentlycontinue'

    # If statement that checks to see if a VM with that name already exists
    if ($VMCheck){
        Write-Warning "A VM with the name $VMName already exists"
    }
    # If no VM with that name exists, continue
    else{
        # Specify the parameters of our new VM.
        $VMParams = @{
            Name = $VMName
            MemoryStartupBytes = $Memory
            Generation = 2
            NewVHDPath = $NewVHDPath
            NewVHDSizeBytes = $Storagesize
            BootDevice = "VHD"
            Path = $Path
            SwitchName = (Get-VMSwitch).name
        }

        # Create the VM.
        New-VM @VMParams

        # Add a DVD drive and mount the iso file.
        Add-VMDvdDrive -VMName $VMName -Path $ISOPath

        # Create variables for the names of the boot devices.
        $DVD = (Get-VMDvdDrive -VMName $VMName)
        $HDD = (Get-VMHardDiskDrive -VMName $VMName)
        $NA = (Get-VMNetWorkAdapter -VMName $VMName)

        # Set boot order.
        Set-VMFirmware -VMName $VMName -BootOrder $DVD, $HDD, $NA

        # Print message if VM was created
        Write-Host "A VM with the name $VMName was created."
    }
}
