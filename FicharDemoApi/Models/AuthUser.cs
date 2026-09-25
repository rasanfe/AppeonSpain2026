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
//10-09-2026: AuthUser.cs
//Autor: Ramón San Félix Ramón
//Email: rsanfelix@rsrsystem.com
//Web:   rsrsystem.blogspot.com
//
//  Appeon PowerBuilder Regional Conference Spain 2026
//  Barcelona, 27 de octubre de 2026
//  Ponencia: «Modernizando PowerBuilder con tecnologías web»

using System.ComponentModel.DataAnnotations;

namespace FicharApi.Models
{
    /// <summary>Credenciales que llegan al login (usuario + PIN).</summary>
    public class AuthUser
    {
        [Required]
        public string? Username { get; set; }

        [Required, DataType(DataType.Password)]
        public string? Password { get; set; }

        /// <summary>Quien pide el token: PB, WEB o MOVIL. Solo para pintarlo en la demo.</summary>
        public string? Origen { get; set; }
    }

    /// <summary>Lo que devuelve el login a cualquiera de los tres clientes.</summary>
    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public DateTime Expira { get; set; }
        public string? Usuario { get; set; }
        public string? Empresa { get; set; }
        public string? Empleado { get; set; }
        public string? Grupo { get; set; }
        public string? Origen { get; set; }
    }

    /// <summary>Ticket de un solo uso que PowerBuilder le pasa a la web embebida.</summary>
    public class TicketResponse
    {
        public string Ticket { get; set; } = string.Empty;
        public int ExpiraSegundos { get; set; }
    }

    public class RedeemRequest
    {
        [Required]
        public string? Ticket { get; set; }
    }
}
