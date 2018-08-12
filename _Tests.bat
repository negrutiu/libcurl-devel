REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.

cd /d "%~dp0"

for /D %%a in (Debug-*)   do call :TEST "%%~fa"
for /D %%a in (Release-*) do call :TEST "%%~fa"
REM pause
goto :EOF

:TEST
if exist "%~1\Test.bat" start "%~n1" %comspec% /C "%~1\Test.bat"
goto :EOF
