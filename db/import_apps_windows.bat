@echo off
chcp 65001 > nul
setlocal
rem =============================================================================
rem NOONA PLUS | استيراد كل تطبيقات APEX دفعة واحدة (بدل الاستيراد اليدوي من App Builder)
rem   يستبدل التطبيق الموجود بنفس الرقم (مثل Reuse Application ID) ويبقي بيانات القاعدة كما هي
rem   يشغل بعد update_windows.bat أو install_windows.bat
rem =============================================================================
set NLS_LANG=AMERICAN_AMERICA.AL32UTF8
set HOST=localhost
set /p HOST=Database host [localhost]: 
if "%HOST%"=="" set HOST=localhost
set PORT=1521
set /p PORT=Listener port [1521]: 
if "%PORT%"=="" set PORT=1521
set PDB=ORCLPDB
set /p PDB=PDB service name [ORCLPDB]: 
if "%PDB%"=="" set PDB=ORCLPDB
set WS=NOONAPLUS
set /p WS=APEX workspace [NOONAPLUS]: 
if "%WS%"=="" set WS=NOONAPLUS
set /p APP_PWD=NOONA_APP password: 
set CONN=//%HOST%:%PORT%/%PDB%
set ROOT=%~dp0..\apex
set FAILED=
echo.
echo ===== NOONA_MASTER (f115)
pushd "%ROOT%\NOONA_MASTER\f115"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 115 < nul > "%TEMP%\noona_imp_115.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_115.log & set FAILED=%FAILED% 115) else (echo    done)
popd
echo ===== NOONA_PORTAL (f119)
pushd "%ROOT%\NOONA_PORTAL\f119"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 119 < nul > "%TEMP%\noona_imp_119.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_119.log & set FAILED=%FAILED% 119) else (echo    done)
popd
echo ===== NOONA_ADMIN (f123)
pushd "%ROOT%\NOONA_ADMIN\f123"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 123 < nul > "%TEMP%\noona_imp_123.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_123.log & set FAILED=%FAILED% 123) else (echo    done)
popd
echo ===== NOONA_PLATFORM (f125)
pushd "%ROOT%\NOONA_PLATFORM\f125"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 125 < nul > "%TEMP%\noona_imp_125.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_125.log & set FAILED=%FAILED% 125) else (echo    done)
popd
echo ===== NOONA_FIN (f127)
pushd "%ROOT%\NOONA_FIN\f127"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 127 < nul > "%TEMP%\noona_imp_127.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_127.log & set FAILED=%FAILED% 127) else (echo    done)
popd
echo ===== NOONA_DOC (f129)
pushd "%ROOT%\NOONA_DOC\f129"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 129 < nul > "%TEMP%\noona_imp_129.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_129.log & set FAILED=%FAILED% 129) else (echo    done)
popd
echo ===== NOONA_SCM (f131)
pushd "%ROOT%\NOONA_SCM\f131"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 131 < nul > "%TEMP%\noona_imp_131.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_131.log & set FAILED=%FAILED% 131) else (echo    done)
popd
echo ===== NOONA_POS (f133)
pushd "%ROOT%\NOONA_POS\f133"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 133 < nul > "%TEMP%\noona_imp_133.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_133.log & set FAILED=%FAILED% 133) else (echo    done)
popd
echo ===== NOONA_MFG (f135)
pushd "%ROOT%\NOONA_MFG\f135"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 135 < nul > "%TEMP%\noona_imp_135.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_135.log & set FAILED=%FAILED% 135) else (echo    done)
popd
echo ===== NOONA_HR (f137)
pushd "%ROOT%\NOONA_HR\f137"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 137 < nul > "%TEMP%\noona_imp_137.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_137.log & set FAILED=%FAILED% 137) else (echo    done)
popd
echo ===== NOONA_PRJ (f139)
pushd "%ROOT%\NOONA_PRJ\f139"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 139 < nul > "%TEMP%\noona_imp_139.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_139.log & set FAILED=%FAILED% 139) else (echo    done)
popd
echo ===== NOONA_HIS (f141)
pushd "%ROOT%\NOONA_HIS\f141"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 141 < nul > "%TEMP%\noona_imp_141.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_141.log & set FAILED=%FAILED% 141) else (echo    done)
popd
echo ===== NOONA_BI (f143)
pushd "%ROOT%\NOONA_BI\f143"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 143 < nul > "%TEMP%\noona_imp_143.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_143.log & set FAILED=%FAILED% 143) else (echo    done)
popd
echo ===== NOONA_AUTO (f145)
pushd "%ROOT%\NOONA_AUTO\f145"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 145 < nul > "%TEMP%\noona_imp_145.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_145.log & set FAILED=%FAILED% 145) else (echo    done)
popd
echo ===== NOONA_TRN (f147)
pushd "%ROOT%\NOONA_TRN\f147"
sqlplus -S -L NOONA_APP/"%APP_PWD%"@%CONN% @..\..\import_app.sql %WS% 147 < nul > "%TEMP%\noona_imp_147.log" 2>&1
if errorlevel 1 (echo    FAILED - see %TEMP%\noona_imp_147.log & set FAILED=%FAILED% 147) else (echo    done)
popd
echo.
if not "%FAILED%"=="" (echo ===== Apps that failed:%FAILED%  - open the log files listed above & pause & exit /b 1)
echo ===== All 15 apps imported. Open http://localhost:8080/ords/r/noonaplus/noona_master/home
pause
exit /b 0
