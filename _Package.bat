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

robocopy "bin\mingw-curl_openssl-Release-x64\include" "%package%\include" *.h /XF __DECC_*.h /MIR /NS /NC /NDL /NP /NJH /NJS
robocopy "openssl\include\crypto" "%package%\include\openssl\crypto" *.h /XF __DECC_*.h /MIR /NS /NC /NDL /NP /NJH /NJS
robocopy "openssl\include\internal" "%package%\include\openssl\internal" *.h /XF __DECC_*.h /MIR /NS /NC /NDL /NP /NJH /NJS

move "%package%\include\openssl\opensslconf.h" "%package%\include\openssl\opensslconf64.h"
copy /Y "bin\mingw-curl_openssl-Release-Win32\include\openssl\opensslconf.h" "%package%\include\openssl\opensslconf32.h"

echo #if defined (_M_IX86)>				   "%package%\include\openssl\opensslconf.h"
echo #include ^"opensslconf32.h^">>		   "%package%\include\openssl\opensslconf.h"
echo #elif defined (_M_AMD64)>>			   "%package%\include\openssl\opensslconf.h"
echo #include ^"opensslconf64.h^">>		   "%package%\include\openssl\opensslconf.h"
echo #else>>							   "%package%\include\openssl\opensslconf.h"
echo #error Architecture not supported>>   "%package%\include\openssl\opensslconf.h"
echo #endif>>							   "%package%\include\openssl\opensslconf.h"

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
xcopy "openssl\providers\*.*"				"%package%\src\openssl\providers\" /EI

xcopy "nghttp2\AUTHORS"						"%package%\src\nghttp2\" /IY
xcopy "nghttp2\CONTRIBUTION"				"%package%\src\nghttp2\" /IY
xcopy "nghttp2\COPYING"						"%package%\src\nghttp2\" /IY
xcopy "nghttp2\LICENSE"						"%package%\src\nghttp2\" /IY
xcopy "nghttp2\NEWS"						"%package%\src\nghttp2\" /IY
xcopy "nghttp2\README*.*"					"%package%\src\nghttp2\" /IY
xcopy "nghttp2\lib\*.h"						"%package%\src\nghttp2\lib\" /IY
xcopy "nghttp2\lib\*.c"						"%package%\src\nghttp2\lib\" /IY

xcopy "zlib\FAQ"							"%package%\src\zlib\" /IY
xcopy "zlib\README"							"%package%\src\zlib\" /IY
xcopy "zlib\*.h"							"%package%\src\zlib\" /IY
xcopy "zlib\*.c"							"%package%\src\zlib\" /IY
xcopy "zlib\*.pdf"							"%package%\src\zlib\" /IY

REM | Extract LICENSE from zlib.h header. Read all lines until "*/" is found
powershell -ExecutionPolicy bypass -Command "foreach ($ln in gc -totalcount 64 .\zlib\zlib.h) { $ln; if ($ln -match '\w*\*/\w*') {break} }"> "%package%\src\zlib\LICENSE"

echo -------------------------------------------------------------------------------
echo NOTES.md
echo -------------------------------------------------------------------------------

set f=%package%\NOTES.md
echo # Git tags> "%f%"

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
	echo `%~1` %TAG%
	echo `%~1` %TAG%>> "%f%"
	exit /B 0
:log_git_tag_end


echo.>> "%f%"
echo # Notes>> "%f%"
echo Directory `src` contains parts of the source code.>> "%f%"
echo Although incomplete, these files should allow you to step into `curl` sources during debugging.>> "%f%"
echo For the complete source code please clone their respective Git repositories.>> "%f%"

xcopy "LICENSE*" "%package%\" /Y
xcopy "README*" "%package%\" /Y

REM -------------------------------------------------------------------------------
REM bin
REM -------------------------------------------------------------------------------
for /D %%d in ("bin\MSVC-curl*") do call :dir "%%~fd"
for /D %%d in ("bin\mingw-curl*-Release*") do call :dir "%%~fd"

goto :dir_end
:dir
echo -------------------------------------------------------------------------------
echo %~n1
echo -------------------------------------------------------------------------------
xcopy "%~1\bin" "%package%\%~n1\bin" /YI
xcopy "%~1\lib" "%package%\%~n1\lib" /YI
exit /B
:dir_end

echo.
echo -------------------------------------------------------------------------------
echo Archive
echo -------------------------------------------------------------------------------
REM for /f tokens^=2^ delims^=^" %%v in ('find "LIBCURL_VERSION " "curl\include\curl\curlver.h"') do set CURL_VERSION=%%v
set /P prompt7z=Build .7z archive? [Y/n] 
if /I "%prompt7z%" equ "n" goto :7z_end
	move /Y libcurl-devel-negrutiu.7z libcurl-devel-negrutiu.7z.bak 2> NUL
	pushd "%package%"
	"%Z7%" a "..\libcurl-devel-negrutiu.7z" * -r -mx=9 -myx=9 -ms=e -mqs=on
	popd
:7z_end

echo -------------------------------------------------------------------------------
pause
exit /B
