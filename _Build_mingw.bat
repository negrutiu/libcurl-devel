@echo off
setlocal EnableDelayedExpansion

set MINGW=C:\TDM-GCC-64
if not exist "%MINGW%\mingwvars.bat" echo ERROR: "%MINGW%\mingwvars.bat" not found && pause && goto :EOF
if not exist "%MINGW%\bin\mingw32-make.exe" echo ERROR: "%MINGW%\bin\mingw32-make.exe" not found && pause && goto :EOF
call "%MINGW%\mingwvars.bat"


if /I "%1" equ "x86-libs" (
	set BUILD_OUTDIR=%~dp0\Release-Win32-mbedTLS
	set BUILD_ARCH=X86
	set BUILD_MBEDTLS_DLL=0
	set BUILD_CURL_DLL=0
	goto :BUILD
)

if /I "%1" equ "x64-libs" (
	set BUILD_OUTDIR=%~dp0\Release-x64-mbedTLS
	set BUILD_ARCH=X64
	set BUILD_MBEDTLS_DLL=0
	set BUILD_CURL_DLL=0
	goto :BUILD
)

if /I "%1" equ "x86-dlls" (
	set BUILD_OUTDIR=%~dp0\Release-Win32-mbedTLS-dll
	set BUILD_ARCH=X86
	set BUILD_MBEDTLS_DLL=1
	set BUILD_CURL_DLL=1
	goto :BUILD
)

if /I "%1" equ "x64-dlls" (
	set BUILD_OUTDIR=%~dp0\Release-x64-mbedTLS-dll
	set BUILD_ARCH=X64
	set BUILD_MBEDTLS_DLL=1
	set BUILD_CURL_DLL=1
	goto :BUILD
)

start "x86-libs" "%COMSPEC%" /C "%~f0" x86-libs
start "x64-libs" "%COMSPEC%" /C "%~f0" x64-libs
start "x86-dlls" "%COMSPEC%" /C "%~f0" x86-dlls
start "x64-dlls" "%COMSPEC%" /C "%~f0" x64-dlls
goto :EOF


:: ----------------------------------------------------------------
::  Build one platform
:: ----------------------------------------------------------------
:BUILD

if not exist "%BUILD_OUTDIR%" mkdir "%BUILD_OUTDIR%"

:: Duplicate the relevant sources so we can build in parallel
cd /d "%~dp0"

xcopy "mbedTLS\*.*" "%BUILD_OUTDIR%\mbedTLS" /IYD
xcopy "mbedTLS\include" "%BUILD_OUTDIR%\mbedTLS\include" /EIYD
xcopy "mbedTLS\library" "%BUILD_OUTDIR%\mbedTLS\library" /EIYD

xcopy "cURL\*.*" "%BUILD_OUTDIR%\cURL" /IYD
xcopy "cURL\include" "%BUILD_OUTDIR%\cURL\include" /EIYD
xcopy "cURL\lib" "%BUILD_OUTDIR%\cURL\lib" /EIYD
xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src" /EIYD

if exist cacert.pem xcopy cacert.pem "%BUILD_OUTDIR%" /FIYD


set MBEDTLS_CFLAGS=-DMBEDTLS_CONFIG_FILE='^<%~dp0libmbedtls.config.h^>'
set CURL_CFLAGS=-DHTTP_ONLY -DUSE_MBEDTLS -Dhave_curlssl_ca_path -I../../mbedTLS/include

if /I "%BUILD_ARCH%" equ "x64" (
	set GLOBAL_CFLAGS=-m64 -mmmx -msse -msse2 -D_WIN32_WINNT=0x0502
	set GLOBAL_LFLAGS=-m64 -s -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base
	set MBEDTLS_CFLAGS=!MBEDTLS_CFLAGS! -DMBEDTLS_HAVE_SSE2
) else (
	set GLOBAL_CFLAGS=-m32 -mtune=i386 -march=i386 -D_WIN32_WINNT=0x0400
	set GLOBAL_LFLAGS=-m32 -s -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base
)


:MBEDTLS
echo.
echo -----------------------------------
echo  libmbedTLS
echo -----------------------------------
:: NOTE: Must be built with ANSI code page
cd /d "%BUILD_OUTDIR%\mbedTLS\library"

if "%BUILD_MBEDTLS_DLL%" equ "1" set SHARED=1
if "%BUILD_MBEDTLS_DLL%" neq "1" set SHARED=

mingw32-make ^
	WINDOWS=1 CC=gcc ^
	"CFLAGS=%GLOBAL_CFLAGS% %MBEDTLS_CFLAGS%" ^
	"LDFLAGS=%GLOBAL_LFLAGS%" ^
	all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF


:LIBCURL
echo.
echo -----------------------------------
echo  libcurl
echo -----------------------------------
:: NOTE: Must be built with ANSI code page
cd /d "%BUILD_OUTDIR%\cURL\lib"

if "%BUILD_CURL_DLL%" equ "1" set CFG=-dyn
if "%BUILD_CURL_DLL%" neq "1" set CFG=

if /I "%BUILD_ARCH%" equ "x64" set ARCH=w64
if /I "%BUILD_ARCH%" neq "x64" set ARCH=w32

if "%BUILD_MBEDTLS_DLL%" equ "1" set CURL_LDFLAG_EXTRAS2=-L'%BUILD_OUTDIR%\mbedTLS\library' -lmbedtls.dll -lmbedx509.dll -lmbedcrypto.dll
if "%BUILD_MBEDTLS_DLL%" neq "1" set CURL_LDFLAG_EXTRAS2=-L'%BUILD_OUTDIR%\mbedTLS\library' -lmbedtls -lmbedx509 -lmbedcrypto -lws2_32

mingw32-make -f Makefile.m32 ^
	"CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS%" ^
	"CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS%" ^
	all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF


:CURL
echo.
echo -----------------------------------
echo  curl.exe
echo -----------------------------------
:: NOTE: Must be built with ANSI code page
cd /d "%BUILD_OUTDIR%\cURL\src"

if "%BUILD_CURL_DLL%" equ "1" set CFG=-dyn
if "%BUILD_CURL_DLL%" neq "1" set CFG=

if /I "%BUILD_ARCH%" equ "x64" set ARCH=w64
if /I "%BUILD_ARCH%" neq "x64" set ARCH=w32

if "%BUILD_MBEDTLS_DLL%" equ "1" set CURL_LDFLAG_EXTRAS2=-L'%BUILD_OUTDIR%\mbedTLS\library' -lmbedtls.dll -lmbedx509.dll -lmbedcrypto.dll
if "%BUILD_MBEDTLS_DLL%" neq "1" set CURL_LDFLAG_EXTRAS2=-L'%BUILD_OUTDIR%\mbedTLS\library' -lmbedtls -lmbedx509 -lmbedcrypto -lws2_32

mingw32-make -f Makefile.m32 ^
	"CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS%" ^
	"CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS%" ^
	all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF


:COLLECT
echo.
if "%BUILD_MBEDTLS_DLL%" equ "1" xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.dll" "%BUILD_OUTDIR%" /YF
if "%BUILD_CURL_DLL%"    equ "1" xcopy "%BUILD_OUTDIR%\cURL\lib\*.dll" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.a" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\cURL\lib\*.a" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\cURL\src\*.exe" "%BUILD_OUTDIR%" /YF

:: ObjDump
objdump -d -S "%BUILD_OUTDIR%\mbedTLS\library\*.o" > "%BUILD_OUTDIR%\asm-mbedTLS.txt"
objdump -d -S "%BUILD_OUTDIR%\cURL\lib\*.o"        > "%BUILD_OUTDIR%\asm-cURL-lib.txt"
objdump -d -S "%BUILD_OUTDIR%\cURL\src\*.o"        > "%BUILD_OUTDIR%\asm-cURL-src.txt"
