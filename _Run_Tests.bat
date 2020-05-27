REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.

cd /d "%~dp0"

for /D %%a in (bin\*) do call :TEST "%%~fa"
REM pause
exit /B

:TEST
if exist "%~1\_Test_curl.bat" start "%~n1" %comspec% /C "%~1\_Test_curl.bat"
exit /B
