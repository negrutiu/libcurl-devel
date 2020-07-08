@echo off
SetLocal EnableDelayedExpansion

pushd "%~dp0\bin"
for /d %%d in (*-openssl-*.*) do if exist "%%d\curl.exe" call :test_curl "%%d" openssl
for /d %%d in (*-winssl-*.*)  do if exist "%%d\curl.exe" call :test_curl "%%d" winssl
popd

echo.
pause
exit /B

:test_curl
echo.
echo %~1
set url=negrutiu.com/
set txt= 

REM set err=[*]&& "%~1\curl.exe" -V | findstr "SSL" > NUL || set err=[ ]
REM set txt=!txt! SSL:%err%

set err=[*]&& "%~1\curl.exe" -V | findstr "TLS-SRP" > NUL || set err=[ ]
set txt=!txt! TLS-SRP:%err%

set err=[*]&& "%~1\curl.exe" -V | findstr "HTTP2" > NUL || set err=[ ]
set txt=!txt! HTTP2:%err%

set err=[*]&& "%~1\curl.exe" -V | findstr "HTTPS-proxy" > NUL || set err=[ ]
set txt=!txt! HTTPS-proxy:%err%

set err=[*]&& "%~1\curl.exe" -V | findstr "libz" > NUL || set err=[ ]
set txt=!txt! libz:%err%

"%~1\curl.exe" -L -v -w "HTTPCODE:%%{response_code}" %url% > "%~1\test-data.md" 2> "%~1\test-trace.md"
set txt=!txt! CURLE:[%errorlevel%]

set err=???&& for /f "delims=: tokens=2" %%l in ('type "%1\test-data.md" ^| findstr "HTTPCODE:"') do set err=%%l
set txt=!txt! HTTP-status:[%err%]

set err=[*]&& findstr "GET / HTTP/2" "%~1\test-trace.md" > NUL || set err=[ ]
set txt=!txt! HTTP/2:%err%

if /i "%~2" equ "openssl" (
	set err=[*]&& findstr "using TLSv1.3" "%~1\test-trace.md" > NUL || set err=[ ]
	set txt=!txt! TLSv1.3:%err%
) else (
	set txt=!txt! TLSv1.3:[?]
)

del "%~1\test-trace.md" 2> NUL
del "%~1\test-data.md" 2> NUL

echo !txt!
exit /B