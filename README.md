# Fix Remote Desktop (port 3389)

## A. On the TARGET PC (the one you connect TO, e.g. 192.168.8.107)

Open **Command Prompt as Administrator**, then run the steps below.

### 1. Check Windows edition (Home = no RDP host)
```
systeminfo | findstr /B /C:"OS Name"
```

### 2. Enable RDP + firewall + service (paste all 4 lines at once)
```
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall add rule name="RDP 3389" dir=in action=allow protocol=TCP localport=3389
sc config TermService start= auto
net start TermService
```

### 3. Confirm it listens (expect `0.0.0.0:3389 ... LISTENING`)
```
netstat -an | findstr 3389
```

## B. On YOUR PC (the one you connect FROM, e.g. 192.168.8.111)

### 4. Test port (expect `TcpTestSucceeded : True`)
```
powershell Test-NetConnection 192.168.8.107 -Port 3389
```

### 5. Connect
```
mstsc /v:192.168.8.107
```

## Notes
- Target account must have a password. Blank password = RDP refuses.
- Microsoft account: log in with email + Microsoft password, not PIN.
- Other PCs: repeat steps 1-3 on each, change the IP in steps 4-5.
- Step 1 says Home: RDP host not possible. Upgrade to Pro, or use RustDesk / AnyDesk.
