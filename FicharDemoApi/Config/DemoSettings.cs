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
    /// Lee del .env los datos de la demo y arma la cadena de conexion.
    /// Ni host, ni base de datos, ni usuario, ni clave aparecen en el codigo.
    /// </summary>
    public class DemoSettings
    {
        public string ConnectionString { get; }
        public string JwtKey { get; }
        public int Puerto { get; }

        public DemoSettings(IConfiguration config)
        {
            var host = Requerido(config, "DEMO_DB_HOST");
            var puerto = config["DEMO_DB_PORT"] ?? "1433";
            var bd = Requerido(config, "DEMO_DB_NAME");
            var usuario = Requerido(config, "DEMO_DB_USER");
            var clave = Requerido(config, "DEMO_DB_PASSWORD");

            ConnectionString =
                $"Data Source={host},{puerto};Initial Catalog={bd};" +
                $"User ID={usuario};Password={clave};" +
                "Integrated Security=False;Pooling=True;MultipleActiveResultSets=False;" +
                "Encrypt=False;TrustServerCertificate=True";

            JwtKey = Requerido(config, "DEMO_JWT_KEY");
            Puerto = int.TryParse(config["DEMO_API_PORT"], out var p) ? p : 5080;
        }

        private static string Requerido(IConfiguration config, string clave)
        {
            var valor = config[clave];
            if (string.IsNullOrWhiteSpace(valor))
            {
                throw new InvalidOperationException(
                    $"Falta '{clave}' en el fichero .env de la carpeta de la charla.");
            }
            return valor;
        }
    }
}
