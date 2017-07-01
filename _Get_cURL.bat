@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

:: NOTE
:: "master" branch is the development branch
:: The project doesn't have a "latest stable" branch
:: We'll clone "master" branch
:: <obsolete>We'll clone the latest tag, but it'll require manual modification each time a new stable version is released</obsolete>

set LIBNAME=cURL
set URL=https://github.com/curl/curl.git
set BRANCH=master

echo Retrieving "%BRANCH%"...
:: <obsolete>echo Verify if newer (stable) %LIBNAME% versions are available!</obsolete>
echo.

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
	"%GIT%" reset --hard
	"%GIT%" clean -fd
	"%GIT%" pull --verbose --progress "origin"
	call buildconf.bat
) else (
	"%GIT%" clone --verbose --progress -b "%BRANCH%" %URL% %LIBNAME%
	cd %LIBNAME%
	call buildconf.bat
)


:: Some patching is required
echo.
set /p answer=Apply patch? (yes/[no]) 
if /I "%answer%" equ "yes" goto :_patch
if /I "%answer%" equ "y" goto :_patch
goto :EOF
:_patch
cd /d "%~dp0"
"%GIT%" apply --verbose --whitespace=fix --directory=%LIBNAME% Patches\_patch-%LIBNAME%.diff

echo Removing "-DEV" version suffix...
powershell -Command "(gc curl\include\curl\curlver.h) -replace '-DEV', ''| Out-File -encoding ASCII curl\include\curl\curlver.h"


pause