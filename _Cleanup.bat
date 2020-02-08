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
rd /S /Q bin
rd /S /Q Release
del cacert.pem

rd /S /Q .vs
rd /S /Q ipch

del *.aps
del *.bak
del *.user
del *.ncb
del /AH *.suo
del *.sdf
del *.VC.db
