@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto Grabbing
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit
REM Must be ran as admin.

REM Part 0: Are you using ZeroTier?

:Grabbing
if not exist SCDA_online.txt (
	set files=SCDA_online
	call chooser.bat
	goto :proceeds
)
:proceeds
if not exist gamedir.txt (
echo Choose folder containing the game...
set folderloc=gamedir
call chooserf.bat
goto :checking
)

:checking
if not exist SCDA_online.txt goto REQUIRED
if not exist gamedir.txt goto :REQUIRED
goto :VPNCHECK 

:REQUIRED
echo You need to specify the game's location...
echo Try Again, Quit?
choice /C 12 /n /M "Try Again [1] Quit [2]"
if ERRORLEVEL 2 exit
if ERRORLEVEL 1 goto setup

:VPNCHECK
echo Are you using ZeroTier, or Other?
choice /c 12 /n /M "ZeroTier [1], Other [2]"
if ERRORLEVEL 2 goto START
if ERRORLEVEL 1 goto BEGIN


:BEGIN
sc start ZeroTierOneService>NUL
If ERRORLEVEL 0 (
  GOTO BESURE
) ELSE (
  echo ZeroTier Process Could Not Be Started...
  echo Make sure program is installed / reinstall the program.
  choice /c 12 /n /M "Launch Anyway? Yes[1], No[2]"
  if ERRORLEVEL 2 exit
  if ERRORLEVEL 1 goto START
)


:BESURE
echo Are you joining the unify network, or a private one?
choice /C 12 /n /M "Unify [1] Private [2]"
if ERRORLEVEL 2 goto private
if ERRORLEVEL 1 goto unify

:unify
echo Connecting to the Unify Network...
set network=0cccb752f756b32b
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
Timeout /T 5 /Nobreak >NUL
goto START

:private
echo Please enter the private network's ID...
set /p network="Network ID: "
echo Connecting to the private network...
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
Timeout /T 5 /Nobreak >NUL
goto START


:START
set /p thegame=<SCDA_Online.txt
set "limiterdir=%local%\DoubleAgent\Limiter"
cd /d "%limiterdir%"
call SCDA_online.exe.limited.bat
popd
REM The above launches the 3D Analyzer Program & Game

REM Part 2: Setting the Network Adapter
set "NetConID="
  wmic NIC where Description="ZeroTier One Virtual Port" ^
    list /format:textvaluelist.xsl>"%temp%\wmcnc.txt" 2>&1
  for /F "tokens=1* delims==" %%I in ('type "%temp%\wmcnc.txt"') do (
    if /i "%%I"=="NetConnectionID" set "NetConID=%%~J"
  )
del "%temp%\wmcnc.txt" 2>nul
netsh interface ipv4 set interface "!NetConID!" metric=1 >NUL
ECHO Metric has been set.
REM The above sets the metric of the adapter.

REM PART 3: Game Status

ECHO Game has launched, monitoring now.
Timeout /T 20 /Nobreak >NUL
REM This will monitor the game's activity. If it stops running, then everything is closed.
:LOOP
tasklist | find /i "SCDA_online" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO QUIT
) ELSE (
  Timeout /T 1 /Nobreak >NUL
  GOTO LOOP
)
REM This checks and sees if CT is operating. Slight loop delay added.

:QUIT
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q leave %network% >NUL
Timeout /T 1 /Nobreak >NUL
taskkill /F /IM SCDALauncher.exe >NUL
taskkill /F /IM FPS_Limiter.exe >NUL
exit
