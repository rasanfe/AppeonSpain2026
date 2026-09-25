@echo off
title Fichar Demo - restaurar los datos de la demo
cd /d "%~dp0"

echo(
echo Restaura data2026.json tal y como estaba antes de trastear
echo (altas, bajas y modificaciones de las pruebas se pierden).
echo(

if not exist "PersonDemo\data2026.original.json" (
    echo No hay copia de seguridad: PersonDemo\data2026.original.json
    pause
    exit /b 1
)

copy /y "PersonDemo\data2026.original.json" "PersonDemo\data2026.json" >nul
if errorlevel 1 (
    echo No se ha podido restaurar.
    pause
    exit /b 1
)

echo Datos restaurados.
echo(
timeout /t 3 >nul
