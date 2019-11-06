REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

cd /d "%~dp0"

REM ------------------------------------
REM  Name          | Role
REM ---------------|--------------------
REM  master        | release branch
REM  development   | development branch
REM  mbedtls-x.y.z | release tags
REM ------------------------------------

set LIBNAME=mbedTLS
set URL=https://github.com/ARMmbed/mbedtls.git
set TAGS=mbedtls-*
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
git clone --recurse-submodules --no-checkout --verbose --progress %URL% %LIBNAME%
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
for /f usebackq %%i in (`git branch -ar`) do (
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
for /f usebackq %%i in (`git tag -l --sort=-version:refname "%TAGS%"`) do (
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

REM :: git submodule
echo.
echo Submodules...
REM : Revert "crypto" otherwise patching will fail
pushd crypto
git checkout -f HEAD
popd
git submodule sync
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
git apply --verbose --whitespace=fix --directory=%LIBNAME% _Patches\_patch-%LIBNAME%.diff

cd /d "%~dp0\mbedTLS\crypto"
git apply --verbose --whitespace=fix ..\..\_Patches\_patch-%LIBNAME%-crypto.diff

echo.
pause