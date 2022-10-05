# Powershell script to create a virtual machine in Hyper-V
# Created by Gnome787  | 21 SEP 22

# Import AD module
Import-Module ActiveDirectory

# Store csv file data in a variable $OUs
$OUs = Import-Csv H:\MakeADEnv\2DC1\ouconfig.csv -Delimiter ","

# Iterate over each row in the csv file and assign the data to variables
foreach ($OU in $OUs) {
    $Name = [string]$OU.name
    $Path = [string]$OU.path

    # Create OU check variable
    # $OUCheck = Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Where-Object Name -Match $Name
    $OUCheck = Get-ADOrganizationalUnit -Filter 'Name -like $Name'

    # Check to see if the OU exists already
    if ($OUCheck){
    Write-Warning "An OU with the name $Name already exists"
    }
    else {
        # Create OU with specified values
        New-ADOrganizationalUnit -Name $Name -Path $Path
        
        # Print message if OU was created
        Write-Host "An OU with the name $Name was created." -ForegroundColor Cyan
    }
}

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

Write-Host "Staff group created" -ForegroundColor Cyan