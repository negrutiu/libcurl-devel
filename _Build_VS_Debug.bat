REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.

:CHDIR
cd /d "%~dp0"

:DEFINITIONS
if not exist "%PF%" set PF=%PROGRAMFILES(X86)%
if not exist "%PF%" set PF=%PROGRAMFILES%

set BUILD_SOLUTION=%CD%\cURL.sln
set BUILD_CONFIG=Debug
set BUILD_VERBOSITY=normal
:: Verbosity: quiet, minimal, normal, detailed, diagnostic

:prerequisites
if not exist cacert.pem echo ERROR: Missing cacert.pem. Get it! && pause && exit /B 2

:COMPILER
set VSWHERE=%PF%\Microsoft Visual Studio\Installer\vswhere.exe
if exist "%VSWHERE%" (
	for /f "usebackq tokens=1* delims=: " %%i in (`"%VSWHERE%" -version 15 -requires Microsoft.Component.MSBuild`) do (
		if /i "%%i"=="installationPath" (
			set VCVARSALL=%%j\VC\Auxiliary\Build\VCVarsAll.bat
			set BUILD_PLATFORMTOOLSET=v141
		)
	)
)
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 14.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v140
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 12.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v120
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 11.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v110
if exist "%VCVARSALL%" goto :BUILD

set VCVARSALL=%PF%\Microsoft Visual Studio 10.0\VC\VcVarsAll.bat
set BUILD_PLATFORMTOOLSET=v100
if exist "%VCVARSALL%" goto :BUILD

echo ERROR: Can't find Visual Studio 2010/2012/2013/2015/2017
pause
exit /B 2

:BUILD
pushd "%CD%"
call "%VCVARSALL%" x86
popd


:: ----------------------------------------------------------------
:mbedtls_lib
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-lib
if /I "%1" neq "/%CONFIG%" goto :mbedtls_lib_end
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_lib_done

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_lib_done

:mbedtls_lib_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%"
	exit /B
:mbedtls_lib_end


:: ----------------------------------------------------------------
:mbedtls_dll
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-dll
if /I "%1" neq "/%CONFIG%" goto :mbedtls_dll_end
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_dll_done

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_dll_done

:mbedtls_dll_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%"
	exit /B
:mbedtls_dll_end


:: ----------------------------------------------------------------
:winssl_lib
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-lib
if /I "%1" neq "/%CONFIG%" goto :winssl_lib_end
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_lib_done

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_lib_done

:winssl_lib_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%"
	exit /B
:winssl_lib_end


:: ----------------------------------------------------------------
:winssl_dll
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-dll
if /I "%1" neq "/%CONFIG%" goto :winssl_dll_end
	echo Building> "%~dp0\flag-%CONFIG%"

	title %CONFIG%-Win32
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_dll_done

	title %CONFIG%-x64
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_dll_done

:winssl_dll_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%"
	exit /B
:winssl_dll_end


:: ----------------------------------------------------------------
:mbedtls_lib_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-lib
if /I "%1" neq "/%CONFIG%-HTTP_ONLY" goto :mbedtls_lib_httponly_end
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_lib_httponly_done

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_lib_httponly_done

:mbedtls_lib_httponly_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	exit /B
:mbedtls_lib_httponly_end


:: ----------------------------------------------------------------
:mbedtls_dll_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-mbedTLS-dll
if /I "%1" neq "/%CONFIG%-HTTP_ONLY" goto :mbedtls_dll_httponly_end
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_dll_httponly_done

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :mbedtls_dll_httponly_done

:mbedtls_dll_httponly_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	exit /B
:mbedtls_dll_httponly_end


:: ----------------------------------------------------------------
:winssl_lib_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-lib
if /I "%1" neq "/%CONFIG%-HTTP_ONLY" goto :winssl_lib_httponly_end
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_lib_httponly_done

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_lib_httponly_done

:winssl_lib_httponly_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	exit /B
:winssl_lib_httponly_end


:: ----------------------------------------------------------------
:winssl_dll_httponly
:: ----------------------------------------------------------------
set CONFIG=%BUILD_CONFIG%-VC-WinSSL-dll
if /I "%1" neq "/%CONFIG%-HTTP_ONLY" goto :winssl_dll_httponly_end
	echo Building> "%~dp0\flag-%CONFIG%-HTTP_ONLY"

	title %CONFIG%-Win32-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=Win32 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_dll_httponly_done

	title %CONFIG%-x64-HTTP_ONLY
	msbuild /m /t:build "%BUILD_SOLUTION%" /p:Configuration=%CONFIG% /p:Platform=x64 /p:MyPathSuffix=-HTTP_ONLY /p:MyCurlDefinitions=HTTP_ONLY /p:PlatformToolset=%BUILD_PLATFORMTOOLSET% /nologo /verbosity:%BUILD_VERBOSITY%
	if %errorlevel% neq 0 echo ERRORLEVEL = %errorlevel% && pause && goto :winssl_dll_httponly_done

:winssl_dll_httponly_done
	if %errorlevel% neq 0 echo %errorlevel%> "%~dp0\error-%CONFIG%"
	del "%~dp0\flag-%CONFIG%-HTTP_ONLY"
	exit /B
:winssl_dll_httponly_end



:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
:: Reject other parameters
if "%1" neq "" exit /B 57

echo Building...
title %BUILD_CONFIG% Master
set START_TIME=%date% %time%

if exist "%~dp0\flag-%BUILD_CONFIG%-*" del "%~dp0\flag-%BUILD_CONFIG%-*"
if exist "%~dp0\error-%BUILD_CONFIG%-*" del "%~dp0\error-%BUILD_CONFIG%-*"

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
	if not exist "%~dp0\flag-%BUILD_CONFIG%-*" goto :WAIT_END
	timeout /T 1 /NOBREAK > NUL
	goto :WAIT
:WAIT_END
if exist "%~dp0\error-%BUILD_CONFIG%-*" exit /B 1


:TEST
for /D %%a in (%BUILD_CONFIG%-VC-mbedTLS-*) do (
	if exist "%~dp0\cacert.pem" xcopy "%~dp0\cacert.pem" "%%a" /FIYD

	echo "%%~dp0\curl.exe" -L -v --capath "%%~dp0\" negrutiu.com> "%%a\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%%a\test.bat"
	echo pause>> "%%a\test.bat"
)
for /D %%a in (%BUILD_CONFIG%-VC-WinSSL-*) do (
	echo "%%~dp0\curl.exe" -L -v negrutiu.com> "%%a\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%%a\test.bat"
	echo pause>> "%%a\test.bat"
)

set END_TIME=%date% %time%
echo Started %START_TIME%
echo Ended   %END_TIME%
REM pause