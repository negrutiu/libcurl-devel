@REM PowerShell.exe -ExecutionPolicy Unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Invoke-WebRequest -Uri https://curl.haxx.se/ca/cacert.pem -OutFile '%~dp0\cacert.pem'"

curl.exe -v -z curl-ca-bundle.crt -o curl-ca-bundle.crt --no-progress-meter -w "HTTP %%{http_code}" https://curl.haxx.se/ca/cacert.pem
if %errorlevel% neq 0 pause && exit /B %errorlevel%
@REM pause
