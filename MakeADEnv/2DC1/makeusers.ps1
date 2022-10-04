# Powershell script to create a virtual machine in Hyper-V
# Created by Gnome787  | 21 SEP 22

# Import AD module
Import-Module ActiveDirectory

# Store csv file data in a variable $Users
$Users = Import-Csv H:\MakeADEnv\2DC1\userconfig.csv -Delimiter ","

# Iterate over each row in the csv file and assign the data to variables
foreach ($User in $Users) {
    $FirstName = [string]$User.firstname
    $LastName = [string]$User.lastname
    $Username = [string]$User.username
    $Password = [string]$User.password
    $Org = [string]$User.ou

    # Create User check variable
    $UserCheck = Get-ADUser -Filter 'Name -like $Username' 

    # Check to see if the User exists already
    if ($UserCheck){
    Write-Warning "A User with the name $Username already exists"
    }
    else {
        # Create User with specified values
        $params = @{
            Name = "$Username"
            GivenName = $FirstName
            Surname = $LastName
            DisplayName = "$LastName, $FirstName"
            Path = $Org
            AccountPassword = (ConvertTo-SecureString $Password -AsPlainText -Force)
            Enabled = $true
            ChangePasswordAtLogon = $true
        }
        New-ADUser @params

        # Add user to staff group
        Add-AdGroupMember -Identity "Staff" -Members $Username

        # Add user to remote desktop users
        Add-ADGroupMember -Identity "Remote Desktop Users" -Members $Username
        
        # Print message if User was created
        Write-Host "A user with the name $FirstName $LastName was created." -ForegroundColor Cyan
        Write-Host "$Username was added to the Staff group" -ForegroundColor Cyan
        Write-Host "$Usernaem was added to the remote desktop users group" -ForegroundColor Cyan
    }
}