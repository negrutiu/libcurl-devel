REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

REM | CONFIG=Debug|Release|RelWithDebInfo|MinSizeRel
if not defined CONFIG set CONFIG=Release

cd /d "%~dp0"
set ROOTDIR=%CD%

:REQUIREMENTS
if not exist "%PF32%" set PF32=%PROGRAMFILES(X86)%
if not exist "%PF32%" set PF32=%PROGRAMFILES%

REM | Visual Studio
set VSWHERE=%PF32%\Microsoft Visual Studio\Installer\vswhere.exe
if not exist "%VSWHERE%" echo ERROR: Missing "%VSHWERE%" && pause && exit /B 1
for /f "usebackq tokens=1* delims=: " %%i in (`"%VSWHERE%" -version 15 -requires Microsoft.Component.MSBuild`) do if /i "%%i"=="installationPath" set VSDIR=%%j

set VCVARSALL=%VSDIR%\VC\Auxiliary\Build\vcvarsall.bat
if not exist "%VCVARSALL%" echo ERROR: Missing "%VCVARSALL%" && pause && exit /B 1

REM | NASM (required starting with OpenSSL 1.0.2)
REM | Use powershell to read NASM path from registry to properly handle paths with spaces (e.g. "C:\Program Files\NASM")
set NASM_PATH=
for /f "usebackq delims=*" %%a in (`powershell -Command "(gp 'HKCU:\Software\nasm').'(Default)'"`) do set NASM_PATH=%%a
if not exist "%NASM_PATH%\nasm.exe" echo ERROR: Missing "%NASM_PATH%\nasm.exe" && pause && exit /B 1
set PATH=%PATH%;%NASM_PATH%

REM | Perl
perl -v > NUL
if %errorlevel% neq 0 echo ERROR: Missing Perl && pause && exit /B 1

REM | cmake
cmake --version > NUL
if %errorlevel% neq 0 echo ERROR: Missing 'cmake' && pause && exit /B 1

REM | cacert.pem
if not exist cacert.pem echo ERROR: Missing cacert.pem. Get it! && pause && exit /B 2


:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------

if /i "%~1" equ "/build" goto :BUILD

REM =============================================
:PARALLEL_OPENSSL
REM =============================================

REM | Notice the `call` in "start "" cmd /C call <script> <params>"
REM | Without it parameters such as -PARAM="val1 val2 val3" are incorrectly escaped...

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-Win32 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-x64 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-Win32-HTTP_ONLY ^
	BUILD_CRT=static ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-x64-HTTP_ONLY ^
	BUILD_CRT=static ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl_dll-Win32 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=shared ^
	BUILD_NGHTTP2=shared ^
	BUILD_OPENSSL=shared ^
	BUILD_CURL=shared ^
	BUILD_OPENSSL_CONFIGURE_EXTRA=""  ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl_dll-x64 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=shared ^
	BUILD_NGHTTP2=shared ^
	BUILD_OPENSSL=shared ^
	BUILD_CURL=shared ^
	BUILD_OPENSSL_CONFIGURE_EXTRA=""  ^
	BUILD_CURL_CONFIGURE_EXTRA=""

REM =============================================
:PARALLEL_WINSSL
REM =============================================

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-WinSSL-Win32 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-WinSSL-x64 ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-WinSSL-Win32-HTTP_ONLY ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-WinSSL-x64-HTTP_ONLY ^
	BUILD_CRT=static ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

exit /B 0


:: ----------------------------------------------------------------
:GET_DIR_NAME
:: ----------------------------------------------------------------
set DIRNAME=%~nx1
exit /B

:: ----------------------------------------------------------------
:BUILD
:: ----------------------------------------------------------------

REM | Command line parameters
shift
:loop_params
	if "%~1" equ "" goto :loop_params_end
	set %~1=%~2
	shift & shift
	goto :loop_params
:loop_params_end

call :GET_DIR_NAME "%BUILD_OUTDIR%"

if /I "%BUILD_ARCH%" equ "Win32" set VCVARS_ARCH=x86
if /I "%BUILD_ARCH%" equ "x86"   set VCVARS_ARCH=x86
if /I "%BUILD_ARCH%" equ "Win64" set VCVARS_ARCH=x64
if /I "%BUILD_ARCH%" equ "x64"   set VCVARS_ARCH=x64

mkdir "%BUILD_OUTDIR%" 2> NUL
cd /d "%BUILD_OUTDIR%"

REM | Parameter cleansing
if /i "%BUILD_SSL_BACKEND%" neq "OPENSSL" set BUILD_OPENSSL=

REM | Initialize MSVC environment
pushd "%CD%"
call "%VCVARSALL%" %VCVARS_ARCH%
popd


:ZLIB
if "%BUILD_ZLIB%" equ "" goto :ZLIB_END
echo.
echo -----------------------------------
echo  zlib
echo -----------------------------------
title %DIRNAME%-zlib

xcopy "%ROOTDIR%\zlib" zlib /QEIYD

REM | Configure
if not exist zlib\BUILD\CMakeCache.txt (
	REM | Comment `set(CMAKE_DEBUG_POSTFIX "d")`
	if /i "%CONFIG%" equ "Debug" powershell -Command "(gc zlib\CMakeLists.txt) -replace '^\s*set\(CMAKE_DEBUG_POSTFIX', '    #set(CMAKE_DEBUG_POSTFIX'  | Out-File -encoding ASCII zlib\CMakeLists.txt"

	cmake -G "NMake Makefiles" -S zlib -B zlib\BUILD ^
		-DCMAKE_BUILD_TYPE=%CONFIG%
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)
if /i "%BUILD_CRT%" equ "static" (
	REM | By default zlib links to shared CRT library
	REM | Because zlib doesn't have a cmake variable to control CRT linkage, we'll do this by replacing in .vcxproj files...
	echo Configure static CRT...
	powershell -Command "(gc zlib\BUILD\CMakeCache.txt) -replace '/MDd', '/MTd' | Out-File -encoding ASCII zlib\BUILD\CMakeCache.txt"
	powershell -Command "(gc zlib\BUILD\CMakeCache.txt) -replace '/MD',  '/MT'  | Out-File -encoding ASCII zlib\BUILD\CMakeCache.txt"
)

cmake --build zlib\BUILD --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | zconf.h
echo.
echo Copying zconf.h...
copy /Y zlib\BUILD\zconf.h zlib\zconf.h

REM | Collect
echo.
pushd zlib\BUILD
	for %%f in (zlib*.dll zlib*.lib zlib*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd zlib\BUILD\CMakeFiles\zlibstatic.dir
	for %%f in (zlib*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
:ZLIB_END


:NGHTTP2
if "%BUILD_NGHTTP2%" equ "" goto :NGHTTP2_END
echo.
echo -----------------------------------
echo  nghttp2
echo -----------------------------------
title %DIRNAME%-nghttp2

xcopy "%ROOTDIR%\nghttp2" nghttp2 /QEIYD

if not exist nghttp2\BUILD\CMakeCache.txt (
	set CMAKE_NGHTTP2_VARIABLES=-DENABLE_SHARED_LIB=ON -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=OFF

	if /i "%BUILD_CRT%" equ "static" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_STATIC_CRT=ON
	if /i "%BUILD_CRT%" neq "static" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_STATIC_CRT=OFF

	if /i "%CONFIG%" equ "Debug" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_DEBUG=ON

	cmake -G "NMake Makefiles" -S nghttp2 -B nghttp2\BUILD ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		!CMAKE_NGHTTP2_VARIABLES!
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

cmake --build nghttp2\BUILD --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | Collect
echo.
pushd nghttp2\BUILD\lib
	for %%f in (*.dll *.lib *.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd nghttp2\BUILD\lib\CMakeFiles\nghttp2_static.dir
	for %%f in (nghttp2*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
:NGHTTP2_END


:OPENSSL
if /i "%BUILD_SSL_BACKEND%" neq "OPENSSL" goto :OPENSSL_END
echo.
echo -----------------------------------
echo  openssl
echo -----------------------------------
title %DIRNAME%-openssl

REM | Make a copy of the source code
echo Cloning the source code...
pushd "%BUILD_OUTDIR%"
	echo fuzz> exclude.txt
	xcopy "%ROOTDIR%\openssl\*.*" openssl\ /EXCLUDE:exclude.txt /QEIYD
	del exclude.txt
popd

REM | Features
set BUILD_OPENSSL_PARAMS=shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
if /i "%BUILD_ARCH%" equ "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! VC-WIN64A
if /i "%BUILD_ARCH%" neq "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! VC-WIN32

if /i "%CONFIG%" equ "Debug" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! --debug
if /i "%CONFIG%" neq "Debug" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! --release


pushd "%BUILD_OUTDIR%\openssl"

REM | Configure
if not exist makefile (
	perl Configure !BUILD_OPENSSL_PARAMS! !BUILD_OPENSSL_CONFIGURE_EXTRA! --prefix="%CD%\_PACKAGE"
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

if /i "%BUILD_CRT%" equ "static" (
	REM | By default openssl links to shared CRT library
	REM | Because openssl doesn't have a variable to control CRT linkage, we'll do this by replacing compiler flag in makefile
	REM | NOTE: There is the -static parameter, but it's useless in MSVC. It works in mingw though...
	echo Configure static CRT...
	powershell -Command "(gc makefile) -replace '/MDd', '/MTd' | Out-File -encoding ASCII makefile"
	powershell -Command "(gc makefile) -replace '/MD',  '/MT'  | Out-File -encoding ASCII makefile"
)

REM | Make
nmake
if %errorlevel% neq 0 pause && exit /B %errorlevel%

popd

REM | Collect
echo.
pushd openssl
	for %%f in (lib*.dll lib*.lib lib*.pdb ossl_*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd openssl\apps
	for %%f in (openssl.exe openssl.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
:OPENSSL_END


:CURL
echo.
echo -----------------------------------
echo  libcurl
echo -----------------------------------
title %DIRNAME%-libcurl

xcopy "%ROOTDIR%\curl\*.*" curl /QEIYD

REM | curl(*)
set CL=
set CMAKE_CURL_VARIABLES=
set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_VERBOSE_MAKEFILE=ON
set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DBUILD_TESTING=OFF
if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DENABLE_CURLDEBUG=ON -DENABLE_DEBUG=ON -DCMAKE_DEBUG_POSTFIX:STRING=""

REM | curl(static .exe)
if /i "%BUILD_CURL%" equ "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DBUILD_SHARED_LIBS=OFF
if /i "%BUILD_CURL%" neq "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DBUILD_SHARED_LIBS=ON

REM | curl(static CRT)
if /i "%BUILD_CRT%" equ "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=ON
if /i "%BUILD_CRT%" neq "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=OFF

REM | curl(zlib)
if /i "%BUILD_ZLIB%" equ "static" (
	set BUILD_ZLIB_VALID=1
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="!BUILD_OUTDIR!/zlib" -DZLIB_LIBRARY_DEBUG=zlib/BUILD/zlibstatic.lib
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="!BUILD_OUTDIR!/zlib" -DZLIB_LIBRARY_RELEASE=zlib/BUILD/zlibstatic.lib
)
if /i "%BUILD_ZLIB%" equ "shared" (
	set BUILD_ZLIB_VALID=1
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="!BUILD_OUTDIR!/zlib" -DZLIB_LIBRARY_DEBUG=zlib/BUILD/zlib.lib
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="!BUILD_OUTDIR!/zlib" -DZLIB_LIBRARY_RELEASE=zlib/BUILD/zlib.lib
)
if "%BUILD_ZLIB_VALID%" neq "1" (
	if "%BUILD_ZLIB%" neq "" echo ERROR: Invalid BUILD_ZLIB=%BUILD_ZLIB%. Use BUILD_ZLIB=static^|shared && pause && exit /B 57
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=OFF
)

REM | curl(nghttp2)
if /i "%BUILD_NGHTTP2%" equ "static" (
	set BUILD_NGHTTP2_VALID=1
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR=nghttp2/lib/includes -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/nghttp2_static.lib
	REM | Hack: NGHTTP2_STATICLIB must be defined for curl to link statically to nghttp2
	set CL=/DNGHTTP2_STATICLIB=1 %CL%
)
if /i "%BUILD_NGHTTP2%" equ "shared" (
	set BUILD_NGHTTP2_VALID=1
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR=nghttp2/lib/includes -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/nghttp2.lib
)
if "%BUILD_NGHTTP2_VALID%" neq "1" (
	if "%BUILD_NGHTTP2%" neq "" echo ERROR: Invalid BUILD_NGHTTP2=%BUILD_NGHTTP2%. Use BUILD_NGHTTP2=static^|shared && pause && exit /B 57
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=OFF
)

REM | curl(openssl)
if /i "%BUILD_SSL_BACKEND%" equ "OPENSSL" (
	REM | To activate TLS-SRP, defining USE_TLS_SRP cmake variable is not enough. We'll also specify compiler definition /DUSE_TLS_SRP which does the job
	set CL=!CL! /DUSE_TLS_SRP
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DCMAKE_USE_OPENSSL=ON ^
		-DOPENSSL_ROOT_DIR="!BUILD_OUTDIR!/openssl" ^
		-DOPENSSL_CRYPTO_LIBRARY="!BUILD_OUTDIR!/openssl" ^
		-DUSE_TLS_SRP:BOOL=ON
)
if /i "%BUILD_OPENSSL%" equ "static" (
	set BUILD_OPENSSL_VALID=1
	REM | openssl builds both static (libcrypto_static.lib) and shared (libcrypto.lib) libraries
	REM | curl always links to libcrypto.lib/libssl.lib and I've found no way to redirect it to the static libraries
	REM | Until better workaround is found, we'll temporarily rename libxxx_static.lib -> libxxx.lib
	REM | TODO: Research OPENSSL_USE_STATIC_LIBS (see "%PROGRAMFILES%\CMake\share\cmake-3.17\Modules\FindOpenSSL.cmake")
	echo.
	echo Configure openssl static libraries...
	move /Y openssl\libcrypto.lib			openssl\libcrypto.dll.lib
	move /Y openssl\libssl.lib				openssl\libssl.dll.lib
	move /Y openssl\libcrypto_static.lib	openssl\libcrypto.lib
	move /Y openssl\libssl_static.lib		openssl\libssl.lib
)
if /i "%BUILD_OPENSSL%" equ "shared" (
	set BUILD_OPENSSL_VALID=1
)
if "%BUILD_OPENSSL_VALID%" neq "1" (
	if "%BUILD_OPENSSL%" neq "" echo ERROR: Invalid BUILD_OPENSSL=%BUILD_OPENSSL%. Use BUILD_OPENSSL=static^|shared && pause && exit /B 57
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_USE_OPENSSL=OFF
)

REM | curl(winssl)
if /i "%BUILD_SSL_BACKEND%" equ "WINSSL" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_USE_WINSSL=ON
)

REM | Configure
if not exist curl\BUILD\CMakeCache.txt (
	cmake -G "NMake Makefiles" -S curl -B curl\BUILD ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		!CMAKE_CURL_VARIABLES! ^
		!BUILD_CURL_CONFIGURE_EXTRA!
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

REM | Build
cmake --build curl\BUILD --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | Revert static libs
if exist openssl\libcrypto.dll.lib (
	echo.
	echo Revert openssl static libraries...
	move /Y openssl\libcrypto.lib		openssl\libcrypto_static.lib
	move /Y openssl\libssl.lib			openssl\libssl_static.lib
	move /Y openssl\libcrypto.dll.lib	openssl\libcrypto.lib
	move /Y openssl\libssl.dll.lib		openssl\libssl.lib
)

REM | Collect
echo.
pushd curl\BUILD\lib
	for %%f in (*.dll *.lib *.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd curl\BUILD\lib\CMakeFiles\libcurl.dir
	for %%f in (libcurl*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd curl\BUILD\src
	for %%f in (*.exe *.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
:CURL_END

:: test.bat + cacert.pem
set testfile=%BUILD_OUTDIR%\_test_curl.bat
if /i "%BUILD_SSL_BACKEND%" equ "WinSSL" (
	echo "%%~dp0\curl.exe" -L -v -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%testfile%"
	echo "%%~dp0\curl.exe" -V>> "%testfile%"
	echo pause>> "%testfile%"
) else (
	mklink /H cacert.pem "%ROOTDIR%\cacert.pem" 2> NUL
	echo "%%~dp0\curl.exe" -L -v --cacert cacert.pem -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%testfile%"
	echo "%%~dp0\curl.exe" -V>> "%testfile%"
	echo pause>> "%testfile%"
)

echo **********************************************************
echo  The End
echo **********************************************************

