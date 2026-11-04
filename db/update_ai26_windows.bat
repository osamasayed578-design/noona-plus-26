@echo off
REM ===========================================================================
REM  NOONA PLUS 26 - AI assistant updater (Oracle AI Database 26ai + APEX 26.2)
REM  Run AFTER update_windows.bat. Applies the AI upgrades (safe to re-run)
REM  and refreshes the NOONA_APP synonym. Keys are NOT entered here: create the
REM  APEX AI services yourself (see docs\ai_setup_26.md).
REM ===========================================================================
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"
set PDB=FREEPDB1
set /p PDB=PDB service name [FREEPDB1]: 
if "%PDB%"=="" set PDB=FREEPDB1
set CONN=//localhost:1521/%PDB%
set /p OWNER_PWD=NOONA_OWNER password: 
set /p APP_PWD=NOONA_APP password: 
for %%U in (upgrade_ai26_01 upgrade_ai26_02) do (
  echo ===== %%U
  sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@%CONN% @%%U.sql < nul
  if errorlevel 1 goto :fail
)
echo CREATE OR REPLACE SYNONYM NOONA_AI_PKG FOR NOONA_OWNER.NOONA_AI_PKG;> "%TEMP%\noona_ai_syn.sql"
echo EXIT>> "%TEMP%\noona_ai_syn.sql"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @"%TEMP%\noona_ai_syn.sql" < nul
echo.
echo ===== Done. Import the apps (apex\*\f*\install.sql) and configure the AI services: docs\ai_setup_26.md
goto :eof
:fail
echo ***** FAILED - see the messages above
exit /b 1
