REM :: Marius Negrutiu :: 2020/02/02
@echo off

set Z7=%PROGRAMFILES%\7-Zip\7z.exe
if not exist "%Z7%" echo ERROR: Missing %Z7% && pause && exit /B 2

cd /d "%~dp0"
set package=Release

if not exist "bin" echo ERROR: Missing "bin" && pause && exit /B 2

rmdir /S /Q "%package%" > NUL 2> NUL
mkdir "%package%"

echo -------------------------------------------------------------------------------
echo include
echo -------------------------------------------------------------------------------

xcopy "curl\include\curl\*.h"				"%package%\include\curl\" /EI
xcopy "openssl\include\*.*"					"%package%\include\openssl\" /EI
xcopy "nghttp2\src\includes\nghttp2\*.h"	"%package%\include\nghttp2\" /EI
xcopy "zlib\zlib.h"							"%package%\include\zlib\" /I
xcopy "zlib\zconf.h"						"%package%\include\zlib\" /I

echo Instrument openssl.conf...
del /Q "%package%\include\openssl\openssl\opensslconf.h.in"
echo #if defined (_M_IX86)>				   "%package%\include\openssl\openssl\opensslconf.h"
echo #include ^"opensslconf32.h^">>		   "%package%\include\openssl\openssl\opensslconf.h"
echo #elif defined (_M_AMD64)>>			   "%package%\include\openssl\openssl\opensslconf.h"
echo #include ^"opensslconf64.h^">>		   "%package%\include\openssl\openssl\opensslconf.h"
echo #else>>							   "%package%\include\openssl\openssl\opensslconf.h"
echo #error Architecture not supported>>   "%package%\include\openssl\openssl\opensslconf.h"
echo #endif>>							   "%package%\include\openssl\openssl\opensslconf.h"

copy "bin\mingw-openssl-Release-Win32\openssl\include\openssl\opensslconf.h" "%package%\include\openssl\openssl\opensslconf32.h"
copy "bin\mingw-openssl-Release-x64\openssl\include\openssl\opensslconf.h"   "%package%\include\openssl\openssl\opensslconf64.h"

echo -------------------------------------------------------------------------------
echo src
echo -------------------------------------------------------------------------------

xcopy "curl\*.md"							"%package%\src\curl\" /IY
xcopy "curl\README*.*"						"%package%\src\curl\" /IY
xcopy "curl\COPYING"						"%package%\src\curl\" /IY
xcopy "curl\docs\THANKS"					"%package%\src\curl\" /IY
xcopy "curl\include\*.*"					"%package%\src\curl\include\" /EI
xcopy "curl\lib\*.*"						"%package%\src\curl\lib\" /EI
xcopy "curl\src\*.*"						"%package%\src\curl\src\" /EI

xcopy "openssl\LICENSE"						"%package%\src\openssl\" /IY
xcopy "openssl\AUTHORS"						"%package%\src\openssl\" /IY
xcopy "openssl\ACKNOWLEDGEMENTS"			"%package%\src\openssl\" /IY
xcopy "openssl\NEWS"						"%package%\src\openssl\" /IY
xcopy "openssl\CHANGES"						"%package%\src\openssl\" /IY
xcopy "openssl\NOTES*.*"					"%package%\src\openssl\" /IY
xcopy "openssl\README*.*"					"%package%\src\openssl\" /IY
xcopy "openssl\*.h"							"%package%\src\openssl\" /IY
xcopy "openssl\crypto\*.*"					"%package%\src\openssl\crypto\" /EI
xcopy "openssl\ssl\*.*"						"%package%\src\openssl\ssl\" /EI
xcopy "openssl\engines\*.*"					"%package%\src\openssl\engines\" /EI

echo -------------------------------------------------------------------------------
echo readme
echo -------------------------------------------------------------------------------

set README=%package%\src\Readme.txt
echo Git tags:> "%readme%"

call :log_git_tag curl
call :log_git_tag openssl
call :log_git_tag nghttp2
call :log_git_tag zlib

goto :log_git_tag_end
:log_git_tag
	set TAG=
	pushd %~1
	for /f usebackq %%i in (`git rev-parse --abbrev-ref HEAD`) do set TAG=%%i
	if /i "%TAG%" equ "HEAD" (
		for /f usebackq %%i in (`git describe --tags`) do set TAG=%%i
	)
	popd
	echo %~1: %TAG%
	echo %~1: %TAG%>> "%readme%"
	exit /B 0
:log_git_tag_end


echo.>> "%readme%"
echo NOTE:>> "%readme%"
echo This directory contains part of the source code of the main sub-projects.>> "%readme%"
echo Although incomplete, these files should allow you to step into CURL sources during debugging.>> "%readme%"
echo For the complete source code please clone their respective Git repositories.>> "%readme%"

echo -------------------------------------------------------------------------------
echo bin
echo -------------------------------------------------------------------------------

for /d %%d in (bin\MSVC-*) do call :copy_bin %%d
for /d %%d in (bin\mingw-*-Release*) do call :copy_bin %%d

goto :copy_bin_end
:copy_bin
echo %~1
echo \curl.pdb> skip.txt
echo \openssl.pdb>> skip.txt
xcopy "%~1\*.exe"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.dll"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.pdb"							"%package%\%~1\" /I /EXCLUDE:skip.txt > NUL 2> NUL
xcopy "%~1\*.lib"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.a"								"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\cacert.pem"						"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\test.bat"						"%package%\%~1\" /I > NUL 2> NUL
del skip.txt
exit /B
:copy_bin_end

echo -------------------------------------------------------------------------------
echo package
echo -------------------------------------------------------------------------------

xcopy "LICENSE"								"%package%\" /Y
xcopy "README.md"							"%package%\" /Y

REM for /f tokens^=2^ delims^=^" %%v in ('find "LIBCURL_VERSION " "curl\include\curl\curlver.h"') do set CURL_VERSION=%%v

echo.
set /P prompt7z=Build .7z archive? [Y/n] 
if /I "%prompt7z%" equ "n" goto :7z_end
	move /Y libcurl-devel-negrutiu.7z libcurl-devel-negrutiu.7z.bak 2> NUL
	pushd "%package%"
	"%Z7%" a "..\libcurl-devel-negrutiu.7z" * -r -mx=9 -myx=9 -ms=e -mqs=on
	popd
:7z_end

echo -------------------------------------------------------------------------------
pause