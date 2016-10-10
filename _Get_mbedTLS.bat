@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

:: NOTE
:: "master" branch has the latest stable version
:: "development" branch has the latest commit

set LIBNAME=mbedTLS
set URL=https://github.com/ARMmbed/mbedtls.git
set BRANCH=master

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --verbose --progress -b "%BRANCH%" %URL% %LIBNAME%
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

pause