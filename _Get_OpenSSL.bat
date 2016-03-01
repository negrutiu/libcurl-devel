@echo off
set GIT=%PROGRAMFILES%\Git\bin\git.exe

cd /d "%~dp0"

if exist "OpenSSL\.git" (
	cd OpenSSL
	"%GIT%" pull --verbose --progress "origin"
) else (
	"%GIT%" clone --verbose --progress -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl.git OpenSSL
	cd OpenSSL
	"%GIT%" config core.autocrlf false
	"%GIT%" config core.eol lf	
	"%GIT%" checkout .
)


pause