@echo off
REM NOONA PLUS ERP - allow the database to call an external integration (insurance gateway / e-prescription platform). Run as DBA; asks for the SYS password.
setlocal
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
chcp 65001 >nul
cd /d "%~dp0"
set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
sqlplus -L "sys@//localhost:1521/%PDB% as sysdba" @admin/03_his_network_acl.sql
pause
