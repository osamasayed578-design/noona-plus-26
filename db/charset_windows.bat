@echo off
REM ===========================================================================
REM  NOONA PLUS ERP - Character set check (Windows)
REM  Sets the UTF-8 client (NLS_LANG + code page 65001) and checks the database.
REM ===========================================================================
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"
set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
set /p OWNER_PWD=NOONA_OWNER password: 
sqlplus -S -L NOONA_OWNER/"%OWNER_PWD%"@//localhost:1521/%PDB% @check_charset.sql < nul
pause
