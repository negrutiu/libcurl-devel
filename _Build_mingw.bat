@echo off
setlocal EnableDelayedExpansion

set MINGW=C:\TDM-GCC-64
if not exist "%MINGW%\mingwvars.bat" echo ERROR: "%MINGW%\mingwvars.bat" not found && pause && goto :EOF
if not exist "%MINGW%\bin\mingw32-make.exe" echo ERROR: "%MINGW%\bin\mingw32-make.exe" not found && pause && goto :EOF
call "%MINGW%\mingwvars.bat"


:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
if /I "%1" equ "/build-x86" (
	set BUILD_OUTDIR=%~dp0\Release-mingw-mbedTLS-Win32
	set BUILD_ARCH=X86
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	goto :BUILD
)

if /I "%1" equ "/build-x64" (
	set BUILD_OUTDIR=%~dp0\Release-mingw-mbedTLS-x64
	set BUILD_ARCH=X64
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	goto :BUILD
)

if /I "%1" equ "/build-x86-mbedtls_dll" (
	set BUILD_OUTDIR=%~dp0\Release-mingw-mbedTLS_dll-Win32
	set BUILD_ARCH=X86
	set BUILD_MBEDTLS_DLL=1
	set BUILD_LIBCURL_DLL=1
	goto :BUILD
)

if /I "%1" equ "/build-x64-mbedtls_dll" (
	set BUILD_OUTDIR=%~dp0\Release-mingw-mbedTLS_dll-x64
	set BUILD_ARCH=X64
	set BUILD_MBEDTLS_DLL=1
	set BUILD_LIBCURL_DLL=1
	goto :BUILD
)

:: Re-launch this script to build multiple targets in parallel
start "mingw32" "%COMSPEC%" /C "%~f0" /build-x86
start "mingw64" "%COMSPEC%" /C "%~f0" /build-x64
::start "mingw32 (mbedtls_dll)" "%COMSPEC%" /C "%~f0" /build-x86-mbedtls_dll
::start "mingw64 (mbedtls_dll)" "%COMSPEC%" /C "%~f0" /build-x64-mbedtls_dll
goto :EOF


:: ----------------------------------------------------------------
:BUILD
:: ----------------------------------------------------------------

if not exist "%BUILD_OUTDIR%" mkdir "%BUILD_OUTDIR%"

:: Duplicate the relevant sources so we can build in parallel
cd /d "%~dp0"

xcopy "zlib" "%BUILD_OUTDIR%\zlib" /EIYD
xcopy "nghttp2\lib" "%BUILD_OUTDIR%\nghttp2\lib" /EIYD

xcopy "mbedTLS\*.*" "%BUILD_OUTDIR%\mbedTLS" /IYD
xcopy "mbedTLS\include" "%BUILD_OUTDIR%\mbedTLS\include" /EIYD
xcopy "mbedTLS\library" "%BUILD_OUTDIR%\mbedTLS\library" /EIYD

xcopy "cURL\*.*" "%BUILD_OUTDIR%\cURL" /IYD
xcopy "cURL\include" "%BUILD_OUTDIR%\cURL\include" /EIYD
xcopy "cURL\lib" "%BUILD_OUTDIR%\cURL\lib" /EIYD

xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src" /EIYD


if exist cacert.pem xcopy cacert.pem "%BUILD_OUTDIR%" /FIYD

set NGHTTP2_CFLAGS=-DNGHTTP2_STATICLIB
::set MBEDTLS_CFLAGS=-DMBEDTLS_CONFIG_FILE='^<%~dp0libmbedtls.config.h^>'
set CURL_CFLAGS=-DUSE_MBEDTLS -Dhave_curlssl_ca_path -I../../mbedTLS/include
::set CURL_CFLAGS=!CURL_CFLAGS! -DHTTP_ONLY

if /I "%BUILD_ARCH%" equ "x64" (
	set GLOBAL_CFLAGS=-m64 -mmmx -msse -msse2 -DWIN32 -D_WIN32_WINNT=0x0502
	set GLOBAL_LFLAGS=-m64 -s -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base
	set GLOBAL_RFLAGS=-F pe-x86-64
	set MBEDTLS_CFLAGS=!MBEDTLS_CFLAGS! -DMBEDTLS_HAVE_SSE2
) else (
	set GLOBAL_CFLAGS=-m32 -mtune=i386 -march=i386 -DWIN32 -D_WIN32_WINNT=0x0400
	set GLOBAL_LFLAGS=-m32 -s -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base
	set GLOBAL_RFLAGS=-F pe-i386
)


:ZLIB
echo.
echo -----------------------------------
echo  zlib
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-zlib
cd /d "%BUILD_OUTDIR%\zlib"

set MYCFLAGS=%GLOBAL_CFLAGS%
set MYLDFLAGS=%GLOBAL_LFLAGS%
set MYRCFLAGS=%GLOBAL_RFLAGS%
mingw32-make -f win32/Makefile.gcc libz.a
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF


:NGHTTP2
echo.
echo -----------------------------------
echo  nghttp2
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-nghttp2
cd /d "%BUILD_OUTDIR%\nghttp2"
if not exist "include" mklink /J "include" "lib\includes"

cd lib
set MYCFLAGS=%GLOBAL_CFLAGS% %NGHTTP2_CFLAGS%
set MYLFLAGS=%GLOBAL_LFLAGS%
mingw32-make static
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\nghttp2\lib\*.a" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\nghttp2\lib\*.o" > "%BUILD_OUTDIR%\asm-nghttp2.txt"


:MBEDTLS
echo.
echo -----------------------------------
echo  libmbedTLS
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-libmbedtls
cd /d "%BUILD_OUTDIR%\mbedTLS\library"

if %BUILD_MBEDTLS_DLL% equ 0 set SHARED=
if %BUILD_MBEDTLS_DLL% neq 0 set SHARED=1

mingw32-make ^
	WINDOWS=1 CC=gcc ^
	"CFLAGS=%GLOBAL_CFLAGS% %MBEDTLS_CFLAGS%" ^
	"LDFLAGS=%GLOBAL_LFLAGS%" ^
	all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.dll" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.a"   "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\mbedTLS\library\*.o" > "%BUILD_OUTDIR%\asm-mbedTLS.txt"


:LIBCURL
echo.
echo -----------------------------------
echo  libcurl
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-libcurl
cd /d "%BUILD_OUTDIR%\cURL\lib"

set ZLIB=1
set ZLIB_PATH=../../zlib

set NGHTTP2=1
set NGHTTP2_PATH=../../nghttp2

if %BUILD_LIBCURL_DLL% equ 0 set CFG=
if %BUILD_LIBCURL_DLL% neq 0 set CFG=-dyn

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS% %NGHTTP2_CFLAGS%
set CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS% -L../../mbedTLS/library
if %BUILD_MBEDTLS_DLL% equ 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls -lmbedx509 -lmbedcrypto -lws2_32
if %BUILD_MBEDTLS_DLL% neq 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls.dll -lmbedx509.dll -lmbedcrypto.dll

mingw32-make -f Makefile.m32 all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\cURL\lib\*.dll" "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\cURL\lib\*.a"   "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\lib\*.o" > "%BUILD_OUTDIR%\asm-cURL-lib.txt"


:CURL
echo.
echo -----------------------------------
echo  curl.exe
echo -----------------------------------
:: NOTE: Must build in ANSI code page
cd /d "%BUILD_OUTDIR%\cURL\src"

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS% %NGHTTP2_CFLAGS%
set CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS% -L../../mbedTLS/library
if %BUILD_MBEDTLS_DLL% equ 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls -lmbedx509 -lmbedcrypto -lws2_32
if %BUILD_MBEDTLS_DLL% neq 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls.dll -lmbedx509.dll -lmbedcrypto.dll

:: curl.exe (dynamic)
if "%BUILD_LIBCURL_DLL%" equ "1" (

	title mingw-%BUILD_ARCH%-libcurl.exe
	mingw32-make -f Makefile.m32 CFG=-dyn clean all
	echo.
	echo ERRORLEVEL = %ERRORLEVEL%
	if %ERRORLEVEL% neq 0 pause && goto :EOF

	echo.
	move /Y "%BUILD_OUTDIR%\cURL\src\curl.exe" "%BUILD_OUTDIR%\cURL\src\libcurl.exe"
	xcopy "%BUILD_OUTDIR%\cURL\src\*.exe" "%BUILD_OUTDIR%" /YF
	objdump -d -S "%BUILD_OUTDIR%\cURL\src\*.o" > "%BUILD_OUTDIR%\asm-libcURL-src.txt"

	mingw32-make -f Makefile.m32 clean
	echo -----------------------------------
)

:: curl.exe (static)
title mingw-%BUILD_ARCH%-curl.exe
::set CURL_LDFLAG_EXTRAS2=!CURL_LDFLAG_EXTRAS2! -Wl,--exclude-libs=ALL
mingw32-make -f Makefile.m32 CFG= all
echo.
echo ERRORLEVEL = %ERRORLEVEL%
if %ERRORLEVEL% neq 0 pause && goto :EOF

::Collect
echo.
xcopy "%BUILD_OUTDIR%\cURL\src\*.exe" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\src\*.o" > "%BUILD_OUTDIR%\asm-cURL-src.txt"
