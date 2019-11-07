@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
pushd %~dp0
REM Command above is to get the current location.

:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto :checking
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit
REM Must be ran as admin.

:checking
echo Quickstarting Splinter Cell Double Agent...
if not exist SCDA_online.txt goto :REQUIRED
if not exist gamedir.txt goto :REQUIRED
goto :BEGIN

:BEGIN
sc start ZeroTierOneService>NUL
If ERRORLEVEL 0 (
  GOTO unify
) ELSE (
  echo ZeroTier Process Could Not Be Started...
  echo Make sure program is installed / reinstall the program.
  choice /c 12 /n /M "Launch Anyway? Yes[1], No[2]"
  if ERRORLEVEL 2 exit
  if ERRORLEVEL 1 goto START
)

:unify
set network=0cccb752f756b32b
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
REM The above sets the metric of the adapter.

REM PART 3: Game Status
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

:REQUIRED
echo You need to complete inital setup first...
echo Press any key to close...
pause >nul
exit
