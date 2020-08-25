@echo off
SetLocal EnableDelayedExpansion

set url=negrutiu.com/
set index=0

pushd "%~dp0\bin"
for /d %%d in (*-curl_openssl-*.*) do call :test_dir "%%d\bin" openssl
for /d %%d in (*-curl_schannel-*.*)  do call :test_dir "%%d\bin" schannel
popd

echo.
pause
exit /B

:test_dir
set /a index += 1
echo.
echo %index%. %~1

if exist "%~1\curl.exe"    call :test_curl "%~1\curl.exe" "%~2"
if exist "%~1\libcurl.exe" call :test_curl "%~1\libcurl.exe" "%~2"
exit /B


:test_curl
set txt= 

REM set err=[*]&& "%~1" -V | findstr "SSL" > NUL || set err=[ ]
REM set txt=!txt! SSL:%err%

set err=[*]&& "%~1" -V | findstr "TLS-SRP" > NUL || set err=[ ]
set txt=!txt! TLS-SRP:%err%

set err=[*]&& "%~1" -V | findstr "HTTP2" > NUL || set err=[ ]
set txt=!txt! HTTP2:%err%

set err=[*]&& "%~1" -V | findstr "HTTPS-proxy" > NUL || set err=[ ]
set txt=!txt! HTTPS-proxy:%err%

set err=[*]&& "%~1" -V | findstr "libz" > NUL || set err=[ ]
set txt=!txt! libz:%err%

"%~1" -L -v -w "HTTPCODE:%%{response_code}" %url% > "%~dp1\test-data.md" 2> "%~dp1\test-trace.md"
set txt=!txt! CURLE:[%errorlevel%]

set err=???&& for /f "delims=: tokens=2" %%l in ('type "%~dp1\test-data.md" ^| findstr "HTTPCODE:"') do set err=%%l
set txt=!txt! HTTP-status:[%err%]

set err=[*]&& findstr "GET / HTTP/2" "%~dp1\test-trace.md" > NUL || set err=[ ]
set txt=!txt! HTTP/2:%err%

if /i "%~2" equ "openssl" (
	set err=[*]&& findstr "using TLSv1.3" "%~dp1\test-trace.md" > NUL || set err=[ ]
	set txt=!txt! TLSv1.3:%err%
) else (
	set txt=!txt! TLSv1.3:[?]
)

del "%~1\test-trace.md" 2> NUL
del "%~1\test-data.md" 2> NUL

echo !txt!
exit /B