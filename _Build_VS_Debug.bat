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


:: ----------------------------------------------------------------
:mbedtls_lib
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-lib
if /I "%1" equ "/%CONFIG%" (
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%"
	goto :EOF
)


:: ----------------------------------------------------------------
:mbedtls_dll
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-dll
if /I "%1" equ "/%CONFIG%" (
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%"
	goto :EOF
)


:: ----------------------------------------------------------------
:winssl_lib
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-lib
if /I "%1" equ "/%CONFIG%" (
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%"
	goto :EOF
)


:: ----------------------------------------------------------------
:winssl_dll
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-dll
if /I "%1" equ "/%CONFIG%" (
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%"
	goto :EOF
)


:: ----------------------------------------------------------------
:mbedtls_lib_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-lib
if /I "%1" equ "/%CONFIG%-HTTP_ONLY" (
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	goto :EOF
)


:: ----------------------------------------------------------------
:mbedtls_dll_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-dll
if /I "%1" equ "/%CONFIG%-HTTP_ONLY" (
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	goto :EOF
)


:: ----------------------------------------------------------------
:winssl_lib_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-lib
if /I "%1" equ "/%CONFIG%-HTTP_ONLY" (
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	goto :EOF
)


:: ----------------------------------------------------------------
:winssl_dll_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-dll
if /I "%1" equ "/%CONFIG%-HTTP_ONLY" (
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %ERRORLEVEL% neq 0 echo ERRORLEVEL = %ERRORLEVEL% && pause && goto :EOF

	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	goto :EOF
)



:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
:: Reject other parameters
if "%1" neq "" goto :EOF

echo Building...
title %BUILD_CONFIG% Master
set START_TIME=%date% %time%

if exist "%~dp0\flag-*" del "%~dp0\flag-*"
if exist "%~dp0\error-*" del "%~dp0\error-*"

start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-mbedTLS-lib
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-mbedTLS-dll
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-WinSSL-lib
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-WinSSL-dll
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-mbedTLS-lib-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-mbedTLS-dll-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-WinSSL-lib-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /%BUILD_CONFIG%-VC-WinSSL-dll-HTTP_ONLY

:: Wait for children
timeout /T 5 /NOBREAK > NUL
:WAIT
	if not exist "%~dp0\flag-*" goto :WAIT_END
	timeout /T 1 /NOBREAK > NUL
	goto :WAIT
:WAIT_END
if exist "%~dp0\error-*" goto :EOF


:TEST
for /D %%a in (%BUILD_CONFIG%-VC-mbedTLS-*) do (
	if exist "%~dp0\cacert.pem" xcopy "%~dp0\cacert.pem" "%%a" /FIYD

	echo "%%~dp0\curl.exe" -V> "%%a\test.bat"
	echo "%%~dp0\curl.exe" -L -v --capath "%%~dp0\" negrutiu.com>> "%%a\test.bat"
	echo pause>> "%%a\test.bat"
)
for /D %%a in (%BUILD_CONFIG%-VC-WinSSL-*) do (
	echo "%%~dp0\curl.exe" -V> "%%a\test.bat"
	echo "%%~dp0\curl.exe" -L -v negrutiu.com>> "%%a\test.bat"
	echo pause>> "%%a\test.bat"
)

set END_TIME=%date% %time%
echo Started %START_TIME%
echo Ended   %END_TIME%
pause