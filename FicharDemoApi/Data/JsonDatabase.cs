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
//17-10-2026: JsonDatabase.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.Text.Encodings.Web;
using System.Text.Json;
using FicharApi.Config;

namespace FicharApi.Data
{
    /// <summary>
    /// La "base de datos" de la demo: un JSON por tabla en la carpeta Database,
    /// igual que la app de PowerBuilder trabaja con sus ficheros. Sin SQL Server.
    ///
    /// Los tres clientes (PowerBuilder, navegador y movil) escriben a la vez, pero
    /// todos pasan por esta API, que es un solo proceso: con un cerrojo basta.
    /// Cada peticion lee del disco, asi que restaurar_datos_demo.bat puede dejar
    /// los fichajes como estaban con la API arrancada.
    /// </summary>
    public class JsonDatabase
    {
        private static readonly JsonSerializerOptions Formato = new()
        {
            WriteIndented = true,
            PropertyNameCaseInsensitive = true,
            // Que las tildes queden legibles en el fichero, no como é
            Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
        };

        private readonly SemaphoreSlim _cerrojo = new(1, 1);
        private readonly string _carpeta;

        public JsonDatabase(DemoSettings ajustes)
        {
            _carpeta = ajustes.CarpetaDatos;
        }

        /// <summary>Todas las filas de una tabla.</summary>
        public async Task<List<T>> LeerAsync<T>(string tabla, CancellationToken cancellationToken)
        {
            await _cerrojo.WaitAsync(cancellationToken);
            try
            {
                return await LeerFicheroAsync<T>(tabla, cancellationToken);
            }
            finally
            {
                _cerrojo.Release();
            }
        }

        /// <summary>
        /// Lee la tabla, le aplica el cambio y la graba entera, sin que nadie
        /// escriba en medio. Si el cambio lanza una excepcion, no se graba nada.
        /// </summary>
        public async Task ModificarAsync<T>(string tabla, Action<List<T>> cambio, CancellationToken cancellationToken)
        {
            await _cerrojo.WaitAsync(cancellationToken);
            try
            {
                var filas = await LeerFicheroAsync<T>(tabla, cancellationToken);
                cambio(filas);
                await GrabarFicheroAsync(tabla, filas, cancellationToken);
            }
            finally
            {
                _cerrojo.Release();
            }
        }

        private async Task<List<T>> LeerFicheroAsync<T>(string tabla, CancellationToken cancellationToken)
        {
            var ruta = PrepararFichero(tabla);
            await using var fichero = File.OpenRead(ruta);
            return await JsonSerializer.DeserializeAsync<List<T>>(fichero, Formato, cancellationToken) ?? new List<T>();
        }

        /// <summary>
        /// Se escribe en un temporal y se cambia de golpe: si algo falla a mitad,
        /// la tabla sigue entera (un JSON cortado deja la demo sin datos).
        /// </summary>
        private async Task GrabarFicheroAsync<T>(string tabla, List<T> filas, CancellationToken cancellationToken)
        {
            var ruta = Ruta(tabla);
            var temporal = ruta + ".tmp";

            await using (var fichero = File.Create(temporal))
            {
                await JsonSerializer.SerializeAsync(fichero, filas, Formato, cancellationToken);
            }
            File.Move(temporal, ruta, overwrite: true);
        }

        /// <summary>
        /// La tabla de trabajo. Si no existe, nace de su copia intacta (.original):
        /// asi lo que se ficha en los ensayos no ensucia lo que va al repositorio.
        /// </summary>
        private string PrepararFichero(string tabla)
        {
            var ruta = Ruta(tabla);
            var original = Path.Combine(_carpeta, tabla + DemoConstants.SufijoOriginal + ".json");

            if (!File.Exists(ruta) && File.Exists(original))
            {
                File.Copy(original, ruta);
            }
            return File.Exists(ruta)
                ? ruta
                : throw new FileNotFoundException($"Falta la tabla '{tabla}' en {_carpeta}.");
        }

        private string Ruta(string tabla) => Path.Combine(_carpeta, tabla + ".json");
    }
}
