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
//10-09-2026: DemoSettings.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»


namespace FicharApi.Config
{
    /// <summary>
    /// Lee del .env los datos de la demo y localiza la carpeta de los datos.
    /// No hay base de datos: las tablas son ficheros JSON (como en PowerBuilder).
    /// </summary>
    public class DemoSettings
    {
        public string CarpetaDatos { get; }
        public string JwtKey { get; }
        public int Puerto { get; }

        public DemoSettings(IConfiguration config, string rutaBase)
        {
            CarpetaDatos = LocalizarDatos(rutaBase);
            JwtKey = Requerido(config, "DEMO_JWT_KEY");
            Puerto = int.TryParse(config["DEMO_API_PORT"], out var p) ? p : 5080;
        }

        /// <summary>La carpeta Database de la API, buscada hacia arriba (sirve igual desde bin).</summary>
        private static string LocalizarDatos(string rutaBase)
        {
            var dir = EnvFile.BuscarHaciaArriba(rutaBase, ruta => File.Exists(
                Path.Combine(ruta, DemoConstants.CarpetaDatos, DemoConstants.TablaUsuarios + ".json")));

            return dir is null
                ? throw new InvalidOperationException(
                    $"No se encuentra la carpeta '{DemoConstants.CarpetaDatos}' con los datos de la demo.")
                : Path.Combine(dir, DemoConstants.CarpetaDatos);
        }

        private static string Requerido(IConfiguration config, string nombre)
        {
            var valor = config[nombre];
            if (string.IsNullOrWhiteSpace(valor))
            {
                throw new InvalidOperationException(
                    $"Falta '{nombre}' en el fichero .env de la carpeta de la charla.");
            }
            return valor;
        }
    }
}
