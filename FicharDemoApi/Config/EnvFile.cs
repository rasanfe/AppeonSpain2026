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
//10-09-2026: EnvFile.cs
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
    /// Carga un fichero .env (KEY=VALOR) en la configuracion de la aplicacion.
    /// El .env vive en la carpeta del proyecto de la charla y es la UNICA fuente
    /// de credenciales: no se repiten en appsettings ni en ningun otro sitio.
    /// </summary>
    public static class EnvFile
    {
        public static void Cargar(IConfigurationBuilder config, string rutaBase)
        {
            var ruta = LocalizarEnv(rutaBase);
            if (ruta is null) return;

            var valores = new Dictionary<string, string?>();
            foreach (var linea in File.ReadAllLines(ruta))
            {
                var texto = linea.Trim();
                if (texto.Length == 0 || texto.StartsWith('#')) continue;

                var igual = texto.IndexOf('=');
                if (igual <= 0) continue;

                var clave = texto[..igual].Trim();
                var valor = texto[(igual + 1)..].Trim();
                valores[clave] = valor;
            }
            config.AddInMemoryCollection(valores);
        }

        /// <summary>Busca el .env hacia arriba desde la carpeta de ejecucion.</summary>
        private static string? LocalizarEnv(string rutaBase)
        {
            var dir = new DirectoryInfo(rutaBase);
            while (dir is not null)
            {
                var candidato = Path.Combine(dir.FullName, ".env");
                if (File.Exists(candidato)) return candidato;
                dir = dir.Parent;
            }
            return null;
        }
    }
}
