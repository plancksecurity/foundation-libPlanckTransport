ECHO "Generate transport files"
ECHO "PROCESSOR_ARCHITECTURE:%PROCESSOR_ARCHITECTURE%"
ECHO "PROCESSOR_ARCHITEW6432:%PROCESSOR_ARCHITEW6432%"

SET vcpkg_platform=x86-windows

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET vcpkg_platform=x64-windows
IF "%PROCESSOR_ARCHITECTURE%"=="IA64" SET vcpkg_platform=x64-windows
IF "%PROCESSOR_ARCHITECTURE%"=="ARM64" SET vcpkg_platform=arm64-windows

IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET vcpkg_platform=x64-windows
IF "%PROCESSOR_ARCHITEW6432%"=="IA64" SET vcpkg_platform=x64-windows
IF "%PROCESSOR_ARCHITEW6432%"=="ARM64" SET vcpkg_platform=arm64-windows

SET PY=%USERPROFILE%\vcpkg\installed\%vcpkg_platform%\tools\python3\python.exe
SET YML2PROC=%PY% %1\yml2\yml2proc

:: Generate the code
PUSHD ..\src
IF NOT EXIST generated MKDIR generated

%YML2PROC% -E utf-8 -y gen_c.ysl2 transport_status_code.yml2 -o transport_status_code.h
IF %ERRORLEVEL% NEQ 0 GOTO end

%YML2PROC% -E utf-8 -y gen_strings.ysl2 transport_status_code.yml2 -o transport_status_code.c
IF %ERRORLEVEL% NEQ 0 GOTO end

%YML2PROC% -E utf-8 -y gen_objc.ysl2 transport_status_code.yml2 -o PEPTransportStatusCode.h
IF %ERRORLEVEL% NEQ 0 GOTO end

%YML2PROC% -E utf-8 -y gen_kotlin.ysl2 transport_status_code.yml2 -o TransportStatusCode.kt
IF %ERRORLEVEL% NEQ 0 GOTO end

%YML2PROC% -E utf-8 -y gen_cs.ysl2 transport_status_code.yml2 -o TransportStatusCode.cs
IF %ERRORLEVEL% NEQ 0 GOTO end

%YML2PROC% -E utf-8 -P transport_status_code.yml2 -o transport_status_code.xml
IF %ERRORLEVEL% NEQ 0 GOTO end

IF NOT EXIST %1\include\pEp MKDIR %1\include\pEp
XCOPY /y *.c %1\include\pEp\
XCOPY /y *.h %1\include\pEp\

:end

POPD
EXIT /B %ERRORLEVEL%
