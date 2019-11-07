@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto grabbing
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit

:Grabbing
if not exist SCCT_Versus.txt goto :REQUIRED
if not exist 3DAnalyze.txt goto :REQUIRED
if not exist Framer.txt goto :REQUIRED
goto :unify

:unify
echo Connecting to the Unify Network...
set network=0cccb752f756b32b
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
goto START


:START
Timeout /T 5 /Nobreak >NUL
set /p thegame=<SCCT_Versus.txt
set /p ThreeDAnalyzer=<3DAnalyze.txt
set /p FramerApp=<Framer.txt

REM PART 1: Launching Framer and the Game.
start "" "%FramerApp%"
REM This allows for users to enter their own FPS before proceeding.
start "" "%ThreeDAnalyzer%" /EXE=%thegame%
REM The above launches the 3D Analyzer Program & Game
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
Timeout /T 15 /Nobreak >NUL
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

:REQUIRED
echo You need to run through setup...
echo press any key to close...
pause>nul
exit
