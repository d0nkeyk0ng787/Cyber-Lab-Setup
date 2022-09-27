# PSRemoting

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
