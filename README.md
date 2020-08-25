# Unofficial [libcurl](https://curl.haxx.se/) development binaries

[![License: 0BSD](https://img.shields.io/badge/License-0BSD-blue.svg)](/LICENSE)
[![Latest Release](https://img.shields.io/badge/dynamic/json.svg?label=Latest%20Release&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fnegrutiu%2Flibcurl-devel%2Freleases%2Flatest&query=%24.name&colorB=orange)](../../releases/latest)

### Webpage:
https://github.com/negrutiu/libcurl-devel

### Features:
* [libcurl](https://curl.haxx.se/) **Windows** binaries for **x86** and **amd64** architectures
* [OpenSSL](https://www.openssl.org/) and [schannel](https://docs.microsoft.com/en-us/windows/win32/secauthn/secure-channel/) as SSL backends
* Built-in support for [HTTP/2](https://www.nghttp2.org/)
* Binaries built with [Microsoft Visual Studio](https://visualstudio.microsoft.com/) (Debug and Release configurations) and [msys2](https://www.msys2.org/)/[mingw](http://mingw.org/)
* Package contents:
	* Configurations compatible with legacy Windows versions (e.g. `mingw-openssl-Release-Win32-Legacy` works well in Win NT4+)
	* Static and shared libraries for `libcurl`, `openssl`, `nghttp2`, `zlib`
	* Debugging files (`*.pdb`)
	* Test tools (`curl.exe`, `openssl.exe`)

### Binary matrix:
Configuration|Comments
:---|:---
mingw-curl_openssl-Release-Win32|Built with `mingw`. Static libraries. `OpenSSL` backend
mingw-curl_openssl-Release-Win32-HTTP_ONLY|HTTP protocol only
mingw-curl_openssl-Release-Win32-Legacy|HTTP protocol only. Backward compatible with legacy Windows versions (NT4+)
mingw-curl_openssl-Release-Win32-Shared|Built with `mingw`. Shared libraries. `OpenSSL` backend
mingw-curl_openssl-Release-x64|
mingw-curl_openssl-Release-x64-HTTP_ONLY|
mingw-curl_openssl-Release-x64-Legacy|HTTP protocol only. Backward compatible with legacy Windows versions (XP64+)
mingw-curl_openssl-Release-x64-Shared|
mingw-curl_schannel-Release-Win32|Built with `mingw`. Static libraries. `schannel` (aka `WinSSL`) backend
mingw-curl_schannel-Release-Win32-HTTP_ONLY|
mingw-curl_schannel-Release-Win32-Shared|
mingw-curl_schannel-Release-x64|
mingw-curl_schannel-Release-x64-HTTP_ONLY|
mingw-curl_schannel-Release-x64-Shared|
MSVC-curl_openssl-Debug-Win32|Built with `Microsoft Visual Studio`
MSVC-curl_openssl-Debug-Win32-HTTP_ONLY|
MSVC-curl_openssl-Debug-Win32-Shared|
MSVC-curl_openssl-Debug-x64|
MSVC-curl_openssl-Debug-x64-HTTP_ONLY|
MSVC-curl_openssl-Debug-x64-Shared|
MSVC-curl_openssl-Release-Win32|
MSVC-curl_openssl-Release-Win32-HTTP_ONLY|
MSVC-curl_openssl-Release-Win32-Shared|
MSVC-curl_openssl-Release-x64|
MSVC-curl_openssl-Release-x64-HTTP_ONLY|
MSVC-curl_openssl-Release-x64-Shared|
MSVC-curl_schannel-Debug-Win32|
MSVC-curl_schannel-Debug-Win32-HTTP_ONLY|
MSVC-curl_schannel-Debug-Win32-Shared|
MSVC-curl_schannel-Debug-x64|
MSVC-curl_schannel-Debug-x64-HTTP_ONLY|
MSVC-curl_schannel-Debug-x64-Shared|
MSVC-curl_schannel-Release-Win32|
MSVC-curl_schannel-Release-Win32-HTTP_ONLY|
MSVC-curl_schannel-Release-Win32-Shared|
MSVC-curl_schannel-Release-x64|
MSVC-curl_schannel-Release-x64-HTTP_ONLY|
MSVC-curl_schannel-Release-x64-Shared|

### [OpenSSL](https://www.openssl.org/) vs. [schannel](https://docs.microsoft.com/en-us/windows/win32/secauthn/secure-channel) (aka WinSSL):
Parameter|Comments
:---|:---
File sizes|`schannel` is a Windows native engine, `OpenSSL` is a 3rd party engine.<br>Binaries built on top of `schannel` are smaller.
Certificate store|`schannel` uses the system certificate store (run `certmgr.msc` to view it) whereas <br>`OpenSSL` requires [cacert.pem](https://curl.haxx.se/ca/cacert.pem) alongside your binaries, which adds another 200-300KB to your package...<br>Although `schannel` sounds better, older Windows versions (XP, Vista, Win7) stop receiving certificate store updates, so they quickly become unable to connect to modern HTTPS servers.<br>If your binaries are required to support older Windows versions, `OpenSSL` is your only choice here.
Protocols & Ciphers|`schannel` has different capabilities depending on the Windows version (e.g. XP only supports TLS 1.0) (See [this blog](https://docs.microsoft.com/en-us/archive/blogs/kaushal/support-for-ssltls-protocols-on-windows)).<br>3rd party software can interfere with `schannel` (See [this article](https://support.microsoft.com/en-us/help/245030/how-to-restrict-the-use-of-certain-cryptographic-algorithms-and-protoc)).<br>`OpenSSL` supports all modern encryption including TLS1.3, HTTP/2, etc.

### Licenses:
Project|License
:---|:---
This project itself|[0BSD](LICENSE)
libcurl|[MIT/X inspired](https://curl.haxx.se/docs/copyright.html)
OpenSSL|[Dual License](https://www.openssl.org/source/license.html)
nghttp2|[MIT](https://github.com/nghttp2/nghttp2/blob/master/COPYING)
zlib|[zlib](https://www.zlib.net/zlib_license.html)
