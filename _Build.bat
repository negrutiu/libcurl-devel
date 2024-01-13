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
if not exist "%VCVARSALL%" for /f "tokens=1* delims=: " %%i in ('"%VSWHERE%" -version 16 -requires Microsoft.Component.MSBuild 2^> NUL') do if /i "%%i"=="installationPath" set VCVARSALL=%%j\VC\Auxiliary\Build\VCVarsAll.bat&& set BUILD_PLATFORMTOOLSET=v142
if not exist "%VCVARSALL%" for /f "tokens=1* delims=: " %%i in ('"%VSWHERE%" -version 15 -requires Microsoft.Component.MSBuild 2^> NUL') do if /i "%%i"=="installationPath" set VCVARSALL=%%j\VC\Auxiliary\Build\VCVarsAll.bat&& set BUILD_PLATFORMTOOLSET=v141
if not exist "%VCVARSALL%" echo ERROR: Missing "%VCVARSALL%" && pause && exit /B 1

REM | NASM (required since OpenSSL 1.0.2)
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

REM | Start time
for /f "delims=*" %%t in ('powershell -Command "(Get-Date).ToString()"') do set BUILD_T0=%%t
echo [%BUILDER% %CONFIG%] Time: %BUILD_T0%


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
echo [%BUILDER% %CONFIG%] Starting libraries . . .
:WAIT_4LIBS_2START
	if not exist "bin\build-running-%BUILDER%*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_4LIBS_2START

REM | Wait for build-running-*.flag to go away
echo [%BUILDER% %CONFIG%] Building libraries . . .
:WAIT_4LIBS_2FINISH
	if exist "bin\build-running-%BUILDER%*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_4LIBS_2FINISH

REM | Abort on build errors
if exist "bin\build-error-%BUILDER%*%CONFIG%*.flag" exit /B 1

REM | Intermediate time
for /f "delims=*" %%t in ('powershell -Command "(Get-Date).ToString()"') do set BUILD_T1=%%t
for /f "usebackq delims=*" %%t in (`powershell -Command "(New-TimeSpan -Start '%BUILD_T0%' -End '%BUILD_T1%').ToString()"`) do set BUILD_DT=%%t
echo [%BUILDER% %CONFIG%] Time: %BUILD_T1% ( +%BUILD_DT% )


REM =============================================
:PARALLEL_CURL_OPENSSL
REM =============================================

REM | NOTES:
REM | > We use -D_UNISTD_H to counter the effect of curl commit 474a947e, 11 Oct 2022, "cmake: enable more detection on Windows"
REM |   We prevent "unistd.h" from being used because it defines ftruncate(..) which relies on FindFirstVolume/FindNextVolume/GetFileSizeEx => unavailable in NT4

set ARCH=Win32
if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-Legacy ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_C_FLAGS="-march=pentium2 -U_WIN32_WINNT -D_WIN32_WINNT=0x0400 -D_UNISTD_H" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON -DMAKE_USE_OPENLDAP=OFF -DENABLE_INET_PTON=OFF"

set ARCH=x64
if /i "%BUILDER%" equ "mingw" start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-Legacy ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%-Legacy" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_C_FLAGS="-march=x86-64 -U_WIN32_WINNT -D_WIN32_WINNT=0x0502 -D_UNISTD_H" ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON -DMAKE_USE_OPENLDAP=OFF -DENABLE_INET_PTON=OFF"

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH% ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH% ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-HTTP_ONLY ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-HTTP_ONLY ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-Shared ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=shared ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=shared ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_openssl-%CONFIG%-%ARCH%-Shared ^
	BUILD_SSL_BACKEND=OPENSSL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=shared ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=shared ^
	BUILD_OPENSSL_DIR="%~dp0\bin\%BUILDER%-openssl-%CONFIG%-%ARCH%" ^
	BUILD_OPENSSL_LNK=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""


REM =============================================
:PARALLEL_CURL_SCHANNEL
REM =============================================

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH% ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH% ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH%-Shared ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=shared ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH%-Shared ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=shared ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=shared ^
	BUILD_CURL_CONFIGURE_EXTRA=""

set ARCH=Win32
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH%-HTTP_ONLY ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"

set ARCH=x64
start "" %COMSPEC% /C call "%~f0" /build ^
	BUILD_CURL=1 ^
	BUILD_ARCH=%ARCH% ^
	BUILD_OUTDIR=%~dp0\bin\%BUILDER%-curl_schannel-%CONFIG%-%ARCH%-HTTP_ONLY ^
	BUILD_SSL_BACKEND=SCHANNEL ^
	BUILD_ZLIB_DIR="%~dp0\bin\%BUILDER%-zlib-%CONFIG%-%ARCH%" ^
	BUILD_ZLIB_LNK=static ^
	BUILD_NGHTTP2_DIR="%~dp0\bin\%BUILDER%-nghttp2-%CONFIG%-%ARCH%" ^
	BUILD_NGHTTP2_LNK=static ^
	BUILD_CURL_CONFIGURE_EXTRA="-DHTTP_ONLY=ON"


REM | Wait for build-running-*.flag to appear
echo [%BUILDER% %CONFIG%] Starting curl . . .
:WAIT_4CURL_2START
	if not exist "bin\build-running-%BUILDER%-curl*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_4CURL_2START

REM | Wait for build-running-*.flag to go away
echo [%BUILDER% %CONFIG%] Building curl . . .
:WAIT_4CURL_2FINISH
	if exist "bin\build-running-%BUILDER%-curl*%CONFIG%*.flag" ping.exe -n 2 127.0.0.1 > NUL && goto :WAIT_4CURL_2FINISH

REM | End time
for /f "delims=*" %%t in ('powershell -Command "(Get-Date).ToString()"') do set BUILD_T1=%%t
for /f "usebackq delims=*" %%t in (`powershell -Command "(New-TimeSpan -Start '%BUILD_T0%' -End '%BUILD_T1%').ToString()"`) do set BUILD_DT=%%t
echo [%BUILDER% %CONFIG%] Time: %BUILD_T1% ( +%BUILD_DT% )

REM echo.
REM pause
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
	echo set %~1=%~2
	set %~1=%~2
	shift & shift
	goto :loop_params
:loop_params_end
echo(

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

if /i "%BUILDER%" equ "mingw" if /i "%CONFIG%" equ "Debug" set BUILD_C_FLAGS=!BUILD_C_FLAGS! -Og
if /i "%BUILDER%" equ "mingw" if /i "%CONFIG%" equ "Release" set BUILD_C_FLAGS=!BUILD_C_FLAGS! -O3

REM | Prevent mingw builds from linking to libgcc_*.dll
if /i "%BUILDER%" equ "mingw" set BUILD_C_FLAGS=!BUILD_C_FLAGS! -static-libgcc


if "%BUILD_ZLIB%" equ "1" goto :BUILD_ZLIB
if "%BUILD_NGHTTP2%" equ "1" goto :BUILD_NGHTTP2
if "%BUILD_OPENSSL%" equ "1" goto :BUILD_OPENSSL
if "%BUILD_CURL%" equ "1" goto :BUILD_CURL

echo ERROR: Unknown build request
pause
exit /B 2


:BUILD_ZLIB
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-zlib

REM | Configure
REM | Starting with zlib/1.3 the library always builds with /MD[d]
REM | We've customized CMakeLists.txt to internally set MSVC_RUNTIME_LIBRARY based on `CRT`
if not exist .build\BUILD\CMakeCache.txt (
	cmake -G "%BUILD_CMAKE_GENERATOR%" -S "%ROOTDIR%\zlib" -B .build ^
        -DCRT=%CRT% ^
		-DCMAKE_VERBOSE_MAKEFILE=%VERBOSE% ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		-DCMAKE_INSTALL_PREFIX="%BUILD_OUTDIR%" ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS!"
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

REM | Build
cmake --build .build --config %CONFIG% --target zlibstatic zlib install
if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666

REM | Collect extra
call :make_link /H bin\zlib.pdb .build\zlib.pdb
call :make_link /H lib\zlibstatic.pdb .build\CMakeFiles\zlibstatic.dir\zlibstatic.pdb

del /Q "%FLAG_RUNNING%"
exit /B


:BUILD_NGHTTP2
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-nghttp2

REM xcopy "%ROOTDIR%\nghttp2" .build /QEIYD

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

	cmake -G "%BUILD_CMAKE_GENERATOR%" -S "%ROOTDIR%\nghttp2" -B .build ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		!CMAKE_NGHTTP2_VARIABLES! ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS!"
		
    if /i "%BUILDER%,%CRT%" equ "MSVC,static" powershell -Command "(gc .build\CMakeCache.txt) -replace '/MDd', '/MTd' | Out-File -encoding ASCII .build\CMakeCache.txt"
    if /i "%BUILDER%,%CRT%" equ "MSVC,static" powershell -Command "(gc .build\CMakeCache.txt) -replace '/MD', '/MT' | Out-File -encoding ASCII .build\CMakeCache.txt"

	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

REM | Build
cmake --build .build --config %CONFIG% --target nghttp2_static nghttp2 install
if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666

REM | Collect extra
call :make_link /H bin\nghttp2.pdb .build\lib\nghttp2.pdb
call :make_link /H lib\nghttp2_static.pdb .build\lib\CMakeFiles\nghttp2_static.dir\nghttp2_static.pdb

del /Q "%FLAG_RUNNING%"
exit /B


:BUILD_OPENSSL
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
	perl Configure !BUILD_OPENSSL_PARAMS! CFLAGS="!BUILD_C_FLAGS!" !BUILD_OPENSSL_CONFIGURE_EXTRA!
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

if /i "%BUILDER%,%CRT%" equ "MSVC,static" (
	REM | By default openssl links to shared CRT library
	REM | openssl doesn't expose any variable to control the CRT linkage, therefore we'll do some replacing in files...
	echo Configure static CRT...
	powershell -Command "(gc makefile) -replace '/MDd', '/MTd' | Out-File -encoding ASCII makefile"
	powershell -Command "(gc makefile) -replace '/MD',  '/MT'  | Out-File -encoding ASCII makefile"
)

REM | Make
if /i "%BUILDER%" equ "MSVC" (
	nmake.exe
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)
if /i "%BUILDER%" equ "mingw" (
	mingw32-make.exe
	if !errorlevel! neq 0 echo errorlevel=%errorlevel% && move /Y "%FLAG_RUNNING%" "%FLAG_ERROR%" && pause && exit /B 666
)

popd

REM | Collect
REM | We try to emulate what 'make install' does
REM | Unfortunately openssl 'make install' always overwrites existing files (*.h *.lib *.a *.exe) causing 'curl' to always recompile later on
call :make_link /J include .build\include
mkdir bin > NUL 2> NUL
mkdir lib > NUL 2> NUL

pushd .build
	for %%f in (lib*.dll lib*.pdb) do call :make_link /H "%BUILD_OUTDIR%\bin\%%~f" "%%~f"
	for %%f in (lib*.lib lib*.a) do call :make_link /H "%BUILD_OUTDIR%\lib\%%~f" "%%~f"
popd
pushd .build\apps
	for %%f in (openssl.exe openssl.pdb.skip) do call :make_link /H "%BUILD_OUTDIR%\bin\%%~f" "%%~f"
popd
if exist .build\ossl_static.pdb call :make_link /H lib\ossl_static.pdb .build\ossl_static.pdb

del /Q "%FLAG_RUNNING%"
exit /B


:BUILD_CURL
set FLAG_RUNNING=%BUILD_OUTDIR%\..\build-running-%DIRNAME%.flag
set FLAG_ERROR=%BUILD_OUTDIR%\..\build-error-%DIRNAME%.flag
echo todo> "%FLAG_RUNNING%"

title %DIRNAME%-libcurl

REM | Parameter validation
echo _%BUILD_SSL_BACKEND%_| findstr /I /B /E "_openssl_ _schannel_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_SSL_BACKEND=%BUILD_SSL_BACKEND%. Use BUILD_SSL_BACKEND=OPENSSL^|SCHANNEL && pause && exit /B 57

if "%BUILD_ZLIB_DIR%" neq "" (
	if not exist "%BUILD_ZLIB_DIR%" echo ERROR: Not found BUILD_ZLIB_DIR=%BUILD_ZLIB_DIR% && pause && exit /B 57
)

echo _%BUILD_ZLIB_LNK%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_ZLIB_LNK=%BUILD_ZLIB_LNK%. Use BUILD_ZLIB_LNK=static^|shared && pause && exit /B 57

if "%BUILD_NGHTTP2_DIR%" neq "" (
	if not exist "%BUILD_NGHTTP2_DIR%" echo ERROR: Not found BUILD_NGHTTP2_DIR=%BUILD_NGHTTP2_DIR% && pause && exit /B 57
)

echo _%BUILD_NGHTTP2_LNK%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_NGHTTP2_LNK=%BUILD_NGHTTP2_LNK%. Use BUILD_NGHTTP2_LNK=static^|shared && pause && exit /B 57

if "%BUILD_OPENSSL_DIR%" neq "" (
	if not exist "%BUILD_OPENSSL_DIR%" echo ERROR: Not found BUILD_OPENSSL_DIR=%BUILD_OPENSSL_DIR% && pause && exit /B 57
)

echo _%BUILD_OPENSSL_LNK%_| findstr /I /B /E "__ _static_ _shared_" > NUL 2> NUL
if %errorlevel% neq 0 echo ERROR: Invalid BUILD_OPENSSL_LNK=%BUILD_OPENSSL_LNK%. Use BUILD_OPENSSL_LNK=static^|shared && pause && exit /B 57


REM | curl(*)
set CMAKE_CURL_C_FLAGS=
set CMAKE_CURL_VARIABLES=

set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
	-DCMAKE_VERBOSE_MAKEFILE=%VERBOSE% ^
	-DBUILD_TESTING=OFF

if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DENABLE_CURLDEBUG=ON -DENABLE_DEBUG=ON -DCMAKE_DEBUG_POSTFIX:STRING=""

REM | CURL requires valid CURL_TARGET_WINDOWS_VERSION
REM | https://github.com/curl/curl/issues/9406
for /f "usebackq delims=*" %%s in (`powershell -ExecutionPolicy bypass -Command "if ('!BUILD_C_FLAGS!' -match '-D_WIN32_WINNT=(?<hexver>0x[0-9a-fA-F]+)') { $Matches.hexver }"`) do set CURL_TARGET_WINDOWS_VERSION=%%s
if "%CURL_TARGET_WINDOWS_VERSION%" equ "" set CURL_TARGET_WINDOWS_VERSION=0x0601
set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_TARGET_WINDOWS_VERSION=%CURL_TARGET_WINDOWS_VERSION%

REM | curl(static CRT)
if /i "%BUILDER%" equ "MSVC" (
	if /i "%CRT%" equ "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=ON
	if /i "%CRT%" neq "static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_STATIC_CRT=OFF
)

REM | curl(libssh2)
set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_USE_LIBSSH2=OFF

REM | curl(zlib)
if "%BUILD_ZLIB_LNK%" equ "" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=OFF
) else (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_ZLIB=ON -DZLIB_INCLUDE_DIR="%BUILD_ZLIB_DIR%\include"
)
if /i "%BUILDER%,%BUILD_ZLIB_LNK%" equ "MSVC,static" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG="%BUILD_ZLIB_DIR%\lib\zlibstatic.lib"
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE="%BUILD_ZLIB_DIR%\lib\zlibstatic.lib"
)
if /i "%BUILDER%,%BUILD_ZLIB_LNK%" equ "MSVC,shared" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG="%BUILD_ZLIB_DIR%\lib\zlib.lib"
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE="%BUILD_ZLIB_DIR%\lib\zlib.lib"
)
if /i "%BUILDER%,%BUILD_ZLIB_LNK%" equ "mingw,static" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG="%BUILD_ZLIB_DIR%\lib\libzlibstatic.a"
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE="%BUILD_ZLIB_DIR%\lib\libzlibstatic.a"
)
if /i "%BUILDER%,%BUILD_ZLIB_LNK%" equ "mingw,shared" (
	if /i "%CONFIG%" equ "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_DEBUG="%BUILD_ZLIB_DIR%\lib\libzlib.dll.a"
	if /i "%CONFIG%" neq "Debug" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DZLIB_LIBRARY_RELEASE="%BUILD_ZLIB_DIR%\lib\libzlib.dll.a"
)

REM | curl(nghttp2)
if "%BUILD_NGHTTP2_LNK%" equ "" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=OFF
)
if /i "%BUILD_NGHTTP2_LNK%" equ "static" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR="%BUILD_NGHTTP2_DIR%\include"
	if /i "%BUILDER%" equ "MSVC"  set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY="%BUILD_NGHTTP2_DIR%\lib\nghttp2_static.lib"
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY="%BUILD_NGHTTP2_DIR%\lib\libnghttp2_static.a"
	REM | Hack: NGHTTP2_STATICLIB preprocessor definition must exist for curl to link statically to nghttp2
	set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DNGHTTP2_STATICLIB -DUSE_NGHTTP2
)
if /i "%BUILD_NGHTTP2_LNK%" equ "shared" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DUSE_NGHTTP2=ON -DNGHTTP2_INCLUDE_DIR="%BUILD_NGHTTP2_DIR%\include"
	if /i "%BUILDER%" equ "MSVC"  set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY="%BUILD_NGHTTP2_DIR%\lib\nghttp2.lib"
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DNGHTTP2_LIBRARY="%BUILD_NGHTTP2_DIR%\lib\libnghttp2.dll.a"
	set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DUSE_NGHTTP2
)

REM | Force use of ALPN (to activate HTTP2 /w SChannel)
if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DHAS_ALPN

REM | To activate TLS-SRP, defining USE_TLS_SRP cmake variable is apparently not enough
REM | We need to explicitly specify the USE_TLS_SRP compiler definition as well
set CMAKE_CURL_C_FLAGS=!CMAKE_CURL_C_FLAGS! -DUSE_TLS_SRP

REM | curl(openssl)
if /i "%BUILD_SSL_BACKEND%" equ "OPENSSL" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DCURL_USE_OPENSSL=ON ^
		-DOPENSSL_ROOT_DIR:PATH="%BUILD_OPENSSL_DIR%" ^
		-DUSE_TLS_SRP:BOOL=ON
	REM | OpenSSL linkage
	if "%BUILDER%,%BUILD_OPENSSL_LNK%" equ "mingw,static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DLIB_EAY="%BUILD_OPENSSL_DIR%\lib\libcrypto.a" ^
		-DSSL_EAY="%BUILD_OPENSSL_DIR%\lib\libssl.a"
	if "%BUILDER%,%BUILD_OPENSSL_LNK%" equ "mingw,shared" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DLIB_EAY="%BUILD_OPENSSL_DIR%\lib\libcrypto.dll.a" ^
		-DSSL_EAY="%BUILD_OPENSSL_DIR%\lib\libssl.dll.a"
	if "%BUILDER%,%BUILD_OPENSSL_LNK%" equ "MSVC,static" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DLIB_EAY="%BUILD_OPENSSL_DIR%\lib\libcrypto_static.lib" ^
		-DSSL_EAY="%BUILD_OPENSSL_DIR%\lib\libssl_static.lib"
	if "%BUILDER%,%BUILD_OPENSSL_LNK%" equ "MSVC,shared" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DLIB_EAY="%BUILD_OPENSSL_DIR%\lib\libcrypto.lib" ^
		-DSSL_EAY="%BUILD_OPENSSL_DIR%\lib\libssl.lib"
	REM | ws2_32 library missing from mingw makefile...
	if /i "%BUILDER%" equ "mingw" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! ^
		-DCMAKE_C_STANDARD_LIBRARIES="-lws2_32"
)

REM | curl(schannel)
if /i "%BUILD_SSL_BACKEND%" equ "SCHANNEL" (
	set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCURL_USE_SCHANNEL=ON
)

REM | curl(C_FLAGS)
if "!CMAKE_CURL_C_FLAGS!" neq "" set CMAKE_CURL_VARIABLES=!CMAKE_CURL_VARIABLES! -DCMAKE_C_FLAGS="!CMAKE_CURL_C_FLAGS!"


REM | Configure (shared)
title %DIRNAME%-libcurl (shared)
if not exist .shared\CMakeCache.txt (
	cmake -G "%BUILD_CMAKE_GENERATOR%" -S "%ROOTDIR%\curl" -B .shared ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		-DBUILD_SHARED_LIBS=ON ^
		!CMAKE_CURL_VARIABLES! ^
		!BUILD_CURL_CONFIGURE_EXTRA! ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS! !CMAKE_CURL_C_FLAGS!"
	if !errorlevel! neq 0 pause && exit /B !errorlevel!
)

REM | Build (shared)
cmake --build .shared --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | Collect (shared)
REM cmake --build .shared --config %CONFIG% --target install
REM if %errorlevel% neq 0 pause && exit /B %errorlevel%

mkdir bin > NUL 2> NUL
mkdir include > NUL 2> NUL
mkdir lib > NUL 2> NUL
call :make_link /J include\curl "%ROOTDIR%\curl\include\curl"

call :make_link /H bin\libcurl.exe .shared\src\curl.exe
REM call :make_link /H bin\libcurl.exe.pdb .shared\src\curl.pdb
call :make_link /H bin\libcurl.dll .shared\lib\libcurl.dll
call :make_link /H bin\libcurl.pdb .shared\lib\libcurl.pdb
if "%BUILDER%" equ "MSVC" call :make_link /H lib\libcurl.dll.lib .shared\lib\libcurl_imp.lib
if "%BUILDER%" neq "MSVC" call :make_link /H lib\libcurl.dll.a   .shared\lib\libcurl_imp.lib

REM | Configure (static)
title %DIRNAME%-libcurl (static)
if not exist .static\CMakeCache.txt (
	cmake -G "%BUILD_CMAKE_GENERATOR%" -S "%ROOTDIR%\curl" -B .static ^
		-DCMAKE_BUILD_TYPE=%CONFIG% ^
		-DBUILD_SHARED_LIBS=OFF ^
		!CMAKE_CURL_VARIABLES! ^
		!BUILD_CURL_CONFIGURE_EXTRA! ^
		-DCMAKE_C_FLAGS="!BUILD_C_FLAGS! !CMAKE_CURL_C_FLAGS!"
	if !errorlevel! neq 0 pause && exit /B !errorlevel!
)

REM | Build (static)
cmake --build .static --config %CONFIG%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

REM | Collect (static)
REM cmake --build .static --config %CONFIG% --target install
REM if %errorlevel% neq 0 pause && exit /B %errorlevel%

call :make_link /H bin\curl.exe .static\src\curl.exe
REM call :make_link /H bin\curl.pdb .static\src\curl.pdb
if /i "%BUILDER%" equ "MSVC" call :make_link /H lib\libcurl.lib .static\lib\libcurl.lib
if /i "%BUILDER%" equ "MSVC" call :make_link /H lib\libcurl.pdb .static\lib\CMakeFiles\libcurl.dir\libcurl.pdb
if /i "%BUILDER%" neq "MSVC" call :make_link /H lib\libcurl.a   .static\lib\libcurl.a

REM | Collect libraries
if "%BUILD_ZLIB_DIR%" neq "" for %%f in ("%BUILD_ZLIB_DIR%\bin\*.*")    do call :make_link /H "bin\%%~nxf" "%%~ff"
if "%BUILD_ZLIB_DIR%" neq "" for %%f in ("%BUILD_ZLIB_DIR%\lib\*.*")    do call :make_link /H "lib\%%~nxf" "%%~ff"
if "%BUILD_ZLIB_DIR%" neq "" call :make_link /J "include\zlib" "%BUILD_ZLIB_DIR%\include"

if "%BUILD_NGHTTP2_DIR%" neq "" for %%f in ("%BUILD_NGHTTP2_DIR%\bin\*.*") do call :make_link /H "bin\%%~nxf" "%%~ff"
if "%BUILD_NGHTTP2_DIR%" neq "" for %%f in ("%BUILD_NGHTTP2_DIR%\lib\*.*") do call :make_link /H "lib\%%~nxf" "%%~ff"
if "%BUILD_NGHTTP2_DIR%" neq "" call :make_link /J "include\nghttp2" "%BUILD_NGHTTP2_DIR%\include\nghttp2"

if "%BUILD_OPENSSL_DIR%" neq "" for %%f in ("%BUILD_OPENSSL_DIR%\bin\*.*") do call :make_link /H "bin\%%~nxf" "%%~ff"
if "%BUILD_OPENSSL_DIR%" neq "" for %%f in ("%BUILD_OPENSSL_DIR%\lib\*.*") do call :make_link /H "lib\%%~nxf" "%%~ff"
if "%BUILD_OPENSSL_DIR%" neq "" call :make_link /J "include\openssl" "%BUILD_OPENSSL_DIR%\include\openssl

:: curl-ca-bundle.crt
if /i "%BUILD_SSL_BACKEND%" neq "SCHANNEL" call :make_link /H "%BUILD_OUTDIR%\bin\curl-ca-bundle.crt" "%ROOTDIR%\curl-ca-bundle.crt" || pause && exit /B %errorlevel%

:: _test_curl.bat
set testfile=%BUILD_OUTDIR%\bin\_test_curl.bat
echo "%%~dp0\curl.exe" -L -v -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%testfile%"
echo "%%~dp0\curl.exe" -V>> "%testfile%"
echo pause>> "%testfile%"

:: _test_libcurl.bat
set testfile=%BUILD_OUTDIR%\bin\_test_libcurl.bat
echo "%%~dp0\libcurl.exe" -L -v -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%testfile%"
echo "%%~dp0\libcurl.exe" -V>> "%testfile%"
echo pause>> "%testfile%"

del /Q "%FLAG_RUNNING%"
exit /B


REM | make_link /J|/H <Link> <Target>
:make_link
REM | NOTE: We need to remove & recreate existing hardlinks because *if* the previous target got deleted & recreated the existing link retains the old content
if /i "%~1" equ "/H" if exist "%~2" echo del /Q "%~2" && del /Q "%~2" || pause
if /i "%~1" equ "/J" if exist "%~2" echo rd /Q "%~2"  && rd /Q "%~2"  || pause
if not exist "%~3" exit /B 2
mklink %1 "%~2" "%~3" || pause
exit /B %errorlevel%
