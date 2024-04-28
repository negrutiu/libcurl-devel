REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

cd /d "%~dp0"

REM ------------------------------------
REM  Name          | Role
REM ---------------|--------------------
REM  n/a           | release branch
REM  master        | development branch
REM  vx.y.z        | release tags
REM ------------------------------------

set LIBNAME=nghttp2
set URL=https://github.com/nghttp2/nghttp2.git
title %LIBNAME%

:: Validate git
git --version 2> NUL
if %ERRORLEVEL% neq 0 echo ERROR: git not in PATH && pause && exit /B 2

if exist "%LIBNAME%\.git" (
	goto :EXISTING
) else (
	goto :NEW
)

:NEW
git clone --no-checkout --verbose --progress %URL% %LIBNAME%
if %ERRORLEVEL% neq 0 pause && exit /B %ERRORLEVEL%


:EXISTING
cd %LIBNAME%

REM :: git fetch
git fetch
if %ERRORLEVEL% neq 0 pause && exit /B %ERRORLEVEL%

REM :: Available branches
echo.
echo Branches:
set COUNT=0
for /f usebackq %%i in (`git branch -ar --sort=-committerdate`) do (
	set /A COUNT = !COUNT! + 1
	if !COUNT! leq 10 echo   %%i
)
if !COUNT! gtr 10 (
	set /A COUNT = !COUNT! - 10
	echo   !COUNT! more...
)

REM :: Available tags
echo.
echo Tags:
set COUNT=0
for /f usebackq %%i in (`git tag -l --sort=-creatordate`) do (
	set /A COUNT = !COUNT! + 1
	if !COUNT! leq 10 echo   %%i
)
if !COUNT! gtr 10 (
	set /A COUNT = !COUNT! - 10
	echo   !COUNT! more...
)

REM :: Switch to...
for /f usebackq %%i in (`git rev-parse --abbrev-ref HEAD`) do set CUR_TAG=%%i
if /i "%CUR_TAG%" equ "HEAD" (
	for /f usebackq %%i in (`git describe --tags`) do set CUR_TAG=%%i
)
echo.
echo NOTE: Switching branches/tags will discard all local changes
set /p NEW_TAG=Switch to [%CUR_TAG%]: 
if "%NEW_TAG%" equ "" set NEW_TAG=%CUR_TAG%

echo.
echo Checking out...
git checkout --force "%NEW_TAG%"
if %ERRORLEVEL% neq 0 pause && exit /B %ERRORLEVEL%

REM :: git pull
echo.
echo Pulling...
git pull origin "%NEW_TAG%"
if %ERRORLEVEL% neq 0 pause && exit /B %ERRORLEVEL%


:: Patch
echo.
set /p answer=Apply patch? ([yes]/no) 
if /I "%answer%" equ "" goto :PATCH
if /I "%answer%" equ "yes" goto :PATCH
if /I "%answer%" equ "y" goto :PATCH
exit /B 1
:PATCH
cd /d "%~dp0"

set patches=
for /f "" %%f in ('dir /b _Patches\%LIBNAME%*.diff') do set patches=!patches! "_Patches\%%~f"
if "%patches%" neq "" git apply --verbose --whitespace=fix --directory=%LIBNAME% !patches! || echo -- patching failed

REM ---------------------------------
REM Extract string version from tag name (e.g. "1.2.3")
for /f "delims=v" %%i in ("%NEW_TAG%") do set VER_STR=%%i

REM Extract hex version from tag name (e.g. 0x010203)
for /f "tokens=1,2,3 delims=v." %%i in ("%NEW_TAG%") do set v1=%%i&& set v2=%%j&& set v3=%%k

set /A V1^<^<=16
set /A V2^<^<=8
set /A V3^<^<=0
set /A VER=%V1%^|%V2%
set /A VER=%VER%^|%V3%
:: decimal -> hex (https://www.dostips.com/forum/viewtopic.php?t=2261)
call cmd /c exit /b %VER%
set HEX=%=exitcode%
set HEX6=%HEX:~-6%
set VER_HEX=0x%HEX6%
REM ---------------------------------

set VER_H=%LIBNAME%\lib\includes\%LIBNAME%\nghttp2ver.h
echo Copy "%VER_H%"
copy /Y "%VER_H%.in" "%VER_H%"
echo Configure version %VER_STR% (%VER_HEX%) in "%VER_H%"...
powershell -Command "(gc %VER_H%) -replace '@PACKAGE_VERSION@', '%VER_STR%' -replace '@PACKAGE_VERSION_NUM@', '%VER_HEX%' | Out-File -encoding UTF8 %VER_H%"
echo         ERRORLEVEL = %ERRORLEVEL%

echo.
pause