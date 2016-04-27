@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

set LIBNAME=cURL
set URL=https://github.com/curl/curl.git
set BRANCH=master

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
	"%GIT%" pull --verbose --progress "origin"
	call buildconf.bat
) else (
	"%GIT%" clone --verbose --progress -b "%BRANCH%" %URL% %LIBNAME%
	cd cURL
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