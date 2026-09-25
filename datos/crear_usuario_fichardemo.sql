/* ===========================================================================
   FicharDemo - usuario de la base de datos de la demo
   Appeon PowerBuilder Regional Conference Spain 2026 (Barcelona, 27-10-2026)

   Crea el login [fichar], que SOLO puede trabajar contra FicharDemo:
   ni ve ni toca ninguna otra base de datos del servidor.

   CUANDO SE USA
     - Una vez, despues de restaurar la base FicharDemo en tu SQL Server.
       Es el unico paso de permisos.

   COMO SE USA
     1. Sustituir <PON-AQUI-LA-CLAVE> (aparece DOS veces: CREATE y ALTER)
        por la contrasena de la demo.
     2. Ejecutarlo con un usuario administrador (sa o equivalente).
     3. Poner ESE mismo usuario y clave en el .env de la carpeta de la charla:
            DEMO_DB_HOST=<servidor>
            DEMO_DB_PORT=<puerto>
            DEMO_DB_NAME=FicharDemo
            DEMO_DB_USER=fichar
            DEMO_DB_PASSWORD=...
        El .env es el UNICO sitio donde vive la clave: NO la dejes guardada aqui.
     4. Comprobar que quedo bien:  python datos/comprobar_bd_demo.py

   DOS COSAS QUE YA NOS MORDIERON (por eso el script es como es)
     - La clave de la demo no cumple la politica de complejidad de Windows:
       por eso CHECK_POLICY = OFF.
     - En FicharDemo ya existia un usuario 'fichar' HUERFANO (de la demo de
       2024, usuario sin login): hay que re-vincularlo con ALTER USER, no
       crearlo otra vez.

   Es repetible: si algo ya existe, no falla.
   =========================================================================== */

USE master;
GO

/* --- 1. El login ---------------------------------------------------------
   CHECK_POLICY = OFF: es una base de datos de DEMO en la red local, y asi
   la clave no tiene que cumplir la politica de complejidad de Windows.
   Si prefieres exigirla, pon ON y usa una clave de 8+ con mayusculas,
   minusculas y digitos o simbolos.                                        */

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'fichar')
BEGIN
    CREATE LOGIN [fichar]
        WITH PASSWORD        = '<PON-AQUI-LA-CLAVE>',
             DEFAULT_DATABASE = [FicharDemo],
             CHECK_POLICY     = OFF;
    PRINT '>> Login [fichar] creado.';
END
ELSE
BEGIN
    /* Ya existia: le ponemos la clave del .env, por si no coincide */
    ALTER LOGIN [fichar] WITH PASSWORD = '<PON-AQUI-LA-CLAVE>', CHECK_POLICY = OFF;
    ALTER LOGIN [fichar] ENABLE;
    PRINT '>> El login [fichar] ya existia: clave actualizada y habilitado.';
END
GO

/* Si el paso 1 fallo, no seguimos a ciegas */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'fichar')
BEGIN
    RAISERROR('NO se ha creado el login [fichar]. Revisa el error de arriba (clave o permisos).', 20, 1) WITH LOG;
END
GO

/* --- 2. Que no pueda ni LISTAR las demas bases de datos ------------------ */
DENY VIEW ANY DATABASE TO [fichar];
GO

/* --- 3. El usuario dentro de FicharDemo ----------------------------------
   OJO: en esta base ya habia un usuario 'fichar' de la demo de 2024, huerfano
   (usuario sin login). Crearlo otra vez falla; hay que RE-VINCULARLO.      */

USE [FicharDemo];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'fichar')
BEGIN
    CREATE USER [fichar] FOR LOGIN [fichar];
    PRINT '>> Usuario [fichar] creado en FicharDemo.';
END
ELSE
BEGIN
    ALTER USER [fichar] WITH LOGIN = [fichar];   -- adopta el usuario huerfano
    PRINT '>> Usuario [fichar] ya existia: re-vinculado al login.';
END
GO

/* --- 4. Permisos ---------------------------------------------------------
   db_owner: manda dentro de FicharDemo y SOLO dentro de FicharDemo.
   Para el minimo imprescindible, comenta el db_owner y usa las tres de abajo. */

ALTER ROLE [db_owner] ADD MEMBER [fichar];
GO

-- ALTER ROLE [db_datareader] ADD MEMBER [fichar];
-- ALTER ROLE [db_datawriter] ADD MEMBER [fichar];
-- GRANT EXECUTE ON SCHEMA::dbo TO [fichar];
-- GO

/* --- 5. Comprobacion: como ha quedado ------------------------------------ */
PRINT '--- Roles del usuario en FicharDemo ---';
SELECT  p.name AS usuario, r.name AS rol
FROM    sys.database_role_members m
        JOIN sys.database_principals r ON r.principal_id = m.role_principal_id
        JOIN sys.database_principals p ON p.principal_id = m.member_principal_id
WHERE   p.name = 'fichar';

PRINT '--- Login vinculado (huerfano = 0 filas) ---';
SELECT  dp.name AS usuario_bd, sp.name AS login_servidor, sp.is_disabled
FROM    sys.database_principals dp
        JOIN sys.server_principals sp ON sp.sid = dp.sid
WHERE   dp.name = 'fichar';
GO

/* --- 6. Lo que la API espera encontrar en esta base de datos -------------- */
PRINT '--- Objetos que necesita la API (1 = esta, 0 = falta) ---';
SELECT 'nomregistro'     AS objeto, COUNT(*) AS existe FROM sys.objects WHERE name = 'nomregistro'     AND type IN ('U','V')
UNION ALL
SELECT 'Usuarios_mobile',           COUNT(*)           FROM sys.objects WHERE name = 'Usuarios_mobile' AND type IN ('U','V')
UNION ALL
SELECT 'fichar (proc)',             COUNT(*)           FROM sys.objects WHERE name = 'fichar'          AND type = 'P';
GO
