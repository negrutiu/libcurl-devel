@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

:: NOTE
:: "master" branch is the development branch
:: The project doesn't have a "latest stable" branch
:: We'll clone the latest tag, but it'll require manual modification each time a new stable version is released

set LIBNAME=cURL
set URL=https://github.com/curl/curl.git
set BRANCH=curl-7_48_0

echo Working with "%BRANCH%" tag
echo Verify if newer (stable) %LIBNAME% versions are available!
echo.

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
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
"%GIT%" apply --verbose --whitespace=fix --directory=%LIBNAME% _patch-%LIBNAME%.diff

pause