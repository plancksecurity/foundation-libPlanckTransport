SET PY=%1\vcpkg\installed\x64-windows\tools\python3\python.exe

SET yml2_directory=%1\yml2

SET YML2PROC="%yml2_directory%\yml2proc"

:: Generate the code
PUSHD ..\src
IF NOT EXIST generated MKDIR generated

%PY% %YML2PROC% -E utf-8 -y gen_c.ysl2 transport_status_code.yml2 -o transport_status_code.h
IF %ERRORLEVEL% NEQ 0 GOTO end

%PY% %YML2PROC% -E utf-8 -y gen_strings.ysl2 transport_status_code.yml2 -o transport_status_code.c
IF %ERRORLEVEL% NEQ 0 GOTO end

%PY% %YML2PROC% -E utf-8 -y gen_objc.ysl2 transport_status_code.yml2 -o PEPTransportStatusCode.h
IF %ERRORLEVEL% NEQ 0 GOTO end

%PY% %YML2PROC% -E utf-8 -y gen_kotlin.ysl2 transport_status_code.yml2 -o TransportStatusCode.kt
IF %ERRORLEVEL% NEQ 0 GOTO end

%PY% %YML2PROC% -E utf-8 -y gen_cs.ysl2 transport_status_code.yml2 -o TransportStatusCode.cs
IF %ERRORLEVEL% NEQ 0 GOTO end

%PY% %YML2PROC% -E utf-8 -P transport_status_code.yml2 -o transport_status_code.xml
IF %ERRORLEVEL% NEQ 0 GOTO end

IF NOT EXIST %1\include\pEp MKDIR %1\include\pEp
XCOPY /y *.c %1\include\pEp\
XCOPY /y *.h %1\include\pEp\

:end

POPD
EXIT /B %ERRORLEVEL%
