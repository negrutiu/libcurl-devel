REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.
setlocal EnableDelayedExpansion

cd /d "%~dp0"

if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS2
if not exist "%MSYS2%" set MSYS2=%SYSTEMDRIVE%\MSYS64
if not exist "%MSYS2%" echo ERROR: Missing msys2/mingw && pause && exit /B 2

if not exist cacert.pem echo ERROR: Missing cacert.pem. Get it! && pause && exit /B 2


:: ----------------------------------------------------------------
:PARALLEL
:: ----------------------------------------------------------------
:ARG_OPENSSL

if /I "%1" equ "/build-openssl-Win32" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl-Win32
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	REM By default LDAP links to wldap32!ber_free, inexistent in NT4 (available starting with W2K)
	set CURL_CFLAGS=-DCURL_DISABLE_LDAP
	REM | [openssl] (compatible with NT4+)
	REM | no-capieng   prevents linking to advapi32!CryptEnumProvidersW
	REM | no-async     prevents linking to kernel32!ConvertFiberToThread
	REM | no-pinshared prevents linking to kernel32!GetModuleHandleExW
	set BUILD_OPENSSL_FEATURES=mingw --release no-shared enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared no-sse2 enable-ssl3 386
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS! -march=pentium2
	REM set OPENSSL_LDFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl-x64
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	REM | [openssl]
	set BUILD_OPENSSL_FEATURES=mingw64 --release no-shared enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared enable-ssl3
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS!
	REM set OPENSSL_LFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

if /I "%1" equ "/build-openssl-Win32-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl-Win32-HTTP_ONLY
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	REM | [openssl] (compatible with NT4+)
	set BUILD_OPENSSL_FEATURES=mingw --release no-shared enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared no-sse2 enable-ssl3 386
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS! -march=pentium2
	REM set OPENSSL_LDFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64-HTTP_ONLY" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl-x64-HTTP_ONLY
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=0
	set BUILD_USE_NGHTTP2=0
	set BUILD_OPENSSL_DLL=0
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=-DHTTP_ONLY
	REM | [openssl]
	set BUILD_OPENSSL_FEATURES=mingw64 --release no-shared enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared enable-ssl3
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS!
	REM set OPENSSL_LFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

if /I "%1" equ "/build-openssl-Win32-openssl_dll" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl_dll-Win32
	set BUILD_ARCH=Win32
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	REM | [openssl] (compatible with NT4+)
	set BUILD_OPENSSL_FEATURES=mingw --release enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared no-sse2 enable-ssl3 386
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS! -march=pentium2
	REM set OPENSSL_LDFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

if /I "%1" equ "/build-openssl-x64-openssl_dll" (
	set BUILD_OUTDIR=%~dp0\bin\Release-mingw-openssl_dll-x64
	set BUILD_ARCH=x64
	set BUILD_SSL_ENGINE=OPENSSL
	set BUILD_USE_ZLIB=1
	set BUILD_USE_NGHTTP2=1
	set BUILD_OPENSSL_DLL=1
	set BUILD_LIBCURL_DLL=1
	set CURL_CFLAGS=
	REM | [openssl]
	set BUILD_OPENSSL_FEATURES=mingw64 --release enable-static-engine no-dynamic-engine no-tests no-capieng no-async no-pinshared enable-ssl3
	REM set OPENSSL_CFLAGS=!OPENSSL_CFLAGS!
	REM set OPENSSL_LFLAGS=!OPENSSL_LDFLAGS!
	goto :BUILD
)

:ARG_WINSSL
if /I "%1" equ "/build-winssl-Win32" (
	set BUILD_SUBDIR=Release-mingw-WinSSL-Win32
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
	set BUILD_SUBDIR=Release-mingw-WinSSL-x64
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
	set BUILD_SUBDIR=Release-mingw-WinSSL-Win32-HTTP_ONLY
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
	set BUILD_SUBDIR=Release-mingw-WinSSL-x64-HTTP_ONLY
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
start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64
start "" "%COMSPEC%" /C "%~f0" /build-openssl-Win32-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64-HTTP_ONLY
start "" "%COMSPEC%" /C "%~f0" /build-openssl-Win32-openssl_dll
start "" "%COMSPEC%" /C "%~f0" /build-openssl-x64-openssl_dll

start "" "%COMSPEC%" /C "%~f0" /build-winssl-Win32
start "" "%COMSPEC%" /C "%~f0" /build-winssl-x64
start "" "%COMSPEC%" /C "%~f0" /build-winssl-Win32-HTTP_ONLY
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


:OPENSSL
if /i "%BUILD_SSL_ENGINE%" neq "OPENSSL" goto :OPENSSL_END
echo.
echo -----------------------------------
echo  openssl
echo -----------------------------------
title mingw-%BUILD_ARCH%-openssl

mkdir "%BUILD_OUTDIR%" 2> NUL
cd /d "%BUILD_OUTDIR%"

REM :: Make a copy of the source code
echo Cloning the source code...
echo fuzz> exclude.txt
xcopy "..\..\openssl\*.*" openssl\ /EXCLUDE:exclude.txt /QEIYD
del exclude.txt

pushd openssl
mkdir fuzz 2> NUL

REM :: Generate mybuild.sh
set FLAG_RUNNING=mybuild.running
set FLAG_ERROR=mybuild.error
echo Building> %FLAG_RUNNING%

echo #! /bin/bash> mybuild.sh
echo. >> mybuild.sh
echo touch %FLAG_RUNNING%>> mybuild.sh
echo trap 'rm %FLAG_RUNNING%' exit>> mybuild.sh
echo. >> mybuild.sh
echo [ -f makefile ] ^|^| ./Configure %BUILD_OPENSSL_FEATURES% --prefix=`pwd`/_PACKAGE>> mybuild.sh
echo. >> mybuild.sh
echo # Remove long file prefixes to prevent exceeding the maximum command line size in Windows>> mybuild.sh
echo sed -i 's/libfips-lib-//g' Makefile>> mybuild.sh
echo sed -i 's/libimplementations-lib-//g' Makefile>> mybuild.sh
echo sed -i 's/libcrypto-lib-/lib-/g' Makefile>> mybuild.sh
echo sed -i 's/libcrypto-shlib-/dll-/g' Makefile>> mybuild.sh
echo sed -i 's/liblegacy-lib-//g' Makefile>> mybuild.sh
echo. >> mybuild.sh
echo touch %FLAG_ERROR%>>mybuild.sh
echo mingw32-make.exe>> mybuild.sh
echo if [ $? -eq 0 ]; then>> mybuild.sh
echo   rm %FLAG_ERROR%>> mybuild.sh
echo else>>mybuild.sh
echo   read>> mybuild.sh
echo fi>> mybuild.sh
echo. >> mybuild.sh
echo # mingw32-make.exe install>> mybuild.sh
echo. >> mybuild.sh
echo rm %FLAG_RUNNING%>> mybuild.sh

REM :: Execute mybuild.sh
if /I "%BUILD_ARCH%" equ "x64"   set MSYS2_TYPE=-mingw64
if /I "%BUILD_ARCH%" equ "Win32" set MSYS2_TYPE=-mingw32

set CFLAGS=!GLOBAL_CFLAGS! !OPENSSL_CFLAGS!
set LDFLAGS=!GLOBAL_LFLAGS! !OPENSSL_LDFLAGS!
call "%MSYS2%\msys2_shell.cmd" %MSYS2_TYPE% -no-start -here "mybuild.sh"

echo.
echo Build in progress...
:WAIT_OPENSSL
if exist "%FLAG_RUNNING%" ping -n 2 127.0.0.1 > NUL && goto :WAIT_OPENSSL
if exist "%FLAG_ERROR%" exit /B 3

popd

REM :: Gather binaries
if %BUILD_OPENSSL_DLL% equ 0 (
	mklink /H libcrypto.a			openssl\libcrypto.a
	mklink /H libssl.a				openssl\libssl.a
) else (
	mklink /H libcrypto.dll.a		openssl\libcrypto.a
	mklink /H libssl.dll.a			openssl\libssl.a
	mklink /H libcrypto-1_1.dll		openssl\libcrypto-1_1.dll		2> NUL
	mklink /H libssl-1_1.dll		openssl\libssl-1_1.dll			2> NUL
	mklink /H libcrypto-1_1-x64.dll	openssl\libcrypto-1_1-x64.dll	2> NUL
	mklink /H libssl-1_1-x64.dll	openssl\libssl-1_1-x64.dll		2> NUL
)
mklink /H openssl.exe				openssl\apps\openssl.exe		2> NUL

REM :: Configure libcurl for openssl
if %BUILD_OPENSSL_DLL% equ 0 set CURL_CFLAGS=!CURL_CFLAGS! -static -DCURL_STATICLIB
if %BUILD_OPENSSL_DLL% equ 0 set CURL_LDFLAG_EXTRAS=!CURL_LDFLAG_EXTRAS! -static
set CURL_CFLAGS=!CURL_CFLAGS! -DUSE_OPENSSL -DUSE_TLS_SRP -I../openssl/include
set CURL_LDFLAG_EXTRAS=!CURL_LDFLAG_EXTRAS! -L../
if %BUILD_OPENSSL_DLL% equ 0 set CURL_LDFLAG_EXTRAS2=-lssl -lcrypto -lws2_32
if %BUILD_OPENSSL_DLL% neq 0 set CURL_LDFLAG_EXTRAS2=-lssl.dll -lcrypto.dll
:OPENSSL_END


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

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %OPENSSL_CFLAGS% %NGHTTP2_CFLAGS%
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

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %OPENSSL_CFLAGS% %NGHTTP2_CFLAGS%
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

set CURL_CFLAG_EXTRAS=%GLOBAL_CFLAGS% %CURL_CFLAGS% %OPENSSL_CFLAGS% %NGHTTP2_CFLAGS%
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
	echo "%%~dp0\curl.exe" -L -v --cacert cacert.pem -X POST -d "{ """number_of_the_beast""" : 666 }" -H "Content-Type: application/json" https://httpbin.org/post> "%BUILD_OUTDIR%\test.bat"
	echo "%%~dp0\curl.exe" -V>> "%BUILD_OUTDIR%\test.bat"
	echo pause>> "%BUILD_OUTDIR%\test.bat"
)
