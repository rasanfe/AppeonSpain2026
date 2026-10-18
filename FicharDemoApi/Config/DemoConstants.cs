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
//10-09-2026: DemoConstants.cs
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
    /// Constantes de la demo. Nada de literales sueltos por el codigo:
    /// todo lo que se puede tocar vive aqui o en el .env.
    /// </summary>
    public static class DemoConstants
    {
        /// <summary>Horas que vive el JWT de un usuario.</summary>
        public const int TokenHoras = 8;

        /// <summary>Segundos que vive el ticket de un solo uso que crea PowerBuilder.</summary>
        public const int TicketSegundos = 30;

        /// <summary>Emisor y audiencia del JWT.</summary>
        public const string JwtIssuer = "FicharDemoApi";
        public const string JwtAudience = "FicharDemo";

        /// <summary>Claims propios que viajan en el token.</summary>
        public const string ClaimEmpresa = "empresa";
        public const string ClaimEmpleado = "empleado";
        public const string ClaimGrupo = "grupo";

        /// <summary>Cliente que pidio el token: PB, WEB o MOVIL (solo para la demo, se pinta en pantalla).</summary>
        public const string ClaimOrigen = "origen";

        /// <summary>Modo con el que se graba un fichaje desde la app.</summary>
        public const int ModoFichaje = 37;

        /// <summary>
        /// Minutos que tiene el empleado para borrar un fichaje recien hecho, como
        /// en WebFichar. La web enseña un reloj mientras se puede (su copia del
        /// valor esta en WebFicharDemo/src/config/appConfig.ts: tienen que casar).
        /// </summary>
        public const int MinutosParaBorrar = 5;

        /// <summary>Terminal que graba los fichajes de la app (el Mchn del reloj).</summary>
        public const int TerminalApp = 1;

        /// <summary>
        /// Los datos: un JSON por tabla en esta carpeta de la API. Sin SQL Server,
        /// la demo arranca en cualquier maquina y sin red.
        /// </summary>
        public const string CarpetaDatos = "Database";
        public const string TablaUsuarios = "usuarios_mobile";
        public const string TablaFichajes = "nomregistro";

        /// <summary>
        /// Sufijo de la copia intacta de una tabla. Si falta la de trabajo, se crea
        /// a partir de ella; restaurar_datos_demo.bat la vuelve a copiar encima.
        /// </summary>
        public const string SufijoOriginal = ".original";
    }
}
