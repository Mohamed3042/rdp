@echo off
rem Saves the SERVER login in Windows so \\server and \\192.168.8.107 open on this PC, then maps the D share as Z:.
rem Newer Windows 11 blocks the server's guest access, so it needs a real server account + password.
rem Run from a NORMAL cmd or by double-click - not Administrator (Explorer can't see drives mapped as Administrator).
net session >nul 2>&1 && (
  echo Do NOT run this as Administrator. Open a normal cmd ^(Win+R, cmd, Enter^) and run it again.
  pause
  exit /b 1
)

set "U="
set /p "U=Server login name: "
if not defined U (
  echo No name typed. Run it again.
  pause
  exit /b 1
)

rem Drop old/broken connections to the server. Only disconnects, no files touched.
net use Z: /delete /y >nul 2>&1
net use \\server\D /delete /y >nul 2>&1
net use \\server\IPC$ /delete /y >nul 2>&1
net use \\192.168.8.107\IPC$ /delete /y >nul 2>&1

echo.
echo Type the SERVER password (nothing shows while typing):
cmdkey /add:server /user:SERVER\%U% /pass
echo Type the SAME password again:
cmdkey /add:192.168.8.107 /user:SERVER\%U% /pass

net use Z: \\server\D /persistent:yes
if errorlevel 1 (
  echo.
  echo Z: failed. Take a photo of this window.
  pause
  exit /b 1
)

start "" \\192.168.8.107
echo.
echo Done. Win+R \\192.168.8.107 or \\server now opens. Server D drive is also Z: in This PC.
pause
