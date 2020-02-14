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
xcopy "mbedtls\include\mbedtls\*.h"			"%package%\include\mbedtls\" /EI
xcopy "mbedtls\crypto\include\mbedtls\*.h"	"%package%\include\mbedtls\crypto\mbedtls\" /EI
xcopy "nghttp2\src\includes\nghttp2\*.h"	"%package%\include\nghttp2\" /EI
xcopy "zlib\zlib.h"							"%package%\include\zlib\" /I
xcopy "zlib\zconf.h"						"%package%\include\zlib\" /I

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

xcopy "mbedtls\*.md"						"%package%\src\mbedtls\" /IY
xcopy "mbedtls\README*.*"					"%package%\src\mbedtls\" /IY
xcopy "mbedtls\LICENSE"						"%package%\src\mbedtls\" /IY
xcopy "mbedtls\apache-2.0.txt"				"%package%\src\mbedtls\" /IY
xcopy "mbedtls\include\*.*"					"%package%\src\mbedtls\include\" /EI
xcopy "mbedtls\library\*.*"					"%package%\src\mbedtls\library\" /EI
xcopy "mbedtls\programs\*.*"				"%package%\src\mbedtls\programs\" /EI

xcopy "mbedtls\crypto\*.md"					"%package%\src\mbedtls\crypto\" /IY
xcopy "mbedtls\crypto\README*.*"			"%package%\src\mbedtls\crypto\" /IY
xcopy "mbedtls\crypto\LICENSE"				"%package%\src\mbedtls\crypto\" /IY
xcopy "mbedtls\crypto\apache-2.0.txt"		"%package%\src\mbedtls\crypto\" /IY
xcopy "mbedtls\crypto\3rdparty\*.*"			"%package%\src\mbedtls\crypto\3rdparty\" /EI
xcopy "mbedtls\crypto\include\*.*"			"%package%\src\mbedtls\crypto\include\" /EI
xcopy "mbedtls\crypto\library\*.*"			"%package%\src\mbedtls\crypto\library\" /EI
xcopy "mbedtls\crypto\programs\*.*"			"%package%\src\mbedtls\crypto\programs\" /EI

echo -------------------------------------------------------------------------------
echo versions
echo -------------------------------------------------------------------------------

set README=%package%\src\Readme.txt
echo Git tags:> "%readme%"

set TAG=
pushd curl
for /f usebackq %%i in (`git rev-parse --abbrev-ref HEAD`) do set TAG=%%i
if /i "%TAG%" equ "HEAD" (
	for /f usebackq %%i in (`git describe --tags`) do set TAG=%%i
)
popd
echo %TAG%
echo %TAG%>> "%readme%"

set TAG=
pushd mbedtls
for /f usebackq %%i in (`git rev-parse --abbrev-ref HEAD`) do set TAG=%%i
if /i "%TAG%" equ "HEAD" (
	for /f usebackq %%i in (`git describe --tags`) do set TAG=%%i
)
popd
echo %TAG%
echo %TAG%>> "%readme%"

echo.>> "%readme%"
echo NOTE:>> "%readme%"
echo The source files saved here are incomplete.>> "%readme%"
echo Still, they are sufficient for stepping into CURL code during debugging.>> "%readme%"
echo You are welcome to clone their respective Git projects for the complete source code.>> "%readme%"

echo -------------------------------------------------------------------------------
echo bin
echo -------------------------------------------------------------------------------

for /d %%d in (bin\*) do call :copy_bin %%d

goto :copy_bin_end
:copy_bin
echo %~1
xcopy "%~1\*.exe"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.dll"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.pdb"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.lib"							"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\*.a"								"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\cacert.pem"						"%package%\%~1\" /I > NUL 2> NUL
xcopy "%~1\test.bat"						"%package%\%~1\" /I > NUL 2> NUL
exit /B
:copy_bin_end

echo -------------------------------------------------------------------------------
echo package
echo -------------------------------------------------------------------------------

xcopy "LICENSE"								"%package%\" /Y
xcopy "README.md"							"%package%\" /Y

REM for /f tokens^=2^ delims^=^" %%v in ('find "LIBCURL_VERSION " "curl\include\curl\curlver.h"') do set CURL_VERSION=%%v

pushd "%package%"
"%Z7%" a "..\libcurl-devel-negrutiu.7z" * -r -mx=9 -myx=9 -ms=e -mqs=on
popd

echo -------------------------------------------------------------------------------
pause