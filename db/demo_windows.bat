@echo off
REM ===========================================================================
REM  NOONA PLUS ERP - Demo data for finance, inventory, purchases, sales, POS, manufacturing, correspondence, HR, payroll, fixed assets, real estate, hospitality, maintenance, restaurants and hospital
REM  Run AFTER update_windows.bat (upgrade 25). Loads once per organisation;
REM  running it again adds nothing.
REM ===========================================================================
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"

set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
set CONN=//localhost:1521/%PDB%
set /p APP_PWD=NOONA_APP password: 
set ADMIN_USER=ADMIN
set /p ADMIN_USER=Organisation admin username [ADMIN]: 
if "%ADMIN_USER%"=="" set ADMIN_USER=ADMIN
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_trade_data.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_manufacturing.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_correspondence.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_hr.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_fixed_assets.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_property_hospitality.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_restaurant.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_healthcare.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_healthcare2.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_healthcare3.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_healthcare4.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_projects.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @demo/demo_localization.sql %ADMIN_USER% < nul
if errorlevel 1 goto fail
echo.
echo ===== Demo data loaded. Open Finance (incl. Fixed Assets), Supply Chain, Sales/POS, Manufacturing, Documents, HR and Real Estate and Hospitality, Projects and Tax to review it. Restaurants are in Sales and POS. Hospital data is in Hospital and Clinics.
pause
exit /b 0

:fail
echo.
echo ***** STOPPED: copy the FAILED line above and send it.
pause
exit /b 1
