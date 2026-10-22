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

for %%U in (upgrade_01_apex_layer upgrade_02_portal upgrade_03_apex_error upgrade_04_ui upgrade_05_admin upgrade_06_brand upgrade_07_admin_complete upgrade_08_limits upgrade_09_gl upgrade_10_cash upgrade_11_reports upgrade_12_fin_docs upgrade_13_dms upgrade_14_dms_storage upgrade_15_journal_types upgrade_16_supply_chain upgrade_17_manufacturing upgrade_18_tenant_admin) do (
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

echo.
echo ===== Database updated. Every test line should end with: 0 failed
echo ===== test_dms may report the server-folder test only if a storage folder is configured but not reachable from the DB server.
echo ===== Compile warnings shown inside upgrades 09-14 are expected on old databases; upgrades 15 and 16 recompile everything.
echo ===== Next: import apex\NOONA_MASTER\f115, NOONA_PORTAL\f119, NOONA_ADMIN\f123, NOONA_PLATFORM\f125, NOONA_FIN\f127, NOONA_DOC\f129, NOONA_SCM\f131, NOONA_POS\f133, NOONA_MFG\f135 zips (Reuse Application ID)
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: the step above failed. Copy the error lines and send them.
pause
exit /b 1
