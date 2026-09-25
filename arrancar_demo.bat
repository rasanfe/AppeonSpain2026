@echo off
setlocal enabledelayedexpansion
title Fichar Demo - Appeon Regional Conference Spain 2026
cd /d "%~dp0"

echo(
echo ============================================================
echo   DEMO Appeon Spain 2026  -  Fichar dentro y fuera del ERP
echo ============================================================
echo(

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

echo [1/3] Compilando la web de React dentro de la API...
pushd WebFicharDemo
call npm run build
if errorlevel 1 (
    popd
    echo(
    echo ERROR compilando la web.
    pause
    exit /b 1
)
popd

echo(
echo [2/3] Arrancando la API ^(sirve la web y los endpoints^)...
start "API - Fichar Demo" cmd /k "cd /d "%~dp0FicharDemoApi" && dotnet run"

echo(
echo [3/3] Esperando a que la API responda...
set INTENTOS=0
:esperar
set /a INTENTOS+=1
curl -s -o nul -m 2 http://localhost:%PUERTO%/ && goto :listo
if %INTENTOS% GEQ 60 (
    echo(
    echo La API no ha respondido en 60 intentos. Mira su ventana.
    pause
    exit /b 1
)
timeout /t 1 >nul
goto :esperar

:listo
echo    La API responde. Abriendo el navegador...
start "" http://localhost:%PUERTO%/

echo(
echo ------------------------------------------------------------
echo    En esta maquina : http://localhost:%PUERTO%
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=* delims= " %%j in ("%%i") do echo    Desde el movil  : http://%%j:%PUERTO%
)
echo    Swagger         : http://localhost:%PUERTO%/swagger
echo ------------------------------------------------------------
echo(
echo    La API corre en su propia ventana. Cierrala para parar la demo.
echo    Para la vista de movil:  abrir_movil.bat
echo(
pause
