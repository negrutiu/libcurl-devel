@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

:: NOTE
:: "master" branch is the development branch
:: The project doesn't have a "latest stable" branch
:: We'll clone the latest tag, but it'll require manual modification each time a new stable version is released

set LIBNAME=nghttp2
set URL=https://github.com/nghttp2/nghttp2.git
set BRANCH=v1.21.1
set VER=1.21.1
set VER_NUM=0x011501

echo Working with "%BRANCH%" tag
echo Verify if newer (stable) %LIBNAME% versions are available!
echo.

if exist "%LIBNAME%\.git" (
	cd %LIBNAME%
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --recursive --verbose --progress -b "%BRANCH%" %URL% %LIBNAME%
)


:: Some patching is required
echo.
set /p answer=Apply patch? (yes/[no]) 
if /I "%answer%" equ "yes" goto :_patch
if /I "%answer%" equ "y" goto :_patch
goto :EOF
:_patch
cd /d "%~dp0"

echo Copy "%LIBNAME%\lib\Makefile"
copy /Y Patches\_patch-%LIBNAME%-Makefile "%LIBNAME%\lib\Makefile"

set VER_H=%LIBNAME%\lib\includes\%LIBNAME%\nghttp2ver.h
echo Copy "%VER_H%"
copy /Y "%VER_H%.in" "%VER_H%"
echo Replacing in "%VER_H%"...
powershell -Command "(gc %VER_H%) -replace '@PACKAGE_VERSION@', '%VER%' -replace '@PACKAGE_VERSION_NUM@', '%VER_NUM%' | Out-File -encoding UTF8 %VER_H%"
echo         ERRORLEVEL = %ERRORLEVEL%

pause