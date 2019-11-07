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
if not exist splintercell3.txt (
	set files=splintercell3
	call chooser.bat
)

if not exist coopdir.txt (
echo Choose folder containing the game...
set folderloc=coopdir
call chooserf.bat
goto :checking
)
:checking
if not exist splintercell3.txt goto :REQUIRED
if not exist coopdir.txt goto :REQUIRED
goto :ORIGIN

:REQUIRED
echo The Program Requires All Files.
echo Try Again, Quit?
choice /C 12 /n /M "Try Again [1] Quit [2]"
if ERRORLEVEL 2 exit
if ERRORLEVEL 1 goto :Grabbing

:ORIGIN
echo Before COOP is launched, would you like a clean ini files?
choice /C 123 /n /M "Yes [1], No[2], Info[3]"
if ERRORLEVEL 3 goto :info
if ERRORLEVEL 2 goto :VPNCHECK
if ERRORLEVEL 1 goto :CLEAN

:INFO
echo It is advised that both players invovled in COOP have the same ini file.
echo If both players have varying ini files it can cause disconnects.
echo The clean INI files are from a fresh install. If both players use them, then they will have the same INI files.
echo Note: Feel Free to upgrade the graphics, and change the resolution to what you wish from ingame.
echo Press any key to go back to the choice...
pause>nul
Timeout /T 1 /Nobreak >NUL
goto :ORIGIN

:CLEAN
set /p coopdir=<coopdir.txt
set "syslocal=%local%\ChaosTheory\System"
set "datalocal=%local%\ChaosTheory\ProgramData"
xcopy /s /y "%syslocal%" "%coopdir%">nul
xcopy /s /y "%datalocal%" "C:\ProgramData\Ubisoft\Tom Clancy's Splinter Cell Chaos Theory">nul
echo Files cleaned...
goto :Custom

:CUSTOM
echo Want to clean your existing profile as well?
choice /C 12 /n /M "Yes [1], No[2]"
if ERRORLEVEL 2 goto :VPNCHECK
if ERRORLEVEL 1 goto :CustomClean

:CustomClean
set /p "custom=Type Profile Name Here: "
set "customdir=C:\ProgramData\Ubisoft\Tom Clancy's Splinter Cell Chaos Theory\Profiles\%custom%"
if not exist "%customdir%" goto :TryAgain
set "customdefault=%datalocal%\Profiles\DEFAULT\Default.ini"
set "customfile=C:\ProgramData\Ubisoft\Tom Clancy's Splinter Cell Chaos Theory\Profiles\%custom%\%custom%.ini"
xcopy /y "%customdefault%" "%customfile%">nul
echo Profile "%custom%" cleaned...
goto :VPNCHECK

:TryAgain
echo Profile not found... Try Again?
echo Note: If you choose no, remember that only the default profile will have been cleaned.
choice /C 12 /n /M "Yes [1], No[2]"
if ERRORLEVEL 2 goto :VPNCHECK
if ERRORLEVEL 1 goto :CustomClean


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
goto :START

:private
echo Please enter the private network's ID...
set /p network="Network ID: "
echo Connecting to the private network...
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
