//╔═════════════════════════════════════════════════════════════════════════════════╗
//║                                                                                 ║
//║  ██████╗ ███████╗██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗  ║
//║  ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║  ║
//║  ██████╔╝███████╗██████╔╝███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║  ║
//║  ██╔══██╗╚════██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║  ║
//║  ██║  ██║███████║██║  ██║███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║  ║
//║  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝  ║
//║                                                                                 ║
//╚═════════════════════════════════════════════════════════════════════════════════╝
//
//10-09-2026: UsuariosService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SnapObjects.Data;

namespace FicharApi.Services.Impl
{
    public class UsuariosService : IUsuariosService
    {
        private readonly DataContext _dataContext;
        
        public UsuariosService(DefaultDataContext dataContext)
        {
            _dataContext = dataContext;
        }
        public async Task<string> EmpresaUsuarioAsync(string usuario, CancellationToken cancellationToken)
        {
            string empresa = "";
            
            
            var sql = @"SELECT empresa
                    FROM Usuarios_mobile
                    WHERE Usuarios_mobile.usuario=@usuario";

            empresa = await _dataContext.SqlExecutor.ScalarAsync<string>(sql, usuario, cancellationToken);

            if ((empresa == null) || (empresa.Trim() == ""))
            {
                empresa = "";
            }

            return empresa;

        }

        public async Task<string> GrupoUsuarioAsync(string usuario, CancellationToken cancellationToken)
        {
            string grupo = "";


            var sql = @"SELECT grupo
                    FROM Usuarios_mobile
                    WHERE Usuarios_mobile.usuario=@usuario";

            grupo = await _dataContext.SqlExecutor.ScalarAsync<string>(sql, usuario, cancellationToken);

            if ((grupo == null) || (grupo.Trim() == ""))
            {
                grupo = "";
            }

            return grupo;
        }

        public async Task<string> EmpleadoUsuarioAsync(string usuario, CancellationToken cancellationToken)
        {
            string empleado = "";


            var sql = @"SELECT empleado
                    FROM Usuarios_mobile
                    WHERE Usuarios_mobile.usuario=@usuario
                    AND activo = 1";

            empleado = await _dataContext.SqlExecutor.ScalarAsync<string>(sql, usuario, cancellationToken);

            if ((empleado == null) || (empleado.Trim() == ""))
            {
                empleado = "";
            }

            return empleado;
            
        }
        
        public async Task<string> UsuarioEmpleadoAsync(string empresa, string empleado, CancellationToken cancellationToken)
        {
            string usuario = "";


            var sql = @"SELECT usuario
                    FROM Usuarios_mobile
                    WHERE Usuarios_mobile.empresa=@empresa
                    AND Usuarios_mobile.empleado=@empleado";

            usuario = await _dataContext.SqlExecutor.ScalarAsync<string>(sql, empresa, empleado, cancellationToken);

            if ((usuario == null) || (usuario.Trim() == ""))
            {
                usuario = "";
            }

            return usuario;

        }
        
        
    }
}
