# AD Administration

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

