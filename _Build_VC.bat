REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion
set CONFIG=Release

cd /d "%~dp0"

:REQUIREMENTS
if not exist "%PF32%" set PF32=%PROGRAMFILES(X86)%
if not exist "%PF32%" set PF32=%PROGRAMFILES%

REM :: Visual Studio
set VSWHERE=%PF32%\Microsoft Visual Studio\Installer\vswhere.exe
if not exist "%VSWHERE%" echo ERROR: Missing "%VSHWERE%" && pause && exit /B 1
for /f "usebackq tokens=1* delims=: " %%i in (`"%VSWHERE%" -version 15 -requires Microsoft.Component.MSBuild`) do if /i "%%i"=="installationPath" set VSDIR=%%j

set VCVARSALL=%VSDIR%\VC\Auxiliary\Build\vcvarsall.bat
if not exist "%VCVARSALL%" echo ERROR: Missing "%VCVARSALL%" && pause && exit /B 1

:: TODO: Determine dynamic
set CMAKE_GENERATOR_BASE=Visual Studio 15 2017

REM :: NASM (required starting with OpenSSL 1.0.2)
REM :: Use powershell to read NASM path from registry to properly handle paths with spaces (e.g. "C:\Program Files\NASM")
set NASM_PATH=
for /f "usebackq delims=*" %%a in (`powershell -Command "(gp 'HKCU:\Software\nasm').'(Default)'"`) do set NASM_PATH=%%a
if not exist "%NASM_PATH%\nasm.exe" echo ERROR: Missing "%NASM_PATH%\nasm.exe" && pause && exit /B 1
set PATH=%PATH%;%NASM_PATH%

REM :: Perl
perl -v > NUL
if %errorlevel% neq 0 echo ERROR: Missing Perl && pause && exit /B 1

REM :: cmake
cmake --version > NUL
if %errorlevel% neq 0 echo ERROR: Missing 'cmake' && pause && exit /B 1

REM :: cacert.pem
if not exist cacert.pem echo ERROR: Missing cacert.pem. Get it! && pause && exit /B 2


:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
:ARG_OPENSSL

if /I "%1" equ "/build-openssl-Win32" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-Win32
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	set BUILD_OPENSSL_FEATURES=VC-WIN32 --release no-shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-x64
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	set BUILD_OPENSSL_FEATURES=VC-WIN64A --release no-shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

if /I "%1" equ "/build-openssl-Win32-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-Win32-HTTP_ONLY
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	set BUILD_OPENSSL_FEATURES=VC-WIN32 --release no-shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl-x64-HTTP_ONLY
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	set BUILD_OPENSSL_FEATURES=VC-WIN64A --release no-shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

if /I "%1" equ "/build-openssl-Win32-openssl_dll" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl_dll-Win32
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DCURL_DISABLE_LDAP
	set BUILD_OPENSSL_FEATURES=VC-WIN32 --release shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64-openssl_dll" (
	set BUILD_OUTDIR=%~dp0\bin\%CONFIG%-VC-openssl_dll-x64
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	set BUILD_OPENSSL_FEATURES=VC-WIN64A --release shared enable-static-engine no-dynamic-engine no-tests enable-ssl3
	goto :BUILD
)

:ARG_WINSSL
if /I "%1" equ "/build-winssl-Win32" (
	set BUILD_SUBDIR=%CONFIG%-VC-WinSSL-Win32
	set BUILD_OUTDIR=%~dp0\bin\!BUILD_SUBDIR!
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DCURL_DISABLE_LDAP -DPROV_RSA_AES=24
	goto :BUILD
)

if /I "%1" equ "/build-winssl-x64" (
	set BUILD_SUBDIR=%CONFIG%-VC-WinSSL-x64
	set BUILD_OUTDIR=%~dp0\bin\!BUILD_SUBDIR!
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	goto :BUILD
)

if /I "%1" equ "/build-winssl-Win32-HTTP_ONLY" (
	set BUILD_SUBDIR=%CONFIG%-VC-WinSSL-Win32-HTTP_ONLY
	set BUILD_OUTDIR=%~dp0\bin\!BUILD_SUBDIR!
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY -DPROV_RSA_AES=24
	goto :BUILD
)

if /I "%1" equ "/build-winssl-x64-HTTP_ONLY" (
	set BUILD_SUBDIR=%CONFIG%-VC-WinSSL-x64-HTTP_ONLY
	set BUILD_OUTDIR=%~dp0\bin\!BUILD_SUBDIR!
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	goto :BUILD
)

:: Unknown argument?
if "%1" neq "" echo ERROR: Unknown argument "%1" && pause && exit /B


:: Launch parallel builds
start "" "%COMSPEC%" /C "%~f0" /build-openssl-Win32
REM start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64
REM start "" "%COMSPEC%" /C "%~f0" /build-openssl-Win32-HTTP_ONLY
REM start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /build-openssl-Win32-openssl_dll
REM start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64-openssl_dll

REM start "" "%COMSPEC%" /C "%~f0" /build-winssl-Win32
REM start "" "%COMSPEC%" /C "%~f0" /build-winssl-x64
REM start "" "%COMSPEC%" /C "%~f0" /build-winssl-Win32-HTTP_ONLY
REM start "" "%COMSPEC%" /C "%~f0" /build-winssl-x64-HTTP_ONLY
exit /B

:: ----------------------------------------------------------------
:GET_DIR_NAME
:: ----------------------------------------------------------------
set DIRNAME=%~nx1
exit /B

:: ----------------------------------------------------------------
:BUILD
:: ----------------------------------------------------------------

call :GET_DIR_NAME "%BUILD_OUTDIR%"

if /I "%BUILD_ARCH%" equ "Win32" set CMAKE_GENERATOR=%CMAKE_GENERATOR_BASE%
if /I "%BUILD_ARCH%" equ "x86"   set CMAKE_GENERATOR=%CMAKE_GENERATOR_BASE%
if /I "%BUILD_ARCH%" equ "Win64" set CMAKE_GENERATOR=%CMAKE_GENERATOR_BASE% Win64
if /I "%BUILD_ARCH%" equ "x64"   set CMAKE_GENERATOR=%CMAKE_GENERATOR_BASE% Win64

if /I "%BUILD_ARCH%" equ "Win32" set VCVARS_ARCH=x86
if /I "%BUILD_ARCH%" equ "x86"   set VCVARS_ARCH=x86
if /I "%BUILD_ARCH%" equ "Win64" set VCVARS_ARCH=x64
if /I "%BUILD_ARCH%" equ "x64"   set VCVARS_ARCH=x64

mkdir "%BUILD_OUTDIR%" 2> NUL
cd /d "%BUILD_OUTDIR%"


:ZLIB
if "%BUILD_USE_ZLIB%" lss "1" goto :ZLIB_END
echo.
echo -----------------------------------
echo  zlib
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title %DIRNAME%-zlib

xcopy "%~dp0\zlib" zlib /QEIYD

if not exist zlib\build\CMakeCache.txt (
	cmake -G "%CMAKE_GENERATOR%" -S zlib -B zlib\build
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

cmake --build zlib\build --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

mklink /H zlibstatic.lib zlib\build\%CONFIG%\zlibstatic.lib 2> NUL

:: Build libcurl with zlib support
set ZLIB=1
set ZLIB_PATH=../../zlib
:ZLIB_END


:NGHTTP2
if "%BUILD_USE_NGHTTP2%" lss "1" goto :NGHTTP2_END
echo.
echo -----------------------------------
echo  nghttp2
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title %DIRNAME%-nghttp2

xcopy "%~dp0\nghttp2" nghttp2 /QEIYD

if not exist nghttp2\build\CMakeCache.txt (
	cmake -G "%CMAKE_GENERATOR%" -S nghttp2 -B nghttp2\build -DENABLE_LIB_ONLY=ON -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
	if /I "%CONFIG%" equ "Debug" cmake nghttp2/build -DENABLE_DEBUG=ON
)

cmake --build nghttp2\build --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%


mklink /H nghttp2_static.lib nghttp2\build\lib\Release\nghttp2_static.lib 2> NUL

:: Build libcurl with nghttp2 support
set NGHTTP2=1
set NGHTTP2_PATH=../../nghttp2
:NGHTTP2_END


REM | if /I "%BUILD_ARCH%" equ "x64" (
REM | 	set MINGW=%MSYS2%\mingw64
REM | 	set GLOBAL_CFLAGS=-march=x86-64 -s -Os -DWIN32 -D_WIN32_WINNT=0x0502 -DNDEBUG -O3 -ffunction-sections -fdata-sections
REM | 	set GLOBAL_LFLAGS=!GLOBAL_CFLAGS! -static-libgcc -static-libstdc++ -Wl,--gc-sections -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base -Wl,--enable-stdcall-fixup -Wl,--high-entropy-va
REM | 	set GLOBAL_RFLAGS=-F pe-x86-64
REM | ) else (
REM | 	set MINGW=%MSYS2%\mingw32
REM | 	set GLOBAL_CFLAGS=-march=pentium2 -s -Os -DWIN32 -D_WIN32_WINNT=0x0400 -DNDEBUG -O3 -ffunction-sections -fdata-sections
REM | 	set GLOBAL_LFLAGS=!GLOBAL_CFLAGS! -static-libgcc -static-libstdc++ -Wl,--gc-sections -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base -Wl,--enable-stdcall-fixup
REM | 	set GLOBAL_RFLAGS=-F pe-i386
REM | )
REM | set CURL_CFG=
REM | set CURL_LDFLAG_EXTRAS=
REM | set CURL_LDFLAG_EXTRAS2=
REM | set PATH=%MINGW%\bin;%MSYS2%\usr\bin;%PATH%
REM | call :GET_DIR_NAME "%BUILD_OUTDIR%"

:OPENSSL
if /i "%BUILD_SSL_ENGINE%" neq "OPENSSL" goto :OPENSSL_END
echo.
echo -----------------------------------
echo  openssl
echo -----------------------------------
title %DIRNAME%-openssl

REM :: Make a copy of the source code
echo Cloning the source code...
pushd "%BUILD_OUTDIR%"
	echo fuzz> exclude.txt
	xcopy "%~dp0\openssl\*.*" openssl\ /EXCLUDE:exclude.txt /QEIYD
	del exclude.txt
popd

pushd "%CD%"
call "%VCVARSALL%" %VCVARS_ARCH%
popd

pushd "%BUILD_OUTDIR%\openssl"

REM :: Configure
if not exist makefile (
	perl Configure %BUILD_OPENSSL_FEATURES% --prefix="%CD%\_PACKAGE"
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

REM :: Make
nmake
if %errorlevel% neq 0 pause && exit /B %errorlevel%

popd

REM :: Gather binaries
mklink /H openssl.exe				openssl\apps\openssl.exe 2> NUL
mklink /H libcrypto.lib				openssl\libcrypto.lib 2> NUL
mklink /H libssl.lib				openssl\libssl.lib 2> NUL
if %BUILD_OPENSSL_DLL% neq 0 (
	mklink /H libcrypto-1_1.dll		openssl\libcrypto-1_1.dll		2> NUL
	mklink /H libcrypto-1_1.pdb		openssl\libcrypto-1_1.pdb		2> NUL
	mklink /H libssl-1_1.dll		openssl\libssl-1_1.dll			2> NUL
	mklink /H libssl-1_1.pdb		openssl\libssl-1_1.pdb			2> NUL
	mklink /H libcrypto-1_1-x64.dll	openssl\libcrypto-1_1-x64.dll	2> NUL
	mklink /H libcrypto-1_1-x64.pdb	openssl\libcrypto-1_1-x64.pdb	2> NUL
	mklink /H libssl-1_1-x64.dll	openssl\libssl-1_1-x64.dll		2> NUL
	mklink /H libssl-1_1-x64.pdb	openssl\libssl-1_1-x64.pdb		2> NUL
)

REM :: Configure libcurl for openssl
REM | if %BUILD_OPENSSL_DLL% equ 0 set CURL_CFLAGS=!CURL_CFLAGS! -static -DCURL_STATICLIB
REM | if %BUILD_OPENSSL_DLL% equ 0 set CURL_LDFLAG_EXTRAS=!CURL_LDFLAG_EXTRAS! -static -DCURL_STATICLIB
REM | set CURL_CFLAGS=!CURL_CFLAGS! -DUSE_OPENSSL -DUSE_TLS_SRP -I../openssl/include
REM | set CURL_LDFLAG_EXTRAS=!CURL_LDFLAG_EXTRAS! -L../..
REM | if %BUILD_OPENSSL_DLL% equ 0 set CURL_LDFLAG_EXTRAS2=-lssl -lcrypto -lws2_32
REM | if %BUILD_OPENSSL_DLL% neq 0 set CURL_LDFLAG_EXTRAS2=-lssl.dll -lcrypto.dll -lws2_32
:OPENSSL_END


:WINSSL
if /i "%BUILD_SSL_ENGINE%" neq "WINSSL" goto :WINSSL_END
echo.
echo -----------------------------------
echo  WinSSL
echo -----------------------------------
title %DIRNAME%-WinSSL

:: Build libcurl with WinSSL
set CURL_CFG=!CURL_CFG! -winssl
set CURL_LDFLAG_EXTRAS2=!CURL_LDFLAG_EXTRAS2! -lcrypt32

echo Done
:WINSSL_END


:LIBCURL
echo.
echo -----------------------------------
echo  libcurl
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title %DIRNAME%-libcurl

xcopy "%~dp0\curl\*.*"			curl /QIYD
xcopy "%~dp0\curl\include" 		curl\include" /QEIYD
xcopy "%~dp0\curl\lib"			curl\lib" /QEIYD

REM :: Configure
if not exist curl\build\CMakeCache.txt (
	cmake -G "%CMAKE_GENERATOR%" -S curl -B curl\build
	if %errorlevel% neq 0 pause && exit /B %errorlevel%
)

echo **********************************************************
echo %CD%
pause
exit /B

if %BUILD_LIBCURL_DLL% equ 0 set CFG=!CURL_CFG!
if %BUILD_LIBCURL_DLL% neq 0 set CFG=!CURL_CFG! -dyn

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=!GLOBAL_CFLAGS! !CURL_CFLAGS! !OPENSSL_CFLAGS! !NGHTTP2_CFLAGS!
set CURL_LDFLAG_EXTRAS=!GLOBAL_LFLAGS! !CURL_LDFLAG_EXTRAS!
::set CURL_LDFLAG_EXTRAS2=!CURL_LDFLAG_EXTRAS!

mingw32-make -f Makefile.m32 all
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\cURL\lib\*.dll" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\cURL\lib\*.a"   "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\lib\*.o" > "%BUILD_OUTDIR%\asm-cURL-lib.txt"


:LIBCURL_EXE
if "%BUILD_LIBCURL_DLL%" equ "0" goto :LIBCURL_EXE_END
echo.
echo -----------------------------------
echo  libcurl.exe
echo -----------------------------------
title %DIRNAME%-libcurl.exe
:: NOTE: Must build in ANSI code page

cd /d "%~dp0"
xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src-dyn" /QEIYD
cd /d "%BUILD_OUTDIR%\cURL\src-dyn"

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

REM set CURL_CFLAG_EXTRAS=<use_existing>
REM set CURL_LDFLAG_EXTRAS=<use_existing>

:: curl.exe (dynamic) -> libcurl.exe
mingw32-make -f Makefile.m32 CFG=-dyn all
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
move /Y "%BUILD_OUTDIR%\cURL\src-dyn\curl.exe" "%BUILD_OUTDIR%\cURL\src-dyn\libcurl.exe"
xcopy "%BUILD_OUTDIR%\cURL\src-dyn\*.exe" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\src-dyn\*.o" > "%BUILD_OUTDIR%\asm-libcurl-src.txt"
:LIBCURL_EXE_END


:CURL_EXE
echo.
echo -----------------------------------
echo  curl.exe
echo -----------------------------------
title %DIRNAME%-curl.exe
:: NOTE: Must build in ANSI code page

cd /d "%~dp0"
xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src" /QEIYD
cd /d "%BUILD_OUTDIR%\cURL\src"

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

REM set CURL_CFLAG_EXTRAS=<use_existing>
REM set CURL_LDFLAG_EXTRAS=<use_existing>

:: curl.exe (static)
mingw32-make -f Makefile.m32 CFG= all
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

::Collect
echo.
xcopy "%BUILD_OUTDIR%\cURL\src\*.exe" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\src\*.o" > "%BUILD_OUTDIR%\asm-cURL-src.txt"
:CURL_EXE_END


:: test.bat + cacert.pem
if /I "%BUILD_SSL_ENGINE%" equ "WinSSL" (
	echo "%%~dp0\curl.exe" -L -v -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%BUILD_OUTDIR%\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%BUILD_OUTDIR%\test.bat"
	echo pause>> "%BUILD_OUTDIR%\test.bat"
) else (
	xcopy "%~dp0\cacert.pem" "%BUILD_OUTDIR%" /FIYD
	echo "%%~dp0\curl.exe" -L -v --cacert cacert.pem -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%BUILD_OUTDIR%\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%BUILD_OUTDIR%\test.bat"
	echo pause>> "%BUILD_OUTDIR%\test.bat"
)
