# Fix Remote Desktop (port 3389)

## 0. Which PC am I on? (run on any PC)

Shows this PC's IP. Part A must run on the PC that shows `192.168.8.107`.
```
ipconfig | findstr IPv4
```

Is "server" the .107 PC? Run from 192.168.8.111:
```
ping -4 server
```

Confirmed: `SERVER` = 192.168.8.107 (the file-server computer).

## A. On the SERVER computer itself (192.168.8.107) - sit at it in person

The OMEN PC is 192.168.8.111 (Windows 11 Home). Do NOT run part A on the OMEN PC.

Open **Command Prompt as Administrator**. STOP check first - this must print `SERVER`. If not, wrong PC:
```
hostname
```

No browser on the server? Open this sheet in Notepad:
```
notepad "\\server\D\Mail folder\22 - Moamed Ahmed\the test\rdp.txt"
```

### 1. Check Windows edition (Home = no RDP host)
CHECKED: SERVER = Windows 7 Professional -> RDP OK. Windows 7 cmd: Ctrl+V does NOT paste. Right-click inside the window -> Paste.
SERVER is Windows 7 (6.1.7601). OK = Professional / Ultimate / Enterprise. NOT OK = Starter / Home Basic / Home Premium.
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

CHECKED: SERVER shows `0.0.0.0:3389 LISTENING` -> server side done.

### 3b. Still on SERVER: make a separate RDP login (existing account untouched)
Paste ONE box at a time. This asks for your new login name (no spaces) - type it, press Enter:
```
set /p U=New login name: 
```
Create it. Type a new password twice (nothing shows while typing). Write it down:
```
net user %U% * /add
```
Allow Remote Desktop + stop password expiring after 42 days (right-click -> Paste):
```
net localgroup "Remote Desktop Users" %U% /add
wmic useraccount where name="%U%" set PasswordExpires=FALSE
```
Optional - full admin over RDP (install software, settings):
```
net localgroup Administrators %U% /add
```
Login in step 5: `SERVER\` + your name, and the password you set.

### 3c. FIX: forgot the name, account got created as `%U%`
Do this in a NEW Command Prompt (Administrator). List accounts - look for `%U%`:
```
net user
```
`%U%` is there? Rename it. This asks the real name - type it, Enter:
```
set /p N=New login name: 
```
```
wmic useraccount where name="%U%" rename %N%
```
Check: expect `*Remote Desktop Users` and `Password expires  Never`:
```
net user %N%
```
`%U%` NOT in the list? Do 3b again.

## B. On YOUR PC (the one you connect FROM, e.g. 192.168.8.111)

### 4. Test port (expect `TcpTestSucceeded : True`)
```
powershell Test-NetConnection 192.168.8.107 -Port 3389
```

### 5. Connect
```
mstsc /v:192.168.8.107
```
Same thing by name:
```
mstsc /v:server
```

## Notes
- SERVER gets its IP from the router (DHCP), so .107 can change. Connect by name (`mstsc /v:server`) to be safe.
- SECURITY: Windows 7 RDP has a known remote-takeover hole (BlueKeep). Use RDP inside the office network only. NEVER forward port 3389 on the router.
- `SourceAddress` in step 4 = the PC you are on. If it says .111, you are NOT on the target.
- Target account must have a password. Blank password = RDP refuses.
- Microsoft account: log in with email + Microsoft password, not PIN.
- Other PCs: repeat steps 1-3 on each, change the IP in steps 4-5.
- Step 1 says Home: RDP host not possible. Upgrade to Pro, or use RustDesk / AnyDesk.
