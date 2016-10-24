@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

set LIBNAME=zlib
set URL=https://github.com/madler/zlib.git
set BRANCH=master

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --verbose --progress -b "%BRANCH%" %URL% %LIBNAME%
)


:: Some patching is required
REM echo.
REM set /p answer=Apply patch? (yes/[no]) 
REM if /I "%answer%" equ "yes" goto :_patch
REM if /I "%answer%" equ "y" goto :_patch
REM goto :EOF
REM :_patch
REM cd /d "%~dp0"
REM "%GIT%" apply --verbose --whitespace=fix --directory=%LIBNAME% Patches\_patch-%LIBNAME%.diff

pause