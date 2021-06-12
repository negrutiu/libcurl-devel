@start "" /WAIT /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Release^&^& "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@timeout /T 60

@start "" /WAIT /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Release^&^& "%~dp0\_Build.bat"
pause
