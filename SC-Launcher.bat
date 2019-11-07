::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCuDJGmW+0UiKRYUag2OOXj6Tq1EvqHH3P6Co0AhR/Y6eYLayqSdHOMc50jre6oexnZTlt8JHhhdch7rTQc1pn0CgmyAONWFjyzVB2SI80UzE2Bmu1DfmTk4ZcBUk8AM3W249UH60awT3hg=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+IeA==
::cxY6rQJ7JhzQF1fEqQJgZko0
::ZQ05rAF9IBncCkqN+0xwdVsEAlXi
::ZQ05rAF9IAHYFVzEqQIDOBddQhCHLiuZA7kQqMT6+uSEqkgPNA==
::eg0/rx1wNQPfEVWB+kM9LVsJDDehcUe7E7sf4O3pjw==
::fBEirQZwNQPfEVWB+kM9LVsJDDehcUe7E7sf4O3pjw==
::cRolqwZ3JBvQF1fEqQIcKQ5aTwzCCmK0ErQb7ajI/+aOrFkYRqIcfYPXmoCHNOwW+QSE
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRm34Es8JFtdQkSAOX+7SvUZ8Pj+7P7HoFgaR6xf
::Zh4grVQjdCuDJGmW+0UiKRYUag2OOXj6Tq1EvqHH3P6Co0AhR/Y6eYLayqSdHOMc50jre6oexnZTlt8JHhhdch7rTQc1pn0CgmyAONWFjyzVB2SI80UzE2Bmu1DzwQc6dd1rksYRnSWm+S0=
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off >NUL
@SETLOCAL enableextensions enabledelayedexpansion
:check_Permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
		goto GameSelect
    ) else (
        echo Insufficient Permissions: You must run this program as administrator.
    )

    pause >nul
	exit
REM Must be ran as admin.

:GameSelect
if exist "%~dp0Sources" (
	cd /d "%~dp0Sources"
) else goto :error

if not exist local.txt echo %~dp0Sources>local.txt
goto :SelectNow

:SelectNow
type logo.txt
echo.
echo Standard Launch, Quickstart, Close Launcher?
choice /C 123 /n /M "Regular [1], Quickstart [2] Close Launcher [3]"
if ERRORLEVEL 3 goto exit
if ERRORLEVEL 2 goto quickstart
if ERRORLEVEL 1 goto regular

:regular
echo Setup which game?
choice /C 12 /M "Chaos Theory [1] Double Agent [2]"
if ERRORLEVEL 2 goto DA
if ERRORLEVEL 1 goto CT

:quickstart
echo Quickstart which game?
choice /C 12 /M "Chaos Theory [1] Double Agent [2]"
if ERRORLEVEL 2 goto DAQ
if ERRORLEVEL 1 goto CTQ

:CT
choice /C 12 /n /M "SvM [1] Coop [2]"
if ERRORLEVEL 2 (
call CT-Launcher-Source-C.bat
exit
)
if ERRORLEVEL 1 (
call CT-Launcher-Source.bat
exit
)

:DA
call DA-Launcher-Source.bat
exit

:CTQ
choice /C 12 /n /M "SvM [1] Coop [2]"
if ERRORLEVEL 2 (
call CT-Launcher-Source-C-Q.bat
exit
)
if ERRORLEVEL 1 
( call CT-Launcher-Source-Q.bat
exit
)

:DAQ
call DA-Launcher-Source-Q.bat
exit


:error
echo Sources folder is missing...
echo Please make sure the sources folder is next to this exe file and try again.
echo Press any key to close...
pause >nul
exit