@echo off

:CHDIR
cd /d "%~dp0"

:DEFINITIONS
if defined PROGRAMFILES(X86) set PF=%PROGRAMFILES(X86)%
if not defined PROGRAMFILES(X86) set PF=%PROGRAMFILES%

set BUILD_SOLUTION=%CD%\cURL.sln
set BUILD_CONFIG=Debug
set BUILD_VERBOSITY=normal
:: Verbosity: quiet, minimal, normal, detailed, diagnostic

:COMPILER
set VCVARSALL=%PF%\Microsoft Visual Studio 14.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v140_xp
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 12.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v120_xp
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 11.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v110_xp
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 10.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v100
if exist "%VCVARSALL%" goto :BUILD

echo ERROR: Can't find Visual Studio 2010/2012/2013/2015
pause
goto :EOF

:BUILD
call "%VCVARSALL%" x86

title %BUILD_CONFIG%-VC-lib-Win32
msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%BUILD_CONFIG%-VC-lib /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
if %ERRORLEVEL% neq 0 ( echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF )

title %BUILD_CONFIG%-VC-lib-x64
msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%BUILD_CONFIG%-VC-lib /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
if %ERRORLEVEL% neq 0 ( echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF )

title %BUILD_CONFIG%-VC-dll-Win32
msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%BUILD_CONFIG%-VC-dll /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
if %ERRORLEVEL% neq 0 ( echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF )

title %BUILD_CONFIG%-VC-dll-x64
msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%BUILD_CONFIG%-VC-dll /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
if %ERRORLEVEL% neq 0 ( echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF )
