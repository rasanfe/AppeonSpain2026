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
//10-09-2026: EmpleadosService.cs
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
    public class EmpleadosService : IEmpleadosService
    {
        private readonly DataContext _dataContext;
        
        public EmpleadosService(DefaultDataContext dataContext)
        {
            _dataContext = dataContext;
        }
        public async Task<string> CompuestoEmpleadoAsync(string empresa, string empleado, CancellationToken cancellationToken)
        {
            string nombre = "";
            string apellidos = "";
            string compuesto = "";
            
            
            var sql = @"SELECT nombre,
                        apellidos
                    FROM nomgenter
                    WHERE nomgenter.empresa=@empresa
                    AND nomgenter.codigo=@empleado";
            
            var list = await _dataContext.SqlExecutor.SelectAsync<DynamicModel>(sql, empresa, empleado, cancellationToken);
            
            int rowCount = list.Count;
            
            if (rowCount > 1)
            {
                throw new Exception("La consulta SQL ha devuelto más de un resultado.");
            }
            else if (rowCount == 0)
            {
                throw new Exception("La consulta SQL no ha devuelto ningún resultado.");
            }


            nombre = list[0].GetValue<string>("nombre");
            apellidos = list[0].GetValue<string>("apellidos");
            
            if ((nombre == null) || (nombre.Trim() == ""))
            {
                nombre = "";
            }

            if ((apellidos == null) || (apellidos.Trim() == ""))
            {
                apellidos = "";
            }

            compuesto = nombre + " " + apellidos;
            
            return compuesto;
            
        }
        
    }
}
