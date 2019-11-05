@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto setup
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit
REM Must be ran as admin.

REM Part 0: Are you using ZeroTier?
:setup
cls
type logo.txt
echo.
:Grabbing
if not exist SCCT_Versus.txt (
	set files=SCCT_Versus
	call chooser.bat
)
if not exist 3DAnalyze.txt (
	set files=3DAnalyze
	call chooser.bat
)
if not exist Framer.txt (
	set files=Framer
	call chooser.bat
)

if exist "SCCT_Versus.txt" (
    if exist "3DAnalyze.txt" (
		if exist "Framer.txt" (
			goto :ORIGIN
    ) else goto :REQUIRED
) else goto :REQUIRED
)
else goto :REQUIRED

:REQUIRED
echo The Program Requires All Files.
echo Try Again, Quit?
choice /C 12 /n /M "Try Again [1] Quit [2]"
if ERRORLEVEL 2 exit
if ERRORLEVEL 1 goto setup


:ORIGIN
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
set /p zeroprocess=<zerotier-one_x64.txt
echo Are you joining the unify network, or a private one?
choice /C 12 /n /M "Unify [1] Private [2]"
if ERRORLEVEL 2 goto private
if ERRORLEVEL 1 goto unify

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
set /p thegame=<SCCT_Versus.txt
set /p ThreeDAnalyzer=<3DAnalyze.txt
set /p FramerApp=<Framer.txt

REM PART 1: Launching Framer and the Game.
start "" "%FramerApp%"
REM Launches Framer for optional FPS change.
echo Enter your desired FPS.
echo Click here and press any key to proceed.
pause >NUL
REM This allows for users to enter their own FPS before proceeding.
start "" "%ThreeDAnalyzer%" /EXE=%thegame%
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
exit