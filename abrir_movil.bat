@echo off
setlocal enabledelayedexpansion
title Fichar Demo - vista MOVIL
cd /d "%~dp0"

rem Abre la app como se ve en un telefono: ventana estrecha, sin barras y
rem con user-agent de Android, para que la propia web se reconozca como MOVIL.

rem --- El puerto sale del .env: no se escribe aqui ---
set PUERTO=
for /f "usebackq eol=# tokens=1,* delims==" %%a in (".env") do (
    if /i "%%a"=="DEMO_API_PORT" set PUERTO=%%b
)
if "%PUERTO%"=="" (
    echo ERROR: no se ha encontrado DEMO_API_PORT en el fichero .env
    pause
    exit /b 1
)

set CHROME=
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set CHROME=%LocalAppData%\Google\Chrome\Application\chrome.exe

if "%CHROME%"=="" (
    echo No se ha encontrado Chrome. Se abre en el navegador por defecto.
    start "" http://localhost:%PUERTO%/
    exit /b 0
)

echo Abriendo la vista de movil en http://localhost:%PUERTO% ...

rem --user-data-dir aparte: sin el, Chrome reutiliza la ventana ya abierta
rem y se ignoran tanto el tamano como el user-agent.
start "" "%CHROME%" --app=http://localhost:%PUERTO%/ ^
 --window-size=430,880 ^
 --window-position=60,40 ^
 --user-data-dir="%TEMP%\fichardemo-movil" ^
 --user-agent="Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36"

exit /b 0
