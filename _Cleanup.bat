@echo off

cd /d "%~dp0"

call :CLEANUP
ping -n 2 127.0.0.1 > NUL
call :CLEANUP
ping -n 2 127.0.0.1 > NUL
call :CLEANUP
goto :EOF


:CLEANUP
echo ----------
rd /S /Q .vs
rd /S /Q ipch

for /D %%a in (Debug-*) do rd /S /Q "%%a"
for /D %%a in (Release-*) do rd /S /Q "%%a"

del *.aps
del *.bak
del *.user
del *.ncb
del /AH *.suo
del *.sdf
del *.VC.db

:CLEANUP_WDK
for /D %%a in (objchk*) do rd /S /Q "%%a"
for /D %%a in (objfre*) do rd /S /Q "%%a"

del *.err
del *.wrn
del *.log
del buildfre*.*
del buildchk*.*
del prefast*.*

:CLEANUP_MBEDTLS
del mbedTLS\library\*.a mbedTLS\library\*.o mbedTLS\library\*.dll

:CLEANUP_CURL
del cURL\lib\*.a cURL\lib\*.o cURL\lib\*.res cURL\lib\*.dll
del cURL\lib\vtls\*.o
del cURL\src\*.a cURL\src\*.o cURL\src\*.res cURL\src\*.exe
