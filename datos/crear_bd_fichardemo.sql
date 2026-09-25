/* ===========================================================================
   FicharDemo - la base de datos de la demo, desde cero
   Appeon PowerBuilder Regional Conference Spain 2026 (Barcelona, 27-10-2026)

   Crea la base FicharDemo con lo que la API necesita: cuatro tablas y el
   procedimiento `fichar`. Trae la empresa y el empleado del ponente para
   poder entrar; los fichajes empiezan vacios.

   ORDEN
     1. Este script, con un usuario administrador (sa o equivalente).
     2. crear_usuario_fichardemo.sql  -> el login que usa la API.
     3. empleados_demo.sql            -> los usuarios APPEON y PUBLICO.
     4. python datos/comprobar_bd_demo.py

   Es repetible: si algo ya existe, no lo toca.
   =========================================================================== */

USE master;
GO

IF DB_ID('FicharDemo') IS NULL
BEGIN
    CREATE DATABASE [FicharDemo];
    PRINT '>> Base de datos FicharDemo creada.';
END
GO

USE [FicharDemo];
GO

/* --- Tablas ---------------------------------------------------------------- */

IF OBJECT_ID('dbo.empresas', 'U') IS NULL
    CREATE TABLE dbo.empresas (
        empresa  char(5)  NOT NULL CONSTRAINT PK_empresas PRIMARY KEY,
        nombre   char(50) NOT NULL
    );
GO

IF OBJECT_ID('dbo.nomgenter', 'U') IS NULL
    CREATE TABLE dbo.nomgenter (
        empresa    char(5)  NOT NULL,
        codigo     char(15) NOT NULL,
        nombre     char(50) NULL,
        apellidos  char(50) NULL,
        activo     char(1)  NULL,
        CONSTRAINT PK_nomgenter PRIMARY KEY (empresa, codigo)
    );
GO

IF OBJECT_ID('dbo.Usuarios_mobile', 'U') IS NULL
    CREATE TABLE dbo.Usuarios_mobile (
        Usuario   char(15) NOT NULL CONSTRAINT PK_Usuarios_mobile PRIMARY KEY,
        Pin       char(4)  NULL,
        empresa   char(5)  NULL,
        empleado  char(5)  NULL,
        grupo     char(5)  NULL,
        activo    bit      NULL
    );
GO

/* Cada fichaje. Entrada y salida NO se guardan: se deducen del orden
   dentro del dia, igual que en el ERP. Mode 37 = fichado desde la app.   */
IF OBJECT_ID('dbo.nomregistro', 'U') IS NULL
    CREATE TABLE dbo.nomregistro (
        No        int      NOT NULL CONSTRAINT PK_nomregistro PRIMARY KEY,
        Mchn      int      NULL,
        EnNo      int      NULL,
        Name      char(25) NULL,
        Mode      int      NULL,
        IOMd      int      NULL,
        DateTime  datetime NULL,
        latitud   float    NULL,
        longitud  float    NULL
    );
GO

/* --- El procedimiento que graba un fichaje --------------------------------- */

CREATE OR ALTER PROCEDURE dbo.fichar
    @empresa   char(5),
    @empleado  char(5),
    @mode      int,
    @latitud   float,
    @longitud  float
AS
    DECLARE @id int;
    DECLARE @fecha datetime;
    DECLARE @nombre char(25);

    SET NOCOUNT ON;

    SET @fecha  = GETDATE();
    /* ISNULL: con la tabla vacia, MAX devuelve NULL */
    SET @id     = ISNULL((SELECT MAX(No) FROM nomregistro), 0) + 1;
    SET @nombre = (SELECT rtrim(Usuario) FROM Usuarios_mobile
                   WHERE empresa = @empresa AND empleado = @empleado);

    INSERT INTO nomregistro (No, Mchn, EnNo, Name, Mode, IOMd, DateTime, latitud, longitud)
    VALUES (@id, 1, @empleado, @nombre, @mode, convert(int, @empresa), @fecha, @latitud, @longitud);
GO

/* --- Datos minimos para entrar --------------------------------------------
   El usuario y el PIN coinciden con PersonDemo/Setting.ini. Son publicos a
   proposito: base de demostracion, sin un solo dato real.                  */

IF NOT EXISTS (SELECT 1 FROM empresas WHERE empresa = '1')
    INSERT INTO empresas (empresa, nombre) VALUES ('1', 'RSRSYSTEM, S.L');

MERGE nomgenter AS destino
USING (VALUES
        ('1', '15', 'RAMON',         'SAN FELIX RAMON',     'S'),
        ('1', '20', 'EMPLEADO 1-20', 'APELLIDO1 APELLIDO2', 'N'),
        ('1', '21', 'EMPLEADO 1-21', 'APELLIDO1 APELLIDO2', 'N')
      ) AS origen (empresa, codigo, nombre, apellidos, activo)
   ON  destino.empresa = origen.empresa AND destino.codigo = origen.codigo
WHEN NOT MATCHED THEN
    INSERT (empresa, codigo, nombre, apellidos, activo)
    VALUES (origen.empresa, origen.codigo, origen.nombre, origen.apellidos, origen.activo);

IF NOT EXISTS (SELECT 1 FROM Usuarios_mobile WHERE Usuario = 'RASANFE')
    INSERT INTO Usuarios_mobile (Usuario, Pin, empresa, empleado, grupo, activo)
    VALUES ('RASANFE', '0000', '1', '15', '1', 1);
GO

PRINT '--- FicharDemo lista. Siguiente: crear_usuario_fichardemo.sql ---';
GO
