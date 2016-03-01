@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

if exist "mbedTLS\.git" (
	cd mbedTLS
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --verbose --progress https://github.com/ARMmbed/mbedtls.git mbedTLS
)


:: Some patching is required to build mbedTLS properly
echo.
set /p answer=Apply patch? (yes/[no]) 
if /I "%answer%" equ "yes" goto :_patch
if /I "%answer%" equ "y" goto :_patch
goto :EOF
:_patch
cd /d "%~dp0"
"%GIT%" apply --verbose --directory=mbedTLS _patch-mbedTLS.diff

pause