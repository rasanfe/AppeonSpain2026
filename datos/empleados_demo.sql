/* ===========================================================================
   Empleados de la demo  -  FicharDemo
   Appeon PowerBuilder Regional Conference Spain 2026

   POR QUE: la base solo traia UN usuario (RASANFE). Con uno no se puede
   enseñar el momento bueno de la charla: uno ficha en el movil y se ve
   aparecer dentro de la ventana de PowerBuilder.

   Estos PIN son publicos A PROPOSITO: es una base de datos de demostracion,
   sin un solo dato real, y los PIN se van a teclear delante de la sala.
   Ninguna credencial de verdad entra aqui.

   Repetible: si el usuario ya existe, actualiza sus datos y no duplica.
   =========================================================================== */

USE [FicharDemo];
GO

/* usuario | pin  | empresa | empleado | grupo | para que
   --------+------+---------+----------+-------+---------------------------------
   RASANFE | (ya) | 1       | 15       | 1     | el ponente: entra desde PowerBuilder
   APPEON  | 1111 | 1       | 20       | 2     | el que ficha desde el movil
   PUBLICO | 2222 | 1       | 21       | 2     | por si alguien quiere probarlo   */

MERGE Usuarios_mobile AS destino
USING (VALUES
        ('APPEON ', '1111', '1', '20', '2', 1),
        ('PUBLICO', '2222', '1', '21', '2', 1)
      ) AS origen (Usuario, Pin, empresa, empleado, grupo, activo)
   ON  destino.Usuario = origen.Usuario
WHEN MATCHED THEN
    UPDATE SET Pin      = origen.Pin,
               empresa  = origen.empresa,
               empleado = origen.empleado,
               grupo    = origen.grupo,
               activo   = origen.activo
WHEN NOT MATCHED THEN
    INSERT (Usuario, Pin, empresa, empleado, grupo, activo)
    VALUES (origen.Usuario, origen.Pin, origen.empresa, origen.empleado, origen.grupo, origen.activo);
GO

PRINT '--- Usuarios de la demo ---';
SELECT rtrim(Usuario) AS usuario, rtrim(empresa) AS empresa,
       rtrim(empleado) AS empleado, rtrim(grupo) AS grupo, activo
FROM   Usuarios_mobile
ORDER  BY empleado;
GO
