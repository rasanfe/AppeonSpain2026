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
//10-09-2026: NomregistroService.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using FicharApi.Config;
using FicharApi.Data;
using FicharApi.Models;

namespace FicharApi.Services.Impl
{
    public class NomregistroService : INomregistroService
    {
        private readonly JsonDatabase _db;

        public NomregistroService(JsonDatabase db)
        {
            _db = db;
        }

        /// <summary>Los fichajes de un dia, en orden. Sin empleado, los de toda la empresa.</summary>
        public async Task<IEnumerable<Fichaje>> RetrieveAsync(string as_empresa, string as_empelado, DateTime? adt_fecha, CancellationToken cancellationToken)
		{
            if (adt_fecha is null) return Enumerable.Empty<Fichaje>();

            return await RetrieveHistoricoAsync(as_empresa, as_empelado, adt_fecha.Value, adt_fecha.Value, cancellationToken);
		}

        /// <summary>
        /// Los fichajes de un rango de dias (ambos incluidos), en orden: el historial del mes.
        ///
        /// Los que todavia no han pasado NO salen: los datos de la demo llegan
        /// generados hasta el dia de la charla, y un fichaje del futuro no existe.
        /// Asi cada dia de ensayo se ve como una jornada real hasta la hora actual.
        /// </summary>
        public async Task<IEnumerable<Fichaje>> RetrieveHistoricoAsync(string empresa, string empleado, DateTime desde, DateTime hasta, CancellationToken cancellationToken)
        {
            var fichajes = await _db.LeerAsync<Nomregistro>(DemoConstants.TablaFichajes, cancellationToken);
            var ahora = DateTime.Now;

            return fichajes
                .Where(f => Texto.Igual(f.IOMd, empresa))
                .Where(f => string.IsNullOrWhiteSpace(empleado) || Texto.Igual(f.EnNo, empleado))
                .Where(f => f.Fecha?.Date >= desde.Date && f.Fecha?.Date <= hasta.Date)
                .Where(f => f.Fecha <= ahora)
                .OrderBy(f => f.Fecha)
                .Select(Fichaje.Desde)
                .ToList();
        }

        /// <summary>Lo que hacia el procedimiento almacenado 'fichar' de 2024.</summary>
        public async Task FicharAsync(string empresa, string empleado, double latitud, double longitud, CancellationToken cancellationToken)
        {
            var usuarios = await _db.LeerAsync<Usuarios>(DemoConstants.TablaUsuarios, cancellationToken);
            var nombre = usuarios
                .FirstOrDefault(u => Texto.Igual(u.Empresa, empresa) && Texto.Igual(u.Empleado, empleado))
                ?.Usuario?.Trim();

            if (!int.TryParse(empresa?.Trim(), out var numEmpresa) || !int.TryParse(empleado?.Trim(), out var numEmpleado))
            {
                throw new Exception($"Empresa '{empresa}' o empleado '{empleado}' no validos.");
            }

            await _db.ModificarAsync<Nomregistro>(DemoConstants.TablaFichajes, fichajes =>
            {
                fichajes.Add(new Nomregistro
                {
                    No = fichajes.Count == 0 ? 1 : fichajes.Max(f => f.No) + 1,
                    Mchn = DemoConstants.TerminalApp,
                    EnNo = numEmpleado,
                    Name = nombre,
                    Mode = DemoConstants.ModoFichaje,
                    IOMd = numEmpresa,
                    Fecha = AhoraSinZona(),
                    Latitud = latitud,
                    Longitud = longitud
                });
            }, cancellationToken);
        }

        public async Task<ResultadoBorrado> BorrarFichajeAsync(int id, string empresa, string empleado, CancellationToken cancellationToken)
        {
            var resultado = ResultadoBorrado.NoEncontrado;

            await _db.ModificarAsync<Nomregistro>(DemoConstants.TablaFichajes, fichajes =>
            {
                var fichaje = fichajes.FirstOrDefault(f => f.No == id && EsDe(f, empresa, empleado));
                if (fichaje is null) return;

                if (!DentroDelPlazo(fichaje))
                {
                    resultado = ResultadoBorrado.FueraDePlazo;
                    return;
                }

                fichajes.Remove(fichaje);
                resultado = ResultadoBorrado.Borrado;
            }, cancellationToken);

            return resultado;
        }

        /// <summary>
        /// Se fichó hace menos de DemoConstants.MinutosParaBorrar. Lo decide la API,
        /// no la web: el reloj de la pantalla es solo el aviso.
        /// </summary>
        private static bool DentroDelPlazo(Nomregistro fichaje) =>
            fichaje.Fecha is { } fecha
            && fecha <= DateTime.Now   // uno de los generados para mas adelante no se toca
            && DateTime.Now - fecha <= TimeSpan.FromMinutes(DemoConstants.MinutosParaBorrar);

        /// <summary>El fichaje es de ese empleado de esa empresa.</summary>
        private static bool EsDe(Nomregistro fichaje, string empresa, string empleado) =>
            Texto.Igual(fichaje.IOMd, empresa) && Texto.Igual(fichaje.EnNo, empleado);

        /// <summary>
        /// La hora local tal cual, sin zona y al milisegundo (como el datetime de
        /// SQL Server): asi viaja a la web igual que los fichajes de antes.
        /// </summary>
        private static DateTime AhoraSinZona()
        {
            var ahora = DateTime.Now;
            return new DateTime(ahora.Ticks - ahora.Ticks % TimeSpan.TicksPerMillisecond, DateTimeKind.Unspecified);
        }
    }
}
