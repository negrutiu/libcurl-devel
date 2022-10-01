@if not exist "%~dp0\curl-ca-bunddle.crt" call "%~dp0\_Get_ca_bundle.bat"

@start "" /WAIT /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Release^&^& "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Release^&^& "%~dp0\_Build.bat"
pause
