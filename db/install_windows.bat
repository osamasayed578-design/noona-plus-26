@echo off
REM ===========================================================================
REM  NOONA PLUS ERP - Windows installer (development)
REM  Sets NLS_LANG to UTF-8 automatically, then runs the install steps in order
REM  and stops at the first error.
REM  Usage: double-click, or from CMD:  install_windows.bat
REM  Prerequisite (once): admin\00_create_schemas.sql and admin\01_sys_grants.sql
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
echo NLS_LANG=%NLS_LANG%   CONNECT=%CONN%
echo.

echo ===== 1/5 install.sql (NOONA_OWNER)
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @install.sql < nul
if errorlevel 1 goto :fail

echo ===== 2/5 synonyms (NOONA_APP)
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @security/41_synonyms_noona_app.sql < nul > nul
if errorlevel 1 goto :fail

echo ===== 3/5 demo tenant (NOONA_OWNER)
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @seed/90_demo_tenant_DEV_ONLY.sql < nul
if errorlevel 1 goto :fail

echo ===== 4/5 tests phase 1 (NOONA_OWNER)
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @tests/test_phase1.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ABORT" /c:"ORA-"
if errorlevel 2 goto :fail

echo ===== 5/5 tests APEX layer + portal (NOONA_APP)
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_apex_pkg.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_portal.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_sec_admin.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_brand.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_admin_ref.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_platform_admin.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_gl.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_cash.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_reports.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_fin_docs.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_dms.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-" /c:"WARN"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_journal_types.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_inventory.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_purchases.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_sales.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_manufacturing.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_tenant_admin.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_correspondence.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_hr_payroll.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_fixed_assets.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_property_hospitality.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_restaurant.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_healthcare.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_healthcare2.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_healthcare3.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_healthcare4.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_reports_hub.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @tests/test_projects.sql < nul | findstr /c:"RESULT" /c:"FAIL" /c:"ORA-"

echo.
echo ===== Finished. Expected: 79 / 26 / 21 / 25 / 10 / 19 / 18 / 19 / 43 / 29 / 26 / 38 / 24 / 52 / 49 / 54 / 77 / 41 / 47 / 54 / 70 / 72 / 75 / 62 / 51 / 62 / 36 / 37 / 70 passed, 0 failed (test_dms prints a WARN line when no NOONA_DMS_T[tenant] server folder exists).
echo ===== Next: import the APEX apps 115 to 135 (Reuse Application ID), including NOONA_MFG\f135 for manufacturing, NOONA_PRJ\f139 and NOONA_HIS\f141.
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: the step above failed. Copy the error lines and send them.
pause
exit /b 1
