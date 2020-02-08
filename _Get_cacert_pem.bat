PowerShell.exe -ExecutionPolicy Unrestricted -Command "Invoke-WebRequest -Uri https://curl.haxx.se/ca/cacert.pem -OutFile '%~dp0\cacert.pem'"
