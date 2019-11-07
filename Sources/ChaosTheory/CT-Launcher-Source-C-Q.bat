@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto :Checking
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
exit
REM Must be ran as admin.

REM Part 0: Are you using ZeroTier?
:checking
if not exist splintercell3.txt goto :REQUIRED
if not exist coopdir.txt goto :REQUIRED
goto :unify

:unify
echo Connecting to the Unify Network...
set network=0cccb752f756b32b
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q join %network% >NUL
goto :START

:START
Timeout /T 5 /Nobreak >NUL
set /p coopgame=<splintercell3.txt
start "" "%coopgame%" -nointro
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
Timeout /T 15 /Nobreak >NUL
REM This will monitor the game's activity. If it stops running, then everything is closed.
:LOOP
tasklist | find /i "splintercell3.exe" >nul 2>&1
IF ERRORLEVEL 1 (
  GOTO QUIT
) ELSE (
  Timeout /T 1 /Nobreak >NUL
  GOTO LOOP
)
REM This checks and sees if CT is operating. Slight loop delay added.

:QUIT
start "" "C:\ProgramData\ZeroTier\One\zerotier-one_x64.exe" -q leave %network% >NUL
exit

:REQUIRED
echo You need to run through setup...
echo Press any key to close...
pause>nul
exit