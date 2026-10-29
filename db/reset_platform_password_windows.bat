@echo off
REM NOONA PLUS ERP - change the PLATFORM administrator password and unlock the account (run on the database server)
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"

set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
set CONN=//localhost:1521/%PDB%
set /p OWNER_PWD=NOONA_OWNER password: 
set USR=PLATFORM
echo Platform administrator: PLATFORM
echo New password: at least 10 characters, upper + lower case + digit, must not contain the word PLATFORM (example: Noona#2026Pass)
set /p NEWPWD=New password: 
echo.
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @reset_password.sql %USR% "%NEWPWD%" < nul
if errorlevel 1 goto :fail
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: copy the error lines above and send them.
pause
exit /b 1
