REM :: Marius Negrutiu (marius.negrutiu@protonmail.com)

@echo off
echo.

cd /d "%~dp0"

call :CLEANUP
call :CLEANUP
call :CLEANUP
call :CLEANUP
call :CLEANUP
goto :EOF


:CLEANUP
echo.
echo.
echo.

rd /S /Q .vs
rd /S /Q ipch

for /D %%a in (Debug-*)   do rd /S /Q "%%a"
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
