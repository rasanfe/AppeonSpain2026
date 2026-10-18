@echo off
title Fichar Demo - restaurar los datos de la demo
cd /d "%~dp0"

echo(
echo Deja los datos de la demo como estaban antes de trastear:
echo   - las facturas de PowerBuilder      (PersonDemo\Database\data2026.json)
echo   - los usuarios del ERP              (PersonDemo\Database\usuarios.json)
echo   - los fichajes de la app            (FicharDemoApi\Database\nomregistro.json)
echo Las altas, bajas, modificaciones y fichajes de las pruebas se pierden.
echo Se puede hacer con la API arrancada: lee los ficheros en cada peticion.
echo(

call :restaurar "PersonDemo\Database\data2026.original.json" "PersonDemo\Database\data2026.json" || goto :error
call :restaurar "PersonDemo\Database\usuarios.original.json" "PersonDemo\Database\usuarios.json" || goto :error
call :restaurar "FicharDemoApi\Database\nomregistro.original.json" "FicharDemoApi\Database\nomregistro.json" || goto :error

echo Datos restaurados.
echo(
timeout /t 3 >nul
exit /b 0

:restaurar
if not exist "%~1" (
    echo No hay copia de seguridad: %~1
    exit /b 1
)
copy /y "%~1" "%~2" >nul
if errorlevel 1 (
    echo No se ha podido restaurar: %~2
    exit /b 1
)
echo   OK  %~2
exit /b 0

:error
echo(
echo No se ha podido restaurar todo.
pause
exit /b 1
