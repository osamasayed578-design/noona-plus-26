@echo off
REM ===========================================================================
REM  NOONA PLUS ERP - Windows updater (existing database)
REM  Run AFTER "git pull origin main". Applies all upgrade scripts in order
REM  (safe to re-run: CREATE OR REPLACE + GRANT), refreshes NOONA_APP synonyms,
REM  then runs the test suites. Stops at the first error.
REM ===========================================================================
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

for %%U in (upgrade_01_apex_layer upgrade_02_portal upgrade_03_apex_error upgrade_04_ui) do (
  echo ===== %%U
  sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @%%U.sql < nul
  if errorlevel 1 goto :fail
)

echo ===== synonyms (NOONA_APP)
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @security/41_synonyms_noona_app.sql < nul > nul
if errorlevel 1 goto :fail

echo ===== tests
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @tests/test_phase1.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_apex_pkg.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_portal.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"

echo.
echo ===== Database updated. Expected: 79 / 26 / 21 passed, 0 failed.
echo ===== Next: import apex\NOONA_MASTER\f115_NOONA_MASTER.zip and apex\NOONA_PORTAL\f119_NOONA_PORTAL.zip
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: the step above failed. Copy the error lines and send them.
pause
exit /b 1
