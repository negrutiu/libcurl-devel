REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

REM | CONFIG=Debug|Release|RelWithDebInfo|MinSizeRel
if not defined CONFIG set CONFIG=Release

REM | BUILDER=MSVC|mingw
if not defined BUILDER set BUILDER=MSVC

REM | CRT=static|shared
if not defined CRT set CRT=static

REM | VERBOSE=ON|OFF
if not defined VERBOSE set VERBOSE=OFF

cd /d "%~dp0"
set ROOTDIR=%CD%

if /i "%BUILDER%" equ "MSVC"  goto :REQUIREMENTS_MSVC
if /i "%BUILDER%" equ "mingw" goto :REQUIREMENTS_mingw
echo ERROR: BUILDER=%BUILDER%. Use BULDER=MSVC^|mingw && pause && exit /B 57

:REQUIREMENTS_MSVC
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
if not exist "%NASM_PATH%\nasm.exe" echo ERROR: Missing NASM. Install from `https://nasm.us/` && pause && exit /B 1
set PATH=%PATH%;%NASM_PATH%

REM | Perl
perl -v > NUL
if %errorlevel% neq 0 echo ERROR: Missing Perl. Install it from `http://strawberryperl.com/` && pause && exit /B 1

REM | cmake
cmake --version > NUL
if %errorlevel% neq 0 echo ERROR: Missing cmake. Install it from `https://cmake.org/` && pause && exit /B 1
set BUILD_CMAKE_GENERATOR=NMake Makefiles

goto :REQURIEMENTS_END

:REQUIREMENTS_mingw
REM | msys2
if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS2
if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS64
if not exist "%MSYS2%" echo ERROR: Missing msys2. Install from `https://msys2.org/` && pause && exit /B 2

REM | msys2/perl
if not exist "%MSYS2%\usr\bin\perl.exe" echo ERROR: Missing msys2/perl. Run `pacman -S perl` in msys2 && pause && exit /B 2

REM | mingw
if not exist "%MINGW64%\bin\gcc.exe" set MINGW64=%MINGW64_INSTDIR%
if not exist "%MINGW64%\bin\gcc.exe" set MINGW64=%MSYS2%\mingw64
if not exist "%MINGW64%\bin\gcc.exe" echo ERROR: Missing mingw64. Run `pacman -S mingw-w64-x86_64-toolchain` in msys2 && pause && exit /B 2

if not exist "%MINGW32%\bin\gcc.exe" set MINGW32=%MINGW32_INSTDIR%
if not exist "%MINGW32%\bin\gcc.exe" set MINGW32=%MSYS2%\mingw32
if not exist "%MINGW32%\bin\gcc.exe" echo ERROR: Missing mingw32. Run `pacman -S mingw-w64-i686-toolchain` in msys2 && pause && exit /B 2

REM | sspi.h
set sspi32_h=%MINGW32%\i686-w64-mingw32\include\sspi.h
findstr SEC_APPLICATION_PROTOCOL_NEGOTIATION_STATUS "%sspi32_h%" > NUL
if %errorlevel% neq 0 set sspi32_ok=FALSE

set sspi64_h=%MINGW64%\x86_64-w64-mingw32\include\sspi.h
findstr SEC_APPLICATION_PROTOCOL_NEGOTIATION_STATUS "%sspi64_h%" > NUL
if %errorlevel% neq 0 set sspi64_ok=FALSE

if /i "%sspi32_ok%,%sspi64_ok%" neq "," echo ERROR: In order to support nghttp2 /w SChannel the file "sspi.h" from mingw32/64 requires patching && echo Run these commands:
if /i "%sspi32_ok%" neq "" echo   move /Y "%sspi32_h%" "%sspi32_h%.bak" && echo   copy /Y "%CD%\_Patches\sspi.h" "%sspi32_h%"
if /i "%sspi64_ok%" neq "" echo   move /Y "%sspi64_h%" "%sspi64_h%.bak" && echo   copy /Y "%CD%\_Patches\sspi.h" "%sspi64_h%"
if /i "%sspi32_ok%,%sspi64_ok%" neq "," pause && exit /B 2

REM | cmake
cmake --version > NUL
if %errorlevel% neq 0 echo ERROR: Missing cmake. Install it from `https://cmake.org/` && pause && exit /B 1
set BUILD_CMAKE_GENERATOR=MinGW Makefiles

goto :REQURIEMENTS_END


:REQURIEMENTS_END

REM | curl-ca-bundle.crt
if not exist curl-ca-bundle.crt echo ERROR: Missing curl-ca-bundle.crt. Run `_Get_ca_bundle.bat` && pause && exit /B 2


:: ----------------------------------------------------------------
REM | PARALLEL
:: ----------------------------------------------------------------

if /i "%~1" equ "/build" goto :BUILD

title [%BUILDER%] %CONFIG%
del "bin\build*.flag" 2> NUL > NUL

REM | Notice the `call` in `start "" cmd /C call <script> <params>`
REM | Without it parameters such as -PARAM="val1 val2 val3" are incorrectly escaped...

REM =============================================
:PARALLEL_ZLIB
REM =============================================

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ZLIB=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-zlib-%CONFIG%-Win32-Legacy ^
	BUILD_C_FLAGS="-march=pentium2 -D_WIN32_WINNT=0x0400"

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ZLIB=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-zlib-%CONFIG%-x64-Legacy ^
	BUILD_C_FLAGS="-march=x86-64 -D_WIN32_WINNT=0x0502"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ZLIB=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-zlib-%CONFIG%-Win32

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ZLIB=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-zlib-%CONFIG%-x64


REM =============================================
:PARALLEL_NGHTTP2
REM =============================================

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_NGHTTP2=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-Win32-Legacy ^
	BUILD_C_FLAGS="-march=pentium2 -D_WIN32_WINNT=0x0400"

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_NGHTTP2=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-x64-Legacy ^
	BUILD_C_FLAGS="-march=x86-64 -D_WIN32_WINNT=0x0502"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_NGHTTP2=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-Win32

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_NGHTTP2=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-x64


REM =============================================
:PARALLEL_OPENSSL
REM =============================================

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_OPENSSL=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32-Legacy ^
	BUILD_C_FLAGS="-march=pentium2 -D_WIN32_WINNT=0x0400" ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="no-capieng no-async no-pinshared 386"

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_OPENSSL=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64-Legacy ^
	BUILD_C_FLAGS="-march=x86-64 -D_WIN32_WINNT=0x0502" ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="no-capieng no-async no-pinshared"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_OPENSSL=1 ^
	BUILD_ARCH=Win32 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_OPENSSL=1 ^
	BUILD_ARCH=x64 ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64


REM | Wait for build-running-*.flag to appear
echo Starting . . .
:WAIT_2START
	if not exist "bin\build-running-%BUILDER%*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_2START

REM | Wait for build-running-*.flag to go away
echo Building libraries . . .
:WAIT_4LIBS
	if exist "bin\build-running-%BUILDER%*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_4LIBS

if exist "bin\build-error-%BUILDER%*%CONFIG%*.flag" exit /B 1

REM pause
exit /B

REM =============================================
:PARALLEL_OPENSSL2
REM =============================================

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32-Legacy ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_C_FLAGS="-march=pentium2 -D_WIN32_WINNT=0x0400" ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="no-capieng no-async no-pinshared 386" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON -DMAKE_USE_OPENLDAP=OFF"

if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64-Legacy ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_C_FLAGS="-march=x86-64 -D_WIN32_WINNT=0x0502" ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="no-capieng no-async no-pinshared" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON -DMAKE_USE_OPENLDAP=OFF"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32 ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64 ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32-HTTP_ONLY ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64-HTTP_ONLY ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_OPENSSL=static ^
	BUILD_CURL=static ^
	BUILD_OPENSSL_CONFIGURE_EXTRA="" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-Win32-DLL ^
	BUILD_ZLIB=shared ^
	BUILD_NGHTTP2=shared ^
	BUILD_OPENSSL=shared ^
	BUILD_CURL=shared ^
	BUILD_OPENSSL_CONFIGURE_EXTRA=""  ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-openssl-%CONFIG%-x64-DLL ^
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
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-Win32 ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-x64 ^
	BUILD_ZLIB=static ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-Win32-DLL ^
	BUILD_ZLIB=shared ^
	BUILD_NGHTTP2=shared ^
	BUILD_CURL=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-x64-DLL ^
	BUILD_ZLIB=shared ^
	BUILD_NGHTTP2=shared ^
	BUILD_CURL=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=Win32 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-Win32-HTTP_ONLY ^
	BUILD_ZLIB="" ^
	BUILD_NGHTTP2=static ^
	BUILD_CURL=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_ARCH=x64 ^
	BUILD_SSL_BACKEND=WINSSL ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-WinSSL-%CONFIG%-x64-HTTP_ONLY ^
	BUILD_ZLIB="" ^
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

mkdir "%BUILD_OUTDIR%" 2> NUL
cd /d "%BUILD_OUTDIR%"

REM | Parameter validation
echo _%BUILDER%_| findstr /I /B /E "_msvc_ _mingw_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILDER=%BUILDER%. Use BUILDER=mingw^|msvc && pause && exit /B 57

echo _%CRT%_| findstr /I /B /E "_static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid CRT=%CRT%. Use CRT=static^|shared && pause && exit /B 57

REM | Initialize MSVC environment
if /i "%BUILDER%" equ "MSVC" (
	pushd "%CD%"
	if /i "%BUILD_ARCH%" equ "Win32" call "%VCVARSALL%" x86
	if /i "%BUILD_ARCH%" equ "x86"   call "%VCVARSALL%" x86
	if /i "%BUILD_ARCH%" equ "Win64" call "%VCVARSALL%" x64
	if /i "%BUILD_ARCH%" equ "x64"   call "%VCVARSALL%" x64
	popd
)

REM | Initialize mingw environment
if /i "%BUILD_ARCH%" equ "x64" set MINGW=%MINGW64%
if /i "%BUILD_ARCH%" neq "x64" set MINGW=%MINGW32%
if /i "%BUILDER%" equ "mingw" set PATH=%MINGW%\bin;%MSYS2%\usr\bin;%PATH%
REM if /i "%BUILDER%" equ "mingw" set BUILD_C_FLAGS=!BUILD_C_FLAGS! -D__USE_MINGW_ANSI_STDIO=0

REM | Prevent mingw builds from linking to libgcc_*.dll
if /i "%BUILDER%" equ "mingw" set BUILD_C_FLAGS=!BUILD_C_FLAGS! -static-libgcc


if "%BUILD_ZLIB%" equ "1" goto :ZLIB
if "%BUILD_NGHTTP2%" equ "1" goto :NGHTTP2
if "%BUILD_OPENSSL%" equ "1" goto :OPENSSL

echo **************
echo Don't know what to build
echo **************
pause
exit /B 2


echo _%BUILD_CURL%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_CURL=%BUILD_CURL%. Use BUILD_CURL=static^|shared && pause && exit /B 57

if /i "%BUILD_SSL_BACKEND%" neq "OPENSSL" set BUILD_OPENSSL=

echo _%BUILD_SSL_BACKEND%_| findstr /I /B /E "_openssl_ _winssl_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_SSL_BACKEND=%BUILD_SSL_BACKEND%. Use BUILD_SSL_BACKEND=OPENSSL^|WINSSL && pause && exit /B 57

echo _%BUILD_CURL%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_CURL=%BUILD_CURL%. Use BUILD_CURL=static^|shared && pause && exit /B 57

echo _%BUILD_OPENSSL%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_OPENSSL=%BUILD_OPENSSL%. Use BUILD_OPENSSL=static^|shared && pause && exit /B 57

echo _%BUILD_NGHTTP2%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_NGHTTP2=%BUILD_NGHTTP2%. Use BUILD_NGHTTP2=static^|shared && pause && exit /B 57

echo _%BUILD_ZLIB%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_ZLIB=%BUILD_ZLIB%. Use BUILD_ZLIB=static^|shared && pause && exit /B 57


:ZLIB
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-zlib

xcopy "%ROOTDIR%\zlib" .build /QEIYD

REM | Configure
if not exist .build\BUILD\CMakeCache.txt (
	cmake -G "%BUILD_CMAKE_GENERATOR%" -S .build -B .build\BUILD ^
		-DCMAKE_VERBOSE_MAKEFILE=%VERBOSE% ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		-DCMAKE_INSTALL_PREFIX="%BUILD_OUTDIR%" ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS!"
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

if /i "%BUILDER%,%CRT%" equ "MSVC,static" (
	REM | By default zlib links to shared CRT library
	REM | Zlib doesn't provide a variable to control CRT linkage, so we'll replace compiler flags in .vcxproj files...
	echo Configure static CRT...
	powershell -Command "(gc .build\BUILD\CMakeCache.txt) -replace '/MDd', '/MTd' | Out-File -encoding ASCII .build\BUILD\CMakeCache.txt"
	powershell -Command "(gc .build\BUILD\CMakeCache.txt) -replace '/MD',  '/MT'  | Out-File -encoding ASCII .build\BUILD\CMakeCache.txt"
)

REM | Build
cmake --build .build\BUILD --config %CONFIG% --target zlibstatic zlib install
if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666

del /Q "%FLAG_RUNNING%"
exit /B


:NGHTTP2
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-nghttp2

xcopy "%ROOTDIR%\nghttp2" .build /QEIYD

REM | Configure
if not exist .build\BUILD\CMakeCache.txt (
	set CMAKE_NGHTTP2_VARIABLES=^
		-DCMAKE_VERBOSE_MAKEFILE=%VERBOSE% ^
		-DSTATIC_LIB_SUFFIX:STRING=_static ^
		-DCMAKE_INSTALL_PREFIX="%BUILD_OUTDIR%" ^
		-DENABLE_SHARED_LIB=ON ^
		-DENABLE_STATIC_LIB=ON ^
		-DENABLE_LIB_ONLY=ON

	if /i "%CRT%" equ "static" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_STATIC_CRT=ON
	if /i "%CRT%" neq "static" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_STATIC_CRT=OFF

	if /i "%CONFIG%" equ "Debug" set CMAKE_NGHTTP2_VARIABLES=!CMAKE_NGHTTP2_VARIABLES! -DENABLE_DEBUG=ON

	cmake -G "%BUILD_CMAKE_GENERATOR%" -S .build -B .build\BUILD ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		!CMAKE_NGHTTP2_VARIABLES! ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS!"
		
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

REM | Build
cmake --build .build\BUILD --config %CONFIG% --target nghttp2_static nghttp2 install
if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666

del /Q "%FLAG_RUNNING%"
exit /B


:OPENSSL
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-openssl

REM | Make a copy of the source code
echo Cloning the source code...
pushd "%BUILD_OUTDIR%"
	echo fuzz> exclude.txt
	xcopy "%ROOTDIR%\openssl\*.*" .build\ /EXCLUDE:exclude.txt /QEIYD
	del exclude.txt
	mkdir .build\fuzz 2> NUL
popd

REM | Features
set BUILD_OPENSSL_PARAMS=enable-static-engine no-dynamic-engine no-tests enable-ssl3
if /i "%BUILDER%" equ "MSVC" (
	if /i "%BUILD_ARCH%" equ "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! VC-WIN64A
	if /i "%BUILD_ARCH%" neq "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! VC-WIN32
)
if /i "%BUILDER%" equ "mingw" (
	if /i "%BUILD_ARCH%" equ "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! mingw64
	if /i "%BUILD_ARCH%" neq "x64" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! mingw
)

if /i "%CONFIG%" equ "Debug" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! --debug
if /i "%CONFIG%" neq "Debug" set BUILD_OPENSSL_PARAMS=!BUILD_OPENSSL_PARAMS! --release

pushd "%BUILD_OUTDIR%\.build"

REM | Configure
if not exist makefile (
	perl Configure !BUILD_OPENSSL_PARAMS! CFLAGS="!BUILD_C_FLAGS!" !BUILD_OPENSSL_CONFIGURE_EXTRA! --prefix="%BUILD_OUTDIR%" --openssldir="%BUILD_OUTDIR%\config"
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

if /i "%BUILDER%,%CRT%" equ "MSVC,static" (
	REM | By default openssl links to shared CRT library
	REM | Because openssl doesn't have a variable to control CRT linkage, we'll do this by replacing compiler flag in makefile
	echo Configure static CRT...
	powershell -Command "(gc makefile) -replace '/MDd', '/MTd' | Out-File -encoding ASCII makefile"
	powershell -Command "(gc makefile) -replace '/MD',  '/MT'  | Out-File -encoding ASCII makefile"
)

REM | Make
if /i "%BUILDER%" equ "MSVC" (
	nmake.exe all install_sw install_ssldirs
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)
if /i "%BUILDER%" equ "mingw" (
	mingw32-make.exe all install_sw install_ssldirs
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

popd

REM | Collect
REM echo.
REM pushd openssl
	REM for %%f in (lib*.dll lib*.lib lib*.a lib*.pdb ossl_*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
REM popd
REM pushd openssl\apps
	REM for %%f in (openssl.exe openssl.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
REM popd

del /Q "%FLAG_RUNNING%"
exit /B


:CURL
echo.
echo -----------------------------------
echo  libcurl
echo -----------------------------------
title %DIRNAME%-libcurl

xcopy "%ROOTDIR%\curl\*.*" curl /QEIYD

REM | curl(*)
set CMAKE_CURL_C_FLAGS=
set CMAKE_CURL_VARIABLES=

set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
	-DCMAKE_VERBOSE_MAKEFILE=%VERBOSE% ^
	-DBUILD_TESTING=OFF

if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DENABLE_CURLDEBUG=ON -DENABLE_DEBUG=ON -DCMAKE_DEBUG_POSTFIX:STRING=""

REM | curl(static .exe)
if /i "%BUILD_CURL%" equ "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DBUILD_SHARED_LIBS=OFF
if /i "%BUILD_CURL%" neq "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DBUILD_SHARED_LIBS=ON

REM | curl(static CRT)
if /i "%BUILDER%" equ "MSVC" (
	if /i "%CRT%" equ "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=ON
	if /i "%CRT%" neq "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=OFF
)

REM | curl(libssh2)
set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_USE_LIBSSH2=OFF

REM | curl(zlib)
if "%BUILD_ZLIB%" equ "" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=OFF
) else (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="!BUILD_OUTDIR!/zlib"
)
if /i "%BUILDER%,%BUILD_ZLIB%" equ "MSVC,static" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG=zlib/BUILD/zlibstatic.lib
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE=zlib/BUILD/zlibstatic.lib
)
if /i "%BUILDER%,%BUILD_ZLIB%" equ "MSVC,shared" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG=zlib/BUILD/zlib.lib
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE=zlib/BUILD/zlib.lib
)
if /i "%BUILDER%,%BUILD_ZLIB%" equ "mingw,static" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG=zlib/BUILD/libzlibstatic.a
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE=zlib/BUILD/libzlibstatic.a
)
if /i "%BUILDER%,%BUILD_ZLIB%" equ "mingw,shared" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG=zlib/BUILD/libzlib.dll.a
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE=zlib/BUILD/libzlib.dll.a
)

REM | curl(nghttp2)
if "%BUILD_NGHTTP2%" equ "" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=OFF
)
if /i "%BUILD_NGHTTP2%" equ "static" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR=nghttp2/lib/includes
	if /i "%BUILDER%" equ "MSVC"  set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/nghttp2.lib
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/libnghttp2.a
	REM | Hack: NGHTTP2_STATICLIB preprocessor definition must exist for curl to link statically to nghttp2
	set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DNGHTTP2_STATICLIB -DUSE_NGHTTP2
)
if /i "%BUILD_NGHTTP2%" equ "shared" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR=nghttp2/lib/includes
	if /i "%BUILDER%" equ "MSVC"  set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/nghttp2.lib
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY=nghttp2/BUILD/lib/libnghttp2.dll.a
	set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DUSE_NGHTTP2
)

REM | To use HTTP2 /w SChannel curl requires a recent version of sspi.h from Windows SDK
REM | The sspi.h from mingw is missing multiple definitions therefore a "patched" sspi.h is required
REM | Force use of ALPN (to activate HTTP2 /w SChannel)
REM | Related topic: https://github.com/curl/curl/issues/2591
if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DHAS_ALPN

REM | To activate TLS-SRP, defining USE_TLS_SRP cmake variable is apparently not enough
REM | We need to explicitly specify the USE_TLS_SRP compiler definition as well
set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DUSE_TLS_SRP

REM | curl(openssl)
if /i "%BUILD_SSL_BACKEND%" equ "OPENSSL" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DCMAKE_USE_OPENSSL=ON ^
		-DOPENSSL_ROOT_DIR="!BUILD_OUTDIR!/openssl" ^
		-DOPENSSL_CRYPTO_LIBRARY="!BUILD_OUTDIR!/openssl" ^
		-DUSE_TLS_SRP:BOOL=ON
	REM | ws2_32 library missing from mingw makefile...
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_C_STANDARD_LIBRARIES="-lws2_32"
)

REM | curl(winssl)
if /i "%BUILD_SSL_BACKEND%" equ "WINSSL" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_USE_WINSSL=ON
)

REM | curl(C_FLAGS)
if "!CMAKE_CURL_C_FLAGS!" neq "" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_C_FLAGS="!CMAKE_CURL_C_FLAGS!"

REM | Configure
if not exist curl\BUILD\CMakeCache.txt (
	cmake -G "%BUILD_CMAKE_GENERATOR%" -S curl -B curl\BUILD ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		!CMAKE_CURL_VARIABLES! ^
		!BUILD_CURL_CONFIGURE_EXTRA! ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS! !CMAKE_CURL_C_FLAGS!"
	if !errorlevel! neq 0 pause && exit /B !errorlevel!
)

REM | Build
cmake --build curl\BUILD --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | Collect
echo.
pushd curl\BUILD\lib
	for %%f in (*.dll *.lib *.a *.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd curl\BUILD\lib\CMakeFiles\libcurl.dir
	for %%f in (libcurl*.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
pushd curl\BUILD\src
	for %%f in (*.exe *.pdb) do del "%BUILD_OUTDIR%\%%~f" 2> NUL & mklink /H "%BUILD_OUTDIR%\%%~f" "%%~f"
popd
:CURL_END

:: curl-ca-bundle.crt
if /i "%BUILD_SSL_BACKEND%" neq "WINSSL" mklink /H "%BUILD_OUTDIR%\curl-ca-bundle.crt" "%ROOTDIR%\curl-ca-bundle.crt" || pause && exit /B %errorlevel%

:: _test_curl.bat
set testfile=%BUILD_OUTDIR%\_test_curl.bat
echo "%%~dp0\curl.exe" -L -v -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%testfile%"
echo "%%~dp0\curl.exe" -V>> "%testfile%"
echo pause>> "%testfile%"

echo **********************************************************
echo  The End
echo **********************************************************

REM pause
