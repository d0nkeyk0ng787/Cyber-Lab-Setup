# Import AD module
Import-Module ActiveDirectory

# Store csv file data in a variable $Users
$Users = Import-Csv PATHTOCSV -Delimiter ","

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
        $args = @{
            Name = "$Username"
            GivenName = $FirstName
            Surname = $LastName
            DisplayName = "$LastName, $FirstName"
            Path = $Org
            AccountPassword = (ConvertTo-SecureString $Password -AsPlainText -Force)
            Enabled = $true
            ChangePasswordAtLogon = $true
        }
        New-ADUser @args
        
        # Print message if User was created
        Write-Host "A user with name $FirstName $LastName was created."
    }

}
Read-Host -Prompt "Press Enter to exit"
