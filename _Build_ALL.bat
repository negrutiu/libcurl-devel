@start ""       /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@start "" /WAIT /B %COMSPEC% /C set BUILDER=MSVC^&^&  set CONFIG=Release^&^& "%~dp0\_Build.bat"
@start ""       /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Debug^&^&   "%~dp0\_Build.bat"
@start "" /WAIT /B %COMSPEC% /C set BUILDER=mingw^&^& set CONFIG=Release^&^& "%~dp0\_Build.bat"
pause
