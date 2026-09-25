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

        /// <summary>Codigo de fichaje que usa el procedimiento almacenado 'fichar'.</summary>
        public const int ModoFichaje = 37;
    }
}
