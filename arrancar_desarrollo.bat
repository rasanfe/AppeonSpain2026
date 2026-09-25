@echo off
setlocal enabledelayedexpansion
title Fichar Demo - DESARROLLO
cd /d "%~dp0"

echo(
echo ============================================================
echo   DESARROLLO  -  API + Vite con recarga en caliente
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

echo Arrancando la API en el puerto %PUERTO% ...
start "API - FicharDemoApi" cmd /k "cd /d "%~dp0FicharDemoApi" && dotnet run"

echo Arrancando Vite ^(la web, con recarga^) ...
start "WEB - WebFicharDemo" cmd /k "cd /d "%~dp0WebFicharDemo" && npm run dev"

echo(
echo Esperando a que Vite responda...
set INTENTOS=0
:esperar
set /a INTENTOS+=1
curl -s -o nul -m 2 http://localhost:5173/ && goto :listo
if %INTENTOS% GEQ 60 (
    echo Vite no ha respondido. Mira su ventana.
    pause
    exit /b 1
)
timeout /t 1 >nul
goto :esperar

:listo
start "" http://localhost:5173/

echo(
echo    Web (desarrollo) : http://localhost:5173
echo    API              : http://localhost:%PUERTO%   ^(y /swagger^)
echo(
echo    Se han abierto dos ventanas. Cierralas para parar.
echo(
timeout /t 6 >nul
