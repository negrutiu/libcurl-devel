@echo off

echo(

"%~dp0\bin\mingw-curl_openssl-Release-x64\bin\curl.exe" -V

echo(

"%~dp0\bin\mingw-curl_schannel-Release-x64\bin\curl.exe" -V

echo(

echo curl-ca-bundle.crt
type "%~dp0\curl-ca-bundle.crt" | findstr /C:"as of:"

echo(

pause