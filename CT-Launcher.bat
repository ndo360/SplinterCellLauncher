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
if ERRORLEVEL 1 goto START

:INFO
echo You must have ran the game at least once through 3DAnalzyer.
echo This is to ensure that you have the flashlight fix applied.
echo Once you have ran the game at least once, using 3DAnalyzer, you may use this launcher.
echo Press any button to close.
pause >NUL
exit


:START
tasklist /fi "imagename eq %exe%" 2>NUL |find /I /N "%exe%">NUL
If not ERRORLEVEL 1 (
  GOTO BESURE
) ELSE (
  echo Are you using ZeroTier?
  choice /C YN /n /M "Yes [Y] No [N]"
  if ERRORLEVEL 2 goto START
  if ERRORLEVEL 1 goto CHECKING
)

:CHECKING
cls
echo Welcome to the launcher.
echo Before we can launch, have you ran the game with 3DAnalyzer before?
echo Yes [Y] No [N] Y
echo Are you using ZeroTier?
echo Yes [Y] No [N] Y
tasklist /fi "imagename eq %exe%" 2>NUL |find /I /N "%exe%">NUL
If not ERRORLEVEL 1 (
  GOTO BESURE
) ELSE (
  echo ZeroTier is not running...
  choice /C YN /n /M "Try Again? Yes [Y] No [N]"
  if ERRORLEVEL 2 goto CANCEL
  if ERRORLEVEL 1 goto CHECKING
)

:CANCEL
cls
echo Welcome to the launcher.
echo Before we can launch, have you ran the game with 3DAnalyzer before?
echo Yes [Y] No [N] Y
echo Are you using ZeroTier?
echo Yes [Y] No [N] Y
echo ZeroTier is not running...
echo Try Again? Yes [Y] No [N] N
echo Proceed without ZeroTier? If not, program will close.
choice /C YN /n /M "Yes [Y] No [N]"
if ERRORLEVEL 2 goto Close
if ERRORLEVEL 1 goto Start
)

:CLOSE
exit

:BESURE
echo Make sure that you are connected to the network. The ID is below.
echo 0cccb752f756b32b
echo.
echo Press any key once connected.
pause >NUL

:Ensuring Connection
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
start "" "..\Framer.exe"
REM Launches Framer for optional FPS change.
echo Enter your desired FPS.
echo Click here and press any key to proceed.
pause >NUL
REM This allows for users to enter their own FPS before proceeding.
start "" "..\3DAnalyzer\3DAnalyze.exe" /EXE=%~dp0\System\SCCT_Versus.exe
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
taskkill /F /IM 3DAnalyze.exe
exit
