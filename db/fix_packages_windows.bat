@echo off
REM NOONA PLUS ERP - recompile DMS + finance packages in the right order (safe to re-run)
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"

set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
set CONN=//localhost:1521/%PDB%
set /p OWNER_PWD=NOONA_OWNER password: 
set /p APP_PWD=NOONA_APP password: 
echo.

sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @fix_packages.sql < nul
if errorlevel 1 goto :fail
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @security/41_synonyms_noona_app.sql < nul > nul
if errorlevel 1 goto :fail
echo ===== tests
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_reports.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_dms.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
echo.
echo ===== Done. Expected: all 7 packages VALID, no error lines; tests 29 and 38 (or 44) passed, 0 failed.
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: the step above failed. Copy the error lines and send them.
pause
exit /b 1
