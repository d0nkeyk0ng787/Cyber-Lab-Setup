# AD Install

### Start a PSRemoting Session

On a remote machine start WinRM.

```powershell
Start-Service WinRM
```

Now add the remote host to the trusted hosts.

```powershell
Set-Item WSMan:\localhost\clients\trustedhosts\ -Value <IPADDRESS>
```

Now start a new PSSession.

```powershell
New-PSSession -ComputerName <IPADDRESS> -Credential (Get-Credentail)
```

This will launch a prompt where you will enter the remote hosts username and password and then it will start a session. From there you just enter the session and will be able to remotely configure the host through powershell.

```powershell
Enter-PSSession <SESSIONID>
```

### Install AD On Server Core

Before we install AD, we need to ensure we have set a static IP address for the server. This can be done from **SConfig** pressing option **8**. From here set the address, default gateway and DNS server.

To install AD DS with management tookls, we simply enter the following.

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

This will then start the install process which will take a little while.

Installation can be verified with the following command. Scroll up to the top and note the **X** in the box for **Active Directory Domain Services**.

```powershell
Get-WindowsFeature
```

### Configure AD DS

First we want to import the module so that we can work with it.

```powershell
Import-Module ADDSDeployment
```

Now we want to install our AD DS forest and configure our server as a domain controller.

```powershell
Install-ADDSForest
```

From here we will need to choose a domain name and enter in a password. The server will then restart and will now be a domain controller.

One last thing we will need to go back into **SConfig** upon the servers reboot and change the **DNS** to our servers IP and not **127.0.0.1**.

### Configure a DC on an exisitng Domain

We want to add our new server as a DC on an exisiting domain, this can be done by doing the following on the new server.

```posh
Import-Module ADDSDeployment
```

```posh
Install-ADDSDomainController -DomaiName "Adatum.com" -InstallDns:$true -NoRebootOnCompletion:$false -Force:$true 
```

Input a password when prompted and you are done.


