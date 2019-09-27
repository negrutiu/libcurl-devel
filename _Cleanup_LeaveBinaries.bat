REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.

cd /d "%~dp0"
echo Cleaning up...

call :CLEANUP
call :CLEANUP
call :CLEANUP
call :CLEANUP
call :CLEANUP
goto :EOF


:CLEANUP
for /D %%a in (Debug-*)   do call :DIR "%%a"
for /D %%a in (Release-*) do call :DIR "%%a"

exit /B

:DIR
	rd /S /Q "%~1\curl" 2> NUL
	rd /S /Q "%~1\libcurl" 2> NUL
	rd /S /Q "%~1\libmbedtls" 2> NUL
	rd /S /Q "%~1\mbedtls" 2> NUL
	rd /S /Q "%~1\nghttp2" 2> NUL
	rd /S /Q "%~1\zlib" 2> NUL
	del "%~1\*.iobj" 2> NUL
	del "%~1\*.ipdb" 2> NUL
	del "%~1\*.exp"  2> NUL
	del "%~1\*.ilk"  2> NUL
	exit /B