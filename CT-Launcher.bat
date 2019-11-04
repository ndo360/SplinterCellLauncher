@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto ORIGIN
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit
REM Must be ran as admin.

REM Part 0: Are you using ZeroTier?

:ORIGIN
set "exe=ZeroTier One.exe"

echo Welcome to the launcher.
echo Before we can launch, have you ran the game with 3DAnalyzer before?
choice /C YN /n /M "Yes [Y] No [N]"
if ERRORLEVEL 2 goto INFO
if ERRORLEVEL 1 goto VPNCHECK

:INFO
echo You must have ran the game at least once through 3DAnalzyer.
echo This is to ensure that you have the flashlight fix applied.
echo Once you have ran the game at least once, using 3DAnalyzer, you may use this launcher.
echo Press any button to close.
pause >NUL
exit

:VPNCHECK
echo Are you using ZeroTier, or Other?
choice /c 12 /n /M "ZeroTier [1], Other [2]"
if ERRORLEVEL 2 goto START
if ERRORLEVEL 1 goto BEGIN

:BEGIN
tasklist /fi "imagename eq %exe%" 2>NUL |find /I /N "%exe%">NUL
If not ERRORLEVEL 1 (
  GOTO BESURE
) ELSE (
  echo Starting ZeroTier...
  start "" "C:\Program Files (x86)\ZeroTier\One\ZeroTier One.exe"
  Timeout /T 3 /Nobreak >NUL
  GOTO BEGIN
)

:BESURE
echo Are you joining the unify network, or a private one?
choice /C 12 /n /M "Unify [1] Private [2]"
if ERRORLEVEL 1 goto unify
if ERRORLEVEL 2 goto private

:unify
echo Connecting to the Unify Network...
set network=0cccb752f756b32b
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
goto Ensuring-Connection

:private
echo Please enter the private network's ID...
set /p network="Network ID: "
echo Connecting to the private network...
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
goto Ensuring-Connection


:Ensuring-Connection
echo Please wait as the launcher verifies the adapter's creation...
:Ensuring-Loop
FOR /F "tokens=3,*" %%A IN ('netsh interface show interface^|find "Connected"') DO echo %%B | findstr "ZeroTier" > Nul
If not ERRORLEVEL 1 (
  GOTO START
) ELSE (
  Timeout /T 1 /Nobreak >NUL
  goto Ensuring-Loop
)


:START
REM PART 1: Launching Framer and the Game.
start "" "Framer.exe"
REM Launches Framer for optional FPS change.
echo Enter your desired FPS.
echo Click here and press any key to proceed.
pause >NUL
REM This allows for users to enter their own FPS before proceeding.
start "" "3DAnalyzer\3DAnalyze.exe" /EXE=%~dp0\System\SCCT_Versus.exe
REM The above launches the 3D Analyzer Program & Game

REM Part 2: Setting the Network Adapter
popd
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
Timeout /T 5 /Nobreak >NUL
REM This will monitor the game's activity. If it stops running, then everything is closed.
:LOOP
tasklist | find /i "SCCT_Versus" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO QUIT
) ELSE (
  Timeout /T 1 /Nobreak >NUL
  GOTO LOOP
)
REM This checks and sees if CT is operating. Slight loop delay added.

:QUIT
taskkill /F /IM 3DAnalyze.exe >NUL
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q leave %network% >NUL
taskkill /F /IM "ZeroTier One.exe" >NUL
exit
