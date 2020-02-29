REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

if not exist "%PF32%" set PF32=%PROGRAMFILES(X86)%
if not exist "%PF32%" set PF32=%PROGRAMFILES%

if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS2
if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS64
if not exist "%MSYS2%" echo ERROR: Missing msys2/mingw && pause && exit /B 2

if not exist cacert.pem echo ERROR: Missing cacert.pem. Get it! && pause && exit /B 2


:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
:ARG_MBEDTLS
if /I "%1" equ "/build-mbedtls-x86" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS-Win32
	set BUILD_ARCH=X86
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	REM By default LDAP links to wldap32!ber_free, inexistent in NT4 (available starting with W2K)
	set CURL_CFLAGS=-DCURL_DISABLE_LDAP
	goto :BUILD
)

if /I "%1" equ "/build-mbedtls-x64" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS-x64
	set BUILD_ARCH=X64
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	goto :BUILD
)

if /I "%1" equ "/build-mbedtls-x86-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS-Win32-HTTP_ONLY
	set BUILD_ARCH=X86
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	goto :BUILD
)

if /I "%1" equ "/build-mbedtls-x64-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS-x64-HTTP_ONLY
	set BUILD_ARCH=X64
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	goto :BUILD
)

if /I "%1" equ "/build-mbedtls-x86-mbedtls_dll" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS_dll-Win32
	set BUILD_ARCH=X86
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	goto :BUILD
)

if /I "%1" equ "/build-mbedtls-x64-mbedtls_dll" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-mbedTLS_dll-x64
	set BUILD_ARCH=X64
	set BUILD_SSL_ENGINE=MBEDTLS
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	goto :BUILD
)

:ARG_WINSSL
if /I "%1" equ "/build-winssl-x86" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-WinSSL-Win32
	set BUILD_ARCH=X86
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DCURL_DISABLE_LDAP -DPROV_RSA_AES=24
	goto :BUILD
)

if /I "%1" equ "/build-winssl-x64" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-WinSSL-x64
	set BUILD_ARCH=X64
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	goto :BUILD
)

if /I "%1" equ "/build-winssl-x86-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-WinSSL-Win32-HTTP_ONLY
	set BUILD_ARCH=X86
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY -DPROV_RSA_AES=24
	goto :BUILD
)

if /I "%1" equ "/build-winssl-x64-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-WinSSL-x64-HTTP_ONLY
	set BUILD_ARCH=X64
	set BUILD_SSL_ENGINE=WINSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_MBEDTLS_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	goto :BUILD
)

:: Unknown argument?
if "%1" neq "" echo ERROR: Unknown argument "%1" && pause && exit /B

:: Re-launch this script to build multiple targets in parallel
start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x86
start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x64
start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x86-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x64-HTTP_ONLY
REM start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x86-mbedtls_dll
REM start "" "%COMSPEC%" /C "%~f0" /build-mbedtls-x64-mbedtls_dll
start "" "%COMSPEC%" /C "%~f0" /build-winssl-x86
start "" "%COMSPEC%" /C "%~f0" /build-winssl-x64
start "" "%COMSPEC%" /C "%~f0" /build-winssl-x86-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /build-winssl-x64-HTTP_ONLY
exit /B


:: ----------------------------------------------------------------
:BUILD
:: ----------------------------------------------------------------

if not exist "%BUILD_OUTDIR%" mkdir "%BUILD_OUTDIR%"

if /I "%BUILD_ARCH%" equ "x64" (
	set MINGW=%MSYS2%\mingw64
	set GLOBAL_CFLAGS=-march=x86-64 -s -Os -DWIN32 -D_WIN32_WINNT=0x0502 -DNDEBUG -O3
	set GLOBAL_LFLAGS=!GLOBAL_CFLAGS! -static-libgcc -static-libstdc++ -Wl,--gc-sections -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base -Wl,--enable-stdcall-fixup -Wl,--high-entropy-va
	set GLOBAL_RFLAGS=-F pe-x86-64
) else (
	set MINGW=%MSYS2%\mingw32
	set GLOBAL_CFLAGS=-march=pentium2 -s -Os -DWIN32 -D_WIN32_WINNT=0x0400 -DNDEBUG -O3
	set GLOBAL_LFLAGS=!GLOBAL_CFLAGS! -static-libgcc -static-libstdc++ -Wl,--gc-sections -Wl,--nxcompat -Wl,--dynamicbase -Wl,--enable-auto-image-base -Wl,--enable-stdcall-fixup
	set GLOBAL_RFLAGS=-F pe-i386
)
set CURL_CFG=
set CURL_LDFLAG_EXTRAS=
set CURL_LDFLAG_EXTRAS2=
set PATH=%MINGW%\bin;%MSYS2%\usr\bin;%PATH%


:ZLIB
if "%BUILD_USE_ZLIB%" lss "1" goto :ZLIB_END
echo.
echo -----------------------------------
echo  zlib
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-zlib

cd /d "%~dp0"
xcopy "zlib" "%BUILD_OUTDIR%\zlib" /QEIYD
cd /d "%BUILD_OUTDIR%\zlib"

set LOC=%GLOBAL_CFLAGS% %GLOBAL_LFLAGS%
mingw32-make -f win32/Makefile.gcc libz.a
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\zlib\*.a" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\zlib\*.o" > "%BUILD_OUTDIR%\asm-zlib.txt"

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
title mingw-%BUILD_ARCH%-nghttp2

cd /d "%~dp0"
xcopy "nghttp2\lib" "%BUILD_OUTDIR%\nghttp2\lib" /QEIYD
cd /d "%BUILD_OUTDIR%\nghttp2"
rd "include" > NUL 2> NUL
mklink /J "include" "lib\includes"
cd lib

set NGHTTP2_CFLAGS=-DNGHTTP2_STATICLIB
set MYCFLAGS=%GLOBAL_CFLAGS% %NGHTTP2_CFLAGS%
set MYLFLAGS=%GLOBAL_LFLAGS%
mingw32-make static
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\nghttp2\lib\*.a" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\nghttp2\lib\*.o" > "%BUILD_OUTDIR%\asm-nghttp2.txt"

:: Build libcurl with nghttp2 support
set NGHTTP2=1
set NGHTTP2_PATH=../../nghttp2
:NGHTTP2_END


:MBEDTLS
if /i "%BUILD_SSL_ENGINE%" neq "MBEDTLS" goto :MBEDTLS_END
echo.
echo -----------------------------------
echo  libmbedTLS
echo -----------------------------------
:: NOTE: Must build in ANSI code page
title mingw-%BUILD_ARCH%-libmbedtls

cd /d "%~dp0"
xcopy "mbedTLS\*.*" "%BUILD_OUTDIR%\mbedTLS" /QEIYD
cd /d "%BUILD_OUTDIR%\mbedTLS"

:: MD4 is required by curl_ntlm_core.c (Marius)
set MBEDTLS_CFLAGS=!MBEDTLS_CFLAGS! -DMBEDTLS_MD4_C
if /I "%BUILD_ARCH%" equ "x64" set MBEDTLS_CFLAGS=!MBEDTLS_CFLAGS! -DMBEDTLS_HAVE_SSE2

if %BUILD_MBEDTLS_DLL% equ 0 set SHARED=
if %BUILD_MBEDTLS_DLL% neq 0 set SHARED=1

mingw32-make WINDOWS=1 CC=gcc "CFLAGS=%GLOBAL_CFLAGS% %MBEDTLS_CFLAGS%" "LDFLAGS=%GLOBAL_LFLAGS%" lib
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.dll"         "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\mbedTLS\library\*.a"           "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\mbedTLS\crypto\library\*.dll"  "%BUILD_OUTDIR%" /YF
xcopy "%BUILD_OUTDIR%\mbedTLS\crypto\library\*.a"    "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\mbedTLS\library\*.o" > "%BUILD_OUTDIR%\asm-mbedTLS.txt"

:: Build libcurl with libmbedtls
set CURL_CFLAGS=!CURL_CFLAGS! -DUSE_MBEDTLS -DUSE_TLS_SRP -I../../mbedTLS/include -I../../mbedTLS/crypto/include
set CURL_LDFLAG_EXTRAS=!CURL_LDFLAG_EXTRAS! -L../../mbedTLS/library -L../../mbedTLS/crypto/library
if %BUILD_MBEDTLS_DLL% equ 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls -lmbedx509 -lmbedcrypto -lws2_32
if %BUILD_MBEDTLS_DLL% neq 0 set CURL_LDFLAG_EXTRAS2=-lmbedtls.dll -lmbedx509.dll -lmbedcrypto.dll
:MBEDTLS_END


:WINSSL
if /i "%BUILD_SSL_ENGINE%" neq "WINSSL" goto :WINSSL_END
echo.
echo -----------------------------------
echo  WinSSL
echo -----------------------------------
title mingw-%BUILD_ARCH%-WinSSL

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
title mingw-%BUILD_ARCH%-%BUILD_SSL_ENGINE%-libcurl

cd /d "%~dp0"
xcopy "cURL\*.*" "%BUILD_OUTDIR%\cURL" /QIYD
xcopy "cURL\include" "%BUILD_OUTDIR%\cURL\include" /QEIYD
xcopy "cURL\lib" "%BUILD_OUTDIR%\cURL\lib" /QEIYD
cd /d "%BUILD_OUTDIR%\cURL\lib"

if %BUILD_LIBCURL_DLL% equ 0 set CFG=!CURL_CFG!
if %BUILD_LIBCURL_DLL% neq 0 set CFG=!CURL_CFG! -dyn

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS% %NGHTTP2_CFLAGS%
set CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS% !CURL_LDFLAG_EXTRAS!
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
title mingw-%BUILD_ARCH%-%BUILD_SSL_ENGINE%-libcurl.exe
:: NOTE: Must build in ANSI code page

cd /d "%~dp0"
xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src-dyn" /QEIYD
cd /d "%BUILD_OUTDIR%\cURL\src-dyn"

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS% %NGHTTP2_CFLAGS%
set CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS% !CURL_LDFLAG_EXTRAS!
::set CURL_LDFLAG_EXTRAS2=!CURL_LDFLAG_EXTRAS!

:: curl.exe (dynamic) -> libcurl.exe
mingw32-make -f Makefile.m32 CFG=-dyn all
echo.
echo ERRORLEVEL = %errorlevel%
if %errorlevel% neq 0 pause && exit /B %errorlevel%

:: Collect
echo.
move /Y "%BUILD_OUTDIR%\cURL\src-dyn\curl.exe" "%BUILD_OUTDIR%\cURL\src-dyn\libcurl.exe"
xcopy "%BUILD_OUTDIR%\cURL\src-dyn\*.exe" "%BUILD_OUTDIR%" /YF
objdump -d -S "%BUILD_OUTDIR%\cURL\src-dyn\*.o" > "%BUILD_OUTDIR%\asm-libcURL-src.txt"
:LIBCURL_EXE_END


:CURL_EXE
echo.
echo -----------------------------------
echo  curl.exe
echo -----------------------------------
title mingw-%BUILD_ARCH%-%BUILD_SSL_ENGINE%-curl.exe
:: NOTE: Must build in ANSI code page

cd /d "%~dp0"
xcopy "cURL\src" "%BUILD_OUTDIR%\cURL\src" /QEIYD
cd /d "%BUILD_OUTDIR%\cURL\src"

if /I %BUILD_ARCH% equ x64 set ARCH=w64
if /I %BUILD_ARCH% neq x64 set ARCH=w32

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %MBEDTLS_CFLAGS% %NGHTTP2_CFLAGS%
set CURL_LDFLAG_EXTRAS=%GLOBAL_LFLAGS% !CURL_LDFLAG_EXTRAS!
::set CURL_LDFLAG_EXTRAS2=!CURL_LDFLAG_EXTRAS! -Wl,--exclude-libs=ALL

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
	echo "%%~dp0\curl.exe" -L -v --capath "%%~dp0\" -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%BUILD_OUTDIR%\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%BUILD_OUTDIR%\test.bat"
	echo pause>> "%BUILD_OUTDIR%\test.bat"
)
