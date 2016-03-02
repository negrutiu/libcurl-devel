@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

if exist "cURL\.git" (
	cd cURL
	"%GIT%" pull --verbose --progress "origin"
	call buildconf.bat
) else (
	"%GIT%" clone --verbose --progress https://github.com/curl/curl.git cURL
	cd cURL
	call buildconf.bat
)

:: Some patching is required to build cURL properly
echo.
set /p answer=Apply patch? (yes/[no]) 
if /I "%answer%" equ "yes" goto :_patch
if /I "%answer%" equ "y" goto :_patch
goto :EOF
:_patch
cd /d "%~dp0"
"%GIT%" apply --verbose --whitespace=fix --directory=cURL _patch-cURL.diff

pause
