@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

if exist "zlib\.git" (
	cd zlib
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --verbose --progress https://github.com/madler/zlib.git zlib
)


:: Some patching is required to build zlib properly
echo.
set /p answer=Apply patch? (yes/[no]) 
if /I "%answer%" equ "yes" goto :_patch
if /I "%answer%" equ "y" goto :_patch
goto :EOF
:_patch
cd /d "%~dp0"
"%GIT%" apply --verbose --whitespace=fix --directory=zlib _patch-zlib.diff

pause