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
REM  curl-x_y_z    | release tags
REM ------------------------------------

set LIBNAME=cURL
set URL=https://github.com/curl/curl.git
title %LIBNAME%

:: Validate git
git --version > NUL 2> NUL
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


REM :: Configure libcurl
echo --------------------------------------
call buildconf.bat
if %ERRORLEVEL% neq 0 pause && exit /B %ERRORLEVEL%
echo --------------------------------------


:: Patch
echo.
set /p answer=Apply patch? ([yes]/no) 
if /I "%answer%" equ "" goto :PATCH
if /I "%answer%" equ "yes" goto :PATCH
if /I "%answer%" equ "y" goto :PATCH
exit /B 1
:PATCH
REM :: Remember last tag's commit time before changing directory
for /f "tokens=1 delims= " %%i in ('git log -1 --format^=%%ai') do set YMD=%%i

cd /d "%~dp0"
git apply --verbose --whitespace=fix --directory=%LIBNAME% _Patches\_patch-%LIBNAME%.diff

echo Removing "-DEV" version suffix...
powershell -Command "(gc curl\include\curl\curlver.h) -replace '-DEV', ''| Out-File -encoding ASCII curl\include\curl\curlver.h"

echo Replacing "[unreleased]" timestamp with "%YMD%"...
powershell -Command "(gc curl\include\curl\curlver.h) -replace '\[unreleased\]', '%YMD%'| Out-File -encoding ASCII curl\include\curl\curlver.h"

echo.
pause