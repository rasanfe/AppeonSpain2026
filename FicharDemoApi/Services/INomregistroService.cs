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
//10-09-2026: INomregistroService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FicharApi;
using FicharApi.Models;

namespace FicharApi.Services
{
    public interface INomregistroService
    {
		Task<IEnumerable<Fichaje>> RetrieveAsync(string as_empresa, string as_empelado, DateTime? adt_fecha, CancellationToken cancellationToken);

        Task<IEnumerable<Fichaje>> RetrieveHistoricoAsync(string empresa, string empleado, DateTime desde, DateTime hasta, CancellationToken cancellationToken);

        Task FicharAsync(string empresa, string empleado, double latitud, double longitud, CancellationToken cancellationToken);

        /// <summary>
        /// Borra un fichaje PROPIO y solo dentro de los minutos que hay para
        /// arrepentirse (DemoConstants.MinutosParaBorrar).
        /// </summary>
        Task<ResultadoBorrado> BorrarFichajeAsync(int id, string empresa, string empleado, CancellationToken cancellationToken);
    }

    public enum ResultadoBorrado
    {
        Borrado,
        /// <summary>No existe, o es de otro empleado.</summary>
        NoEncontrado,
        /// <summary>Es suyo, pero ya pasaron los minutos para borrarlo.</summary>
        FueraDePlazo

    }
}